import type {Query, Firestore} from "firebase-admin/firestore";
import {
  requireMillis,
  sameScope,
  scopeId,
  type AnchorFacts,
  type MomentDefinition,
  type MomentScope,
  type RunRecord,
} from "./momentModel";
import type {RecipientEndpoint} from "./momentPolicy";

/**
 * Document <-> domain boundary for the moments collections. Documents are
 * read leniently (unknown/extra fields ignored, missing required fields
 * reject the doc) so the runner keeps working across schema iterations;
 * the contract schemas own strictness once registered.
 */

export const MOMENTS_COLLECTION = "organizerMoments";
export const MOMENT_RUNS_COLLECTION = "organizerMomentRuns";
export const MOMENT_SENDS_COLLECTION = "organizerMomentSends";

export function momentFromDocument(
  data: Record<string, unknown>,
): MomentDefinition | null {
  const scope = readScope(data.scope);
  const initiation = readInitiation(data.initiation);
  const audience = readAudience(data.audience);
  const action = readAction(data.action);
  if (!scope || !initiation || !audience || !action) return null;
  const status = data.status;
  if (status !== "draft" && status !== "armed" && status !== "paused" &&
      status !== "done") return null;
  return {
    momentId: requireString(data.momentId, "momentId"),
    scope,
    name: requireString(data.name, "name"),
    initiation,
    sense: data.sense === "individual" ? "individual" : "audience",
    audience,
    action,
    status,
    approval: readApproval(data.approval),
    origin: data.origin === "systemDefault" ? "systemDefault" : "organizer",
    revision: readInt(data.revision, 1),
  };
}

/** Serializes a definition for storage; scopeKind/scopeId are denormalized
 *  for list queries. */
export function momentToDocument(
  moment: MomentDefinition,
  nowMillis: number,
  isCreate: boolean,
): Record<string, unknown> {
  return {
    momentId: moment.momentId,
    scope: moment.scope,
    scopeKind: moment.scope.kind,
    scopeId: scopeId(moment.scope),
    name: moment.name,
    initiation: moment.initiation,
    sense: moment.sense,
    audience: moment.audience,
    action: moment.action,
    status: moment.status,
    approval: moment.approval,
    origin: moment.origin,
    revision: moment.revision,
    updatedAtMillis: nowMillis,
    ...(isCreate ? {createdAtMillis: nowMillis} : {}),
  };
}

export function runFromDocument(data: Record<string, unknown>): RunRecord {
  const status = data.status;
  if (status !== "planned" && status !== "resolving" &&
      status !== "dispatched" && status !== "skipped" &&
      status !== "superseded" && status !== "failed") {
    throw new RangeError(`Unknown run status: ${String(status)}`);
  }
  return {
    runId: requireString(data.runId, "runId"),
    momentId: requireString(data.momentId, "momentId"),
    dueAtMillis: readInt(data.dueAtMillis, 0),
    anchorRevision: readInt(data.anchorRevision, 0),
    status,
    ...(typeof data.targetFunctionId === "string" ?
      {targetFunctionId: data.targetFunctionId} : {}),
    ...(typeof data.subjectId === "string" ?
      {subjectId: data.subjectId} : {}),
  };
}

// --- Facts -----------------------------------------------------------------

/**
 * Assembles the AnchorFacts a moment plans/fires against. Program scopes
 * read organizerPrograms + programFunctions + programTravelLegs; event
 * scopes read the events doc. A non-active scope reports `cancelled` so
 * fire-time dispositions fail closed.
 */
