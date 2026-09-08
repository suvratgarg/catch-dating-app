// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_late_join_setting_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventAssistanceLateJoinSettingRepository)
final eventAssistanceLateJoinSettingRepositoryProvider =
    EventAssistanceLateJoinSettingRepositoryProvider._();

final class EventAssistanceLateJoinSettingRepositoryProvider
    extends
        $FunctionalProvider<
          EventAssistanceLateJoinSettingRepository,
          EventAssistanceLateJoinSettingRepository,
          EventAssistanceLateJoinSettingRepository
        >
    with $Provider<EventAssistanceLateJoinSettingRepository> {
  EventAssistanceLateJoinSettingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventAssistanceLateJoinSettingRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$eventAssistanceLateJoinSettingRepositoryHash();

  @$internal
  @override
  $ProviderElement<EventAssistanceLateJoinSettingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EventAssistanceLateJoinSettingRepository create(Ref ref) {
    return eventAssistanceLateJoinSettingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventAssistanceLateJoinSettingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EventAssistanceLateJoinSettingRepository>(value),
    );
  }
}

String _$eventAssistanceLateJoinSettingRepositoryHash() =>
    r'ac4dc663e31ef4af82d131c584be277cad0ced90';
