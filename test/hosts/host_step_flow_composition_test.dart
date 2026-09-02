import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/host_club_editor_loading_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_route_loading_screen.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('club editor loading uses the canonical step-flow surface', (
    tester,
  ) async {
    await _pump(tester, const HostClubEditorLoadingScreen());

    expect(find.byType(CatchScreenScaffold), findsOneWidget);
    expect(find.text('Organizer basics'), findsOneWidget);
  });

  testWidgets('event editor loading uses the canonical step-flow surface', (
    tester,
  ) async {
    await _pump(tester, const HostCreateEventRouteLoadingScreen());

    expect(find.byType(CatchScreenScaffold), findsOneWidget);
    expect(find.text('Event basics'), findsOneWidget);
  });
}

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}
