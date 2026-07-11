import 'package:catch_dating_app/app_bootstrap.dart';
import 'package:catch_dating_app/core/app_config.dart';

Future<void> main() {
  return runCatchApp(
    appRole: AppRole.consumer,
    environment: AppEnvironment.prod,
  );
}
