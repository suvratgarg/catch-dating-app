import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations_en.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CatchPrivacyBadge renders each handoff visibility mode', (
    tester,
  ) async {
    final copy = catchPrivacyBadgeCopy(AppLocalizationsEn());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CatchPrivacyBadge(copy: copy),
              CatchPrivacyBadge(
                copy: copy,
                kind: CatchPrivacyBadgeKind.catchPrivate,
              ),
              CatchPrivacyBadge(
                copy: copy,
                kind: CatchPrivacyBadgeKind.hostCanSee,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('PRIVATE TO YOU'), findsOneWidget);
    expect(find.text('CATCH PRIVATE'), findsOneWidget);
    expect(find.text('HOST CAN SEE'), findsOneWidget);
    expect(find.byIcon(CatchIcons.lockOutlineRounded), findsOneWidget);
    expect(find.byIcon(CatchIcons.shieldOutlined), findsOneWidget);
    expect(find.byIcon(CatchIcons.visibilityOutlined), findsOneWidget);
    expect(find.byType(CatchBadge), findsNWidgets(3));
  });
}
