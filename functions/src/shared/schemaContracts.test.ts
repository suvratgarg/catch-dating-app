/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import {
  schemaErrorMessages,
  validateActivityNotificationDocument,
  validateArchiveClubCallablePayload,
  validateBlockUserCallablePayload,
  validateBlockDocument,
  validateCancelEventCallablePayload,
  validateChatMessageDocument,
  validateConfigCitiesDocument,
  validateCreateEventCallablePayload,
  validateCreateClubCallablePayload,
  validateCreateEventReviewCallablePayload,
  validateCreateChatMessageClientWrite,
  validateCreateProfileDecisionClientWrite,
  validateCreateSavedEventClientWrite,
  validateDeleteEventCallablePayload,
  validateDeleteClubCallablePayload,
  validateDeleteEventReviewCallablePayload,
  validateDeleteSavedEventClientWrite,
  validateDeletedUserTombstoneDocument,
  validateFunctionEventReceiptDocument,
  validateMarkNotificationReadClientWrite,
  validateMarkEventAttendanceCallablePayload,
  validateMatchDocument,
  validateModerationFlagDocument,
  validateOnboardingDraftDocument,
  validatePaymentDocument,
  validatePlaceDetailsCallablePayload,
  validatePlacesAutocompleteCallablePayload,
  validatePhotoPromptAnswer,
  validateProfilePhoto,
  validateProfilePromptAnswer,
  validatePublicProfileDocument,
  validateRateLimitDocument,
  validateReportDocument,
  validateReportUserCallablePayload,
  validateReviewDocument,
  validateResetMatchUnreadCountClientWrite,
  validateClubHostClaimDocument,
  validateClubScheduleLockDocument,
  validateEventIdCallablePayload,
  validateClubDocument,
  validateClubMembershipDocument,
  validateEventDocument,
  validateEventParticipationDocument,
  validateSavedEventDocument,
  validateSeedEventManifestDocument,
  validateClubMembershipCallablePayload,
  validateSelfCheckInAttendanceCallablePayload,
  validateSetClubNotificationPreferenceCallablePayload,
  validateSwipeDocument,
  validateUpdateUserProfileCallablePayload,
  validateUpdateEventCallablePayload,
  validateUpdateClubCallablePayload,
  validateUpdateEventReviewCallablePayload,
  validateUnblockUserCallablePayload,
  validateUserEventScheduleLockDocument,
  validateUserProfileDocument,
  validateVerifyRazorpayPaymentCallablePayload,
} from "./generated/schemaValidators";

type Validator = Parameters<typeof schemaErrorMessages>[0];
const contractRoot = fs.existsSync(path.resolve(process.cwd(), "contracts")) ?
  path.resolve(process.cwd(), "contracts") :
  path.resolve(process.cwd(), "..", "contracts");

function readFixture(relativePath: string): unknown {
  return JSON.parse(
    fs.readFileSync(
      path.resolve(contractRoot, relativePath),
      "utf8"
    )
  );
}

function assertValid(validator: Validator, payload: unknown) {
  assert.equal(validator(payload), true, schemaErrorMessages(validator).join(
    "\n"
  ));
}

function assertInvalid(validator: Validator, payload: unknown) {
  assert.equal(validator(payload), false);
}

