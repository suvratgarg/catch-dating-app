/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import Ajv, {ValidateFunction} from "ajv";
import addFormats from "ajv-formats";
import {OperationRun} from "./operationRunContract";
import {OperationWorkItem} from "./operationWorkItemContract";
import {ProfilePromptAnswer} from "./profilePromptAnswer";
import {PhotoPromptAnswer} from "./photoPromptAnswer";
import {ProfilePhoto} from "./profilePhoto";
import {UploadedPhoto} from "./uploadedPhoto";
import {ActivityPreferences} from "./activityPreferences";
import {ConfigCitiesDocument} from "./configCitiesDocument";
import {OnboardingDraftDocument} from "./onboardingDraftDocument";
import {UserProfileDocument} from "./userProfileDocument";
import {PublicProfileDocument} from "./publicProfileDocument";
import {HostProfileDocument} from "./hostProfileDocument";
import {ClubDocument} from "./clubDocument";
import {ClubPostDocument} from "./clubPostDocument";
import {ClubMembershipDocument} from "./clubMembershipDocument";
import {ClubHostClaimDocument} from "./clubHostClaimDocument";
import {ClubClaimRequestDocument} from "./clubClaimRequestDocument";
import {EventDocument} from "./eventDocument";
import {ExternalEventDocument} from "./externalEventDocument";
import {EventPrivateAccessDocument} from "./eventPrivateAccessDocument";
import {EventInviteLinkDocument} from "./eventInviteLinkDocument";
import {EventParticipationDocument} from "./eventParticipationDocument";
import {EventBroadcastDocument} from "./eventBroadcastDocument";
import {EventWaitlistOfferDocument} from "./eventWaitlistOfferDocument";
import {EventSuccessPlanDocument} from "./eventSuccessPlanDocument";
import {EventSuccessFeedbackDocument} from "./eventSuccessFeedbackDocument";
import {EventSuccessPreferenceDocument} from "./eventSuccessPreferenceDocument";
import {EventSuccessCompatibilityResponseDocument} from "./eventSuccessCompatibilityResponseDocument";
import {EventSuccessWingmanRequestDocument} from "./eventSuccessWingmanRequestDocument";
import {EventSuccessArrivalMissionDocument} from "./eventSuccessArrivalMissionDocument";
import {EventSuccessAssignmentDocument} from "./eventSuccessAssignmentDocument";
import {EventSuccessScorecardDocument} from "./eventSuccessScorecardDocument";
import {EventSafetyReportDocument} from "./eventSafetyReportDocument";
import {ClubScheduleLockDocument} from "./clubScheduleLockDocument";
import {UserEventScheduleLockDocument} from "./userEventScheduleLockDocument";
import {SavedEventDocument} from "./savedEventDocument";
import {HostAnalyticsEvent} from "./hostAnalyticsEvent";
import {UserProfileExposureEvent} from "./userProfileExposureEvent";
import {PaymentDocument} from "./paymentDocument";
import {HostPaymentAccountDocument} from "./hostPaymentAccountDocument";
import {RazorpayPendingOrderDocument} from "./razorpayPendingOrderDocument";
import {SwipeDocument} from "./swipeDocument";
import {MatchDocument} from "./matchDocument";
import {ChatMessageDocument} from "./chatMessageDocument";
import {ActivityNotificationDocument} from "./activityNotificationDocument";
import {ReviewDocument} from "./reviewDocument";
import {BlockDocument} from "./blockDocument";
import {ReportDocument} from "./reportDocument";
import {ModerationFlagDocument} from "./moderationFlagDocument";
import {DeletedUserTombstoneDocument} from "./deletedUserTombstoneDocument";
import {RateLimitDocument} from "./rateLimitDocument";
import {FunctionEventReceiptDocument} from "./functionEventReceiptDocument";
import {PublicRouteReservationDocument} from "./publicRouteReservationDocument";
import {SeedEventManifestDocument} from "./seedEventManifestDocument";
import {OrganizerIntakeReviewDecisionDocument} from "./organizerIntakeReviewDecisionDocument";
import {EventIntakeReviewDecisionDocument} from "./eventIntakeReviewDecisionDocument";
import {OrganizerIntakeCurationDecisionDocument} from "./organizerIntakeCurationDecisionDocument";
import {OrganizerEventCandidateReviewDecisionDocument} from "./organizerEventCandidateReviewDecisionDocument";
import {OrganizerEventLocationResolutionDecisionDocument} from "./organizerEventLocationResolutionDecisionDocument";
import {OrganizerPolicyGapReviewDecisionDocument} from "./organizerPolicyGapReviewDecisionDocument";
import {UpdateUserProfileCallablePayload} from "./updateUserProfileCallablePayload";
import {CreateClubCallablePayload} from "./createClubCallablePayload";
import {CreateClubCallableResponse} from "./createClubCallableResponse";
import {CreateClubPostCallablePayload} from "./createClubPostCallablePayload";
import {CreateClubPostCallableResponse} from "./createClubPostCallableResponse";
import {SendEventBroadcastCallablePayload} from "./sendEventBroadcastCallablePayload";
import {SendEventBroadcastCallableResponse} from "./sendEventBroadcastCallableResponse";
import {UpdateClubCallablePayload} from "./updateClubCallablePayload";
import {HostAnalyticsQueryCallablePayload} from "./hostAnalyticsQueryCallablePayload";
import {HostAnalyticsCallableResponse} from "./hostAnalyticsCallableResponse";
import {UserAnalyticsQueryCallablePayload} from "./userAnalyticsQueryCallablePayload";
import {UserAnalyticsCallableResponse} from "./userAnalyticsCallableResponse";
import {AddClubHostCallablePayload} from "./addClubHostCallablePayload";
import {RemoveClubHostCallablePayload} from "./removeClubHostCallablePayload";
import {TransferClubOwnershipCallablePayload} from "./transferClubOwnershipCallablePayload";
import {RequestClubClaimCallablePayload} from "./requestClubClaimCallablePayload";
import {RequestClubClaimCallableResponse} from "./requestClubClaimCallableResponse";
import {AdminDecideClubClaimCallablePayload} from "./adminDecideClubClaimCallablePayload";
import {AdminDecideOrganizerIntakeCallablePayload} from "./adminDecideOrganizerIntakeCallablePayload";
import {AdminRecordOrganizerCurationCallablePayload} from "./adminRecordOrganizerCurationCallablePayload";
import {AdminRecordEventIntakeReviewDecisionCallablePayload} from "./adminRecordEventIntakeReviewDecisionCallablePayload";
import {AdminListIntakeOperationsCallablePayload} from "./adminListIntakeOperationsCallablePayload";
import {AdminDecideOrganizerEventCandidateCallablePayload} from "./adminDecideOrganizerEventCandidateCallablePayload";
import {AdminDecideOrganizerPolicyGapCallablePayload} from "./adminDecideOrganizerPolicyGapCallablePayload";
import {AdminResolveOrganizerEventLocationCallablePayload} from "./adminResolveOrganizerEventLocationCallablePayload";
import {AdminSetClubIndexStatusCallablePayload} from "./adminSetClubIndexStatusCallablePayload";
import {AdminGetClubDetailsCallablePayload} from "./adminGetClubDetailsCallablePayload";
import {AdminListClubDetailsCallablePayload} from "./adminListClubDetailsCallablePayload";
import {AdminUpdateClubDetailsCallablePayload} from "./adminUpdateClubDetailsCallablePayload";
import {AdminGetEventDetailsCallablePayload} from "./adminGetEventDetailsCallablePayload";
import {AdminListEventDetailsCallablePayload} from "./adminListEventDetailsCallablePayload";
import {AdminListExternalEventDetailsCallablePayload} from "./adminListExternalEventDetailsCallablePayload";
import {AdminUpdateEventDetailsCallablePayload} from "./adminUpdateEventDetailsCallablePayload";
import {AdminPublishExternalEventCallablePayload} from "./adminPublishExternalEventCallablePayload";
import {StartClubHostConversationCallablePayload} from "./startClubHostConversationCallablePayload";
import {ArchiveClubCallablePayload} from "./archiveClubCallablePayload";
import {DeleteClubCallablePayload} from "./deleteClubCallablePayload";
import {ClubMembershipCallablePayload} from "./clubMembershipCallablePayload";
import {SetClubNotificationPreferenceCallablePayload} from "./setClubNotificationPreferenceCallablePayload";
import {CreateEventCallablePayload} from "./createEventCallablePayload";
import {UpdateEventCallablePayload} from "./updateEventCallablePayload";
import {CancelEventCallablePayload} from "./cancelEventCallablePayload";
import {DeleteEventCallablePayload} from "./deleteEventCallablePayload";
import {EventIdCallablePayload} from "./eventIdCallablePayload";
import {CreateEventWaitlistOffersCallablePayload} from "./createEventWaitlistOffersCallablePayload";
import {CreateEventInviteLinkCallablePayload} from "./createEventInviteLinkCallablePayload";
import {DisableEventInviteLinkCallablePayload} from "./disableEventInviteLinkCallablePayload";
import {RecordEventInviteLinkOpenCallablePayload} from "./recordEventInviteLinkOpenCallablePayload";
import {RecordOrganizerAnalyticsEventCallablePayload} from "./recordOrganizerAnalyticsEventCallablePayload";
import {RecordOrganizerAnalyticsEventCallableResponse} from "./recordOrganizerAnalyticsEventCallableResponse";
import {MarkEventAttendanceCallablePayload} from "./markEventAttendanceCallablePayload";
import {EventJoinRequestDecisionCallablePayload} from "./eventJoinRequestDecisionCallablePayload";
import {OverrideEventSuccessRotationsCallablePayload} from "./overrideEventSuccessRotationsCallablePayload";
import {OverrideEventSuccessGroupsCallablePayload} from "./overrideEventSuccessGroupsCallablePayload";
import {SubmitEventSuccessWingmanRequestCallablePayload} from "./submitEventSuccessWingmanRequestCallablePayload";
import {StartEventSuccessFirstHelloMissionCallablePayload} from "./startEventSuccessFirstHelloMissionCallablePayload";
import {CompleteEventSuccessFirstHelloMissionCallablePayload} from "./completeEventSuccessFirstHelloMissionCallablePayload";
import {MarkEventAttendanceCallableResponse} from "./markEventAttendanceCallableResponse";
import {SelfCheckInAttendanceCallablePayload} from "./selfCheckInAttendanceCallablePayload";
import {CreateEventReviewCallablePayload} from "./createEventReviewCallablePayload";
import {CreatePublicClubReviewCallablePayload} from "./createPublicClubReviewCallablePayload";
import {CreatePublicClubReviewCallableResponse} from "./createPublicClubReviewCallableResponse";
import {ListPublicClubReviewsCallablePayload} from "./listPublicClubReviewsCallablePayload";
import {ListPublicClubReviewsCallableResponse} from "./listPublicClubReviewsCallableResponse";
import {UpdateEventReviewCallablePayload} from "./updateEventReviewCallablePayload";
import {DeleteEventReviewCallablePayload} from "./deleteEventReviewCallablePayload";
import {SetReviewResponseCallablePayload} from "./setReviewResponseCallablePayload";
import {BlockUserCallablePayload} from "./blockUserCallablePayload";
import {UnblockUserCallablePayload} from "./unblockUserCallablePayload";
import {ReportUserCallablePayload} from "./reportUserCallablePayload";
import {RequestSuvbotDemoOperationCallablePayload} from "./requestSuvbotDemoOperationCallablePayload";
import {ListSuvbotDemoActionsCallableResponse} from "./listSuvbotDemoActionsCallableResponse";
import {VerifyRazorpayPaymentCallablePayload} from "./verifyRazorpayPaymentCallablePayload";
import {EventBookingCallablePayload} from "./eventBookingCallablePayload";
import {CreateRazorpayOrderCallablePayload} from "./createRazorpayOrderCallablePayload";
import {RazorpayOrderCallableResponse} from "./razorpayOrderCallableResponse";
import {CreateStripeCheckoutSessionCallablePayload} from "./createStripeCheckoutSessionCallablePayload";
import {StripeCheckoutSessionCallableResponse} from "./stripeCheckoutSessionCallableResponse";
import {CreateStripeHostOnboardingLinkCallablePayload} from "./createStripeHostOnboardingLinkCallablePayload";
import {RefreshStripeHostPaymentAccountCallablePayload} from "./refreshStripeHostPaymentAccountCallablePayload";
import {StripeHostOnboardingLinkCallableResponse} from "./stripeHostOnboardingLinkCallableResponse";
import {PlacesAutocompleteCallablePayload} from "./placesAutocompleteCallablePayload";
import {PlacesAutocompleteCallableResponse} from "./placesAutocompleteCallableResponse";
import {PlaceDetailsCallablePayload} from "./placeDetailsCallablePayload";
import {PlaceDetailsCallableResponse} from "./placeDetailsCallableResponse";
import {ExploreSearchCallablePayload} from "./exploreSearchCallablePayload";
import {ExploreSearchCallableResponse} from "./exploreSearchCallableResponse";
import {WebsiteHostListingProjection} from "./websiteHostListingProjection";
import {FetchEventSuccessWingmanCandidatesCallableResponse} from "./fetchEventSuccessWingmanCandidatesCallableResponse";
import {CreateProfileDecisionClientWrite} from "./createProfileDecisionClientWrite";
import {CreateChatMessageClientWrite} from "./createChatMessageClientWrite";
import {CreateSavedEventClientWrite} from "./createSavedEventClientWrite";
import {DeleteSavedEventClientWrite} from "./deleteSavedEventClientWrite";
import {MarkNotificationReadClientWrite} from "./markNotificationReadClientWrite";
import {ResetMatchUnreadCountClientWrite} from "./resetMatchUnreadCountClientWrite";
import {
  operationRunSchema,
  operationWorkItemSchema,
  profilePromptAnswerSchema,
  photoPromptAnswerSchema,
  profilePhotoSchema,
  uploadedPhotoSchema,
  activityPreferencesSchema,
  configCitiesDocumentSchema,
  onboardingDraftDocumentSchema,
  userProfileDocumentSchema,
  publicProfileDocumentSchema,
  hostProfileDocumentSchema,
  clubDocumentSchema,
  clubPostDocumentSchema,
  clubMembershipDocumentSchema,
  clubHostClaimDocumentSchema,
  clubClaimRequestDocumentSchema,
  eventDocumentSchema,
  externalEventDocumentSchema,
  eventPrivateAccessDocumentSchema,
  eventInviteLinkDocumentSchema,
  eventParticipationDocumentSchema,
  eventBroadcastDocumentSchema,
  eventWaitlistOfferDocumentSchema,
  eventSuccessPlanDocumentSchema,
  eventSuccessFeedbackDocumentSchema,
  eventSuccessPreferenceDocumentSchema,
  eventSuccessCompatibilityResponseDocumentSchema,
  eventSuccessWingmanRequestDocumentSchema,
  eventSuccessArrivalMissionDocumentSchema,
  eventSuccessAssignmentDocumentSchema,
  eventSuccessScorecardDocumentSchema,
  eventSafetyReportDocumentSchema,
  clubScheduleLockDocumentSchema,
  userEventScheduleLockDocumentSchema,
  savedEventDocumentSchema,
  hostAnalyticsEventSchema,
  userProfileExposureEventSchema,
  paymentDocumentSchema,
  hostPaymentAccountDocumentSchema,
  razorpayPendingOrderDocumentSchema,
  swipeDocumentSchema,
  matchDocumentSchema,
  chatMessageDocumentSchema,
  activityNotificationDocumentSchema,
  reviewDocumentSchema,
  blockDocumentSchema,
  reportDocumentSchema,
  moderationFlagDocumentSchema,
  deletedUserTombstoneDocumentSchema,
  rateLimitDocumentSchema,
  functionEventReceiptDocumentSchema,
  publicRouteReservationDocumentSchema,
  seedEventManifestDocumentSchema,
  organizerIntakeReviewDecisionDocumentSchema,
  eventIntakeReviewDecisionDocumentSchema,
  organizerIntakeCurationDecisionDocumentSchema,
  organizerEventCandidateReviewDecisionDocumentSchema,
  organizerEventLocationResolutionDecisionDocumentSchema,
  organizerPolicyGapReviewDecisionDocumentSchema,
  updateUserProfileCallablePayloadSchema,
  createClubCallablePayloadSchema,
  createClubCallableResponseSchema,
  createClubPostCallablePayloadSchema,
  createClubPostCallableResponseSchema,
  sendEventBroadcastCallablePayloadSchema,
  sendEventBroadcastCallableResponseSchema,
  updateClubCallablePayloadSchema,
  hostAnalyticsQueryCallablePayloadSchema,
  hostAnalyticsCallableResponseSchema,
  userAnalyticsQueryCallablePayloadSchema,
  userAnalyticsCallableResponseSchema,
  addClubHostCallablePayloadSchema,
  removeClubHostCallablePayloadSchema,
  transferClubOwnershipCallablePayloadSchema,
  requestClubClaimCallablePayloadSchema,
  requestClubClaimCallableResponseSchema,
  adminDecideClubClaimCallablePayloadSchema,
  adminDecideOrganizerIntakeCallablePayloadSchema,
  adminRecordOrganizerCurationCallablePayloadSchema,
  adminRecordEventIntakeReviewDecisionCallablePayloadSchema,
  adminListIntakeOperationsCallablePayloadSchema,
  adminDecideOrganizerEventCandidateCallablePayloadSchema,
  adminDecideOrganizerPolicyGapCallablePayloadSchema,
  adminResolveOrganizerEventLocationCallablePayloadSchema,
  adminSetClubIndexStatusCallablePayloadSchema,
  adminGetClubDetailsCallablePayloadSchema,
  adminListClubDetailsCallablePayloadSchema,
  adminUpdateClubDetailsCallablePayloadSchema,
  adminGetEventDetailsCallablePayloadSchema,
  adminListEventDetailsCallablePayloadSchema,
  adminListExternalEventDetailsCallablePayloadSchema,
  adminUpdateEventDetailsCallablePayloadSchema,
  adminPublishExternalEventCallablePayloadSchema,
  startClubHostConversationCallablePayloadSchema,
  archiveClubCallablePayloadSchema,
  deleteClubCallablePayloadSchema,
  clubMembershipCallablePayloadSchema,
  setClubNotificationPreferenceCallablePayloadSchema,
  createEventCallablePayloadSchema,
  updateEventCallablePayloadSchema,
  cancelEventCallablePayloadSchema,
  deleteEventCallablePayloadSchema,
  eventIdCallablePayloadSchema,
  createEventWaitlistOffersCallablePayloadSchema,
  createEventInviteLinkCallablePayloadSchema,
  disableEventInviteLinkCallablePayloadSchema,
  recordEventInviteLinkOpenCallablePayloadSchema,
  recordOrganizerAnalyticsEventCallablePayloadSchema,
  recordOrganizerAnalyticsEventCallableResponseSchema,
  markEventAttendanceCallablePayloadSchema,
  eventJoinRequestDecisionCallablePayloadSchema,
  overrideEventSuccessRotationsCallablePayloadSchema,
  overrideEventSuccessGroupsCallablePayloadSchema,
  submitEventSuccessWingmanRequestCallablePayloadSchema,
  startEventSuccessFirstHelloMissionCallablePayloadSchema,
  completeEventSuccessFirstHelloMissionCallablePayloadSchema,
  markEventAttendanceCallableResponseSchema,
  selfCheckInAttendanceCallablePayloadSchema,
  createEventReviewCallablePayloadSchema,
  createPublicClubReviewCallablePayloadSchema,
  createPublicClubReviewCallableResponseSchema,
  listPublicClubReviewsCallablePayloadSchema,
  listPublicClubReviewsCallableResponseSchema,
  updateEventReviewCallablePayloadSchema,
  deleteEventReviewCallablePayloadSchema,
  setReviewResponseCallablePayloadSchema,
  blockUserCallablePayloadSchema,
  unblockUserCallablePayloadSchema,
  reportUserCallablePayloadSchema,
  requestSuvbotDemoOperationCallablePayloadSchema,
  listSuvbotDemoActionsCallableResponseSchema,
  verifyRazorpayPaymentCallablePayloadSchema,
  eventBookingCallablePayloadSchema,
  createRazorpayOrderCallablePayloadSchema,
  razorpayOrderCallableResponseSchema,
  createStripeCheckoutSessionCallablePayloadSchema,
  stripeCheckoutSessionCallableResponseSchema,
  createStripeHostOnboardingLinkCallablePayloadSchema,
  refreshStripeHostPaymentAccountCallablePayloadSchema,
  stripeHostOnboardingLinkCallableResponseSchema,
  placesAutocompleteCallablePayloadSchema,
  placesAutocompleteCallableResponseSchema,
  placeDetailsCallablePayloadSchema,
  placeDetailsCallableResponseSchema,
  exploreSearchCallablePayloadSchema,
  exploreSearchCallableResponseSchema,
  websiteHostListingProjectionSchema,
  fetchEventSuccessWingmanCandidatesCallableResponseSchema,
  createProfileDecisionClientWriteSchema,
  createChatMessageClientWriteSchema,
  createSavedEventClientWriteSchema,
  deleteSavedEventClientWriteSchema,
  markNotificationReadClientWriteSchema,
  resetMatchUnreadCountClientWriteSchema,
} from "./schemaRegistry";

