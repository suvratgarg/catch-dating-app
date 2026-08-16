import {createHash} from "crypto";
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from
  "../shared/callableOptions";
import {GetOrganizerContactDetailCallablePayload} from
  "../shared/generated/getOrganizerContactDetailCallablePayload";
import {GetOrganizerContactDetailCallableResponse} from
  "../shared/generated/getOrganizerContactDetailCallableResponse";
import {CreateOrganizerContactCallablePayload} from
  "../shared/generated/createOrganizerContactCallablePayload";
import {CreateOrganizerContactCallableResponse} from
  "../shared/generated/createOrganizerContactCallableResponse";
import {CreateOrganizerContactNoteCallablePayload} from
  "../shared/generated/createOrganizerContactNoteCallablePayload";
import {ExportOrganizerContactsCallablePayload} from
  "../shared/generated/exportOrganizerContactsCallablePayload";
import {ExportOrganizerContactsCallableResponse} from
  "../shared/generated/exportOrganizerContactsCallableResponse";
import {MutateOrganizerContactCallablePayload} from
  "../shared/generated/mutateOrganizerContactCallablePayload";
import {MutateOrganizerContactCallableResponse} from
  "../shared/generated/mutateOrganizerContactCallableResponse";
import {MutateOrganizerContactNoteCallablePayload} from
  "../shared/generated/mutateOrganizerContactNoteCallablePayload";
import {OrganizerContactNoteCallableResponse} from
  "../shared/generated/organizerContactNoteCallableResponse";
import {
  OrganizerAudienceSummaryDocument,
  OrganizerBroadcastSummaryDocument,
  OrganizerCampaignDocument,
  OrganizerCampaignRecipientDocument,
  OrganizerContactDocument,
  OrganizerContactChannelStateDocument,
  OrganizerContactEventEdgeDocument,
  OrganizerContactMergeReceiptDocument,
  OrganizerContactNoteDocument,
  OrganizerContactTagVocabularyDocument,
  OrganizerContactTraitDocument,
  PaymentDocument,
} from "../shared/generated/firestoreAdminTypes";
import {ListOrganizerContactsCallablePayload} from
  "../shared/generated/listOrganizerContactsCallablePayload";
import {ListOrganizerContactsCallableResponse} from
  "../shared/generated/listOrganizerContactsCallableResponse";
import {
  validateExportOrganizerContactsCallablePayload,
  validateCreateOrganizerContactNoteCallablePayload,
  validateCreateOrganizerContactCallablePayload,
  validateGetOrganizerContactDetailCallablePayload,
  validateListOrganizerContactsCallablePayload,
  validateMutateOrganizerContactCallablePayload,
  validateMutateOrganizerContactNoteCallablePayload,
} from "../shared/generated/schemaValidators";
import {requireOrganizerManager} from
  "../shared/organizerManagerAuthority";
import {checkRateLimit} from "../shared/rateLimit";
import {validateCallableWithAjv} from "../shared/validation";
import {organizerContactChannelStateId} from "./organizerCampaignModel";

const defaultContactPageSize = 50;
const maxDetailEvents = 100;
const maxDetailNotes = 100;
const maxDetailSends = 100;
const maxDetailMergeReceipts = 500;
const maxExportContacts = 2500;
const maxContactPayments = 500;
const maxOrganizerManualTags = 20;
const maxContactManualTags = 5;
const maxSortedCandidateScan = 2500;

type ContactSort = NonNullable<ListOrganizerContactsCallablePayload["sort"]>;

interface OrganizerContactsDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
}

const defaultDeps: OrganizerContactsDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
};

interface ContactCursor {
  version: 2;
  organizerId: string;
  plan: "people" | "search" | "segment" | "manualTag";
  sort: ContactSort;
  search: string | null;
  value: string;
  contactId: string;
  segmentId: string | null;
  manualTagId: string | null;
}

/** Lists one manager's organizer contacts with indexed, opaque pagination. */
export async function listOrganizerContactsHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerContactsDeps = defaultDeps
): Promise<ListOrganizerContactsCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<ListOrganizerContactsCallablePayload>(
    request,
    validateListOrganizerContactsCallablePayload,
    normalizeListContactsPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "listOrganizerContacts");
  await requireOrganizerManager({
    db,
    organizerId: data.organizerId,
    actorUid,
  });
  if (data.segmentId && data.manualTagId) {
    throw new HttpsError(
      "invalid-argument",
      "Choose either a computed segment or a manual tag, not both."
    );
  }
  const [summarySnap, tagVocabularySnap] = await Promise.all([
    db.collection("organizerAudienceSummaries").doc(data.organizerId).get(),
    db.collection("organizerContactTagVocabularies")
      .doc(data.organizerId).get(),
  ]);
  const summary = summarySnap.data() as
    OrganizerAudienceSummaryDocument | undefined;
  const tagVocabulary = tagVocabularySnap.data() as
    OrganizerContactTagVocabularyDocument | undefined;
  const manualTagVocabulary = safeManualTagVocabulary(
    data.organizerId,
    tagVocabulary
  );
  const manualTagsById = new Map(
    manualTagVocabulary.map((tag) => [tag.tagId, tag])
  );
  const limit = data.limit ?? defaultContactPageSize;
  const search = normalizeSearch(data.query ?? null);
  const cursor = decodeContactCursor(data.cursor ?? null);
  const sort = data.sort ?? "lastSeen";
  const exactMatchCountPromise = exactListContactsMatchCount({
    db,
    organizerId: data.organizerId,
    segmentId: data.segmentId ?? null,
    manualTagId: data.manualTagId ?? null,
    search,
    summary,
  });

  const sortedPage = await listSortedContactDocuments({
    db,
    organizerId: data.organizerId,
    search,
    segmentId: data.segmentId ?? null,
    manualTagId: data.manualTagId ?? null,
    sort,
    cursor,
    limit,
  });
  const contacts = sortedPage.contacts;
  const traitSnaps = contacts.length === 0 ? [] : await db.getAll(
    ...contacts.map((item) => db.collection("organizerContactTraits")
      .doc(item.id))
  );
  const traitsById = new Map(traitSnaps
    .filter((snap) => snap.exists)
    .map((snap) => [snap.id, snap.data() as OrganizerContactTraitDocument]));
  const channelSnaps = contacts.length === 0 ? [] : await db.getAll(
    ...contacts.map((item) => db.collection("organizerContactChannelStates")
      .doc(organizerContactChannelStateId(data.organizerId, item.id)))
  );
  const channelByContactId = new Map(channelSnaps
    .filter((snap) => snap.exists)
    .map((snap) => {
      const state = snap.data() as OrganizerContactChannelStateDocument;
      return [state.contactId, state] as const;
    }));
  const rows = contacts
    .map((item) => safeContactRow(
      item.id,
      item.data,
      traitsById.get(item.id),
      channelByContactId.get(item.id),
      manualTagsById
    ))
    .filter((item): item is NonNullable<typeof item> => item !== null);
  const pageRows = rows;
  const finalContact = contacts.at(-1);
  const nextCursor = sortedPage.hasMore && finalContact ?
    encodeContactCursor({
      version: 2,
      organizerId: data.organizerId,
      plan: contactQueryPlan({
        segmentId: data.segmentId ?? null,
        manualTagId: data.manualTagId ?? null,
        search,
      }),
      sort,
      search,
      value: sortedPage.lastValue!,
      contactId: finalContact.id,
      segmentId: data.segmentId ?? null,
      manualTagId: data.manualTagId ?? null,
    }) : null;
  const exactMatchCount = await exactMatchCountPromise;
  const countResult = listContactsMatchCountResult(
    exactMatchCount,
    pageRows.length
  );

  return {
    organizerId: data.organizerId,
    contacts: pageRows,
    nextCursor,
    ...countResult,
    manualTagVocabulary,
    sourceCoverage: summary?.sourceCoverage ?? "partial",
    projectionVersion: summary?.projectionVersion ?? 1,
  };
}

export function listContactsMatchCountResult(
  exactMatchCount: number | null,
  visiblePageCount: number
): Pick<ListOrganizerContactsCallableResponse,
  "matchCount" | "matchCountCoverage"> {
  return exactMatchCount === null ? {
    matchCount: visiblePageCount,
    matchCountCoverage: "atLeast",
  } : {
    matchCount: exactMatchCount,
    matchCountCoverage: "exact",
  };
}

