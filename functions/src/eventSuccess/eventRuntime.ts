import {createHash} from "crypto";
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {
  EventAttendeeDocument,
  EventDocument,
  EventRuntimeClaimRequestDocument,
  EventRuntimeParticipantDocument,
  EventSuccessPlanDocument,
  OnboardingDraftDocument,
} from "../shared/generated/firestoreAdminTypes";
import {ApproveEventRuntimeClaimCallablePayload} from
  "../shared/generated/approveEventRuntimeClaimCallablePayload";
import {ApproveEventRuntimeClaimCallableResponse} from
  "../shared/generated/approveEventRuntimeClaimCallableResponse";
import {ClaimEventRuntimeAccessCallablePayload} from
  "../shared/generated/claimEventRuntimeAccessCallablePayload";
import {ClaimEventRuntimeAccessCallableResponse} from
  "../shared/generated/claimEventRuntimeAccessCallableResponse";
import {CheckInEventRuntimeCallablePayload} from
  "../shared/generated/checkInEventRuntimeCallablePayload";
import {CheckInEventRuntimeCallableResponse} from
  "../shared/generated/checkInEventRuntimeCallableResponse";
import {GetEventRuntimeBootstrapCallablePayload} from
  "../shared/generated/getEventRuntimeBootstrapCallablePayload";
import {GetEventRuntimeBootstrapCallableResponse} from
  "../shared/generated/getEventRuntimeBootstrapCallableResponse";
import {SubmitEventRuntimeProfileCallablePayload} from
  "../shared/generated/submitEventRuntimeProfileCallablePayload";
import {SubmitEventRuntimeProfileCallableResponse} from
  "../shared/generated/submitEventRuntimeProfileCallableResponse";
import {
  validateApproveEventRuntimeClaimCallablePayload,
  validateClaimEventRuntimeAccessCallablePayload,
  validateCheckInEventRuntimeCallablePayload,
  validateGetEventRuntimeBootstrapCallablePayload,
  validateSubmitEventRuntimeProfileCallablePayload,
} from "../shared/generated/schemaValidators";
import {
  eventOrganizerRef,
  requireEventOrganizer,
} from "../shared/eventOrganizers";
import {requireEventOperatorPermission} from
  "../shared/eventOperatorAuthority";
import {checkRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {
  eventAttendeeId,
  normalizeRosterPhone,
  onboardingDraftSeed,
} from "../events/eventAttendees";
import {resolveInviteAttributionToken} from "../events/inviteLinks";
import {eventSuccessPrimitivesFor} from "./formatPrimitives";

type RuntimeFieldId =
  EventRuntimeParticipantDocument["requiredFieldIds"][number];
type RuntimeProfile = EventRuntimeParticipantDocument["runtimeProfile"];

interface EventRuntimeDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  timestamp: () => FirebaseFirestore.Timestamp;
  timestampFromMillis: (millis: number) => FirebaseFirestore.Timestamp;
}

const defaultDeps: EventRuntimeDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  timestamp: () => admin.firestore.Timestamp.now(),
  timestampFromMillis: (millis) =>
    admin.firestore.Timestamp.fromMillis(millis),
};

const PREFERENCE_AWARE_MODULE_IDS = new Set([
  "first_hello_check_in",
  "guided_rotations",
  "micro_pods",
  "wingman_requests",
]);

