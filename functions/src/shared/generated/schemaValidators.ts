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
import {OrganizerTeamMembershipDocument} from "./organizerTeamMembershipDocument";
import {OrganizerFollowDocument} from "./organizerFollowDocument";
import {OrganizerCommunicationPreferenceDocument} from "./organizerCommunicationPreferenceDocument";
import {OrganizerContactDocument} from "./organizerContactDocument";
import {OrganizerContactNoteDocument} from "./organizerContactNoteDocument";
import {OrganizerContactTagVocabularyDocument} from "./organizerContactTagVocabularyDocument";
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
import {EventSuccessLateArrivalDocument} from "./eventSuccessLateArrivalDocument";
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
import {UpsertEventSuccessLayoutCallablePayload} from "./upsertEventSuccessLayoutCallablePayload";
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
import {GetOrganizerApplicationDetailCallablePayload} from "./getOrganizerApplicationDetailCallablePayload";
import {GetOrganizerApplicationDetailCallableResponse} from "./getOrganizerApplicationDetailCallableResponse";
import {ReviewOrganizerApplicationCallablePayload} from "./reviewOrganizerApplicationCallablePayload";
import {ReviewOrganizerApplicationCallableResponse} from "./reviewOrganizerApplicationCallableResponse";
import {CreateOrganizerContactCallablePayload} from "./createOrganizerContactCallablePayload";
import {CreateOrganizerContactCallableResponse} from "./createOrganizerContactCallableResponse";
import {ListOrganizerContactsCallableResponse} from "./listOrganizerContactsCallableResponse";
import {GetOrganizerContactDetailCallablePayload} from "./getOrganizerContactDetailCallablePayload";
import {GetOrganizerContactDetailCallableResponse} from "./getOrganizerContactDetailCallableResponse";
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
  organizerTeamMembershipDocumentSchema,
  organizerFollowDocumentSchema,
  organizerCommunicationPreferenceDocumentSchema,
  organizerContactDocumentSchema,
  organizerContactNoteDocumentSchema,
  organizerContactTagVocabularyDocumentSchema,
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
  eventSuccessLateArrivalDocumentSchema,
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
  upsertEventSuccessLayoutCallablePayloadSchema,
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
  getOrganizerApplicationDetailCallablePayloadSchema,
  getOrganizerApplicationDetailCallableResponseSchema,
  reviewOrganizerApplicationCallablePayloadSchema,
  reviewOrganizerApplicationCallableResponseSchema,
  createOrganizerContactCallablePayloadSchema,
  createOrganizerContactCallableResponseSchema,
  listOrganizerContactsCallableResponseSchema,
  getOrganizerContactDetailCallablePayloadSchema,
  getOrganizerContactDetailCallableResponseSchema,
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

export const validateMobileFormState:
  ValidateFunction<MobileFormState> =
    ajv.compile(mobileFormStateSchema) as
      ValidateFunction<MobileFormState>;
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
export const validateEventOrigin:
  ValidateFunction<EventOrigin> =
    ajv.compile(eventOriginSchema) as
      ValidateFunction<EventOrigin>;
export const validateEventRuntimeAccess:
  ValidateFunction<EventRuntimeAccess> =
    ajv.compile(eventRuntimeAccessSchema) as
      ValidateFunction<EventRuntimeAccess>;
export const validateActivityPreferences:
  ValidateFunction<ActivityPreferences> =
    ajv.compile(activityPreferencesSchema) as
      ValidateFunction<ActivityPreferences>;
export const validateOrganizerSupplyCapabilities:
  ValidateFunction<OrganizerSupplyCapabilities> =
    ajv.compile(organizerSupplyCapabilitiesSchema) as
      ValidateFunction<OrganizerSupplyCapabilities>;
export const validateExternalEventBlockerResolution:
  ValidateFunction<ExternalEventBlockerResolution> =
    ajv.compile(externalEventBlockerResolutionSchema) as
      ValidateFunction<ExternalEventBlockerResolution>;
export const validateExternalEventPublicationReceiptDocument:
  ValidateFunction<ExternalEventPublicationReceiptDocument> =
    ajv.compile(externalEventPublicationReceiptDocumentSchema) as
      ValidateFunction<ExternalEventPublicationReceiptDocument>;
export const validateConfigCitiesDocument:
  ValidateFunction<ConfigCitiesDocument> =
    ajv.compile(configCitiesDocumentSchema) as
      ValidateFunction<ConfigCitiesDocument>;
export const validateOnboardingDraftDocument:
  ValidateFunction<OnboardingDraftDocument> =
    ajv.compile(onboardingDraftDocumentSchema) as
      ValidateFunction<OnboardingDraftDocument>;
export const validateAccessApplicationDocument:
  ValidateFunction<AccessApplicationDocument> =
    ajv.compile(accessApplicationDocumentSchema) as
      ValidateFunction<AccessApplicationDocument>;
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
export const validateOrganizerDocument:
  ValidateFunction<OrganizerDocument> =
    ajv.compile(organizerDocumentSchema) as
      ValidateFunction<OrganizerDocument>;
export const validateOrganizerPostDocument:
  ValidateFunction<OrganizerPostDocument> =
    ajv.compile(organizerPostDocumentSchema) as
      ValidateFunction<OrganizerPostDocument>;
export const validateOrganizerTeamMembershipDocument:
  ValidateFunction<OrganizerTeamMembershipDocument> =
    ajv.compile(organizerTeamMembershipDocumentSchema) as
      ValidateFunction<OrganizerTeamMembershipDocument>;
export const validateOrganizerFollowDocument:
  ValidateFunction<OrganizerFollowDocument> =
    ajv.compile(organizerFollowDocumentSchema) as
      ValidateFunction<OrganizerFollowDocument>;
export const validateOrganizerCommunicationPreferenceDocument:
  ValidateFunction<OrganizerCommunicationPreferenceDocument> =
    ajv.compile(organizerCommunicationPreferenceDocumentSchema) as
      ValidateFunction<OrganizerCommunicationPreferenceDocument>;
export const validateOrganizerContactDocument:
  ValidateFunction<OrganizerContactDocument> =
    ajv.compile(organizerContactDocumentSchema) as
      ValidateFunction<OrganizerContactDocument>;
export const validateOrganizerContactNoteDocument:
  ValidateFunction<OrganizerContactNoteDocument> =
    ajv.compile(organizerContactNoteDocumentSchema) as
      ValidateFunction<OrganizerContactNoteDocument>;
export const validateOrganizerContactTagVocabularyDocument:
  ValidateFunction<OrganizerContactTagVocabularyDocument> =
    ajv.compile(organizerContactTagVocabularyDocumentSchema) as
      ValidateFunction<OrganizerContactTagVocabularyDocument>;
export const validateOrganizerContactIdentityLinkDocument:
  ValidateFunction<OrganizerContactIdentityLinkDocument> =
    ajv.compile(organizerContactIdentityLinkDocumentSchema) as
      ValidateFunction<OrganizerContactIdentityLinkDocument>;
export const validateOrganizerContactIdentityClaimDocument:
  ValidateFunction<OrganizerContactIdentityClaimDocument> =
    ajv.compile(organizerContactIdentityClaimDocumentSchema) as
      ValidateFunction<OrganizerContactIdentityClaimDocument>;
export const validateOrganizerContactEventEdgeDocument:
  ValidateFunction<OrganizerContactEventEdgeDocument> =
    ajv.compile(organizerContactEventEdgeDocumentSchema) as
      ValidateFunction<OrganizerContactEventEdgeDocument>;
export const validateOrganizerContactTraitDocument:
  ValidateFunction<OrganizerContactTraitDocument> =
    ajv.compile(organizerContactTraitDocumentSchema) as
      ValidateFunction<OrganizerContactTraitDocument>;
export const validateOrganizerAudienceSummaryDocument:
  ValidateFunction<OrganizerAudienceSummaryDocument> =
    ajv.compile(organizerAudienceSummaryDocumentSchema) as
      ValidateFunction<OrganizerAudienceSummaryDocument>;
export const validateOrganizerAudienceProjectionReceiptDocument:
  ValidateFunction<OrganizerAudienceProjectionReceiptDocument> =
    ajv.compile(organizerAudienceProjectionReceiptDocumentSchema) as
      ValidateFunction<OrganizerAudienceProjectionReceiptDocument>;
export const validateOrganizerContactMergeReceiptDocument:
  ValidateFunction<OrganizerContactMergeReceiptDocument> =
    ajv.compile(organizerContactMergeReceiptDocumentSchema) as
      ValidateFunction<OrganizerContactMergeReceiptDocument>;
export const validateOrganizerContactMergeReviewDecisionDocument:
  ValidateFunction<OrganizerContactMergeReviewDecisionDocument> =
    ajv.compile(organizerContactMergeReviewDecisionDocumentSchema) as
      ValidateFunction<OrganizerContactMergeReviewDecisionDocument>;
export const validateOrganizerSenderConnectionDocument:
  ValidateFunction<OrganizerSenderConnectionDocument> =
    ajv.compile(organizerSenderConnectionDocumentSchema) as
      ValidateFunction<OrganizerSenderConnectionDocument>;
export const validateOrganizerProviderConnectionDocument:
  ValidateFunction<OrganizerProviderConnectionDocument> =
    ajv.compile(organizerProviderConnectionDocumentSchema) as
      ValidateFunction<OrganizerProviderConnectionDocument>;
export const validateOrganizerApplicationFormDocument:
  ValidateFunction<OrganizerApplicationFormDocument> =
    ajv.compile(organizerApplicationFormDocumentSchema) as
      ValidateFunction<OrganizerApplicationFormDocument>;
export const validateOrganizerApplicationFormVersionDocument:
  ValidateFunction<OrganizerApplicationFormVersionDocument> =
    ajv.compile(organizerApplicationFormVersionDocumentSchema) as
      ValidateFunction<OrganizerApplicationFormVersionDocument>;
export const validateOrganizerFormDocument:
  ValidateFunction<OrganizerFormDocument> =
    ajv.compile(organizerFormDocumentSchema) as
      ValidateFunction<OrganizerFormDocument>;
export const validateOrganizerFormDraftDocument:
  ValidateFunction<OrganizerFormDraftDocument> =
    ajv.compile(organizerFormDraftDocumentSchema) as
      ValidateFunction<OrganizerFormDraftDocument>;
