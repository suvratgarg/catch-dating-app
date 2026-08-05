import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/cross_paths/domain/cross_paths_feature_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cross_paths_feature_config_provider.g.dart';

// keepalive: Cross Paths flags are global rollout inputs fetched at startup.
@Riverpod(keepAlive: true)
CrossPathsFeatureConfig crossPathsFeatureConfig(Ref ref) {
  try {
    final remoteConfig = ref.watch(firebaseRemoteConfigProvider);
    return CrossPathsFeatureConfig(
      consentControlsEnabled: remoteConfig.getBool(
        CrossPathsFeatureConfig.enableConsentControlsKey,
      ),
      exploreSuggestionsEnabled: remoteConfig.getBool(
        CrossPathsFeatureConfig.enableExploreSuggestionsKey,
      ),
    );
  } on Object {
    // Firebase initialization and fetch errors must never expose an unfinished
    // people surface. Startup owns error logging; this read stays fail-closed.
    return CrossPathsFeatureConfig.disabled;
  }
}
