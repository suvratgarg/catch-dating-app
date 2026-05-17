// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventRepository)
final eventRepositoryProvider = EventRepositoryProvider._();

final class EventRepositoryProvider
    extends
        $FunctionalProvider<EventRepository, EventRepository, EventRepository>
    with $Provider<EventRepository> {
  EventRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventRepositoryHash();

  @$internal
  @override
  $ProviderElement<EventRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EventRepository create(Ref ref) {
    return eventRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventRepository>(value),
    );
  }
}

String _$eventRepositoryHash() => r'5c27fcaf610df7c473e469b917d805e9b5bdde72';

@ProviderFor(watchEvent)
final watchEventProvider = WatchEventFamily._();

final class WatchEventProvider
    extends $FunctionalProvider<AsyncValue<Event?>, Event?, Stream<Event?>>
    with $FutureModifier<Event?>, $StreamProvider<Event?> {
  WatchEventProvider._({
    required WatchEventFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchEventProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchEventHash();

  @override
  String toString() {
    return r'watchEventProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Event?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Event?> create(Ref ref) {
    final argument = this.argument as String;
    return watchEvent(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchEventProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchEventHash() => r'28619c56a3d029be7cccee2fab8d084962288c6f';

final class WatchEventFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Event?>, String> {
  WatchEventFamily._()
    : super(
        retry: null,
        name: r'watchEventProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchEventProvider call(String eventId) =>
      WatchEventProvider._(argument: eventId, from: this);

  @override
  String toString() => r'watchEventProvider';
}

@ProviderFor(watchEventsForClub)
final watchEventsForClubProvider = WatchEventsForClubFamily._();

final class WatchEventsForClubProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Event>>,
          List<Event>,
          Stream<List<Event>>
        >
    with $FutureModifier<List<Event>>, $StreamProvider<List<Event>> {
  WatchEventsForClubProvider._({
    required WatchEventsForClubFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchEventsForClubProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchEventsForClubHash();

  @override
  String toString() {
    return r'watchEventsForClubProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Event>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Event>> create(Ref ref) {
    final argument = this.argument as String;
    return watchEventsForClub(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchEventsForClubProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchEventsForClubHash() =>
    r'fd4d52b8f0ceb8ba17c85c11c216fdb7899cb7b1';

final class WatchEventsForClubFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Event>>, String> {
  WatchEventsForClubFamily._()
    : super(
        retry: null,
        name: r'watchEventsForClubProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchEventsForClubProvider call(String clubId) =>
      WatchEventsForClubProvider._(argument: clubId, from: this);

  @override
  String toString() => r'watchEventsForClubProvider';
}

@ProviderFor(watchAttendedEvents)
final watchAttendedEventsProvider = WatchAttendedEventsFamily._();

final class WatchAttendedEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Event>>,
          List<Event>,
          Stream<List<Event>>
        >
    with $FutureModifier<List<Event>>, $StreamProvider<List<Event>> {
  WatchAttendedEventsProvider._({
    required WatchAttendedEventsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchAttendedEventsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchAttendedEventsHash();

  @override
  String toString() {
    return r'watchAttendedEventsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Event>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Event>> create(Ref ref) {
    final argument = this.argument as String;
    return watchAttendedEvents(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchAttendedEventsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchAttendedEventsHash() =>
    r'4b95afe7e5274275c5a1693c98c1b49eabddaad0';

final class WatchAttendedEventsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Event>>, String> {
  WatchAttendedEventsFamily._()
    : super(
        retry: null,
        name: r'watchAttendedEventsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchAttendedEventsProvider call(String uid) =>
      WatchAttendedEventsProvider._(argument: uid, from: this);

  @override
  String toString() => r'watchAttendedEventsProvider';
}

@ProviderFor(watchSignedUpEvents)
final watchSignedUpEventsProvider = WatchSignedUpEventsFamily._();

final class WatchSignedUpEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Event>>,
          List<Event>,
          Stream<List<Event>>
        >
    with $FutureModifier<List<Event>>, $StreamProvider<List<Event>> {
  WatchSignedUpEventsProvider._({
    required WatchSignedUpEventsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchSignedUpEventsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchSignedUpEventsHash();

  @override
  String toString() {
    return r'watchSignedUpEventsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Event>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Event>> create(Ref ref) {
    final argument = this.argument as String;
    return watchSignedUpEvents(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchSignedUpEventsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchSignedUpEventsHash() =>
    r'22fcd6826b7f48f6a58c0ee3591c084b79c3c3bf';

final class WatchSignedUpEventsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Event>>, String> {
  WatchSignedUpEventsFamily._()
    : super(
        retry: null,
        name: r'watchSignedUpEventsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchSignedUpEventsProvider call(String uid) =>
      WatchSignedUpEventsProvider._(argument: uid, from: this);

  @override
  String toString() => r'watchSignedUpEventsProvider';
}

/// Returns upcoming events from clubs the user follows.

@ProviderFor(recommendedEvents)
final recommendedEventsProvider = RecommendedEventsFamily._();

/// Returns upcoming events from clubs the user follows.

final class RecommendedEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Event>>,
          List<Event>,
          FutureOr<List<Event>>
        >
    with $FutureModifier<List<Event>>, $FutureProvider<List<Event>> {
  /// Returns upcoming events from clubs the user follows.
  RecommendedEventsProvider._({
    required RecommendedEventsFamily super.from,
    required RecommendedEventsQuery super.argument,
  }) : super(
         retry: null,
         name: r'recommendedEventsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recommendedEventsHash();

  @override
  String toString() {
    return r'recommendedEventsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Event>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Event>> create(Ref ref) {
    final argument = this.argument as RecommendedEventsQuery;
    return recommendedEvents(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecommendedEventsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recommendedEventsHash() => r'bc5ff15bfc6186cb5f74823a30b2fb2ec3c7749c';

/// Returns upcoming events from clubs the user follows.

final class RecommendedEventsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Event>>,
          RecommendedEventsQuery
        > {
  RecommendedEventsFamily._()
    : super(
        retry: null,
        name: r'recommendedEventsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Returns upcoming events from clubs the user follows.

  RecommendedEventsProvider call(RecommendedEventsQuery query) =>
      RecommendedEventsProvider._(argument: query, from: this);

  @override
  String toString() => r'recommendedEventsProvider';
}