async function exactListContactsMatchCount(params: {
  db: FirebaseFirestore.Firestore;
  organizerId: string;
  segmentId: OrganizerContactTraitDocument["segmentIds"][number] | null;
  manualTagId: string | null;
  search: string | null;
  summary: OrganizerAudienceSummaryDocument | undefined;
}): Promise<number | null> {
  if (params.search) return null;
  if (params.manualTagId) {
    const snapshot = await params.db.collection("organizerContacts")
      .where("organizerId", "==", params.organizerId)
      .where("deletedAt", "==", null)
      .where("hiddenAt", "==", null)
      .where("manualTagIds", "array-contains", params.manualTagId)
      .count()
      .get();
    return snapshot.data().count;
  }
  if (!params.segmentId) return params.summary?.contactCount ?? null;
  const snapshot = await params.db.collection("organizerContactTraits")
    .where("organizerId", "==", params.organizerId)
    .where("segmentIds", "array-contains", params.segmentId)
    .count()
    .get();
  return snapshot.data().count;
}

/** Creates a name-only organizer CRM contact without inventing identity. */
export async function createOrganizerContactHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerContactsDeps = defaultDeps
): Promise<CreateOrganizerContactCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<CreateOrganizerContactCallablePayload>(
    request,
    validateCreateOrganizerContactCallablePayload,
    normalizeCreateContactPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "mutateOrganizerContact");
  await requireOrganizerManager({db, organizerId: data.organizerId, actorUid});

  const now = admin.firestore.Timestamp.now();
  const contactRef = db.collection("organizerContacts").doc();
  const traitRef = db.collection("organizerContactTraits").doc(contactRef.id);
  const summaryRef = db.collection("organizerAudienceSummaries")
    .doc(data.organizerId);
  const revision = Math.max(1, now.toMillis());
  const trait: OrganizerContactTraitDocument = {
    organizerId: data.organizerId,
    contactId: contactRef.id,
    expectedEventCount: 0,
    attendedEventCount: 0,
    cancelledEventCount: 0,
    noShowCount: 0,
    importedEventCount: 0,
    referredRegistrationCount: 0,
    referredCheckedInCount: 0,
    referredCheckedIn365DayCount: 0,
    linkedAccount: false,
    firstSeenAt: now,
    lastSeenAt: now,
    firstAttendedAt: null,
    lastAttendedAt: null,
    attendanceRate: null,
    segmentIds: ["new_to_organizer"],
    definitionVersion: 2,
    whatsappStatus: "unknown",
    smsStatus: "unknown",
    sourceCoverage: "exact",
    projectionVersion: 1,
    computedAt: now,
  };
  const contact: OrganizerContactDocument = {
    organizerId: data.organizerId,
    displayName: data.displayName,
    displayNameOverride: null,
    searchName: data.displayName.toLocaleLowerCase("en"),
    linkedUid: null,
    phoneE164: null,
    email: null,
    identityState: "unlinked",
    identityConfidence: "eventOnly",
    primarySource: "hostManual",
    ambiguousCandidateContactIds: [],
    firstSeenAt: now,
    lastSeenAt: now,
    sourceCount: 1,
    whatsappStatus: "unknown",
    smsStatus: "unknown",
    manualTagIds: [],
    revision,
    mergedIntoContactId: null,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    hiddenAt: null,
    hiddenBy: null,
    hiddenTraitSnapshot: null,
  };

  await db.runTransaction(async (tx) => {
    const summarySnap = await tx.get(summaryRef);
    tx.create(contactRef, contact);
    tx.create(traitRef, trait);
    tx.set(summaryRef, summaryWithTrait(
      data.organizerId,
      summarySnap.data() as OrganizerAudienceSummaryDocument | undefined,
      trait,
      now
    ));
  });
  return {
    organizerId: data.organizerId,
    contactId: contactRef.id,
    displayName: data.displayName,
    revision,
  };
}

/** Returns one manager-only contact record and its bounded event timeline. */
export async function getOrganizerContactDetailHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerContactsDeps = defaultDeps
): Promise<GetOrganizerContactDetailCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<
    GetOrganizerContactDetailCallablePayload
  >(
    request,
    validateGetOrganizerContactDetailCallablePayload,
    normalizeContactDetailPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "getOrganizerContactDetail");
  await requireOrganizerManager({
    db,
    organizerId: data.organizerId,
    actorUid,
  });
  const contactRef = db.collection("organizerContacts").doc(data.contactId);
  const traitRef = db.collection("organizerContactTraits").doc(data.contactId);
  const channelRef = db.collection("organizerContactChannelStates").doc(
    organizerContactChannelStateId(data.organizerId, data.contactId)
  );
  const [
    contactSnap,
    traitSnap,
    eventSnap,
    channelSnap,
    noteSnap,
    recipientSnap,
    broadcastSnap,
    tagVocabularySnap,
    mergeReceiptSnap,
  ] = await Promise.all([
    contactRef.get(),
    traitRef.get(),
    db.collection("organizerContactEventEdges")
      .where("contactId", "==", data.contactId)
      .orderBy("eventStartAt", "desc")
      .limit(maxDetailEvents + 1)
      .get(),
    channelRef.get(),
    db.collection("organizerContactNotes")
      .where("organizerId", "==", data.organizerId)
      .where("contactId", "==", data.contactId)
      .orderBy("createdAt", "desc")
      .orderBy(admin.firestore.FieldPath.documentId(), "desc")
      .limit(maxDetailNotes + 1)
      .get(),
    db.collection("organizerCampaignRecipients")
      .where("organizerId", "==", data.organizerId)
      .where("contactId", "==", data.contactId)
      .orderBy("createdAt", "desc")
      .orderBy(admin.firestore.FieldPath.documentId(), "desc")
      .limit(maxDetailSends + 1)
      .get(),
    db.collection("organizerBroadcastSummaries")
      .where("recipientContactIds", "array-contains", data.contactId)
      .get(),
    db.collection("organizerContactTagVocabularies")
      .doc(data.organizerId).get(),
    db.collection("organizerContactMergeReceipts")
      .where("organizerId", "==", data.organizerId)
      .where("survivorContactId", "==", data.contactId)
      .orderBy("createdAt", "desc")
      .orderBy(admin.firestore.FieldPath.documentId(), "desc")
      .limit(maxDetailMergeReceipts)
      .get(),
  ]);
  const contact = contactSnap.data() as OrganizerContactDocument | undefined;
  const traits = traitSnap.data() as OrganizerContactTraitDocument | undefined;
  if (!contact || contact.organizerId !== data.organizerId ||
      contact.deletedAt !== null || contact.hiddenAt != null ||
      contact.identityState === "merged" ||
      !traits || traits.organizerId !== data.organizerId) {
    throw new HttpsError("not-found", "Audience contact not found.");
  }
  const eventDocuments = eventSnap.docs.slice(0, maxDetailEvents)
    .map((doc) => doc.data() as OrganizerContactEventEdgeDocument);
  const events = eventDocuments
    .map((doc) => eventDetailRow(
      doc
    ));
  const revenue = await contactRevenue({
    db,
    contact,
    eventIds: new Set(eventDocuments.map((edge) => edge.eventId)),
    eventHistoryTruncated: eventSnap.size > maxDetailEvents,
  });
  const tagVocabulary = safeManualTagVocabulary(
    data.organizerId,
    tagVocabularySnap.data() as
      OrganizerContactTagVocabularyDocument | undefined
  );
  const manualTagsById = new Map(
    tagVocabulary.map((tag) => [tag.tagId, tag])
  );
  const notes = noteSnap.docs.slice(0, maxDetailNotes)
    .map((doc) => noteDetailRow(
      doc.id,
      doc.data() as OrganizerContactNoteDocument
    ))
    .filter((note): note is NonNullable<typeof note> => note !== null);
  const campaignSends = await contactCampaignSendHistory({
    db,
    organizerId: data.organizerId,
    recipientDocuments: recipientSnap.docs.slice(0, maxDetailSends).map(
      (doc) => ({
        id: doc.id,
        data: doc.data() as OrganizerCampaignRecipientDocument,
      })
    ),
  });
  const broadcastSends = contactBroadcastSendHistory({
    organizerId: data.organizerId,
    contactId: data.contactId,
    summaries: broadcastSnap.docs.map((doc) =>
      doc.data() as OrganizerBroadcastSummaryDocument),
  });
  const allSends = [...campaignSends, ...broadcastSends].sort(
    (left, right) => sendHistoryMillis(right) - sendHistoryMillis(left),
  );
  const sends = allSends.slice(0, maxDetailSends);
  const activeMerges = await activeMergeRows({
    db,
    organizerId: data.organizerId,
    receipts: mergeReceiptSnap.docs.map((document) => ({
      id: document.id,
      data: document.data() as OrganizerContactMergeReceiptDocument,
    })),
  });
  return {
    organizerId: data.organizerId,
    contactId: data.contactId,
    displayName: effectiveDisplayName(contact),
    sourceDisplayName: contact.displayName,
    displayNameOverride: contact.displayNameOverride ?? null,
    phoneE164: contact.phoneE164,
    email: contact.email,
    linkedAccount: contact.linkedUid !== null,
    identityState: activeIdentityState(contact.identityState),
    identityConfidence: contact.identityConfidence,
    ambiguousCandidateContactIds: contact.ambiguousCandidateContactIds,
    whatsappAdminSuppressed:
      (channelSnap.data() as OrganizerContactChannelStateDocument | undefined)
        ?.adminSuppressed === true,
    traits: {
      expectedEventCount: traits.expectedEventCount,
      attendedEventCount: traits.attendedEventCount,
      cancelledEventCount: traits.cancelledEventCount,
      noShowCount: traits.noShowCount,
      importedEventCount: traits.importedEventCount,
      attendanceRate: traits.attendanceRate,
      segmentIds: traits.segmentIds,
      whatsappStatus: traits.whatsappStatus,
      smsStatus: traits.smsStatus,
      sourceCoverage: traits.sourceCoverage,
    },
    revenue,
    events,
    eventsTruncated: eventSnap.size > maxDetailEvents,
    manualTags: manualTagsForContact(contact, manualTagsById),
    manualTagVocabulary: tagVocabulary,
    notes,
    notesTruncated: noteSnap.size > maxDetailNotes,
    sends,
    sendsTruncated:
      recipientSnap.size > maxDetailSends || allSends.length > maxDetailSends,
    activeMerges,
    revision: contact.revision,
  };
}

