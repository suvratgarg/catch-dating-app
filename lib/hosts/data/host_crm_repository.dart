import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/data/read_limit_policy.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_crm_repository.g.dart';

enum HostCrmChannelReadiness {
  currentEventOnly,
  providerSetupRequired,
  providerAndDltSetupRequired,
}

enum HostAudienceSourceCoverage { exact, partial, insufficientData }

enum HostAudienceIdentityState { unlinked, verified, ambiguous }

enum HostAudiencePermissionStatus { unknown, optedIn, optedOut }

enum HostAudienceSegment {
  firstTimeAttendee('first_time_attendee'),
  repeatAttendee('repeat_attendee'),
  regular('regular'),
  lapsedRegular('lapsed_regular'),
  reliableAttendee('reliable_attendee'),
  advocate('advocate'),
  highImpactAdvocate('high_impact_advocate'),
  whatsappReachable('whatsapp_reachable');

  const HostAudienceSegment(this.wireValue);

  final String wireValue;

  static HostAudienceSegment? fromWireValue(String value) {
    for (final segment in values) {
      if (segment.wireValue == value) return segment;
    }
    return null;
  }
}

class HostAudienceQuery {
  const HostAudienceQuery({this.search, this.segment, this.cursor});

  final String? search;
  final HostAudienceSegment? segment;
  final String? cursor;

  HostAudienceQuery copyWith({
    String? search,
    HostAudienceSegment? segment,
    String? cursor,
    bool clearSegment = false,
    bool clearCursor = false,
  }) => HostAudienceQuery(
    search: search ?? this.search,
    segment: clearSegment ? null : segment ?? this.segment,
    cursor: clearCursor ? null : cursor ?? this.cursor,
  );

  @override
  bool operator ==(Object other) =>
      other is HostAudienceQuery &&
      other.search == search &&
      other.segment == segment &&
      other.cursor == cursor;

  @override
  int get hashCode => Object.hash(search, segment, cursor);
}

class HostAudienceContact {
  const HostAudienceContact({
    required this.contactId,
    required this.displayName,
    required this.phoneE164,
    required this.email,
    required this.identityState,
    required this.identityConfidence,
    required this.ambiguousCandidateCount,
    required this.attendedEventCount,
    required this.expectedEventCount,
    required this.lastAttendedAt,
    required this.segments,
    required this.whatsappStatus,
    required this.whatsappAdminSuppressed,
    required this.smsStatus,
    required this.sourceCoverage,
    required this.revision,
  });

  factory HostAudienceContact.fromMap(Map<Object?, Object?> map) =>
      HostAudienceContact(
        contactId: _requiredString(map, 'contactId'),
        displayName: _requiredString(map, 'displayName'),
        phoneE164: _nullableString(map['phoneE164']),
        email: _nullableString(map['email']),
        identityState: _enumByName(
          HostAudienceIdentityState.values,
          _requiredString(map, 'identityState'),
          'identityState',
        ),
        identityConfidence: _requiredString(map, 'identityConfidence'),
        ambiguousCandidateCount: _requiredInt(map, 'ambiguousCandidateCount'),
        attendedEventCount: _requiredInt(map, 'attendedEventCount'),
        expectedEventCount: _requiredInt(map, 'expectedEventCount'),
        lastAttendedAt: _dateTimeFromMillis(map['lastAttendedAtMillis']),
        segments: _stringList(map['segmentIds'])
            .map(HostAudienceSegment.fromWireValue)
            .whereType<HostAudienceSegment>()
            .toSet(),
        whatsappStatus: _enumByName(
          HostAudiencePermissionStatus.values,
          _requiredString(map, 'whatsappStatus'),
          'whatsappStatus',
        ),
        whatsappAdminSuppressed: _requiredBool(map, 'whatsappAdminSuppressed'),
        smsStatus: _enumByName(
          HostAudiencePermissionStatus.values,
          _requiredString(map, 'smsStatus'),
          'smsStatus',
        ),
        sourceCoverage: _enumByName(
          HostAudienceSourceCoverage.values,
          _requiredString(map, 'sourceCoverage'),
          'sourceCoverage',
        ),
        revision: _requiredInt(map, 'revision'),
      );

