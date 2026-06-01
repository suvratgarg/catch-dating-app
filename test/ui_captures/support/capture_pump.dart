import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'capture_device.dart';

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

class CaptureTheme {
  const CaptureTheme(this.name, this.brightness);

  final String name;
  final Brightness brightness;

  static const light = CaptureTheme('light', Brightness.light);
  static const dark = CaptureTheme('dark', Brightness.dark);
  static const all = <CaptureTheme>[light, dark];
}

class CaptureArtifact {
  const CaptureArtifact({
    required this.id,
    required this.theme,
    required this.file,
  });

  final String id;
  final CaptureTheme theme;
  final File file;
}

enum CaptureOutputLayout {
  captureFirst,
  themeFirst;

  static CaptureOutputLayout fromName(String name) => switch (name) {
    'capture-first' || '' => CaptureOutputLayout.captureFirst,
    'theme-first' => CaptureOutputLayout.themeFirst,
    _ => throw ArgumentError.value(
      name,
      'name',
      'Unknown capture output layout.',
    ),
  };
}

Future<List<CaptureArtifact>> captureCatchWidget(
  WidgetTester tester, {
  required String id,
  required WidgetBuilder builder,
  required Directory outputDirectory,
  CaptureDevice device = CaptureDevice.reviewPhone,
  double pixelRatio = 1.0,
  double textScale = 1.0,
  CaptureOutputLayout outputLayout = CaptureOutputLayout.captureFirst,
  List<CaptureTheme> themes = CaptureTheme.all,
  List<ImageProvider<Object>> precache = const <ImageProvider<Object>>[],
  Iterable providerOverrides = const [],
}) async {
  tester.view.devicePixelRatio = device.devicePixelRatio;
  tester.view.physicalSize = device.size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  if (precache.isNotEmpty) {
    await tester.runAsync(() async {
      for (final provider in precache) {
        await _warmImage(
          provider,
        ).timeout(const Duration(seconds: 2), onTimeout: () {});
      }
    });
  }

  final artifacts = <CaptureArtifact>[];

  for (final theme in themes) {
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      _frame(
        boundaryKey: boundaryKey,
        brightness: theme.brightness,
        textScale: textScale,
        device: device,
        builder: builder,
        providerOverrides: providerOverrides,
      ),
    );
    await _pumpCaptureFrame(tester);

    final file = _captureFile(
      outputDirectory: outputDirectory,
      id: id,
      theme: theme,
      layout: outputLayout,
    );
    await tester.runAsync(
      () => _writeBoundaryPng(boundaryKey, file, pixelRatio: pixelRatio),
    );
    artifacts.add(CaptureArtifact(id: id, theme: theme, file: file));
  }

  await tester.pump(const Duration(milliseconds: 50));
  return artifacts;
}

File _captureFile({
  required Directory outputDirectory,
  required String id,
  required CaptureTheme theme,
  required CaptureOutputLayout layout,
}) {
  return switch (layout) {
    CaptureOutputLayout.captureFirst => File(
      '${outputDirectory.path}/$id/${theme.name}.png',
    ),
    CaptureOutputLayout.themeFirst => File(
      '${outputDirectory.path}/${theme.name}/$id.png',
    ),
  };
}

Future<void> _pumpCaptureFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 250));
}

Future<void> _writeBoundaryPng(
  GlobalKey key,
  File file, {
  required double pixelRatio,
}) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  if (bytes == null) {
    throw StateError('Failed to encode ${file.path} as PNG.');
  }

  await file.create(recursive: true);
  await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
}

Widget _frame({
  required GlobalKey boundaryKey,
  required Brightness brightness,
  required double textScale,
  required CaptureDevice device,
  required WidgetBuilder builder,
  required Iterable providerOverrides,
}) {
  return ProviderScope(
    overrides: [...providerOverrides],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      home: RepaintBoundary(
        key: boundaryKey,
        child: Builder(
          builder: (context) => MediaQuery(
            data: _captureMediaQuery(
              MediaQuery.of(context),
              device: device,
              textScale: textScale,
            ),
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Builder(builder: builder),
            ),
          ),
        ),
      ),
    ),
  );
}

MediaQueryData _captureMediaQuery(
  MediaQueryData data, {
  required CaptureDevice device,
  required double textScale,
}) {
  return data.copyWith(
    padding: device.safeArea,
    viewPadding: device.safeArea,
    textScaler: TextScaler.linear(textScale),
  );
}
