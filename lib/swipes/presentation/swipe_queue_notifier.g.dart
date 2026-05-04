// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swipe_queue_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern C: AsyncNotifier with async state**
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

/// **Pattern C: AsyncNotifier with async state**
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
  /// **Pattern C: AsyncNotifier with async state**
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
    r'a6a1b140086c291d58594e550a821603724ff7ce';

/// **Pattern C: AsyncNotifier with async state**
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

  /// **Pattern C: AsyncNotifier with async state**
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
    String runId, {
    Set<String> vibeIds = const {},
  }) => SwipeQueueNotifierProvider._(
    argument: (runId, vibeIds: vibeIds),
    from: this,
  );

  @override
  String toString() => r'swipeQueueProvider';
}

/// **Pattern C: AsyncNotifier with async state**
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
  String get runId => _$args.$1;
  Set<String> get vibeIds => _$args.vibeIds;

  FutureOr<List<PublicProfile>> build(
    String runId, {
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