/** Returns the bounded public event projection and the caller's own state. */
export async function getEventRuntimeBootstrapHandler(
  request: CallableRequest<unknown>,
  deps: EventRuntimeDeps = defaultDeps
): Promise<GetEventRuntimeBootstrapCallableResponse> {
  const payload = validateCallableWithAjv<
    GetEventRuntimeBootstrapCallablePayload
  >(
    request,
    validateGetEventRuntimeBootstrapCallablePayload,
    normalizeRuntimeIdPayload
  );
  const db = deps.firestore();
  const rateLimitIdentity = request.auth?.uid ??
    `runtime_${sha256(payload.publicRuntimeId).slice(0, 40)}`;
  await deps.checkRateLimit(
    db,
    rateLimitIdentity,
    "getEventRuntimeBootstrap"
  );
  const resolved = await resolveRuntimeEvent(db, payload.publicRuntimeId);
  const participantRef = request.auth ? db
    .collection("eventRuntimeParticipants")
    .doc(eventRuntimeParticipantId(resolved.eventId, request.auth.uid)) : null;
  const [participantSnap, planSnap] = await Promise.all([
    participantRef ? participantRef.get() : Promise.resolve(null),
    db.collection("eventSuccessPlans").doc(resolved.eventId).get(),
  ]);
  const plan = planSnap.exists ? requireDoc<EventSuccessPlanDocument>(
    planSnap,
    "EventSuccessPlanDocument"
  ) : null;
  let participant = participantSnap?.exists ?
    requireRuntimeParticipant(
      participantSnap,
      resolved.eventId,
      request.auth!.uid
    ) : null;
  if (participant && participantRef) {
    participant = await reconcileRuntimeParticipantRequirements({
      participant,
      participantRef,
      requiredFieldIds: requiredRuntimeFieldIds(plan),
      now: deps.timestamp(),
    });
  }
  let attendeeStatus: EventAttendeeDocument["status"] | null = null;
  if (participant?.eventAttendeeId) {
    const attendeeSnap = await db
      .collection("eventAttendees")
      .doc(participant.eventAttendeeId)
      .get();
    if (attendeeSnap.exists) {
      const attendee = requireDoc<EventAttendeeDocument>(
        attendeeSnap,
        "EventAttendeeDocument"
      );
      if (attendee.eventId === resolved.eventId) {
        attendeeStatus = attendee.status;
      }
    }
  }
  return {
    event: publicRuntimeEventProjection(
      resolved.event,
      resolved.eventId,
      payload.publicRuntimeId,
      plan
    ),
    participant: participant ? {
      accessStatus: participant.accessStatus,
      attendanceStatus: attendeeStatus,
      eventId: resolved.eventId,
      clubId: participant.clubId,
      organizerId: participant.organizerId ?? participant.clubId,
      requiredFieldIds: participant.requiredFieldIds,
      completedFieldIds: participant.completedFieldIds,
      runtimeProfile: runtimeProfileResponse(participant.runtimeProfile),
    } : null,
  };
}

/** Claims a matching roster row, or opens the configured walk-in flow. */
export async function claimEventRuntimeAccessHandler(
  request: CallableRequest<unknown>,
  deps: EventRuntimeDeps = defaultDeps
): Promise<ClaimEventRuntimeAccessCallableResponse> {
  const uid = requireAuth(request);
  const payload = validateCallableWithAjv<
    ClaimEventRuntimeAccessCallablePayload
  >(
    request,
    validateClaimEventRuntimeAccessCallablePayload,
    normalizeClaimPayload
  );
  const phone = verifiedPhone(request);
  const db = deps.firestore();
  await deps.checkRateLimit(db, uid, "claimEventRuntimeAccess");
  const resolved = await resolveRuntimeEvent(db, payload.publicRuntimeId);
  const inviteAttribution = await resolveInviteAttributionToken({
    db,
    eventId: resolved.eventId,
    inviteToken: payload.inviteToken,
  });
  requireRuntimeTerms(resolved.event, payload.runtimeTermsVersion);

  const participantRef = db.collection("eventRuntimeParticipants")
    .doc(eventRuntimeParticipantId(resolved.eventId, uid));
  const requestRef = db.collection("eventRuntimeClaimRequests")
    .doc(eventRuntimeParticipantId(resolved.eventId, uid));
  const exactAttendeeId = eventAttendeeId(
    resolved.eventId,
    `phone:${phone}`
  );
  const attendeeRef = db.collection("eventAttendees").doc(exactAttendeeId);
  const planRef = db.collection("eventSuccessPlans").doc(resolved.eventId);

  return db.runTransaction(async (tx) => {
    const [participantSnap, attendeeSnap, planSnap] = await Promise.all([
      tx.get(participantRef),
      tx.get(attendeeRef),
      tx.get(planRef),
    ]);
    if (participantSnap.exists) {
      const participant = requireRuntimeParticipant(
        participantSnap,
        resolved.eventId,
        uid
      );
      if (participant.accessStatus !== "revoked") {
        return claimResponse(participant);
      }
    }

    const plan = planSnap.exists ? requireDoc<EventSuccessPlanDocument>(
      planSnap,
      "EventSuccessPlanDocument"
    ) : null;
    const requiredFieldIds = requiredRuntimeFieldIds(plan);
    const now = deps.timestamp();
    let attendee = attendeeSnap.exists ? requireDoc<EventAttendeeDocument>(
      attendeeSnap,
      "EventAttendeeDocument"
    ) : null;
    if (attendee && attendee.eventId !== resolved.eventId) {
      throw new HttpsError("internal", "Roster identity is inconsistent.");
    }
    if (attendee?.linkedUid && attendee.linkedUid !== uid) {
      throw new HttpsError(
        "permission-denied",
        "This ticket has already been claimed. Ask the Host for help."
      );
    }
    if (attendee?.status === "cancelled") {
      throw new HttpsError(
        "failed-precondition",
        "This attendee registration is cancelled."
      );
    }

    const walkInPolicy = resolved.event.runtimeAccess!.walkInPolicy;
    if (!attendee && walkInPolicy === "deny") {
      throw new HttpsError(
        "permission-denied",
        "We could not match this verified number to the Host's guest list."
      );
    }

    if (!attendee) {
      attendee = runtimeAttendeeDocument({
        event: resolved.event,
        eventId: resolved.eventId,
        uid: walkInPolicy === "autoCreate" ? uid : null,
        displayName: payload.displayName,
        phone,
        status: walkInPolicy === "autoCreate" ? "registered" : "invited",
        inviteLinkId: inviteAttribution?.inviteLinkId ?? null,
        now,
      });
      tx.create(attendeeRef, attendee);
    } else {
      tx.update(attendeeRef, {
        linkedUid: uid,
        linkedAt: attendee.linkedAt ?? now,
        ...(attendee.inviteLinkId || !inviteAttribution ? {} : {
          inviteLinkId: inviteAttribution.inviteLinkId,
          inviteCapturedAt: now,
        }),
        updatedAt: now,
      });
      attendee = {...attendee, linkedUid: uid};
    }

    const needsApproval = !attendeeSnap.exists &&
      walkInPolicy === "hostApproval";
    const profile = emptyRuntimeProfile(payload.displayName);
    const completedFieldIds = completedRuntimeFieldIds(profile);
    const accessStatus = needsApproval ? "pendingApproval" :
      runtimeAccessStatus(requiredFieldIds, completedFieldIds);
    const participant: EventRuntimeParticipantDocument = {
      eventId: resolved.eventId,
      clubId: resolved.event.clubId,
      organizerId: resolved.event.organizerId ?? resolved.event.clubId,
      uid,
      eventAttendeeId: exactAttendeeId,
      identityVersion: 1,
      claimMethod: "verifiedPhone",
      accessStatus,
      requiredFieldIds,
      completedFieldIds,
      runtimeProfile: profile,
      consents: {
        runtimeTermsVersion: payload.runtimeTermsVersion,
        sensitiveDataTermsVersion: null,
        saveAsCatchPrefill: false,
      },
      claimedAt: now,
      readyAt: accessStatus === "ready" ? now : null,
      revokedAt: null,
      createdAt: now,
      updatedAt: now,
    };
    tx.set(participantRef, participant);
    if (needsApproval) {
      const claimRequest: EventRuntimeClaimRequestDocument = {
        eventId: resolved.eventId,
        clubId: resolved.event.clubId,
        organizerId: resolved.event.organizerId ?? resolved.event.clubId,
        uid,
        displayName: payload.displayName,
        phoneLastFour: phone.slice(-4),
        candidateAttendeeIds: [exactAttendeeId],
        status: "pending",
        reviewedBy: null,
        reviewReason: null,
        createdAt: now,
        updatedAt: now,
        reviewedAt: null,
      };
      tx.set(requestRef, claimRequest);
    }
    return claimResponse(participant);
  });
}

