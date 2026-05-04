import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/calendar/presentation/calendar_screen.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/presentation/run_map_screen.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Future<void> pumpTopLevelRoute(
    WidgetTester tester, {
    required String path,
    required Widget child,
  }) async {
    final router = GoRouter(
      initialLocation: Routes.dashboardScreen.path,
      routes: [
        GoRoute(
          path: Routes.dashboardScreen.path,
          builder: (context, _) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => context.push(path),
                child: const Text('Open destination'),
              ),
            ),
          ),
        ),
        GoRoute(path: path, builder: (_, _) => child),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value(null)),
          watchUserProfileProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open destination'));
    await tester.pumpAndSettle();
  }

  testWidgets('calendar back button returns to dashboard', (tester) async {
    await pumpTopLevelRoute(
      tester,
      path: Routes.calendarScreen.path,
      child: const CalendarScreen(),
    );

    expect(find.text('Calendar'), findsWidgets);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Open destination'), findsOneWidget);
  });

  testWidgets('map back button returns to dashboard', (tester) async {
    await pumpTopLevelRoute(
      tester,
      path: Routes.runMapScreen.path,
      child: const RunMapScreen(enableNetworkTiles: false),
    );

    expect(find.text('Map view'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Open destination'), findsOneWidget);
  });
}
