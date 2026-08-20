import {createHash} from "crypto";
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {
  EventAttendeeDocument,
  EventAttendeeImportDocument,
  EventDocument,
  OnboardingDraftDocument,
  OrganizerCommunicationPreferenceDocument,
} from "../shared/generated/firestoreAdminTypes";
import {ImportEventAttendeesCallablePayload} from
  "../shared/generated/importEventAttendeesCallablePayload";
import {MarkEventAttendeeAttendanceCallablePayload} from
  "../shared/generated/markEventAttendeeAttendanceCallablePayload";
import {SetEventAttendeeAttendanceCallablePayload} from
  "../shared/generated/setEventAttendeeAttendanceCallablePayload";
import {SetEventAttendeeAttendanceCallableResponse} from
  "../shared/generated/setEventAttendeeAttendanceCallableResponse";
import {RegisterPublicEventCallablePayload} from
  "../shared/generated/registerPublicEventCallablePayload";
import {RegisterPublicEventCallableResponse} from
  "../shared/generated/registerPublicEventCallableResponse";
import {
  validateImportEventAttendeesCallablePayload,
  validateMarkEventAttendeeAttendanceCallablePayload,
  validateRegisterPublicEventCallablePayload,
  validateSetEventAttendeeAttendanceCallablePayload,
} from "../shared/generated/schemaValidators";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {
  eventOrganizerRef,
  isEventOrganizerManager,
  requireEventOrganizer,
} from "../shared/eventOrganizers";
import {requireEventOperatorPermission} from
  "../shared/eventOperatorAuthority";
import {checkRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {organizerCommunicationPreferenceId} from
  "../shared/organizerCommunicationPreferences";
import {eventPolicyFromEvent} from "./eventPolicy";
import {resolveInviteAttributionToken} from "./inviteLinks";

type ImportRow = ImportEventAttendeesCallablePayload["rows"][number];
type ImportError = EventAttendeeImportDocument["errors"][number];

interface EventAttendeeDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  timestamp: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: EventAttendeeDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  timestamp: () => admin.firestore.Timestamp.now(),
};

const attendanceReceiptRetentionMillis = 30 * 24 * 60 * 60 * 1000;

export interface EventAttendeeImportResult {
  importId: string;
  status: "completed" | "partial" | "failed";
  rowCount: number;
  createdCount: number;
  updatedCount: number;
  skippedCount: number;
  errors: ImportError[];
  replayed: boolean;
}

interface PreparedRow {
  attendeeId: string;
  rowId: string;
  displayName: string;
  searchName: string;
  phoneE164: string | null;
  email: string | null;
  externalReference: string | null;
  arrivalGroup: string | null;
  ticketType: string | null;
  revenueAmountMinor: number | null;
  revenueCurrency: string | null;
  revenueSource: "hostImport" | "hostEstimate" | null;
  revenueAllocation: "perAttendee" | "sharedOrder" | null;
  revenueOrderReference: string | null;
  revenueOrderAmountMinor: number | null;
  status: "invited" | "registered" | "waitlisted";
}

/**
 * Imports a bounded roster into the server-owned operational attendee layer.
 */
export async function importEventAttendeesHandler(
  request: CallableRequest<unknown>,
  deps: EventAttendeeDeps = defaultDeps
): Promise<EventAttendeeImportResult> {
  const hostUid = requireAuth(request);
  const payload = validateCallableWithAjv<
    ImportEventAttendeesCallablePayload
  >(
    request,
    validateImportEventAttendeesCallablePayload,
    normalizeImportPayload
  );
  return importEventAttendeesForHost({hostUid, payload}, deps);
}

