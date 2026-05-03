// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_booking_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern B: Stateless controller + static Mutations**
///
/// This is the most common mutation pattern in the app (6 controllers use it):
/// - [build()] returns `void` — the controller holds no Riverpod state.
/// - [Mutation]s (`bookMutation`, `cancelMutation`, etc.) are `static final`
///   fields that track the lifecycle of single-shot operations.
/// - The UI watches mutations directly (e.g. `ref.watch(controller.mutation)`)
///   and checks `.isPending`, `.hasError`, `.isSuccess`.
/// - Controller methods delegate to repositories and let errors propagate
///   into the Mutation error state automatically.
///
/// **When to use this pattern:** Single-shot user actions (book, cancel, join,
/// leave, submit, delete) where the UI needs to show loading/error/success
/// state for a specific action.

@ProviderFor(RunBookingController)
final runBookingControllerProvider = RunBookingControllerProvider._();

/// **Pattern B: Stateless controller + static Mutations**
///
/// This is the most common mutation pattern in the app (6 controllers use it):
/// - [build()] returns `void` — the controller holds no Riverpod state.
/// - [Mutation]s (`bookMutation`, `cancelMutation`, etc.) are `static final`
///   fields that track the lifecycle of single-shot operations.
/// - The UI watches mutations directly (e.g. `ref.watch(controller.mutation)`)
///   and checks `.isPending`, `.hasError`, `.isSuccess`.
/// - Controller methods delegate to repositories and let errors propagate
///   into the Mutation error state automatically.
///
/// **When to use this pattern:** Single-shot user actions (book, cancel, join,
/// leave, submit, delete) where the UI needs to show loading/error/success
/// state for a specific action.
final class RunBookingControllerProvider
    extends $NotifierProvider<RunBookingController, void> {
  /// **Pattern B: Stateless controller + static Mutations**
  ///
  /// This is the most common mutation pattern in the app (6 controllers use it):
  /// - [build()] returns `void` — the controller holds no Riverpod state.
  /// - [Mutation]s (`bookMutation`, `cancelMutation`, etc.) are `static final`
  ///   fields that track the lifecycle of single-shot operations.
  /// - The UI watches mutations directly (e.g. `ref.watch(controller.mutation)`)
  ///   and checks `.isPending`, `.hasError`, `.isSuccess`.
  /// - Controller methods delegate to repositories and let errors propagate
  ///   into the Mutation error state automatically.
  ///
  /// **When to use this pattern:** Single-shot user actions (book, cancel, join,
  /// leave, submit, delete) where the UI needs to show loading/error/success
  /// state for a specific action.
  RunBookingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runBookingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runBookingControllerHash();

  @$internal
  @override
  RunBookingController create() => RunBookingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$runBookingControllerHash() =>
    r'db4ef224c18fd012ee9350fd33c1a298b27734fb';

/// **Pattern B: Stateless controller + static Mutations**
///
/// This is the most common mutation pattern in the app (6 controllers use it):
/// - [build()] returns `void` — the controller holds no Riverpod state.
/// - [Mutation]s (`bookMutation`, `cancelMutation`, etc.) are `static final`
///   fields that track the lifecycle of single-shot operations.
/// - The UI watches mutations directly (e.g. `ref.watch(controller.mutation)`)
///   and checks `.isPending`, `.hasError`, `.isSuccess`.
/// - Controller methods delegate to repositories and let errors propagate
///   into the Mutation error state automatically.
///
/// **When to use this pattern:** Single-shot user actions (book, cancel, join,
/// leave, submit, delete) where the UI needs to show loading/error/success
/// state for a specific action.

abstract class _$RunBookingController extends $Notifier<void> {
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
