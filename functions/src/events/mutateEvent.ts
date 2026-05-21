import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  appCheckCallableOptions,
  appCheckCallableOptionsWithSecrets,
} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {
  PaymentDoc,
  ClubDoc,
  EventDoc,
  EventConstraints,
  EventFormatSnapshot,
} from "../shared/firestore";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {CancelEventCallablePayload} from
  "../shared/generated/cancelEventCallablePayload";
import {CreateEventCallablePayload} from
  "../shared/generated/createEventCallablePayload";
import {DeleteEventCallablePayload} from
  "../shared/generated/deleteEventCallablePayload";
import {
  validateCancelEventCallablePayload,
  validateCreateEventCallablePayload,
  validateDeleteEventCallablePayload,
  validateUpdateEventCallablePayload,
} from "../shared/generated/schemaValidators";
import {UpdateEventCallablePayload} from
  "../shared/generated/updateEventCallablePayload";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {
  allowsPushPreference,
  activityNotificationId,
  eventActivityNotificationCopy,
  sendFcmNotification,
  setActivityNotification,
} from "../shared/notifications";
import {
  eventParticipationsByStatusInTransaction,
} from "../shared/relationshipDocuments";
import {
  assertValidEventTimeRange,
  claimClubScheduleInTransaction,
  releaseClubScheduleInTransaction,
  releaseUserEventScheduleInTransaction,
  replaceClubScheduleInTransaction,
} from "./scheduleConflicts";
import {refreshClubNextEvent as defaultRefreshClubNextEvent} from
  "../clubs/syncClubNextEvent";
import {
  normalizeCancelEventPayload,
  normalizeCreateEventPayload,
  normalizeEventIdPayload,
  normalizeUpdateEventPayload,
} from "./eventPayloadNormalization";
import {
  EventPolicyBundleDoc,
  normalizeInviteCode,
  normalizePolicy,
} from "./eventPolicy";
import {isClubHost} from "../shared/clubHosts";
import {
  createRazorpayClient,
  razorpayKeyId,
  razorpayKeySecret,
} from "../payments/razorpay";

interface EventMutationDeps {
  firestore: () => FirebaseFirestore.Firestore;
  timestampFromMillis: (millis: number) => FirebaseFirestore.Timestamp;
  serverTimestamp?: () => FirebaseFirestore.FieldValue;
  sendNotification?: typeof sendFcmNotification;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
  refreshClubNextEvent?: (
    clubId: string,
    deps?: {
      firestore: () => FirebaseFirestore.Firestore;
      nowTimestamp: () => FirebaseFirestore.Timestamp;
    }
  ) => Promise<void>;
  refundPayment?: (paymentId: string, amount: number) => Promise<void>;
}

type ParsedEventConstraints = NonNullable<
  CreateEventCallablePayload["constraints"]
>;
type EventSuccessDefaultsPayload = NonNullable<
  CreateEventCallablePayload["eventSuccessDefaults"]
>;
type EventSuccessStructureConfigPayload = NonNullable<
  EventSuccessDefaultsPayload["structureConfig"]
>;
type CreateEventPayloadWithPolicy = CreateEventCallablePayload & {
  eventPolicy?: EventPolicyBundleDoc;
  eventFormat?: EventFormatSnapshot;
  privateAccess?: {
    inviteCode?: string | null;
  };
};
type EventHostUpdateFields = UpdateEventCallablePayload["fields"];

type NotificationUserDoc = {
  fcmToken?: string;
  prefsEventReminders?: boolean;
  prefsRunStatusUpdates?: boolean;
  prefsClubUpdates?: boolean;
};

type ClubMembershipNotificationDoc = {
  uid?: string;
  pushNotificationsEnabled?: boolean;
};

const defaultDeps: EventMutationDeps = {
  firestore: () => admin.firestore(),
  timestampFromMillis: (millis) =>
    admin.firestore.Timestamp.fromMillis(millis),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  sendNotification: sendFcmNotification,
  checkRateLimit: defaultCheckRateLimit,
  refreshClubNextEvent: defaultRefreshClubNextEvent,
  refundPayment: async (paymentId, amount) => {
    await createRazorpayClient().payments.refund(paymentId, {amount});
  },
};

/**
 * Creates an event for a club hosted by the signed-in user.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {EventMutationDeps} deps Injectable dependencies for tests.
 * @return {Promise<{eventId: string}>} Created event id.
 */
