// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_cases_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventAssistanceCasesRepository)
final eventAssistanceCasesRepositoryProvider =
    EventAssistanceCasesRepositoryProvider._();

final class EventAssistanceCasesRepositoryProvider
    extends
        $FunctionalProvider<
          EventAssistanceCasesRepository,
          EventAssistanceCasesRepository,
          EventAssistanceCasesRepository
        >
    with $Provider<EventAssistanceCasesRepository> {
  EventAssistanceCasesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventAssistanceCasesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventAssistanceCasesRepositoryHash();

  @$internal
  @override
  $ProviderElement<EventAssistanceCasesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EventAssistanceCasesRepository create(Ref ref) {
    return eventAssistanceCasesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventAssistanceCasesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventAssistanceCasesRepository>(
        value,
      ),
    );
  }
}

String _$eventAssistanceCasesRepositoryHash() =>
    r'7f79c5b29479fd46e5f8b19c1b502054cb79303f';