async function activeMergeRows(params: {
  db: FirebaseFirestore.Firestore;
  organizerId: string;
  receipts: Array<{
    id: string;
    data: OrganizerContactMergeReceiptDocument;
  }>;
}): Promise<GetOrganizerContactDetailCallableResponse["activeMerges"]> {
  const reversedReceiptIds = new Set(params.receipts
    .filter((receipt) => receipt.data.organizerId === params.organizerId &&
      receipt.data.operation === "unmerge" &&
      receipt.data.reversalOfReceiptId !== null)
    .map((receipt) => receipt.data.reversalOfReceiptId!));
  const activeReceipts = params.receipts.filter((receipt) =>
    receipt.data.organizerId === params.organizerId &&
    receipt.data.operation === "merge" &&
    !reversedReceiptIds.has(receipt.id)
  ).slice(0, 50);
  return Promise.all(activeReceipts.map(async (receipt) => {
    const sourceSnapshot = await params.db.collection("organizerContacts")
      .doc(receipt.data.sourceContactId).get();
    const source = sourceSnapshot.data() as
      OrganizerContactDocument | undefined;
    return {
      mergeReceiptId: receipt.id,
      sourceContactId: receipt.data.sourceContactId,
      sourceDisplayName: source?.organizerId === params.organizerId ?
        effectiveDisplayName(source) : "Merged customer",
      evidence: receipt.data.evidence,
      conflicts: receipt.data.conflicts,
      movedFactCount: receipt.data.movedEdgeCount +
        receipt.data.movedIdentityEvidenceCount +
        receipt.data.movedClaimCount,
      mergedAtMillis: receipt.data.createdAt.toMillis(),
    };
  }));
}

async function contactRevenue(params: {
  db: FirebaseFirestore.Firestore;
  contact: OrganizerContactDocument;
  eventIds: Set<string>;
  eventHistoryTruncated: boolean;
}): Promise<GetOrganizerContactDetailCallableResponse["revenue"]> {
  if (params.contact.linkedUid === null ||
      params.contact.identityState !== "verified") {
    return {coverage: "unavailable", amounts: []};
  }
  const paymentsSnap = await params.db.collection("payments")
    .where("userId", "==", params.contact.linkedUid)
    .limit(maxContactPayments + 1)
    .get();
  return summarizeContactRevenue(
    paymentsSnap.docs.slice(0, maxContactPayments)
      .map((paymentSnap) => paymentSnap.data() as PaymentDocument),
    params.eventIds,
    paymentsSnap.size > maxContactPayments || params.eventHistoryTruncated ?
      "partial" : "exact"
  );
}

/** Aggregates only completed, non-refunded Catch payments for known events. */
export function summarizeContactRevenue(
  payments: PaymentDocument[],
  eventIds: Set<string>,
  coverage: "exact" | "partial"
): GetOrganizerContactDetailCallableResponse["revenue"] {
  const totals = new Map<
    string,
    {amountMinor: number; paidOrderCount: number}
  >();
  for (const payment of payments) {
    if (!eventIds.has(payment.eventId) ||
        payment.status !== "completed" || payment.signUpFailed) continue;
    const amountMinor = payment.amountMinor ?? payment.amount;
    const currency = payment.currency.trim().toUpperCase();
    if (!Number.isSafeInteger(amountMinor) || amountMinor <= 0 ||
        !/^[A-Z]{3}$/.test(currency)) continue;
    const prior = totals.get(currency);
    totals.set(currency, {
      amountMinor: (prior?.amountMinor ?? 0) + amountMinor,
      paidOrderCount: (prior?.paidOrderCount ?? 0) + 1,
    });
  }
  return {
    coverage,
    amounts: [...totals.entries()]
      .sort(([left], [right]) => left.localeCompare(right))
      .map(([currency, value]) => ({currency, ...value})),
  };
}