const ajv = new Ajv({allErrors: true, strict: false});
addFormats(ajv);

export const validateOperationRun:
  ValidateFunction<OperationRun> =
    ajv.compile(operationRunSchema) as
      ValidateFunction<OperationRun>;
export const validateOperationWorkItem:
  ValidateFunction<OperationWorkItem> =
    ajv.compile(operationWorkItemSchema) as
      ValidateFunction<OperationWorkItem>;
export const validateProfilePromptAnswer:
  ValidateFunction<ProfilePromptAnswer> =
    ajv.compile(profilePromptAnswerSchema) as
      ValidateFunction<ProfilePromptAnswer>;
export const validatePhotoPromptAnswer:
  ValidateFunction<PhotoPromptAnswer> =
    ajv.compile(photoPromptAnswerSchema) as
      ValidateFunction<PhotoPromptAnswer>;
export const validateProfilePhoto:
  ValidateFunction<ProfilePhoto> =
    ajv.compile(profilePhotoSchema) as
      ValidateFunction<ProfilePhoto>;
export const validateUploadedPhoto:
  ValidateFunction<UploadedPhoto> =
    ajv.compile(uploadedPhotoSchema) as
      ValidateFunction<UploadedPhoto>;
export const validateActivityPreferences:
  ValidateFunction<ActivityPreferences> =
    ajv.compile(activityPreferencesSchema) as
      ValidateFunction<ActivityPreferences>;