/** Shared importer for authenticated callable and signed inbound transports. */
export async function importEventAttendeesForHost(
  params: {
    hostUid: string;
    payload: ImportEventAttendeesCallablePayload;
  },
  deps: EventAttendeeDeps = defaultDeps
): Promise<EventAttendeeImportResult> {
  const {hostUid, payload} = params;
  const db = deps.firestore();
  await deps.checkRateLimit(db, hostUid, "importEventAttendees");

  const eventRef = db.collection("events").doc(payload.eventId);
  const eventSnap = await eventRef.get();
  if (!eventSnap.exists) {
    throw new HttpsError("not-found", "Event not found.");
  }
  const event = requireDoc<EventDocument>(eventSnap, "EventDocument");
  if (event.status === "cancelled") {
    throw new HttpsError("failed-precondition", "This event is cancelled.");
  }
  const organizerSnap = await eventOrganizerRef(db, event).get();
  const organizer = requireEventOrganizer(organizerSnap, event);
  if (!isEventOrganizerManager(organizer, event, hostUid)) {
    throw new HttpsError(
      "permission-denied",
      "Only an organizer manager can import attendees."
    );
  }

  const canonicalPayload = canonicalImportPayload(payload);
  const payloadHash = sha256(JSON.stringify(canonicalPayload));
  const importId = eventAttendeeImportId({
    eventId: payload.eventId,
    hostUid,
    importKey: payload.importKey,
  });
  const importRef = db.collection("eventAttendeeImports").doc(importId);
  const existingImportSnap = await importRef.get();
  if (existingImportSnap.exists) {
    const existing = requireDoc<EventAttendeeImportDocument>(
      existingImportSnap,
      "EventAttendeeImportDocument"
    );
    if (existing.payloadHash !== payloadHash) {
      throw new HttpsError(
        "failed-precondition",
        "This import key was already used for different roster data."
      );
    }
    return importResult(importId, existing, true);
  }

  const {prepared, errors} = prepareImportRows({
    eventId: payload.eventId,
    importKey: payload.importKey,
    format: payload.format,
    rows: payload.rows,
  });
  const attendeeRefs = prepared.map((row) =>
    db.collection("eventAttendees").doc(row.attendeeId)
  );
  const existingAttendeeSnaps = attendeeRefs.length === 0 ? [] :
    await db.getAll(...attendeeRefs);
  const existingById = new Map(
    existingAttendeeSnaps
      .filter((snap) => snap.exists)
      .map((snap) => [snap.id, snap.data() as EventAttendeeDocument])
  );

  const now = deps.timestamp();
  const source = payload.format === "manual" ? "hostManual" : "hostImport";
  const batch = db.batch();
  for (let index = 0; index < prepared.length; index += 1) {
    const row = prepared[index];
    const attendeeRef = attendeeRefs[index];
    const existing = existingById.get(row.attendeeId);
    const status = existing?.status === "checkedIn" ? "checkedIn" : row.status;
    const document: EventAttendeeDocument = {
      eventId: payload.eventId,
      clubId: event.clubId,
      organizerId: event.organizerId ?? event.clubId,
      displayName: row.displayName,
      searchName: row.searchName,
      source: existing?.source === "catchBooking" ? "catchBooking" : source,
      status,
      linkedUid: existing?.linkedUid ?? null,
      phoneE164: row.phoneE164 ?? existing?.phoneE164 ?? null,
      email: row.email ?? existing?.email ?? null,
      externalReference:
        row.externalReference ?? existing?.externalReference ?? null,
      arrivalGroup: row.arrivalGroup ?? existing?.arrivalGroup ?? null,
      ticketType: row.ticketType ?? existing?.ticketType ?? null,
      revenueAmountMinor:
        row.revenueAmountMinor ?? existing?.revenueAmountMinor ?? null,
      revenueCurrency:
        row.revenueCurrency ?? existing?.revenueCurrency ?? null,
      revenueSource: row.revenueSource ?? existing?.revenueSource ?? null,
      revenueAllocation:
        row.revenueAllocation ?? existing?.revenueAllocation ?? null,
      revenueOrderReference:
        row.revenueOrderReference ?? existing?.revenueOrderReference ?? null,
      revenueOrderAmountMinor:
        row.revenueOrderAmountMinor ??
        existing?.revenueOrderAmountMinor ?? null,
      importId,
      sourceRowId: row.rowId,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      registeredAt: status === "registered" ?
        existing?.registeredAt ?? now : existing?.registeredAt ?? null,
      waitlistedAt: status === "waitlisted" ?
        existing?.waitlistedAt ?? now : existing?.waitlistedAt ?? null,
      checkedInAt: existing?.checkedInAt ?? null,
      cancelledAt: existing?.cancelledAt ?? null,
      checkedInBy: existing?.checkedInBy ?? null,
      linkedAt: existing?.linkedAt ?? null,
      inviteLinkId: existing?.inviteLinkId ?? null,
      inviteCapturedAt: existing?.inviteCapturedAt ?? null,
      attendanceRevision: existing?.attendanceRevision ?? 0,
      preCheckInStatus: existing?.preCheckInStatus ?? null,
    };
    batch.set(attendeeRef, document);
  }

  const createdCount = prepared.filter(
    (row) => !existingById.has(row.attendeeId)
  ).length;
  const updatedCount = prepared.length - createdCount;
  const skippedCount = payload.rows.length - prepared.length;
  const status = prepared.length === 0 ? "failed" :
    errors.length > 0 ? "partial" : "completed";
  const receipt: EventAttendeeImportDocument = {
    eventId: payload.eventId,
    clubId: event.clubId,
    organizerId: event.organizerId ?? event.clubId,
    uploadedBy: hostUid,
    importKey: payload.importKey,
    fileName: payload.fileName,
    format: payload.format,
    payloadHash,
    status,
    rowCount: payload.rows.length,
    createdCount,
    updatedCount,
    skippedCount,
    errors: errors.slice(0, 100),
    createdAt: now,
    updatedAt: now,
    completedAt: now,
  };
  batch.create(importRef, receipt);
  await batch.commit();
  return importResult(importId, receipt, false);
}

