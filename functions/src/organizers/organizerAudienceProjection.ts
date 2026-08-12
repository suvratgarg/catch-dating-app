import {createHash} from "crypto";
import * as admin from "firebase-admin";
import {defineSecret} from "firebase-functions/params";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {organizerCommunicationPreferenceId} from
  "../shared/organizerCommunicationPreferences";
import {
  EventAttendeeDocument,
  EventDocument,
  OrganizerAudienceProjectionReceiptDocument,
  OrganizerAudienceSummaryDocument,
  OrganizerCommunicationPreferenceDocument,
  OrganizerContactDocument,
  OrganizerContactEventEdgeDocument,
  OrganizerContactIdentityClaimDocument,
  OrganizerContactIdentityLinkDocument,
  OrganizerContactTraitDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  attendeeIdentityEvidence,
  OrganizerAudienceContribution,
  organizerAudienceContribution,
  organizerAudienceProjectionVersion,
  organizerContactEventEdge,
  organizerContactId,
  organizerContactTraits,
  organizerIdentityClaimId,
  organizerIdentityEvidenceId,
} from "./organizerAudienceModel";

export const organizerContactIdentityKey = defineSecret(
  "ORGANIZER_CONTACT_IDENTITY_KEY"
);

const projectionReceiptTtlMillis = 30 * 24 * 60 * 60 * 1000;

export interface AudienceProjectionDeps {
  firestore: () => FirebaseFirestore.Firestore;
  timestamp: () => FirebaseFirestore.Timestamp;
  identitySecret: () => string;
}

const defaultDeps: AudienceProjectionDeps = {
  firestore: () => admin.firestore(),
  timestamp: () => admin.firestore.Timestamp.now(),
  identitySecret: () => organizerContactIdentityKey.value(),
};

