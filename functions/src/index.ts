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
export {
  createRazorpayHostPaymentAccount,
  refreshRazorpayHostPaymentAccount,
} from "./payments/razorpayHostAccounts";
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
  createAttendeeInviteLink,
  createEventInviteLink,
  disableEventInviteLink,
  getEventInviteLinkToken,
  recordEventInviteLinkOpen,
  recordEventShareIntent,
  resolveEventInviteLanding,
} from "./events/inviteLinks";
export {onOrganizerContactEventEdgeInviteAttributed} from
  "./events/eventInviteAttributionProjection";
export {decideEventJoinRequest} from "./events/decideEventJoinRequest";
export {markEventAttendance} from "./events/markEventAttendance";
export {
  importEventAttendees,
  markEventAttendeeAttendance,
  registerPublicEvent,
  setEventAttendeeAttendance,
} from "./events/eventAttendees";
export {
  getEventOperatorAccess,
  grantEventStaff,
  listEventStaff,
  revokeEventStaff,
} from "./events/eventStaff";
export {
  createEventRosterHandoff,
  ingestEventRosterWebhook,
} from "./events/eventRosterHandoffs";
export {
  approveEventRuntimeClaim,
  checkInEventRuntime,
  claimEventRuntimeAccess,
  getEventRuntimeBootstrap,
  submitEventRuntimeProfile,
} from "./eventSuccess/eventRuntime";
export {
  completeEventRehearsal,
  controlEventRehearsal,
  controlEventRehearsalSpatial,
  createEventRehearsal,
  expireEventRehearsals,
  exportEventRehearsalReproduction,
  getEventRehearsalBootstrap,
  getEventRehearsalGuestBootstrap,
  injectEventRehearsalBehavior,
  resetEventRehearsal,
  rotateEventRehearsalGuestLink,
  submitEventRehearsalGuestAction,
  updateEventRehearsalSetup,
} from "./eventRehearsal/handlers";
export {
  onEventParticipationRosterProjected,
} from "./events/eventAttendeeProjection";
export {selfCheckInAttendance} from "./events/selfCheckInAttendance";
export {createEventVenueSession} from "./events/venueSessions";
export {
  createEvent,
  updateEvent,
  cancelEvent,
  deleteEvent,
} from "./events/mutateEvent";
export {publishEventLivePosition} from "./events/eventLivePositions";
export {sendEventReminders} from "./events/sendEventReminders";
export {sendEventBroadcast} from "./events/sendEventBroadcast";
export {
  placeDetails,
  placesAutocomplete,
} from "./places/placeAutocomplete";
export {createOrganizer} from "./organizers/createOrganizer";
export {
  startOrganizerContactConversation,
  startOrganizerConversation,
} from "./organizers/organizerConversations";
export {syncOrganizerFollowerStats} from
  "./organizers/syncOrganizerFollowerStats";
export {syncOrganizerNextEvent} from "./organizers/syncOrganizerNextEvent";
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
export {dispatchPendingOrganizerFollowerUpdates} from
  "./organizers/organizerPostDelivery";
export {getOrganizerCrmSummary} from "./organizers/organizerCrm";
export {getEventRosterInsights} from "./organizers/eventRosterInsights";
export {
  createOrganizerContact,
  createOrganizerContactNote,
  exportOrganizerContacts,
  getOrganizerContactDetail,
  listOrganizerContacts,
  mutateOrganizerContact,
  mutateOrganizerContactNote,
} from "./organizers/organizerContacts";
export {resolveOrganizerCommunicationPlan} from
  "./organizers/organizerCommunicationPlans";