/** Saves the plan-derived event profile and optional private prefill. */
export async function submitEventRuntimeProfileHandler(
  request: CallableRequest<unknown>,
  deps: EventRuntimeDeps = defaultDeps
): Promise<SubmitEventRuntimeProfileCallableResponse> {
  const uid = requireAuth(request);
  const phone = verifiedPhone(request);
  const payload = validateCallableWithAjv<
    SubmitEventRuntimeProfileCallablePayload
  >(
    request,
    validateSubmitEventRuntimeProfileCallablePayload,
    normalizeProfilePayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, uid, "submitEventRuntimeProfile");
  const resolved = await resolveRuntimeEvent(db, payload.publicRuntimeId);
  requireRuntimeTerms(resolved.event, payload.runtimeTermsVersion);
  const participantRef = db.collection("eventRuntimeParticipants")
    .doc(eventRuntimeParticipantId(resolved.eventId, uid));
  const planRef = db.collection("eventSuccessPlans").doc(resolved.eventId);
  const draftRef = db.collection("onboarding_drafts").doc(uid);
  const userRef = db.collection("users").doc(uid);

  return db.runTransaction(async (tx) => {
    const [participantSnap, planSnap, draftSnap, userSnap] = await Promise.all([
      tx.get(participantRef),
      tx.get(planRef),
      tx.get(draftRef),
      tx.get(userRef),
    ]);
    const participant = requireRuntimeParticipant(
      participantSnap,
      resolved.eventId,
      uid
    );
    if (participant.accessStatus === "pendingApproval") {
      throw new HttpsError(
        "failed-precondition",
        "The Host must approve this guest-list request first."
      );
    }
    if (participant.accessStatus === "revoked") {
      throw new HttpsError("permission-denied", "Runtime access was revoked.");
    }
    const plan = planSnap.exists ? requireDoc<EventSuccessPlanDocument>(
      planSnap,
      "EventSuccessPlanDocument"
    ) : null;
    const requiredFieldIds = requiredRuntimeFieldIds(plan);
    const profile = mergeRuntimeProfile(
      participant.runtimeProfile,
      payload.fields,
      deps.timestampFromMillis
    );
    const completedFieldIds = completedRuntimeFieldIds(profile);
    const accessStatus = runtimeAccessStatus(
      requiredFieldIds,
      completedFieldIds
    );
    if (completedFieldIds.some((field) =>
      isSensitiveRuntimeField(field)) &&
      !payload.sensitiveDataTermsVersion &&
      !participant.consents.sensitiveDataTermsVersion) {
      throw new HttpsError(
        "failed-precondition",
        "Accept the sensitive-data notice before submitting these answers."
      );
    }
    const now = deps.timestamp();
    tx.update(participantRef, {
      requiredFieldIds,
      completedFieldIds,
      runtimeProfile: profile,
      accessStatus,
      consents: {
        runtimeTermsVersion: payload.runtimeTermsVersion,
        sensitiveDataTermsVersion: payload.sensitiveDataTermsVersion ??
          participant.consents.sensitiveDataTermsVersion,
        saveAsCatchPrefill: payload.saveAsCatchPrefill,
      },
      readyAt: accessStatus === "ready" ? participant.readyAt ?? now : null,
      updatedAt: now,
    });
    if (payload.saveAsCatchPrefill && !userSnap.exists) {
      const existingDraft = draftSnap.exists ?
        draftSnap.data() as OnboardingDraftDocument : null;
      tx.set(
        draftRef,
        onboardingPrefillPatch(existingDraft, profile, phone),
        {merge: true}
      );
    }
    return {status: accessStatus, requiredFieldIds, completedFieldIds};
  });
}

