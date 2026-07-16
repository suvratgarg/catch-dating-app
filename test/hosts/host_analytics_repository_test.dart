import 'package:catch_dating_app/hosts/data/host_analytics_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('HostAnalyticsQuery serializes custom event-scoped ranges', () {
    final request = HostAnalyticsQuery(
      clubId: 'club-1',
      eventId: 'event-1',
      rangePreset: HostAnalyticsRangePreset.custom,
      startDate: DateTime(2026, 6),
      endDate: DateTime(2026, 6, 30),
      granularity: HostAnalyticsGranularity.week,
    ).toCallableRequest().toJson();

    expect(request, {
      'clubId': 'club-1',
      'eventId': 'event-1',
      'rangePreset': 'custom',
      'startDate': '2026-06-01',
      'endDate': '2026-06-30',
      'granularity': 'week',
    });
  });

  test('HostAnalyticsQuery omits date bounds for preset ranges', () {
    final request = HostAnalyticsQuery(
      clubId: 'club-1',
      rangePreset: HostAnalyticsRangePreset.ninetyDays,
      startDate: DateTime(2026, 2),
      endDate: DateTime(2026, 1, 31),
      granularity: HostAnalyticsGranularity.month,
    ).toCallableRequest().toJson();

    expect(request, {
      'clubId': 'club-1',
      'rangePreset': '90d',
      'granularity': 'month',
    });
  });

  test('HostAnalyticsQuery sends the 12-month preset and IANA timezone', () {
    const query = HostAnalyticsQuery(
      clubId: 'club-1',
      rangePreset: HostAnalyticsRangePreset.twelveMonths,
      granularity: HostAnalyticsGranularity.month,
      timezone: 'Asia/Kolkata',
    );
    final request = query.toCallableRequest().toJson();

    expect(request, {
      'clubId': 'club-1',
      'rangePreset': '12m',
      'granularity': 'month',
      'timezone': 'Asia/Kolkata',
    });
  });

  test('trend wire keys stay pinned to the callable response fixture', () {
    final report = HostAnalyticsReport.fromCallableData({
      'generatedAt': '2026-06-18T12:00:00.000Z',
      'timezone': 'Asia/Kolkata',
      'summaryCards': [
        {
          'id': 'bookings',
          'label': 'SERVER_LABEL',
          'value': 12,
          'previousValue': 8,
          'unit': 'count',
          'status': 'ready',
        },
      ],
      'trend': [
        {
          'periodStart': '2026-06-01T18:30:00.000Z',
          'periodEnd': '2026-06-08T18:29:59.999Z',
          'metrics': {for (final key in HostAnalyticsTrendKeys.values) key: 1},
        },
      ],
      'topEvents': const [],
      'reviewSummary': const {},
      'discoverySummary': const {},
      'dataQuality': const [],
    });

    expect(report.timezone, 'Asia/Kolkata');
    expect(report.summaryCards.single.previousValue, 8);
    expect(
      report.trend.single.metrics.keys.toSet(),
      HostAnalyticsTrendKeys.values,
    );
  });

  test('HostAnalyticsEventRow parses full backend event metrics', () {
    final row = HostAnalyticsEventRow.fromMap({
      'eventId': 'event-1',
      'clubId': 'club-1',
      'title': 'Morning miles',
      'startTime': '2026-06-18T02:30:00.000Z',
      'status': 'completed',
      'bookedCount': 24,
      'checkedInCount': 21,
      'waitlistedCount': 3,
      'fillRate': 80,
      'checkInRate': 87.5,
      'grossRevenueMinor': 120000,
      'currency': 'INR',
      'checkoutStartedCount': 29,
      'checkoutDropoffCount': 4,
      'paymentCompletedCount': 24,
      'paymentFailedCount': 2,
      'paymentRefundedCount': 1,
      'reviewCount': 7,
      'averageRating': 4.6,
      'demandCount': 31,
      'inviteOpenCount': 19,
      'mutualMatchCount': 8,
      'chatStartedCount': 5,
      'repeatAttendeeCount': 6,
    });

    expect(row.status, 'completed');
    expect(row.checkoutStartedCount, 29);
    expect(row.checkoutDropoffCount, 4);
    expect(row.paymentCompletedCount, 24);
    expect(row.paymentFailedCount, 2);
    expect(row.paymentRefundedCount, 1);
    expect(row.demandCount, 31);
    expect(row.chatStartedCount, 5);
    expect(row.repeatAttendeeCount, 6);
  });

  test(
    'preset providers reuse cached reports until explicitly invalidated',
    () async {
      final repository = _CountingHostAnalyticsRepository();
      final container = ProviderContainer(
        overrides: [
          hostAnalyticsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      const queries = [
        HostAnalyticsQuery(
          clubId: 'club-1',
          timezone: 'Asia/Kolkata',
        ),
        HostAnalyticsQuery(
          clubId: 'club-1',
          rangePreset: HostAnalyticsRangePreset.ninetyDays,
          granularity: HostAnalyticsGranularity.week,
          timezone: 'Asia/Kolkata',
        ),
        HostAnalyticsQuery(
          clubId: 'club-1',
          rangePreset: HostAnalyticsRangePreset.twelveMonths,
          granularity: HostAnalyticsGranularity.month,
          timezone: 'Asia/Kolkata',
        ),
      ];

      Future<void> load(HostAnalyticsQuery query) async {
        final provider = hostAnalyticsProvider(query);
        final subscription = container.listen(provider, (_, _) {});
        await container.read(provider.future);
        subscription.close();
        await Future<void>.delayed(Duration.zero);
      }

      for (final query in queries) {
        await load(query);
      }
      await load(queries.first);
      expect(repository.callCount, 3);

      container.invalidate(hostAnalyticsProvider(queries.first));
      await load(queries.first);
      expect(repository.callCount, 4);
    },
  );
}

class _CountingHostAnalyticsRepository implements HostAnalyticsRepository {
  int callCount = 0;

  @override
  Future<HostAnalyticsReport> getHostAnalytics(HostAnalyticsQuery query) async {
    callCount += 1;
    return HostAnalyticsReport.fromCallableData({
      'generatedAt': '2026-06-18T12:00:00.000Z',
      'timezone': query.timezone,
      'summaryCards': const [],
      'trend': const [],
      'topEvents': const [],
      'reviewSummary': const {},
      'discoverySummary': const {},
      'dataQuality': const [],
    });
  }
}
