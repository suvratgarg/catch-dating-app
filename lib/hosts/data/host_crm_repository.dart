import 'dart:convert';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/data/read_limit_policy.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/hosts/domain/crm/crm_response_fields.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_audience_contact.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_audience_contact_detail.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_audience_query.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_campaign.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_communication_plan.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_contact_merge.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_crm_summary.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_customer_memory.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_event_roster_insights.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_manual_send_task.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_messaging_setup.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_saved_audience.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_saved_audience_definition.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_saved_audience_filter_options.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_send_summary.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_whatsapp_thread.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_crm_repository.g.dart';

final class _HostCommunicationContactTarget {
  const _HostCommunicationContactTarget({required this.contactId});

  final String contactId;

  Map<String, Object?> toJson() => {'kind': 'contact', 'contactId': contactId};
}

class HostCrmRepository {
  const HostCrmRepository(this._functions);

  final FirebaseFunctions _functions;

  Future<HostCrmSummary> getSummary(String organizerId) => _call(
    name: 'getOrganizerCrmSummary',
    payload: GetOrganizerCrmSummaryCallableRequest(
      organizerId: organizerId,
    ).toJson(),
    action: 'load organizer CRM summary',
    parse: HostCrmSummary.fromCallableData,
  );

  Future<HostEventRosterInsights> getEventRosterInsights(String eventId) =>
      _call(
        name: 'getEventRosterInsights',
        payload: GetEventRosterInsightsCallableRequest(
          eventId: eventId,
        ).toJson(),
        action: 'load event roster customer labels',
        parse: HostEventRosterInsights.fromCallableData,
      );

  Future<List<HostStaticAudienceMember>> resolveAudienceMembers(
    String organizerId,
    List<String> contactIds,
  ) => _call(
    name: 'resolveOrganizerAudienceMembers',
    payload: ResolveOrganizerAudienceMembersCallableRequest(
      organizerId: organizerId,
      contactIds: contactIds,
    ).toJson(),
    action: 'load selected audience people',
    parse: (data) => crmMapList(
      crmRequiredMap(data, 'selected audience people')['members'],
      'selected audience people',
    ).map(HostStaticAudienceMember.fromMap).toList(growable: false),
  );

  Future<HostAudiencePage> listContacts(
    String organizerId, {
    HostAudienceQuery query = const HostAudienceQuery(),
    int limit = ReadLimitPolicy.directoryPage,
  }) => _call(
    name: 'listOrganizerContacts',
    payload: ListOrganizerContactsCallableRequest(
      organizerId: organizerId,
      limit: limit,
      cursor: query.cursor,
      query: query.search?.trim().isEmpty ?? true ? null : query.search?.trim(),
      // The callable's canonical default is lastSeen. Omitting it keeps the
      // default directory compatible during a rolling client/server rollout.
      sort: query.sort == HostAudienceSort.lastSeen
          ? null
          : query.sort.wireValue,
      segmentId: query.segment?.wireValue,
      manualTagId: query.manualTagId,
    ).toJson(),
    action: 'load organizer audience',
    parse: HostAudiencePage.fromCallableData,
  );

  Future<HostAudienceContactDetail> getContactDetail(
    String organizerId,
    String contactId,
  ) => _call(
    name: 'getOrganizerContactDetail',
    payload: GetOrganizerContactDetailCallableRequest(
      organizerId: organizerId,
      contactId: contactId,
    ).toJson(),
    action: 'load organizer contact detail',
    parse: HostAudienceContactDetail.fromCallableData,
  );

