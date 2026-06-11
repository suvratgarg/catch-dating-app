import * as crypto from "crypto";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  CallableRequest,
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";
import {
  EventDocument,
  EventInviteLinkDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  CreateEventInviteLinkCallablePayload,
} from "../shared/generated/createEventInviteLinkCallablePayload";
import {
  DisableEventInviteLinkCallablePayload,
} from "../shared/generated/disableEventInviteLinkCallablePayload";
import {
  RecordEventInviteLinkOpenCallablePayload,
} from "../shared/generated/recordEventInviteLinkOpenCallablePayload";
import {
  validateCreateEventInviteLinkCallablePayload,
  validateDisableEventInviteLinkCallablePayload,
  validateRecordEventInviteLinkOpenCallablePayload,
} from "../shared/generated/schemaValidators";
import {requireAuth} from "../shared/auth";
import {isClubHost} from "../shared/clubHosts";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";

export type InviteLinkCounterField =
  | "openCount"
  | "requestCount"
  | "confirmedCount"
  | "paidCount"
  | "checkedInCount";

export interface InviteAttribution {
  inviteLinkId: string;
  inviteSource: string | null;
}

interface EventInviteLinkDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  increment: (value: number) => FirebaseFirestore.FieldValue;
}

const defaultDeps: EventInviteLinkDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  increment: (value) => admin.firestore.FieldValue.increment(value),
};

export async function createEventInviteLinkHandler(
  request: CallableRequest<unknown>,
  deps: EventInviteLinkDeps = defaultDeps
): Promise<{
  inviteLinkId: string;
  eventId: string;
  label: string;
  source: string | null;
}> {
  const hostUid = requireAuth(request);
  const payload = validateCallableWithAjv<
    CreateEventInviteLinkCallablePayload
  >(
    request,
    validateCreateEventInviteLinkCallablePayload,
    normalizeInviteLinkPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, hostUid, "createEventInviteLink");

  const inviteRef = db.collection("eventInviteLinks").doc();
  const eventRef = db.collection("events").doc(payload.eventId);
  const label = payload.label.trim();
  const source = stringOrNull(payload.source);

  await db.runTransaction(async (tx) => {
    const eventSnap = await tx.get(eventRef);
    if (!eventSnap.exists) {
      throw new HttpsError("not-found", "Event not found.");
    }
    const event = requireDoc<EventDocument>(eventSnap, "EventDocument");
    const clubSnap = await tx.get(db.collection("clubs").doc(event.clubId));
    if (!clubSnap.exists) {
      throw new HttpsError("not-found", "Club not found.");
    }
    if (!isClubHost(clubSnap.data() as Parameters<typeof isClubHost>[0],
      hostUid)) {
      throw new HttpsError(
        "permission-denied",
        "Only a club host can create invite links."
      );
    }

    const now = deps.serverTimestamp();
    tx.create(inviteRef, {
      eventId: payload.eventId,
      clubId: event.clubId,
      hostUid,
      label,
      source,
      tokenHash: inviteLinkTokenHash(inviteRef.id),
      openCount: 0,
      requestCount: 0,
      confirmedCount: 0,
      paidCount: 0,
      checkedInCount: 0,
      catcherCount: 0,
      matchCount: 0,
      chatStartedCount: 0,
      disabledAt: null,
      createdAt: now,
      updatedAt: now,
    });
  });

  return {
    inviteLinkId: inviteRef.id,
    eventId: payload.eventId,
    label,
    source,
  };
}

export async function disableEventInviteLinkHandler(
  request: CallableRequest<unknown>,
  deps: EventInviteLinkDeps = defaultDeps
): Promise<{disabled: boolean}> {
  const hostUid = requireAuth(request);
  const payload = validateCallableWithAjv<
    DisableEventInviteLinkCallablePayload
  >(
    request,
    validateDisableEventInviteLinkCallablePayload,
    normalizeInviteLinkPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, hostUid, "disableEventInviteLink");

  await db.runTransaction(async (tx) => {
    const linkRef = db.collection("eventInviteLinks")
      .doc(payload.inviteLinkId);
    const linkSnap = await tx.get(linkRef);
    if (!linkSnap.exists) {
      throw new HttpsError("not-found", "Invite link not found.");
    }
    const link = linkSnap.data() as Partial<EventInviteLinkDocument>;
    if (link.eventId !== payload.eventId) {
      throw new HttpsError(
        "failed-precondition",
        "Invite link does not belong to this event."
      );
    }
    const eventSnap = await tx.get(db.collection("events").doc(
      payload.eventId
    ));
    if (!eventSnap.exists) {
      throw new HttpsError("not-found", "Event not found.");
    }
    const event = requireDoc<EventDocument>(eventSnap, "EventDocument");
    const clubSnap = await tx.get(db.collection("clubs").doc(event.clubId));
    if (!clubSnap.exists) {
      throw new HttpsError("not-found", "Club not found.");
    }
    if (!isClubHost(clubSnap.data() as Parameters<typeof isClubHost>[0],
      hostUid)) {
      throw new HttpsError(
        "permission-denied",
        "Only a club host can disable invite links."
      );
    }
    if (link.disabledAt != null) return;
    tx.set(linkRef, {
      disabledAt: deps.serverTimestamp(),
      updatedAt: deps.serverTimestamp(),
    }, {merge: true});
  });

  return {disabled: true};
}

