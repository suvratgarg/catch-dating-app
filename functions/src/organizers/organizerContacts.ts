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
import {
  OrganizerAudienceSummaryDocument,
  OrganizerContactDocument,
  OrganizerContactEventEdgeDocument,
  OrganizerContactTraitDocument,
} from "../shared/generated/firestoreAdminTypes";
import {ListOrganizerContactsCallablePayload} from
  "../shared/generated/listOrganizerContactsCallablePayload";
import {ListOrganizerContactsCallableResponse} from
  "../shared/generated/listOrganizerContactsCallableResponse";
import {
  validateGetOrganizerContactDetailCallablePayload,
  validateListOrganizerContactsCallablePayload,
} from "../shared/generated/schemaValidators";
import {requireOrganizerManager} from
  "../shared/organizerManagerAuthority";
import {checkRateLimit} from "../shared/rateLimit";
import {validateCallableWithAjv} from "../shared/validation";

const defaultContactPageSize = 50;
const maxDetailEvents = 100;

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
    .filter((item): item is ContactDocumentRow => item !== undefined) :
    contactPage;
  const traitSnaps = contacts.length === 0 ? [] : await db.getAll(
    ...contacts.map((item) => db.collection("organizerContactTraits")
      .doc(item.id))
  );
  const traitsById = new Map(traitSnaps
    .filter((snap) => snap.exists)
    .map((snap) => [snap.id, snap.data() as OrganizerContactTraitDocument]));
  const rows = contacts
    .map((item) => safeContactRow(item.id, item.data, traitsById.get(item.id)))
    .filter((item): item is NonNullable<typeof item> => item !== null);
  const hasMore = traitRows?.hasMore ?? contactPage.length > limit;
  const pageRows = rows.slice(0, limit);
  const finalContact = contacts.slice(0, limit).at(-1);
  const nextCursor = hasMore && finalContact ? encodeContactCursor({
    plan: data.segmentId ? "segment" : search ? "search" : "people",
    value: data.segmentId ? finalContact.id :
      search ? finalContact.data.searchName :
        String(finalContact.data.lastSeenAt.toMillis()),
    contactId: finalContact.id,
    segmentId: data.segmentId ?? null,
  }) : null;

  return {
    organizerId: data.organizerId,
    contacts: pageRows,
    nextCursor,
    sourceCoverage: summary?.sourceCoverage ?? "partial",
    projectionVersion: summary?.projectionVersion ?? 1,
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
  const [contactSnap, traitSnap, eventSnap] = await Promise.all([
    contactRef.get(),
    traitRef.get(),
    db.collection("organizerContactEventEdges")
      .where("contactId", "==", data.contactId)
      .orderBy("eventStartAt", "desc")
      .limit(maxDetailEvents + 1)
      .get(),
  ]);
  const contact = contactSnap.data() as OrganizerContactDocument | undefined;
  const traits = traitSnap.data() as OrganizerContactTraitDocument | undefined;
  if (!contact || contact.organizerId !== data.organizerId ||
      contact.deletedAt !== null || contact.identityState === "merged" ||
      !traits || traits.organizerId !== data.organizerId) {
    throw new HttpsError("not-found", "Audience contact not found.");
  }
  const events = eventSnap.docs.slice(0, maxDetailEvents)
    .map((doc) => eventDetailRow(
      doc.data() as OrganizerContactEventEdgeDocument
    ));
  return {
    organizerId: data.organizerId,
    contactId: data.contactId,
    displayName: contact.displayName,
    phoneE164: contact.phoneE164,
    email: contact.email,
    linkedAccount: contact.linkedUid !== null,
    identityState: activeIdentityState(contact.identityState),
    identityConfidence: contact.identityConfidence,
    ambiguousCandidateContactIds: contact.ambiguousCandidateContactIds,
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
    events,
    eventsTruncated: eventSnap.size > maxDetailEvents,
    revision: contact.revision,
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
    item.data.identityState !== "merged");
}

function safeContactRow(
  contactId: string,
  contact: OrganizerContactDocument,
  traits: OrganizerContactTraitDocument | undefined
): ListOrganizerContactsCallableResponse["contacts"][number] | null {
  if (!traits || traits.organizerId !== contact.organizerId ||
      contact.identityState === "merged") return null;
  return {
    contactId,
    displayName: contact.displayName,
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
