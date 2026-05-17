// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_recap_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventRecapViewModel)
final eventRecapViewModelProvider = EventRecapViewModelFamily._();

final class EventRecapViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventRecapViewModel?>,
          AsyncValue<EventRecapViewModel?>,
          AsyncValue<EventRecapViewModel?>
        >
    with $Provider<AsyncValue<EventRecapViewModel?>> {
  EventRecapViewModelProvider._({
    required EventRecapViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventRecapViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventRecapViewModelHash();

  @override
  String toString() {
    return r'eventRecapViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<EventRecapViewModel?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<EventRecapViewModel?> create(Ref ref) {
    final argument = this.argument as String;
    return eventRecapViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<EventRecapViewModel?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<EventRecapViewModel?>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventRecapViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventRecapViewModelHash() =>
    r'4ad09975f9b1acd783e77d3b8f6d04a0f2114ee6';

final class EventRecapViewModelFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<EventRecapViewModel?>, String> {
  EventRecapViewModelFamily._()
    : super(
        retry: null,
        name: r'eventRecapViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventRecapViewModelProvider call(String eventId) =>
      EventRecapViewModelProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventRecapViewModelProvider';
}
