import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  EventDocument,
  UserProfileDocument,
} from "../shared/generated/firestoreAdminTypes";
import {signUpUserForEvent} from "./signUpUserForEvent";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {requireAuth} from "../shared/auth";
import {
  EventBookingCallablePayload,
} from "../shared/generated/eventBookingCallablePayload";
import {validateEventBookingCallablePayload} from
  "../shared/generated/schemaValidators";
import {validateCallableWithAjv} from "../shared/validation";
import {normalizeEventIdPayload} from "./eventPayloadNormalization";
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
} from "./eventPolicy";
import {eventParticipationId} from "../shared/relationshipDocuments";
import {
  InviteAttribution,
  resolveInviteAttribution,
} from "./inviteLinks";

interface SignUpForFreeEventDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
  signUpForEvent: (
    db: FirebaseFirestore.Firestore,
    eventId: string,
    userId: string,
    paymentId?: string,
    options?: {
      hasValidInvite?: boolean;
      hasHostApproval?: boolean;
      inviteAttribution?: InviteAttribution | null;
    }
  ) => Promise<void>;
}

const defaultDeps: SignUpForFreeEventDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  signUpForEvent: signUpUserForEvent,
};

/**
 * Callable implementation for signing the caller up for a free event.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {SignUpForFreeEventDeps} deps Injectable Firebase dependencies.
 * @return {Promise<{success: boolean}>} Operation result.
 */
export async function signUpForFreeEventHandler(
  request: CallableRequest<unknown>,
  deps: SignUpForFreeEventDeps = defaultDeps
): Promise<{success: boolean}> {
  const uid = requireAuth(request);
  const payload = validateCallableWithAjv<EventBookingCallablePayload>(
    request,
    validateEventBookingCallablePayload,
    normalizeEventIdPayload
  );
  const {eventId, inviteCode, inviteLinkId} = payload;
  const db = deps.firestore();

  await deps.checkRateLimit(db, uid, "signUpForFreeEvent");

  // Verify the event exists and is actually free.
  const [eventSnap, userSnap, participationSnap] = await Promise.all([
    db.collection("events").doc(eventId).get(),
    db.collection("users").doc(uid).get(),
    db.collection("eventParticipations")
      .doc(eventParticipationId(eventId, uid))
      .get(),
  ]);

  if (!eventSnap.exists) {
    throw new HttpsError("not-found", "Event not found.");
  }
  if (!userSnap.exists) {
    throw new HttpsError("not-found", "User profile not found.");
  }

  const event = eventSnap.data() as EventDocument;
  const user = userSnap.data() as UserProfileDocument;
  const policy = eventPolicyFromEvent(event);
  const cohortId = cohortIdForUser(user);
  const roster = await rosterWithReservedWaitlistOffers(
    db,
    eventId,
    rosterFromEvent(event),
    {excludeUid: uid}
  );
  const participation = participationSnap.data();
  const hasWaitlistOfferAccess =
    hasAcceptedWaitlistOfferAccess(participation);
  const hasHostApproval = hasHostApprovedJoinRequest(participation);
  const hasValidInvite = await hasValidInviteForEvent({
    db,
    eventId,
    policy,
    inviteCode,
  });
  const priceInPaise = quotePriceInPaise({
    policy,
    cohortId,
    roster,
  });

  if (priceInPaise !== 0) {
    throw new HttpsError(
      "permission-denied",
      "This event requires payment. Use the payment flow instead."
    );
  }
  assertPolicyAllowsSignup({
    policy,
    cohortId,
    roster,
    hasValidInvite: hasValidInvite || hasWaitlistOfferAccess,
    hasHostApproval,
  });

  const inviteAttribution = await resolveInviteAttribution({
    db,
    eventId,
    inviteLinkId,
  });
  await deps.signUpForEvent(db, eventId, uid, undefined, {
    hasValidInvite: hasValidInvite || hasWaitlistOfferAccess,
    ...(hasHostApproval ? {hasHostApproval} : {}),
    ...(inviteAttribution ? {inviteAttribution} : {}),
  });

  return {success: true};
}

export const signUpForFreeEvent = onCall(appCheckCallableOptions, (request) =>
  signUpForFreeEventHandler(request)
);
