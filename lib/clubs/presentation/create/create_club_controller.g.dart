// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_club_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern A: Action controller + static Mutations**
///
/// Handles create and edit club submission. [submitMutation] tracks the
/// lifecycle of the async submit operation. The UI watches
/// `ref.watch(createClubControllerProvider.submitMutation)`.

@ProviderFor(CreateClubController)
final createClubControllerProvider = CreateClubControllerProvider._();

/// **Pattern A: Action controller + static Mutations**
///
/// Handles create and edit club submission. [submitMutation] tracks the
/// lifecycle of the async submit operation. The UI watches
/// `ref.watch(createClubControllerProvider.submitMutation)`.
final class CreateClubControllerProvider
    extends $NotifierProvider<CreateClubController, void> {
  /// **Pattern A: Action controller + static Mutations**
  ///
  /// Handles create and edit club submission. [submitMutation] tracks the
  /// lifecycle of the async submit operation. The UI watches
  /// `ref.watch(createClubControllerProvider.submitMutation)`.
  CreateClubControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createClubControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createClubControllerHash();

  @$internal
  @override
  CreateClubController create() => CreateClubController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$createClubControllerHash() =>
    r'2d0068fa4cd97d32783d429b7ac05e974ee52806';

/// **Pattern A: Action controller + static Mutations**
///
/// Handles create and edit club submission. [submitMutation] tracks the
/// lifecycle of the async submit operation. The UI watches
/// `ref.watch(createClubControllerProvider.submitMutation)`.

abstract class _$CreateClubController extends $Notifier<void> {
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
