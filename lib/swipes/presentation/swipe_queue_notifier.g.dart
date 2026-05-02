// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swipe_queue_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SwipeQueueNotifier)
final swipeQueueProvider = SwipeQueueNotifierFamily._();

final class SwipeQueueNotifierProvider
    extends $AsyncNotifierProvider<SwipeQueueNotifier, List<PublicProfile>> {
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
    r'bfd3b1260f2f6cc61dd9902b37baf8c3f463adde';

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
