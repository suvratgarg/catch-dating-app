import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/cross_paths/domain/cross_paths_feature_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cross_paths_feature_config_provider.g.dart';

// keepalive: Cross Paths flags are global rollout inputs fetched at startup.
@Riverpod(keepAlive: true)
CrossPathsFeatureConfig crossPathsFeatureConfig(Ref ref) {
  final previewEnabled = AppConfig.enableCrossPathsPreview;
  try {
    final remoteConfig = ref.watch(firebaseRemoteConfigProvider);
    return CrossPathsFeatureConfig(
      consentControlsEnabled:
          previewEnabled ||
          remoteConfig.getBool(
            CrossPathsFeatureConfig.enableConsentControlsKey,
          ),
      exploreSuggestionsEnabled:
          previewEnabled ||
          remoteConfig.getBool(
            CrossPathsFeatureConfig.enableExploreSuggestionsKey,
          ),
      pairInventoryEnabled: remoteConfig.getBool(
        CrossPathsFeatureConfig.enablePairInventoryKey,
      ),
    );
  } on Object {
    // Firebase initialization and fetch errors must never expose an unfinished
    // people surface. The only fallback is an explicit non-production debug
    // preview; release and production builds stay fail-closed.
    return previewEnabled
        ? const CrossPathsFeatureConfig(
            consentControlsEnabled: true,
            exploreSuggestionsEnabled: true,
          )
        : CrossPathsFeatureConfig.disabled;
  }
}
