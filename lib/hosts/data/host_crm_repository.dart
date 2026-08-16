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

class HostAudienceQuery {
  const HostAudienceQuery({
    this.search,
    this.segment,
    this.manualTagId,
    this.cursor,
  });

  final String? search;
  final HostAudienceSegment? segment;
  final String? manualTagId;
  final String? cursor;

  HostAudienceQuery copyWith({
    String? search,
    HostAudienceSegment? segment,
    String? manualTagId,
    String? cursor,
    bool clearSegment = false,
    bool clearManualTag = false,
    bool clearCursor = false,
  }) => HostAudienceQuery(
    search: search ?? this.search,
    segment: clearSegment ? null : segment ?? this.segment,
    manualTagId: clearManualTag ? null : manualTagId ?? this.manualTagId,
    cursor: clearCursor ? null : cursor ?? this.cursor,
  );

  @override
  bool operator ==(Object other) =>
      other is HostAudienceQuery &&
      other.search == search &&
      other.segment == segment &&
      other.manualTagId == manualTagId &&
      other.cursor == cursor;

  @override
  int get hashCode => Object.hash(search, segment, manualTagId, cursor);
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

class HostCustomerTraits {
  const HostCustomerTraits({
    required this.expectedEventCount,
    required this.attendedEventCount,
    required this.cancelledEventCount,
    required this.noShowCount,
    required this.importedEventCount,
    required this.attendanceRate,
    required this.segments,
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
  final HostAudienceSourceCoverage sourceCoverage;
}

class HostCustomerRevenueAmount {
  const HostCustomerRevenueAmount({
    required this.currency,
    required this.amountMinor,
    required this.paidOrderCount,
  });

  factory HostCustomerRevenueAmount.fromMap(Map<Object?, Object?> map) =>
      HostCustomerRevenueAmount(
        currency: _requiredString(map, 'currency'),
        amountMinor: _requiredInt(map, 'amountMinor'),
        paidOrderCount: _requiredInt(map, 'paidOrderCount'),
      );

  final String currency;
  final int amountMinor;
  final int paidOrderCount;
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

class HostCustomerSend {
  const HostCustomerSend({
    required this.campaignId,
    required this.name,
    required this.messageClass,
    required this.deliveryStatus,
    required this.createdAt,
    required this.sentAt,
    required this.updatedAt,
  });

  factory HostCustomerSend.fromMap(Map<Object?, Object?> map) {
    if (_requiredString(map, 'kind') != 'campaign') {
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

  final String campaignId;
  final String name;
  final String messageClass;
  final HostCustomerSendDeliveryStatus deliveryStatus;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime updatedAt;
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
    this.sends = const [],
    this.sendsTruncated = false,
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
      linkedAccount: _requiredBool(map, 'linkedAccount'),
      identityState: _enumByName(
        HostAudienceIdentityState.values,
        _requiredString(map, 'identityState'),
        'identityState',
      ),
      identityConfidence: _requiredString(map, 'identityConfidence'),
      ambiguousCandidateCount: _stringList(
        map['ambiguousCandidateContactIds'],
      ).length,
      whatsappAdminSuppressed: _requiredBool(map, 'whatsappAdminSuppressed'),
      traits: HostCustomerTraits.fromMap(
        _requiredMap(map['traits'], 'customer traits'),
      ),
      revenue: HostCustomerRevenue.fromMap(
        _requiredMap(map['revenue'], 'customer revenue'),
      ),
      events: _mapList(
        map['events'],
        'contact events',
      ).map(HostAudienceEventFact.fromMap).toList(growable: false),
      eventsTruncated: _requiredBool(map, 'eventsTruncated'),
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
      sends: _optionalMapList(
        map['sends'],
        'contact sends',
      ).map(HostCustomerSend.fromMap).toList(growable: false),
      sendsTruncated: map['sendsTruncated'] == null
          ? false
          : _requiredBool(map, 'sendsTruncated'),
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
  final bool linkedAccount;
  final HostAudienceIdentityState identityState;
  final String identityConfidence;
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
  final List<HostCustomerSend> sends;
  final bool sendsTruncated;
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
    int limit = ReadLimitPolicy.historyPage,
  }) => _call(
    name: 'listOrganizerContacts',
    payload: ListOrganizerContactsCallableRequest(
      organizerId: organizerId,
      limit: limit,
      cursor: query.cursor,
      query: query.search?.trim().isEmpty ?? true ? null : query.search?.trim(),
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

  Future<HostCreatedCustomer> createContact({
    required String organizerId,
    required String displayName,
  }) => _call(
    name: 'createOrganizerContact',
    payload: CreateOrganizerContactCallableRequest(
      organizerId: organizerId,
      displayName: displayName,
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

List<Map<Object?, Object?>> _optionalMapList(Object? value, String label) =>
    value == null ? const [] : _mapList(value, label);

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
