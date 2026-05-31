import 'dart:async';

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// google_fonts cannot fetch in `flutter test` and throws "Failed to load font";
/// our FontLoader-registered files already render, so that throw is pure noise.
bool _isGoogleFontsFetchNoise(Object error) {
  final s = error.toString();
  return s.contains('Failed to load font') ||
      s.contains('allowRuntimeFetching') ||
      s.contains('google_fonts');
}

/// Decode an image fixture into the cache (no BuildContext needed). Done inside
/// `runAsync` BEFORE the guarded pump loop so photo goldens paint without
/// calling runAsync inside `runZonedGuarded` (which throws).
Future<void> _warmImage(ImageProvider<Object> provider) {
  final completer = Completer<void>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  void done() {
    stream.removeListener(listener);
    if (!completer.isCompleted) completer.complete();
  }

  listener = ImageStreamListener(
    (image, sync) => done(),
    onError: (error, stack) => done(),
  );
  stream.addListener(listener);
  return completer.future;
}

/// Pumps [builder] inside the real Catch theme on a fixed surface and asserts
/// the golden in BOTH light and dark: `baseline/<name>.light.png` and
/// `baseline/<name>.dark.png`. Use [textScale] for Dynamic-Type variants and
/// [precache] to warm image fixtures so photo-bearing goldens paint.
///
/// devicePixelRatio is pinned to 1.0 and the surface is fixed for crisp,
/// deterministic PNGs. Real failures (golden mismatch, layout/overflow errors)
/// are preserved and re-thrown; only google_fonts' offline-fetch noise is
/// suppressed.
Future<void> matchCatchGolden(
  WidgetTester tester,
  String name, {
  required WidgetBuilder builder,
  double textScale = 1.0,
  Size size = const Size(440, 1220),
  List<ImageProvider<Object>> precache = const <ImageProvider<Object>>[],
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  if (precache.isNotEmpty) {
    await tester.runAsync(() async {
      for (final provider in precache) {
        await _warmImage(provider);
      }
    });
  }

  Object? realFailure;
  StackTrace? realStack;

  await runZonedGuarded(
    () async {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(_frame(brightness, textScale, builder));
        await tester.pumpAndSettle();
        final mode = brightness == Brightness.light ? 'light' : 'dark';
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('baseline/$name.$mode.png'),
        );
      }
      // Flush late google_fonts load-failure microtasks into this guarded zone.
      await tester.pump(const Duration(milliseconds: 50));
    },
    (error, stack) {
      if (_isGoogleFontsFetchNoise(error)) return;
      realFailure ??= error;
      realStack ??= stack;
    },
  );

  if (realFailure != null) {
    Error.throwWithStackTrace(realFailure!, realStack ?? StackTrace.current);
  }
}

Widget _frame(Brightness brightness, double textScale, WidgetBuilder builder) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Builder(builder: builder),
        ),
      ),
    ),
  );
}
