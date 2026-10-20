import 'dart:async';

import 'package:catch_dating_app/core/riverpod_ui/catch_notice_overlay.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/safety/presentation/settings_controller.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _DeletionController extends SettingsController {
  int requests = 0;
  final completion = Completer<void>();

  @override
  Future<void> requestAccountDeletion() {
    requests++;
    return completion.future;
  }
}

Future<void> _pump(WidgetTester tester, _DeletionController controller) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const HostClubsScaffold(
          clubs: [],
          currentUid: 'host-review-test',
          initialTab: HostClubTab.edit,
        ),
      ),
      GoRoute(
        path: Routes.startScreen.path,
        builder: (_, _) => const Text('Signed out after deletion'),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [settingsControllerProvider.overrideWith(() => controller)],
      child: MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        builder: (_, child) => CatchNoticeOverlay(child: child!),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openDeletion(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('host-account-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Delete account'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Host without an organizer can cancel account deletion', (
    tester,
  ) async {
    final controller = _DeletionController();
    await _pump(tester, controller);
    await _openDeletion(tester);
    expect(find.textContaining('Shared business records'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(controller.requests, 0);
    expect(find.byKey(const ValueKey('host-account-menu')), findsOneWidget);
  });

  testWidgets(
    'Host deletion requires confirmation and freezes account actions',
    (tester) async {
      final controller = _DeletionController();
      await _pump(tester, controller);
      await _openDeletion(tester);
      expect(controller.requests, 0);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(controller.requests, 1);
      expect(
        tester
            .widget<CatchActionMenu<String>>(
              find.byKey(const ValueKey('host-account-menu')),
            )
            .enabled,
        isFalse,
      );
      expect(
        tester
            .widget<CatchIconAction>(
              find.byKey(const ValueKey('host-organizer-sign-out')),
            )
            .onPressed,
        isNull,
      );
      controller.completion.complete();
      await tester.pumpAndSettle();
      expect(find.text('Signed out after deletion'), findsOneWidget);
    },
  );

  testWidgets('Failed Host deletion keeps the account screen available', (
    tester,
  ) async {
    final controller = _DeletionController();
    await _pump(tester, controller);
    await _openDeletion(tester);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    controller.completion.completeError(StateError('Deletion unavailable'));
    await tester.pumpAndSettle();
    expect(find.text('Signed out after deletion'), findsNothing);
    expect(
      tester
          .widget<CatchActionMenu<String>>(
            find.byKey(const ValueKey('host-account-menu')),
          )
          .enabled,
      isTrue,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