export {
  getOrganizerApplicationDetail,
  importOrganizerApplications,
  listOrganizerApplications,
  previewOrganizerApplicationImport,
  publishOrganizerApplicationForm,
  reviewOrganizerApplication,
} from "./organizers/organizerApplications";
export {
  createOrganizerForm,
  deleteOrganizerFormDraft,
  duplicateOrganizerForm,
  getOrganizerFormEditor,
  listOrganizerForms,
  listOrganizerFormTemplates,
  publishOrganizerForm,
  setOrganizerFormLifecycle,
  updateOrganizerFormDraft,
  validateOrganizerFormDraft,
} from "./organizers/organizerForms";
export {
  beginOrganizerFormResponse,
  createOrganizerFormAssetIntent,
  createOrganizerFormShareLink,
  finalizeOrganizerFormAsset,
  getOrganizerFormShareAssets,
  getPublicOrganizerForm,
  saveOrganizerFormResponseDraft,
  submitOrganizerFormResponse,
  withdrawOrganizerFormResponse,
} from "./organizers/organizerFormResponses";
export {
  getOrganizerFormAnalytics,
  getOrganizerFormResponseDetail,
  listOrganizerFormResponses,
} from "./organizers/organizerFormOperations";
export {onOrganizerFormResponseAggregated} from
  "./organizers/organizerFormAggregates";
export {
  onOrganizerFormExportRequested,
  requestOrganizerFormExport,
} from "./organizers/organizerFormExports";
export {
  convertOrganizerFormResponse,
  previewOrganizerFormConversion,
} from "./organizers/organizerFormConversions";
export {
  createOrganizerFormAutomation,
  listOrganizerFormAutomationRuns,
  onOrganizerFormResponseAutomated,
  setOrganizerFormAutomationState,
} from "./organizers/organizerFormAutomations";
export {
  getParticipantOrganizerApplicationForm,
  revokeParticipantOrganizerDataGrant,
  submitParticipantOrganizerApplication,
} from "./organizers/participantOrganizerApplications";
export {
  mergeOrganizerContacts,
  unmergeOrganizerContacts,
} from "./organizers/organizerContactMerges";
export {
  listOrganizerContactMergeCandidates,
  reviewOrganizerContactMergeCandidate,
} from "./organizers/organizerContactMergeReview";
export {
  approveOrganizerCampaign,
  cancelOrganizerCampaign,
  getOrganizerCampaignReport,
  previewOrganizerCampaign,
  upsertOrganizerCampaign,
} from "./organizers/organizerCampaigns";
export {listOrganizerCampaigns} from "./organizers/organizerSends";
export {
  dispatchOrganizerCampaign,
  dispatchScheduledOrganizerCampaigns,
} from "./organizers/organizerCampaignDispatcher";
export {
  getOrganizerWhatsappThread,
  listOrganizerWhatsappThreads,
  sendOrganizerWhatsappReply,
} from "./organizers/organizerWhatsappThreads";
export {
  completeOrganizerWhatsappConnection,
  disconnectOrganizerWhatsappConnection,
  getOrganizerMessagingSetup,
  sendOrganizerWhatsappTest,
  syncOrganizerWhatsappTemplates,
} from "./organizers/organizerMessagingSetup";
export {
  connectOrganizerLumaProvider,
  disconnectOrganizerProvider,
  getOrganizerProviderSetup,
  listOrganizerLumaEvents,
  syncOrganizerProviderEvent,
} from "./organizers/organizerProviderSetup";
export {
  onOrganizerMessagingWebhookEventCreated,
  organizerWhatsappWebhook,
} from "./organizers/organizerWhatsappWebhook";
export {
  onEventAttendeeAudienceProjected,
  onOrganizerCommunicationPreferenceAudienceProjected,
} from "./organizers/organizerAudienceProjection";
export {
  adminDecideOrganizerClaim,
  requestOrganizerClaim,
} from "./organizers/organizerClaims";
export {onSwipeCreated} from "./matching/onSwipeCreated";
export {fetchSwipeCandidates} from "./matching/fetchSwipeCandidates";
export {onMatchCreated} from "./matching/onMatchCreated";
export {onMessageCreated} from "./matching/onMessageCreated";
export {
  onEventInviteLinkWritten,
  onEventParticipationWritten,
  onEventSuccessConversationGraphWritten,
  onEventSuccessFeedbackWritten,
  onEventWaitlistOfferWritten,
  onPaymentWritten,
} from "./marketplace/eventSuccessScorecards";
export {
  getEventSuccessConversationGraph,
  submitEventSuccessConversationGraph,
} from "./eventSuccess/conversationGraph";
export {
  generateEventSuccessPods,
  overrideEventSuccessGroups,
} from "./eventSuccess/generateEventSuccessPods";
export {
  generateEventSuccessRotations,
  overrideEventSuccessRotations,
} from "./eventSuccess/generateEventSuccessRotations";
export {
  controlEventSuccessLive,
  publishEventSuccessRotationRound,
} from "./eventSuccess/liveControl";
export {setEventSuccessAccountabilityResolution} from
  "./eventSuccess/accountability";