export const validateOrganizerFormVersionDocument:
  ValidateFunction<OrganizerFormVersionDocument> =
    ajv.compile(organizerFormVersionDocumentSchema) as
      ValidateFunction<OrganizerFormVersionDocument>;
export const validateOrganizerApplicationDocument:
  ValidateFunction<OrganizerApplicationDocument> =
    ajv.compile(organizerApplicationDocumentSchema) as
      ValidateFunction<OrganizerApplicationDocument>;
export const validateOrganizerApplicationResponseDocument:
  ValidateFunction<OrganizerApplicationResponseDocument> =
    ajv.compile(organizerApplicationResponseDocumentSchema) as
      ValidateFunction<OrganizerApplicationResponseDocument>;
export const validateOrganizerApplicationAssetDocument:
  ValidateFunction<OrganizerApplicationAssetDocument> =
    ajv.compile(organizerApplicationAssetDocumentSchema) as
      ValidateFunction<OrganizerApplicationAssetDocument>;
export const validateOrganizerApplicationSourceMappingDocument:
  ValidateFunction<OrganizerApplicationSourceMappingDocument> =
    ajv.compile(organizerApplicationSourceMappingDocumentSchema) as
      ValidateFunction<OrganizerApplicationSourceMappingDocument>;
export const validateOrganizerApplicationImportReceiptDocument:
  ValidateFunction<OrganizerApplicationImportReceiptDocument> =
    ajv.compile(organizerApplicationImportReceiptDocumentSchema) as
      ValidateFunction<OrganizerApplicationImportReceiptDocument>;
export const validateParticipantIntakeProfileDocument:
  ValidateFunction<ParticipantIntakeProfileDocument> =
    ajv.compile(participantIntakeProfileDocumentSchema) as
      ValidateFunction<ParticipantIntakeProfileDocument>;
export const validateParticipantOrganizerDataGrantDocument:
  ValidateFunction<ParticipantOrganizerDataGrantDocument> =
    ajv.compile(participantOrganizerDataGrantDocumentSchema) as
      ValidateFunction<ParticipantOrganizerDataGrantDocument>;
export const validateExternalEventMappingDocument:
  ValidateFunction<ExternalEventMappingDocument> =
    ajv.compile(externalEventMappingDocumentSchema) as
      ValidateFunction<ExternalEventMappingDocument>;
export const validateProviderSyncRunDocument:
  ValidateFunction<ProviderSyncRunDocument> =
    ajv.compile(providerSyncRunDocumentSchema) as
      ValidateFunction<ProviderSyncRunDocument>;
export const validateOrganizerMessageTemplateDocument:
  ValidateFunction<OrganizerMessageTemplateDocument> =
    ajv.compile(organizerMessageTemplateDocumentSchema) as
      ValidateFunction<OrganizerMessageTemplateDocument>;
export const validateOrganizerContactChannelStateDocument:
  ValidateFunction<OrganizerContactChannelStateDocument> =
    ajv.compile(organizerContactChannelStateDocumentSchema) as
      ValidateFunction<OrganizerContactChannelStateDocument>;
export const validateOrganizerCampaignDocument:
  ValidateFunction<OrganizerCampaignDocument> =
    ajv.compile(organizerCampaignDocumentSchema) as
      ValidateFunction<OrganizerCampaignDocument>;
export const validateOrganizerBroadcastSummaryDocument:
  ValidateFunction<OrganizerBroadcastSummaryDocument> =
    ajv.compile(organizerBroadcastSummaryDocumentSchema) as
      ValidateFunction<OrganizerBroadcastSummaryDocument>;
export const validateOrganizerCampaignRecipientDocument:
  ValidateFunction<OrganizerCampaignRecipientDocument> =
    ajv.compile(organizerCampaignRecipientDocumentSchema) as
      ValidateFunction<OrganizerCampaignRecipientDocument>;
export const validateOrganizerCampaignWebhookReceiptDocument:
  ValidateFunction<OrganizerCampaignWebhookReceiptDocument> =
    ajv.compile(organizerCampaignWebhookReceiptDocumentSchema) as
      ValidateFunction<OrganizerCampaignWebhookReceiptDocument>;
export const validateOrganizerMessagingWebhookEventDocument:
  ValidateFunction<OrganizerMessagingWebhookEventDocument> =
    ajv.compile(organizerMessagingWebhookEventDocumentSchema) as
      ValidateFunction<OrganizerMessagingWebhookEventDocument>;
export const validateOrganizerWhatsappThreadDocument:
  ValidateFunction<OrganizerWhatsappThreadDocument> =
    ajv.compile(organizerWhatsappThreadDocumentSchema) as
      ValidateFunction<OrganizerWhatsappThreadDocument>;
export const validateOrganizerWhatsappMessageDocument:
  ValidateFunction<OrganizerWhatsappMessageDocument> =
    ajv.compile(organizerWhatsappMessageDocumentSchema) as
      ValidateFunction<OrganizerWhatsappMessageDocument>;
export const validateOrganizerWhatsappReplyOperationDocument:
  ValidateFunction<OrganizerWhatsappReplyOperationDocument> =
    ajv.compile(organizerWhatsappReplyOperationDocumentSchema) as
      ValidateFunction<OrganizerWhatsappReplyOperationDocument>;
export const validateOrganizerClaimRequestDocument:
  ValidateFunction<OrganizerClaimRequestDocument> =
    ajv.compile(organizerClaimRequestDocumentSchema) as
      ValidateFunction<OrganizerClaimRequestDocument>;
export const validateOrganizerScheduleLockDocument:
  ValidateFunction<OrganizerScheduleLockDocument> =
    ajv.compile(organizerScheduleLockDocumentSchema) as
      ValidateFunction<OrganizerScheduleLockDocument>;
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
export const validateEventInviteLinkSecretDocument:
  ValidateFunction<EventInviteLinkSecretDocument> =
    ajv.compile(eventInviteLinkSecretDocumentSchema) as
      ValidateFunction<EventInviteLinkSecretDocument>;
export const validateEventInviteTouchDocument:
  ValidateFunction<EventInviteTouchDocument> =
    ajv.compile(eventInviteTouchDocumentSchema) as
      ValidateFunction<EventInviteTouchDocument>;
export const validateEventShareIntentDocument:
  ValidateFunction<EventShareIntentDocument> =
    ajv.compile(eventShareIntentDocumentSchema) as
      ValidateFunction<EventShareIntentDocument>;
export const validateEventInviteAttributionDocument:
  ValidateFunction<EventInviteAttributionDocument> =
    ajv.compile(eventInviteAttributionDocumentSchema) as
      ValidateFunction<EventInviteAttributionDocument>;
export const validateEventParticipationDocument:
  ValidateFunction<EventParticipationDocument> =
    ajv.compile(eventParticipationDocumentSchema) as
      ValidateFunction<EventParticipationDocument>;
export const validateEventAttendeeDocument:
  ValidateFunction<EventAttendeeDocument> =
    ajv.compile(eventAttendeeDocumentSchema) as
      ValidateFunction<EventAttendeeDocument>;
export const validateEventStaffGrantDocument:
  ValidateFunction<EventStaffGrantDocument> =
    ajv.compile(eventStaffGrantDocumentSchema) as
      ValidateFunction<EventStaffGrantDocument>;
export const validateEventAttendeeAttendanceReceiptDocument:
  ValidateFunction<EventAttendeeAttendanceReceiptDocument> =
    ajv.compile(eventAttendeeAttendanceReceiptDocumentSchema) as
      ValidateFunction<EventAttendeeAttendanceReceiptDocument>;
export const validateEventAttendeeImportDocument:
  ValidateFunction<EventAttendeeImportDocument> =
    ajv.compile(eventAttendeeImportDocumentSchema) as
      ValidateFunction<EventAttendeeImportDocument>;
export const validateEventRosterHandoffDocument:
  ValidateFunction<EventRosterHandoffDocument> =
    ajv.compile(eventRosterHandoffDocumentSchema) as
      ValidateFunction<EventRosterHandoffDocument>;
export const validateEventRuntimeParticipantDocument:
  ValidateFunction<EventRuntimeParticipantDocument> =
    ajv.compile(eventRuntimeParticipantDocumentSchema) as
      ValidateFunction<EventRuntimeParticipantDocument>;
export const validateEventVenueSessionDocument:
  ValidateFunction<EventVenueSessionDocument> =
    ajv.compile(eventVenueSessionDocumentSchema) as
      ValidateFunction<EventVenueSessionDocument>;
export const validateEventVenueSessionRedemptionDocument:
  ValidateFunction<EventVenueSessionRedemptionDocument> =
    ajv.compile(eventVenueSessionRedemptionDocumentSchema) as
      ValidateFunction<EventVenueSessionRedemptionDocument>;
export const validateEventSuccessPresenceDocument:
  ValidateFunction<EventSuccessPresenceDocument> =
    ajv.compile(eventSuccessPresenceDocumentSchema) as
      ValidateFunction<EventSuccessPresenceDocument>;
export const validateEventSuccessLateArrivalDocument:
  ValidateFunction<EventSuccessLateArrivalDocument> =
    ajv.compile(eventSuccessLateArrivalDocumentSchema) as
      ValidateFunction<EventSuccessLateArrivalDocument>;
export const validateEventRuntimeClaimRequestDocument:
  ValidateFunction<EventRuntimeClaimRequestDocument> =
    ajv.compile(eventRuntimeClaimRequestDocumentSchema) as
      ValidateFunction<EventRuntimeClaimRequestDocument>;
export const validateEventCrossPathsConsentDocument:
  ValidateFunction<EventCrossPathsConsentDocument> =
    ajv.compile(eventCrossPathsConsentDocumentSchema) as
      ValidateFunction<EventCrossPathsConsentDocument>;
export const validateCrossPathsShowcaseEligibilityDocument:
  ValidateFunction<CrossPathsShowcaseEligibilityDocument> =
    ajv.compile(crossPathsShowcaseEligibilityDocumentSchema) as
      ValidateFunction<CrossPathsShowcaseEligibilityDocument>;
