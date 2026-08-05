/// Cross Paths feature public API.
///
/// Presentation consumers outside this feature must import this barrel instead
/// of reaching into Cross Paths presentation internals.
library;

export 'presentation/cross_paths_event_consent_section.dart'; // public-api: provider-free consent component embedded by Event Detail
export 'presentation/cross_paths_event_consent_state.dart'; // public-api: provider-free consent display state composed by Event Detail
