// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import {createRequire} from "node:module";
import {
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
  clubMembershipDocumentSchema,
  clubHostClaimDocumentSchema,
  clubClaimRequestDocumentSchema,
  eventDocumentSchema,
  externalEventDocumentSchema,
  eventPrivateAccessDocumentSchema,
  eventInviteLinkDocumentSchema,
  eventParticipationDocumentSchema,
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
} from "./schema_contract_registry.mjs";

const requireFromRepo = createRequire(
  new URL("../../../package.json", import.meta.url)
);
const requireFromFunctions = createRequire(
  new URL("../../../functions/package.json", import.meta.url)
);

function requireContractDependency(name) {
  try {
    return requireFromRepo(name);
  } catch (error) {
    if (error?.code !== "MODULE_NOT_FOUND") throw error;
    return requireFromFunctions(name);
  }
}

const Ajv = requireContractDependency("ajv");
const addFormats = requireContractDependency("ajv-formats");

const ajv = new Ajv({allErrors: true, strict: false});
addFormats(ajv);

export const validateProfilePromptAnswer = ajv.compile(profilePromptAnswerSchema);
export const validatePhotoPromptAnswer = ajv.compile(photoPromptAnswerSchema);
export const validateProfilePhoto = ajv.compile(profilePhotoSchema);
export const validateUploadedPhoto = ajv.compile(uploadedPhotoSchema);
export const validateActivityPreferences = ajv.compile(activityPreferencesSchema);
export const validateConfigCitiesDocument = ajv.compile(configCitiesDocumentSchema);
export const validateOnboardingDraftDocument = ajv.compile(onboardingDraftDocumentSchema);
export const validateUserProfileDocument = ajv.compile(userProfileDocumentSchema);
export const validatePublicProfileDocument = ajv.compile(publicProfileDocumentSchema);
export const validateHostProfileDocument = ajv.compile(hostProfileDocumentSchema);
export const validateClubDocument = ajv.compile(clubDocumentSchema);
export const validateClubMembershipDocument = ajv.compile(clubMembershipDocumentSchema);
export const validateClubHostClaimDocument = ajv.compile(clubHostClaimDocumentSchema);
export const validateClubClaimRequestDocument = ajv.compile(clubClaimRequestDocumentSchema);
export const validateEventDocument = ajv.compile(eventDocumentSchema);
export const validateExternalEventDocument = ajv.compile(externalEventDocumentSchema);
export const validateEventPrivateAccessDocument = ajv.compile(eventPrivateAccessDocumentSchema);
export const validateEventInviteLinkDocument = ajv.compile(eventInviteLinkDocumentSchema);
export const validateEventParticipationDocument = ajv.compile(eventParticipationDocumentSchema);
export const validateEventWaitlistOfferDocument = ajv.compile(eventWaitlistOfferDocumentSchema);
export const validateEventSuccessPlanDocument = ajv.compile(eventSuccessPlanDocumentSchema);
export const validateEventSuccessFeedbackDocument = ajv.compile(eventSuccessFeedbackDocumentSchema);
export const validateEventSuccessPreferenceDocument = ajv.compile(eventSuccessPreferenceDocumentSchema);
export const validateEventSuccessCompatibilityResponseDocument = ajv.compile(eventSuccessCompatibilityResponseDocumentSchema);
export const validateEventSuccessWingmanRequestDocument = ajv.compile(eventSuccessWingmanRequestDocumentSchema);
export const validateEventSuccessArrivalMissionDocument = ajv.compile(eventSuccessArrivalMissionDocumentSchema);
export const validateEventSuccessAssignmentDocument = ajv.compile(eventSuccessAssignmentDocumentSchema);
export const validateEventSuccessScorecardDocument = ajv.compile(eventSuccessScorecardDocumentSchema);
export const validateEventSafetyReportDocument = ajv.compile(eventSafetyReportDocumentSchema);
export const validateClubScheduleLockDocument = ajv.compile(clubScheduleLockDocumentSchema);
export const validateUserEventScheduleLockDocument = ajv.compile(userEventScheduleLockDocumentSchema);
export const validateSavedEventDocument = ajv.compile(savedEventDocumentSchema);
export const validateHostAnalyticsEvent = ajv.compile(hostAnalyticsEventSchema);
export const validateUserProfileExposureEvent = ajv.compile(userProfileExposureEventSchema);
export const validatePaymentDocument = ajv.compile(paymentDocumentSchema);
export const validateHostPaymentAccountDocument = ajv.compile(hostPaymentAccountDocumentSchema);
export const validateRazorpayPendingOrderDocument = ajv.compile(razorpayPendingOrderDocumentSchema);
export const validateSwipeDocument = ajv.compile(swipeDocumentSchema);
export const validateMatchDocument = ajv.compile(matchDocumentSchema);
export const validateChatMessageDocument = ajv.compile(chatMessageDocumentSchema);
export const validateActivityNotificationDocument = ajv.compile(activityNotificationDocumentSchema);
export const validateReviewDocument = ajv.compile(reviewDocumentSchema);
export const validateBlockDocument = ajv.compile(blockDocumentSchema);
export const validateReportDocument = ajv.compile(reportDocumentSchema);
export const validateModerationFlagDocument = ajv.compile(moderationFlagDocumentSchema);
export const validateDeletedUserTombstoneDocument = ajv.compile(deletedUserTombstoneDocumentSchema);
export const validateRateLimitDocument = ajv.compile(rateLimitDocumentSchema);
export const validateFunctionEventReceiptDocument = ajv.compile(functionEventReceiptDocumentSchema);
export const validatePublicRouteReservationDocument = ajv.compile(publicRouteReservationDocumentSchema);
export const validateSeedEventManifestDocument = ajv.compile(seedEventManifestDocumentSchema);
export const validateOrganizerIntakeReviewDecisionDocument = ajv.compile(organizerIntakeReviewDecisionDocumentSchema);
export const validateEventIntakeReviewDecisionDocument = ajv.compile(eventIntakeReviewDecisionDocumentSchema);
export const validateOrganizerIntakeCurationDecisionDocument = ajv.compile(organizerIntakeCurationDecisionDocumentSchema);
export const validateOrganizerEventCandidateReviewDecisionDocument = ajv.compile(organizerEventCandidateReviewDecisionDocumentSchema);
export const validateOrganizerEventLocationResolutionDecisionDocument = ajv.compile(organizerEventLocationResolutionDecisionDocumentSchema);
export const validateOrganizerPolicyGapReviewDecisionDocument = ajv.compile(organizerPolicyGapReviewDecisionDocumentSchema);
export const validateUpdateUserProfileCallablePayload = ajv.compile(updateUserProfileCallablePayloadSchema);
export const validateCreateClubCallablePayload = ajv.compile(createClubCallablePayloadSchema);
export const validateCreateClubCallableResponse = ajv.compile(createClubCallableResponseSchema);
export const validateUpdateClubCallablePayload = ajv.compile(updateClubCallablePayloadSchema);
export const validateHostAnalyticsQueryCallablePayload = ajv.compile(hostAnalyticsQueryCallablePayloadSchema);
export const validateHostAnalyticsCallableResponse = ajv.compile(hostAnalyticsCallableResponseSchema);
export const validateUserAnalyticsQueryCallablePayload = ajv.compile(userAnalyticsQueryCallablePayloadSchema);
export const validateUserAnalyticsCallableResponse = ajv.compile(userAnalyticsCallableResponseSchema);
export const validateAddClubHostCallablePayload = ajv.compile(addClubHostCallablePayloadSchema);
export const validateRemoveClubHostCallablePayload = ajv.compile(removeClubHostCallablePayloadSchema);
export const validateTransferClubOwnershipCallablePayload = ajv.compile(transferClubOwnershipCallablePayloadSchema);
export const validateRequestClubClaimCallablePayload = ajv.compile(requestClubClaimCallablePayloadSchema);
export const validateRequestClubClaimCallableResponse = ajv.compile(requestClubClaimCallableResponseSchema);
export const validateAdminDecideClubClaimCallablePayload = ajv.compile(adminDecideClubClaimCallablePayloadSchema);
export const validateAdminDecideOrganizerIntakeCallablePayload = ajv.compile(adminDecideOrganizerIntakeCallablePayloadSchema);
export const validateAdminRecordOrganizerCurationCallablePayload = ajv.compile(adminRecordOrganizerCurationCallablePayloadSchema);
export const validateAdminRecordEventIntakeReviewDecisionCallablePayload = ajv.compile(adminRecordEventIntakeReviewDecisionCallablePayloadSchema);
export const validateAdminDecideOrganizerEventCandidateCallablePayload = ajv.compile(adminDecideOrganizerEventCandidateCallablePayloadSchema);
export const validateAdminDecideOrganizerPolicyGapCallablePayload = ajv.compile(adminDecideOrganizerPolicyGapCallablePayloadSchema);
export const validateAdminResolveOrganizerEventLocationCallablePayload = ajv.compile(adminResolveOrganizerEventLocationCallablePayloadSchema);
export const validateAdminSetClubIndexStatusCallablePayload = ajv.compile(adminSetClubIndexStatusCallablePayloadSchema);
export const validateAdminGetClubDetailsCallablePayload = ajv.compile(adminGetClubDetailsCallablePayloadSchema);
export const validateAdminListClubDetailsCallablePayload = ajv.compile(adminListClubDetailsCallablePayloadSchema);
export const validateAdminUpdateClubDetailsCallablePayload = ajv.compile(adminUpdateClubDetailsCallablePayloadSchema);
export const validateAdminGetEventDetailsCallablePayload = ajv.compile(adminGetEventDetailsCallablePayloadSchema);
export const validateAdminListEventDetailsCallablePayload = ajv.compile(adminListEventDetailsCallablePayloadSchema);
export const validateAdminListExternalEventDetailsCallablePayload = ajv.compile(adminListExternalEventDetailsCallablePayloadSchema);
export const validateAdminUpdateEventDetailsCallablePayload = ajv.compile(adminUpdateEventDetailsCallablePayloadSchema);
export const validateAdminPublishExternalEventCallablePayload = ajv.compile(adminPublishExternalEventCallablePayloadSchema);
export const validateStartClubHostConversationCallablePayload = ajv.compile(startClubHostConversationCallablePayloadSchema);
export const validateArchiveClubCallablePayload = ajv.compile(archiveClubCallablePayloadSchema);
export const validateDeleteClubCallablePayload = ajv.compile(deleteClubCallablePayloadSchema);
export const validateClubMembershipCallablePayload = ajv.compile(clubMembershipCallablePayloadSchema);
export const validateSetClubNotificationPreferenceCallablePayload = ajv.compile(setClubNotificationPreferenceCallablePayloadSchema);
export const validateCreateEventCallablePayload = ajv.compile(createEventCallablePayloadSchema);
export const validateUpdateEventCallablePayload = ajv.compile(updateEventCallablePayloadSchema);
export const validateCancelEventCallablePayload = ajv.compile(cancelEventCallablePayloadSchema);
export const validateDeleteEventCallablePayload = ajv.compile(deleteEventCallablePayloadSchema);
export const validateEventIdCallablePayload = ajv.compile(eventIdCallablePayloadSchema);
export const validateCreateEventWaitlistOffersCallablePayload = ajv.compile(createEventWaitlistOffersCallablePayloadSchema);
export const validateCreateEventInviteLinkCallablePayload = ajv.compile(createEventInviteLinkCallablePayloadSchema);
export const validateDisableEventInviteLinkCallablePayload = ajv.compile(disableEventInviteLinkCallablePayloadSchema);
export const validateRecordEventInviteLinkOpenCallablePayload = ajv.compile(recordEventInviteLinkOpenCallablePayloadSchema);
export const validateRecordOrganizerAnalyticsEventCallablePayload = ajv.compile(recordOrganizerAnalyticsEventCallablePayloadSchema);
export const validateRecordOrganizerAnalyticsEventCallableResponse = ajv.compile(recordOrganizerAnalyticsEventCallableResponseSchema);
export const validateMarkEventAttendanceCallablePayload = ajv.compile(markEventAttendanceCallablePayloadSchema);
export const validateEventJoinRequestDecisionCallablePayload = ajv.compile(eventJoinRequestDecisionCallablePayloadSchema);
export const validateOverrideEventSuccessRotationsCallablePayload = ajv.compile(overrideEventSuccessRotationsCallablePayloadSchema);
export const validateOverrideEventSuccessGroupsCallablePayload = ajv.compile(overrideEventSuccessGroupsCallablePayloadSchema);
export const validateSubmitEventSuccessWingmanRequestCallablePayload = ajv.compile(submitEventSuccessWingmanRequestCallablePayloadSchema);
export const validateStartEventSuccessFirstHelloMissionCallablePayload = ajv.compile(startEventSuccessFirstHelloMissionCallablePayloadSchema);
export const validateCompleteEventSuccessFirstHelloMissionCallablePayload = ajv.compile(completeEventSuccessFirstHelloMissionCallablePayloadSchema);
export const validateMarkEventAttendanceCallableResponse = ajv.compile(markEventAttendanceCallableResponseSchema);
export const validateSelfCheckInAttendanceCallablePayload = ajv.compile(selfCheckInAttendanceCallablePayloadSchema);
export const validateCreateEventReviewCallablePayload = ajv.compile(createEventReviewCallablePayloadSchema);
export const validateCreatePublicClubReviewCallablePayload = ajv.compile(createPublicClubReviewCallablePayloadSchema);
export const validateCreatePublicClubReviewCallableResponse = ajv.compile(createPublicClubReviewCallableResponseSchema);
export const validateListPublicClubReviewsCallablePayload = ajv.compile(listPublicClubReviewsCallablePayloadSchema);
export const validateListPublicClubReviewsCallableResponse = ajv.compile(listPublicClubReviewsCallableResponseSchema);
export const validateUpdateEventReviewCallablePayload = ajv.compile(updateEventReviewCallablePayloadSchema);
export const validateDeleteEventReviewCallablePayload = ajv.compile(deleteEventReviewCallablePayloadSchema);
export const validateSetReviewResponseCallablePayload = ajv.compile(setReviewResponseCallablePayloadSchema);
export const validateBlockUserCallablePayload = ajv.compile(blockUserCallablePayloadSchema);
export const validateUnblockUserCallablePayload = ajv.compile(unblockUserCallablePayloadSchema);
export const validateReportUserCallablePayload = ajv.compile(reportUserCallablePayloadSchema);
export const validateRequestSuvbotDemoOperationCallablePayload = ajv.compile(requestSuvbotDemoOperationCallablePayloadSchema);
export const validateListSuvbotDemoActionsCallableResponse = ajv.compile(listSuvbotDemoActionsCallableResponseSchema);
export const validateVerifyRazorpayPaymentCallablePayload = ajv.compile(verifyRazorpayPaymentCallablePayloadSchema);
export const validateEventBookingCallablePayload = ajv.compile(eventBookingCallablePayloadSchema);
export const validateCreateRazorpayOrderCallablePayload = ajv.compile(createRazorpayOrderCallablePayloadSchema);
export const validateRazorpayOrderCallableResponse = ajv.compile(razorpayOrderCallableResponseSchema);
export const validateCreateStripeCheckoutSessionCallablePayload = ajv.compile(createStripeCheckoutSessionCallablePayloadSchema);
export const validateStripeCheckoutSessionCallableResponse = ajv.compile(stripeCheckoutSessionCallableResponseSchema);
export const validateCreateStripeHostOnboardingLinkCallablePayload = ajv.compile(createStripeHostOnboardingLinkCallablePayloadSchema);
export const validateRefreshStripeHostPaymentAccountCallablePayload = ajv.compile(refreshStripeHostPaymentAccountCallablePayloadSchema);
export const validateStripeHostOnboardingLinkCallableResponse = ajv.compile(stripeHostOnboardingLinkCallableResponseSchema);
export const validatePlacesAutocompleteCallablePayload = ajv.compile(placesAutocompleteCallablePayloadSchema);
export const validatePlacesAutocompleteCallableResponse = ajv.compile(placesAutocompleteCallableResponseSchema);
export const validatePlaceDetailsCallablePayload = ajv.compile(placeDetailsCallablePayloadSchema);
export const validatePlaceDetailsCallableResponse = ajv.compile(placeDetailsCallableResponseSchema);
export const validateExploreSearchCallablePayload = ajv.compile(exploreSearchCallablePayloadSchema);
export const validateExploreSearchCallableResponse = ajv.compile(exploreSearchCallableResponseSchema);
export const validateWebsiteHostListingProjection = ajv.compile(websiteHostListingProjectionSchema);
export const validateFetchEventSuccessWingmanCandidatesCallableResponse = ajv.compile(fetchEventSuccessWingmanCandidatesCallableResponseSchema);
export const validateCreateProfileDecisionClientWrite = ajv.compile(createProfileDecisionClientWriteSchema);
export const validateCreateChatMessageClientWrite = ajv.compile(createChatMessageClientWriteSchema);
export const validateCreateSavedEventClientWrite = ajv.compile(createSavedEventClientWriteSchema);
export const validateDeleteSavedEventClientWrite = ajv.compile(deleteSavedEventClientWriteSchema);
export const validateMarkNotificationReadClientWrite = ajv.compile(markNotificationReadClientWriteSchema);
export const validateResetMatchUnreadCountClientWrite = ajv.compile(resetMatchUnreadCountClientWriteSchema);

export function schemaErrorMessages(validator) {
  return (validator.errors ?? []).map((error) => {
    const location = error.instancePath || "/";
    return `${location} ${error.message ?? "failed validation"}`;
  });
}

export function assertValidSchemaPayload(validator, payload, label) {
  if (validator(payload)) return;
  const details = schemaErrorMessages(validator).join("; ");
  throw new Error(`${label} failed schema validation: ${details}`);
}
