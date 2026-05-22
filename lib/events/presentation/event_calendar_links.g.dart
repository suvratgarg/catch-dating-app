// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_calendar_links.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventCalendarController)
final eventCalendarControllerProvider = EventCalendarControllerProvider._();

final class EventCalendarControllerProvider
    extends
        $FunctionalProvider<
          EventCalendarController,
          EventCalendarController,
          EventCalendarController
        >
    with $Provider<EventCalendarController> {
  EventCalendarControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventCalendarControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventCalendarControllerHash();

  @$internal
  @override
  $ProviderElement<EventCalendarController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EventCalendarController create(Ref ref) {
    return eventCalendarController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventCalendarController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventCalendarController>(value),
    );
  }
}

String _$eventCalendarControllerHash() =>
    r'7bc402933186825f159914e24b4f1ee303c73f37';
