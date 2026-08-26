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

enum HostAudienceMatchCountCoverage { exact, atLeast }

enum HostAudienceIdentityState { unlinked, verified, ambiguous }

enum HostAudiencePermissionStatus { unknown, optedIn, optedOut }

enum HostCustomerRevenueCoverage { exact, partial, unavailable }

enum HostCustomerRevenueSource {
  catchPayment,
  hostImport,
  hostEstimate,
  providerOrder,
}

enum HostCustomerEventOrigin { catchNative, externalCompanion, unknown }

enum HostCustomerRevenueAllocation { perAttendee, sharedOrder }

enum HostCustomerHistoryCoverage { exact, unavailable }

enum HostContactMergeMatchKind {
  sameVerifiedUid,
  sameVerifiedPhone,
  sameImportedPhone,
  sameEmail,
}

enum HostContactMergeConfidence { verified, proposed }

enum HostContactMergeDecisionState { none, differentPeople, reopened }

enum HostWhatsappMessageDirection { inbound, outbound }

enum HostRosterInsightCoverage { exact, partial }

enum HostRosterSpendCoverage { catchPaymentsOnly, insufficientData }

enum HostRosterInsightAvailability {
  ready,
  projectionPending,
  ambiguousIdentity,
  insufficientHistory,
}

enum HostRosterInsightSignal {
  firstTime('first_time'),
  returning('returning'),
  regular('regular'),
  reEngaging('re_engaging'),
  reliable('reliable'),
  needsConfirmation('needs_confirmation'),
  advocate('advocate'),
  highImpactAdvocate('high_impact_advocate'),
  knownCatchSpender('known_catch_spender'),
  topCatchSpender('top_catch_spender');

  const HostRosterInsightSignal(this.wireValue);

  final String wireValue;

  static HostRosterInsightSignal fromWireValue(String value) =>
      values.firstWhere(
        (signal) => signal.wireValue == value,
        orElse: () => throw const FormatException(
          'Roster insight response had an invalid signal.',
        ),
      );
}

class HostRosterCatchSpend {
  const HostRosterCatchSpend({
    required this.currency,
    required this.amountMinor,
    required this.paidOrderCount,
  });

  factory HostRosterCatchSpend.fromMap(Map<Object?, Object?> map) =>
      HostRosterCatchSpend(
        currency: _requiredString(map, 'currency'),
        amountMinor: _requiredInt(map, 'amountMinor'),
        paidOrderCount: _requiredInt(map, 'paidOrderCount'),
      );

  final String currency;
  final int amountMinor;
  final int paidOrderCount;
}

class HostEventRosterInsight {
  const HostEventRosterInsight({
    required this.attendeeId,
    required this.contactId,
    required this.availability,
    required this.signals,
    required this.priorAttendedEventCount,
    required this.priorExpectedEventCount,
    required this.priorNoShowCount,
    required this.lastAttendedAt,
    required this.attendanceRate,
    required this.catchSpend,
  });

  factory HostEventRosterInsight.fromMap(Map<Object?, Object?> map) =>
      HostEventRosterInsight(
        attendeeId: _requiredString(map, 'attendeeId'),
        contactId: _nullableString(map['contactId']),
        availability: _enumByName(
          HostRosterInsightAvailability.values,
          _requiredString(map, 'availability'),
          'availability',
        ),
        signals: _stringList(
          map['signals'],
        ).map(HostRosterInsightSignal.fromWireValue).toSet(),
        priorAttendedEventCount: _requiredInt(map, 'priorAttendedEventCount'),
        priorExpectedEventCount: _requiredInt(map, 'priorExpectedEventCount'),
        priorNoShowCount: _requiredInt(map, 'priorNoShowCount'),
        lastAttendedAt: _dateTimeFromMillis(map['lastAttendedAtMillis']),
        attendanceRate: _nullableDouble(map['attendanceRate']),
        catchSpend: _mapList(
          map['catchSpend'],
          'catchSpend',
        ).map(HostRosterCatchSpend.fromMap).toList(growable: false),
      );

  final String attendeeId;
  final String? contactId;
  final HostRosterInsightAvailability availability;
  final Set<HostRosterInsightSignal> signals;
  final int priorAttendedEventCount;
  final int priorExpectedEventCount;
  final int priorNoShowCount;
  final DateTime? lastAttendedAt;
  final double? attendanceRate;
  final List<HostRosterCatchSpend> catchSpend;
}

class HostEventRosterInsights {
  const HostEventRosterInsights({
    required this.eventId,
    required this.organizerId,
    required this.cutoffAt,
    required this.sourceCoverage,
    required this.spendCoverage,
    required this.rows,
    required this.computedAt,
  });

  factory HostEventRosterInsights.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'event roster insights');
    return HostEventRosterInsights(
      eventId: _requiredString(map, 'eventId'),
      organizerId: _requiredString(map, 'organizerId'),
      cutoffAt: _requiredDateTimeFromMillis(map, 'cutoffAtMillis'),
      sourceCoverage: _enumByName(
        HostRosterInsightCoverage.values,
        _requiredString(map, 'sourceCoverage'),
        'sourceCoverage',
      ),
      spendCoverage: _enumByName(
        HostRosterSpendCoverage.values,
        _requiredString(map, 'spendCoverage'),
        'spendCoverage',
      ),
      rows: _mapList(
        map['rows'],
        'event roster insight rows',
      ).map(HostEventRosterInsight.fromMap).toList(growable: false),
      computedAt: _requiredDateTimeFromMillis(map, 'computedAtMillis'),
    );
  }

  final String eventId;
  final String organizerId;
  final DateTime cutoffAt;
  final HostRosterInsightCoverage sourceCoverage;
  final HostRosterSpendCoverage spendCoverage;
  final List<HostEventRosterInsight> rows;
  final DateTime computedAt;

  Map<String, HostEventRosterInsight> get byAttendeeId => {
    for (final row in rows) row.attendeeId: row,
  };
}

enum HostAudienceSegment {
  newToOrganizer('new_to_organizer'),
  firstTimeAttendee('first_time_attendee'),
  repeatAttendee('repeat_attendee'),
  regular('regular'),
  lapsedRegular('lapsed_regular'),
  reliableAttendee('reliable_attendee'),
  needsConfirmation('needs_confirmation'),
  advocate('advocate'),
  highImpactAdvocate('high_impact_advocate'),
  whatsappReachable('whatsapp_reachable'),
  smsReachable('sms_reachable');

