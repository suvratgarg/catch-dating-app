/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

import Ajv, {ValidateFunction} from "ajv";
import addFormats from "ajv-formats";
import {ProfilePromptAnswer} from "./profilePromptAnswer";
import {PhotoPromptAnswer} from "./photoPromptAnswer";
import {ProfilePhoto} from "./profilePhoto";
import {ConfigCitiesDocument} from "./configCitiesDocument";
import {OnboardingDraftDocument} from "./onboardingDraftDocument";
import {UserProfileDocument} from "./userProfileDocument";
import {PublicProfileDocument} from "./publicProfileDocument";
import {RunClubDocument} from "./runClubDocument";
import {RunClubMembershipDocument} from "./runClubMembershipDocument";
import {RunClubHostClaimDocument} from "./runClubHostClaimDocument";
import {RunDocument} from "./runDocument";
import {RunParticipationDocument} from "./runParticipationDocument";
import {RunClubScheduleLockDocument} from "./runClubScheduleLockDocument";
import {UserRunScheduleLockDocument} from "./userRunScheduleLockDocument";
import {SavedRunDocument} from "./savedRunDocument";
import {PaymentDocument} from "./paymentDocument";
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
import {SeedRunManifestDocument} from "./seedRunManifestDocument";
import {UpdateUserProfileCallablePayload} from "./updateUserProfileCallablePayload";
import {CreateRunClubCallablePayload} from "./createRunClubCallablePayload";
import {UpdateRunClubCallablePayload} from "./updateRunClubCallablePayload";
import {ArchiveRunClubCallablePayload} from "./archiveRunClubCallablePayload";
import {DeleteRunClubCallablePayload} from "./deleteRunClubCallablePayload";
import {RunClubMembershipCallablePayload} from "./runClubMembershipCallablePayload";
import {SetRunClubNotificationPreferenceCallablePayload} from "./setRunClubNotificationPreferenceCallablePayload";
import {CreateRunCallablePayload} from "./createRunCallablePayload";
import {UpdateRunCallablePayload} from "./updateRunCallablePayload";
import {CancelRunCallablePayload} from "./cancelRunCallablePayload";
import {DeleteRunCallablePayload} from "./deleteRunCallablePayload";
import {RunIdCallablePayload} from "./runIdCallablePayload";
import {MarkRunAttendanceCallablePayload} from "./markRunAttendanceCallablePayload";
import {SelfCheckInAttendanceCallablePayload} from "./selfCheckInAttendanceCallablePayload";
import {CreateRunReviewCallablePayload} from "./createRunReviewCallablePayload";
import {UpdateRunReviewCallablePayload} from "./updateRunReviewCallablePayload";
import {DeleteRunReviewCallablePayload} from "./deleteRunReviewCallablePayload";
import {BlockUserCallablePayload} from "./blockUserCallablePayload";
import {UnblockUserCallablePayload} from "./unblockUserCallablePayload";
import {ReportUserCallablePayload} from "./reportUserCallablePayload";
import {VerifyRazorpayPaymentCallablePayload} from "./verifyRazorpayPaymentCallablePayload";
import {PlacesAutocompleteCallablePayload} from "./placesAutocompleteCallablePayload";
import {PlaceDetailsCallablePayload} from "./placeDetailsCallablePayload";
import {CreateProfileDecisionClientWrite} from "./createProfileDecisionClientWrite";
import {CreateChatMessageClientWrite} from "./createChatMessageClientWrite";
import {CreateSavedRunClientWrite} from "./createSavedRunClientWrite";
import {DeleteSavedRunClientWrite} from "./deleteSavedRunClientWrite";
import {MarkNotificationReadClientWrite} from "./markNotificationReadClientWrite";
import {ResetMatchUnreadCountClientWrite} from "./resetMatchUnreadCountClientWrite";
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
} from "./schemaRegistry";

const ajv = new Ajv({allErrors: true, strict: false});
addFormats(ajv);

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
export const validateRunClubDocument:
  ValidateFunction<RunClubDocument> =
    ajv.compile(runClubDocumentSchema) as
      ValidateFunction<RunClubDocument>;
