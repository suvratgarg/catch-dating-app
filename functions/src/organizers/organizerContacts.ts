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
import {ExportOrganizerContactsCallablePayload} from
  "../shared/generated/exportOrganizerContactsCallablePayload";
import {ExportOrganizerContactsCallableResponse} from
  "../shared/generated/exportOrganizerContactsCallableResponse";
import {MutateOrganizerContactCallablePayload} from
  "../shared/generated/mutateOrganizerContactCallablePayload";
import {MutateOrganizerContactCallableResponse} from
  "../shared/generated/mutateOrganizerContactCallableResponse";
import {
  OrganizerAudienceSummaryDocument,
  OrganizerContactDocument,
  OrganizerContactChannelStateDocument,
  OrganizerContactEventEdgeDocument,
  OrganizerContactTraitDocument,
  PaymentDocument,
} from "../shared/generated/firestoreAdminTypes";
import {ListOrganizerContactsCallablePayload} from
  "../shared/generated/listOrganizerContactsCallablePayload";
import {ListOrganizerContactsCallableResponse} from
  "../shared/generated/listOrganizerContactsCallableResponse";
import {
  validateExportOrganizerContactsCallablePayload,
  validateCreateOrganizerContactCallablePayload,
  validateGetOrganizerContactDetailCallablePayload,
  validateListOrganizerContactsCallablePayload,
  validateMutateOrganizerContactCallablePayload,
} from "../shared/generated/schemaValidators";
import {requireOrganizerManager} from
  "../shared/organizerManagerAuthority";
import {checkRateLimit} from "../shared/rateLimit";
import {validateCallableWithAjv} from "../shared/validation";
import {organizerContactChannelStateId} from "./organizerCampaignModel";

const defaultContactPageSize = 50;
const maxDetailEvents = 100;
const maxExportContacts = 2500;
const maxContactPayments = 500;

interface OrganizerContactsDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
}

const defaultDeps: OrganizerContactsDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
};

interface ContactCursor {
  plan: "people" | "search" | "segment";
  value: string;
  contactId: string;
  segmentId: string | null;
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
  const summarySnap = await db.collection("organizerAudienceSummaries")
    .doc(data.organizerId).get();
  const summary = summarySnap.data() as
    OrganizerAudienceSummaryDocument | undefined;
  const limit = data.limit ?? defaultContactPageSize;
  const search = normalizeSearch(data.query ?? null);
  const cursor = decodeContactCursor(data.cursor ?? null);
  const exactMatchCountPromise = exactListContactsMatchCount({
    db,
    organizerId: data.organizerId,
    segmentId: data.segmentId ?? null,
    search,
    summary,
  });

