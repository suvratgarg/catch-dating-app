import 'package:catch_dating_app/core/theme/catch_font_licenses.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled Catch font licenses are registered', () async {
    registerCatchFontLicenses();

    final entries = await LicenseRegistry.licenses.toList();
    final packages = entries.expand((entry) => entry.packages).toSet();

    expect(packages, containsAll(<String>['Archivo', 'IBM Plex Mono']));
  });
}