/** Corrects an organizer label, suppresses marketing, or hides a CRM row. */
export async function mutateOrganizerContactHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerContactsDeps = defaultDeps
): Promise<MutateOrganizerContactCallableResponse> {
  const actorUid = requireAuth(request);
  assertManualTagInputCap(request.data);
  const data = validateCallableWithAjv<MutateOrganizerContactCallablePayload>(
    request,
    validateMutateOrganizerContactCallablePayload,
    normalizeContactMutationPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "mutateOrganizerContact");
  await requireOrganizerManager({db, organizerId: data.organizerId, actorUid});
  const contactRef = db.collection("organizerContacts").doc(data.contactId);
  const channelRef = db.collection("organizerContactChannelStates").doc(
    organizerContactChannelStateId(data.organizerId, data.contactId)
  );
  return db.runTransaction(async (tx) => {
    const traitRef = db.collection("organizerContactTraits")
      .doc(data.contactId);
    const summaryRef = db.collection("organizerAudienceSummaries")
      .doc(data.organizerId);
    const tagVocabularyRef = db.collection("organizerContactTagVocabularies")
      .doc(data.organizerId);
    const [
      contactSnap,
      channelSnap,
      traitSnap,
      summarySnap,
      tagVocabularySnap,
    ] =
      await Promise.all([
        tx.get(contactRef),
        tx.get(channelRef),
        tx.get(traitRef),
        tx.get(summaryRef),
        tx.get(tagVocabularyRef),
      ]);
    const contact = contactSnap.data() as OrganizerContactDocument | undefined;
    if (!contact || contact.organizerId !== data.organizerId ||
        contact.deletedAt !== null || contact.identityState === "merged") {
      throw new HttpsError("not-found", "Audience contact not found.");
    }
    if (contact.revision !== data.expectedRevision) {
      throw new HttpsError(
        "aborted",
        "This contact changed on another device. Reload it and try again."
      );
    }
    const now = admin.firestore.Timestamp.now();
    const revision = Math.max(contact.revision + 1, now.toMillis());
    const patch: FirebaseFirestore.UpdateData<OrganizerContactDocument> = {
      revision,
      updatedAt: now,
    };
    if (Object.prototype.hasOwnProperty.call(data, "displayNameOverride")) {
      patch.displayNameOverride = data.displayNameOverride ?? null;
      patch.searchName = (data.displayNameOverride ?? contact.displayName)
        .toLocaleLowerCase("en");
    }
    const existingTagVocabulary = tagVocabularySnap.data() as
      OrganizerContactTagVocabularyDocument | undefined;
    let manualTags = manualTagsForContact(
      contact,
      new Map(safeManualTagVocabulary(
        data.organizerId,
        existingTagVocabulary
      ).map((tag) => [tag.tagId, tag]))
    );
    if (data.manualTags) {
      const resolved = resolveManualTags({
        organizerId: data.organizerId,
        labels: data.manualTags,
        vocabulary: existingTagVocabulary,
        actorUid,
        now,
      });
      patch.manualTagIds = resolved.manualTags.map((tag) => tag.tagId);
      manualTags = resolved.manualTags;
      tx.set(tagVocabularyRef, resolved.vocabulary);
    }
    if (typeof data.hidden === "boolean") {
      patch.hiddenAt = data.hidden ? now : null;
      patch.hiddenBy = data.hidden ? actorUid : null;
      const trait = traitSnap.data() as
        OrganizerContactTraitDocument | undefined;
      const hiddenSnapshot = contact.hiddenTraitSnapshot ?? trait ?? null;
      patch.hiddenTraitSnapshot = data.hidden ? hiddenSnapshot : null;
      if (data.hidden && trait) {
        const summary = summarySnap.data() as
          OrganizerAudienceSummaryDocument | undefined;
        tx.set(summaryRef, summaryWithoutTrait(
          data.organizerId,
          summary,
          trait,
          now
        ));
        tx.delete(traitRef);
      } else if (!data.hidden && hiddenSnapshot) {
        const summary = summarySnap.data() as
          OrganizerAudienceSummaryDocument | undefined;
        tx.set(summaryRef, summaryWithTrait(
          data.organizerId,
          summary,
          hiddenSnapshot,
          now
        ));
        tx.set(traitRef, {...hiddenSnapshot, computedAt: now});
      }
    }
    tx.update(contactRef, patch);
    const priorChannel = channelSnap.data() as
      OrganizerContactChannelStateDocument | undefined;
    let whatsappAdminSuppressed =
      priorChannel?.adminSuppressed === true;
    if (typeof data.whatsappAdminSuppressed === "boolean") {
      whatsappAdminSuppressed = data.whatsappAdminSuppressed;
      if (data.whatsappAdminSuppressed) {
        tx.set(channelRef, {
          organizerId: data.organizerId,
          contactId: data.contactId,
          channel: "whatsapp",
          endpointHash: hashEndpoint(contact.phoneE164 ?? ""),
          suppressionStatus: priorChannel?.suppressionStatus ?? "none",
          suppressionSource: priorChannel?.suppressionSource ?? null,
          adminSuppressed: true,
          campaignAcceptedCount: priorChannel?.campaignAcceptedCount ?? 0,
          lastCampaignAcceptedAt: priorChannel?.lastCampaignAcceptedAt ?? null,
          lastInboundAt: priorChannel?.lastInboundAt ?? null,
          lastReplyAt: priorChannel?.lastReplyAt ?? null,
          createdAt: priorChannel?.createdAt ?? now,
          updatedAt: now,
        } satisfies OrganizerContactChannelStateDocument);
      } else if (priorChannel?.adminSuppressed === true) {
        tx.update(channelRef, {
          adminSuppressed: false,
          updatedAt: now,
        });
      }
    }
    const displayNameOverride = Object.prototype.hasOwnProperty.call(
      data,
      "displayNameOverride"
    ) ? data.displayNameOverride ?? null : contact.displayNameOverride ?? null;
    const hidden = typeof data.hidden === "boolean" ?
      data.hidden : contact.hiddenAt != null;
    return {
      organizerId: data.organizerId,
      contactId: data.contactId,
      displayName: displayNameOverride ?? contact.displayName,
      displayNameOverride,
      whatsappAdminSuppressed,
      hidden,
      manualTags,
      revision,
    };
  });
}

/** Appends an author-stamped note to one active organizer contact. */
export async function createOrganizerContactNoteHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerContactsDeps = defaultDeps
): Promise<OrganizerContactNoteCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<
    CreateOrganizerContactNoteCallablePayload
  >(
    request,
    validateCreateOrganizerContactNoteCallablePayload,
    normalizeContactNotePayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "createOrganizerContactNote");
  await requireOrganizerManager({db, organizerId: data.organizerId, actorUid});
  const contactRef = db.collection("organizerContacts").doc(data.contactId);
  const noteRef = db.collection("organizerContactNotes").doc();
  const now = admin.firestore.Timestamp.now();
  const note: OrganizerContactNoteDocument = {
    organizerId: data.organizerId,
    contactId: data.contactId,
    authorUid: actorUid,
    body: data.body,
    revision: Math.max(1, now.toMillis()),
    createdAt: now,
    updatedAt: now,
    updatedByUid: actorUid,
  };
  await db.runTransaction(async (tx) => {
    const contactSnap = await tx.get(contactRef);
    const contact = contactSnap.data() as OrganizerContactDocument | undefined;
    assertActiveOrganizerContact(contact, data.organizerId);
    tx.create(noteRef, note);
  });
  return organizerContactNoteResponse(noteRef.id, note);
}

/** Optimistically edits note text while retaining its original author stamp. */
export async function mutateOrganizerContactNoteHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerContactsDeps = defaultDeps
): Promise<OrganizerContactNoteCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<
    MutateOrganizerContactNoteCallablePayload
  >(
    request,
    validateMutateOrganizerContactNoteCallablePayload,
    normalizeContactNotePayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "mutateOrganizerContactNote");
  await requireOrganizerManager({db, organizerId: data.organizerId, actorUid});
  const contactRef = db.collection("organizerContacts").doc(data.contactId);
  const noteRef = db.collection("organizerContactNotes").doc(data.noteId);
  return db.runTransaction(async (tx) => {
    const [contactSnap, noteSnap] = await Promise.all([
      tx.get(contactRef),
      tx.get(noteRef),
    ]);
    const contact = contactSnap.data() as OrganizerContactDocument | undefined;
    assertActiveOrganizerContact(contact, data.organizerId);
    const note = noteSnap.data() as OrganizerContactNoteDocument | undefined;
    if (!note || note.organizerId !== data.organizerId ||
        note.contactId !== data.contactId) {
      throw new HttpsError("not-found", "Contact note not found.");
    }
    if (note.revision !== data.expectedRevision) {
      throw new HttpsError(
        "aborted",
        "This note changed on another device. Reload it and try again."
      );
    }
    const now = admin.firestore.Timestamp.now();
    const updated: OrganizerContactNoteDocument = {
      ...note,
      body: data.body,
      revision: Math.max(note.revision + 1, now.toMillis()),
      updatedAt: now,
      updatedByUid: actorUid,
    };
    tx.update(noteRef, {
      body: updated.body,
      revision: updated.revision,
      updatedAt: updated.updatedAt,
      updatedByUid: updated.updatedByUid,
    });
    return organizerContactNoteResponse(data.noteId, updated);
  });
}

/** Returns a bounded export instead of exposing bulk Firestore PII. */
export async function exportOrganizerContactsHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerContactsDeps = defaultDeps
): Promise<ExportOrganizerContactsCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<ExportOrganizerContactsCallablePayload>(
    request,
    validateExportOrganizerContactsCallablePayload,
    normalizeExportPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "exportOrganizerContacts");
  await requireOrganizerManager({db, organizerId: data.organizerId, actorUid});
  const [contactSnap, summarySnap] = await Promise.all([
    db.collection("organizerContacts")
      .where("organizerId", "==", data.organizerId)
      .orderBy(admin.firestore.FieldPath.documentId())
      .limit(maxExportContacts + 1)
      .get(),
    db.collection("organizerAudienceSummaries").doc(data.organizerId).get(),
  ]);
  const candidates = contactSnap.docs
    .filter((doc) => {
      const contact = doc.data() as OrganizerContactDocument;
      return contact.deletedAt === null && contact.hiddenAt == null &&
        contact.identityState !== "merged";
    });
  const traitSnaps = candidates.length === 0 ? [] : await db.getAll(
    ...candidates.map((doc) => db.collection("organizerContactTraits")
      .doc(doc.id))
  );
  const rows = candidates.map((doc, index) => ({
    id: doc.id,
    contact: doc.data() as OrganizerContactDocument,
    trait: traitSnaps[index].data() as
      OrganizerContactTraitDocument | undefined,
  })).filter((row) => row.trait?.organizerId === data.organizerId &&
    (!data.segmentId || row.trait!.segmentIds.includes(data.segmentId)))
    .slice(0, maxExportContacts);
  const header = [
    "contact_id", "display_name", "phone_e164", "email",
    "identity_state", "expected_events", "attended_events", "no_shows",
    "attendance_rate", "segments", "whatsapp_permission", "source_coverage",
  ];
  const csv = [header, ...rows.map(({id, contact, trait}) => [
    id,
    effectiveDisplayName(contact),
    contact.phoneE164 ?? "",
    contact.email ?? "",
    contact.identityState,
    String(trait!.expectedEventCount),
    String(trait!.attendedEventCount),
    String(trait!.noShowCount),
    trait!.attendanceRate === null ? "" : String(trait!.attendanceRate),
    trait!.segmentIds.join("|"),
    trait!.whatsappStatus,
    trait!.sourceCoverage,
  ])].map((row) => row.map(csvCell).join(",")).join("\r\n") + "\r\n";
  const summary = summarySnap.data() as
    OrganizerAudienceSummaryDocument | undefined;
  const generatedAt = admin.firestore.Timestamp.now();
  return {
    organizerId: data.organizerId,
    fileName: `catch-audience-${safeFilePart(data.organizerId)}-` +
      `${generatedAt.toDate().toISOString().slice(0, 10)}.csv`,
    csv,
    rowCount: rows.length,
    truncated: contactSnap.size > maxExportContacts,
    generatedAtMillis: generatedAt.toMillis(),
    sourceCoverage: summary?.sourceCoverage ?? "partial",
  };
}

