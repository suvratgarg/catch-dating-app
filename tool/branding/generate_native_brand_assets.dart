import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as image;

const _tokenPath = 'design_context_pack/design_system/tokens.json';
const _baseIconPath = 'assets/branding/catch_icon.png';
const _hostIconPath = 'assets/branding/catch_hosts_icon.png';
const _generatedIconDir = 'assets/branding/generated';

const _androidIconSizes = <String, int>{
  'mipmap-mdpi': 48,
  'mipmap-hdpi': 72,
  'mipmap-xhdpi': 96,
  'mipmap-xxhdpi': 144,
  'mipmap-xxxhdpi': 192,
};

const _iconVariants = <String, _IconVariant>{
  'dev': _IconVariant(
    generatedName: 'catch_icon_dev.png',
    androidSourceSet: 'consumerDev',
    appleIconSet: 'AppIcon-dev',
    filenamePrefix: 'dev',
    ribbons: [_IconRibbon(label: 'DEV', fillToken: 'bg', labelToken: 'ink')],
  ),
  'staging': _IconVariant(
    generatedName: 'catch_icon_staging.png',
    androidSourceSet: 'consumerStaging',
    appleIconSet: 'AppIcon-staging',
    filenamePrefix: 'staging',
    ribbons: [
      _IconRibbon(label: 'STG', fillToken: 'warning', labelToken: 'ink'),
    ],
  ),
  'host-dev': _IconVariant(
    generatedName: 'catch_icon_host_dev.png',
    androidSourceSet: 'hostDev',
    appleIconSet: 'AppIcon-host-dev',
    filenamePrefix: 'host-dev',
    iconBase: _IconBase.host,
    ribbons: [_IconRibbon(label: 'DEV', fillToken: 'bg', labelToken: 'ink')],
  ),
  'host-staging': _IconVariant(
    generatedName: 'catch_icon_host_staging.png',
    androidSourceSet: 'hostStaging',
    appleIconSet: 'AppIcon-host-staging',
    filenamePrefix: 'host-staging',
    iconBase: _IconBase.host,
    ribbons: [
      _IconRibbon(label: 'STG', fillToken: 'warning', labelToken: 'ink'),
    ],
  ),
  'host-prod': _IconVariant(
    generatedName: 'catch_icon_host_prod.png',
    androidSourceSet: 'hostProd',
    appleIconSet: 'AppIcon-host-prod',
    filenamePrefix: 'host-prod',
    iconBase: _IconBase.host,
    ribbons: [],
  ),
};

void main() {
  final tokens = _NativeBrandTokens.load();
  final baseIcon = image.decodePng(File(_baseIconPath).readAsBytesSync());
  if (baseIcon == null) {
    throw StateError('Could not decode $_baseIconPath.');
  }
  final hostIcon = image.decodePng(File(_hostIconPath).readAsBytesSync());
  if (hostIcon == null) {
    throw StateError('Could not decode $_hostIconPath.');
  }

  _syncPubspecTokens(tokens);
  _writeNativeBrandManifest(tokens);

  for (final entry in _iconVariants.entries) {
    final variant = entry.value;
    final sourceIcon = switch (variant.iconBase) {
      _IconBase.consumer => baseIcon,
      _IconBase.host => hostIcon,
    };
    final icon = _buildVariantIcon(sourceIcon, variant, tokens);
    final generatedSourcePath = '$_generatedIconDir/${variant.generatedName}';
    _writePng(generatedSourcePath, icon);
    _writeAndroidIcons(variant.androidSourceSet, icon);
    _writeIosIconSet(variant, icon);
    _writeMacosIconSet(variant, icon);
  }

  _verifyPubspecTokens(tokens);
  stdout.writeln('Generated native flavor brand assets from $_tokenPath.');
}

image.Image _buildVariantIcon(
  image.Image baseIcon,
  _IconVariant variant,
  _NativeBrandTokens tokens,
) {
  final icon = baseIcon.convert(numChannels: 4);
  for (final ribbon in variant.ribbons) {
    _drawRibbon(icon, ribbon, tokens);
  }
  return icon;
}

