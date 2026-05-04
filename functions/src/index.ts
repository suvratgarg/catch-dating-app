import {setGlobalOptions} from "firebase-functions";
import * as admin from "firebase-admin";

setGlobalOptions({region: "asia-south1", maxInstances: 50});

admin.initializeApp();

export {createRazorpayOrder} from "./payments/createRazorpayOrder";
export {verifyRazorpayPayment} from "./payments/verifyRazorpayPayment";
export {signUpForFreeRun} from "./runs/signUpForFreeRun";
export {cancelRunSignUp} from "./runs/cancelRunSignUp";
export {joinRunWaitlist} from "./runs/joinRunWaitlist";
export {markRunAttendance} from "./runs/markRunAttendance";
export {selfCheckInAttendance} from "./runs/selfCheckInAttendance";
export {onSwipeCreated} from "./matching/onSwipeCreated";
export {onMatchCreated} from "./matching/onMatchCreated";
export {onMessageCreated} from "./matching/onMessageCreated";
export {syncRunClubReviewStats} from "./reviews/syncRunClubReviewStats";
export {syncPublicProfile} from "./profiles/syncPublicProfile";
export {joinWaitlist} from "./waitlist/joinWaitlist";
export {blockUser, unblockUser, onBlockCreated} from "./safety/blocking";
export {requestAccountDeletion} from "./safety/accountDeletion";
export {reportUser} from "./safety/reporting";
export {moderatePhotoOnUpload} from "./moderation/moderatePhoto";
export {moderateChatMessage} from "./moderation/moderateMessage";
