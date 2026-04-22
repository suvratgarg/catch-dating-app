import {setGlobalOptions} from "firebase-functions";
import * as admin from "firebase-admin";

setGlobalOptions({maxInstances: 10});

admin.initializeApp();

export {createRazorpayOrder} from "./payments/createRazorpayOrder";
export {verifyRazorpayPayment} from "./payments/verifyRazorpayPayment";
export {signUpForFreeRun} from "./runs/signUpForFreeRun";
export {cancelRunSignUp} from "./runs/cancelRunSignUp";
export {markRunAttendance} from "./runs/markRunAttendance";
export {onSwipeCreated} from "./matching/onSwipeCreated";
export {onMatchCreated} from "./matching/onMatchCreated";
export {onMessageCreated} from "./matching/onMessageCreated";
export {syncRunClubReviewStats} from "./reviews/syncRunClubReviewStats";
export {syncPublicProfile} from "./profiles/syncPublicProfile";
export {joinWaitlist} from "./waitlist/joinWaitlist";