/** Projects one canonical operational attendee into the organizer audience. */
export async function projectEventAttendeeToOrganizerAudience(
  attendeeId: string,
  before: EventAttendeeDocument | undefined,
  after: EventAttendeeDocument | undefined,
  projectionEventId?: string,
  deps: AudienceProjectionDeps = defaultDeps
): Promise<void> {
  if (!before && !after) return;
  const db = deps.firestore();
  const edgeRef = db.collection("organizerContactEventEdges").doc(attendeeId);
  const existingEdgeSnap = await edgeRef.get();
  const existingEdge = existingEdgeSnap.data() as
    OrganizerContactEventEdgeDocument | undefined;
  const affectedContactIds = new Set<string>();
  const receiptBase = projectionEventId ?? deterministicAttendeeReceiptId(
    attendeeId,
    after ?? before!
  );

  if (!after) {
    if (!existingEdge) return;
    affectedContactIds.add(existingEdge.contactId);
    const evidenceSnap = await db
      .collection("organizerContactIdentityLinks")
      .where("attendeeId", "==", attendeeId)
      .get();
    const batch = db.batch();
    batch.delete(edgeRef);
    for (const evidence of evidenceSnap.docs) batch.delete(evidence.ref);
    await batch.commit();
    await rebuildOrganizerContact(
      existingEdge.contactId,
      `${receiptBase}|${existingEdge.contactId}`,
      deps
    );
    return;
  }
  if (existingEdge && existingEdge.sourceUpdatedAt.toMillis() >
      after.updatedAt.toMillis()) {
    return;
  }

  const now = deps.timestamp();
  const evidence = attendeeIdentityEvidence({
    attendee: after,
    secret: deps.identitySecret(),
  });
  const verifiedEvidence = evidence.filter((item) =>
    item.confidence === "verified" &&
      (item.kind === "uid" || item.kind === "phone")
  );
  const claimRefs = verifiedEvidence.map((item) => db
    .collection("organizerContactIdentityClaims")
    .doc(organizerIdentityClaimId(item.identityHash)));
  const fallbackContactId = existingEdge?.contactId ??
    organizerContactId(after.organizerId, attendeeId);
  const proposedCandidateIds = new Set<string>();
  for (const item of verifiedEvidence) {
    const candidates = await db.collection("organizerContactIdentityLinks")
      .where("identityHash", "==", item.identityHash)
      .limit(21)
      .get();
    for (const candidate of candidates.docs) {
      const link = candidate.data() as OrganizerContactIdentityLinkDocument;
      if (link.organizerId === after.organizerId) {
        proposedCandidateIds.add(link.contactId);
      }
    }
  }
  const desiredContactId = proposedCandidateIds.size === 1 ?
    [...proposedCandidateIds][0] : fallbackContactId;
  const claimResolution = claimRefs.length === 0 ? {
    contactId: desiredContactId,
    ambiguousContactIds: proposedCandidateIds.size > 1 ?
      [...proposedCandidateIds] : [] as string[],
  } : await db.runTransaction(async (tx) => {
    const claimSnaps = await Promise.all(claimRefs.map((ref) => tx.get(ref)));
    const claimedContactIds = new Set(claimSnaps
      .filter((snap) => snap.exists)
      .map((snap) => (snap.data() as OrganizerContactIdentityClaimDocument)
        .verifiedContactId));
    const contactId = claimedContactIds.size === 1 ?
      [...claimedContactIds][0] : desiredContactId;
    const allContactIds = new Set([...claimedContactIds, contactId]);
    const conflicted = allContactIds.size > 1;
    for (let index = 0; index < claimRefs.length; index += 1) {
      const claimRef = claimRefs[index];
      const snap = claimSnaps[index];
      const existing = snap.data() as
        OrganizerContactIdentityClaimDocument | undefined;
      const claim: OrganizerContactIdentityClaimDocument = {
        organizerId: after.organizerId,
        kind: verifiedEvidence[index].kind as "uid" | "phone",
        identityHash: verifiedEvidence[index].identityHash,
        hashVersion: "hmac-sha256-v1",
        verifiedContactId: existing?.verifiedContactId ?? contactId,
        originVerifiedContactId: existing?.originVerifiedContactId ??
          existing?.verifiedContactId ?? contactId,
        state: conflicted ? "conflicted" : "verified",
        conflictingContactIds: conflicted ? [...allContactIds]
          .filter((candidate) =>
            candidate !== (existing?.verifiedContactId ?? contactId)
          ).slice(0, 20) : [],
        revision: Math.max(existing?.revision ?? 0, now.toMillis(), 1),
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      };
      if (existing) tx.set(claimRef, claim);
      else tx.create(claimRef, claim);
    }
    const proposedAmbiguities = proposedCandidateIds.size > 1 ?
      [...proposedCandidateIds].filter((candidate) => candidate !== contactId) :
      [];
    return {
      contactId,
      ambiguousContactIds: [...new Set([
        ...(conflicted ? [...allContactIds]
          .filter((candidate) => candidate !== contactId) : []),
        ...proposedAmbiguities,
      ])],
    };
  });
  const contactId = claimResolution.contactId;

  if (existingEdge && existingEdge.contactId !== contactId) {
    affectedContactIds.add(existingEdge.contactId);
  }
  affectedContactIds.add(contactId);

  const eventSnap = await db.collection("events").doc(after.eventId).get();
  const event = eventSnap.data() as EventDocument | undefined;
  const existingContactRef = db.collection("organizerContacts").doc(contactId);
  const preferenceRef = after.linkedUid === null ? null : db
    .collection("organizerCommunicationPreferences")
    .doc(organizerCommunicationPreferenceId(
      after.organizerId,
      after.linkedUid
    ));
  const [existingContactSnap, preferenceSnap] = await Promise.all([
    existingContactRef.get(),
    preferenceRef?.get() ?? Promise.resolve(null),
  ]);
  const existingContact = existingContactSnap.data() as
    OrganizerContactDocument | undefined;
  const preference = preferenceSnap?.data() as
    OrganizerCommunicationPreferenceDocument | undefined;
  const edge = organizerContactEventEdge({
    attendeeId,
    attendee: after,
    contactId,
    eventStartAt: event?.startTime ?? null,
    eventEndAt: event?.endTime ?? null,
    now,
    existing: existingEdge?.contactId === contactId ? existingEdge : undefined,
  });
  const contact = buildOrganizerContact({
    attendee: after,
    existing: existingContact,
    edge,
    ambiguousCandidateContactIds: claimResolution.ambiguousContactIds,
    preference,
    now,
  });
  const existingEvidenceSnap = await db
    .collection("organizerContactIdentityLinks")
    .where("attendeeId", "==", attendeeId)
    .get();
  const currentEvidenceIds = new Set(evidence.map((item) =>
    organizerIdentityEvidenceId({
      attendeeId,
      kind: item.kind,
      identityHash: item.identityHash,
    })
  ));
  const batch = db.batch();
  batch.set(edgeRef, edge);
  batch.set(existingContactRef, contact);
  for (const existingEvidence of existingEvidenceSnap.docs) {
    if (!currentEvidenceIds.has(existingEvidence.id)) {
      batch.delete(existingEvidence.ref);
    }
  }
  for (const item of evidence) {
    const evidenceId = organizerIdentityEvidenceId({
      attendeeId,
      kind: item.kind,
      identityHash: item.identityHash,
    });
    const evidenceRef = db.collection("organizerContactIdentityLinks")
      .doc(evidenceId);
    const link: OrganizerContactIdentityLinkDocument = {
      organizerId: after.organizerId,
      contactId,
      originContactId: (existingEvidenceSnap.docs.find((doc) =>
        doc.id === evidenceId
      )?.data() as OrganizerContactIdentityLinkDocument | undefined)
        ?.originContactId ?? contactId,
      attendeeId,
      kind: item.kind,
      identityHash: item.identityHash,
      hashVersion: "hmac-sha256-v1",
      confidence: item.confidence,
      source: after.source,
      createdAt: after.createdAt,
      updatedAt: now,
    };
    batch.set(evidenceRef, link, {merge: true});
  }
  await batch.commit();

  for (const affectedContactId of affectedContactIds) {
    await rebuildOrganizerContact(
      affectedContactId,
      `${receiptBase}|${affectedContactId}`,
      deps
    );
  }
}

