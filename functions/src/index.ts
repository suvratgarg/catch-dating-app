import {setGlobalOptions} from "firebase-functions";
import * as admin from "firebase-admin";

setGlobalOptions({region: "asia-south1", maxInstances: 50});

admin.initializeApp();

export {createRazorpayOrder} from "./payments/createRazorpayOrder";
export {verifyRazorpayPayment} from "./payments/verifyRazorpayPayment";
export {createStripeCheckoutSession} from
  "./payments/createStripeCheckoutSession";
export {
  createStripeHostOnboardingLink,
  refreshStripeHostPaymentAccount,
} from "./payments/stripeHostAccounts";
export {stripeWebhook} from "./payments/stripeWebhook";
export {signUpForFreeEvent} from "./events/signUpForFreeEvent";
export {cancelEventSignUp} from "./events/cancelEventSignUp";
export {
  joinEventWaitlist,
  leaveEventWaitlist,
} from "./events/joinEventWaitlist";
export {
  acceptEventWaitlistOffer,
  createEventWaitlistOffers,
  declineEventWaitlistOffer,
  expireEventWaitlistOffers,
} from "./events/waitlistOffers";
export {
  createEventInviteLink,
  disableEventInviteLink,
  recordEventInviteLinkOpen,
} from "./events/inviteLinks";
export {decideEventJoinRequest} from "./events/decideEventJoinRequest";
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
export {startClubHostConversation} from "./clubs/clubHostConversations";
export {
  addClubHost,
  removeClubHost,
  transferClubOwnership,
} from "./clubs/manageClubHosts";
export {
  adminDecideClubClaim,
  requestClubClaim,
} from "./clubs/clubClaims";
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
export {
  onEventInviteLinkWritten,
  onEventParticipationWritten,
  onEventSuccessFeedbackWritten,
  onEventWaitlistOfferWritten,
  onPaymentWritten,
} from "./marketplace/eventSuccessScorecards";
export {
  generateEventSuccessPods,
  overrideEventSuccessGroups,
} from "./eventSuccess/generateEventSuccessPods";
export {
  generateEventSuccessRotations,
  overrideEventSuccessRotations,
} from "./eventSuccess/generateEventSuccessRotations";
export {
  fetchEventSuccessWingmanCandidates,
  submitEventSuccessWingmanRequest,
  withdrawEventSuccessWingmanRequest,
} from "./eventSuccess/wingmanRequests";
export {
  completeEventSuccessFirstHelloMission,
  startEventSuccessFirstHelloMission,
} from "./eventSuccess/firstHelloCheckIn";
export {syncClubReviewStats} from "./reviews/syncClubReviewStats";
export {
  createEventReview,
  createPublicClubReview,
  deleteEventReview,
  listPublicClubReviews,
  setReviewResponse,
  updateEventReview,
} from "./reviews/mutateReview";
export {
  syncHostProfile,
  syncPublicProfile,
} from "./profiles/syncPublicProfile";
export {updateUserProfile} from "./profiles/updateUserProfile";
export {
  generateProfilePhotoThumbnail,
} from "./profiles/generateProfilePhotoThumbnail";
export {
  generateClubLogoThumbnail,
} from "./clubs/generateClubLogoThumbnail";
export {joinWaitlist} from "./waitlist/joinWaitlist";
export {blockUser, unblockUser, onBlockCreated} from "./safety/blocking";
export {requestAccountDeletion} from "./safety/accountDeletion";
export {reportUser} from "./safety/reporting";
export {moderatePhotoOnUpload} from "./moderation/moderatePhoto";
export {moderateChatMessage} from "./moderation/moderateMessage";
export {
  listSuvbotDemoActions,
  requestSuvbotDemoOperation,
} from "./demoOps/suvbot";
export {exploreSearch} from "./search/exploreSearch";
export {
  syncAlgoliaClubIndex,
  syncAlgoliaEventIndex,
} from "./search/algoliaExploreIndex";
export {adminGetOverview} from "./admin/overview";
export {
  adminDecideAccessApplication,
} from "./admin/accessApplications";
export {
  adminSetClubIndexStatus,
} from "./admin/clubIndexing";
export {
  adminGetClubDetails,
  adminUpdateClubDetails,
} from "./admin/clubDetails";