test("generated schema validators accept valid contract fixtures", () => {
  assertValid(
    validateProfilePromptAnswer as Validator,
    readFixture("fixtures/valid/profile_prompt_answer.json")
  );
  assertValid(
    validatePhotoPromptAnswer as Validator,
    readFixture("fixtures/valid/photo_prompt_answer.json")
  );
  assertValid(
    validateProfilePhoto as Validator,
    readFixture("fixtures/valid/profile_photo.json")
  );
  assertValid(
    validateConfigCitiesDocument as Validator,
    readFixture("fixtures/valid/config_cities_doc.json")
  );
  assertValid(
    validateOnboardingDraftDocument as Validator,
    readFixture("fixtures/valid/onboarding_draft_doc.json")
  );
  assertValid(
    validateUserProfileDocument as Validator,
    readFixture("fixtures/valid/user_profile_doc.json")
  );
  assertValid(
    validatePublicProfileDocument as Validator,
    readFixture("fixtures/valid/public_profile_doc.json")
  );
  assertValid(
    validateClubDocument as Validator,
    readFixture("fixtures/valid/club_doc.json")
  );
  assertValid(
    validateClubMembershipDocument as Validator,
    readFixture("fixtures/valid/club_membership_doc.json")
  );
  assertValid(
    validateClubHostClaimDocument as Validator,
    readFixture("fixtures/valid/club_host_claim_doc.json")
  );
  assertValid(
    validateEventDocument as Validator,
    readFixture("fixtures/valid/event_doc.json")
  );
  assertValid(
    validateEventParticipationDocument as Validator,
    readFixture("fixtures/valid/event_participation_doc.json")
  );
  assertValid(
    validateClubScheduleLockDocument as Validator,
    readFixture("fixtures/valid/club_schedule_lock_doc.json")
  );
  assertValid(
    validateUserEventScheduleLockDocument as Validator,
    readFixture("fixtures/valid/user_event_schedule_lock_doc.json")
  );
  assertValid(
    validateSavedEventDocument as Validator,
    readFixture("fixtures/valid/saved_event_doc.json")
  );
  assertValid(
    validatePaymentDocument as Validator,
    readFixture("fixtures/valid/payment_doc.json")
  );
  assertValid(
    validateSwipeDocument as Validator,
    readFixture("fixtures/valid/swipe_doc.json")
  );
  assertValid(
    validateMatchDocument as Validator,
    readFixture("fixtures/valid/match_doc.json")
  );
  assertValid(
    validateChatMessageDocument as Validator,
    readFixture("fixtures/valid/chat_message_doc.json")
  );
  assertValid(
    validateActivityNotificationDocument as Validator,
    readFixture("fixtures/valid/activity_notification_doc.json")
  );
  assertValid(
    validateReviewDocument as Validator,
    readFixture("fixtures/valid/review_doc.json")
  );
  assertValid(
    validateBlockDocument as Validator,
    readFixture("fixtures/valid/block_doc.json")
  );
  assertValid(
    validateReportDocument as Validator,
    readFixture("fixtures/valid/report_doc.json")
  );
  assertValid(
    validateModerationFlagDocument as Validator,
    readFixture("fixtures/valid/moderation_flag_doc.json")
  );
  assertValid(
    validateDeletedUserTombstoneDocument as Validator,
    readFixture("fixtures/valid/deleted_user_tombstone_doc.json")
  );
  assertValid(
    validateRateLimitDocument as Validator,
    readFixture("fixtures/valid/rate_limit_doc.json")
  );
  assertValid(
    validateFunctionEventReceiptDocument as Validator,
    readFixture("fixtures/valid/function_event_receipt_doc.json")
  );
  assertValid(
    validateSeedEventManifestDocument as Validator,
    readFixture("fixtures/valid/seed_event_manifest_doc.json")
  );
  assertValid(
    validateUpdateUserProfileCallablePayload as Validator,
    readFixture("fixtures/valid/update_user_profile_patch.json")
  );
  assertValid(
    validateCreateClubCallablePayload as Validator,
    readFixture("fixtures/valid/create_club_payload.json")
  );
  assertValid(
    validateUpdateClubCallablePayload as Validator,
    readFixture("fixtures/valid/update_club_payload.json")
  );
  assertValid(
    validateArchiveClubCallablePayload as Validator,
    readFixture("fixtures/valid/archive_club_payload.json")
  );
  assertValid(
    validateDeleteClubCallablePayload as Validator,
    readFixture("fixtures/valid/delete_club_payload.json")
  );
  assertValid(
    validateClubMembershipCallablePayload as Validator,
    readFixture("fixtures/valid/club_membership_payload.json")
  );
  assertValid(
    validateSetClubNotificationPreferenceCallablePayload as Validator,
    readFixture(
      "fixtures/valid/set_club_notification_preference_payload.json"
    )
  );
  assertValid(
    validateCreateEventCallablePayload as Validator,
    readFixture("fixtures/valid/create_event_payload.json")
  );
  assertValid(
    validateUpdateEventCallablePayload as Validator,
    readFixture("fixtures/valid/update_event_payload.json")
  );
  assertValid(
    validateCancelEventCallablePayload as Validator,
    readFixture("fixtures/valid/cancel_event_payload.json")
  );
  assertValid(
    validateDeleteEventCallablePayload as Validator,
    readFixture("fixtures/valid/delete_event_payload.json")
  );
  assertValid(
    validateEventIdCallablePayload as Validator,
    readFixture("fixtures/valid/event_id_payload.json")
  );
  assertValid(
    validateMarkEventAttendanceCallablePayload as Validator,
    readFixture("fixtures/valid/mark_event_attendance_payload.json")
  );
  assertValid(
    validateSelfCheckInAttendanceCallablePayload as Validator,
    readFixture("fixtures/valid/self_check_in_attendance_payload.json")
  );
  assertValid(
    validateCreateEventReviewCallablePayload as Validator,
    readFixture("fixtures/valid/create_event_review_payload.json")
  );
  assertValid(
    validateUpdateEventReviewCallablePayload as Validator,
    readFixture("fixtures/valid/update_event_review_payload.json")
  );
  assertValid(
    validateDeleteEventReviewCallablePayload as Validator,
    readFixture("fixtures/valid/delete_event_review_payload.json")
  );
  assertValid(
    validateBlockUserCallablePayload as Validator,
    readFixture("fixtures/valid/block_user_payload.json")
  );
  assertValid(
    validateUnblockUserCallablePayload as Validator,
    readFixture("fixtures/valid/unblock_user_payload.json")
  );
  assertValid(
    validateReportUserCallablePayload as Validator,
    readFixture("fixtures/valid/report_user_payload.json")
  );
  assertValid(
    validateVerifyRazorpayPaymentCallablePayload as Validator,
    readFixture("fixtures/valid/verify_razorpay_payment_payload.json")
  );
  assertValid(
    validatePlacesAutocompleteCallablePayload as Validator,
    readFixture("fixtures/valid/places_autocomplete_payload.json")
  );
  assertValid(
    validatePlaceDetailsCallablePayload as Validator,
    readFixture("fixtures/valid/place_details_payload.json")
  );
  assertValid(
    validateCreateProfileDecisionClientWrite as Validator,
    readFixture("fixtures/valid/create_profile_decision_client_write.json")
  );
  assertValid(
    validateCreateChatMessageClientWrite as Validator,
    readFixture("fixtures/valid/create_chat_message_client_write.json")
  );
  assertValid(
    validateCreateSavedEventClientWrite as Validator,
    readFixture("fixtures/valid/create_saved_event_client_write.json")
  );
  assertValid(
    validateDeleteSavedEventClientWrite as Validator,
    readFixture("fixtures/valid/delete_saved_event_client_write.json")
  );
  assertValid(
    validateMarkNotificationReadClientWrite as Validator,
    readFixture("fixtures/valid/mark_notification_read_client_write.json")
  );
  assertValid(
    validateResetMatchUnreadCountClientWrite as Validator,
    readFixture("fixtures/valid/reset_match_unread_count_client_write.json")
  );
});