export const validateCrossPathsSuggestionExposureDocument:
  ValidateFunction<CrossPathsSuggestionExposureDocument> =
    ajv.compile(crossPathsSuggestionExposureDocumentSchema) as
      ValidateFunction<CrossPathsSuggestionExposureDocument>;
export const validateCrossPathsInvitationDocument:
  ValidateFunction<CrossPathsInvitationDocument> =
    ajv.compile(crossPathsInvitationDocumentSchema) as
      ValidateFunction<CrossPathsInvitationDocument>;
export const validateCrossPathsPairHoldDocument:
  ValidateFunction<CrossPathsPairHoldDocument> =
    ajv.compile(crossPathsPairHoldDocumentSchema) as
      ValidateFunction<CrossPathsPairHoldDocument>;
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
export const validateEventSuccessConversationGraphDocument:
  ValidateFunction<EventSuccessConversationGraphDocument> =
    ajv.compile(eventSuccessConversationGraphDocumentSchema) as
      ValidateFunction<EventSuccessConversationGraphDocument>;
export const validateOrganizerEventSuccessLayoutDocument:
  ValidateFunction<OrganizerEventSuccessLayoutDocument> =
    ajv.compile(organizerEventSuccessLayoutDocumentSchema) as
      ValidateFunction<OrganizerEventSuccessLayoutDocument>;
export const validateEventSuccessAssignmentDraftDocument:
  ValidateFunction<EventSuccessAssignmentDraftDocument> =
    ajv.compile(eventSuccessAssignmentDraftDocumentSchema) as
      ValidateFunction<EventSuccessAssignmentDraftDocument>;
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
export const validateEventSuccessUnitOutcomesDocument:
  ValidateFunction<EventSuccessUnitOutcomesDocument> =
    ajv.compile(eventSuccessUnitOutcomesDocumentSchema) as
      ValidateFunction<EventSuccessUnitOutcomesDocument>;
export const validateEventSuccessStandingsDocument:
  ValidateFunction<EventSuccessStandingsDocument> =
    ajv.compile(eventSuccessStandingsDocumentSchema) as
      ValidateFunction<EventSuccessStandingsDocument>;
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
export const validateHostAnalyticsSnapshotDocument:
  ValidateFunction<HostAnalyticsSnapshotDocument> =
    ajv.compile(hostAnalyticsSnapshotDocumentSchema) as
      ValidateFunction<HostAnalyticsSnapshotDocument>;
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
export const validateOrganizerIntakeFieldCorrectionDocument:
  ValidateFunction<OrganizerIntakeFieldCorrectionDocument> =
    ajv.compile(organizerIntakeFieldCorrectionDocumentSchema) as
      ValidateFunction<OrganizerIntakeFieldCorrectionDocument>;
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
export const validateCreateOrganizerCallablePayload:
  ValidateFunction<CreateOrganizerCallablePayload> =
    ajv.compile(createOrganizerCallablePayloadSchema) as
      ValidateFunction<CreateOrganizerCallablePayload>;
export const validateCreateOrganizerCallableResponse:
  ValidateFunction<CreateOrganizerCallableResponse> =
    ajv.compile(createOrganizerCallableResponseSchema) as
      ValidateFunction<CreateOrganizerCallableResponse>;
export const validateUpdateOrganizerCallablePayload:
  ValidateFunction<UpdateOrganizerCallablePayload> =
    ajv.compile(updateOrganizerCallablePayloadSchema) as
      ValidateFunction<UpdateOrganizerCallablePayload>;
export const validateArchiveOrganizerCallablePayload:
  ValidateFunction<ArchiveOrganizerCallablePayload> =
    ajv.compile(archiveOrganizerCallablePayloadSchema) as
      ValidateFunction<ArchiveOrganizerCallablePayload>;
export const validateDeleteOrganizerCallablePayload:
  ValidateFunction<DeleteOrganizerCallablePayload> =
    ajv.compile(deleteOrganizerCallablePayloadSchema) as
      ValidateFunction<DeleteOrganizerCallablePayload>;
export const validateCreateOrganizerPostCallablePayload:
  ValidateFunction<CreateOrganizerPostCallablePayload> =
    ajv.compile(createOrganizerPostCallablePayloadSchema) as
      ValidateFunction<CreateOrganizerPostCallablePayload>;
export const validateCreateOrganizerPostCallableResponse:
  ValidateFunction<CreateOrganizerPostCallableResponse> =
    ajv.compile(createOrganizerPostCallableResponseSchema) as
      ValidateFunction<CreateOrganizerPostCallableResponse>;
export const validateRequestOrganizerClaimCallablePayload:
  ValidateFunction<RequestOrganizerClaimCallablePayload> =
    ajv.compile(requestOrganizerClaimCallablePayloadSchema) as
      ValidateFunction<RequestOrganizerClaimCallablePayload>;
export const validateRequestOrganizerClaimCallableResponse:
  ValidateFunction<RequestOrganizerClaimCallableResponse> =
    ajv.compile(requestOrganizerClaimCallableResponseSchema) as
      ValidateFunction<RequestOrganizerClaimCallableResponse>;
export const validateAdminDecideOrganizerClaimCallablePayload:
  ValidateFunction<AdminDecideOrganizerClaimCallablePayload> =
    ajv.compile(adminDecideOrganizerClaimCallablePayloadSchema) as
      ValidateFunction<AdminDecideOrganizerClaimCallablePayload>;
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
export const validateOrganizerFollowCallablePayload:
  ValidateFunction<OrganizerFollowCallablePayload> =
    ajv.compile(organizerFollowCallablePayloadSchema) as
      ValidateFunction<OrganizerFollowCallablePayload>;
export const validateSetOrganizerNotificationPreferenceCallablePayload:
  ValidateFunction<SetOrganizerNotificationPreferenceCallablePayload> =
    ajv.compile(setOrganizerNotificationPreferenceCallablePayloadSchema) as
      ValidateFunction<SetOrganizerNotificationPreferenceCallablePayload>;
export const validateAddOrganizerManagerCallablePayload:
  ValidateFunction<AddOrganizerManagerCallablePayload> =
    ajv.compile(addOrganizerManagerCallablePayloadSchema) as
      ValidateFunction<AddOrganizerManagerCallablePayload>;
export const validateRemoveOrganizerManagerCallablePayload:
  ValidateFunction<RemoveOrganizerManagerCallablePayload> =
    ajv.compile(removeOrganizerManagerCallablePayloadSchema) as
      ValidateFunction<RemoveOrganizerManagerCallablePayload>;
export const validateTransferOrganizerOwnershipCallablePayload:
  ValidateFunction<TransferOrganizerOwnershipCallablePayload> =
    ajv.compile(transferOrganizerOwnershipCallablePayloadSchema) as
      ValidateFunction<TransferOrganizerOwnershipCallablePayload>;
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
export const validateAdminListActionExecutionsCallablePayload:
  ValidateFunction<AdminListActionExecutionsCallablePayload> =
    ajv.compile(adminListActionExecutionsCallablePayloadSchema) as
      ValidateFunction<AdminListActionExecutionsCallablePayload>;
export const validateAdminRecordActionExecutionCallablePayload:
  ValidateFunction<AdminRecordActionExecutionCallablePayload> =
    ajv.compile(adminRecordActionExecutionCallablePayloadSchema) as
      ValidateFunction<AdminRecordActionExecutionCallablePayload>;
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
export const validateAdminListCrossPathsShowcaseCandidatesCallablePayload:
  ValidateFunction<AdminListCrossPathsShowcaseCandidatesCallablePayload> =
    ajv.compile(adminListCrossPathsShowcaseCandidatesCallablePayloadSchema) as
      ValidateFunction<AdminListCrossPathsShowcaseCandidatesCallablePayload>;
export const validateAdminSetCrossPathsShowcaseEligibilityCallablePayload:
  ValidateFunction<AdminSetCrossPathsShowcaseEligibilityCallablePayload> =
    ajv.compile(adminSetCrossPathsShowcaseEligibilityCallablePayloadSchema) as
      ValidateFunction<AdminSetCrossPathsShowcaseEligibilityCallablePayload>;
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
export const validateAdminGetOrganizerDetailsCallablePayload:
  ValidateFunction<AdminGetOrganizerDetailsCallablePayload> =
    ajv.compile(adminGetOrganizerDetailsCallablePayloadSchema) as
      ValidateFunction<AdminGetOrganizerDetailsCallablePayload>;
export const validateAdminListOrganizerDetailsCallablePayload:
  ValidateFunction<AdminListOrganizerDetailsCallablePayload> =
    ajv.compile(adminListOrganizerDetailsCallablePayloadSchema) as
      ValidateFunction<AdminListOrganizerDetailsCallablePayload>;
export const validateAdminUpdateOrganizerDetailsCallablePayload:
  ValidateFunction<AdminUpdateOrganizerDetailsCallablePayload> =
    ajv.compile(adminUpdateOrganizerDetailsCallablePayloadSchema) as
      ValidateFunction<AdminUpdateOrganizerDetailsCallablePayload>;
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
export const validateAdminTakedownExternalEventCallablePayload:
  ValidateFunction<AdminTakedownExternalEventCallablePayload> =
    ajv.compile(adminTakedownExternalEventCallablePayloadSchema) as
      ValidateFunction<AdminTakedownExternalEventCallablePayload>;
export const validateStartClubHostConversationCallablePayload:
  ValidateFunction<StartClubHostConversationCallablePayload> =
    ajv.compile(startClubHostConversationCallablePayloadSchema) as
      ValidateFunction<StartClubHostConversationCallablePayload>;
export const validateStartOrganizerConversationCallablePayload:
  ValidateFunction<StartOrganizerConversationCallablePayload> =
    ajv.compile(startOrganizerConversationCallablePayloadSchema) as
      ValidateFunction<StartOrganizerConversationCallablePayload>;
export const validateStartOrganizerContactConversationCallablePayload:
  ValidateFunction<StartOrganizerContactConversationCallablePayload> =
    ajv.compile(startOrganizerContactConversationCallablePayloadSchema) as
      ValidateFunction<StartOrganizerContactConversationCallablePayload>;
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
export const validateSetCrossPathsEventConsentCallablePayload:
  ValidateFunction<SetCrossPathsEventConsentCallablePayload> =
    ajv.compile(setCrossPathsEventConsentCallablePayloadSchema) as
      ValidateFunction<SetCrossPathsEventConsentCallablePayload>;
