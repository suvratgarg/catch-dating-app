// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_pending_deliveries.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Discovery references only. Each delivery controller owns its command and retry.
/// A server page may omit a message whose handoff succeeded without confirmation.
// keepalive: Pending delivery discovery survives closed sheets until confirmation or account reset.

@ProviderFor(EventAssistancePendingDeliveries)
final eventAssistancePendingDeliveriesProvider =
    EventAssistancePendingDeliveriesProvider._();

/// Discovery references only. Each delivery controller owns its command and retry.
/// A server page may omit a message whose handoff succeeded without confirmation.
// keepalive: Pending delivery discovery survives closed sheets until confirmation or account reset.
final class EventAssistancePendingDeliveriesProvider
    extends
        $NotifierProvider<
          EventAssistancePendingDeliveries,
          Set<EventAssistanceDeliveryScope>
        > {
  /// Discovery references only. Each delivery controller owns its command and retry.
  /// A server page may omit a message whose handoff succeeded without confirmation.
  // keepalive: Pending delivery discovery survives closed sheets until confirmation or account reset.
  EventAssistancePendingDeliveriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventAssistancePendingDeliveriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventAssistancePendingDeliveriesHash();

  @$internal
  @override
  EventAssistancePendingDeliveries create() =>
      EventAssistancePendingDeliveries();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<EventAssistanceDeliveryScope> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<EventAssistanceDeliveryScope>>(
        value,
      ),
    );
  }
}

String _$eventAssistancePendingDeliveriesHash() =>
    r'35522fd31856a6e2de2f9656816422a43b492a5c';

/// Discovery references only. Each delivery controller owns its command and retry.
/// A server page may omit a message whose handoff succeeded without confirmation.
// keepalive: Pending delivery discovery survives closed sheets until confirmation or account reset.

abstract class _$EventAssistancePendingDeliveries
    extends $Notifier<Set<EventAssistanceDeliveryScope>> {
  Set<EventAssistanceDeliveryScope> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Set<EventAssistanceDeliveryScope>,
              Set<EventAssistanceDeliveryScope>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Set<EventAssistanceDeliveryScope>,
                Set<EventAssistanceDeliveryScope>
              >,
              Set<EventAssistanceDeliveryScope>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
