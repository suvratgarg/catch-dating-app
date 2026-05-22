// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swipe_queue_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(swipeQueueLoadTimeout)
@visibleForTesting
final swipeQueueLoadTimeoutProvider = SwipeQueueLoadTimeoutProvider._();

@visibleForTesting
final class SwipeQueueLoadTimeoutProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  SwipeQueueLoadTimeoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'swipeQueueLoadTimeoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$swipeQueueLoadTimeoutHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return swipeQueueLoadTimeout(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$swipeQueueLoadTimeoutHash() =>
    r'b9128e41b91528012398a137958e3c6fbae438d1';

/// **Pattern C: Async state controller**
///
/// Used when state is loaded asynchronously AND needs to be mutated after load:
/// - [build()] returns `Future<T>` — Riverpod manages the AsyncValue lifecycle
///   (loading / data / error) automatically.
/// - Methods like [swipe] mutate the loaded state by removing the first
///   profile from the list. Since state is `AsyncData<List<...>>`, the
///   mutation is synchronous (just `state = AsyncData(newList)`).
/// - The UI watches with `.when(loading:error:data:)` for the initial load
///   and uses the current state for mutations.
///
/// **When to use this pattern:** Data that needs an async fetch to initialize
/// followed by synchronous state mutations (pagination, queue operations,
/// local filtering of fetched data).

@ProviderFor(SwipeQueueNotifier)
final swipeQueueProvider = SwipeQueueNotifierFamily._();

/// **Pattern C: Async state controller**
///
/// Used when state is loaded asynchronously AND needs to be mutated after load:
/// - [build()] returns `Future<T>` — Riverpod manages the AsyncValue lifecycle
///   (loading / data / error) automatically.
/// - Methods like [swipe] mutate the loaded state by removing the first
///   profile from the list. Since state is `AsyncData<List<...>>`, the
///   mutation is synchronous (just `state = AsyncData(newList)`).
/// - The UI watches with `.when(loading:error:data:)` for the initial load
///   and uses the current state for mutations.
///
/// **When to use this pattern:** Data that needs an async fetch to initialize
/// followed by synchronous state mutations (pagination, queue operations,
/// local filtering of fetched data).
final class SwipeQueueNotifierProvider
    extends $AsyncNotifierProvider<SwipeQueueNotifier, List<PublicProfile>> {
  /// **Pattern C: Async state controller**
  ///
  /// Used when state is loaded asynchronously AND needs to be mutated after load:
  /// - [build()] returns `Future<T>` — Riverpod manages the AsyncValue lifecycle
  ///   (loading / data / error) automatically.
  /// - Methods like [swipe] mutate the loaded state by removing the first
  ///   profile from the list. Since state is `AsyncData<List<...>>`, the
  ///   mutation is synchronous (just `state = AsyncData(newList)`).
  /// - The UI watches with `.when(loading:error:data:)` for the initial load
  ///   and uses the current state for mutations.
  ///
  /// **When to use this pattern:** Data that needs an async fetch to initialize
  /// followed by synchronous state mutations (pagination, queue operations,
  /// local filtering of fetched data).
  SwipeQueueNotifierProvider._({
    required SwipeQueueNotifierFamily super.from,
    required (String, {Set<String> vibeIds}) super.argument,
  }) : super(
         retry: null,
         name: r'swipeQueueProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$swipeQueueNotifierHash();

  @override
  String toString() {
    return r'swipeQueueProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  SwipeQueueNotifier create() => SwipeQueueNotifier();

  @override
  bool operator ==(Object other) {
    return other is SwipeQueueNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$swipeQueueNotifierHash() =>
    r'88dd74744a2ae0275d31c11b6d707b9f316abb1a';

/// **Pattern C: Async state controller**
///
/// Used when state is loaded asynchronously AND needs to be mutated after load:
/// - [build()] returns `Future<T>` — Riverpod manages the AsyncValue lifecycle
///   (loading / data / error) automatically.
/// - Methods like [swipe] mutate the loaded state by removing the first
///   profile from the list. Since state is `AsyncData<List<...>>`, the
///   mutation is synchronous (just `state = AsyncData(newList)`).
/// - The UI watches with `.when(loading:error:data:)` for the initial load
///   and uses the current state for mutations.
///
/// **When to use this pattern:** Data that needs an async fetch to initialize
/// followed by synchronous state mutations (pagination, queue operations,
/// local filtering of fetched data).

final class SwipeQueueNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          SwipeQueueNotifier,
          AsyncValue<List<PublicProfile>>,
          List<PublicProfile>,
          FutureOr<List<PublicProfile>>,
          (String, {Set<String> vibeIds})
        > {
  SwipeQueueNotifierFamily._()
    : super(
        retry: null,
        name: r'swipeQueueProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// **Pattern C: Async state controller**
  ///
  /// Used when state is loaded asynchronously AND needs to be mutated after load:
  /// - [build()] returns `Future<T>` — Riverpod manages the AsyncValue lifecycle
  ///   (loading / data / error) automatically.
  /// - Methods like [swipe] mutate the loaded state by removing the first
  ///   profile from the list. Since state is `AsyncData<List<...>>`, the
  ///   mutation is synchronous (just `state = AsyncData(newList)`).
  /// - The UI watches with `.when(loading:error:data:)` for the initial load
  ///   and uses the current state for mutations.
  ///
  /// **When to use this pattern:** Data that needs an async fetch to initialize
  /// followed by synchronous state mutations (pagination, queue operations,
  /// local filtering of fetched data).

  SwipeQueueNotifierProvider call(
    String eventId, {
    Set<String> vibeIds = const {},
  }) => SwipeQueueNotifierProvider._(
    argument: (eventId, vibeIds: vibeIds),
    from: this,
  );

  @override
  String toString() => r'swipeQueueProvider';
}

/// **Pattern C: Async state controller**
///
/// Used when state is loaded asynchronously AND needs to be mutated after load:
/// - [build()] returns `Future<T>` — Riverpod manages the AsyncValue lifecycle
///   (loading / data / error) automatically.
/// - Methods like [swipe] mutate the loaded state by removing the first
///   profile from the list. Since state is `AsyncData<List<...>>`, the
///   mutation is synchronous (just `state = AsyncData(newList)`).
/// - The UI watches with `.when(loading:error:data:)` for the initial load
///   and uses the current state for mutations.
///
/// **When to use this pattern:** Data that needs an async fetch to initialize
/// followed by synchronous state mutations (pagination, queue operations,
/// local filtering of fetched data).

abstract class _$SwipeQueueNotifier
    extends $AsyncNotifier<List<PublicProfile>> {
  late final _$args = ref.$arg as (String, {Set<String> vibeIds});
  String get eventId => _$args.$1;
  Set<String> get vibeIds => _$args.vibeIds;

  FutureOr<List<PublicProfile>> build(
    String eventId, {
    Set<String> vibeIds = const {},
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<PublicProfile>>, List<PublicProfile>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<PublicProfile>>, List<PublicProfile>>,
              AsyncValue<List<PublicProfile>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, vibeIds: _$args.vibeIds));
  }
}