  final String contactId;
  final String displayName;
  final String? phoneE164;
  final String? email;
  final HostAudienceIdentityState identityState;
  final String identityConfidence;
  final int ambiguousCandidateCount;
  final int attendedEventCount;
  final int expectedEventCount;
  final DateTime? lastAttendedAt;
  final Set<HostAudienceSegment> segments;
  final HostAudiencePermissionStatus whatsappStatus;
  final bool whatsappAdminSuppressed;
  final HostAudiencePermissionStatus smsStatus;
  final HostAudienceSourceCoverage sourceCoverage;
  final int revision;
}

class HostAudienceEventFact {
  const HostAudienceEventFact({
    required this.eventId,
    required this.displayName,
    required this.source,
    required this.status,
    required this.checkedIn,
    required this.eventStartAt,
  });

  factory HostAudienceEventFact.fromMap(Map<Object?, Object?> map) =>
      HostAudienceEventFact(
        eventId: _requiredString(map, 'eventId'),
        displayName: _requiredString(map, 'displayName'),
        source: _requiredString(map, 'source'),
        status: _requiredString(map, 'status'),
        checkedIn: _requiredBool(map, 'checkedIn'),
        eventStartAt: _dateTimeFromMillis(map['eventStartAtMillis']),
      );

  final String eventId;
  final String displayName;
  final String source;
  final String status;
  final bool checkedIn;
  final DateTime? eventStartAt;
}

class HostAudienceContactDetail {
  const HostAudienceContactDetail({
    required this.organizerId,
    required this.contactId,
    required this.displayName,
    required this.sourceDisplayName,
    required this.displayNameOverride,
    required this.phoneE164,
    required this.email,
    required this.whatsappAdminSuppressed,
    required this.events,
    required this.eventsTruncated,
    required this.revision,
  });

  factory HostAudienceContactDetail.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'organizer contact detail');
    return HostAudienceContactDetail(
      organizerId: _requiredString(map, 'organizerId'),
      contactId: _requiredString(map, 'contactId'),
      displayName: _requiredString(map, 'displayName'),
      sourceDisplayName: _requiredString(map, 'sourceDisplayName'),
      displayNameOverride: _nullableString(map['displayNameOverride']),
      phoneE164: _nullableString(map['phoneE164']),
      email: _nullableString(map['email']),
      whatsappAdminSuppressed: _requiredBool(map, 'whatsappAdminSuppressed'),
      events: _mapList(
        map['events'],
        'contact events',
      ).map(HostAudienceEventFact.fromMap).toList(growable: false),
      eventsTruncated: _requiredBool(map, 'eventsTruncated'),
      revision: _requiredInt(map, 'revision'),
    );
  }

  final String organizerId;
  final String contactId;
  final String displayName;
  final String sourceDisplayName;
  final String? displayNameOverride;
  final String? phoneE164;
  final String? email;
  final bool whatsappAdminSuppressed;
  final List<HostAudienceEventFact> events;
  final bool eventsTruncated;
  final int revision;
}

class HostAudienceExport {
  const HostAudienceExport({
    required this.fileName,
    required this.csv,
    required this.rowCount,
    required this.truncated,
  });

  factory HostAudienceExport.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'organizer audience export');
    return HostAudienceExport(
      fileName: _requiredString(map, 'fileName'),
      csv: _requiredString(map, 'csv'),
      rowCount: _requiredInt(map, 'rowCount'),
      truncated: _requiredBool(map, 'truncated'),
    );
  }

  final String fileName;
  final String csv;
  final int rowCount;
  final bool truncated;
}

class HostAudiencePage {
  const HostAudiencePage({
    required this.organizerId,
    required this.contacts,
    required this.nextCursor,
    required this.sourceCoverage,
    required this.projectionVersion,
  });

  factory HostAudiencePage.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'organizer audience response');
    return HostAudiencePage(
      organizerId: _requiredString(map, 'organizerId'),
      contacts: _mapList(
        map['contacts'],
        'contacts',
      ).map(HostAudienceContact.fromMap).toList(growable: false),
      nextCursor: _nullableString(map['nextCursor']),
      sourceCoverage: _enumByName(
        HostAudienceSourceCoverage.values,
        _requiredString(map, 'sourceCoverage'),
        'sourceCoverage',
      ),
      projectionVersion: _requiredInt(map, 'projectionVersion'),
    );
  }

  final String organizerId;
  final List<HostAudienceContact> contacts;
  final String? nextCursor;
  final HostAudienceSourceCoverage sourceCoverage;
  final int projectionVersion;
}