export const validateConfigCitiesDocument:
  ValidateFunction<ConfigCitiesDocument> =
    ajv.compile(configCitiesDocumentSchema) as
      ValidateFunction<ConfigCitiesDocument>;
export const validateOnboardingDraftDocument:
  ValidateFunction<OnboardingDraftDocument> =
    ajv.compile(onboardingDraftDocumentSchema) as
      ValidateFunction<OnboardingDraftDocument>;
export const validateUserProfileDocument:
  ValidateFunction<UserProfileDocument> =
    ajv.compile(userProfileDocumentSchema) as
      ValidateFunction<UserProfileDocument>;
export const validatePublicProfileDocument:
  ValidateFunction<PublicProfileDocument> =
    ajv.compile(publicProfileDocumentSchema) as
      ValidateFunction<PublicProfileDocument>;
export const validateHostProfileDocument:
  ValidateFunction<HostProfileDocument> =
    ajv.compile(hostProfileDocumentSchema) as
      ValidateFunction<HostProfileDocument>;
export const validateClubDocument:
  ValidateFunction<ClubDocument> =
    ajv.compile(clubDocumentSchema) as
      ValidateFunction<ClubDocument>;
export const validateClubPostDocument:
  ValidateFunction<ClubPostDocument> =
    ajv.compile(clubPostDocumentSchema) as
      ValidateFunction<ClubPostDocument>;
