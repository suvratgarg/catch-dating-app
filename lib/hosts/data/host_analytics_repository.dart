import 'dart:async';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_analytics_repository.g.dart';

// keepalive: the device IANA timezone is stable for the app process and lets
// host surfaces render from their market fallback while the plugin resolves.
@Riverpod(keepAlive: true)
Future<String?> hostAnalyticsDeviceTimezone(Ref ref) async {
  try {
    final timezone = (await FlutterTimezone.getLocalTimezone()).identifier;
    final normalized = timezone.trim();
    return normalized.isEmpty ? null : normalized;
  } on Object {
    return null;
  }
}

enum HostAnalyticsRangePreset {
  sevenDays('7d', '7 days'),
  thirtyDays('30d', '30 days'),
  ninetyDays('90d', '90 days'),
  twelveMonths('12m', '12 months'),
  month('month', 'This month'),
  custom('custom', 'Custom');

  const HostAnalyticsRangePreset(this.wireValue, this.label);

  final String wireValue;
  final String label;
}

enum HostAnalyticsGranularity {
  day('day', 'Day'),
  week('week', 'Week'),
  month('month', 'Month');

  const HostAnalyticsGranularity(this.wireValue, this.label);

  final String wireValue;
  final String label;
}

enum HostAnalyticsMetricUnit { count, percent, moneyMinor, rating }

enum HostAnalyticsMetricStatus { ready, partial, missing }

enum HostAnalyticsDataQualityState { ok, partial, missing }

/// Wire keys for [HostAnalyticsTrendPoint.metrics], as emitted by
/// `functions/src/analytics/hostAnalytics.ts`.
abstract final class HostAnalyticsTrendKeys {
  static const eventCount = 'eventCount';
  static const bookings = 'bookings';
  static const checkedIn = 'checkedIn';
  static const revenueMinor = 'revenueMinor';
  static const checkoutStarted = 'checkoutStarted';
  static const checkoutDropoff = 'checkoutDropoff';
  static const demand = 'demand';
  static const reviews = 'reviews';
  static const matches = 'matches';
  static const chats = 'chats';
  static const eventSaves = 'eventSaves';
  static const listingViews = 'listingViews';
  static const eventViews = 'eventViews';
  static const organizerSaves = 'organizerSaves';

  static const values = <String>{
    eventCount,
    bookings,
    checkedIn,
    revenueMinor,
    checkoutStarted,
    checkoutDropoff,
    demand,
    reviews,
    matches,
    chats,
    eventSaves,
    listingViews,
    eventViews,
    organizerSaves,
  };
}

/// Stable summary-card ids emitted by the host analytics callable.
abstract final class HostAnalyticsMetricIds {
  static const listingViews = 'listingViews';
  static const eventViews = 'eventViews';
  static const bookings = 'bookings';
  static const attendanceRate = 'attendanceRate';
  static const revenue = 'revenue';
  static const checkoutDropoff = 'checkoutDropoff';
  static const checkoutConversionRate = 'checkoutConversionRate';
  static const newReviews = 'newReviews';
  static const connections = 'connections';
  static const chats = 'chats';
  static const combinedViews = 'combinedViews';
  static const eventSaves = 'eventSaves';
}

class HostAnalyticsQuery {
  const HostAnalyticsQuery({
    this.clubId,
    this.eventId,
    this.rangePreset = HostAnalyticsRangePreset.thirtyDays,
    this.startDate,
    this.endDate,
    this.granularity,
    this.timezone,
  });

  final String? clubId;
  final String? eventId;
  final HostAnalyticsRangePreset rangePreset;
  final DateTime? startDate;
  final DateTime? endDate;
  final HostAnalyticsGranularity? granularity;
  final String? timezone;

  HostAnalyticsQueryCallableRequest toCallableRequest() =>
      HostAnalyticsQueryCallableRequest(
        clubId: clubId,
        eventId: eventId,
        rangePreset: rangePreset.wireValue,
        startDate: rangePreset == HostAnalyticsRangePreset.custom
            ? _dateOnlyString(startDate)
            : null,
        endDate: rangePreset == HostAnalyticsRangePreset.custom
            ? _dateOnlyString(endDate)
            : null,
        granularity: granularity?.wireValue,
        timezone: timezone,
      );

