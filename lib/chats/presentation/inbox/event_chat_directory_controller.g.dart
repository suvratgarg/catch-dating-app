// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_chat_directory_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EventChatDirectoryController)
final eventChatDirectoryControllerProvider =
    EventChatDirectoryControllerProvider._();

final class EventChatDirectoryControllerProvider
    extends
        $AsyncNotifierProvider<
          EventChatDirectoryController,
          EventChatDirectoryPage
        > {
  EventChatDirectoryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventChatDirectoryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventChatDirectoryControllerHash();

  @$internal
  @override
  EventChatDirectoryController create() => EventChatDirectoryController();
}

String _$eventChatDirectoryControllerHash() =>
    r'c094574f1f7e2a7341bf7e78bb9582dc620dced1';

abstract class _$EventChatDirectoryController
    extends $AsyncNotifier<EventChatDirectoryPage> {
  FutureOr<EventChatDirectoryPage> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<EventChatDirectoryPage>, EventChatDirectoryPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<EventChatDirectoryPage>,
                EventChatDirectoryPage
              >,
              AsyncValue<EventChatDirectoryPage>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
