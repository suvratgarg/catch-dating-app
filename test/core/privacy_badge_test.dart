import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_privacy_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CatchPrivacyBadge renders each handoff visibility mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CatchPrivacyBadge(),
              CatchPrivacyBadge(kind: CatchPrivacyBadgeKind.catchPrivate),
              CatchPrivacyBadge(kind: CatchPrivacyBadgeKind.host),
            ],
          ),
        ),
      ),
    );

    expect(find.text('PRIVATE TO YOU'), findsOneWidget);
    expect(find.text('CATCH PRIVATE'), findsOneWidget);
    expect(find.text('HOST CAN SEE'), findsOneWidget);
    expect(find.byIcon(CatchIcons.lockOutlineRounded), findsNWidgets(2));
    expect(find.byIcon(CatchIcons.visibilityOutlined), findsOneWidget);
  });
}