  Future<HostAudienceContactDetail> getContactOverview(
    String organizerId,
    String contactId,
  ) => withBackendErrorContext(
    () async {
      try {
        final result = await _functions
            .httpsCallable('getOrganizerContactDetail')
            .call<Object?>(
              GetOrganizerContactDetailCallableRequest(
                organizerId: organizerId,
                contactId: contactId,
                includeHistory: false,
              ).toJson(),
            );
        return HostAudienceContactDetail.fromCallableData(result.data);
      } on FirebaseFunctionsException catch (error) {
        // A rolling deployment may still serve the previous request schema.
        // Only its exact unknown-property diagnostic authorizes a full read.
        if (error.code != 'invalid-argument' ||
            error.message !=
                'includeHistory: must NOT have additional properties') {
          rethrow;
        }
        return getContactDetail(organizerId, contactId);
      }
    },
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'load organizer contact overview',
      resource: 'getOrganizerContactDetail',
    ),
  );

  Future<HostCommunicationPlan> resolveIndividualCommunicationPlan({
    required String organizerId,
    required String contactId,
  }) => _call(
    name: 'resolveOrganizerCommunicationPlan',
    payload: ResolveOrganizerCommunicationPlanCallableRequest(
      organizerId: organizerId,
      intent: HostCommunicationIntent.individualConversation.name,
      target: _HostCommunicationContactTarget(contactId: contactId).toJson(),
    ).toJson(),
    action: 'resolve organizer customer communication plan',
    parse: HostCommunicationPlan.fromCallableData,
  );

  Future<HostCreatedCustomer> createContact({
    required String organizerId,
    required String displayName,
    String? phoneE164,
    String? email,
    String? initialNote,
  }) => _call(
    name: 'createOrganizerContact',
    payload: CreateOrganizerContactCallableRequest(
      organizerId: organizerId,
      displayName: displayName,
      phoneE164: phoneE164,
      email: email,
      initialNote: initialNote,
    ).toJson(),
    action: 'create organizer customer',
    parse: HostCreatedCustomer.fromCallableData,
  );

  Future<String> startContactConversation({
    required String organizerId,
    required String contactId,
  }) => _call(
    name: 'startOrganizerContactConversation',
    payload: StartOrganizerContactConversationCallableRequest(
      organizerId: organizerId,
      contactId: contactId,
    ).toJson(),
    action: 'start organizer customer conversation',
    parse: (data) => crmRequiredString(
      crmRequiredMap(data, 'customer conversation'),
      'matchId',
    ),
  );

  Future<void> mutateContact({
    required String organizerId,
    required String contactId,
    required int expectedRevision,
    String? displayNameOverride,
    bool clearDisplayNameOverride = false,
    String? phoneE164,
    bool updatePhoneE164 = false,
    String? email,
    bool updateEmail = false,
    bool? whatsappAdminSuppressed,
    bool? hidden,
    List<String>? manualTags,
  }) => _call<Object?>(
    name: 'mutateOrganizerContact',
    payload: {
      'organizerId': organizerId,
      'contactId': contactId,
      'expectedRevision': expectedRevision,
      if (displayNameOverride != null || clearDisplayNameOverride)
        'displayNameOverride': displayNameOverride,
      if (updatePhoneE164) 'phoneE164': phoneE164,
      if (updateEmail) 'email': email,
      'whatsappAdminSuppressed': ?whatsappAdminSuppressed,
      'hidden': ?hidden,
      'manualTags': ?manualTags,
    },
    action: 'update organizer contact controls',
    parse: (value) => value,
  );

  Future<HostCustomerNote> createContactNote({
    required String organizerId,
    required String contactId,
    required String body,
  }) => _call(
    name: 'createOrganizerContactNote',
    payload: CreateOrganizerContactNoteCallableRequest(
      organizerId: organizerId,
      contactId: contactId,
      body: body,
    ).toJson(),
    action: 'add organizer contact note',
    parse: HostCustomerNote.fromCallableData,
  );

  Future<HostCustomerNote> mutateContactNote({
    required String organizerId,
    required String contactId,
    required String noteId,
    required int expectedRevision,
    required String body,
  }) => _call(
    name: 'mutateOrganizerContactNote',
    payload: MutateOrganizerContactNoteCallableRequest(
      organizerId: organizerId,
      contactId: contactId,
      noteId: noteId,
      expectedRevision: expectedRevision,
      body: body,
    ).toJson(),
    action: 'edit organizer contact note',
    parse: HostCustomerNote.fromCallableData,
  );

  Future<HostAudienceExport> exportContacts(
    String organizerId, {
    HostAudienceSegment? segment,
  }) => _call(
    name: 'exportOrganizerContacts',
    payload: ExportOrganizerContactsCallableRequest(
      organizerId: organizerId,
      segmentId: segment?.wireValue,
    ).toJson(),
    action: 'export organizer audience',
    parse: HostAudienceExport.fromCallableData,
  );

  Future<HostContactMergeCandidatePage> listMergeCandidates(
    String organizerId, {
    String? cursor,
    int limit = ReadLimitPolicy.historyPage,
  }) => _call(
    name: 'listOrganizerContactMergeCandidates',
    payload: ListOrganizerContactMergeCandidatesCallableRequest(
      organizerId: organizerId,
      limit: limit > 50 ? 50 : limit,
      cursor: cursor,
    ).toJson(),
    action: 'load organizer contact merge candidates',
    parse: HostContactMergeCandidatePage.fromCallableData,
  );

  Future<void> reviewMergeCandidate({
    required String organizerId,
    required HostContactMergeCandidate candidate,
    required bool differentPeople,
  }) => _call<Object?>(
    name: 'reviewOrganizerContactMergeCandidate',
    payload: ReviewOrganizerContactMergeCandidateCallableRequest(
      organizerId: organizerId,
      candidateId: candidate.candidateId,
      contactIds: candidate.contacts
          .map((contact) => contact.contactId)
          .toList(),
      decision: differentPeople ? 'differentPeople' : 'reopen',
      expectedRevision: candidate.decisionRevision,
    ).toJson(),
    action: 'review organizer contact merge candidate',
    parse: (value) => value,
  );

  Future<void> mergeContacts({
    required String organizerId,
    required HostContactMergeCandidate candidate,
    required String survivorContactId,
    required bool confirmConflicts,
    required String idempotencyKey,
  }) {
    final survivor = candidate.contacts.singleWhere(
      (contact) => contact.contactId == survivorContactId,
    );
    final source = candidate.contacts.singleWhere(
      (contact) => contact.contactId != survivorContactId,
    );
    return _call<Object?>(
      name: 'mergeOrganizerContacts',
      payload: MergeOrganizerContactsCallableRequest(
        organizerId: organizerId,
        survivorContactId: survivor.contactId,
        sourceContactId: source.contactId,
        survivorRevision: survivor.revision,
        sourceRevision: source.revision,
        confirmConflicts: confirmConflicts,
        idempotencyKey: idempotencyKey,
      ).toJson(),
      action: 'merge organizer contacts',
      parse: (value) => value,
    );
  }

  Future<void> unmergeContacts({
    required String organizerId,
    required String mergeReceiptId,
    required String idempotencyKey,
  }) => _call<Object?>(
    name: 'unmergeOrganizerContacts',
    payload: UnmergeOrganizerContactsCallableRequest(
      organizerId: organizerId,
      mergeReceiptId: mergeReceiptId,
      idempotencyKey: idempotencyKey,
    ).toJson(),
    action: 'undo organizer contact merge',
    parse: (value) => value,
  );

  Future<HostMessagingSetup> getMessagingSetup(
    String organizerId, {
    String? connectionId,
  }) => _messagingAction(
    name: 'getOrganizerMessagingSetup',
    organizerId: organizerId,
    connectionId: connectionId,
    action: 'load WhatsApp setup',
  );

  Future<HostWhatsappThreadPage> listWhatsappThreads(
    String organizerId, {
    String? cursor,
    int limit = ReadLimitPolicy.historyPage,
  }) => _call(
    name: 'listOrganizerWhatsappThreads',
    payload: ListOrganizerWhatsappThreadsCallableRequest(
      organizerId: organizerId,
      limit: limit > 50 ? 50 : limit,
      cursor: cursor,
    ).toJson(),
    action: 'load organizer WhatsApp inbox',
    parse: HostWhatsappThreadPage.fromCallableData,
  );

  Future<HostWhatsappThreadDetail> getWhatsappThread({
    required String organizerId,
    required String threadId,
  }) => _call(
    name: 'getOrganizerWhatsappThread',
    payload: GetOrganizerWhatsappThreadCallableRequest(
      organizerId: organizerId,
      threadId: threadId,
    ).toJson(),
    action: 'load organizer WhatsApp conversation',
    parse: HostWhatsappThreadDetail.fromCallableData,
  );

  Future<void> sendWhatsappReply({
    required String organizerId,
    required HostWhatsappThreadDetail thread,
    required String body,
    required String idempotencyKey,
  }) => _call<Object?>(
    name: 'sendOrganizerWhatsappReply',
    payload: SendOrganizerWhatsappReplyCallableRequest(
      organizerId: organizerId,
      threadId: thread.threadId,
      body: body,
      expectedLastInboundAtMillis: thread.lastInboundAt.millisecondsSinceEpoch,
      idempotencyKey: idempotencyKey,
    ).toJson(),
    action: 'reply in organizer WhatsApp conversation',
    parse: (value) => value,
  );

  Future<HostMessagingSetup> completeWhatsappConnection(
    String organizerId,
    HostWhatsappSignupResult result,
  ) => _call(
    name: 'completeOrganizerWhatsappConnection',
    payload: CompleteOrganizerWhatsappConnectionCallableRequest(
      organizerId: organizerId,
      authorizationCode: result.authorizationCode,
      wabaId: result.wabaId,
      phoneNumberId: result.phoneNumberId,
      businessId: result.businessId,
    ).toJson(),
    action: 'connect WhatsApp sender',
    parse: HostMessagingSetup.fromCallableData,
  );

  Future<HostMessagingSetup> syncWhatsappTemplates(
    String organizerId,
    String connectionId,
  ) => _messagingAction(
    name: 'syncOrganizerWhatsappTemplates',
    organizerId: organizerId,
    connectionId: connectionId,
    action: 'sync WhatsApp templates',
  );

  Future<HostMessagingSetup> disconnectWhatsapp(
    String organizerId,
    String connectionId,
  ) => _messagingAction(
    name: 'disconnectOrganizerWhatsappConnection',
    organizerId: organizerId,
    connectionId: connectionId,
    action: 'disconnect WhatsApp sender',
  );

  Future<HostMessagingSetup> sendWhatsappTest({
    required String organizerId,
    required String connectionId,
    required String templateId,
    required String toE164,
    required Map<String, String> templateVariables,
  }) => _call(
    name: 'sendOrganizerWhatsappTest',
    payload: SendOrganizerWhatsappTestCallableRequest(
      organizerId: organizerId,
      connectionId: connectionId,
      templateId: templateId,
      toE164: toE164,
      templateVariables: templateVariables,
    ).toJson(),
    action: 'send WhatsApp verification message',
    parse: HostMessagingSetup.fromCallableData,
  );

  Future<HostSavedAudienceFilterOptions> savedAudienceFilterOptions(
    String organizerId,
  ) => _call(
    name: 'listOrganizerSavedAudiences',
    payload: ListOrganizerSavedAudiencesCallableRequest(
      organizerId: organizerId,
      limit: 1,
      includeFilterOptions: true,
    ).toJson(),
    action: 'load audience filter choices',
    parse: HostSavedAudienceFilterOptions.fromCallableData,
  );

  Future<HostSavedAudiencePage> listSavedAudiences(
    String organizerId, {
    String status = 'active',
    String? cursor,
    int limit = ReadLimitPolicy.directoryPage,
  }) => _call(
    name: 'listOrganizerSavedAudiences',
    payload: ListOrganizerSavedAudiencesCallableRequest(
      organizerId: organizerId,
      status: status,
      limit: limit > 50 ? 50 : limit,
      cursor: cursor,
    ).toJson(),
    action: 'load organizer saved audiences',
    parse: HostSavedAudiencePage.fromCallableData,
  );

  Future<HostSavedAudience> upsertSavedAudience({
    required String organizerId,
    required String requestId,
    required String name,
    required HostSavedAudienceDefinition definition,
    String? audienceId,
    int? expectedRevision,
  }) => _call(
    name: 'upsertOrganizerSavedAudience',
    payload: {
      'organizerId': organizerId,
      'audienceId': ?audienceId,
      'requestId': requestId,
      'expectedRevision': ?expectedRevision,
      'scope': 'organizerCrm',
      'name': name,
      'definition': definition.toJson(),
    },
    action: 'save organizer audience',
    parse: (value) =>
        HostSavedAudience.fromMap(crmRequiredMap(value, 'saved audience')),
  );

  Future<HostSavedAudiencePreview> previewSavedAudience({
    required String organizerId,
    required HostSavedAudience audience,
    int sampleLimit = 10,
    String? cursor,
  }) => _call(
    name: 'previewOrganizerSavedAudience',
    payload: PreviewOrganizerSavedAudienceCallableRequest(
      organizerId: organizerId,
      audienceId: audience.audienceId,
      expectedRevision: audience.revision,
      sampleLimit: sampleLimit,
      cursor: cursor,
    ).toJson(),
    action: 'preview organizer audience',
    parse: HostSavedAudiencePreview.fromCallableData,
  );

  Future<HostSavedAudience> archiveSavedAudience({
    required String organizerId,
    required HostSavedAudience audience,
  }) => _call(
    name: 'archiveOrganizerSavedAudience',
    payload: ArchiveOrganizerSavedAudienceCallableRequest(
      organizerId: organizerId,
      audienceId: audience.audienceId,
      expectedRevision: audience.revision,
    ).toJson(),
    action: 'archive organizer audience',
    parse: (value) =>
        HostSavedAudience.fromMap(crmRequiredMap(value, 'saved audience')),
  );

  Future<HostManualSendTask> prepareManualSendTask({
    required String organizerId,
    required String contactId,
    required String requestId,
    required String prefillText,
  }) => _call(
    name: 'prepareOrganizerManualSendTask',
    payload: {
      'organizerId': organizerId,
      'contactId': contactId,
      'requestId': requestId,
      'intent': 'individualConversation',
      'prefillText': prefillText,
    },
    action: 'prepare manual WhatsApp handoff',
    parse: HostManualSendTask.fromCallableData,
  );

  Future<HostManualSendTaskPage> listManualSendTasks({
    required String organizerId,
    bool activeOnly = true,
    String? cursor,
    int limit = ReadLimitPolicy.historyPage,
  }) => _call(
    name: 'listOrganizerManualSendTasks',
    payload: ListOrganizerManualSendTasksCallableRequest(
      organizerId: organizerId,
      activeOnly: activeOnly,
      limit: limit > 50 ? 50 : limit,
      cursor: cursor,
    ).toJson(),
    action: 'load manual send tasks',
    parse: HostManualSendTaskPage.fromCallableData,
  );

  Future<HostManualSendTask> recordManualHandoffOpened(
    HostManualSendTask task,
  ) => _call(
    name: 'openOrganizerManualSendTask',
    payload: OpenOrganizerManualSendTaskCallableRequest(
      organizerId: task.organizerId,
      taskId: task.taskId,
      expectedRevision: task.revision,
    ).toJson(),
    action: 'record manual handoff open',
    parse: HostManualSendTask.fromCallableData,
  );

  Future<HostManualSendTask> validateManualSendTaskLaunch(
    HostManualSendTask task,
  ) => _call(
    name: 'validateOrganizerManualSendTaskLaunch',
    payload: ValidateOrganizerManualSendTaskLaunchCallableRequest(
      organizerId: task.organizerId,
      taskId: task.taskId,
      expectedRevision: task.revision,
    ).toJson(),
    action: 'validate manual handoff launch',
    parse: HostManualSendTask.fromCallableData,
  );

  Future<HostManualSendTask> markManualSendTask(
    HostManualSendTask task,
    HostManualSendTaskAction action,
  ) => _call(
    name: 'markOrganizerManualSendTask',
    payload: MarkOrganizerManualSendTaskCallableRequest(
      organizerId: task.organizerId,
      taskId: task.taskId,
      expectedRevision: task.revision,
      action: action.name,
    ).toJson(),
    action: 'mark manual send task ${action.name}',
    parse: HostManualSendTask.fromCallableData,
  );

  Future<HostManualSendTaskReplan> replanManualSendTasks({
    required String organizerId,
    required List<String> taskIds,
  }) => _call(
    name: 'replanOrganizerManualSendTasks',
    payload: ReplanOrganizerManualSendTasksCallableRequest(
      organizerId: organizerId,
      taskIds: taskIds,
    ).toJson(),
    action: 'recheck manual send task routes',
    parse: HostManualSendTaskReplan.fromCallableData,
  );

  Future<HostCampaign> upsertCampaign(
    String organizerId,
    HostCampaignDraft draft,
  ) => _call(
    name: 'upsertOrganizerCampaign',
    payload: UpsertOrganizerCampaignCallableRequest(
      organizerId: organizerId,
      campaignId: draft.campaignId,
      requestId: draft.requestId,
      expectedRevision: draft.expectedRevision,
      name: draft.name,
      messageClass: draft.messageClass,
      savedAudienceId: draft.savedAudienceId,
      connectionId: draft.connectionId,
      templateId: draft.templateId,
      templateVariables: draft.templateVariables,
      eventId: draft.eventId,
      inviteDestinationKind: draft.inviteDestinationKind,
      scheduledAtMillis: draft.scheduledAt?.millisecondsSinceEpoch,
    ).toJson(),
    action: 'save organizer campaign',
    parse: HostCampaign.fromCallableData,
  );

  Future<HostSendsPage> listCampaigns(
    String organizerId, {
    String? cursor,
    int limit = ReadLimitPolicy.historyPage,
  }) => _call(
    name: 'listOrganizerCampaigns',
    payload: ListOrganizerCampaignsCallableRequest(
      organizerId: organizerId,
      limit: limit > 50 ? 50 : limit,
      cursor: cursor,
    ).toJson(),
    action: 'load organizer Sends history',
    parse: HostSendsPage.fromCallableData,
  );

  Future<HostCampaign> previewCampaign(
    String organizerId,
    HostCampaign campaign,
  ) => _campaignAction('previewOrganizerCampaign', organizerId, campaign);

  Future<HostCampaign> approveCampaign(
    String organizerId,
    HostCampaign campaign,
  ) => _campaignAction('approveOrganizerCampaign', organizerId, campaign);

  Future<HostCampaign> dispatchCampaign(
    String organizerId,
    HostCampaign campaign,
  ) => _campaignAction('dispatchOrganizerCampaign', organizerId, campaign);

  Future<HostCampaign> cancelCampaign(
    String organizerId,
    HostCampaign campaign,
  ) => _campaignAction('cancelOrganizerCampaign', organizerId, campaign);

  Future<HostCampaign> getCampaignReport(
    String organizerId,
    String campaignId,
  ) => _call(
    name: 'getOrganizerCampaignReport',
    payload: OrganizerCampaignActionCallableRequest(
      organizerId: organizerId,
      campaignId: campaignId,
    ).toJson(),
    action: 'load organizer campaign report',
    parse: HostCampaign.fromCallableData,
  );

  Future<HostMessagingSetup> _messagingAction({
    required String name,
    required String organizerId,
    required String action,
    String? connectionId,
  }) => _call(
    name: name,
    payload: OrganizerSenderConnectionActionCallableRequest(
      organizerId: organizerId,
      connectionId: connectionId,
    ).toJson(),
    action: action,
    parse: HostMessagingSetup.fromCallableData,
  );

  Future<HostCampaign> _campaignAction(
    String name,
    String organizerId,
    HostCampaign campaign,
  ) => _call(
    name: name,
    payload: OrganizerCampaignActionCallableRequest(
      organizerId: organizerId,
      campaignId: campaign.campaignId,
      expectedRevision: campaign.revision,
    ).toJson(),
    action: '$name organizer campaign',
    parse: HostCampaign.fromCallableData,
  );

  Future<T> _call<T>({
    required String name,
    required Map<String, Object?> payload,
    required String action,
    required T Function(Object?) parse,
  }) => withBackendErrorContext(
    () async {
      final result = await _functions
          .httpsCallable(name)
          .call<Object?>(payload);
      return parse(result.data);
    },
    context: BackendErrorContext(
      service: BackendService.functions,
      action: action,
      resource: name,
    ),
  );
}

