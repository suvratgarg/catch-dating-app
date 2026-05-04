// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_run_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern B: Stateless controller + static Mutations**
///
/// Validates input and delegates run creation to [RunRepository].
/// [submitMutation] carries the created [Run] on success so the UI can
/// navigate to the run detail screen.

@ProviderFor(CreateRunController)
final createRunControllerProvider = CreateRunControllerProvider._();

/// **Pattern B: Stateless controller + static Mutations**
///
/// Validates input and delegates run creation to [RunRepository].
/// [submitMutation] carries the created [Run] on success so the UI can
/// navigate to the run detail screen.
final class CreateRunControllerProvider
    extends $NotifierProvider<CreateRunController, void> {
  /// **Pattern B: Stateless controller + static Mutations**
  ///
  /// Validates input and delegates run creation to [RunRepository].
  /// [submitMutation] carries the created [Run] on success so the UI can
  /// navigate to the run detail screen.
  CreateRunControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createRunControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createRunControllerHash();

  @$internal
  @override
  CreateRunController create() => CreateRunController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$createRunControllerHash() =>
    r'721225f8c2055452a9064c72a030f4a3778bda6f';

/// **Pattern B: Stateless controller + static Mutations**
///
/// Validates input and delegates run creation to [RunRepository].
/// [submitMutation] carries the created [Run] on success so the UI can
/// navigate to the run detail screen.

abstract class _$CreateRunController extends $Notifier<void> {
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