export const validateGetCrossPathsSuggestionsCallablePayload:
  ValidateFunction<GetCrossPathsSuggestionsCallablePayload> =
    ajv.compile(getCrossPathsSuggestionsCallablePayloadSchema) as
      ValidateFunction<GetCrossPathsSuggestionsCallablePayload>;
export const validateSendCrossPathsInvitationCallablePayload:
  ValidateFunction<SendCrossPathsInvitationCallablePayload> =
    ajv.compile(sendCrossPathsInvitationCallablePayloadSchema) as
      ValidateFunction<SendCrossPathsInvitationCallablePayload>;
export const validateRespondCrossPathsInvitationCallablePayload:
  ValidateFunction<RespondCrossPathsInvitationCallablePayload> =
    ajv.compile(respondCrossPathsInvitationCallablePayloadSchema) as
      ValidateFunction<RespondCrossPathsInvitationCallablePayload>;
export const validateCancelCrossPathsInvitationOrPlanCallablePayload:
  ValidateFunction<CancelCrossPathsInvitationOrPlanCallablePayload> =
    ajv.compile(cancelCrossPathsInvitationOrPlanCallablePayloadSchema) as
      ValidateFunction<CancelCrossPathsInvitationOrPlanCallablePayload>;
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
export const validateResolveEventInviteLandingCallablePayload:
  ValidateFunction<ResolveEventInviteLandingCallablePayload> =
    ajv.compile(resolveEventInviteLandingCallablePayloadSchema) as
      ValidateFunction<ResolveEventInviteLandingCallablePayload>;
export const validateResolveEventInviteLandingCallableResponse:
  ValidateFunction<ResolveEventInviteLandingCallableResponse> =
    ajv.compile(resolveEventInviteLandingCallableResponseSchema) as
      ValidateFunction<ResolveEventInviteLandingCallableResponse>;
export const validateGetEventInviteLinkTokenCallablePayload:
  ValidateFunction<GetEventInviteLinkTokenCallablePayload> =
    ajv.compile(getEventInviteLinkTokenCallablePayloadSchema) as
      ValidateFunction<GetEventInviteLinkTokenCallablePayload>;
export const validateRecordEventShareIntentCallablePayload:
  ValidateFunction<RecordEventShareIntentCallablePayload> =
    ajv.compile(recordEventShareIntentCallablePayloadSchema) as
      ValidateFunction<RecordEventShareIntentCallablePayload>;
export const validateUpsertOrganizerCampaignCallablePayload:
  ValidateFunction<UpsertOrganizerCampaignCallablePayload> =
    ajv.compile(upsertOrganizerCampaignCallablePayloadSchema) as
      ValidateFunction<UpsertOrganizerCampaignCallablePayload>;
export const validateOrganizerCampaignActionCallablePayload:
  ValidateFunction<OrganizerCampaignActionCallablePayload> =
    ajv.compile(organizerCampaignActionCallablePayloadSchema) as
      ValidateFunction<OrganizerCampaignActionCallablePayload>;
export const validateCompleteOrganizerWhatsappConnectionCallablePayload:
  ValidateFunction<CompleteOrganizerWhatsappConnectionCallablePayload> =
    ajv.compile(completeOrganizerWhatsappConnectionCallablePayloadSchema) as
      ValidateFunction<CompleteOrganizerWhatsappConnectionCallablePayload>;
export const validateOrganizerSenderConnectionActionCallablePayload:
  ValidateFunction<OrganizerSenderConnectionActionCallablePayload> =
    ajv.compile(organizerSenderConnectionActionCallablePayloadSchema) as
      ValidateFunction<OrganizerSenderConnectionActionCallablePayload>;
export const validateSendOrganizerWhatsappTestCallablePayload:
  ValidateFunction<SendOrganizerWhatsappTestCallablePayload> =
    ajv.compile(sendOrganizerWhatsappTestCallablePayloadSchema) as
      ValidateFunction<SendOrganizerWhatsappTestCallablePayload>;
export const validateOrganizerCampaignCallableResponse:
  ValidateFunction<OrganizerCampaignCallableResponse> =
    ajv.compile(organizerCampaignCallableResponseSchema) as
      ValidateFunction<OrganizerCampaignCallableResponse>;
export const validateListOrganizerCampaignsCallablePayload:
  ValidateFunction<ListOrganizerCampaignsCallablePayload> =
    ajv.compile(listOrganizerCampaignsCallablePayloadSchema) as
      ValidateFunction<ListOrganizerCampaignsCallablePayload>;
export const validateListOrganizerCampaignsCallableResponse:
  ValidateFunction<ListOrganizerCampaignsCallableResponse> =
    ajv.compile(listOrganizerCampaignsCallableResponseSchema) as
      ValidateFunction<ListOrganizerCampaignsCallableResponse>;
export const validateOrganizerMessagingSetupCallableResponse:
  ValidateFunction<OrganizerMessagingSetupCallableResponse> =
    ajv.compile(organizerMessagingSetupCallableResponseSchema) as
      ValidateFunction<OrganizerMessagingSetupCallableResponse>;
export const validateGetOrganizerProviderSetupCallablePayload:
  ValidateFunction<GetOrganizerProviderSetupCallablePayload> =
    ajv.compile(getOrganizerProviderSetupCallablePayloadSchema) as
      ValidateFunction<GetOrganizerProviderSetupCallablePayload>;
export const validateConnectOrganizerLumaProviderCallablePayload:
  ValidateFunction<ConnectOrganizerLumaProviderCallablePayload> =
    ajv.compile(connectOrganizerLumaProviderCallablePayloadSchema) as
      ValidateFunction<ConnectOrganizerLumaProviderCallablePayload>;
export const validateListOrganizerLumaEventsCallablePayload:
  ValidateFunction<ListOrganizerLumaEventsCallablePayload> =
    ajv.compile(listOrganizerLumaEventsCallablePayloadSchema) as
      ValidateFunction<ListOrganizerLumaEventsCallablePayload>;
export const validateSyncOrganizerProviderEventCallablePayload:
  ValidateFunction<SyncOrganizerProviderEventCallablePayload> =
    ajv.compile(syncOrganizerProviderEventCallablePayloadSchema) as
      ValidateFunction<SyncOrganizerProviderEventCallablePayload>;
export const validateDisconnectOrganizerProviderCallablePayload:
  ValidateFunction<DisconnectOrganizerProviderCallablePayload> =
    ajv.compile(disconnectOrganizerProviderCallablePayloadSchema) as
      ValidateFunction<DisconnectOrganizerProviderCallablePayload>;
export const validateOrganizerProviderSetupCallableResponse:
  ValidateFunction<OrganizerProviderSetupCallableResponse> =
    ajv.compile(organizerProviderSetupCallableResponseSchema) as
      ValidateFunction<OrganizerProviderSetupCallableResponse>;
export const validateListOrganizerLumaEventsCallableResponse:
  ValidateFunction<ListOrganizerLumaEventsCallableResponse> =
    ajv.compile(listOrganizerLumaEventsCallableResponseSchema) as
      ValidateFunction<ListOrganizerLumaEventsCallableResponse>;
export const validateSyncOrganizerProviderEventCallableResponse:
  ValidateFunction<SyncOrganizerProviderEventCallableResponse> =
    ajv.compile(syncOrganizerProviderEventCallableResponseSchema) as
      ValidateFunction<SyncOrganizerProviderEventCallableResponse>;
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
export const validateImportEventAttendeesCallablePayload:
  ValidateFunction<ImportEventAttendeesCallablePayload> =
    ajv.compile(importEventAttendeesCallablePayloadSchema) as
      ValidateFunction<ImportEventAttendeesCallablePayload>;
export const validateMarkEventAttendeeAttendanceCallablePayload:
  ValidateFunction<MarkEventAttendeeAttendanceCallablePayload> =
    ajv.compile(markEventAttendeeAttendanceCallablePayloadSchema) as
      ValidateFunction<MarkEventAttendeeAttendanceCallablePayload>;
export const validateSetEventAttendeeAttendanceCallablePayload:
  ValidateFunction<SetEventAttendeeAttendanceCallablePayload> =
    ajv.compile(setEventAttendeeAttendanceCallablePayloadSchema) as
      ValidateFunction<SetEventAttendeeAttendanceCallablePayload>;
export const validateSetEventAttendeeAttendanceCallableResponse:
  ValidateFunction<SetEventAttendeeAttendanceCallableResponse> =
    ajv.compile(setEventAttendeeAttendanceCallableResponseSchema) as
      ValidateFunction<SetEventAttendeeAttendanceCallableResponse>;
export const validateEventOperatorAccessCallablePayload:
  ValidateFunction<EventOperatorAccessCallablePayload> =
    ajv.compile(eventOperatorAccessCallablePayloadSchema) as
      ValidateFunction<EventOperatorAccessCallablePayload>;
export const validateEventOperatorAccessCallableResponse:
  ValidateFunction<EventOperatorAccessCallableResponse> =
    ajv.compile(eventOperatorAccessCallableResponseSchema) as
      ValidateFunction<EventOperatorAccessCallableResponse>;
export const validateGrantEventStaffCallablePayload:
  ValidateFunction<GrantEventStaffCallablePayload> =
    ajv.compile(grantEventStaffCallablePayloadSchema) as
      ValidateFunction<GrantEventStaffCallablePayload>;
export const validateRevokeEventStaffCallablePayload:
  ValidateFunction<RevokeEventStaffCallablePayload> =
    ajv.compile(revokeEventStaffCallablePayloadSchema) as
      ValidateFunction<RevokeEventStaffCallablePayload>;
export const validateEventStaffListCallableResponse:
  ValidateFunction<EventStaffListCallableResponse> =
    ajv.compile(eventStaffListCallableResponseSchema) as
      ValidateFunction<EventStaffListCallableResponse>;
export const validateRegisterPublicEventCallablePayload:
  ValidateFunction<RegisterPublicEventCallablePayload> =
    ajv.compile(registerPublicEventCallablePayloadSchema) as
      ValidateFunction<RegisterPublicEventCallablePayload>;
