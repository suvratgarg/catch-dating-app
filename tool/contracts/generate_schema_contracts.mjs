#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath} from "node:url";

const requireFromFunctions = createRequire(
  new URL("../../functions/package.json", import.meta.url)
);
const {compile} = requireFromFunctions("json-schema-to-typescript");

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "../..");
const contractRoot = path.join(repoRoot, "contracts");
const checkOnly = process.argv.includes("--check");

const schemaSpecs = [
  {
    name: "ProfilePromptAnswer",
    source: "embedded/profile_prompt_answer.schema.json",
    typeOutput: "functions/src/shared/generated/profilePromptAnswer.ts",
  },
  {
    name: "PhotoPromptAnswer",
    source: "embedded/photo_prompt_answer.schema.json",
    typeOutput: "functions/src/shared/generated/photoPromptAnswer.ts",
  },
  {
    name: "ProfilePhoto",
    source: "embedded/profile_photo.schema.json",
    typeOutput: "functions/src/shared/generated/profilePhoto.ts",
  },
  {
    name: "ActivityPreferences",
    source: "embedded/activity_preferences.schema.json",
    typeOutput: "functions/src/shared/generated/activityPreferences.ts",
  },
  {
    name: "ConfigCitiesDocument",
    source: "firestore/config_cities.schema.json",
    typeOutput: "functions/src/shared/generated/configCitiesDocument.ts",
  },
  {
    name: "OnboardingDraftDocument",
    source: "firestore/onboarding_drafts.schema.json",
    typeOutput: "functions/src/shared/generated/onboardingDraftDocument.ts",
  },
  {
    name: "UserProfileDocument",
    source: "firestore/users.schema.json",
    typeOutput: "functions/src/shared/generated/userProfileDocument.ts",
  },
  {
    name: "PublicProfileDocument",
    source: "firestore/public_profiles.schema.json",
    typeOutput: "functions/src/shared/generated/publicProfileDocument.ts",
  },
  {
    name: "ClubDocument",
    source: "firestore/clubs.schema.json",
    typeOutput: "functions/src/shared/generated/clubDocument.ts",
  },
  {
    name: "ClubMembershipDocument",
    source: "firestore/club_memberships.schema.json",
    typeOutput: "functions/src/shared/generated/clubMembershipDocument.ts",
  },
  {
    name: "ClubHostClaimDocument",
    source: "firestore/club_host_claims.schema.json",
    typeOutput: "functions/src/shared/generated/clubHostClaimDocument.ts",
  },
  {
    name: "EventDocument",
    source: "firestore/events.schema.json",
    typeOutput: "functions/src/shared/generated/eventDocument.ts",
  },
  {
    name: "EventPrivateAccessDocument",
    source: "firestore/event_private_access.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventPrivateAccessDocument.ts",
  },
  {
    name: "EventParticipationDocument",
    source: "firestore/event_participations.schema.json",
    typeOutput: "functions/src/shared/generated/eventParticipationDocument.ts",
  },
  {
    name: "EventSuccessPlanDocument",
    source: "firestore/event_success_plans.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessPlanDocument.ts",
  },
  {
    name: "EventSuccessFeedbackDocument",
    source: "firestore/event_success_feedback.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessFeedbackDocument.ts",
  },
  {
    name: "EventSuccessPreferenceDocument",
    source: "firestore/event_success_preferences.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessPreferenceDocument.ts",
  },
  {
    name: "EventSuccessCompatibilityResponseDocument",
    source: "firestore/event_success_compatibility_responses.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessCompatibilityResponseDocument.ts",
  },
  {
    name: "EventSuccessWingmanRequestDocument",
    source: "firestore/event_success_wingman_requests.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessWingmanRequestDocument.ts",
  },
  {
    name: "EventSuccessArrivalMissionDocument",
    source: "firestore/event_success_arrival_missions.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessArrivalMissionDocument.ts",
  },
  {
    name: "EventSuccessAssignmentDocument",
    source: "firestore/event_success_assignments.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessAssignmentDocument.ts",
  },
  {
    name: "EventSuccessScorecardDocument",
    source: "firestore/event_success_scorecards.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessScorecardDocument.ts",
  },
  {
    name: "EventSafetyReportDocument",
    source: "firestore/event_safety_reports.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSafetyReportDocument.ts",
  },
  {
    name: "ClubScheduleLockDocument",
    source: "firestore/club_schedule_locks.schema.json",
    typeOutput:
      "functions/src/shared/generated/clubScheduleLockDocument.ts",
  },
  {
    name: "UserEventScheduleLockDocument",
    source: "firestore/user_event_schedule_locks.schema.json",
    typeOutput:
      "functions/src/shared/generated/userEventScheduleLockDocument.ts",
  },
  {
    name: "SavedEventDocument",
    source: "firestore/saved_events.schema.json",
    typeOutput: "functions/src/shared/generated/savedEventDocument.ts",
  },
  {
    name: "PaymentDocument",
    source: "firestore/payments.schema.json",
    typeOutput: "functions/src/shared/generated/paymentDocument.ts",
  },
  {
    name: "SwipeDocument",
    source: "firestore/swipes.schema.json",
    typeOutput: "functions/src/shared/generated/swipeDocument.ts",
  },
  {
    name: "MatchDocument",
    source: "firestore/matches.schema.json",
    typeOutput: "functions/src/shared/generated/matchDocument.ts",
  },
  {
    name: "ChatMessageDocument",
    source: "firestore/chat_messages.schema.json",
    typeOutput: "functions/src/shared/generated/chatMessageDocument.ts",
  },
  {
    name: "ActivityNotificationDocument",
    source: "firestore/activity_notifications.schema.json",
    typeOutput:
      "functions/src/shared/generated/activityNotificationDocument.ts",
  },
  {
    name: "ReviewDocument",
    source: "firestore/reviews.schema.json",
    typeOutput: "functions/src/shared/generated/reviewDocument.ts",
  },
  {
    name: "BlockDocument",
    source: "firestore/blocks.schema.json",
    typeOutput: "functions/src/shared/generated/blockDocument.ts",
  },
  {
    name: "ReportDocument",
    source: "firestore/reports.schema.json",
    typeOutput: "functions/src/shared/generated/reportDocument.ts",
  },
  {
    name: "ModerationFlagDocument",
    source: "firestore/moderation_flags.schema.json",
    typeOutput: "functions/src/shared/generated/moderationFlagDocument.ts",
  },
  {
    name: "DeletedUserTombstoneDocument",
    source: "firestore/deleted_users.schema.json",
    typeOutput:
      "functions/src/shared/generated/deletedUserTombstoneDocument.ts",
  },
  {
    name: "RateLimitDocument",
    source: "firestore/rate_limits.schema.json",
    typeOutput: "functions/src/shared/generated/rateLimitDocument.ts",
  },
  {
    name: "FunctionEventReceiptDocument",
    source: "firestore/function_event_receipts.schema.json",
    typeOutput:
      "functions/src/shared/generated/functionEventReceiptDocument.ts",
  },
  {
    name: "SeedEventManifestDocument",
    source: "firestore/seed_events.schema.json",
    typeOutput: "functions/src/shared/generated/seedEventManifestDocument.ts",
  },
  {
    name: "UpdateUserProfileCallablePayload",
    source: "patches/update_user_profile.schema.json",
    typeOutput:
      "functions/src/shared/generated/updateUserProfileCallablePayload.ts",
  },
  {
    name: "CreateClubCallablePayload",
    source: "callables/create_club_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/createClubCallablePayload.ts",
  },
  {
    name: "CreateClubCallableResponse",
    source: "callable_responses/create_club_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/createClubCallableResponse.ts",
  },
  {
    name: "UpdateClubCallablePayload",
    source: "callables/update_club_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/updateClubCallablePayload.ts",
  },
  {
    name: "AddClubHostCallablePayload",
    source: "callables/add_club_host_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/addClubHostCallablePayload.ts",
  },
  {
    name: "RemoveClubHostCallablePayload",
    source: "callables/remove_club_host_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/removeClubHostCallablePayload.ts",
  },
  {
    name: "TransferClubOwnershipCallablePayload",
    source: "callables/transfer_club_ownership_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/transferClubOwnershipCallablePayload.ts",
  },
  {
    name: "StartClubHostConversationCallablePayload",
    source: "callables/start_club_host_conversation_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/startClubHostConversationCallablePayload.ts",
  },
  {
    name: "ArchiveClubCallablePayload",
    source: "callables/archive_club_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/archiveClubCallablePayload.ts",
  },
  {
    name: "DeleteClubCallablePayload",
    source: "callables/delete_club_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/deleteClubCallablePayload.ts",
  },
  {
    name: "ClubMembershipCallablePayload",
    source: "callables/club_membership_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/clubMembershipCallablePayload.ts",
  },
  {
    name: "SetClubNotificationPreferenceCallablePayload",
    source: "callables/set_club_notification_preference_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/setClubNotificationPreferenceCallablePayload.ts",
  },
  {
    name: "CreateEventCallablePayload",
    source: "callables/create_event_payload.schema.json",
    typeOutput: "functions/src/shared/generated/createEventCallablePayload.ts",
  },
  {
    name: "UpdateEventCallablePayload",
    source: "callables/update_event_payload.schema.json",
    typeOutput: "functions/src/shared/generated/updateEventCallablePayload.ts",
  },
  {
    name: "CancelEventCallablePayload",
    source: "callables/cancel_event_payload.schema.json",
    typeOutput: "functions/src/shared/generated/cancelEventCallablePayload.ts",
  },
  {
    name: "DeleteEventCallablePayload",
    source: "callables/delete_event_payload.schema.json",
    typeOutput: "functions/src/shared/generated/deleteEventCallablePayload.ts",
  },
  {
    name: "EventIdCallablePayload",
    source: "callables/event_id_payload.schema.json",
    typeOutput: "functions/src/shared/generated/eventIdCallablePayload.ts",
  },
  {
    name: "MarkEventAttendanceCallablePayload",
    source: "callables/mark_event_attendance_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/markEventAttendanceCallablePayload.ts",
  },
  {
    name: "EventJoinRequestDecisionCallablePayload",
    source: "callables/event_join_request_decision_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "eventJoinRequestDecisionCallablePayload.ts",
  },
  {
    name: "OverrideEventSuccessRotationsCallablePayload",
    source: "callables/override_event_success_rotations_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "overrideEventSuccessRotationsCallablePayload.ts",
  },
  {
    name: "OverrideEventSuccessGroupsCallablePayload",
    source: "callables/override_event_success_groups_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "overrideEventSuccessGroupsCallablePayload.ts",
  },
  {
    name: "SubmitEventSuccessWingmanRequestCallablePayload",
    source:
      "callables/submit_event_success_wingman_request_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "submitEventSuccessWingmanRequestCallablePayload.ts",
  },
  {
    name: "StartEventSuccessFirstHelloMissionCallablePayload",
    source:
      "callables/start_event_success_first_hello_mission_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "startEventSuccessFirstHelloMissionCallablePayload.ts",
  },
  {
    name: "CompleteEventSuccessFirstHelloMissionCallablePayload",
    source:
      "callables/complete_event_success_first_hello_mission_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "completeEventSuccessFirstHelloMissionCallablePayload.ts",
  },
  {
    name: "MarkEventAttendanceCallableResponse",
    source: "callable_responses/mark_event_attendance_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/markEventAttendanceCallableResponse.ts",
  },
  {
    name: "SelfCheckInAttendanceCallablePayload",
    source: "callables/self_check_in_attendance_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/selfCheckInAttendanceCallablePayload.ts",
  },
  {
    name: "CreateEventReviewCallablePayload",
    source: "callables/create_event_review_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/createEventReviewCallablePayload.ts",
  },
  {
    name: "UpdateEventReviewCallablePayload",
    source: "callables/update_event_review_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/updateEventReviewCallablePayload.ts",
  },
  {
    name: "DeleteEventReviewCallablePayload",
    source: "callables/delete_event_review_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/deleteEventReviewCallablePayload.ts",
  },
  {
    name: "BlockUserCallablePayload",
    source: "callables/block_user_payload.schema.json",
    typeOutput: "functions/src/shared/generated/blockUserCallablePayload.ts",
  },
  {
    name: "UnblockUserCallablePayload",
    source: "callables/unblock_user_payload.schema.json",
    typeOutput: "functions/src/shared/generated/unblockUserCallablePayload.ts",
  },
  {
    name: "ReportUserCallablePayload",
    source: "callables/report_user_payload.schema.json",
    typeOutput: "functions/src/shared/generated/reportUserCallablePayload.ts",
  },
  {
    name: "RequestSuvbotDemoOperationCallablePayload",
    source: "callables/request_suvbot_demo_operation_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "requestSuvbotDemoOperationCallablePayload.ts",
  },
  {
    name: "ListSuvbotDemoActionsCallableResponse",
    source: "callable_responses/list_suvbot_demo_actions_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/listSuvbotDemoActionsCallableResponse.ts",
  },
  {
    name: "VerifyRazorpayPaymentCallablePayload",
    source: "callables/verify_razorpay_payment_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/verifyRazorpayPaymentCallablePayload.ts",
  },
  {
    name: "EventBookingCallablePayload",
    source: "callables/event_booking_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventBookingCallablePayload.ts",
  },
  {
    name: "CreateRazorpayOrderCallablePayload",
    source: "callables/create_razorpay_order_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/createRazorpayOrderCallablePayload.ts",
  },
  {
    name: "RazorpayOrderCallableResponse",
    source: "callable_responses/razorpay_order_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/razorpayOrderCallableResponse.ts",
  },
  {
    name: "PlacesAutocompleteCallablePayload",
    source: "callables/places_autocomplete_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/placesAutocompleteCallablePayload.ts",
  },
  {
    name: "PlacesAutocompleteCallableResponse",
    source: "callable_responses/places_autocomplete_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/placesAutocompleteCallableResponse.ts",
  },
  {
    name: "PlaceDetailsCallablePayload",
    source: "callables/place_details_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/placeDetailsCallablePayload.ts",
  },
  {
    name: "PlaceDetailsCallableResponse",
    source: "callable_responses/place_details_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/placeDetailsCallableResponse.ts",
  },
  {
    name: "FetchEventSuccessWingmanCandidatesCallableResponse",
    source:
      "callable_responses/fetch_event_success_wingman_candidates_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "fetchEventSuccessWingmanCandidatesCallableResponse.ts",
  },
  {
    name: "CreateProfileDecisionClientWrite",
    source: "client_writes/create_profile_decision.schema.json",
    typeOutput:
      "functions/src/shared/generated/createProfileDecisionClientWrite.ts",
  },
  {
    name: "CreateChatMessageClientWrite",
    source: "client_writes/create_chat_message.schema.json",
    typeOutput:
      "functions/src/shared/generated/createChatMessageClientWrite.ts",
  },
  {
    name: "CreateSavedEventClientWrite",
    source: "client_writes/create_saved_event.schema.json",
    typeOutput:
      "functions/src/shared/generated/createSavedEventClientWrite.ts",
  },
  {
    name: "DeleteSavedEventClientWrite",
    source: "client_writes/delete_saved_event.schema.json",
    typeOutput:
      "functions/src/shared/generated/deleteSavedEventClientWrite.ts",
  },
  {
    name: "MarkNotificationReadClientWrite",
    source: "client_writes/mark_notification_read.schema.json",
    typeOutput:
      "functions/src/shared/generated/markNotificationReadClientWrite.ts",
  },
  {
    name: "ResetMatchUnreadCountClientWrite",
    source: "client_writes/reset_match_unread_count.schema.json",
    typeOutput:
      "functions/src/shared/generated/resetMatchUnreadCountClientWrite.ts",
  },
];