export const validateClubMembershipDocument:
  ValidateFunction<ClubMembershipDocument> =
    ajv.compile(clubMembershipDocumentSchema) as
      ValidateFunction<ClubMembershipDocument>;
export const validateClubHostClaimDocument:
  ValidateFunction<ClubHostClaimDocument> =
    ajv.compile(clubHostClaimDocumentSchema) as
      ValidateFunction<ClubHostClaimDocument>;
export const validateClubClaimRequestDocument:
  ValidateFunction<ClubClaimRequestDocument> =
    ajv.compile(clubClaimRequestDocumentSchema) as
      ValidateFunction<ClubClaimRequestDocument>;
export const validateEventDocument:
  ValidateFunction<EventDocument> =
    ajv.compile(eventDocumentSchema) as
      ValidateFunction<EventDocument>;
export const validateExternalEventDocument:
  ValidateFunction<ExternalEventDocument> =
    ajv.compile(externalEventDocumentSchema) as
      ValidateFunction<ExternalEventDocument>;
export const validateEventPrivateAccessDocument:
  ValidateFunction<EventPrivateAccessDocument> =
    ajv.compile(eventPrivateAccessDocumentSchema) as
      ValidateFunction<EventPrivateAccessDocument>;
export const validateEventInviteLinkDocument:
  ValidateFunction<EventInviteLinkDocument> =
    ajv.compile(eventInviteLinkDocumentSchema) as
      ValidateFunction<EventInviteLinkDocument>;
export const validateEventParticipationDocument:
  ValidateFunction<EventParticipationDocument> =
    ajv.compile(eventParticipationDocumentSchema) as
      ValidateFunction<EventParticipationDocument>;
export const validateEventBroadcastDocument:
  ValidateFunction<EventBroadcastDocument> =
    ajv.compile(eventBroadcastDocumentSchema) as
      ValidateFunction<EventBroadcastDocument>;
export const validateEventWaitlistOfferDocument:
  ValidateFunction<EventWaitlistOfferDocument> =
    ajv.compile(eventWaitlistOfferDocumentSchema) as
      ValidateFunction<EventWaitlistOfferDocument>;
export const validateEventSuccessPlanDocument:
  ValidateFunction<EventSuccessPlanDocument> =
    ajv.compile(eventSuccessPlanDocumentSchema) as
      ValidateFunction<EventSuccessPlanDocument>;
export const validateEventSuccessFeedbackDocument:
  ValidateFunction<EventSuccessFeedbackDocument> =
    ajv.compile(eventSuccessFeedbackDocumentSchema) as
      ValidateFunction<EventSuccessFeedbackDocument>;
export const validateEventSuccessPreferenceDocument:
  ValidateFunction<EventSuccessPreferenceDocument> =
    ajv.compile(eventSuccessPreferenceDocumentSchema) as
      ValidateFunction<EventSuccessPreferenceDocument>;
export const validateEventSuccessCompatibilityResponseDocument:
  ValidateFunction<EventSuccessCompatibilityResponseDocument> =
    ajv.compile(eventSuccessCompatibilityResponseDocumentSchema) as
      ValidateFunction<EventSuccessCompatibilityResponseDocument>;
export const validateEventSuccessWingmanRequestDocument:
  ValidateFunction<EventSuccessWingmanRequestDocument> =
    ajv.compile(eventSuccessWingmanRequestDocumentSchema) as
      ValidateFunction<EventSuccessWingmanRequestDocument>;
export const validateEventSuccessArrivalMissionDocument:
  ValidateFunction<EventSuccessArrivalMissionDocument> =
    ajv.compile(eventSuccessArrivalMissionDocumentSchema) as
      ValidateFunction<EventSuccessArrivalMissionDocument>;
export const validateEventSuccessAssignmentDocument:
  ValidateFunction<EventSuccessAssignmentDocument> =
    ajv.compile(eventSuccessAssignmentDocumentSchema) as
      ValidateFunction<EventSuccessAssignmentDocument>;
export const validateEventSuccessScorecardDocument:
  ValidateFunction<EventSuccessScorecardDocument> =
    ajv.compile(eventSuccessScorecardDocumentSchema) as
      ValidateFunction<EventSuccessScorecardDocument>;
export const validateEventSafetyReportDocument:
  ValidateFunction<EventSafetyReportDocument> =
    ajv.compile(eventSafetyReportDocumentSchema) as
      ValidateFunction<EventSafetyReportDocument>;
export const validateClubScheduleLockDocument:
  ValidateFunction<ClubScheduleLockDocument> =
    ajv.compile(clubScheduleLockDocumentSchema) as
      ValidateFunction<ClubScheduleLockDocument>;
export const validateUserEventScheduleLockDocument:
  ValidateFunction<UserEventScheduleLockDocument> =
    ajv.compile(userEventScheduleLockDocumentSchema) as
      ValidateFunction<UserEventScheduleLockDocument>;
export const validateSavedEventDocument:
  ValidateFunction<SavedEventDocument> =
    ajv.compile(savedEventDocumentSchema) as
      ValidateFunction<SavedEventDocument>;
export const validateHostAnalyticsEvent:
  ValidateFunction<HostAnalyticsEvent> =
    ajv.compile(hostAnalyticsEventSchema) as
      ValidateFunction<HostAnalyticsEvent>;
export const validateUserProfileExposureEvent:
  ValidateFunction<UserProfileExposureEvent> =
    ajv.compile(userProfileExposureEventSchema) as
      ValidateFunction<UserProfileExposureEvent>;
export const validatePaymentDocument:
  ValidateFunction<PaymentDocument> =
    ajv.compile(paymentDocumentSchema) as
      ValidateFunction<PaymentDocument>;
export const validateHostPaymentAccountDocument:
  ValidateFunction<HostPaymentAccountDocument> =
    ajv.compile(hostPaymentAccountDocumentSchema) as
      ValidateFunction<HostPaymentAccountDocument>;
export const validateRazorpayPendingOrderDocument:
  ValidateFunction<RazorpayPendingOrderDocument> =
    ajv.compile(razorpayPendingOrderDocumentSchema) as
      ValidateFunction<RazorpayPendingOrderDocument>;
