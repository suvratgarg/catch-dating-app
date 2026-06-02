import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as image;

const _tokenPath = 'design_context_pack/design_system/tokens.json';
const _baseIconPath = 'assets/branding/catch_icon.png';
const _generatedIconDir = 'assets/branding/generated';

const _androidIconSizes = <String, int>{
  'mipmap-mdpi': 48,
  'mipmap-hdpi': 72,
  'mipmap-xhdpi': 96,
  'mipmap-xxhdpi': 144,
  'mipmap-xxxhdpi': 192,
};

const _flavorBadges = <String, _FlavorBadge>{
  'dev': _FlavorBadge(label: 'D', fillToken: 'ink'),
  'staging': _FlavorBadge(label: 'S', fillToken: 'warning'),
};

void main() {
  final tokens = _NativeBrandTokens.load();
  final baseIcon = image.decodePng(File(_baseIconPath).readAsBytesSync());
  if (baseIcon == null) {
    throw StateError('Could not decode $_baseIconPath.');
  }

  _syncPubspecTokens(tokens);
  _writeNativeBrandManifest(tokens);

  for (final entry in _flavorBadges.entries) {
    final flavor = entry.key;
    final badge = entry.value;
    final icon = _buildFlavorIcon(baseIcon, badge, tokens);
    final generatedSourcePath = '$_generatedIconDir/catch_icon_$flavor.png';
    _writePng(generatedSourcePath, icon);
    _writeAndroidFlavorIcons(flavor, icon);
    _writeIosFlavorIconSet(flavor, icon);
    _writeMacosFlavorIconSet(flavor, icon);
  }

  _verifyPubspecTokens(tokens);
  stdout.writeln('Generated native flavor brand assets from $_tokenPath.');
}

image.Image _buildFlavorIcon(
  image.Image baseIcon,
  _FlavorBadge badge,
  _NativeBrandTokens tokens,
) {
  final icon = baseIcon.convert(numChannels: 4);
  final badgeFill = tokens.color(badge.fillToken, 'light');
  final badgeInk = tokens.color('primaryInk', 'light');
  final badgeRing = tokens.color('bg', 'light');
  final shadow = image.ColorRgba8(0, 0, 0, 88);
  final size = math.min(icon.width, icon.height);
  final radius = (size * 0.205).round();
  final ring = (size * 0.027).round();
  final margin = (size * 0.076).round();
  final center = size - margin - radius;

  image.fillCircle(
    icon,
    x: center + (size * 0.012).round(),
    y: center + (size * 0.018).round(),
    radius: radius + ring,
    color: shadow,
    antialias: true,
  );
  image.fillCircle(
    icon,
    x: center,
    y: center,
    radius: radius + ring,
    color: badgeRing,
    antialias: true,
  );
  image.fillCircle(
    icon,
    x: center,
    y: center,
    radius: radius,
    color: badgeFill,
    antialias: true,
  );

  final labelLayer = image.Image(width: 64, height: 64, numChannels: 4);
  image.drawString(
    labelLayer,
    badge.label,
    font: image.arial48,
    color: badgeInk,
  );
  final labelSize = (radius * 1.18).round();
  final label = image.copyResize(
    labelLayer,
    width: labelSize,
    height: labelSize,
    interpolation: image.Interpolation.cubic,
  );
  image.compositeImage(
    icon,
    label,
    dstX: center - label.width ~/ 2,
    dstY: center - label.height ~/ 2,
  );

  return icon;
}

void _writeAndroidFlavorIcons(String flavor, image.Image source) {
  for (final entry in _androidIconSizes.entries) {
    final resized = image.copyResize(
      source,
      width: entry.value,
      height: entry.value,
      interpolation: image.Interpolation.cubic,
    );
    _writePng(
      'android/app/src/$flavor/res/${entry.key}/ic_launcher.png',
      resized,
    );
  }
}

