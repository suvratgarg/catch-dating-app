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
  OrganizerDocument,
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
import {organizerOwnerUserId} from "../shared/organizerHosts";
import {
  assertPolicyAllowsSignup,
  cohortIdForUser,
  eventPolicyFromEvent,
  hasAcceptedWaitlistOfferAccess,
  hasHostApprovedJoinRequest,
  hasValidInviteForEvent,
  quotePriceInPaise,
  rosterFromEvent,
  rosterWithReservedWaitlistOffers,
} from "../events/eventPolicy";
import {resolveInviteAttribution} from "../events/inviteLinks";
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
  const {eventId, inviteCode, inviteLinkId} = payload;
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

    organizerId: event.organizerId ?? event.clubId,
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
  const hasWaitlistOfferAccess =
    hasAcceptedWaitlistOfferAccess(participation);
  const hasValidInvite = await hasValidInviteForEvent({
    db,
    eventId,
    policy,
    inviteCode,
  });
  assertPolicyAllowsSignup({
    policy,
    cohortId,
    roster: await rosterWithReservedWaitlistOffers(
      db,
      eventId,
      {
        ...rosterFromEvent(event),
        totalBooked: event.bookedCount ?? signedUpCount,
      },
      {excludeUid: uid}
    ),
    hasValidInvite: hasValidInvite || hasWaitlistOfferAccess,
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

  const organizerRef = event.organizerId ?
    db.collection("organizers").doc(event.organizerId) :
    db.collection("clubs").doc(event.clubId);
  const [organizerSnap] = await Promise.all([
    organizerRef.get(),
    deps.checkRateLimit?.(db, uid, "createStripeCheckoutSession"),
  ]);
  if (!organizerSnap.exists) {
    throw new HttpsError("not-found", "Organizer not found.");
  }
  const hostUserId = event.organizerId ?
    organizerOwnerUserId(requireDoc<OrganizerDocument>(
      organizerSnap,
      "OrganizerDocument"
    )) :
    clubOwnerUserId(requireDoc<ClubDocument>(
      organizerSnap,
      "ClubDocument"
    ));
  if (!hostUserId) {
    throw new HttpsError(
      "failed-precondition",
      "This organizer has not claimed payouts yet."
    );
  }
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
  const inviteAttribution = await resolveInviteAttribution({
    db,
    eventId,
    inviteLinkId,
  });
  const session = await deps.stripe().createCheckoutSession({
    paymentId: paymentRef.id,
    eventId,
    clubId: event.clubId,

    organizerId: event.organizerId ?? event.clubId,
    userId: uid,
    hostUserId,
    stripeAccountId: hostAccount.stripeAccountId,
    eventTitle: checkoutEventTitle(event),
    amountMinor,
    currency,
    inviteVerified: policy.admission.inviteRequired === true &&
      (hasValidInvite === true || hasWaitlistOfferAccess === true),
    inviteLinkId: inviteAttribution?.inviteLinkId,
    inviteSource: inviteAttribution?.inviteSource,
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
    ...(inviteAttribution?.inviteLinkId ?
      {inviteLinkId: inviteAttribution.inviteLinkId} :
      {}),
    ...(inviteAttribution?.inviteSource ?
      {inviteSource: inviteAttribution.inviteSource} :
      {}),
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
    stringFields: ["eventId", "inviteCode", "inviteLinkId"],
  });
}

export const createStripeCheckoutSession = onCall(
  appCheckCallableOptionsWithSecrets([stripeSecretKey]),
  (request) => createStripeCheckoutSessionHandler(request)
);
