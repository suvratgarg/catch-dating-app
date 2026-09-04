import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../test/goldens/support/catch_golden_file_comparator.dart';
import '../../test/support/catch_test_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The shared loader resolves bundled files from the app package root.
  final workspace = Directory.current;
  try {
    Directory.current = workspace.parent;
    await loadCatchTestFonts();
  } finally {
    Directory.current = workspace;
  }
  goldenFileComparator = CatchGoldenFileComparator(
    Uri.file('${workspace.parent.path}/test/goldens/flutter_test_config.dart'),
  );
  await testMain();
}