test("generated schema validators reject invalid contract fixtures", () => {
  assertInvalid(
    validateProfilePromptAnswer as Validator,
    readFixture("fixtures/invalid/profile_prompt_answer_overlong.json")
  );
  assertInvalid(
    validateProfilePhoto as Validator,
    readFixture("fixtures/invalid/profile_photo_invalid_storage_path.json")
  );
  assertInvalid(
    validateUserProfileDocument as Validator,
    readFixture("fixtures/invalid/user_profile_legacy_bio.json")
  );
  assertInvalid(
    validateUpdateUserProfileCallablePayload as Validator,
    readFixture("fixtures/invalid/update_user_profile_empty_patch.json")
  );
  assertInvalid(
    validateUpdateUserProfileCallablePayload as Validator,
    readFixture("fixtures/invalid/update_user_profile_height_out_of_range.json")
  );
  assertInvalid(
    validateUpdateUserProfileCallablePayload as Validator,
    readFixture("fixtures/invalid/update_user_profile_invalid_email.json")
  );
  assertInvalid(
    validateEventDocument as Validator,
    readFixture("fixtures/invalid/event_doc_invalid_pace.json")
  );
  assertInvalid(
    validateSwipeDocument as Validator,
    readFixture("fixtures/invalid/swipe_doc_invalid_reaction_target.json")
  );
  assertInvalid(
    validateClubScheduleLockDocument as Validator,
    readFixture("fixtures/invalid/club_schedule_lock_invalid_owner.json")
  );
  assertInvalid(
    validateUpdateClubCallablePayload as Validator,
    readFixture("fixtures/invalid/update_club_empty_fields.json")
  );
  assertInvalid(
    validateUpdateEventCallablePayload as Validator,
    readFixture("fixtures/invalid/update_event_empty_fields.json")
  );
  assertInvalid(
    validateCreateEventReviewCallablePayload as Validator,
    readFixture("fixtures/invalid/create_event_review_invalid_rating.json")
  );
  assertInvalid(
    validatePlacesAutocompleteCallablePayload as Validator,
    readFixture("fixtures/invalid/places_autocomplete_short_input.json")
  );
  assertInvalid(
    validateCreateChatMessageClientWrite as Validator,
    readFixture("fixtures/invalid/create_chat_message_empty_client_write.json")
  );
  assertInvalid(
    validateResetMatchUnreadCountClientWrite as Validator,
    readFixture("fixtures/invalid/reset_match_unread_count_multiple_users.json")
  );
});