const FIRESTORE_ADMIN_EMBEDDED_SPECS = [
  {
    name: "Gender",
    source: "shared/profile_common.schema.json",
    pointer: "/definitions/gender",
  },
  {
    name: "PaymentStatus",
    source: "firestore/payments.schema.json",
    pointer: "/properties/status",
  },
  {
    name: "ProfilePromptAnswer",
    source: "embedded/profile_prompt_answer.schema.json",
  },
  {
    name: "PhotoPromptAnswer",
    source: "embedded/photo_prompt_answer.schema.json",
  },
  {
    name: "ProfilePhoto",
    source: "embedded/profile_photo.schema.json",
  },
  {
    name: "ActivityPreferences",
    source: "embedded/activity_preferences.schema.json",
  },
  {
    name: "EventMeetingLocation",
    source: "shared/event_common.schema.json",
    pointer: "/definitions/eventMeetingLocation",
  },
  {
    name: "EventFormatSnapshot",
    source: "shared/event_common.schema.json",
    pointer: "/definitions/eventFormatSnapshot",
  },
  {
    name: "EventSuccessFormatPrimitives",
    source: "shared/event_common.schema.json",
    pointer: "/definitions/eventSuccessFormatPrimitives",
  },
  {
    name: "EventSuccessStructureConfig",
    source: "shared/event_common.schema.json",
    pointer: "/definitions/eventSuccessStructureConfig",
  },
  {
    name: "EventSuccessQuestionnaireConfig",
    source: "shared/event_common.schema.json",
    pointer: "/definitions/eventSuccessQuestionnaireConfig",
  },
  {
    name: "EventSuccessDefaults",
    source: "shared/event_common.schema.json",
    pointer: "/definitions/eventSuccessDefaults",
  },
  {
    name: "EventPolicyDefaults",
    source: "shared/event_common.schema.json",
    pointer: "/definitions/eventPolicyDefaults",
  },
  {
    name: "ClubHostDefaults",
    source: "shared/event_common.schema.json",
    pointer: "/definitions/clubHostDefaults",
  },
  {
    name: "ClubHostProfile",
    source: "shared/event_common.schema.json",
    pointer: "/definitions/clubHostProfile",
  },
  {
    name: "EventConstraints",
    source: "shared/event_common.schema.json",
    pointer: "/definitions/eventConstraints",
  },
  {
    name: "EventPolicyBundleDocument",
    source: "shared/event_common.schema.json",
    pointer: "/definitions/eventPolicyBundle",
  },
  {
    name: "EventPolicyAdmissionDocument",
    source: "shared/event_common.schema.json",
    pointer: "/definitions/eventPolicyBundle/properties/admission",
  },
  {
    name: "EventPolicyPrivateAccessDocument",
    source: "shared/event_common.schema.json",
    pointer:
      "/definitions/eventPolicyBundle/properties/admission/" +
      "properties/privateAccessPolicy",
  },
  {
    name: "EventPolicyWaitlistDocument",
    source: "shared/event_common.schema.json",
    pointer:
      "/definitions/eventPolicyBundle/properties/admission/" +
      "properties/waitlistPolicy",
  },
  {
    name: "EventPolicyBalancedRatioDocument",
    source: "shared/event_common.schema.json",
    pointer:
      "/definitions/eventPolicyBundle/properties/admission/" +
      "properties/balancedRatioPolicy",
  },
  {
    name: "EventPolicyPricingDocument",
    source: "shared/event_common.schema.json",
    pointer: "/definitions/eventPolicyBundle/properties/pricing",
  },
  {
    name: "EventPolicyDemandPricingRuleDocument",
    source: "shared/event_common.schema.json",
    pointer:
      "/definitions/eventPolicyBundle/properties/pricing/" +
      "properties/demandPricingRules/items",
  },
];

const FIRESTORE_ADMIN_FIELD_OVERRIDES = new Map([
  ["ClubDocument.hostProfiles", "ClubHostProfile[]"],
  ["ClubDocument.hostDefaults", "ClubHostDefaults"],
  ["EventDocument.meetingLocation", "EventMeetingLocation | null"],
  ["EventDocument.eventFormat", "EventFormatSnapshot"],
  ["EventDocument.constraints", "EventConstraints"],
  ["EventDocument.eventPolicy", "EventPolicyBundleDocument | null"],
  ["EventFormatSnapshot.version", "number"],
  [
    "EventFormatSnapshot.eventSuccessPrimitives",
    "EventSuccessFormatPrimitives",
  ],
  ["EventSuccessDefaults.structureConfig", "EventSuccessStructureConfig"],
  [
    "EventSuccessDefaults.questionnaireConfig",
    "EventSuccessQuestionnaireConfig",
  ],
  ["ClubHostDefaults.eventPolicy", "EventPolicyDefaults"],
  ["ClubHostDefaults.eventSuccess", "EventSuccessDefaults"],
  [
    "ClubHostDefaults.eventSuccessByActivityKind",
    "Record<string, EventSuccessDefaults>",
  ],
  ["EventPolicyBundleDocument.version", "number"],
  ["EventPolicyBundleDocument.admission", "EventPolicyAdmissionDocument"],
  ["EventPolicyBundleDocument.pricing", "EventPolicyPricingDocument"],
  ["EventPolicyAdmissionDocument.waitlistPolicy", "EventPolicyWaitlistDocument"],
  [
    "EventPolicyAdmissionDocument.privateAccessPolicy",
    "EventPolicyPrivateAccessDocument",
  ],
  [
    "EventPolicyAdmissionDocument.balancedRatioPolicy",
    "EventPolicyBalancedRatioDocument | null",
  ],
  ["EventPolicyPricingDocument.demandPricingRules", "EventPolicyDemandPricingRuleDocument[]"],
]);

