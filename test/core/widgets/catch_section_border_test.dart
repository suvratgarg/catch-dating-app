import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CatchSection contained error owns the danger state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: CatchSection.contained(
            focused: true,
            hasError: true,
            child: Text('Section body'),
          ),
        ),
      ),
    );

    final surface = tester.widget<CatchSurface>(find.byType(CatchSurface));
    expect(
      surface.borderSpec?.side,
      CatchBorder.resolve(
        CatchTokens.editorialLight,
        CatchBorderRole.danger,
      ).side,
    );
    expect(surface.boxShadow, isNull);
  });
}