export const validateRegisterPublicEventCallableResponse:
  ValidateFunction<RegisterPublicEventCallableResponse> =
    ajv.compile(registerPublicEventCallableResponseSchema) as
      ValidateFunction<RegisterPublicEventCallableResponse>;
export const validateGetEventRuntimeBootstrapCallablePayload:
  ValidateFunction<GetEventRuntimeBootstrapCallablePayload> =
    ajv.compile(getEventRuntimeBootstrapCallablePayloadSchema) as
      ValidateFunction<GetEventRuntimeBootstrapCallablePayload>;
export const validateUpsertEventSuccessLayoutCallablePayload:
  ValidateFunction<UpsertEventSuccessLayoutCallablePayload> =
    ajv.compile(upsertEventSuccessLayoutCallablePayloadSchema) as
      ValidateFunction<UpsertEventSuccessLayoutCallablePayload>;
export const validateUpsertEventSuccessLayoutCallableResponse:
  ValidateFunction<UpsertEventSuccessLayoutCallableResponse> =
    ajv.compile(upsertEventSuccessLayoutCallableResponseSchema) as
      ValidateFunction<UpsertEventSuccessLayoutCallableResponse>;
export const validateGetEventSuccessSpatialLayoutCallablePayload:
  ValidateFunction<GetEventSuccessSpatialLayoutCallablePayload> =
    ajv.compile(getEventSuccessSpatialLayoutCallablePayloadSchema) as
      ValidateFunction<GetEventSuccessSpatialLayoutCallablePayload>;
export const validateGetEventSuccessSpatialLayoutCallableResponse:
  ValidateFunction<GetEventSuccessSpatialLayoutCallableResponse> =
    ajv.compile(getEventSuccessSpatialLayoutCallableResponseSchema) as
      ValidateFunction<GetEventSuccessSpatialLayoutCallableResponse>;
export const validateEventSuccessSpatialActionCallablePayload:
  ValidateFunction<EventSuccessSpatialActionCallablePayload> =
    ajv.compile(eventSuccessSpatialActionCallablePayloadSchema) as
      ValidateFunction<EventSuccessSpatialActionCallablePayload>;
export const validateEventSuccessSpatialActionCallableResponse:
  ValidateFunction<EventSuccessSpatialActionCallableResponse> =
    ajv.compile(eventSuccessSpatialActionCallableResponseSchema) as
      ValidateFunction<EventSuccessSpatialActionCallableResponse>;
export const validateGetEventRuntimeBootstrapCallableResponse:
  ValidateFunction<GetEventRuntimeBootstrapCallableResponse> =
    ajv.compile(getEventRuntimeBootstrapCallableResponseSchema) as
      ValidateFunction<GetEventRuntimeBootstrapCallableResponse>;
export const validateGetEventSuccessConversationGraphCallableResponse:
  ValidateFunction<GetEventSuccessConversationGraphCallableResponse> =
    ajv.compile(getEventSuccessConversationGraphCallableResponseSchema) as
      ValidateFunction<GetEventSuccessConversationGraphCallableResponse>;
export const validateSubmitEventSuccessConversationGraphCallablePayload:
  ValidateFunction<SubmitEventSuccessConversationGraphCallablePayload> =
    ajv.compile(submitEventSuccessConversationGraphCallablePayloadSchema) as
      ValidateFunction<SubmitEventSuccessConversationGraphCallablePayload>;
export const validateSubmitEventSuccessConversationGraphCallableResponse:
  ValidateFunction<SubmitEventSuccessConversationGraphCallableResponse> =
    ajv.compile(submitEventSuccessConversationGraphCallableResponseSchema) as
      ValidateFunction<SubmitEventSuccessConversationGraphCallableResponse>;
export const validateClaimEventRuntimeAccessCallablePayload:
  ValidateFunction<ClaimEventRuntimeAccessCallablePayload> =
    ajv.compile(claimEventRuntimeAccessCallablePayloadSchema) as
      ValidateFunction<ClaimEventRuntimeAccessCallablePayload>;
export const validateClaimEventRuntimeAccessCallableResponse:
  ValidateFunction<ClaimEventRuntimeAccessCallableResponse> =
    ajv.compile(claimEventRuntimeAccessCallableResponseSchema) as
      ValidateFunction<ClaimEventRuntimeAccessCallableResponse>;
export const validateSubmitEventRuntimeProfileCallablePayload:
  ValidateFunction<SubmitEventRuntimeProfileCallablePayload> =
    ajv.compile(submitEventRuntimeProfileCallablePayloadSchema) as
      ValidateFunction<SubmitEventRuntimeProfileCallablePayload>;
export const validateSubmitEventRuntimeProfileCallableResponse:
  ValidateFunction<SubmitEventRuntimeProfileCallableResponse> =
    ajv.compile(submitEventRuntimeProfileCallableResponseSchema) as
      ValidateFunction<SubmitEventRuntimeProfileCallableResponse>;
export const validateCheckInEventRuntimeCallablePayload:
  ValidateFunction<CheckInEventRuntimeCallablePayload> =
    ajv.compile(checkInEventRuntimeCallablePayloadSchema) as
      ValidateFunction<CheckInEventRuntimeCallablePayload>;
export const validateCheckInEventRuntimeCallableResponse:
  ValidateFunction<CheckInEventRuntimeCallableResponse> =
    ajv.compile(checkInEventRuntimeCallableResponseSchema) as
      ValidateFunction<CheckInEventRuntimeCallableResponse>;
export const validateCreateEventVenueSessionCallablePayload:
  ValidateFunction<CreateEventVenueSessionCallablePayload> =
    ajv.compile(createEventVenueSessionCallablePayloadSchema) as
      ValidateFunction<CreateEventVenueSessionCallablePayload>;
export const validateCreateEventVenueSessionCallableResponse:
  ValidateFunction<CreateEventVenueSessionCallableResponse> =
    ajv.compile(createEventVenueSessionCallableResponseSchema) as
      ValidateFunction<CreateEventVenueSessionCallableResponse>;
export const validateApproveEventRuntimeClaimCallablePayload:
  ValidateFunction<ApproveEventRuntimeClaimCallablePayload> =
    ajv.compile(approveEventRuntimeClaimCallablePayloadSchema) as
      ValidateFunction<ApproveEventRuntimeClaimCallablePayload>;
export const validateApproveEventRuntimeClaimCallableResponse:
  ValidateFunction<ApproveEventRuntimeClaimCallableResponse> =
    ajv.compile(approveEventRuntimeClaimCallableResponseSchema) as
      ValidateFunction<ApproveEventRuntimeClaimCallableResponse>;
export const validateCreateEventRosterHandoffCallablePayload:
  ValidateFunction<CreateEventRosterHandoffCallablePayload> =
    ajv.compile(createEventRosterHandoffCallablePayloadSchema) as
      ValidateFunction<CreateEventRosterHandoffCallablePayload>;
export const validateCreateEventRosterHandoffCallableResponse:
  ValidateFunction<CreateEventRosterHandoffCallableResponse> =
    ajv.compile(createEventRosterHandoffCallableResponseSchema) as
      ValidateFunction<CreateEventRosterHandoffCallableResponse>;
export const validateGetOrganizerCrmSummaryCallablePayload:
  ValidateFunction<GetOrganizerCrmSummaryCallablePayload> =
    ajv.compile(getOrganizerCrmSummaryCallablePayloadSchema) as
      ValidateFunction<GetOrganizerCrmSummaryCallablePayload>;
export const validateGetEventRosterInsightsCallablePayload:
  ValidateFunction<GetEventRosterInsightsCallablePayload> =
    ajv.compile(getEventRosterInsightsCallablePayloadSchema) as
      ValidateFunction<GetEventRosterInsightsCallablePayload>;
export const validateGetEventRosterInsightsCallableResponse:
  ValidateFunction<GetEventRosterInsightsCallableResponse> =
    ajv.compile(getEventRosterInsightsCallableResponseSchema) as
      ValidateFunction<GetEventRosterInsightsCallableResponse>;
export const validateGetOrganizerCrmSummaryCallableResponse:
  ValidateFunction<GetOrganizerCrmSummaryCallableResponse> =
    ajv.compile(getOrganizerCrmSummaryCallableResponseSchema) as
      ValidateFunction<GetOrganizerCrmSummaryCallableResponse>;
export const validateListOrganizerContactsCallablePayload:
  ValidateFunction<ListOrganizerContactsCallablePayload> =
    ajv.compile(listOrganizerContactsCallablePayloadSchema) as
      ValidateFunction<ListOrganizerContactsCallablePayload>;
export const validateCreateOrganizerFormCallablePayload:
  ValidateFunction<CreateOrganizerFormCallablePayload> =
    ajv.compile(createOrganizerFormCallablePayloadSchema) as
      ValidateFunction<CreateOrganizerFormCallablePayload>;
export const validateCreateOrganizerFormCallableResponse:
  ValidateFunction<CreateOrganizerFormCallableResponse> =
    ajv.compile(createOrganizerFormCallableResponseSchema) as
      ValidateFunction<CreateOrganizerFormCallableResponse>;
export const validateUpdateOrganizerFormDraftCallablePayload:
  ValidateFunction<UpdateOrganizerFormDraftCallablePayload> =
    ajv.compile(updateOrganizerFormDraftCallablePayloadSchema) as
      ValidateFunction<UpdateOrganizerFormDraftCallablePayload>;
export const validateUpdateOrganizerFormDraftCallableResponse:
  ValidateFunction<UpdateOrganizerFormDraftCallableResponse> =
    ajv.compile(updateOrganizerFormDraftCallableResponseSchema) as
      ValidateFunction<UpdateOrganizerFormDraftCallableResponse>;
export const validateGetOrganizerFormEditorCallablePayload:
  ValidateFunction<GetOrganizerFormEditorCallablePayload> =
    ajv.compile(getOrganizerFormEditorCallablePayloadSchema) as
      ValidateFunction<GetOrganizerFormEditorCallablePayload>;
export const validateGetOrganizerFormEditorCallableResponse:
  ValidateFunction<GetOrganizerFormEditorCallableResponse> =
    ajv.compile(getOrganizerFormEditorCallableResponseSchema) as
      ValidateFunction<GetOrganizerFormEditorCallableResponse>;