export async function createEventHandler(
  request: CallableRequest<unknown>,
  deps: EventMutationDeps = defaultDeps
): Promise<{eventId: string}> {
  const hostUserId = requireAuth(request);
  const data = validateCallableWithAjv<CreateEventCallablePayload>(
    request,
    validateCreateEventCallablePayload,
    normalizeCreateEventPayload
  );
  assertValidEventTimeRange(data.startTimeMillis, data.endTimeMillis);
  assertValidEventConstraints(data.constraints);

  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "createEvent");

  const eventRef = data.eventId ?
    db.collection("events").doc(data.eventId) :
    db.collection("events").doc();
  const privateAccessRef = db.collection("eventPrivateAccess").doc(eventRef.id);
  const eventSuccessPlanRef = db
    .collection("eventSuccessPlans")
    .doc(eventRef.id);
  const clubRef = db.collection("clubs").doc(data.clubId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);

  let createdEvent: EventDoc | null = null;
  let clubName = "Your club";

  await db.runTransaction(async (tx) => {
    const [eventSnap, clubSnap, deletedUserSnap] = await Promise.all([
      tx.get(eventRef),
      tx.get(clubRef),
      tx.get(deletedUserRef),
    ]);

    if (eventSnap.exists) {
      throw new HttpsError("already-exists", "Event already exists.");
    }
    assertCanMutateClub(clubSnap, deletedUserSnap, hostUserId);
    const club = requireDoc<ClubDoc>(clubSnap, "ClubDoc");
    clubName = club.name;
    const event = {
      ...buildCreateEventDoc(data, deps),
      clubId: data.clubId,
      bookedCount: 0,
      checkedInCount: 0,
      waitlistedCount: 0,
      status: "active" as const,
      cancelledAt: null,
      cancellationReason: null,
      genderCounts: {},
    };
    const eventPolicy = event.eventPolicy;
    if (!eventPolicy) {
      throw new HttpsError("internal", "Event policy was not normalized.");
    }
    const inviteCode = normalizedInviteCodeForCreate(data, eventPolicy);
    const eventSuccessPlan = buildCreateEventSuccessPlanDoc({
      data,
      eventId: eventRef.id,
      event,
      serverTimestamp: deps.serverTimestamp,
    });
    const [privateAccessSnap, eventSuccessPlanSnap] = await Promise.all([
      tx.get(privateAccessRef),
      eventSuccessPlan ? tx.get(eventSuccessPlanRef) : Promise.resolve(null),
    ]);
    if (privateAccessSnap.exists) {
      throw new HttpsError(
        "already-exists",
        "Event private access already exists."
      );
    }
    if (eventSuccessPlanSnap?.exists) {
      throw new HttpsError(
        "already-exists",
        "Event success plan already exists."
      );
    }

    await claimClubScheduleInTransaction(tx, db, {
      clubId: data.clubId,
      eventId: eventRef.id,
      startTimeMillis: data.startTimeMillis,
      endTimeMillis: data.endTimeMillis,
    });
    tx.create(eventRef, event);
    if (inviteCode) {
      tx.create(privateAccessRef, {
        eventId: eventRef.id,
        clubId: data.clubId,
        inviteCode,
        createdAt: deps.serverTimestamp?.() ??
          admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    if (eventSuccessPlan) {
      tx.create(eventSuccessPlanRef, eventSuccessPlan);
    }
    createdEvent = event;
  });

  if (createdEvent) {
    await deps.refreshClubNextEvent?.(data.clubId, {
      firestore: deps.firestore,
      nowTimestamp: () => admin.firestore.Timestamp.now(),
    });
    await notifyClubMembersForNewEvent({
      db,
      deps,
      eventId: eventRef.id,
      clubId: data.clubId,
      hostUserId,
      clubName,
      event: createdEvent,
    });
  }

  return {eventId: eventRef.id};
}

/**
 * Updates host-editable schedule/descriptive fields for an event.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {EventMutationDeps} deps Injectable dependencies for tests.
 * @return {Promise<{updated: boolean}>} Whether the update completed.
 */
export async function updateEventHandler(
  request: CallableRequest<unknown>,
  deps: EventMutationDeps = defaultDeps
): Promise<{updated: boolean}> {
  const hostUserId = requireAuth(request);
  const data = validateCallableWithAjv<UpdateEventCallablePayload>(
    request,
    validateUpdateEventCallablePayload,
    normalizeUpdateEventPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "updateEvent");

  const eventRef = db.collection("events").doc(data.eventId);
  const privateAccessRef = db
    .collection("eventPrivateAccess")
    .doc(data.eventId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);
  let updatedEvent: EventDoc | null = null;
  let affectedClubId: string | null = null;
  let shouldNotifyParticipants = false;

  await db.runTransaction(async (tx) => {
    const [eventSnap, deletedUserSnap] = await Promise.all([
      tx.get(eventRef),
      tx.get(deletedUserRef),
    ]);

    if (!eventSnap.exists) {
      throw new HttpsError("not-found", "Event not found.");
    }

    const event = requireDoc<EventDoc>(eventSnap, "EventDoc");
    if (event.status === "cancelled") {
      throw new HttpsError(
        "failed-precondition",
        "Cancelled events cannot be edited."
      );
    }
    const clubRef = db.collection("clubs").doc(event.clubId);
    const [clubSnap, activeParticipations, privateAccessSnap] =
      await Promise.all([
        tx.get(clubRef),
        eventParticipationsByStatusInTransaction(tx, db, data.eventId, [
          "signedUp",
          "waitlisted",
          "attended",
        ]),
        tx.get(privateAccessRef),
      ]);
    assertCanMutateClub(clubSnap, deletedUserSnap, hostUserId);
    assertValidMergedRunUpdate(event, data.fields);
    assertValidEventConstraints(data.fields.constraints);
    if (hasScheduleTimeChange(data.fields) && activeParticipations.length > 0) {
      throw new HttpsError(
        "failed-precondition",
        "Events with participants or waitlisted users cannot be rescheduled."
      );
    }
    if (hasPolicyChange(data.fields) && activeParticipations.length > 0) {
      throw new HttpsError(
        "failed-precondition",
        "Events with participants or waitlisted users cannot change policy."
      );
    }

    const patch = buildUpdateEventPatch(data.fields, deps);
    const nextPolicy = patch.eventPolicy ?? event.eventPolicy ?? null;
    if (hasScheduleTimeChange(data.fields)) {
      await replaceClubScheduleInTransaction(tx, db, {
        clubId: event.clubId,
        eventId: data.eventId,
        previousStartTimeMillis: event.startTime.toMillis(),
        previousEndTimeMillis: event.endTime.toMillis(),
        startTimeMillis: fieldsStartTimeMillis(event, data.fields),
        endTimeMillis: fieldsEndTimeMillis(event, data.fields),
      });
    }
    tx.update(eventRef, patch);
    if (hasPolicyChange(data.fields) && nextPolicy) {
      syncPrivateAccessForPolicyUpdate({
        tx,
        privateAccessRef,
        privateAccessSnap,
        eventId: data.eventId,
        clubId: event.clubId,
        fields: data.fields,
        eventPolicy: nextPolicy,
        serverTimestamp: deps.serverTimestamp,
      });
    }
    updatedEvent = {...event, ...patch};
    affectedClubId = event.clubId;
    shouldNotifyParticipants = hasScheduleOrLocationChange(data.fields);
  });

  if (updatedEvent && shouldNotifyParticipants) {
    await notifyEventParticipants({
      db,
      deps,
      eventId: data.eventId,
      event: updatedEvent,
      type: "eventUpdated",
    });
  }
  if (affectedClubId) {
    await deps.refreshClubNextEvent?.(affectedClubId, {
      firestore: deps.firestore,
      nowTimestamp: () => admin.firestore.Timestamp.now(),
    });
  }

  return {updated: true};
}

/**
 * Cancels an event and notifies signed-up/waitlisted participants.
 *
 * This callable intentionally does not implement refund policy or expose a
 * host UI contract yet. It creates the backend state and notification path so
 * the product policy can be backfilled without client-owned multi-doc writes.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {EventMutationDeps} deps Injectable dependencies for tests.
 * @return {Promise<{cancelled: boolean}>} Whether the event is cancelled.
 */
export async function cancelEventHandler(
  request: CallableRequest<unknown>,
  deps: EventMutationDeps = defaultDeps
): Promise<{cancelled: boolean}> {
  const hostUserId = requireAuth(request);
  const data = validateCallableWithAjv<CancelEventCallablePayload>(
    request,
    validateCancelEventCallablePayload,
    normalizeCancelEventPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "cancelEvent");

  const eventRef = db.collection("events").doc(data.eventId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);
  let cancelledEvent: EventDoc | null = null;
  let affectedClubId: string | null = null;
  let shouldNotifyParticipants = false;

  await db.runTransaction(async (tx) => {
    const [eventSnap, deletedUserSnap] = await Promise.all([
      tx.get(eventRef),
      tx.get(deletedUserRef),
    ]);

    if (!eventSnap.exists) {
      throw new HttpsError("not-found", "Event not found.");
    }

    const event = requireDoc<EventDoc>(eventSnap, "EventDoc");
    const clubRef = db.collection("clubs").doc(event.clubId);
    const [clubSnap, participantEdges] = await Promise.all([
      tx.get(clubRef),
      eventParticipationsByStatusInTransaction(tx, db, data.eventId, [
        "signedUp",
        "waitlisted",
      ]),
    ]);
    assertCanMutateClub(clubSnap, deletedUserSnap, hostUserId);

    if (event.status === "cancelled") {
      cancelledEvent = event;
      affectedClubId = event.clubId;
      return;
    }

    const cancelledAt = deps.serverTimestamp?.() ??
      admin.firestore.FieldValue.serverTimestamp();
    tx.update(eventRef, {
      status: "cancelled",
      cancelledAt,
      cancellationReason: data.reason ?? null,
    });
    releaseClubScheduleInTransaction(tx, db, {
      clubId: event.clubId,
      eventId: data.eventId,
      startTimeMillis: event.startTime.toMillis(),
      endTimeMillis: event.endTime.toMillis(),
    });
    for (const edge of participantEdges) {
      releaseUserEventScheduleInTransaction(tx, db, {
        uid: edge.data.uid,
        eventId: data.eventId,
        startTimeMillis: event.startTime.toMillis(),
        endTimeMillis: event.endTime.toMillis(),
      });
    }
    cancelledEvent = {
      ...event,
      status: "cancelled",
      cancelledAt: event.cancelledAt,
      cancellationReason: data.reason ?? null,
    };
    affectedClubId = event.clubId;
    shouldNotifyParticipants = true;
  });

  if (cancelledEvent && shouldNotifyParticipants) {
    await refundCompletedPaymentsForCancelledEvent(db, deps, data.eventId);
    await notifyEventParticipants({
      db,
      deps,
      eventId: data.eventId,
      event: cancelledEvent,
      type: "eventCancelled",
    });
  }
  if (affectedClubId) {
    await deps.refreshClubNextEvent?.(affectedClubId, {
      firestore: deps.firestore,
      nowTimestamp: () => admin.firestore.Timestamp.now(),
    });
  }

  return {cancelled: true};
}

/**
 * Refunds completed attendee payments after a host/platform cancellation.
 *
 * Host payout is not modeled as a remitted transfer in this codebase yet; the
 * important invariant here is that attendee money is returned before any future
 * host-settlement process can consider the event payable.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {EventMutationDeps} deps Injectable dependencies.
 * @param {string} eventId Cancelled event id.
 */
async function refundCompletedPaymentsForCancelledEvent(
  db: FirebaseFirestore.Firestore,
  deps: EventMutationDeps,
  eventId: string
) {
  const payments = await db
    .collection("payments")
    .where("eventId", "==", eventId)
    .where("status", "==", "completed")
    .get();

  await Promise.all(payments.docs.map(async (paymentDoc) => {
    const payment = requireDoc<PaymentDoc>(paymentDoc, "PaymentDoc");
    try {
      await deps.refundPayment?.(payment.paymentId, payment.amount);
      await paymentDoc.ref.update({status: "refunded"});
    } catch (error) {
      logger.error("Host cancellation refund failed", {
        eventId,
        paymentId: payment.paymentId,
        error,
      });
    }
  }));
}

/**
 * Hard-deletes an unused event.
 *
 * Events with any user activity are cancelled, not deleted, so payments,
 * notifications, reviews, and attendance history keep a stable audit trail.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {EventMutationDeps} deps Injectable dependencies for tests.
 * @return {Promise<{deleted: boolean}>} Whether the event was deleted.
 */
export async function deleteEventHandler(
  request: CallableRequest<unknown>,
  deps: EventMutationDeps = defaultDeps
): Promise<{deleted: boolean}> {
  const hostUserId = requireAuth(request);
  const data = validateCallableWithAjv<DeleteEventCallablePayload>(
    request,
    validateDeleteEventCallablePayload,
    normalizeEventIdPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "deleteEvent");

  const eventRef = db.collection("events").doc(data.eventId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);
  let deletedClubId: string | null = null;

  await db.runTransaction(async (tx) => {
    const eventSnap = await tx.get(eventRef);
    if (!eventSnap.exists) {
      throw new HttpsError("not-found", "Event not found.");
    }

    const event = requireDoc<EventDoc>(eventSnap, "EventDoc");
    const clubRef = db.collection("clubs").doc(event.clubId);
    const [
      clubSnap,
      deletedUserSnap,
      participationSnap,
      paymentSnap,
      reviewSnap,
    ] = await Promise.all([
      tx.get(clubRef),
      tx.get(deletedUserRef),
      tx.get(db.collection("eventParticipations")
        .where("eventId", "==", data.eventId)
        .limit(1)),
      tx.get(db.collection("payments")
        .where("eventId", "==", data.eventId)
        .limit(1)),
      tx.get(db.collection("reviews")
        .where("eventId", "==", data.eventId)
        .limit(1)),
    ]);

    assertCanMutateClub(clubSnap, deletedUserSnap, hostUserId);
    if (
      !participationSnap.empty ||
      !paymentSnap.empty ||
      !reviewSnap.empty
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Events with participants, payments, or reviews must be cancelled."
      );
    }

    tx.delete(eventRef);
    deletedClubId = event.clubId;
    releaseClubScheduleInTransaction(tx, db, {
      clubId: event.clubId,
      eventId: data.eventId,
      startTimeMillis: event.startTime.toMillis(),
      endTimeMillis: event.endTime.toMillis(),
    });
  });

  if (deletedClubId) {
    await deps.refreshClubNextEvent?.(deletedClubId, {
      firestore: deps.firestore,
      nowTimestamp: () => admin.firestore.Timestamp.now(),
    });
  }

  return {deleted: true};
}

/**
 * Builds the immutable initial event document controlled by the create
 * callable.
 * @param {CreateEventCallablePayload} data Validated callable data.
 * @param {EventMutationDeps} deps Injectable dependencies.
 * @return {object} Event fields except ownership/booking aggregates.
 */
function buildCreateEventDoc(
  data: CreateEventCallablePayload,
  deps: EventMutationDeps
): Omit<EventDoc, "clubId" | "genderCounts" |
  "status" | "cancelledAt" | "cancellationReason"> {
  const maxMen = data.constraints?.maxMen;
  const maxWomen = data.constraints?.maxWomen;
  const hasLegacyCaps = maxMen != null || maxWomen != null;
  const eventPolicy = normalizePolicy(
    (data as CreateEventPayloadWithPolicy).eventPolicy ?? {
      version: 1,
      admission: {
        format: hasLegacyCaps ? "fixedCohortCaps" : "open",
        capacityLimit: data.capacityLimit,
        waitlistPolicy: {mode: "rankedOffer", offerWindowMinutes: 20},
        inviteRequired: false,
        membershipRequired: false,
        manualApprovalRequired: false,
        privateAccessPolicy: {
          mode: "none",
          inviteCodeHint: null,
          privateLinkEnabled: false,
        },
        cohortCapacityLimits: {
          ...(maxMen != null ? {menInterestedInWomen: maxMen} : {}),
          ...(maxWomen != null ? {womenInterestedInMen: maxWomen} : {}),
        },
      },
      pricing: {
        basePriceInPaise: data.priceInPaise,
      },
      cancellation: {policyId: "standard"},
      settlement: {hostPayoutTiming: "afterEventCompletion"},
    }
  );
  return {
    startTime: deps.timestampFromMillis(data.startTimeMillis),
    endTime: deps.timestampFromMillis(data.endTimeMillis),
    meetingPoint: data.meetingPoint,
    startingPointLat: data.startingPointLat,
    startingPointLng: data.startingPointLng,
    locationDetails: data.locationDetails ?? null,
    photoUrl: data.photoUrl ?? null,
    eventFormat: normalizeEventFormat(
      (data as CreateEventPayloadWithPolicy).eventFormat
    ),
    distanceKm: data.distanceKm,
    pace: data.pace,
    capacityLimit: eventPolicy.admission.capacityLimit,
    description: data.description,
    priceInPaise: eventPolicy.pricing.basePriceInPaise,
    currency: data.currency ?? "INR",
    constraints: normalizeConstraints(data.constraints),
    eventPolicy,
    cohortCounts: {},
    waitlistedCohortCounts: {},
  };
}

/**
 * Builds the optional initial event-success plan owned by createEvent.
 * @param {object} params Source event and callable payload.
 * @return {object|null} Firestore plan doc, or null when disabled.
 */
function buildCreateEventSuccessPlanDoc(params: {
  data: CreateEventCallablePayload;
  eventId: string;
  event: EventDoc;
  serverTimestamp?: () => FirebaseFirestore.FieldValue;
}): Record<string, unknown> | null {
  const defaults = params.data.eventSuccessDefaults;
  if (!defaults?.enabled) return null;

  const timestamp = params.serverTimestamp?.() ??
    admin.firestore.FieldValue.serverTimestamp();
  const eventFormat = params.event.eventFormat;
  const activityKind = eventFormat.activityKind;
  const interactionModel = eventFormat.interactionModel;
  const targetAttendeeCount = clampInteger(
    params.event.capacityLimit,
    1,
    1000,
    20
  );
  const playbookId =
    normalizeString(defaults.playbookId) ??
    normalizeString(eventFormat.defaultPlaybookId) ??
    defaultEventSuccessPlaybookIdFor(activityKind);
  const selectedModuleIds = stableStringList(
    defaults.selectedModuleIds,
    24,
    defaultEventSuccessModuleIdsFor(interactionModel, activityKind)
  );

  return {
    eventId: params.eventId,
    clubId: params.data.clubId,
    playbookId,
    selectedModuleIds,
    targetAttendeeCount,
    structureConfig: normalizeEventSuccessStructureConfig(
      defaults.structureConfig,
      interactionModel,
      targetAttendeeCount
    ),
    hostGoal:
      normalizeString(defaults.hostGoal) ??
      "Help attendees meet at least two new people.",
    wingmanRequestsEnabled: defaults.wingmanRequestsEnabled ?? true,
    contextualOpenersEnabled: defaults.contextualOpenersEnabled ?? true,
    compatibilityAffectsRanking:
      defaults.compatibilityAffectsRanking ?? activityKind === "singlesMixer",
    questionnaireConfig: normalizeEventSuccessQuestionnaireConfig(
      defaults.questionnaireConfig
    ),
    activeStepIndex: 0,
    status: "setup",
    revealStatus: "idle",
    activeRevealRoundIndex: 0,
    revealStartedAt: null,
    revealEndsAt: null,
    attendeePrompt: normalizeNullableString(defaults.attendeePrompt),
    createdAt: timestamp,
    updatedAt: timestamp,
    frozenAt: null,
    completedAt: null,
  };
}

/**
 * Returns a valid event-success structure for the event format.
 * @param {object=} raw Optional client defaults.
 * @param {string} interactionModel Event interaction model.
 * @param {number} targetAttendeeCount Capacity used for whole-group formats.
 * @return {object} Persistable structure config.
 */
function normalizeEventSuccessStructureConfig(
  raw: EventSuccessStructureConfigPayload | undefined,
  interactionModel: EventFormatSnapshot["interactionModel"],
  targetAttendeeCount: number
) {
  const fallback = defaultEventSuccessStructureConfigFor(
    interactionModel,
    targetAttendeeCount
  );
  return {
    unitKind: raw?.unitKind ?? fallback.unitKind,
    unitSize: raw?.unitSize ?? fallback.unitSize,
    unitCount: raw?.unitCount ?? fallback.unitCount,
    rotationIntervalMinutes:
      raw?.rotationIntervalMinutes ?? fallback.rotationIntervalMinutes,
    revealCountdownSeconds:
      raw?.revealCountdownSeconds ?? fallback.revealCountdownSeconds,
  };
}

/**
 * Returns a valid questionnaire config from optional defaults.
 * @param {object=} raw Optional questionnaire config.
 * @return {object} Persistable questionnaire config.
 */
function normalizeEventSuccessQuestionnaireConfig(
  raw: EventSuccessDefaultsPayload["questionnaireConfig"] | undefined
) {
  return {
    templateId: normalizeString(raw?.templateId) ?? "balanced",
    ...(raw?.customTitle !== undefined ?
      {customTitle: normalizeNullableString(raw.customTitle)} :
      {}),
    ...(raw?.customQuestions !== undefined ?
      {customQuestions: raw.customQuestions} :
      {}),
  };
}

/**
 * Returns a stable unique string list, falling back when empty.
 * @param {string[] | undefined} values Candidate strings.
 * @param {number} maxItems Maximum number of returned strings.
 * @param {string[]} fallback Fallback values when candidates are empty.
 * @return {string[]} Stable unique strings.
 */
function stableStringList(
  values: string[] | undefined,
  maxItems: number,
  fallback: string[]
): string[] {
  const normalized = (values ?? [])
    .map((value) => normalizeString(value))
    .filter((value): value is string => value !== null);
  const source = normalized.length > 0 ? normalized : fallback;
  return [...new Set(source)].sort().slice(0, maxItems);
}

/**
 * Trims a string and returns null when blank.
 * @param {unknown} value Raw value.
 * @return {string|null} Normalized string.
 */
function normalizeString(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const normalized = value.trim();
  return normalized.length === 0 ? null : normalized;
}

/**
 * Trims a nullable string and preserves explicit null for Firestore.
 * @param {unknown} value Raw value.
 * @return {string|null} Normalized nullable string.
 */
function normalizeNullableString(value: unknown): string | null {
  return normalizeString(value);
}

/**
 * Clamps an integer-like value into a valid range.
 * @param {unknown} value Raw value.
 * @param {number} min Minimum value.
 * @param {number} max Maximum value.
 * @param {number} fallback Fallback when not finite.
 * @return {number} Clamped integer.
 */
function clampInteger(
  value: unknown,
  min: number,
  max: number,
  fallback: number
): number {
  if (typeof value !== "number" || !Number.isFinite(value)) return fallback;
  return Math.min(max, Math.max(min, Math.round(value)));
}

/**
 * Maps event activity to a default event-success playbook.
 * @param {string} activityKind Activity kind.
 * @return {string} Playbook id.
 */
function defaultEventSuccessPlaybookIdFor(
  activityKind: EventFormatSnapshot["activityKind"]
): string {
  switch (activityKind) {
  case "pickleball":
  case "padel":
  case "tennis":
  case "badminton":
    return "pickleball_rotations";
  case "pubQuiz":
    return "pub_quiz_team_mixer";
  case "dinner":
    return "dinner_table_mixer";
  case "singlesMixer":
    return "algorithmic_mixer_reveal";
  case "barCrawl":
  case "openActivity":
    return "host_led_social";
  default:
    return "social_run_light";
  }
}

/**
 * Returns default module ids for an event format.
 * @param {string} interactionModel Event interaction model.
 * @param {string} activityKind Activity kind.
 * @return {string[]} Default module ids.
 */
function defaultEventSuccessModuleIdsFor(
  interactionModel: EventFormatSnapshot["interactionModel"],
  activityKind: EventFormatSnapshot["activityKind"]
): string[] {
  const base = [
    "qr_check_in",
    "host_script",
    "social_missions",
    "wingman_requests",
    "contextual_openers",
    "decomposed_feedback",
    "host_analytics",
    "safety_controls",
  ];
  switch (interactionModel) {
  case "pacePods":
    return [...base, "micro_pods"];
  case "pairedRotations":
    return [...base, "guided_rotations", "live_reveal"];
  case "teamRotations":
    return [...base, "micro_pods", "live_reveal"];
  case "freeFormMixer":
    return activityKind === "singlesMixer" ?
      [...base, "guided_rotations", "live_reveal",
        "compatibility_questionnaire"] :
      [...base, "guided_rotations", "live_reveal"];
  default:
    return base;
  }
}

/**
 * Returns default event-success structure for an event format.
 * @param {string} interactionModel Event interaction model.
 * @param {number} targetAttendeeCount Event target size.
 * @return {object} Structure config.
 */
function defaultEventSuccessStructureConfigFor(
  interactionModel: EventFormatSnapshot["interactionModel"],
  targetAttendeeCount: number
): EventSuccessStructureConfigPayload {
  switch (interactionModel) {
  case "pairedRotations":
  case "freeFormMixer":
    return {
      unitKind: "pairs",
      unitSize: 2,
      unitCount: null,
      rotationIntervalMinutes: 15,
      revealCountdownSeconds: 10,
    };
  case "teamRotations":
    return {
      unitKind: "teams",
      unitSize: 5,
      unitCount: 3,
      rotationIntervalMinutes: null,
      revealCountdownSeconds: 10,
    };
  case "seatedTable":
    return {
      unitKind: "tables",
      unitSize: 4,
      unitCount: null,
      rotationIntervalMinutes: 30,
      revealCountdownSeconds: 10,
    };
  case "pacePods":
  case "hostLedProgram":
  case "openFormat":
  default:
    return {
      unitKind: "wholeGroup",
      unitSize: targetAttendeeCount,
      unitCount: 1,
      rotationIntervalMinutes: null,
      revealCountdownSeconds: 10,
    };
  }
}

/**
 * Validates and returns invite-only access material for the host-private doc.
 * @param {CreateEventCallablePayload} data Validated create payload.
 * @param {EventPolicyBundleDoc} eventPolicy Normalized public policy snapshot.
 * @return {string|null} Invite code to store in eventPrivateAccess/{eventId}.
 */
function normalizedInviteCodeForCreate(
  data: CreateEventCallablePayload,
  eventPolicy: EventPolicyBundleDoc
): string | null {
  if (!eventPolicy.admission.inviteRequired) return null;

  const inviteCode = normalizeInviteCode(
    (data as CreateEventPayloadWithPolicy).privateAccess?.inviteCode
  );
  if (!inviteCode || inviteCode.length < 4 || inviteCode.length > 64) {
    throw new HttpsError(
      "invalid-argument",
      "Invite-only events need an invite code between 4 and 64 characters."
    );
  }
  return inviteCode;
}

/**
 * Normalizes the optional event-format snapshot on create.
 * @param {EventFormatSnapshot | null | undefined} raw Client payload snapshot.
 * @return {EventFormatSnapshot} Persistable event-format snapshot.
 */
function normalizeEventFormat(
  raw?: EventFormatSnapshot | null
): EventFormatSnapshot {
  const activityKind = raw?.activityKind ?? "socialRun";
  return {
    version: 1,
    activityKind,
    interactionModel:
      raw?.interactionModel ?? defaultInteractionModelFor(activityKind),
    ...(raw?.customActivityLabel != null ?
      {customActivityLabel: raw.customActivityLabel} : {}),
    ...(raw?.defaultPlaybookId != null ?
      {defaultPlaybookId: raw.defaultPlaybookId} : {}),
    ...(raw?.defaultModuleIds != null && raw.defaultModuleIds.length > 0 ?
      {defaultModuleIds: raw.defaultModuleIds} : {}),
    ...(raw?.activityDetails != null ?
      {activityDetails: raw.activityDetails} : {}),
  };
}

/**
 * Returns the default interaction model for a known activity kind.
 * @param {string} activityKind Activity kind.
 * @return {string} Interaction model.
 */
function defaultInteractionModelFor(
  activityKind: EventFormatSnapshot["activityKind"]
): EventFormatSnapshot["interactionModel"] {
  switch (activityKind) {
  case "socialRun":
    return "pacePods";
  case "pickleball":
  case "padel":
  case "tennis":
  case "badminton":
    return "pairedRotations";
  case "pubQuiz":
    return "teamRotations";
  case "dinner":
    return "seatedTable";
  case "barCrawl":
  case "singlesMixer":
    return "freeFormMixer";
  case "openActivity":
    return "openFormat";
  default:
    return "hostLedProgram";
  }
}

/**
 * Converts host-editable callable fields into Firestore update fields.
 * @param {object} fields Update fields.
 * @param {EventMutationDeps} deps Injectable dependencies.
 * @return {Partial<EventDoc>} Firestore update patch.
 */
function buildUpdateEventPatch(
  fields: EventHostUpdateFields,
  deps: EventMutationDeps
): Partial<EventDoc> {
  const patch: Partial<EventDoc> = {};
  if (fields.startTimeMillis !== undefined) {
    patch.startTime = deps.timestampFromMillis(fields.startTimeMillis);
  }
  if (fields.endTimeMillis !== undefined) {
    patch.endTime = deps.timestampFromMillis(fields.endTimeMillis);
  }
  if (fields.meetingPoint !== undefined) {
    patch.meetingPoint = fields.meetingPoint;
  }
  if (fields.startingPointLat !== undefined) {
    patch.startingPointLat = fields.startingPointLat;
  }
  if (fields.startingPointLng !== undefined) {
    patch.startingPointLng = fields.startingPointLng;
  }
  if (fields.locationDetails !== undefined) {
    patch.locationDetails = fields.locationDetails;
  }
  if (fields.photoUrl !== undefined) patch.photoUrl = fields.photoUrl;
  if (fields.distanceKm !== undefined) patch.distanceKm = fields.distanceKm;
  if (fields.pace !== undefined) patch.pace = fields.pace;
  if (fields.description !== undefined) patch.description = fields.description;
  if (fields.constraints !== undefined) {
    patch.constraints = normalizeConstraints(fields.constraints);
  }
  if (fields.eventPolicy !== undefined) {
    const eventPolicy = normalizePolicy(fields.eventPolicy);
    patch.eventPolicy = eventPolicy;
    patch.capacityLimit = eventPolicy.admission.capacityLimit;
    patch.priceInPaise = eventPolicy.pricing.basePriceInPaise;
  } else {
    if (fields.capacityLimit !== undefined) {
      patch.capacityLimit = fields.capacityLimit;
    }
    if (fields.priceInPaise !== undefined) {
      patch.priceInPaise = fields.priceInPaise;
    }
  }
  return patch;
}

/**
 * Returns true when an update changes when/where participants show up.
 * @param {object} fields Host update fields.
 * @return {boolean} Whether participants should be notified.
 */
function hasScheduleOrLocationChange(
  fields: EventHostUpdateFields
): boolean {
  return fields.startTimeMillis !== undefined ||
    fields.endTimeMillis !== undefined ||
    fields.meetingPoint !== undefined ||
    fields.startingPointLat !== undefined ||
    fields.startingPointLng !== undefined ||
    fields.locationDetails !== undefined;
}

/**
 * Returns true when the event's time window changes, not merely its location.
 * @param {object} fields Host update fields.
 * @return {boolean} Whether time locks must be replaced.
 */
function hasScheduleTimeChange(
  fields: EventHostUpdateFields
): boolean {
  return fields.startTimeMillis !== undefined ||
    fields.endTimeMillis !== undefined;
}

/**
 * Returns true when an update touches booking policy or private invite state.
 * @param {object} fields Host update fields.
 * @return {boolean} Whether participant-free policy guards should run.
 */
function hasPolicyChange(fields: EventHostUpdateFields): boolean {
  return fields.capacityLimit !== undefined ||
    fields.priceInPaise !== undefined ||
    fields.constraints !== undefined ||
    fields.eventPolicy !== undefined ||
    fields.privateAccess !== undefined;
}

/**
 * Syncs the host-private invite code document after a policy update.
 * @param {object} params Sync dependencies and normalized policy fields.
 */
function syncPrivateAccessForPolicyUpdate(params: {
  tx: FirebaseFirestore.Transaction;
  privateAccessRef: FirebaseFirestore.DocumentReference;
  privateAccessSnap: FirebaseFirestore.DocumentSnapshot;
  eventId: string;
  clubId: string;
  fields: EventHostUpdateFields;
  eventPolicy: EventPolicyBundleDoc;
  serverTimestamp?: () => FirebaseFirestore.FieldValue;
}) {
  if (!params.eventPolicy.admission.inviteRequired) {
    if (params.privateAccessSnap.exists) {
      params.tx.delete(params.privateAccessRef);
    }
    return;
  }

  const existingCode = params.privateAccessSnap.exists ?
    normalizeInviteCode(params.privateAccessSnap.data()?.inviteCode) :
    null;
  const nextCode =
    normalizeInviteCode(params.fields.privateAccess?.inviteCode) ??
    existingCode;
  if (!nextCode || nextCode.length < 4 || nextCode.length > 64) {
    throw new HttpsError(
      "invalid-argument",
      "Invite-only events need an invite code between 4 and 64 characters."
    );
  }

  params.tx.set(params.privateAccessRef, {
    eventId: params.eventId,
    clubId: params.clubId,
    inviteCode: nextCode,
    createdAt: params.privateAccessSnap.data()?.createdAt ??
      params.serverTimestamp?.() ??
      admin.firestore.FieldValue.serverTimestamp(),
  }, {merge: true});
}

/**
 * Applies partial schedule edits to an event start time.
 * @param {EventDoc} event Current event document.
 * @param {object} fields Update fields.
 * @return {number} Merged start time in epoch milliseconds.
 */
function fieldsStartTimeMillis(
  event: EventDoc,
  fields: EventHostUpdateFields
): number {
  return fields.startTimeMillis ?? event.startTime.toMillis();
}

/**
 * Applies partial schedule edits to an event end time.
 * @param {EventDoc} event Current event document.
 * @param {object} fields Update fields.
 * @return {number} Merged end time in epoch milliseconds.
 */
function fieldsEndTimeMillis(
  event: EventDoc,
  fields: EventHostUpdateFields
): number {
  return fields.endTimeMillis ?? event.endTime.toMillis();
}

/**
 * Converts optional client constraint fields into the canonical stored shape.
 * @param {ParsedEventConstraints=} constraints Validated constraints.
 * @return {EventConstraints} Firestore constraints shape.
 */
function normalizeConstraints(
  constraints?: ParsedEventConstraints
): EventConstraints {
  const value = {
    minAge: 0,
    maxAge: 99,
    ...constraints,
  };
  return {
    minAge: value.minAge,
    maxAge: value.maxAge,
    maxMen: value.maxMen ?? null,
    maxWomen: value.maxWomen ?? null,
  };
}

/**
 * Enforces cross-field age bounds that JSON Schema draft-07 cannot express
 * cleanly without making the payload schema harder to read.
 * @param {ParsedEventConstraints=} constraints Validated constraint fields.
 */
function assertValidEventConstraints(constraints?: ParsedEventConstraints) {
  if (!constraints) return;
  const minAge = constraints.minAge ?? 0;
  const maxAge = constraints.maxAge ?? 99;
  if (maxAge < minAge) {
    throw new HttpsError(
      "invalid-argument",
      "maxAge must be greater than or equal to minAge"
    );
  }
}

/**
 * Ensures the caller is an active account and host of the target club.
 * @param {FirebaseFirestore.DocumentSnapshot} clubSnap Club snapshot.
 * @param {FirebaseFirestore.DocumentSnapshot} deletedUserSnap Tombstone snap.
 * @param {string} hostUserId Authenticated caller UID.
 */
function assertCanMutateClub(
  clubSnap: FirebaseFirestore.DocumentSnapshot,
  deletedUserSnap: FirebaseFirestore.DocumentSnapshot,
  hostUserId: string
) {
  if (deletedUserSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "This account cannot manage events."
    );
  }
  if (!clubSnap.exists) {
    throw new HttpsError("not-found", "Club not found.");
  }
  const club = requireDoc<ClubDoc>(clubSnap, "ClubDoc");
  if (!isClubHost(club, hostUserId)) {
    throw new HttpsError(
      "permission-denied",
      "Only the club host can manage events."
    );
  }
}