  const HostAudienceSegment(this.wireValue);

  final String wireValue;

  static HostAudienceSegment? fromWireValue(String value) {
    for (final segment in values) {
      if (segment.wireValue == value) return segment;
    }
    return null;
  }
}

enum HostAudienceSort {
  lastSeen('lastSeen'),
  mostAttended('mostAttended'),
  name('name');

  const HostAudienceSort(this.wireValue);

  final String wireValue;
}

class HostAudienceQuery {
  const HostAudienceQuery({
    this.search,
    this.segment,
    this.manualTagId,
    this.sort = HostAudienceSort.lastSeen,
    this.cursor,
  });

  final String? search;
  final HostAudienceSegment? segment;
  final String? manualTagId;
  final HostAudienceSort sort;
  final String? cursor;

  HostAudienceQuery copyWith({
    String? search,
    HostAudienceSegment? segment,
    String? manualTagId,
    HostAudienceSort? sort,
    String? cursor,
    bool clearSegment = false,
    bool clearManualTag = false,
    bool clearCursor = false,
  }) => HostAudienceQuery(
    search: search ?? this.search,
    segment: clearSegment ? null : segment ?? this.segment,
    manualTagId: clearManualTag ? null : manualTagId ?? this.manualTagId,
    sort: sort ?? this.sort,
    cursor: clearCursor ? null : cursor ?? this.cursor,
  );

  @override
  bool operator ==(Object other) =>
      other is HostAudienceQuery &&
      other.search == search &&
      other.segment == segment &&
      other.manualTagId == manualTagId &&
      other.sort == sort &&
      other.cursor == cursor;

  @override
  int get hashCode => Object.hash(search, segment, manualTagId, sort, cursor);
}

class HostManualTag {
  const HostManualTag({required this.tagId, required this.label});

  factory HostManualTag.fromMap(Map<Object?, Object?> map) => HostManualTag(
    tagId: _requiredString(map, 'tagId'),
    label: _requiredString(map, 'label'),
  );

  final String tagId;
  final String label;

  @override
  bool operator ==(Object other) =>
      other is HostManualTag && other.tagId == tagId && other.label == label;

  @override
  int get hashCode => Object.hash(tagId, label);
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
    this.manualTags = const [],
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
        manualTags: _optionalMapList(
          map['manualTags'],
          'manual tags',
        ).map(HostManualTag.fromMap).toList(growable: false),
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
  final List<HostManualTag> manualTags;
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
    this.eventOrigin = HostCustomerEventOrigin.unknown,
    this.eventProvider,
    required this.source,
    required this.status,
    required this.checkedIn,
    required this.eventStartAt,
    this.revenues = const [],
  });

  factory HostAudienceEventFact.fromMap(Map<Object?, Object?> map) =>
      HostAudienceEventFact(
        eventId: _requiredString(map, 'eventId'),
        displayName: _requiredString(map, 'displayName'),
        eventOrigin: _enumByName(
          HostCustomerEventOrigin.values,
          _requiredString(map, 'eventOriginMode'),
          'event origin',
        ),
        eventProvider: _nullableString(map['eventProvider']),
        source: _requiredString(map, 'source'),
        status: _requiredString(map, 'status'),
        checkedIn: _requiredBool(map, 'checkedIn'),
        eventStartAt: _dateTimeFromMillis(map['eventStartAtMillis']),
        revenues: _mapList(
          map['revenues'],
          'event revenue',
        ).map(HostCustomerEventRevenue.fromMap).toList(growable: false),
      );

  final String eventId;
  final String displayName;
  final HostCustomerEventOrigin eventOrigin;
  final String? eventProvider;
  final String source;
  final String status;
  final bool checkedIn;
  final DateTime? eventStartAt;
  final List<HostCustomerEventRevenue> revenues;
}

class HostCustomerEventRevenue {
  const HostCustomerEventRevenue({
    required this.currency,
    required this.amountMinor,
    required this.source,
    required this.factCount,
    required this.allocation,
  });

  factory HostCustomerEventRevenue.fromMap(Map<Object?, Object?> map) =>
      HostCustomerEventRevenue(
        currency: _requiredString(map, 'currency'),
        amountMinor: _requiredInt(map, 'amountMinor'),
        source: _enumByName(
          HostCustomerRevenueSource.values,
          _requiredString(map, 'source'),
          'event revenue source',
        ),
        factCount: _requiredInt(map, 'factCount'),
        allocation: _enumByName(
          HostCustomerRevenueAllocation.values,
          _requiredString(map, 'allocation'),
          'event revenue allocation',
        ),
      );

  final String currency;
  final int amountMinor;
  final HostCustomerRevenueSource source;
  final int factCount;
  final HostCustomerRevenueAllocation allocation;
}

class HostCustomerTraits {
  const HostCustomerTraits({
    required this.expectedEventCount,
    required this.attendedEventCount,
    required this.cancelledEventCount,
    required this.noShowCount,
    required this.importedEventCount,
    required this.attendanceRate,
    required this.segments,
    required this.whatsappStatus,
    required this.sourceCoverage,
  });

  factory HostCustomerTraits.fromMap(Map<Object?, Object?> map) =>
      HostCustomerTraits(
        expectedEventCount: _requiredInt(map, 'expectedEventCount'),
        attendedEventCount: _requiredInt(map, 'attendedEventCount'),
        cancelledEventCount: _requiredInt(map, 'cancelledEventCount'),
        noShowCount: _requiredInt(map, 'noShowCount'),
        importedEventCount: _requiredInt(map, 'importedEventCount'),
        attendanceRate: _nullableDouble(map['attendanceRate']),
        segments: _stringList(map['segmentIds'])
            .map(HostAudienceSegment.fromWireValue)
            .whereType<HostAudienceSegment>()
            .toSet(),
        whatsappStatus: _enumByName(
          HostAudiencePermissionStatus.values,
          _requiredString(map, 'whatsappStatus'),
          'whatsappStatus',
        ),
        sourceCoverage: _enumByName(
          HostAudienceSourceCoverage.values,
          _requiredString(map, 'sourceCoverage'),
          'sourceCoverage',
        ),
      );