/** Rebuilds contact fields and traits from canonical event edges. */
export async function rebuildOrganizerContact(
  contactId: string,
  summaryEventId: string,
  deps: AudienceProjectionDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const contactRef = db.collection("organizerContacts").doc(contactId);
  const traitRef = db.collection("organizerContactTraits").doc(contactId);
  const [contactSnap, edgesSnap] = await Promise.all([
    contactRef.get(),
    db.collection("organizerContactEventEdges")
      .where("contactId", "==", contactId)
      .get(),
  ]);
  const contact = contactSnap.data() as OrganizerContactDocument | undefined;
  if (!contact) return;
  const now = deps.timestamp();
  const edges = edgesSnap.docs.map((doc) =>
    doc.data() as OrganizerContactEventEdgeDocument
  );
  if (edges.length === 0) {
    await commitContactTraitAndSummary({
      contactRef,
      contactPatch: {deletedAt: now, updatedAt: now},
      traitRef,
      afterTrait: undefined,
      organizerId: contact.organizerId,
      summaryEventId,
      now,
      deps,
    });
    return;
  }
  const preferred = [...edges].sort(compareContactEdges)[0];
  const linked = edges.find((edge) => edge.linkedUid !== null) ?? preferred;
  const rebuiltContact: OrganizerContactDocument = {
    ...contact,
    displayName: preferred.displayName,
    searchName: preferred.displayName.toLocaleLowerCase("en"),
    linkedUid: linked.linkedUid,
    phoneE164: linked.phoneE164 ?? preferred.phoneE164,
    email: linked.email ?? preferred.email,
    identityState: contact.ambiguousCandidateContactIds.length > 0 ?
      "ambiguous" : linked.linkedUid !== null ? "verified" : "unlinked",
    identityConfidence: linked.linkedUid !== null ? "verified" :
      linked.phoneE164 !== null || linked.email !== null ?
        "proposed" : "eventOnly",
    primarySource: preferred.source,
    firstSeenAt: edges.map((edge) => edge.sourceCreatedAt)
      .sort(compareTimestamp)[0],
    lastSeenAt: edges.map((edge) => edge.sourceUpdatedAt)
      .sort(compareTimestamp).at(-1)!,
    sourceCount: edges.length,
    revision: Math.max(contact.revision + 1, now.toMillis()),
    updatedAt: now,
    deletedAt: null,
  };
  const traits = organizerContactTraits({
    contactId,
    contact: rebuiltContact,
    edges,
    now,
  });
  await commitContactTraitAndSummary({
    contactRef,
    contact: rebuiltContact,
    traitRef,
    afterTrait: traits ?? undefined,
    summaryEventId,
    now,
    deps,
  });
}

