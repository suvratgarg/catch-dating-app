import 'package:catch_dating_app/payments/presentation/payment_confirmation_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

void main() {
  test('builds a calendar URI from run details', () {
    final run = buildRun(
      meetingPoint: 'Marine Drive',
      startTime: DateTime(2026, 5, 5, 18, 30),
      endTime: DateTime(2026, 5, 5, 19, 30),
    );

    final uri = PaymentConfirmationController.calendarUri(run);

    expect(uri.host, 'calendar.google.com');
    expect(uri.toString(), contains('Tuesday%20Evening%20Run'));
    expect(uri.toString(), contains('20260505T183000/20260505T193000'));
    expect(uri.toString(), contains('Marine%20Drive'));
  });

  test('builds directions URI from coordinates when available', () {
    final run = buildRun(startingPointLat: 19.076, startingPointLng: 72.878);

    final uri = PaymentConfirmationController.directionsUri(run);

    expect(uri.toString(), 'https://maps.google.com/maps?daddr=19.076,72.878');
  });

  test(
    'builds directions URI from meeting point when coordinates are absent',
    () {
      final run = buildRun(meetingPoint: 'Carter Road');

      final uri = PaymentConfirmationController.directionsUri(run);

      expect(uri.toString(), contains('Carter%20Road'));
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
