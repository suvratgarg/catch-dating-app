// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

import {createRequire} from "node:module";
import {
  profilePromptAnswerSchema,
  photoPromptAnswerSchema,
  profilePhotoSchema,
  configCitiesDocumentSchema,
  onboardingDraftDocumentSchema,
  userProfileDocumentSchema,
  publicProfileDocumentSchema,
  runClubDocumentSchema,
  runClubMembershipDocumentSchema,
  runClubHostClaimDocumentSchema,
  runDocumentSchema,
  runParticipationDocumentSchema,
  runClubScheduleLockDocumentSchema,
  userRunScheduleLockDocumentSchema,
  savedRunDocumentSchema,
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
  seedRunManifestDocumentSchema,
  updateUserProfileCallablePayloadSchema,
  createRunClubCallablePayloadSchema,
  updateRunClubCallablePayloadSchema,
  archiveRunClubCallablePayloadSchema,
  deleteRunClubCallablePayloadSchema,
  runClubMembershipCallablePayloadSchema,
  setRunClubNotificationPreferenceCallablePayloadSchema,
  createRunCallablePayloadSchema,
  updateRunCallablePayloadSchema,
  cancelRunCallablePayloadSchema,
  deleteRunCallablePayloadSchema,
  runIdCallablePayloadSchema,
  markRunAttendanceCallablePayloadSchema,
  selfCheckInAttendanceCallablePayloadSchema,
  createRunReviewCallablePayloadSchema,
  updateRunReviewCallablePayloadSchema,
  deleteRunReviewCallablePayloadSchema,
  blockUserCallablePayloadSchema,
  unblockUserCallablePayloadSchema,
  reportUserCallablePayloadSchema,
  verifyRazorpayPaymentCallablePayloadSchema,
  placesAutocompleteCallablePayloadSchema,
  placeDetailsCallablePayloadSchema,
  createProfileDecisionClientWriteSchema,
  createChatMessageClientWriteSchema,
  createSavedRunClientWriteSchema,
  deleteSavedRunClientWriteSchema,
  markNotificationReadClientWriteSchema,
  resetMatchUnreadCountClientWriteSchema,
} from "./schema_contract_registry.mjs";

const requireFromFunctions = createRequire(
  new URL("../../functions/package.json", import.meta.url)
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
export const validateRunClubDocument = ajv.compile(runClubDocumentSchema);
export const validateRunClubMembershipDocument = ajv.compile(runClubMembershipDocumentSchema);
export const validateRunClubHostClaimDocument = ajv.compile(runClubHostClaimDocumentSchema);
export const validateRunDocument = ajv.compile(runDocumentSchema);
export const validateRunParticipationDocument = ajv.compile(runParticipationDocumentSchema);
export const validateRunClubScheduleLockDocument = ajv.compile(runClubScheduleLockDocumentSchema);
export const validateUserRunScheduleLockDocument = ajv.compile(userRunScheduleLockDocumentSchema);
export const validateSavedRunDocument = ajv.compile(savedRunDocumentSchema);
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
export const validateSeedRunManifestDocument = ajv.compile(seedRunManifestDocumentSchema);
export const validateUpdateUserProfileCallablePayload = ajv.compile(updateUserProfileCallablePayloadSchema);
export const validateCreateRunClubCallablePayload = ajv.compile(createRunClubCallablePayloadSchema);
export const validateUpdateRunClubCallablePayload = ajv.compile(updateRunClubCallablePayloadSchema);
export const validateArchiveRunClubCallablePayload = ajv.compile(archiveRunClubCallablePayloadSchema);
export const validateDeleteRunClubCallablePayload = ajv.compile(deleteRunClubCallablePayloadSchema);
export const validateRunClubMembershipCallablePayload = ajv.compile(runClubMembershipCallablePayloadSchema);
export const validateSetRunClubNotificationPreferenceCallablePayload = ajv.compile(setRunClubNotificationPreferenceCallablePayloadSchema);
export const validateCreateRunCallablePayload = ajv.compile(createRunCallablePayloadSchema);
export const validateUpdateRunCallablePayload = ajv.compile(updateRunCallablePayloadSchema);
export const validateCancelRunCallablePayload = ajv.compile(cancelRunCallablePayloadSchema);
export const validateDeleteRunCallablePayload = ajv.compile(deleteRunCallablePayloadSchema);
export const validateRunIdCallablePayload = ajv.compile(runIdCallablePayloadSchema);
export const validateMarkRunAttendanceCallablePayload = ajv.compile(markRunAttendanceCallablePayloadSchema);
export const validateSelfCheckInAttendanceCallablePayload = ajv.compile(selfCheckInAttendanceCallablePayloadSchema);
export const validateCreateRunReviewCallablePayload = ajv.compile(createRunReviewCallablePayloadSchema);
export const validateUpdateRunReviewCallablePayload = ajv.compile(updateRunReviewCallablePayloadSchema);
export const validateDeleteRunReviewCallablePayload = ajv.compile(deleteRunReviewCallablePayloadSchema);
export const validateBlockUserCallablePayload = ajv.compile(blockUserCallablePayloadSchema);
export const validateUnblockUserCallablePayload = ajv.compile(unblockUserCallablePayloadSchema);
export const validateReportUserCallablePayload = ajv.compile(reportUserCallablePayloadSchema);
export const validateVerifyRazorpayPaymentCallablePayload = ajv.compile(verifyRazorpayPaymentCallablePayloadSchema);
export const validatePlacesAutocompleteCallablePayload = ajv.compile(placesAutocompleteCallablePayloadSchema);
export const validatePlaceDetailsCallablePayload = ajv.compile(placeDetailsCallablePayloadSchema);
export const validateCreateProfileDecisionClientWrite = ajv.compile(createProfileDecisionClientWriteSchema);
export const validateCreateChatMessageClientWrite = ajv.compile(createChatMessageClientWriteSchema);
export const validateCreateSavedRunClientWrite = ajv.compile(createSavedRunClientWriteSchema);
export const validateDeleteSavedRunClientWrite = ajv.compile(deleteSavedRunClientWriteSchema);
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
