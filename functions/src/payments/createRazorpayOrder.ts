import {
  CallableRequest,
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import Razorpay from "razorpay";
import {
  EventDoc,
  UserProfileDoc,
} from "../shared/generated/firestoreAdminTypes";
import {buildOrderCreatePayload} from "./paymentValidation";
import {
  createRazorpayClient,
  razorpayKeyId,
  razorpayKeySecret,
} from "./razorpay";
import {hasBlockingRelationship} from "../safety/blocking";
import {appCheckCallableOptionsWithSecrets} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {requireAuth} from "../shared/auth";
import {
  CreateRazorpayOrderCallablePayload,
} from "../shared/generated/createRazorpayOrderCallablePayload";
import {validateCreateRazorpayOrderCallablePayload} from
  "../shared/generated/schemaValidators";
import {validateCallableWithAjv, requireDoc} from "../shared/validation";
import {eventParticipationId} from "../shared/relationshipDocuments";
import {assertNoUserEventScheduleConflict} from "../events/scheduleConflicts";
import {normalizeEventIdPayload} from "../events/eventPayloadNormalization";
import {
  assertPolicyAllowsSignup,
  cohortIdForUser,
  eventPolicyFromEvent,
  hasHostApprovedJoinRequest,
  hasValidInviteForEvent,
  quotePriceInPaise,
  rosterFromEvent,
} from "../events/eventPolicy";

interface CreateRazorpayOrderDeps {
  createClient: () => Razorpay;
  firestore: () => FirebaseFirestore.Firestore;
  now: () => number;
}

const defaultDeps: CreateRazorpayOrderDeps = {
  createClient: createRazorpayClient,
  firestore: () => admin.firestore(),
  now: () => Date.now(),
};

/**
 * Creates a Razorpay order from trusted Firestore event data.
 * @param {CallableRequest<Partial<CreateOrderData> | null>} request Callable.
 * @param {CreateRazorpayOrderDeps} deps Injectable service dependencies.
 * @return {Promise<{orderId: string, amount: number, currency: string}>} Order.
 */
export async function createRazorpayOrderHandler(
  request: CallableRequest<unknown>,
  deps: CreateRazorpayOrderDeps = defaultDeps
) {
  const uid = requireAuth(request);
  const payload = validateCallableWithAjv<CreateRazorpayOrderCallablePayload>(
    request,
    validateCreateRazorpayOrderCallablePayload,
    normalizeEventIdPayload
  );
  const {eventId, inviteCode} = payload;

  const db = deps.firestore();
  const [eventSnap, userSnap, participationSnap, activeParticipationsSnap] =
    await Promise.all([
      db.collection("events").doc(eventId).get(),
      db.collection("users").doc(uid).get(),
      db.collection("eventParticipations")
        .doc(eventParticipationId(eventId, uid))
        .get(),
      db.collection("eventParticipations")
        .where("eventId", "==", eventId)
        .where("status", "in", ["signedUp", "attended"])
        .get(),
    ]);

  if (!eventSnap.exists) {
    throw new HttpsError("not-found", "Event not found.");
  }
  if (!userSnap.exists) {
    throw new HttpsError("not-found", "User profile not found.");
  }

  const event = requireDoc<EventDoc>(eventSnap, "EventDoc");
  const user = requireDoc<UserProfileDoc>(userSnap, "UserProfileDoc");
  const participation = participationSnap.exists ?
    participationSnap.data() as {status?: string} :
    null;
  const activeParticipantIds = activeParticipationsSnap.docs
    .map((doc) => doc.data().uid)
    .filter((participantUid) => typeof participantUid === "string");

  // Pre-flight capacity check; the real atomic check happens in
  // signUpUserForEvent.
  if (
    participation?.status === "signedUp" ||
    participation?.status === "attended"
  ) {
    throw new HttpsError(
      "already-exists",
      "You are already booked for this event."
    );
  }

  const signedUpCount = activeParticipationsSnap.docs
    .filter((doc) => doc.data().status === "signedUp")
    .length;
  if ((event.bookedCount ?? signedUpCount) >= event.capacityLimit) {
    throw new HttpsError(
      "failed-precondition",
      "This event is full. You can join the waitlist instead."
    );
  }

  await assertNoUserEventScheduleConflict(db, {
    uid,
    eventId,
    clubId: event.clubId,
    startTimeMillis: event.startTime.toMillis(),
    endTimeMillis: event.endTime.toMillis(),
  });

  if (await hasBlockingRelationship(db, uid, activeParticipantIds)) {
    throw new HttpsError(
      "failed-precondition",
      "This event is unavailable."
    );
  }

  const policy = eventPolicyFromEvent(event);
  const cohortId = cohortIdForUser(user);
  const hasValidInvite = await hasValidInviteForEvent({
    db,
    eventId,
    policy,
    inviteCode,
  });
  assertPolicyAllowsSignup({
    policy,
    cohortId,
    roster: {
      ...rosterFromEvent(event),
      totalBooked: event.bookedCount ?? signedUpCount,
    },
    hasValidInvite,
    hasHostApproval: hasHostApprovedJoinRequest(participation),
  });

  const razorpay = deps.createClient();
  const amountInPaise = quotePriceInPaise({
    policy,
    cohortId,
    roster: rosterFromEvent(event),
  });
  const order = await razorpay.orders.create(
    buildOrderCreatePayload({
      eventId,
      event,
      userId: uid,
      receiptToken: deps.now(),
      amountInPaise,
      inviteVerified: policy.admission.inviteRequired && hasValidInvite,
    })
  );

  return {
    orderId: order.id,
    amount: Number(order.amount),
    currency: order.currency,
  };
}

export const createRazorpayOrder = onCall(
  appCheckCallableOptionsWithSecrets([razorpayKeyId, razorpayKeySecret]),
  async (request) => {
    if (request.auth) {
      await checkRateLimit(
        admin.firestore(),
        request.auth.uid,
        "createRazorpayOrder"
      );
    }
    return createRazorpayOrderHandler(request);
  }
);
