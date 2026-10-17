import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('nested suite retains an intentional golden mismatch', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(460, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ColoredBox(color: Color(0xFFFF00FF)),
      ),
    );
    expect(tester.takeException(), isNull);
    try {
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('program_screens/program_trips.png'),
      );
    } catch (_) {
      final comparator = goldenFileComparator;
      if (comparator is LocalFileComparator) {
        for (final suffix in [
          'masterImage',
          'testImage',
          'isolatedDiff',
          'maskedDiff',
        ]) {
          final original = File.fromUri(
            comparator.basedir.resolve('failures/program_trips_$suffix.png'),
          );
          try {
            if (original.existsSync()) {
              original.copySync(
                File.fromUri(
                  comparator.basedir.resolve(
                    'failures/cat89_omitted_suite_$suffix.png',
                  ),
                ).path,
              );
            }
          } on FileSystemException catch (error) {
            stderr.writeln('CAT89 golden diagnostic copy failed: $error');
          }
        }
      }
      rethrow;
    }
  });
}
