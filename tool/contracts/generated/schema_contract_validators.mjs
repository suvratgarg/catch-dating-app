// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import {createRequire} from "node:module";
import {
  profilePromptAnswerSchema,
  photoPromptAnswerSchema,
  profilePhotoSchema,
  configCitiesDocumentSchema,
  onboardingDraftDocumentSchema,
  userProfileDocumentSchema,
  publicProfileDocumentSchema,
  clubDocumentSchema,
  clubMembershipDocumentSchema,
  clubHostClaimDocumentSchema,
  eventDocumentSchema,
  eventPrivateAccessDocumentSchema,
  eventParticipationDocumentSchema,
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
  paymentDocumentSchema,
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
  seedEventManifestDocumentSchema,
  updateUserProfileCallablePayloadSchema,
  createClubCallablePayloadSchema,
  createClubCallableResponseSchema,
  updateClubCallablePayloadSchema,
  addClubHostCallablePayloadSchema,
  removeClubHostCallablePayloadSchema,
  transferClubOwnershipCallablePayloadSchema,
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
  markEventAttendanceCallablePayloadSchema,
  eventJoinRequestDecisionCallablePayloadSchema,
  overrideEventSuccessRotationsCallablePayloadSchema,
  submitEventSuccessWingmanRequestCallablePayloadSchema,
  startEventSuccessFirstHelloMissionCallablePayloadSchema,
  completeEventSuccessFirstHelloMissionCallablePayloadSchema,
  markEventAttendanceCallableResponseSchema,
  selfCheckInAttendanceCallablePayloadSchema,
  createEventReviewCallablePayloadSchema,
  updateEventReviewCallablePayloadSchema,
  deleteEventReviewCallablePayloadSchema,
  blockUserCallablePayloadSchema,
  unblockUserCallablePayloadSchema,
  reportUserCallablePayloadSchema,
  requestSuvbotDemoOperationCallablePayloadSchema,
  listSuvbotDemoActionsCallableResponseSchema,
  verifyRazorpayPaymentCallablePayloadSchema,
  eventBookingCallablePayloadSchema,
  createRazorpayOrderCallablePayloadSchema,
  razorpayOrderCallableResponseSchema,
  placesAutocompleteCallablePayloadSchema,
  placesAutocompleteCallableResponseSchema,
  placeDetailsCallablePayloadSchema,
  placeDetailsCallableResponseSchema,
  fetchEventSuccessWingmanCandidatesCallableResponseSchema,
  createProfileDecisionClientWriteSchema,
  createChatMessageClientWriteSchema,
  createSavedEventClientWriteSchema,
  deleteSavedEventClientWriteSchema,
  markNotificationReadClientWriteSchema,
  resetMatchUnreadCountClientWriteSchema,
} from "./schema_contract_registry.mjs";

const requireFromFunctions = createRequire(
  new URL("../../../functions/package.json", import.meta.url)
);
const Ajv = requireFromFunctions("ajv");
const addFormats = requireFromFunctions("ajv-formats");

const ajv = new Ajv({allErrors: true, strict: false});
addFormats(ajv);

