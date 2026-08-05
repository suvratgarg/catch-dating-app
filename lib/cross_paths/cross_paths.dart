/// Cross Paths feature public API.
///
/// Presentation consumers outside this feature must import this barrel instead
/// of reaching into Cross Paths presentation internals.
library;

export 'data/cross_paths_feature_config_provider.dart'; // public-api: fail-closed rollout configuration
export 'data/cross_paths_repository.dart'; // public-api: feature-owned callable seam
export 'domain/cross_paths_feature_config.dart'; // public-api: rollout state consumed by Explore enrichment
export 'domain/cross_paths_suggestion.dart'; // public-api: sanitized suggestion projection
export 'presentation/cross_paths_event_consent_section.dart'; // public-api: provider-free consent component embedded by Event Detail
export 'presentation/cross_paths_event_consent_state.dart'; // public-api: provider-free consent display state composed by Event Detail
export 'presentation/cross_paths_explore_card.dart'; // public-api: Explore person card and event-tied profile preview
