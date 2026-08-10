/// Bundled defaults for the shipped consent-safe Cross Paths feature.
///
/// These keep the client surface available during a Remote Config outage.
/// Server-owned selected-event, layered-consent, showcase, admission, and
/// safety checks still decide whether any suggestion or invitation is legal.
const kCrossPathsConfigDefaults = <String, dynamic>{
  CrossPathsFeatureConfig.enableConsentControlsKey: true,
  CrossPathsFeatureConfig.enableExploreSuggestionsKey: true,
  CrossPathsFeatureConfig.enablePairInventoryKey: true,
};

class CrossPathsFeatureConfig {
  const CrossPathsFeatureConfig({
    required this.consentControlsEnabled,
    required this.exploreSuggestionsEnabled,
    this.pairInventoryEnabled = false,
  });

  static const enableConsentControlsKey = 'cross_paths_enable_consent_controls';
  static const enableExploreSuggestionsKey =
      'cross_paths_enable_explore_suggestions';
  static const enablePairInventoryKey = 'cross_paths_enable_pair_inventory';

  final bool consentControlsEnabled;
  final bool exploreSuggestionsEnabled;
  final bool pairInventoryEnabled;

  static const disabled = CrossPathsFeatureConfig(
    consentControlsEnabled: false,
    exploreSuggestionsEnabled: false,
  );

  static const live = CrossPathsFeatureConfig(
    consentControlsEnabled: true,
    exploreSuggestionsEnabled: true,
    pairInventoryEnabled: true,
  );
}