  final int expectedEventCount;
  final int attendedEventCount;
  final int cancelledEventCount;
  final int noShowCount;
  final int importedEventCount;
  final double? attendanceRate;
  final Set<HostAudienceSegment> segments;
  final HostAudiencePermissionStatus whatsappStatus;
  final HostAudienceSourceCoverage sourceCoverage;
}

class HostCustomerRevenueAmount {
  const HostCustomerRevenueAmount({
    required this.currency,
    required this.amountMinor,
    int? factCount,
    int? paidOrderCount,
    this.sources = const [],
  }) : factCount = factCount ?? paidOrderCount ?? 0;

  factory HostCustomerRevenueAmount.fromMap(Map<Object?, Object?> map) =>
      HostCustomerRevenueAmount(
        currency: _requiredString(map, 'currency'),
        amountMinor: _requiredInt(map, 'amountMinor'),
        factCount: _requiredInt(map, 'factCount'),
        sources: _mapList(
          map['sources'],
          'customer revenue sources',
        ).map(HostCustomerRevenueSourceAmount.fromMap).toList(growable: false),
      );

  final String currency;
  final int amountMinor;
  final int factCount;
  final List<HostCustomerRevenueSourceAmount> sources;
}

class HostCustomerRevenueSourceAmount {
  const HostCustomerRevenueSourceAmount({
    required this.source,
    required this.amountMinor,
    required this.factCount,
  });

  factory HostCustomerRevenueSourceAmount.fromMap(Map<Object?, Object?> map) =>
      HostCustomerRevenueSourceAmount(
        source: _enumByName(
          HostCustomerRevenueSource.values,
          _requiredString(map, 'source'),
          'revenue source',
        ),
        amountMinor: _requiredInt(map, 'amountMinor'),
        factCount: _requiredInt(map, 'factCount'),
      );

  final HostCustomerRevenueSource source;
  final int amountMinor;
  final int factCount;
}

class HostCustomerRevenue {
  const HostCustomerRevenue({required this.coverage, required this.amounts});

  factory HostCustomerRevenue.fromMap(Map<Object?, Object?> map) =>
      HostCustomerRevenue(
        coverage: _enumByName(
          HostCustomerRevenueCoverage.values,
          _requiredString(map, 'coverage'),
          'revenue coverage',
        ),
        amounts: _mapList(
          map['amounts'],
          'customer revenue amounts',
        ).map(HostCustomerRevenueAmount.fromMap).toList(growable: false),
      );

  final HostCustomerRevenueCoverage coverage;
  final List<HostCustomerRevenueAmount> amounts;
}

class HostCustomerNote {
  const HostCustomerNote({
    required this.noteId,
    required this.body,
    required this.authorUid,
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
  });

  factory HostCustomerNote.fromMap(Map<Object?, Object?> map) =>
      HostCustomerNote(
        noteId: _requiredString(map, 'noteId'),
        body: _requiredString(map, 'body'),
        authorUid: _requiredString(map, 'authorUid'),
        createdAt: _requiredDateTimeFromMillis(map, 'createdAtMillis'),
        updatedAt: _requiredDateTimeFromMillis(map, 'updatedAtMillis'),
        revision: _requiredInt(map, 'revision'),
      );

  factory HostCustomerNote.fromCallableData(Object? data) =>
      HostCustomerNote.fromMap(_requiredMap(data, 'organizer contact note'));

  final String noteId;
  final String body;
  final String authorUid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int revision;

  bool get wasEdited => updatedAt.isAfter(createdAt);
}

enum HostCustomerSendDeliveryStatus {
  available,
  pending,
  sending,
  suppressed,
  accepted,
  sent,
  delivered,
  read,
  failed,
  replied,
  optedOut,
}

enum HostCustomerSendKind { campaign, announcement }

class HostCustomerSend {
  const HostCustomerSend({
    this.kind = HostCustomerSendKind.campaign,
    required this.campaignId,
    required this.name,
    required this.messageClass,
    required this.deliveryStatus,
    required this.createdAt,
    required this.sentAt,
    required this.updatedAt,
    this.broadcastId,
    this.eventId,
    this.audience,
    this.partialFailure = false,
  });

  factory HostCustomerSend.fromMap(Map<Object?, Object?> map) {
    final kind = _requiredString(map, 'kind');
    if (kind == 'announcement') {
      final broadcastId = _requiredString(map, 'broadcastId');
      final sentAt = _requiredDateTimeFromMillis(map, 'sentAtMillis');
      return HostCustomerSend(
        kind: HostCustomerSendKind.announcement,
        campaignId: broadcastId,
        name: _requiredString(map, 'eventName'),
        messageClass: 'announcement',
        deliveryStatus: _enumByName(
          HostCustomerSendDeliveryStatus.values,
          _requiredString(map, 'deliveryStatus'),
          'announcement delivery status',
        ),
        createdAt: sentAt,
        sentAt: sentAt,
        updatedAt: sentAt,
        broadcastId: broadcastId,
        eventId: _requiredString(map, 'eventId'),
        audience: _requiredString(map, 'audience'),
        partialFailure: _requiredBool(map, 'partialFailure'),
      );
    }
    if (kind != 'campaign') {
      throw const FormatException('Contact send had an unsupported kind.');
    }
    return HostCustomerSend(
      campaignId: _requiredString(map, 'campaignId'),
      name: _requiredString(map, 'name'),
      messageClass: _requiredString(map, 'messageClass'),
      deliveryStatus: _enumByName(
        HostCustomerSendDeliveryStatus.values,
        _requiredString(map, 'deliveryStatus'),
        'contact send delivery status',
      ),
      createdAt: _requiredDateTimeFromMillis(map, 'createdAtMillis'),
      sentAt: _dateTimeFromMillis(map['sentAtMillis']),
      updatedAt: _requiredDateTimeFromMillis(map, 'updatedAtMillis'),
    );
  }

  final HostCustomerSendKind kind;
  final String campaignId;
  final String name;
  final String messageClass;
  final HostCustomerSendDeliveryStatus deliveryStatus;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime updatedAt;
  final String? broadcastId;
  final String? eventId;
  final String? audience;
  final bool partialFailure;
}

class HostContactMergeCandidateContact {
  const HostContactMergeCandidateContact({
    required this.contactId,
    required this.displayName,
    required this.phoneE164,
    required this.email,
    required this.linkedAccount,
    required this.primarySource,
    required this.revision,
  });

