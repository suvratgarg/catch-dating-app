import 'package:catch_dating_app/payments/presentation/payment_confirmation_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

void main() {
  test('builds a calendar URI from run details', () {
    final run = buildRun(
      meetingPoint: 'Marine Drive',
      locationDetails: 'South entrance',
      startTime: DateTime.utc(2026, 5, 5, 18, 30),
      endTime: DateTime.utc(2026, 5, 5, 19, 30),
    );

    final uri = PaymentConfirmationController.calendarUri(run);

    expect(uri.host, 'calendar.google.com');
    expect(uri.queryParameters['action'], 'TEMPLATE');
    expect(uri.queryParameters['text'], 'Tuesday Evening Run');
    expect(uri.queryParameters['dates'], '20260505T183000Z/20260505T193000Z');
    expect(uri.queryParameters['location'], 'Marine Drive, South entrance');
    expect(uri.queryParameters['details'], contains('Catch run'));
    expect(uri.queryParameters['details'], contains('5km · Easy'));
  });

  test('builds directions URI from coordinates when available', () {
    final run = buildRun(startingPointLat: 19.076, startingPointLng: 72.878);

    final uri = PaymentConfirmationController.directionsUri(run);

    expect(
      uri.toString(),
      'https://www.google.com/maps/dir/?api=1&destination=19.076%2C72.878&travelmode=walking',
    );
  });

  test(
    'builds directions URI from meeting point when coordinates are absent',
    () {
      final run = buildRun(meetingPoint: 'Carter Road');

      final uri = PaymentConfirmationController.directionsUri(run);

      expect(uri.queryParameters['query'], 'Carter Road');
    },
  );

  test('builds invite and referral text without widget dependencies', () {
    final run = buildRun(meetingPoint: 'Bandra');

    expect(
      PaymentConfirmationController.inviteText(run),
      contains('${run.title} - Bandra'),
    );
    expect(
      PaymentConfirmationController.referralText(run),
      contains('download Catch'),
    );
  });
}
