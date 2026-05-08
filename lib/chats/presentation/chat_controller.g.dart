// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern A: Action controller + static Mutations**
///
/// Holds no Riverpod state ([build] returns void). [Mutation]s track the
/// lifecycle of single-shot operations so the UI can show loading spinners
/// and error banners. UI wraps calls in `mutation.run(ref, ...)`.

@ProviderFor(ChatController)
final chatControllerProvider = ChatControllerProvider._();

/// **Pattern A: Action controller + static Mutations**
///
/// Holds no Riverpod state ([build] returns void). [Mutation]s track the
/// lifecycle of single-shot operations so the UI can show loading spinners
/// and error banners. UI wraps calls in `mutation.run(ref, ...)`.
final class ChatControllerProvider
    extends $NotifierProvider<ChatController, void> {
  /// **Pattern A: Action controller + static Mutations**
  ///
  /// Holds no Riverpod state ([build] returns void). [Mutation]s track the
  /// lifecycle of single-shot operations so the UI can show loading spinners
  /// and error banners. UI wraps calls in `mutation.run(ref, ...)`.
  ChatControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatControllerHash();

  @$internal
  @override
  ChatController create() => ChatController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$chatControllerHash() => r'27bb07f30b6528af4270deadb49073e39f5f9aed';

/// **Pattern A: Action controller + static Mutations**
///
/// Holds no Riverpod state ([build] returns void). [Mutation]s track the
/// lifecycle of single-shot operations so the UI can show loading spinners
/// and error banners. UI wraps calls in `mutation.run(ref, ...)`.

abstract class _$ChatController extends $Notifier<void> {
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

@ProviderFor(chatUnreadResetter)
final chatUnreadResetterProvider = ChatUnreadResetterProvider._();

final class ChatUnreadResetterProvider
    extends
        $FunctionalProvider<
          ChatUnreadResetter,
          ChatUnreadResetter,
          ChatUnreadResetter
        >
    with $Provider<ChatUnreadResetter> {
  ChatUnreadResetterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatUnreadResetterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatUnreadResetterHash();

  @$internal
  @override
  $ProviderElement<ChatUnreadResetter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChatUnreadResetter create(Ref ref) {
    return chatUnreadResetter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatUnreadResetter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatUnreadResetter>(value),
    );
  }
}

String _$chatUnreadResetterHash() =>
    r'ff424538592002dccc8574c33393a4ddee490091';
