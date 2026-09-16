// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_pending_cases.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Discovery references only. Each case editor owns its command and retry.
/// A server page may omit a case whose save succeeded without confirmation.
// keepalive: Pending case discovery survives closed sheets until confirmation or account reset.

@ProviderFor(EventAssistancePendingCases)
final eventAssistancePendingCasesProvider =
    EventAssistancePendingCasesProvider._();

/// Discovery references only. Each case editor owns its command and retry.
/// A server page may omit a case whose save succeeded without confirmation.
// keepalive: Pending case discovery survives closed sheets until confirmation or account reset.
final class EventAssistancePendingCasesProvider
    extends
        $NotifierProvider<
          EventAssistancePendingCases,
          Set<EventAssistanceCaseScope>
        > {
  /// Discovery references only. Each case editor owns its command and retry.
  /// A server page may omit a case whose save succeeded without confirmation.
  // keepalive: Pending case discovery survives closed sheets until confirmation or account reset.
  EventAssistancePendingCasesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventAssistancePendingCasesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventAssistancePendingCasesHash();

  @$internal
  @override
  EventAssistancePendingCases create() => EventAssistancePendingCases();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<EventAssistanceCaseScope> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<EventAssistanceCaseScope>>(
        value,
      ),
    );
  }
}

String _$eventAssistancePendingCasesHash() =>
    r'8a4f44a888be576c14012ca267e29bcf6c24a86f';

/// Discovery references only. Each case editor owns its command and retry.
/// A server page may omit a case whose save succeeded without confirmation.
// keepalive: Pending case discovery survives closed sheets until confirmation or account reset.

abstract class _$EventAssistancePendingCases
    extends $Notifier<Set<EventAssistanceCaseScope>> {
  Set<EventAssistanceCaseScope> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Set<EventAssistanceCaseScope>,
              Set<EventAssistanceCaseScope>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Set<EventAssistanceCaseScope>,
                Set<EventAssistanceCaseScope>
              >,
              Set<EventAssistanceCaseScope>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