  factory HostContactMergeCandidateContact.fromMap(Map<Object?, Object?> map) =>
      HostContactMergeCandidateContact(
        contactId: _requiredString(map, 'contactId'),
        displayName: _requiredString(map, 'displayName'),
        phoneE164: _nullableString(map['phoneE164']),
        email: _nullableString(map['email']),
        linkedAccount: _requiredBool(map, 'linkedAccount'),
        primarySource: _requiredString(map, 'primarySource'),
        revision: _requiredInt(map, 'revision'),
      );

  final String contactId;
  final String displayName;
  final String? phoneE164;
  final String? email;
  final bool linkedAccount;
  final String primarySource;
  final int revision;
}

class HostContactMergeCandidate {
  const HostContactMergeCandidate({
    required this.candidateId,
    required this.contacts,
    required this.matchKinds,
    required this.confidence,
    required this.sourceKinds,
    required this.sharedEventIds,
    required this.sharedEventCount,
    required this.updatedAt,
    required this.decisionState,
    required this.decisionRevision,
    required this.canReopen,
  });

  factory HostContactMergeCandidate.fromMap(Map<Object?, Object?> map) =>
      HostContactMergeCandidate(
        candidateId: _requiredString(map, 'candidateId'),
        contacts: _mapList(
          map['contacts'],
          'merge candidate contacts',
        ).map(HostContactMergeCandidateContact.fromMap).toList(growable: false),
        matchKinds: _stringList(map['matchKinds'])
            .map(
              (value) => _enumByName(
                HostContactMergeMatchKind.values,
                value,
                'merge match kind',
              ),
            )
            .toSet(),
        confidence: _enumByName(
          HostContactMergeConfidence.values,
          _requiredString(map, 'confidence'),
          'merge confidence',
        ),
        sourceKinds: _stringList(map['sourceKinds']).toSet(),
        sharedEventIds: _stringList(map['sharedEventIds']),
        sharedEventCount: _requiredInt(map, 'sharedEventCount'),
        updatedAt: _requiredDateTimeFromMillis(map, 'updatedAtMillis'),
        decisionState: _enumByName(
          HostContactMergeDecisionState.values,
          _requiredString(map, 'decisionState'),
          'merge decision state',
        ),
        decisionRevision: map['decisionRevision'] == null
            ? null
            : _requiredInt(map, 'decisionRevision'),
        canReopen: _requiredBool(map, 'canReopen'),
      );

  final String candidateId;
  final List<HostContactMergeCandidateContact> contacts;
  final Set<HostContactMergeMatchKind> matchKinds;
  final HostContactMergeConfidence confidence;
  final Set<String> sourceKinds;
  final List<String> sharedEventIds;
  final int sharedEventCount;
  final DateTime updatedAt;
  final HostContactMergeDecisionState decisionState;
  final int? decisionRevision;
  final bool canReopen;
}

class HostContactMergeCandidatePage {
  const HostContactMergeCandidatePage({
    required this.organizerId,
    required this.candidates,
    required this.dismissedCandidates,
    required this.nextCursor,
    required this.truncated,
  });

  factory HostContactMergeCandidatePage.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'contact merge candidates');
    return HostContactMergeCandidatePage(
      organizerId: _requiredString(map, 'organizerId'),
      candidates: _mapList(
        map['candidates'],
        'contact merge candidates',
      ).map(HostContactMergeCandidate.fromMap).toList(growable: false),
      dismissedCandidates: _mapList(
        map['dismissedCandidates'],
        'dismissed contact merge candidates',
      ).map(HostContactMergeCandidate.fromMap).toList(growable: false),
      nextCursor: _nullableString(map['nextCursor']),
      truncated: _requiredBool(map, 'truncated'),
    );
  }

  final String organizerId;
  final List<HostContactMergeCandidate> candidates;
  final List<HostContactMergeCandidate> dismissedCandidates;
  final String? nextCursor;
  final bool truncated;
}

class HostActiveContactMerge {
  const HostActiveContactMerge({
    required this.mergeReceiptId,
    required this.sourceContactId,
    required this.sourceDisplayName,
    required this.evidence,
    required this.conflicts,
    required this.movedFactCount,
    required this.mergedAt,
  });

  factory HostActiveContactMerge.fromMap(Map<Object?, Object?> map) =>
      HostActiveContactMerge(
        mergeReceiptId: _requiredString(map, 'mergeReceiptId'),
        sourceContactId: _requiredString(map, 'sourceContactId'),
        sourceDisplayName: _requiredString(map, 'sourceDisplayName'),
        evidence: _stringList(map['evidence']),
        conflicts: _stringList(map['conflicts']),
        movedFactCount: _requiredInt(map, 'movedFactCount'),
        mergedAt: _requiredDateTimeFromMillis(map, 'mergedAtMillis'),
      );

  final String mergeReceiptId;
  final String sourceContactId;
  final String sourceDisplayName;
  final List<String> evidence;
  final List<String> conflicts;
  final int movedFactCount;
  final DateTime mergedAt;
}

class HostWhatsappThreadSummary {
  const HostWhatsappThreadSummary({
    required this.threadId,
    required this.contactId,
    required this.displayName,
    required this.eventIds,
    required this.lastMessageBody,
    required this.lastMessageDirection,
    required this.lastMessageAt,
    required this.lastInboundAt,
    required this.serviceWindowExpiresAt,
    required this.serviceWindowOpen,
  });

  factory HostWhatsappThreadSummary.fromMap(Map<Object?, Object?> map) =>
      HostWhatsappThreadSummary(
        threadId: _requiredString(map, 'threadId'),
        contactId: _requiredString(map, 'contactId'),
        displayName: _requiredString(map, 'displayName'),
        eventIds: _stringList(map['eventIds']),
        lastMessageBody: _requiredString(map, 'lastMessageBody'),
        lastMessageDirection: _enumByName(
          HostWhatsappMessageDirection.values,
          _requiredString(map, 'lastMessageDirection'),
          'WhatsApp message direction',
        ),
        lastMessageAt: _requiredDateTimeFromMillis(map, 'lastMessageAtMillis'),
        lastInboundAt: _requiredDateTimeFromMillis(map, 'lastInboundAtMillis'),
        serviceWindowExpiresAt: _requiredDateTimeFromMillis(
          map,
          'serviceWindowExpiresAtMillis',
        ),
        serviceWindowOpen: _requiredBool(map, 'serviceWindowOpen'),
      );