const FIRESTORE_ADMIN_OPTIONAL_FIELDS = new Map([
  ["EventConstraints", ["maxMen", "maxWomen"]],
  [
    "EventDocument",
    [
      "startingPointLat",
      "startingPointLng",
      "locationDetails",
      "bookedCount",
      "checkedInCount",
      "waitlistedCount",
      "cancelledAt",
      "cancellationReason",
    ],
  ],
  [
    "MatchDocument",
    [
      "lastMessageAt",
      "lastMessagePreview",
      "lastMessageSenderId",
      "blockedBy",
      "blockedAt",
    ],
  ],
  [
    "EventPolicyAdmissionDocument",
    [
      "waitlistPolicy",
      "inviteRequired",
      "membershipRequired",
      "manualApprovalRequired",
      "privateAccessPolicy",
      "cohortCapacityLimits",
      "balancedRatioPolicy",
    ],
  ],
  [
    "EventPolicyPricingDocument",
    [
      "cohortAdjustmentsInPaise",
      "demandPricingRules",
    ],
  ],
]);

const generatedFiles = [];

async function main() {
  const profileCatalog = readContractJson("catalogs/profile_prompts.json");
  const profilePhotoPolicy = readContractJson(
    "catalogs/profile_photo_policy.json"
  );
  const photoCatalog = withProfilePhotoPolicy(
    readContractJson("catalogs/photo_prompts.json"),
    profilePhotoPolicy
  );
  const profileDecisionMigration = readContractJson(
    "migrations/swipes_to_profile_decisions.json"
  );
  const bundledSchemas = new Map();

  for (const spec of schemaSpecs) {
    const file = path.join(contractRoot, spec.source);
    const schema = applyProfilePhotoPolicy(
      bundleSchema(file),
      profilePhotoPolicy
    );
    bundledSchemas.set(spec.name, schema);
    await addTypeOutput(spec, schema);
  }

  addTextOutput(
    "functions/src/shared/generated/schemaRegistry.ts",
    renderTsSchemaRegistry({
      schemaMap: bundledSchemas,
      profileCatalog,
      photoCatalog,
      profilePhotoPolicy,
    })
  );
  addTextOutput(
    "functions/src/shared/generated/schemaValidators.ts",
    renderTsValidators()
  );
  addTextOutput(
    "functions/src/shared/generated/firestoreAdminTypes.ts",
    await renderTsFirestoreAdminTypes({
      schemaSpecs,
      profilePhotoPolicy,
    })
  );
  addTextOutput(
    "functions/src/shared/generated/schemaPaths.ts",
    renderTsPathConstants({
      profileDecisionSchema: bundledSchemas.get("SwipeDocument"),
      profileDecisionMigration,
    })
  );
  addTextOutput(
    "tool/contracts/generated/schema_contract_registry.mjs",
    renderToolSchemaRegistry({
      schemaMap: bundledSchemas,
      profileCatalog,
      photoCatalog,
      profilePhotoPolicy,
    })
  );
  addTextOutput(
    "tool/contracts/generated/schema_contract_validators.mjs",
    renderToolValidators()
  );
  addTextOutput(
    "lib/core/schema_contracts/generated/profile_schema_contracts.g.dart",
    renderDartContracts({
      profileCatalog,
      photoCatalog,
      profilePhotoPolicy,
      profilePromptSchema: bundledSchemas.get("ProfilePromptAnswer"),
      photoPromptSchema: bundledSchemas.get("PhotoPromptAnswer"),
      profilePhotoSchema: bundledSchemas.get("ProfilePhoto"),
      updateUserProfileSchema: bundledSchemas.get(
        "UpdateUserProfileCallablePayload"
      ),
      profileDecisionSchema: bundledSchemas.get("SwipeDocument"),
      profileDecisionMigration,
      commonSchema: readContractJson("shared/profile_common.schema.json"),
    })
  );
  const dartSchemaContracts = renderDartSchemaContracts({
    schemaMap: bundledSchemas,
  });
  addTextOutput(
    "lib/core/schema_contracts/generated/schema_contracts.g.dart",
    dartSchemaContracts.text
  );
  for (const file of dartSchemaContracts.files) {
    addTextOutput(file.path, file.content);
  }

  const dartCallableRequests = renderDartCallableRequestClasses({
    schemaSpecs,
    schemaMap: bundledSchemas,
    commonSchema: readContractJson("shared/profile_common.schema.json"),
  });
  addTextOutput(
    "lib/core/schema_contracts/generated/callable_request_dtos.g.dart",
    dartCallableRequests.text
  );
  for (const file of dartCallableRequests.files) {
    addTextOutput(file.path, file.content);
  }
  addTextOutput(
    "lib/core/schema_contracts/generated/INDEX.md",
    renderGeneratedIndex({dartSchemaContracts, dartCallableRequests})
  );
  if (!checkOnly && dartCallableRequests.ungenerable.length > 0) {
    console.log(
      `[callable_request_dtos.g.dart] ${dartCallableRequests.ungenerable.length} ` +
      `schemas not yet generatable (hand-written callable helpers still own them):`
    );
    for (const entry of dartCallableRequests.ungenerable) {
      console.log(`  - ${entry.name}: ${entry.reason}`);
    }
  }

  const staleFiles = [];
  if (!checkOnly) {
    fs.rmSync(
      path.join(repoRoot, "lib/core/schema_contracts/generated/callables"),
      {recursive: true, force: true}
    );
    fs.rmSync(
      path.join(repoRoot, "lib/core/schema_contracts/generated/schemas"),
      {recursive: true, force: true}
    );
  }
  for (const file of generatedFiles) {
    const absolutePath = path.join(repoRoot, file.path);
    if (checkOnly) {
      const current = fs.existsSync(absolutePath) ?
        fs.readFileSync(absolutePath, "utf8") :
        null;
      if (current !== file.content) staleFiles.push(file.path);
    } else {
      fs.mkdirSync(path.dirname(absolutePath), {recursive: true});
      fs.writeFileSync(absolutePath, file.content);
    }
  }

  if (staleFiles.length > 0) {
    console.error("Generated schema contract outputs are stale:");
    for (const file of staleFiles) console.error(`- ${file}`);
    console.error("Run: node tool/contracts/generate_schema_contracts.mjs");
    process.exitCode = 1;
    return;
  }

  console.log(
    checkOnly ?
      "Generated schema contract outputs are current." :
      `Generated ${generatedFiles.length} schema contract files.`
  );
}

function withProfilePhotoPolicy(photoCatalog, profilePhotoPolicy) {
  return {
    ...photoCatalog,
    limits: {
      ...photoCatalog.limits,
      maxCaptions: profilePhotoPolicy.maxPhotos,
    },
  };
}

function applyProfilePhotoPolicy(schema, profilePhotoPolicy) {
  const cloned = structuredClone(schema);
  applyDerivedProfilePhotoPolicyValues(cloned, profilePhotoPolicy);
  return cloned;
}

function applyDerivedProfilePhotoPolicyValues(value, profilePhotoPolicy) {
  if (Array.isArray(value)) {
    for (const item of value) {
      applyDerivedProfilePhotoPolicyValues(item, profilePhotoPolicy);
    }
    return;
  }
  if (!value || typeof value !== "object") return;
  if (
    value["x-catch-maximumFrom"] ===
    "profilePhotoPolicy.maxPhotosMinusOne"
  ) {
    value.maximum = profilePhotoPolicy.maxPhotos - 1;
    delete value["x-catch-maximumFrom"];
  }
  for (const child of Object.values(value)) {
    applyDerivedProfilePhotoPolicyValues(child, profilePhotoPolicy);
  }
}

async function addTypeOutput(spec, schema) {
  let types = await compileTs(schema, spec.name);
  types = normalizeExternalTypeReferences(spec.name, types);
  const imports = tsTypeImports(spec.name, types);
  addTextOutput(
    spec.typeOutput,
    `${tsGeneratedHeader()}${imports}${types.trim()}\n`
  );
}

function compileTs(schema, name) {
  return compile(schema, name, {
    bannerComment: "",
    cwd: repoRoot,
    declareExternallyReferenced: false,
    enableConstEnums: false,
    format: true,
    ignoreMinAndMaxItems: true,
    style: {
      bracketSpacing: false,
      printWidth: 80,
      semi: true,
      singleQuote: false,
      tabWidth: 2,
      trailingComma: "es5",
      useTabs: false,
    },
  });
}

async function renderTsFirestoreAdminTypes({schemaSpecs, profilePhotoPolicy}) {
  const firestoreSpecs = schemaSpecs
    .filter((spec) => spec.source.startsWith("firestore/"));
  const allAdminTypeNames = [
    ...FIRESTORE_ADMIN_EMBEDDED_SPECS.map((spec) => spec.name),
    ...firestoreSpecs.map((spec) => firestoreAdminTypeName(spec.name)),
  ];
  const sections = [];

  for (const spec of FIRESTORE_ADMIN_EMBEDDED_SPECS) {
    const schema = firestoreAdminNamedSchema(spec, profilePhotoPolicy);
    applyFirestoreAdminFieldOverrides(schema, spec.name);
    applyFirestoreAdminOptionalFields(schema, spec.name);
    sections.push(await compileFirestoreAdminType(
      schema,
      spec.name,
      allAdminTypeNames
    ));
  }

  for (const spec of firestoreSpecs) {
    const file = path.join(contractRoot, spec.source);
    const schema = applyProfilePhotoPolicy(
      bundleSchema(file),
      profilePhotoPolicy
    );
    stripInternalDemoFields(schema);
    stripTopLevelStructuralValidation(schema);
    const adminName = firestoreAdminTypeName(spec.name);
    schema.title = adminName;
    applyFirestoreAdminFieldOverrides(schema, adminName);
    applyFirestoreAdminOptionalFields(schema, adminName);
    sections.push(await compileFirestoreAdminType(
      withAdminTimestamps(schema),
      adminName,
      allAdminTypeNames
    ));
  }

  return `${tsGeneratedHeader()}` +
`/**
 * Schema-derived Admin SDK Firestore document types.
 *
 * The sibling generated document files model serialized JSON fixture
 * timestamps as {_seconds, _nanoseconds}. These types keep the same
 * schema-owned fields, but project Firestore timestamp values as live
 * FirebaseFirestore.Timestamp instances for Cloud Functions code that reads
 * and writes through the Admin SDK.
 */

// FirebaseFirestore.Timestamp is available globally through firebase-admin's
// @google-cloud/firestore dependency.

${sections.join("\n\n")}\n`;
}

