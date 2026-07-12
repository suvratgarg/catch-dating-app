import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

bool _fontLicensesRegistered = false;

/// Registers the bundled font licenses with Flutter's license registry.
///
/// Registration is idempotent so tests and hot-restart bootstrap paths do not
/// duplicate entries.
void registerCatchFontLicenses() {
  if (_fontLicensesRegistered) return;
  _fontLicensesRegistered = true;

  LicenseRegistry.addLicense(() async* {
    const licenses = <String, String>{
      'Archivo': 'assets/fonts/OFL-Archivo.txt',
      'IBM Plex Mono': 'assets/fonts/OFL-IBMPlexMono.txt',
    };
    for (final entry in licenses.entries) {
      yield LicenseEntryWithLineBreaks(<String>[
        entry.key,
      ], await rootBundle.loadString(entry.value));
    }
  });
}
