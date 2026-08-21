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
    name: "MobileFormState",
    source: "forms/mobile_form_state.schema.json",
    typeOutput: "functions/src/shared/generated/mobileFormState.ts",
  },
  {
    name: "OperationRun",
    source: "operations/run.schema.json",
    typeOutput: "functions/src/shared/generated/operationRunContract.ts",
  },
  {
    name: "OperationWorkItem",
    source: "operations/work_item.schema.json",
    typeOutput: "functions/src/shared/generated/operationWorkItemContract.ts",
  },
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
    name: "UploadedPhoto",
    source: "embedded/uploaded_photo.schema.json",
    typeOutput: "functions/src/shared/generated/uploadedPhoto.ts",
  },
  {
    name: "EventOrigin",
    source: "embedded/event_origin.schema.json",
    typeOutput: "functions/src/shared/generated/eventOrigin.ts",
  },
  {
    name: "EventRuntimeAccess",
    source: "embedded/event_runtime_access.schema.json",
    typeOutput: "functions/src/shared/generated/eventRuntimeAccess.ts",
  },
  {
    name: "ActivityPreferences",
    source: "embedded/activity_preferences.schema.json",
    typeOutput: "functions/src/shared/generated/activityPreferences.ts",
  },
  {
    name: "OrganizerSupplyCapabilities",
    source: "embedded/organizer_supply_capabilities.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerSupplyCapabilities.ts",
  },
  {
    name: "ExternalEventBlockerResolution",
    source: "embedded/external_event_blocker_resolution.schema.json",
    typeOutput:
      "functions/src/shared/generated/externalEventBlockerResolution.ts",
  },
  {
    name: "ExternalEventPublicationReceiptDocument",
    source:
      "firestore/external_event_publication_receipts.schema.json",
    typeOutput:
      "functions/src/shared/generated/externalEventPublicationReceiptDocument.ts",
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
    name: "AccessApplicationDocument",
    source: "firestore/access_applications.schema.json",
    typeOutput:
      "functions/src/shared/generated/accessApplicationDocument.ts",
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
    name: "HostProfileDocument",
    source: "firestore/host_profiles.schema.json",
    typeOutput: "functions/src/shared/generated/hostProfileDocument.ts",
  },
  {
    name: "ClubDocument",
    source: "firestore/clubs.schema.json",
    typeOutput: "functions/src/shared/generated/clubDocument.ts",
  },
  {
    name: "OrganizerDocument",
    source: "firestore/organizers.schema.json",
    typeOutput: "functions/src/shared/generated/organizerDocument.ts",
  },
  {
    name: "OrganizerPostDocument",
    source: "firestore/organizer_posts.schema.json",
    typeOutput: "functions/src/shared/generated/organizerPostDocument.ts",
  },
  {
    name: "OrganizerPostDeliveryOperationDocument",
    source: "firestore/organizer_post_delivery_operations.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "organizerPostDeliveryOperationDocument.ts",
  },
  {
    name: "OrganizerPostDeliveryRecipientDocument",
    source: "firestore/organizer_post_delivery_recipients.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "organizerPostDeliveryRecipientDocument.ts",
  },
  {
    name: "OrganizerTeamMembershipDocument",
    source: "firestore/organizer_team_memberships.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerTeamMembershipDocument.ts",
  },
  {
    name: "OrganizerFollowDocument",
    source: "firestore/organizer_follows.schema.json",
    typeOutput: "functions/src/shared/generated/organizerFollowDocument.ts",
  },
  {
    name: "OrganizerCommunicationPreferenceDocument",
    source: "firestore/organizer_communication_preferences.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "organizerCommunicationPreferenceDocument.ts",
  },
  {
    name: "OrganizerContactDocument",
    source: "firestore/organizer_contacts.schema.json",
    typeOutput: "functions/src/shared/generated/organizerContactDocument.ts",
  },
  {
    name: "OrganizerContactNoteDocument",
    source: "firestore/organizer_contact_notes.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerContactNoteDocument.ts",
  },
  {
    name: "OrganizerContactTagVocabularyDocument",
    source: "firestore/organizer_contact_tag_vocabularies.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "organizerContactTagVocabularyDocument.ts",
  },
  {
    name: "OrganizerContactIdentityLinkDocument",
    source: "firestore/organizer_contact_identity_links.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerContactIdentityLinkDocument.ts",
  },
  {
    name: "OrganizerContactIdentityClaimDocument",
    source: "firestore/organizer_contact_identity_claims.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerContactIdentityClaimDocument.ts",
  },
  {
    name: "OrganizerContactEventEdgeDocument",
    source: "firestore/organizer_contact_event_edges.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerContactEventEdgeDocument.ts",
  },
  {
    name: "OrganizerContactTraitDocument",
    source: "firestore/organizer_contact_traits.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerContactTraitDocument.ts",
  },
  {
    name: "OrganizerAudienceSummaryDocument",
    source: "firestore/organizer_audience_summaries.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerAudienceSummaryDocument.ts",
  },
  {
    name: "OrganizerAudienceProjectionReceiptDocument",
    source: "firestore/organizer_audience_projection_receipts.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerAudienceProjectionReceiptDocument.ts",
  },
  {
    name: "OrganizerContactMergeReceiptDocument",
    source: "firestore/organizer_contact_merge_receipts.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerContactMergeReceiptDocument.ts",
  },
  {
    name: "OrganizerContactMergeReviewDecisionDocument",
    source:
      "firestore/organizer_contact_merge_review_decisions.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "organizerContactMergeReviewDecisionDocument.ts",
  },
  {
    name: "OrganizerSenderConnectionDocument",
    source: "firestore/organizer_sender_connections.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerSenderConnectionDocument.ts",
  },
  {
    name: "OrganizerProviderConnectionDocument",
    source: "firestore/organizer_provider_connections.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerProviderConnectionDocument.ts",
  },
  {
    name: "OrganizerApplicationFormDocument",
    source: "firestore/organizer_application_forms.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerApplicationFormDocument.ts",
  },
  {
    name: "OrganizerApplicationFormVersionDocument",
    source: "firestore/organizer_application_form_versions.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerApplicationFormVersionDocument.ts",
  },
  {
    name: "OrganizerFormDocument",
    source: "firestore/organizer_forms.schema.json",
    typeOutput: "functions/src/shared/generated/organizerFormDocument.ts",
  },
  {
    name: "OrganizerFormDraftDocument",
    source: "firestore/organizer_form_drafts.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerFormDraftDocument.ts",
  },
  {
    name: "OrganizerFormVersionDocument",
    source: "firestore/organizer_form_versions.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerFormVersionDocument.ts",
  },
  {
    name: "OrganizerFormResponseDraftDocument",
    source: "firestore/organizer_form_response_drafts.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerFormResponseDraftDocument.ts",
  },
  {
    name: "OrganizerFormResponseDocument",
    source: "firestore/organizer_form_responses.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerFormResponseDocument.ts",
  },
  {
    name: "OrganizerFormAssetDocument",
    source: "firestore/organizer_form_assets.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerFormAssetDocument.ts",
  },
  {
    name: "OrganizerFormAggregateDocument",
    source: "firestore/organizer_form_aggregates.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerFormAggregateDocument.ts",
  },
  {
    name: "OrganizerFormAggregateEventDocument",
    source: "firestore/organizer_form_aggregate_events.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerFormAggregateEventDocument.ts",
  },
  {
    name: "OrganizerFormExportDocument",
    source: "firestore/organizer_form_exports.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerFormExportDocument.ts",
  },
  {
    name: "OrganizerFormAutomationRuleDocument",
    source: "firestore/organizer_form_automation_rules.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerFormAutomationRuleDocument.ts",
  },
  {
    name: "OrganizerFormAutomationRunDocument",
    source: "firestore/organizer_form_automation_runs.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerFormAutomationRunDocument.ts",
  },
  {
    name: "OrganizerFormConversionReceiptDocument",
    source: "firestore/organizer_form_conversion_receipts.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerFormConversionReceiptDocument.ts",
  },
  {
    name: "OrganizerFormShareLinkDocument",
    source: "firestore/organizer_form_share_links.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerFormShareLinkDocument.ts",
  },
  {
    name: "OrganizerApplicationDocument",
    source: "firestore/organizer_applications.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerApplicationDocument.ts",
  },
  {
    name: "OrganizerApplicationResponseDocument",
    source: "firestore/organizer_application_responses.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerApplicationResponseDocument.ts",
  },
  {
    name: "OrganizerApplicationAssetDocument",
    source: "firestore/organizer_application_assets.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerApplicationAssetDocument.ts",
  },
  {
    name: "OrganizerApplicationSourceMappingDocument",
    source: "firestore/organizer_application_source_mappings.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerApplicationSourceMappingDocument.ts",
  },
  {
    name: "OrganizerApplicationImportReceiptDocument",
    source: "firestore/organizer_application_import_receipts.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerApplicationImportReceiptDocument.ts",
  },
  {
    name: "ParticipantIntakeProfileDocument",
    source: "firestore/participant_intake_profiles.schema.json",
    typeOutput:
      "functions/src/shared/generated/participantIntakeProfileDocument.ts",
  },
  {
    name: "ParticipantOrganizerDataGrantDocument",
    source: "firestore/participant_organizer_data_grants.schema.json",
    typeOutput:
      "functions/src/shared/generated/participantOrganizerDataGrantDocument.ts",
  },
  {
    name: "ExternalEventMappingDocument",
    source: "firestore/external_event_mappings.schema.json",
    typeOutput:
      "functions/src/shared/generated/externalEventMappingDocument.ts",
  },
  {
    name: "ProviderSyncRunDocument",
    source: "firestore/provider_sync_runs.schema.json",
    typeOutput:
      "functions/src/shared/generated/providerSyncRunDocument.ts",
  },
  {
    name: "OrganizerMessageTemplateDocument",
    source: "firestore/organizer_message_templates.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerMessageTemplateDocument.ts",
  },
  {
    name: "OrganizerContactChannelStateDocument",
    source: "firestore/organizer_contact_channel_states.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerContactChannelStateDocument.ts",
  },
  {
    name: "OrganizerCampaignDocument",
    source: "firestore/organizer_campaigns.schema.json",
    typeOutput: "functions/src/shared/generated/organizerCampaignDocument.ts",
  },
  {
    name: "OrganizerBroadcastSummaryDocument",
    source: "firestore/organizer_broadcast_summaries.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerBroadcastSummaryDocument.ts",
  },
  {
    name: "OrganizerCampaignRecipientDocument",
    source: "firestore/organizer_campaign_recipients.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerCampaignRecipientDocument.ts",
  },
  {
    name: "OrganizerCampaignWebhookReceiptDocument",
    source: "firestore/organizer_campaign_webhook_receipts.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "organizerCampaignWebhookReceiptDocument.ts",
  },
  {
    name: "OrganizerMessagingWebhookEventDocument",
    source: "firestore/organizer_messaging_webhook_events.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "organizerMessagingWebhookEventDocument.ts",
  },
  {
    name: "OrganizerWhatsappThreadDocument",
    source: "firestore/organizer_whatsapp_threads.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerWhatsappThreadDocument.ts",
  },
  {
    name: "OrganizerWhatsappMessageDocument",
    source: "firestore/organizer_whatsapp_messages.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerWhatsappMessageDocument.ts",
  },
  {
    name: "OrganizerWhatsappReplyOperationDocument",
    source: "firestore/organizer_whatsapp_reply_operations.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "organizerWhatsappReplyOperationDocument.ts",
  },
  {
    name: "OrganizerClaimRequestDocument",
    source: "firestore/organizer_claim_requests.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerClaimRequestDocument.ts",
  },
  {
    name: "OrganizerScheduleLockDocument",
    source: "firestore/organizer_schedule_locks.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerScheduleLockDocument.ts",
  },
  {
    name: "ClubPostDocument",
    source: "firestore/club_posts.schema.json",
    typeOutput: "functions/src/shared/generated/clubPostDocument.ts",
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
    name: "ClubClaimRequestDocument",
    source: "firestore/club_claim_requests.schema.json",
    typeOutput: "functions/src/shared/generated/clubClaimRequestDocument.ts",
  },
  {
    name: "EventDocument",
    source: "firestore/events.schema.json",
    typeOutput: "functions/src/shared/generated/eventDocument.ts",
  },
  {
    name: "ExternalEventDocument",
    source: "firestore/external_events.schema.json",
    typeOutput: "functions/src/shared/generated/externalEventDocument.ts",
  },
  {
    name: "EventPrivateAccessDocument",
    source: "firestore/event_private_access.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventPrivateAccessDocument.ts",
  },
  {
    name: "EventInviteLinkDocument",
    source: "firestore/event_invite_links.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventInviteLinkDocument.ts",
  },
  {
    name: "EventInviteLinkSecretDocument",
    source: "firestore/event_invite_link_secrets.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventInviteLinkSecretDocument.ts",
  },
  {
    name: "EventInviteTouchDocument",
    source: "firestore/event_invite_touches.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventInviteTouchDocument.ts",
  },
  {
    name: "EventShareIntentDocument",
    source: "firestore/event_share_intents.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventShareIntentDocument.ts",
  },
  {
    name: "EventInviteAttributionDocument",
    source: "firestore/event_invite_attributions.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventInviteAttributionDocument.ts",
  },
  {
    name: "EventParticipationDocument",
    source: "firestore/event_participations.schema.json",
    typeOutput: "functions/src/shared/generated/eventParticipationDocument.ts",
  },
  {
    name: "EventAttendeeDocument",
    source: "firestore/event_attendees.schema.json",
    typeOutput: "functions/src/shared/generated/eventAttendeeDocument.ts",
  },
  {
    name: "EventStaffGrantDocument",
    source: "firestore/event_staff_grants.schema.json",
    typeOutput: "functions/src/shared/generated/eventStaffGrantDocument.ts",
  },
  {
    name: "EventAttendeeAttendanceReceiptDocument",
    source: "firestore/event_attendee_attendance_receipts.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "eventAttendeeAttendanceReceiptDocument.ts",
  },
  {
    name: "EventAttendeeImportDocument",
    source: "firestore/event_attendee_imports.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventAttendeeImportDocument.ts",
  },
  {
    name: "EventRosterHandoffDocument",
    source: "firestore/event_roster_handoffs.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventRosterHandoffDocument.ts",
  },
  {
    name: "EventRuntimeParticipantDocument",
    source: "firestore/event_runtime_participants.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventRuntimeParticipantDocument.ts",
  },
  {
    name: "EventVenueSessionDocument",
    source: "firestore/event_venue_sessions.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventVenueSessionDocument.ts",
  },
  {
    name: "EventVenueSessionRedemptionDocument",
    source: "firestore/event_venue_session_redemptions.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventVenueSessionRedemptionDocument.ts",
  },
  {
    name: "EventSuccessPresenceDocument",
    source: "firestore/event_success_presence.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessPresenceDocument.ts",
  },
  {
    name: "EventLivePositionDocument",
    source: "firestore/event_live_positions.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventLivePositionDocument.ts",
  },
  {
    name: "EventSuccessLateArrivalDocument",
    source: "firestore/event_success_late_arrivals.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessLateArrivalDocument.ts",
  },
  {
    name: "EventRehearsalDocument",
    source: "firestore/event_rehearsals.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventRehearsalDocument.ts",
  },
  {
    name: "EventRehearsalActorDocument",
    source: "firestore/event_rehearsal_actors.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventRehearsalActorDocument.ts",
  },
  {
    name: "EventRehearsalActionDocument",
    source: "firestore/event_rehearsal_actions.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventRehearsalActionDocument.ts",
  },
  {
    name: "EventRehearsalGuestViewDocument",
    source: "firestore/event_rehearsal_guest_views.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventRehearsalGuestViewDocument.ts",
  },
  {
    name: "EventRuntimeClaimRequestDocument",
    source: "firestore/event_runtime_claim_requests.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventRuntimeClaimRequestDocument.ts",
  },
  {
    name: "EventCrossPathsConsentDocument",
    source: "firestore/event_cross_paths_consents.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventCrossPathsConsentDocument.ts",
  },
  {
    name: "CrossPathsShowcaseEligibilityDocument",
    source: "firestore/cross_paths_showcase_eligibility.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "crossPathsShowcaseEligibilityDocument.ts",
  },
  {
    name: "CrossPathsSuggestionExposureDocument",
    source: "firestore/cross_paths_suggestion_exposures.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "crossPathsSuggestionExposureDocument.ts",
  },
  {
    name: "CrossPathsInvitationDocument",
    source: "firestore/cross_paths_invitations.schema.json",
    typeOutput:
      "functions/src/shared/generated/crossPathsInvitationDocument.ts",
  },
  {
    name: "CrossPathsPairHoldDocument",
    source: "firestore/cross_paths_pair_holds.schema.json",
    typeOutput:
      "functions/src/shared/generated/crossPathsPairHoldDocument.ts",
  },
  {
    name: "EventBroadcastDocument",
    source: "firestore/event_broadcasts.schema.json",
    typeOutput: "functions/src/shared/generated/eventBroadcastDocument.ts",
  },
  {
    name: "EventWaitlistOfferDocument",
    source: "firestore/event_waitlist_offers.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventWaitlistOfferDocument.ts",
  },
  {
    name: "EventSuccessPlanDocument",
    source: "firestore/event_success_plans.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessPlanDocument.ts",
  },
  {
    name: "EventSuccessConversationGraphDocument",
    source: "firestore/event_success_conversation_graphs.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "eventSuccessConversationGraphDocument.ts",
  },
  {
    name: "OrganizerEventSuccessLayoutDocument",
    source: "firestore/organizer_event_success_layouts.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "organizerEventSuccessLayoutDocument.ts",
  },
  {
    name: "EventSuccessAssignmentDraftDocument",
    source: "firestore/event_success_assignment_drafts.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "eventSuccessAssignmentDraftDocument.ts",
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
    name: "EventSuccessUnitOutcomesDocument",
    source: "firestore/event_success_unit_outcomes.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessUnitOutcomesDocument.ts",
  },
  {
    name: "EventSuccessStandingsDocument",
    source: "firestore/event_success_standings.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessStandingsDocument.ts",
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
    name: "HostAnalyticsEvent",
    source: "bigquery/host_analytics_event.schema.json",
    typeOutput: "functions/src/shared/generated/hostAnalyticsEvent.ts",
  },
  {
    name: "UserProfileExposureEvent",
    source: "bigquery/user_profile_exposure_event.schema.json",
    typeOutput: "functions/src/shared/generated/userProfileExposureEvent.ts",
  },
  {
    name: "PaymentDocument",
    source: "firestore/payments.schema.json",
    typeOutput: "functions/src/shared/generated/paymentDocument.ts",
  },
  {
    name: "HostPaymentAccountDocument",
    source: "firestore/host_payment_accounts.schema.json",
    typeOutput: "functions/src/shared/generated/hostPaymentAccountDocument.ts",
  },
  {
    name: "RazorpayPendingOrderDocument",
    source: "firestore/razorpay_pending_orders.schema.json",
    typeOutput:
      "functions/src/shared/generated/razorpayPendingOrderDocument.ts",
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
    name: "HostAnalyticsSnapshotDocument",
    source: "firestore/host_analytics_snapshots.schema.json",
    typeOutput:
      "functions/src/shared/generated/hostAnalyticsSnapshotDocument.ts",
  },
  {
    name: "FunctionEventReceiptDocument",
    source: "firestore/function_event_receipts.schema.json",
    typeOutput:
      "functions/src/shared/generated/functionEventReceiptDocument.ts",
  },
  {
    name: "PublicRouteReservationDocument",
    source: "firestore/public_route_reservations.schema.json",
    typeOutput:
      "functions/src/shared/generated/publicRouteReservationDocument.ts",
  },
  {
    name: "SeedEventManifestDocument",
    source: "firestore/seed_events.schema.json",
    typeOutput: "functions/src/shared/generated/seedEventManifestDocument.ts",
  },
  {
    name: "OrganizerIntakeReviewDecisionDocument",
    source: "firestore/organizer_intake_review_decisions.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerIntakeReviewDecisionDocument.ts",
  },
  {
    name: "EventIntakeReviewDecisionDocument",
    source: "firestore/event_intake_review_decisions.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventIntakeReviewDecisionDocument.ts",
  },
  {
    name: "OrganizerIntakeCurationDecisionDocument",
    source: "firestore/organizer_intake_curation_decisions.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerIntakeCurationDecisionDocument.ts",
  },
  {
    name: "OrganizerIntakeFieldCorrectionDocument",
    source: "firestore/organizer_intake_field_corrections.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerIntakeFieldCorrectionDocument.ts",
  },
  {
    name: "OrganizerEventCandidateReviewDecisionDocument",
    source: "firestore/organizer_event_candidate_review_decisions.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerEventCandidateReviewDecisionDocument.ts",
  },
  {
    name: "OrganizerEventLocationResolutionDecisionDocument",
    source:
      "firestore/organizer_event_location_resolution_decisions.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerEventLocationResolutionDecisionDocument.ts",
  },
  {
    name: "OrganizerPolicyGapReviewDecisionDocument",
    source: "firestore/organizer_policy_gap_review_decisions.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerPolicyGapReviewDecisionDocument.ts",
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
    name: "CreateOrganizerCallablePayload",
    source: "callables/create_organizer_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/createOrganizerCallablePayload.ts",
  },
  {
    name: "CreateOrganizerCallableResponse",
    source: "callable_responses/create_organizer_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/createOrganizerCallableResponse.ts",
  },
  {
    name: "UpdateOrganizerCallablePayload",
    source: "callables/update_organizer_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/updateOrganizerCallablePayload.ts",
  },
  {
    name: "ArchiveOrganizerCallablePayload",
    source: "callables/archive_organizer_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/archiveOrganizerCallablePayload.ts",
  },
  {
    name: "DeleteOrganizerCallablePayload",
    source: "callables/delete_organizer_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/deleteOrganizerCallablePayload.ts",
  },
  {
    name: "CreateOrganizerPostCallablePayload",
    source: "callables/create_organizer_post_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/createOrganizerPostCallablePayload.ts",
  },
  {
    name: "CreateOrganizerPostCallableResponse",
    source: "callable_responses/create_organizer_post_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/createOrganizerPostCallableResponse.ts",
  },
  {
    name: "RequestOrganizerClaimCallablePayload",
    source: "callables/request_organizer_claim_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/requestOrganizerClaimCallablePayload.ts",
  },
  {
    name: "RequestOrganizerClaimCallableResponse",
    source: "callable_responses/request_organizer_claim_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/requestOrganizerClaimCallableResponse.ts",
  },
  {
    name: "AdminDecideOrganizerClaimCallablePayload",
    source: "callables/admin_decide_organizer_claim_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminDecideOrganizerClaimCallablePayload.ts",
  },
  {
    name: "CreateClubCallableResponse",
    source: "callable_responses/create_club_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/createClubCallableResponse.ts",
  },
  {
    name: "CreateClubPostCallablePayload",
    source: "callables/create_club_post_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/createClubPostCallablePayload.ts",
  },
  {
    name: "CreateClubPostCallableResponse",
    source: "callable_responses/create_club_post_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/createClubPostCallableResponse.ts",
  },
  {
    name: "SendEventBroadcastCallablePayload",
    source: "callables/send_event_broadcast_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/sendEventBroadcastCallablePayload.ts",
  },
  {
    name: "SendEventBroadcastCallableResponse",
    source: "callable_responses/send_event_broadcast_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/sendEventBroadcastCallableResponse.ts",
  },
  {
    name: "UpdateClubCallablePayload",
    source: "callables/update_club_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/updateClubCallablePayload.ts",
  },
  {
    name: "HostAnalyticsQueryCallablePayload",
    source: "callables/host_analytics_query_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/hostAnalyticsQueryCallablePayload.ts",
  },
  {
    name: "HostAnalyticsCallableResponse",
    source: "callable_responses/host_analytics_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/hostAnalyticsCallableResponse.ts",
  },
  {
    name: "UserAnalyticsQueryCallablePayload",
    source: "callables/user_analytics_query_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/userAnalyticsQueryCallablePayload.ts",
  },
  {
    name: "UserAnalyticsCallableResponse",
    source: "callable_responses/user_analytics_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/userAnalyticsCallableResponse.ts",
  },
  {
    name: "AddClubHostCallablePayload",
    source: "callables/add_club_host_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/addClubHostCallablePayload.ts",
  },
  {
    name: "OrganizerFollowCallablePayload",
    source: "callables/organizer_follow_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerFollowCallablePayload.ts",
  },
  {
    name: "SetOrganizerNotificationPreferenceCallablePayload",
    source:
      "callables/set_organizer_notification_preference_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "setOrganizerNotificationPreferenceCallablePayload.ts",
  },
  {
    name: "AddOrganizerManagerCallablePayload",
    source: "callables/add_organizer_manager_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/addOrganizerManagerCallablePayload.ts",
  },
  {
    name: "RemoveOrganizerManagerCallablePayload",
    source: "callables/remove_organizer_manager_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/removeOrganizerManagerCallablePayload.ts",
  },
  {
    name: "TransferOrganizerOwnershipCallablePayload",
    source: "callables/transfer_organizer_ownership_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "transferOrganizerOwnershipCallablePayload.ts",
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
    name: "RequestClubClaimCallablePayload",
    source: "callables/request_club_claim_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/requestClubClaimCallablePayload.ts",
  },
  {
    name: "RequestClubClaimCallableResponse",
    source: "callable_responses/request_club_claim_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/requestClubClaimCallableResponse.ts",
  },
  {
    name: "AdminDecideClubClaimCallablePayload",
    source: "callables/admin_decide_club_claim_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminDecideClubClaimCallablePayload.ts",
  },
  {
    name: "AdminDecideOrganizerIntakeCallablePayload",
    source: "callables/admin_decide_organizer_intake_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminDecideOrganizerIntakeCallablePayload.ts",
  },
  {
    name: "AdminRecordOrganizerCurationCallablePayload",
    source: "callables/admin_record_organizer_curation_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminRecordOrganizerCurationCallablePayload.ts",
  },
  {
    name: "AdminRecordEventIntakeReviewDecisionCallablePayload",
    source:
      "callables/admin_record_event_intake_review_decision_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminRecordEventIntakeReviewDecisionCallablePayload.ts",
  },
  {
    name: "AdminListIntakeOperationsCallablePayload",
    source: "callables/admin_list_intake_operations_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminListIntakeOperationsCallablePayload.ts",
  },
  {
    name: "AdminListActionExecutionsCallablePayload",
    source: "callables/admin_list_action_executions_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminListActionExecutionsCallablePayload.ts",
  },
  {
    name: "AdminRecordActionExecutionCallablePayload",
    source: "callables/admin_record_action_execution_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminRecordActionExecutionCallablePayload.ts",
  },
  {
    name: "AdminDecideOrganizerEventCandidateCallablePayload",
    source: "callables/admin_decide_organizer_event_candidate_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminDecideOrganizerEventCandidateCallablePayload.ts",
  },
  {
    name: "AdminDecideOrganizerPolicyGapCallablePayload",
    source: "callables/admin_decide_organizer_policy_gap_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminDecideOrganizerPolicyGapCallablePayload.ts",
  },
  {
    name: "AdminResolveOrganizerEventLocationCallablePayload",
    source:
      "callables/admin_resolve_organizer_event_location_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminResolveOrganizerEventLocationCallablePayload.ts",
  },
  {
    name: "AdminSetClubIndexStatusCallablePayload",
    source: "callables/admin_set_club_index_status_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminSetClubIndexStatusCallablePayload.ts",
  },
  {
    name: "AdminListCrossPathsShowcaseCandidatesCallablePayload",
    source:
      "callables/" +
      "admin_list_cross_paths_showcase_candidates_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminListCrossPathsShowcaseCandidatesCallablePayload.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/" +
      "adminListCrossPathsShowcaseCandidatesCallablePayload.ts",
    ],
  },
  {
    name: "AdminSetCrossPathsShowcaseEligibilityCallablePayload",
    source:
      "callables/" +
      "admin_set_cross_paths_showcase_eligibility_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminSetCrossPathsShowcaseEligibilityCallablePayload.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/" +
      "adminSetCrossPathsShowcaseEligibilityCallablePayload.ts",
    ],
  },
  {
    name: "AdminGetClubDetailsCallablePayload",
    source: "callables/admin_get_club_details_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminGetClubDetailsCallablePayload.ts",
  },
  {
    name: "AdminListClubDetailsCallablePayload",
    source: "callables/admin_list_club_details_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminListClubDetailsCallablePayload.ts",
  },
  {
    name: "AdminUpdateClubDetailsCallablePayload",
    source: "callables/admin_update_club_details_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminUpdateClubDetailsCallablePayload.ts",
  },
  {
    name: "AdminGetOrganizerDetailsCallablePayload",
    source: "callables/admin_get_organizer_details_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminGetOrganizerDetailsCallablePayload.ts",
  },
  {
    name: "AdminListOrganizerDetailsCallablePayload",
    source: "callables/admin_list_organizer_details_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminListOrganizerDetailsCallablePayload.ts",
  },
  {
    name: "AdminUpdateOrganizerDetailsCallablePayload",
    source: "callables/admin_update_organizer_details_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminUpdateOrganizerDetailsCallablePayload.ts",
  },
  {
    name: "AdminGetEventDetailsCallablePayload",
    source: "callables/admin_get_event_details_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminGetEventDetailsCallablePayload.ts",
  },
  {
    name: "AdminListEventDetailsCallablePayload",
    source: "callables/admin_list_event_details_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminListEventDetailsCallablePayload.ts",
  },
  {
    name: "AdminListExternalEventDetailsCallablePayload",
    source:
      "callables/admin_list_external_event_details_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminListExternalEventDetailsCallablePayload.ts",
  },
  {
    name: "AdminUpdateEventDetailsCallablePayload",
    source: "callables/admin_update_event_details_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminUpdateEventDetailsCallablePayload.ts",
  },
  {
    name: "AdminPublishExternalEventCallablePayload",
    source: "callables/admin_publish_external_event_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminPublishExternalEventCallablePayload.ts",
  },
  {
    name: "AdminTakedownExternalEventCallablePayload",
    source: "callables/admin_takedown_external_event_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminTakedownExternalEventCallablePayload.ts",
  },
  {
    name: "StartClubHostConversationCallablePayload",
    source: "callables/start_club_host_conversation_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/startClubHostConversationCallablePayload.ts",
  },
  {
    name: "StartOrganizerConversationCallablePayload",
    source: "callables/start_organizer_conversation_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "startOrganizerConversationCallablePayload.ts",
  },
  {
    name: "StartOrganizerContactConversationCallablePayload",
    source:
      "callables/start_organizer_contact_conversation_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "startOrganizerContactConversationCallablePayload.ts",
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
    name: "SetCrossPathsEventConsentCallablePayload",
    source:
      "callables/set_cross_paths_event_consent_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "setCrossPathsEventConsentCallablePayload.ts",
  },
  {
    name: "GetCrossPathsSuggestionsCallablePayload",
    source: "callables/get_cross_paths_suggestions_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "getCrossPathsSuggestionsCallablePayload.ts",
  },
  {
    name: "SendCrossPathsInvitationCallablePayload",
    source: "callables/send_cross_paths_invitation_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "sendCrossPathsInvitationCallablePayload.ts",
  },
  {
    name: "RespondCrossPathsInvitationCallablePayload",
    source: "callables/respond_cross_paths_invitation_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "respondCrossPathsInvitationCallablePayload.ts",
  },
  {
    name: "CancelCrossPathsInvitationOrPlanCallablePayload",
    source:
      "callables/cancel_cross_paths_invitation_or_plan_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "cancelCrossPathsInvitationOrPlanCallablePayload.ts",
  },
  {
    name: "CreateEventWaitlistOffersCallablePayload",
    source: "callables/create_event_waitlist_offers_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "createEventWaitlistOffersCallablePayload.ts",
  },
  {
    name: "CreateEventInviteLinkCallablePayload",
    source: "callables/create_event_invite_link_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "createEventInviteLinkCallablePayload.ts",
  },
  {
    name: "DisableEventInviteLinkCallablePayload",
    source: "callables/disable_event_invite_link_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "disableEventInviteLinkCallablePayload.ts",
  },
  {
    name: "RecordEventInviteLinkOpenCallablePayload",
    source: "callables/record_event_invite_link_open_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "recordEventInviteLinkOpenCallablePayload.ts",
  },
  {
    name: "ResolveEventInviteLandingCallablePayload",
    source: "callables/resolve_event_invite_landing_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "resolveEventInviteLandingCallablePayload.ts",
  },
  {
    name: "ResolveEventInviteLandingCallableResponse",
    source:
      "callable_responses/resolve_event_invite_landing_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "resolveEventInviteLandingCallableResponse.ts",
  },
  {
    name: "GetEventInviteLinkTokenCallablePayload",
    source: "callables/get_event_invite_link_token_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "getEventInviteLinkTokenCallablePayload.ts",
  },
  {
    name: "RecordEventShareIntentCallablePayload",
    source: "callables/record_event_share_intent_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/recordEventShareIntentCallablePayload.ts",
  },
  {
    name: "UpsertOrganizerCampaignCallablePayload",
    source: "callables/upsert_organizer_campaign_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/upsertOrganizerCampaignCallablePayload.ts",
  },
  {
    name: "OrganizerCampaignActionCallablePayload",
    source: "callables/organizer_campaign_action_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerCampaignActionCallablePayload.ts",
  },
  {
    name: "CompleteOrganizerWhatsappConnectionCallablePayload",
    source:
      "callables/complete_organizer_whatsapp_connection_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "completeOrganizerWhatsappConnectionCallablePayload.ts",
  },
  {
    name: "OrganizerSenderConnectionActionCallablePayload",
    source:
      "callables/organizer_sender_connection_action_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "organizerSenderConnectionActionCallablePayload.ts",
  },
  {
    name: "SendOrganizerWhatsappTestCallablePayload",
    source: "callables/send_organizer_whatsapp_test_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/sendOrganizerWhatsappTestCallablePayload.ts",
  },
  {
    name: "OrganizerCampaignCallableResponse",
    source: "callable_responses/organizer_campaign_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerCampaignCallableResponse.ts",
  },
  {
    name: "ListOrganizerCampaignsCallablePayload",
    source: "callables/list_organizer_campaigns_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/listOrganizerCampaignsCallablePayload.ts",
  },
  {
    name: "ListOrganizerCampaignsCallableResponse",
    source: "callable_responses/list_organizer_campaigns_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/listOrganizerCampaignsCallableResponse.ts",
  },
  {
    name: "OrganizerMessagingSetupCallableResponse",
    source:
      "callable_responses/organizer_messaging_setup_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/organizerMessagingSetupCallableResponse.ts",
  },
  {
    name: "GetOrganizerProviderSetupCallablePayload",
    source: "callables/get_organizer_provider_setup_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "getOrganizerProviderSetupCallablePayload.ts",
  },
  {
    name: "ConnectOrganizerLumaProviderCallablePayload",
    source: "callables/connect_organizer_luma_provider_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "connectOrganizerLumaProviderCallablePayload.ts",
  },
  {
    name: "ListOrganizerLumaEventsCallablePayload",
    source: "callables/list_organizer_luma_events_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "listOrganizerLumaEventsCallablePayload.ts",
  },
  {
    name: "SyncOrganizerProviderEventCallablePayload",
    source: "callables/sync_organizer_provider_event_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "syncOrganizerProviderEventCallablePayload.ts",
  },
  {
    name: "DisconnectOrganizerProviderCallablePayload",
    source: "callables/disconnect_organizer_provider_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "disconnectOrganizerProviderCallablePayload.ts",
  },
  {
    name: "OrganizerProviderSetupCallableResponse",
    source:
      "callable_responses/organizer_provider_setup_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "organizerProviderSetupCallableResponse.ts",
  },
  {
    name: "ListOrganizerLumaEventsCallableResponse",
    source:
      "callable_responses/list_organizer_luma_events_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "listOrganizerLumaEventsCallableResponse.ts",
  },
  {
    name: "SyncOrganizerProviderEventCallableResponse",
    source:
      "callable_responses/sync_organizer_provider_event_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "syncOrganizerProviderEventCallableResponse.ts",
  },
  {
    name: "RecordOrganizerAnalyticsEventCallablePayload",
    source:
      "callables/record_organizer_analytics_event_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "recordOrganizerAnalyticsEventCallablePayload.ts",
  },
  {
    name: "RecordOrganizerAnalyticsEventCallableResponse",
    source:
      "callable_responses/record_organizer_analytics_event_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "recordOrganizerAnalyticsEventCallableResponse.ts",
  },
  {
    name: "MarkEventAttendanceCallablePayload",
    source: "callables/mark_event_attendance_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/markEventAttendanceCallablePayload.ts",
  },
  {
    name: "ImportEventAttendeesCallablePayload",
    source: "callables/import_event_attendees_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/importEventAttendeesCallablePayload.ts",
  },
  {
    name: "MarkEventAttendeeAttendanceCallablePayload",
    source:
      "callables/mark_event_attendee_attendance_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "markEventAttendeeAttendanceCallablePayload.ts",
  },
  {
    name: "SetEventAttendeeAttendanceCallablePayload",
    source:
      "callables/set_event_attendee_attendance_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "setEventAttendeeAttendanceCallablePayload.ts",
  },
  {
    name: "SetEventAttendeeAttendanceCallableResponse",
    source:
      "callable_responses/set_event_attendee_attendance_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "setEventAttendeeAttendanceCallableResponse.ts",
  },
  {
    name: "EventOperatorAccessCallablePayload",
    source: "callables/event_operator_access_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventOperatorAccessCallablePayload.ts",
  },
  {
    name: "EventOperatorAccessCallableResponse",
    source: "callable_responses/event_operator_access_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventOperatorAccessCallableResponse.ts",
  },
  {
    name: "GrantEventStaffCallablePayload",
    source: "callables/grant_event_staff_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/grantEventStaffCallablePayload.ts",
  },
  {
    name: "RevokeEventStaffCallablePayload",
    source: "callables/revoke_event_staff_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/revokeEventStaffCallablePayload.ts",
  },
  {
    name: "EventStaffListCallableResponse",
    source: "callable_responses/event_staff_list_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventStaffListCallableResponse.ts",
  },
  {
    name: "RegisterPublicEventCallablePayload",
    source: "callables/register_public_event_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/registerPublicEventCallablePayload.ts",
  },
  {
    name: "RegisterPublicEventCallableResponse",
    source: "callable_responses/register_public_event_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/registerPublicEventCallableResponse.ts",
  },
  {
    name: "GetEventRuntimeBootstrapCallablePayload",
    source: "callables/get_event_runtime_bootstrap_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/getEventRuntimeBootstrapCallablePayload.ts",
  },
  {
    name: "CreateEventRehearsalCallablePayload",
    source: "callables/create_event_rehearsal_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/createEventRehearsalCallablePayload.ts",
  },
  {
    name: "CreateEventRehearsalCallableResponse",
    source: "callable_responses/create_event_rehearsal_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/createEventRehearsalCallableResponse.ts",
  },
  {
    name: "GetEventRehearsalBootstrapCallablePayload",
    source: "callables/get_event_rehearsal_bootstrap_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/getEventRehearsalBootstrapCallablePayload.ts",
  },
  {
    name: "EventRehearsalBootstrapCallableResponse",
    source:
      "callable_responses/event_rehearsal_bootstrap_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventRehearsalBootstrapCallableResponse.ts",
  },
  {
    name: "UpdateEventRehearsalSetupCallablePayload",
    source: "callables/update_event_rehearsal_setup_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/updateEventRehearsalSetupCallablePayload.ts",
  },
  {
    name: "ControlEventRehearsalCallablePayload",
    source: "callables/control_event_rehearsal_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/controlEventRehearsalCallablePayload.ts",
  },
  {
    name: "InjectEventRehearsalBehaviorCallablePayload",
    source:
      "callables/inject_event_rehearsal_behavior_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/injectEventRehearsalBehaviorCallablePayload.ts",
  },
  {
    name: "ControlEventRehearsalSpatialCallablePayload",
    source:
      "callables/control_event_rehearsal_spatial_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/controlEventRehearsalSpatialCallablePayload.ts",
  },
  {
    name: "ResetEventRehearsalCallablePayload",
    source: "callables/reset_event_rehearsal_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/resetEventRehearsalCallablePayload.ts",
  },
  {
    name: "RotateEventRehearsalGuestLinkCallablePayload",
    source:
      "callables/rotate_event_rehearsal_guest_link_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/rotateEventRehearsalGuestLinkCallablePayload.ts",
  },
  {
    name: "GetEventRehearsalGuestBootstrapCallablePayload",
    source:
      "callables/get_event_rehearsal_guest_bootstrap_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/getEventRehearsalGuestBootstrapCallablePayload.ts",
    additionalTypeOutputs: [
      "website/src/shared/contracts/generated/" +
      "getEventRehearsalGuestBootstrapCallablePayload.ts",
    ],
  },
  {
    name: "EventRehearsalGuestBootstrapCallableResponse",
    source:
      "callable_responses/event_rehearsal_guest_bootstrap_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventRehearsalGuestBootstrapCallableResponse.ts",
    additionalTypeOutputs: [
      "website/src/shared/contracts/generated/" +
      "eventRehearsalGuestBootstrapCallableResponse.ts",
    ],
  },
  {
    name: "SubmitEventRehearsalGuestActionCallablePayload",
    source:
      "callables/submit_event_rehearsal_guest_action_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/submitEventRehearsalGuestActionCallablePayload.ts",
    additionalTypeOutputs: [
      "website/src/shared/contracts/generated/" +
      "submitEventRehearsalGuestActionCallablePayload.ts",
    ],
  },
  {
    name: "EventRehearsalReproductionCallableResponse",
    source:
      "callable_responses/event_rehearsal_reproduction_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventRehearsalReproductionCallableResponse.ts",
  },
  {
    name: "UpsertEventSuccessLayoutCallablePayload",
    source: "callables/upsert_event_success_layout_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "upsertEventSuccessLayoutCallablePayload.ts",
  },
  {
    name: "UpsertEventSuccessLayoutCallableResponse",
    source:
      "callable_responses/upsert_event_success_layout_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "upsertEventSuccessLayoutCallableResponse.ts",
  },
  {
    name: "GetEventSuccessSpatialLayoutCallablePayload",
    source:
      "callables/get_event_success_spatial_layout_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "getEventSuccessSpatialLayoutCallablePayload.ts",
  },
  {
    name: "GetEventSuccessSpatialLayoutCallableResponse",
    source:
      "callable_responses/" +
      "get_event_success_spatial_layout_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "getEventSuccessSpatialLayoutCallableResponse.ts",
  },
  {
    name: "EventSuccessSpatialActionCallablePayload",
    source: "callables/event_success_spatial_action_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "eventSuccessSpatialActionCallablePayload.ts",
  },
  {
    name: "EventSuccessSpatialActionCallableResponse",
    source:
      "callable_responses/event_success_spatial_action_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "eventSuccessSpatialActionCallableResponse.ts",
  },
  {
    name: "GetEventRuntimeBootstrapCallableResponse",
    source:
      "callable_responses/get_event_runtime_bootstrap_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/getEventRuntimeBootstrapCallableResponse.ts",
  },
  {
    name: "GetEventSuccessConversationGraphCallableResponse",
    source:
      "callable_responses/" +
      "get_event_success_conversation_graph_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "getEventSuccessConversationGraphCallableResponse.ts",
  },
  {
    name: "SubmitEventSuccessConversationGraphCallablePayload",
    source:
      "callables/submit_event_success_conversation_graph_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "submitEventSuccessConversationGraphCallablePayload.ts",
  },
  {
    name: "SubmitEventSuccessConversationGraphCallableResponse",
    source:
      "callable_responses/" +
      "submit_event_success_conversation_graph_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "submitEventSuccessConversationGraphCallableResponse.ts",
  },
  {
    name: "ClaimEventRuntimeAccessCallablePayload",
    source: "callables/claim_event_runtime_access_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/claimEventRuntimeAccessCallablePayload.ts",
  },
  {
    name: "ClaimEventRuntimeAccessCallableResponse",
    source:
      "callable_responses/claim_event_runtime_access_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/claimEventRuntimeAccessCallableResponse.ts",
  },
  {
    name: "SubmitEventRuntimeProfileCallablePayload",
    source: "callables/submit_event_runtime_profile_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/submitEventRuntimeProfileCallablePayload.ts",
  },
  {
    name: "SubmitEventRuntimeProfileCallableResponse",
    source:
      "callable_responses/submit_event_runtime_profile_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/submitEventRuntimeProfileCallableResponse.ts",
  },
  {
    name: "CheckInEventRuntimeCallablePayload",
    source: "callables/check_in_event_runtime_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/checkInEventRuntimeCallablePayload.ts",
  },
  {
    name: "CheckInEventRuntimeCallableResponse",
    source:
      "callable_responses/check_in_event_runtime_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/checkInEventRuntimeCallableResponse.ts",
  },
  {
    name: "CreateEventVenueSessionCallablePayload",
    source: "callables/create_event_venue_session_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/createEventVenueSessionCallablePayload.ts",
  },
  {
    name: "CreateEventVenueSessionCallableResponse",
    source:
      "callable_responses/create_event_venue_session_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/createEventVenueSessionCallableResponse.ts",
  },
  {
    name: "ApproveEventRuntimeClaimCallablePayload",
    source: "callables/approve_event_runtime_claim_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/approveEventRuntimeClaimCallablePayload.ts",
  },
  {
    name: "ApproveEventRuntimeClaimCallableResponse",
    source:
      "callable_responses/approve_event_runtime_claim_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/approveEventRuntimeClaimCallableResponse.ts",
  },
  {
    name: "CreateEventRosterHandoffCallablePayload",
    source: "callables/create_event_roster_handoff_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/createEventRosterHandoffCallablePayload.ts",
  },
  {
    name: "CreateEventRosterHandoffCallableResponse",
    source:
      "callable_responses/create_event_roster_handoff_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/createEventRosterHandoffCallableResponse.ts",
  },
  {
    name: "GetOrganizerCrmSummaryCallablePayload",
    source: "callables/get_organizer_crm_summary_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/getOrganizerCrmSummaryCallablePayload.ts",
  },
  {
    name: "GetEventRosterInsightsCallablePayload",
    source: "callables/get_event_roster_insights_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/getEventRosterInsightsCallablePayload.ts",
  },
  {
    name: "GetEventRosterInsightsCallableResponse",
    source:
      "callable_responses/get_event_roster_insights_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/getEventRosterInsightsCallableResponse.ts",
  },
  {
    name: "GetOrganizerCrmSummaryCallableResponse",
    source:
      "callable_responses/get_organizer_crm_summary_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/getOrganizerCrmSummaryCallableResponse.ts",
  },
  {
    name: "ListOrganizerContactsCallablePayload",
    source: "callables/list_organizer_contacts_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/listOrganizerContactsCallablePayload.ts",
  },
  {
    name: "CreateOrganizerFormCallablePayload",
    source: "callables/create_organizer_form_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/createOrganizerFormCallablePayload.ts",
  },
  {
    name: "CreateOrganizerFormCallableResponse",
    source: "callable_responses/create_organizer_form_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/createOrganizerFormCallableResponse.ts",
  },
  {
    name: "UpdateOrganizerFormDraftCallablePayload",
    source: "callables/update_organizer_form_draft_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "updateOrganizerFormDraftCallablePayload.ts",
  },
  {
    name: "UpdateOrganizerFormDraftCallableResponse",
    source:
      "callable_responses/update_organizer_form_draft_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "updateOrganizerFormDraftCallableResponse.ts",
  },
  {
    name: "GetOrganizerFormEditorCallablePayload",
    source: "callables/get_organizer_form_editor_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/getOrganizerFormEditorCallablePayload.ts",
  },
  {
    name: "GetOrganizerFormEditorCallableResponse",
    source:
      "callable_responses/get_organizer_form_editor_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "getOrganizerFormEditorCallableResponse.ts",
  },
  {
    name: "ListOrganizerFormsCallablePayload",
    source: "callables/list_organizer_forms_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/listOrganizerFormsCallablePayload.ts",
  },
  {
    name: "ListOrganizerFormsCallableResponse",
    source: "callable_responses/list_organizer_forms_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/listOrganizerFormsCallableResponse.ts",
  },
  {
    name: "ValidateOrganizerFormDraftCallablePayload",
    source: "callables/validate_organizer_form_draft_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "validateOrganizerFormDraftCallablePayload.ts",
  },
  {
    name: "ValidateOrganizerFormDraftCallableResponse",
    source:
      "callable_responses/validate_organizer_form_draft_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "validateOrganizerFormDraftCallableResponse.ts",
  },
  {
    name: "PublishOrganizerFormCallablePayload",
    source: "callables/publish_organizer_form_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/publishOrganizerFormCallablePayload.ts",
  },
  {
    name: "PublishOrganizerFormCallableResponse",
    source: "callable_responses/publish_organizer_form_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/publishOrganizerFormCallableResponse.ts",
  },
  {
    name: "SetOrganizerFormLifecycleCallablePayload",
    source: "callables/set_organizer_form_lifecycle_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "setOrganizerFormLifecycleCallablePayload.ts",
  },
  {
    name: "SetOrganizerFormLifecycleCallableResponse",
    source:
      "callable_responses/set_organizer_form_lifecycle_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "setOrganizerFormLifecycleCallableResponse.ts",
  },
  {
    name: "DuplicateOrganizerFormCallablePayload",
    source: "callables/duplicate_organizer_form_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/duplicateOrganizerFormCallablePayload.ts",
  },
  {
    name: "DuplicateOrganizerFormCallableResponse",
    source: "callable_responses/duplicate_organizer_form_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/duplicateOrganizerFormCallableResponse.ts",
  },
  {
    name: "DeleteOrganizerFormDraftCallablePayload",
    source: "callables/delete_organizer_form_draft_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "deleteOrganizerFormDraftCallablePayload.ts",
  },
  {
    name: "DeleteOrganizerFormDraftCallableResponse",
    source:
      "callable_responses/delete_organizer_form_draft_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "deleteOrganizerFormDraftCallableResponse.ts",
  },
  {
    name: "ListOrganizerFormTemplatesCallablePayload",
    source: "callables/list_organizer_form_templates_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "listOrganizerFormTemplatesCallablePayload.ts",
  },
  {
    name: "ListOrganizerFormTemplatesCallableResponse",
    source:
      "callable_responses/list_organizer_form_templates_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "listOrganizerFormTemplatesCallableResponse.ts",
  },
  {
    name: "GetPublicOrganizerFormCallablePayload",
    source: "callables/get_public_organizer_form_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/getPublicOrganizerFormCallablePayload.ts",
  },
  {
    name: "GetPublicOrganizerFormCallableResponse",
    source:
      "callable_responses/get_public_organizer_form_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/getPublicOrganizerFormCallableResponse.ts",
  },
  {
    name: "BeginOrganizerFormResponseCallablePayload",
    source:
      "callables/begin_organizer_form_response_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "beginOrganizerFormResponseCallablePayload.ts",
  },
  {
    name: "BeginOrganizerFormResponseCallableResponse",
    source:
      "callable_responses/" +
      "begin_organizer_form_response_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "beginOrganizerFormResponseCallableResponse.ts",
  },
  {
    name: "SaveOrganizerFormResponseDraftCallablePayload",
    source:
      "callables/save_organizer_form_response_draft_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "saveOrganizerFormResponseDraftCallablePayload.ts",
  },
  {
    name: "SaveOrganizerFormResponseDraftCallableResponse",
    source:
      "callable_responses/" +
      "save_organizer_form_response_draft_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "saveOrganizerFormResponseDraftCallableResponse.ts",
  },
  {
    name: "CreateOrganizerFormAssetIntentCallablePayload",
    source:
      "callables/create_organizer_form_asset_intent_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "createOrganizerFormAssetIntentCallablePayload.ts",
  },
  {
    name: "CreateOrganizerFormAssetIntentCallableResponse",
    source:
      "callable_responses/" +
      "create_organizer_form_asset_intent_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "createOrganizerFormAssetIntentCallableResponse.ts",
  },
  {
    name: "FinalizeOrganizerFormAssetCallablePayload",
    source: "callables/finalize_organizer_form_asset_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "finalizeOrganizerFormAssetCallablePayload.ts",
  },
  {
    name: "FinalizeOrganizerFormAssetCallableResponse",
    source:
      "callable_responses/finalize_organizer_form_asset_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "finalizeOrganizerFormAssetCallableResponse.ts",
  },
  {
    name: "SubmitOrganizerFormResponseCallablePayload",
    source: "callables/submit_organizer_form_response_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "submitOrganizerFormResponseCallablePayload.ts",
  },
  {
    name: "SubmitOrganizerFormResponseCallableResponse",
    source:
      "callable_responses/" +
      "submit_organizer_form_response_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "submitOrganizerFormResponseCallableResponse.ts",
  },
  {
    name: "WithdrawOrganizerFormResponseCallablePayload",
    source:
      "callables/withdraw_organizer_form_response_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "withdrawOrganizerFormResponseCallablePayload.ts",
  },
  {
    name: "WithdrawOrganizerFormResponseCallableResponse",
    source:
      "callable_responses/" +
      "withdraw_organizer_form_response_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "withdrawOrganizerFormResponseCallableResponse.ts",
  },
  {
    name: "CreateOrganizerFormShareLinkCallablePayload",
    source:
      "callables/create_organizer_form_share_link_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "createOrganizerFormShareLinkCallablePayload.ts",
  },
  {
    name: "CreateOrganizerFormShareLinkCallableResponse",
    source:
      "callable_responses/" +
      "create_organizer_form_share_link_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "createOrganizerFormShareLinkCallableResponse.ts",
  },
  {
    name: "GetOrganizerFormShareAssetsCallablePayload",
    source:
      "callables/get_organizer_form_share_assets_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "getOrganizerFormShareAssetsCallablePayload.ts",
  },
  {
    name: "GetOrganizerFormShareAssetsCallableResponse",
    source:
      "callable_responses/" +
      "get_organizer_form_share_assets_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "getOrganizerFormShareAssetsCallableResponse.ts",
  },
  {
    name: "ListOrganizerFormResponsesCallablePayload",
    source: "callables/list_organizer_form_responses_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/listOrganizerFormResponsesCallablePayload.ts",
  },
  {
    name: "ListOrganizerFormResponsesCallableResponse",
    source:
      "callable_responses/list_organizer_form_responses_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/listOrganizerFormResponsesCallableResponse.ts",
  },
  {
    name: "GetOrganizerFormResponseDetailCallablePayload",
    source:
      "callables/get_organizer_form_response_detail_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/getOrganizerFormResponseDetailCallablePayload.ts",
  },
  {
    name: "GetOrganizerFormResponseDetailCallableResponse",
    source:
      "callable_responses/get_organizer_form_response_detail_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/getOrganizerFormResponseDetailCallableResponse.ts",
  },
  {
    name: "GetOrganizerFormAnalyticsCallablePayload",
    source: "callables/get_organizer_form_analytics_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/getOrganizerFormAnalyticsCallablePayload.ts",
  },
  {
    name: "GetOrganizerFormAnalyticsCallableResponse",
    source:
      "callable_responses/get_organizer_form_analytics_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/getOrganizerFormAnalyticsCallableResponse.ts",
  },
  {
    name: "RequestOrganizerFormExportCallablePayload",
    source: "callables/request_organizer_form_export_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/requestOrganizerFormExportCallablePayload.ts",
  },
  {
    name: "RequestOrganizerFormExportCallableResponse",
    source:
      "callable_responses/request_organizer_form_export_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/requestOrganizerFormExportCallableResponse.ts",
  },
  {
    name: "CreateOrganizerFormAutomationCallablePayload",
    source:
      "callables/create_organizer_form_automation_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/createOrganizerFormAutomationCallablePayload.ts",
  },
  {
    name: "CreateOrganizerFormAutomationCallableResponse",
    source:
      "callable_responses/create_organizer_form_automation_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/createOrganizerFormAutomationCallableResponse.ts",
  },
  {
    name: "SetOrganizerFormAutomationStateCallablePayload",
    source:
      "callables/set_organizer_form_automation_state_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/setOrganizerFormAutomationStateCallablePayload.ts",
  },
  {
    name: "SetOrganizerFormAutomationStateCallableResponse",
    source:
      "callable_responses/set_organizer_form_automation_state_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/setOrganizerFormAutomationStateCallableResponse.ts",
  },
  {
    name: "ListOrganizerFormAutomationRunsCallablePayload",
    source:
      "callables/list_organizer_form_automation_runs_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/listOrganizerFormAutomationRunsCallablePayload.ts",
  },
  {
    name: "ListOrganizerFormAutomationRunsCallableResponse",
    source:
      "callable_responses/list_organizer_form_automation_runs_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/listOrganizerFormAutomationRunsCallableResponse.ts",
  },
  {
    name: "PreviewOrganizerFormConversionCallablePayload",
    source:
      "callables/preview_organizer_form_conversion_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/previewOrganizerFormConversionCallablePayload.ts",
  },
  {
    name: "PreviewOrganizerFormConversionCallableResponse",
    source:
      "callable_responses/preview_organizer_form_conversion_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/previewOrganizerFormConversionCallableResponse.ts",
  },
  {
    name: "ConvertOrganizerFormResponseCallablePayload",
    source:
      "callables/convert_organizer_form_response_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/convertOrganizerFormResponseCallablePayload.ts",
  },
  {
    name: "ConvertOrganizerFormResponseCallableResponse",
    source:
      "callable_responses/convert_organizer_form_response_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/convertOrganizerFormResponseCallableResponse.ts",
  },
  {
    name: "PublishOrganizerApplicationFormCallablePayload",
    source:
      "callables/publish_organizer_application_form_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "publishOrganizerApplicationFormCallablePayload.ts",
  },
  {
    name: "GetParticipantOrganizerApplicationFormCallablePayload",
    source:
      "callables/get_participant_organizer_application_form_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "getParticipantOrganizerApplicationFormCallablePayload.ts",
  },
  {
    name: "GetParticipantOrganizerApplicationFormCallableResponse",
    source:
      "callable_responses/" +
      "get_participant_organizer_application_form_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "getParticipantOrganizerApplicationFormCallableResponse.ts",
  },
  {
    name: "SubmitParticipantOrganizerApplicationCallablePayload",
    source:
      "callables/submit_participant_organizer_application_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "submitParticipantOrganizerApplicationCallablePayload.ts",
  },
  {
    name: "SubmitParticipantOrganizerApplicationCallableResponse",
    source:
      "callable_responses/" +
      "submit_participant_organizer_application_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "submitParticipantOrganizerApplicationCallableResponse.ts",
  },
  {
    name: "RevokeParticipantOrganizerDataGrantCallablePayload",
    source:
      "callables/revoke_participant_organizer_data_grant_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "revokeParticipantOrganizerDataGrantCallablePayload.ts",
  },
  {
    name: "RevokeParticipantOrganizerDataGrantCallableResponse",
    source:
      "callable_responses/" +
      "revoke_participant_organizer_data_grant_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "revokeParticipantOrganizerDataGrantCallableResponse.ts",
  },
  {
    name: "PublishOrganizerApplicationFormCallableResponse",
    source:
      "callable_responses/" +
      "publish_organizer_application_form_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "publishOrganizerApplicationFormCallableResponse.ts",
  },
  {
    name: "PreviewOrganizerApplicationImportCallablePayload",
    source:
      "callables/preview_organizer_application_import_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "previewOrganizerApplicationImportCallablePayload.ts",
  },
  {
    name: "PreviewOrganizerApplicationImportCallableResponse",
    source:
      "callable_responses/" +
      "preview_organizer_application_import_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "previewOrganizerApplicationImportCallableResponse.ts",
  },
  {
    name: "ImportOrganizerApplicationsCallablePayload",
    source: "callables/import_organizer_applications_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "importOrganizerApplicationsCallablePayload.ts",
  },
  {
    name: "ImportOrganizerApplicationsCallableResponse",
    source:
      "callable_responses/import_organizer_applications_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "importOrganizerApplicationsCallableResponse.ts",
  },
  {
    name: "ListOrganizerApplicationsCallablePayload",
    source: "callables/list_organizer_applications_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "listOrganizerApplicationsCallablePayload.ts",
  },
  {
    name: "ListOrganizerApplicationsCallableResponse",
    source:
      "callable_responses/list_organizer_applications_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "listOrganizerApplicationsCallableResponse.ts",
  },
  {
    name: "GetOrganizerApplicationDetailCallablePayload",
    source:
      "callables/get_organizer_application_detail_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "getOrganizerApplicationDetailCallablePayload.ts",
  },
  {
    name: "GetOrganizerApplicationDetailCallableResponse",
    source:
      "callable_responses/" +
      "get_organizer_application_detail_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "getOrganizerApplicationDetailCallableResponse.ts",
  },
  {
    name: "ReviewOrganizerApplicationCallablePayload",
    source: "callables/review_organizer_application_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "reviewOrganizerApplicationCallablePayload.ts",
  },
  {
    name: "ReviewOrganizerApplicationCallableResponse",
    source:
      "callable_responses/review_organizer_application_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "reviewOrganizerApplicationCallableResponse.ts",
  },
  {
    name: "CreateOrganizerContactCallablePayload",
    source: "callables/create_organizer_contact_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/createOrganizerContactCallablePayload.ts",
  },
  {
    name: "CreateOrganizerContactCallableResponse",
    source:
      "callable_responses/create_organizer_contact_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/createOrganizerContactCallableResponse.ts",
  },
  {
    name: "ListOrganizerContactsCallableResponse",
    source:
      "callable_responses/list_organizer_contacts_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/listOrganizerContactsCallableResponse.ts",
  },
  {
    name: "GetOrganizerContactDetailCallablePayload",
    source: "callables/get_organizer_contact_detail_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/getOrganizerContactDetailCallablePayload.ts",
  },
  {
    name: "GetOrganizerContactDetailCallableResponse",
    source:
      "callable_responses/get_organizer_contact_detail_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/getOrganizerContactDetailCallableResponse.ts",
  },
  {
    name: "MutateOrganizerContactCallablePayload",
    source: "callables/mutate_organizer_contact_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/mutateOrganizerContactCallablePayload.ts",
  },
  {
    name: "MutateOrganizerContactCallableResponse",
    source: "callable_responses/mutate_organizer_contact_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/mutateOrganizerContactCallableResponse.ts",
  },
  {
    name: "CreateOrganizerContactNoteCallablePayload",
    source: "callables/create_organizer_contact_note_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "createOrganizerContactNoteCallablePayload.ts",
  },
  {
    name: "MutateOrganizerContactNoteCallablePayload",
    source: "callables/mutate_organizer_contact_note_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "mutateOrganizerContactNoteCallablePayload.ts",
  },
  {
    name: "OrganizerContactNoteCallableResponse",
    source:
      "callable_responses/organizer_contact_note_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "organizerContactNoteCallableResponse.ts",
  },
  {
    name: "ExportOrganizerContactsCallablePayload",
    source: "callables/export_organizer_contacts_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/exportOrganizerContactsCallablePayload.ts",
  },
  {
    name: "ExportOrganizerContactsCallableResponse",
    source: "callable_responses/export_organizer_contacts_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/exportOrganizerContactsCallableResponse.ts",
  },
  {
    name: "MergeOrganizerContactsCallablePayload",
    source: "callables/merge_organizer_contacts_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/mergeOrganizerContactsCallablePayload.ts",
  },
  {
    name: "ListOrganizerContactMergeCandidatesCallablePayload",
    source:
      "callables/list_organizer_contact_merge_candidates_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "listOrganizerContactMergeCandidatesCallablePayload.ts",
  },
  {
    name: "ListOrganizerContactMergeCandidatesCallableResponse",
    source:
      "callable_responses/" +
      "list_organizer_contact_merge_candidates_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "listOrganizerContactMergeCandidatesCallableResponse.ts",
  },
  {
    name: "ReviewOrganizerContactMergeCandidateCallablePayload",
    source:
      "callables/review_organizer_contact_merge_candidate_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "reviewOrganizerContactMergeCandidateCallablePayload.ts",
  },
  {
    name: "ReviewOrganizerContactMergeCandidateCallableResponse",
    source:
      "callable_responses/" +
      "review_organizer_contact_merge_candidate_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "reviewOrganizerContactMergeCandidateCallableResponse.ts",
  },
  {
    name: "ListOrganizerWhatsappThreadsCallablePayload",
    source: "callables/list_organizer_whatsapp_threads_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "listOrganizerWhatsappThreadsCallablePayload.ts",
  },
  {
    name: "ListOrganizerWhatsappThreadsCallableResponse",
    source:
      "callable_responses/list_organizer_whatsapp_threads_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "listOrganizerWhatsappThreadsCallableResponse.ts",
  },
  {
    name: "GetOrganizerWhatsappThreadCallablePayload",
    source: "callables/get_organizer_whatsapp_thread_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "getOrganizerWhatsappThreadCallablePayload.ts",
  },
  {
    name: "GetOrganizerWhatsappThreadCallableResponse",
    source:
      "callable_responses/get_organizer_whatsapp_thread_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "getOrganizerWhatsappThreadCallableResponse.ts",
  },
  {
    name: "SendOrganizerWhatsappReplyCallablePayload",
    source: "callables/send_organizer_whatsapp_reply_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "sendOrganizerWhatsappReplyCallablePayload.ts",
  },
  {
    name: "SendOrganizerWhatsappReplyCallableResponse",
    source:
      "callable_responses/send_organizer_whatsapp_reply_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "sendOrganizerWhatsappReplyCallableResponse.ts",
  },
  {
    name: "UnmergeOrganizerContactsCallablePayload",
    source: "callables/unmerge_organizer_contacts_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/unmergeOrganizerContactsCallablePayload.ts",
  },
  {
    name: "MutateOrganizerContactMergeCallableResponse",
    source:
      "callable_responses/mutate_organizer_contact_merge_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "mutateOrganizerContactMergeCallableResponse.ts",
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
    name: "PrepareEventSuccessRotationDraftCallablePayload",
    source:
      "callables/prepare_event_success_rotation_draft_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "prepareEventSuccessRotationDraftCallablePayload.ts",
  },
  {
    name: "PublishEventSuccessRotationRoundCallablePayload",
    source:
      "callables/publish_event_success_rotation_round_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "publishEventSuccessRotationRoundCallablePayload.ts",
  },
  {
    name: "EventSuccessLiveActionCallablePayload",
    source: "callables/event_success_live_action_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "eventSuccessLiveActionCallablePayload.ts",
  },
  {
    name: "SetEventSuccessAccountabilityResolutionCallablePayload",
    source:
      "callables/" +
      "set_event_success_accountability_resolution_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "setEventSuccessAccountabilityResolutionCallablePayload.ts",
  },
  {
    name: "RecordEventSuccessUnitOutcomesCallablePayload",
    source:
      "callables/record_event_success_unit_outcomes_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "recordEventSuccessUnitOutcomesCallablePayload.ts",
  },
  {
    name: "RecordEventSuccessUnitOutcomesCallableResponse",
    source:
      "callable_responses/" +
      "record_event_success_unit_outcomes_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "recordEventSuccessUnitOutcomesCallableResponse.ts",
  },
  {
    name: "HeartbeatEventSuccessPresenceCallablePayload",
    source:
      "callables/heartbeat_event_success_presence_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "heartbeatEventSuccessPresenceCallablePayload.ts",
  },
  {
    name: "HeartbeatEventSuccessPresenceCallableResponse",
    source:
      "callable_responses/" +
      "heartbeat_event_success_presence_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "heartbeatEventSuccessPresenceCallableResponse.ts",
  },
  {
    name: "PublishEventLivePositionCallablePayload",
    source: "callables/publish_event_live_position_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "publishEventLivePositionCallablePayload.ts",
  },
  {
    name: "PublishEventLivePositionCallableResponse",
    source:
      "callable_responses/publish_event_live_position_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "publishEventLivePositionCallableResponse.ts",
  },
  {
    name: "GetEventSuccessPresenceSummaryCallableResponse",
    source:
      "callable_responses/" +
      "get_event_success_presence_summary_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "getEventSuccessPresenceSummaryCallableResponse.ts",
  },
  {
    name: "ResolveEventSuccessLateArrivalCallablePayload",
    source:
      "callables/resolve_event_success_late_arrival_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "resolveEventSuccessLateArrivalCallablePayload.ts",
  },
  {
    name: "ResolveEventSuccessLateArrivalCallableResponse",
    source:
      "callable_responses/" +
      "resolve_event_success_late_arrival_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "resolveEventSuccessLateArrivalCallableResponse.ts",
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
    name: "CreatePublicClubReviewCallablePayload",
    source: "callables/create_public_club_review_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/createPublicClubReviewCallablePayload.ts",
  },
  {
    name: "CreatePublicClubReviewCallableResponse",
    source: "callable_responses/create_public_club_review_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/createPublicClubReviewCallableResponse.ts",
  },
  {
    name: "ListPublicClubReviewsCallablePayload",
    source: "callables/list_public_club_reviews_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/listPublicClubReviewsCallablePayload.ts",
  },
  {
    name: "ListPublicClubReviewsCallableResponse",
    source: "callable_responses/list_public_club_reviews_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/listPublicClubReviewsCallableResponse.ts",
  },
  {
    name: "CreatePublicOrganizerReviewCallablePayload",
    source: "callables/create_public_organizer_review_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/createPublicOrganizerReviewCallablePayload.ts",
  },
  {
    name: "CreatePublicOrganizerReviewCallableResponse",
    source:
      "callable_responses/create_public_organizer_review_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/createPublicOrganizerReviewCallableResponse.ts",
  },
  {
    name: "ListPublicOrganizerReviewsCallablePayload",
    source: "callables/list_public_organizer_reviews_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/listPublicOrganizerReviewsCallablePayload.ts",
  },
  {
    name: "ListPublicOrganizerReviewsCallableResponse",
    source:
      "callable_responses/list_public_organizer_reviews_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/listPublicOrganizerReviewsCallableResponse.ts",
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
    name: "SetReviewResponseCallablePayload",
    source: "callables/set_review_response_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/setReviewResponseCallablePayload.ts",
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
    name: "CreateStripeCheckoutSessionCallablePayload",
    source: "callables/create_stripe_checkout_session_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "createStripeCheckoutSessionCallablePayload.ts",
  },
  {
    name: "StripeCheckoutSessionCallableResponse",
    source: "callable_responses/stripe_checkout_session_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "stripeCheckoutSessionCallableResponse.ts",
  },
  {
    name: "CreateStripeHostOnboardingLinkCallablePayload",
    source: "callables/create_stripe_host_onboarding_link_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "createStripeHostOnboardingLinkCallablePayload.ts",
  },
  {
    name: "RefreshStripeHostPaymentAccountCallablePayload",
    source:
      "callables/refresh_stripe_host_payment_account_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "refreshStripeHostPaymentAccountCallablePayload.ts",
  },
  {
    name: "CreateRazorpayHostPaymentAccountCallablePayload",
    source:
      "callables/create_razorpay_host_payment_account_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "createRazorpayHostPaymentAccountCallablePayload.ts",
  },
  {
    name: "RefreshRazorpayHostPaymentAccountCallablePayload",
    source:
      "callables/refresh_razorpay_host_payment_account_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "refreshRazorpayHostPaymentAccountCallablePayload.ts",
  },
  {
    name: "StripeHostOnboardingLinkCallableResponse",
    source:
      "callable_responses/stripe_host_onboarding_link_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "stripeHostOnboardingLinkCallableResponse.ts",
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
    name: "ExploreSearchCallablePayload",
    source: "callables/explore_search_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/exploreSearchCallablePayload.ts",
  },
  {
    name: "ExploreSearchCallableResponse",
    source: "callable_responses/explore_search_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/exploreSearchCallableResponse.ts",
  },
  {
    name: "WebsiteHostListingProjection",
    source: "public/website_host_listing_projection.schema.json",
    typeOutput:
      "functions/src/shared/generated/websiteHostListingProjection.ts",
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
    name: "FetchSwipeCandidatesCallableResponse",
    source: "callable_responses/fetch_swipe_candidates_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/fetchSwipeCandidatesCallableResponse.ts",
  },
  {
    name: "SetCrossPathsEventConsentCallableResponse",
    source:
      "callable_responses/set_cross_paths_event_consent_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "setCrossPathsEventConsentCallableResponse.ts",
  },
  {
    name: "GetCrossPathsSuggestionsCallableResponse",
    source:
      "callable_responses/get_cross_paths_suggestions_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "getCrossPathsSuggestionsCallableResponse.ts",
  },
  {
    name: "SendCrossPathsInvitationCallableResponse",
    source:
      "callable_responses/send_cross_paths_invitation_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "sendCrossPathsInvitationCallableResponse.ts",
  },
  {
    name: "RespondCrossPathsInvitationCallableResponse",
    source:
      "callable_responses/respond_cross_paths_invitation_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "respondCrossPathsInvitationCallableResponse.ts",
  },
  {
    name: "CancelCrossPathsInvitationOrPlanCallableResponse",
    source:
      "callable_responses/" +
      "cancel_cross_paths_invitation_or_plan_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "cancelCrossPathsInvitationOrPlanCallableResponse.ts",
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
  {
    name: "AdminGetOverviewCallablePayload",
    source: "callables/admin_get_overview_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminGetOverviewCallablePayload.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/adminGetOverviewCallablePayload.ts",
    ],
  },
  {
    name: "AdminGetOverviewCallableResponse",
    source: "callable_responses/admin_get_overview_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminGetOverviewCallableResponse.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/adminGetOverviewCallableResponse.ts",
    ],
  },
  {
    name: "AdminDecideAccessApplicationCallablePayload",
    source:
      "callables/admin_decide_access_application_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminDecideAccessApplicationCallablePayload.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/" +
      "adminDecideAccessApplicationCallablePayload.ts",
    ],
  },
  {
    name: "AdminDecideAccessApplicationCallableResponse",
    source:
      "callable_responses/" +
      "admin_decide_access_application_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminDecideAccessApplicationCallableResponse.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/" +
      "adminDecideAccessApplicationCallableResponse.ts",
    ],
  },
  {
    name: "AdminSetAdminUserRolesCallablePayload",
    source: "callables/admin_set_admin_user_roles_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminSetAdminUserRolesCallablePayload.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/adminSetAdminUserRolesCallablePayload.ts",
    ],
  },
  {
    name: "AdminSetAdminUserRolesCallableResponse",
    source:
      "callable_responses/admin_set_admin_user_roles_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/adminSetAdminUserRolesCallableResponse.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/adminSetAdminUserRolesCallableResponse.ts",
    ],
  },
  {
    name: "AdminDecideSafetyTriageItemCallablePayload",
    source:
      "callables/admin_decide_safety_triage_item_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminDecideSafetyTriageItemCallablePayload.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/" +
      "adminDecideSafetyTriageItemCallablePayload.ts",
    ],
  },
  {
    name: "AdminDecideSafetyTriageItemCallableResponse",
    source:
      "callable_responses/" +
      "admin_decide_safety_triage_item_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminDecideSafetyTriageItemCallableResponse.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/" +
      "adminDecideSafetyTriageItemCallableResponse.ts",
    ],
  },
  {
    name: "AdminAssignSafetyTriageItemCallablePayload",
    source:
      "callables/admin_assign_safety_triage_item_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminAssignSafetyTriageItemCallablePayload.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/" +
      "adminAssignSafetyTriageItemCallablePayload.ts",
    ],
  },
  {
    name: "AdminAssignSafetyTriageItemCallableResponse",
    source:
      "callable_responses/" +
      "admin_assign_safety_triage_item_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminAssignSafetyTriageItemCallableResponse.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/" +
      "adminAssignSafetyTriageItemCallableResponse.ts",
    ],
  },
  {
    name: "AdminCreateOrganizerDraftFromCandidateCallablePayload",
    source:
      "callables/" +
      "admin_create_organizer_draft_from_candidate_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminCreateOrganizerDraftFromCandidateCallablePayload.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/" +
      "adminCreateOrganizerDraftFromCandidateCallablePayload.ts",
    ],
  },
  {
    name: "AdminCreateOrganizerDraftFromCandidateCallableResponse",
    source:
      "callable_responses/" +
      "admin_create_organizer_draft_from_candidate_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminCreateOrganizerDraftFromCandidateCallableResponse.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/" +
      "adminCreateOrganizerDraftFromCandidateCallableResponse.ts",
    ],
  },
  {
    name: "AdminCreateMarketingContentDraftCallablePayload",
    source:
      "callables/admin_create_marketing_content_draft_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminCreateMarketingContentDraftCallablePayload.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/" +
      "adminCreateMarketingContentDraftCallablePayload.ts",
    ],
  },
  {
    name: "AdminCreateMarketingContentDraftCallableResponse",
    source:
      "callable_responses/" +
      "admin_create_marketing_content_draft_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminCreateMarketingContentDraftCallableResponse.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/" +
      "adminCreateMarketingContentDraftCallableResponse.ts",
    ],
  },
  {
    name: "AdminRecordMarketingReviewDecisionCallablePayload",
    source:
      "callables/" +
      "admin_record_marketing_review_decision_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminRecordMarketingReviewDecisionCallablePayload.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/" +
      "adminRecordMarketingReviewDecisionCallablePayload.ts",
    ],
  },
  {
    name: "AdminRecordMarketingReviewDecisionCallableResponse",
    source:
      "callable_responses/" +
      "admin_record_marketing_review_decision_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminRecordMarketingReviewDecisionCallableResponse.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/" +
      "adminRecordMarketingReviewDecisionCallableResponse.ts",
    ],
  },
  {
    name: "AdminListCrossPathsShowcaseCandidatesCallableResponse",
    source:
      "callable_responses/" +
      "admin_list_cross_paths_showcase_candidates_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminListCrossPathsShowcaseCandidatesCallableResponse.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/" +
      "adminListCrossPathsShowcaseCandidatesCallableResponse.ts",
    ],
  },
  {
    name: "AdminSetCrossPathsShowcaseEligibilityCallableResponse",
    source:
      "callable_responses/" +
      "admin_set_cross_paths_showcase_eligibility_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "adminSetCrossPathsShowcaseEligibilityCallableResponse.ts",
    additionalTypeOutputs: [
      "admin/src/generated/contracts/" +
      "adminSetCrossPathsShowcaseEligibilityCallableResponse.ts",
    ],
  },
  {
    name: "JoinWaitlistHTTPRequest",
    source: "http/join_waitlist_request.schema.json",
    typeOutput: "functions/src/shared/generated/joinWaitlistHttpRequest.ts",
    additionalTypeOutputs: [
      "website/src/shared/contracts/generated/joinWaitlistHttpRequest.ts",
    ],
  },
  {
    name: "JoinWaitlistHTTPResponse",
    source: "http/join_waitlist_response.schema.json",
    typeOutput: "functions/src/shared/generated/joinWaitlistHttpResponse.ts",
    additionalTypeOutputs: [
      "website/src/shared/contracts/generated/joinWaitlistHttpResponse.ts",
    ],
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
    name: "UploadedPhoto",
    source: "embedded/uploaded_photo.schema.json",
  },
  {
    name: "ActivityPreferences",
    source: "embedded/activity_preferences.schema.json",
  },
  {
    name: "OrganizerSupplyCapabilities",
    source: "embedded/organizer_supply_capabilities.schema.json",
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
  ["EventDocument.meetingLocation", "EventMeetingLocation"],
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
  const personFieldCatalog = readContractJson("catalogs/person_fields.json");
  const organizerFormTemplateCatalog = readContractJson(
    "catalogs/organizer_form_templates.json"
  );
  assertOrganizerFormTemplateCatalog(organizerFormTemplateCatalog);
  const eventSuccessMomentPresentationCatalog = readContractJson(
    "catalogs/event_success_moment_presentations.json"
  );
  assertEventSuccessMomentPresentationCatalog(
    eventSuccessMomentPresentationCatalog
  );
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
      personFieldCatalog,
      organizerFormTemplateCatalog,
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
      personFieldCatalog,
      organizerFormTemplateCatalog,
      photoCatalog,
      profilePhotoPolicy,
    })
  );
  addTextOutput(
    "tool/contracts/generated/schema_contract_validators.mjs",
    renderToolValidators()
  );
  addTextOutput(
    "website/src/shared/contracts/generated/joinWaitlistSchemas.ts",
    renderWebsiteJoinWaitlistSchemas({
      requestSchema: bundledSchemas.get("JoinWaitlistHTTPRequest"),
      responseSchema: bundledSchemas.get("JoinWaitlistHTTPResponse"),
    })
  );
  addTextOutput(
    "functions/src/shared/generated/eventSuccessMomentPresentations.ts",
    renderTsEventSuccessMomentPresentations(
      eventSuccessMomentPresentationCatalog
    )
  );
  addTextOutput(
    "lib/core/schema_contracts/generated/" +
      "event_success_moment_presentations.g.dart",
    renderDartEventSuccessMomentPresentations(
      eventSuccessMomentPresentationCatalog
    )
  );
  addTextOutput(
    "lib/core/schema_contracts/generated/profile_schema_contracts.g.dart",
    renderDartContracts({
      profileCatalog,
      personFieldCatalog,
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

  addTextOutput(
    "lib/core/schema_contracts/generated/field_constraints.g.dart",
    renderDartFieldConstraints({
      schemaSpecs,
      schemaMap: bundledSchemas,
    })
  );

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

const ORGANIZER_FORM_TEMPLATE_IDS = [
  "event-application",
  "event-registration",
  "dinner-guest-intake",
  "run-walk-participation",
  "racket-session",
  "quiz-team-night",
  "event-waiver",
  "post-event-feedback",
  "blank",
];
const ORGANIZER_FORM_PURPOSES = new Set([
  "application",
  "registration",
  "intake",
  "waiver",
  "feedback",
  "survey",
]);
const ORGANIZER_FORM_IDENTITY_POLICIES = new Set([
  "anonymous",
  "emailVerified",
  "phoneVerified",
  "emailOrPhoneVerified",
  "catchAccount",
]);

function assertOrganizerFormTemplateCatalog(catalog) {
  if (catalog?.schemaVersion !== 1 ||
      catalog?.kind !== "organizerFormTemplates") {
    throw new Error("Organizer form template catalog identity is invalid.");
  }
  if (!Array.isArray(catalog.templates) ||
      catalog.templates.length !== ORGANIZER_FORM_TEMPLATE_IDS.length) {
    throw new Error("Organizer form template catalog coverage is incomplete.");
  }
  const ids = new Set();
  for (const template of catalog.templates) {
    if (!ORGANIZER_FORM_TEMPLATE_IDS.includes(template?.id) ||
        ids.has(template.id)) {
      throw new Error(`Invalid organizer form template id: ${template?.id}`);
    }
    ids.add(template.id);
    if (!Number.isInteger(template.version) || template.version < 1 ||
        typeof template.title !== "string" || !template.title.trim() ||
        typeof template.description !== "string" ||
        !ORGANIZER_FORM_PURPOSES.has(template.purpose) ||
        !ORGANIZER_FORM_IDENTITY_POLICIES.has(template.identityPolicy) ||
        !Array.isArray(template.sections) || template.sections.length === 0) {
      throw new Error(`Organizer form template ${template.id} is malformed.`);
    }
    const sectionIds = new Set();
    const questionKeys = new Set();
    for (const section of template.sections) {
      if (typeof section?.id !== "string" || !section.id ||
          sectionIds.has(section.id) ||
          typeof section.title !== "string" || !section.title.trim() ||
          !Array.isArray(section.questions)) {
        throw new Error(
          `Organizer form template ${template.id} has an invalid section.`
        );
      }
      sectionIds.add(section.id);
      for (const question of section.questions) {
        if (typeof question?.key !== "string" ||
            !/^[A-Za-z][A-Za-z0-9_]{0,79}$/u.test(question.key) ||
            questionKeys.has(question.key) ||
            typeof question.label !== "string" || !question.label.trim() ||
            typeof question.kind !== "string" ||
            typeof question.required !== "boolean") {
          throw new Error(
            `Organizer form template ${template.id} has an invalid question.`
          );
        }
        questionKeys.add(question.key);
      }
    }
  }
}

const EVENT_SUCCESS_MOMENT_KINDS = [
  "none",
  "preArrival",
  "selfCheckIn",
  "firstHelloCheckIn",
  "compatibilityQuestionnaire",
  "liveStepContext",
  "socialPrompt",
  "conversationCues",
  "assignment",
  "liveReveal",
  "wingmanRequest",
  "postEvent",
];
const EVENT_SUCCESS_SEED_RULE = "fnv1a32-utf8-fields-v1";
const EVENT_SUCCESS_REVEAL_CLOCK =
  "revealStartedAtPlusStructureRevealCountdown";
const EVENT_SUCCESS_INTERACTION_MODELS = [
  "pacePods",
  "pairedRotations",
  "teamRotations",
  "seatedTable",
  "freeFormMixer",
  "hostLedProgram",
  "openFormat",
];
const EVENT_SUCCESS_DISCLOSURE_LEVELS = ["light", "personal", "reflective"];

function assertEventSuccessMomentPresentationCatalog(catalog) {
  if (catalog?.schemaVersion !== 1 ||
      catalog?.kind !== "eventSuccessMomentPresentations") {
    throw new Error(
      "Event Success moment presentation catalog identity is invalid."
    );
  }
  if (!Array.isArray(catalog.moments) ||
      catalog.moments.length !== EVENT_SUCCESS_MOMENT_KINDS.length) {
    throw new Error(
      "Event Success moment presentation catalog must cover every moment."
    );
  }
  const momentsByKind = new Map();
  const motifIds = new Set([
    "path", "gate", "spark", "rhythm", "orbit", "reveal", "signal",
    "afterglow",
  ]);
  const accentPolicies = new Set([
    "primary", "secondary", "secondaryUntilReveal",
  ]);
  const ambientBedIds = new Set([
    "theatrical", "pulse", "sunrise", "silent",
  ]);
  for (const moment of catalog.moments) {
    if (!EVENT_SUCCESS_MOMENT_KINDS.includes(moment?.momentKind)) {
      throw new Error(
        `Unknown Event Success moment presentation: ${moment?.momentKind}`
      );
    }
    if (momentsByKind.has(moment.momentKind)) {
      throw new Error(
        `Duplicate Event Success moment presentation: ${moment.momentKind}`
      );
    }
    momentsByKind.set(moment.momentKind, moment);
    if (typeof moment.paletteTokenId !== "string" ||
        moment.paletteTokenId.length === 0) {
      throw new Error(`${moment.momentKind} requires a palette token id.`);
    }
    if (moment.accentPaletteTokenId !== null &&
        (typeof moment.accentPaletteTokenId !== "string" ||
         moment.accentPaletteTokenId.length === 0)) {
      throw new Error(
        `${moment.momentKind} has an invalid accent palette token id.`
      );
    }
    if (!accentPolicies.has(moment.accentPalettePolicyId)) {
      throw new Error(
        `${moment.momentKind} has an invalid accent palette policy.`
      );
    }
    if (moment.accentPalettePolicyId !== "primary" &&
        moment.accentPaletteTokenId === null) {
      throw new Error(
        `${moment.momentKind} requires its secondary palette token.`
      );
    }
    if (!motifIds.has(moment.motifId)) {
      throw new Error(`${moment.momentKind} has an invalid motif id.`);
    }
    const durations = moment.phaseDurationsMs;
    for (const phase of ["anticipation", "climax", "settle"]) {
      if (!Number.isInteger(durations?.[phase]) || durations[phase] < 0) {
        throw new Error(
          `${moment.momentKind} has an invalid ${phase} duration.`
        );
      }
    }
    if (typeof moment.tempoBpm !== "number" ||
        !Number.isFinite(moment.tempoBpm) || moment.tempoBpm <= 0) {
      throw new Error(`${moment.momentKind} has an invalid tempo.`);
    }
    if (!Number.isInteger(moment.idlePulsePeriodMs) ||
        moment.idlePulsePeriodMs <= 0) {
      throw new Error(
        `${moment.momentKind} has an invalid idle-pulse period.`
      );
    }
    if (!Number.isInteger(moment.particleDensity) ||
        moment.particleDensity < 0) {
      throw new Error(
        `${moment.momentKind} has an invalid particle density.`
      );
    }
    if (moment.seedDerivationRuleId !== EVENT_SUCCESS_SEED_RULE) {
      throw new Error(
        `${moment.momentKind} has an unsupported deterministic seed rule.`
      );
    }
    if (moment.clockReferenceId !== "none" &&
        moment.clockReferenceId !== EVENT_SUCCESS_REVEAL_CLOCK) {
      throw new Error(
        `${moment.momentKind} has an unsupported server clock reference.`
      );
    }
    if (!ambientBedIds.has(moment.ambientBedId) ||
        (moment.ambientBedWhenEventEndedId !== null &&
         !ambientBedIds.has(moment.ambientBedWhenEventEndedId))) {
      throw new Error(`${moment.momentKind} has an invalid ambient bed id.`);
    }
  }
  for (const momentKind of EVENT_SUCCESS_MOMENT_KINDS) {
    if (!momentsByKind.has(momentKind)) {
      throw new Error(
        `Missing Event Success moment presentation: ${momentKind}`
      );
    }
  }
  const reveal = momentsByKind.get("liveReveal");
  if (reveal.clockReferenceId !== EVENT_SUCCESS_REVEAL_CLOCK ||
      reveal.phaseDurationsMs.anticipation <= 0 ||
      reveal.phaseDurationsMs.climax <= 0 ||
      reveal.phaseDurationsMs.settle <= 0 ||
      reveal.particleDensity <= 0) {
    throw new Error(
      "Live reveal must own its server clock, phases, and particle density."
    );
  }
  for (const [momentKind, moment] of momentsByKind) {
    if (momentKind === "liveReveal") continue;
    if (moment.clockReferenceId !== "none" || moment.particleDensity !== 0) {
      throw new Error(
        `${momentKind} cannot inherit the live-reveal ceremony.`
      );
    }
  }
  assertEventSuccessSocialMissionPromptSets(catalog.socialMissionPromptSets);
  assertEventSuccessMomentParityFixture(catalog.parityFixture, reveal);
}

function assertEventSuccessSocialMissionPromptSets(promptSets) {
  if (!Array.isArray(promptSets) ||
      promptSets.length !== EVENT_SUCCESS_INTERACTION_MODELS.length) {
    throw new Error(
      "Event Success social missions must cover every interaction model."
    );
  }
  const models = new Set();
  for (const promptSet of promptSets) {
    if (!EVENT_SUCCESS_INTERACTION_MODELS.includes(
      promptSet?.interactionModel
    ) || models.has(promptSet.interactionModel)) {
      throw new Error(
        `Invalid Event Success social mission model: ${
          promptSet?.interactionModel
        }`
      );
    }
    models.add(promptSet.interactionModel);
    if (!Array.isArray(promptSet.prompts) ||
        promptSet.prompts.length !== EVENT_SUCCESS_DISCLOSURE_LEVELS.length) {
      throw new Error(
        `${promptSet.interactionModel} requires three social mission prompts.`
      );
    }
    promptSet.prompts.forEach((prompt, index) => {
      if (prompt?.disclosureLevel !== EVENT_SUCCESS_DISCLOSURE_LEVELS[index] ||
          typeof prompt?.promptId !== "string" ||
          !/^[A-Za-z][A-Za-z0-9.]{2,79}$/u.test(prompt.promptId)) {
        throw new Error(
          `${promptSet.interactionModel} social mission ${index} is invalid.`
        );
      }
    });
  }
}

function assertEventSuccessMomentParityFixture(fixture, presentation) {
  if (fixture?.momentKind !== presentation.momentKind ||
      !Number.isInteger(fixture.activeRevealRoundIndex) ||
      !Number.isSafeInteger(fixture.serverAnchorMillis) ||
      !Number.isInteger(fixture.revealCountdownMs) ||
      fixture.revealCountdownMs < 0 || typeof fixture.eventId !== "string" ||
      fixture.eventId.length === 0) {
    throw new Error("Event Success moment parity fixture input is invalid.");
  }
  const timeline = resolveEventSuccessMomentTimelineFixture({
    presentation,
    serverAnchorMillis: fixture.serverAnchorMillis,
    revealCountdownMs: fixture.revealCountdownMs,
  });
  const seed = deriveEventSuccessMomentSeedFixture({
    presentation,
    eventId: fixture.eventId,
    activeRevealRoundIndex: fixture.activeRevealRoundIndex,
    serverAnchorMillis: fixture.serverAnchorMillis,
  });
  const expected = {...timeline, seed};
  if (JSON.stringify(fixture.expected) !== JSON.stringify(expected)) {
    throw new Error(
      "Event Success moment parity fixture expected output is stale."
    );
  }
}

function resolveEventSuccessMomentTimelineFixture({
  presentation,
  serverAnchorMillis,
  revealCountdownMs,
}) {
  const anticipationDurationMs =
    presentation.clockReferenceId === EVENT_SUCCESS_REVEAL_CLOCK ?
      revealCountdownMs : presentation.phaseDurationsMs.anticipation;
  const climaxStartsAtMillis = serverAnchorMillis + anticipationDurationMs;
  const settleStartsAtMillis =
    climaxStartsAtMillis + presentation.phaseDurationsMs.climax;
  return {
    anticipationStartsAtMillis: serverAnchorMillis,
    climaxStartsAtMillis,
    settleStartsAtMillis,
    completesAtMillis:
      settleStartsAtMillis + presentation.phaseDurationsMs.settle,
  };
}

function deriveEventSuccessMomentSeedFixture({
  presentation,
  eventId,
  activeRevealRoundIndex,
  serverAnchorMillis,
}) {
  if (presentation.seedDerivationRuleId !== EVENT_SUCCESS_SEED_RULE) {
    throw new Error(
      `Unsupported Event Success seed rule: ${
        presentation.seedDerivationRuleId
      }`
    );
  }
  let hash = 0x811c9dc5;
  const fields = [
    eventId,
    presentation.momentKind,
    String(activeRevealRoundIndex),
    String(serverAnchorMillis),
  ];
  for (const field of fields) {
    for (const byte of new TextEncoder().encode(field)) {
      hash = Math.imul(hash ^ byte, 0x01000193) >>> 0;
    }
    hash = Math.imul(hash ^ 0xff, 0x01000193) >>> 0;
  }
  return hash;
}

function renderTsEventSuccessMomentPresentations(catalog) {
  const momentKindType = EVENT_SUCCESS_MOMENT_KINDS
    .map((value) => JSON.stringify(value))
    .join(" | ");
  const interactionModelType = EVENT_SUCCESS_INTERACTION_MODELS
    .map((value) => JSON.stringify(value))
    .join(" | ");
  return `${tsGeneratedHeader()}export type EventSuccessMomentKind =
  ${momentKindType};
export type EventSuccessInteractionModel =
  ${interactionModelType};
export type EventSuccessDisclosureLevel =
  "light" | "personal" | "reflective";
export type EventSuccessAccentPalettePolicyId =
  "primary" | "secondary" | "secondaryUntilReveal";
export type EventSuccessMomentClockReferenceId =
  "none" | "${EVENT_SUCCESS_REVEAL_CLOCK}";
export type EventSuccessMomentSeedDerivationRuleId =
  "${EVENT_SUCCESS_SEED_RULE}";
export type EventSuccessAmbientBedId =
  "theatrical" | "pulse" | "sunrise" | "silent";

export interface EventSuccessMomentPhaseDurations {
  readonly anticipation: number;
  readonly climax: number;
  readonly settle: number;
}

export interface EventSuccessMomentPresentationContract {
  readonly momentKind: EventSuccessMomentKind;
  readonly paletteTokenId: string;
  readonly accentPaletteTokenId: string | null;
  readonly accentPalettePolicyId: EventSuccessAccentPalettePolicyId;
  readonly motifId: string;
  readonly phaseDurationsMs: EventSuccessMomentPhaseDurations;
  readonly tempoBpm: number;
  readonly idlePulsePeriodMs: number;
  readonly particleDensity: number;
  readonly seedDerivationRuleId: EventSuccessMomentSeedDerivationRuleId;
  readonly clockReferenceId: EventSuccessMomentClockReferenceId;
  readonly ambientBedId: EventSuccessAmbientBedId;
  readonly ambientBedWhenEventEndedId: EventSuccessAmbientBedId | null;
}

export interface EventSuccessSocialMissionPromptContract {
  readonly promptId: string;
  readonly disclosureLevel: EventSuccessDisclosureLevel;
}

export interface EventSuccessSocialMissionPromptSetContract {
  readonly interactionModel: EventSuccessInteractionModel;
  readonly prompts: readonly EventSuccessSocialMissionPromptContract[];
}

export interface EventSuccessMomentPresentationCatalog {
  readonly schemaVersion: 1;
  readonly kind: "eventSuccessMomentPresentations";
  readonly moments: readonly EventSuccessMomentPresentationContract[];
  readonly socialMissionPromptSets:
    readonly EventSuccessSocialMissionPromptSetContract[];
  readonly parityFixture: {
    readonly eventId: string;
    readonly momentKind: EventSuccessMomentKind;
    readonly activeRevealRoundIndex: number;
    readonly serverAnchorMillis: number;
    readonly revealCountdownMs: number;
    readonly expected: EventSuccessCeremonyTimeline & {readonly seed: number};
  };
}

export interface EventSuccessCeremonyTimeline {
  readonly anticipationStartsAtMillis: number;
  readonly climaxStartsAtMillis: number;
  readonly settleStartsAtMillis: number;
  readonly completesAtMillis: number;
}

export const eventSuccessMomentPresentationCatalog:
  EventSuccessMomentPresentationCatalog =
  ${jsonForTs(catalog)};

const eventSuccessMomentPresentationsByKind = new Map<
  EventSuccessMomentKind,
  EventSuccessMomentPresentationContract
>(eventSuccessMomentPresentationCatalog.moments.map((presentation) => [
  presentation.momentKind,
  presentation,
]));

export function eventSuccessMomentPresentationFor(
  momentKind: EventSuccessMomentKind
): EventSuccessMomentPresentationContract {
  const presentation = eventSuccessMomentPresentationsByKind.get(momentKind);
  if (!presentation) {
    throw new Error("Missing Event Success moment presentation: " + momentKind);
  }
  return presentation;
}

const eventSuccessSocialMissionPromptsByInteractionModel = new Map<
  EventSuccessInteractionModel,
  EventSuccessSocialMissionPromptSetContract
>(eventSuccessMomentPresentationCatalog.socialMissionPromptSets.map((set) => [
  set.interactionModel,
  set,
]));

export function eventSuccessSocialMissionPromptFor(input: {
  interactionModel: EventSuccessInteractionModel;
  activeStepIndex: number;
}): EventSuccessSocialMissionPromptContract {
  const promptSet = eventSuccessSocialMissionPromptsByInteractionModel.get(
    input.interactionModel
  );
  if (!promptSet || promptSet.prompts.length !== 3) {
    throw new Error(
      "Missing Event Success social missions: " + input.interactionModel
    );
  }
  const disclosureIndex = Math.max(0, Math.min(2, input.activeStepIndex));
  return promptSet.prompts[disclosureIndex];
}

export function resolveEventSuccessCeremonyTimeline(input: {
  presentation: EventSuccessMomentPresentationContract;
  serverAnchorMillis: number;
  revealCountdownMs?: number | null;
}): EventSuccessCeremonyTimeline {
  const configuredAnticipationMs =
    input.presentation.phaseDurationsMs.anticipation;
  const anticipationDurationMs =
    input.presentation.clockReferenceId ===
      "${EVENT_SUCCESS_REVEAL_CLOCK}" ?
      input.revealCountdownMs ?? configuredAnticipationMs :
      configuredAnticipationMs;
  if (!Number.isSafeInteger(input.serverAnchorMillis) ||
      !Number.isInteger(anticipationDurationMs) ||
      anticipationDurationMs < 0) {
    throw new Error("Event Success ceremony timing input is invalid.");
  }
  const climaxStartsAtMillis =
    input.serverAnchorMillis + anticipationDurationMs;
  const settleStartsAtMillis =
    climaxStartsAtMillis + input.presentation.phaseDurationsMs.climax;
  return {
    anticipationStartsAtMillis: input.serverAnchorMillis,
    climaxStartsAtMillis,
    settleStartsAtMillis,
    completesAtMillis:
      settleStartsAtMillis + input.presentation.phaseDurationsMs.settle,
  };
}

export function deriveEventSuccessMomentSeed(input: {
  presentation: EventSuccessMomentPresentationContract;
  eventId: string;
  activeRevealRoundIndex: number;
  serverAnchorMillis: number;
}): number {
  if (input.presentation.seedDerivationRuleId !==
      "${EVENT_SUCCESS_SEED_RULE}") {
    throw new Error(
      "Unsupported Event Success seed rule: " +
        input.presentation.seedDerivationRuleId
    );
  }
  let hash = 0x811c9dc5;
  const fields = [
    input.eventId,
    input.presentation.momentKind,
    String(input.activeRevealRoundIndex),
    String(input.serverAnchorMillis),
  ];
  for (const field of fields) {
    for (const byte of new TextEncoder().encode(field)) {
      hash = Math.imul(hash ^ byte, 0x01000193) >>> 0;
    }
    hash = Math.imul(hash ^ 0xff, 0x01000193) >>> 0;
  }
  return hash;
}
`;
}

function renderDartEventSuccessMomentPresentations(catalog) {
  const moments = catalog.moments.map((moment) =>
    `  EventSuccessMomentPresentationContract(\n` +
    `    momentKind: ${dartString(moment.momentKind)},\n` +
    `    paletteTokenId: ${dartString(moment.paletteTokenId)},\n` +
    `    accentPaletteTokenId: ${dartLiteral(moment.accentPaletteTokenId)},\n` +
    `    accentPalettePolicyId: ${
      dartString(moment.accentPalettePolicyId)
    },\n` +
    `    motifId: ${dartString(moment.motifId)},\n` +
    `    phaseDurationsMs: EventSuccessMomentPhaseDurations(\n` +
    `      anticipation: ${moment.phaseDurationsMs.anticipation},\n` +
    `      climax: ${moment.phaseDurationsMs.climax},\n` +
    `      settle: ${moment.phaseDurationsMs.settle},\n` +
    `    ),\n` +
    `    tempoBpm: ${moment.tempoBpm},\n` +
    `    idlePulsePeriodMs: ${moment.idlePulsePeriodMs},\n` +
    `    particleDensity: ${moment.particleDensity},\n` +
    `    seedDerivationRuleId: ${
      dartString(moment.seedDerivationRuleId)
    },\n` +
    `    clockReferenceId: ${dartString(moment.clockReferenceId)},\n` +
    `    ambientBedId: ${dartString(moment.ambientBedId)},\n` +
    `    ambientBedWhenEventEndedId: ${
      dartLiteral(moment.ambientBedWhenEventEndedId)
    },\n` +
    `  ),`
  ).join("\n");
  const byKind = catalog.moments.map((moment) =>
    `  ${dartString(moment.momentKind)}: ` +
      `eventSuccessMomentPresentations[${
        EVENT_SUCCESS_MOMENT_KINDS.indexOf(moment.momentKind)
      }],`
  ).join("\n");
  const promptSets = catalog.socialMissionPromptSets.map((promptSet) =>
    `  EventSuccessSocialMissionPromptSetContract(\n` +
    `    interactionModel: ${dartString(promptSet.interactionModel)},\n` +
    `    prompts: <EventSuccessSocialMissionPromptContract>[\n` +
    promptSet.prompts.map((prompt) =>
      `      EventSuccessSocialMissionPromptContract(` +
      `promptId: ${dartString(prompt.promptId)}, ` +
      `disclosureLevel: ${dartString(prompt.disclosureLevel)}),`
    ).join("\n") + `\n    ],\n  ),`
  ).join("\n");
  const promptSetsByModel = catalog.socialMissionPromptSets.map((promptSet) =>
    `  ${dartString(promptSet.interactionModel)}: ` +
      `eventSuccessSocialMissionPromptSets[${
        EVENT_SUCCESS_INTERACTION_MODELS.indexOf(promptSet.interactionModel)
      }],`
  ).join("\n");
  return `${dartGeneratedHeader()}
import 'dart:convert';

class EventSuccessMomentPhaseDurations {
  const EventSuccessMomentPhaseDurations({
    required this.anticipation,
    required this.climax,
    required this.settle,
  });

  final int anticipation;
  final int climax;
  final int settle;
}

class EventSuccessMomentPresentationContract {
  const EventSuccessMomentPresentationContract({
    required this.momentKind,
    required this.paletteTokenId,
    required this.accentPaletteTokenId,
    required this.accentPalettePolicyId,
    required this.motifId,
    required this.phaseDurationsMs,
    required this.tempoBpm,
    required this.idlePulsePeriodMs,
    required this.particleDensity,
    required this.seedDerivationRuleId,
    required this.clockReferenceId,
    required this.ambientBedId,
    required this.ambientBedWhenEventEndedId,
  });

  final String momentKind;
  final String paletteTokenId;
  final String? accentPaletteTokenId;
  final String accentPalettePolicyId;
  final String motifId;
  final EventSuccessMomentPhaseDurations phaseDurationsMs;
  final double tempoBpm;
  final int idlePulsePeriodMs;
  final int particleDensity;
  final String seedDerivationRuleId;
  final String clockReferenceId;
  final String ambientBedId;
  final String? ambientBedWhenEventEndedId;
}

class EventSuccessSocialMissionPromptContract {
  const EventSuccessSocialMissionPromptContract({
    required this.promptId,
    required this.disclosureLevel,
  });

  final String promptId;
  final String disclosureLevel;
}

class EventSuccessSocialMissionPromptSetContract {
  const EventSuccessSocialMissionPromptSetContract({
    required this.interactionModel,
    required this.prompts,
  });

  final String interactionModel;
  final List<EventSuccessSocialMissionPromptContract> prompts;
}

class EventSuccessCeremonyTimeline {
  const EventSuccessCeremonyTimeline({
    required this.anticipationStartsAtMillis,
    required this.climaxStartsAtMillis,
    required this.settleStartsAtMillis,
    required this.completesAtMillis,
  });

  final int anticipationStartsAtMillis;
  final int climaxStartsAtMillis;
  final int settleStartsAtMillis;
  final int completesAtMillis;

  Map<String, Object?> toJson() => <String, Object?>{
    'anticipationStartsAtMillis': anticipationStartsAtMillis,
    'climaxStartsAtMillis': climaxStartsAtMillis,
    'settleStartsAtMillis': settleStartsAtMillis,
    'completesAtMillis': completesAtMillis,
  };
}

const eventSuccessMomentPresentationCatalogJson =
    ${dartLiteral(catalog)};

const eventSuccessMomentPresentations =
    <EventSuccessMomentPresentationContract>[
${moments}
];

final eventSuccessMomentPresentationsByKind =
    <String, EventSuccessMomentPresentationContract>{
${byKind}
};

const eventSuccessSocialMissionPromptSets =
    <EventSuccessSocialMissionPromptSetContract>[
${promptSets}
];

final eventSuccessSocialMissionPromptsByInteractionModel =
    <String, EventSuccessSocialMissionPromptSetContract>{
${promptSetsByModel}
};

EventSuccessMomentPresentationContract eventSuccessMomentPresentationFor(
  String momentKind,
) {
  final presentation = eventSuccessMomentPresentationsByKind[momentKind];
  if (presentation == null) {
    throw StateError('Missing Event Success moment presentation: \$momentKind');
  }
  return presentation;
}

EventSuccessSocialMissionPromptContract eventSuccessSocialMissionPromptFor({
  required String interactionModel,
  required int activeStepIndex,
}) {
  final promptSet =
      eventSuccessSocialMissionPromptsByInteractionModel[interactionModel];
  if (promptSet == null || promptSet.prompts.length != 3) {
    throw StateError(
      'Missing Event Success social missions: \$interactionModel',
    );
  }
  final disclosureIndex = activeStepIndex < 0
      ? 0
      : activeStepIndex > 2
      ? 2
      : activeStepIndex;
  return promptSet.prompts[disclosureIndex];
}

EventSuccessCeremonyTimeline resolveEventSuccessCeremonyTimeline({
  required EventSuccessMomentPresentationContract presentation,
  required int serverAnchorMillis,
  int? revealCountdownMs,
}) {
  final configuredAnticipationMs = presentation.phaseDurationsMs.anticipation;
  final anticipationDurationMs = presentation.clockReferenceId ==
          '${EVENT_SUCCESS_REVEAL_CLOCK}'
      ? revealCountdownMs ?? configuredAnticipationMs
      : configuredAnticipationMs;
  if (anticipationDurationMs < 0) {
    throw ArgumentError.value(
      anticipationDurationMs,
      'revealCountdownMs',
      'must not be negative',
    );
  }
  final climaxStartsAtMillis = serverAnchorMillis + anticipationDurationMs;
  final settleStartsAtMillis =
      climaxStartsAtMillis + presentation.phaseDurationsMs.climax;
  return EventSuccessCeremonyTimeline(
    anticipationStartsAtMillis: serverAnchorMillis,
    climaxStartsAtMillis: climaxStartsAtMillis,
    settleStartsAtMillis: settleStartsAtMillis,
    completesAtMillis:
        settleStartsAtMillis + presentation.phaseDurationsMs.settle,
  );
}

int deriveEventSuccessMomentSeed({
  required EventSuccessMomentPresentationContract presentation,
  required String eventId,
  required int activeRevealRoundIndex,
  required int serverAnchorMillis,
}) {
  if (presentation.seedDerivationRuleId != '${EVENT_SUCCESS_SEED_RULE}') {
    throw UnsupportedError(
      'Unsupported Event Success seed rule: '
      '\${presentation.seedDerivationRuleId}',
    );
  }
  var hash = 0x811c9dc5;
  final fields = <String>[
    eventId,
    presentation.momentKind,
    activeRevealRoundIndex.toString(),
    serverAnchorMillis.toString(),
  ];
  for (final field in fields) {
    for (final byte in utf8.encode(field)) {
      hash = ((hash ^ byte) * 0x01000193) & 0xffffffff;
    }
    hash = ((hash ^ 0xff) * 0x01000193) & 0xffffffff;
  }
  return hash;
}
`;
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
  const content = `${tsGeneratedHeader()}${imports}${types.trim()}\n`;
  for (const output of [
    spec.typeOutput,
    ...(spec.additionalTypeOutputs ?? []),
  ]) {
    addTextOutput(output, content);
  }
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

  const sectionSource = sections.join("\n\n");
  const externalImports = schemaSpecs
    .filter((spec) => !allAdminTypeNames.includes(spec.name))
    .filter((spec) => new RegExp(`\\b${spec.name}\\b`).test(sectionSource))
    .map((spec) => `import {${spec.name}} from "${typeImportPath(spec)}";`)
    .join("\n");
  const importBlock = externalImports.length === 0 ?
    "" : `${externalImports}\n\n`;

  return `${tsGeneratedHeader()}${importBlock}` +
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

${sectionSource}\n`;
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
  personFieldCatalog,
  organizerFormTemplateCatalog,
  photoCatalog,
  profilePhotoPolicy,
}) {
  const entries = schemaRegistryEntries(schemaMap);
  const catalogEntries = [
    ["profilePromptCatalog", profileCatalog],
    ["personFieldCatalog", personFieldCatalog],
    ["organizerFormTemplateCatalog", organizerFormTemplateCatalog],
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
  const validators = schemaSpecs.map((spec) => `export const ${validatorName(spec)} =
  lazyValidator<${spec.name}>(${schemaConstName(spec)});`).join("\n");

  return `${tsGeneratedHeader()}import Ajv, {ValidateFunction} from "ajv";
import addFormats from "ajv-formats";
${typeImports}
import {
${schemaImports}
} from "./schemaRegistry";

const ajv = new Ajv({allErrors: true, strict: false});
addFormats(ajv);

function lazyValidator<T>(
  schema: Record<string, unknown>
): ValidateFunction<T> {
  let compiled: ValidateFunction<T> | null = null;
  const validate = ((data: unknown) => {
    compiled ??= ajv.compile(schema) as ValidateFunction<T>;
    return compiled(data);
  }) as ValidateFunction<T>;
  Object.defineProperty(validate, "errors", {
    get: () => compiled?.errors ?? null,
  });
  return validate;
}

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
  personFieldCatalog,
  organizerFormTemplateCatalog,
  photoCatalog,
  profilePhotoPolicy,
}) {
  const entries = schemaRegistryEntries(schemaMap);
  const catalogEntries = [
    ["profilePromptCatalog", profileCatalog],
    ["personFieldCatalog", personFieldCatalog],
    ["organizerFormTemplateCatalog", organizerFormTemplateCatalog],
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

function renderWebsiteJoinWaitlistSchemas({requestSchema, responseSchema}) {
  return `${tsGeneratedHeader()}` +
`export const joinWaitlistRequestSchema: Record<string, unknown> =
  ${jsonForTs(requestSchema)};

export const joinWaitlistResponseSchema: Record<string, unknown> =
  ${jsonForTs(responseSchema)};
`;
}

function renderDartContracts({
  profileCatalog,
  personFieldCatalog,
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
  const personFields = personFieldCatalog.fields.map((field) =>
    `  SchemaPersonFieldDefinition(` +
    `id: ${dartString(field.id)}, ` +
    `aliases: <String>[${field.aliases.map(dartString).join(", ")}], ` +
    `questionKind: ${dartString(field.questionKind)}, ` +
    `transform: ${dartString(field.transform)}, ` +
    `privacyClass: ${dartString(field.privacyClass)}, ` +
    `prefillPolicy: ${dartString(field.prefillPolicy)}, ` +
    `hostPresentation: ${dartString(field.hostPresentation)}, ` +
    `authority: ${dartString(field.authority)}, ` +
    `privateProfilePath: ${dartLiteral(field.privateProfilePath)}, ` +
    `derivedFrom: ${dartLiteral(field.derivedFrom)}, ` +
    `publicProfileProjection: ` +
    `${dartString(field.publicProfileProjection)}, ` +
    `publicProfilePath: ${dartLiteral(field.publicProfilePath)},` +
    `),`
  ).join("\n");
  const personFieldAliases = personFieldCatalog.fields.flatMap((field) =>
    field.aliases.map((alias) =>
      `  ${dartString(alias)}: ${dartString(field.id)},`
    )
  ).join("\n");

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

class SchemaPersonFieldDefinition {
  const SchemaPersonFieldDefinition({
    required this.id,
    required this.aliases,
    required this.questionKind,
    required this.transform,
    required this.privacyClass,
    required this.prefillPolicy,
    required this.hostPresentation,
    required this.authority,
    required this.privateProfilePath,
    required this.derivedFrom,
    required this.publicProfileProjection,
    required this.publicProfilePath,
  });

  final String id;
  final List<String> aliases;
  final String questionKind;
  final String transform;
  final String privacyClass;
  final String prefillPolicy;
  final String hostPresentation;
  final String authority;
  final String? privateProfilePath;
  final String? derivedFrom;
  final String publicProfileProjection;
  final String? publicProfilePath;
}

const schemaPersonFieldOrganizerAccessPolicy = ${dartString(
  personFieldCatalog.organizerAccessPolicy
)};
const schemaPersonFieldPublicProfileMetadataPolicy = ${dartString(
  personFieldCatalog.publicProfileMetadataPolicy
)};
const schemaPersonFieldTabularChoiceImportPolicy = ${dartString(
  personFieldCatalog.tabularChoiceImportPolicy
)};

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

const schemaPersonFieldCatalog = <SchemaPersonFieldDefinition>[
${personFields}
];

const schemaPersonFieldIdByNormalizedAlias = <String, String>{
${personFieldAliases}
};

String? schemaPersonFieldIdForNormalizedAlias(String alias) =>
    schemaPersonFieldIdByNormalizedAlias[alias];

SchemaPersonFieldDefinition? schemaPersonFieldForId(String id) {
  for (final field in schemaPersonFieldCatalog) {
    if (field.id == id) return field;
  }
  return null;
}

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

export 'event_success_moment_presentations.g.dart';
export 'field_constraints.g.dart';
export 'schemas/schema_constants.g.dart';
export 'schemas/schema_registry.g.dart';
`,
    files,
    generatedConstants,
  };
}

function renderDartFieldConstraints({schemaSpecs, schemaMap}) {
  const constraints = [];
  for (const spec of schemaSpecs) {
    const schema = schemaMap.get(spec.name);
    if (!schema) continue;

    const patchConfig = schema["x-callable-shape"] === "patch" ?
      dartPatchClassConfig(spec.name) :
      null;
    const rootName = lowerCamelCase(patchConfig?.className ?? spec.name);
    const rootSchema = patchConfig ? schema.properties?.fields : schema;
    if (!rootSchema || typeof rootSchema !== "object") continue;
    collectFieldConstraints({
      schema: rootSchema,
      rootName,
      segments: [],
      constraints,
    });
  }

  constraints.sort((a, b) => a.path.localeCompare(b.path));
  disambiguateFieldConstraintNames(constraints);
  const declarations = constraints.map((entry) => {
    const args = [
      `path: ${dartString(entry.path)}`,
      entry.maxLength == null ? null : `maxLength: ${entry.maxLength}`,
      entry.minLength == null ? null : `minLength: ${entry.minLength}`,
      entry.required ? "required: true" : null,
      entry.valueTypes == null ? null :
        `valueTypes: <String>[${entry.valueTypes.map(dartString).join(", ")}]`,
      entry.format == null ? null : `format: ${dartString(entry.format)}`,
      entry.pattern == null ? null : `pattern: ${dartString(entry.pattern)}`,
      entry.enumValues == null ? null :
        `enumValues: <String>[${entry.enumValues.map(dartString).join(", ")}]`,
      entry.itemValueTypes == null ? null :
        `itemValueTypes: <String>[${
          entry.itemValueTypes.map(dartString).join(", ")
        }]`,
      entry.itemEnumValues == null ? null :
        `itemEnumValues: <String>[${
          entry.itemEnumValues.map(dartString).join(", ")
        }]`,
      entry.minItems == null ? null : `minItems: ${entry.minItems}`,
      entry.maxItems == null ? null : `maxItems: ${entry.maxItems}`,
      entry.uniqueItems ? "uniqueItems: true" : null,
      entry.minimum == null ? null : `minimum: ${entry.minimum}`,
      entry.maximum == null ? null : `maximum: ${entry.maximum}`,
      entry.multipleOf == null ? null : `multipleOf: ${entry.multipleOf}`,
    ].filter(Boolean);
    return `  static const ${entry.constName} = CatchContractFieldConstraints(\n` +
      `${args.map((arg) => `    ${arg},`).join("\n")}\n` +
      "  );";
  }).join("\n\n");
  const allEntries = constraints.map((entry) =>
    `    ${dartString(entry.path)}: ${entry.constName},`
  ).join("\n");

  return `${dartGeneratedHeader()}
/// UI-relevant constraints projected from every generated JSON Schema.
class CatchContractFieldConstraints {
  const CatchContractFieldConstraints({
    required this.path,
    this.maxLength,
    this.minLength,
    this.required = false,
    this.valueTypes,
    this.format,
    this.pattern,
    this.enumValues,
    this.itemValueTypes,
    this.itemEnumValues,
    this.minItems,
    this.maxItems,
    this.uniqueItems = false,
    this.minimum,
    this.maximum,
    this.multipleOf,
  });

  final String path;
  final int? maxLength;
  final int? minLength;
  final bool required;
  final List<String>? valueTypes;
  final String? format;
  final String? pattern;
  final List<String>? enumValues;
  final List<String>? itemValueTypes;
  final List<String>? itemEnumValues;
  final int? minItems;
  final int? maxItems;
  final bool uniqueItems;
  final num? minimum;
  final num? maximum;
  final num? multipleOf;
}

abstract final class CatchContractConstraints {
${declarations}

  static const all = <String, CatchContractFieldConstraints>{
${allEntries}
  };
}
`;
}

function disambiguateFieldConstraintNames(constraints) {
  const entriesByName = new Map();
  for (const entry of constraints) {
    const entries = entriesByName.get(entry.constName) ?? [];
    entries.push(entry);
    entriesByName.set(entry.constName, entries);
  }

  const usedNames = new Set(
    constraints
      .filter((entry) => entriesByName.get(entry.constName)?.length === 1)
      .map((entry) => entry.constName),
  );
  for (const entries of entriesByName.values()) {
    if (entries.length === 1) continue;
    for (const entry of entries) {
      const pathSuffix = entry.segments.map(pascalCase).join("Property");
      const candidate = `${entry.constName}At${pathSuffix}`;
      let uniqueName = candidate;
      let suffix = 2;
      while (usedNames.has(uniqueName)) {
        uniqueName = `${candidate}${suffix}`;
        suffix += 1;
      }
      entry.constName = uniqueName;
      usedNames.add(uniqueName);
    }
  }
}

function collectFieldConstraints({schema, rootName, segments, constraints}) {
  const objectSchema = constraintObjectSchema(schema);
  const properties = objectSchema?.properties;
  if (!properties || typeof properties !== "object") return;
  const requiredFields = new Set(objectSchema.required ?? []);

  for (const [fieldName, fieldSchema] of Object.entries(properties)) {
    const nextSegments = [...segments, fieldName];
    const nestedObject = constraintObjectSchema(fieldSchema);
    if (nestedObject?.properties) {
      collectFieldConstraints({
        schema: nestedObject,
        rootName,
        segments: nextSegments,
        constraints,
      });
      continue;
    }

    const projected = projectFieldConstraint(
      fieldSchema,
      requiredFields.has(fieldName)
    );
    if (projected) {
      const path = `${rootName}.${nextSegments.join(".")}`;
      constraints.push({
        ...projected,
        path,
        segments: nextSegments,
        constName: `${rootName}${nextSegments.map(pascalCase).join("")}`,
      });
    }

    const itemObject = constraintObjectSchema(fieldSchema?.items);
    if (itemObject?.properties) {
      collectFieldConstraints({
        schema: itemObject,
        rootName,
        segments: [...nextSegments, "items"],
        constraints,
      });
    } else if (fieldSchema?.items && typeof fieldSchema.items === "object") {
      const itemConstraint = projectFieldConstraint(fieldSchema.items, true);
      if (itemConstraint) {
        const itemSegments = [...nextSegments, "items"];
        constraints.push({
          ...itemConstraint,
          path: `${rootName}.${itemSegments.join(".")}`,
          segments: itemSegments,
          constName: `${rootName}${itemSegments.map(pascalCase).join("")}`,
        });
      }
    }
  }
}

function constraintObjectSchema(schema) {
  if (!schema || typeof schema !== "object") return null;
  if (schema.type === "object" || schema.properties) return schema;
  const objectBranches = [...(schema.anyOf ?? []), ...(schema.oneOf ?? [])]
    .filter((branch) => branch?.type === "object" || branch?.properties);
  if (objectBranches.length === 0) return null;
  return {
    properties: Object.assign(
      {},
      ...objectBranches.map((branch) => branch.properties ?? {}),
    ),
    required: [...new Set(
      objectBranches.flatMap((branch) => branch.required ?? []),
    )],
  };
}

function projectFieldConstraint(schema, parentRequired) {
  const branches = [schema, ...(schema?.anyOf ?? []), ...(schema?.oneOf ?? [])]
    .filter((branch) => branch && typeof branch === "object");
  const values = (key) => branches
    .map((branch) => branch[key])
    .filter((value) => value != null);
  const numberValue = (key, choose) => {
    const candidates = values(key).filter((value) => typeof value === "number");
    return candidates.length === 0 ? null : choose(...candidates);
  };
  const stringValues = values("pattern")
    .filter((value) => typeof value === "string");
  const patterns = [...new Set(stringValues)];
  const enumValues = [...new Set(
    branches.flatMap((branch) => Array.isArray(branch.enum) ? branch.enum : [])
      .filter((value) => typeof value === "string")
  )];
  const types = [...new Set(branches.flatMap((branch) => Array.isArray(branch.type) ?
    branch.type :
    [branch.type]
  ).filter((value) => typeof value === "string"))];
  const valueTypes = types.filter((type) => type !== "null");
  const formats = [...new Set(values("format")
    .filter((value) => typeof value === "string"))];
  const itemBranches = branches.flatMap((branch) => {
    const items = branch.items;
    if (!items || Array.isArray(items) || typeof items !== "object") return [];
    return [items, ...(items.anyOf ?? []), ...(items.oneOf ?? [])]
      .filter((item) => item && typeof item === "object");
  });
  const itemValueTypes = [...new Set(itemBranches.flatMap((item) =>
    Array.isArray(item.type) ? item.type : [item.type]
  ).filter((value) => typeof value === "string" && value !== "null"))];
  const itemEnumValues = [...new Set(itemBranches.flatMap((item) =>
    Array.isArray(item.enum) ? item.enum : []
  ).filter((value) => typeof value === "string"))];
  const allowsNull = types.includes("null") ||
    branches.some((branch) => branch.const === null);
  const allowsEmpty = branches.some((branch) => branch.const === "") ||
    branches.some((branch) => branch.minLength === 0);
  const minLength = numberValue("minLength", Math.min);
  const maxLength = numberValue("maxLength", Math.max);
  const required = (parentRequired || (minLength ?? 0) > 0) &&
    !allowsNull && !allowsEmpty;
  const result = {
    maxLength,
    minLength,
    required,
    valueTypes: valueTypes.length > 0 ? valueTypes : null,
    format: formats.length === 1 ? formats[0] : null,
    pattern: patterns.length === 1 ? patterns[0] : null,
    enumValues: enumValues.length > 0 ? enumValues : null,
    itemValueTypes: itemValueTypes.length > 0 ? itemValueTypes : null,
    itemEnumValues: itemEnumValues.length > 0 ? itemEnumValues : null,
    minItems: numberValue("minItems", Math.min),
    maxItems: numberValue("maxItems", Math.max),
    uniqueItems: values("uniqueItems").includes(true),
    minimum: numberValue("minimum", Math.min),
    maximum: numberValue("maximum", Math.max),
    multipleOf: numberValue("multipleOf", Math.min),
  };
  return Object.values(result).some((value) => value != null && value !== false) ?
    result :
    null;
}

function lowerCamelCase(value) {
  const converted = pascalCase(value);
  return converted.length === 0 ? converted :
    `${converted[0].toLowerCase()}${converted.slice(1)}`;
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
| \`lib/core/schema_contracts/generated/field_constraints.g.dart\` | UI-relevant constraints projected from patch and Firestore document schemas. |
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