/** Toggles Host-managed check-in for an operational attendee. */
export async function markEventAttendeeAttendanceHandler(
  request: CallableRequest<unknown>,
  deps: EventAttendeeDeps = defaultDeps
): Promise<{attendeeId: string; attended: boolean}> {
  const hostUid = requireAuth(request);
  const payload = validateCallableWithAjv<
    MarkEventAttendeeAttendanceCallablePayload
  >(
    request,
    validateMarkEventAttendeeAttendanceCallablePayload,
    normalizeAttendancePayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, hostUid, "markEventAttendeeAttendance");

  const eventRef = db.collection("events").doc(payload.eventId);
  const attendeeRef = db.collection("eventAttendees").doc(payload.attendeeId);
  return db.runTransaction(async (tx) => {
    const eventSnap = await tx.get(eventRef);
    if (!eventSnap.exists) {
      throw new HttpsError("not-found", "Event not found.");
    }
    const event = requireDoc<EventDocument>(eventSnap, "EventDocument");
    if (event.status === "cancelled") {
      throw new HttpsError("failed-precondition", "This event is cancelled.");
    }
    const organizerSnap = await tx.get(eventOrganizerRef(db, event));
    const organizer = requireEventOrganizer(organizerSnap, event);
    await requireEventOperatorPermission({
      db,
      organizer,
      event,
      eventId: payload.eventId,
      actorUid: hostUid,
      permission: "setAttendance",
      now: deps.timestamp(),
      transaction: tx,
    });
    const attendeeSnap = await tx.get(attendeeRef);
    if (!attendeeSnap.exists) {
      throw new HttpsError("not-found", "Attendee not found.");
    }
    const attendee = requireDoc<EventAttendeeDocument>(
      attendeeSnap,
      "EventAttendeeDocument"
    );
    if (attendee.eventId !== payload.eventId) {
      throw new HttpsError(
        "failed-precondition",
        "This attendee does not belong to the event."
      );
    }
    if (attendee.status === "cancelled") {
      throw new HttpsError(
        "failed-precondition",
        "A cancelled attendee cannot be checked in."
      );
    }
    const attended = attendee.status !== "checkedIn";
    const now = deps.timestamp();
    tx.update(attendeeRef, {
      status: attended ? "checkedIn" : "registered",
      checkedInAt: attended ? now : null,
      checkedInBy: attended ? hostUid : null,
      updatedAt: now,
    });
    return {attendeeId: payload.attendeeId, attended};
  });
}

/**
 * Sets one attendee's desired attendance state without replaying a toggle.
 * A client operation id is immutable, and stale revisions fail visibly.
 */
