// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_checkpoint_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The route consumes this outer provider; old-account data is never rendered.

@ProviderFor(EventAssistanceCheckpoint)
final eventAssistanceCheckpointProvider = EventAssistanceCheckpointFamily._();

/// The route consumes this outer provider; old-account data is never rendered.
final class EventAssistanceCheckpointProvider
    extends
        $NotifierProvider<
          EventAssistanceCheckpoint,
          AsyncValue<EventAssistanceCheckpointSession>
        > {
  /// The route consumes this outer provider; old-account data is never rendered.
  EventAssistanceCheckpointProvider._({
    required EventAssistanceCheckpointFamily super.from,
    required EventAssistanceCheckpointScope super.argument,
  }) : super(
         retry: null,
         name: r'eventAssistanceCheckpointProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventAssistanceCheckpointHash();

  @override
  String toString() {
    return r'eventAssistanceCheckpointProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventAssistanceCheckpoint create() => EventAssistanceCheckpoint();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    AsyncValue<EventAssistanceCheckpointSession> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<EventAssistanceCheckpointSession>>(
            value,
          ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceCheckpointProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceCheckpointHash() =>
    r'374fd4651b50ec22314a11dcffff3152e8f1e967';

/// The route consumes this outer provider; old-account data is never rendered.

final class EventAssistanceCheckpointFamily extends $Family
    with
        $ClassFamilyOverride<
          EventAssistanceCheckpoint,
          AsyncValue<EventAssistanceCheckpointSession>,
          AsyncValue<EventAssistanceCheckpointSession>,
          AsyncValue<EventAssistanceCheckpointSession>,
          EventAssistanceCheckpointScope
        > {
  EventAssistanceCheckpointFamily._()
    : super(
        retry: null,
        name: r'eventAssistanceCheckpointProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The route consumes this outer provider; old-account data is never rendered.

  EventAssistanceCheckpointProvider call(
    EventAssistanceCheckpointScope scope,
  ) => EventAssistanceCheckpointProvider._(argument: scope, from: this);

  @override
  String toString() => r'eventAssistanceCheckpointProvider';
}

/// The route consumes this outer provider; old-account data is never rendered.

abstract class _$EventAssistanceCheckpoint
    extends $Notifier<AsyncValue<EventAssistanceCheckpointSession>> {
  late final _$args = ref.$arg as EventAssistanceCheckpointScope;
  EventAssistanceCheckpointScope get scope => _$args;

  AsyncValue<EventAssistanceCheckpointSession> build(
    EventAssistanceCheckpointScope scope,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<EventAssistanceCheckpointSession>,
              AsyncValue<EventAssistanceCheckpointSession>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<EventAssistanceCheckpointSession>,
                AsyncValue<EventAssistanceCheckpointSession>
              >,
              AsyncValue<EventAssistanceCheckpointSession>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(eventAssistanceCheckpointForAccount)
final eventAssistanceCheckpointForAccountProvider =
    EventAssistanceCheckpointForAccountFamily._();

final class EventAssistanceCheckpointForAccountProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventAssistanceCheckpointSession>,
          EventAssistanceCheckpointSession,
          FutureOr<EventAssistanceCheckpointSession>
        >
    with
        $FutureModifier<EventAssistanceCheckpointSession>,
        $FutureProvider<EventAssistanceCheckpointSession> {
  EventAssistanceCheckpointForAccountProvider._({
    required EventAssistanceCheckpointForAccountFamily super.from,
    required (EventAssistanceCheckpointScope, {AuthenticatedSession account})
    super.argument,
  }) : super(
         retry: _noCheckpointReadRetry,
         name: r'eventAssistanceCheckpointForAccountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$eventAssistanceCheckpointForAccountHash();

  @override
  String toString() {
    return r'eventAssistanceCheckpointForAccountProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<EventAssistanceCheckpointSession> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EventAssistanceCheckpointSession> create(Ref ref) {
    final argument =
        this.argument
            as (EventAssistanceCheckpointScope, {AuthenticatedSession account});
    return eventAssistanceCheckpointForAccount(
      ref,
      argument.$1,
      account: argument.account,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceCheckpointForAccountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceCheckpointForAccountHash() =>
    r'1215dc40bff55ee7385e2dcd48fca65a2b122f9a';

final class EventAssistanceCheckpointForAccountFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<EventAssistanceCheckpointSession>,
          (EventAssistanceCheckpointScope, {AuthenticatedSession account})
        > {
  EventAssistanceCheckpointForAccountFamily._()
    : super(
        retry: _noCheckpointReadRetry,
        name: r'eventAssistanceCheckpointForAccountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventAssistanceCheckpointForAccountProvider call(
    EventAssistanceCheckpointScope scope, {
    required AuthenticatedSession account,
  }) => EventAssistanceCheckpointForAccountProvider._(
    argument: (scope, account: account),
    from: this,
  );

  @override
  String toString() => r'eventAssistanceCheckpointForAccountProvider';
}