  @override
  bool operator ==(Object other) {
    return other is HostAnalyticsQuery &&
        other.clubId == clubId &&
        other.eventId == eventId &&
        other.rangePreset == rangePreset &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.granularity == granularity &&
        other.timezone == timezone;
  }

  @override
  int get hashCode => Object.hash(
    clubId,
    eventId,
    rangePreset,
    startDate,
    endDate,
    granularity,
    timezone,
  );
}

class HostAnalyticsMetricCard {
  const HostAnalyticsMetricCard({
    required this.id,
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
    this.caption,
    this.previousValue,
  });

  factory HostAnalyticsMetricCard.fromMap(Map<Object?, Object?> map) {
    return HostAnalyticsMetricCard(
      id: _string(map['id']),
      label: _string(map['label']),
      value: _num(map['value']),
      unit: _metricUnit(_string(map['unit'])),
      status: _metricStatus(_string(map['status'])),
      caption: _nullableString(map['caption']),
      previousValue: _nullableNum(map['previousValue']),
    );
  }

  final String id;
  final String label;
  final num value;
  final HostAnalyticsMetricUnit unit;
  final HostAnalyticsMetricStatus status;
  final String? caption;
  final num? previousValue;
}

class HostAnalyticsTrendPoint {
  const HostAnalyticsTrendPoint({
    required this.periodStart,
    required this.periodEnd,
    required this.metrics,
  });

  factory HostAnalyticsTrendPoint.fromMap(Map<Object?, Object?> map) {
    return HostAnalyticsTrendPoint(
      periodStart: _dateTime(map['periodStart']),
      periodEnd: _dateTime(map['periodEnd']),
      metrics: _numberMap(map['metrics']),
    );
  }

  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<String, num> metrics;
}

class HostAnalyticsEventRow {
  const HostAnalyticsEventRow({
    required this.eventId,
    required this.clubId,
    required this.title,
    required this.startTime,
    required this.status,
    required this.bookedCount,
    required this.checkedInCount,
    required this.waitlistedCount,
    required this.fillRate,
    required this.checkInRate,
    required this.grossRevenueMinor,
    required this.currency,
    required this.checkoutStartedCount,
    required this.checkoutDropoffCount,
    required this.paymentCompletedCount,
    required this.paymentFailedCount,
    required this.paymentRefundedCount,
    required this.reviewCount,
    required this.averageRating,
    required this.demandCount,
    required this.inviteOpenCount,
    required this.mutualMatchCount,
    required this.chatStartedCount,
    required this.repeatAttendeeCount,
  });

  factory HostAnalyticsEventRow.fromMap(Map<Object?, Object?> map) {
    return HostAnalyticsEventRow(
      eventId: _string(map['eventId']),
      clubId: _string(map['clubId']),
      title: _string(map['title']),
      startTime: _dateTime(map['startTime']),
      status: _string(map['status'], fallback: 'unknown'),
      bookedCount: _int(map['bookedCount']),
      checkedInCount: _int(map['checkedInCount']),
      waitlistedCount: _int(map['waitlistedCount']),
      fillRate: _num(map['fillRate']),
      checkInRate: _num(map['checkInRate']),
      grossRevenueMinor: _int(map['grossRevenueMinor']),
      currency: _string(map['currency'], fallback: 'INR'),
      checkoutStartedCount: _int(map['checkoutStartedCount']),
      checkoutDropoffCount: _int(map['checkoutDropoffCount']),
      paymentCompletedCount: _int(map['paymentCompletedCount']),
      paymentFailedCount: _int(map['paymentFailedCount']),
      paymentRefundedCount: _int(map['paymentRefundedCount']),
      reviewCount: _int(map['reviewCount']),
      averageRating: _num(map['averageRating']),
      demandCount: _int(map['demandCount']),
      inviteOpenCount: _int(map['inviteOpenCount']),
      mutualMatchCount: _int(map['mutualMatchCount']),
      chatStartedCount: _int(map['chatStartedCount']),
      repeatAttendeeCount: _int(map['repeatAttendeeCount']),
    );
  }