  final String threadId;
  final String contactId;
  final String displayName;
  final List<String> eventIds;
  final String lastMessageBody;
  final HostWhatsappMessageDirection lastMessageDirection;
  final DateTime lastMessageAt;
  final DateTime lastInboundAt;
  final DateTime serviceWindowExpiresAt;
  final bool serviceWindowOpen;
}

class HostWhatsappThreadPage {
  const HostWhatsappThreadPage({
    required this.organizerId,
    required this.threads,
    required this.nextCursor,
  });

  factory HostWhatsappThreadPage.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'organizer WhatsApp threads');
    return HostWhatsappThreadPage(
      organizerId: _requiredString(map, 'organizerId'),
      threads: _mapList(
        map['threads'],
        'organizer WhatsApp threads',
      ).map(HostWhatsappThreadSummary.fromMap).toList(growable: false),
      nextCursor: _nullableString(map['nextCursor']),
    );
  }

  final String organizerId;
  final List<HostWhatsappThreadSummary> threads;
  final String? nextCursor;
}

class HostWhatsappMessage {
  const HostWhatsappMessage({
    required this.messageId,
    required this.direction,
    required this.body,
    required this.occurredAt,
  });

  factory HostWhatsappMessage.fromMap(Map<Object?, Object?> map) =>
      HostWhatsappMessage(
        messageId: _requiredString(map, 'messageId'),
        direction: _enumByName(
          HostWhatsappMessageDirection.values,
          _requiredString(map, 'direction'),
          'WhatsApp message direction',
        ),
        body: _requiredString(map, 'body'),
        occurredAt: _requiredDateTimeFromMillis(map, 'occurredAtMillis'),
      );

  final String messageId;
  final HostWhatsappMessageDirection direction;
  final String body;
  final DateTime occurredAt;
}

class HostWhatsappThreadDetail {
  const HostWhatsappThreadDetail({
    required this.organizerId,
    required this.threadId,
    required this.contactId,
    required this.displayName,
    required this.lastInboundAt,
    required this.serviceWindowExpiresAt,
    required this.serviceWindowOpen,
    required this.messages,
    required this.messagesTruncated,
  });

  factory HostWhatsappThreadDetail.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'organizer WhatsApp thread');
    return HostWhatsappThreadDetail(
      organizerId: _requiredString(map, 'organizerId'),
      threadId: _requiredString(map, 'threadId'),
      contactId: _requiredString(map, 'contactId'),
      displayName: _requiredString(map, 'displayName'),
      lastInboundAt: _requiredDateTimeFromMillis(map, 'lastInboundAtMillis'),
      serviceWindowExpiresAt: _requiredDateTimeFromMillis(
        map,
        'serviceWindowExpiresAtMillis',
      ),
      serviceWindowOpen: _requiredBool(map, 'serviceWindowOpen'),
      messages: _mapList(
        map['messages'],
        'organizer WhatsApp messages',
      ).map(HostWhatsappMessage.fromMap).toList(growable: false),
      messagesTruncated: _requiredBool(map, 'messagesTruncated'),
    );
  }

  final String organizerId;
  final String threadId;
  final String contactId;
  final String displayName;
  final DateTime lastInboundAt;
  final DateTime serviceWindowExpiresAt;
  final bool serviceWindowOpen;
  final List<HostWhatsappMessage> messages;
  final bool messagesTruncated;
}