/**
 * Validates timing and coordinate invariants after applying a partial update.
 * @param {EventDoc} event Current event document.
 * @param {object} fields Update fields.
 */
function assertValidMergedRunUpdate(
  event: EventDoc,
  fields: EventHostUpdateFields
) {
  const startTimeMillis = fields.startTimeMillis ??
    event.startTime.toMillis();
  const endTimeMillis = fields.endTimeMillis ??
    event.endTime.toMillis();
  assertValidEventTimeRange(startTimeMillis, endTimeMillis);
  assertValidCoordinatePair(
    fields.startingPointLat !== undefined ?
      fields.startingPointLat :
      event.startingPointLat,
    fields.startingPointLng !== undefined ?
      fields.startingPointLng :
      event.startingPointLng
  );
}

/**
 * Throws when only one coordinate is present.
 * @param {number|null=} latitude Latitude.
 * @param {number|null=} longitude Longitude.
 */
function assertValidCoordinatePair(
  latitude?: number | null,
  longitude?: number | null
) {
  if ((latitude == null) !== (longitude == null)) {
    throw new HttpsError(
      "invalid-argument",
      "Starting latitude and longitude must be provided together."
    );
  }
}

/**
 * Fans out a new-event activity item to active club members.
 *
 * Notification delivery is intentionally best-effort: event creation should not
 * be reported as failed after the event document has already been committed.
 * @param {object} params Fan-out parameters.
 * @param {FirebaseFirestore.Firestore} params.db Firestore instance.
 * @param {EventMutationDeps} params.deps Injectable dependencies.
 * @param {string} params.eventId Created event id.
 * @param {string} params.clubId Club id.
 * @param {string} params.hostUserId Host user id to exclude.
 * @param {string} params.clubName Club display name.
 * @param {EventDoc} params.event Created event document.
 */