  final String eventId;
  final String clubId;
  final String title;
  final DateTime startTime;
  final String status;
  final int bookedCount;
  final int checkedInCount;
  final int waitlistedCount;
  final num fillRate;
  final num checkInRate;
  final int grossRevenueMinor;
  final String currency;
  final int checkoutStartedCount;
  final int checkoutDropoffCount;
  final int paymentCompletedCount;
  final int paymentFailedCount;
  final int paymentRefundedCount;
  final int reviewCount;
  final num averageRating;
  final int demandCount;
  final int inviteOpenCount;
  final int mutualMatchCount;
  final int chatStartedCount;
  final int repeatAttendeeCount;
}

class HostAnalyticsReviewSummary {
  const HostAnalyticsReviewSummary({
    required this.newReviews,
    required this.publishedReviews,
    required this.verifiedReviews,
    required this.publicReviews,
    required this.ownerResponseCount,
    required this.averageRating,
  });

  factory HostAnalyticsReviewSummary.fromMap(Map<Object?, Object?> map) {
    return HostAnalyticsReviewSummary(
      newReviews: _int(map['newReviews']),
      publishedReviews: _int(map['publishedReviews']),
      verifiedReviews: _int(map['verifiedReviews']),
      publicReviews: _int(map['publicReviews']),
      ownerResponseCount: _int(map['ownerResponseCount']),
      averageRating: _num(map['averageRating']),
    );
  }

  final int newReviews;
  final int publishedReviews;
  final int verifiedReviews;
  final int publicReviews;
  final int ownerResponseCount;
  final num averageRating;
}

class HostAnalyticsDiscoverySummary {
  const HostAnalyticsDiscoverySummary({
    required this.listingViews,
    required this.searchAppearances,
    required this.eventViews,
    required this.organizerSaves,
    required this.eventSaves,
    required this.contactClicks,
    required this.claimClicks,
    required this.outboundClicks,
  });

  factory HostAnalyticsDiscoverySummary.fromMap(Map<Object?, Object?> map) {
    return HostAnalyticsDiscoverySummary(
      listingViews: _int(map['listingViews']),
      searchAppearances: _int(map['searchAppearances']),
      eventViews: _int(map['eventViews']),
      organizerSaves: _int(map['organizerSaves']),
      eventSaves: _int(map['eventSaves']),
      contactClicks: _int(map['contactClicks']),
      claimClicks: _int(map['claimClicks']),
      outboundClicks: _int(map['outboundClicks']),
    );
  }

  final int listingViews;
  final int searchAppearances;
  final int eventViews;
  final int organizerSaves;
  final int eventSaves;
  final int contactClicks;
  final int claimClicks;
  final int outboundClicks;
}

class HostAnalyticsDataQuality {
  const HostAnalyticsDataQuality({
    required this.id,
    required this.state,
    required this.detail,
  });

  factory HostAnalyticsDataQuality.fromMap(Map<Object?, Object?> map) {
    return HostAnalyticsDataQuality(
      id: _string(map['id']),
      state: _dataQualityState(_string(map['state'])),
      detail: _string(map['detail']),
    );
  }

  final String id;
  final HostAnalyticsDataQualityState state;
  final String detail;
}

class HostAnalyticsReport {
  const HostAnalyticsReport({
    required this.generatedAt,
    required this.summaryCards,
    required this.trend,
    required this.topEvents,
    required this.reviewSummary,
    required this.discoverySummary,
    required this.dataQuality,
    this.timezone = 'UTC',
  });

  factory HostAnalyticsReport.fromCallableData(Object? data) {
    if (data case final Map<Object?, Object?> map) {
      return HostAnalyticsReport(
        generatedAt: _dateTime(map['generatedAt']),
        summaryCards: _mapList(
          map['summaryCards'],
          HostAnalyticsMetricCard.fromMap,
        ),
        trend: _mapList(map['trend'], HostAnalyticsTrendPoint.fromMap),
        topEvents: _mapList(map['topEvents'], HostAnalyticsEventRow.fromMap),
        reviewSummary: HostAnalyticsReviewSummary.fromMap(
          _map(map['reviewSummary']),
        ),
        discoverySummary: HostAnalyticsDiscoverySummary.fromMap(
          _map(map['discoverySummary']),
        ),
        dataQuality: _mapList(
          map['dataQuality'],
          HostAnalyticsDataQuality.fromMap,
        ),
        timezone: _string(map['timezone'], fallback: 'UTC'),
      );
    }
    throw const FormatException('Invalid host analytics response.');
  }

