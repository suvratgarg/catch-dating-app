import 'dart:async';

import 'package:catch_dating_app/core/riverpod_ui/catch_error_snack_bar.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';

void main() {
  testWidgets('snackbar preserves explicit recovery for permission errors', (
    tester,
  ) async {
    var recovered = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: CatchTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showCatchErrorSnackBar(
                context,
                const PermissionException('Raw permission diagnostic.'),
                onRetry: () => recovered++,
              ),
              child: const Text('Show failure'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Show failure'));
    await pumpFeatureUi(tester);
    expect(find.text('Raw permission diagnostic.'), findsNothing);
    await tester.tap(find.text('Try again'));
    expect(recovered, 1);
  });
  testWidgets(
    'subscriptions follow distinct handles and active build branches',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final family = Mutation<void>();
      final first = family('first');
      final second = family('second');
      final unrelated = family('unrelated');
      final enabled = ValueNotifier(true);
      addTearDown(enabled.dispose);
      final version = ValueNotifier(0);
      addTearDown(version.dispose);
      final messenger = GlobalKey<ScaffoldMessengerState>();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: CatchTheme.light,
            scaffoldMessengerKey: messenger,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ListenableBuilder(
              listenable: Listenable.merge([enabled, version]),
              builder: (context, _) => Consumer(
                builder: (context, ref, _) {
                  if (enabled.value) {
                    listenToCatchMutationErrors(
                      context,
                      ref,
                      mutations: [first, first, second],
                    );
                  }
                  return Scaffold(
                    body: Text('Parent version ${version.value}'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      Future<void> fail(Mutation<void> mutation) => mutation
          .run(
            container,
            (_) async => throw StateError('Raw mutation failure.'),
          )
          .catchError((_) {});
      await fail(unrelated);
      await pumpFeatureUi(tester);
      expect(find.byType(SnackBar), findsNothing);
      await first.run(container, (_) async {});
      first.reset(container);
      await pumpFeatureUi(tester);
      expect(find.byType(SnackBar), findsNothing);
      await fail(first);
      await pumpFeatureUi(tester);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(SnackBarAction), findsNothing);
      expect(find.text('Raw mutation failure.'), findsNothing);
      messenger.currentState!.removeCurrentSnackBar();
      await pumpFeatureUi(tester);
      expect(
        find.byType(SnackBar),
        findsNothing,
        reason: 'The duplicate handle must not queue a second notification.',
      );
      version.value++;
      await tester.pump();
      expect(
        find.byType(SnackBar),
        findsNothing,
        reason: 'Rebuilding must not replay the current error.',
      );
      await fail(second);
      await pumpFeatureUi(tester);
      expect(find.byType(SnackBar), findsOneWidget);
      messenger.currentState!.removeCurrentSnackBar();
      await pumpFeatureUi(tester);
      enabled.value = false;
      await tester.pump();
      await fail(first);
      await pumpFeatureUi(tester);
      expect(
        find.byType(SnackBar),
        findsNothing,
        reason: 'Leaving the owning branch must cancel its subscriptions.',
      );
      enabled.value = true;
      await tester.pump();
      expect(find.byType(SnackBar), findsNothing);
      await fail(first);
      await pumpFeatureUi(tester);
      expect(find.byType(SnackBar), findsOneWidget);
      messenger.currentState!.removeCurrentSnackBar();
      await pumpFeatureUi(tester);
      final completion = Completer<void>();
      final pending = first
          .run(container, (_) => completion.future)
          .catchError((_) {});
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      completion.completeError(StateError('Completed after route disposal.'));
      await pending;
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
