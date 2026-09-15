// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_person_conversation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hostPersonWhatsappDetail)
final hostPersonWhatsappDetailProvider = HostPersonWhatsappDetailFamily._();

final class HostPersonWhatsappDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostWhatsappThreadDetail>,
          HostWhatsappThreadDetail,
          FutureOr<HostWhatsappThreadDetail>
        >
    with
        $FutureModifier<HostWhatsappThreadDetail>,
        $FutureProvider<HostWhatsappThreadDetail> {
  HostPersonWhatsappDetailProvider._({
    required HostPersonWhatsappDetailFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'hostPersonWhatsappDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostPersonWhatsappDetailHash();

  @override
  String toString() {
    return r'hostPersonWhatsappDetailProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<HostWhatsappThreadDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostWhatsappThreadDetail> create(Ref ref) {
    final argument = this.argument as (String, String);
    return hostPersonWhatsappDetail(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is HostPersonWhatsappDetailProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostPersonWhatsappDetailHash() =>
    r'6c032abcf7ba1b9a7200787ce4b7f55f5a7facea';

final class HostPersonWhatsappDetailFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<HostWhatsappThreadDetail>,
          (String, String)
        > {
  HostPersonWhatsappDetailFamily._()
    : super(
        retry: null,
        name: r'hostPersonWhatsappDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostPersonWhatsappDetailProvider call(String organizerId, String threadId) =>
      HostPersonWhatsappDetailProvider._(
        argument: (organizerId, threadId),
        from: this,
      );

  @override
  String toString() => r'hostPersonWhatsappDetailProvider';
}

@ProviderFor(hostPersonConversationController)
final hostPersonConversationControllerProvider =
    HostPersonConversationControllerProvider._();

final class HostPersonConversationControllerProvider
    extends
        $FunctionalProvider<
          HostPersonConversationController,
          HostPersonConversationController,
          HostPersonConversationController
        >
    with $Provider<HostPersonConversationController> {
  HostPersonConversationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostPersonConversationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostPersonConversationControllerHash();

  @$internal
  @override
  $ProviderElement<HostPersonConversationController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HostPersonConversationController create(Ref ref) {
    return hostPersonConversationController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HostPersonConversationController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HostPersonConversationController>(
        value,
      ),
    );
  }
}

String _$hostPersonConversationControllerHash() =>
    r'69c71c32aead454bb96be93842d65b640f47e1bd';
