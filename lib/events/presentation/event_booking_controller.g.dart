// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_booking_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern A: Action controller + static Mutations**
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

@ProviderFor(EventBookingController)
final eventBookingControllerProvider = EventBookingControllerProvider._();

/// **Pattern A: Action controller + static Mutations**
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
final class EventBookingControllerProvider
    extends $NotifierProvider<EventBookingController, void> {
  /// **Pattern A: Action controller + static Mutations**
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
  EventBookingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventBookingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventBookingControllerHash();

  @$internal
  @override
  EventBookingController create() => EventBookingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$eventBookingControllerHash() =>
    r'4be12407b0e1b546973ef384b25533009cdf8248';

/// **Pattern A: Action controller + static Mutations**
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

abstract class _$EventBookingController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