async function compileFirestoreAdminType(schema, name, allAdminTypeNames) {
  let types = await compileTs(schema, name);
  types = normalizeTypeReferences(name, types, allAdminTypeNames);
  return types.trim();
}

function firestoreAdminNamedSchema(spec, profilePhotoPolicy) {
  const file = path.join(contractRoot, spec.source);
  const bundled = applyProfilePhotoPolicy(bundleSchema(file), profilePhotoPolicy);
  const source = spec.pointer ?
    resolveJsonPointer(bundled, spec.pointer) :
    bundled;
  return withAdminTimestamps({
    ...structuredClone(source),
    title: spec.name,
  });
}

function firestoreAdminTypeName(schemaName) {
  return schemaName;
}

function withAdminTimestamps(schema) {
  const cloned = structuredClone(schema);
  replaceSerializedTimestampSchemas(cloned);
  return cloned;
}

function replaceSerializedTimestampSchemas(value) {
  if (Array.isArray(value)) {
    for (let i = 0; i < value.length; i++) {
      const item = value[i];
      if (isSerializedTimestampSchema(item)) {
        value[i] = {tsType: "FirebaseFirestore.Timestamp"};
      } else {
        replaceSerializedTimestampSchemas(item);
      }
    }
    return;
  }
  if (!value || typeof value !== "object") return;
  if (isSerializedTimestampSchema(value)) {
    for (const key of Object.keys(value)) delete value[key];
    value.tsType = "FirebaseFirestore.Timestamp";
    return;
  }
  for (const child of Object.values(value)) {
    replaceSerializedTimestampSchemas(child);
  }
}

function isSerializedTimestampSchema(value) {
  if (!value || typeof value !== "object" || value.type !== "object") {
    return false;
  }
  const properties = value.properties;
  if (!properties || typeof properties !== "object") return false;
  return Boolean(
    properties._seconds?.type === "integer" &&
    properties._nanoseconds?.type === "integer"
  );
}

function stripInternalDemoFields(schema) {
  const fields = schema["x-internal-demo-fields"];
  if (!Array.isArray(fields) || !schema.properties) return;
  for (const field of fields) {
    delete schema.properties[field];
  }
  if (Array.isArray(schema.required)) {
    schema.required = schema.required.filter((field) => !fields.includes(field));
  }
}

function stripTopLevelStructuralValidation(schema) {
  delete schema.anyOf;
  delete schema.oneOf;
  delete schema.allOf;
}

function applyFirestoreAdminFieldOverrides(schema, typeName) {
  if (!schema.properties) return;
  for (const [key, tsType] of FIRESTORE_ADMIN_FIELD_OVERRIDES) {
    const [targetTypeName, fieldName] = key.split(".");
    if (targetTypeName !== typeName || !schema.properties[fieldName]) {
      continue;
    }
    schema.properties[fieldName] = {tsType};
  }
}

function applyFirestoreAdminOptionalFields(schema, typeName) {
  const fields = FIRESTORE_ADMIN_OPTIONAL_FIELDS.get(typeName);
  if (!fields || !Array.isArray(schema.required)) return;
  schema.required = schema.required.filter((field) => !fields.includes(field));
}

function normalizeTypeReferences(currentTypeName, source, typeNames) {
  let normalized = source;
  for (const name of typeNames) {
    if (currentTypeName === name) continue;
    normalized = normalized.replace(
      new RegExp(`\\b${name}\\d+\\b`, "g"),
      name
    );
  }
  return normalized;
}

function normalizeExternalTypeReferences(currentTypeName, source) {
  return normalizeTypeReferences(
    currentTypeName,
    source,
    schemaSpecs.map((spec) => spec.name)
  );
}

