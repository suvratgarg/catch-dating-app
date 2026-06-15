import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/section_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CatchSectionLabel carries the accent through icon and label', (
    tester,
  ) async {
    const accent = Color(0xFF9A4A2A);
    final sectionIcon = CatchIcons.wavingHandOutlined;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              child: CatchSectionLabel(
                icon: sectionIcon,
                label: 'FIRST HELLO',
                accentColor: accent,
              ),
            ),
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(sectionIcon));
    expect(icon.color, accent);
    expect(icon.size, CatchIcon.md);

    final label = tester.widget<Text>(find.text('FIRST HELLO'));
    expect(label.maxLines, 1);
    expect(label.overflow, TextOverflow.ellipsis);
    expect(label.style?.color, accent);
  });
}