enum HostPersonalWhatsappHandoffAvailability {
  ready,
  missingPhone,
  organizerSuppressed,
  contactOptedOut,
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
    required this.linkedAccount,
    required this.identityState,
    required this.identityConfidence,
    this.contactDetailsEditable = false,
    required this.ambiguousCandidateCount,
    required this.whatsappAdminSuppressed,
    required this.traits,
    required this.revenue,
    required this.events,
    required this.eventsTruncated,
    this.manualTags = const [],
    this.manualTagVocabulary = const [],
    this.notes = const [],
    this.notesTruncated = false,
    this.notesCoverage = HostCustomerHistoryCoverage.exact,
    this.sends = const [],
    this.sendsTruncated = false,
    this.sendsCoverage = HostCustomerHistoryCoverage.exact,
    this.activeMerges = const [],
    required this.revision,
  });

  factory HostAudienceContactDetail.fromCallableData(Object? data) =>
      HostAudienceContactDetail._fromMap(
        _requiredMap(data, 'organizer contact detail'),
        includeHistory: true,
      );

  factory HostAudienceContactDetail.fromOverviewCallableData(Object? data) {
    final map = _requiredMap(data, 'organizer contact overview');
    _requireContactSection(map, 'overview');
    return HostAudienceContactDetail._fromMap(map, includeHistory: false);
  }

  factory HostAudienceContactDetail._fromMap(
    Map<Object?, Object?> map, {
    required bool includeHistory,
  }) {
    return HostAudienceContactDetail(
      organizerId: _requiredString(map, 'organizerId'),
      contactId: _requiredString(map, 'contactId'),
      displayName: _requiredString(map, 'displayName'),
      sourceDisplayName: _requiredString(map, 'sourceDisplayName'),
      displayNameOverride: _nullableString(map['displayNameOverride']),
      phoneE164: _nullableString(map['phoneE164']),
      email: _nullableString(map['email']),
      linkedAccount: _requiredBool(map, 'linkedAccount'),
      identityState: _enumByName(
        HostAudienceIdentityState.values,
        _requiredString(map, 'identityState'),
        'identityState',
      ),
      identityConfidence: _requiredString(map, 'identityConfidence'),
      contactDetailsEditable: map['contactDetailsEditable'] == null
          ? false
          : _requiredBool(map, 'contactDetailsEditable'),
      ambiguousCandidateCount: _stringList(
        map['ambiguousCandidateContactIds'],
      ).length,
      whatsappAdminSuppressed: _requiredBool(map, 'whatsappAdminSuppressed'),
      traits: HostCustomerTraits.fromMap(
        _requiredMap(map['traits'], 'customer traits'),
      ),
      revenue: includeHistory
          ? HostCustomerRevenue.fromMap(
              _requiredMap(map['revenue'], 'customer revenue'),
            )
          : const HostCustomerRevenue(
              coverage: HostCustomerRevenueCoverage.unavailable,
              amounts: [],
            ),
      events: includeHistory
          ? _mapList(
              map['events'],
              'contact events',
            ).map(HostAudienceEventFact.fromMap).toList(growable: false)
          : const [],
      eventsTruncated: includeHistory
          ? _requiredBool(map, 'eventsTruncated')
          : false,
      manualTags: _optionalMapList(
        map['manualTags'],
        'manual tags',
      ).map(HostManualTag.fromMap).toList(growable: false),
      manualTagVocabulary: _optionalMapList(
        map['manualTagVocabulary'],
        'manual tag vocabulary',
      ).map(HostManualTag.fromMap).toList(growable: false),
      notes: _optionalMapList(
        map['notes'],
        'contact notes',
      ).map(HostCustomerNote.fromMap).toList(growable: false),
      notesTruncated: map['notesTruncated'] == null
          ? false
          : _requiredBool(map, 'notesTruncated'),
      notesCoverage: map['notesCoverage'] == null
          ? HostCustomerHistoryCoverage.exact
          : _enumByName(
              HostCustomerHistoryCoverage.values,
              _requiredString(map, 'notesCoverage'),
              'notes coverage',
            ),
      sends: includeHistory
          ? _optionalMapList(
              map['sends'],
              'contact sends',
            ).map(HostCustomerSend.fromMap).toList(growable: false)
          : const [],
      sendsTruncated: includeHistory
          ? map['sendsTruncated'] == null
                ? false
                : _requiredBool(map, 'sendsTruncated')
          : false,
      sendsCoverage: includeHistory
          ? map['sendsCoverage'] == null
                ? HostCustomerHistoryCoverage.exact
                : _enumByName(
                    HostCustomerHistoryCoverage.values,
                    _requiredString(map, 'sendsCoverage'),
                    'sends coverage',
                  )
          : HostCustomerHistoryCoverage.unavailable,
      activeMerges: includeHistory
          ? _optionalMapList(
              map['activeMerges'],
              'active contact merges',
            ).map(HostActiveContactMerge.fromMap).toList(growable: false)
          : const [],
      revision: _requiredInt(map, 'revision'),
    );
  }

  HostAudienceContactDetail withHistory(HostAudienceContactHistory history) {
    if (history.organizerId != organizerId ||
        history.contactId != contactId ||
        history.revision != revision) {
      throw const FormatException(
        'Customer history does not match the loaded overview.',
      );
    }
    return HostAudienceContactDetail(
      organizerId: organizerId,
      contactId: contactId,
      displayName: displayName,
      sourceDisplayName: sourceDisplayName,
      displayNameOverride: displayNameOverride,
      phoneE164: phoneE164,
      email: email,
      linkedAccount: linkedAccount,
      identityState: identityState,
      identityConfidence: identityConfidence,
      contactDetailsEditable: contactDetailsEditable,
      ambiguousCandidateCount: ambiguousCandidateCount,
      whatsappAdminSuppressed: whatsappAdminSuppressed,
      traits: traits,
      revenue: history.revenue,
      events: history.events,
      eventsTruncated: history.eventsTruncated,
      manualTags: manualTags,
      manualTagVocabulary: manualTagVocabulary,
      notes: notes,
      notesTruncated: notesTruncated,
      notesCoverage: notesCoverage,
      sends: history.sends,
      sendsTruncated: history.sendsTruncated,
      sendsCoverage: history.sendsCoverage,
      activeMerges: history.activeMerges,
      revision: revision,
    );
  }

  final String organizerId;
  final String contactId;
  final String displayName;
  final String sourceDisplayName;
  final String? displayNameOverride;
  final String? phoneE164;
  final String? email;
  final bool linkedAccount;
  final HostAudienceIdentityState identityState;
  final String identityConfidence;

  bool get isIdentityVerified => identityConfidence == 'verified';
  final bool contactDetailsEditable;
  final int ambiguousCandidateCount;
  final bool whatsappAdminSuppressed;
  final HostCustomerTraits traits;
  final HostCustomerRevenue revenue;
  final List<HostAudienceEventFact> events;
  final bool eventsTruncated;
  final List<HostManualTag> manualTags;
  final List<HostManualTag> manualTagVocabulary;
  final List<HostCustomerNote> notes;
  final bool notesTruncated;
  final HostCustomerHistoryCoverage notesCoverage;
  final List<HostCustomerSend> sends;
  final bool sendsTruncated;
  final HostCustomerHistoryCoverage sendsCoverage;
  final List<HostActiveContactMerge> activeMerges;
  final int revision;

  HostPersonalWhatsappHandoffAvailability
  get personalWhatsappHandoffAvailability {
    if (phoneE164 == null) {
      return HostPersonalWhatsappHandoffAvailability.missingPhone;
    }
    if (whatsappAdminSuppressed) {
      return HostPersonalWhatsappHandoffAvailability.organizerSuppressed;
    }
    if (traits.whatsappStatus == HostAudiencePermissionStatus.optedOut) {
      return HostPersonalWhatsappHandoffAvailability.contactOptedOut;
    }
    return HostPersonalWhatsappHandoffAvailability.ready;
  }

  bool get canUsePersonalWhatsappHandoff =>
      personalWhatsappHandoffAvailability ==
      HostPersonalWhatsappHandoffAvailability.ready;
}

class HostAudienceContactHistory {
  const HostAudienceContactHistory({
    required this.organizerId,
    required this.contactId,
    required this.revenue,
    required this.events,
    required this.eventsTruncated,
    required this.sends,
    required this.sendsTruncated,
    required this.sendsCoverage,
    required this.activeMerges,
    required this.revision,
  });