export async function loadAnchorFacts(
  db: Firestore,
  scope: MomentScope,
): Promise<AnchorFacts | null> {
  if (scope.kind === "event") {
    const doc = await db.collection("events").doc(scope.eventId).get();
    if (!doc.exists) return null;
    const data = doc.data() as Record<string, unknown>;
    const start = readTimestamp(data.startTime);
    if (start === null) return null;
    return {
      scope: {
        startsAtMillis: start,
        endsAtMillis: readTimestamp(data.endTime),
        rsvpDeadlineAtMillis: null,
        revision: readInt(data.revision, 0),
        messagingEnabled: true,
        cancelled: data.status !== "active",
      },
      functions: {},
      travelLegs: {},
    };
  }
  const program = await db.collection("organizerPrograms")
    .doc(scope.programId).get();
  if (!program.exists) return null;
  const pdata = program.data() as Record<string, unknown>;
  const startsAt = readTimestamp(pdata.startsAt);
  if (startsAt === null) return null;
  const capabilities = Array.isArray(pdata.capabilities) ?
    pdata.capabilities : [];
  const functions = await db.collection("programFunctions")
    .where("programId", "==", scope.programId).get();
  const legs = await db.collection("programTravelLegs")
    .where("programId", "==", scope.programId).get();
  return {
    scope: {
      startsAtMillis: startsAt,
      endsAtMillis: readTimestamp(pdata.endsAt),
      // RSVP deadlines are not a program field yet; the anchor stays
      // unresolved (missingAnchor) until the contract adds one.
      rsvpDeadlineAtMillis: null,
      revision: readInt(pdata.revision, 0),
      messagingEnabled: capabilities.includes("messaging"),
      cancelled: pdata.status !== "active",
    },
    functions: Object.fromEntries(functions.docs.map((doc) => {
      const fn = doc.data() as Record<string, unknown>;
      return [doc.id, {
        startsAtMillis: readTimestamp(fn.startsAt) ?? 0,
        endsAtMillis: readTimestamp(fn.endsAt) ?? 0,
        revision: readInt(fn.revision, 0),
        cancelled: fn.status === "cancelled",
      }];
    })),
    travelLegs: Object.fromEntries(legs.docs.map((doc) => {
      const leg = doc.data() as Record<string, unknown>;
      // The moment anchor follows the leg's effective departure time:
      // an operator-supplied curb time wins over the scheduled arrival.
      return [doc.id, {
        atMillis: readTimestamp(leg.manualCurbAt) ??
          readTimestamp(leg.scheduledArrivalAt) ?? 0,
        revision: readInt(leg.revision, 0),
      }];
    })),
  };
}

// --- Recipients --------------------------------------------------------------

export interface ResolvedRecipient {
  /** Stable idempotency key (household:, guest:, uid:, contact: prefixed). */
  recipientKey: string;
  endpoint: RecipientEndpoint;
  householdId: string | null;
}

export interface RecipientResolution {
  recipients: ResolvedRecipient[];
  suppressedNoEndpoint: number;
}

/**
 * Resolves a moment audience against live documents at fire time. Consent
 * and endpoint facts are attached later by the policy pass — this is the
 * set-of-recipients step only.
 */