void _drawRibbon(
  image.Image icon,
  _IconRibbon ribbon,
  _NativeBrandTokens tokens,
) {
  final ribbonFill = tokens.color(ribbon.fillToken, 'light');
  final ribbonInk = tokens.color(ribbon.labelToken, 'light');
  final shadow = image.ColorRgba8(0, 0, 0, 88);
  final size = math.min(icon.width, icon.height);
  final depth = (size * 0.29).round();
  final band = (size * 0.105).round();
  final shadowOffset = (size * 0.014).round();

  image.fillPolygon(
    icon,
    vertices: _topLeftRibbonVertices(depth + shadowOffset, band),
    color: shadow,
  );
  image.fillPolygon(
    icon,
    vertices: _topLeftRibbonVertices(depth, band),
    color: ribbonFill,
  );

  final labelLayer = image.Image(width: 220, height: 72, numChannels: 4);
  labelLayer.clear(image.ColorRgba8(0, 0, 0, 0));
  image.drawString(
    labelLayer,
    ribbon.label,
    font: image.arial48,
    color: ribbonInk,
  );
  final scaledLabel = image.copyResize(
    labelLayer,
    width: (size * 0.23).round(),
    height: (size * 0.076).round(),
    interpolation: image.Interpolation.cubic,
  );
  final label = image.copyRotate(
    scaledLabel,
    angle: -45,
    interpolation: image.Interpolation.cubic,
  );
  image.compositeImage(
    icon,
    label,
    dstX: (size * 0.075).round(),
    dstY: (size * 0.035).round(),
  );
}

List<image.Point> _topLeftRibbonVertices(int depth, int band) {
  return [
    image.Point(0, depth),
    image.Point(depth),
    image.Point(depth + band),
    image.Point(0, depth + band),
  ];
}

void _writeAndroidIcons(String sourceSet, image.Image source) {
  for (final entry in _androidIconSizes.entries) {
    final resized = image.copyResize(
      source,
      width: entry.value,
      height: entry.value,
      interpolation: image.Interpolation.cubic,
    );
    _writePng(
      'android/app/src/$sourceSet/res/${entry.key}/ic_launcher.png',
      resized,
    );
    _writePng(
      'android/app/src/$sourceSet/res/${entry.key}/ic_launcher_round.png',
      resized,
    );
  }
}

void _writeIosIconSet(_IconVariant variant, image.Image source) {
  final basePath = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
  final outputPath =
      'ios/Runner/Assets.xcassets/${variant.appleIconSet}.appiconset';
  final contents = _readJsonMap('$basePath/Contents.json');
  final images = contents['images'] as List<dynamic>;

  for (final item in images.cast<Map<String, dynamic>>()) {
    final filename = item['filename'] as String?;
    if (filename == null) continue;
    final outputFilename = filename.replaceFirst(
      'Icon-App-',
      'Icon-App-${variant.filenamePrefix}-',
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

void _writeMacosIconSet(_IconVariant variant, image.Image source) {
  final basePath = 'macos/Runner/Assets.xcassets/AppIcon.appiconset';
  final outputPath =
      'macos/Runner/Assets.xcassets/${variant.appleIconSet}.appiconset';
  final contents = _readJsonMap('$basePath/Contents.json');
  final images = contents['images'] as List<dynamic>;

  for (final item in images.cast<Map<String, dynamic>>()) {
    final filename = item['filename'] as String?;
    if (filename == null) continue;
    final outputFilename = filename.replaceFirst(
      'app_icon_',
      'app_icon_${variant.filenamePrefix}_',
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
      'dev_ribbon': tokens.colorHex('bg', 'light'),
      'staging_ribbon': tokens.colorHex('warning', 'light'),
      'ribbon_ink': tokens.colorHex('ink', 'light'),
    },
    'generated': [
      _hostIconPath,
      for (final variant in _iconVariants.values)
        'assets/branding/generated/${variant.generatedName}',
      for (final variant in _iconVariants.values)
        'android/app/src/${variant.androidSourceSet}/res/**/ic_launcher.png',
      for (final variant in _iconVariants.values)
        'android/app/src/${variant.androidSourceSet}/res/**/ic_launcher_round.png',
      for (final variant in _iconVariants.values)
        'ios/Runner/Assets.xcassets/${variant.appleIconSet}.appiconset',
      for (final variant in _iconVariants.values)
        'macos/Runner/Assets.xcassets/${variant.appleIconSet}.appiconset',
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

class _IconVariant {
  const _IconVariant({
    required this.generatedName,
    required this.androidSourceSet,
    required this.appleIconSet,
    required this.filenamePrefix,
    required this.ribbons,
    this.iconBase = _IconBase.consumer,
  });

  final String generatedName;
  final String androidSourceSet;
  final String appleIconSet;
  final String filenamePrefix;
  final List<_IconRibbon> ribbons;
  final _IconBase iconBase;
}

enum _IconBase { consumer, host }

class _IconRibbon {
  const _IconRibbon({
    required this.label,
    required this.fillToken,
    required this.labelToken,
  });

  final String label;
  final String fillToken;
  final String labelToken;
}