export const validateListOrganizerFormsCallablePayload:
  ValidateFunction<ListOrganizerFormsCallablePayload> =
    ajv.compile(listOrganizerFormsCallablePayloadSchema) as
      ValidateFunction<ListOrganizerFormsCallablePayload>;
export const validateListOrganizerFormsCallableResponse:
  ValidateFunction<ListOrganizerFormsCallableResponse> =
    ajv.compile(listOrganizerFormsCallableResponseSchema) as
      ValidateFunction<ListOrganizerFormsCallableResponse>;
export const validateValidateOrganizerFormDraftCallablePayload:
  ValidateFunction<ValidateOrganizerFormDraftCallablePayload> =
    ajv.compile(validateOrganizerFormDraftCallablePayloadSchema) as
      ValidateFunction<ValidateOrganizerFormDraftCallablePayload>;
export const validateValidateOrganizerFormDraftCallableResponse:
  ValidateFunction<ValidateOrganizerFormDraftCallableResponse> =
    ajv.compile(validateOrganizerFormDraftCallableResponseSchema) as
      ValidateFunction<ValidateOrganizerFormDraftCallableResponse>;
export const validatePublishOrganizerFormCallablePayload:
  ValidateFunction<PublishOrganizerFormCallablePayload> =
    ajv.compile(publishOrganizerFormCallablePayloadSchema) as
      ValidateFunction<PublishOrganizerFormCallablePayload>;
export const validatePublishOrganizerFormCallableResponse:
  ValidateFunction<PublishOrganizerFormCallableResponse> =
    ajv.compile(publishOrganizerFormCallableResponseSchema) as
      ValidateFunction<PublishOrganizerFormCallableResponse>;
export const validateSetOrganizerFormLifecycleCallablePayload:
  ValidateFunction<SetOrganizerFormLifecycleCallablePayload> =
    ajv.compile(setOrganizerFormLifecycleCallablePayloadSchema) as
      ValidateFunction<SetOrganizerFormLifecycleCallablePayload>;
export const validateSetOrganizerFormLifecycleCallableResponse:
  ValidateFunction<SetOrganizerFormLifecycleCallableResponse> =
    ajv.compile(setOrganizerFormLifecycleCallableResponseSchema) as
      ValidateFunction<SetOrganizerFormLifecycleCallableResponse>;
export const validateDuplicateOrganizerFormCallablePayload:
  ValidateFunction<DuplicateOrganizerFormCallablePayload> =
    ajv.compile(duplicateOrganizerFormCallablePayloadSchema) as
      ValidateFunction<DuplicateOrganizerFormCallablePayload>;
export const validateDuplicateOrganizerFormCallableResponse:
  ValidateFunction<DuplicateOrganizerFormCallableResponse> =
    ajv.compile(duplicateOrganizerFormCallableResponseSchema) as
      ValidateFunction<DuplicateOrganizerFormCallableResponse>;
export const validateDeleteOrganizerFormDraftCallablePayload:
  ValidateFunction<DeleteOrganizerFormDraftCallablePayload> =
    ajv.compile(deleteOrganizerFormDraftCallablePayloadSchema) as
      ValidateFunction<DeleteOrganizerFormDraftCallablePayload>;
export const validateDeleteOrganizerFormDraftCallableResponse:
  ValidateFunction<DeleteOrganizerFormDraftCallableResponse> =
    ajv.compile(deleteOrganizerFormDraftCallableResponseSchema) as
      ValidateFunction<DeleteOrganizerFormDraftCallableResponse>;
export const validateListOrganizerFormTemplatesCallablePayload:
  ValidateFunction<ListOrganizerFormTemplatesCallablePayload> =
    ajv.compile(listOrganizerFormTemplatesCallablePayloadSchema) as
      ValidateFunction<ListOrganizerFormTemplatesCallablePayload>;
export const validateListOrganizerFormTemplatesCallableResponse:
  ValidateFunction<ListOrganizerFormTemplatesCallableResponse> =
    ajv.compile(listOrganizerFormTemplatesCallableResponseSchema) as
      ValidateFunction<ListOrganizerFormTemplatesCallableResponse>;
export const validatePublishOrganizerApplicationFormCallablePayload:
  ValidateFunction<PublishOrganizerApplicationFormCallablePayload> =
    ajv.compile(publishOrganizerApplicationFormCallablePayloadSchema) as
      ValidateFunction<PublishOrganizerApplicationFormCallablePayload>;
export const validateGetParticipantOrganizerApplicationFormCallablePayload:
  ValidateFunction<GetParticipantOrganizerApplicationFormCallablePayload> =
    ajv.compile(getParticipantOrganizerApplicationFormCallablePayloadSchema) as
      ValidateFunction<GetParticipantOrganizerApplicationFormCallablePayload>;
export const validateGetParticipantOrganizerApplicationFormCallableResponse:
  ValidateFunction<GetParticipantOrganizerApplicationFormCallableResponse> =
    ajv.compile(getParticipantOrganizerApplicationFormCallableResponseSchema) as
      ValidateFunction<GetParticipantOrganizerApplicationFormCallableResponse>;
export const validateSubmitParticipantOrganizerApplicationCallablePayload:
  ValidateFunction<SubmitParticipantOrganizerApplicationCallablePayload> =
    ajv.compile(submitParticipantOrganizerApplicationCallablePayloadSchema) as
      ValidateFunction<SubmitParticipantOrganizerApplicationCallablePayload>;
export const validateSubmitParticipantOrganizerApplicationCallableResponse:
  ValidateFunction<SubmitParticipantOrganizerApplicationCallableResponse> =
    ajv.compile(submitParticipantOrganizerApplicationCallableResponseSchema) as
      ValidateFunction<SubmitParticipantOrganizerApplicationCallableResponse>;
export const validateRevokeParticipantOrganizerDataGrantCallablePayload:
  ValidateFunction<RevokeParticipantOrganizerDataGrantCallablePayload> =
    ajv.compile(revokeParticipantOrganizerDataGrantCallablePayloadSchema) as
      ValidateFunction<RevokeParticipantOrganizerDataGrantCallablePayload>;
export const validateRevokeParticipantOrganizerDataGrantCallableResponse:
  ValidateFunction<RevokeParticipantOrganizerDataGrantCallableResponse> =
    ajv.compile(revokeParticipantOrganizerDataGrantCallableResponseSchema) as
      ValidateFunction<RevokeParticipantOrganizerDataGrantCallableResponse>;
export const validatePublishOrganizerApplicationFormCallableResponse:
  ValidateFunction<PublishOrganizerApplicationFormCallableResponse> =
    ajv.compile(publishOrganizerApplicationFormCallableResponseSchema) as
      ValidateFunction<PublishOrganizerApplicationFormCallableResponse>;
export const validatePreviewOrganizerApplicationImportCallablePayload:
  ValidateFunction<PreviewOrganizerApplicationImportCallablePayload> =
    ajv.compile(previewOrganizerApplicationImportCallablePayloadSchema) as
      ValidateFunction<PreviewOrganizerApplicationImportCallablePayload>;
export const validatePreviewOrganizerApplicationImportCallableResponse:
  ValidateFunction<PreviewOrganizerApplicationImportCallableResponse> =
    ajv.compile(previewOrganizerApplicationImportCallableResponseSchema) as
      ValidateFunction<PreviewOrganizerApplicationImportCallableResponse>;
export const validateImportOrganizerApplicationsCallablePayload:
  ValidateFunction<ImportOrganizerApplicationsCallablePayload> =
    ajv.compile(importOrganizerApplicationsCallablePayloadSchema) as
      ValidateFunction<ImportOrganizerApplicationsCallablePayload>;
export const validateImportOrganizerApplicationsCallableResponse:
  ValidateFunction<ImportOrganizerApplicationsCallableResponse> =
    ajv.compile(importOrganizerApplicationsCallableResponseSchema) as
      ValidateFunction<ImportOrganizerApplicationsCallableResponse>;
export const validateListOrganizerApplicationsCallablePayload:
  ValidateFunction<ListOrganizerApplicationsCallablePayload> =
    ajv.compile(listOrganizerApplicationsCallablePayloadSchema) as
      ValidateFunction<ListOrganizerApplicationsCallablePayload>;
export const validateListOrganizerApplicationsCallableResponse:
  ValidateFunction<ListOrganizerApplicationsCallableResponse> =
    ajv.compile(listOrganizerApplicationsCallableResponseSchema) as
      ValidateFunction<ListOrganizerApplicationsCallableResponse>;
export const validateGetOrganizerApplicationDetailCallablePayload:
  ValidateFunction<GetOrganizerApplicationDetailCallablePayload> =
    ajv.compile(getOrganizerApplicationDetailCallablePayloadSchema) as
      ValidateFunction<GetOrganizerApplicationDetailCallablePayload>;
export const validateGetOrganizerApplicationDetailCallableResponse:
  ValidateFunction<GetOrganizerApplicationDetailCallableResponse> =
    ajv.compile(getOrganizerApplicationDetailCallableResponseSchema) as
      ValidateFunction<GetOrganizerApplicationDetailCallableResponse>;
export const validateReviewOrganizerApplicationCallablePayload:
  ValidateFunction<ReviewOrganizerApplicationCallablePayload> =
    ajv.compile(reviewOrganizerApplicationCallablePayloadSchema) as
      ValidateFunction<ReviewOrganizerApplicationCallablePayload>;
export const validateReviewOrganizerApplicationCallableResponse:
  ValidateFunction<ReviewOrganizerApplicationCallableResponse> =
    ajv.compile(reviewOrganizerApplicationCallableResponseSchema) as
      ValidateFunction<ReviewOrganizerApplicationCallableResponse>;
export const validateCreateOrganizerContactCallablePayload:
  ValidateFunction<CreateOrganizerContactCallablePayload> =
    ajv.compile(createOrganizerContactCallablePayloadSchema) as
      ValidateFunction<CreateOrganizerContactCallablePayload>;
export const validateCreateOrganizerContactCallableResponse:
  ValidateFunction<CreateOrganizerContactCallableResponse> =
    ajv.compile(createOrganizerContactCallableResponseSchema) as
      ValidateFunction<CreateOrganizerContactCallableResponse>;