export async function setEventAttendeeAttendanceHandler(
  request: CallableRequest<unknown>,
  deps: EventAttendeeDeps = defaultDeps
): Promise<SetEventAttendeeAttendanceCallableResponse> {
  const hostUid = requireAuth(request);
  const payload = validateCallableWithAjv<
    SetEventAttendeeAttendanceCallablePayload
  >(
    request,
    validateSetEventAttendeeAttendanceCallablePayload,
    normalizeSetAttendancePayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, hostUid, "setEventAttendeeAttendance");
  const eventRef = db.collection("events").doc(payload.eventId);
  const attendeeRef = db.collection("eventAttendees")
    .doc(payload.attendeeId);
  const receiptId = attendanceReceiptId({
    eventId: payload.eventId,
    actorUid: hostUid,
    clientOperationId: payload.clientOperationId,
  });
  const receiptRef = db.collection("eventAttendeeAttendanceReceipts")
    .doc(receiptId);
  return db.runTransaction(async (tx) => {
    const [eventSnap, receiptSnap] = await Promise.all([
      tx.get(eventRef),
      tx.get(receiptRef),
    ]);
    if (!eventSnap.exists) {
      throw new HttpsError("not-found", "Event not found.");
    }
    const event = requireDoc<EventDocument>(eventSnap, "EventDocument");
    if (event.status === "cancelled") {
      throw new HttpsError("failed-precondition", "This event is cancelled.");
    }
    const organizerSnap = await tx.get(eventOrganizerRef(db, event));
    const organizer = requireEventOrganizer(organizerSnap, event);
    await requireEventOperatorPermission({
      db,
      organizer,
      event,
      eventId: payload.eventId,
      actorUid: hostUid,
      permission: "setAttendance",
      now: deps.timestamp(),
      transaction: tx,
    });
    if (receiptSnap.exists) {
      const receipt = receiptSnap.data() as {
        eventId?: string;
        attendeeId?: string;
        desiredCheckedIn?: boolean;
        acceptedRevision?: number;
        changed?: boolean;
      };
      if (receipt.eventId !== payload.eventId ||
          receipt.attendeeId !== payload.attendeeId ||
          receipt.desiredCheckedIn !== payload.desiredCheckedIn ||
          typeof receipt.acceptedRevision !== "number" ||
          typeof receipt.changed !== "boolean") {
        throw new HttpsError(
          "failed-precondition",
          "This attendance operation id was already used differently."
        );
      }
      return {
        attendeeId: payload.attendeeId,
        checkedIn: receipt.desiredCheckedIn,
        acceptedRevision: receipt.acceptedRevision,
        replayed: true,
        changed: receipt.changed,
      };
    }
    const attendeeSnap = await tx.get(attendeeRef);
    if (!attendeeSnap.exists) {
      throw new HttpsError("not-found", "Attendee not found.");
    }
    const attendee = requireDoc<EventAttendeeDocument>(
      attendeeSnap,
      "EventAttendeeDocument"
    );
    if (attendee.eventId !== payload.eventId) {
      throw new HttpsError(
        "failed-precondition",
        "This attendee does not belong to the event."
      );
    }
    if (attendee.status === "cancelled") {
      throw new HttpsError(
        "failed-precondition",
        "A cancelled attendee cannot be checked in."
      );
    }
    const priorRevision = attendee.attendanceRevision ?? 0;
    if (payload.expectedRevision !== priorRevision) {
      throw new HttpsError(
        "aborted",
        "Attendance changed on another device. Current revision: " +
          `${priorRevision}.`
      );
    }
    const alreadyCheckedIn = attendee.status === "checkedIn";
    const changed = alreadyCheckedIn !== payload.desiredCheckedIn;
    const acceptedRevision = changed ? priorRevision + 1 : priorRevision;
    const now = deps.timestamp();
    if (changed) {
      const restoredStatus = attendee.preCheckInStatus ?? "registered";
      tx.update(attendeeRef, {
        status: payload.desiredCheckedIn ? "checkedIn" : restoredStatus,
        checkedInAt: payload.desiredCheckedIn ? now : null,
        checkedInBy: payload.desiredCheckedIn ? hostUid : null,
        attendanceRevision: acceptedRevision,
        preCheckInStatus: payload.desiredCheckedIn ? attendee.status : null,
        updatedAt: now,
      });
      tx.update(eventRef, {
        checkedInCount: admin.firestore.FieldValue.increment(
          payload.desiredCheckedIn ? 1 : -1
        ),
        updatedAt: now,
      });
    }
    tx.create(receiptRef, {
      eventId: payload.eventId,
      organizerId: event.organizerId ?? event.clubId,
      attendeeId: payload.attendeeId,
      actorUid: hostUid,
      clientOperationId: payload.clientOperationId,
      desiredCheckedIn: payload.desiredCheckedIn,
      priorRevision,
      acceptedRevision,
      changed,
      createdAt: now,
      expiresAt: admin.firestore.Timestamp.fromMillis(
        now.toMillis() + attendanceReceiptRetentionMillis
      ),
    });
    return {
      attendeeId: payload.attendeeId,
      checkedIn: payload.desiredCheckedIn,
      acceptedRevision,
      replayed: false,
      changed,
    };
  });
}

/**
 * Registers a phone-authenticated website visitor without requiring the
 * Consumer onboarding/profile contract. A matching imported phone row is
 * linked in place, so the Host never sees duplicate operational identities.
 */
