import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../support/catch_test_fonts.dart';

/// Auto-discovered by `flutter test` for EVERY test under `test/goldens/` (and
/// nowhere else — the app's other ~1200 tests are unaffected).
///
/// Catch bundles its three identity fonts (see `pubspec.yaml`), so goldens load
/// the **exact same variable TTFs** the app ships and register them under the
/// plain family names [CatchFonts] requests (`Newsreader`, `Inter`,
/// `IBM Plex Mono`). Because they are the real variable files, `FontVariation`
/// (the `opsz` optical-size axis + the `wght` weight axis) renders in goldens
/// just as it does at runtime — so optical sizing is part of the visual
/// contract. Roman + italic are loaded into one `Newsreader` family; IBM Plex
/// Mono uses its per-weight statics. Icon fonts are also registered so app
/// chrome renders as real glyphs instead of missing-glyph boxes. Test-only —
/// adds no app assets.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadCatchTestFonts();
  await testMain();
}
