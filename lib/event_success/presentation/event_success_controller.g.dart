// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_success_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EventSuccessController)
final eventSuccessControllerProvider = EventSuccessControllerProvider._();

final class EventSuccessControllerProvider
    extends $NotifierProvider<EventSuccessController, void> {
  EventSuccessControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventSuccessControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventSuccessControllerHash();

  @$internal
  @override
  EventSuccessController create() => EventSuccessController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$eventSuccessControllerHash() =>
    r'0b42ba5a286ba4537d0147b677e2abdb6d2a4780';

abstract class _$EventSuccessController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