void _writeIosFlavorIconSet(String flavor, image.Image source) {
  final basePath = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
  final outputPath = 'ios/Runner/Assets.xcassets/AppIcon-$flavor.appiconset';
  final contents = _readJsonMap('$basePath/Contents.json');
  final images = contents['images'] as List<dynamic>;

  for (final item in images.cast<Map<String, dynamic>>()) {
    final filename = item['filename'] as String?;
    if (filename == null) continue;
    final outputFilename = filename.replaceFirst(
      'Icon-App-',
      'Icon-App-$flavor-',
    );
    item['filename'] = outputFilename;
    final pixelSize = _applePixelSize(item);
    _writePng(
      '$outputPath/$outputFilename',
      image.copyResize(
        source,
        width: pixelSize,
        height: pixelSize,
        interpolation: image.Interpolation.cubic,
      ),
    );
  }

  _writeJson('$outputPath/Contents.json', contents);
}

void _writeMacosFlavorIconSet(String flavor, image.Image source) {
  final basePath = 'macos/Runner/Assets.xcassets/AppIcon.appiconset';
  final outputPath = 'macos/Runner/Assets.xcassets/AppIcon-$flavor.appiconset';
  final contents = _readJsonMap('$basePath/Contents.json');
  final images = contents['images'] as List<dynamic>;

  for (final item in images.cast<Map<String, dynamic>>()) {
    final filename = item['filename'] as String?;
    if (filename == null) continue;
    final outputFilename = filename.replaceFirst(
      'app_icon_',
      'app_icon_${flavor}_',
    );
    item['filename'] = outputFilename;
    final pixelSize = _applePixelSize(item);
    _writePng(
      '$outputPath/$outputFilename',
      image.copyResize(
        source,
        width: pixelSize,
        height: pixelSize,
        interpolation: image.Interpolation.cubic,
      ),
    );
  }

  _writeJson('$outputPath/Contents.json', contents);
}

int _applePixelSize(Map<String, dynamic> item) {
  final logicalSize = (item['size'] as String).split('x').first;
  final scale = (item['scale'] as String).replaceAll('x', '');
  return (double.parse(logicalSize) * double.parse(scale)).round();
}

void _writeNativeBrandManifest(_NativeBrandTokens tokens) {
  _writeJson('tool/branding/native_branding.generated.json', {
    'source': _tokenPath,
    'colors': {
      'splash_light_bg': tokens.colorHex('bg', 'light'),
      'splash_dark_bg': tokens.colorHex('bg', 'dark'),
      'web_theme': tokens.colorHex('ink', 'light'),
      'dev_badge': tokens.colorHex('ink', 'light'),
      'staging_badge': tokens.colorHex('warning', 'light'),
      'badge_ink': tokens.colorHex('primaryInk', 'light'),
    },
    'generated': [
      'assets/branding/generated/catch_icon_dev.png',
      'assets/branding/generated/catch_icon_staging.png',
      'android/app/src/dev/res/**/ic_launcher.png',
      'android/app/src/staging/res/**/ic_launcher.png',
      'ios/Runner/Assets.xcassets/AppIcon-dev.appiconset',
      'ios/Runner/Assets.xcassets/AppIcon-staging.appiconset',
      'macos/Runner/Assets.xcassets/AppIcon-dev.appiconset',
      'macos/Runner/Assets.xcassets/AppIcon-staging.appiconset',
    ],
  });
}

