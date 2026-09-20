// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_pending_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Discovery references only. Each settings editor owns its command and retry.
/// Current event setup may omit a group whose setting save remains unconfirmed.
// keepalive: Pending setting discovery survives closed sheets until confirmation or account reset.

@ProviderFor(EventAssistancePendingSettings)
final eventAssistancePendingSettingsProvider =
    EventAssistancePendingSettingsProvider._();

/// Discovery references only. Each settings editor owns its command and retry.
/// Current event setup may omit a group whose setting save remains unconfirmed.
// keepalive: Pending setting discovery survives closed sheets until confirmation or account reset.
final class EventAssistancePendingSettingsProvider
    extends
        $NotifierProvider<
          EventAssistancePendingSettings,
          Set<EventAssistanceGroupScope>
        > {
  /// Discovery references only. Each settings editor owns its command and retry.
  /// Current event setup may omit a group whose setting save remains unconfirmed.
  // keepalive: Pending setting discovery survives closed sheets until confirmation or account reset.
  EventAssistancePendingSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventAssistancePendingSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventAssistancePendingSettingsHash();

  @$internal
  @override
  EventAssistancePendingSettings create() => EventAssistancePendingSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<EventAssistanceGroupScope> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<EventAssistanceGroupScope>>(
        value,
      ),
    );
  }
}

String _$eventAssistancePendingSettingsHash() =>
    r'943a2673c65b4a07da155d3b048fcde6e798c983';

/// Discovery references only. Each settings editor owns its command and retry.
/// Current event setup may omit a group whose setting save remains unconfirmed.
// keepalive: Pending setting discovery survives closed sheets until confirmation or account reset.

abstract class _$EventAssistancePendingSettings
    extends $Notifier<Set<EventAssistanceGroupScope>> {
  Set<EventAssistanceGroupScope> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Set<EventAssistanceGroupScope>,
              Set<EventAssistanceGroupScope>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Set<EventAssistanceGroupScope>,
                Set<EventAssistanceGroupScope>
              >,
              Set<EventAssistanceGroupScope>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