/** Applies organizer communication grants to every verified UID contact. */
export async function projectOrganizerCommunicationPreference(
  before: OrganizerCommunicationPreferenceDocument | undefined,
  after: OrganizerCommunicationPreferenceDocument | undefined,
  projectionEventId?: string,
  deps: AudienceProjectionDeps = defaultDeps
): Promise<void> {
  const preference = after ?? before;
  if (!preference) return;
  const db = deps.firestore();
  const contactsSnap = await db.collection("organizerContacts")
    .where("organizerId", "==", preference.organizerId)
    .where("linkedUid", "==", preference.uid)
    .get();
  const now = deps.timestamp();
  const receiptBase = projectionEventId ??
    `preference:${preference.organizerId}:${preference.uid}:` +
      `${preference.updatedAt.toMillis()}`;
  for (const doc of contactsSnap.docs) {
    await doc.ref.update({
      whatsappStatus: after?.whatsapp.status ?? "unknown",
      smsStatus: after?.sms.status ?? "unknown",
      revision: Math.max(
        (doc.data() as OrganizerContactDocument).revision + 1,
        now.toMillis()
      ),
      updatedAt: now,
    });
    await rebuildOrganizerContact(
      doc.id,
      `${receiptBase}|${doc.id}`,
      deps
    );
  }
}

/** Applies one trait contribution exactly once to the summary. */
export async function applyOrganizerAudienceSummaryDelta(
  eventId: string,
  before: OrganizerContactTraitDocument | undefined,
  after: OrganizerContactTraitDocument | undefined,
  deps: AudienceProjectionDeps = defaultDeps
): Promise<void> {
  const organizerId = after?.organizerId ?? before?.organizerId;
  if (!organizerId) return;
  const db = deps.firestore();
  const now = deps.timestamp();
  const receiptId = `oapr_${createHash("sha256")
    .update(eventId).digest("hex").slice(0, 48)}`;
  const receiptRef = db.collection("organizerAudienceProjectionReceipts")
    .doc(receiptId);
  const summaryRef = db.collection("organizerAudienceSummaries")
    .doc(organizerId);
  const beforeContribution = organizerAudienceContribution(before);
  const afterContribution = organizerAudienceContribution(after);
  await db.runTransaction(async (tx) => {
    const [receiptSnap, summarySnap] = await Promise.all([
      tx.get(receiptRef),
      tx.get(summaryRef),
    ]);
    if (receiptSnap.exists) return;
    const existing = summarySnap.data() as
      OrganizerAudienceSummaryDocument | undefined;
    const summary = audienceSummaryAfterDelta({
      organizerId,
      existing,
      before: beforeContribution,
      after: afterContribution,
      now,
    });
    const receipt: OrganizerAudienceProjectionReceiptDocument = {
      organizerId,
      eventId,
      createdAt: now,
      expiresAt: admin.firestore.Timestamp.fromMillis(
        now.toMillis() + projectionReceiptTtlMillis
      ),
    };
    tx.set(summaryRef, summary);
    tx.create(receiptRef, receipt);
  });
}