  const traitRows = data.segmentId ? await listSegmentTraitRows({
    db,
    organizerId: data.organizerId,
    segmentId: data.segmentId,
    cursor,
    limit,
  }) : null;
  const contactIds = traitRows?.contactIds ?? null;
  const contactPage = contactIds ? await getContactsById(db, contactIds) :
    await listContactDocuments({
      db,
      organizerId: data.organizerId,
      search,
      cursor,
      limit,
    });
  const contacts = contactIds ? contactIds
    .map((contactId) => contactPage.find((item) => item.id === contactId))
    .filter((item): item is ContactDocumentRow => item !== undefined)
    .filter((item) => !search || item.data.searchName.startsWith(search)) :
    contactPage;
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
      channelByContactId.get(item.id)
    ))
    .filter((item): item is NonNullable<typeof item> => item !== null);
  const hasMore = traitRows?.hasMore ?? contactPage.length > limit;
  const pageRows = rows.slice(0, limit);
  const finalContact = contacts.slice(0, limit).at(-1);
  const finalContactId = data.segmentId ? traitRows?.contactIds.at(-1) :
    finalContact?.id;
  const nextCursor = hasMore && finalContactId ? encodeContactCursor({
    plan: data.segmentId ? "segment" : search ? "search" : "people",
    value: data.segmentId ? finalContactId :
      search ? finalContact!.data.searchName :
        String(finalContact!.data.lastSeenAt.toMillis()),
    contactId: finalContactId,
    segmentId: data.segmentId ?? null,
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
  search: string | null;
  summary: OrganizerAudienceSummaryDocument | undefined;
}): Promise<number | null> {
  if (params.search) return null;
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
  const [contactSnap, traitSnap, eventSnap, channelSnap] = await Promise.all([
    contactRef.get(),
    traitRef.get(),
    db.collection("organizerContactEventEdges")
      .where("contactId", "==", data.contactId)
      .orderBy("eventStartAt", "desc")
      .limit(maxDetailEvents + 1)
      .get(),
    channelRef.get(),
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
    revision: contact.revision,
  };
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
    const [contactSnap, channelSnap, traitSnap, summarySnap] =
      await Promise.all([
        tx.get(contactRef),
        tx.get(channelRef),
        tx.get(traitRef),
        tx.get(summaryRef),
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
      revision,
    };
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

async function listContactDocuments(params: {
  db: FirebaseFirestore.Firestore;
  organizerId: string;
  search: string | null;
  cursor: ContactCursor | null;
  limit: number;
}): Promise<ContactDocumentRow[]> {
  const plan = params.search ? "search" : "people";
  assertCursorPlan(params.cursor, plan, null);
  let query: FirebaseFirestore.Query = params.db
    .collection("organizerContacts")
    .where("organizerId", "==", params.organizerId)
    .where("deletedAt", "==", null);
  if (params.search) {
    query = query.orderBy("searchName").orderBy(
      admin.firestore.FieldPath.documentId()
    ).startAt(params.search).endAt(`${params.search}\uf8ff`);
    if (params.cursor) {
      query = query.startAfter(params.cursor.value, params.cursor.contactId);
    }
  } else {
    query = query.orderBy("lastSeenAt", "desc").orderBy(
      admin.firestore.FieldPath.documentId(), "desc"
    );
    if (params.cursor) {
      query = query.startAfter(
        admin.firestore.Timestamp.fromMillis(Number(params.cursor.value)),
        params.cursor.contactId
      );
    }
  }
  const snap = await query.limit(params.limit + 1).get();
  return snap.docs.map((doc) => ({
    id: doc.id,
    data: doc.data() as OrganizerContactDocument,
  }));
}

async function listSegmentTraitRows(params: {
  db: FirebaseFirestore.Firestore;
  organizerId: string;
  segmentId: OrganizerContactTraitDocument["segmentIds"][number];
  cursor: ContactCursor | null;
  limit: number;
}): Promise<{contactIds: string[]; hasMore: boolean}> {
  assertCursorPlan(params.cursor, "segment", params.segmentId);
  let query: FirebaseFirestore.Query = params.db
    .collection("organizerContactTraits")
    .where("organizerId", "==", params.organizerId)
    .where("segmentIds", "array-contains", params.segmentId)
    .orderBy(admin.firestore.FieldPath.documentId());
  if (params.cursor) query = query.startAfter(params.cursor.contactId);
  const snapshot = await query.limit(params.limit + 1).get();
  return {
    contactIds: snapshot.docs.slice(0, params.limit).map((doc) => doc.id),
    hasMore: snapshot.size > params.limit,
  };
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
  channelState?: OrganizerContactChannelStateDocument
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
    whatsappStatus: traits.whatsappStatus,
    whatsappAdminSuppressed:
      channelState?.adminSuppressed === true,
    smsStatus: traits.smsStatus,
    sourceCoverage: traits.sourceCoverage,
    revision: contact.revision,
  };
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
  return normalized;
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
    if (!cursor.plan || !["people", "search", "segment"]
      .includes(cursor.plan) || typeof cursor.value !== "string" ||
      typeof cursor.contactId !== "string" || cursor.contactId.length === 0 ||
      !(typeof cursor.segmentId === "string" || cursor.segmentId === null)) {
      throw new Error();
    }
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

export const exportOrganizerContacts = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 120, maxInstances: 10}),
  (request) => exportOrganizerContactsHandler(request)
);

function assertCursorPlan(
  cursor: ContactCursor | null,
  plan: ContactCursor["plan"],
  segmentId: string | null
): void {
  if (cursor && (cursor.plan !== plan || cursor.segmentId !== segmentId)) {
    throw new HttpsError(
      "invalid-argument",
      "Audience cursor does not match the selected filters."
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