class HostCrmSummary {
  const HostCrmSummary({
    required this.organizerId,
    required this.contactCount,
    required this.pastAttendeeCount,
    required this.repeatAttendeeCount,
    required this.linkedAccountCount,
    required this.importedContactCount,
    required this.whatsappOptInCount,
    required this.smsOptInCount,
    required this.truncated,
    required this.inAppReadiness,
    required this.whatsappReadiness,
    required this.smsReadiness,
  });

  factory HostCrmSummary.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'CRM summary response');
    final readiness = _requiredMap(map['readiness'], 'CRM readiness');
    return HostCrmSummary(
      organizerId: _requiredString(map, 'organizerId'),
      contactCount: _requiredInt(map, 'contactCount'),
      pastAttendeeCount: _requiredInt(map, 'pastAttendeeCount'),
      repeatAttendeeCount: _requiredInt(map, 'repeatAttendeeCount'),
      linkedAccountCount: _requiredInt(map, 'linkedAccountCount'),
      importedContactCount: _requiredInt(map, 'importedContactCount'),
      whatsappOptInCount: _requiredInt(map, 'whatsappOptInCount'),
      smsOptInCount: _requiredInt(map, 'smsOptInCount'),
      truncated: _requiredBool(map, 'truncated'),
      inAppReadiness: _readiness(readiness['inApp']),
      whatsappReadiness: _readiness(readiness['whatsapp']),
      smsReadiness: _readiness(readiness['sms']),
    );
  }

  final String organizerId;
  final int contactCount;
  final int pastAttendeeCount;
  final int repeatAttendeeCount;
  final int linkedAccountCount;
  final int importedContactCount;
  final int whatsappOptInCount;
  final int smsOptInCount;
  final bool truncated;
  final HostCrmChannelReadiness inAppReadiness;
  final HostCrmChannelReadiness whatsappReadiness;
  final HostCrmChannelReadiness smsReadiness;
}

class HostWhatsappEmbeddedSignupConfig {
  const HostWhatsappEmbeddedSignupConfig({
    required this.appId,
    required this.configId,
    required this.graphVersion,
  });

  final String? appId;
  final String? configId;
  final String? graphVersion;

  bool get isConfigured =>
      appId != null && configId != null && graphVersion != null;
}

class HostWhatsappConnection {
  const HostWhatsappConnection({
    required this.connectionId,
    required this.status,
    required this.displayPhoneNumber,
    required this.verifiedName,
    required this.qualityRating,
    required this.messagingLimitTier,
    required this.templateSyncStatus,
    required this.webhookStatus,
    required this.testStatus,
    required this.revision,
  });

  factory HostWhatsappConnection.fromMap(Map<Object?, Object?> map) =>
      HostWhatsappConnection(
        connectionId: _requiredString(map, 'connectionId'),
        status: _requiredString(map, 'status'),
        displayPhoneNumber: _nullableString(map['displayPhoneNumber']),
        verifiedName: _nullableString(map['verifiedName']),
        qualityRating: _nullableString(map['qualityRating']),
        messagingLimitTier: _nullableString(map['messagingLimitTier']),
        templateSyncStatus: _requiredString(map, 'templateSyncStatus'),
        webhookStatus: _requiredString(map, 'webhookStatus'),
        testStatus: _requiredString(map, 'testStatus'),
        revision: _requiredInt(map, 'revision'),
      );

  final String connectionId;
  final String status;
  final String? displayPhoneNumber;
  final String? verifiedName;
  final String? qualityRating;
  final String? messagingLimitTier;
  final String templateSyncStatus;
  final String webhookStatus;
  final String testStatus;
  final int revision;

  bool get isActive => status == 'active';
}

class HostWhatsappTemplate {
  const HostWhatsappTemplate({
    required this.templateId,
    required this.name,
    required this.language,
    required this.category,
    required this.status,
    required this.variableNames,
    required this.hasMediaHeader,
    required this.buttonKinds,
  });

  factory HostWhatsappTemplate.fromMap(Map<Object?, Object?> map) =>
      HostWhatsappTemplate(
        templateId: _requiredString(map, 'templateId'),
        name: _requiredString(map, 'name'),
        language: _requiredString(map, 'language'),
        category: _requiredString(map, 'category'),
        status: _requiredString(map, 'status'),
        variableNames: _stringList(map['variableNames']),
        hasMediaHeader: _requiredBool(map, 'hasMediaHeader'),
        buttonKinds: _stringList(map['buttonKinds']),
      );