interface ContactDocumentRow {
  id: string;
  data: OrganizerContactDocument;
}

interface SortedContactPage {
  contacts: ContactDocumentRow[];
  hasMore: boolean;
  lastValue: string | null;
}

async function listSortedContactDocuments(params: {
  db: FirebaseFirestore.Firestore;
  organizerId: string;
  search: string | null;
  segmentId: OrganizerContactTraitDocument["segmentIds"][number] | null;
  manualTagId: string | null;
  sort: ContactSort;
  cursor: ContactCursor | null;
  limit: number;
}): Promise<SortedContactPage> {
  const plan = contactQueryPlan(params);
  assertCursorPlan(
    params.cursor,
    plan,
    params.organizerId,
    params.search,
    params.segmentId,
    params.manualTagId,
    params.sort
  );
  const directContactSort = !params.segmentId && !params.manualTagId &&
    (!params.search || params.sort === "name") &&
    params.sort !== "mostAttended";
  if (directContactSort) return listDirectContactSort(params);
  if (!params.segmentId && !params.manualTagId && !params.search &&
      params.sort === "mostAttended") {
    return listDirectAttendanceSort(params);
  }
  return listBoundedFilteredSort(params);
}

async function listDirectContactSort(params: {
  db: FirebaseFirestore.Firestore;
  organizerId: string;
  search: string | null;
  sort: ContactSort;
  cursor: ContactCursor | null;
  limit: number;
}): Promise<SortedContactPage> {
  let baseQuery: FirebaseFirestore.Query = params.db
    .collection("organizerContacts")
    .where("organizerId", "==", params.organizerId)
    .where("deletedAt", "==", null);
  if (params.sort === "name") {
    baseQuery = baseQuery.orderBy("searchName").orderBy(
      admin.firestore.FieldPath.documentId()
    );
    if (params.search) {
      baseQuery = baseQuery.startAt(params.search)
        .endAt(`${params.search}\uf8ff`);
    }
  } else {
    baseQuery = baseQuery.orderBy("lastSeenAt", "desc").orderBy(
      admin.firestore.FieldPath.documentId(), "desc"
    );
  }
  const eligible: ContactDocumentRow[] = [];
  let scanned = 0;
  let scanValue = params.cursor?.value ?? null;
  let scanContactId = params.cursor?.contactId ?? null;
  while (eligible.length <= params.limit) {
    const remaining = maxSortedCandidateScan - scanned;
    if (remaining <= 0) throwSortScanLimit();
    const batchLimit = Math.min(
      Math.max(params.limit + 1, 100),
      remaining + 1
    );
    let pageQuery = baseQuery;
    if (scanValue !== null && scanContactId !== null) {
      pageQuery = params.sort === "name" ?
        pageQuery.startAfter(scanValue, scanContactId) :
        pageQuery.startAfter(
          admin.firestore.Timestamp.fromMillis(Number(scanValue)),
          scanContactId
        );
    }
    const snapshot = await pageQuery.limit(batchLimit).get();
    const allowed = snapshot.docs.slice(0, remaining);
    const rows = allowed.map((document) => ({
      id: document.id,
      data: document.data() as OrganizerContactDocument,
    }));
    eligible.push(...rows.filter((contact) =>
      contact.data.hiddenAt == null &&
      contact.data.identityState !== "merged"
    ));
    scanned += allowed.length;
    if (eligible.length > params.limit) break;
    if (snapshot.size > allowed.length) throwSortScanLimit();
    if (snapshot.size < batchLimit || allowed.length === 0) break;
    const lastScanned = rows.at(-1)!;
    scanValue = contactSortValue(lastScanned, undefined, params.sort);
    scanContactId = lastScanned.id;
  }
  const selected = eligible.slice(0, params.limit);
  const last = selected.at(-1);
  return {
    contacts: selected,
    hasMore: eligible.length > params.limit,
    lastValue: last ? contactSortValue(last, undefined, params.sort) : null,
  };
}

async function listDirectAttendanceSort(params: {
  db: FirebaseFirestore.Firestore;
  organizerId: string;
  cursor: ContactCursor | null;
  limit: number;
}): Promise<SortedContactPage> {
  const baseQuery: FirebaseFirestore.Query = params.db
    .collection("organizerContactTraits")
    .where("organizerId", "==", params.organizerId)
    .orderBy("attendedEventCount", "desc")
    .orderBy(admin.firestore.FieldPath.documentId(), "desc");
  const eligible: Array<{
    contact: ContactDocumentRow;
    trait: OrganizerContactTraitDocument;
  }> = [];
  let scanned = 0;
  let scanValue = params.cursor?.value ?? null;
  let scanContactId = params.cursor?.contactId ?? null;
  while (eligible.length <= params.limit) {
    const remaining = maxSortedCandidateScan - scanned;
    if (remaining <= 0) throwSortScanLimit();
    const batchLimit = Math.min(
      Math.max(params.limit + 1, 100),
      remaining + 1
    );
    let pageQuery = baseQuery;
    if (scanValue !== null && scanContactId !== null) {
      pageQuery = pageQuery.startAfter(Number(scanValue), scanContactId);
    }
    const snapshot = await pageQuery.limit(batchLimit).get();
    const allowed = snapshot.docs.slice(0, remaining).map((document) => ({
      id: document.id,
      data: document.data() as OrganizerContactTraitDocument,
    }));
    const contacts = await getContactsById(
      params.db,
      allowed.map((row) => row.id)
    );
    const byId = new Map(contacts.map((contact) => [contact.id, contact]));
    eligible.push(...allowed.map((trait) => {
      const contact = byId.get(trait.id);
      return contact ? {contact, trait: trait.data} : null;
    }).filter((row): row is NonNullable<typeof row> => row !== null));
    scanned += allowed.length;
    if (eligible.length > params.limit) break;
    if (snapshot.size > allowed.length) throwSortScanLimit();
    if (snapshot.size < batchLimit || allowed.length === 0) break;
    const lastScanned = allowed.at(-1)!;
    scanValue = String(lastScanned.data.attendedEventCount);
    scanContactId = lastScanned.id;
  }
  const selected = eligible.slice(0, params.limit);
  const last = selected.at(-1);
  return {
    contacts: selected.map((row) => row.contact),
    hasMore: eligible.length > params.limit,
    lastValue: last ? String(last.trait.attendedEventCount) : null,
  };
}

function throwSortScanLimit(): never {
  throw new HttpsError(
    "resource-exhausted",
    "This audience is too large to sort. Narrow the filters."
  );
}