export const validateSwipeDocument:
  ValidateFunction<SwipeDocument> =
    ajv.compile(swipeDocumentSchema) as
      ValidateFunction<SwipeDocument>;
export const validateMatchDocument:
  ValidateFunction<MatchDocument> =
    ajv.compile(matchDocumentSchema) as
      ValidateFunction<MatchDocument>;
export const validateChatMessageDocument:
  ValidateFunction<ChatMessageDocument> =
    ajv.compile(chatMessageDocumentSchema) as
      ValidateFunction<ChatMessageDocument>;
export const validateActivityNotificationDocument:
  ValidateFunction<ActivityNotificationDocument> =
    ajv.compile(activityNotificationDocumentSchema) as
      ValidateFunction<ActivityNotificationDocument>;
export const validateReviewDocument:
  ValidateFunction<ReviewDocument> =
    ajv.compile(reviewDocumentSchema) as
      ValidateFunction<ReviewDocument>;
export const validateBlockDocument:
  ValidateFunction<BlockDocument> =
    ajv.compile(blockDocumentSchema) as
      ValidateFunction<BlockDocument>;
export const validateReportDocument:
  ValidateFunction<ReportDocument> =
    ajv.compile(reportDocumentSchema) as
      ValidateFunction<ReportDocument>;
export const validateModerationFlagDocument:
  ValidateFunction<ModerationFlagDocument> =
    ajv.compile(moderationFlagDocumentSchema) as
      ValidateFunction<ModerationFlagDocument>;
export const validateDeletedUserTombstoneDocument:
  ValidateFunction<DeletedUserTombstoneDocument> =
    ajv.compile(deletedUserTombstoneDocumentSchema) as
      ValidateFunction<DeletedUserTombstoneDocument>;
export const validateRateLimitDocument:
  ValidateFunction<RateLimitDocument> =
    ajv.compile(rateLimitDocumentSchema) as
      ValidateFunction<RateLimitDocument>;
export const validateFunctionEventReceiptDocument:
  ValidateFunction<FunctionEventReceiptDocument> =
    ajv.compile(functionEventReceiptDocumentSchema) as
      ValidateFunction<FunctionEventReceiptDocument>;
export const validatePublicRouteReservationDocument:
  ValidateFunction<PublicRouteReservationDocument> =
    ajv.compile(publicRouteReservationDocumentSchema) as
      ValidateFunction<PublicRouteReservationDocument>;
export const validateSeedEventManifestDocument:
  ValidateFunction<SeedEventManifestDocument> =
    ajv.compile(seedEventManifestDocumentSchema) as
      ValidateFunction<SeedEventManifestDocument>;
export const validateOrganizerIntakeReviewDecisionDocument:
  ValidateFunction<OrganizerIntakeReviewDecisionDocument> =
    ajv.compile(organizerIntakeReviewDecisionDocumentSchema) as
      ValidateFunction<OrganizerIntakeReviewDecisionDocument>;
export const validateEventIntakeReviewDecisionDocument:
  ValidateFunction<EventIntakeReviewDecisionDocument> =
    ajv.compile(eventIntakeReviewDecisionDocumentSchema) as
      ValidateFunction<EventIntakeReviewDecisionDocument>;
export const validateOrganizerIntakeCurationDecisionDocument:
  ValidateFunction<OrganizerIntakeCurationDecisionDocument> =
    ajv.compile(organizerIntakeCurationDecisionDocumentSchema) as
      ValidateFunction<OrganizerIntakeCurationDecisionDocument>;
export const validateOrganizerEventCandidateReviewDecisionDocument:
  ValidateFunction<OrganizerEventCandidateReviewDecisionDocument> =
    ajv.compile(organizerEventCandidateReviewDecisionDocumentSchema) as
      ValidateFunction<OrganizerEventCandidateReviewDecisionDocument>;
export const validateOrganizerEventLocationResolutionDecisionDocument:
  ValidateFunction<OrganizerEventLocationResolutionDecisionDocument> =
    ajv.compile(organizerEventLocationResolutionDecisionDocumentSchema) as
      ValidateFunction<OrganizerEventLocationResolutionDecisionDocument>;
export const validateOrganizerPolicyGapReviewDecisionDocument:
  ValidateFunction<OrganizerPolicyGapReviewDecisionDocument> =
    ajv.compile(organizerPolicyGapReviewDecisionDocumentSchema) as
      ValidateFunction<OrganizerPolicyGapReviewDecisionDocument>;
export const validateUpdateUserProfileCallablePayload:
  ValidateFunction<UpdateUserProfileCallablePayload> =
    ajv.compile(updateUserProfileCallablePayloadSchema) as
      ValidateFunction<UpdateUserProfileCallablePayload>;
export const validateCreateClubCallablePayload:
  ValidateFunction<CreateClubCallablePayload> =
    ajv.compile(createClubCallablePayloadSchema) as
      ValidateFunction<CreateClubCallablePayload>;
export const validateCreateClubCallableResponse:
  ValidateFunction<CreateClubCallableResponse> =
    ajv.compile(createClubCallableResponseSchema) as
      ValidateFunction<CreateClubCallableResponse>;
export const validateCreateClubPostCallablePayload:
  ValidateFunction<CreateClubPostCallablePayload> =
    ajv.compile(createClubPostCallablePayloadSchema) as
      ValidateFunction<CreateClubPostCallablePayload>;
export const validateCreateClubPostCallableResponse:
  ValidateFunction<CreateClubPostCallableResponse> =
    ajv.compile(createClubPostCallableResponseSchema) as
      ValidateFunction<CreateClubPostCallableResponse>;
export const validateSendEventBroadcastCallablePayload:
  ValidateFunction<SendEventBroadcastCallablePayload> =
    ajv.compile(sendEventBroadcastCallablePayloadSchema) as
      ValidateFunction<SendEventBroadcastCallablePayload>;
export const validateSendEventBroadcastCallableResponse:
  ValidateFunction<SendEventBroadcastCallableResponse> =
    ajv.compile(sendEventBroadcastCallableResponseSchema) as
      ValidateFunction<SendEventBroadcastCallableResponse>;
export const validateUpdateClubCallablePayload:
  ValidateFunction<UpdateClubCallablePayload> =
    ajv.compile(updateClubCallablePayloadSchema) as
      ValidateFunction<UpdateClubCallablePayload>;
export const validateHostAnalyticsQueryCallablePayload:
  ValidateFunction<HostAnalyticsQueryCallablePayload> =
    ajv.compile(hostAnalyticsQueryCallablePayloadSchema) as
      ValidateFunction<HostAnalyticsQueryCallablePayload>;
export const validateHostAnalyticsCallableResponse:
  ValidateFunction<HostAnalyticsCallableResponse> =
    ajv.compile(hostAnalyticsCallableResponseSchema) as
      ValidateFunction<HostAnalyticsCallableResponse>;
export const validateUserAnalyticsQueryCallablePayload:
  ValidateFunction<UserAnalyticsQueryCallablePayload> =
    ajv.compile(userAnalyticsQueryCallablePayloadSchema) as
      ValidateFunction<UserAnalyticsQueryCallablePayload>;
export const validateUserAnalyticsCallableResponse:
  ValidateFunction<UserAnalyticsCallableResponse> =
    ajv.compile(userAnalyticsCallableResponseSchema) as
      ValidateFunction<UserAnalyticsCallableResponse>;
export const validateAddClubHostCallablePayload:
  ValidateFunction<AddClubHostCallablePayload> =
    ajv.compile(addClubHostCallablePayloadSchema) as
      ValidateFunction<AddClubHostCallablePayload>;
