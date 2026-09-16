// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_host_guests_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EventAssistanceHostGuests)
final eventAssistanceHostGuestsProvider = EventAssistanceHostGuestsFamily._();

final class EventAssistanceHostGuestsProvider
    extends
        $NotifierProvider<
          EventAssistanceHostGuests,
          AsyncValue<EventAssistanceHostGuestsSession>
        > {
  EventAssistanceHostGuestsProvider._({
    required EventAssistanceHostGuestsFamily super.from,
    required EventAssistanceGuestSelection super.argument,
  }) : super(
         retry: null,
         name: r'eventAssistanceHostGuestsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventAssistanceHostGuestsHash();

  @override
  String toString() {
    return r'eventAssistanceHostGuestsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventAssistanceHostGuests create() => EventAssistanceHostGuests();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    AsyncValue<EventAssistanceHostGuestsSession> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<EventAssistanceHostGuestsSession>>(
            value,
          ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceHostGuestsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceHostGuestsHash() =>
    r'a7283bfdc6d12858276510fcfcdf8cd67036fd3e';

final class EventAssistanceHostGuestsFamily extends $Family
    with
        $ClassFamilyOverride<
          EventAssistanceHostGuests,
          AsyncValue<EventAssistanceHostGuestsSession>,
          AsyncValue<EventAssistanceHostGuestsSession>,
          AsyncValue<EventAssistanceHostGuestsSession>,
          EventAssistanceGuestSelection
        > {
  EventAssistanceHostGuestsFamily._()
    : super(
        retry: null,
        name: r'eventAssistanceHostGuestsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventAssistanceHostGuestsProvider call(
    EventAssistanceGuestSelection selection,
  ) => EventAssistanceHostGuestsProvider._(argument: selection, from: this);

  @override
  String toString() => r'eventAssistanceHostGuestsProvider';
}

abstract class _$EventAssistanceHostGuests
    extends $Notifier<AsyncValue<EventAssistanceHostGuestsSession>> {
  late final _$args = ref.$arg as EventAssistanceGuestSelection;
  EventAssistanceGuestSelection get selection => _$args;

  AsyncValue<EventAssistanceHostGuestsSession> build(
    EventAssistanceGuestSelection selection,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<EventAssistanceHostGuestsSession>,
              AsyncValue<EventAssistanceHostGuestsSession>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<EventAssistanceHostGuestsSession>,
                AsyncValue<EventAssistanceHostGuestsSession>
              >,
              AsyncValue<EventAssistanceHostGuestsSession>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(eventAssistanceHostGuestsForAccount)
final eventAssistanceHostGuestsForAccountProvider =
    EventAssistanceHostGuestsForAccountFamily._();

final class EventAssistanceHostGuestsForAccountProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventAssistanceHostGuestsSession>,
          EventAssistanceHostGuestsSession,
          FutureOr<EventAssistanceHostGuestsSession>
        >
    with
        $FutureModifier<EventAssistanceHostGuestsSession>,
        $FutureProvider<EventAssistanceHostGuestsSession> {
  EventAssistanceHostGuestsForAccountProvider._({
    required EventAssistanceHostGuestsForAccountFamily super.from,
    required (EventAssistanceGuestSelection, {String accountId}) super.argument,
  }) : super(
         retry: null,
         name: r'eventAssistanceHostGuestsForAccountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$eventAssistanceHostGuestsForAccountHash();

  @override
  String toString() {
    return r'eventAssistanceHostGuestsForAccountProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<EventAssistanceHostGuestsSession> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EventAssistanceHostGuestsSession> create(Ref ref) {
    final argument =
        this.argument as (EventAssistanceGuestSelection, {String accountId});
    return eventAssistanceHostGuestsForAccount(
      ref,
      argument.$1,
      accountId: argument.accountId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceHostGuestsForAccountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceHostGuestsForAccountHash() =>
    r'4aa51e62a31fc8def788f25007d161a808103d2a';

final class EventAssistanceHostGuestsForAccountFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<EventAssistanceHostGuestsSession>,
          (EventAssistanceGuestSelection, {String accountId})
        > {
  EventAssistanceHostGuestsForAccountFamily._()
    : super(
        retry: null,
        name: r'eventAssistanceHostGuestsForAccountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventAssistanceHostGuestsForAccountProvider call(
    EventAssistanceGuestSelection selection, {
    required String accountId,
  }) => EventAssistanceHostGuestsForAccountProvider._(
    argument: (selection, accountId: accountId),
    from: this,
  );

  @override
  String toString() => r'eventAssistanceHostGuestsForAccountProvider';
}
