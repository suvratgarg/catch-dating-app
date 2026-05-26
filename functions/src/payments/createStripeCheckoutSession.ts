/* eslint-disable require-jsdoc */
import {
  CallableRequest,
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  ClubDocument,
  EventDocument,
  HostPaymentAccountDocument,
  UserProfileDocument,
} from "../shared/generated/firestoreAdminTypes";
import {hasBlockingRelationship} from "../safety/blocking";
import {assertNoUserEventScheduleConflict} from "../events/scheduleConflicts";
import {normalizePayloadStrings} from "../shared/callablePayloadNormalization";
import {requireAuth} from "../shared/auth";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {eventParticipationId} from "../shared/relationshipDocuments";
import {appCheckCallableOptionsWithSecrets} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {clubOwnerUserId} from "../shared/clubHosts";
import {
  assertPolicyAllowsSignup,
  cohortIdForUser,
  eventPolicyFromEvent,
  hasHostApprovedJoinRequest,
  hasValidInviteForEvent,
  quotePriceInPaise,
  rosterFromEvent,
} from "../events/eventPolicy";
import {
  CreateStripeCheckoutSessionCallablePayload,
} from "../shared/generated/createStripeCheckoutSessionCallablePayload";
import {
  validateCreateStripeCheckoutSessionCallablePayload,
} from "../shared/generated/schemaValidators";
import {
  createStripeClient,
  stripeCheckoutCancelUrlValue,
  stripeCheckoutSuccessUrlValue,
  stripeFeeAmountMinor,
  StripeClient,
  stripeSecretKey,
} from "./stripe";

interface CreateStripeCheckoutSessionDeps {
  firestore: () => FirebaseFirestore.Firestore;
  stripe: () => StripeClient;
  serverTimestamp: () => unknown;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: CreateStripeCheckoutSessionDeps = {
  firestore: () => admin.firestore(),
  stripe: createStripeClient,
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit,
};

export async function createStripeCheckoutSessionHandler(
  request: CallableRequest<unknown>,
  deps: CreateStripeCheckoutSessionDeps = defaultDeps
) {
  const uid = requireAuth(request);
  const payload = validateCallableWithAjv<
    CreateStripeCheckoutSessionCallablePayload
  >(
    request,
    validateCreateStripeCheckoutSessionCallablePayload,
    normalizeStripeCheckoutPayload
  );
  const {eventId, inviteCode} = payload;
  const db = deps.firestore();

  const [
    eventSnap,
    userSnap,
    participationSnap,
    activeParticipationsSnap,
  ] = await Promise.all([
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

  const event = requireDoc<EventDocument>(
    eventSnap,
    "EventDocument"
  );
  const user = requireDoc<UserProfileDocument>(
    userSnap,
    "UserProfileDocument"
  );
  const currency = (event.currency ?? "INR").toUpperCase();
  if (currency === "INR") {
    throw new HttpsError(
      "failed-precondition",
      "Use Razorpay for INR paid bookings."
    );
  }

  const participation = participationSnap.exists ?
    participationSnap.data() as {status?: string} :
    null;
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

  const activeParticipantIds = activeParticipationsSnap.docs
    .map((doc) => doc.data().uid)
    .filter((participantUid) => typeof participantUid === "string");
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

  const amountMinor = quotePriceInPaise({
    policy,
    cohortId,
    roster: rosterFromEvent(event),
  });
  if (!Number.isInteger(amountMinor) || amountMinor <= 0) {
    throw new HttpsError(
      "invalid-argument",
      "Event price must be a positive integer."
    );
  }

  const [clubSnap] = await Promise.all([
    db.collection("clubs").doc(event.clubId).get(),
    deps.checkRateLimit?.(db, uid, "createStripeCheckoutSession"),
  ]);
  if (!clubSnap.exists) {
    throw new HttpsError("not-found", "Club not found.");
  }
  const club = requireDoc<ClubDocument>(clubSnap, "ClubDocument");
  const hostUserId = clubOwnerUserId(club);
  const hostAccountSnap = await db
    .collection("hostPaymentAccounts")
    .doc(hostUserId)
    .get();
  if (!hostAccountSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "This host has not set up international payouts yet."
    );
  }
  const hostAccount = requireDoc<HostPaymentAccountDocument>(
    hostAccountSnap,
    "HostPaymentAccountDocument"
  );
  if (
    hostAccount.provider !== "stripe" ||
    !hostAccount.chargesEnabled ||
    !hostAccount.payoutsEnabled ||
    hostAccount.onboardingStatus !== "complete"
  ) {
    throw new HttpsError(
      "failed-precondition",
      "This host cannot accept international payments yet."
    );
  }

  const paymentRef = db.collection("payments").doc();
  const applicationFeeAmount = stripeFeeAmountMinor(amountMinor);
  const session = await deps.stripe().createCheckoutSession({
    paymentId: paymentRef.id,
    eventId,
    clubId: event.clubId,
    userId: uid,
    hostUserId,
    stripeAccountId: hostAccount.stripeAccountId,
    eventTitle: checkoutEventTitle(event),
    amountMinor,
    currency,
    inviteVerified: policy.admission.inviteRequired === true &&
      hasValidInvite === true,
    applicationFeeAmount,
    successUrl: successUrlForSession(eventId),
    cancelUrl: stripeCheckoutCancelUrlValue(),
  });
  if (session.url === null) {
    throw new HttpsError(
      "internal",
      "Stripe did not return a checkout URL."
    );
  }

  await paymentRef.set({
    userId: uid,
    orderId: session.id,
    paymentId: paymentRef.id,
    eventId,
    amount: amountMinor,
    amountMinor,
    currency,
    provider: "stripe",
    providerPaymentId: session.paymentIntentId,
    checkoutSessionId: session.id,
    hostUserId,
    stripeAccountId: hostAccount.stripeAccountId,
    applicationFeeAmount,
    status: "pending",
    signUpFailed: false,
    createdAt: deps.serverTimestamp(),
  });

  return {
    sessionId: session.id,
    paymentId: paymentRef.id,
    amountMinor,
    currency,
    checkoutUrl: session.url,
    provider: "stripe",
  };
}

function checkoutEventTitle(event: EventDocument): string {
  const kind = event.eventFormat?.activityKind ?? "event";
  return `Catch ${kind} at ${event.meetingPoint}`;
}

function successUrlForSession(eventId: string): string {
  const configured = stripeCheckoutSuccessUrlValue();
  if (configured.includes("{CHECKOUT_SESSION_ID}")) return configured;
  const separator = configured.includes("?") ? "&" : "?";
  return `${configured}${separator}` +
    `eventId=${encodeURIComponent(eventId)}` +
    "&session_id={CHECKOUT_SESSION_ID}";
}

function normalizeStripeCheckoutPayload(data: unknown): unknown {
  return normalizePayloadStrings(data, {
    stringFields: ["eventId", "inviteCode"],
  });
}

export const createStripeCheckoutSession = onCall(
  appCheckCallableOptionsWithSecrets([stripeSecretKey]),
  (request) => createStripeCheckoutSessionHandler(request)
);
