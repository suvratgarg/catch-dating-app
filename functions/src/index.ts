import {setGlobalOptions} from "firebase-functions";
import * as admin from "firebase-admin";

setGlobalOptions({region: "asia-south1", maxInstances: 50});

admin.initializeApp();

export {createRazorpayOrder} from "./payments/createRazorpayOrder";
export {verifyRazorpayPayment} from "./payments/verifyRazorpayPayment";
export {signUpForFreeRun} from "./runs/signUpForFreeRun";
export {cancelRunSignUp} from "./runs/cancelRunSignUp";
export {joinRunWaitlist, leaveRunWaitlist} from "./runs/joinRunWaitlist";
export {markRunAttendance} from "./runs/markRunAttendance";
export {selfCheckInAttendance} from "./runs/selfCheckInAttendance";
export {createRun, updateRun, cancelRun, deleteRun} from "./runs/mutateRun";
export {sendRunReminders} from "./runs/sendRunReminders";
export {
  placeDetails,
  placesAutocomplete,
} from "./places/placeAutocomplete";
export {createRunClub} from "./runClubs/createRunClub";
export {syncRunClubMemberStats} from "./runClubs/syncRunClubMemberStats";
export {syncRunClubNextRun} from "./runClubs/syncRunClubNextRun";
export {
  joinRunClub,
  leaveRunClub,
  setRunClubNotificationPreference,
} from "./runClubs/membership";
export {
  archiveRunClub,
  deleteRunClub,
  updateRunClub,
} from "./runClubs/mutateRunClub";
export {onSwipeCreated} from "./matching/onSwipeCreated";
export {onMatchCreated} from "./matching/onMatchCreated";
export {onMessageCreated} from "./matching/onMessageCreated";
export {syncRunClubReviewStats} from "./reviews/syncRunClubReviewStats";
export {
  createRunReview,
  deleteRunReview,
  updateRunReview,
} from "./reviews/mutateReview";
export {syncPublicProfile} from "./profiles/syncPublicProfile";
export {updateUserProfile} from "./profiles/updateUserProfile";
export {
  generateProfilePhotoThumbnail,
} from "./profiles/generateProfilePhotoThumbnail";
export {joinWaitlist} from "./waitlist/joinWaitlist";
export {blockUser, unblockUser, onBlockCreated} from "./safety/blocking";
export {requestAccountDeletion} from "./safety/accountDeletion";
export {reportUser} from "./safety/reporting";
export {moderatePhotoOnUpload} from "./moderation/moderatePhoto";
export {moderateChatMessage} from "./moderation/moderateMessage";
