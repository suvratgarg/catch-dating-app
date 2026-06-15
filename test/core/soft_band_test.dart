import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/soft_band.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CatchSoftBand renders the handoff primary-soft inset row', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(
            child: CatchSoftBand(child: Text('Only you see this privacy note.')),
          ),
        ),
      ),
    );

    expect(find.text('Only you see this privacy note.'), findsOneWidget);

    final surface = tester.widget<CatchSurface>(find.byType(CatchSurface));
    expect(surface.tone, CatchSurfaceTone.primarySoft);
    expect(surface.elevation, CatchSurfaceElevation.none);
    expect(surface.radius, CatchRadius.sm);
    expect(surface.borderWidth, 0);
    expect(
      surface.padding,
      const EdgeInsets.symmetric(
        horizontal: CatchSpacing.micro14,
        vertical: CatchSpacing.s3,
      ),
    );
  });
}