async function commitContactTraitAndSummary(params: {
  contactRef: FirebaseFirestore.DocumentReference;
  contact?: OrganizerContactDocument;
  contactPatch?: FirebaseFirestore.UpdateData<OrganizerContactDocument>;
  traitRef: FirebaseFirestore.DocumentReference;
  afterTrait: OrganizerContactTraitDocument | undefined;
  organizerId?: string;
  summaryEventId: string;
  now: FirebaseFirestore.Timestamp;
  deps: AudienceProjectionDeps;
}): Promise<void> {
  const organizerId = params.afterTrait?.organizerId ??
    params.contact?.organizerId ?? params.organizerId;
  if (!organizerId) return;
  const db = params.deps.firestore();
  const receiptId = `oapr_${createHash("sha256")
    .update(params.summaryEventId).digest("hex").slice(0, 48)}`;
  const receiptRef = db.collection("organizerAudienceProjectionReceipts")
    .doc(receiptId);
  const summaryRef = db.collection("organizerAudienceSummaries")
    .doc(organizerId);
  await db.runTransaction(async (tx) => {
    const [receiptSnap, summarySnap, currentTraitSnap] = await Promise.all([
      tx.get(receiptRef),
      tx.get(summaryRef),
      tx.get(params.traitRef),
    ]);
    if (receiptSnap.exists) return;
    const beforeTrait = currentTraitSnap.data() as
      OrganizerContactTraitDocument | undefined;
    const existing = summarySnap.data() as
      OrganizerAudienceSummaryDocument | undefined;
    const summary = audienceSummaryAfterDelta({
      organizerId,
      existing,
      before: organizerAudienceContribution(beforeTrait),
      after: organizerAudienceContribution(params.afterTrait),
      now: params.now,
    });
    const receipt: OrganizerAudienceProjectionReceiptDocument = {
      organizerId,
      eventId: params.summaryEventId,
      createdAt: params.now,
      expiresAt: admin.firestore.Timestamp.fromMillis(
        params.now.toMillis() + projectionReceiptTtlMillis
      ),
    };
    if (params.contact) tx.set(params.contactRef, params.contact);
    else if (params.contactPatch) {
      tx.update(params.contactRef, params.contactPatch);
    }
    if (params.afterTrait) tx.set(params.traitRef, params.afterTrait);
    else tx.delete(params.traitRef);
    tx.set(summaryRef, summary);
    tx.create(receiptRef, receipt);
  });
}

/** Recomputes one organizer summary from indexed trait aggregations. */
export async function rebuildOrganizerAudienceSummary(
  organizerId: string,
  sourceCoverage: OrganizerAudienceSummaryDocument["sourceCoverage"],
  deps: Pick<AudienceProjectionDeps, "firestore" | "timestamp"> = defaultDeps
): Promise<OrganizerAudienceSummaryDocument> {
  const db = deps.firestore();
  const traits = db.collection("organizerContactTraits")
    .where("organizerId", "==", organizerId);
  const [
    contactCount,
    pastAttendeeCount,
    repeatAttendeeCount,
    linkedAccountCount,
    importedContactCount,
    whatsappOptInCount,
    smsOptInCount,
  ] = await Promise.all([
    traits.count().get(),
    traits.where("attendedEventCount", ">", 0).count().get(),
    traits.where("attendedEventCount", ">", 1).count().get(),
    traits.where("linkedAccount", "==", true).count().get(),
    traits.where("importedEventCount", ">", 0).count().get(),
    traits.where("whatsappStatus", "==", "optedIn").count().get(),
    traits.where("smsStatus", "==", "optedIn").count().get(),
  ]);
  const summary: OrganizerAudienceSummaryDocument = {
    organizerId,
    contactCount: contactCount.data().count,
    pastAttendeeCount: pastAttendeeCount.data().count,
    repeatAttendeeCount: repeatAttendeeCount.data().count,
    linkedAccountCount: linkedAccountCount.data().count,
    importedContactCount: importedContactCount.data().count,
    whatsappOptInCount: whatsappOptInCount.data().count,
    smsOptInCount: smsOptInCount.data().count,
    sourceCoverage,
    projectionVersion: organizerAudienceProjectionVersion,
    computedAt: deps.timestamp(),
  };
  await db.collection("organizerAudienceSummaries").doc(organizerId)
    .set(summary);
  return summary;
}

export function audienceSummaryAfterDelta(params: {
  organizerId: string;
  existing?: OrganizerAudienceSummaryDocument;
  before: OrganizerAudienceContribution;
  after: OrganizerAudienceContribution;
  now: FirebaseFirestore.Timestamp;
}): OrganizerAudienceSummaryDocument {
  const value = (field: keyof OrganizerAudienceContribution) => Math.max(
    0,
    (params.existing?.[field] ?? 0) - params.before[field] +
      params.after[field]
  );
  return {
    organizerId: params.organizerId,
    contactCount: value("contactCount"),
    pastAttendeeCount: value("pastAttendeeCount"),
    repeatAttendeeCount: value("repeatAttendeeCount"),
    linkedAccountCount: value("linkedAccountCount"),
    importedContactCount: value("importedContactCount"),
    whatsappOptInCount: value("whatsappOptInCount"),
    smsOptInCount: value("smsOptInCount"),
    sourceCoverage: params.existing?.sourceCoverage ?? "partial",
    projectionVersion: organizerAudienceProjectionVersion,
    computedAt: params.now,
  };
}

