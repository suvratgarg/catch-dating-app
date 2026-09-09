// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_membership_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The route consumes this outer provider; old-account data is never rendered.

@ProviderFor(EventAssistanceMembership)
final eventAssistanceMembershipProvider = EventAssistanceMembershipFamily._();

/// The route consumes this outer provider; old-account data is never rendered.
final class EventAssistanceMembershipProvider
    extends
        $NotifierProvider<
          EventAssistanceMembership,
          AsyncValue<EventAssistanceMembershipSession>
        > {
  /// The route consumes this outer provider; old-account data is never rendered.
  EventAssistanceMembershipProvider._({
    required EventAssistanceMembershipFamily super.from,
    required EventAssistanceGuestScope super.argument,
  }) : super(
         retry: null,
         name: r'eventAssistanceMembershipProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventAssistanceMembershipHash();

  @override
  String toString() {
    return r'eventAssistanceMembershipProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventAssistanceMembership create() => EventAssistanceMembership();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    AsyncValue<EventAssistanceMembershipSession> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<EventAssistanceMembershipSession>>(
            value,
          ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceMembershipProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceMembershipHash() =>
    r'025f2bb887b368f8f879d63f909cd77b2eb3b9c7';

/// The route consumes this outer provider; old-account data is never rendered.

final class EventAssistanceMembershipFamily extends $Family
    with
        $ClassFamilyOverride<
          EventAssistanceMembership,
          AsyncValue<EventAssistanceMembershipSession>,
          AsyncValue<EventAssistanceMembershipSession>,
          AsyncValue<EventAssistanceMembershipSession>,
          EventAssistanceGuestScope
        > {
  EventAssistanceMembershipFamily._()
    : super(
        retry: null,
        name: r'eventAssistanceMembershipProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The route consumes this outer provider; old-account data is never rendered.

  EventAssistanceMembershipProvider call(EventAssistanceGuestScope scope) =>
      EventAssistanceMembershipProvider._(argument: scope, from: this);

  @override
  String toString() => r'eventAssistanceMembershipProvider';
}

/// The route consumes this outer provider; old-account data is never rendered.

abstract class _$EventAssistanceMembership
    extends $Notifier<AsyncValue<EventAssistanceMembershipSession>> {
  late final _$args = ref.$arg as EventAssistanceGuestScope;
  EventAssistanceGuestScope get scope => _$args;

  AsyncValue<EventAssistanceMembershipSession> build(
    EventAssistanceGuestScope scope,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<EventAssistanceMembershipSession>,
              AsyncValue<EventAssistanceMembershipSession>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<EventAssistanceMembershipSession>,
                AsyncValue<EventAssistanceMembershipSession>
              >,
              AsyncValue<EventAssistanceMembershipSession>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(eventAssistanceMembershipForAccount)
final eventAssistanceMembershipForAccountProvider =
    EventAssistanceMembershipForAccountFamily._();

final class EventAssistanceMembershipForAccountProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventAssistanceMembershipSession>,
          EventAssistanceMembershipSession,
          FutureOr<EventAssistanceMembershipSession>
        >
    with
        $FutureModifier<EventAssistanceMembershipSession>,
        $FutureProvider<EventAssistanceMembershipSession> {
  EventAssistanceMembershipForAccountProvider._({
    required EventAssistanceMembershipForAccountFamily super.from,
    required (EventAssistanceGuestScope, {AuthenticatedSession account})
    super.argument,
  }) : super(
         retry: _noMembershipReadRetry,
         name: r'eventAssistanceMembershipForAccountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$eventAssistanceMembershipForAccountHash();

  @override
  String toString() {
    return r'eventAssistanceMembershipForAccountProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<EventAssistanceMembershipSession> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EventAssistanceMembershipSession> create(Ref ref) {
    final argument =
        this.argument
            as (EventAssistanceGuestScope, {AuthenticatedSession account});
    return eventAssistanceMembershipForAccount(
      ref,
      argument.$1,
      account: argument.account,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceMembershipForAccountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceMembershipForAccountHash() =>
    r'd5e07790644d1d31aae814d4b665a4a9adedb70c';

final class EventAssistanceMembershipForAccountFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<EventAssistanceMembershipSession>,
          (EventAssistanceGuestScope, {AuthenticatedSession account})
        > {
  EventAssistanceMembershipForAccountFamily._()
    : super(
        retry: _noMembershipReadRetry,
        name: r'eventAssistanceMembershipForAccountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventAssistanceMembershipForAccountProvider call(
    EventAssistanceGuestScope scope, {
    required AuthenticatedSession account,
  }) => EventAssistanceMembershipForAccountProvider._(
    argument: (scope, account: account),
    from: this,
  );

  @override
  String toString() => r'eventAssistanceMembershipForAccountProvider';
}
