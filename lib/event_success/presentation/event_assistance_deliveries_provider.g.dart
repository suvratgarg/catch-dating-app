// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_deliveries_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EventAssistanceDeliveries)
final eventAssistanceDeliveriesProvider = EventAssistanceDeliveriesFamily._();

final class EventAssistanceDeliveriesProvider
    extends
        $NotifierProvider<
          EventAssistanceDeliveries,
          AsyncValue<EventAssistanceDeliveriesSession>
        > {
  EventAssistanceDeliveriesProvider._({
    required EventAssistanceDeliveriesFamily super.from,
    required EventAssistanceDeliveryQuery super.argument,
  }) : super(
         retry: null,
         name: r'eventAssistanceDeliveriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventAssistanceDeliveriesHash();

  @override
  String toString() {
    return r'eventAssistanceDeliveriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventAssistanceDeliveries create() => EventAssistanceDeliveries();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    AsyncValue<EventAssistanceDeliveriesSession> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<EventAssistanceDeliveriesSession>>(
            value,
          ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceDeliveriesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceDeliveriesHash() =>
    r'97c336e06b56c4a86d4931f250190dcdc887bf3b';

final class EventAssistanceDeliveriesFamily extends $Family
    with
        $ClassFamilyOverride<
          EventAssistanceDeliveries,
          AsyncValue<EventAssistanceDeliveriesSession>,
          AsyncValue<EventAssistanceDeliveriesSession>,
          AsyncValue<EventAssistanceDeliveriesSession>,
          EventAssistanceDeliveryQuery
        > {
  EventAssistanceDeliveriesFamily._()
    : super(
        retry: null,
        name: r'eventAssistanceDeliveriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventAssistanceDeliveriesProvider call(EventAssistanceDeliveryQuery query) =>
      EventAssistanceDeliveriesProvider._(argument: query, from: this);

  @override
  String toString() => r'eventAssistanceDeliveriesProvider';
}

abstract class _$EventAssistanceDeliveries
    extends $Notifier<AsyncValue<EventAssistanceDeliveriesSession>> {
  late final _$args = ref.$arg as EventAssistanceDeliveryQuery;
  EventAssistanceDeliveryQuery get query => _$args;

  AsyncValue<EventAssistanceDeliveriesSession> build(
    EventAssistanceDeliveryQuery query,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<EventAssistanceDeliveriesSession>,
              AsyncValue<EventAssistanceDeliveriesSession>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<EventAssistanceDeliveriesSession>,
                AsyncValue<EventAssistanceDeliveriesSession>
              >,
              AsyncValue<EventAssistanceDeliveriesSession>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(eventAssistanceDeliveriesForAccount)
final eventAssistanceDeliveriesForAccountProvider =
    EventAssistanceDeliveriesForAccountFamily._();

final class EventAssistanceDeliveriesForAccountProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventAssistanceDeliveriesSession>,
          EventAssistanceDeliveriesSession,
          FutureOr<EventAssistanceDeliveriesSession>
        >
    with
        $FutureModifier<EventAssistanceDeliveriesSession>,
        $FutureProvider<EventAssistanceDeliveriesSession> {
  EventAssistanceDeliveriesForAccountProvider._({
    required EventAssistanceDeliveriesForAccountFamily super.from,
    required (EventAssistanceDeliveryQuery, {EventAssistanceAccount account})
    super.argument,
  }) : super(
         retry: _noDeliveryReadRetry,
         name: r'eventAssistanceDeliveriesForAccountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$eventAssistanceDeliveriesForAccountHash();

  @override
  String toString() {
    return r'eventAssistanceDeliveriesForAccountProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<EventAssistanceDeliveriesSession> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EventAssistanceDeliveriesSession> create(Ref ref) {
    final argument =
        this.argument
            as (EventAssistanceDeliveryQuery, {EventAssistanceAccount account});
    return eventAssistanceDeliveriesForAccount(
      ref,
      argument.$1,
      account: argument.account,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceDeliveriesForAccountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceDeliveriesForAccountHash() =>
    r'35e3b69cca9b3169117e6055812ba4af2c08a50e';

final class EventAssistanceDeliveriesForAccountFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<EventAssistanceDeliveriesSession>,
          (EventAssistanceDeliveryQuery, {EventAssistanceAccount account})
        > {
  EventAssistanceDeliveriesForAccountFamily._()
    : super(
        retry: _noDeliveryReadRetry,
        name: r'eventAssistanceDeliveriesForAccountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventAssistanceDeliveriesForAccountProvider call(
    EventAssistanceDeliveryQuery query, {
    required EventAssistanceAccount account,
  }) => EventAssistanceDeliveriesForAccountProvider._(
    argument: (query, account: account),
    from: this,
  );

  @override
  String toString() => r'eventAssistanceDeliveriesForAccountProvider';
}