export async function resolveMomentRecipients(
  db: Firestore,
  moment: MomentDefinition,
  run: RunRecord,
): Promise<RecipientResolution> {
  const {audience, scope} = moment;
  switch (audience.kind) {
  case "subject": {
    // The triggering fact names the subject (e.g. a travel leg). Resolve to
    // that record's endpoint; the caller maps leg -> guest -> phone.
    const subject = run.subjectId;
    if (!subject || scope.kind !== "program") {
      return {recipients: [], suppressedNoEndpoint: 0};
    }
    const leg = await db.collection("programTravelLegs").doc(subject).get();
    if (!leg.exists) return {recipients: [], suppressedNoEndpoint: 0};
    const legData = leg.data() as Record<string, unknown>;
    const guestId = typeof legData.guestId === "string" ?
      legData.guestId : null;
    if (!guestId) return {recipients: [], suppressedNoEndpoint: 1};
    return guestsToRecipients(
      await guestsByIds(db, scope.programId, [guestId]));
  }
  case "functionGuests": {
    if (scope.kind !== "program") {
      return {recipients: [], suppressedNoEndpoint: 0};
    }
    const joinRows = await db.collection("programFunctionGuests")
      .where("programId", "==", scope.programId)
      .where("functionId", "==", audience.functionId).get();
    const invited = new Map<string, string>();
    for (const row of joinRows.docs) {
      const data = row.data() as Record<string, unknown>;
      if (data.invited !== true) continue;
      if (typeof data.guestId === "string") {
        invited.set(data.guestId,
          typeof data.rsvpStatus === "string" ? data.rsvpStatus : "pending");
      }
    }
    const guests = await guestsByIds(db, scope.programId, [...invited.keys()]);
    const eligible = guests.filter((guest) =>
      (audience.rsvp as ReadonlyArray<string>).includes(
        invited.get(guest.guestId) ?? "pending"));
    return dedupeGuests(eligible, audience.householdDedupe);
  }
  case "households": {
    if (scope.kind !== "program") {
      return {recipients: [], suppressedNoEndpoint: 0};
    }
    const households = await db.collection("programHouseholds")
      .where("programId", "==", scope.programId).get();
    const recipients: ResolvedRecipient[] = [];
    let suppressedNoEndpoint = 0;
    for (const doc of households.docs) {
      const data = doc.data() as Record<string, unknown>;
      if (audience.rsvpPendingOnly &&
          !await householdHasPendingMember(db, scope.programId, doc.id)) {
        continue;
      }
      const phone = typeof data.primaryPhoneE164 === "string" ?
        data.primaryPhoneE164 : null;
      if (!phone) {
        suppressedNoEndpoint += 1;
        continue;
      }
      recipients.push({
        recipientKey: `household:${doc.id}`,
        endpoint: {kind: "phone", e164: phone},
        householdId: doc.id,
      });
    }
    return {recipients, suppressedNoEndpoint};
  }
  case "staffDuty": {
    const grants = await staffGrantsFor(db, scope);
    const recipients: ResolvedRecipient[] = [];
    for (const doc of grants.docs) {
      const data = doc.data() as Record<string, unknown>;
      if (data.status !== "active" && data.revokedAt != null) continue;
      const duties = Array.isArray(data.duties) ? data.duties : [];
      const match = duties.some((duty: unknown) => {
        if (typeof duty !== "object" || duty === null) return false;
        const row = duty as Record<string, unknown>;
        if (row.duty !== audience.duty) return false;
        if (audience.scopeIds === null) return true;
        const scoped = [
          ...(Array.isArray(row.functionIds) ?
            row.functionIds as string[] : []),
          ...(Array.isArray(row.pickupPointIds) ?
            row.pickupPointIds as string[] : []),
          ...(Array.isArray(row.hotelIds) ? row.hotelIds as string[] : []),
        ];
        return audience.scopeIds!.some((id) => scoped.includes(id));
      });
      if (!match) continue;
      const uid = typeof data.uid === "string" ? data.uid : null;
      if (!uid) continue;
      recipients.push({
        recipientKey: `uid:${uid}`,
        endpoint: {kind: "uid", uid, fcmToken: null},
        householdId: null,
      });
    }
    return hydrateFcmTokens(db, {recipients, suppressedNoEndpoint: 0});
  }
  case "eventParticipants": {
    if (scope.kind !== "event") {
      return {recipients: [], suppressedNoEndpoint: 0};
    }
    const participations = await db.collection("eventParticipations")
      .where("eventId", "==", scope.eventId).get();
    const recipients: ResolvedRecipient[] = [];
    for (const doc of participations.docs) {
      const data = doc.data() as Record<string, unknown>;
      if (data.deletedAt != null || data.cancelledAt != null) continue;
      if (!(audience.statuses as ReadonlyArray<string>).includes(
        String(data.status))) continue;
      const uid = typeof data.uid === "string" ? data.uid : null;
      if (!uid) continue;
      recipients.push({
        recipientKey: `uid:${uid}`,
        endpoint: {kind: "uid", uid, fcmToken: null},
        householdId: null,
      });
    }
    return hydrateFcmTokens(db, {recipients, suppressedNoEndpoint: 0});
  }
  }
}

/** Reads users/{uid}.fcmToken so the policy layer can suppress recipients
 *  with no push endpoint and the sender does not re-read the user doc. */