void _syncPubspecTokens(_NativeBrandTokens tokens) {
  final file = File('pubspec.yaml');
  final webTheme = tokens.colorHex('ink', 'light');
  final splashLight = tokens.colorHex('bg', 'light');
  final splashDark = tokens.colorHex('bg', 'dark');
  var pubspec = file.readAsStringSync();

  pubspec = _replaceRequiredLine(
    pubspec,
    RegExp(r'^    background_color: .+$', multiLine: true),
    '    background_color: "$webTheme"',
  );
  pubspec = _replaceRequiredLine(
    pubspec,
    RegExp(r'^    theme_color: .+$', multiLine: true),
    '    theme_color: "$webTheme"',
  );
  pubspec = _replaceRequiredLine(
    pubspec,
    RegExp(r'^  color: .+$', multiLine: true),
    '  color: "$splashLight"',
  );
  pubspec = _replaceRequiredLine(
    pubspec,
    RegExp(r'^  color_web: .+$', multiLine: true),
    '  color_web: "$splashLight"',
  );
  pubspec = _replaceRequiredLine(
    pubspec,
    RegExp(r'^  color_dark: .+$', multiLine: true),
    '  color_dark: "$splashDark"',
  );
  pubspec = _replaceRequiredLine(
    pubspec,
    RegExp(r'^  color_dark_web: .+$', multiLine: true),
    '  color_dark_web: "$splashDark"',
  );
  pubspec = _replaceRequiredLine(
    pubspec,
    RegExp(r'^    color: .+$', multiLine: true),
    '    color: "$splashLight"',
  );
  pubspec = _replaceRequiredLine(
    pubspec,
    RegExp(r'^    color_dark: .+$', multiLine: true),
    '    color_dark: "$splashDark"',
  );

  file.writeAsStringSync(pubspec);
}

String _replaceRequiredLine(String source, RegExp pattern, String replacement) {
  final matches = pattern.allMatches(source).length;
  if (matches != 1) {
    throw StateError(
      'Expected one pubspec.yaml match for ${pattern.pattern}, found $matches.',
    );
  }
  return source.replaceAll(pattern, replacement);
}

void _verifyPubspecTokens(_NativeBrandTokens tokens) {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final expected = <String>[
    "background_color: \"${tokens.colorHex('ink', 'light')}\"",
    "theme_color: \"${tokens.colorHex('ink', 'light')}\"",
    "color: \"${tokens.colorHex('bg', 'light')}\"",
    "color_web: \"${tokens.colorHex('bg', 'light')}\"",
    "color_dark: \"${tokens.colorHex('bg', 'dark')}\"",
    "color_dark_web: \"${tokens.colorHex('bg', 'dark')}\"",
  ];
  final missing = expected.where((line) => !pubspec.contains(line)).toList();
  if (missing.isNotEmpty) {
    throw StateError(
      'pubspec.yaml is not aligned with $_tokenPath:\n${missing.join('\n')}',
    );
  }
}

Map<String, dynamic> _readJsonMap(String path) {
  return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
}

void _writeJson(String path, Object value) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(value)}\n',
  );
}

void _writePng(String path, image.Image icon) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(image.encodePng(icon));
}

class _NativeBrandTokens {
  const _NativeBrandTokens(this._tokens);

  final Map<String, dynamic> _tokens;

  static _NativeBrandTokens load() {
    final file = File(_tokenPath);
    if (!file.existsSync()) {
      throw StateError(
        'Missing native brand token cache: $_tokenPath. '
        'Regenerate the design context pack before native brand assets.',
      );
    }
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return _NativeBrandTokens(json);
  }

  image.Color color(String name, String mode) {
    final hex = colorHex(name, mode).replaceFirst('#', '');
    final value = int.parse(hex, radix: 16);
    return image.ColorRgb8(
      (value >> 16) & 0xff,
      (value >> 8) & 0xff,
      value & 0xff,
    );
  }

  String colorHex(String name, String mode) {
    final color =
        (((_tokens['color'] as Map<String, dynamic>)[name]
                    as Map<String, dynamic>)['\$value']
                as Map<String, dynamic>)[mode]
            as String;
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(color)) {
      throw StateError('Token color.$name.$mode must be a #RRGGBB color.');
    }
    return color.toUpperCase();
  }
}

class _FlavorBadge {
  const _FlavorBadge({required this.label, required this.fillToken});

  final String label;
  final String fillToken;
}
