// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_participation_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventAssistanceParticipationRepository)
final eventAssistanceParticipationRepositoryProvider =
    EventAssistanceParticipationRepositoryProvider._();

final class EventAssistanceParticipationRepositoryProvider
    extends
        $FunctionalProvider<
          EventAssistanceParticipationRepository,
          EventAssistanceParticipationRepository,
          EventAssistanceParticipationRepository
        >
    with $Provider<EventAssistanceParticipationRepository> {
  EventAssistanceParticipationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventAssistanceParticipationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$eventAssistanceParticipationRepositoryHash();

  @$internal
  @override
  $ProviderElement<EventAssistanceParticipationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EventAssistanceParticipationRepository create(Ref ref) {
    return eventAssistanceParticipationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventAssistanceParticipationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EventAssistanceParticipationRepository>(value),
    );
  }
}

String _$eventAssistanceParticipationRepositoryHash() =>
    r'f5d69e6034b3f9897559013e86e22563ec4851c6';
