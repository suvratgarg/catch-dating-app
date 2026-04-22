import 'package:catch_dating_app/force_update/data/app_version_repository.dart';
import 'package:catch_dating_app/force_update/domain/version.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'force_update_provider.g.dart';

/// The current app version string (e.g. "1.2.3") from the platform.
@Riverpod(keepAlive: true)
Future<String> currentAppVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
}

/// True when the running version is below the remote [minVersion].
///
/// Returns false while either value is loading so the UI is never blocked
/// by a transient loading state.
@Riverpod(keepAlive: true)
bool forceUpdateRequired(Ref ref) {
  final configAsync = ref.watch(watchAppVersionConfigProvider);
  final versionAsync = ref.watch(currentAppVersionProvider);

  final config = configAsync.asData?.value;
  final current = versionAsync.asData?.value;

  if (config == null || current == null) return false;

  return isUpdateRequired(current: current, minimum: config.minVersion);
}