async function listBoundedFilteredSort(params: {
  db: FirebaseFirestore.Firestore;
  organizerId: string;
  search: string | null;
  segmentId: OrganizerContactTraitDocument["segmentIds"][number] | null;
  manualTagId: string | null;
  sort: ContactSort;
  cursor: ContactCursor | null;
  limit: number;
}): Promise<SortedContactPage> {
  let candidateQuery: FirebaseFirestore.Query;
  let candidatesAreTraits = false;
  if (params.segmentId) {
    candidatesAreTraits = true;
    candidateQuery = params.db.collection("organizerContactTraits")
      .where("organizerId", "==", params.organizerId)
      .where("segmentIds", "array-contains", params.segmentId)
      .orderBy(admin.firestore.FieldPath.documentId());
  } else {
    candidateQuery = params.db.collection("organizerContacts")
      .where("organizerId", "==", params.organizerId)
      .where("deletedAt", "==", null);
    if (params.manualTagId) {
      candidateQuery = candidateQuery
        .where("hiddenAt", "==", null)
        .where("manualTagIds", "array-contains", params.manualTagId)
        .orderBy(admin.firestore.FieldPath.documentId());
    } else if (params.search) {
      candidateQuery = candidateQuery.orderBy("searchName")
        .orderBy(admin.firestore.FieldPath.documentId())
        .startAt(params.search).endAt(`${params.search}\uf8ff`);
    } else {
      candidateQuery = candidateQuery.orderBy(
        admin.firestore.FieldPath.documentId()
      );
    }
  }
  const candidateSnapshot = await candidateQuery
    .limit(maxSortedCandidateScan + 1).get();
  if (candidateSnapshot.size > maxSortedCandidateScan) {
    throw new HttpsError(
      "resource-exhausted",
      "This filtered audience is too large to sort. Narrow the filters."
    );
  }
  const candidateIds = candidateSnapshot.docs.map((document) => document.id);
  const [contactRows, traitSnapshots] = await Promise.all([
    candidatesAreTraits ? getContactsById(params.db, candidateIds) :
      Promise.resolve(candidateSnapshot.docs.map((document) => ({
        id: document.id,
        data: document.data() as OrganizerContactDocument,
      }))),
    candidateIds.length === 0 ? Promise.resolve([]) : params.db.getAll(
      ...candidateIds.map((contactId) => params.db
        .collection("organizerContactTraits").doc(contactId))
    ),
  ]);
  const traitsById = new Map(traitSnapshots
    .filter((snapshot) => snapshot.exists)
    .map((snapshot) => [
      snapshot.id,
      snapshot.data() as OrganizerContactTraitDocument,
    ]));
  const eligible = contactRows.filter((contact) => {
    const trait = traitsById.get(contact.id);
    return contact.data.organizerId === params.organizerId &&
      contact.data.deletedAt === null && contact.data.hiddenAt == null &&
      contact.data.identityState !== "merged" &&
      (!params.search || contact.data.searchName.startsWith(params.search)) &&
      (!params.manualTagId ||
        (contact.data.manualTagIds ?? []).includes(params.manualTagId)) &&
      (!params.segmentId || trait?.segmentIds.includes(params.segmentId));
  });
  eligible.sort((left, right) => compareContactSortRows(
    left,
    right,
    traitsById,
    params.sort
  ));
  const afterCursor = eligible.filter((contact) => contactIsAfterCursor(
    contact,
    traitsById.get(contact.id),
    params.sort,
    params.cursor
  ));
  const selected = afterCursor.slice(0, params.limit);
  const last = selected.at(-1);
  return {
    contacts: selected,
    hasMore: afterCursor.length > selected.length,
    lastValue: last ? contactSortValue(
      last,
      traitsById.get(last.id),
      params.sort
    ) : null,
  };
}

function compareContactSortRows(
  left: ContactDocumentRow,
  right: ContactDocumentRow,
  traitsById: ReadonlyMap<string, OrganizerContactTraitDocument>,
  sort: ContactSort
): number {
  const leftValue = contactSortValue(left, traitsById.get(left.id), sort);
  const rightValue = contactSortValue(right, traitsById.get(right.id), sort);
  if (leftValue !== rightValue) {
    return sort === "name" ? leftValue.localeCompare(rightValue) :
      Number(rightValue) - Number(leftValue);
  }
  return sort === "name" ? left.id.localeCompare(right.id) :
    right.id.localeCompare(left.id);
}

function contactIsAfterCursor(
  contact: ContactDocumentRow,
  trait: OrganizerContactTraitDocument | undefined,
  sort: ContactSort,
  cursor: ContactCursor | null
): boolean {
  if (!cursor) return true;
  const value = contactSortValue(contact, trait, sort);
  if (value === cursor.value) {
    return sort === "name" ?
      contact.id.localeCompare(cursor.contactId) > 0 :
      contact.id.localeCompare(cursor.contactId) < 0;
  }
  return sort === "name" ? value.localeCompare(cursor.value) > 0 :
    Number(value) < Number(cursor.value);
}

function contactSortValue(
  contact: ContactDocumentRow,
  trait: OrganizerContactTraitDocument | undefined,
  sort: ContactSort
): string {
  if (sort === "name") return contact.data.searchName;
  if (sort === "mostAttended") {
    return String(trait?.attendedEventCount ?? 0);
  }
  return String(contact.data.lastSeenAt.toMillis());
}

function contactQueryPlan(params: {
  search: string | null;
  segmentId: string | null;
  manualTagId: string | null;
}): ContactCursor["plan"] {
  if (params.segmentId) return "segment";
  if (params.manualTagId) return "manualTag";
  return params.search ? "search" : "people";
}

async function getContactsById(
  db: FirebaseFirestore.Firestore,
  contactIds: string[]
): Promise<ContactDocumentRow[]> {
  if (contactIds.length === 0) return [];
  const snapshots = await db.getAll(...contactIds.map((contactId) =>
    db.collection("organizerContacts").doc(contactId)
  ));
  return snapshots.filter((snap) => snap.exists).map((snap) => ({
    id: snap.id,
    data: snap.data() as OrganizerContactDocument,
  })).filter((item) => item.data.deletedAt === null &&
    item.data.hiddenAt == null &&
    item.data.identityState !== "merged");
}

function safeContactRow(
  contactId: string,
  contact: OrganizerContactDocument,
  traits: OrganizerContactTraitDocument | undefined,
  channelState: OrganizerContactChannelStateDocument | undefined,
  manualTagsById: ReadonlyMap<string, ManualTagRow>
): ListOrganizerContactsCallableResponse["contacts"][number] | null {
  if (!traits || traits.organizerId !== contact.organizerId ||
      contact.identityState === "merged" || contact.hiddenAt != null) {
    return null;
  }
  return {
    contactId,
    displayName: effectiveDisplayName(contact),
    phoneE164: contact.phoneE164,
    email: contact.email,
    identityState: activeIdentityState(contact.identityState),
    identityConfidence: contact.identityConfidence,
    ambiguousCandidateCount: contact.ambiguousCandidateContactIds.length,
    attendedEventCount: traits.attendedEventCount,
    expectedEventCount: traits.expectedEventCount,
    lastAttendedAtMillis: traits.lastAttendedAt?.toMillis() ?? null,
    segmentIds: traits.segmentIds,
    manualTags: manualTagsForContact(contact, manualTagsById),
    whatsappStatus: traits.whatsappStatus,
    whatsappAdminSuppressed:
      channelState?.adminSuppressed === true,
    smsStatus: traits.smsStatus,
    sourceCoverage: traits.sourceCoverage,
    revision: contact.revision,
  };
}

type ManualTagRow = NonNullable<
  GetOrganizerContactDetailCallableResponse["manualTags"]
>[number];

function safeManualTagVocabulary(
  organizerId: string,
  vocabulary: OrganizerContactTagVocabularyDocument | undefined
): ManualTagRow[] {
  if (!vocabulary || vocabulary.organizerId !== organizerId) return [];
  return vocabulary.tags.slice(0, maxOrganizerManualTags).map((tag) => ({
    tagId: tag.tagId,
    label: tag.label,
  }));
}

function manualTagsForContact(
  contact: OrganizerContactDocument,
  manualTagsById: ReadonlyMap<string, ManualTagRow>
): ManualTagRow[] {
  return (contact.manualTagIds ?? [])
    .slice(0, maxContactManualTags)
    .map((tagId) => manualTagsById.get(tagId))
    .filter((tag): tag is ManualTagRow => tag !== undefined);
}

