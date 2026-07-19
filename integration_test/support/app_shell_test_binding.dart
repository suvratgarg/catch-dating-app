import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Uses the fast headless binding for deterministic CI wrappers and opts into
/// the platform integration binding only for an explicitly selected device.
void ensureAppShellTestBinding() {
  if (const bool.fromEnvironment('APP_SHELL_NATIVE_INTEGRATION')) {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    return;
  }
  TestWidgetsFlutterBinding.ensureInitialized();
}
