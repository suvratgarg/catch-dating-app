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
import {ClubDocument} from "./clubDocument";
import {ClubMembershipDocument} from "./clubMembershipDocument";
import {ClubHostClaimDocument} from "./clubHostClaimDocument";
import {EventDocument} from "./eventDocument";
import {EventParticipationDocument} from "./eventParticipationDocument";
import {EventSuccessPlanDocument} from "./eventSuccessPlanDocument";
import {EventSuccessFeedbackDocument} from "./eventSuccessFeedbackDocument";
import {ClubScheduleLockDocument} from "./clubScheduleLockDocument";
import {UserEventScheduleLockDocument} from "./userEventScheduleLockDocument";
import {SavedEventDocument} from "./savedEventDocument";
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
import {SeedEventManifestDocument} from "./seedEventManifestDocument";
import {UpdateUserProfileCallablePayload} from "./updateUserProfileCallablePayload";
import {CreateClubCallablePayload} from "./createClubCallablePayload";
import {UpdateClubCallablePayload} from "./updateClubCallablePayload";
import {ArchiveClubCallablePayload} from "./archiveClubCallablePayload";
import {DeleteClubCallablePayload} from "./deleteClubCallablePayload";
import {ClubMembershipCallablePayload} from "./clubMembershipCallablePayload";
import {SetClubNotificationPreferenceCallablePayload} from "./setClubNotificationPreferenceCallablePayload";
import {CreateEventCallablePayload} from "./createEventCallablePayload";
import {UpdateEventCallablePayload} from "./updateEventCallablePayload";
import {CancelEventCallablePayload} from "./cancelEventCallablePayload";
import {DeleteEventCallablePayload} from "./deleteEventCallablePayload";
import {EventIdCallablePayload} from "./eventIdCallablePayload";
import {MarkEventAttendanceCallablePayload} from "./markEventAttendanceCallablePayload";
import {SelfCheckInAttendanceCallablePayload} from "./selfCheckInAttendanceCallablePayload";
import {CreateEventReviewCallablePayload} from "./createEventReviewCallablePayload";
import {UpdateEventReviewCallablePayload} from "./updateEventReviewCallablePayload";
import {DeleteEventReviewCallablePayload} from "./deleteEventReviewCallablePayload";
import {BlockUserCallablePayload} from "./blockUserCallablePayload";
import {UnblockUserCallablePayload} from "./unblockUserCallablePayload";
import {ReportUserCallablePayload} from "./reportUserCallablePayload";
import {VerifyRazorpayPaymentCallablePayload} from "./verifyRazorpayPaymentCallablePayload";
import {PlacesAutocompleteCallablePayload} from "./placesAutocompleteCallablePayload";
import {PlaceDetailsCallablePayload} from "./placeDetailsCallablePayload";
import {CreateProfileDecisionClientWrite} from "./createProfileDecisionClientWrite";
import {CreateChatMessageClientWrite} from "./createChatMessageClientWrite";
import {CreateSavedEventClientWrite} from "./createSavedEventClientWrite";
import {DeleteSavedEventClientWrite} from "./deleteSavedEventClientWrite";
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
  clubDocumentSchema,
  clubMembershipDocumentSchema,
  clubHostClaimDocumentSchema,
  eventDocumentSchema,
  eventParticipationDocumentSchema,
  eventSuccessPlanDocumentSchema,
  eventSuccessFeedbackDocumentSchema,
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
  updateClubCallablePayloadSchema,
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
  selfCheckInAttendanceCallablePayloadSchema,
  createEventReviewCallablePayloadSchema,
  updateEventReviewCallablePayloadSchema,
  deleteEventReviewCallablePayloadSchema,
  blockUserCallablePayloadSchema,
  unblockUserCallablePayloadSchema,
  reportUserCallablePayloadSchema,
  verifyRazorpayPaymentCallablePayloadSchema,
  placesAutocompleteCallablePayloadSchema,
  placeDetailsCallablePayloadSchema,
  createProfileDecisionClientWriteSchema,
  createChatMessageClientWriteSchema,
  createSavedEventClientWriteSchema,
  deleteSavedEventClientWriteSchema,
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
export const validateClubDocument:
  ValidateFunction<ClubDocument> =
    ajv.compile(clubDocumentSchema) as
      ValidateFunction<ClubDocument>;