export async function recordEventInviteLinkOpenHandler(
  request: CallableRequest<unknown>,
  deps: EventInviteLinkDeps = defaultDeps
): Promise<{
  accepted: boolean;
  disabled: boolean;
  eventId: string;
  inviteLinkId: string;
  label: string | null;
  source: string | null;
}> {
  const payload = validateCallableWithAjv<
    RecordEventInviteLinkOpenCallablePayload
  >(
    request,
    validateRecordEventInviteLinkOpenCallablePayload,
    normalizeInviteLinkPayload
  );
  const db = deps.firestore();
  const linkRef = db.collection("eventInviteLinks")
    .doc(payload.inviteLinkId);
  let result = {
    accepted: false,
    disabled: false,
    eventId: payload.eventId,
    inviteLinkId: payload.inviteLinkId,
    label: null as string | null,
    source: null as string | null,
  };

  await db.runTransaction(async (tx) => {
    const linkSnap = await tx.get(linkRef);
    if (!linkSnap.exists) return;
    const link = linkSnap.data() as Partial<EventInviteLinkDocument>;
    if (
      link.eventId !== payload.eventId ||
      link.tokenHash !== inviteLinkTokenHash(payload.inviteLinkId)
    ) {
      return;
    }
    result = {
      accepted: link.disabledAt == null,
      disabled: link.disabledAt != null,
      eventId: payload.eventId,
      inviteLinkId: payload.inviteLinkId,
      label: typeof link.label === "string" ? link.label : null,
      source: stringOrNull(link.source),
    };
    if (!result.accepted) return;
    tx.set(linkRef, {
      openCount: deps.increment(1),
      updatedAt: deps.serverTimestamp(),
    }, {merge: true});
  });

  return result;
}

export async function resolveInviteAttribution(params: {
  db: FirebaseFirestore.Firestore;
  eventId: string;
  inviteLinkId?: string | null;
}): Promise<InviteAttribution | null> {
  const inviteLinkId = stringOrNull(params.inviteLinkId);
  if (!inviteLinkId) return null;
  const snap = await params.db.collection("eventInviteLinks")
    .doc(inviteLinkId)
    .get();
  return inviteAttributionFromSnapshot({
    eventId: params.eventId,
    inviteLinkId,
    data: snap.data(),
  });
}

export async function resolveInviteAttributionInTransaction(params: {
  tx: FirebaseFirestore.Transaction;
  db: FirebaseFirestore.Firestore;
  eventId: string;
  inviteLinkId?: string | null;
}): Promise<InviteAttribution | null> {
  const inviteLinkId = stringOrNull(params.inviteLinkId);
  if (!inviteLinkId) return null;
  const snap = await params.tx.get(params.db.collection("eventInviteLinks")
    .doc(inviteLinkId));
  return inviteAttributionFromSnapshot({
    eventId: params.eventId,
    inviteLinkId,
    data: snap.data(),
  });
}

export function inviteAttributionWriteFields(
  attribution: InviteAttribution | null | undefined
): Record<string, unknown> {
  if (!attribution) return {};
  return {
    inviteLinkId: attribution.inviteLinkId,
    inviteSource: attribution.inviteSource,
    inviteCapturedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

export function incrementInviteLinkCounterInTransaction(params: {
  tx: FirebaseFirestore.Transaction;
  db: FirebaseFirestore.Firestore;
  attribution: InviteAttribution | null | undefined;
  field: InviteLinkCounterField;
  delta?: number;
}) {
  if (!params.attribution) return;
  params.tx.set(params.db.collection("eventInviteLinks")
    .doc(params.attribution.inviteLinkId), {
    [params.field]: admin.firestore.FieldValue.increment(params.delta ?? 1),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, {merge: true});
}

export async function incrementInviteLinkCounterBestEffort(params: {
  db: FirebaseFirestore.Firestore;
  inviteLinkId?: string | null;
  field: InviteLinkCounterField;
  delta?: number;
}): Promise<void> {
  const inviteLinkId = stringOrNull(params.inviteLinkId);
  if (!inviteLinkId) return;
  try {
    await params.db.collection("eventInviteLinks").doc(inviteLinkId).set({
      [params.field]: admin.firestore.FieldValue.increment(params.delta ?? 1),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, {merge: true});
  } catch (error) {
    logger.error("Failed to update invite link counter", {
      inviteLinkId,
      field: params.field,
      error,
      reasonMessage: error instanceof Error ? error.message : String(error),
    });
  }
}

export function inviteLinkTokenHash(inviteLinkId: string): string {
  return crypto.createHash("sha256").update(inviteLinkId).digest("hex");
}

function inviteAttributionFromSnapshot(params: {
  eventId: string;
  inviteLinkId: string;
  data: FirebaseFirestore.DocumentData | undefined;
}): InviteAttribution | null {
  const link = params.data as Partial<EventInviteLinkDocument> | undefined;
  if (!link) return null;
  if (link.eventId !== params.eventId) return null;
  if (link.disabledAt != null) return null;
  if (link.tokenHash !== inviteLinkTokenHash(params.inviteLinkId)) {
    return null;
  }
  const source = stringOrNull(link.source) ?? stringOrNull(link.label);
  return {
    inviteLinkId: params.inviteLinkId,
    inviteSource: source,
  };
}

function normalizeInviteLinkPayload(data: unknown): unknown {
  if (typeof data !== "object" || data === null || Array.isArray(data)) {
    return data;
  }
  const payload = {...data as Record<string, unknown>};
  for (const key of ["eventId", "inviteLinkId", "label", "source"]) {
    if (typeof payload[key] === "string") {
      payload[key] = payload[key].trim();
    }
  }
  return payload;
}

function stringOrNull(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

export const createEventInviteLink = onCall(appCheckCallableOptions, (
  request
) => createEventInviteLinkHandler(request));

export const disableEventInviteLink = onCall(appCheckCallableOptions, (
  request
) => disableEventInviteLinkHandler(request));

export const recordEventInviteLinkOpen = onCall(appCheckCallableOptions, (
  request
) => recordEventInviteLinkOpenHandler(request));