export async function registerPublicEventHandler(
  request: CallableRequest<unknown>,
  deps: EventAttendeeDeps = defaultDeps
): Promise<RegisterPublicEventCallableResponse> {
  const uid = requireAuth(request);
  const payload = validateCallableWithAjv<RegisterPublicEventCallablePayload>(
    request,
    validateRegisterPublicEventCallablePayload,
    normalizePublicRegistrationPayload
  );
  const rawPhone = request.auth?.token.phone_number;
  const phone = normalizeRosterPhone(
    typeof rawPhone === "string" ? rawPhone : null
  ).value;
  if (!phone) {
    throw new HttpsError(
      "failed-precondition",
      "Verify a phone number before registering for this event."
    );
  }

  const db = deps.firestore();
  await deps.checkRateLimit(db, uid, "registerPublicEvent");
  const inviteAttribution = await resolveInviteAttributionToken({
    db,
    eventId: payload.eventId,
    inviteToken: payload.inviteToken,
  });
  const eventRef = db.collection("events").doc(payload.eventId);
  const attendeeId = eventAttendeeId(payload.eventId, `phone:${phone}`);
  const attendeeRef = db.collection("eventAttendees").doc(attendeeId);
  const onboardingDraftRef = db.collection("onboarding_drafts").doc(uid);

  return db.runTransaction(async (tx) => {
    const eventSnap = await tx.get(eventRef);
    if (!eventSnap.exists) {
      throw new HttpsError("not-found", "Event not found.");
    }
    const event = requireDoc<EventDocument>(eventSnap, "EventDocument");
    const organizerId = event.organizerId ?? event.clubId;
    const communicationPreferenceRef = db
      .collection("organizerCommunicationPreferences")
      .doc(organizerCommunicationPreferenceId(organizerId, uid));
    const [
      organizerSnap,
      attendeeSnap,
      rosterSnap,
      onboardingDraftSnap,
      communicationPreferenceSnap,
    ] = await Promise.all([
      tx.get(eventOrganizerRef(db, event)),
      tx.get(attendeeRef),
      tx.get(db.collection("eventAttendees")
        .where("eventId", "==", payload.eventId)),
      tx.get(onboardingDraftRef),
      tx.get(communicationPreferenceRef),
    ]);
    const organizer = requireEventOrganizer(organizerSnap, event);
    const policy = eventPolicyFromEvent(event);
    const existing = attendeeSnap.exists ?
      requireDoc<EventAttendeeDocument>(attendeeSnap, "EventAttendeeDocument") :
      null;
    const alreadyRegistered = existing?.status === "registered" ||
      existing?.status === "checkedIn";
    const activeCount = rosterSnap.docs.reduce((count, document) => {
      const attendee = requireDoc<EventAttendeeDocument>(
        document,
        "EventAttendeeDocument"
      );
      return attendee.status === "registered" ||
        attendee.status === "checkedIn" ? count + 1 : count;
    }, 0);
    assertPublicRegistrationEligibility({
      organizerVisibility: organizer.appVisibility,
      organizerPublishStatus: organizer.publicPage?.publishStatus,
      eventStatus: event.status,
      eventEndTimeMs: event.endTime.toMillis(),
      publicRegistrationEnabled: event.publicRegistrationEnabled === true,
      admissionFormat: policy.admission.format,
      inviteRequired: policy.admission.inviteRequired === true,
      membershipRequired: policy.admission.membershipRequired === true,
      manualApprovalRequired:
        policy.admission.manualApprovalRequired === true,
      priceInPaise: policy.pricing.basePriceInPaise,
    });

    const now = deps.timestamp();
    const displayName = existing?.displayName ?? payload.displayName;
    const status = publicRegistrationStatus({
      activeCount,
      capacityLimit: policy.admission.capacityLimit,
      existingStatus: existing?.status,
    });
    const document: EventAttendeeDocument = {
      eventId: payload.eventId,
      clubId: event.clubId,
      organizerId,
      displayName,
      searchName: displayName.toLocaleLowerCase("en"),
      source: existing?.source ?? "webOtp",
      status,
      linkedUid: uid,
      phoneE164: phone,
      email: existing?.email ?? null,
      externalReference: existing?.externalReference ?? null,
      arrivalGroup: existing?.arrivalGroup ?? null,
      ticketType: existing?.ticketType ?? null,
      importId: existing?.importId ?? null,
      sourceRowId: existing?.sourceRowId ?? null,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      registeredAt: status === "registered" || status === "checkedIn" ?
        existing?.registeredAt ?? now : existing?.registeredAt ?? null,
      waitlistedAt: status === "waitlisted" ?
        existing?.waitlistedAt ?? now : existing?.waitlistedAt ?? null,
      checkedInAt: existing?.checkedInAt ?? null,
      cancelledAt: null,
      checkedInBy: existing?.checkedInBy ?? null,
      linkedAt: existing?.linkedAt ?? now,
      inviteLinkId: existing?.inviteLinkId ??
        inviteAttribution?.inviteLinkId ?? null,
      inviteCapturedAt: existing?.inviteCapturedAt ??
        (inviteAttribution ? now : null),
      attendanceRevision: existing?.attendanceRevision ?? 0,
      preCheckInStatus: existing?.preCheckInStatus ?? null,
    };
    tx.set(attendeeRef, document);
    if (!onboardingDraftSnap.exists) {
      tx.create(onboardingDraftRef, onboardingDraftSeed({
        displayName,
        phoneE164: phone,
      }));
    }
    const communicationPreference = mergeOrganizerCommunicationPreference({
      existing: communicationPreferenceSnap.exists ?
        communicationPreferenceSnap.data() as
          OrganizerCommunicationPreferenceDocument : undefined,
      organizerId,
      uid,
      eventId: payload.eventId,
      organizerUpdates: payload.organizerUpdates,
      now,
    });
    if (communicationPreference) {
      tx.set(communicationPreferenceRef, communicationPreference);
    }
    return {
      eventId: payload.eventId,
      attendeeId,
      status: alreadyRegistered ? "alreadyRegistered" :
        status === "waitlisted" ? "waitlisted" : "registered",
    };
  });
}

/** Builds the private Consumer onboarding seed for an OTP-only attendee. */
export function onboardingDraftSeed(params: {
  displayName: string;
  phoneE164: string;
}): OnboardingDraftDocument {
  const phone = splitSupportedPhone(params.phoneE164);
  return {
    step: 1,
    draftVersion: 2,
    firstName: params.displayName.trim().slice(0, 80),
    lastName: "",
    phoneNumber: phone.nationalNumber,
    countryCode: phone.countryCode,
  };
}

/**
 * Applies only explicit opt-ins from registration. An unchecked box never
 * revokes a prior grant; withdrawal belongs to the self-service/STOP path.
 */
