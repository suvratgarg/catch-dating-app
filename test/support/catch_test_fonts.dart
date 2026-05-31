import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the app text fonts plus icon fonts for visual tests.
///
/// Flutter widget tests do not automatically register bundled icon fonts, so
/// [Icon] falls back to missing-glyph boxes unless we load Material Icons and
/// package icon fonts explicitly.
Future<void> loadCatchTestFonts() async {
  final loaders = <FontLoader>[
    FontLoader('Newsreader')
      ..addFont(_bytes('assets/fonts/Newsreader-Roman-VF.ttf'))
      ..addFont(_bytes('assets/fonts/Newsreader-Italic-VF.ttf')),
    FontLoader('Inter')..addFont(_bytes('assets/fonts/Inter-Roman-VF.ttf')),
    FontLoader('IBM Plex Mono')
      ..addFont(_bytes('assets/fonts/IBMPlexMono-Regular.ttf'))
      ..addFont(_bytes('assets/fonts/IBMPlexMono-Medium.ttf'))
      ..addFont(_bytes('assets/fonts/IBMPlexMono-SemiBold.ttf'))
      ..addFont(_bytes('assets/fonts/IBMPlexMono-Bold.ttf')),
    FontLoader('MaterialIcons')..addFont(_fileBytes(_materialIconsFont())),
  ];

  final phosphorRoot = _packageRoot('phosphor_flutter');
  for (final spec in _phosphorFonts) {
    final fontFile = File('${phosphorRoot.path}/${spec.path}');
    if (!fontFile.existsSync()) {
      throw StateError('Missing Phosphor test font: ${fontFile.path}');
    }

    // TextStyle(package: ...) resolves the family to packages/<pkg>/<family>.
    loaders
      ..add(FontLoader(spec.family)..addFont(_fileBytes(fontFile)))
      ..add(
        FontLoader('packages/phosphor_flutter/${spec.family}')
          ..addFont(_fileBytes(fontFile)),
      );
  }

  await Future.wait([for (final loader in loaders) loader.load()]);
}

Future<ByteData> _bytes(String path) =>
    File(path).readAsBytes().then(ByteData.sublistView);

Future<ByteData> _fileBytes(File file) =>
    file.readAsBytes().then(ByteData.sublistView);

File _materialIconsFont() {
  for (final candidate in _materialIconFontCandidates()) {
    if (candidate.existsSync()) return candidate;
  }
  throw StateError(
    'Unable to locate MaterialIcons-Regular.otf. Set FLUTTER_ROOT or run with '
    'a Flutter SDK that has material font artifacts.',
  );
}

Iterable<File> _materialIconFontCandidates() sync* {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null && flutterRoot.isNotEmpty) {
    yield File(
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
  }

  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 8; i += 1) {
    yield File(
      '${dir.path}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }

  yield File('build/unit_test_assets/fonts/MaterialIcons-Regular.otf');
  yield File('build/flutter_assets/fonts/MaterialIcons-Regular.otf');
}

Directory _packageRoot(String packageName) {
  final configFile = File('.dart_tool/package_config.json');
  if (!configFile.existsSync()) {
    throw StateError('Missing .dart_tool/package_config.json.');
  }

  final config =
      jsonDecode(configFile.readAsStringSync()) as Map<String, Object?>;
  final packages = (config['packages'] as List<Object?>)
      .cast<Map<String, Object?>>();
  final package = packages.where((entry) => entry['name'] == packageName).first;
  final rootUri = Uri.parse(package['rootUri']! as String);
  final resolved = rootUri.hasScheme
      ? rootUri
      : configFile.parent.uri.resolveUri(rootUri);
  return Directory.fromUri(resolved);
}

class _PackageFontSpec {
  const _PackageFontSpec(this.family, this.path);

  final String family;
  final String path;
}

const _phosphorFonts = <_PackageFontSpec>[
  _PackageFontSpec('PhosphorBold', 'lib/fonts/Phosphor-Bold.ttf'),
  _PackageFontSpec('PhosphorDuotone', 'lib/fonts/Phosphor-Duotone.ttf'),
  _PackageFontSpec('PhosphorFill', 'lib/fonts/Phosphor-Fill.ttf'),
  _PackageFontSpec('PhosphorLight', 'lib/fonts/Phosphor-Light.ttf'),
  _PackageFontSpec('PhosphorRegular', 'lib/fonts/Phosphor.ttf'),
  _PackageFontSpec('PhosphorThin', 'lib/fonts/Phosphor-Thin.ttf'),
];
