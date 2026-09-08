import 'package:catch_ui/catch_ui.dart';
import 'package:catch_ui_lints/catch_ui_lints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Catch UI lint font-family drift set matches CatchFonts', () {
    expect(catchUiLintFontFamilies, {
      CatchFonts.voiceFamily,
      CatchFonts.monoFamily,
      ...CatchFonts.platformFunctionFamilies,
    });
  });
}