/** Checks a ready runtime identity into its linked operational attendee. */
export async function checkInEventRuntimeHandler(
  request: CallableRequest<unknown>,
  deps: EventRuntimeDeps = defaultDeps
): Promise<CheckInEventRuntimeCallableResponse> {
  const uid = requireAuth(request);
  const payload = validateCallableWithAjv<CheckInEventRuntimeCallablePayload>(
    request,
    validateCheckInEventRuntimeCallablePayload,
    normalizeRuntimeIdPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, uid, "checkInEventRuntime");
  const resolved = await resolveRuntimeEvent(db, payload.publicRuntimeId);
  const participantRef = db.collection("eventRuntimeParticipants")
    .doc(eventRuntimeParticipantId(resolved.eventId, uid));
  const eventRef = db.collection("events").doc(resolved.eventId);

  return db.runTransaction(async (tx) => {
    const participantSnap = await tx.get(participantRef);
    const participant = requireRuntimeParticipant(
      participantSnap,
      resolved.eventId,
      uid
    );
    if (participant.accessStatus !== "ready" || !participant.eventAttendeeId) {
      throw new HttpsError(
        "failed-precondition",
        "Finish the event profile before checking in."
      );
    }
    const attendeeRef = db.collection("eventAttendees")
      .doc(participant.eventAttendeeId);
    const attendeeSnap = await tx.get(attendeeRef);
    if (!attendeeSnap.exists) {
      throw new HttpsError("not-found", "Guest-list entry not found.");
    }
    const attendee = requireDoc<EventAttendeeDocument>(
      attendeeSnap,
      "EventAttendeeDocument"
    );
    if (
      attendee.eventId !== resolved.eventId ||
      attendee.linkedUid !== uid ||
      attendee.status === "cancelled"
    ) {
      throw new HttpsError(
        "failed-precondition",
        "This guest-list entry cannot be checked in."
      );
    }
    if (attendee.status === "checkedIn") {
      return {status: "checkedIn", alreadyCheckedIn: true};
    }
    const now = deps.timestamp();
    tx.update(attendeeRef, {
      status: "checkedIn",
      checkedInAt: now,
      checkedInBy: uid,
      attendanceRevision: (attendee.attendanceRevision ?? 0) + 1,
      preCheckInStatus: attendee.status,
      updatedAt: now,
    });
    tx.update(eventRef, {
      checkedInCount: admin.firestore.FieldValue.increment(1),
      updatedAt: now,
    });
    return {status: "checkedIn", alreadyCheckedIn: false};
  });
}

