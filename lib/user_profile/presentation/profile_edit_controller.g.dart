// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_edit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern A: Action controller + static Mutations**
///
/// Serializes profile-field saves so rapid bottom-sheet edits cannot race.

@ProviderFor(ProfileEditController)
final profileEditControllerProvider = ProfileEditControllerProvider._();

/// **Pattern A: Action controller + static Mutations**
///
/// Serializes profile-field saves so rapid bottom-sheet edits cannot race.
final class ProfileEditControllerProvider
    extends $NotifierProvider<ProfileEditController, void> {
  /// **Pattern A: Action controller + static Mutations**
  ///
  /// Serializes profile-field saves so rapid bottom-sheet edits cannot race.
  ProfileEditControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileEditControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileEditControllerHash();

  @$internal
  @override
  ProfileEditController create() => ProfileEditController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$profileEditControllerHash() =>
    r'4c734618c52c24e5a9928428fe3777f962261405';

/// **Pattern A: Action controller + static Mutations**
///
/// Serializes profile-field saves so rapid bottom-sheet edits cannot race.

abstract class _$ProfileEditController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
