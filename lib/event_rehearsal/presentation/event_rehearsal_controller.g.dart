// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_rehearsal_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EventRehearsalController)
final eventRehearsalControllerProvider = EventRehearsalControllerProvider._();

final class EventRehearsalControllerProvider
    extends $NotifierProvider<EventRehearsalController, void> {
  EventRehearsalControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventRehearsalControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventRehearsalControllerHash();

  @$internal
  @override
  EventRehearsalController create() => EventRehearsalController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$eventRehearsalControllerHash() =>
    r'99e944b3cc2af3bf0668fefc012f85ef8bd64a9c';

abstract class _$EventRehearsalController extends $Notifier<void> {
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
