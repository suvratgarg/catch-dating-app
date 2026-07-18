import 'package:catch_dating_app/core/formatters/catch_count_copy.dart';
import 'package:catch_dating_app/core/formatters/catch_distance_formatter.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('CatchCountCopy localizes event counts', () {
    expect(CatchCountCopy.events(l10n, 0), 'No events');
    expect(CatchCountCopy.events(l10n, 1), '1 event');
    expect(CatchCountCopy.events(l10n, 12), '12 events');
  });

  test('CatchDistanceFormatter uses bounded metric precision', () {
    expect(CatchDistanceFormatter.away(l10n, null), isNull);
    expect(CatchDistanceFormatter.away(l10n, 0.42), '420 m away');
    expect(CatchDistanceFormatter.away(l10n, 1.25), '1.3 km away');
    expect(CatchDistanceFormatter.away(l10n, 12.6), '13 km away');
  });
}