export const validateProfilePromptAnswer = ajv.compile(profilePromptAnswerSchema);
export const validatePhotoPromptAnswer = ajv.compile(photoPromptAnswerSchema);
export const validateProfilePhoto = ajv.compile(profilePhotoSchema);
export const validateConfigCitiesDocument = ajv.compile(configCitiesDocumentSchema);
export const validateOnboardingDraftDocument = ajv.compile(onboardingDraftDocumentSchema);
export const validateUserProfileDocument = ajv.compile(userProfileDocumentSchema);
export const validatePublicProfileDocument = ajv.compile(publicProfileDocumentSchema);
export const validateClubDocument = ajv.compile(clubDocumentSchema);
export const validateClubMembershipDocument = ajv.compile(clubMembershipDocumentSchema);
export const validateClubHostClaimDocument = ajv.compile(clubHostClaimDocumentSchema);
export const validateEventDocument = ajv.compile(eventDocumentSchema);
export const validateEventPrivateAccessDocument = ajv.compile(eventPrivateAccessDocumentSchema);
export const validateEventParticipationDocument = ajv.compile(eventParticipationDocumentSchema);
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
export const validatePaymentDocument = ajv.compile(paymentDocumentSchema);
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
export const validateSeedEventManifestDocument = ajv.compile(seedEventManifestDocumentSchema);
export const validateUpdateUserProfileCallablePayload = ajv.compile(updateUserProfileCallablePayloadSchema);
export const validateCreateClubCallablePayload = ajv.compile(createClubCallablePayloadSchema);
export const validateCreateClubCallableResponse = ajv.compile(createClubCallableResponseSchema);
export const validateUpdateClubCallablePayload = ajv.compile(updateClubCallablePayloadSchema);
export const validateAddClubHostCallablePayload = ajv.compile(addClubHostCallablePayloadSchema);
export const validateRemoveClubHostCallablePayload = ajv.compile(removeClubHostCallablePayloadSchema);
export const validateTransferClubOwnershipCallablePayload = ajv.compile(transferClubOwnershipCallablePayloadSchema);
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
export const validateMarkEventAttendanceCallablePayload = ajv.compile(markEventAttendanceCallablePayloadSchema);
export const validateEventJoinRequestDecisionCallablePayload = ajv.compile(eventJoinRequestDecisionCallablePayloadSchema);
export const validateOverrideEventSuccessRotationsCallablePayload = ajv.compile(overrideEventSuccessRotationsCallablePayloadSchema);
export const validateSubmitEventSuccessWingmanRequestCallablePayload = ajv.compile(submitEventSuccessWingmanRequestCallablePayloadSchema);
export const validateStartEventSuccessFirstHelloMissionCallablePayload = ajv.compile(startEventSuccessFirstHelloMissionCallablePayloadSchema);
export const validateCompleteEventSuccessFirstHelloMissionCallablePayload = ajv.compile(completeEventSuccessFirstHelloMissionCallablePayloadSchema);
export const validateMarkEventAttendanceCallableResponse = ajv.compile(markEventAttendanceCallableResponseSchema);
export const validateSelfCheckInAttendanceCallablePayload = ajv.compile(selfCheckInAttendanceCallablePayloadSchema);
export const validateCreateEventReviewCallablePayload = ajv.compile(createEventReviewCallablePayloadSchema);
export const validateUpdateEventReviewCallablePayload = ajv.compile(updateEventReviewCallablePayloadSchema);
export const validateDeleteEventReviewCallablePayload = ajv.compile(deleteEventReviewCallablePayloadSchema);
export const validateBlockUserCallablePayload = ajv.compile(blockUserCallablePayloadSchema);
export const validateUnblockUserCallablePayload = ajv.compile(unblockUserCallablePayloadSchema);
export const validateReportUserCallablePayload = ajv.compile(reportUserCallablePayloadSchema);
export const validateRequestSuvbotDemoOperationCallablePayload = ajv.compile(requestSuvbotDemoOperationCallablePayloadSchema);
export const validateListSuvbotDemoActionsCallableResponse = ajv.compile(listSuvbotDemoActionsCallableResponseSchema);
export const validateVerifyRazorpayPaymentCallablePayload = ajv.compile(verifyRazorpayPaymentCallablePayloadSchema);
export const validateEventBookingCallablePayload = ajv.compile(eventBookingCallablePayloadSchema);
export const validateCreateRazorpayOrderCallablePayload = ajv.compile(createRazorpayOrderCallablePayloadSchema);
export const validateRazorpayOrderCallableResponse = ajv.compile(razorpayOrderCallableResponseSchema);
export const validatePlacesAutocompleteCallablePayload = ajv.compile(placesAutocompleteCallablePayloadSchema);
export const validatePlacesAutocompleteCallableResponse = ajv.compile(placesAutocompleteCallableResponseSchema);
export const validatePlaceDetailsCallablePayload = ajv.compile(placeDetailsCallablePayloadSchema);
export const validatePlaceDetailsCallableResponse = ajv.compile(placeDetailsCallableResponseSchema);
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
