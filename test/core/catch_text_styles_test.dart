import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
