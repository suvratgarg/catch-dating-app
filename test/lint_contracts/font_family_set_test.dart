import 'package:catch_dating_app/core/theme/catch_fonts.dart';
import 'package:catch_ui_lints/catch_ui_lints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Catch UI lint font-family drift set matches CatchFonts', () {
    expect(catchUiLintFontFamilies, {
      CatchFonts.serifFamily,
      CatchFonts.sansFamily,
      CatchFonts.monoFamily,
    });
  });
}