export function mergeOrganizerCommunicationPreference(params: {
  existing?: OrganizerCommunicationPreferenceDocument;
  organizerId: string;
  uid: string;
  eventId: string;
  organizerUpdates?: RegisterPublicEventCallablePayload["organizerUpdates"];
  now: FirebaseFirestore.Timestamp;
}): OrganizerCommunicationPreferenceDocument | null {
  const grantsWhatsapp = params.organizerUpdates?.whatsapp === true;
  const grantsSms = params.organizerUpdates?.sms === true;
  if (!params.existing && !grantsWhatsapp && !grantsSms) return null;
  if (params.existing && !grantsWhatsapp && !grantsSms) return null;

  const unknownChannel = {
    status: "unknown" as const,
    termsVersion: null,
    source: null,
    sourceEventId: null,
    updatedAt: null,
  };
  const optedInChannel = {
    status: "optedIn" as const,
    termsVersion: params.organizerUpdates!.termsVersion,
    source: "publicEventRegistration" as const,
    sourceEventId: params.eventId,
    updatedAt: params.now,
  };
  return {
    organizerId: params.organizerId,
    uid: params.uid,
    whatsapp: grantsWhatsapp ? optedInChannel :
      params.existing?.whatsapp ?? unknownChannel,
    sms: grantsSms ? optedInChannel : params.existing?.sms ?? unknownChannel,
    createdAt: params.existing?.createdAt ?? params.now,
    updatedAt: params.now,
  };
}

function splitSupportedPhone(phoneE164: string): {
  countryCode: string;
  nationalNumber: string;
} {
  for (const countryCode of ["+977", "+91", "+61", "+1"]) {
    if (phoneE164.startsWith(countryCode)) {
      return {
        countryCode,
        nationalNumber: phoneE164.slice(countryCode.length),
      };
    }
  }
  return {countryCode: "", nationalNumber: phoneE164};
}

export function assertPublicRegistrationEligibility(params: {
  organizerVisibility: string | undefined;
  organizerPublishStatus: string | undefined;
  eventStatus: string;
  eventEndTimeMs: number;
  publicRegistrationEnabled: boolean;
  admissionFormat: string;
  inviteRequired: boolean;
  membershipRequired: boolean;
  manualApprovalRequired: boolean;
  priceInPaise: number;
}): void {
  if (
    params.organizerVisibility !== "discoverable" ||
    params.organizerPublishStatus !== "published"
  ) {
    throw new HttpsError(
      "failed-precondition",
      "This organizer has not published public registration."
    );
  }
  if (params.eventStatus === "cancelled" ||
      params.eventEndTimeMs <= Date.now()) {
    throw new HttpsError(
      "failed-precondition",
      "Registration is closed for this event."
    );
  }
  if (!params.publicRegistrationEnabled) {
    throw new HttpsError(
      "failed-precondition",
      "Website registration is not enabled for this event."
    );
  }
  if (params.priceInPaise > 0) {
    throw new HttpsError(
      "failed-precondition",
      "Website OTP registration cannot bypass payment for a paid event."
    );
  }
  if (params.admissionFormat !== "open" ||
      params.inviteRequired ||
      params.membershipRequired ||
      params.manualApprovalRequired) {
    throw new HttpsError(
      "failed-precondition",
      "Website OTP registration currently supports open-admission events."
    );
  }
}

export function publicRegistrationStatus(params: {
  activeCount: number;
  capacityLimit: number;
  existingStatus: EventAttendeeDocument["status"] | undefined;
}): EventAttendeeDocument["status"] {
  if (params.existingStatus === "checkedIn") return "checkedIn";
  if (params.existingStatus === "registered") return "registered";
  return params.activeCount < params.capacityLimit ?
    "registered" : "waitlisted";
}

