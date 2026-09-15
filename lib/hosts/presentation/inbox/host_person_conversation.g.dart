// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_person_conversation.dart';

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
