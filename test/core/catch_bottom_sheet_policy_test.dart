import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production sheets route through the Catch bottom-sheet presenter', () {
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path.replaceAll('\\', '/');
      if (path == 'lib/core/widgets/catch_bottom_sheet.dart') continue;

      final source = entity.readAsStringSync();
      if (source.contains('showModalBottomSheet')) {
        offenders.add(path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Use showCatchBottomSheet so sheets present above shell chrome.',
    );
  });
}
