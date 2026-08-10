import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/cross_paths/domain/cross_paths_feature_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cross_paths_feature_config_provider.g.dart';

// keepalive: Cross Paths operational switches are global inputs fetched once.
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
      pairInventoryEnabled: remoteConfig.getBool(
        CrossPathsFeatureConfig.enablePairInventoryKey,
      ),
    );
  } on Object {
    // Cross Paths is a shipped feature. A Remote Config outage must not turn
    // it back into a hidden work-in-progress surface. Server-owned event,
    // consent, showcase, admission, and safety checks remain authoritative.
    return CrossPathsFeatureConfig.live;
  }
}
