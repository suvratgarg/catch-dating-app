import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {EventDoc, UserProfileDoc} from "../shared/firestore";
import {signUpUserForEvent} from "./signUpUserForEvent";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {requireAuth} from "../shared/auth";
import {
  EventIdCallablePayload,
} from "../shared/generated/eventIdCallablePayload";
import {validateEventIdCallablePayload} from
  "../shared/generated/schemaValidators";
import {validateCallableWithAjv} from "../shared/validation";
import {normalizeEventIdPayload} from "./eventPayloadNormalization";
import {
  cohortIdForUser,
  eventPolicyFromEvent,
  quotePriceInPaise,
  rosterFromEvent,
} from "./eventPolicy";

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
    userId: string
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
  const {eventId} = validateCallableWithAjv<EventIdCallablePayload>(
    request,
    validateEventIdCallablePayload,
    normalizeEventIdPayload
  );
  const db = deps.firestore();

  await deps.checkRateLimit(db, uid, "signUpForFreeEvent");

  // Verify the event exists and is actually free.
  const [eventSnap, userSnap] = await Promise.all([
    db.collection("events").doc(eventId).get(),
    db.collection("users").doc(uid).get(),
  ]);

  if (!eventSnap.exists) {
    throw new HttpsError("not-found", "Event not found.");
  }
  if (!userSnap.exists) {
    throw new HttpsError("not-found", "User profile not found.");
  }

  const event = eventSnap.data() as EventDoc;
  const user = userSnap.data() as UserProfileDoc;
  const priceInPaise = quotePriceInPaise({
    policy: eventPolicyFromEvent(event),
    cohortId: cohortIdForUser(user),
    roster: rosterFromEvent(event),
  });

  if (priceInPaise !== 0) {
    throw new HttpsError(
      "permission-denied",
      "This event requires payment. Use the payment flow instead."
    );
  }

  await deps.signUpForEvent(db, eventId, uid);

  return {success: true};
}

export const signUpForFreeEvent = onCall(appCheckCallableOptions, (request) =>
  signUpForFreeEventHandler(request)
);
