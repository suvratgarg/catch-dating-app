import {setGlobalOptions} from "firebase-functions";
import * as admin from "firebase-admin";

setGlobalOptions({region: "asia-south1", maxInstances: 50});

admin.initializeApp();

export {createRazorpayOrder} from "./payments/createRazorpayOrder";
export {verifyRazorpayPayment} from "./payments/verifyRazorpayPayment";
export {razorpayWebhook} from "./payments/razorpayWebhook";
export {
  reconcileRazorpayOrders,
} from "./payments/reconcileRazorpayOrders";
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
export {sendEventBroadcast} from "./events/sendEventBroadcast";
export {
  placeDetails,
  placesAutocomplete,
} from "./places/placeAutocomplete";
export {createClub} from "./clubs/createClub";
export {createOrganizer} from "./organizers/createOrganizer";
export {createClubPost} from "./clubs/clubPosts";
export {
  startClubHostConversation,
  startOrganizerConversation,
} from "./clubs/clubHostConversations";
export {
  addClubHost,
  removeClubHost,
  transferClubOwnership,
} from "./clubs/manageClubHosts";
export {
  adminDecideClubClaim,
  requestClubClaim,
} from "./clubs/clubClaims";
export {
  syncClubMemberStats,
  syncOrganizerFollowerStats,
} from "./clubs/syncClubMemberStats";
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
export {
  archiveOrganizer,
  deleteOrganizer,
  updateOrganizer,
} from "./organizers/mutateOrganizer";
export {
  followOrganizer,
  setOrganizerNotificationPreference,
  unfollowOrganizer,
} from "./organizers/follows";
export {
  addOrganizerManager,
  removeOrganizerManager,
  transferOrganizerOwnership,
} from "./organizers/manageOrganizerTeam";
export {createOrganizerPost} from "./organizers/organizerPosts";
export {
  adminDecideOrganizerClaim,
  requestOrganizerClaim,
} from "./organizers/organizerClaims";
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
  createPublicOrganizerReview,
  deleteEventReview,
  listPublicClubReviews,
  listPublicOrganizerReviews,
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
export {
  generateOrganizerLogoThumbnail,
} from "./organizers/generateOrganizerLogoThumbnail";
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
  syncAlgoliaOrganizerIndex,
} from "./search/algoliaExploreIndex";
export {
  adminGetAdminUserRoles,
  adminListAdminRoleAssignments,
  adminSetAdminUserRoles,
} from "./admin/adminUserRoles";
export {adminGetOverview} from "./admin/overview";
export {
  adminAssignSafetyTriageItem,
  adminDecideSafetyTriageItem,
  adminGetSafetyTriageDetails,
} from "./admin/safetyTriage";
export {
  adminDecideAccessApplication,
  adminGetAccessApplicationDetails,
} from "./admin/accessApplications";
export {
  adminGetClubClaimRequestDetails,
  adminListClubClaimRequests,
} from "./admin/clubClaimReview";
export {
  adminSetClubIndexStatus,
} from "./admin/clubIndexing";
export {
  adminGetClubDetails,
  adminGetOrganizerDetails,
  adminListClubDetails,
  adminListOrganizerDetails,
  adminUpdateClubDetails,
  adminUpdateOrganizerDetails,
} from "./admin/clubDetails";
export {
  adminGetEventDetails,
  adminListEventDetails,
  adminUpdateEventDetails,
} from "./admin/eventDetails";
export {
  adminListExternalEventDetails,
} from "./admin/externalEventDetails";
export {
  adminGetEventSupplyReadiness,
} from "./admin/eventSupplyReadiness";
export {
  adminPublishExternalEvent,
} from "./admin/externalEventPublishing";
export {
  adminGetEventIntakeDashboard,
} from "./admin/eventIntakeDashboard";
export {
  adminListIntakeOperations,
} from "./admin/intakeOperations";
export {
  adminListActionExecutions,
  adminRecordActionExecution,
} from "./admin/adminActionExecutions";
export {
  adminDecideOrganizerIntake,
} from "./admin/organizerIntake";
export {
  adminRecordOrganizerCuration,
} from "./admin/organizerCuration";
export {
  adminRecordEventIntakeReviewDecision,
} from "./admin/eventIntakeReview";
export {
  adminDecideOrganizerEventCandidate,
} from "./admin/organizerEventIntake";
export {
  adminResolveOrganizerEventLocation,
} from "./admin/organizerEventLocationResolution";
export {
  adminDecideOrganizerPolicyGap,
} from "./admin/organizerPolicyGap";
export {
  adminCreateMarketingContentDraft,
  adminGetMarketingOpsDashboard,
  adminRecordMarketingReviewDecision,
} from "./admin/marketingOps";
export {
  adminGetHostAnalytics,
  getHostAnalytics,
} from "./analytics/hostAnalytics";
export {
  adminGetUserAnalytics,
  getUserAnalytics,
} from "./analytics/userAnalytics";
export {
  recordOrganizerAnalyticsEvent,
} from "./analytics/organizerAnalyticsEvents";
