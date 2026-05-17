// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_success_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventSuccessRepository)
final eventSuccessRepositoryProvider = EventSuccessRepositoryProvider._();

final class EventSuccessRepositoryProvider
    extends
        $FunctionalProvider<
          EventSuccessRepository,
          EventSuccessRepository,
          EventSuccessRepository
        >
    with $Provider<EventSuccessRepository> {
  EventSuccessRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventSuccessRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventSuccessRepositoryHash();

  @$internal
  @override
  $ProviderElement<EventSuccessRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EventSuccessRepository create(Ref ref) {
    return eventSuccessRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventSuccessRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventSuccessRepository>(value),
    );
  }
}

String _$eventSuccessRepositoryHash() =>
    r'9473ada9872bd4f33b489576f74dc5a074b19f04';

@ProviderFor(watchEventSuccessPlan)
final watchEventSuccessPlanProvider = WatchEventSuccessPlanFamily._();

final class WatchEventSuccessPlanProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventSuccessPlan?>,
          EventSuccessPlan?,
          Stream<EventSuccessPlan?>
        >
    with
        $FutureModifier<EventSuccessPlan?>,
        $StreamProvider<EventSuccessPlan?> {
  WatchEventSuccessPlanProvider._({
    required WatchEventSuccessPlanFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchEventSuccessPlanProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchEventSuccessPlanHash();

  @override
  String toString() {
    return r'watchEventSuccessPlanProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<EventSuccessPlan?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<EventSuccessPlan?> create(Ref ref) {
    final argument = this.argument as String;
    return watchEventSuccessPlan(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchEventSuccessPlanProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchEventSuccessPlanHash() =>
    r'f88d9855b7c8eb3de4832db44225fbb615414032';

final class WatchEventSuccessPlanFamily extends $Family
    with $FunctionalFamilyOverride<Stream<EventSuccessPlan?>, String> {
  WatchEventSuccessPlanFamily._()
    : super(
        retry: null,
        name: r'watchEventSuccessPlanProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchEventSuccessPlanProvider call(String eventId) =>
      WatchEventSuccessPlanProvider._(argument: eventId, from: this);

  @override
  String toString() => r'watchEventSuccessPlanProvider';
}

@ProviderFor(watchEventSuccessFeedback)
final watchEventSuccessFeedbackProvider = WatchEventSuccessFeedbackFamily._();

final class WatchEventSuccessFeedbackProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventSuccessFeedback>>,
          List<EventSuccessFeedback>,
          Stream<List<EventSuccessFeedback>>
        >
    with
        $FutureModifier<List<EventSuccessFeedback>>,
        $StreamProvider<List<EventSuccessFeedback>> {
  WatchEventSuccessFeedbackProvider._({
    required WatchEventSuccessFeedbackFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchEventSuccessFeedbackProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchEventSuccessFeedbackHash();

  @override
  String toString() {
    return r'watchEventSuccessFeedbackProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<EventSuccessFeedback>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<EventSuccessFeedback>> create(Ref ref) {
    final argument = this.argument as String;
    return watchEventSuccessFeedback(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchEventSuccessFeedbackProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchEventSuccessFeedbackHash() =>
    r'01eb0280dd93905ed9ba301008108a1f1ef9b399';

final class WatchEventSuccessFeedbackFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<EventSuccessFeedback>>, String> {
  WatchEventSuccessFeedbackFamily._()
    : super(
        retry: null,
        name: r'watchEventSuccessFeedbackProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchEventSuccessFeedbackProvider call(String eventId) =>
      WatchEventSuccessFeedbackProvider._(argument: eventId, from: this);

  @override
  String toString() => r'watchEventSuccessFeedbackProvider';
}

@ProviderFor(watchUserEventSuccessFeedback)
final watchUserEventSuccessFeedbackProvider =
    WatchUserEventSuccessFeedbackFamily._();

final class WatchUserEventSuccessFeedbackProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventSuccessFeedback?>,
          EventSuccessFeedback?,
          Stream<EventSuccessFeedback?>
        >
    with
        $FutureModifier<EventSuccessFeedback?>,
        $StreamProvider<EventSuccessFeedback?> {
  WatchUserEventSuccessFeedbackProvider._({
    required WatchUserEventSuccessFeedbackFamily super.from,
    required ({String eventId, String uid}) super.argument,
  }) : super(
         retry: null,
         name: r'watchUserEventSuccessFeedbackProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchUserEventSuccessFeedbackHash();

  @override
  String toString() {
    return r'watchUserEventSuccessFeedbackProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<EventSuccessFeedback?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<EventSuccessFeedback?> create(Ref ref) {
    final argument = this.argument as ({String eventId, String uid});
    return watchUserEventSuccessFeedback(
      ref,
      eventId: argument.eventId,
      uid: argument.uid,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WatchUserEventSuccessFeedbackProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchUserEventSuccessFeedbackHash() =>
    r'd198f249f98d4335a425eeaa0c63de7c4d6114b4';

final class WatchUserEventSuccessFeedbackFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<EventSuccessFeedback?>,
          ({String eventId, String uid})
        > {
  WatchUserEventSuccessFeedbackFamily._()
    : super(
        retry: null,
        name: r'watchUserEventSuccessFeedbackProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchUserEventSuccessFeedbackProvider call({
    required String eventId,
    required String uid,
  }) => WatchUserEventSuccessFeedbackProvider._(
    argument: (eventId: eventId, uid: uid),
    from: this,
  );

  @override
  String toString() => r'watchUserEventSuccessFeedbackProvider';
}

@ProviderFor(privateCrushCandidates)
final privateCrushCandidatesProvider = PrivateCrushCandidatesFamily._();

final class PrivateCrushCandidatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PublicProfile>>,
          List<PublicProfile>,
          FutureOr<List<PublicProfile>>
        >
    with
        $FutureModifier<List<PublicProfile>>,
        $FutureProvider<List<PublicProfile>> {
  PrivateCrushCandidatesProvider._({
    required PrivateCrushCandidatesFamily super.from,
    required ({String eventId, String currentUid}) super.argument,
  }) : super(
         retry: null,
         name: r'privateCrushCandidatesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$privateCrushCandidatesHash();

  @override
  String toString() {
    return r'privateCrushCandidatesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<PublicProfile>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PublicProfile>> create(Ref ref) {
    final argument = this.argument as ({String eventId, String currentUid});
    return privateCrushCandidates(
      ref,
      eventId: argument.eventId,
      currentUid: argument.currentUid,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PrivateCrushCandidatesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$privateCrushCandidatesHash() =>
    r'34e72853f7f45ba6bcf999ff016b02086386e6df';

final class PrivateCrushCandidatesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PublicProfile>>,
          ({String eventId, String currentUid})
        > {
  PrivateCrushCandidatesFamily._()
    : super(
        retry: null,
        name: r'privateCrushCandidatesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PrivateCrushCandidatesProvider call({
    required String eventId,
    required String currentUid,
  }) => PrivateCrushCandidatesProvider._(
    argument: (eventId: eventId, currentUid: currentUid),
    from: this,
  );

  @override
  String toString() => r'privateCrushCandidatesProvider';
}