export function resolveManualTags(params: {
  organizerId: string;
  labels: string[];
  vocabulary: OrganizerContactTagVocabularyDocument | undefined;
  actorUid: string;
  now: FirebaseFirestore.Timestamp;
}): {
  vocabulary: OrganizerContactTagVocabularyDocument;
  manualTags: ManualTagRow[];
} {
  if (params.labels.length > maxContactManualTags) {
    throw new HttpsError(
      "invalid-argument",
      "A contact can have at most 5 manual tags."
    );
  }
  if (params.vocabulary &&
      params.vocabulary.organizerId !== params.organizerId) {
    throw new HttpsError(
      "failed-precondition",
      "The organizer tag vocabulary is invalid."
    );
  }
  const tags = [...(params.vocabulary?.tags ?? [])];
  const byNormalizedLabel = new Map(
    tags.map((tag) => [tag.normalizedLabel, tag])
  );
  const desired = new Map<string, string>();
  for (const rawLabel of params.labels) {
    const label = normalizeManualTagLabel(rawLabel);
    desired.set(label.toLocaleLowerCase("en"), label);
  }
  if (desired.size > maxContactManualTags) {
    throw new HttpsError(
      "invalid-argument",
      "A contact can have at most 5 manual tags."
    );
  }
  const manualTags = [...desired.entries()].map(([normalizedLabel, label]) => {
    const existing = byNormalizedLabel.get(normalizedLabel);
    if (existing) return {tagId: existing.tagId, label: existing.label};
    const created = {
      tagId: manualTagId(params.organizerId, normalizedLabel),
      label,
      normalizedLabel,
      createdByUid: params.actorUid,
      createdAt: params.now,
    } satisfies OrganizerContactTagVocabularyDocument["tags"][number];
    tags.push(created);
    byNormalizedLabel.set(normalizedLabel, created);
    return {tagId: created.tagId, label: created.label};
  });
  if (tags.length > maxOrganizerManualTags) {
    throw new HttpsError(
      "failed-precondition",
      "An organizer can have at most 20 manual tags."
    );
  }
  return {
    vocabulary: {
      organizerId: params.organizerId,
      tags,
      updatedAt: params.now,
    },
    manualTags,
  };
}

function manualTagId(organizerId: string, normalizedLabel: string): string {
  return createHash("sha256")
    .update(`${organizerId}\u0000${normalizedLabel}`)
    .digest("hex")
    .slice(0, 32);
}

function normalizeManualTagLabel(value: string): string {
  return value.trim().replace(/\s+/g, " ");
}

function noteDetailRow(
  noteId: string,
  note: OrganizerContactNoteDocument
): NonNullable<GetOrganizerContactDetailCallableResponse["notes"]>[number] |
  null {
  if (!note.body.trim()) return null;
  return {
    noteId,
    body: note.body,
    authorUid: note.authorUid,
    createdAtMillis: note.createdAt.toMillis(),
    updatedAtMillis: note.updatedAt.toMillis(),
    revision: note.revision,
  };
}

async function contactCampaignSendHistory(params: {
  db: FirebaseFirestore.Firestore;
  organizerId: string;
  recipientDocuments: Array<{
    id: string;
    data: OrganizerCampaignRecipientDocument;
  }>;
}): Promise<NonNullable<
  GetOrganizerContactDetailCallableResponse["sends"]
>> {
  const recipients = params.recipientDocuments.filter(
    (row) => row.data.organizerId === params.organizerId
  );
  if (recipients.length === 0) return [];
  const campaignIds = [...new Set(
    recipients.map((row) => row.data.campaignId)
  )];
  const campaignSnapshots = await params.db.getAll(
    ...campaignIds.map((campaignId) => params.db
      .collection("organizerCampaigns").doc(campaignId))
  );
  const campaigns = new Map(campaignSnapshots
    .filter((snapshot) => snapshot.exists)
    .map((snapshot) => [
      snapshot.id,
      snapshot.data() as OrganizerCampaignDocument,
    ]));
  return recipients.map(({data: recipient}) => {
    const campaign = campaigns.get(recipient.campaignId);
    if (!campaign || campaign.organizerId !== params.organizerId) return null;
    return {
      kind: "campaign" as const,
      campaignId: recipient.campaignId,
      name: campaign.name,
      messageClass: campaign.messageClass,
      deliveryStatus: recipient.status,
      createdAtMillis: recipient.createdAt.toMillis(),
      sentAtMillis: recipient.sentAt?.toMillis() ?? null,
      updatedAtMillis: recipient.updatedAt.toMillis(),
    };
  }).filter((row): row is NonNullable<typeof row> => row !== null);
}

function contactBroadcastSendHistory(params: {
  organizerId: string;
  contactId: string;
  summaries: OrganizerBroadcastSummaryDocument[];
}): NonNullable<GetOrganizerContactDetailCallableResponse["sends"]> {
  return params.summaries
    .filter((summary) =>
      summary.organizerId === params.organizerId &&
      summary.recipientContactIds.includes(params.contactId))
    .map((summary) => ({
      kind: "announcement" as const,
      broadcastId: summary.broadcastId,
      eventId: summary.eventId,
      eventName: summary.eventName,
      audience: summary.audience,
      deliveryStatus: summary.recipientDeliveryStates[params.contactId] ??
        "failed",
      sentAtMillis: summary.sentAt.toMillis(),
      partialFailure: summary.partialFailure,
    }));
}

function sendHistoryMillis(
  row: NonNullable<GetOrganizerContactDetailCallableResponse["sends"]>[number]
): number {
  return row.kind === "campaign" ? row.updatedAtMillis : row.sentAtMillis;
}

function organizerContactNoteResponse(
  noteId: string,
  note: OrganizerContactNoteDocument
): OrganizerContactNoteCallableResponse {
  return {
    organizerId: note.organizerId,
    contactId: note.contactId,
    noteId,
    body: note.body,
    authorUid: note.authorUid,
    createdAtMillis: note.createdAt.toMillis(),
    updatedAtMillis: note.updatedAt.toMillis(),
    revision: note.revision,
  };
}

function assertActiveOrganizerContact(
  contact: OrganizerContactDocument | undefined,
  organizerId: string
): asserts contact is OrganizerContactDocument {
  if (!contact || contact.organizerId !== organizerId ||
      contact.deletedAt !== null || contact.hiddenAt != null ||
      contact.identityState === "merged") {
    throw new HttpsError("not-found", "Audience contact not found.");
  }
}

function eventDetailRow(
  edge: OrganizerContactEventEdgeDocument
): GetOrganizerContactDetailCallableResponse["events"][number] {
  const millis = (value: FirebaseFirestore.Timestamp | null) =>
    value?.toMillis() ?? null;
  return {
    eventId: edge.eventId,
    attendeeId: edge.attendeeId,
    displayName: edge.displayName,
    source: edge.source,
    status: edge.status,
    expected: edge.expected,
    registered: edge.registered,
    cancelled: edge.cancelled,
    checkedIn: edge.checkedIn,
    eventStartAtMillis: millis(edge.eventStartAt),
    eventEndAtMillis: millis(edge.eventEndAt),
    registeredAtMillis: millis(edge.registeredAt),
    cancelledAtMillis: millis(edge.cancelledAt),
    checkedInAtMillis: millis(edge.checkedInAt),
  };
}

function activeIdentityState(
  state: OrganizerContactDocument["identityState"]
): "unlinked" | "verified" | "ambiguous" {
  if (state === "merged") {
    throw new HttpsError("not-found", "Audience contact not found.");
  }
  return state;
}

function normalizeSearch(value: string | null): string | null {
  const normalized = value?.trim().toLocaleLowerCase("en") ?? "";
  return normalized.length === 0 ? null : normalized;
}

function normalizeContactMutationPayload(data: unknown): unknown {
  if (typeof data !== "object" || data === null || Array.isArray(data)) {
    return data;
  }
  const normalized = {...data} as Record<string, unknown>;
  for (const field of ["organizerId", "contactId"]) {
    if (typeof normalized[field] === "string") {
      normalized[field] = normalized[field].trim();
    }
  }
  if (typeof normalized.displayNameOverride === "string") {
    normalized.displayNameOverride = normalized.displayNameOverride
      .trim().replace(/\s+/g, " ");
  }
  if (Array.isArray(normalized.manualTags)) {
    normalized.manualTags = normalized.manualTags.map((tag) =>
      typeof tag === "string" ? normalizeManualTagLabel(tag) : tag
    );
  }
  return normalized;
}

