// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_success_live_effects_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventSuccessLiveEffectsController)
final eventSuccessLiveEffectsControllerProvider =
    EventSuccessLiveEffectsControllerProvider._();

final class EventSuccessLiveEffectsControllerProvider
    extends
        $FunctionalProvider<
          EventSuccessLiveEffectsController,
          EventSuccessLiveEffectsController,
          EventSuccessLiveEffectsController
        >
    with $Provider<EventSuccessLiveEffectsController> {
  EventSuccessLiveEffectsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventSuccessLiveEffectsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$eventSuccessLiveEffectsControllerHash();

  @$internal
  @override
  $ProviderElement<EventSuccessLiveEffectsController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EventSuccessLiveEffectsController create(Ref ref) {
    return eventSuccessLiveEffectsController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventSuccessLiveEffectsController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventSuccessLiveEffectsController>(
        value,
      ),
    );
  }
}

String _$eventSuccessLiveEffectsControllerHash() =>
    r'2f8571ab632d7bb7eab9cd4ee4c54dd676a71795';