export const validateRemoveClubHostCallablePayload:
  ValidateFunction<RemoveClubHostCallablePayload> =
    ajv.compile(removeClubHostCallablePayloadSchema) as
      ValidateFunction<RemoveClubHostCallablePayload>;
export const validateTransferClubOwnershipCallablePayload:
  ValidateFunction<TransferClubOwnershipCallablePayload> =
    ajv.compile(transferClubOwnershipCallablePayloadSchema) as
      ValidateFunction<TransferClubOwnershipCallablePayload>;
export const validateRequestClubClaimCallablePayload:
  ValidateFunction<RequestClubClaimCallablePayload> =
    ajv.compile(requestClubClaimCallablePayloadSchema) as
      ValidateFunction<RequestClubClaimCallablePayload>;
export const validateRequestClubClaimCallableResponse:
  ValidateFunction<RequestClubClaimCallableResponse> =
    ajv.compile(requestClubClaimCallableResponseSchema) as
      ValidateFunction<RequestClubClaimCallableResponse>;
export const validateAdminDecideClubClaimCallablePayload:
  ValidateFunction<AdminDecideClubClaimCallablePayload> =
    ajv.compile(adminDecideClubClaimCallablePayloadSchema) as
      ValidateFunction<AdminDecideClubClaimCallablePayload>;
export const validateAdminDecideOrganizerIntakeCallablePayload:
  ValidateFunction<AdminDecideOrganizerIntakeCallablePayload> =
    ajv.compile(adminDecideOrganizerIntakeCallablePayloadSchema) as
      ValidateFunction<AdminDecideOrganizerIntakeCallablePayload>;
export const validateAdminRecordOrganizerCurationCallablePayload:
  ValidateFunction<AdminRecordOrganizerCurationCallablePayload> =
    ajv.compile(adminRecordOrganizerCurationCallablePayloadSchema) as
      ValidateFunction<AdminRecordOrganizerCurationCallablePayload>;
export const validateAdminRecordEventIntakeReviewDecisionCallablePayload:
  ValidateFunction<AdminRecordEventIntakeReviewDecisionCallablePayload> =
    ajv.compile(adminRecordEventIntakeReviewDecisionCallablePayloadSchema) as
      ValidateFunction<AdminRecordEventIntakeReviewDecisionCallablePayload>;
export const validateAdminListIntakeOperationsCallablePayload:
  ValidateFunction<AdminListIntakeOperationsCallablePayload> =
    ajv.compile(adminListIntakeOperationsCallablePayloadSchema) as
      ValidateFunction<AdminListIntakeOperationsCallablePayload>;
export const validateAdminDecideOrganizerEventCandidateCallablePayload:
  ValidateFunction<AdminDecideOrganizerEventCandidateCallablePayload> =
    ajv.compile(adminDecideOrganizerEventCandidateCallablePayloadSchema) as
      ValidateFunction<AdminDecideOrganizerEventCandidateCallablePayload>;
export const validateAdminDecideOrganizerPolicyGapCallablePayload:
  ValidateFunction<AdminDecideOrganizerPolicyGapCallablePayload> =
    ajv.compile(adminDecideOrganizerPolicyGapCallablePayloadSchema) as
      ValidateFunction<AdminDecideOrganizerPolicyGapCallablePayload>;
export const validateAdminResolveOrganizerEventLocationCallablePayload:
  ValidateFunction<AdminResolveOrganizerEventLocationCallablePayload> =
    ajv.compile(adminResolveOrganizerEventLocationCallablePayloadSchema) as
      ValidateFunction<AdminResolveOrganizerEventLocationCallablePayload>;
export const validateAdminSetClubIndexStatusCallablePayload:
  ValidateFunction<AdminSetClubIndexStatusCallablePayload> =
    ajv.compile(adminSetClubIndexStatusCallablePayloadSchema) as
      ValidateFunction<AdminSetClubIndexStatusCallablePayload>;
export const validateAdminGetClubDetailsCallablePayload:
  ValidateFunction<AdminGetClubDetailsCallablePayload> =
    ajv.compile(adminGetClubDetailsCallablePayloadSchema) as
      ValidateFunction<AdminGetClubDetailsCallablePayload>;
export const validateAdminListClubDetailsCallablePayload:
  ValidateFunction<AdminListClubDetailsCallablePayload> =
    ajv.compile(adminListClubDetailsCallablePayloadSchema) as
      ValidateFunction<AdminListClubDetailsCallablePayload>;
export const validateAdminUpdateClubDetailsCallablePayload:
  ValidateFunction<AdminUpdateClubDetailsCallablePayload> =
    ajv.compile(adminUpdateClubDetailsCallablePayloadSchema) as
      ValidateFunction<AdminUpdateClubDetailsCallablePayload>;
export const validateAdminGetEventDetailsCallablePayload:
  ValidateFunction<AdminGetEventDetailsCallablePayload> =
    ajv.compile(adminGetEventDetailsCallablePayloadSchema) as
      ValidateFunction<AdminGetEventDetailsCallablePayload>;
export const validateAdminListEventDetailsCallablePayload:
  ValidateFunction<AdminListEventDetailsCallablePayload> =
    ajv.compile(adminListEventDetailsCallablePayloadSchema) as
      ValidateFunction<AdminListEventDetailsCallablePayload>;
export const validateAdminListExternalEventDetailsCallablePayload:
  ValidateFunction<AdminListExternalEventDetailsCallablePayload> =
    ajv.compile(adminListExternalEventDetailsCallablePayloadSchema) as
      ValidateFunction<AdminListExternalEventDetailsCallablePayload>;
export const validateAdminUpdateEventDetailsCallablePayload:
  ValidateFunction<AdminUpdateEventDetailsCallablePayload> =
    ajv.compile(adminUpdateEventDetailsCallablePayloadSchema) as
      ValidateFunction<AdminUpdateEventDetailsCallablePayload>;
export const validateAdminPublishExternalEventCallablePayload:
  ValidateFunction<AdminPublishExternalEventCallablePayload> =
    ajv.compile(adminPublishExternalEventCallablePayloadSchema) as
      ValidateFunction<AdminPublishExternalEventCallablePayload>;
export const validateStartClubHostConversationCallablePayload:
  ValidateFunction<StartClubHostConversationCallablePayload> =
    ajv.compile(startClubHostConversationCallablePayloadSchema) as
      ValidateFunction<StartClubHostConversationCallablePayload>;
export const validateArchiveClubCallablePayload:
  ValidateFunction<ArchiveClubCallablePayload> =
    ajv.compile(archiveClubCallablePayloadSchema) as
      ValidateFunction<ArchiveClubCallablePayload>;
export const validateDeleteClubCallablePayload:
  ValidateFunction<DeleteClubCallablePayload> =
    ajv.compile(deleteClubCallablePayloadSchema) as
      ValidateFunction<DeleteClubCallablePayload>;
export const validateClubMembershipCallablePayload:
  ValidateFunction<ClubMembershipCallablePayload> =
    ajv.compile(clubMembershipCallablePayloadSchema) as
      ValidateFunction<ClubMembershipCallablePayload>;
export const validateSetClubNotificationPreferenceCallablePayload:
  ValidateFunction<SetClubNotificationPreferenceCallablePayload> =
    ajv.compile(setClubNotificationPreferenceCallablePayloadSchema) as
      ValidateFunction<SetClubNotificationPreferenceCallablePayload>;
export const validateCreateEventCallablePayload:
  ValidateFunction<CreateEventCallablePayload> =
    ajv.compile(createEventCallablePayloadSchema) as
      ValidateFunction<CreateEventCallablePayload>;
