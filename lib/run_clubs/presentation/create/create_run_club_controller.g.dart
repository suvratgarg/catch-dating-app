// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_run_club_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern B: Stateless controller + static Mutations**
///
/// Handles create and edit club submission. [submitMutation] tracks the
/// lifecycle of the async submit operation. The UI watches
/// `ref.watch(createRunClubControllerProvider.submitMutation)`.

@ProviderFor(CreateRunClubController)
final createRunClubControllerProvider = CreateRunClubControllerProvider._();

/// **Pattern B: Stateless controller + static Mutations**
///
/// Handles create and edit club submission. [submitMutation] tracks the
/// lifecycle of the async submit operation. The UI watches
/// `ref.watch(createRunClubControllerProvider.submitMutation)`.
final class CreateRunClubControllerProvider
    extends $NotifierProvider<CreateRunClubController, void> {
  /// **Pattern B: Stateless controller + static Mutations**
  ///
  /// Handles create and edit club submission. [submitMutation] tracks the
  /// lifecycle of the async submit operation. The UI watches
  /// `ref.watch(createRunClubControllerProvider.submitMutation)`.
  CreateRunClubControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createRunClubControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createRunClubControllerHash();

  @$internal
  @override
  CreateRunClubController create() => CreateRunClubController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$createRunClubControllerHash() =>
    r'd304d919e6d90249ea0ba55175140d7282a5fc9d';

/// **Pattern B: Stateless controller + static Mutations**
///
/// Handles create and edit club submission. [submitMutation] tracks the
/// lifecycle of the async submit operation. The UI watches
/// `ref.watch(createRunClubControllerProvider.submitMutation)`.

abstract class _$CreateRunClubController extends $Notifier<void> {
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