async function notifyClubMembersForNewEvent(params: {
  db: FirebaseFirestore.Firestore;
  deps: EventMutationDeps;
  eventId: string;
  clubId: string;
  hostUserId: string;
  clubName: string;
  event: EventDoc;
}) {
  try {
    const members = await params.db
      .collection("clubMemberships")
      .where("clubId", "==", params.clubId)
      .where("status", "==", "active")
      .get();
    const memberEntries = members.docs
      .map((doc) => doc.data() as ClubMembershipNotificationDoc)
      .filter((membership): membership is
        Required<Pick<ClubMembershipNotificationDoc, "uid">> &
        ClubMembershipNotificationDoc =>
        typeof membership.uid === "string" &&
        membership.uid !== params.hostUserId
      );
    if (memberEntries.length === 0) return;

    const userSnaps = await Promise.all(
      memberEntries.map((membership) =>
        params.db.collection("users").doc(membership.uid).get()
      )
    );
    const copy = newClubEventNotificationCopy(params.clubName, params.event);

    await Promise.all(userSnaps.map(async (snap, index) => {
      const membership = memberEntries[index];
      const uid = membership.uid;
      const user = snap.data() as NotificationUserDoc | undefined;
      if (!user) return;
      await setActivityNotification(params.db, {
        id: activityNotificationId("clubUpdate", params.eventId),
        uid,
        type: "clubUpdate",
        title: copy.title,
        body: copy.body,
        createdAt: params.deps.serverTimestamp?.() ??
          admin.firestore.FieldValue.serverTimestamp(),
        eventId: params.eventId,
        clubId: params.clubId,
      });
      if (
        membership.pushNotificationsEnabled === true &&
        user.fcmToken &&
        allowsPushPreference(user, "clubUpdates")
      ) {
        await params.deps.sendNotification?.({
          token: user.fcmToken,
          title: copy.title,
          body: copy.body,
          type: "clubUpdate",
          eventId: params.eventId,
          clubId: params.clubId,
        });
      }
    }));
  } catch (error) {
    logger.error("Failed to fan out new-event notifications", {
      eventId: params.eventId,
      clubId: params.clubId,
      error,
    });
  }
}

