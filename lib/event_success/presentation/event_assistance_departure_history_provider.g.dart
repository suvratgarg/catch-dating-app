// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_departure_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Account-scoped pages never render a previous sign-in's history on refresh.

@ProviderFor(EventAssistanceDepartureHistory)
final eventAssistanceDepartureHistoryProvider =
    EventAssistanceDepartureHistoryFamily._();

/// Account-scoped pages never render a previous sign-in's history on refresh.
final class EventAssistanceDepartureHistoryProvider
    extends
        $NotifierProvider<
          EventAssistanceDepartureHistory,
          AsyncValue<EventAssistanceDepartureHistorySession>
        > {
  /// Account-scoped pages never render a previous sign-in's history on refresh.
  EventAssistanceDepartureHistoryProvider._({
    required EventAssistanceDepartureHistoryFamily super.from,
    required EventAssistanceDepartureHistoryQuery super.argument,
  }) : super(
         retry: null,
         name: r'eventAssistanceDepartureHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventAssistanceDepartureHistoryHash();

  @override
  String toString() {
    return r'eventAssistanceDepartureHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventAssistanceDepartureHistory create() => EventAssistanceDepartureHistory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    AsyncValue<EventAssistanceDepartureHistorySession> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<
            AsyncValue<EventAssistanceDepartureHistorySession>
          >(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceDepartureHistoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceDepartureHistoryHash() =>
    r'ff25f184712a28a223cba1226c670bfa3aec1a5a';

/// Account-scoped pages never render a previous sign-in's history on refresh.

final class EventAssistanceDepartureHistoryFamily extends $Family
    with
        $ClassFamilyOverride<
          EventAssistanceDepartureHistory,
          AsyncValue<EventAssistanceDepartureHistorySession>,
          AsyncValue<EventAssistanceDepartureHistorySession>,
          AsyncValue<EventAssistanceDepartureHistorySession>,
          EventAssistanceDepartureHistoryQuery
        > {
  EventAssistanceDepartureHistoryFamily._()
    : super(
        retry: null,
        name: r'eventAssistanceDepartureHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Account-scoped pages never render a previous sign-in's history on refresh.

  EventAssistanceDepartureHistoryProvider call(
    EventAssistanceDepartureHistoryQuery query,
  ) => EventAssistanceDepartureHistoryProvider._(argument: query, from: this);

  @override
  String toString() => r'eventAssistanceDepartureHistoryProvider';
}

/// Account-scoped pages never render a previous sign-in's history on refresh.

abstract class _$EventAssistanceDepartureHistory
    extends $Notifier<AsyncValue<EventAssistanceDepartureHistorySession>> {
  late final _$args = ref.$arg as EventAssistanceDepartureHistoryQuery;
  EventAssistanceDepartureHistoryQuery get query => _$args;

  AsyncValue<EventAssistanceDepartureHistorySession> build(
    EventAssistanceDepartureHistoryQuery query,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<EventAssistanceDepartureHistorySession>,
              AsyncValue<EventAssistanceDepartureHistorySession>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<EventAssistanceDepartureHistorySession>,
                AsyncValue<EventAssistanceDepartureHistorySession>
              >,
              AsyncValue<EventAssistanceDepartureHistorySession>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(eventAssistanceDepartureHistoryForAccount)
final eventAssistanceDepartureHistoryForAccountProvider =
    EventAssistanceDepartureHistoryForAccountFamily._();

final class EventAssistanceDepartureHistoryForAccountProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventAssistanceDepartureHistorySession>,
          EventAssistanceDepartureHistorySession,
          FutureOr<EventAssistanceDepartureHistorySession>
        >
    with
        $FutureModifier<EventAssistanceDepartureHistorySession>,
        $FutureProvider<EventAssistanceDepartureHistorySession> {
  EventAssistanceDepartureHistoryForAccountProvider._({
    required EventAssistanceDepartureHistoryForAccountFamily super.from,
    required (
      EventAssistanceDepartureHistoryQuery, {
      AuthenticatedSession account,
    })
    super.argument,
  }) : super(
         retry: _noHistoryReadRetry,
         name: r'eventAssistanceDepartureHistoryForAccountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$eventAssistanceDepartureHistoryForAccountHash();

  @override
  String toString() {
    return r'eventAssistanceDepartureHistoryForAccountProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<EventAssistanceDepartureHistorySession> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EventAssistanceDepartureHistorySession> create(Ref ref) {
    final argument =
        this.argument
            as (
              EventAssistanceDepartureHistoryQuery, {
              AuthenticatedSession account,
            });
    return eventAssistanceDepartureHistoryForAccount(
      ref,
      argument.$1,
      account: argument.account,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceDepartureHistoryForAccountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceDepartureHistoryForAccountHash() =>
    r'5e537880adea46e4de9d6b9133b96e423fccb92c';

final class EventAssistanceDepartureHistoryForAccountFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<EventAssistanceDepartureHistorySession>,
          (EventAssistanceDepartureHistoryQuery, {AuthenticatedSession account})
        > {
  EventAssistanceDepartureHistoryForAccountFamily._()
    : super(
        retry: _noHistoryReadRetry,
        name: r'eventAssistanceDepartureHistoryForAccountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventAssistanceDepartureHistoryForAccountProvider call(
    EventAssistanceDepartureHistoryQuery query, {
    required AuthenticatedSession account,
  }) => EventAssistanceDepartureHistoryForAccountProvider._(
    argument: (query, account: account),
    from: this,
  );

  @override
  String toString() => r'eventAssistanceDepartureHistoryForAccountProvider';
}