async function hydrateFcmTokens(
  db: Firestore,
  resolution: RecipientResolution,
): Promise<RecipientResolution> {
  const uidEndpoints = resolution.recipients
    .filter((r) => r.endpoint.kind === "uid");
  if (uidEndpoints.length === 0) return resolution;
  const snaps = await Promise.all(uidEndpoints.map((r) =>
    db.collection("users")
      .doc((r.endpoint as {uid: string}).uid).get()));
  snaps.forEach((snap, index) => {
    const data = snap.data() as Record<string, unknown> | undefined;
    const token = typeof data?.fcmToken === "string" &&
      data.fcmToken.length > 0 ? data.fcmToken : null;
    (uidEndpoints[index].endpoint as {fcmToken: string | null})
      .fcmToken = token;
  });
  return resolution;
}

interface GuestRow {
  guestId: string;
  householdId: string | null;
  phoneE164: string | null;
}

async function guestsByIds(
  db: Firestore,
  programId: string,
  guestIds: ReadonlyArray<string>,
): Promise<GuestRow[]> {
  if (guestIds.length === 0) return [];
  const snap = await db.collection("programGuests")
    .where("programId", "==", programId).get();
  const wanted = new Set(guestIds);
  return snap.docs
    .filter((doc) => wanted.has(doc.id))
    .map((doc) => {
      const data = doc.data() as Record<string, unknown>;
      return {
        guestId: doc.id,
        householdId: typeof data.householdId === "string" ?
          data.householdId : null,
        phoneE164: typeof data.phoneE164 === "string" ?
          data.phoneE164 : null,
      };
    });
}

function guestsToRecipients(guests: GuestRow[]): RecipientResolution {
  const recipients: ResolvedRecipient[] = [];
  let suppressedNoEndpoint = 0;
  for (const guest of guests) {
    if (!guest.phoneE164) {
      suppressedNoEndpoint += 1;
      continue;
    }
    recipients.push({
      recipientKey: `guest:${guest.guestId}`,
      endpoint: {kind: "phone", e164: guest.phoneE164},
      householdId: guest.householdId,
    });
  }
  return {recipients, suppressedNoEndpoint};
}

function dedupeGuests(
  guests: GuestRow[],
  householdDedupe: boolean,
): RecipientResolution {
  if (!householdDedupe) return guestsToRecipients(guests);
  const byKey = new Map<string, GuestRow>();
  let suppressedNoEndpoint = 0;
  for (const guest of guests) {
    const key = guest.householdId === null ?
      `guest:${guest.guestId}` : `household:${guest.householdId}`;
    const existing = byKey.get(key);
    if (existing === undefined ||
        (existing.phoneE164 === null && guest.phoneE164 !== null)) {
      byKey.set(key, guest);
    }
  }
  const recipients: ResolvedRecipient[] = [];
  for (const [key, guest] of byKey) {
    if (!guest.phoneE164) {
      suppressedNoEndpoint += 1;
      continue;
    }
    recipients.push({
      recipientKey: key,
      endpoint: {kind: "phone", e164: guest.phoneE164},
      householdId: guest.householdId,
    });
  }
  recipients.sort((a, b) => a.recipientKey.localeCompare(b.recipientKey));
  return {recipients, suppressedNoEndpoint};
}

async function householdHasPendingMember(
  db: Firestore,
  programId: string,
  householdId: string,
): Promise<boolean> {
  const guests = await db.collection("programGuests")
    .where("programId", "==", programId)
    .where("householdId", "==", householdId).get();
  return guests.docs.some((doc) =>
    (doc.data() as Record<string, unknown>).rsvpStatus === "pending");
}

async function staffGrantsFor(
  db: Firestore,
  scope: MomentScope,
): Promise<FirebaseFirestore.QuerySnapshot> {
  const collection = scope.kind === "program" ?
    "programStaffGrants" : "eventStaffGrants";
  let query: Query = db.collection(collection);
  if (scope.kind === "program") {
    query = query.where("programId", "==", scope.programId);
  } else {
    query = query.where("eventId", "==", scope.eventId);
  }
  return query.get();
}

// --- Readers -----------------------------------------------------------------
// Exported so callable handlers parse payloads through the same lenient
// readers as stored documents — one shape, one grammar.

export function readScope(raw: unknown): MomentScope | null {
  if (typeof raw !== "object" || raw === null) return null;
  const data = raw as Record<string, unknown>;
  if (data.kind === "event" && typeof data.eventId === "string") {
    return {kind: "event", eventId: data.eventId};
  }
  if (data.kind === "program" && typeof data.programId === "string") {
    return {kind: "program", programId: data.programId};
  }
  return null;
}