/**
 * Fans out event update/cancellation activity to booked and waitlisted users.
 *
 * Delivery is best-effort after the canonical event write commits. A
 * notification failure should not roll back a host's already-committed schedule
 * update or cancellation.
 * @param {object} params Fan-out parameters.
 * @param {FirebaseFirestore.Firestore} params.db Firestore instance.
 * @param {EventMutationDeps} params.deps Injectable dependencies.
 * @param {string} params.eventId Event id.
 * @param {EventDoc} params.event Event document used for copy.
 * @param {"eventUpdated"|"eventCancelled"} params.type Notification type.
 */
async function notifyEventParticipants(params: {
  db: FirebaseFirestore.Firestore;
  deps: EventMutationDeps;
  eventId: string;
  event: EventDoc;
  type: "eventUpdated" | "eventCancelled";
}) {
  try {
    const [signedUp, waitlisted] = await Promise.all([
      params.db
        .collection("eventParticipations")
        .where("eventId", "==", params.eventId)
        .where("status", "==", "signedUp")
        .get(),
      params.db
        .collection("eventParticipations")
        .where("eventId", "==", params.eventId)
        .where("status", "==", "waitlisted")
        .get(),
    ]);
    const uids = Array.from(new Set([...signedUp.docs, ...waitlisted.docs]
      .map((doc) => doc.data().uid)
      .filter((uid): uid is string => typeof uid === "string")));
    if (uids.length === 0) return;

    const copy = eventActivityNotificationCopy(params.type, params.event);
    const userSnaps = await Promise.all(
      uids.map((uid) => params.db.collection("users").doc(uid).get())
    );

    await Promise.all(userSnaps.map(async (snap, index) => {
      const uid = uids[index];
      const user = snap.data() as NotificationUserDoc | undefined;
      if (!user) return;
      await setActivityNotification(params.db, {
        id: activityNotificationId(params.type, params.eventId),
        uid,
        type: params.type,
        title: copy.title,
        body: copy.body,
        createdAt: params.deps.serverTimestamp?.() ??
          admin.firestore.FieldValue.serverTimestamp(),
        eventId: params.eventId,
        clubId: params.event.clubId,
      });
      if (user.fcmToken && allowsPushPreference(user, "eventStatusUpdates")) {
        await params.deps.sendNotification?.({
          token: user.fcmToken,
          title: copy.title,
          body: copy.body,
          type: params.type,
          eventId: params.eventId,
          clubId: params.event.clubId,
        });
      }
    }));
  } catch (error) {
    logger.error("Failed to fan out event participant notifications", {
      eventId: params.eventId,
      type: params.type,
      error,
    });
  }
}

