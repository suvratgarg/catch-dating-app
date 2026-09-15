// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_inbox_whatsapp_pages.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HostInboxWhatsappPages)
final hostInboxWhatsappPagesProvider = HostInboxWhatsappPagesFamily._();

final class HostInboxWhatsappPagesProvider
    extends
        $AsyncNotifierProvider<
          HostInboxWhatsappPages,
          HostInboxWhatsappPageState
        > {
  HostInboxWhatsappPagesProvider._({
    required HostInboxWhatsappPagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hostInboxWhatsappPagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostInboxWhatsappPagesHash();

  @override
  String toString() {
    return r'hostInboxWhatsappPagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HostInboxWhatsappPages create() => HostInboxWhatsappPages();

  @override
  bool operator ==(Object other) {
    return other is HostInboxWhatsappPagesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostInboxWhatsappPagesHash() =>
    r'5e00f4e99cae7882985b5aa3dd575cc235e935a0';

final class HostInboxWhatsappPagesFamily extends $Family
    with
        $ClassFamilyOverride<
          HostInboxWhatsappPages,
          AsyncValue<HostInboxWhatsappPageState>,
          HostInboxWhatsappPageState,
          FutureOr<HostInboxWhatsappPageState>,
          String
        > {
  HostInboxWhatsappPagesFamily._()
    : super(
        retry: null,
        name: r'hostInboxWhatsappPagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostInboxWhatsappPagesProvider call(String organizerId) =>
      HostInboxWhatsappPagesProvider._(argument: organizerId, from: this);

  @override
  String toString() => r'hostInboxWhatsappPagesProvider';
}

abstract class _$HostInboxWhatsappPages
    extends $AsyncNotifier<HostInboxWhatsappPageState> {
  late final _$args = ref.$arg as String;
  String get organizerId => _$args;

  FutureOr<HostInboxWhatsappPageState> build(String organizerId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<HostInboxWhatsappPageState>,
              HostInboxWhatsappPageState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<HostInboxWhatsappPageState>,
                HostInboxWhatsappPageState
              >,
              AsyncValue<HostInboxWhatsappPageState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
