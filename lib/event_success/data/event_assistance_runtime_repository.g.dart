// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_runtime_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventAssistanceRuntimeRepository)
final eventAssistanceRuntimeRepositoryProvider =
    EventAssistanceRuntimeRepositoryProvider._();

final class EventAssistanceRuntimeRepositoryProvider
    extends
        $FunctionalProvider<
          EventAssistanceRuntimeRepository,
          EventAssistanceRuntimeRepository,
          EventAssistanceRuntimeRepository
        >
    with $Provider<EventAssistanceRuntimeRepository> {
  EventAssistanceRuntimeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventAssistanceRuntimeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventAssistanceRuntimeRepositoryHash();

  @$internal
  @override
  $ProviderElement<EventAssistanceRuntimeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EventAssistanceRuntimeRepository create(Ref ref) {
    return eventAssistanceRuntimeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventAssistanceRuntimeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventAssistanceRuntimeRepository>(
        value,
      ),
    );
  }
}

String _$eventAssistanceRuntimeRepositoryHash() =>
    r'0042e3f1273be97d7d547ce6de9c7f3b61a52b22';