  factory HostAudienceContactHistory.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'organizer contact history');
    _requireContactSection(map, 'history');
    return HostAudienceContactHistory(
      organizerId: _requiredString(map, 'organizerId'),
      contactId: _requiredString(map, 'contactId'),
      revenue: HostCustomerRevenue.fromMap(
        _requiredMap(map['revenue'], 'customer revenue'),
      ),
      events: _mapList(
        map['events'],
        'contact events',
      ).map(HostAudienceEventFact.fromMap).toList(growable: false),
      eventsTruncated: _requiredBool(map, 'eventsTruncated'),
      sends: _mapList(
        map['sends'],
        'contact sends',
      ).map(HostCustomerSend.fromMap).toList(growable: false),
      sendsTruncated: _requiredBool(map, 'sendsTruncated'),
      sendsCoverage: _enumByName(
        HostCustomerHistoryCoverage.values,
        _requiredString(map, 'sendsCoverage'),
        'sends coverage',
      ),
      activeMerges: _mapList(
        map['activeMerges'],
        'active contact merges',
      ).map(HostActiveContactMerge.fromMap).toList(growable: false),
      revision: _requiredInt(map, 'revision'),
    );
  }

  final String organizerId;
  final String contactId;
  final HostCustomerRevenue revenue;
  final List<HostAudienceEventFact> events;
  final bool eventsTruncated;
  final List<HostCustomerSend> sends;
  final bool sendsTruncated;
  final HostCustomerHistoryCoverage sendsCoverage;
  final List<HostActiveContactMerge> activeMerges;
  final int revision;
}

class HostCreatedCustomer {
  const HostCreatedCustomer({
    required this.organizerId,
    required this.contactId,
    required this.displayName,
    required this.revision,
  });

  factory HostCreatedCustomer.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'created organizer customer');
    return HostCreatedCustomer(
      organizerId: _requiredString(map, 'organizerId'),
      contactId: _requiredString(map, 'contactId'),
      displayName: _requiredString(map, 'displayName'),
      revision: _requiredInt(map, 'revision'),
    );
  }

  final String organizerId;
  final String contactId;
  final String displayName;
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
    required this.matchCount,
    required this.matchCountCoverage,
    this.manualTagVocabulary = const [],
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
      matchCount: _requiredInt(map, 'matchCount'),
      matchCountCoverage: _enumByName(
        HostAudienceMatchCountCoverage.values,
        _requiredString(map, 'matchCountCoverage'),
        'matchCountCoverage',
      ),
      manualTagVocabulary: _optionalMapList(
        map['manualTagVocabulary'],
        'manual tag vocabulary',
      ).map(HostManualTag.fromMap).toList(growable: false),
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
  final int matchCount;
  final HostAudienceMatchCountCoverage matchCountCoverage;
  final List<HostManualTag> manualTagVocabulary;
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

enum HostWhatsappCampaignReadiness {
  providerUnavailable,
  senderNotConnected,
  senderNeedsAttention,
  approvedTemplateRequired,
  ready,
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

  HostWhatsappCampaignReadiness get campaignReadiness {
    if (!providerConfigured) {
      return HostWhatsappCampaignReadiness.providerUnavailable;
    }
    final sender = connection;
    if (sender == null) {
      return HostWhatsappCampaignReadiness.senderNotConnected;
    }
    if (!sender.isActive) {
      return HostWhatsappCampaignReadiness.senderNeedsAttention;
    }
    if (approvedTemplates.isEmpty) {
      return HostWhatsappCampaignReadiness.approvedTemplateRequired;
    }
    return HostWhatsappCampaignReadiness.ready;
  }

  bool get canComposeCampaign =>
      campaignReadiness == HostWhatsappCampaignReadiness.ready;
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

sealed class HostSendSummary {
  const HostSendSummary({required this.activityAt});

  factory HostSendSummary.fromMap(Map<Object?, Object?> map) =>
      switch (_requiredString(map, 'kind')) {
        'campaign' => HostCampaignSendSummary.fromMap(map),
        'announcement' => HostAnnouncementSendSummary.fromMap(map),
        'followerUpdate' => HostFollowerUpdateSendSummary.fromMap(map),
        _ => throw const FormatException('Send row had an unsupported kind.'),
      };

  final DateTime activityAt;
  String get id;
}

final class HostCampaignSendSummary extends HostSendSummary {
  const HostCampaignSendSummary({
    required this.campaignId,
    required this.name,
    required this.status,
    required this.segments,
    required this.templateId,
    required this.templateName,
    required this.audienceCounts,
    required this.deliveryCounts,
    required this.scheduledAt,
    required this.dispatchedAt,
    required super.activityAt,
  });

  factory HostCampaignSendSummary.fromMap(Map<Object?, Object?> map) =>
      HostCampaignSendSummary(
        campaignId: _requiredString(map, 'campaignId'),
        name: _requiredString(map, 'name'),
        status: _requiredString(map, 'status'),
        segments: _stringList(map['segmentIds'])
            .map(HostAudienceSegment.fromWireValue)
            .whereType<HostAudienceSegment>()
            .toSet(),
        templateId: _requiredString(map, 'templateId'),
        templateName: _nullableString(map['templateName']),
        audienceCounts: HostCampaignCounts.fromMap(
          map['audienceCounts'],
          'send audience counts',
        ),
        deliveryCounts: HostCampaignCounts.fromMap(
          map['deliveryCounts'],
          'send delivery counts',
        ),
        scheduledAt: _dateTimeFromMillis(map['scheduledAtMillis']),
        dispatchedAt: _dateTimeFromMillis(map['dispatchedAtMillis']),
        activityAt: _requiredDateTimeFromMillis(map, 'activityAtMillis'),
      );

  final String campaignId;
  final String name;
  final String status;
  final Set<HostAudienceSegment> segments;
  final String templateId;
  final String? templateName;
  final HostCampaignCounts audienceCounts;
  final HostCampaignCounts deliveryCounts;
  final DateTime? scheduledAt;
  final DateTime? dispatchedAt;

  @override
  String get id => campaignId;
}

final class HostAnnouncementSendSummary extends HostSendSummary {
  const HostAnnouncementSendSummary({
    required this.broadcastId,
    required this.eventId,
    required this.eventName,
    required this.audience,
    required this.recipientCount,
    required this.sentAt,
    required this.partialFailure,
    required super.activityAt,
  });

  factory HostAnnouncementSendSummary.fromMap(Map<Object?, Object?> map) =>
      HostAnnouncementSendSummary(
        broadcastId: _requiredString(map, 'broadcastId'),
        eventId: _requiredString(map, 'eventId'),
        eventName: _requiredString(map, 'eventName'),
        audience: _requiredString(map, 'audience'),
        recipientCount: _requiredInt(map, 'recipientCount'),
        sentAt: _requiredDateTimeFromMillis(map, 'sentAtMillis'),
        partialFailure: _requiredBool(map, 'partialFailure'),
        activityAt: _requiredDateTimeFromMillis(map, 'activityAtMillis'),
      );