export const validateUpdateEventCallablePayload:
  ValidateFunction<UpdateEventCallablePayload> =
    ajv.compile(updateEventCallablePayloadSchema) as
      ValidateFunction<UpdateEventCallablePayload>;
export const validateCancelEventCallablePayload:
  ValidateFunction<CancelEventCallablePayload> =
    ajv.compile(cancelEventCallablePayloadSchema) as
      ValidateFunction<CancelEventCallablePayload>;
export const validateDeleteEventCallablePayload:
  ValidateFunction<DeleteEventCallablePayload> =
    ajv.compile(deleteEventCallablePayloadSchema) as
      ValidateFunction<DeleteEventCallablePayload>;
export const validateEventIdCallablePayload:
  ValidateFunction<EventIdCallablePayload> =
    ajv.compile(eventIdCallablePayloadSchema) as
      ValidateFunction<EventIdCallablePayload>;
export const validateCreateEventWaitlistOffersCallablePayload:
  ValidateFunction<CreateEventWaitlistOffersCallablePayload> =
    ajv.compile(createEventWaitlistOffersCallablePayloadSchema) as
      ValidateFunction<CreateEventWaitlistOffersCallablePayload>;
export const validateCreateEventInviteLinkCallablePayload:
  ValidateFunction<CreateEventInviteLinkCallablePayload> =
    ajv.compile(createEventInviteLinkCallablePayloadSchema) as
      ValidateFunction<CreateEventInviteLinkCallablePayload>;
export const validateDisableEventInviteLinkCallablePayload:
  ValidateFunction<DisableEventInviteLinkCallablePayload> =
    ajv.compile(disableEventInviteLinkCallablePayloadSchema) as
      ValidateFunction<DisableEventInviteLinkCallablePayload>;
export const validateRecordEventInviteLinkOpenCallablePayload:
  ValidateFunction<RecordEventInviteLinkOpenCallablePayload> =
    ajv.compile(recordEventInviteLinkOpenCallablePayloadSchema) as
      ValidateFunction<RecordEventInviteLinkOpenCallablePayload>;
export const validateRecordOrganizerAnalyticsEventCallablePayload:
  ValidateFunction<RecordOrganizerAnalyticsEventCallablePayload> =
    ajv.compile(recordOrganizerAnalyticsEventCallablePayloadSchema) as
      ValidateFunction<RecordOrganizerAnalyticsEventCallablePayload>;
export const validateRecordOrganizerAnalyticsEventCallableResponse:
  ValidateFunction<RecordOrganizerAnalyticsEventCallableResponse> =
    ajv.compile(recordOrganizerAnalyticsEventCallableResponseSchema) as
      ValidateFunction<RecordOrganizerAnalyticsEventCallableResponse>;
export const validateMarkEventAttendanceCallablePayload:
  ValidateFunction<MarkEventAttendanceCallablePayload> =
    ajv.compile(markEventAttendanceCallablePayloadSchema) as
      ValidateFunction<MarkEventAttendanceCallablePayload>;
export const validateEventJoinRequestDecisionCallablePayload:
  ValidateFunction<EventJoinRequestDecisionCallablePayload> =
    ajv.compile(eventJoinRequestDecisionCallablePayloadSchema) as
      ValidateFunction<EventJoinRequestDecisionCallablePayload>;
export const validateOverrideEventSuccessRotationsCallablePayload:
  ValidateFunction<OverrideEventSuccessRotationsCallablePayload> =
    ajv.compile(overrideEventSuccessRotationsCallablePayloadSchema) as
      ValidateFunction<OverrideEventSuccessRotationsCallablePayload>;
export const validateOverrideEventSuccessGroupsCallablePayload:
  ValidateFunction<OverrideEventSuccessGroupsCallablePayload> =
    ajv.compile(overrideEventSuccessGroupsCallablePayloadSchema) as
      ValidateFunction<OverrideEventSuccessGroupsCallablePayload>;
export const validateSubmitEventSuccessWingmanRequestCallablePayload:
  ValidateFunction<SubmitEventSuccessWingmanRequestCallablePayload> =
    ajv.compile(submitEventSuccessWingmanRequestCallablePayloadSchema) as
      ValidateFunction<SubmitEventSuccessWingmanRequestCallablePayload>;
export const validateStartEventSuccessFirstHelloMissionCallablePayload:
  ValidateFunction<StartEventSuccessFirstHelloMissionCallablePayload> =
    ajv.compile(startEventSuccessFirstHelloMissionCallablePayloadSchema) as
      ValidateFunction<StartEventSuccessFirstHelloMissionCallablePayload>;
export const validateCompleteEventSuccessFirstHelloMissionCallablePayload:
  ValidateFunction<CompleteEventSuccessFirstHelloMissionCallablePayload> =
    ajv.compile(completeEventSuccessFirstHelloMissionCallablePayloadSchema) as
      ValidateFunction<CompleteEventSuccessFirstHelloMissionCallablePayload>;
export const validateMarkEventAttendanceCallableResponse:
  ValidateFunction<MarkEventAttendanceCallableResponse> =
    ajv.compile(markEventAttendanceCallableResponseSchema) as
      ValidateFunction<MarkEventAttendanceCallableResponse>;
export const validateSelfCheckInAttendanceCallablePayload:
  ValidateFunction<SelfCheckInAttendanceCallablePayload> =
    ajv.compile(selfCheckInAttendanceCallablePayloadSchema) as
      ValidateFunction<SelfCheckInAttendanceCallablePayload>;
export const validateCreateEventReviewCallablePayload:
  ValidateFunction<CreateEventReviewCallablePayload> =
    ajv.compile(createEventReviewCallablePayloadSchema) as
      ValidateFunction<CreateEventReviewCallablePayload>;
export const validateCreatePublicClubReviewCallablePayload:
  ValidateFunction<CreatePublicClubReviewCallablePayload> =
    ajv.compile(createPublicClubReviewCallablePayloadSchema) as
      ValidateFunction<CreatePublicClubReviewCallablePayload>;
export const validateCreatePublicClubReviewCallableResponse:
  ValidateFunction<CreatePublicClubReviewCallableResponse> =
    ajv.compile(createPublicClubReviewCallableResponseSchema) as
      ValidateFunction<CreatePublicClubReviewCallableResponse>;
export const validateListPublicClubReviewsCallablePayload:
  ValidateFunction<ListPublicClubReviewsCallablePayload> =
    ajv.compile(listPublicClubReviewsCallablePayloadSchema) as
      ValidateFunction<ListPublicClubReviewsCallablePayload>;
export const validateListPublicClubReviewsCallableResponse:
  ValidateFunction<ListPublicClubReviewsCallableResponse> =
    ajv.compile(listPublicClubReviewsCallableResponseSchema) as
      ValidateFunction<ListPublicClubReviewsCallableResponse>;
export const validateUpdateEventReviewCallablePayload:
  ValidateFunction<UpdateEventReviewCallablePayload> =
    ajv.compile(updateEventReviewCallablePayloadSchema) as
      ValidateFunction<UpdateEventReviewCallablePayload>;
export const validateDeleteEventReviewCallablePayload:
  ValidateFunction<DeleteEventReviewCallablePayload> =
    ajv.compile(deleteEventReviewCallablePayloadSchema) as
      ValidateFunction<DeleteEventReviewCallablePayload>;
export const validateSetReviewResponseCallablePayload:
  ValidateFunction<SetReviewResponseCallablePayload> =
    ajv.compile(setReviewResponseCallablePayloadSchema) as
      ValidateFunction<SetReviewResponseCallablePayload>;
