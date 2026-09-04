/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import Ajv, {ValidateFunction} from "ajv";
import addFormats from "ajv-formats";
import {MobileFormState} from "./mobileFormState";
import {OperationRun} from "./operationRunContract";
import {OperationWorkItem} from "./operationWorkItemContract";
import {ProfilePromptAnswer} from "./profilePromptAnswer";
import {PhotoPromptAnswer} from "./photoPromptAnswer";
import {ProfilePhoto} from "./profilePhoto";
import {UploadedPhoto} from "./uploadedPhoto";
import {EventOrigin} from "./eventOrigin";
import {EventRuntimeAccess} from "./eventRuntimeAccess";
import {ActivityPreferences} from "./activityPreferences";
import {OrganizerSupplyCapabilities} from "./organizerSupplyCapabilities";
import {ExternalEventBlockerResolution} from "./externalEventBlockerResolution";
import {ExternalEventPublicationReceiptDocument} from "./externalEventPublicationReceiptDocument";
import {ConfigCitiesDocument} from "./configCitiesDocument";
import {OnboardingDraftDocument} from "./onboardingDraftDocument";
import {AccessApplicationDocument} from "./accessApplicationDocument";
import {UserProfileDocument} from "./userProfileDocument";
import {PublicProfileDocument} from "./publicProfileDocument";
import {HostProfileDocument} from "./hostProfileDocument";
import {ClubDocument} from "./clubDocument";
import {OrganizerDocument} from "./organizerDocument";
import {OrganizerPostDocument} from "./organizerPostDocument";
import {OrganizerPostDeliveryOperationDocument} from "./organizerPostDeliveryOperationDocument";
import {OrganizerPostDeliveryRecipientDocument} from "./organizerPostDeliveryRecipientDocument";
import {OrganizerTeamMembershipDocument} from "./organizerTeamMembershipDocument";
import {OrganizerFollowDocument} from "./organizerFollowDocument";
import {OrganizerCommunicationPreferenceDocument} from "./organizerCommunicationPreferenceDocument";
import {OrganizerCommunicationPermissionReceiptDocument} from "./organizerCommunicationPermissionReceiptDocument";
import {OrganizerContactDocument} from "./organizerContactDocument";
import {OrganizerContactOriginDocument} from "./organizerContactOriginDocument";
import {OrganizerContactNoteDocument} from "./organizerContactNoteDocument";
import {OrganizerContactTagVocabularyDocument} from "./organizerContactTagVocabularyDocument";
import {OrganizerSavedAudienceDocument} from "./organizerSavedAudienceDocument";
import {OrganizerManualSendTaskDocument} from "./organizerManualSendTaskDocument";
import {OrganizerAttentionItemDocument} from "./organizerAttentionItemDocument";
import {OrganizerContactIdentityLinkDocument} from "./organizerContactIdentityLinkDocument";
import {OrganizerContactIdentityClaimDocument} from "./organizerContactIdentityClaimDocument";
import {OrganizerContactEventEdgeDocument} from "./organizerContactEventEdgeDocument";
import {OrganizerContactTraitDocument} from "./organizerContactTraitDocument";
import {OrganizerAudienceSummaryDocument} from "./organizerAudienceSummaryDocument";
import {OrganizerAudienceProjectionReceiptDocument} from "./organizerAudienceProjectionReceiptDocument";
import {OrganizerContactMergeReceiptDocument} from "./organizerContactMergeReceiptDocument";
import {OrganizerContactMergeReviewDecisionDocument} from "./organizerContactMergeReviewDecisionDocument";
import {OrganizerSenderConnectionDocument} from "./organizerSenderConnectionDocument";
import {OrganizerProviderConnectionDocument} from "./organizerProviderConnectionDocument";
import {OrganizerApplicationFormDocument} from "./organizerApplicationFormDocument";
import {OrganizerApplicationFormVersionDocument} from "./organizerApplicationFormVersionDocument";
import {OrganizerFormDocument} from "./organizerFormDocument";
import {OrganizerFormDraftDocument} from "./organizerFormDraftDocument";
import {OrganizerFormVersionDocument} from "./organizerFormVersionDocument";
import {OrganizerFormResponseDraftDocument} from "./organizerFormResponseDraftDocument";
import {OrganizerFormResponseDocument} from "./organizerFormResponseDocument";
import {OrganizerFormAssetDocument} from "./organizerFormAssetDocument";
import {OrganizerFormAggregateDocument} from "./organizerFormAggregateDocument";
import {OrganizerFormAggregateEventDocument} from "./organizerFormAggregateEventDocument";
import {OrganizerFormExportDocument} from "./organizerFormExportDocument";
import {OrganizerFormAutomationRuleDocument} from "./organizerFormAutomationRuleDocument";
import {OrganizerFormAutomationRunDocument} from "./organizerFormAutomationRunDocument";
import {OrganizerFormConversionReceiptDocument} from "./organizerFormConversionReceiptDocument";
import {OrganizerFormShareLinkDocument} from "./organizerFormShareLinkDocument";
import {OrganizerApplicationDocument} from "./organizerApplicationDocument";
import {OrganizerApplicationResponseDocument} from "./organizerApplicationResponseDocument";
import {OrganizerApplicationAssetDocument} from "./organizerApplicationAssetDocument";
import {OrganizerApplicationSourceMappingDocument} from "./organizerApplicationSourceMappingDocument";
import {OrganizerApplicationImportReceiptDocument} from "./organizerApplicationImportReceiptDocument";
import {ParticipantIntakeProfileDocument} from "./participantIntakeProfileDocument";
import {ParticipantOrganizerDataGrantDocument} from "./participantOrganizerDataGrantDocument";
import {ExternalEventMappingDocument} from "./externalEventMappingDocument";
import {ProviderSyncRunDocument} from "./providerSyncRunDocument";
import {OrganizerMessageTemplateDocument} from "./organizerMessageTemplateDocument";
import {OrganizerContactChannelStateDocument} from "./organizerContactChannelStateDocument";
import {OrganizerCampaignDocument} from "./organizerCampaignDocument";
import {OrganizerBroadcastSummaryDocument} from "./organizerBroadcastSummaryDocument";
import {OrganizerCampaignRecipientDocument} from "./organizerCampaignRecipientDocument";
import {OrganizerCampaignWebhookReceiptDocument} from "./organizerCampaignWebhookReceiptDocument";
import {OrganizerMessagingWebhookEventDocument} from "./organizerMessagingWebhookEventDocument";
import {OrganizerWhatsappThreadDocument} from "./organizerWhatsappThreadDocument";
import {OrganizerWhatsappMessageDocument} from "./organizerWhatsappMessageDocument";
import {OrganizerWhatsappReplyOperationDocument} from "./organizerWhatsappReplyOperationDocument";
import {OrganizerClaimRequestDocument} from "./organizerClaimRequestDocument";
import {OrganizerScheduleLockDocument} from "./organizerScheduleLockDocument";
import {ClubPostDocument} from "./clubPostDocument";
import {ClubMembershipDocument} from "./clubMembershipDocument";
import {ClubHostClaimDocument} from "./clubHostClaimDocument";
import {ClubClaimRequestDocument} from "./clubClaimRequestDocument";
import {EventDocument} from "./eventDocument";
import {ExternalEventDocument} from "./externalEventDocument";
import {EventPrivateAccessDocument} from "./eventPrivateAccessDocument";
import {EventInviteLinkDocument} from "./eventInviteLinkDocument";
import {EventInviteLinkSecretDocument} from "./eventInviteLinkSecretDocument";
import {EventInviteTouchDocument} from "./eventInviteTouchDocument";
import {EventShareIntentDocument} from "./eventShareIntentDocument";
import {EventInviteAttributionDocument} from "./eventInviteAttributionDocument";
import {EventParticipationDocument} from "./eventParticipationDocument";
import {EventAttendeeDocument} from "./eventAttendeeDocument";
import {EventStaffGrantDocument} from "./eventStaffGrantDocument";
import {EventAttendeeAttendanceReceiptDocument} from "./eventAttendeeAttendanceReceiptDocument";
import {EventAttendeeImportDocument} from "./eventAttendeeImportDocument";
import {EventRosterHandoffDocument} from "./eventRosterHandoffDocument";
import {EventRuntimeParticipantDocument} from "./eventRuntimeParticipantDocument";
import {EventVenueSessionDocument} from "./eventVenueSessionDocument";
import {EventVenueSessionRedemptionDocument} from "./eventVenueSessionRedemptionDocument";
import {EventSuccessPresenceDocument} from "./eventSuccessPresenceDocument";
import {EventLivePositionDocument} from "./eventLivePositionDocument";
import {EventSuccessLateArrivalDocument} from "./eventSuccessLateArrivalDocument";
import {EventRehearsalDocument} from "./eventRehearsalDocument";
import {EventRehearsalActorDocument} from "./eventRehearsalActorDocument";
import {EventRehearsalActionDocument} from "./eventRehearsalActionDocument";
import {EventRehearsalGuestViewDocument} from "./eventRehearsalGuestViewDocument";
import {EventRuntimeClaimRequestDocument} from "./eventRuntimeClaimRequestDocument";
import {EventCrossPathsConsentDocument} from "./eventCrossPathsConsentDocument";
import {CrossPathsShowcaseEligibilityDocument} from "./crossPathsShowcaseEligibilityDocument";
import {CrossPathsSuggestionExposureDocument} from "./crossPathsSuggestionExposureDocument";
import {CrossPathsInvitationDocument} from "./crossPathsInvitationDocument";
import {CrossPathsPairHoldDocument} from "./crossPathsPairHoldDocument";
import {EventBroadcastDocument} from "./eventBroadcastDocument";
import {EventWaitlistOfferDocument} from "./eventWaitlistOfferDocument";
import {EventSuccessPlanDocument} from "./eventSuccessPlanDocument";
import {EventSuccessConversationGraphDocument} from "./eventSuccessConversationGraphDocument";
import {OrganizerEventSuccessLayoutDocument} from "./organizerEventSuccessLayoutDocument";
import {OrganizerEventVenueDocument} from "./organizerEventVenueDocument";
import {EventSuccessAssignmentDraftDocument} from "./eventSuccessAssignmentDraftDocument";
import {EventSuccessFeedbackDocument} from "./eventSuccessFeedbackDocument";
import {EventSuccessPreferenceDocument} from "./eventSuccessPreferenceDocument";
import {EventSuccessCompatibilityResponseDocument} from "./eventSuccessCompatibilityResponseDocument";
import {EventSuccessWingmanRequestDocument} from "./eventSuccessWingmanRequestDocument";
import {EventSuccessArrivalMissionDocument} from "./eventSuccessArrivalMissionDocument";
import {EventSuccessAssignmentDocument} from "./eventSuccessAssignmentDocument";
import {EventSuccessUnitOutcomesDocument} from "./eventSuccessUnitOutcomesDocument";
import {EventSuccessStandingsDocument} from "./eventSuccessStandingsDocument";
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
import {HostAnalyticsSnapshotDocument} from "./hostAnalyticsSnapshotDocument";
import {FunctionEventReceiptDocument} from "./functionEventReceiptDocument";
import {PublicRouteReservationDocument} from "./publicRouteReservationDocument";
import {SeedEventManifestDocument} from "./seedEventManifestDocument";
import {OrganizerIntakeReviewDecisionDocument} from "./organizerIntakeReviewDecisionDocument";
import {EventIntakeReviewDecisionDocument} from "./eventIntakeReviewDecisionDocument";
import {OrganizerIntakeCurationDecisionDocument} from "./organizerIntakeCurationDecisionDocument";
import {OrganizerIntakeFieldCorrectionDocument} from "./organizerIntakeFieldCorrectionDocument";
import {OrganizerEventCandidateReviewDecisionDocument} from "./organizerEventCandidateReviewDecisionDocument";
import {OrganizerEventLocationResolutionDecisionDocument} from "./organizerEventLocationResolutionDecisionDocument";
import {OrganizerPolicyGapReviewDecisionDocument} from "./organizerPolicyGapReviewDecisionDocument";
import {UpdateUserProfileCallablePayload} from "./updateUserProfileCallablePayload";
import {CreateClubCallablePayload} from "./createClubCallablePayload";
import {CreateOrganizerCallablePayload} from "./createOrganizerCallablePayload";
import {CreateOrganizerCallableResponse} from "./createOrganizerCallableResponse";
import {UpdateOrganizerCallablePayload} from "./updateOrganizerCallablePayload";
import {ArchiveOrganizerCallablePayload} from "./archiveOrganizerCallablePayload";
import {DeleteOrganizerCallablePayload} from "./deleteOrganizerCallablePayload";
import {CreateOrganizerPostCallablePayload} from "./createOrganizerPostCallablePayload";
import {CreateOrganizerPostCallableResponse} from "./createOrganizerPostCallableResponse";
import {RequestOrganizerClaimCallablePayload} from "./requestOrganizerClaimCallablePayload";
import {RequestOrganizerClaimCallableResponse} from "./requestOrganizerClaimCallableResponse";
import {AdminDecideOrganizerClaimCallablePayload} from "./adminDecideOrganizerClaimCallablePayload";
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
import {OrganizerFollowCallablePayload} from "./organizerFollowCallablePayload";
import {SetOrganizerNotificationPreferenceCallablePayload} from "./setOrganizerNotificationPreferenceCallablePayload";
import {AddOrganizerManagerCallablePayload} from "./addOrganizerManagerCallablePayload";
import {RemoveOrganizerManagerCallablePayload} from "./removeOrganizerManagerCallablePayload";
import {TransferOrganizerOwnershipCallablePayload} from "./transferOrganizerOwnershipCallablePayload";
import {RemoveClubHostCallablePayload} from "./removeClubHostCallablePayload";
import {TransferClubOwnershipCallablePayload} from "./transferClubOwnershipCallablePayload";
import {RequestClubClaimCallablePayload} from "./requestClubClaimCallablePayload";
import {RequestClubClaimCallableResponse} from "./requestClubClaimCallableResponse";
import {AdminDecideClubClaimCallablePayload} from "./adminDecideClubClaimCallablePayload";
import {AdminDecideOrganizerIntakeCallablePayload} from "./adminDecideOrganizerIntakeCallablePayload";
import {AdminRecordOrganizerCurationCallablePayload} from "./adminRecordOrganizerCurationCallablePayload";
import {AdminRecordEventIntakeReviewDecisionCallablePayload} from "./adminRecordEventIntakeReviewDecisionCallablePayload";
import {AdminListIntakeOperationsCallablePayload} from "./adminListIntakeOperationsCallablePayload";
import {AdminListActionExecutionsCallablePayload} from "./adminListActionExecutionsCallablePayload";
import {AdminRecordActionExecutionCallablePayload} from "./adminRecordActionExecutionCallablePayload";
import {AdminDecideOrganizerEventCandidateCallablePayload} from "./adminDecideOrganizerEventCandidateCallablePayload";
import {AdminDecideOrganizerPolicyGapCallablePayload} from "./adminDecideOrganizerPolicyGapCallablePayload";
import {AdminResolveOrganizerEventLocationCallablePayload} from "./adminResolveOrganizerEventLocationCallablePayload";
import {AdminSetClubIndexStatusCallablePayload} from "./adminSetClubIndexStatusCallablePayload";
import {AdminListCrossPathsShowcaseCandidatesCallablePayload} from "./adminListCrossPathsShowcaseCandidatesCallablePayload";
import {AdminSetCrossPathsShowcaseEligibilityCallablePayload} from "./adminSetCrossPathsShowcaseEligibilityCallablePayload";
import {AdminGetClubDetailsCallablePayload} from "./adminGetClubDetailsCallablePayload";
import {AdminListClubDetailsCallablePayload} from "./adminListClubDetailsCallablePayload";
import {AdminUpdateClubDetailsCallablePayload} from "./adminUpdateClubDetailsCallablePayload";
import {AdminGetOrganizerDetailsCallablePayload} from "./adminGetOrganizerDetailsCallablePayload";
import {AdminListOrganizerDetailsCallablePayload} from "./adminListOrganizerDetailsCallablePayload";
import {AdminUpdateOrganizerDetailsCallablePayload} from "./adminUpdateOrganizerDetailsCallablePayload";
import {AdminGetEventDetailsCallablePayload} from "./adminGetEventDetailsCallablePayload";
import {AdminListEventDetailsCallablePayload} from "./adminListEventDetailsCallablePayload";
import {AdminListExternalEventDetailsCallablePayload} from "./adminListExternalEventDetailsCallablePayload";
import {AdminUpdateEventDetailsCallablePayload} from "./adminUpdateEventDetailsCallablePayload";
import {AdminPublishExternalEventCallablePayload} from "./adminPublishExternalEventCallablePayload";
import {AdminTakedownExternalEventCallablePayload} from "./adminTakedownExternalEventCallablePayload";
import {StartClubHostConversationCallablePayload} from "./startClubHostConversationCallablePayload";
import {StartOrganizerConversationCallablePayload} from "./startOrganizerConversationCallablePayload";
import {StartOrganizerContactConversationCallablePayload} from "./startOrganizerContactConversationCallablePayload";
import {ArchiveClubCallablePayload} from "./archiveClubCallablePayload";
import {DeleteClubCallablePayload} from "./deleteClubCallablePayload";
import {ClubMembershipCallablePayload} from "./clubMembershipCallablePayload";
import {SetClubNotificationPreferenceCallablePayload} from "./setClubNotificationPreferenceCallablePayload";
import {CreateEventCallablePayload} from "./createEventCallablePayload";
import {UpdateEventCallablePayload} from "./updateEventCallablePayload";
import {CancelEventCallablePayload} from "./cancelEventCallablePayload";
import {DeleteEventCallablePayload} from "./deleteEventCallablePayload";
import {EventIdCallablePayload} from "./eventIdCallablePayload";
import {SetCrossPathsEventConsentCallablePayload} from "./setCrossPathsEventConsentCallablePayload";
import {GetCrossPathsSuggestionsCallablePayload} from "./getCrossPathsSuggestionsCallablePayload";
import {SendCrossPathsInvitationCallablePayload} from "./sendCrossPathsInvitationCallablePayload";
import {RespondCrossPathsInvitationCallablePayload} from "./respondCrossPathsInvitationCallablePayload";
import {CancelCrossPathsInvitationOrPlanCallablePayload} from "./cancelCrossPathsInvitationOrPlanCallablePayload";
import {CreateEventWaitlistOffersCallablePayload} from "./createEventWaitlistOffersCallablePayload";
import {CreateEventInviteLinkCallablePayload} from "./createEventInviteLinkCallablePayload";
import {DisableEventInviteLinkCallablePayload} from "./disableEventInviteLinkCallablePayload";
import {RecordEventInviteLinkOpenCallablePayload} from "./recordEventInviteLinkOpenCallablePayload";
import {ResolveEventInviteLandingCallablePayload} from "./resolveEventInviteLandingCallablePayload";
import {ResolveEventInviteLandingCallableResponse} from "./resolveEventInviteLandingCallableResponse";
import {GetEventInviteLinkTokenCallablePayload} from "./getEventInviteLinkTokenCallablePayload";
import {RecordEventShareIntentCallablePayload} from "./recordEventShareIntentCallablePayload";
import {UpsertOrganizerCampaignCallablePayload} from "./upsertOrganizerCampaignCallablePayload";
import {UpsertOrganizerSavedAudienceCallablePayload} from "./upsertOrganizerSavedAudienceCallablePayload";
import {ListOrganizerSavedAudiencesCallablePayload} from "./listOrganizerSavedAudiencesCallablePayload";
import {PreviewOrganizerSavedAudienceCallablePayload} from "./previewOrganizerSavedAudienceCallablePayload";
import {ResolveOrganizerAudienceMembersCallablePayload} from "./resolveOrganizerAudienceMembersCallablePayload";
import {ResolveOrganizerAudienceMembersCallableResponse} from "./resolveOrganizerAudienceMembersCallableResponse";
import {ArchiveOrganizerSavedAudienceCallablePayload} from "./archiveOrganizerSavedAudienceCallablePayload";
import {OrganizerSavedAudienceCallableResponse} from "./organizerSavedAudienceCallableResponse";
import {ListOrganizerSavedAudiencesCallableResponse} from "./listOrganizerSavedAudiencesCallableResponse";
import {PreviewOrganizerSavedAudienceCallableResponse} from "./previewOrganizerSavedAudienceCallableResponse";
import {PrepareOrganizerManualSendTaskCallablePayload} from "./prepareOrganizerManualSendTaskCallablePayload";
import {ListOrganizerManualSendTasksCallablePayload} from "./listOrganizerManualSendTasksCallablePayload";
import {OpenOrganizerManualSendTaskCallablePayload} from "./openOrganizerManualSendTaskCallablePayload";
import {ValidateOrganizerManualSendTaskLaunchCallablePayload} from "./validateOrganizerManualSendTaskLaunchCallablePayload";
import {MarkOrganizerManualSendTaskCallablePayload} from "./markOrganizerManualSendTaskCallablePayload";
import {ReplanOrganizerManualSendTasksCallablePayload} from "./replanOrganizerManualSendTasksCallablePayload";
import {OrganizerManualSendTaskCallableResponse} from "./organizerManualSendTaskCallableResponse";
import {ListOrganizerManualSendTasksCallableResponse} from "./listOrganizerManualSendTasksCallableResponse";
import {ReplanOrganizerManualSendTasksCallableResponse} from "./replanOrganizerManualSendTasksCallableResponse";
import {OrganizerCampaignActionCallablePayload} from "./organizerCampaignActionCallablePayload";
import {CompleteOrganizerWhatsappConnectionCallablePayload} from "./completeOrganizerWhatsappConnectionCallablePayload";
import {OrganizerSenderConnectionActionCallablePayload} from "./organizerSenderConnectionActionCallablePayload";
import {SendOrganizerWhatsappTestCallablePayload} from "./sendOrganizerWhatsappTestCallablePayload";
import {OrganizerCampaignCallableResponse} from "./organizerCampaignCallableResponse";
import {ListOrganizerCampaignsCallablePayload} from "./listOrganizerCampaignsCallablePayload";
import {ListOrganizerCampaignsCallableResponse} from "./listOrganizerCampaignsCallableResponse";
import {OrganizerMessagingSetupCallableResponse} from "./organizerMessagingSetupCallableResponse";
import {GetOrganizerProviderSetupCallablePayload} from "./getOrganizerProviderSetupCallablePayload";
import {ConnectOrganizerLumaProviderCallablePayload} from "./connectOrganizerLumaProviderCallablePayload";
import {ListOrganizerLumaEventsCallablePayload} from "./listOrganizerLumaEventsCallablePayload";
import {SyncOrganizerProviderEventCallablePayload} from "./syncOrganizerProviderEventCallablePayload";
import {DisconnectOrganizerProviderCallablePayload} from "./disconnectOrganizerProviderCallablePayload";
import {OrganizerProviderSetupCallableResponse} from "./organizerProviderSetupCallableResponse";
import {ListOrganizerLumaEventsCallableResponse} from "./listOrganizerLumaEventsCallableResponse";
import {SyncOrganizerProviderEventCallableResponse} from "./syncOrganizerProviderEventCallableResponse";
import {RecordOrganizerAnalyticsEventCallablePayload} from "./recordOrganizerAnalyticsEventCallablePayload";
import {RecordOrganizerAnalyticsEventCallableResponse} from "./recordOrganizerAnalyticsEventCallableResponse";
import {MarkEventAttendanceCallablePayload} from "./markEventAttendanceCallablePayload";
import {ImportEventAttendeesCallablePayload} from "./importEventAttendeesCallablePayload";
import {MarkEventAttendeeAttendanceCallablePayload} from "./markEventAttendeeAttendanceCallablePayload";
import {SetEventAttendeeAttendanceCallablePayload} from "./setEventAttendeeAttendanceCallablePayload";
import {SetEventAttendeeAttendanceCallableResponse} from "./setEventAttendeeAttendanceCallableResponse";
import {EventOperatorAccessCallablePayload} from "./eventOperatorAccessCallablePayload";
import {EventOperatorAccessCallableResponse} from "./eventOperatorAccessCallableResponse";
import {GrantEventStaffCallablePayload} from "./grantEventStaffCallablePayload";
import {RevokeEventStaffCallablePayload} from "./revokeEventStaffCallablePayload";
import {EventStaffListCallableResponse} from "./eventStaffListCallableResponse";
import {RegisterPublicEventCallablePayload} from "./registerPublicEventCallablePayload";
import {RegisterPublicEventCallableResponse} from "./registerPublicEventCallableResponse";
import {GetEventRuntimeBootstrapCallablePayload} from "./getEventRuntimeBootstrapCallablePayload";
import {CreateEventRehearsalCallablePayload} from "./createEventRehearsalCallablePayload";
import {CreateEventRehearsalCallableResponse} from "./createEventRehearsalCallableResponse";
import {GetEventRehearsalBootstrapCallablePayload} from "./getEventRehearsalBootstrapCallablePayload";
import {EventRehearsalBootstrapCallableResponse} from "./eventRehearsalBootstrapCallableResponse";
import {UpdateEventRehearsalSetupCallablePayload} from "./updateEventRehearsalSetupCallablePayload";
import {ControlEventRehearsalCallablePayload} from "./controlEventRehearsalCallablePayload";
import {InjectEventRehearsalBehaviorCallablePayload} from "./injectEventRehearsalBehaviorCallablePayload";
import {ControlEventRehearsalSpatialCallablePayload} from "./controlEventRehearsalSpatialCallablePayload";
import {ResetEventRehearsalCallablePayload} from "./resetEventRehearsalCallablePayload";
import {RotateEventRehearsalGuestLinkCallablePayload} from "./rotateEventRehearsalGuestLinkCallablePayload";
import {GetEventRehearsalGuestBootstrapCallablePayload} from "./getEventRehearsalGuestBootstrapCallablePayload";
import {EventRehearsalGuestBootstrapCallableResponse} from "./eventRehearsalGuestBootstrapCallableResponse";
import {SubmitEventRehearsalGuestActionCallablePayload} from "./submitEventRehearsalGuestActionCallablePayload";
import {EventRehearsalReproductionCallableResponse} from "./eventRehearsalReproductionCallableResponse";
import {UpsertEventSuccessLayoutCallablePayload} from "./upsertEventSuccessLayoutCallablePayload";
import {UpsertOrganizerEventVenueCallablePayload} from "./upsertOrganizerEventVenueCallablePayload";
import {UpsertOrganizerEventVenueCallableResponse} from "./upsertOrganizerEventVenueCallableResponse";
import {UpsertEventSuccessLayoutCallableResponse} from "./upsertEventSuccessLayoutCallableResponse";
import {GetEventSuccessSpatialLayoutCallablePayload} from "./getEventSuccessSpatialLayoutCallablePayload";
import {GetEventSuccessSpatialLayoutCallableResponse} from "./getEventSuccessSpatialLayoutCallableResponse";
import {EventSuccessSpatialActionCallablePayload} from "./eventSuccessSpatialActionCallablePayload";
import {EventSuccessSpatialActionCallableResponse} from "./eventSuccessSpatialActionCallableResponse";
import {GetEventRuntimeBootstrapCallableResponse} from "./getEventRuntimeBootstrapCallableResponse";
import {GetEventSuccessConversationGraphCallableResponse} from "./getEventSuccessConversationGraphCallableResponse";
import {SubmitEventSuccessConversationGraphCallablePayload} from "./submitEventSuccessConversationGraphCallablePayload";
import {SubmitEventSuccessConversationGraphCallableResponse} from "./submitEventSuccessConversationGraphCallableResponse";
import {ClaimEventRuntimeAccessCallablePayload} from "./claimEventRuntimeAccessCallablePayload";
import {ClaimEventRuntimeAccessCallableResponse} from "./claimEventRuntimeAccessCallableResponse";
import {SubmitEventRuntimeProfileCallablePayload} from "./submitEventRuntimeProfileCallablePayload";
import {SubmitEventRuntimeProfileCallableResponse} from "./submitEventRuntimeProfileCallableResponse";
import {CheckInEventRuntimeCallablePayload} from "./checkInEventRuntimeCallablePayload";
import {CheckInEventRuntimeCallableResponse} from "./checkInEventRuntimeCallableResponse";
import {CreateEventVenueSessionCallablePayload} from "./createEventVenueSessionCallablePayload";
import {CreateEventVenueSessionCallableResponse} from "./createEventVenueSessionCallableResponse";
import {ApproveEventRuntimeClaimCallablePayload} from "./approveEventRuntimeClaimCallablePayload";
import {ApproveEventRuntimeClaimCallableResponse} from "./approveEventRuntimeClaimCallableResponse";
import {CreateEventRosterHandoffCallablePayload} from "./createEventRosterHandoffCallablePayload";
import {CreateEventRosterHandoffCallableResponse} from "./createEventRosterHandoffCallableResponse";
import {GetOrganizerCrmSummaryCallablePayload} from "./getOrganizerCrmSummaryCallablePayload";
import {GetEventRosterInsightsCallablePayload} from "./getEventRosterInsightsCallablePayload";
import {GetEventRosterInsightsCallableResponse} from "./getEventRosterInsightsCallableResponse";
import {GetOrganizerCrmSummaryCallableResponse} from "./getOrganizerCrmSummaryCallableResponse";
import {ListOrganizerContactsCallablePayload} from "./listOrganizerContactsCallablePayload";
import {CreateOrganizerFormCallablePayload} from "./createOrganizerFormCallablePayload";
import {CreateOrganizerFormCallableResponse} from "./createOrganizerFormCallableResponse";
import {UpdateOrganizerFormDraftCallablePayload} from "./updateOrganizerFormDraftCallablePayload";
import {UpdateOrganizerFormDraftCallableResponse} from "./updateOrganizerFormDraftCallableResponse";
import {GetOrganizerFormEditorCallablePayload} from "./getOrganizerFormEditorCallablePayload";
import {GetOrganizerFormEditorCallableResponse} from "./getOrganizerFormEditorCallableResponse";
import {ListOrganizerFormsCallablePayload} from "./listOrganizerFormsCallablePayload";
import {ListOrganizerFormsCallableResponse} from "./listOrganizerFormsCallableResponse";
import {ValidateOrganizerFormDraftCallablePayload} from "./validateOrganizerFormDraftCallablePayload";
import {ValidateOrganizerFormDraftCallableResponse} from "./validateOrganizerFormDraftCallableResponse";
import {PublishOrganizerFormCallablePayload} from "./publishOrganizerFormCallablePayload";
import {PublishOrganizerFormCallableResponse} from "./publishOrganizerFormCallableResponse";
import {SetOrganizerFormLifecycleCallablePayload} from "./setOrganizerFormLifecycleCallablePayload";
import {SetOrganizerFormLifecycleCallableResponse} from "./setOrganizerFormLifecycleCallableResponse";
import {DuplicateOrganizerFormCallablePayload} from "./duplicateOrganizerFormCallablePayload";
import {DuplicateOrganizerFormCallableResponse} from "./duplicateOrganizerFormCallableResponse";
import {DeleteOrganizerFormDraftCallablePayload} from "./deleteOrganizerFormDraftCallablePayload";
import {DeleteOrganizerFormDraftCallableResponse} from "./deleteOrganizerFormDraftCallableResponse";
import {ListOrganizerFormTemplatesCallablePayload} from "./listOrganizerFormTemplatesCallablePayload";
import {ListOrganizerFormTemplatesCallableResponse} from "./listOrganizerFormTemplatesCallableResponse";
import {GetPublicOrganizerFormCallablePayload} from "./getPublicOrganizerFormCallablePayload";
import {GetPublicOrganizerFormCallableResponse} from "./getPublicOrganizerFormCallableResponse";
import {BeginOrganizerFormResponseCallablePayload} from "./beginOrganizerFormResponseCallablePayload";
import {BeginOrganizerFormResponseCallableResponse} from "./beginOrganizerFormResponseCallableResponse";
import {SaveOrganizerFormResponseDraftCallablePayload} from "./saveOrganizerFormResponseDraftCallablePayload";
import {SaveOrganizerFormResponseDraftCallableResponse} from "./saveOrganizerFormResponseDraftCallableResponse";
import {CreateOrganizerFormAssetIntentCallablePayload} from "./createOrganizerFormAssetIntentCallablePayload";
import {CreateOrganizerFormAssetIntentCallableResponse} from "./createOrganizerFormAssetIntentCallableResponse";
import {FinalizeOrganizerFormAssetCallablePayload} from "./finalizeOrganizerFormAssetCallablePayload";
import {FinalizeOrganizerFormAssetCallableResponse} from "./finalizeOrganizerFormAssetCallableResponse";
import {SubmitOrganizerFormResponseCallablePayload} from "./submitOrganizerFormResponseCallablePayload";
import {SubmitOrganizerFormResponseCallableResponse} from "./submitOrganizerFormResponseCallableResponse";
import {WithdrawOrganizerFormResponseCallablePayload} from "./withdrawOrganizerFormResponseCallablePayload";
import {WithdrawOrganizerFormResponseCallableResponse} from "./withdrawOrganizerFormResponseCallableResponse";
import {CreateOrganizerFormShareLinkCallablePayload} from "./createOrganizerFormShareLinkCallablePayload";
import {CreateOrganizerFormShareLinkCallableResponse} from "./createOrganizerFormShareLinkCallableResponse";
import {GetOrganizerFormShareAssetsCallablePayload} from "./getOrganizerFormShareAssetsCallablePayload";
import {GetOrganizerFormShareAssetsCallableResponse} from "./getOrganizerFormShareAssetsCallableResponse";
import {ListOrganizerFormResponsesCallablePayload} from "./listOrganizerFormResponsesCallablePayload";
import {ListOrganizerFormResponsesCallableResponse} from "./listOrganizerFormResponsesCallableResponse";
import {GetOrganizerFormResponseDetailCallablePayload} from "./getOrganizerFormResponseDetailCallablePayload";
import {GetOrganizerFormResponseDetailCallableResponse} from "./getOrganizerFormResponseDetailCallableResponse";
import {GetOrganizerFormAnalyticsCallablePayload} from "./getOrganizerFormAnalyticsCallablePayload";
import {GetOrganizerFormAnalyticsCallableResponse} from "./getOrganizerFormAnalyticsCallableResponse";
import {RequestOrganizerFormExportCallablePayload} from "./requestOrganizerFormExportCallablePayload";
import {RequestOrganizerFormExportCallableResponse} from "./requestOrganizerFormExportCallableResponse";
import {CreateOrganizerFormAutomationCallablePayload} from "./createOrganizerFormAutomationCallablePayload";
import {CreateOrganizerFormAutomationCallableResponse} from "./createOrganizerFormAutomationCallableResponse";
import {SetOrganizerFormAutomationStateCallablePayload} from "./setOrganizerFormAutomationStateCallablePayload";
import {SetOrganizerFormAutomationStateCallableResponse} from "./setOrganizerFormAutomationStateCallableResponse";
import {ListOrganizerFormAutomationRunsCallablePayload} from "./listOrganizerFormAutomationRunsCallablePayload";
import {ListOrganizerFormAutomationRunsCallableResponse} from "./listOrganizerFormAutomationRunsCallableResponse";
import {PreviewOrganizerFormConversionCallablePayload} from "./previewOrganizerFormConversionCallablePayload";
import {PreviewOrganizerFormConversionCallableResponse} from "./previewOrganizerFormConversionCallableResponse";
import {ConvertOrganizerFormResponseCallablePayload} from "./convertOrganizerFormResponseCallablePayload";
import {ConvertOrganizerFormResponseCallableResponse} from "./convertOrganizerFormResponseCallableResponse";
import {PublishOrganizerApplicationFormCallablePayload} from "./publishOrganizerApplicationFormCallablePayload";
import {GetParticipantOrganizerApplicationFormCallablePayload} from "./getParticipantOrganizerApplicationFormCallablePayload";
import {GetParticipantOrganizerApplicationFormCallableResponse} from "./getParticipantOrganizerApplicationFormCallableResponse";
import {SubmitParticipantOrganizerApplicationCallablePayload} from "./submitParticipantOrganizerApplicationCallablePayload";
import {SubmitParticipantOrganizerApplicationCallableResponse} from "./submitParticipantOrganizerApplicationCallableResponse";
import {RevokeParticipantOrganizerDataGrantCallablePayload} from "./revokeParticipantOrganizerDataGrantCallablePayload";
import {RevokeParticipantOrganizerDataGrantCallableResponse} from "./revokeParticipantOrganizerDataGrantCallableResponse";
import {PublishOrganizerApplicationFormCallableResponse} from "./publishOrganizerApplicationFormCallableResponse";
import {PreviewOrganizerApplicationImportCallablePayload} from "./previewOrganizerApplicationImportCallablePayload";
import {PreviewOrganizerApplicationImportCallableResponse} from "./previewOrganizerApplicationImportCallableResponse";
import {ImportOrganizerApplicationsCallablePayload} from "./importOrganizerApplicationsCallablePayload";
import {ImportOrganizerApplicationsCallableResponse} from "./importOrganizerApplicationsCallableResponse";
import {ListOrganizerApplicationsCallablePayload} from "./listOrganizerApplicationsCallablePayload";
import {ListOrganizerApplicationsCallableResponse} from "./listOrganizerApplicationsCallableResponse";
import {ListOrganizerAttentionItemsCallablePayload} from "./listOrganizerAttentionItemsCallablePayload";
import {ListOrganizerAttentionItemsCallableResponse} from "./listOrganizerAttentionItemsCallableResponse";
import {GetOrganizerApplicationDetailCallablePayload} from "./getOrganizerApplicationDetailCallablePayload";
import {GetOrganizerApplicationDetailCallableResponse} from "./getOrganizerApplicationDetailCallableResponse";
import {ReviewOrganizerApplicationCallablePayload} from "./reviewOrganizerApplicationCallablePayload";
import {ReviewOrganizerApplicationCallableResponse} from "./reviewOrganizerApplicationCallableResponse";
import {CreateOrganizerContactCallablePayload} from "./createOrganizerContactCallablePayload";
import {CreateOrganizerContactCallableResponse} from "./createOrganizerContactCallableResponse";
import {ListOrganizerContactsCallableResponse} from "./listOrganizerContactsCallableResponse";
import {GetOrganizerContactDetailCallablePayload} from "./getOrganizerContactDetailCallablePayload";
import {GetOrganizerContactDetailCallableResponse} from "./getOrganizerContactDetailCallableResponse";
import {ResolveOrganizerCommunicationPlanCallablePayload} from "./resolveOrganizerCommunicationPlanCallablePayload";
import {ResolveOrganizerCommunicationPlanCallableResponse} from "./resolveOrganizerCommunicationPlanCallableResponse";
import {MutateOrganizerContactCallablePayload} from "./mutateOrganizerContactCallablePayload";
import {MutateOrganizerContactCallableResponse} from "./mutateOrganizerContactCallableResponse";
import {CreateOrganizerContactNoteCallablePayload} from "./createOrganizerContactNoteCallablePayload";
import {MutateOrganizerContactNoteCallablePayload} from "./mutateOrganizerContactNoteCallablePayload";
import {OrganizerContactNoteCallableResponse} from "./organizerContactNoteCallableResponse";
import {ExportOrganizerContactsCallablePayload} from "./exportOrganizerContactsCallablePayload";
import {ExportOrganizerContactsCallableResponse} from "./exportOrganizerContactsCallableResponse";
import {MergeOrganizerContactsCallablePayload} from "./mergeOrganizerContactsCallablePayload";
import {ListOrganizerContactMergeCandidatesCallablePayload} from "./listOrganizerContactMergeCandidatesCallablePayload";
import {ListOrganizerContactMergeCandidatesCallableResponse} from "./listOrganizerContactMergeCandidatesCallableResponse";
import {ReviewOrganizerContactMergeCandidateCallablePayload} from "./reviewOrganizerContactMergeCandidateCallablePayload";
import {ReviewOrganizerContactMergeCandidateCallableResponse} from "./reviewOrganizerContactMergeCandidateCallableResponse";
import {ListOrganizerWhatsappThreadsCallablePayload} from "./listOrganizerWhatsappThreadsCallablePayload";
import {ListOrganizerWhatsappThreadsCallableResponse} from "./listOrganizerWhatsappThreadsCallableResponse";
import {GetOrganizerWhatsappThreadCallablePayload} from "./getOrganizerWhatsappThreadCallablePayload";
import {GetOrganizerWhatsappThreadCallableResponse} from "./getOrganizerWhatsappThreadCallableResponse";
import {SendOrganizerWhatsappReplyCallablePayload} from "./sendOrganizerWhatsappReplyCallablePayload";
import {SendOrganizerWhatsappReplyCallableResponse} from "./sendOrganizerWhatsappReplyCallableResponse";
import {UnmergeOrganizerContactsCallablePayload} from "./unmergeOrganizerContactsCallablePayload";
import {MutateOrganizerContactMergeCallableResponse} from "./mutateOrganizerContactMergeCallableResponse";
import {EventJoinRequestDecisionCallablePayload} from "./eventJoinRequestDecisionCallablePayload";
import {OverrideEventSuccessRotationsCallablePayload} from "./overrideEventSuccessRotationsCallablePayload";
import {PrepareEventSuccessRotationDraftCallablePayload} from "./prepareEventSuccessRotationDraftCallablePayload";
import {PublishEventSuccessRotationRoundCallablePayload} from "./publishEventSuccessRotationRoundCallablePayload";
import {EventSuccessLiveActionCallablePayload} from "./eventSuccessLiveActionCallablePayload";
import {SetEventSuccessAccountabilityResolutionCallablePayload} from "./setEventSuccessAccountabilityResolutionCallablePayload";
import {RecordEventSuccessUnitOutcomesCallablePayload} from "./recordEventSuccessUnitOutcomesCallablePayload";
import {RecordEventSuccessUnitOutcomesCallableResponse} from "./recordEventSuccessUnitOutcomesCallableResponse";
import {HeartbeatEventSuccessPresenceCallablePayload} from "./heartbeatEventSuccessPresenceCallablePayload";
import {HeartbeatEventSuccessPresenceCallableResponse} from "./heartbeatEventSuccessPresenceCallableResponse";
import {PublishEventLivePositionCallablePayload} from "./publishEventLivePositionCallablePayload";
import {PublishEventLivePositionCallableResponse} from "./publishEventLivePositionCallableResponse";
import {GetEventSuccessPresenceSummaryCallableResponse} from "./getEventSuccessPresenceSummaryCallableResponse";
import {ResolveEventSuccessLateArrivalCallablePayload} from "./resolveEventSuccessLateArrivalCallablePayload";
import {ResolveEventSuccessLateArrivalCallableResponse} from "./resolveEventSuccessLateArrivalCallableResponse";
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
import {CreatePublicOrganizerReviewCallablePayload} from "./createPublicOrganizerReviewCallablePayload";
import {CreatePublicOrganizerReviewCallableResponse} from "./createPublicOrganizerReviewCallableResponse";
import {ListPublicOrganizerReviewsCallablePayload} from "./listPublicOrganizerReviewsCallablePayload";
import {ListPublicOrganizerReviewsCallableResponse} from "./listPublicOrganizerReviewsCallableResponse";
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
import {CreateRazorpayHostPaymentAccountCallablePayload} from "./createRazorpayHostPaymentAccountCallablePayload";
import {RefreshRazorpayHostPaymentAccountCallablePayload} from "./refreshRazorpayHostPaymentAccountCallablePayload";
import {StripeHostOnboardingLinkCallableResponse} from "./stripeHostOnboardingLinkCallableResponse";
import {PlacesAutocompleteCallablePayload} from "./placesAutocompleteCallablePayload";
import {PlacesAutocompleteCallableResponse} from "./placesAutocompleteCallableResponse";
import {PlaceDetailsCallablePayload} from "./placeDetailsCallablePayload";
import {PlaceDetailsCallableResponse} from "./placeDetailsCallableResponse";
import {ExploreSearchCallablePayload} from "./exploreSearchCallablePayload";
import {ExploreSearchCallableResponse} from "./exploreSearchCallableResponse";
import {WebsiteHostListingProjection} from "./websiteHostListingProjection";
import {FetchEventSuccessWingmanCandidatesCallableResponse} from "./fetchEventSuccessWingmanCandidatesCallableResponse";
import {FetchSwipeCandidatesCallableResponse} from "./fetchSwipeCandidatesCallableResponse";
import {SetCrossPathsEventConsentCallableResponse} from "./setCrossPathsEventConsentCallableResponse";
import {GetCrossPathsSuggestionsCallableResponse} from "./getCrossPathsSuggestionsCallableResponse";
import {SendCrossPathsInvitationCallableResponse} from "./sendCrossPathsInvitationCallableResponse";
import {RespondCrossPathsInvitationCallableResponse} from "./respondCrossPathsInvitationCallableResponse";
import {CancelCrossPathsInvitationOrPlanCallableResponse} from "./cancelCrossPathsInvitationOrPlanCallableResponse";
import {CreateProfileDecisionClientWrite} from "./createProfileDecisionClientWrite";
import {CreateChatMessageClientWrite} from "./createChatMessageClientWrite";
import {CreateSavedEventClientWrite} from "./createSavedEventClientWrite";
import {DeleteSavedEventClientWrite} from "./deleteSavedEventClientWrite";
import {MarkNotificationReadClientWrite} from "./markNotificationReadClientWrite";
import {ResetMatchUnreadCountClientWrite} from "./resetMatchUnreadCountClientWrite";
import {AdminGetOverviewCallablePayload} from "./adminGetOverviewCallablePayload";
import {AdminGetOverviewCallableResponse} from "./adminGetOverviewCallableResponse";
import {AdminDecideAccessApplicationCallablePayload} from "./adminDecideAccessApplicationCallablePayload";
import {AdminDecideAccessApplicationCallableResponse} from "./adminDecideAccessApplicationCallableResponse";
import {AdminSetAdminUserRolesCallablePayload} from "./adminSetAdminUserRolesCallablePayload";
import {AdminSetAdminUserRolesCallableResponse} from "./adminSetAdminUserRolesCallableResponse";
import {AdminDecideSafetyTriageItemCallablePayload} from "./adminDecideSafetyTriageItemCallablePayload";
import {AdminDecideSafetyTriageItemCallableResponse} from "./adminDecideSafetyTriageItemCallableResponse";
import {AdminAssignSafetyTriageItemCallablePayload} from "./adminAssignSafetyTriageItemCallablePayload";
import {AdminAssignSafetyTriageItemCallableResponse} from "./adminAssignSafetyTriageItemCallableResponse";
import {AdminCreateOrganizerDraftFromCandidateCallablePayload} from "./adminCreateOrganizerDraftFromCandidateCallablePayload";
import {AdminCreateOrganizerDraftFromCandidateCallableResponse} from "./adminCreateOrganizerDraftFromCandidateCallableResponse";
import {AdminCreateMarketingContentDraftCallablePayload} from "./adminCreateMarketingContentDraftCallablePayload";
import {AdminCreateMarketingContentDraftCallableResponse} from "./adminCreateMarketingContentDraftCallableResponse";
import {AdminRecordMarketingReviewDecisionCallablePayload} from "./adminRecordMarketingReviewDecisionCallablePayload";
import {AdminRecordMarketingReviewDecisionCallableResponse} from "./adminRecordMarketingReviewDecisionCallableResponse";
import {AdminListCrossPathsShowcaseCandidatesCallableResponse} from "./adminListCrossPathsShowcaseCandidatesCallableResponse";
import {AdminSetCrossPathsShowcaseEligibilityCallableResponse} from "./adminSetCrossPathsShowcaseEligibilityCallableResponse";
import {JoinWaitlistHTTPRequest} from "./joinWaitlistHttpRequest";
import {JoinWaitlistHTTPResponse} from "./joinWaitlistHttpResponse";
import {
  mobileFormStateSchema,
  operationRunSchema,
  operationWorkItemSchema,
  profilePromptAnswerSchema,
  photoPromptAnswerSchema,
  profilePhotoSchema,
  uploadedPhotoSchema,
  eventOriginSchema,
  eventRuntimeAccessSchema,
  activityPreferencesSchema,
  organizerSupplyCapabilitiesSchema,
  externalEventBlockerResolutionSchema,
  externalEventPublicationReceiptDocumentSchema,
  configCitiesDocumentSchema,
  onboardingDraftDocumentSchema,
  accessApplicationDocumentSchema,
  userProfileDocumentSchema,
  publicProfileDocumentSchema,
  hostProfileDocumentSchema,
  clubDocumentSchema,
  organizerDocumentSchema,
  organizerPostDocumentSchema,
  organizerPostDeliveryOperationDocumentSchema,
  organizerPostDeliveryRecipientDocumentSchema,
  organizerTeamMembershipDocumentSchema,
  organizerFollowDocumentSchema,
  organizerCommunicationPreferenceDocumentSchema,
  organizerCommunicationPermissionReceiptDocumentSchema,
  organizerContactDocumentSchema,
  organizerContactOriginDocumentSchema,
  organizerContactNoteDocumentSchema,
  organizerContactTagVocabularyDocumentSchema,
  organizerSavedAudienceDocumentSchema,
  organizerManualSendTaskDocumentSchema,
  organizerAttentionItemDocumentSchema,
  organizerContactIdentityLinkDocumentSchema,
  organizerContactIdentityClaimDocumentSchema,
  organizerContactEventEdgeDocumentSchema,
  organizerContactTraitDocumentSchema,
  organizerAudienceSummaryDocumentSchema,
  organizerAudienceProjectionReceiptDocumentSchema,
  organizerContactMergeReceiptDocumentSchema,
  organizerContactMergeReviewDecisionDocumentSchema,
  organizerSenderConnectionDocumentSchema,
  organizerProviderConnectionDocumentSchema,
  organizerApplicationFormDocumentSchema,
  organizerApplicationFormVersionDocumentSchema,
  organizerFormDocumentSchema,
  organizerFormDraftDocumentSchema,
  organizerFormVersionDocumentSchema,
  organizerFormResponseDraftDocumentSchema,
  organizerFormResponseDocumentSchema,
  organizerFormAssetDocumentSchema,
  organizerFormAggregateDocumentSchema,
  organizerFormAggregateEventDocumentSchema,
  organizerFormExportDocumentSchema,
  organizerFormAutomationRuleDocumentSchema,
  organizerFormAutomationRunDocumentSchema,
  organizerFormConversionReceiptDocumentSchema,
  organizerFormShareLinkDocumentSchema,
  organizerApplicationDocumentSchema,
  organizerApplicationResponseDocumentSchema,
  organizerApplicationAssetDocumentSchema,
  organizerApplicationSourceMappingDocumentSchema,
  organizerApplicationImportReceiptDocumentSchema,
  participantIntakeProfileDocumentSchema,
  participantOrganizerDataGrantDocumentSchema,
  externalEventMappingDocumentSchema,
  providerSyncRunDocumentSchema,
  organizerMessageTemplateDocumentSchema,
  organizerContactChannelStateDocumentSchema,
  organizerCampaignDocumentSchema,
  organizerBroadcastSummaryDocumentSchema,
  organizerCampaignRecipientDocumentSchema,
  organizerCampaignWebhookReceiptDocumentSchema,
  organizerMessagingWebhookEventDocumentSchema,
  organizerWhatsappThreadDocumentSchema,
  organizerWhatsappMessageDocumentSchema,
  organizerWhatsappReplyOperationDocumentSchema,
  organizerClaimRequestDocumentSchema,
  organizerScheduleLockDocumentSchema,
  clubPostDocumentSchema,
  clubMembershipDocumentSchema,
  clubHostClaimDocumentSchema,
  clubClaimRequestDocumentSchema,
  eventDocumentSchema,
  externalEventDocumentSchema,
  eventPrivateAccessDocumentSchema,
  eventInviteLinkDocumentSchema,
  eventInviteLinkSecretDocumentSchema,
  eventInviteTouchDocumentSchema,
  eventShareIntentDocumentSchema,
  eventInviteAttributionDocumentSchema,
  eventParticipationDocumentSchema,
  eventAttendeeDocumentSchema,
  eventStaffGrantDocumentSchema,
  eventAttendeeAttendanceReceiptDocumentSchema,
  eventAttendeeImportDocumentSchema,
  eventRosterHandoffDocumentSchema,
  eventRuntimeParticipantDocumentSchema,
  eventVenueSessionDocumentSchema,
  eventVenueSessionRedemptionDocumentSchema,
  eventSuccessPresenceDocumentSchema,
  eventLivePositionDocumentSchema,
  eventSuccessLateArrivalDocumentSchema,
  eventRehearsalDocumentSchema,
  eventRehearsalActorDocumentSchema,
  eventRehearsalActionDocumentSchema,
  eventRehearsalGuestViewDocumentSchema,
  eventRuntimeClaimRequestDocumentSchema,
  eventCrossPathsConsentDocumentSchema,
  crossPathsShowcaseEligibilityDocumentSchema,
  crossPathsSuggestionExposureDocumentSchema,
  crossPathsInvitationDocumentSchema,
  crossPathsPairHoldDocumentSchema,
  eventBroadcastDocumentSchema,
  eventWaitlistOfferDocumentSchema,
  eventSuccessPlanDocumentSchema,
  eventSuccessConversationGraphDocumentSchema,
  organizerEventSuccessLayoutDocumentSchema,
  organizerEventVenueDocumentSchema,
  eventSuccessAssignmentDraftDocumentSchema,
  eventSuccessFeedbackDocumentSchema,
  eventSuccessPreferenceDocumentSchema,
  eventSuccessCompatibilityResponseDocumentSchema,
  eventSuccessWingmanRequestDocumentSchema,
  eventSuccessArrivalMissionDocumentSchema,
  eventSuccessAssignmentDocumentSchema,
  eventSuccessUnitOutcomesDocumentSchema,
  eventSuccessStandingsDocumentSchema,
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
  hostAnalyticsSnapshotDocumentSchema,
  functionEventReceiptDocumentSchema,
  publicRouteReservationDocumentSchema,
  seedEventManifestDocumentSchema,
  organizerIntakeReviewDecisionDocumentSchema,
  eventIntakeReviewDecisionDocumentSchema,
  organizerIntakeCurationDecisionDocumentSchema,
  organizerIntakeFieldCorrectionDocumentSchema,
  organizerEventCandidateReviewDecisionDocumentSchema,
  organizerEventLocationResolutionDecisionDocumentSchema,
  organizerPolicyGapReviewDecisionDocumentSchema,
  updateUserProfileCallablePayloadSchema,
  createClubCallablePayloadSchema,
  createOrganizerCallablePayloadSchema,
  createOrganizerCallableResponseSchema,
  updateOrganizerCallablePayloadSchema,
  archiveOrganizerCallablePayloadSchema,
  deleteOrganizerCallablePayloadSchema,
  createOrganizerPostCallablePayloadSchema,
  createOrganizerPostCallableResponseSchema,
  requestOrganizerClaimCallablePayloadSchema,
  requestOrganizerClaimCallableResponseSchema,
  adminDecideOrganizerClaimCallablePayloadSchema,
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
  organizerFollowCallablePayloadSchema,
  setOrganizerNotificationPreferenceCallablePayloadSchema,
  addOrganizerManagerCallablePayloadSchema,
  removeOrganizerManagerCallablePayloadSchema,
  transferOrganizerOwnershipCallablePayloadSchema,
  removeClubHostCallablePayloadSchema,
  transferClubOwnershipCallablePayloadSchema,
  requestClubClaimCallablePayloadSchema,
  requestClubClaimCallableResponseSchema,
  adminDecideClubClaimCallablePayloadSchema,
  adminDecideOrganizerIntakeCallablePayloadSchema,
  adminRecordOrganizerCurationCallablePayloadSchema,
  adminRecordEventIntakeReviewDecisionCallablePayloadSchema,
  adminListIntakeOperationsCallablePayloadSchema,
  adminListActionExecutionsCallablePayloadSchema,
  adminRecordActionExecutionCallablePayloadSchema,
  adminDecideOrganizerEventCandidateCallablePayloadSchema,
  adminDecideOrganizerPolicyGapCallablePayloadSchema,
  adminResolveOrganizerEventLocationCallablePayloadSchema,
  adminSetClubIndexStatusCallablePayloadSchema,
  adminListCrossPathsShowcaseCandidatesCallablePayloadSchema,
  adminSetCrossPathsShowcaseEligibilityCallablePayloadSchema,
  adminGetClubDetailsCallablePayloadSchema,
  adminListClubDetailsCallablePayloadSchema,
  adminUpdateClubDetailsCallablePayloadSchema,
  adminGetOrganizerDetailsCallablePayloadSchema,
  adminListOrganizerDetailsCallablePayloadSchema,
  adminUpdateOrganizerDetailsCallablePayloadSchema,
  adminGetEventDetailsCallablePayloadSchema,
  adminListEventDetailsCallablePayloadSchema,
  adminListExternalEventDetailsCallablePayloadSchema,
  adminUpdateEventDetailsCallablePayloadSchema,
  adminPublishExternalEventCallablePayloadSchema,
  adminTakedownExternalEventCallablePayloadSchema,
  startClubHostConversationCallablePayloadSchema,
  startOrganizerConversationCallablePayloadSchema,
  startOrganizerContactConversationCallablePayloadSchema,
  archiveClubCallablePayloadSchema,
  deleteClubCallablePayloadSchema,
  clubMembershipCallablePayloadSchema,
  setClubNotificationPreferenceCallablePayloadSchema,
  createEventCallablePayloadSchema,
  updateEventCallablePayloadSchema,
  cancelEventCallablePayloadSchema,
  deleteEventCallablePayloadSchema,
  eventIdCallablePayloadSchema,
  setCrossPathsEventConsentCallablePayloadSchema,
  getCrossPathsSuggestionsCallablePayloadSchema,
  sendCrossPathsInvitationCallablePayloadSchema,
  respondCrossPathsInvitationCallablePayloadSchema,
  cancelCrossPathsInvitationOrPlanCallablePayloadSchema,
  createEventWaitlistOffersCallablePayloadSchema,
  createEventInviteLinkCallablePayloadSchema,
  disableEventInviteLinkCallablePayloadSchema,
  recordEventInviteLinkOpenCallablePayloadSchema,
  resolveEventInviteLandingCallablePayloadSchema,
  resolveEventInviteLandingCallableResponseSchema,
  getEventInviteLinkTokenCallablePayloadSchema,
  recordEventShareIntentCallablePayloadSchema,
  upsertOrganizerCampaignCallablePayloadSchema,
  upsertOrganizerSavedAudienceCallablePayloadSchema,
  listOrganizerSavedAudiencesCallablePayloadSchema,
  previewOrganizerSavedAudienceCallablePayloadSchema,
  resolveOrganizerAudienceMembersCallablePayloadSchema,
  resolveOrganizerAudienceMembersCallableResponseSchema,
  archiveOrganizerSavedAudienceCallablePayloadSchema,
  organizerSavedAudienceCallableResponseSchema,
  listOrganizerSavedAudiencesCallableResponseSchema,
  previewOrganizerSavedAudienceCallableResponseSchema,
  prepareOrganizerManualSendTaskCallablePayloadSchema,
  listOrganizerManualSendTasksCallablePayloadSchema,
  openOrganizerManualSendTaskCallablePayloadSchema,
  validateOrganizerManualSendTaskLaunchCallablePayloadSchema,
  markOrganizerManualSendTaskCallablePayloadSchema,
  replanOrganizerManualSendTasksCallablePayloadSchema,
  organizerManualSendTaskCallableResponseSchema,
  listOrganizerManualSendTasksCallableResponseSchema,
  replanOrganizerManualSendTasksCallableResponseSchema,
  organizerCampaignActionCallablePayloadSchema,
  completeOrganizerWhatsappConnectionCallablePayloadSchema,
  organizerSenderConnectionActionCallablePayloadSchema,
  sendOrganizerWhatsappTestCallablePayloadSchema,
  organizerCampaignCallableResponseSchema,
  listOrganizerCampaignsCallablePayloadSchema,
  listOrganizerCampaignsCallableResponseSchema,
  organizerMessagingSetupCallableResponseSchema,
  getOrganizerProviderSetupCallablePayloadSchema,
  connectOrganizerLumaProviderCallablePayloadSchema,
  listOrganizerLumaEventsCallablePayloadSchema,
  syncOrganizerProviderEventCallablePayloadSchema,
  disconnectOrganizerProviderCallablePayloadSchema,
  organizerProviderSetupCallableResponseSchema,
  listOrganizerLumaEventsCallableResponseSchema,
  syncOrganizerProviderEventCallableResponseSchema,
  recordOrganizerAnalyticsEventCallablePayloadSchema,
  recordOrganizerAnalyticsEventCallableResponseSchema,
  markEventAttendanceCallablePayloadSchema,
  importEventAttendeesCallablePayloadSchema,
  markEventAttendeeAttendanceCallablePayloadSchema,
  setEventAttendeeAttendanceCallablePayloadSchema,
  setEventAttendeeAttendanceCallableResponseSchema,
  eventOperatorAccessCallablePayloadSchema,
  eventOperatorAccessCallableResponseSchema,
  grantEventStaffCallablePayloadSchema,
  revokeEventStaffCallablePayloadSchema,
  eventStaffListCallableResponseSchema,
  registerPublicEventCallablePayloadSchema,
  registerPublicEventCallableResponseSchema,
  getEventRuntimeBootstrapCallablePayloadSchema,
  createEventRehearsalCallablePayloadSchema,
  createEventRehearsalCallableResponseSchema,
  getEventRehearsalBootstrapCallablePayloadSchema,
  eventRehearsalBootstrapCallableResponseSchema,
  updateEventRehearsalSetupCallablePayloadSchema,
  controlEventRehearsalCallablePayloadSchema,
  injectEventRehearsalBehaviorCallablePayloadSchema,
  controlEventRehearsalSpatialCallablePayloadSchema,
  resetEventRehearsalCallablePayloadSchema,
  rotateEventRehearsalGuestLinkCallablePayloadSchema,
  getEventRehearsalGuestBootstrapCallablePayloadSchema,
  eventRehearsalGuestBootstrapCallableResponseSchema,
  submitEventRehearsalGuestActionCallablePayloadSchema,
  eventRehearsalReproductionCallableResponseSchema,
  upsertEventSuccessLayoutCallablePayloadSchema,
  upsertOrganizerEventVenueCallablePayloadSchema,
  upsertOrganizerEventVenueCallableResponseSchema,
  upsertEventSuccessLayoutCallableResponseSchema,
  getEventSuccessSpatialLayoutCallablePayloadSchema,
  getEventSuccessSpatialLayoutCallableResponseSchema,
  eventSuccessSpatialActionCallablePayloadSchema,
  eventSuccessSpatialActionCallableResponseSchema,
  getEventRuntimeBootstrapCallableResponseSchema,
  getEventSuccessConversationGraphCallableResponseSchema,
  submitEventSuccessConversationGraphCallablePayloadSchema,
  submitEventSuccessConversationGraphCallableResponseSchema,
  claimEventRuntimeAccessCallablePayloadSchema,
  claimEventRuntimeAccessCallableResponseSchema,
  submitEventRuntimeProfileCallablePayloadSchema,
  submitEventRuntimeProfileCallableResponseSchema,
  checkInEventRuntimeCallablePayloadSchema,
  checkInEventRuntimeCallableResponseSchema,
  createEventVenueSessionCallablePayloadSchema,
  createEventVenueSessionCallableResponseSchema,
  approveEventRuntimeClaimCallablePayloadSchema,
  approveEventRuntimeClaimCallableResponseSchema,
  createEventRosterHandoffCallablePayloadSchema,
  createEventRosterHandoffCallableResponseSchema,
  getOrganizerCrmSummaryCallablePayloadSchema,
  getEventRosterInsightsCallablePayloadSchema,
  getEventRosterInsightsCallableResponseSchema,
  getOrganizerCrmSummaryCallableResponseSchema,
  listOrganizerContactsCallablePayloadSchema,
  createOrganizerFormCallablePayloadSchema,
  createOrganizerFormCallableResponseSchema,
  updateOrganizerFormDraftCallablePayloadSchema,
  updateOrganizerFormDraftCallableResponseSchema,
  getOrganizerFormEditorCallablePayloadSchema,
  getOrganizerFormEditorCallableResponseSchema,
  listOrganizerFormsCallablePayloadSchema,
  listOrganizerFormsCallableResponseSchema,
  validateOrganizerFormDraftCallablePayloadSchema,
  validateOrganizerFormDraftCallableResponseSchema,
  publishOrganizerFormCallablePayloadSchema,
  publishOrganizerFormCallableResponseSchema,
  setOrganizerFormLifecycleCallablePayloadSchema,
  setOrganizerFormLifecycleCallableResponseSchema,
  duplicateOrganizerFormCallablePayloadSchema,
  duplicateOrganizerFormCallableResponseSchema,
  deleteOrganizerFormDraftCallablePayloadSchema,
  deleteOrganizerFormDraftCallableResponseSchema,
  listOrganizerFormTemplatesCallablePayloadSchema,
  listOrganizerFormTemplatesCallableResponseSchema,
  getPublicOrganizerFormCallablePayloadSchema,
  getPublicOrganizerFormCallableResponseSchema,
  beginOrganizerFormResponseCallablePayloadSchema,
  beginOrganizerFormResponseCallableResponseSchema,
  saveOrganizerFormResponseDraftCallablePayloadSchema,
  saveOrganizerFormResponseDraftCallableResponseSchema,
  createOrganizerFormAssetIntentCallablePayloadSchema,
  createOrganizerFormAssetIntentCallableResponseSchema,
  finalizeOrganizerFormAssetCallablePayloadSchema,
  finalizeOrganizerFormAssetCallableResponseSchema,
  submitOrganizerFormResponseCallablePayloadSchema,
  submitOrganizerFormResponseCallableResponseSchema,
  withdrawOrganizerFormResponseCallablePayloadSchema,
  withdrawOrganizerFormResponseCallableResponseSchema,
  createOrganizerFormShareLinkCallablePayloadSchema,
  createOrganizerFormShareLinkCallableResponseSchema,
  getOrganizerFormShareAssetsCallablePayloadSchema,
  getOrganizerFormShareAssetsCallableResponseSchema,
  listOrganizerFormResponsesCallablePayloadSchema,
  listOrganizerFormResponsesCallableResponseSchema,
  getOrganizerFormResponseDetailCallablePayloadSchema,
  getOrganizerFormResponseDetailCallableResponseSchema,
  getOrganizerFormAnalyticsCallablePayloadSchema,
  getOrganizerFormAnalyticsCallableResponseSchema,
  requestOrganizerFormExportCallablePayloadSchema,
  requestOrganizerFormExportCallableResponseSchema,
  createOrganizerFormAutomationCallablePayloadSchema,
  createOrganizerFormAutomationCallableResponseSchema,
  setOrganizerFormAutomationStateCallablePayloadSchema,
  setOrganizerFormAutomationStateCallableResponseSchema,
  listOrganizerFormAutomationRunsCallablePayloadSchema,
  listOrganizerFormAutomationRunsCallableResponseSchema,
  previewOrganizerFormConversionCallablePayloadSchema,
  previewOrganizerFormConversionCallableResponseSchema,
  convertOrganizerFormResponseCallablePayloadSchema,
  convertOrganizerFormResponseCallableResponseSchema,
  publishOrganizerApplicationFormCallablePayloadSchema,
  getParticipantOrganizerApplicationFormCallablePayloadSchema,
  getParticipantOrganizerApplicationFormCallableResponseSchema,
  submitParticipantOrganizerApplicationCallablePayloadSchema,
  submitParticipantOrganizerApplicationCallableResponseSchema,
  revokeParticipantOrganizerDataGrantCallablePayloadSchema,
  revokeParticipantOrganizerDataGrantCallableResponseSchema,
  publishOrganizerApplicationFormCallableResponseSchema,
  previewOrganizerApplicationImportCallablePayloadSchema,
  previewOrganizerApplicationImportCallableResponseSchema,
  importOrganizerApplicationsCallablePayloadSchema,
  importOrganizerApplicationsCallableResponseSchema,
  listOrganizerApplicationsCallablePayloadSchema,
  listOrganizerApplicationsCallableResponseSchema,
  listOrganizerAttentionItemsCallablePayloadSchema,
  listOrganizerAttentionItemsCallableResponseSchema,
  getOrganizerApplicationDetailCallablePayloadSchema,
  getOrganizerApplicationDetailCallableResponseSchema,
  reviewOrganizerApplicationCallablePayloadSchema,
  reviewOrganizerApplicationCallableResponseSchema,
  createOrganizerContactCallablePayloadSchema,
  createOrganizerContactCallableResponseSchema,
  listOrganizerContactsCallableResponseSchema,
  getOrganizerContactDetailCallablePayloadSchema,
  getOrganizerContactDetailCallableResponseSchema,
  resolveOrganizerCommunicationPlanCallablePayloadSchema,
  resolveOrganizerCommunicationPlanCallableResponseSchema,
  mutateOrganizerContactCallablePayloadSchema,
  mutateOrganizerContactCallableResponseSchema,
  createOrganizerContactNoteCallablePayloadSchema,
  mutateOrganizerContactNoteCallablePayloadSchema,
  organizerContactNoteCallableResponseSchema,
  exportOrganizerContactsCallablePayloadSchema,
  exportOrganizerContactsCallableResponseSchema,
  mergeOrganizerContactsCallablePayloadSchema,
  listOrganizerContactMergeCandidatesCallablePayloadSchema,
  listOrganizerContactMergeCandidatesCallableResponseSchema,
  reviewOrganizerContactMergeCandidateCallablePayloadSchema,
  reviewOrganizerContactMergeCandidateCallableResponseSchema,
  listOrganizerWhatsappThreadsCallablePayloadSchema,
  listOrganizerWhatsappThreadsCallableResponseSchema,
  getOrganizerWhatsappThreadCallablePayloadSchema,
  getOrganizerWhatsappThreadCallableResponseSchema,
  sendOrganizerWhatsappReplyCallablePayloadSchema,
  sendOrganizerWhatsappReplyCallableResponseSchema,
  unmergeOrganizerContactsCallablePayloadSchema,
  mutateOrganizerContactMergeCallableResponseSchema,
  eventJoinRequestDecisionCallablePayloadSchema,
  overrideEventSuccessRotationsCallablePayloadSchema,
  prepareEventSuccessRotationDraftCallablePayloadSchema,
  publishEventSuccessRotationRoundCallablePayloadSchema,
  eventSuccessLiveActionCallablePayloadSchema,
  setEventSuccessAccountabilityResolutionCallablePayloadSchema,
  recordEventSuccessUnitOutcomesCallablePayloadSchema,
  recordEventSuccessUnitOutcomesCallableResponseSchema,
  heartbeatEventSuccessPresenceCallablePayloadSchema,
  heartbeatEventSuccessPresenceCallableResponseSchema,
  publishEventLivePositionCallablePayloadSchema,
  publishEventLivePositionCallableResponseSchema,
  getEventSuccessPresenceSummaryCallableResponseSchema,
  resolveEventSuccessLateArrivalCallablePayloadSchema,
  resolveEventSuccessLateArrivalCallableResponseSchema,
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
  createPublicOrganizerReviewCallablePayloadSchema,
  createPublicOrganizerReviewCallableResponseSchema,
  listPublicOrganizerReviewsCallablePayloadSchema,
  listPublicOrganizerReviewsCallableResponseSchema,
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
  createRazorpayHostPaymentAccountCallablePayloadSchema,
  refreshRazorpayHostPaymentAccountCallablePayloadSchema,
  stripeHostOnboardingLinkCallableResponseSchema,
  placesAutocompleteCallablePayloadSchema,
  placesAutocompleteCallableResponseSchema,
  placeDetailsCallablePayloadSchema,
  placeDetailsCallableResponseSchema,
  exploreSearchCallablePayloadSchema,
  exploreSearchCallableResponseSchema,
  websiteHostListingProjectionSchema,
  fetchEventSuccessWingmanCandidatesCallableResponseSchema,
  fetchSwipeCandidatesCallableResponseSchema,
  setCrossPathsEventConsentCallableResponseSchema,
  getCrossPathsSuggestionsCallableResponseSchema,
  sendCrossPathsInvitationCallableResponseSchema,
  respondCrossPathsInvitationCallableResponseSchema,
  cancelCrossPathsInvitationOrPlanCallableResponseSchema,
  createProfileDecisionClientWriteSchema,
  createChatMessageClientWriteSchema,
  createSavedEventClientWriteSchema,
  deleteSavedEventClientWriteSchema,
  markNotificationReadClientWriteSchema,
  resetMatchUnreadCountClientWriteSchema,
  adminGetOverviewCallablePayloadSchema,
  adminGetOverviewCallableResponseSchema,
  adminDecideAccessApplicationCallablePayloadSchema,
  adminDecideAccessApplicationCallableResponseSchema,
  adminSetAdminUserRolesCallablePayloadSchema,
  adminSetAdminUserRolesCallableResponseSchema,
  adminDecideSafetyTriageItemCallablePayloadSchema,
  adminDecideSafetyTriageItemCallableResponseSchema,
  adminAssignSafetyTriageItemCallablePayloadSchema,
  adminAssignSafetyTriageItemCallableResponseSchema,
  adminCreateOrganizerDraftFromCandidateCallablePayloadSchema,
  adminCreateOrganizerDraftFromCandidateCallableResponseSchema,
  adminCreateMarketingContentDraftCallablePayloadSchema,
  adminCreateMarketingContentDraftCallableResponseSchema,
  adminRecordMarketingReviewDecisionCallablePayloadSchema,
  adminRecordMarketingReviewDecisionCallableResponseSchema,
  adminListCrossPathsShowcaseCandidatesCallableResponseSchema,
  adminSetCrossPathsShowcaseEligibilityCallableResponseSchema,
  joinWaitlistHTTPRequestSchema,
  joinWaitlistHTTPResponseSchema,
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

export const validateMobileFormState =
  lazyValidator<MobileFormState>(mobileFormStateSchema);
export const validateOperationRun =
  lazyValidator<OperationRun>(operationRunSchema);
export const validateOperationWorkItem =
  lazyValidator<OperationWorkItem>(operationWorkItemSchema);
export const validateProfilePromptAnswer =
  lazyValidator<ProfilePromptAnswer>(profilePromptAnswerSchema);
export const validatePhotoPromptAnswer =
  lazyValidator<PhotoPromptAnswer>(photoPromptAnswerSchema);
export const validateProfilePhoto =
  lazyValidator<ProfilePhoto>(profilePhotoSchema);
export const validateUploadedPhoto =
  lazyValidator<UploadedPhoto>(uploadedPhotoSchema);
export const validateEventOrigin =
  lazyValidator<EventOrigin>(eventOriginSchema);
export const validateEventRuntimeAccess =
  lazyValidator<EventRuntimeAccess>(eventRuntimeAccessSchema);
export const validateActivityPreferences =
  lazyValidator<ActivityPreferences>(activityPreferencesSchema);
export const validateOrganizerSupplyCapabilities =
  lazyValidator<OrganizerSupplyCapabilities>(organizerSupplyCapabilitiesSchema);
export const validateExternalEventBlockerResolution =
  lazyValidator<ExternalEventBlockerResolution>(externalEventBlockerResolutionSchema);
export const validateExternalEventPublicationReceiptDocument =
  lazyValidator<ExternalEventPublicationReceiptDocument>(externalEventPublicationReceiptDocumentSchema);
export const validateConfigCitiesDocument =
  lazyValidator<ConfigCitiesDocument>(configCitiesDocumentSchema);
export const validateOnboardingDraftDocument =
  lazyValidator<OnboardingDraftDocument>(onboardingDraftDocumentSchema);
export const validateAccessApplicationDocument =
  lazyValidator<AccessApplicationDocument>(accessApplicationDocumentSchema);
export const validateUserProfileDocument =
  lazyValidator<UserProfileDocument>(userProfileDocumentSchema);
export const validatePublicProfileDocument =
  lazyValidator<PublicProfileDocument>(publicProfileDocumentSchema);
export const validateHostProfileDocument =
  lazyValidator<HostProfileDocument>(hostProfileDocumentSchema);
export const validateClubDocument =
  lazyValidator<ClubDocument>(clubDocumentSchema);
export const validateOrganizerDocument =
  lazyValidator<OrganizerDocument>(organizerDocumentSchema);
export const validateOrganizerPostDocument =
  lazyValidator<OrganizerPostDocument>(organizerPostDocumentSchema);
export const validateOrganizerPostDeliveryOperationDocument =
  lazyValidator<OrganizerPostDeliveryOperationDocument>(organizerPostDeliveryOperationDocumentSchema);
export const validateOrganizerPostDeliveryRecipientDocument =
  lazyValidator<OrganizerPostDeliveryRecipientDocument>(organizerPostDeliveryRecipientDocumentSchema);
export const validateOrganizerTeamMembershipDocument =
  lazyValidator<OrganizerTeamMembershipDocument>(organizerTeamMembershipDocumentSchema);
export const validateOrganizerFollowDocument =
  lazyValidator<OrganizerFollowDocument>(organizerFollowDocumentSchema);
export const validateOrganizerCommunicationPreferenceDocument =
  lazyValidator<OrganizerCommunicationPreferenceDocument>(organizerCommunicationPreferenceDocumentSchema);
export const validateOrganizerCommunicationPermissionReceiptDocument =
  lazyValidator<OrganizerCommunicationPermissionReceiptDocument>(organizerCommunicationPermissionReceiptDocumentSchema);
export const validateOrganizerContactDocument =
  lazyValidator<OrganizerContactDocument>(organizerContactDocumentSchema);
export const validateOrganizerContactOriginDocument =
  lazyValidator<OrganizerContactOriginDocument>(organizerContactOriginDocumentSchema);
export const validateOrganizerContactNoteDocument =
  lazyValidator<OrganizerContactNoteDocument>(organizerContactNoteDocumentSchema);
export const validateOrganizerContactTagVocabularyDocument =
  lazyValidator<OrganizerContactTagVocabularyDocument>(organizerContactTagVocabularyDocumentSchema);
export const validateOrganizerSavedAudienceDocument =
  lazyValidator<OrganizerSavedAudienceDocument>(organizerSavedAudienceDocumentSchema);
export const validateOrganizerManualSendTaskDocument =
  lazyValidator<OrganizerManualSendTaskDocument>(organizerManualSendTaskDocumentSchema);
export const validateOrganizerAttentionItemDocument =
  lazyValidator<OrganizerAttentionItemDocument>(organizerAttentionItemDocumentSchema);
export const validateOrganizerContactIdentityLinkDocument =
  lazyValidator<OrganizerContactIdentityLinkDocument>(organizerContactIdentityLinkDocumentSchema);
export const validateOrganizerContactIdentityClaimDocument =
  lazyValidator<OrganizerContactIdentityClaimDocument>(organizerContactIdentityClaimDocumentSchema);
export const validateOrganizerContactEventEdgeDocument =
  lazyValidator<OrganizerContactEventEdgeDocument>(organizerContactEventEdgeDocumentSchema);
export const validateOrganizerContactTraitDocument =
  lazyValidator<OrganizerContactTraitDocument>(organizerContactTraitDocumentSchema);
export const validateOrganizerAudienceSummaryDocument =
  lazyValidator<OrganizerAudienceSummaryDocument>(organizerAudienceSummaryDocumentSchema);
export const validateOrganizerAudienceProjectionReceiptDocument =
  lazyValidator<OrganizerAudienceProjectionReceiptDocument>(organizerAudienceProjectionReceiptDocumentSchema);
export const validateOrganizerContactMergeReceiptDocument =
  lazyValidator<OrganizerContactMergeReceiptDocument>(organizerContactMergeReceiptDocumentSchema);
export const validateOrganizerContactMergeReviewDecisionDocument =
  lazyValidator<OrganizerContactMergeReviewDecisionDocument>(organizerContactMergeReviewDecisionDocumentSchema);
export const validateOrganizerSenderConnectionDocument =
  lazyValidator<OrganizerSenderConnectionDocument>(organizerSenderConnectionDocumentSchema);
export const validateOrganizerProviderConnectionDocument =
  lazyValidator<OrganizerProviderConnectionDocument>(organizerProviderConnectionDocumentSchema);
export const validateOrganizerApplicationFormDocument =
  lazyValidator<OrganizerApplicationFormDocument>(organizerApplicationFormDocumentSchema);
export const validateOrganizerApplicationFormVersionDocument =
  lazyValidator<OrganizerApplicationFormVersionDocument>(organizerApplicationFormVersionDocumentSchema);
export const validateOrganizerFormDocument =
  lazyValidator<OrganizerFormDocument>(organizerFormDocumentSchema);
export const validateOrganizerFormDraftDocument =
  lazyValidator<OrganizerFormDraftDocument>(organizerFormDraftDocumentSchema);
export const validateOrganizerFormVersionDocument =
  lazyValidator<OrganizerFormVersionDocument>(organizerFormVersionDocumentSchema);
export const validateOrganizerFormResponseDraftDocument =
  lazyValidator<OrganizerFormResponseDraftDocument>(organizerFormResponseDraftDocumentSchema);
export const validateOrganizerFormResponseDocument =
  lazyValidator<OrganizerFormResponseDocument>(organizerFormResponseDocumentSchema);
export const validateOrganizerFormAssetDocument =
  lazyValidator<OrganizerFormAssetDocument>(organizerFormAssetDocumentSchema);
export const validateOrganizerFormAggregateDocument =
  lazyValidator<OrganizerFormAggregateDocument>(organizerFormAggregateDocumentSchema);
export const validateOrganizerFormAggregateEventDocument =
  lazyValidator<OrganizerFormAggregateEventDocument>(organizerFormAggregateEventDocumentSchema);
export const validateOrganizerFormExportDocument =
  lazyValidator<OrganizerFormExportDocument>(organizerFormExportDocumentSchema);
export const validateOrganizerFormAutomationRuleDocument =
  lazyValidator<OrganizerFormAutomationRuleDocument>(organizerFormAutomationRuleDocumentSchema);
export const validateOrganizerFormAutomationRunDocument =
  lazyValidator<OrganizerFormAutomationRunDocument>(organizerFormAutomationRunDocumentSchema);
export const validateOrganizerFormConversionReceiptDocument =
  lazyValidator<OrganizerFormConversionReceiptDocument>(organizerFormConversionReceiptDocumentSchema);
export const validateOrganizerFormShareLinkDocument =
  lazyValidator<OrganizerFormShareLinkDocument>(organizerFormShareLinkDocumentSchema);
export const validateOrganizerApplicationDocument =
  lazyValidator<OrganizerApplicationDocument>(organizerApplicationDocumentSchema);
export const validateOrganizerApplicationResponseDocument =
  lazyValidator<OrganizerApplicationResponseDocument>(organizerApplicationResponseDocumentSchema);
export const validateOrganizerApplicationAssetDocument =
  lazyValidator<OrganizerApplicationAssetDocument>(organizerApplicationAssetDocumentSchema);
export const validateOrganizerApplicationSourceMappingDocument =
  lazyValidator<OrganizerApplicationSourceMappingDocument>(organizerApplicationSourceMappingDocumentSchema);
export const validateOrganizerApplicationImportReceiptDocument =
  lazyValidator<OrganizerApplicationImportReceiptDocument>(organizerApplicationImportReceiptDocumentSchema);
export const validateParticipantIntakeProfileDocument =
  lazyValidator<ParticipantIntakeProfileDocument>(participantIntakeProfileDocumentSchema);
export const validateParticipantOrganizerDataGrantDocument =
  lazyValidator<ParticipantOrganizerDataGrantDocument>(participantOrganizerDataGrantDocumentSchema);
export const validateExternalEventMappingDocument =
  lazyValidator<ExternalEventMappingDocument>(externalEventMappingDocumentSchema);
export const validateProviderSyncRunDocument =
  lazyValidator<ProviderSyncRunDocument>(providerSyncRunDocumentSchema);
export const validateOrganizerMessageTemplateDocument =
  lazyValidator<OrganizerMessageTemplateDocument>(organizerMessageTemplateDocumentSchema);
export const validateOrganizerContactChannelStateDocument =
  lazyValidator<OrganizerContactChannelStateDocument>(organizerContactChannelStateDocumentSchema);
export const validateOrganizerCampaignDocument =
  lazyValidator<OrganizerCampaignDocument>(organizerCampaignDocumentSchema);
export const validateOrganizerBroadcastSummaryDocument =
  lazyValidator<OrganizerBroadcastSummaryDocument>(organizerBroadcastSummaryDocumentSchema);
export const validateOrganizerCampaignRecipientDocument =
  lazyValidator<OrganizerCampaignRecipientDocument>(organizerCampaignRecipientDocumentSchema);
export const validateOrganizerCampaignWebhookReceiptDocument =
  lazyValidator<OrganizerCampaignWebhookReceiptDocument>(organizerCampaignWebhookReceiptDocumentSchema);
export const validateOrganizerMessagingWebhookEventDocument =
  lazyValidator<OrganizerMessagingWebhookEventDocument>(organizerMessagingWebhookEventDocumentSchema);
export const validateOrganizerWhatsappThreadDocument =
  lazyValidator<OrganizerWhatsappThreadDocument>(organizerWhatsappThreadDocumentSchema);
export const validateOrganizerWhatsappMessageDocument =
  lazyValidator<OrganizerWhatsappMessageDocument>(organizerWhatsappMessageDocumentSchema);
export const validateOrganizerWhatsappReplyOperationDocument =
  lazyValidator<OrganizerWhatsappReplyOperationDocument>(organizerWhatsappReplyOperationDocumentSchema);
export const validateOrganizerClaimRequestDocument =
  lazyValidator<OrganizerClaimRequestDocument>(organizerClaimRequestDocumentSchema);
export const validateOrganizerScheduleLockDocument =
  lazyValidator<OrganizerScheduleLockDocument>(organizerScheduleLockDocumentSchema);
export const validateClubPostDocument =
  lazyValidator<ClubPostDocument>(clubPostDocumentSchema);
export const validateClubMembershipDocument =
  lazyValidator<ClubMembershipDocument>(clubMembershipDocumentSchema);
export const validateClubHostClaimDocument =
  lazyValidator<ClubHostClaimDocument>(clubHostClaimDocumentSchema);
export const validateClubClaimRequestDocument =
  lazyValidator<ClubClaimRequestDocument>(clubClaimRequestDocumentSchema);
export const validateEventDocument =
  lazyValidator<EventDocument>(eventDocumentSchema);
export const validateExternalEventDocument =
  lazyValidator<ExternalEventDocument>(externalEventDocumentSchema);
export const validateEventPrivateAccessDocument =
  lazyValidator<EventPrivateAccessDocument>(eventPrivateAccessDocumentSchema);
export const validateEventInviteLinkDocument =
  lazyValidator<EventInviteLinkDocument>(eventInviteLinkDocumentSchema);
export const validateEventInviteLinkSecretDocument =
  lazyValidator<EventInviteLinkSecretDocument>(eventInviteLinkSecretDocumentSchema);
export const validateEventInviteTouchDocument =
  lazyValidator<EventInviteTouchDocument>(eventInviteTouchDocumentSchema);
export const validateEventShareIntentDocument =
  lazyValidator<EventShareIntentDocument>(eventShareIntentDocumentSchema);
export const validateEventInviteAttributionDocument =
  lazyValidator<EventInviteAttributionDocument>(eventInviteAttributionDocumentSchema);
export const validateEventParticipationDocument =
  lazyValidator<EventParticipationDocument>(eventParticipationDocumentSchema);
export const validateEventAttendeeDocument =
  lazyValidator<EventAttendeeDocument>(eventAttendeeDocumentSchema);
export const validateEventStaffGrantDocument =
  lazyValidator<EventStaffGrantDocument>(eventStaffGrantDocumentSchema);
export const validateEventAttendeeAttendanceReceiptDocument =
  lazyValidator<EventAttendeeAttendanceReceiptDocument>(eventAttendeeAttendanceReceiptDocumentSchema);
export const validateEventAttendeeImportDocument =
  lazyValidator<EventAttendeeImportDocument>(eventAttendeeImportDocumentSchema);
export const validateEventRosterHandoffDocument =
  lazyValidator<EventRosterHandoffDocument>(eventRosterHandoffDocumentSchema);
export const validateEventRuntimeParticipantDocument =
  lazyValidator<EventRuntimeParticipantDocument>(eventRuntimeParticipantDocumentSchema);
export const validateEventVenueSessionDocument =
  lazyValidator<EventVenueSessionDocument>(eventVenueSessionDocumentSchema);
export const validateEventVenueSessionRedemptionDocument =
  lazyValidator<EventVenueSessionRedemptionDocument>(eventVenueSessionRedemptionDocumentSchema);
export const validateEventSuccessPresenceDocument =
  lazyValidator<EventSuccessPresenceDocument>(eventSuccessPresenceDocumentSchema);
export const validateEventLivePositionDocument =
  lazyValidator<EventLivePositionDocument>(eventLivePositionDocumentSchema);
export const validateEventSuccessLateArrivalDocument =
  lazyValidator<EventSuccessLateArrivalDocument>(eventSuccessLateArrivalDocumentSchema);
export const validateEventRehearsalDocument =
  lazyValidator<EventRehearsalDocument>(eventRehearsalDocumentSchema);
export const validateEventRehearsalActorDocument =
  lazyValidator<EventRehearsalActorDocument>(eventRehearsalActorDocumentSchema);
export const validateEventRehearsalActionDocument =
  lazyValidator<EventRehearsalActionDocument>(eventRehearsalActionDocumentSchema);
export const validateEventRehearsalGuestViewDocument =
  lazyValidator<EventRehearsalGuestViewDocument>(eventRehearsalGuestViewDocumentSchema);
export const validateEventRuntimeClaimRequestDocument =
  lazyValidator<EventRuntimeClaimRequestDocument>(eventRuntimeClaimRequestDocumentSchema);
export const validateEventCrossPathsConsentDocument =
  lazyValidator<EventCrossPathsConsentDocument>(eventCrossPathsConsentDocumentSchema);
export const validateCrossPathsShowcaseEligibilityDocument =
  lazyValidator<CrossPathsShowcaseEligibilityDocument>(crossPathsShowcaseEligibilityDocumentSchema);
export const validateCrossPathsSuggestionExposureDocument =
  lazyValidator<CrossPathsSuggestionExposureDocument>(crossPathsSuggestionExposureDocumentSchema);
export const validateCrossPathsInvitationDocument =
  lazyValidator<CrossPathsInvitationDocument>(crossPathsInvitationDocumentSchema);
export const validateCrossPathsPairHoldDocument =
  lazyValidator<CrossPathsPairHoldDocument>(crossPathsPairHoldDocumentSchema);
export const validateEventBroadcastDocument =
  lazyValidator<EventBroadcastDocument>(eventBroadcastDocumentSchema);
export const validateEventWaitlistOfferDocument =
  lazyValidator<EventWaitlistOfferDocument>(eventWaitlistOfferDocumentSchema);
export const validateEventSuccessPlanDocument =
  lazyValidator<EventSuccessPlanDocument>(eventSuccessPlanDocumentSchema);
export const validateEventSuccessConversationGraphDocument =
  lazyValidator<EventSuccessConversationGraphDocument>(eventSuccessConversationGraphDocumentSchema);
export const validateOrganizerEventSuccessLayoutDocument =
  lazyValidator<OrganizerEventSuccessLayoutDocument>(organizerEventSuccessLayoutDocumentSchema);
export const validateOrganizerEventVenueDocument =
  lazyValidator<OrganizerEventVenueDocument>(organizerEventVenueDocumentSchema);
export const validateEventSuccessAssignmentDraftDocument =
  lazyValidator<EventSuccessAssignmentDraftDocument>(eventSuccessAssignmentDraftDocumentSchema);
export const validateEventSuccessFeedbackDocument =
  lazyValidator<EventSuccessFeedbackDocument>(eventSuccessFeedbackDocumentSchema);
export const validateEventSuccessPreferenceDocument =
  lazyValidator<EventSuccessPreferenceDocument>(eventSuccessPreferenceDocumentSchema);
export const validateEventSuccessCompatibilityResponseDocument =
  lazyValidator<EventSuccessCompatibilityResponseDocument>(eventSuccessCompatibilityResponseDocumentSchema);
export const validateEventSuccessWingmanRequestDocument =
  lazyValidator<EventSuccessWingmanRequestDocument>(eventSuccessWingmanRequestDocumentSchema);
export const validateEventSuccessArrivalMissionDocument =
  lazyValidator<EventSuccessArrivalMissionDocument>(eventSuccessArrivalMissionDocumentSchema);
export const validateEventSuccessAssignmentDocument =
  lazyValidator<EventSuccessAssignmentDocument>(eventSuccessAssignmentDocumentSchema);
export const validateEventSuccessUnitOutcomesDocument =
  lazyValidator<EventSuccessUnitOutcomesDocument>(eventSuccessUnitOutcomesDocumentSchema);
export const validateEventSuccessStandingsDocument =
  lazyValidator<EventSuccessStandingsDocument>(eventSuccessStandingsDocumentSchema);
export const validateEventSuccessScorecardDocument =
  lazyValidator<EventSuccessScorecardDocument>(eventSuccessScorecardDocumentSchema);
export const validateEventSafetyReportDocument =
  lazyValidator<EventSafetyReportDocument>(eventSafetyReportDocumentSchema);
export const validateClubScheduleLockDocument =
  lazyValidator<ClubScheduleLockDocument>(clubScheduleLockDocumentSchema);
export const validateUserEventScheduleLockDocument =
  lazyValidator<UserEventScheduleLockDocument>(userEventScheduleLockDocumentSchema);
export const validateSavedEventDocument =
  lazyValidator<SavedEventDocument>(savedEventDocumentSchema);
export const validateHostAnalyticsEvent =
  lazyValidator<HostAnalyticsEvent>(hostAnalyticsEventSchema);
export const validateUserProfileExposureEvent =
  lazyValidator<UserProfileExposureEvent>(userProfileExposureEventSchema);
export const validatePaymentDocument =
  lazyValidator<PaymentDocument>(paymentDocumentSchema);
export const validateHostPaymentAccountDocument =
  lazyValidator<HostPaymentAccountDocument>(hostPaymentAccountDocumentSchema);
export const validateRazorpayPendingOrderDocument =
  lazyValidator<RazorpayPendingOrderDocument>(razorpayPendingOrderDocumentSchema);
export const validateSwipeDocument =
  lazyValidator<SwipeDocument>(swipeDocumentSchema);
export const validateMatchDocument =
  lazyValidator<MatchDocument>(matchDocumentSchema);
export const validateChatMessageDocument =
  lazyValidator<ChatMessageDocument>(chatMessageDocumentSchema);
export const validateActivityNotificationDocument =
  lazyValidator<ActivityNotificationDocument>(activityNotificationDocumentSchema);
export const validateReviewDocument =
  lazyValidator<ReviewDocument>(reviewDocumentSchema);
export const validateBlockDocument =
  lazyValidator<BlockDocument>(blockDocumentSchema);
export const validateReportDocument =
  lazyValidator<ReportDocument>(reportDocumentSchema);
export const validateModerationFlagDocument =
  lazyValidator<ModerationFlagDocument>(moderationFlagDocumentSchema);
export const validateDeletedUserTombstoneDocument =
  lazyValidator<DeletedUserTombstoneDocument>(deletedUserTombstoneDocumentSchema);
export const validateRateLimitDocument =
  lazyValidator<RateLimitDocument>(rateLimitDocumentSchema);
export const validateHostAnalyticsSnapshotDocument =
  lazyValidator<HostAnalyticsSnapshotDocument>(hostAnalyticsSnapshotDocumentSchema);
export const validateFunctionEventReceiptDocument =
  lazyValidator<FunctionEventReceiptDocument>(functionEventReceiptDocumentSchema);
export const validatePublicRouteReservationDocument =
  lazyValidator<PublicRouteReservationDocument>(publicRouteReservationDocumentSchema);
export const validateSeedEventManifestDocument =
  lazyValidator<SeedEventManifestDocument>(seedEventManifestDocumentSchema);
export const validateOrganizerIntakeReviewDecisionDocument =
  lazyValidator<OrganizerIntakeReviewDecisionDocument>(organizerIntakeReviewDecisionDocumentSchema);
export const validateEventIntakeReviewDecisionDocument =
  lazyValidator<EventIntakeReviewDecisionDocument>(eventIntakeReviewDecisionDocumentSchema);
export const validateOrganizerIntakeCurationDecisionDocument =
  lazyValidator<OrganizerIntakeCurationDecisionDocument>(organizerIntakeCurationDecisionDocumentSchema);
export const validateOrganizerIntakeFieldCorrectionDocument =
  lazyValidator<OrganizerIntakeFieldCorrectionDocument>(organizerIntakeFieldCorrectionDocumentSchema);
export const validateOrganizerEventCandidateReviewDecisionDocument =
  lazyValidator<OrganizerEventCandidateReviewDecisionDocument>(organizerEventCandidateReviewDecisionDocumentSchema);
export const validateOrganizerEventLocationResolutionDecisionDocument =
  lazyValidator<OrganizerEventLocationResolutionDecisionDocument>(organizerEventLocationResolutionDecisionDocumentSchema);
export const validateOrganizerPolicyGapReviewDecisionDocument =
  lazyValidator<OrganizerPolicyGapReviewDecisionDocument>(organizerPolicyGapReviewDecisionDocumentSchema);
export const validateUpdateUserProfileCallablePayload =
  lazyValidator<UpdateUserProfileCallablePayload>(updateUserProfileCallablePayloadSchema);
export const validateCreateClubCallablePayload =
  lazyValidator<CreateClubCallablePayload>(createClubCallablePayloadSchema);
export const validateCreateOrganizerCallablePayload =
  lazyValidator<CreateOrganizerCallablePayload>(createOrganizerCallablePayloadSchema);
export const validateCreateOrganizerCallableResponse =
  lazyValidator<CreateOrganizerCallableResponse>(createOrganizerCallableResponseSchema);
export const validateUpdateOrganizerCallablePayload =
  lazyValidator<UpdateOrganizerCallablePayload>(updateOrganizerCallablePayloadSchema);
export const validateArchiveOrganizerCallablePayload =
  lazyValidator<ArchiveOrganizerCallablePayload>(archiveOrganizerCallablePayloadSchema);
export const validateDeleteOrganizerCallablePayload =
  lazyValidator<DeleteOrganizerCallablePayload>(deleteOrganizerCallablePayloadSchema);
export const validateCreateOrganizerPostCallablePayload =
  lazyValidator<CreateOrganizerPostCallablePayload>(createOrganizerPostCallablePayloadSchema);
export const validateCreateOrganizerPostCallableResponse =
  lazyValidator<CreateOrganizerPostCallableResponse>(createOrganizerPostCallableResponseSchema);
export const validateRequestOrganizerClaimCallablePayload =
  lazyValidator<RequestOrganizerClaimCallablePayload>(requestOrganizerClaimCallablePayloadSchema);
export const validateRequestOrganizerClaimCallableResponse =
  lazyValidator<RequestOrganizerClaimCallableResponse>(requestOrganizerClaimCallableResponseSchema);
export const validateAdminDecideOrganizerClaimCallablePayload =
  lazyValidator<AdminDecideOrganizerClaimCallablePayload>(adminDecideOrganizerClaimCallablePayloadSchema);
export const validateCreateClubCallableResponse =
  lazyValidator<CreateClubCallableResponse>(createClubCallableResponseSchema);
export const validateCreateClubPostCallablePayload =
  lazyValidator<CreateClubPostCallablePayload>(createClubPostCallablePayloadSchema);
export const validateCreateClubPostCallableResponse =
  lazyValidator<CreateClubPostCallableResponse>(createClubPostCallableResponseSchema);
export const validateSendEventBroadcastCallablePayload =
  lazyValidator<SendEventBroadcastCallablePayload>(sendEventBroadcastCallablePayloadSchema);
export const validateSendEventBroadcastCallableResponse =
  lazyValidator<SendEventBroadcastCallableResponse>(sendEventBroadcastCallableResponseSchema);
export const validateUpdateClubCallablePayload =
  lazyValidator<UpdateClubCallablePayload>(updateClubCallablePayloadSchema);
export const validateHostAnalyticsQueryCallablePayload =
  lazyValidator<HostAnalyticsQueryCallablePayload>(hostAnalyticsQueryCallablePayloadSchema);
export const validateHostAnalyticsCallableResponse =
  lazyValidator<HostAnalyticsCallableResponse>(hostAnalyticsCallableResponseSchema);
export const validateUserAnalyticsQueryCallablePayload =
  lazyValidator<UserAnalyticsQueryCallablePayload>(userAnalyticsQueryCallablePayloadSchema);
export const validateUserAnalyticsCallableResponse =
  lazyValidator<UserAnalyticsCallableResponse>(userAnalyticsCallableResponseSchema);
export const validateAddClubHostCallablePayload =
  lazyValidator<AddClubHostCallablePayload>(addClubHostCallablePayloadSchema);
export const validateOrganizerFollowCallablePayload =
  lazyValidator<OrganizerFollowCallablePayload>(organizerFollowCallablePayloadSchema);
export const validateSetOrganizerNotificationPreferenceCallablePayload =
  lazyValidator<SetOrganizerNotificationPreferenceCallablePayload>(setOrganizerNotificationPreferenceCallablePayloadSchema);
export const validateAddOrganizerManagerCallablePayload =
  lazyValidator<AddOrganizerManagerCallablePayload>(addOrganizerManagerCallablePayloadSchema);
export const validateRemoveOrganizerManagerCallablePayload =
  lazyValidator<RemoveOrganizerManagerCallablePayload>(removeOrganizerManagerCallablePayloadSchema);
export const validateTransferOrganizerOwnershipCallablePayload =
  lazyValidator<TransferOrganizerOwnershipCallablePayload>(transferOrganizerOwnershipCallablePayloadSchema);
export const validateRemoveClubHostCallablePayload =
  lazyValidator<RemoveClubHostCallablePayload>(removeClubHostCallablePayloadSchema);
export const validateTransferClubOwnershipCallablePayload =
  lazyValidator<TransferClubOwnershipCallablePayload>(transferClubOwnershipCallablePayloadSchema);
export const validateRequestClubClaimCallablePayload =
  lazyValidator<RequestClubClaimCallablePayload>(requestClubClaimCallablePayloadSchema);
export const validateRequestClubClaimCallableResponse =
  lazyValidator<RequestClubClaimCallableResponse>(requestClubClaimCallableResponseSchema);
export const validateAdminDecideClubClaimCallablePayload =
  lazyValidator<AdminDecideClubClaimCallablePayload>(adminDecideClubClaimCallablePayloadSchema);
export const validateAdminDecideOrganizerIntakeCallablePayload =
  lazyValidator<AdminDecideOrganizerIntakeCallablePayload>(adminDecideOrganizerIntakeCallablePayloadSchema);
export const validateAdminRecordOrganizerCurationCallablePayload =
  lazyValidator<AdminRecordOrganizerCurationCallablePayload>(adminRecordOrganizerCurationCallablePayloadSchema);
export const validateAdminRecordEventIntakeReviewDecisionCallablePayload =
  lazyValidator<AdminRecordEventIntakeReviewDecisionCallablePayload>(adminRecordEventIntakeReviewDecisionCallablePayloadSchema);
export const validateAdminListIntakeOperationsCallablePayload =
  lazyValidator<AdminListIntakeOperationsCallablePayload>(adminListIntakeOperationsCallablePayloadSchema);
export const validateAdminListActionExecutionsCallablePayload =
  lazyValidator<AdminListActionExecutionsCallablePayload>(adminListActionExecutionsCallablePayloadSchema);
export const validateAdminRecordActionExecutionCallablePayload =
  lazyValidator<AdminRecordActionExecutionCallablePayload>(adminRecordActionExecutionCallablePayloadSchema);
export const validateAdminDecideOrganizerEventCandidateCallablePayload =
  lazyValidator<AdminDecideOrganizerEventCandidateCallablePayload>(adminDecideOrganizerEventCandidateCallablePayloadSchema);
export const validateAdminDecideOrganizerPolicyGapCallablePayload =
  lazyValidator<AdminDecideOrganizerPolicyGapCallablePayload>(adminDecideOrganizerPolicyGapCallablePayloadSchema);
export const validateAdminResolveOrganizerEventLocationCallablePayload =
  lazyValidator<AdminResolveOrganizerEventLocationCallablePayload>(adminResolveOrganizerEventLocationCallablePayloadSchema);
export const validateAdminSetClubIndexStatusCallablePayload =
  lazyValidator<AdminSetClubIndexStatusCallablePayload>(adminSetClubIndexStatusCallablePayloadSchema);
export const validateAdminListCrossPathsShowcaseCandidatesCallablePayload =
  lazyValidator<AdminListCrossPathsShowcaseCandidatesCallablePayload>(adminListCrossPathsShowcaseCandidatesCallablePayloadSchema);
export const validateAdminSetCrossPathsShowcaseEligibilityCallablePayload =
  lazyValidator<AdminSetCrossPathsShowcaseEligibilityCallablePayload>(adminSetCrossPathsShowcaseEligibilityCallablePayloadSchema);
export const validateAdminGetClubDetailsCallablePayload =
  lazyValidator<AdminGetClubDetailsCallablePayload>(adminGetClubDetailsCallablePayloadSchema);
export const validateAdminListClubDetailsCallablePayload =
  lazyValidator<AdminListClubDetailsCallablePayload>(adminListClubDetailsCallablePayloadSchema);
export const validateAdminUpdateClubDetailsCallablePayload =
  lazyValidator<AdminUpdateClubDetailsCallablePayload>(adminUpdateClubDetailsCallablePayloadSchema);
export const validateAdminGetOrganizerDetailsCallablePayload =
  lazyValidator<AdminGetOrganizerDetailsCallablePayload>(adminGetOrganizerDetailsCallablePayloadSchema);
export const validateAdminListOrganizerDetailsCallablePayload =
  lazyValidator<AdminListOrganizerDetailsCallablePayload>(adminListOrganizerDetailsCallablePayloadSchema);
export const validateAdminUpdateOrganizerDetailsCallablePayload =
  lazyValidator<AdminUpdateOrganizerDetailsCallablePayload>(adminUpdateOrganizerDetailsCallablePayloadSchema);
export const validateAdminGetEventDetailsCallablePayload =
  lazyValidator<AdminGetEventDetailsCallablePayload>(adminGetEventDetailsCallablePayloadSchema);
export const validateAdminListEventDetailsCallablePayload =
  lazyValidator<AdminListEventDetailsCallablePayload>(adminListEventDetailsCallablePayloadSchema);
export const validateAdminListExternalEventDetailsCallablePayload =
  lazyValidator<AdminListExternalEventDetailsCallablePayload>(adminListExternalEventDetailsCallablePayloadSchema);
export const validateAdminUpdateEventDetailsCallablePayload =
  lazyValidator<AdminUpdateEventDetailsCallablePayload>(adminUpdateEventDetailsCallablePayloadSchema);
export const validateAdminPublishExternalEventCallablePayload =
  lazyValidator<AdminPublishExternalEventCallablePayload>(adminPublishExternalEventCallablePayloadSchema);
export const validateAdminTakedownExternalEventCallablePayload =
  lazyValidator<AdminTakedownExternalEventCallablePayload>(adminTakedownExternalEventCallablePayloadSchema);
export const validateStartClubHostConversationCallablePayload =
  lazyValidator<StartClubHostConversationCallablePayload>(startClubHostConversationCallablePayloadSchema);
export const validateStartOrganizerConversationCallablePayload =
  lazyValidator<StartOrganizerConversationCallablePayload>(startOrganizerConversationCallablePayloadSchema);
export const validateStartOrganizerContactConversationCallablePayload =
  lazyValidator<StartOrganizerContactConversationCallablePayload>(startOrganizerContactConversationCallablePayloadSchema);
export const validateArchiveClubCallablePayload =
  lazyValidator<ArchiveClubCallablePayload>(archiveClubCallablePayloadSchema);
export const validateDeleteClubCallablePayload =
  lazyValidator<DeleteClubCallablePayload>(deleteClubCallablePayloadSchema);
export const validateClubMembershipCallablePayload =
  lazyValidator<ClubMembershipCallablePayload>(clubMembershipCallablePayloadSchema);
export const validateSetClubNotificationPreferenceCallablePayload =
  lazyValidator<SetClubNotificationPreferenceCallablePayload>(setClubNotificationPreferenceCallablePayloadSchema);
export const validateCreateEventCallablePayload =
  lazyValidator<CreateEventCallablePayload>(createEventCallablePayloadSchema);
export const validateUpdateEventCallablePayload =
  lazyValidator<UpdateEventCallablePayload>(updateEventCallablePayloadSchema);
export const validateCancelEventCallablePayload =
  lazyValidator<CancelEventCallablePayload>(cancelEventCallablePayloadSchema);
export const validateDeleteEventCallablePayload =
  lazyValidator<DeleteEventCallablePayload>(deleteEventCallablePayloadSchema);
export const validateEventIdCallablePayload =
  lazyValidator<EventIdCallablePayload>(eventIdCallablePayloadSchema);
export const validateSetCrossPathsEventConsentCallablePayload =
  lazyValidator<SetCrossPathsEventConsentCallablePayload>(setCrossPathsEventConsentCallablePayloadSchema);
export const validateGetCrossPathsSuggestionsCallablePayload =
  lazyValidator<GetCrossPathsSuggestionsCallablePayload>(getCrossPathsSuggestionsCallablePayloadSchema);
export const validateSendCrossPathsInvitationCallablePayload =
  lazyValidator<SendCrossPathsInvitationCallablePayload>(sendCrossPathsInvitationCallablePayloadSchema);
export const validateRespondCrossPathsInvitationCallablePayload =
  lazyValidator<RespondCrossPathsInvitationCallablePayload>(respondCrossPathsInvitationCallablePayloadSchema);
export const validateCancelCrossPathsInvitationOrPlanCallablePayload =
  lazyValidator<CancelCrossPathsInvitationOrPlanCallablePayload>(cancelCrossPathsInvitationOrPlanCallablePayloadSchema);
export const validateCreateEventWaitlistOffersCallablePayload =
  lazyValidator<CreateEventWaitlistOffersCallablePayload>(createEventWaitlistOffersCallablePayloadSchema);
export const validateCreateEventInviteLinkCallablePayload =
  lazyValidator<CreateEventInviteLinkCallablePayload>(createEventInviteLinkCallablePayloadSchema);
export const validateDisableEventInviteLinkCallablePayload =
  lazyValidator<DisableEventInviteLinkCallablePayload>(disableEventInviteLinkCallablePayloadSchema);
export const validateRecordEventInviteLinkOpenCallablePayload =
  lazyValidator<RecordEventInviteLinkOpenCallablePayload>(recordEventInviteLinkOpenCallablePayloadSchema);
export const validateResolveEventInviteLandingCallablePayload =
  lazyValidator<ResolveEventInviteLandingCallablePayload>(resolveEventInviteLandingCallablePayloadSchema);
export const validateResolveEventInviteLandingCallableResponse =
  lazyValidator<ResolveEventInviteLandingCallableResponse>(resolveEventInviteLandingCallableResponseSchema);
export const validateGetEventInviteLinkTokenCallablePayload =
  lazyValidator<GetEventInviteLinkTokenCallablePayload>(getEventInviteLinkTokenCallablePayloadSchema);
export const validateRecordEventShareIntentCallablePayload =
  lazyValidator<RecordEventShareIntentCallablePayload>(recordEventShareIntentCallablePayloadSchema);
export const validateUpsertOrganizerCampaignCallablePayload =
  lazyValidator<UpsertOrganizerCampaignCallablePayload>(upsertOrganizerCampaignCallablePayloadSchema);
export const validateUpsertOrganizerSavedAudienceCallablePayload =
  lazyValidator<UpsertOrganizerSavedAudienceCallablePayload>(upsertOrganizerSavedAudienceCallablePayloadSchema);
export const validateListOrganizerSavedAudiencesCallablePayload =
  lazyValidator<ListOrganizerSavedAudiencesCallablePayload>(listOrganizerSavedAudiencesCallablePayloadSchema);
export const validatePreviewOrganizerSavedAudienceCallablePayload =
  lazyValidator<PreviewOrganizerSavedAudienceCallablePayload>(previewOrganizerSavedAudienceCallablePayloadSchema);
export const validateResolveOrganizerAudienceMembersCallablePayload =
  lazyValidator<ResolveOrganizerAudienceMembersCallablePayload>(resolveOrganizerAudienceMembersCallablePayloadSchema);
export const validateResolveOrganizerAudienceMembersCallableResponse =
  lazyValidator<ResolveOrganizerAudienceMembersCallableResponse>(resolveOrganizerAudienceMembersCallableResponseSchema);
export const validateArchiveOrganizerSavedAudienceCallablePayload =
  lazyValidator<ArchiveOrganizerSavedAudienceCallablePayload>(archiveOrganizerSavedAudienceCallablePayloadSchema);
export const validateOrganizerSavedAudienceCallableResponse =
  lazyValidator<OrganizerSavedAudienceCallableResponse>(organizerSavedAudienceCallableResponseSchema);
export const validateListOrganizerSavedAudiencesCallableResponse =
  lazyValidator<ListOrganizerSavedAudiencesCallableResponse>(listOrganizerSavedAudiencesCallableResponseSchema);
export const validatePreviewOrganizerSavedAudienceCallableResponse =
  lazyValidator<PreviewOrganizerSavedAudienceCallableResponse>(previewOrganizerSavedAudienceCallableResponseSchema);
export const validatePrepareOrganizerManualSendTaskCallablePayload =
  lazyValidator<PrepareOrganizerManualSendTaskCallablePayload>(prepareOrganizerManualSendTaskCallablePayloadSchema);
export const validateListOrganizerManualSendTasksCallablePayload =
  lazyValidator<ListOrganizerManualSendTasksCallablePayload>(listOrganizerManualSendTasksCallablePayloadSchema);
export const validateOpenOrganizerManualSendTaskCallablePayload =
  lazyValidator<OpenOrganizerManualSendTaskCallablePayload>(openOrganizerManualSendTaskCallablePayloadSchema);
export const validateValidateOrganizerManualSendTaskLaunchCallablePayload =
  lazyValidator<ValidateOrganizerManualSendTaskLaunchCallablePayload>(validateOrganizerManualSendTaskLaunchCallablePayloadSchema);
export const validateMarkOrganizerManualSendTaskCallablePayload =
  lazyValidator<MarkOrganizerManualSendTaskCallablePayload>(markOrganizerManualSendTaskCallablePayloadSchema);
export const validateReplanOrganizerManualSendTasksCallablePayload =
  lazyValidator<ReplanOrganizerManualSendTasksCallablePayload>(replanOrganizerManualSendTasksCallablePayloadSchema);
export const validateOrganizerManualSendTaskCallableResponse =
  lazyValidator<OrganizerManualSendTaskCallableResponse>(organizerManualSendTaskCallableResponseSchema);
export const validateListOrganizerManualSendTasksCallableResponse =
  lazyValidator<ListOrganizerManualSendTasksCallableResponse>(listOrganizerManualSendTasksCallableResponseSchema);
export const validateReplanOrganizerManualSendTasksCallableResponse =
  lazyValidator<ReplanOrganizerManualSendTasksCallableResponse>(replanOrganizerManualSendTasksCallableResponseSchema);
export const validateOrganizerCampaignActionCallablePayload =
  lazyValidator<OrganizerCampaignActionCallablePayload>(organizerCampaignActionCallablePayloadSchema);
export const validateCompleteOrganizerWhatsappConnectionCallablePayload =
  lazyValidator<CompleteOrganizerWhatsappConnectionCallablePayload>(completeOrganizerWhatsappConnectionCallablePayloadSchema);
export const validateOrganizerSenderConnectionActionCallablePayload =
  lazyValidator<OrganizerSenderConnectionActionCallablePayload>(organizerSenderConnectionActionCallablePayloadSchema);
export const validateSendOrganizerWhatsappTestCallablePayload =
  lazyValidator<SendOrganizerWhatsappTestCallablePayload>(sendOrganizerWhatsappTestCallablePayloadSchema);
export const validateOrganizerCampaignCallableResponse =
  lazyValidator<OrganizerCampaignCallableResponse>(organizerCampaignCallableResponseSchema);
export const validateListOrganizerCampaignsCallablePayload =
  lazyValidator<ListOrganizerCampaignsCallablePayload>(listOrganizerCampaignsCallablePayloadSchema);
export const validateListOrganizerCampaignsCallableResponse =
  lazyValidator<ListOrganizerCampaignsCallableResponse>(listOrganizerCampaignsCallableResponseSchema);
export const validateOrganizerMessagingSetupCallableResponse =
  lazyValidator<OrganizerMessagingSetupCallableResponse>(organizerMessagingSetupCallableResponseSchema);
export const validateGetOrganizerProviderSetupCallablePayload =
  lazyValidator<GetOrganizerProviderSetupCallablePayload>(getOrganizerProviderSetupCallablePayloadSchema);
export const validateConnectOrganizerLumaProviderCallablePayload =
  lazyValidator<ConnectOrganizerLumaProviderCallablePayload>(connectOrganizerLumaProviderCallablePayloadSchema);
export const validateListOrganizerLumaEventsCallablePayload =
  lazyValidator<ListOrganizerLumaEventsCallablePayload>(listOrganizerLumaEventsCallablePayloadSchema);
export const validateSyncOrganizerProviderEventCallablePayload =
  lazyValidator<SyncOrganizerProviderEventCallablePayload>(syncOrganizerProviderEventCallablePayloadSchema);
export const validateDisconnectOrganizerProviderCallablePayload =
  lazyValidator<DisconnectOrganizerProviderCallablePayload>(disconnectOrganizerProviderCallablePayloadSchema);
export const validateOrganizerProviderSetupCallableResponse =
  lazyValidator<OrganizerProviderSetupCallableResponse>(organizerProviderSetupCallableResponseSchema);
export const validateListOrganizerLumaEventsCallableResponse =
  lazyValidator<ListOrganizerLumaEventsCallableResponse>(listOrganizerLumaEventsCallableResponseSchema);
export const validateSyncOrganizerProviderEventCallableResponse =
  lazyValidator<SyncOrganizerProviderEventCallableResponse>(syncOrganizerProviderEventCallableResponseSchema);
export const validateRecordOrganizerAnalyticsEventCallablePayload =
  lazyValidator<RecordOrganizerAnalyticsEventCallablePayload>(recordOrganizerAnalyticsEventCallablePayloadSchema);
export const validateRecordOrganizerAnalyticsEventCallableResponse =
  lazyValidator<RecordOrganizerAnalyticsEventCallableResponse>(recordOrganizerAnalyticsEventCallableResponseSchema);
export const validateMarkEventAttendanceCallablePayload =
  lazyValidator<MarkEventAttendanceCallablePayload>(markEventAttendanceCallablePayloadSchema);
export const validateImportEventAttendeesCallablePayload =
  lazyValidator<ImportEventAttendeesCallablePayload>(importEventAttendeesCallablePayloadSchema);
export const validateMarkEventAttendeeAttendanceCallablePayload =
  lazyValidator<MarkEventAttendeeAttendanceCallablePayload>(markEventAttendeeAttendanceCallablePayloadSchema);
export const validateSetEventAttendeeAttendanceCallablePayload =
  lazyValidator<SetEventAttendeeAttendanceCallablePayload>(setEventAttendeeAttendanceCallablePayloadSchema);
export const validateSetEventAttendeeAttendanceCallableResponse =
  lazyValidator<SetEventAttendeeAttendanceCallableResponse>(setEventAttendeeAttendanceCallableResponseSchema);
export const validateEventOperatorAccessCallablePayload =
  lazyValidator<EventOperatorAccessCallablePayload>(eventOperatorAccessCallablePayloadSchema);
export const validateEventOperatorAccessCallableResponse =
  lazyValidator<EventOperatorAccessCallableResponse>(eventOperatorAccessCallableResponseSchema);
export const validateGrantEventStaffCallablePayload =
  lazyValidator<GrantEventStaffCallablePayload>(grantEventStaffCallablePayloadSchema);
export const validateRevokeEventStaffCallablePayload =
  lazyValidator<RevokeEventStaffCallablePayload>(revokeEventStaffCallablePayloadSchema);
export const validateEventStaffListCallableResponse =
  lazyValidator<EventStaffListCallableResponse>(eventStaffListCallableResponseSchema);
export const validateRegisterPublicEventCallablePayload =
  lazyValidator<RegisterPublicEventCallablePayload>(registerPublicEventCallablePayloadSchema);
export const validateRegisterPublicEventCallableResponse =
  lazyValidator<RegisterPublicEventCallableResponse>(registerPublicEventCallableResponseSchema);
export const validateGetEventRuntimeBootstrapCallablePayload =
  lazyValidator<GetEventRuntimeBootstrapCallablePayload>(getEventRuntimeBootstrapCallablePayloadSchema);
export const validateCreateEventRehearsalCallablePayload =
  lazyValidator<CreateEventRehearsalCallablePayload>(createEventRehearsalCallablePayloadSchema);
export const validateCreateEventRehearsalCallableResponse =
  lazyValidator<CreateEventRehearsalCallableResponse>(createEventRehearsalCallableResponseSchema);
export const validateGetEventRehearsalBootstrapCallablePayload =
  lazyValidator<GetEventRehearsalBootstrapCallablePayload>(getEventRehearsalBootstrapCallablePayloadSchema);
export const validateEventRehearsalBootstrapCallableResponse =
  lazyValidator<EventRehearsalBootstrapCallableResponse>(eventRehearsalBootstrapCallableResponseSchema);
export const validateUpdateEventRehearsalSetupCallablePayload =
  lazyValidator<UpdateEventRehearsalSetupCallablePayload>(updateEventRehearsalSetupCallablePayloadSchema);
export const validateControlEventRehearsalCallablePayload =
  lazyValidator<ControlEventRehearsalCallablePayload>(controlEventRehearsalCallablePayloadSchema);
export const validateInjectEventRehearsalBehaviorCallablePayload =
  lazyValidator<InjectEventRehearsalBehaviorCallablePayload>(injectEventRehearsalBehaviorCallablePayloadSchema);
export const validateControlEventRehearsalSpatialCallablePayload =
  lazyValidator<ControlEventRehearsalSpatialCallablePayload>(controlEventRehearsalSpatialCallablePayloadSchema);
export const validateResetEventRehearsalCallablePayload =
  lazyValidator<ResetEventRehearsalCallablePayload>(resetEventRehearsalCallablePayloadSchema);
export const validateRotateEventRehearsalGuestLinkCallablePayload =
  lazyValidator<RotateEventRehearsalGuestLinkCallablePayload>(rotateEventRehearsalGuestLinkCallablePayloadSchema);
export const validateGetEventRehearsalGuestBootstrapCallablePayload =
  lazyValidator<GetEventRehearsalGuestBootstrapCallablePayload>(getEventRehearsalGuestBootstrapCallablePayloadSchema);
export const validateEventRehearsalGuestBootstrapCallableResponse =
  lazyValidator<EventRehearsalGuestBootstrapCallableResponse>(eventRehearsalGuestBootstrapCallableResponseSchema);
export const validateSubmitEventRehearsalGuestActionCallablePayload =
  lazyValidator<SubmitEventRehearsalGuestActionCallablePayload>(submitEventRehearsalGuestActionCallablePayloadSchema);
export const validateEventRehearsalReproductionCallableResponse =
  lazyValidator<EventRehearsalReproductionCallableResponse>(eventRehearsalReproductionCallableResponseSchema);
export const validateUpsertEventSuccessLayoutCallablePayload =
  lazyValidator<UpsertEventSuccessLayoutCallablePayload>(upsertEventSuccessLayoutCallablePayloadSchema);
export const validateUpsertOrganizerEventVenueCallablePayload =
  lazyValidator<UpsertOrganizerEventVenueCallablePayload>(upsertOrganizerEventVenueCallablePayloadSchema);
export const validateUpsertOrganizerEventVenueCallableResponse =
  lazyValidator<UpsertOrganizerEventVenueCallableResponse>(upsertOrganizerEventVenueCallableResponseSchema);
export const validateUpsertEventSuccessLayoutCallableResponse =
  lazyValidator<UpsertEventSuccessLayoutCallableResponse>(upsertEventSuccessLayoutCallableResponseSchema);
export const validateGetEventSuccessSpatialLayoutCallablePayload =
  lazyValidator<GetEventSuccessSpatialLayoutCallablePayload>(getEventSuccessSpatialLayoutCallablePayloadSchema);
export const validateGetEventSuccessSpatialLayoutCallableResponse =
  lazyValidator<GetEventSuccessSpatialLayoutCallableResponse>(getEventSuccessSpatialLayoutCallableResponseSchema);
export const validateEventSuccessSpatialActionCallablePayload =
  lazyValidator<EventSuccessSpatialActionCallablePayload>(eventSuccessSpatialActionCallablePayloadSchema);
export const validateEventSuccessSpatialActionCallableResponse =
  lazyValidator<EventSuccessSpatialActionCallableResponse>(eventSuccessSpatialActionCallableResponseSchema);
export const validateGetEventRuntimeBootstrapCallableResponse =
  lazyValidator<GetEventRuntimeBootstrapCallableResponse>(getEventRuntimeBootstrapCallableResponseSchema);
export const validateGetEventSuccessConversationGraphCallableResponse =
  lazyValidator<GetEventSuccessConversationGraphCallableResponse>(getEventSuccessConversationGraphCallableResponseSchema);
export const validateSubmitEventSuccessConversationGraphCallablePayload =
  lazyValidator<SubmitEventSuccessConversationGraphCallablePayload>(submitEventSuccessConversationGraphCallablePayloadSchema);
export const validateSubmitEventSuccessConversationGraphCallableResponse =
  lazyValidator<SubmitEventSuccessConversationGraphCallableResponse>(submitEventSuccessConversationGraphCallableResponseSchema);
export const validateClaimEventRuntimeAccessCallablePayload =
  lazyValidator<ClaimEventRuntimeAccessCallablePayload>(claimEventRuntimeAccessCallablePayloadSchema);
export const validateClaimEventRuntimeAccessCallableResponse =
  lazyValidator<ClaimEventRuntimeAccessCallableResponse>(claimEventRuntimeAccessCallableResponseSchema);
export const validateSubmitEventRuntimeProfileCallablePayload =
  lazyValidator<SubmitEventRuntimeProfileCallablePayload>(submitEventRuntimeProfileCallablePayloadSchema);
export const validateSubmitEventRuntimeProfileCallableResponse =
  lazyValidator<SubmitEventRuntimeProfileCallableResponse>(submitEventRuntimeProfileCallableResponseSchema);
export const validateCheckInEventRuntimeCallablePayload =
  lazyValidator<CheckInEventRuntimeCallablePayload>(checkInEventRuntimeCallablePayloadSchema);
export const validateCheckInEventRuntimeCallableResponse =
  lazyValidator<CheckInEventRuntimeCallableResponse>(checkInEventRuntimeCallableResponseSchema);
export const validateCreateEventVenueSessionCallablePayload =
  lazyValidator<CreateEventVenueSessionCallablePayload>(createEventVenueSessionCallablePayloadSchema);
export const validateCreateEventVenueSessionCallableResponse =
  lazyValidator<CreateEventVenueSessionCallableResponse>(createEventVenueSessionCallableResponseSchema);
export const validateApproveEventRuntimeClaimCallablePayload =
  lazyValidator<ApproveEventRuntimeClaimCallablePayload>(approveEventRuntimeClaimCallablePayloadSchema);
export const validateApproveEventRuntimeClaimCallableResponse =
  lazyValidator<ApproveEventRuntimeClaimCallableResponse>(approveEventRuntimeClaimCallableResponseSchema);
export const validateCreateEventRosterHandoffCallablePayload =
  lazyValidator<CreateEventRosterHandoffCallablePayload>(createEventRosterHandoffCallablePayloadSchema);
export const validateCreateEventRosterHandoffCallableResponse =
  lazyValidator<CreateEventRosterHandoffCallableResponse>(createEventRosterHandoffCallableResponseSchema);
export const validateGetOrganizerCrmSummaryCallablePayload =
  lazyValidator<GetOrganizerCrmSummaryCallablePayload>(getOrganizerCrmSummaryCallablePayloadSchema);
export const validateGetEventRosterInsightsCallablePayload =
  lazyValidator<GetEventRosterInsightsCallablePayload>(getEventRosterInsightsCallablePayloadSchema);
export const validateGetEventRosterInsightsCallableResponse =
  lazyValidator<GetEventRosterInsightsCallableResponse>(getEventRosterInsightsCallableResponseSchema);
export const validateGetOrganizerCrmSummaryCallableResponse =
  lazyValidator<GetOrganizerCrmSummaryCallableResponse>(getOrganizerCrmSummaryCallableResponseSchema);
export const validateListOrganizerContactsCallablePayload =
  lazyValidator<ListOrganizerContactsCallablePayload>(listOrganizerContactsCallablePayloadSchema);
export const validateCreateOrganizerFormCallablePayload =
  lazyValidator<CreateOrganizerFormCallablePayload>(createOrganizerFormCallablePayloadSchema);
export const validateCreateOrganizerFormCallableResponse =
  lazyValidator<CreateOrganizerFormCallableResponse>(createOrganizerFormCallableResponseSchema);
export const validateUpdateOrganizerFormDraftCallablePayload =
  lazyValidator<UpdateOrganizerFormDraftCallablePayload>(updateOrganizerFormDraftCallablePayloadSchema);
export const validateUpdateOrganizerFormDraftCallableResponse =
  lazyValidator<UpdateOrganizerFormDraftCallableResponse>(updateOrganizerFormDraftCallableResponseSchema);
export const validateGetOrganizerFormEditorCallablePayload =
  lazyValidator<GetOrganizerFormEditorCallablePayload>(getOrganizerFormEditorCallablePayloadSchema);
export const validateGetOrganizerFormEditorCallableResponse =
  lazyValidator<GetOrganizerFormEditorCallableResponse>(getOrganizerFormEditorCallableResponseSchema);
export const validateListOrganizerFormsCallablePayload =
  lazyValidator<ListOrganizerFormsCallablePayload>(listOrganizerFormsCallablePayloadSchema);
export const validateListOrganizerFormsCallableResponse =
  lazyValidator<ListOrganizerFormsCallableResponse>(listOrganizerFormsCallableResponseSchema);
export const validateValidateOrganizerFormDraftCallablePayload =
  lazyValidator<ValidateOrganizerFormDraftCallablePayload>(validateOrganizerFormDraftCallablePayloadSchema);
export const validateValidateOrganizerFormDraftCallableResponse =
  lazyValidator<ValidateOrganizerFormDraftCallableResponse>(validateOrganizerFormDraftCallableResponseSchema);
export const validatePublishOrganizerFormCallablePayload =
  lazyValidator<PublishOrganizerFormCallablePayload>(publishOrganizerFormCallablePayloadSchema);
export const validatePublishOrganizerFormCallableResponse =
  lazyValidator<PublishOrganizerFormCallableResponse>(publishOrganizerFormCallableResponseSchema);
export const validateSetOrganizerFormLifecycleCallablePayload =
  lazyValidator<SetOrganizerFormLifecycleCallablePayload>(setOrganizerFormLifecycleCallablePayloadSchema);
export const validateSetOrganizerFormLifecycleCallableResponse =
  lazyValidator<SetOrganizerFormLifecycleCallableResponse>(setOrganizerFormLifecycleCallableResponseSchema);
export const validateDuplicateOrganizerFormCallablePayload =
  lazyValidator<DuplicateOrganizerFormCallablePayload>(duplicateOrganizerFormCallablePayloadSchema);
export const validateDuplicateOrganizerFormCallableResponse =
  lazyValidator<DuplicateOrganizerFormCallableResponse>(duplicateOrganizerFormCallableResponseSchema);
export const validateDeleteOrganizerFormDraftCallablePayload =
  lazyValidator<DeleteOrganizerFormDraftCallablePayload>(deleteOrganizerFormDraftCallablePayloadSchema);
export const validateDeleteOrganizerFormDraftCallableResponse =
  lazyValidator<DeleteOrganizerFormDraftCallableResponse>(deleteOrganizerFormDraftCallableResponseSchema);
export const validateListOrganizerFormTemplatesCallablePayload =
  lazyValidator<ListOrganizerFormTemplatesCallablePayload>(listOrganizerFormTemplatesCallablePayloadSchema);
export const validateListOrganizerFormTemplatesCallableResponse =
  lazyValidator<ListOrganizerFormTemplatesCallableResponse>(listOrganizerFormTemplatesCallableResponseSchema);
export const validateGetPublicOrganizerFormCallablePayload =
  lazyValidator<GetPublicOrganizerFormCallablePayload>(getPublicOrganizerFormCallablePayloadSchema);
export const validateGetPublicOrganizerFormCallableResponse =
  lazyValidator<GetPublicOrganizerFormCallableResponse>(getPublicOrganizerFormCallableResponseSchema);
export const validateBeginOrganizerFormResponseCallablePayload =
  lazyValidator<BeginOrganizerFormResponseCallablePayload>(beginOrganizerFormResponseCallablePayloadSchema);
export const validateBeginOrganizerFormResponseCallableResponse =
  lazyValidator<BeginOrganizerFormResponseCallableResponse>(beginOrganizerFormResponseCallableResponseSchema);
export const validateSaveOrganizerFormResponseDraftCallablePayload =
  lazyValidator<SaveOrganizerFormResponseDraftCallablePayload>(saveOrganizerFormResponseDraftCallablePayloadSchema);
export const validateSaveOrganizerFormResponseDraftCallableResponse =
  lazyValidator<SaveOrganizerFormResponseDraftCallableResponse>(saveOrganizerFormResponseDraftCallableResponseSchema);
export const validateCreateOrganizerFormAssetIntentCallablePayload =
  lazyValidator<CreateOrganizerFormAssetIntentCallablePayload>(createOrganizerFormAssetIntentCallablePayloadSchema);
export const validateCreateOrganizerFormAssetIntentCallableResponse =
  lazyValidator<CreateOrganizerFormAssetIntentCallableResponse>(createOrganizerFormAssetIntentCallableResponseSchema);
export const validateFinalizeOrganizerFormAssetCallablePayload =
  lazyValidator<FinalizeOrganizerFormAssetCallablePayload>(finalizeOrganizerFormAssetCallablePayloadSchema);
export const validateFinalizeOrganizerFormAssetCallableResponse =
  lazyValidator<FinalizeOrganizerFormAssetCallableResponse>(finalizeOrganizerFormAssetCallableResponseSchema);
export const validateSubmitOrganizerFormResponseCallablePayload =
  lazyValidator<SubmitOrganizerFormResponseCallablePayload>(submitOrganizerFormResponseCallablePayloadSchema);
export const validateSubmitOrganizerFormResponseCallableResponse =
  lazyValidator<SubmitOrganizerFormResponseCallableResponse>(submitOrganizerFormResponseCallableResponseSchema);
export const validateWithdrawOrganizerFormResponseCallablePayload =
  lazyValidator<WithdrawOrganizerFormResponseCallablePayload>(withdrawOrganizerFormResponseCallablePayloadSchema);
export const validateWithdrawOrganizerFormResponseCallableResponse =
  lazyValidator<WithdrawOrganizerFormResponseCallableResponse>(withdrawOrganizerFormResponseCallableResponseSchema);
export const validateCreateOrganizerFormShareLinkCallablePayload =
  lazyValidator<CreateOrganizerFormShareLinkCallablePayload>(createOrganizerFormShareLinkCallablePayloadSchema);
export const validateCreateOrganizerFormShareLinkCallableResponse =
  lazyValidator<CreateOrganizerFormShareLinkCallableResponse>(createOrganizerFormShareLinkCallableResponseSchema);
export const validateGetOrganizerFormShareAssetsCallablePayload =
  lazyValidator<GetOrganizerFormShareAssetsCallablePayload>(getOrganizerFormShareAssetsCallablePayloadSchema);
export const validateGetOrganizerFormShareAssetsCallableResponse =
  lazyValidator<GetOrganizerFormShareAssetsCallableResponse>(getOrganizerFormShareAssetsCallableResponseSchema);
export const validateListOrganizerFormResponsesCallablePayload =
  lazyValidator<ListOrganizerFormResponsesCallablePayload>(listOrganizerFormResponsesCallablePayloadSchema);
export const validateListOrganizerFormResponsesCallableResponse =
  lazyValidator<ListOrganizerFormResponsesCallableResponse>(listOrganizerFormResponsesCallableResponseSchema);
export const validateGetOrganizerFormResponseDetailCallablePayload =
  lazyValidator<GetOrganizerFormResponseDetailCallablePayload>(getOrganizerFormResponseDetailCallablePayloadSchema);
export const validateGetOrganizerFormResponseDetailCallableResponse =
  lazyValidator<GetOrganizerFormResponseDetailCallableResponse>(getOrganizerFormResponseDetailCallableResponseSchema);
export const validateGetOrganizerFormAnalyticsCallablePayload =
  lazyValidator<GetOrganizerFormAnalyticsCallablePayload>(getOrganizerFormAnalyticsCallablePayloadSchema);
export const validateGetOrganizerFormAnalyticsCallableResponse =
  lazyValidator<GetOrganizerFormAnalyticsCallableResponse>(getOrganizerFormAnalyticsCallableResponseSchema);
export const validateRequestOrganizerFormExportCallablePayload =
  lazyValidator<RequestOrganizerFormExportCallablePayload>(requestOrganizerFormExportCallablePayloadSchema);
export const validateRequestOrganizerFormExportCallableResponse =
  lazyValidator<RequestOrganizerFormExportCallableResponse>(requestOrganizerFormExportCallableResponseSchema);
export const validateCreateOrganizerFormAutomationCallablePayload =
  lazyValidator<CreateOrganizerFormAutomationCallablePayload>(createOrganizerFormAutomationCallablePayloadSchema);
export const validateCreateOrganizerFormAutomationCallableResponse =
  lazyValidator<CreateOrganizerFormAutomationCallableResponse>(createOrganizerFormAutomationCallableResponseSchema);
export const validateSetOrganizerFormAutomationStateCallablePayload =
  lazyValidator<SetOrganizerFormAutomationStateCallablePayload>(setOrganizerFormAutomationStateCallablePayloadSchema);
export const validateSetOrganizerFormAutomationStateCallableResponse =
  lazyValidator<SetOrganizerFormAutomationStateCallableResponse>(setOrganizerFormAutomationStateCallableResponseSchema);
export const validateListOrganizerFormAutomationRunsCallablePayload =
  lazyValidator<ListOrganizerFormAutomationRunsCallablePayload>(listOrganizerFormAutomationRunsCallablePayloadSchema);
export const validateListOrganizerFormAutomationRunsCallableResponse =
  lazyValidator<ListOrganizerFormAutomationRunsCallableResponse>(listOrganizerFormAutomationRunsCallableResponseSchema);
export const validatePreviewOrganizerFormConversionCallablePayload =
  lazyValidator<PreviewOrganizerFormConversionCallablePayload>(previewOrganizerFormConversionCallablePayloadSchema);
export const validatePreviewOrganizerFormConversionCallableResponse =
  lazyValidator<PreviewOrganizerFormConversionCallableResponse>(previewOrganizerFormConversionCallableResponseSchema);
export const validateConvertOrganizerFormResponseCallablePayload =
  lazyValidator<ConvertOrganizerFormResponseCallablePayload>(convertOrganizerFormResponseCallablePayloadSchema);
export const validateConvertOrganizerFormResponseCallableResponse =
  lazyValidator<ConvertOrganizerFormResponseCallableResponse>(convertOrganizerFormResponseCallableResponseSchema);
export const validatePublishOrganizerApplicationFormCallablePayload =
  lazyValidator<PublishOrganizerApplicationFormCallablePayload>(publishOrganizerApplicationFormCallablePayloadSchema);
export const validateGetParticipantOrganizerApplicationFormCallablePayload =
  lazyValidator<GetParticipantOrganizerApplicationFormCallablePayload>(getParticipantOrganizerApplicationFormCallablePayloadSchema);
export const validateGetParticipantOrganizerApplicationFormCallableResponse =
  lazyValidator<GetParticipantOrganizerApplicationFormCallableResponse>(getParticipantOrganizerApplicationFormCallableResponseSchema);
export const validateSubmitParticipantOrganizerApplicationCallablePayload =
  lazyValidator<SubmitParticipantOrganizerApplicationCallablePayload>(submitParticipantOrganizerApplicationCallablePayloadSchema);
export const validateSubmitParticipantOrganizerApplicationCallableResponse =
  lazyValidator<SubmitParticipantOrganizerApplicationCallableResponse>(submitParticipantOrganizerApplicationCallableResponseSchema);
export const validateRevokeParticipantOrganizerDataGrantCallablePayload =
  lazyValidator<RevokeParticipantOrganizerDataGrantCallablePayload>(revokeParticipantOrganizerDataGrantCallablePayloadSchema);
export const validateRevokeParticipantOrganizerDataGrantCallableResponse =
  lazyValidator<RevokeParticipantOrganizerDataGrantCallableResponse>(revokeParticipantOrganizerDataGrantCallableResponseSchema);
export const validatePublishOrganizerApplicationFormCallableResponse =
  lazyValidator<PublishOrganizerApplicationFormCallableResponse>(publishOrganizerApplicationFormCallableResponseSchema);
export const validatePreviewOrganizerApplicationImportCallablePayload =
  lazyValidator<PreviewOrganizerApplicationImportCallablePayload>(previewOrganizerApplicationImportCallablePayloadSchema);
export const validatePreviewOrganizerApplicationImportCallableResponse =
  lazyValidator<PreviewOrganizerApplicationImportCallableResponse>(previewOrganizerApplicationImportCallableResponseSchema);
export const validateImportOrganizerApplicationsCallablePayload =
  lazyValidator<ImportOrganizerApplicationsCallablePayload>(importOrganizerApplicationsCallablePayloadSchema);
export const validateImportOrganizerApplicationsCallableResponse =
  lazyValidator<ImportOrganizerApplicationsCallableResponse>(importOrganizerApplicationsCallableResponseSchema);
export const validateListOrganizerApplicationsCallablePayload =
  lazyValidator<ListOrganizerApplicationsCallablePayload>(listOrganizerApplicationsCallablePayloadSchema);
export const validateListOrganizerApplicationsCallableResponse =
  lazyValidator<ListOrganizerApplicationsCallableResponse>(listOrganizerApplicationsCallableResponseSchema);
export const validateListOrganizerAttentionItemsCallablePayload =
  lazyValidator<ListOrganizerAttentionItemsCallablePayload>(listOrganizerAttentionItemsCallablePayloadSchema);
export const validateListOrganizerAttentionItemsCallableResponse =
  lazyValidator<ListOrganizerAttentionItemsCallableResponse>(listOrganizerAttentionItemsCallableResponseSchema);
export const validateGetOrganizerApplicationDetailCallablePayload =
  lazyValidator<GetOrganizerApplicationDetailCallablePayload>(getOrganizerApplicationDetailCallablePayloadSchema);
export const validateGetOrganizerApplicationDetailCallableResponse =
  lazyValidator<GetOrganizerApplicationDetailCallableResponse>(getOrganizerApplicationDetailCallableResponseSchema);
export const validateReviewOrganizerApplicationCallablePayload =
  lazyValidator<ReviewOrganizerApplicationCallablePayload>(reviewOrganizerApplicationCallablePayloadSchema);
export const validateReviewOrganizerApplicationCallableResponse =
  lazyValidator<ReviewOrganizerApplicationCallableResponse>(reviewOrganizerApplicationCallableResponseSchema);
export const validateCreateOrganizerContactCallablePayload =
  lazyValidator<CreateOrganizerContactCallablePayload>(createOrganizerContactCallablePayloadSchema);
export const validateCreateOrganizerContactCallableResponse =
  lazyValidator<CreateOrganizerContactCallableResponse>(createOrganizerContactCallableResponseSchema);
export const validateListOrganizerContactsCallableResponse =
  lazyValidator<ListOrganizerContactsCallableResponse>(listOrganizerContactsCallableResponseSchema);
export const validateGetOrganizerContactDetailCallablePayload =
  lazyValidator<GetOrganizerContactDetailCallablePayload>(getOrganizerContactDetailCallablePayloadSchema);
export const validateGetOrganizerContactDetailCallableResponse =
  lazyValidator<GetOrganizerContactDetailCallableResponse>(getOrganizerContactDetailCallableResponseSchema);
export const validateResolveOrganizerCommunicationPlanCallablePayload =
  lazyValidator<ResolveOrganizerCommunicationPlanCallablePayload>(resolveOrganizerCommunicationPlanCallablePayloadSchema);
export const validateResolveOrganizerCommunicationPlanCallableResponse =
  lazyValidator<ResolveOrganizerCommunicationPlanCallableResponse>(resolveOrganizerCommunicationPlanCallableResponseSchema);
export const validateMutateOrganizerContactCallablePayload =
  lazyValidator<MutateOrganizerContactCallablePayload>(mutateOrganizerContactCallablePayloadSchema);
export const validateMutateOrganizerContactCallableResponse =
  lazyValidator<MutateOrganizerContactCallableResponse>(mutateOrganizerContactCallableResponseSchema);
export const validateCreateOrganizerContactNoteCallablePayload =
  lazyValidator<CreateOrganizerContactNoteCallablePayload>(createOrganizerContactNoteCallablePayloadSchema);
export const validateMutateOrganizerContactNoteCallablePayload =
  lazyValidator<MutateOrganizerContactNoteCallablePayload>(mutateOrganizerContactNoteCallablePayloadSchema);
export const validateOrganizerContactNoteCallableResponse =
  lazyValidator<OrganizerContactNoteCallableResponse>(organizerContactNoteCallableResponseSchema);
export const validateExportOrganizerContactsCallablePayload =
  lazyValidator<ExportOrganizerContactsCallablePayload>(exportOrganizerContactsCallablePayloadSchema);
export const validateExportOrganizerContactsCallableResponse =
  lazyValidator<ExportOrganizerContactsCallableResponse>(exportOrganizerContactsCallableResponseSchema);
export const validateMergeOrganizerContactsCallablePayload =
  lazyValidator<MergeOrganizerContactsCallablePayload>(mergeOrganizerContactsCallablePayloadSchema);
export const validateListOrganizerContactMergeCandidatesCallablePayload =
  lazyValidator<ListOrganizerContactMergeCandidatesCallablePayload>(listOrganizerContactMergeCandidatesCallablePayloadSchema);
export const validateListOrganizerContactMergeCandidatesCallableResponse =
  lazyValidator<ListOrganizerContactMergeCandidatesCallableResponse>(listOrganizerContactMergeCandidatesCallableResponseSchema);
export const validateReviewOrganizerContactMergeCandidateCallablePayload =
  lazyValidator<ReviewOrganizerContactMergeCandidateCallablePayload>(reviewOrganizerContactMergeCandidateCallablePayloadSchema);
export const validateReviewOrganizerContactMergeCandidateCallableResponse =
  lazyValidator<ReviewOrganizerContactMergeCandidateCallableResponse>(reviewOrganizerContactMergeCandidateCallableResponseSchema);
export const validateListOrganizerWhatsappThreadsCallablePayload =
  lazyValidator<ListOrganizerWhatsappThreadsCallablePayload>(listOrganizerWhatsappThreadsCallablePayloadSchema);
export const validateListOrganizerWhatsappThreadsCallableResponse =
  lazyValidator<ListOrganizerWhatsappThreadsCallableResponse>(listOrganizerWhatsappThreadsCallableResponseSchema);
export const validateGetOrganizerWhatsappThreadCallablePayload =
  lazyValidator<GetOrganizerWhatsappThreadCallablePayload>(getOrganizerWhatsappThreadCallablePayloadSchema);
export const validateGetOrganizerWhatsappThreadCallableResponse =
  lazyValidator<GetOrganizerWhatsappThreadCallableResponse>(getOrganizerWhatsappThreadCallableResponseSchema);
export const validateSendOrganizerWhatsappReplyCallablePayload =
  lazyValidator<SendOrganizerWhatsappReplyCallablePayload>(sendOrganizerWhatsappReplyCallablePayloadSchema);
export const validateSendOrganizerWhatsappReplyCallableResponse =
  lazyValidator<SendOrganizerWhatsappReplyCallableResponse>(sendOrganizerWhatsappReplyCallableResponseSchema);
export const validateUnmergeOrganizerContactsCallablePayload =
  lazyValidator<UnmergeOrganizerContactsCallablePayload>(unmergeOrganizerContactsCallablePayloadSchema);
export const validateMutateOrganizerContactMergeCallableResponse =
  lazyValidator<MutateOrganizerContactMergeCallableResponse>(mutateOrganizerContactMergeCallableResponseSchema);
export const validateEventJoinRequestDecisionCallablePayload =
  lazyValidator<EventJoinRequestDecisionCallablePayload>(eventJoinRequestDecisionCallablePayloadSchema);
export const validateOverrideEventSuccessRotationsCallablePayload =
  lazyValidator<OverrideEventSuccessRotationsCallablePayload>(overrideEventSuccessRotationsCallablePayloadSchema);
export const validatePrepareEventSuccessRotationDraftCallablePayload =
  lazyValidator<PrepareEventSuccessRotationDraftCallablePayload>(prepareEventSuccessRotationDraftCallablePayloadSchema);
export const validatePublishEventSuccessRotationRoundCallablePayload =
  lazyValidator<PublishEventSuccessRotationRoundCallablePayload>(publishEventSuccessRotationRoundCallablePayloadSchema);
export const validateEventSuccessLiveActionCallablePayload =
  lazyValidator<EventSuccessLiveActionCallablePayload>(eventSuccessLiveActionCallablePayloadSchema);
export const validateSetEventSuccessAccountabilityResolutionCallablePayload =
  lazyValidator<SetEventSuccessAccountabilityResolutionCallablePayload>(setEventSuccessAccountabilityResolutionCallablePayloadSchema);
export const validateRecordEventSuccessUnitOutcomesCallablePayload =
  lazyValidator<RecordEventSuccessUnitOutcomesCallablePayload>(recordEventSuccessUnitOutcomesCallablePayloadSchema);
export const validateRecordEventSuccessUnitOutcomesCallableResponse =
  lazyValidator<RecordEventSuccessUnitOutcomesCallableResponse>(recordEventSuccessUnitOutcomesCallableResponseSchema);
export const validateHeartbeatEventSuccessPresenceCallablePayload =
  lazyValidator<HeartbeatEventSuccessPresenceCallablePayload>(heartbeatEventSuccessPresenceCallablePayloadSchema);
export const validateHeartbeatEventSuccessPresenceCallableResponse =
  lazyValidator<HeartbeatEventSuccessPresenceCallableResponse>(heartbeatEventSuccessPresenceCallableResponseSchema);
export const validatePublishEventLivePositionCallablePayload =
  lazyValidator<PublishEventLivePositionCallablePayload>(publishEventLivePositionCallablePayloadSchema);
export const validatePublishEventLivePositionCallableResponse =
  lazyValidator<PublishEventLivePositionCallableResponse>(publishEventLivePositionCallableResponseSchema);
export const validateGetEventSuccessPresenceSummaryCallableResponse =
  lazyValidator<GetEventSuccessPresenceSummaryCallableResponse>(getEventSuccessPresenceSummaryCallableResponseSchema);
export const validateResolveEventSuccessLateArrivalCallablePayload =
  lazyValidator<ResolveEventSuccessLateArrivalCallablePayload>(resolveEventSuccessLateArrivalCallablePayloadSchema);
export const validateResolveEventSuccessLateArrivalCallableResponse =
  lazyValidator<ResolveEventSuccessLateArrivalCallableResponse>(resolveEventSuccessLateArrivalCallableResponseSchema);
export const validateOverrideEventSuccessGroupsCallablePayload =
  lazyValidator<OverrideEventSuccessGroupsCallablePayload>(overrideEventSuccessGroupsCallablePayloadSchema);
export const validateSubmitEventSuccessWingmanRequestCallablePayload =
  lazyValidator<SubmitEventSuccessWingmanRequestCallablePayload>(submitEventSuccessWingmanRequestCallablePayloadSchema);
export const validateStartEventSuccessFirstHelloMissionCallablePayload =
  lazyValidator<StartEventSuccessFirstHelloMissionCallablePayload>(startEventSuccessFirstHelloMissionCallablePayloadSchema);
export const validateCompleteEventSuccessFirstHelloMissionCallablePayload =
  lazyValidator<CompleteEventSuccessFirstHelloMissionCallablePayload>(completeEventSuccessFirstHelloMissionCallablePayloadSchema);
export const validateMarkEventAttendanceCallableResponse =
  lazyValidator<MarkEventAttendanceCallableResponse>(markEventAttendanceCallableResponseSchema);
export const validateSelfCheckInAttendanceCallablePayload =
  lazyValidator<SelfCheckInAttendanceCallablePayload>(selfCheckInAttendanceCallablePayloadSchema);
export const validateCreateEventReviewCallablePayload =
  lazyValidator<CreateEventReviewCallablePayload>(createEventReviewCallablePayloadSchema);
export const validateCreatePublicClubReviewCallablePayload =
  lazyValidator<CreatePublicClubReviewCallablePayload>(createPublicClubReviewCallablePayloadSchema);
export const validateCreatePublicClubReviewCallableResponse =
  lazyValidator<CreatePublicClubReviewCallableResponse>(createPublicClubReviewCallableResponseSchema);
export const validateListPublicClubReviewsCallablePayload =
  lazyValidator<ListPublicClubReviewsCallablePayload>(listPublicClubReviewsCallablePayloadSchema);
export const validateListPublicClubReviewsCallableResponse =
  lazyValidator<ListPublicClubReviewsCallableResponse>(listPublicClubReviewsCallableResponseSchema);
export const validateCreatePublicOrganizerReviewCallablePayload =
  lazyValidator<CreatePublicOrganizerReviewCallablePayload>(createPublicOrganizerReviewCallablePayloadSchema);
export const validateCreatePublicOrganizerReviewCallableResponse =
  lazyValidator<CreatePublicOrganizerReviewCallableResponse>(createPublicOrganizerReviewCallableResponseSchema);
export const validateListPublicOrganizerReviewsCallablePayload =
  lazyValidator<ListPublicOrganizerReviewsCallablePayload>(listPublicOrganizerReviewsCallablePayloadSchema);
export const validateListPublicOrganizerReviewsCallableResponse =
  lazyValidator<ListPublicOrganizerReviewsCallableResponse>(listPublicOrganizerReviewsCallableResponseSchema);
export const validateUpdateEventReviewCallablePayload =
  lazyValidator<UpdateEventReviewCallablePayload>(updateEventReviewCallablePayloadSchema);
export const validateDeleteEventReviewCallablePayload =
  lazyValidator<DeleteEventReviewCallablePayload>(deleteEventReviewCallablePayloadSchema);
export const validateSetReviewResponseCallablePayload =
  lazyValidator<SetReviewResponseCallablePayload>(setReviewResponseCallablePayloadSchema);
export const validateBlockUserCallablePayload =
  lazyValidator<BlockUserCallablePayload>(blockUserCallablePayloadSchema);
export const validateUnblockUserCallablePayload =
  lazyValidator<UnblockUserCallablePayload>(unblockUserCallablePayloadSchema);
export const validateReportUserCallablePayload =
  lazyValidator<ReportUserCallablePayload>(reportUserCallablePayloadSchema);
export const validateRequestSuvbotDemoOperationCallablePayload =
  lazyValidator<RequestSuvbotDemoOperationCallablePayload>(requestSuvbotDemoOperationCallablePayloadSchema);
export const validateListSuvbotDemoActionsCallableResponse =
  lazyValidator<ListSuvbotDemoActionsCallableResponse>(listSuvbotDemoActionsCallableResponseSchema);
export const validateVerifyRazorpayPaymentCallablePayload =
  lazyValidator<VerifyRazorpayPaymentCallablePayload>(verifyRazorpayPaymentCallablePayloadSchema);
export const validateEventBookingCallablePayload =
  lazyValidator<EventBookingCallablePayload>(eventBookingCallablePayloadSchema);
export const validateCreateRazorpayOrderCallablePayload =
  lazyValidator<CreateRazorpayOrderCallablePayload>(createRazorpayOrderCallablePayloadSchema);
export const validateRazorpayOrderCallableResponse =
  lazyValidator<RazorpayOrderCallableResponse>(razorpayOrderCallableResponseSchema);
export const validateCreateStripeCheckoutSessionCallablePayload =
  lazyValidator<CreateStripeCheckoutSessionCallablePayload>(createStripeCheckoutSessionCallablePayloadSchema);
export const validateStripeCheckoutSessionCallableResponse =
  lazyValidator<StripeCheckoutSessionCallableResponse>(stripeCheckoutSessionCallableResponseSchema);
export const validateCreateStripeHostOnboardingLinkCallablePayload =
  lazyValidator<CreateStripeHostOnboardingLinkCallablePayload>(createStripeHostOnboardingLinkCallablePayloadSchema);
export const validateRefreshStripeHostPaymentAccountCallablePayload =
  lazyValidator<RefreshStripeHostPaymentAccountCallablePayload>(refreshStripeHostPaymentAccountCallablePayloadSchema);
export const validateCreateRazorpayHostPaymentAccountCallablePayload =
  lazyValidator<CreateRazorpayHostPaymentAccountCallablePayload>(createRazorpayHostPaymentAccountCallablePayloadSchema);
export const validateRefreshRazorpayHostPaymentAccountCallablePayload =
  lazyValidator<RefreshRazorpayHostPaymentAccountCallablePayload>(refreshRazorpayHostPaymentAccountCallablePayloadSchema);
export const validateStripeHostOnboardingLinkCallableResponse =
  lazyValidator<StripeHostOnboardingLinkCallableResponse>(stripeHostOnboardingLinkCallableResponseSchema);
export const validatePlacesAutocompleteCallablePayload =
  lazyValidator<PlacesAutocompleteCallablePayload>(placesAutocompleteCallablePayloadSchema);
export const validatePlacesAutocompleteCallableResponse =
  lazyValidator<PlacesAutocompleteCallableResponse>(placesAutocompleteCallableResponseSchema);
export const validatePlaceDetailsCallablePayload =
  lazyValidator<PlaceDetailsCallablePayload>(placeDetailsCallablePayloadSchema);
export const validatePlaceDetailsCallableResponse =
  lazyValidator<PlaceDetailsCallableResponse>(placeDetailsCallableResponseSchema);
export const validateExploreSearchCallablePayload =
  lazyValidator<ExploreSearchCallablePayload>(exploreSearchCallablePayloadSchema);
export const validateExploreSearchCallableResponse =
  lazyValidator<ExploreSearchCallableResponse>(exploreSearchCallableResponseSchema);
export const validateWebsiteHostListingProjection =
  lazyValidator<WebsiteHostListingProjection>(websiteHostListingProjectionSchema);
export const validateFetchEventSuccessWingmanCandidatesCallableResponse =
  lazyValidator<FetchEventSuccessWingmanCandidatesCallableResponse>(fetchEventSuccessWingmanCandidatesCallableResponseSchema);
export const validateFetchSwipeCandidatesCallableResponse =
  lazyValidator<FetchSwipeCandidatesCallableResponse>(fetchSwipeCandidatesCallableResponseSchema);
export const validateSetCrossPathsEventConsentCallableResponse =
  lazyValidator<SetCrossPathsEventConsentCallableResponse>(setCrossPathsEventConsentCallableResponseSchema);
export const validateGetCrossPathsSuggestionsCallableResponse =
  lazyValidator<GetCrossPathsSuggestionsCallableResponse>(getCrossPathsSuggestionsCallableResponseSchema);
export const validateSendCrossPathsInvitationCallableResponse =
  lazyValidator<SendCrossPathsInvitationCallableResponse>(sendCrossPathsInvitationCallableResponseSchema);
export const validateRespondCrossPathsInvitationCallableResponse =
  lazyValidator<RespondCrossPathsInvitationCallableResponse>(respondCrossPathsInvitationCallableResponseSchema);
export const validateCancelCrossPathsInvitationOrPlanCallableResponse =
  lazyValidator<CancelCrossPathsInvitationOrPlanCallableResponse>(cancelCrossPathsInvitationOrPlanCallableResponseSchema);
export const validateCreateProfileDecisionClientWrite =
  lazyValidator<CreateProfileDecisionClientWrite>(createProfileDecisionClientWriteSchema);
export const validateCreateChatMessageClientWrite =
  lazyValidator<CreateChatMessageClientWrite>(createChatMessageClientWriteSchema);
export const validateCreateSavedEventClientWrite =
  lazyValidator<CreateSavedEventClientWrite>(createSavedEventClientWriteSchema);
export const validateDeleteSavedEventClientWrite =
  lazyValidator<DeleteSavedEventClientWrite>(deleteSavedEventClientWriteSchema);
export const validateMarkNotificationReadClientWrite =
  lazyValidator<MarkNotificationReadClientWrite>(markNotificationReadClientWriteSchema);
export const validateResetMatchUnreadCountClientWrite =
  lazyValidator<ResetMatchUnreadCountClientWrite>(resetMatchUnreadCountClientWriteSchema);
export const validateAdminGetOverviewCallablePayload =
  lazyValidator<AdminGetOverviewCallablePayload>(adminGetOverviewCallablePayloadSchema);
export const validateAdminGetOverviewCallableResponse =
  lazyValidator<AdminGetOverviewCallableResponse>(adminGetOverviewCallableResponseSchema);
export const validateAdminDecideAccessApplicationCallablePayload =
  lazyValidator<AdminDecideAccessApplicationCallablePayload>(adminDecideAccessApplicationCallablePayloadSchema);
export const validateAdminDecideAccessApplicationCallableResponse =
  lazyValidator<AdminDecideAccessApplicationCallableResponse>(adminDecideAccessApplicationCallableResponseSchema);
export const validateAdminSetAdminUserRolesCallablePayload =
  lazyValidator<AdminSetAdminUserRolesCallablePayload>(adminSetAdminUserRolesCallablePayloadSchema);
export const validateAdminSetAdminUserRolesCallableResponse =
  lazyValidator<AdminSetAdminUserRolesCallableResponse>(adminSetAdminUserRolesCallableResponseSchema);
export const validateAdminDecideSafetyTriageItemCallablePayload =
  lazyValidator<AdminDecideSafetyTriageItemCallablePayload>(adminDecideSafetyTriageItemCallablePayloadSchema);
export const validateAdminDecideSafetyTriageItemCallableResponse =
  lazyValidator<AdminDecideSafetyTriageItemCallableResponse>(adminDecideSafetyTriageItemCallableResponseSchema);
export const validateAdminAssignSafetyTriageItemCallablePayload =
  lazyValidator<AdminAssignSafetyTriageItemCallablePayload>(adminAssignSafetyTriageItemCallablePayloadSchema);
export const validateAdminAssignSafetyTriageItemCallableResponse =
  lazyValidator<AdminAssignSafetyTriageItemCallableResponse>(adminAssignSafetyTriageItemCallableResponseSchema);
export const validateAdminCreateOrganizerDraftFromCandidateCallablePayload =
  lazyValidator<AdminCreateOrganizerDraftFromCandidateCallablePayload>(adminCreateOrganizerDraftFromCandidateCallablePayloadSchema);
export const validateAdminCreateOrganizerDraftFromCandidateCallableResponse =
  lazyValidator<AdminCreateOrganizerDraftFromCandidateCallableResponse>(adminCreateOrganizerDraftFromCandidateCallableResponseSchema);
export const validateAdminCreateMarketingContentDraftCallablePayload =
  lazyValidator<AdminCreateMarketingContentDraftCallablePayload>(adminCreateMarketingContentDraftCallablePayloadSchema);
export const validateAdminCreateMarketingContentDraftCallableResponse =
  lazyValidator<AdminCreateMarketingContentDraftCallableResponse>(adminCreateMarketingContentDraftCallableResponseSchema);
export const validateAdminRecordMarketingReviewDecisionCallablePayload =
  lazyValidator<AdminRecordMarketingReviewDecisionCallablePayload>(adminRecordMarketingReviewDecisionCallablePayloadSchema);
export const validateAdminRecordMarketingReviewDecisionCallableResponse =
  lazyValidator<AdminRecordMarketingReviewDecisionCallableResponse>(adminRecordMarketingReviewDecisionCallableResponseSchema);
export const validateAdminListCrossPathsShowcaseCandidatesCallableResponse =
  lazyValidator<AdminListCrossPathsShowcaseCandidatesCallableResponse>(adminListCrossPathsShowcaseCandidatesCallableResponseSchema);
export const validateAdminSetCrossPathsShowcaseEligibilityCallableResponse =
  lazyValidator<AdminSetCrossPathsShowcaseEligibilityCallableResponse>(adminSetCrossPathsShowcaseEligibilityCallableResponseSchema);
export const validateJoinWaitlistHTTPRequest =
  lazyValidator<JoinWaitlistHTTPRequest>(joinWaitlistHTTPRequestSchema);
export const validateJoinWaitlistHTTPResponse =
  lazyValidator<JoinWaitlistHTTPResponse>(joinWaitlistHTTPResponseSchema);

export function schemaErrorMessages(
  validator: ValidateFunction<unknown>
): string[] {
  return (validator.errors ?? []).map((error) => {
    const location = error.instancePath || "/";
    return `${location} ${error.message ?? "failed validation"}`;
  });
}