/**
 * Builds user-facing copy for a newly hosted club event.
 * @param {string} clubName Club display name.
 * @param {EventDoc} event Created event.
 * @return {{title: string, body: string}} Notification copy.
 */
function newClubEventNotificationCopy(
  clubName: string,
  event: EventDoc
): {title: string; body: string} {
  return {
    title: `${clubName} posted an event`,
    body: `${formatDistance(event.distanceKm)} from ${event.meetingPoint}.`,
  };
}

/**
 * Formats a distance without noisy trailing decimals.
 * @param {number} distanceKm Distance in kilometres.
 * @return {string} Human-readable distance.
 */
function formatDistance(distanceKm: number): string {
  return Number.isInteger(distanceKm) ?
    `${distanceKm} km` :
    `${distanceKm.toFixed(1)} km`;
}

export const createEvent = onCall(
  appCheckCallableOptions,
  (request) => createEventHandler(request)
);
export const updateEvent = onCall(
  appCheckCallableOptions,
  (request) => updateEventHandler(request)
);
export const cancelEvent = onCall(
  appCheckCallableOptionsWithSecrets([razorpayKeyId, razorpayKeySecret]),
  (request) => cancelEventHandler(request)
);
export const deleteEvent = onCall(
  appCheckCallableOptions,
  (request) => deleteEventHandler(request)
);