export const validateRunClubMembershipDocument:
  ValidateFunction<RunClubMembershipDocument> =
    ajv.compile(runClubMembershipDocumentSchema) as
      ValidateFunction<RunClubMembershipDocument>;
export const validateRunClubHostClaimDocument:
  ValidateFunction<RunClubHostClaimDocument> =
    ajv.compile(runClubHostClaimDocumentSchema) as
      ValidateFunction<RunClubHostClaimDocument>;
export const validateRunDocument:
  ValidateFunction<RunDocument> =
    ajv.compile(runDocumentSchema) as
      ValidateFunction<RunDocument>;
export const validateRunParticipationDocument:
  ValidateFunction<RunParticipationDocument> =
    ajv.compile(runParticipationDocumentSchema) as
      ValidateFunction<RunParticipationDocument>;
export const validateRunClubScheduleLockDocument:
  ValidateFunction<RunClubScheduleLockDocument> =
    ajv.compile(runClubScheduleLockDocumentSchema) as
      ValidateFunction<RunClubScheduleLockDocument>;
export const validateUserRunScheduleLockDocument:
  ValidateFunction<UserRunScheduleLockDocument> =
    ajv.compile(userRunScheduleLockDocumentSchema) as
      ValidateFunction<UserRunScheduleLockDocument>;
export const validateSavedRunDocument:
  ValidateFunction<SavedRunDocument> =
    ajv.compile(savedRunDocumentSchema) as
      ValidateFunction<SavedRunDocument>;
export const validatePaymentDocument:
  ValidateFunction<PaymentDocument> =
    ajv.compile(paymentDocumentSchema) as
      ValidateFunction<PaymentDocument>;
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
export const validateSeedRunManifestDocument:
  ValidateFunction<SeedRunManifestDocument> =
    ajv.compile(seedRunManifestDocumentSchema) as
      ValidateFunction<SeedRunManifestDocument>;
export const validateUpdateUserProfileCallablePayload:
  ValidateFunction<UpdateUserProfileCallablePayload> =
    ajv.compile(updateUserProfileCallablePayloadSchema) as
      ValidateFunction<UpdateUserProfileCallablePayload>;
export const validateCreateRunClubCallablePayload:
  ValidateFunction<CreateRunClubCallablePayload> =
    ajv.compile(createRunClubCallablePayloadSchema) as
      ValidateFunction<CreateRunClubCallablePayload>;
export const validateUpdateRunClubCallablePayload:
  ValidateFunction<UpdateRunClubCallablePayload> =
    ajv.compile(updateRunClubCallablePayloadSchema) as
      ValidateFunction<UpdateRunClubCallablePayload>;
export const validateArchiveRunClubCallablePayload:
  ValidateFunction<ArchiveRunClubCallablePayload> =
    ajv.compile(archiveRunClubCallablePayloadSchema) as
      ValidateFunction<ArchiveRunClubCallablePayload>;
export const validateDeleteRunClubCallablePayload:
  ValidateFunction<DeleteRunClubCallablePayload> =
    ajv.compile(deleteRunClubCallablePayloadSchema) as
      ValidateFunction<DeleteRunClubCallablePayload>;
export const validateRunClubMembershipCallablePayload:
  ValidateFunction<RunClubMembershipCallablePayload> =
    ajv.compile(runClubMembershipCallablePayloadSchema) as
      ValidateFunction<RunClubMembershipCallablePayload>;
export const validateSetRunClubNotificationPreferenceCallablePayload:
  ValidateFunction<SetRunClubNotificationPreferenceCallablePayload> =
    ajv.compile(setRunClubNotificationPreferenceCallablePayloadSchema) as
      ValidateFunction<SetRunClubNotificationPreferenceCallablePayload>;
export const validateCreateRunCallablePayload:
  ValidateFunction<CreateRunCallablePayload> =
    ajv.compile(createRunCallablePayloadSchema) as
      ValidateFunction<CreateRunCallablePayload>;