export function readInitiation(
  raw: unknown,
): MomentDefinition["initiation"] | null {
  if (typeof raw !== "object" || raw === null) return null;
  const data = raw as Record<string, unknown>;
  switch (data.kind) {
  case "manual":
    return {kind: "manual"};
  case "scheduled":
    return {kind: "scheduled", atMillis: readInt(data.atMillis, 0)};
  case "anchored":
    return {
      kind: "anchored",
      anchorKind: data.anchorKind as never,
      anchorId: typeof data.anchorId === "string" ? data.anchorId : null,
      offsetMinutes: readInt(data.offsetMinutes, 0),
    };
  case "triggered":
    return {
      kind: "triggered",
      triggerKind: data.triggerKind as never,
      functionId: typeof data.functionId === "string" ?
        data.functionId : null,
    };
  default:
    return null;
  }
}

export function readAudience(
  raw: unknown,
): MomentDefinition["audience"] | null {
  if (typeof raw !== "object" || raw === null) return null;
  const data = raw as Record<string, unknown>;
  switch (data.kind) {
  case "subject":
    return {kind: "subject"};
  case "eventParticipants":
    return {
      kind: "eventParticipants",
      statuses: Array.isArray(data.statuses) ?
        data.statuses as never : ["signedUp"],
    };
  case "functionGuests":
    return {
      kind: "functionGuests",
      functionId: String(data.functionId ?? ""),
      rsvp: Array.isArray(data.rsvp) ? data.rsvp as never : ["attending"],
      householdDedupe: data.householdDedupe !== false,
    };
  case "households":
    return {kind: "households", rsvpPendingOnly: data.rsvpPendingOnly === true};
  case "staffDuty":
    return {
      kind: "staffDuty",
      duty: String(data.duty ?? ""),
      scopeIds: Array.isArray(data.scopeIds) ?
        data.scopeIds as string[] : null,
    };
  default:
    return null;
  }
}

export function readAction(
  raw: unknown,
): MomentDefinition["action"] | null {
  if (typeof raw !== "object" || raw === null) return null;
  const data = raw as Record<string, unknown>;
  switch (data.kind) {
  case "sendTemplate":
    return {
      kind: "sendTemplate",
      connectionId: String(data.connectionId ?? ""),
      templateId: String(data.templateId ?? ""),
      variables: typeof data.variables === "object" &&
        data.variables !== null ?
        data.variables as Readonly<Record<string, string>> : {},
    };
  case "push":
    return {
      kind: "push",
      notificationType: String(data.notificationType ?? ""),
      preferenceKey: String(data.preferenceKey ?? ""),
    };
  case "staffAttention":
    return {
      kind: "staffAttention",
      duty: String(data.duty ?? ""),
      severity: data.severity === "urgent" || data.severity === "warning" ?
        data.severity : "info",
      titleTemplate: String(data.titleTemplate ?? ""),
    };
  default:
    return null;
  }
}

function readApproval(
  raw: unknown,
): MomentDefinition["approval"] {
  if (typeof raw !== "object" || raw === null) return null;
  const data = raw as Record<string, unknown>;
  if (typeof data.approvedByUid !== "string") return null;
  return {
    approvedByUid: data.approvedByUid,
    approvedAtMillis: readInt(data.approvedAtMillis, 0),
  };
}

function readString(value: unknown): string | null {
  return typeof value === "string" && value.trim().length > 0 ?
    value : null;
}

function requireString(value: unknown, field: string): string {
  const text = readString(value);
  if (text === null) {
    throw new RangeError(`Moment document ${field} must be non-empty.`);
  }
  return text;
}

function readInt(value: unknown, fallback: number): number {
  return typeof value === "number" && Number.isSafeInteger(value) ?
    value : fallback;
}

function readTimestamp(value: unknown): number | null {
  if (typeof value === "number") return value;
  if (typeof value === "object" && value !== null &&
      "toMillis" in value) {
    return (value as {toMillis: () => number}).toMillis();
  }
  return null;
}

export {sameScope, scopeId, requireMillis};