  final String templateId;
  final String name;
  final String language;
  final String category;
  final String status;
  final List<String> variableNames;
  final bool hasMediaHeader;
  final List<String> buttonKinds;

  bool get isApproved => status == 'APPROVED';
}

class HostMessagingSetup {
  const HostMessagingSetup({
    required this.organizerId,
    required this.providerConfigured,
    required this.embeddedSignup,
    required this.connection,
    required this.templates,
  });

  factory HostMessagingSetup.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'organizer messaging setup response');
    final signup = _requiredMap(map['embeddedSignup'], 'embeddedSignup');
    final connectionValue = map['connection'];
    return HostMessagingSetup(
      organizerId: _requiredString(map, 'organizerId'),
      providerConfigured: _requiredBool(map, 'providerConfigured'),
      embeddedSignup: HostWhatsappEmbeddedSignupConfig(
        appId: _nullableString(signup['appId']),
        configId: _nullableString(signup['configId']),
        graphVersion: _nullableString(signup['graphVersion']),
      ),
      connection: connectionValue == null
          ? null
          : HostWhatsappConnection.fromMap(
              _requiredMap(connectionValue, 'connection'),
            ),
      templates: _mapList(
        map['templates'],
        'templates',
      ).map(HostWhatsappTemplate.fromMap).toList(growable: false),
    );
  }

  final String organizerId;
  final bool providerConfigured;
  final HostWhatsappEmbeddedSignupConfig embeddedSignup;
  final HostWhatsappConnection? connection;
  final List<HostWhatsappTemplate> templates;

  List<HostWhatsappTemplate> get approvedTemplates => templates
      .where((template) => template.isApproved)
      .toList(growable: false);
}

class HostWhatsappSignupResult {
  const HostWhatsappSignupResult({
    required this.authorizationCode,
    required this.wabaId,
    required this.phoneNumberId,
    this.businessId,
  });

  final String authorizationCode;
  final String wabaId;
  final String phoneNumberId;
  final String? businessId;
}

class HostCampaignDraft {
  const HostCampaignDraft({
    required this.requestId,
    required this.name,
    required this.messageClass,
    required this.segments,
    required this.connectionId,
    required this.templateId,
    required this.templateVariables,
    this.campaignId,
    this.expectedRevision,
    this.eventId,
    this.inviteDestinationKind,
    this.scheduledAt,
  });

  final String requestId;
  final String name;
  final String messageClass;
  final Set<HostAudienceSegment> segments;
  final String connectionId;
  final String templateId;
  final Map<String, String> templateVariables;
  final String? campaignId;
  final int? expectedRevision;
  final String? eventId;
  final String? inviteDestinationKind;
  final DateTime? scheduledAt;
}

class HostCampaignCounts {
  const HostCampaignCounts(this.values);

  factory HostCampaignCounts.fromMap(Object? value, String label) {
    final map = _requiredMap(value, label);
    return HostCampaignCounts({
      for (final entry in map.entries)
        if (entry.key is String && entry.value is num)
          entry.key as String: (entry.value as num).toInt(),
    });
  }

  final Map<String, int> values;

  int operator [](String key) => values[key] ?? 0;
}

class HostCampaign {
  const HostCampaign({
    required this.organizerId,
    required this.campaignId,
    required this.status,
    required this.revision,
    required this.audienceCounts,
    required this.deliveryCounts,
    required this.senderStatus,
    required this.templateStatus,
    required this.canApprove,
    required this.canDispatch,
    required this.blockers,
  });

