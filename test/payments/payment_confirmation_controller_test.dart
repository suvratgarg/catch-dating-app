import 'package:catch_dating_app/payments/presentation/payment_confirmation_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';

void main() {
  test('builds a calendar URI from event details', () {
    final event = buildEvent(
      meetingPoint: 'Marine Drive',
      locationDetails: 'South entrance',
      startTime: DateTime.utc(2026, 5, 5, 18, 30),
      endTime: DateTime.utc(2026, 5, 5, 19, 30),
    );

    final uri = PaymentConfirmationController.calendarUri(event);

    expect(uri.host, 'calendar.google.com');
    expect(uri.queryParameters['action'], 'TEMPLATE');
    expect(uri.queryParameters['text'], 'Tuesday Evening Event');
    expect(uri.queryParameters['dates'], '20260505T183000Z/20260505T193000Z');
    expect(uri.queryParameters['location'], 'Marine Drive, South entrance');
    expect(uri.queryParameters['details'], contains('Catch event'));
    expect(uri.queryParameters['details'], contains('5km · Easy'));
  });

  test('builds directions URI from coordinates when available', () {
    final event = buildEvent(
      startingPointLat: 19.076,
      startingPointLng: 72.878,
    );

    final uri = PaymentConfirmationController.directionsUri(event);

    expect(
      uri.toString(),
      'https://www.google.com/maps/dir/?api=1&destination=19.076%2C72.878&travelmode=walking',
    );
  });

  test(
    'builds directions URI from meeting point when coordinates are absent',
    () {
      final event = buildEvent(meetingPoint: 'Carter Road');

      final uri = PaymentConfirmationController.directionsUri(event);

      expect(uri.queryParameters['query'], 'Carter Road');
    },
  );

  test('builds invite and referral text without widget dependencies', () {
    final event = buildEvent(meetingPoint: 'Bandra');

    expect(
      PaymentConfirmationController.inviteText(event),
      contains('${event.title} - Bandra'),
    );
    expect(
      PaymentConfirmationController.referralText(event),
      contains('download Catch'),
    );
  });
}