export const validateBlockUserCallablePayload:
  ValidateFunction<BlockUserCallablePayload> =
    ajv.compile(blockUserCallablePayloadSchema) as
      ValidateFunction<BlockUserCallablePayload>;
export const validateUnblockUserCallablePayload:
  ValidateFunction<UnblockUserCallablePayload> =
    ajv.compile(unblockUserCallablePayloadSchema) as
      ValidateFunction<UnblockUserCallablePayload>;
export const validateReportUserCallablePayload:
  ValidateFunction<ReportUserCallablePayload> =
    ajv.compile(reportUserCallablePayloadSchema) as
      ValidateFunction<ReportUserCallablePayload>;
export const validateRequestSuvbotDemoOperationCallablePayload:
  ValidateFunction<RequestSuvbotDemoOperationCallablePayload> =
    ajv.compile(requestSuvbotDemoOperationCallablePayloadSchema) as
      ValidateFunction<RequestSuvbotDemoOperationCallablePayload>;
export const validateListSuvbotDemoActionsCallableResponse:
  ValidateFunction<ListSuvbotDemoActionsCallableResponse> =
    ajv.compile(listSuvbotDemoActionsCallableResponseSchema) as
      ValidateFunction<ListSuvbotDemoActionsCallableResponse>;
export const validateVerifyRazorpayPaymentCallablePayload:
  ValidateFunction<VerifyRazorpayPaymentCallablePayload> =
    ajv.compile(verifyRazorpayPaymentCallablePayloadSchema) as
      ValidateFunction<VerifyRazorpayPaymentCallablePayload>;
export const validateEventBookingCallablePayload:
  ValidateFunction<EventBookingCallablePayload> =
    ajv.compile(eventBookingCallablePayloadSchema) as
      ValidateFunction<EventBookingCallablePayload>;
export const validateCreateRazorpayOrderCallablePayload:
  ValidateFunction<CreateRazorpayOrderCallablePayload> =
    ajv.compile(createRazorpayOrderCallablePayloadSchema) as
      ValidateFunction<CreateRazorpayOrderCallablePayload>;
export const validateRazorpayOrderCallableResponse:
  ValidateFunction<RazorpayOrderCallableResponse> =
    ajv.compile(razorpayOrderCallableResponseSchema) as
      ValidateFunction<RazorpayOrderCallableResponse>;
export const validateCreateStripeCheckoutSessionCallablePayload:
  ValidateFunction<CreateStripeCheckoutSessionCallablePayload> =
    ajv.compile(createStripeCheckoutSessionCallablePayloadSchema) as
      ValidateFunction<CreateStripeCheckoutSessionCallablePayload>;
export const validateStripeCheckoutSessionCallableResponse:
  ValidateFunction<StripeCheckoutSessionCallableResponse> =
    ajv.compile(stripeCheckoutSessionCallableResponseSchema) as
      ValidateFunction<StripeCheckoutSessionCallableResponse>;
export const validateCreateStripeHostOnboardingLinkCallablePayload:
  ValidateFunction<CreateStripeHostOnboardingLinkCallablePayload> =
    ajv.compile(createStripeHostOnboardingLinkCallablePayloadSchema) as
      ValidateFunction<CreateStripeHostOnboardingLinkCallablePayload>;
export const validateRefreshStripeHostPaymentAccountCallablePayload:
  ValidateFunction<RefreshStripeHostPaymentAccountCallablePayload> =
    ajv.compile(refreshStripeHostPaymentAccountCallablePayloadSchema) as
      ValidateFunction<RefreshStripeHostPaymentAccountCallablePayload>;
export const validateStripeHostOnboardingLinkCallableResponse:
  ValidateFunction<StripeHostOnboardingLinkCallableResponse> =
    ajv.compile(stripeHostOnboardingLinkCallableResponseSchema) as
      ValidateFunction<StripeHostOnboardingLinkCallableResponse>;
export const validatePlacesAutocompleteCallablePayload:
  ValidateFunction<PlacesAutocompleteCallablePayload> =
    ajv.compile(placesAutocompleteCallablePayloadSchema) as
      ValidateFunction<PlacesAutocompleteCallablePayload>;
export const validatePlacesAutocompleteCallableResponse:
  ValidateFunction<PlacesAutocompleteCallableResponse> =
    ajv.compile(placesAutocompleteCallableResponseSchema) as
      ValidateFunction<PlacesAutocompleteCallableResponse>;
export const validatePlaceDetailsCallablePayload:
  ValidateFunction<PlaceDetailsCallablePayload> =
    ajv.compile(placeDetailsCallablePayloadSchema) as
      ValidateFunction<PlaceDetailsCallablePayload>;
export const validatePlaceDetailsCallableResponse:
  ValidateFunction<PlaceDetailsCallableResponse> =
    ajv.compile(placeDetailsCallableResponseSchema) as
      ValidateFunction<PlaceDetailsCallableResponse>;
export const validateExploreSearchCallablePayload:
  ValidateFunction<ExploreSearchCallablePayload> =
    ajv.compile(exploreSearchCallablePayloadSchema) as
      ValidateFunction<ExploreSearchCallablePayload>;
export const validateExploreSearchCallableResponse:
  ValidateFunction<ExploreSearchCallableResponse> =
    ajv.compile(exploreSearchCallableResponseSchema) as
      ValidateFunction<ExploreSearchCallableResponse>;
export const validateWebsiteHostListingProjection:
  ValidateFunction<WebsiteHostListingProjection> =
    ajv.compile(websiteHostListingProjectionSchema) as
      ValidateFunction<WebsiteHostListingProjection>;
export const validateFetchEventSuccessWingmanCandidatesCallableResponse:
  ValidateFunction<FetchEventSuccessWingmanCandidatesCallableResponse> =
    ajv.compile(fetchEventSuccessWingmanCandidatesCallableResponseSchema) as
      ValidateFunction<FetchEventSuccessWingmanCandidatesCallableResponse>;
export const validateCreateProfileDecisionClientWrite:
  ValidateFunction<CreateProfileDecisionClientWrite> =
    ajv.compile(createProfileDecisionClientWriteSchema) as
      ValidateFunction<CreateProfileDecisionClientWrite>;
export const validateCreateChatMessageClientWrite:
  ValidateFunction<CreateChatMessageClientWrite> =
    ajv.compile(createChatMessageClientWriteSchema) as
      ValidateFunction<CreateChatMessageClientWrite>;
export const validateCreateSavedEventClientWrite:
  ValidateFunction<CreateSavedEventClientWrite> =
    ajv.compile(createSavedEventClientWriteSchema) as
      ValidateFunction<CreateSavedEventClientWrite>;
export const validateDeleteSavedEventClientWrite:
  ValidateFunction<DeleteSavedEventClientWrite> =
    ajv.compile(deleteSavedEventClientWriteSchema) as
      ValidateFunction<DeleteSavedEventClientWrite>;
export const validateMarkNotificationReadClientWrite:
  ValidateFunction<MarkNotificationReadClientWrite> =
    ajv.compile(markNotificationReadClientWriteSchema) as
      ValidateFunction<MarkNotificationReadClientWrite>;
export const validateResetMatchUnreadCountClientWrite:
  ValidateFunction<ResetMatchUnreadCountClientWrite> =
    ajv.compile(resetMatchUnreadCountClientWriteSchema) as
      ValidateFunction<ResetMatchUnreadCountClientWrite>;

export function schemaErrorMessages(
  validator: ValidateFunction<unknown>
): string[] {
  return (validator.errors ?? []).map((error) => {
    const location = error.instancePath || "/";
    return `${location} ${error.message ?? "failed validation"}`;
  });
}
