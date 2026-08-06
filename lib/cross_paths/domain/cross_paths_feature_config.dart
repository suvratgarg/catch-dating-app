/// Remote Config defaults for the consent-safe Cross Paths rollout.
///
/// Both controls fail closed. The consent UI can be reviewed independently,
/// while Explore identities remain disabled until a server-owned suggestion
/// response exists.
const kCrossPathsConfigDefaults = <String, dynamic>{
  CrossPathsFeatureConfig.enableConsentControlsKey: false,
  CrossPathsFeatureConfig.enableExploreSuggestionsKey: false,
  CrossPathsFeatureConfig.enablePairInventoryKey: false,
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
}