export const validateUpdateRunCallablePayload:
  ValidateFunction<UpdateRunCallablePayload> =
    ajv.compile(updateRunCallablePayloadSchema) as
      ValidateFunction<UpdateRunCallablePayload>;
export const validateCancelRunCallablePayload:
  ValidateFunction<CancelRunCallablePayload> =
    ajv.compile(cancelRunCallablePayloadSchema) as
      ValidateFunction<CancelRunCallablePayload>;
export const validateDeleteRunCallablePayload:
  ValidateFunction<DeleteRunCallablePayload> =
    ajv.compile(deleteRunCallablePayloadSchema) as
      ValidateFunction<DeleteRunCallablePayload>;
export const validateRunIdCallablePayload:
  ValidateFunction<RunIdCallablePayload> =
    ajv.compile(runIdCallablePayloadSchema) as
      ValidateFunction<RunIdCallablePayload>;
export const validateMarkRunAttendanceCallablePayload:
  ValidateFunction<MarkRunAttendanceCallablePayload> =
    ajv.compile(markRunAttendanceCallablePayloadSchema) as
      ValidateFunction<MarkRunAttendanceCallablePayload>;
export const validateSelfCheckInAttendanceCallablePayload:
  ValidateFunction<SelfCheckInAttendanceCallablePayload> =
    ajv.compile(selfCheckInAttendanceCallablePayloadSchema) as
      ValidateFunction<SelfCheckInAttendanceCallablePayload>;
export const validateCreateRunReviewCallablePayload:
  ValidateFunction<CreateRunReviewCallablePayload> =
    ajv.compile(createRunReviewCallablePayloadSchema) as
      ValidateFunction<CreateRunReviewCallablePayload>;
export const validateUpdateRunReviewCallablePayload:
  ValidateFunction<UpdateRunReviewCallablePayload> =
    ajv.compile(updateRunReviewCallablePayloadSchema) as
      ValidateFunction<UpdateRunReviewCallablePayload>;
export const validateDeleteRunReviewCallablePayload:
  ValidateFunction<DeleteRunReviewCallablePayload> =
    ajv.compile(deleteRunReviewCallablePayloadSchema) as
      ValidateFunction<DeleteRunReviewCallablePayload>;
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
export const validateVerifyRazorpayPaymentCallablePayload:
  ValidateFunction<VerifyRazorpayPaymentCallablePayload> =
    ajv.compile(verifyRazorpayPaymentCallablePayloadSchema) as
      ValidateFunction<VerifyRazorpayPaymentCallablePayload>;
export const validatePlacesAutocompleteCallablePayload:
  ValidateFunction<PlacesAutocompleteCallablePayload> =
    ajv.compile(placesAutocompleteCallablePayloadSchema) as
      ValidateFunction<PlacesAutocompleteCallablePayload>;
export const validatePlaceDetailsCallablePayload:
  ValidateFunction<PlaceDetailsCallablePayload> =
    ajv.compile(placeDetailsCallablePayloadSchema) as
      ValidateFunction<PlaceDetailsCallablePayload>;
export const validateCreateProfileDecisionClientWrite:
  ValidateFunction<CreateProfileDecisionClientWrite> =
    ajv.compile(createProfileDecisionClientWriteSchema) as
      ValidateFunction<CreateProfileDecisionClientWrite>;
export const validateCreateChatMessageClientWrite:
  ValidateFunction<CreateChatMessageClientWrite> =
    ajv.compile(createChatMessageClientWriteSchema) as
      ValidateFunction<CreateChatMessageClientWrite>;
export const validateCreateSavedRunClientWrite:
  ValidateFunction<CreateSavedRunClientWrite> =
    ajv.compile(createSavedRunClientWriteSchema) as
      ValidateFunction<CreateSavedRunClientWrite>;
export const validateDeleteSavedRunClientWrite:
  ValidateFunction<DeleteSavedRunClientWrite> =
    ajv.compile(deleteSavedRunClientWriteSchema) as
      ValidateFunction<DeleteSavedRunClientWrite>;
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