  final DateTime generatedAt;
  final List<HostAnalyticsMetricCard> summaryCards;
  final List<HostAnalyticsTrendPoint> trend;
  final List<HostAnalyticsEventRow> topEvents;
  final HostAnalyticsReviewSummary reviewSummary;
  final HostAnalyticsDiscoverySummary discoverySummary;
  final List<HostAnalyticsDataQuality> dataQuality;
  final String timezone;
}

class HostAnalyticsRepository {
  const HostAnalyticsRepository(this._functions);

  final FirebaseFunctions _functions;

  Future<HostAnalyticsReport> getHostAnalytics(HostAnalyticsQuery query) =>
      withBackendErrorContext(
        () async {
          final result = await _functions
              .httpsCallable('getHostAnalytics')
              .call(query.toCallableRequest().toJson());
          return HostAnalyticsReport.fromCallableData(result.data);
        },
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'load host analytics',
          resource: 'getHostAnalytics',
        ),
      );
}

@riverpod
HostAnalyticsRepository hostAnalyticsRepository(Ref ref) {
  return HostAnalyticsRepository(ref.watch(firebaseFunctionsProvider));
}

@riverpod
Future<HostAnalyticsReport> hostAnalytics(Ref ref, HostAnalyticsQuery query) {
  // keepalive: Reuse each scorecard preset for ten minutes after tab exit.
  final link = ref.keepAlive();
  Timer? expiryTimer;
  ref.onCancel(() {
    expiryTimer?.cancel();
    expiryTimer = Timer(const Duration(minutes: 10), () {
      link.close();
      ref.invalidateSelf();
    });
  });
  ref.onResume(() => expiryTimer?.cancel());
  ref.onDispose(() => expiryTimer?.cancel());
  return ref.watch(hostAnalyticsRepositoryProvider).getHostAnalytics(query);
}

Map<Object?, Object?> _map(Object? value) =>
    value is Map<Object?, Object?> ? value : const {};

List<T> _mapList<T>(
  Object? value,
  T Function(Map<Object?, Object?> map) mapper,
) {
  if (value is! List<Object?>) return const [];
  return [
    for (final item in value)
      if (item is Map<Object?, Object?>) mapper(item),
  ];
}

Map<String, num> _numberMap(Object? value) {
  if (value is! Map<Object?, Object?>) return const {};
  return {
    for (final entry in value.entries)
      if (entry.key case final String key)
        if (entry.value case final num number) key: number,
  };
}

String _string(Object? value, {String fallback = ''}) =>
    value is String ? value : fallback;

String? _nullableString(Object? value) => value is String ? value : null;

int _int(Object? value) => value is num ? value.round() : 0;

num _num(Object? value) => value is num ? value : 0;

num? _nullableNum(Object? value) => value is num ? value : null;

DateTime _dateTime(Object? value) {
  if (value is String) return DateTime.tryParse(value) ?? DateTime(1970);
  return DateTime(1970);
}

String? _dateOnlyString(DateTime? value) {
  if (value == null) return null;
  final normalized = DateUtils.dateOnly(value);
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');
  return '${normalized.year}-$month-$day';
}

HostAnalyticsMetricUnit _metricUnit(String value) => switch (value) {
  'percent' => HostAnalyticsMetricUnit.percent,
  'money_minor' => HostAnalyticsMetricUnit.moneyMinor,
  'rating' => HostAnalyticsMetricUnit.rating,
  _ => HostAnalyticsMetricUnit.count,
};

HostAnalyticsMetricStatus _metricStatus(String value) => switch (value) {
  'partial' => HostAnalyticsMetricStatus.partial,
  'missing' => HostAnalyticsMetricStatus.missing,
  _ => HostAnalyticsMetricStatus.ready,
};

HostAnalyticsDataQualityState _dataQualityState(String value) =>
    switch (value) {
      'partial' => HostAnalyticsDataQualityState.partial,
      'missing' => HostAnalyticsDataQualityState.missing,
      _ => HostAnalyticsDataQualityState.ok,
    };
