/// User Profile feature — public API barrel.
///
/// Prefer importing this barrel over individual files so internal reorg stays
/// invisible to the ~20 external consumers across 10 features.
///
library;

/// ## Data
export 'data/user_profile_repository.dart';

/// ## Domain
export 'domain/profile_photo.dart';
export 'domain/profile_photo_policy.dart';
export 'domain/profile_prompts.dart';
export 'domain/profile_readiness.dart';
export 'domain/profile_validation.dart';
export 'domain/user_profile.dart';

/// ## Presentation (screens and shared widgets)
export 'presentation/profile_edit_controller.dart'; // public-api: command seam for route-owned actions
export 'presentation/profile_screen.dart'; // public-api: route entry point exposed to app routing
export 'presentation/self_profile_edit_tab_state.dart'; // public-api: provider-free display state reused by tests and routes
export 'presentation/self_profile_inline_edit_patch_factory.dart'; // public-api: presentation value/helper API used across feature boundaries
export 'presentation/self_profile_photo_intent_factory.dart'; // public-api: presentation value/helper API used across feature boundaries
export 'presentation/self_profile_screen_state.dart'; // public-api: provider-free display state reused by tests and routes
export 'presentation/widgets/preview_tab.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/profile_inline_editors.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/profile_sliver_header.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/profile_tab.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/profile_tab_skeleton.dart'; // public-api: shared presentation component used outside this feature
