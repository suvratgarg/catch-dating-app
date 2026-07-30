import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

void main() {
  test(
    'Host wordmarks use the locked Archivo axes and singular product name',
    () {
      final generator = File(
        'tool/branding/generate_catch_icon.swift',
      ).readAsStringSync();

      expect(generator, contains('private let archivoWidth: CGFloat = 78'));
      expect(generator, contains('private let archivoWeight: CGFloat = 600'));
      expect(
        generator,
        contains(
          'private func hostFont(size: CGFloat) -> NSFont {\n'
          '  consumerWordmarkFont(size: size)\n'
          '}',
        ),
      );
      expect(generator, contains('string: "Host"'));
      expect(generator, isNot(contains('string: "Hosts"')));
      expect(generator, isNot(contains('NSFont.systemFont')));
    },
  );

  test('Host splash masters remain transparent and unclipped', () {
    for (final path in const [
      'assets/branding/catch_host_splash_mark_light.png',
      'assets/branding/catch_host_splash_mark_dark.png',
    ]) {
      final decoded = image.decodePng(File(path).readAsBytesSync());
      expect(decoded, isNotNull, reason: path);
      expect(decoded!.width, 1024, reason: path);
      expect(decoded.height, 1024, reason: path);

      final bounds = _alphaBounds(decoded);
      expect(bounds.minX, greaterThan(0), reason: path);
      expect(bounds.minY, greaterThan(0), reason: path);
      expect(bounds.maxX, lessThan(decoded.width - 1), reason: path);
      expect(bounds.maxY, lessThan(decoded.height - 1), reason: path);
    }
  });

  test(
    'Host installable target receives generated icons and splash assets',
    () {
      final manifest = File(
        'tool/branding/native_branding.generated.json',
      ).readAsStringSync();
      expect(
        manifest,
        contains('assets/branding/catch_host_splash_mark_light.png'),
      );
      expect(
        manifest,
        contains('assets/branding/catch_host_splash_mark_dark.png'),
      );
      expect(
        manifest,
        contains(
          'apps/host/ios/Runner/Assets.xcassets/'
          'AppIcon-host-prod.appiconset',
        ),
      );
      expect(
        manifest,
        contains('apps/host/android/app/src/main/res/**/splash.png'),
      );

      _expectPngSize(
        'apps/host/ios/Runner/Assets.xcassets/'
        'AppIcon-host-prod.appiconset/Icon-App-host-prod-1024x1024@1x.png',
        1024,
      );
      _expectPngSize(
        'apps/host/ios/Runner/Assets.xcassets/'
        'LaunchImage.imageset/LaunchImage@3x.png',
        768,
      );
      _expectPngSize(
        'apps/host/android/app/src/hostProd/res/'
        'mipmap-xxxhdpi/ic_launcher.png',
        192,
      );
      _expectPngSize(
        'apps/host/android/app/src/main/res/'
        'drawable-xxxhdpi/android12splash.png',
        1024,
      );
    },
  );
}

({int minX, int minY, int maxX, int maxY}) _alphaBounds(image.Image source) {
  var minX = source.width;
  var minY = source.height;
  var maxX = -1;
  var maxY = -1;

  for (final pixel in source) {
    if (pixel.a == 0) continue;
    if (pixel.x < minX) minX = pixel.x;
    if (pixel.y < minY) minY = pixel.y;
    if (pixel.x > maxX) maxX = pixel.x;
    if (pixel.y > maxY) maxY = pixel.y;
  }

  expect(maxX, greaterThanOrEqualTo(0));
  expect(maxY, greaterThanOrEqualTo(0));
  return (minX: minX, minY: minY, maxX: maxX, maxY: maxY);
}

void _expectPngSize(String path, int expected) {
  final bytes = Uint8List.fromList(File(path).readAsBytesSync());
  final decoded = image.decodePng(bytes);
  expect(decoded, isNotNull, reason: path);
  expect(decoded!.width, expected, reason: path);
  expect(decoded.height, expected, reason: path);
}
