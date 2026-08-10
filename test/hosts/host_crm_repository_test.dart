import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses privacy-bounded CRM counts and delivery readiness', () {
    final summary = HostCrmSummary.fromCallableData({
      'organizerId': 'organizer-1',
      'contactCount': 20,
      'pastAttendeeCount': 12,
      'repeatAttendeeCount': 3,
      'linkedAccountCount': 8,
      'importedContactCount': 5,
      'whatsappOptInCount': 6,
      'smsOptInCount': 4,
      'truncated': false,
      'readiness': {
        'inApp': 'currentEventOnly',
        'whatsapp': 'providerSetupRequired',
        'sms': 'providerAndDltSetupRequired',
      },
    });

    expect(summary.pastAttendeeCount, 12);
    expect(summary.repeatAttendeeCount, 3);
    expect(summary.whatsappOptInCount, 6);
    expect(
      summary.smsReadiness,
      HostCrmChannelReadiness.providerAndDltSetupRequired,
    );
  });

  test('rejects a summary that omits a required readiness field', () {
    expect(
      () => HostCrmSummary.fromCallableData({
        'organizerId': 'organizer-1',
        'contactCount': 0,
        'pastAttendeeCount': 0,
        'repeatAttendeeCount': 0,
        'linkedAccountCount': 0,
        'importedContactCount': 0,
        'whatsappOptInCount': 0,
        'smsOptInCount': 0,
        'truncated': false,
        'readiness': const <String, Object?>{},
      }),
      throwsFormatException,
    );
  });
}
