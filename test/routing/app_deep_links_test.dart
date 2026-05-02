import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppDeepLinks', () {
    test('builds a run club detail URL from the router path contract', () {
      expect(
        AppDeepLinks.runClub('club-1').toString(),
        'https://catchdates.com/clubs/run-clubs/club-1',
      );
    });

    test('builds a nested run detail URL from the router path contract', () {
      expect(
        AppDeepLinks.run(runClubId: 'club-1', runId: 'run-1').toString(),
        'https://catchdates.com/clubs/run-clubs/club-1/runs/run-1',
      );
    });

    test('encodes route parameter values as path segments', () {
      expect(
        AppDeepLinks.runClub('club with spaces').toString(),
        'https://catchdates.com/clubs/run-clubs/club%20with%20spaces',
      );
    });

    test('rejects missing route parameter values', () {
      expect(() => AppDeepLinks.runClub(''), throwsArgumentError);
    });
  });
}