function buildOrganizerContact(params: {
  attendee: EventAttendeeDocument;
  existing?: OrganizerContactDocument;
  edge: OrganizerContactEventEdgeDocument;
  ambiguousCandidateContactIds: string[];
  preference?: OrganizerCommunicationPreferenceDocument;
  now: FirebaseFirestore.Timestamp;
}): OrganizerContactDocument {
  const {attendee, existing, edge, now} = params;
  const linked = attendee.linkedUid !== null;
  return {
    organizerId: attendee.organizerId,
    displayName: attendee.displayName,
    searchName: attendee.searchName,
    linkedUid: attendee.linkedUid ?? existing?.linkedUid ?? null,
    phoneE164: attendee.phoneE164 ?? existing?.phoneE164 ?? null,
    email: edge.email ?? existing?.email ?? null,
    identityState: params.ambiguousCandidateContactIds.length > 0 ?
      "ambiguous" : linked ? "verified" : "unlinked",
    identityConfidence: linked ? "verified" :
      attendee.phoneE164 !== null || attendee.email !== null ?
        "proposed" : "eventOnly",
    primarySource: existing?.primarySource ?? attendee.source,
    ambiguousCandidateContactIds: params.ambiguousCandidateContactIds,
    firstSeenAt: existing?.firstSeenAt ?? attendee.createdAt,
    lastSeenAt: attendee.updatedAt,
    sourceCount: existing?.sourceCount ?? 1,
    whatsappStatus: params.preference?.whatsapp.status ??
      existing?.whatsappStatus ?? "unknown",
    smsStatus: params.preference?.sms.status ??
      existing?.smsStatus ?? "unknown",
    revision: Math.max(existing?.revision ?? 0, now.toMillis(), 1),
    mergedIntoContactId: existing?.mergedIntoContactId ?? null,
    createdAt: existing?.createdAt ?? now,
    updatedAt: now,
    deletedAt: null,
  };
}

function compareContactEdges(
  left: OrganizerContactEventEdgeDocument,
  right: OrganizerContactEventEdgeDocument
): number {
  const identityDifference = Number(right.linkedUid !== null) -
    Number(left.linkedUid !== null);
  if (identityDifference !== 0) return identityDifference;
  return right.sourceUpdatedAt.toMillis() - left.sourceUpdatedAt.toMillis();
}

function compareTimestamp(
  left: FirebaseFirestore.Timestamp,
  right: FirebaseFirestore.Timestamp
): number {
  return left.toMillis() - right.toMillis();
}

function deterministicAttendeeReceiptId(
  attendeeId: string,
  attendee: EventAttendeeDocument
): string {
  return `attendee:${attendeeId}:${attendee.updatedAt.toMillis()}:` +
    `${attendee.status}:${attendee.linkedUid ?? "unlinked"}`;
}

export const onEventAttendeeAudienceProjected = onDocumentWritten(
  {
    document: "eventAttendees/{attendeeId}",
    secrets: [organizerContactIdentityKey],
  },
  async (event) => {
    const before = event.data?.before.data() as
      EventAttendeeDocument | undefined;
    const after = event.data?.after.data() as
      EventAttendeeDocument | undefined;
    await projectEventAttendeeToOrganizerAudience(
      event.params.attendeeId,
      before,
      after,
      event.id
    );
  }
);

export const onOrganizerCommunicationPreferenceAudienceProjected =
  onDocumentWritten(
    "organizerCommunicationPreferences/{preferenceId}",
    async (event) => {
      const before = event.data?.before.data() as
        OrganizerCommunicationPreferenceDocument | undefined;
      const after = event.data?.after.data() as
        OrganizerCommunicationPreferenceDocument | undefined;
      await projectOrganizerCommunicationPreference(before, after, event.id);
    }
  );