// keepalive: One callable client repository serves every organizer CRM surface.
@Riverpod(keepAlive: true)
HostCrmRepository hostCrmRepository(Ref ref) =>
    HostCrmRepository(ref.watch(firebaseFunctionsProvider));

@riverpod
Future<HostCrmSummary> hostCrmSummary(Ref ref, String organizerId) =>
    ref.read(hostCrmRepositoryProvider).getSummary(organizerId);

@riverpod
Future<HostEventRosterInsights> hostEventRosterInsights(
  Ref ref,
  String eventId,
) => ref.read(hostCrmRepositoryProvider).getEventRosterInsights(eventId);

@riverpod
Future<HostAudiencePage> hostAudience(
  Ref ref,
  String organizerId,
  HostAudienceQuery query,
) =>
    ref.read(hostCrmRepositoryProvider).listContacts(organizerId, query: query);

@riverpod
Future<HostAudienceContactDetail> hostAudienceContactDetail(
  Ref ref,
  String organizerId,
  String contactId,
) => ref
    .read(hostCrmRepositoryProvider)
    .getContactOverview(organizerId, contactId);

@riverpod
Future<HostAudienceContactDetail> hostAudienceContactHistory(
  Ref ref,
  String organizerId,
  String contactId,
) => ref
    .read(hostCrmRepositoryProvider)
    .getContactDetail(organizerId, contactId);