/** Lets an organizer manager approve or reject a pending claim. */
export async function approveEventRuntimeClaimHandler(
  request: CallableRequest<unknown>,
  deps: EventRuntimeDeps = defaultDeps
): Promise<ApproveEventRuntimeClaimCallableResponse> {
  const hostUid = requireAuth(request);
  const payload = validateCallableWithAjv<
    ApproveEventRuntimeClaimCallablePayload
  >(
    request,
    validateApproveEventRuntimeClaimCallablePayload,
    normalizeApprovalPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, hostUid, "approveEventRuntimeClaim");
  const eventRef = db.collection("events").doc(payload.eventId);
  const participantId = eventRuntimeParticipantId(payload.eventId, payload.uid);
  const participantRef = db.collection("eventRuntimeParticipants")
    .doc(participantId);
  const claimRef = db.collection("eventRuntimeClaimRequests")
    .doc(participantId);

  return db.runTransaction(async (tx) => {
    const eventSnap = await tx.get(eventRef);
    if (!eventSnap.exists) {
      throw new HttpsError("not-found", "Event not found.");
    }
    const event = requireDoc<EventDocument>(eventSnap, "EventDocument");
    const organizerSnap = await tx.get(eventOrganizerRef(db, event));
    const organizer = requireEventOrganizer(organizerSnap, event);
    await requireEventOperatorPermission({
      db,
      organizer,
      event,
      eventId: payload.eventId,
      actorUid: hostUid,
      permission: "reviewRuntimeClaims",
      now: deps.timestamp(),
      transaction: tx,
    });
    const [participantSnap, claimSnap] = await Promise.all([
      tx.get(participantRef),
      tx.get(claimRef),
    ]);
    const participant = requireRuntimeParticipant(
      participantSnap,
      payload.eventId,
      payload.uid
    );
    if (!claimSnap.exists) {
      throw new HttpsError("not-found", "Runtime claim not found.");
    }
    const claim = requireDoc<EventRuntimeClaimRequestDocument>(
      claimSnap,
      "EventRuntimeClaimRequestDocument"
    );
    if (claim.status !== "pending" ||
        participant.accessStatus !== "pendingApproval") {
      throw new HttpsError(
        "failed-precondition",
        "This runtime claim has already been reviewed."
      );
    }
    const now = deps.timestamp();
    if (payload.decision === "reject") {
      tx.update(claimRef, {
        status: "rejected",
        reviewedBy: hostUid,
        reviewReason: payload.reason ?? null,
        reviewedAt: now,
        updatedAt: now,
      });
      tx.update(participantRef, {
        accessStatus: "revoked",
        revokedAt: now,
        updatedAt: now,
      });
      return {status: "rejected"};
    }

    const attendeeId = payload.attendeeId ?? participant.eventAttendeeId;
    if (!attendeeId || !claim.candidateAttendeeIds.includes(attendeeId)) {
      throw new HttpsError(
        "invalid-argument",
        "Choose one of this claim's event-scoped attendee records."
      );
    }
    const attendeeRef = db.collection("eventAttendees").doc(attendeeId);
    const attendeeSnap = await tx.get(attendeeRef);
    if (!attendeeSnap.exists) {
      throw new HttpsError("not-found", "Attendee not found.");
    }
    const attendee = requireDoc<EventAttendeeDocument>(
      attendeeSnap,
      "EventAttendeeDocument"
    );
    if (attendee.eventId !== payload.eventId ||
        attendee.status === "cancelled" ||
        (attendee.linkedUid && attendee.linkedUid !== payload.uid)) {
      throw new HttpsError(
        "failed-precondition",
        "This attendee cannot be linked to the claim."
      );
    }
    const accessStatus = runtimeAccessStatus(
      participant.requiredFieldIds,
      participant.completedFieldIds
    );
    tx.update(attendeeRef, {
      linkedUid: payload.uid,
      linkedAt: attendee.linkedAt ?? now,
      status: attendee.status === "invited" ? "registered" : attendee.status,
      registeredAt: attendee.registeredAt ?? now,
      attendanceRevision: attendee.attendanceRevision ?? 0,
      preCheckInStatus: attendee.preCheckInStatus ?? null,
      updatedAt: now,
    });
    tx.update(participantRef, {
      eventAttendeeId: attendeeId,
      claimMethod: "hostApproval",
      accessStatus,
      readyAt: accessStatus === "ready" ? now : null,
      updatedAt: now,
    });
    tx.update(claimRef, {
      status: "approved",
      reviewedBy: hostUid,
      reviewReason: payload.reason ?? null,
      reviewedAt: now,
      updatedAt: now,
    });
    return {status: "approved"};
  });
}

export function eventRuntimeParticipantId(
  eventId: string,
  uid: string
): string {
  return `${eventId}_${uid}`;
}

export function requiredRuntimeFieldIds(
  _plan?: EventSuccessPlanDocument | null
): RuntimeFieldId[] {
  void _plan;
  return ["displayName"];
}