  final String broadcastId;
  final String eventId;
  final String eventName;
  final String audience;
  final int recipientCount;
  final DateTime sentAt;
  final bool partialFailure;

  @override
  String get id => broadcastId;
}

final class HostFollowerUpdateSendSummary extends HostSendSummary {
  const HostFollowerUpdateSendSummary({
    required this.postId,
    required this.eventId,
    required this.audience,
    required this.status,
    required this.deliveryStatus,
    required this.recipientCount,
    required this.excludedCount,
    required this.activityAvailableCount,
    required this.pushAttemptedCount,
    required this.pushAcceptedCount,
    required this.pushFailedCount,
    required this.pushUnknownCount,
    required this.createdAt,
    required super.activityAt,
  });

  factory HostFollowerUpdateSendSummary.fromMap(Map<Object?, Object?> map) =>
      HostFollowerUpdateSendSummary(
        postId: _requiredString(map, 'postId'),
        eventId: _nullableString(map['eventId']),
        audience: _requiredString(map, 'audience'),
        status: _requiredString(map, 'status'),
        deliveryStatus: _requiredString(map, 'deliveryStatus'),
        recipientCount: _requiredInt(map, 'recipientCount'),
        excludedCount: _requiredInt(map, 'excludedCount'),
        activityAvailableCount: _requiredInt(map, 'activityAvailableCount'),
        pushAttemptedCount: _requiredInt(map, 'pushAttemptedCount'),
        pushAcceptedCount: _requiredInt(map, 'pushAcceptedCount'),
        pushFailedCount: _requiredInt(map, 'pushFailedCount'),
        pushUnknownCount: _requiredInt(map, 'pushUnknownCount'),
        createdAt: _requiredDateTimeFromMillis(map, 'createdAtMillis'),
        activityAt: _requiredDateTimeFromMillis(map, 'activityAtMillis'),
      );

  final String postId;
  final String? eventId;
  final String audience;
  final String status;
  final String deliveryStatus;
  final int recipientCount;
  final int excludedCount;
  final int activityAvailableCount;
  final int pushAttemptedCount;
  final int pushAcceptedCount;
  final int pushFailedCount;
  final int pushUnknownCount;
  final DateTime createdAt;

  bool get hasTrackedDelivery => deliveryStatus != 'unknown';

  bool get deliveryCompleted => deliveryStatus == 'completed';

  @override
  String get id => postId;
}

class HostSendsPage {
  const HostSendsPage({
    required this.organizerId,
    required this.sends,
    required this.nextCursor,
  });

  factory HostSendsPage.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'organizer Sends response');
    return HostSendsPage(
      organizerId: _requiredString(map, 'organizerId'),
      sends: _mapList(
        map['sends'],
        'organizer Sends rows',
      ).map(HostSendSummary.fromMap).toList(growable: false),
      nextCursor: _nullableString(map['nextCursor']),
    );
  }

  final String organizerId;
  final List<HostSendSummary> sends;
  final String? nextCursor;
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
  ) => _call(
    name: 'getOrganizerContactSection',
    payload: GetOrganizerContactSectionCallableRequest(
      organizerId: organizerId,
      contactId: contactId,
      section: 'overview',
    ).toJson(),
    action: 'load organizer contact overview',
    parse: HostAudienceContactDetail.fromOverviewCallableData,
  );

  Future<HostAudienceContactHistory> getContactHistory(
    String organizerId,
    String contactId,
  ) => _call(
    name: 'getOrganizerContactSection',
    payload: GetOrganizerContactSectionCallableRequest(
      organizerId: organizerId,
      contactId: contactId,
      section: 'history',
    ).toJson(),
    action: 'load organizer contact history',
    parse: HostAudienceContactHistory.fromCallableData,
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
    parse: (data) =>
        _requiredString(_requiredMap(data, 'customer conversation'), 'matchId'),
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
    .getContactDetail(organizerId, contactId);

@riverpod
Future<HostAudienceContactDetail> hostAudienceContactOverview(
  Ref ref,
  String organizerId,
  String contactId,
) => ref
    .read(hostCrmRepositoryProvider)
    .getContactOverview(organizerId, contactId);

@riverpod
Future<HostAudienceContactHistory> hostAudienceContactHistory(
  Ref ref,
  String organizerId,
  String contactId,
) => ref
    .read(hostCrmRepositoryProvider)
    .getContactHistory(organizerId, contactId);

@riverpod
Future<HostMessagingSetup> hostMessagingSetup(Ref ref, String organizerId) =>
    ref.read(hostCrmRepositoryProvider).getMessagingSetup(organizerId);

@riverpod
Future<HostSendsPage> hostSends(Ref ref, String organizerId) =>
    ref.read(hostCrmRepositoryProvider).listCampaigns(organizerId);

@riverpod
Future<HostWhatsappThreadPage> hostWhatsappThreads(
  Ref ref,
  String organizerId,
) => ref.read(hostCrmRepositoryProvider).listWhatsappThreads(organizerId);

Map<Object?, Object?> _requiredMap(Object? value, String label) {
  if (value is Map<Object?, Object?>) return value;
  throw FormatException('Invalid $label.');
}

List<Map<Object?, Object?>> _mapList(Object? value, String label) {
  if (value is! List<Object?>) throw FormatException('Invalid $label.');
  return value.map((item) => _requiredMap(item, label)).toList(growable: false);
}

List<Map<Object?, Object?>> _optionalMapList(Object? value, String label) =>
    value == null ? const [] : _mapList(value, label);

void _requireContactSection(Map<Object?, Object?> map, String expected) {
  if (_requiredString(map, 'section') != expected) {
    throw FormatException('Invalid organizer contact $expected response.');
  }
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

DateTime _requiredDateTimeFromMillis(Map<Object?, Object?> map, String key) {
  final value = _dateTimeFromMillis(map[key]);
  if (value != null) return value;
  throw FormatException('Response was missing $key.');
}

double? _nullableDouble(Object? value) {
  if (value == null) return null;
  if (value is num && value >= 0 && value <= 1) return value.toDouble();
  throw const FormatException('Expected a ratio between zero and one.');
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
