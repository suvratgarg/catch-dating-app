import 'package:catch_dating_app/runs/presentation/location_picker_screen.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'runs_test_helpers.dart';

void main() {
  group('LocationPickerScreen', () {
    test('stores the initial location argument', () {
      const initialLocation = LatLng(19.076, 72.8777);
      const screen = LocationPickerScreen(initialLocation: initialLocation);

      expect(screen.initialLocation, initialLocation);
    });

    testWidgets('starts without a selection', (tester) async {
      await pumpRunsTestApp(tester, const LocationPickerScreen());

      expect(find.text('Pick starting point'), findsOneWidget);
      expect(
        find.text('Tap on the map to set the starting point'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Confirm'))
            .onPressed,
        isNull,
      );
    });

    testWidgets('updates the selected point when the map callback fires', (
      tester,
    ) async {
      await pumpRunsTestApp(tester, const LocationPickerScreen());

      final flutterMap = tester.widget<FlutterMap>(find.byType(FlutterMap));
      const selectedPoint = LatLng(19.11, 72.91);
      flutterMap.options.onTap?.call(
        const TapPosition(Offset.zero, Offset.zero),
        selectedPoint,
      );
      await tester.pump();

      expect(find.text('19.110000, 72.910000'), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Confirm'))
            .onPressed,
        isNotNull,
      );
    });

    testWidgets(
      'uses the initial location and confirms it through navigation',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<LatLng?>(
                          builder: (_) => const LocationPickerScreen(
                            initialLocation: LatLng(19.076, 72.8777),
                          ),
                        ),
                      );
                    },
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('19.076000, 72.877700'), findsOneWidget);
        expect(
          tester
              .widget<TextButton>(find.widgetWithText(TextButton, 'Confirm'))
              .onPressed,
          isNotNull,
        );

        await tester.tap(find.widgetWithText(TextButton, 'Confirm'));
        await tester.pumpAndSettle();

        expect(find.text('Open'), findsOneWidget);
      },
    );
  });
}