export function prepareImportRows(params: {
  eventId: string;
  importKey: string;
  format?: "csv" | "xlsx" | "manual";
  rows: ImportRow[];
}): {prepared: PreparedRow[]; errors: ImportError[]} {
  const prepared: PreparedRow[] = [];
  const errors: ImportError[] = [];
  const seenAttendeeIds = new Set<string>();
  for (const row of params.rows) {
    const displayName = row.displayName.trim().replace(/\s+/g, " ");
    const phoneResult = normalizeRosterPhone(row.phone);
    if (phoneResult.issue) {
      errors.push({
        rowId: row.rowId,
        code: "invalid-phone",
        message: phoneResult.issue,
      });
      continue;
    }
    const email = stringOrNull(row.email)?.toLowerCase() ?? null;
    if (email !== null && !isValidEmail(email)) {
      errors.push({
        rowId: row.rowId,
        code: "invalid-email",
        message: "Enter a valid email address or leave it blank.",
      });
      continue;
    }
    const externalReference = stringOrNull(row.externalReference);
    const arrivalGroup = stringOrNull(row.arrivalGroup);
    let stableKey = `row:${params.importKey}:${row.rowId}`;
    if (arrivalGroup !== null && externalReference !== null) {
      stableKey = `external:${externalReference.toLowerCase()}`;
    } else if (phoneResult.value !== null) {
      stableKey = `phone:${phoneResult.value}`;
    } else if (email !== null) {
      stableKey = `email:${email}`;
    } else if (externalReference !== null) {
      stableKey = `external:${externalReference.toLowerCase()}`;
    } else if (params.format !== "manual") {
      errors.push({
        rowId: row.rowId,
        code: "missing-stable-identity",
        message: "Map a phone, email, or booking reference so this guest " +
          "can be safely re-imported.",
      });
      continue;
    }
    const attendeeId = eventAttendeeId(params.eventId, stableKey);
    if (seenAttendeeIds.has(attendeeId)) {
      errors.push({
        rowId: row.rowId,
        code: "duplicate-row",
        message: "This attendee appears more than once in the import.",
      });
      continue;
    }
    seenAttendeeIds.add(attendeeId);
    const revenueAmountMinor = row.revenueAmountMinor ?? null;
    const revenueCurrency = stringOrNull(row.revenueCurrency)?.toUpperCase() ??
      null;
    const revenueSource = row.revenueSource ?? null;
    const hasRevenue = revenueAmountMinor !== null ||
      revenueCurrency !== null || revenueSource !== null;
    if (hasRevenue &&
        (!Number.isSafeInteger(revenueAmountMinor) ||
          revenueAmountMinor! < 0 ||
          revenueCurrency === null ||
          !/^[A-Z]{3}$/.test(revenueCurrency) ||
          revenueSource === null)) {
      errors.push({
        rowId: row.rowId,
        code: "invalid-revenue",
        message: "Revenue needs a non-negative amount, three-letter " +
          "currency, and reported or estimated source.",
      });
      continue;
    }
    prepared.push({
      attendeeId,
      rowId: row.rowId,
      displayName,
      searchName: displayName.toLocaleLowerCase("en"),
      phoneE164: phoneResult.value,
      email,
      externalReference,
      arrivalGroup,
      ticketType: stringOrNull(row.ticketType),
      revenueAmountMinor,
      revenueCurrency,
      revenueSource,
      revenueAllocation: hasRevenue ? "perAttendee" : null,
      revenueOrderReference: null,
      revenueOrderAmountMinor: null,
      status: row.status,
    });
  }
  allocateSharedOrderRevenue(prepared);
  return {prepared, errors};
}

/**
 * A repeated imported order total is divided across its attendee rows once.
 * Host-entered fallbacks are explicitly per attendee and are never divided.
 */
export function allocateSharedOrderRevenue(rows: PreparedRow[]): void {
  const groups = new Map<string, PreparedRow[]>();
  for (const row of rows) {
    if (row.arrivalGroup === null || row.revenueSource !== "hostImport" ||
        row.revenueAmountMinor === null || row.revenueCurrency === null) {
      continue;
    }
    const key = `${row.arrivalGroup}|${row.revenueCurrency}|` +
      `${row.revenueAmountMinor}`;
    groups.set(key, [...(groups.get(key) ?? []), row]);
  }
  for (const group of groups.values()) {
    if (group.length < 2) continue;
    const orderAmount = group[0].revenueAmountMinor!;
    const baseShare = Math.floor(orderAmount / group.length);
    const remainder = orderAmount % group.length;
    group.forEach((row, index) => {
      row.revenueAmountMinor = baseShare + (index < remainder ? 1 : 0);
      row.revenueAllocation = "sharedOrder";
      row.revenueOrderReference = row.arrivalGroup;
      row.revenueOrderAmountMinor = orderAmount;
    });
  }
}

export function normalizeRosterPhone(
  value: string | null | undefined
): {value: string | null; issue: string | null} {
  const input = stringOrNull(value);
  if (input === null) return {value: null, issue: null};
  let normalized = input.replace(/[^\d+]/g, "");
  if (normalized.startsWith("00")) normalized = `+${normalized.slice(2)}`;
  if (!normalized.startsWith("+")) {
    const digits = normalized.replace(/^0+/, "");
    normalized = digits.length === 10 ? `+91${digits}` : `+${digits}`;
  }
  if (!/^\+[1-9][0-9]{7,14}$/.test(normalized)) {
    return {
      value: null,
      issue: "Use a complete phone number with country code.",
    };
  }
  return {value: normalized, issue: null};
}

export function eventAttendeeId(eventId: string, stableKey: string): string {
  return `att_${sha256(`${eventId}|${stableKey}`).slice(0, 48)}`;
}

function eventAttendeeImportId(params: {
  eventId: string;
  hostUid: string;
  importKey: string;
}): string {
  return `imp_${sha256(
    `${params.eventId}|${params.hostUid}|${params.importKey}`
  ).slice(0, 48)}`;
}