function tsTypeImports(currentTypeName, source) {
  const imports = [];
  const typeSource = source
    .replace(/\/\*[\s\S]*?\*\//g, "")
    .replace(/\/\/.*$/gm, "");
  for (const spec of schemaSpecs) {
    if (currentTypeName === spec.name) continue;
    const pattern = new RegExp(`\\b${spec.name}\\b`);
    if (!pattern.test(typeSource)) continue;
    imports.push(`import {${spec.name}} from "${typeImportPath(spec)}";`);
  }
  return imports.length === 0 ? "" : `${imports.join("\n")}\n\n`;
}

function addTextOutput(relativePath, content) {
  generatedFiles.push({path: relativePath, content});
}

function schemaRegistryEntries(schemaMap) {
  return schemaSpecs.map((spec) => [
    schemaConstName(spec),
    schemaMap.get(spec.name),
  ]);
}

function schemaConstName(spec) {
  return `${spec.name.charAt(0).toLowerCase()}${spec.name.slice(1)}Schema`;
}

function validatorName(spec) {
  return `validate${spec.name}`;
}

function typeImportPath(spec) {
  return `./${path.basename(spec.typeOutput, ".ts")}`;
}

function renderTsSchemaRegistry({
  schemaMap,
  profileCatalog,
  photoCatalog,
  profilePhotoPolicy,
}) {
  const entries = schemaRegistryEntries(schemaMap);
  const catalogEntries = [
    ["profilePromptCatalog", profileCatalog],
    ["photoPromptCatalog", photoCatalog],
    ["profilePromptLimits", profileCatalog.limits],
    ["photoPromptLimits", photoCatalog.limits],
    ["profilePhotoPolicy", profilePhotoPolicy],
    ["defaultProfilePromptIds", profileCatalog.defaultPromptIds],
  ];
  return `${tsGeneratedHeader()}${entries.map(([name, schema]) =>
    `export const ${name}: Record<string, unknown> = ${jsonForTs(schema)};\n`
  ).join("\n")}\n${catalogEntries.map(([name, value]) =>
    `export const ${name} = ${jsonForTs(value)};\n`
  ).join("\n")}`;
}

function renderTsValidators() {
  const typeImports = schemaSpecs.map((spec) =>
    `import {${spec.name}} from "${typeImportPath(spec)}";`
  ).join("\n");
  const schemaImports = schemaSpecs.map((spec) =>
    `  ${schemaConstName(spec)},`
  ).join("\n");
  const validators = schemaSpecs.map((spec) => `export const ${validatorName(spec)}:
  ValidateFunction<${spec.name}> =
    ajv.compile(${schemaConstName(spec)}) as
      ValidateFunction<${spec.name}>;`).join("\n");

  return `${tsGeneratedHeader()}import Ajv, {ValidateFunction} from "ajv";
import addFormats from "ajv-formats";
${typeImports}
import {
${schemaImports}
} from "./schemaRegistry";

const ajv = new Ajv({allErrors: true, strict: false});
addFormats(ajv);

${validators}

export function schemaErrorMessages(
  validator: ValidateFunction<unknown>
): string[] {
  return (validator.errors ?? []).map((error) => {
    const location = error.instancePath || "/";
    return \`\${location} \${error.message ?? "failed validation"}\`;
  });
}
`;
}

function renderTsPathConstants({
  profileDecisionSchema,
  profileDecisionMigration,
}) {
  const pathParts = profileDecisionPathParts(profileDecisionSchema);
  const futurePathParts = profileDecisionPathParts(
    profileDecisionMigration?.candidatePrimaryStoragePath
  );
  return `${tsGeneratedHeader()}export const schemaProfileDecisionLogicalName =
  ${JSON.stringify(profileDecisionSchema["x-logical-name"] ?? "profileDecision")};
export const schemaProfileDecisionPathTemplate =
  ${JSON.stringify(pathParts.pathTemplate)};
export const schemaProfileDecisionTriggerPath =
  ${JSON.stringify(pathParts.triggerPath)};
export const schemaProfileDecisionCollectionPath =
  ${JSON.stringify(pathParts.collectionPath)};
export const schemaProfileDecisionOutgoingSubcollectionPath =
  ${JSON.stringify(pathParts.outgoingSubcollectionPath)};
export const schemaProfileDecisionFuturePathTemplate =
  ${JSON.stringify(futurePathParts.pathTemplate)};
export const schemaProfileDecisionFutureCollectionPath =
  ${JSON.stringify(futurePathParts.collectionPath)};
export const schemaProfileDecisionFutureOutgoingSubcollectionPath =
  ${JSON.stringify(futurePathParts.outgoingSubcollectionPath)};
`;
}

function renderToolSchemaRegistry({
  schemaMap,
  profileCatalog,
  photoCatalog,
  profilePhotoPolicy,
}) {
  const entries = schemaRegistryEntries(schemaMap);
  const catalogEntries = [
    ["profilePromptCatalog", profileCatalog],
    ["photoPromptCatalog", photoCatalog],
    ["profilePromptLimits", profileCatalog.limits],
    ["photoPromptLimits", photoCatalog.limits],
    ["profilePhotoPolicy", profilePhotoPolicy],
    ["defaultProfilePromptIds", profileCatalog.defaultPromptIds],
  ];
  return `${mjsGeneratedHeader()}${entries.map(([name, schema]) =>
    `export const ${name} = ${jsonForJs(schema)};\n`
  ).join("\n")}\n${catalogEntries.map(([name, value]) =>
    `export const ${name} = ${jsonForJs(value)};\n`
  ).join("\n")}`;
}

function renderToolValidators() {
  const schemaImports = schemaSpecs.map((spec) =>
    `  ${schemaConstName(spec)},`
  ).join("\n");
  const validators = schemaSpecs.map((spec) =>
    `export const ${validatorName(spec)} = ajv.compile(${schemaConstName(spec)});`
  ).join("\n");

  return `${mjsGeneratedHeader()}import {createRequire} from "node:module";
import {
${schemaImports}
} from "./schema_contract_registry.mjs";

const requireFromFunctions = createRequire(
  new URL("../../../functions/package.json", import.meta.url)
);
const Ajv = requireFromFunctions("ajv");
const addFormats = requireFromFunctions("ajv-formats");

const ajv = new Ajv({allErrors: true, strict: false});
addFormats(ajv);

${validators}

export function schemaErrorMessages(validator) {
  return (validator.errors ?? []).map((error) => {
    const location = error.instancePath || "/";
    return \`\${location} \${error.message ?? "failed validation"}\`;
  });
}

export function assertValidSchemaPayload(validator, payload, label) {
  if (validator(payload)) return;
  const details = schemaErrorMessages(validator).join("; ");
  throw new Error(\`\${label} failed schema validation: \${details}\`);
}
`;
}

function renderDartContracts({
  profileCatalog,
  photoCatalog,
  profilePhotoPolicy,
  profilePromptSchema,
  photoPromptSchema,
  profilePhotoSchema,
  updateUserProfileSchema,
  profileDecisionSchema,
  profileDecisionMigration,
  commonSchema,
}) {
  const profileLimits = profileCatalog.limits;
  const photoLimits = photoCatalog.limits;
  const height = commonSchema.definitions.heightCm;
  const profileDecisionPath = profileDecisionPathParts(profileDecisionSchema);
  const profileDecisionFuturePath = profileDecisionPathParts(
    profileDecisionMigration?.candidatePrimaryStoragePath
  );
  const preferredAge = updateUserProfileSchema.properties.fields.properties
    .minAgePreference;
  const profilePrompts = profileCatalog.prompts.map((prompt) =>
    `  SchemaProfilePromptDefinition(` +
    `id: ${dartString(prompt.id)}, ` +
    `title: ${dartString(prompt.title)}, ` +
    `placeholder: ${dartString(prompt.placeholder)},` +
    `),`
  ).join("\n");
  const photoPrompts = photoCatalog.prompts.map((prompt) =>
    `  SchemaPhotoPromptDefinition(` +
    `id: ${dartString(prompt.id)}, ` +
    `title: ${dartString(prompt.title)}, ` +
    `placeholder: ${dartString(prompt.placeholder)},` +
    `),`
  ).join("\n");
  const defaultPromptIds = profileCatalog.defaultPromptIds
    .map((id) => `  ${dartString(id)},`)
    .join("\n");

  return `${dartGeneratedHeader()}
class SchemaProfilePromptDefinition {
  const SchemaProfilePromptDefinition({
    required this.id,
    required this.title,
    required this.placeholder,
  });

  final String id;
  final String title;
  final String placeholder;
}

class SchemaPhotoPromptDefinition {
  const SchemaPhotoPromptDefinition({
    required this.id,
    required this.title,
    required this.placeholder,
  });

  final String id;
  final String title;
  final String placeholder;
}

const schemaProfilePromptPerfectEventId = ${dartString(
  profileCatalog.defaultPromptIds[0]
)};
const schemaMaxProfilePromptAnswers = ${profileLimits.maxAnswers};
const schemaMaxPhotoPromptCaptions = ${photoLimits.maxCaptions};
const schemaMinimumProfilePhotos = ${profilePhotoPolicy.minPhotos};
const schemaMaximumProfilePhotos = ${profilePhotoPolicy.maxPhotos};
const schemaProfilePhotoAspectRatioWidth =
    ${profilePhotoPolicy.displayAspectRatio.width};
const schemaProfilePhotoAspectRatioHeight =
    ${profilePhotoPolicy.displayAspectRatio.height};
const schemaProfilePhotoThumbnailSize = ${profilePhotoPolicy.thumbnailSize};
const schemaProfilePhotoMaxUploadBytes = ${profilePhotoPolicy.maxUploadBytes};
const schemaMaximumProfilePromptAnswerLength =
    ${profileLimits.maxAnswerLength};
const schemaMaximumPhotoPromptCaptionLength = ${photoLimits.maxCaptionLength};
const schemaMinimumProfileAge = ${preferredAge.minimum};
const schemaMaximumPreferredMatchAge = ${preferredAge.maximum};
const schemaMinimumHeightCm = ${height.minimum};
const schemaMaximumHeightCm = ${height.maximum};
const schemaProfileDecisionLogicalName =
    ${dartString(profileDecisionSchema["x-logical-name"] ?? "profileDecision")};
const schemaProfileDecisionPathTemplate =
    ${dartString(profileDecisionPath.pathTemplate)};
const schemaProfileDecisionCollectionPath =
    ${dartString(profileDecisionPath.collectionPath)};
const schemaProfileDecisionOutgoingSubcollectionPath =
    ${dartString(profileDecisionPath.outgoingSubcollectionPath)};
const schemaProfileDecisionFuturePathTemplate =
    ${dartString(profileDecisionFuturePath.pathTemplate)};
const schemaProfileDecisionFutureCollectionPath =
    ${dartString(profileDecisionFuturePath.collectionPath)};
const schemaProfileDecisionFutureOutgoingSubcollectionPath =
    ${dartString(profileDecisionFuturePath.outgoingSubcollectionPath)};

const schemaDefaultProfilePromptIds = <String>[
${defaultPromptIds}
];

const schemaProfilePromptCatalog = <SchemaProfilePromptDefinition>[
${profilePrompts}
];

const schemaPhotoPromptCatalog = <SchemaPhotoPromptDefinition>[
${photoPrompts}
];

const schemaProfilePromptAnswerSchema = ${dartLiteral(profilePromptSchema)};

const schemaPhotoPromptAnswerSchema = ${dartLiteral(photoPromptSchema)};

const schemaProfilePhotoSchema = ${dartLiteral(profilePhotoSchema)};

const schemaUpdateUserProfileCallablePayloadSchema =
    ${dartLiteral(updateUserProfileSchema)};
`;
}

const DART_SCHEMA_OUTPUT_DIR = "lib/core/schema_contracts/generated/schemas";

function renderDartSchemaContracts({schemaMap}) {
  const files = [];
  const generatedConstants = [];
  const schemaExports = [];

  for (const spec of schemaSpecs) {
    const constName = dartSchemaConstName(spec.name);
    const output = dartSchemaOutputPath(spec.name);
    generatedConstants.push({
      constName,
      schemaName: spec.name,
      source: spec.source,
      output,
    });
    schemaExports.push(dartSchemaGeneratedExportPath(output));
    files.push({
      path: output,
      content: renderDartSchemaConstantFile({
        constName,
        source: spec.source,
        schema: schemaMap.get(spec.name),
      }),
    });
  }

  const definitions = schemaSpecs.map((spec) => {
    const schemaName = dartSchemaConstName(spec.name);
    return `  SchemaContractDefinition(
    name: ${dartString(spec.name)},
    source: ${dartString(spec.source)},
    schema: ${schemaName},
  ),`;
  }).join("\n");
  const byName = schemaSpecs.map((spec) =>
    `  ${dartString(spec.name)}: ${dartSchemaConstName(spec.name)},`
  ).join("\n");
  const bySource = schemaSpecs.map((spec) =>
    `  ${dartString(spec.source)}: ${dartSchemaConstName(spec.name)},`
  ).join("\n");

  files.push({
    path: `${DART_SCHEMA_OUTPUT_DIR}/schema_constants.g.dart`,
    content: `${dartGeneratedHeader()}
// Barrel for generated Dart JSON Schema constants.

${[...new Set(schemaExports)]
    .sort()
    .map((item) => `export '${item}';`)
    .join("\n")}
`,
  });

  files.push({
    path: `${DART_SCHEMA_OUTPUT_DIR}/schema_registry.g.dart`,
    content: `${dartGeneratedHeader()}import 'schema_constants.g.dart';

class SchemaContractDefinition {
  const SchemaContractDefinition({
    required this.name,
    required this.source,
    required this.schema,
  });

  final String name;
  final String source;
  final Map<String, Object?> schema;
}

const schemaContractDefinitions = <SchemaContractDefinition>[
${definitions}
];

const schemaContractsByName = <String, Map<String, Object?>>{
${byName}
};

const schemaContractsBySource = <String, Map<String, Object?>>{
${bySource}
};
`,
  });

  return {
    text: `${dartGeneratedHeader()}
// Stable barrel for generated Dart JSON Schema contracts.

export 'schemas/schema_constants.g.dart';
export 'schemas/schema_registry.g.dart';
`,
    files,
    generatedConstants,
  };
}

function dartSchemaOutputPath(name) {
  return `${DART_SCHEMA_OUTPUT_DIR}/${snakeCase(name)}.g.dart`;
}

function dartSchemaGeneratedExportPath(outputPath) {
  return outputPath.replace(`${DART_SCHEMA_OUTPUT_DIR}/`, "");
}

function renderDartSchemaConstantFile({constName, source, schema}) {
  return `${dartGeneratedHeader()}
// JSON Schema constant emitted from ${source}.

const ${constName} = ${dartLiteral(schema)};
`;
}

function renderGeneratedIndex({dartSchemaContracts, dartCallableRequests}) {
  const tsRows = schemaSpecs.map((spec) =>
    `| ${spec.name} | \`${spec.source}\` | \`${spec.typeOutput}\` |`
  ).join("\n");
  const dartSchemaRows = dartSchemaContracts.generatedConstants.map((entry) =>
    `| \`${entry.constName}\` | ${entry.schemaName} | ` +
    `\`${entry.source}\` | \`${entry.output}\` |`
  ).join("\n");
  const callableRows = dartCallableRequests.generatedClasses.length === 0 ?
    "| _None_ | _None_ | _None_ | _None_ |" :
    dartCallableRequests.generatedClasses.map((entry) =>
      `| ${entry.className} | ${entry.schemaName} | ` +
      `\`${entry.source}\` | \`${entry.output}\` |`
    ).join("\n");
  const ungenerableRows = dartCallableRequests.ungenerable.length === 0 ?
    "| _None_ | _None_ |" :
    dartCallableRequests.ungenerable.map((entry) =>
      `| ${entry.name} | ${entry.reason} |`
    ).join("\n");

  return `${markdownGeneratedHeader()}# Generated Schema Contracts Index

This file is generated by \`tool/contracts/generate_schema_contracts.mjs\`.
Do not edit it by hand.

## TypeScript Schema Types

| Generated Type | Source Schema | Output |
|---|---|---|
${tsRows}

## Dart Schema Constants

| Dart Constant | Schema Name | Source Schema | Output |
|---|---|---|---|
${dartSchemaRows}

## Dart Callable Classes

| Generated Class | Schema Name | Source Schema | Output |
|---|---|---|---|
${callableRows}

## Callable Schemas Still Hand-Written In Dart

| Schema | Reason |
|---|---|
${ungenerableRows}

## Registry And Validator Outputs

| Output | Purpose |
|---|---|
| \`functions/src/shared/generated/schemaRegistry.ts\` | TypeScript schema registry for Functions runtime code. |
| \`functions/src/shared/generated/schemaValidators.ts\` | Ajv validators compiled from callable/schema contracts. |
| \`functions/src/shared/generated/firestoreAdminTypes.ts\` | Admin SDK Timestamp-aware Firestore projection types. |
| \`functions/src/shared/generated/schemaPaths.ts\` | Generated storage/path constants for migrated logical paths. |
| \`tool/contracts/generated/schema_contract_registry.mjs\` | Node-side schema registry for validation tooling. |
| \`tool/contracts/generated/schema_contract_validators.mjs\` | Node-side Ajv validators for contract checks. |
| \`lib/core/schema_contracts/generated/profile_schema_contracts.g.dart\` | Dart profile catalog and storage policy constants. |
| \`lib/core/schema_contracts/generated/schema_contracts.g.dart\` | Dart schema contract barrel. |
| \`lib/core/schema_contracts/generated/schemas/*.g.dart\` | One generated Dart JSON Schema constant file per schema, plus lookup registry files. |
| \`lib/core/schema_contracts/generated/callable_request_dtos.g.dart\` | Generated Dart callable request and patch helper barrel. |
| \`lib/core/schema_contracts/generated/callables/*.g.dart\` | One generated Dart callable request or patch helper file per schema-owned class. |
`;
}

function dartSchemaConstName(name) {
  return `schema${name}Schema`;
}

// ────────────────────────────────────────────────────────────────────────────
// Dart callable request DTO generation.
//
// Walks every callable payload schema (and the update_user_profile patch),
// emits a Dart class with constructor, fields, and toJson(). Classes for
// schemas that are still too rich (nested objects without inline class
// emission yet, anyOf with multiple non-null branches, etc.) are skipped and
// reported via the `dartUngenerable` list returned alongside the rendered
// text — the caller logs it so contributors see what's still hand-written.
// ────────────────────────────────────────────────────────────────────────────

// Callable schemas whose generated patch helper owns the callable wrapper via
// toCallableJson(), so emitting a separate *CallableRequest would duplicate the
// same payload shape:
//   - schemas with x-callable-shape: patch
//
// Callable schemas where the generator's projection would shadow a
// hand-written class that adds behavior the generator can't reproduce:
//   - EventBookingCallablePayload / CreateRazorpayOrderCallablePayload:
//     hand-written DTOs apply `inviteCode?.trim()` at serialization time.
//     The schemas exist for validation and as the contract source of truth;
//     the Dart classes stay hand-written so the trim normalization remains
//     attached to the boundary.
const DART_CALLABLE_REQUEST_SKIP = new Set([
  "EventBookingCallablePayload",
  "CreateRazorpayOrderCallablePayload",
]);

const DART_CALLABLE_REQUEST_OUTPUT_DIR =
  "lib/core/schema_contracts/generated/callables";

const DART_CALLABLE_FIELD_OVERRIDES = new Map([
  [
    "CreateClubCallableRequest.hostDefaults",
    {
      dartType: "ClubHostDefaults",
      imports: [
        "import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';",
      ],
      jsonExpression: (name) => `${name}.toJson()`,
      nullableJsonExpression: (name) => `${name}?.toJson()`,
    },
  ],
  [
    "CreateEventCallableRequest.meetingLocation",
    {
      dartType: "EventMeetingLocation",
      imports: [
        "import 'package:catch_dating_app/events/domain/event_meeting_location.dart';",
      ],
      jsonExpression: (name) => `${name}.toJson()`,
      nullableJsonExpression: (name) => `${name}?.toJson()`,
    },
  ],
  [
    "CreateEventCallableRequest.eventPolicy",
    {
      dartType: "EventPolicyBundle",
      imports: [
        "import 'package:catch_dating_app/event_policies/domain/event_policy.dart';",
      ],
      jsonExpression: (name) => `${name}.toJson()`,
      nullableJsonExpression: (name) => `${name}?.toJson()`,
    },
  ],
  [
    "CreateEventCallableRequest.privateAccess",
    {
      dartType: "CreateEventPrivateAccess",
      jsonExpression: (name) => `${name}.toJson()`,
      nullableJsonExpression: (name) => `${name}?.toJson()`,
    },
  ],
  [
    "CreateEventCallableRequest.eventFormat",
    {
      dartType: "EventFormatSnapshot",
      imports: [
        "import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';",
      ],
      jsonExpression: (name) => `${name}.toJson()`,
      nullableJsonExpression: (name) => `${name}?.toJson()`,
    },
  ],
  [
    "CreateEventCallableRequest.eventSuccessDefaults",
    {
      dartType: "EventSuccessDefaults",
      imports: [
        "import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';",
      ],
      jsonExpression: (name) => `${name}.toJson()`,
      nullableJsonExpression: (name) => `${name}?.toJson()`,
    },
  ],
  [
    "CreateEventCallableRequest.constraints",
    {
      dartType: "EventConstraints",
      imports: [
        "import 'package:catch_dating_app/events/domain/event_constraints.dart';",
      ],
      jsonExpression: (name) => `${name}.toJson()`,
      nullableJsonExpression: (name) => `${name}?.toJson()`,
    },
  ],
]);

function renderDartCallableRequestClasses({schemaSpecs, schemaMap, commonSchema}) {
  const files = [];
  const barrelExports = [];
  const ungenerable = [];
  const generatedClasses = [];
  const enumTypesBySignature = dartProfileEnumTypesBySignature(commonSchema);

  for (const spec of schemaSpecs) {
    if (!isCallableRequestSpec(spec)) continue;
    const schema = schemaMap.get(spec.name);
    if (!schema) continue;

    const callableShape = schema["x-callable-shape"];
    const isPatchShape = callableShape === "patch";

    if (isPatchShape) {
      if (!isPatchCallableSchema(schema)) {
        ungenerable.push({
          name: `${spec.name}Patch`,
          reason: "x-callable-shape patch requires a top-level required fields object",
        });
      } else {
        const patchResult = tryEmitDartPatchClass(
          spec,
          schema,
          enumTypesBySignature
        );
        if (patchResult.ok) {
          const output = dartCallableRequestOutputPath(patchResult.className);
          files.push({
            path: output,
            content: renderDartCallableRequestClassFile({
              imports: patchResult.imports,
              schemaSource: spec.source,
              body: patchResult.text,
            }),
          });
          barrelExports.push(dartGeneratedExportPath(output));
          generatedClasses.push({
            className: patchResult.className,
            schemaName: spec.name,
            source: spec.source,
            output,
          });
        } else {
          ungenerable.push({
            name: `${spec.name}Patch`,
            reason: patchResult.reason,
          });
        }
      }
    }

    if (isPatchShape || DART_CALLABLE_REQUEST_SKIP.has(spec.name)) continue;

    const result = tryEmitDartCallableClass(spec, schema);
    if (result.ok) {
      const output = dartCallableRequestOutputPath(result.className);
      files.push({
        path: output,
        content: renderDartCallableRequestClassFile({
          imports: result.imports,
          schemaSource: spec.source,
          body: result.text,
        }),
      });
      barrelExports.push(dartGeneratedExportPath(output));
      for (const className of result.classNames) {
        generatedClasses.push({
          className,
          schemaName: spec.name,
          source: spec.source,
          output,
        });
      }
    } else {
      ungenerable.push({name: spec.name, reason: result.reason});
    }
  }

  const body = barrelExports.length === 0 ?
    "// No callable request classes are currently generatable.\n" :
    [...new Set(barrelExports)]
      .sort()
      .map((item) => `export '${item}';`)
      .join("\n");
  const text = `${dartGeneratedHeader()}
// Typed callable request DTOs emitted from contracts/callables/ and
// contracts/patches/. The toJson() output of each class is validated against
// the corresponding JSON Schema by test/core/callable_dto_contracts_test.dart.
// Patch helper classes are emitted for schemas with x-callable-shape: patch.
// This file is a stable barrel; individual generated classes live under
// lib/core/schema_contracts/generated/callables/.
//
// Hand-written callable request/response helpers may still exist for schemas
// that need custom normalization or response parsing beyond generated request
// toJson() classes.

${body}
`;

  return {text, files, ungenerable, generatedClasses};
}

function dartCallableRequestOutputPath(className) {
  return `${DART_CALLABLE_REQUEST_OUTPUT_DIR}/${snakeCase(className)}.g.dart`;
}

function dartGeneratedExportPath(outputPath) {
  return outputPath.replace("lib/core/schema_contracts/generated/", "");
}

function renderDartCallableRequestClassFile({imports, schemaSource, body}) {
  const importBlock = [...(imports ?? [])].sort().join("\n");
  const normalizedBody = body.trimEnd();
  return `${dartGeneratedHeader()}${importBlock ? `${importBlock}\n\n` : ""}
// Typed callable request DTO emitted from ${schemaSource}.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

${normalizedBody}
`;
}

function isCallableRequestSpec(spec) {
  if (typeof spec.source !== "string") return false;
  if (spec.source.startsWith("callables/")) return true;
  if (spec.source === "patches/update_user_profile.schema.json") return true;
  return false;
}

function isPatchCallableSchema(schema) {
  return schema?.type === "object" &&
    schema?.properties?.fields?.type === "object" &&
    schema?.properties?.fields?.properties &&
    schema?.required?.includes("fields");
}

function tryEmitDartCallableClass(spec, schema) {
  if (schema.type !== "object" || !schema.properties) {
    return {ok: false, reason: "not an object schema"};
  }

  // BlockUserCallablePayload → BlockUserCallableRequest
  // CreateClubCallablePayload → CreateClubCallableRequest
  const className = spec.name.replace(/Payload$/, "Request");
  const required = new Set(schema.required ?? []);

  const fields = [];
  const imports = new Set();
  for (const [fieldName, prop] of Object.entries(schema.properties)) {
    const override = dartCallableFieldOverride(className, fieldName);
    const mapped = override?.dartType ?? mapDartType(prop);
    if (mapped === null) {
      return {
        ok: false,
        reason: `cannot map field "${fieldName}" (${describeSchemaType(prop)})`,
      };
    }
    for (const item of override?.imports ?? []) imports.add(item);
    const isRequired = required.has(fieldName);
    // Optional schema fields ("not in required") map to nullable Dart fields,
    // even when the schema type itself is non-null. JSON-side "omitted" is
    // Dart-side null. The map literal uses `?name` to drop entries when null.
    const dartType = isRequired || mapped.endsWith("?") ? mapped : `${mapped}?`;
    fields.push({
      name: fieldName,
      dartType,
      isRequired,
      jsonExpression: override?.jsonExpression?.(fieldName),
      nullableJsonExpression: override?.nullableJsonExpression?.(fieldName),
    });
  }

  if (fields.length === 0) {
    return {ok: false, reason: "no properties"};
  }

  const extraText = dartCallableExtraClassText(className);
  const text = formatDartCallableClass(className, fields, schema.description);
  const extraClassNames = dartCallableExtraClassNames(className);

  return {
    ok: true,
    className,
    imports,
    classNames: [...extraClassNames, className],
    text: extraText ? `${extraText}\n\n${text}` : text,
  };
}

function dartCallableFieldOverride(className, fieldName) {
  return DART_CALLABLE_FIELD_OVERRIDES.get(`${className}.${fieldName}`) ?? null;
}

function dartCallableExtraClassText(className) {
  if (className !== "CreateEventCallableRequest") return "";
  return `/// Nested private-access payload accepted by createEvent.
final class CreateEventPrivateAccess {
  const CreateEventPrivateAccess({this.inviteCode});

  final String? inviteCode;

  Map<String, Object?> toJson() => {
    'inviteCode': ?inviteCode,
  };
}`;
}

function dartCallableExtraClassNames(className) {
  if (className !== "CreateEventCallableRequest") return [];
  return ["CreateEventPrivateAccess"];
}

function tryEmitDartPatchClass(spec, schema, enumTypesBySignature) {
  const config = dartPatchClassConfig(spec.name);
  if (!config) {
    return {ok: false, reason: "no Dart patch config"};
  }
  const fieldsSchema = schema.properties.fields;
  const patchProperties = fieldsSchema.properties;
  if (!patchProperties || Object.keys(patchProperties).length === 0) {
    return {ok: false, reason: "patch fields object has no properties"};
  }

  const fields = [];
  for (const [fieldName, prop] of Object.entries(patchProperties)) {
    const mapped = mapDartPatchField(fieldName, prop, enumTypesBySignature, config);
    if (mapped === null) {
      return {
        ok: false,
        reason: `cannot map patch field "${fieldName}" (${describeSchemaType(prop)})`,
      };
    }
    fields.push({name: fieldName, ...mapped});
  }

  const callableFields = [];
  const callableRequired = new Set(schema.required ?? []);
  for (const [fieldName, prop] of Object.entries(schema.properties ?? {})) {
    if (fieldName === "fields") continue;
    const mapped = mapDartType(prop);
    if (mapped === null) {
      return {
        ok: false,
        reason: `cannot map callable wrapper field "${fieldName}" (${describeSchemaType(prop)})`,
      };
    }
    const isRequired = callableRequired.has(fieldName);
    const dartType = isRequired || mapped.endsWith("?") ? mapped : `${mapped}?`;
    callableFields.push({
      name: fieldName,
      dartType,
      isRequired,
    });
  }

  return {
    ok: true,
    className: config.className,
    imports: config.imports,
    text: formatDartPatchClass(config, fields, callableFields, schema.description),
  };
}

function dartPatchClassConfig(specName) {
  const className = specName
    .replace(/CallablePayload$/, "")
    .replace(/Payload$/, "") + "Patch";
  switch (specName) {
    case "UpdateUserProfileCallablePayload":
      return {
        className,
        sentinelName: "unsetSentinel",
        jsonValueHelperName: "_updateUserProfilePatchJsonValue",
        includeTimestampJsonHelper: true,
        imports: [
          "import 'package:catch_dating_app/core/sentinels.dart';",
          "import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';",
          "import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';",
          "import 'package:catch_dating_app/user_profile/domain/user_profile.dart';",
          "import 'package:cloud_firestore/cloud_firestore.dart';",
        ],
        objectFields: new Map([["activityPreferences", "ActivityPreferences"]]),
        listObjectFields: new Map([
          ["profilePrompts", "ProfilePromptAnswer"],
          ["profilePhotos", "ProfilePhoto"],
        ]),
      };
    case "UpdateClubCallablePayload":
      return {
        className,
        sentinelName: "unsetSentinel",
        jsonValueHelperName: "_updateClubPatchJsonValue",
        includeTimestampJsonHelper: false,
        imports: [
          "import 'package:catch_dating_app/core/sentinels.dart';",
          "import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';",
        ],
        objectFields: new Map([["hostDefaults", "ClubHostDefaults"]]),
        listObjectFields: new Map(),
      };
    default:
      return null;
  }
}

function dartProfileEnumTypesBySignature(commonSchema) {
  const definitions = commonSchema?.definitions ?? {};
  const typesBySignature = new Map();
  for (const [name, definition] of Object.entries(definitions)) {
    if (!Array.isArray(definition?.enum)) continue;
    const values = definition.enum.filter((value) => value !== null);
    if (values.length === 0 || !values.every((value) => typeof value === "string")) {
      continue;
    }
    typesBySignature.set(enumSignature(values), pascalCase(name));
  }
  return typesBySignature;
}

function mapDartPatchField(fieldName, prop, enumTypesBySignature, config) {
  if (!prop || typeof prop !== "object") return null;
  const nullable = schemaAllowsNull(prop);
  const enumType = dartEnumTypeForSchema(prop, enumTypesBySignature);
  const dateTime = isMillisSinceEpochInteger(prop);
  const list = prop.type === "array" ? mapDartPatchListField(
    fieldName,
    prop,
    enumTypesBySignature,
    config
  ) : null;
  const objectType = config.objectFields.get(fieldName);

  if (list) {
    return {
      paramType: `${list.dartType}?`,
      nullable,
      jsonExpression: `${fieldName}.map((e) => ${list.itemJsonExpression("e")}).toList()`,
      usesJsonValueHelper: list.usesJsonValueHelper,
    };
  }
  if (enumType) {
    return {
      paramType: nullable ? "Object?" : `${enumType}?`,
      nullable,
      jsonExpression: nullable ?
        `(${fieldName} as ${enumType}?)?.name` :
        `${fieldName}.name`,
    };
  }
  if (dateTime) {
    return {
      paramType: "DateTime?",
      nullable,
      jsonExpression: `${fieldName}.millisecondsSinceEpoch`,
    };
  }
  if (objectType) {
    return {
      paramType: `${objectType}?`,
      nullable,
      jsonExpression: `${fieldName}.toJson()`,
    };
  }

  const scalarType = dartScalarPatchType(prop);
  if (scalarType) {
    return {
      paramType: nullable ? "Object?" : `${scalarType}?`,
      nullable,
      jsonExpression: nullable ? fieldName : fieldName,
    };
  }

  return null;
}

function mapDartPatchListField(fieldName, prop, enumTypesBySignature, config) {
  const items = prop.items;
  if (!items || typeof items !== "object") return null;
  const enumType = dartEnumTypeForSchema(items, enumTypesBySignature);
  if (enumType) {
    return {
      dartType: `List<${enumType}>`,
      itemJsonExpression: (value) => `${value}.name`,
    };
  }
  const objectType = config.listObjectFields.get(fieldName);
  if (objectType) {
    return {
      dartType: `List<${objectType}>`,
      itemJsonExpression: (value) =>
        `${config.jsonValueHelperName}(${value}.toJson())`,
      usesJsonValueHelper: true,
    };
  }
  const scalarType = dartScalarPatchType(items);
  if (scalarType) {
    return {
      dartType: `List<${scalarType}>`,
      itemJsonExpression: (value) => value,
    };
  }
  return null;
}

function dartScalarPatchType(prop) {
  if (!prop || typeof prop !== "object") return null;
  if (Array.isArray(prop.type)) {
    const nonNull = prop.type.filter((value) => value !== "null");
    if (nonNull.length !== 1) return null;
    return dartScalarPatchType({...prop, type: nonNull[0]});
  }
  if (Array.isArray(prop.anyOf) && !prop.type) {
    const nonNull = prop.anyOf.filter((item) => item?.type !== "null");
    const scalarTypes = new Set(nonNull.map(dartScalarPatchType).filter(Boolean));
    return scalarTypes.size === 1 ? [...scalarTypes][0] : null;
  }
  if (Object.hasOwn(prop, "const")) {
    if (typeof prop.const === "string") return "String";
    if (typeof prop.const === "number") {
      return Number.isInteger(prop.const) ? "int" : "double";
    }
    if (typeof prop.const === "boolean") return "bool";
  }
  switch (prop.type) {
    case "string": return "String";
    case "integer": return "int";
    case "number": return "double";
    case "boolean": return "bool";
    default: return null;
  }
}

function dartEnumTypeForSchema(prop, enumTypesBySignature) {
  if (!prop || typeof prop !== "object") return null;
  if (Array.isArray(prop.enum)) {
    const values = prop.enum.filter((value) => value !== null);
    if (values.length > 0 && values.every((value) => typeof value === "string")) {
      return enumTypesBySignature.get(enumSignature(values)) ?? null;
    }
  }
  if (Array.isArray(prop.anyOf)) {
    for (const item of prop.anyOf) {
      const type = dartEnumTypeForSchema(item, enumTypesBySignature);
      if (type) return type;
    }
  }
  return null;
}

function schemaAllowsNull(prop) {
  if (!prop || typeof prop !== "object") return false;
  if (Array.isArray(prop.type) && prop.type.includes("null")) return true;
  if (Array.isArray(prop.enum) && prop.enum.includes(null)) return true;
  if (Array.isArray(prop.anyOf)) return prop.anyOf.some(schemaAllowsNull);
  return prop.type === "null";
}

function isMillisSinceEpochInteger(prop) {
  if (!prop || typeof prop !== "object") return false;
  const type = Array.isArray(prop.type) ?
    prop.type.filter((value) => value !== "null")[0] :
    prop.type;
  return type === "integer" &&
    typeof prop.description === "string" &&
    /milliseconds since epoch/i.test(prop.description);
}

function enumSignature(values) {
  return values.join("\u0000");
}

function pascalCase(value) {
  return String(value)
    .split(/[^A-Za-z0-9]+/)
    .flatMap((part) => part.split(/(?=[A-Z])/))
    .filter(Boolean)
    .map((part) => `${part[0].toUpperCase()}${part.slice(1)}`)
    .join("");
}

function snakeCase(value) {
  return String(value)
    .replace(/([A-Z]+)([A-Z][a-z])/g, "$1_$2")
    .replace(/([a-z0-9])([A-Z])/g, "$1_$2")
    .replace(/[^A-Za-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .toLowerCase();
}

function formatDartPatchClass(config, fields, callableFields, description) {
  const helperBlock = fields.some((field) => field.usesJsonValueHelper) ?
    `\n${formatDartPatchJsonValueHelper(config)}` :
    "";
  const ctorParams = fields.map((field) => {
    const defaultValue = field.nullable ? ` = ${config.sentinelName}` : "";
    return `    ${field.paramType} ${field.name}${defaultValue},`;
  }).join("\n");

  const jsonEntries = fields.map((field) => {
    if (field.nullable) {
      return `         if (!identical(${field.name}, ${config.sentinelName}))
           ${dartString(field.name)}: ${field.jsonExpression},`;
    }
    return `         if (${field.name} != null)
           ${dartString(field.name)}: ${field.jsonExpression},`;
  }).join("\n");

  const docComment = description ?
    `/// Typed patch helper generated from ${description}\n` :
    "/// Typed patch helper generated from the updateUserProfile schema.\n";
  const callableJsonMethod = formatDartPatchCallableJsonMethod(callableFields);

  return `${docComment}final class ${config.className} {
  ${config.className}({
${ctorParams}
  }) : _fields = {
${jsonEntries}
       };

  /// Escape hatch for callers that compute the field key dynamically.
  /// Prefer the typed constructor for app presentation and repository code.
  ${config.className}.raw(Map<String, Object?> fields)
    : _fields = Map<String, Object?>.from(fields);

  final Map<String, Object?> _fields;

  Iterable<String> get keys => _fields.keys;

  bool get isEmpty => _fields.isEmpty;
  bool get isNotEmpty => _fields.isNotEmpty;

  Map<String, Object?> toFieldsJson() =>
      Map<String, Object?>.unmodifiable(_fields);
${callableJsonMethod}
}

${helperBlock}
`;
}

function formatDartPatchCallableJsonMethod(callableFields) {
  const params = callableFields.map((field) =>
    `    ${field.isRequired ? "required " : ""}${field.dartType} ${field.name},`
  ).join("\n");
  const signature = callableFields.length === 0 ?
    "toCallableJson()" :
    `toCallableJson({\n${params}\n  })`;
  const wrapperEntries = callableFields.map((field) => {
    const value = field.isRequired ? field.name : `?${field.name}`;
    return `    ${dartString(field.name)}: ${value},`;
  }).join("\n");
  const entries = [
    wrapperEntries,
    "    'fields': toFieldsJson(),",
  ].filter(Boolean).join("\n");
  return `
  Map<String, Object?> ${signature} => {
${entries}
  };`;
}

function formatDartPatchJsonValueHelper(config) {
  return `Object? ${config.jsonValueHelperName}(Object? value) {
  ${config.includeTimestampJsonHelper ? "if (value is Timestamp) return value.millisecondsSinceEpoch;\n  " : ""}if (value is DateTime) return value.millisecondsSinceEpoch;
  if (value is Iterable) {
    return value.map(${config.jsonValueHelperName}).toList();
  }
  if (value is Map) {
    return value.map(
      (key, child) => MapEntry(key, ${config.jsonValueHelperName}(child)),
    );
  }
  return value;
}`;
}

function mapDartType(prop) {
  if (!prop || typeof prop !== "object") return null;

  // Type union including null → nullable scalar.
  if (Array.isArray(prop.type)) {
    const isNullable = prop.type.includes("null");
    const nonNull = prop.type.filter((t) => t !== "null");
    if (nonNull.length !== 1) return null;
    const base = mapDartType({...prop, type: nonNull[0]});
    if (!base) return null;
    const baseStripped = base.endsWith("?") ? base.slice(0, -1) : base;
    return isNullable ? `${baseStripped}?` : base;
  }

  // anyOf with a "null" branch → nullable of the single non-null branch.
  if (Array.isArray(prop.anyOf) && !prop.type) {
    const hasNull = prop.anyOf.some((s) => s && s.type === "null");
    const nonNull = prop.anyOf.filter((s) => s && s.type !== "null");
    if (nonNull.length !== 1) return null;
    const inner = mapDartType(nonNull[0]);
    if (!inner) return null;
    const innerStripped = inner.endsWith("?") ? inner.slice(0, -1) : inner;
    return hasNull ? `${innerStripped}?` : inner;
  }

  // Enum (string with const list of values) → String for now.
  // The JSON Schema validates the value; Dart side stays String.

  switch (prop.type) {
    case "string": return "String";
    case "integer": return "int";
    case "number": return "double";
    case "boolean": return "bool";
    case "array": {
      if (!prop.items || typeof prop.items !== "object") return null;
      const innerType = mapDartType(prop.items);
      if (!innerType) return null;
      // Dart Lists drop the inner nullability suffix for the element type.
      const innerStripped = innerType.endsWith("?") ?
        innerType.slice(0, -1) :
        innerType;
      return `List<${innerStripped}>`;
    }
    case "object": {
      // Strictly-typed nested objects would ideally each get their own emitted
      // Dart class. For now, project them as Map<String, Object?> — matching
      // the choice the hand-written DTOs make for nested payloads. This keeps
      // the toJson() output schema-conformant while losing field-level Dart
      // typing for the nested shape. Future work: emit nested classes.
      return "Map<String, Object?>";
    }
    default: return null;
  }
}

function describeSchemaType(prop) {
  if (!prop || typeof prop !== "object") return "non-object";
  if (Array.isArray(prop.type)) return `type=[${prop.type.join(", ")}]`;
  if (Array.isArray(prop.anyOf)) return "anyOf";
  if (prop.type === "object" && prop.properties) return "nested object";
  return prop.type ? `type=${prop.type}` : "no type";
}

function formatDartCallableClass(className, fields, description) {
  const ctorParams = fields.map((f) =>
    f.isRequired ?
      `    required this.${f.name},` :
      `    this.${f.name},`
  ).join("\n");

  const fieldDecls = fields.map((f) =>
    `  final ${f.dartType} ${f.name};`
  ).join("\n");

  const jsonEntries = fields.map((f) => {
    const jsonExpression = f.jsonExpression ?? f.name;
    const nullableJsonExpression = f.nullableJsonExpression ?? jsonExpression;
    return f.isRequired ?
      `    ${dartString(f.name)}: ${jsonExpression},` :
      `    ${dartString(f.name)}: ?${nullableJsonExpression},`;
  }).join("\n");

  const docComment = description ?
    `/// ${description}\n` :
    "";

  return `${docComment}final class ${className} {
  const ${className}({
${ctorParams}
  });

${fieldDecls}

  Map<String, Object?> toJson() => {
${jsonEntries}
  };
}`;
}

function profileDecisionPathParts(schemaOrPath) {
  const pathTemplate = typeof schemaOrPath === "string" ?
    schemaOrPath :
    schemaOrPath?.["x-firestore-path"];
  if (typeof pathTemplate !== "string") {
    throw new Error("Profile decision path template is missing.");
  }
  const parts = pathTemplate.split("/");
  if (parts.length !== 4 || parts[2] !== "outgoing") {
    throw new Error(
      `Unexpected profile decision path template: ${pathTemplate}`
    );
  }
  return {
    pathTemplate,
    triggerPath: pathTemplate
      .replace("{userId}", "{swiperId}")
      .replace("{targetId}", "{targetId}"),
    collectionPath: parts[0],
    outgoingSubcollectionPath: parts[2],
  };
}

function bundleSchema(file) {
  const absoluteFile = path.resolve(file);
  const schema = readJsonFile(absoluteFile);
  return resolveRefs(schema, absoluteFile, true);
}

function resolveRefs(node, currentFile, keepSchemaMeta) {
  if (Array.isArray(node)) {
    return node.map((item) => resolveRefs(item, currentFile, false));
  }
  if (!node || typeof node !== "object") return node;

  if (typeof node.$ref === "string") {
    const {$ref, ...siblings} = node;
    const resolved = resolveReference($ref, currentFile);
    const merged = {
      ...stripSchemaMeta(resolveRefs(resolved.value, resolved.file, false)),
      ...resolveRefs(siblings, currentFile, false),
    };
    return Object.keys(merged).length === 0 ? true : merged;
  }

  const result = {};
  for (const [key, value] of Object.entries(node)) {
    if (!keepSchemaMeta && (key === "$schema" || key === "$id")) continue;
    result[key] = resolveRefs(value, currentFile, false);
  }
  return result;
}

function resolveReference(ref, currentFile) {
  if (/^[a-z]+:\/\//i.test(ref)) {
    throw new Error(`Remote schema refs are not supported by this generator: ${
      ref
    }`);
  }
  const [target, pointer = ""] = ref.split("#");
  const file = target ?
    path.resolve(path.dirname(currentFile), target) :
    currentFile;
  const json = readJsonFile(file);
  return {file, value: resolveJsonPointer(json, pointer)};
}

function resolveJsonPointer(document, pointer) {
  if (!pointer || pointer === "/") return document;
  if (!pointer.startsWith("/")) {
    throw new Error(`Unsupported JSON pointer: #${pointer}`);
  }
  return pointer
    .slice(1)
    .split("/")
    .reduce((value, token) => {
      const key = token.replace(/~1/g, "/").replace(/~0/g, "~");
      if (value === undefined || value === null ||
          !Object.prototype.hasOwnProperty.call(value, key)) {
        throw new Error(`JSON pointer segment not found: ${key}`);
      }
      return value[key];
    }, document);
}

function stripSchemaMeta(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) return value;
  const {$schema, $id, ...rest} = value;
  return rest;
}

function readContractJson(relativePath) {
  return readJsonFile(path.join(contractRoot, relativePath));
}

function readJsonFile(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function tsGeneratedHeader() {
  return `/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

`;
}

function mjsGeneratedHeader() {
  return `// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

`;
}

function dartGeneratedHeader() {
  return `// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements
`;
}

function markdownGeneratedHeader() {
  return `<!--
GENERATED CODE - DO NOT MODIFY BY HAND.
Regenerate with: node tool/contracts/generate_schema_contracts.mjs
-->

`;
}

function jsonForTs(value) {
  return `${JSON.stringify(value, null, 2)} as const`;
}

function jsonForJs(value) {
  return JSON.stringify(value, null, 2);
}

function dartLiteral(value) {
  if (value === null) return "null";
  if (typeof value === "string") return dartString(value);
  if (typeof value === "number" || typeof value === "boolean") {
    return String(value);
  }
  if (Array.isArray(value)) {
    if (value.length === 0) return "<Object?>[]";
    return `<Object?>[
${value.map((item) => indent(dartLiteral(item), 2)).join(",\n")},
]`;
  }
  const entries = Object.entries(value).map(([key, item]) =>
    `${indent(`${dartString(key)}: ${dartLiteral(item)}`, 2)}`
  );
  if (entries.length === 0) return "<String, Object?>{}";
  return `<String, Object?>{
${entries.join(",\n")},
}`;
}

function dartString(value) {
  return `'${String(value)
    .replace(/\\/g, "\\\\")
    .replace(/'/g, "\\'")
    .replace(/\$/g, "\\$")
    .replace(/\r/g, "\\r")
    .replace(/\n/g, "\\n")}'`;
}

function indent(value, spaces) {
  const pad = " ".repeat(spaces);
  return String(value)
    .split("\n")
    .map((line) => `${pad}${line}`)
    .join("\n");
}

await main();
