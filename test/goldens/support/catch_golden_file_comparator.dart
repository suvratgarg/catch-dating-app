import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Keeps reviewed macOS goldens stable across hosted-runner rasterizers while
/// still failing material visual changes.
class CatchGoldenFileComparator extends LocalFileComparator {
  CatchGoldenFileComparator(
    super.testFile, {
    this.precisionTolerance = defaultPrecisionTolerance,
  }) : assert(
         0 <= precisionTolerance && precisionTolerance <= 1,
         'precisionTolerance must be between 0 and 1',
       );

  /// Flutter reports this as 0.30% in a golden failure message.
  static const double defaultPrecisionTolerance = 0.003;

  final double precisionTolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    final passed = result.passed || result.diffPercent <= precisionTolerance;
    if (passed) {
      result.dispose();
      return true;
    }

    final error = await generateFailureOutput(result, golden, basedir);
    final actualPercent = (result.diffPercent * 100).toStringAsFixed(4);
    final allowedPercent = (precisionTolerance * 100).toStringAsFixed(2);
    result.dispose();
    throw FlutterError(
      '$error\nCatch golden tolerance exceeded: '
      '$actualPercent% > $allowedPercent%.',
    );
  }
}