function normalizeContactNotePayload(data: unknown): unknown {
  if (typeof data !== "object" || data === null || Array.isArray(data)) {
    return data;
  }
  const normalized = {...data} as Record<string, unknown>;
  for (const field of ["organizerId", "contactId", "noteId"]) {
    if (typeof normalized[field] === "string") {
      normalized[field] = normalized[field].trim();
    }
  }
  if (typeof normalized.body === "string") {
    normalized.body = normalized.body.trim();
  }
  return normalized;
}

function assertManualTagInputCap(data: unknown): void {
  if (typeof data !== "object" || data === null || Array.isArray(data)) return;
  const manualTags = (data as Record<string, unknown>).manualTags;
  if (Array.isArray(manualTags) && manualTags.length > maxContactManualTags) {
    throw new HttpsError(
      "invalid-argument",
      "A contact can have at most 5 manual tags."
    );
  }
}

function normalizeCreateContactPayload(data: unknown): unknown {
  if (typeof data !== "object" || data === null || Array.isArray(data)) {
    return data;
  }
  const normalized = {...data} as Record<string, unknown>;
  if (typeof normalized.organizerId === "string") {
    normalized.organizerId = normalized.organizerId.trim();
  }
  if (typeof normalized.displayName === "string") {
    normalized.displayName = normalized.displayName.trim().replace(/\s+/g, " ");
  }
  return normalized;
}

function normalizeExportPayload(data: unknown): unknown {
  if (typeof data !== "object" || data === null || Array.isArray(data)) {
    return data;
  }
  const normalized = {...data} as Record<string, unknown>;
  for (const field of ["organizerId", "segmentId"]) {
    if (typeof normalized[field] === "string") {
      normalized[field] = normalized[field].trim();
    }
  }
  return normalized;
}

function effectiveDisplayName(contact: OrganizerContactDocument): string {
  return contact.displayNameOverride ?? contact.displayName;
}

function hashEndpoint(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

export function csvCell(value: string): string {
  const protectedValue = /^[=+\-@\t\r]/.test(value) ? `'${value}` : value;
  return /[",\r\n]/.test(protectedValue) ?
    `"${protectedValue.replace(/"/g, "\"\"")}"` : protectedValue;
}

function safeFilePart(value: string): string {
  return value.toLocaleLowerCase("en")
    .replace(/[^a-z0-9_-]+/g, "-").slice(0, 80) || "organizer";
}

function summaryWithoutTrait(
  organizerId: string,
  summary: OrganizerAudienceSummaryDocument | undefined,
  trait: OrganizerContactTraitDocument,
  now: FirebaseFirestore.Timestamp
): OrganizerAudienceSummaryDocument {
  return summaryAfterTraitDelta(organizerId, summary, trait, -1, now);
}

function summaryWithTrait(
  organizerId: string,
  summary: OrganizerAudienceSummaryDocument | undefined,
  trait: OrganizerContactTraitDocument,
  now: FirebaseFirestore.Timestamp
): OrganizerAudienceSummaryDocument {
  return summaryAfterTraitDelta(organizerId, summary, trait, 1, now);
}

function summaryAfterTraitDelta(
  organizerId: string,
  summary: OrganizerAudienceSummaryDocument | undefined,
  trait: OrganizerContactTraitDocument,
  direction: 1 | -1,
  now: FirebaseFirestore.Timestamp
): OrganizerAudienceSummaryDocument {
  const value = (current: number | undefined, applies: boolean) => Math.max(
    0,
    (current ?? 0) + (applies ? direction : 0)
  );
  return {
    organizerId,
    contactCount: value(summary?.contactCount, true),
    pastAttendeeCount: value(summary?.pastAttendeeCount,
      trait.attendedEventCount > 0),
    repeatAttendeeCount: value(summary?.repeatAttendeeCount,
      trait.attendedEventCount >= 2),
    linkedAccountCount: value(summary?.linkedAccountCount,
      trait.linkedAccount),
    importedContactCount: value(summary?.importedContactCount,
      trait.importedEventCount > 0),
    advocateCount: value(summary?.advocateCount,
      trait.referredCheckedInCount > 0),
    highImpactAdvocateCount: value(summary?.highImpactAdvocateCount,
      trait.referredCheckedIn365DayCount >= 3),
    whatsappOptInCount: value(summary?.whatsappOptInCount,
      trait.whatsappStatus === "optedIn"),
    smsOptInCount: value(summary?.smsOptInCount,
      trait.smsStatus === "optedIn"),
    sourceCoverage: summary?.sourceCoverage ?? "partial",
    projectionVersion: summary?.projectionVersion ?? 1,
    computedAt: now,
  };
}

export function encodeContactCursor(cursor: ContactCursor): string {
  return Buffer.from(JSON.stringify(cursor)).toString("base64url");
}

export function decodeContactCursor(
  value: string | null
): ContactCursor | null {
  if (!value) return null;
  try {
    const cursor = JSON.parse(
      Buffer.from(value, "base64url").toString("utf8")
    ) as Partial<ContactCursor>;
    if (cursor.version !== 2 || typeof cursor.organizerId !== "string" ||
      cursor.organizerId.length === 0 || !cursor.plan ||
      !["people", "search", "segment", "manualTag"]
        .includes(cursor.plan) || typeof cursor.value !== "string" ||
      typeof cursor.contactId !== "string" || cursor.contactId.length === 0 ||
      !cursor.sort || !["lastSeen", "mostAttended", "name"]
      .includes(cursor.sort) ||
      !(typeof cursor.search === "string" || cursor.search === null) ||
      !(typeof cursor.segmentId === "string" || cursor.segmentId === null) ||
      !(typeof cursor.manualTagId === "string" ||
        cursor.manualTagId === null)) {
      throw new Error();
    }
    if (cursor.sort !== "name" &&
        (!Number.isSafeInteger(Number(cursor.value)) ||
          Number(cursor.value) < 0)) throw new Error();
    return cursor as ContactCursor;
  } catch {
    throw new HttpsError("invalid-argument", "Audience cursor is invalid.");
  }
}

export const mutateOrganizerContact = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 60, maxInstances: 20}),
  (request) => mutateOrganizerContactHandler(request)
);

export const createOrganizerContact = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 60, maxInstances: 20}),
  (request) => createOrganizerContactHandler(request)
);

export const createOrganizerContactNote = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 60, maxInstances: 20}),
  (request) => createOrganizerContactNoteHandler(request)
);

export const mutateOrganizerContactNote = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 60, maxInstances: 20}),
  (request) => mutateOrganizerContactNoteHandler(request)
);

export const exportOrganizerContacts = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 120, maxInstances: 10}),
  (request) => exportOrganizerContactsHandler(request)
);

function assertCursorPlan(
  cursor: ContactCursor | null,
  plan: ContactCursor["plan"],
  organizerId: string,
  search: string | null,
  segmentId: string | null,
  manualTagId: string | null,
  sort: ContactSort
): void {
  if (cursor && (cursor.plan !== plan ||
      cursor.organizerId !== organizerId || cursor.search !== search ||
      cursor.segmentId !== segmentId || cursor.manualTagId !== manualTagId ||
      cursor.sort !== sort)) {
    throw new HttpsError(
      "invalid-argument",
      "Audience cursor does not match the selected filters and sort order."
    );
  }
}

function normalizeListContactsPayload(value: unknown): unknown {
  if (!value || typeof value !== "object" || Array.isArray(value)) return value;
  const input = value as Record<string, unknown>;
  return {
    ...input,
    organizerId: normalizeString(input.organizerId),
    cursor: normalizeNullableString(input.cursor),
    query: normalizeNullableString(input.query),
    segmentId: normalizeNullableString(input.segmentId),
    manualTagId: normalizeNullableString(input.manualTagId),
    sort: normalizeString(input.sort),
  };
}

function normalizeContactDetailPayload(value: unknown): unknown {
  if (!value || typeof value !== "object" || Array.isArray(value)) return value;
  const input = value as Record<string, unknown>;
  return {
    ...input,
    organizerId: normalizeString(input.organizerId),
    contactId: normalizeString(input.contactId),
  };
}

function normalizeString(value: unknown): unknown {
  return typeof value === "string" ? value.trim() : value;
}

function normalizeNullableString(value: unknown): unknown {
  if (typeof value !== "string") return value;
  const normalized = value.trim();
  return normalized.length === 0 ? null : normalized;
}

export const listOrganizerContacts = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 60, maxInstances: 20}),
  (request) => listOrganizerContactsHandler(request)
);

export const getOrganizerContactDetail = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 60, maxInstances: 20}),
  (request) => getOrganizerContactDetailHandler(request)
);