export {
  getEventSuccessPresenceSummary,
  heartbeatEventSuccessPresence,
} from "./eventSuccess/presence";
export {resolveEventSuccessLateArrival} from
  "./eventSuccess/lateArrivals";
export {recordEventSuccessUnitOutcomes} from
  "./eventSuccess/unitOutcomes";
export {onEventSuccessPlanLiveControlUpdated} from
  "./eventSuccess/rotationDraftTrigger";
export {
  controlEventSuccessSpatial,
  getEventSuccessSpatialLayout,
  upsertEventSuccessLayout,
} from "./eventSuccess/layoutAssets";
export {
  fetchEventSuccessWingmanCandidates,
  submitEventSuccessWingmanRequest,
  withdrawEventSuccessWingmanRequest,
} from "./eventSuccess/wingmanRequests";
export {
  completeEventSuccessFirstHelloMission,
  startEventSuccessFirstHelloMission,
} from "./eventSuccess/firstHelloCheckIn";
export {syncOrganizerReviewStats} from "./reviews/syncOrganizerReviewStats";
export {
  createEventReview,
  createPublicOrganizerReview,
  deleteEventReview,
  listPublicOrganizerReviews,
  setReviewResponse,
  updateEventReview,
} from "./reviews/mutateReview";
export {
  syncHostProfile,
  syncPublicProfile,
} from "./profiles/syncPublicProfile";
export {updateUserProfile} from "./profiles/updateUserProfile";
export {setCrossPathsEventConsent} from
  "./crossPaths/setCrossPathsEventConsent";
export {getCrossPathsSuggestions} from
  "./crossPaths/getCrossPathsSuggestions";
export {
  cancelCrossPathsInvitationOrPlan,
  expireCrossPathsInvitations,
  onCrossPathsBlockCreated,
  onCrossPathsConsentWritten,
  onCrossPathsEventWritten,
  onCrossPathsParticipationWritten,
  respondCrossPathsInvitation,
  sendCrossPathsInvitation,
} from "./crossPaths/invitations";
export {expireCrossPathsPairHolds} from "./crossPaths/pairHolds";
export {
  generateProfilePhotoThumbnail,
} from "./profiles/generateProfilePhotoThumbnail";
export {
  generateOrganizerLogoThumbnail,
} from "./organizers/generateOrganizerLogoThumbnail";
export {
  generateEventMediaThumbnails,
  generateOrganizerMediaThumbnails,
} from "./media/generateAttachedMediaThumbnails";
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
  adminGetOrganizerClaimRequestDetails,
  adminListOrganizerClaimRequests,
} from "./admin/clubClaimReview";
export {
  adminSetOrganizerIndexStatus,
} from "./admin/clubIndexing";
export {
  adminListCrossPathsShowcaseCandidates,
  adminSetCrossPathsShowcaseEligibility,
} from "./admin/crossPathsShowcaseEligibility";
export {
  adminGetOrganizerDetails,
  adminListOrganizerDetails,
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
  adminTakedownExternalEvent,
} from "./admin/externalEventTakedown";
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
  adminCreateOrganizerDraftFromCandidate,
} from "./admin/organizerDraftFromCandidate";
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
