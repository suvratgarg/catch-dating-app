import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_picker.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';

void main() {
  testWidgets('date picker uses Cupertino chrome on iOS', (tester) async {
    await _withIosPlatform(() async {
      DateTime? picked;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                picked = await showCatchDatePicker(
                  context: context,
                  initialDate: DateTime(2026, 5, 12),
                  firstDate: DateTime(2026, 5, 1),
                  lastDate: DateTime(2026, 5, 31),
                  title: 'Run date',
                );
              },
              child: const Text('Open date picker'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open date picker'));
      await pumpFeatureUi(tester);

      expect(find.byType(CupertinoDatePicker), findsOneWidget);
      expect(find.text('Run date'), findsOneWidget);
      expect(find.text('OK'), findsNothing);

      await tester.tap(find.text('Done'));
      await pumpFeatureUi(tester);

      expect(picked, DateTime(2026, 5, 12));
    });
  });

  testWidgets('time picker uses Cupertino chrome on iOS', (tester) async {
    await _withIosPlatform(() async {
      TimeOfDay? picked;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                picked = await showCatchTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 7, minute: 30),
                  title: 'Start time',
                );
              },
              child: const Text('Open time picker'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open time picker'));
      await pumpFeatureUi(tester);

      expect(find.byType(CupertinoDatePicker), findsOneWidget);
      expect(find.text('Start time'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_outlined), findsNothing);

      await tester.tap(find.text('Done'));
      await pumpFeatureUi(tester);

      expect(picked, const TimeOfDay(hour: 7, minute: 30));
    });
  });

  testWidgets('adaptive dialog uses Cupertino alerts on iOS', (tester) async {
    await _withIosPlatform(() async {
      bool? result;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showCatchAdaptiveDialog<bool>(
                  context: context,
                  title: 'Delete draft?',
                  message: 'This will permanently delete the draft.',
                  actions: const [
                    CatchDialogAction(label: 'Cancel', value: false),
                    CatchDialogAction(
                      label: 'Delete',
                      value: true,
                      isDestructive: true,
                    ),
                  ],
                );
              },
              child: const Text('Open dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open dialog'));
      await pumpFeatureUi(tester);

      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      await tester.tap(find.text('Delete'));
      await pumpFeatureUi(tester);

      expect(result, isTrue);
    });
  });

  testWidgets('top bar tabs use a Cupertino segmented control on iOS', (
    tester,
  ) async {
    await _withIosPlatform(() async {
      final controller = TabController(length: 2, vsync: tester);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          CatchTopBarTabBar(
            controller: controller,
            tabs: const [
              Tab(text: 'Dashboard'),
              Tab(text: 'Activity'),
            ],
          ),
        ),
      );

      expect(
        find.byType(CupertinoSlidingSegmentedControl<int>),
        findsOneWidget,
      );
      expect(find.byType(TabBar), findsNothing);

      await tester.tap(find.text('Activity'));
      await pumpFeatureUi(tester);

      expect(controller.index, 1);
    });
  });
}

Future<void> _withIosPlatform(Future<void> Function() body) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: Center(child: child)),
  );
}