/** Sensitive preference fields offered by this plan, but never required. */
export function optionalRuntimeFieldIds(
  event: EventDocument,
  plan: EventSuccessPlanDocument | null
): RuntimeFieldId[] {
  if (!plan?.selectedModuleIds.some((id) =>
    PREFERENCE_AWARE_MODULE_IDS.has(id))) return [];
  const policy = eventSuccessPrimitivesFor(event.eventFormat)
    .compatibilityPolicy;
  if (policy !== "mutualInterestOnly" &&
      policy !== "socialCohortBalance") return [];
  return ["gender", "interestedInGenders"];
}

export function completedRuntimeFieldIds(
  profile: RuntimeProfile
): RuntimeFieldId[] {
  const fields: RuntimeFieldId[] = [];
  if (profile.displayName.trim().length > 0) fields.push("displayName");
  if (profile.gender !== null) fields.push("gender");
  if (profile.interestedInGenders.length > 0) {
    fields.push("interestedInGenders");
  }
  if (profile.relationshipGoal !== null) fields.push("relationshipGoal");
  if (profile.dateOfBirth !== null) fields.push("dateOfBirth");
  return fields;
}

function runtimeAccessStatus(
  required: RuntimeFieldId[],
  completed: RuntimeFieldId[]
): "needsInput" | "ready" {
  return required.every((field) => completed.includes(field)) ?
    "ready" : "needsInput";
}

async function resolveRuntimeEvent(
  db: FirebaseFirestore.Firestore,
  publicRuntimeId: string
): Promise<{eventId: string; event: EventDocument}> {
  const snapshot = await db.collection("events")
    .where("runtimeAccess.publicRuntimeId", "==", publicRuntimeId)
    .limit(2)
    .get();
  if (snapshot.empty) {
    throw new HttpsError("not-found", "Event runtime not found.");
  }
  if (snapshot.size !== 1) {
    throw new HttpsError("internal", "Event runtime identity is not unique.");
  }
  const eventSnap = snapshot.docs[0];
  const event = requireDoc<EventDocument>(eventSnap, "EventDocument");
  if (
    event.status === "cancelled" ||
    event.runtimeAccess?.enabled !== true ||
    event.runtimeAccess.publicRuntimeId !== publicRuntimeId
  ) {
    throw new HttpsError("not-found", "Event runtime not found.");
  }
  return {eventId: eventSnap.id, event};
}

function verifiedPhone(request: CallableRequest<unknown>): string {
  const rawPhone = request.auth?.token.phone_number;
  const result = normalizeRosterPhone(
    typeof rawPhone === "string" ? rawPhone : null
  );
  if (!result.value) {
    throw new HttpsError(
      "failed-precondition",
      "Verify a phone number before joining this event."
    );
  }
  return result.value;
}

function requireRuntimeTerms(event: EventDocument, termsVersion: string): void {
  if (event.runtimeAccess?.termsVersion !== termsVersion) {
    throw new HttpsError(
      "failed-precondition",
      "Review the latest Event Success runtime terms."
    );
  }
}

function requireRuntimeParticipant(
  snapshot: FirebaseFirestore.DocumentSnapshot,
  eventId: string,
  uid: string
): EventRuntimeParticipantDocument {
  if (!snapshot.exists) {
    throw new HttpsError(
      "failed-precondition",
      "Claim this event before continuing."
    );
  }
  const participant = requireDoc<EventRuntimeParticipantDocument>(
    snapshot,
    "EventRuntimeParticipantDocument"
  );
  if (participant.eventId !== eventId || participant.uid !== uid) {
    throw new HttpsError("permission-denied", "Runtime identity mismatch.");
  }
  return participant;
}

function publicRuntimeEventProjection(
  event: EventDocument,
  eventId: string,
  publicRuntimeId: string,
  plan: EventSuccessPlanDocument | null
): GetEventRuntimeBootstrapCallableResponse["event"] {
  const customLabel = event.eventFormat.customActivityLabel?.trim();
  return {
    eventId,
    publicRuntimeId,
    title: customLabel || activityTitle(event.eventFormat.activityKind),
    startTimeMillis: event.startTime.toMillis(),
    endTimeMillis: event.endTime.toMillis(),
    locationName: event.meetingLocation.name || event.meetingPoint,
    runtimeTermsVersion: event.runtimeAccess!.termsVersion,
    moduleIds: plan?.selectedModuleIds ?? [],
    requiredFieldIds: requiredRuntimeFieldIds(plan),
    optionalFieldIds: optionalRuntimeFieldIds(event, plan),
    questionnaireConfig: plan?.questionnaireConfig ?? null,
  };
}

