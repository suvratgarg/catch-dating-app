// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_departure_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventAssistanceDepartureAccount)
final eventAssistanceDepartureAccountProvider =
    EventAssistanceDepartureAccountProvider._();

final class EventAssistanceDepartureAccountProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventDepartureAccount>,
          AsyncValue<EventDepartureAccount>,
          AsyncValue<EventDepartureAccount>
        >
    with $Provider<AsyncValue<EventDepartureAccount>> {
  EventAssistanceDepartureAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventAssistanceDepartureAccountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventAssistanceDepartureAccountHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<EventDepartureAccount>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<EventDepartureAccount> create(Ref ref) {
    return eventAssistanceDepartureAccount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<EventDepartureAccount> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<EventDepartureAccount>>(
        value,
      ),
    );
  }
}

String _$eventAssistanceDepartureAccountHash() =>
    r'b418529a30e4906b38363e12587c52e6297cfff3';

@ProviderFor(EventAssistanceDeparture)
final eventAssistanceDepartureProvider = EventAssistanceDepartureFamily._();

final class EventAssistanceDepartureProvider
    extends
        $NotifierProvider<
          EventAssistanceDeparture,
          AsyncValue<EventDepartureSession>
        > {
  EventAssistanceDepartureProvider._({
    required EventAssistanceDepartureFamily super.from,
    required EventAssistanceGroupScope super.argument,
  }) : super(
         retry: null,
         name: r'eventAssistanceDepartureProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventAssistanceDepartureHash();

  @override
  String toString() {
    return r'eventAssistanceDepartureProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventAssistanceDeparture create() => EventAssistanceDeparture();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<EventDepartureSession> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<EventDepartureSession>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceDepartureProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceDepartureHash() =>
    r'2884cfcbb098cb0562b9608022eb11dd06cbbfdf';

final class EventAssistanceDepartureFamily extends $Family
    with
        $ClassFamilyOverride<
          EventAssistanceDeparture,
          AsyncValue<EventDepartureSession>,
          AsyncValue<EventDepartureSession>,
          AsyncValue<EventDepartureSession>,
          EventAssistanceGroupScope
        > {
  EventAssistanceDepartureFamily._()
    : super(
        retry: null,
        name: r'eventAssistanceDepartureProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventAssistanceDepartureProvider call(EventAssistanceGroupScope scope) =>
      EventAssistanceDepartureProvider._(argument: scope, from: this);

  @override
  String toString() => r'eventAssistanceDepartureProvider';
}

abstract class _$EventAssistanceDeparture
    extends $Notifier<AsyncValue<EventDepartureSession>> {
  late final _$args = ref.$arg as EventAssistanceGroupScope;
  EventAssistanceGroupScope get scope => _$args;

  AsyncValue<EventDepartureSession> build(EventAssistanceGroupScope scope);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<EventDepartureSession>,
              AsyncValue<EventDepartureSession>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<EventDepartureSession>,
                AsyncValue<EventDepartureSession>
              >,
              AsyncValue<EventDepartureSession>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(eventAssistanceDepartureForAccount)
final eventAssistanceDepartureForAccountProvider =
    EventAssistanceDepartureForAccountFamily._();

final class EventAssistanceDepartureForAccountProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventDepartureSession>,
          EventDepartureSession,
          FutureOr<EventDepartureSession>
        >
    with
        $FutureModifier<EventDepartureSession>,
        $FutureProvider<EventDepartureSession> {
  EventAssistanceDepartureForAccountProvider._({
    required EventAssistanceDepartureForAccountFamily super.from,
    required (EventAssistanceGroupScope, {EventDepartureAccount account})
    super.argument,
  }) : super(
         retry: _noDepartureReadRetry,
         name: r'eventAssistanceDepartureForAccountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$eventAssistanceDepartureForAccountHash();

  @override
  String toString() {
    return r'eventAssistanceDepartureForAccountProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<EventDepartureSession> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EventDepartureSession> create(Ref ref) {
    final argument =
        this.argument
            as (EventAssistanceGroupScope, {EventDepartureAccount account});
    return eventAssistanceDepartureForAccount(
      ref,
      argument.$1,
      account: argument.account,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceDepartureForAccountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceDepartureForAccountHash() =>
    r'63a3af8629dd9e2417ffb30507ce13f278ab25bc';

final class EventAssistanceDepartureForAccountFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<EventDepartureSession>,
          (EventAssistanceGroupScope, {EventDepartureAccount account})
        > {
  EventAssistanceDepartureForAccountFamily._()
    : super(
        retry: _noDepartureReadRetry,
        name: r'eventAssistanceDepartureForAccountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventAssistanceDepartureForAccountProvider call(
    EventAssistanceGroupScope scope, {
    required EventDepartureAccount account,
  }) => EventAssistanceDepartureForAccountProvider._(
    argument: (scope, account: account),
    from: this,
  );

  @override
  String toString() => r'eventAssistanceDepartureForAccountProvider';
}
