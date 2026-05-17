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
  normalizePolicy,
} from "./eventPolicy";
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
type CreateEventPayloadWithPolicy = CreateEventCallablePayload & {
  eventPolicy?: EventPolicyBundleDoc;
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

    await claimClubScheduleInTransaction(tx, db, {
      clubId: data.clubId,
      eventId: eventRef.id,
      startTimeMillis: data.startTimeMillis,
      endTimeMillis: data.endTimeMillis,
    });
    tx.create(eventRef, event);
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
    const [clubSnap, activeParticipations] = await Promise.all([
      tx.get(clubRef),
      eventParticipationsByStatusInTransaction(tx, db, data.eventId, [
        "signedUp",
        "waitlisted",
        "attended",
      ]),
    ]);
    assertCanMutateClub(clubSnap, deletedUserSnap, hostUserId);
    assertValidMergedRunUpdate(event, data.fields);
    if (hasScheduleTimeChange(data.fields) && activeParticipations.length > 0) {
      throw new HttpsError(
        "failed-precondition",
        "Events with participants or waitlisted users cannot be rescheduled."
      );
    }

    const patch = buildUpdateEventPatch(data.fields, deps);
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
    distanceKm: data.distanceKm,
    pace: data.pace,
    capacityLimit: eventPolicy.admission.capacityLimit,
    description: data.description,
    priceInPaise: eventPolicy.pricing.basePriceInPaise,
    constraints: normalizeConstraints(data.constraints),
    eventPolicy,
    cohortCounts: {},
  };
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
  if (club.hostUserId !== hostUserId) {
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
