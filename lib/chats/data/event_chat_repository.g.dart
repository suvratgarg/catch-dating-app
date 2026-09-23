// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_chat_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventChatRepository)
final eventChatRepositoryProvider = EventChatRepositoryProvider._();

final class EventChatRepositoryProvider
    extends
        $FunctionalProvider<
          EventChatRepository,
          EventChatRepository,
          EventChatRepository
        >
    with $Provider<EventChatRepository> {
  EventChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventChatRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventChatRepositoryHash();

  @$internal
  @override
  $ProviderElement<EventChatRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EventChatRepository create(Ref ref) {
    return eventChatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventChatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventChatRepository>(value),
    );
  }
}

String _$eventChatRepositoryHash() =>
    r'b2f76ebbf232a46f408db561f07466d3d586fdda';