async function reconcileRuntimeParticipantRequirements(params: {
  participant: EventRuntimeParticipantDocument;
  participantRef: FirebaseFirestore.DocumentReference;
  requiredFieldIds: RuntimeFieldId[];
  now: FirebaseFirestore.Timestamp;
}): Promise<EventRuntimeParticipantDocument> {
  const {participant, participantRef, requiredFieldIds, now} = params;
  const completedFieldIds = completedRuntimeFieldIds(
    participant.runtimeProfile
  );
  const accessStatus = participant.accessStatus === "pendingApproval" ||
      participant.accessStatus === "revoked" ||
      participant.accessStatus === "optedOut" ?
    participant.accessStatus :
    runtimeAccessStatus(requiredFieldIds, completedFieldIds);
  const unchanged = arraysEqual(
    participant.requiredFieldIds,
    requiredFieldIds
  ) && arraysEqual(participant.completedFieldIds, completedFieldIds) &&
    participant.accessStatus === accessStatus;
  if (unchanged) return participant;
  const readyAt = accessStatus === "ready" ? participant.readyAt ?? now : null;
  await participantRef.update({
    requiredFieldIds,
    completedFieldIds,
    accessStatus,
    readyAt,
    updatedAt: now,
  });
  return {
    ...participant,
    requiredFieldIds,
    completedFieldIds,
    accessStatus,
    readyAt,
    updatedAt: now,
  };
}

function arraysEqual<T>(a: T[], b: T[]): boolean {
  return a.length === b.length && a.every((value, index) => value === b[index]);
}

function activityTitle(
  activityKind: EventDocument["eventFormat"]["activityKind"]
): string {
  const titles: Record<typeof activityKind, string> = {
    socialRun: "Social run",
    running: "Run",
    walking: "Walk",
    pickleball: "Pickleball social",
    padel: "Padel social",
    tennis: "Tennis social",
    badminton: "Badminton social",
    cycling: "Cycling social",
    spinClass: "Spin class",
    yoga: "Yoga social",
    strengthTraining: "Strength session",
    pubQuiz: "Pub quiz",
    barCrawl: "Bar crawl",
    dinner: "Dinner",
    singlesMixer: "Singles mixer",
    openActivity: "Hosted event",
  };
  return titles[activityKind];
}

function emptyRuntimeProfile(displayName: string): RuntimeProfile {
  return {
    displayName,
    gender: null,
    interestedInGenders: [],
    relationshipGoal: null,
    dateOfBirth: null,
  };
}

function mergeRuntimeProfile(
  existing: RuntimeProfile,
  fields: SubmitEventRuntimeProfileCallablePayload["fields"],
  timestampFromMillis: (millis: number) => FirebaseFirestore.Timestamp
): RuntimeProfile {
  return {
    displayName: fields.displayName ?? existing.displayName,
    gender: fields.gender === undefined ? existing.gender : fields.gender,
    interestedInGenders: fields.interestedInGenders ??
      existing.interestedInGenders,
    relationshipGoal: fields.relationshipGoal === undefined ?
      existing.relationshipGoal : fields.relationshipGoal,
    dateOfBirth: fields.dateOfBirthMillis === undefined ?
      existing.dateOfBirth :
      fields.dateOfBirthMillis === null ? null :
        timestampFromMillis(fields.dateOfBirthMillis),
  };
}

function onboardingPrefillPatch(
  existing: OnboardingDraftDocument | null,
  profile: RuntimeProfile,
  phoneE164: string
): OnboardingDraftDocument {
  const identitySeed = onboardingDraftSeed({
    displayName: profile.displayName,
    phoneE164,
  });
  const base = existing ?? {step: 1};
  const patch: OnboardingDraftDocument = {
    step: existing?.step ?? 1,
    draftVersion: existing?.draftVersion ?? 2,
  };
  if (!base.firstName) patch.firstName = profile.displayName.slice(0, 80);
  if (!base.phoneNumber) patch.phoneNumber = identitySeed.phoneNumber;
  if (!base.countryCode) patch.countryCode = identitySeed.countryCode;
  if (base.gender == null && profile.gender !== null) {
    patch.gender = profile.gender;
  }
  if (
    (!base.interestedInGenders || base.interestedInGenders.length === 0) &&
    profile.interestedInGenders.length > 0
  ) {
    patch.interestedInGenders = profile.interestedInGenders;
  }
  if (base.dateOfBirth == null && profile.dateOfBirth !== null) {
    patch.dateOfBirth = profile.dateOfBirth;
  }
  if (!base.relationshipGoal && profile.relationshipGoal !== null) {
    patch.relationshipGoal = profile.relationshipGoal;
  }
  patch.eventRuntimePrefill = {
    consented: true,
    source: "eventSuccessRuntime",
  };
  return patch;
}