export const validateListOrganizerContactsCallableResponse:
  ValidateFunction<ListOrganizerContactsCallableResponse> =
    ajv.compile(listOrganizerContactsCallableResponseSchema) as
      ValidateFunction<ListOrganizerContactsCallableResponse>;
export const validateGetOrganizerContactDetailCallablePayload:
  ValidateFunction<GetOrganizerContactDetailCallablePayload> =
    ajv.compile(getOrganizerContactDetailCallablePayloadSchema) as
      ValidateFunction<GetOrganizerContactDetailCallablePayload>;
export const validateGetOrganizerContactDetailCallableResponse:
  ValidateFunction<GetOrganizerContactDetailCallableResponse> =
    ajv.compile(getOrganizerContactDetailCallableResponseSchema) as
      ValidateFunction<GetOrganizerContactDetailCallableResponse>;
export const validateMutateOrganizerContactCallablePayload:
  ValidateFunction<MutateOrganizerContactCallablePayload> =
    ajv.compile(mutateOrganizerContactCallablePayloadSchema) as
      ValidateFunction<MutateOrganizerContactCallablePayload>;
export const validateMutateOrganizerContactCallableResponse:
  ValidateFunction<MutateOrganizerContactCallableResponse> =
    ajv.compile(mutateOrganizerContactCallableResponseSchema) as
      ValidateFunction<MutateOrganizerContactCallableResponse>;
export const validateCreateOrganizerContactNoteCallablePayload:
  ValidateFunction<CreateOrganizerContactNoteCallablePayload> =
    ajv.compile(createOrganizerContactNoteCallablePayloadSchema) as
      ValidateFunction<CreateOrganizerContactNoteCallablePayload>;
export const validateMutateOrganizerContactNoteCallablePayload:
  ValidateFunction<MutateOrganizerContactNoteCallablePayload> =
    ajv.compile(mutateOrganizerContactNoteCallablePayloadSchema) as
      ValidateFunction<MutateOrganizerContactNoteCallablePayload>;
export const validateOrganizerContactNoteCallableResponse:
  ValidateFunction<OrganizerContactNoteCallableResponse> =
    ajv.compile(organizerContactNoteCallableResponseSchema) as
      ValidateFunction<OrganizerContactNoteCallableResponse>;
export const validateExportOrganizerContactsCallablePayload:
  ValidateFunction<ExportOrganizerContactsCallablePayload> =
    ajv.compile(exportOrganizerContactsCallablePayloadSchema) as
      ValidateFunction<ExportOrganizerContactsCallablePayload>;
export const validateExportOrganizerContactsCallableResponse:
  ValidateFunction<ExportOrganizerContactsCallableResponse> =
    ajv.compile(exportOrganizerContactsCallableResponseSchema) as
      ValidateFunction<ExportOrganizerContactsCallableResponse>;
export const validateMergeOrganizerContactsCallablePayload:
  ValidateFunction<MergeOrganizerContactsCallablePayload> =
    ajv.compile(mergeOrganizerContactsCallablePayloadSchema) as
      ValidateFunction<MergeOrganizerContactsCallablePayload>;
export const validateListOrganizerContactMergeCandidatesCallablePayload:
  ValidateFunction<ListOrganizerContactMergeCandidatesCallablePayload> =
    ajv.compile(listOrganizerContactMergeCandidatesCallablePayloadSchema) as
      ValidateFunction<ListOrganizerContactMergeCandidatesCallablePayload>;
export const validateListOrganizerContactMergeCandidatesCallableResponse:
  ValidateFunction<ListOrganizerContactMergeCandidatesCallableResponse> =
    ajv.compile(listOrganizerContactMergeCandidatesCallableResponseSchema) as
      ValidateFunction<ListOrganizerContactMergeCandidatesCallableResponse>;
export const validateReviewOrganizerContactMergeCandidateCallablePayload:
  ValidateFunction<ReviewOrganizerContactMergeCandidateCallablePayload> =
    ajv.compile(reviewOrganizerContactMergeCandidateCallablePayloadSchema) as
      ValidateFunction<ReviewOrganizerContactMergeCandidateCallablePayload>;
export const validateReviewOrganizerContactMergeCandidateCallableResponse:
  ValidateFunction<ReviewOrganizerContactMergeCandidateCallableResponse> =
    ajv.compile(reviewOrganizerContactMergeCandidateCallableResponseSchema) as
      ValidateFunction<ReviewOrganizerContactMergeCandidateCallableResponse>;
export const validateListOrganizerWhatsappThreadsCallablePayload:
  ValidateFunction<ListOrganizerWhatsappThreadsCallablePayload> =
    ajv.compile(listOrganizerWhatsappThreadsCallablePayloadSchema) as
      ValidateFunction<ListOrganizerWhatsappThreadsCallablePayload>;
export const validateListOrganizerWhatsappThreadsCallableResponse:
  ValidateFunction<ListOrganizerWhatsappThreadsCallableResponse> =
    ajv.compile(listOrganizerWhatsappThreadsCallableResponseSchema) as
      ValidateFunction<ListOrganizerWhatsappThreadsCallableResponse>;
export const validateGetOrganizerWhatsappThreadCallablePayload:
  ValidateFunction<GetOrganizerWhatsappThreadCallablePayload> =
    ajv.compile(getOrganizerWhatsappThreadCallablePayloadSchema) as
      ValidateFunction<GetOrganizerWhatsappThreadCallablePayload>;
export const validateGetOrganizerWhatsappThreadCallableResponse:
  ValidateFunction<GetOrganizerWhatsappThreadCallableResponse> =
    ajv.compile(getOrganizerWhatsappThreadCallableResponseSchema) as
      ValidateFunction<GetOrganizerWhatsappThreadCallableResponse>;
export const validateSendOrganizerWhatsappReplyCallablePayload:
  ValidateFunction<SendOrganizerWhatsappReplyCallablePayload> =
    ajv.compile(sendOrganizerWhatsappReplyCallablePayloadSchema) as
      ValidateFunction<SendOrganizerWhatsappReplyCallablePayload>;
export const validateSendOrganizerWhatsappReplyCallableResponse:
  ValidateFunction<SendOrganizerWhatsappReplyCallableResponse> =
    ajv.compile(sendOrganizerWhatsappReplyCallableResponseSchema) as
      ValidateFunction<SendOrganizerWhatsappReplyCallableResponse>;
export const validateUnmergeOrganizerContactsCallablePayload:
  ValidateFunction<UnmergeOrganizerContactsCallablePayload> =
    ajv.compile(unmergeOrganizerContactsCallablePayloadSchema) as
      ValidateFunction<UnmergeOrganizerContactsCallablePayload>;
export const validateMutateOrganizerContactMergeCallableResponse:
  ValidateFunction<MutateOrganizerContactMergeCallableResponse> =
    ajv.compile(mutateOrganizerContactMergeCallableResponseSchema) as
      ValidateFunction<MutateOrganizerContactMergeCallableResponse>;
export const validateEventJoinRequestDecisionCallablePayload:
  ValidateFunction<EventJoinRequestDecisionCallablePayload> =
    ajv.compile(eventJoinRequestDecisionCallablePayloadSchema) as
      ValidateFunction<EventJoinRequestDecisionCallablePayload>;
export const validateOverrideEventSuccessRotationsCallablePayload:
  ValidateFunction<OverrideEventSuccessRotationsCallablePayload> =
    ajv.compile(overrideEventSuccessRotationsCallablePayloadSchema) as
      ValidateFunction<OverrideEventSuccessRotationsCallablePayload>;
export const validatePrepareEventSuccessRotationDraftCallablePayload:
  ValidateFunction<PrepareEventSuccessRotationDraftCallablePayload> =
    ajv.compile(prepareEventSuccessRotationDraftCallablePayloadSchema) as
      ValidateFunction<PrepareEventSuccessRotationDraftCallablePayload>;
export const validatePublishEventSuccessRotationRoundCallablePayload:
  ValidateFunction<PublishEventSuccessRotationRoundCallablePayload> =
    ajv.compile(publishEventSuccessRotationRoundCallablePayloadSchema) as
      ValidateFunction<PublishEventSuccessRotationRoundCallablePayload>;
export const validateEventSuccessLiveActionCallablePayload:
  ValidateFunction<EventSuccessLiveActionCallablePayload> =
    ajv.compile(eventSuccessLiveActionCallablePayloadSchema) as
      ValidateFunction<EventSuccessLiveActionCallablePayload>;
export const validateSetEventSuccessAccountabilityResolutionCallablePayload:
  ValidateFunction<SetEventSuccessAccountabilityResolutionCallablePayload> =
    ajv.compile(setEventSuccessAccountabilityResolutionCallablePayloadSchema) as
      ValidateFunction<SetEventSuccessAccountabilityResolutionCallablePayload>;
export const validateRecordEventSuccessUnitOutcomesCallablePayload:
  ValidateFunction<RecordEventSuccessUnitOutcomesCallablePayload> =
    ajv.compile(recordEventSuccessUnitOutcomesCallablePayloadSchema) as
      ValidateFunction<RecordEventSuccessUnitOutcomesCallablePayload>;
export const validateRecordEventSuccessUnitOutcomesCallableResponse:
  ValidateFunction<RecordEventSuccessUnitOutcomesCallableResponse> =
    ajv.compile(recordEventSuccessUnitOutcomesCallableResponseSchema) as
      ValidateFunction<RecordEventSuccessUnitOutcomesCallableResponse>;
export const validateHeartbeatEventSuccessPresenceCallablePayload:
  ValidateFunction<HeartbeatEventSuccessPresenceCallablePayload> =
    ajv.compile(heartbeatEventSuccessPresenceCallablePayloadSchema) as
      ValidateFunction<HeartbeatEventSuccessPresenceCallablePayload>;
export const validateHeartbeatEventSuccessPresenceCallableResponse:
  ValidateFunction<HeartbeatEventSuccessPresenceCallableResponse> =
    ajv.compile(heartbeatEventSuccessPresenceCallableResponseSchema) as
      ValidateFunction<HeartbeatEventSuccessPresenceCallableResponse>;
export const validateGetEventSuccessPresenceSummaryCallableResponse:
  ValidateFunction<GetEventSuccessPresenceSummaryCallableResponse> =
    ajv.compile(getEventSuccessPresenceSummaryCallableResponseSchema) as
      ValidateFunction<GetEventSuccessPresenceSummaryCallableResponse>;