export const validateClubMembershipDocument:
  ValidateFunction<ClubMembershipDocument> =
    ajv.compile(clubMembershipDocumentSchema) as
      ValidateFunction<ClubMembershipDocument>;
export const validateClubHostClaimDocument:
  ValidateFunction<ClubHostClaimDocument> =
    ajv.compile(clubHostClaimDocumentSchema) as
      ValidateFunction<ClubHostClaimDocument>;
export const validateEventDocument:
  ValidateFunction<EventDocument> =
    ajv.compile(eventDocumentSchema) as
      ValidateFunction<EventDocument>;
export const validateEventParticipationDocument:
  ValidateFunction<EventParticipationDocument> =
    ajv.compile(eventParticipationDocumentSchema) as
      ValidateFunction<EventParticipationDocument>;
export const validateEventSuccessPlanDocument:
  ValidateFunction<EventSuccessPlanDocument> =
    ajv.compile(eventSuccessPlanDocumentSchema) as
      ValidateFunction<EventSuccessPlanDocument>;
export const validateEventSuccessFeedbackDocument:
  ValidateFunction<EventSuccessFeedbackDocument> =
    ajv.compile(eventSuccessFeedbackDocumentSchema) as
      ValidateFunction<EventSuccessFeedbackDocument>;
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
export const validateSeedEventManifestDocument:
  ValidateFunction<SeedEventManifestDocument> =
    ajv.compile(seedEventManifestDocumentSchema) as
      ValidateFunction<SeedEventManifestDocument>;
export const validateUpdateUserProfileCallablePayload:
  ValidateFunction<UpdateUserProfileCallablePayload> =
    ajv.compile(updateUserProfileCallablePayloadSchema) as
      ValidateFunction<UpdateUserProfileCallablePayload>;
export const validateCreateClubCallablePayload:
  ValidateFunction<CreateClubCallablePayload> =
    ajv.compile(createClubCallablePayloadSchema) as
      ValidateFunction<CreateClubCallablePayload>;
export const validateUpdateClubCallablePayload:
  ValidateFunction<UpdateClubCallablePayload> =
    ajv.compile(updateClubCallablePayloadSchema) as
      ValidateFunction<UpdateClubCallablePayload>;
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
export const validateMarkEventAttendanceCallablePayload:
  ValidateFunction<MarkEventAttendanceCallablePayload> =
    ajv.compile(markEventAttendanceCallablePayloadSchema) as
      ValidateFunction<MarkEventAttendanceCallablePayload>;
export const validateSelfCheckInAttendanceCallablePayload:
  ValidateFunction<SelfCheckInAttendanceCallablePayload> =
    ajv.compile(selfCheckInAttendanceCallablePayloadSchema) as
      ValidateFunction<SelfCheckInAttendanceCallablePayload>;
export const validateCreateEventReviewCallablePayload:
  ValidateFunction<CreateEventReviewCallablePayload> =
    ajv.compile(createEventReviewCallablePayloadSchema) as
      ValidateFunction<CreateEventReviewCallablePayload>;
export const validateUpdateEventReviewCallablePayload:
  ValidateFunction<UpdateEventReviewCallablePayload> =
    ajv.compile(updateEventReviewCallablePayloadSchema) as
      ValidateFunction<UpdateEventReviewCallablePayload>;
export const validateDeleteEventReviewCallablePayload:
  ValidateFunction<DeleteEventReviewCallablePayload> =
    ajv.compile(deleteEventReviewCallablePayloadSchema) as
      ValidateFunction<DeleteEventReviewCallablePayload>;
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
