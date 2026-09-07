// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_participation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventAssistanceParticipation)
final eventAssistanceParticipationProvider =
    EventAssistanceParticipationFamily._();

final class EventAssistanceParticipationProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventParticipationSession>,
          EventParticipationSession,
          FutureOr<EventParticipationSession>
        >
    with
        $FutureModifier<EventParticipationSession>,
        $FutureProvider<EventParticipationSession> {
  EventAssistanceParticipationProvider._({
    required EventAssistanceParticipationFamily super.from,
    required EventAssistanceGuestScope super.argument,
  }) : super(
         retry: null,
         name: r'eventAssistanceParticipationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventAssistanceParticipationHash();

  @override
  String toString() {
    return r'eventAssistanceParticipationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<EventParticipationSession> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EventParticipationSession> create(Ref ref) {
    final argument = this.argument as EventAssistanceGuestScope;
    return eventAssistanceParticipation(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceParticipationProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceParticipationHash() =>
    r'454ae9ca7bc850f4be57de92c99271461a580293';

final class EventAssistanceParticipationFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<EventParticipationSession>,
          EventAssistanceGuestScope
        > {
  EventAssistanceParticipationFamily._()
    : super(
        retry: null,
        name: r'eventAssistanceParticipationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventAssistanceParticipationProvider call(EventAssistanceGuestScope scope) =>
      EventAssistanceParticipationProvider._(argument: scope, from: this);

  @override
  String toString() => r'eventAssistanceParticipationProvider';
}

@ProviderFor(EventAssistanceParticipationController)
final eventAssistanceParticipationControllerProvider =
    EventAssistanceParticipationControllerProvider._();

final class EventAssistanceParticipationControllerProvider
    extends $NotifierProvider<EventAssistanceParticipationController, void> {
  EventAssistanceParticipationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventAssistanceParticipationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$eventAssistanceParticipationControllerHash();

  @$internal
  @override
  EventAssistanceParticipationController create() =>
      EventAssistanceParticipationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$eventAssistanceParticipationControllerHash() =>
    r'06b8146344eacd773e85c957df467cc27a7c323b';

abstract class _$EventAssistanceParticipationController
    extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