function canonicalImportPayload(
  payload: ImportEventAttendeesCallablePayload
): ImportEventAttendeesCallablePayload {
  return {
    eventId: payload.eventId,
    importKey: payload.importKey,
    fileName: payload.fileName,
    format: payload.format,
    rows: payload.rows.map((row) => ({
      rowId: row.rowId,
      displayName: row.displayName,
      phone: row.phone ?? null,
      email: row.email ?? null,
      externalReference: row.externalReference ?? null,
      arrivalGroup: row.arrivalGroup ?? null,
      ticketType: row.ticketType ?? null,
      revenueAmountMinor: row.revenueAmountMinor ?? null,
      revenueCurrency: row.revenueCurrency ?? null,
      revenueSource: row.revenueSource ?? null,
      status: row.status,
    })),
  };
}

function normalizeImportPayload(data: unknown): unknown {
  if (typeof data !== "object" || data === null || Array.isArray(data)) {
    return data;
  }
  const normalized = {...data} as Record<string, unknown>;
  for (const field of ["eventId", "importKey", "fileName"]) {
    if (typeof normalized[field] === "string") {
      normalized[field] = normalized[field].trim();
    }
  }
  if (Array.isArray(normalized.rows)) {
    normalized.rows = normalized.rows.map((rawRow) => {
      if (typeof rawRow !== "object" || rawRow === null ||
          Array.isArray(rawRow)) return rawRow;
      const row = {...rawRow} as Record<string, unknown>;
      for (const field of [
        "rowId", "displayName", "phone", "email", "externalReference",
        "arrivalGroup", "ticketType",
        "revenueCurrency",
      ]) {
        if (typeof row[field] === "string") row[field] = row[field].trim();
      }
      return row;
    });
  }
  return normalized;
}

function normalizeAttendancePayload(data: unknown): unknown {
  if (typeof data !== "object" || data === null || Array.isArray(data)) {
    return data;
  }
  const normalized = {...data} as Record<string, unknown>;
  for (const field of ["eventId", "attendeeId"]) {
    if (typeof normalized[field] === "string") {
      normalized[field] = normalized[field].trim();
    }
  }
  return normalized;
}

function normalizeSetAttendancePayload(data: unknown): unknown {
  const normalized = normalizeAttendancePayload(data);
  if (!normalized || typeof normalized !== "object" ||
      Array.isArray(normalized)) return normalized;
  const payload = {...normalized as Record<string, unknown>};
  if (typeof payload.clientOperationId === "string") {
    payload.clientOperationId = payload.clientOperationId.trim();
  }
  return payload;
}

export function attendanceReceiptId(params: {
  eventId: string;
  actorUid: string;
  clientOperationId: string;
}): string {
  return `ear_${sha256(
    `${params.eventId}|${params.actorUid}|${params.clientOperationId}`
  ).slice(0, 48)}`;
}

function normalizePublicRegistrationPayload(data: unknown): unknown {
  if (typeof data !== "object" || data === null || Array.isArray(data)) {
    return data;
  }
  const normalized = {...data} as Record<string, unknown>;
  for (const field of ["eventId", "displayName", "inviteToken"]) {
    if (typeof normalized[field] === "string") {
      normalized[field] = normalized[field].trim().replace(/\s+/g, " ");
    }
  }
  if (typeof normalized.organizerUpdates === "object" &&
      normalized.organizerUpdates !== null &&
      !Array.isArray(normalized.organizerUpdates)) {
    const organizerUpdates = {
      ...normalized.organizerUpdates,
    } as Record<string, unknown>;
    if (typeof organizerUpdates.termsVersion === "string") {
      organizerUpdates.termsVersion = organizerUpdates.termsVersion.trim();
    }
    normalized.organizerUpdates = organizerUpdates;
  }
  return normalized;
}

function importResult(
  importId: string,
  receipt: EventAttendeeImportDocument,
  replayed: boolean
): EventAttendeeImportResult {
  return {
    importId,
    status: receipt.status,
    rowCount: receipt.rowCount,
    createdCount: receipt.createdCount,
    updatedCount: receipt.updatedCount,
    skippedCount: receipt.skippedCount,
    errors: receipt.errors,
    replayed,
  };
}

function stringOrNull(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const normalized = value.trim();
  return normalized.length === 0 ? null : normalized;
}

function isValidEmail(value: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
}

function sha256(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

export const importEventAttendees = onCall(
  appCheckCallableOptions,
  (request) => importEventAttendeesHandler(request)
);

export const markEventAttendeeAttendance = onCall(
  appCheckCallableOptions,
  (request) => markEventAttendeeAttendanceHandler(request)
);

export const setEventAttendeeAttendance = onCall(
  appCheckCallableOptions,
  (request) => setEventAttendeeAttendanceHandler(request)
);

export const registerPublicEvent = onCall(
  appCheckCallableOptions,
  (request) => registerPublicEventHandler(request)
);