@riverpod
Future<HostCommunicationPlan> hostCommunicationPlan(
  Ref ref,
  String organizerId,
  String contactId,
) => ref
    .read(hostCrmRepositoryProvider)
    .resolveIndividualCommunicationPlan(
      organizerId: organizerId,
      contactId: contactId,
    );

@riverpod
Future<HostMessagingSetup> hostMessagingSetup(Ref ref, String organizerId) =>
    ref.read(hostCrmRepositoryProvider).getMessagingSetup(organizerId);

@riverpod
Future<HostSavedAudiencePage> hostSavedAudiences(Ref ref, String organizerId) =>
    ref.read(hostCrmRepositoryProvider).listSavedAudiences(organizerId);

/// Exhaustive saved-audience directory used by the Customers-owned workspace.
///
/// The callable remains cursor-paginated; this bounded provider follows those
/// cursors so client-side name search never silently searches only page one.
@riverpod
Future<HostSavedAudiencePage> hostAllSavedAudiences(
  Ref ref,
  String organizerId,
) async {
  const maximumDefinitions = 2500;
  final repository = ref.read(hostCrmRepositoryProvider);
  final audiences = <HostSavedAudience>[];
  String? cursor;
  do {
    final page = await repository.listSavedAudiences(
      organizerId,
      cursor: cursor,
      limit: 50,
    );
    audiences.addAll(page.audiences);
    cursor = page.nextCursor;
    if (audiences.length >= maximumDefinitions && cursor != null) {
      throw StateError(
        'Saved audience directory exceeds $maximumDefinitions definitions.',
      );
    }
  } while (cursor != null);
  return HostSavedAudiencePage(audiences: audiences, nextCursor: null);
}

@riverpod
Future<HostSendsPage> hostSends(Ref ref, String organizerId) =>
    ref.read(hostCrmRepositoryProvider).listCampaigns(organizerId);

@riverpod
Future<HostManualSendTaskPage> hostManualSendTasks(
  Ref ref,
  String organizerId,
) => ref
    .read(hostCrmRepositoryProvider)
    .listManualSendTasks(organizerId: organizerId);

@riverpod
Future<HostWhatsappThreadPage> hostWhatsappThreads(
  Ref ref,
  String organizerId,
) => ref.read(hostCrmRepositoryProvider).listWhatsappThreads(organizerId);

@riverpod
Future<List<HostStaticAudienceMember>> hostStaticAudienceMembers(
  Ref ref,
  String organizerId,
  String selectionKey,
) => ref
    .read(hostCrmRepositoryProvider)
    .resolveAudienceMembers(
      organizerId,
      crmStringList(jsonDecode(selectionKey)),
    );

@riverpod
Future<HostSavedAudienceFilterOptions> hostSavedAudienceFilterOptions(
  Ref ref,
  String organizerId,
) =>
    ref.read(hostCrmRepositoryProvider).savedAudienceFilterOptions(organizerId);