  factory HostCampaign.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'organizer campaign response');
    return HostCampaign(
      organizerId: _requiredString(map, 'organizerId'),
      campaignId: _requiredString(map, 'campaignId'),
      status: _requiredString(map, 'status'),
      revision: _requiredInt(map, 'revision'),
      audienceCounts: HostCampaignCounts.fromMap(
        map['audienceCounts'],
        'audienceCounts',
      ),
      deliveryCounts: HostCampaignCounts.fromMap(
        map['deliveryCounts'],
        'deliveryCounts',
      ),
      senderStatus: _requiredString(map, 'senderStatus'),
      templateStatus: _requiredString(map, 'templateStatus'),
      canApprove: _requiredBool(map, 'canApprove'),
      canDispatch: _requiredBool(map, 'canDispatch'),
      blockers: _stringList(map['blockers']).toSet(),
    );
  }

  final String organizerId;
  final String campaignId;
  final String status;
  final int revision;
  final HostCampaignCounts audienceCounts;
  final HostCampaignCounts deliveryCounts;
  final String senderStatus;
  final String templateStatus;
  final bool canApprove;
  final bool canDispatch;
  final Set<String> blockers;
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

  Future<HostAudiencePage> listContacts(
    String organizerId, {
    HostAudienceQuery query = const HostAudienceQuery(),
    int limit = ReadLimitPolicy.historyPage,
  }) => _call(
    name: 'listOrganizerContacts',
    payload: ListOrganizerContactsCallableRequest(
      organizerId: organizerId,
      limit: limit,
      cursor: query.cursor,
      query: query.search?.trim().isEmpty ?? true ? null : query.search?.trim(),
      segmentId: query.segment?.wireValue,
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

  Future<void> mutateContact({
    required String organizerId,
    required String contactId,
    required int expectedRevision,
    String? displayNameOverride,
    bool clearDisplayNameOverride = false,
    bool? whatsappAdminSuppressed,
    bool? hidden,
  }) => _call<Object?>(
    name: 'mutateOrganizerContact',
    payload: {
      'organizerId': organizerId,
      'contactId': contactId,
      'expectedRevision': expectedRevision,
      if (displayNameOverride != null || clearDisplayNameOverride)
        'displayNameOverride': displayNameOverride,
      'whatsappAdminSuppressed': ?whatsappAdminSuppressed,
      'hidden': ?hidden,
    },
    action: 'update organizer contact controls',
    parse: (value) => value,
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

  Future<HostMessagingSetup> getMessagingSetup(
    String organizerId, {
    String? connectionId,
  }) => _messagingAction(
    name: 'getOrganizerMessagingSetup',
    organizerId: organizerId,
    connectionId: connectionId,
    action: 'load WhatsApp setup',
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
      segmentIds: draft.segments.map((segment) => segment.wireValue).toList(),
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
Future<HostAudiencePage> hostAudience(
  Ref ref,
  String organizerId,
  HostAudienceQuery query,
) =>
    ref.read(hostCrmRepositoryProvider).listContacts(organizerId, query: query);

@riverpod
Future<HostMessagingSetup> hostMessagingSetup(Ref ref, String organizerId) =>
    ref.read(hostCrmRepositoryProvider).getMessagingSetup(organizerId);

Map<Object?, Object?> _requiredMap(Object? value, String label) {
  if (value is Map<Object?, Object?>) return value;
  throw FormatException('Invalid $label.');
}

List<Map<Object?, Object?>> _mapList(Object? value, String label) {
  if (value is! List<Object?>) throw FormatException('Invalid $label.');
  return value.map((item) => _requiredMap(item, label)).toList(growable: false);
}

List<String> _stringList(Object? value) {
  if (value is! List<Object?> || value.any((item) => item is! String)) {
    throw const FormatException('Expected a string list.');
  }
  return value.cast<String>();
}

String _requiredString(Map<Object?, Object?> map, String key) {
  final value = map[key];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('Response was missing $key.');
}

String? _nullableString(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  throw const FormatException('Expected a nullable string.');
}

int _requiredInt(Map<Object?, Object?> map, String key) {
  final value = map[key];
  if (value is num && value >= 0) return value.toInt();
  throw FormatException('Response was missing $key.');
}

bool _requiredBool(Map<Object?, Object?> map, String key) {
  final value = map[key];
  if (value is bool) return value;
  throw FormatException('Response was missing $key.');
}

DateTime? _dateTimeFromMillis(Object? value) {
  if (value == null) return null;
  if (value is num && value >= 0) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  throw const FormatException('Expected epoch milliseconds.');
}

T _enumByName<T extends Enum>(List<T> values, String name, String label) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('Response had invalid $label.');
}

HostCrmChannelReadiness _readiness(Object? value) => switch (value) {
  'currentEventOnly' => HostCrmChannelReadiness.currentEventOnly,
  'providerSetupRequired' => HostCrmChannelReadiness.providerSetupRequired,
  'providerAndDltSetupRequired' =>
    HostCrmChannelReadiness.providerAndDltSetupRequired,
  _ => throw const FormatException('CRM response had invalid readiness.'),
};
