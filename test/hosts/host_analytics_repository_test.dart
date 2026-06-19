import 'package:catch_dating_app/hosts/data/host_analytics_repository.dart';
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
}
