/// User Profile feature — public API barrel.
///
/// Prefer importing this barrel over individual files so internal reorg stays
/// invisible to the ~20 external consumers across 10 features.
///
/// ## Domain
export 'domain/profile_photo.dart';
export 'domain/profile_photo_policy.dart';
export 'domain/profile_prompts.dart';
export 'domain/profile_readiness.dart';
export 'domain/profile_validation.dart';
export 'domain/user_profile.dart';

/// ## Data
export 'data/user_profile_repository.dart';

/// ## Presentation (screens and shared widgets)
export 'presentation/profile_edit_controller.dart';
export 'presentation/profile_screen.dart';
export 'presentation/self_profile_edit_tab_state.dart';
export 'presentation/self_profile_inline_edit_patch_factory.dart';
export 'presentation/self_profile_photo_action_controller.dart';
export 'presentation/self_profile_screen_state.dart';
export 'presentation/widgets/preview_tab.dart';
export 'presentation/widgets/profile_info_section.dart';
export 'presentation/widgets/profile_inline_editors.dart';
export 'presentation/widgets/profile_sliver_header.dart';
export 'presentation/widgets/profile_tab.dart';
export 'presentation/widgets/profile_tab_skeleton.dart';
