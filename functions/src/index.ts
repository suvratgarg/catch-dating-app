import {setGlobalOptions} from "firebase-functions";
import * as admin from "firebase-admin";

setGlobalOptions({region: "asia-south1", maxInstances: 50});

admin.initializeApp();

export {createRazorpayOrder} from "./payments/createRazorpayOrder";
export {verifyRazorpayPayment} from "./payments/verifyRazorpayPayment";
export {signUpForFreeEvent} from "./events/signUpForFreeEvent";
export {cancelEventSignUp} from "./events/cancelEventSignUp";
export {
  joinEventWaitlist,
  leaveEventWaitlist,
} from "./events/joinEventWaitlist";
export {markEventAttendance} from "./events/markEventAttendance";
export {selfCheckInAttendance} from "./events/selfCheckInAttendance";
export {
  createEvent,
  updateEvent,
  cancelEvent,
  deleteEvent,
} from "./events/mutateEvent";
export {sendEventReminders} from "./events/sendEventReminders";
export {
  placeDetails,
  placesAutocomplete,
} from "./places/placeAutocomplete";
export {createClub} from "./clubs/createClub";
export {syncClubMemberStats} from "./clubs/syncClubMemberStats";
export {syncClubNextEvent} from "./clubs/syncClubNextEvent";
export {
  joinClub,
  leaveClub,
  setClubNotificationPreference,
} from "./clubs/membership";
export {
  archiveClub,
  deleteClub,
  updateClub,
} from "./clubs/mutateClub";
export {onSwipeCreated} from "./matching/onSwipeCreated";
export {onMatchCreated} from "./matching/onMatchCreated";
export {onMessageCreated} from "./matching/onMessageCreated";
export {syncClubReviewStats} from "./reviews/syncClubReviewStats";
export {
  createEventReview,
  deleteEventReview,
  updateEventReview,
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
