// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_rehearsal_entry_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One bounded upcoming-event window; failed lookups remain errors rather than
/// being presented as an organizer with no event or no configured defaults.

@ProviderFor(eventRehearsalEntry)
final eventRehearsalEntryProvider = EventRehearsalEntryFamily._();

/// One bounded upcoming-event window; failed lookups remain errors rather than
/// being presented as an organizer with no event or no configured defaults.

final class EventRehearsalEntryProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventRehearsalEntryData>,
          EventRehearsalEntryData,
          FutureOr<EventRehearsalEntryData>
        >
    with
        $FutureModifier<EventRehearsalEntryData>,
        $FutureProvider<EventRehearsalEntryData> {
  /// One bounded upcoming-event window; failed lookups remain errors rather than
  /// being presented as an organizer with no event or no configured defaults.
  EventRehearsalEntryProvider._({
    required EventRehearsalEntryFamily super.from,
    required (String, String?) super.argument,
  }) : super(
         retry: null,
         name: r'eventRehearsalEntryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventRehearsalEntryHash();

  @override
  String toString() {
    return r'eventRehearsalEntryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<EventRehearsalEntryData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EventRehearsalEntryData> create(Ref ref) {
    final argument = this.argument as (String, String?);
    return eventRehearsalEntry(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is EventRehearsalEntryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventRehearsalEntryHash() =>
    r'f9624dd4f33773de73049b224051ad80a6a41297';

/// One bounded upcoming-event window; failed lookups remain errors rather than
/// being presented as an organizer with no event or no configured defaults.

final class EventRehearsalEntryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<EventRehearsalEntryData>,
          (String, String?)
        > {
  EventRehearsalEntryFamily._()
    : super(
        retry: null,
        name: r'eventRehearsalEntryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One bounded upcoming-event window; failed lookups remain errors rather than
  /// being presented as an organizer with no event or no configured defaults.

  EventRehearsalEntryProvider call(String organizerId, String? sourceEventId) =>
      EventRehearsalEntryProvider._(
        argument: (organizerId, sourceEventId),
        from: this,
      );

  @override
  String toString() => r'eventRehearsalEntryProvider';
}