function runtimeAttendeeDocument(params: {
  event: EventDocument;
  eventId: string;
  uid: string | null;
  displayName: string;
  phone: string;
  status: "invited" | "registered";
  inviteLinkId: string | null;
  now: FirebaseFirestore.Timestamp;
}): EventAttendeeDocument {
  return {
    eventId: params.eventId,
    clubId: params.event.clubId,
    organizerId: params.event.organizerId ?? params.event.clubId,
    displayName: params.displayName,
    searchName: params.displayName.toLocaleLowerCase("en"),
    source: "webOtp",
    status: params.status,
    linkedUid: params.uid,
    phoneE164: params.phone,
    email: null,
    externalReference: null,
    ticketType: null,
    importId: null,
    sourceRowId: null,
    createdAt: params.now,
    updatedAt: params.now,
    registeredAt: params.status === "registered" ? params.now : null,
    waitlistedAt: null,
    checkedInAt: null,
    cancelledAt: null,
    checkedInBy: null,
    linkedAt: params.uid ? params.now : null,
    inviteLinkId: params.inviteLinkId,
    inviteCapturedAt: params.inviteLinkId ? params.now : null,
    attendanceRevision: 0,
    preCheckInStatus: null,
  };
}

function runtimeProfileResponse(
  profile: RuntimeProfile
): NonNullable<
  GetEventRuntimeBootstrapCallableResponse["participant"]
>["runtimeProfile"] {
  return {
    displayName: profile.displayName,
    gender: profile.gender,
    interestedInGenders: profile.interestedInGenders,
    relationshipGoal: profile.relationshipGoal,
    dateOfBirthMillis: profile.dateOfBirth?.toMillis() ?? null,
  };
}

function claimResponse(
  participant: EventRuntimeParticipantDocument
): ClaimEventRuntimeAccessCallableResponse {
  const status = participant.accessStatus;
  if (status !== "pendingApproval" &&
      status !== "needsInput" &&
      status !== "ready") {
    throw new HttpsError(
      "failed-precondition",
      "This runtime claim is no longer active."
    );
  }
  return {
    status,
    attendeeId: participant.eventAttendeeId,
    requiredFieldIds: participant.requiredFieldIds,
    completedFieldIds: participant.completedFieldIds,
  };
}

function isSensitiveRuntimeField(field: RuntimeFieldId): boolean {
  return field !== "displayName";
}

function normalizeRuntimeIdPayload(data: unknown): unknown {
  return normalizeStringFields(data, ["publicRuntimeId"]);
}

function normalizeClaimPayload(data: unknown): unknown {
  return normalizeStringFields(data, [
    "publicRuntimeId",
    "displayName",
    "runtimeTermsVersion",
    "attendeeToken",
    "inviteToken",
  ]);
}

function normalizeProfilePayload(data: unknown): unknown {
  const normalized = normalizeStringFields(data, [
    "publicRuntimeId",
    "runtimeTermsVersion",
    "sensitiveDataTermsVersion",
  ]);
  if (!isRecord(normalized)) return normalized;
  if (isRecord(normalized.fields)) {
    normalized.fields = normalizeStringFields(normalized.fields, [
      "displayName",
    ]);
  }
  return normalized;
}

function normalizeApprovalPayload(data: unknown): unknown {
  return normalizeStringFields(data, [
    "eventId",
    "uid",
    "attendeeId",
    "reason",
  ]);
}

function normalizeStringFields(
  data: unknown,
  fields: string[]
): unknown {
  if (!isRecord(data)) return data;
  const normalized = {...data};
  for (const field of fields) {
    if (typeof normalized[field] === "string") {
      normalized[field] = normalized[field].trim().replace(
        field === "displayName" ? /\s+/g : /$^/,
        field === "displayName" ? " " : ""
      );
    }
  }
  return normalized;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function sha256(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

export const getEventRuntimeBootstrap = onCall(
  appCheckCallableOptions,
  (request) => getEventRuntimeBootstrapHandler(request)
);

export const claimEventRuntimeAccess = onCall(
  appCheckCallableOptions,
  (request) => claimEventRuntimeAccessHandler(request)
);

export const submitEventRuntimeProfile = onCall(
  appCheckCallableOptions,
  (request) => submitEventRuntimeProfileHandler(request)
);

export const checkInEventRuntime = onCall(
  appCheckCallableOptions,
  (request) => checkInEventRuntimeHandler(request)
);

export const approveEventRuntimeClaim = onCall(
  appCheckCallableOptions,
  (request) => approveEventRuntimeClaimHandler(request)
);
