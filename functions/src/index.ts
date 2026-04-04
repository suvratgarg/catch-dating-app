import {setGlobalOptions} from "firebase-functions";
import * as logger from "firebase-functions/logger";
import {beforeUserCreated} from "firebase-functions/v2/identity";
import * as admin from "firebase-admin";

setGlobalOptions({maxInstances: 10});

admin.initializeApp();

export {createRazorpayOrder} from "./payments/createRazorpayOrder";
export {verifyRazorpayPayment} from "./payments/verifyRazorpayPayment";
export {signUpForFreeRun} from "./runs/signUpForFreeRun";
export {onSwipeCreated} from "./matching/onSwipeCreated";
export {onMatchCreated} from "./matching/onMatchCreated";
export {onMessageCreated} from "./matching/onMessageCreated";
export {syncPublicProfile} from "./users/syncPublicProfile";

export const createUserDocument = beforeUserCreated(async (event) => {
  const user = event.data;
  if (!user) return;

  logger.info("Creating Firestore document for new user", {uid: user.uid});

  await admin.firestore().collection("users").doc(user.uid).set({
    uid: user.uid,
    email: user.email ?? null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
});