export const validateResolveEventSuccessLateArrivalCallablePayload:
  ValidateFunction<ResolveEventSuccessLateArrivalCallablePayload> =
    ajv.compile(resolveEventSuccessLateArrivalCallablePayloadSchema) as
      ValidateFunction<ResolveEventSuccessLateArrivalCallablePayload>;
export const validateResolveEventSuccessLateArrivalCallableResponse:
  ValidateFunction<ResolveEventSuccessLateArrivalCallableResponse> =
    ajv.compile(resolveEventSuccessLateArrivalCallableResponseSchema) as
      ValidateFunction<ResolveEventSuccessLateArrivalCallableResponse>;
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
export const validateCreatePublicOrganizerReviewCallablePayload:
  ValidateFunction<CreatePublicOrganizerReviewCallablePayload> =
    ajv.compile(createPublicOrganizerReviewCallablePayloadSchema) as
      ValidateFunction<CreatePublicOrganizerReviewCallablePayload>;
export const validateCreatePublicOrganizerReviewCallableResponse:
  ValidateFunction<CreatePublicOrganizerReviewCallableResponse> =
    ajv.compile(createPublicOrganizerReviewCallableResponseSchema) as
      ValidateFunction<CreatePublicOrganizerReviewCallableResponse>;
export const validateListPublicOrganizerReviewsCallablePayload:
  ValidateFunction<ListPublicOrganizerReviewsCallablePayload> =
    ajv.compile(listPublicOrganizerReviewsCallablePayloadSchema) as
      ValidateFunction<ListPublicOrganizerReviewsCallablePayload>;
export const validateListPublicOrganizerReviewsCallableResponse:
  ValidateFunction<ListPublicOrganizerReviewsCallableResponse> =
    ajv.compile(listPublicOrganizerReviewsCallableResponseSchema) as
      ValidateFunction<ListPublicOrganizerReviewsCallableResponse>;
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
export const validateFetchSwipeCandidatesCallableResponse:
  ValidateFunction<FetchSwipeCandidatesCallableResponse> =
    ajv.compile(fetchSwipeCandidatesCallableResponseSchema) as
      ValidateFunction<FetchSwipeCandidatesCallableResponse>;
export const validateSetCrossPathsEventConsentCallableResponse:
  ValidateFunction<SetCrossPathsEventConsentCallableResponse> =
    ajv.compile(setCrossPathsEventConsentCallableResponseSchema) as
      ValidateFunction<SetCrossPathsEventConsentCallableResponse>;
export const validateGetCrossPathsSuggestionsCallableResponse:
  ValidateFunction<GetCrossPathsSuggestionsCallableResponse> =
    ajv.compile(getCrossPathsSuggestionsCallableResponseSchema) as
      ValidateFunction<GetCrossPathsSuggestionsCallableResponse>;
export const validateSendCrossPathsInvitationCallableResponse:
  ValidateFunction<SendCrossPathsInvitationCallableResponse> =
    ajv.compile(sendCrossPathsInvitationCallableResponseSchema) as
      ValidateFunction<SendCrossPathsInvitationCallableResponse>;
export const validateRespondCrossPathsInvitationCallableResponse:
  ValidateFunction<RespondCrossPathsInvitationCallableResponse> =
    ajv.compile(respondCrossPathsInvitationCallableResponseSchema) as
      ValidateFunction<RespondCrossPathsInvitationCallableResponse>;
export const validateCancelCrossPathsInvitationOrPlanCallableResponse:
  ValidateFunction<CancelCrossPathsInvitationOrPlanCallableResponse> =
    ajv.compile(cancelCrossPathsInvitationOrPlanCallableResponseSchema) as
      ValidateFunction<CancelCrossPathsInvitationOrPlanCallableResponse>;
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
export const validateAdminGetOverviewCallablePayload:
  ValidateFunction<AdminGetOverviewCallablePayload> =
    ajv.compile(adminGetOverviewCallablePayloadSchema) as
      ValidateFunction<AdminGetOverviewCallablePayload>;
export const validateAdminGetOverviewCallableResponse:
  ValidateFunction<AdminGetOverviewCallableResponse> =
    ajv.compile(adminGetOverviewCallableResponseSchema) as
      ValidateFunction<AdminGetOverviewCallableResponse>;
export const validateAdminDecideAccessApplicationCallablePayload:
  ValidateFunction<AdminDecideAccessApplicationCallablePayload> =
    ajv.compile(adminDecideAccessApplicationCallablePayloadSchema) as
      ValidateFunction<AdminDecideAccessApplicationCallablePayload>;
export const validateAdminDecideAccessApplicationCallableResponse:
  ValidateFunction<AdminDecideAccessApplicationCallableResponse> =
    ajv.compile(adminDecideAccessApplicationCallableResponseSchema) as
      ValidateFunction<AdminDecideAccessApplicationCallableResponse>;
export const validateAdminSetAdminUserRolesCallablePayload:
  ValidateFunction<AdminSetAdminUserRolesCallablePayload> =
    ajv.compile(adminSetAdminUserRolesCallablePayloadSchema) as
      ValidateFunction<AdminSetAdminUserRolesCallablePayload>;
export const validateAdminSetAdminUserRolesCallableResponse:
  ValidateFunction<AdminSetAdminUserRolesCallableResponse> =
    ajv.compile(adminSetAdminUserRolesCallableResponseSchema) as
      ValidateFunction<AdminSetAdminUserRolesCallableResponse>;
export const validateAdminDecideSafetyTriageItemCallablePayload:
  ValidateFunction<AdminDecideSafetyTriageItemCallablePayload> =
    ajv.compile(adminDecideSafetyTriageItemCallablePayloadSchema) as
      ValidateFunction<AdminDecideSafetyTriageItemCallablePayload>;
export const validateAdminDecideSafetyTriageItemCallableResponse:
  ValidateFunction<AdminDecideSafetyTriageItemCallableResponse> =
    ajv.compile(adminDecideSafetyTriageItemCallableResponseSchema) as
      ValidateFunction<AdminDecideSafetyTriageItemCallableResponse>;
export const validateAdminAssignSafetyTriageItemCallablePayload:
  ValidateFunction<AdminAssignSafetyTriageItemCallablePayload> =
    ajv.compile(adminAssignSafetyTriageItemCallablePayloadSchema) as
      ValidateFunction<AdminAssignSafetyTriageItemCallablePayload>;
export const validateAdminAssignSafetyTriageItemCallableResponse:
  ValidateFunction<AdminAssignSafetyTriageItemCallableResponse> =
    ajv.compile(adminAssignSafetyTriageItemCallableResponseSchema) as
      ValidateFunction<AdminAssignSafetyTriageItemCallableResponse>;
export const validateAdminCreateOrganizerDraftFromCandidateCallablePayload:
  ValidateFunction<AdminCreateOrganizerDraftFromCandidateCallablePayload> =
    ajv.compile(adminCreateOrganizerDraftFromCandidateCallablePayloadSchema) as
      ValidateFunction<AdminCreateOrganizerDraftFromCandidateCallablePayload>;
export const validateAdminCreateOrganizerDraftFromCandidateCallableResponse:
  ValidateFunction<AdminCreateOrganizerDraftFromCandidateCallableResponse> =
    ajv.compile(adminCreateOrganizerDraftFromCandidateCallableResponseSchema) as
      ValidateFunction<AdminCreateOrganizerDraftFromCandidateCallableResponse>;
export const validateAdminCreateMarketingContentDraftCallablePayload:
  ValidateFunction<AdminCreateMarketingContentDraftCallablePayload> =
    ajv.compile(adminCreateMarketingContentDraftCallablePayloadSchema) as
      ValidateFunction<AdminCreateMarketingContentDraftCallablePayload>;
export const validateAdminCreateMarketingContentDraftCallableResponse:
  ValidateFunction<AdminCreateMarketingContentDraftCallableResponse> =
    ajv.compile(adminCreateMarketingContentDraftCallableResponseSchema) as
      ValidateFunction<AdminCreateMarketingContentDraftCallableResponse>;
export const validateAdminRecordMarketingReviewDecisionCallablePayload:
  ValidateFunction<AdminRecordMarketingReviewDecisionCallablePayload> =
    ajv.compile(adminRecordMarketingReviewDecisionCallablePayloadSchema) as
      ValidateFunction<AdminRecordMarketingReviewDecisionCallablePayload>;
export const validateAdminRecordMarketingReviewDecisionCallableResponse:
  ValidateFunction<AdminRecordMarketingReviewDecisionCallableResponse> =
    ajv.compile(adminRecordMarketingReviewDecisionCallableResponseSchema) as
      ValidateFunction<AdminRecordMarketingReviewDecisionCallableResponse>;
export const validateAdminListCrossPathsShowcaseCandidatesCallableResponse:
  ValidateFunction<AdminListCrossPathsShowcaseCandidatesCallableResponse> =
    ajv.compile(adminListCrossPathsShowcaseCandidatesCallableResponseSchema) as
      ValidateFunction<AdminListCrossPathsShowcaseCandidatesCallableResponse>;
export const validateAdminSetCrossPathsShowcaseEligibilityCallableResponse:
  ValidateFunction<AdminSetCrossPathsShowcaseEligibilityCallableResponse> =
    ajv.compile(adminSetCrossPathsShowcaseEligibilityCallableResponseSchema) as
      ValidateFunction<AdminSetCrossPathsShowcaseEligibilityCallableResponse>;
export const validateJoinWaitlistHTTPRequest:
  ValidateFunction<JoinWaitlistHTTPRequest> =
    ajv.compile(joinWaitlistHTTPRequestSchema) as
      ValidateFunction<JoinWaitlistHTTPRequest>;
export const validateJoinWaitlistHTTPResponse:
  ValidateFunction<JoinWaitlistHTTPResponse> =
    ajv.compile(joinWaitlistHTTPResponseSchema) as
      ValidateFunction<JoinWaitlistHTTPResponse>;

export function schemaErrorMessages(
  validator: ValidateFunction<unknown>
): string[] {
  return (validator.errors ?? []).map((error) => {
    const location = error.instancePath || "/";
    return `${location} ${error.message ?? "failed validation"}`;
  });
}
