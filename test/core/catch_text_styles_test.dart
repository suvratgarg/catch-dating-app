import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_fonts.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('routeTitle is the locked compact Archivo title role', (
    tester,
  ) async {
    late TextStyle style;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            style = CatchTextStyles.routeTitle(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(style.fontFamily, CatchFonts.voiceFamily);
    expect(style.fontSize, 20);
    expect(style.fontWeight, FontWeight.w700);
    expect(style.height, 1.16);
    expect(style.letterSpacing, 0);
    expect(style.fontVariations, const <FontVariation>[
      FontVariation('wght', 700),
      FontVariation('wdth', CatchFonts.archivoWidth),
    ]);
  });

  test('icon raster glyph preserves icon-font metadata and art effects', () {
    final icon = CatchIcons.running;
    const shadow = Shadow(
      color: Colors.black38,
      blurRadius: 4,
      offset: Offset(0, 2),
    );

    final style = CatchTextStyles.iconRasterGlyph(
      icon: icon,
      size: 32,
      color: Colors.orange,
      shadows: const [shadow],
    );

    final package = icon.fontPackage;
    expect(
      style.fontFamily,
      package == null
          ? icon.fontFamily
          : 'packages/$package/${icon.fontFamily}',
    );
    expect(
      style.fontFamilyFallback,
      package == null
          ? icon.fontFamilyFallback
          : icon.fontFamilyFallback
                ?.map((family) => 'packages/$package/$family')
                .toList(),
    );
    expect(style.fontSize, 32);
    expect(style.height, 1);
    expect(style.color, Colors.orange);
    expect(style.shadows, const [shadow]);
  });
}
