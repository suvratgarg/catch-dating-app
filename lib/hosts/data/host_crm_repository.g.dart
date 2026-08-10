// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_crm_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hostCrmRepository)
final hostCrmRepositoryProvider = HostCrmRepositoryProvider._();

final class HostCrmRepositoryProvider
    extends
        $FunctionalProvider<
          HostCrmRepository,
          HostCrmRepository,
          HostCrmRepository
        >
    with $Provider<HostCrmRepository> {
  HostCrmRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostCrmRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostCrmRepositoryHash();

  @$internal
  @override
  $ProviderElement<HostCrmRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HostCrmRepository create(Ref ref) {
    return hostCrmRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HostCrmRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HostCrmRepository>(value),
    );
  }
}

String _$hostCrmRepositoryHash() => r'57853e0668b362f13b2e2578e32747ba5e46db88';

@ProviderFor(hostCrmSummary)
final hostCrmSummaryProvider = HostCrmSummaryFamily._();

final class HostCrmSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostCrmSummary>,
          HostCrmSummary,
          FutureOr<HostCrmSummary>
        >
    with $FutureModifier<HostCrmSummary>, $FutureProvider<HostCrmSummary> {
  HostCrmSummaryProvider._({
    required HostCrmSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hostCrmSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostCrmSummaryHash();

  @override
  String toString() {
    return r'hostCrmSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HostCrmSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostCrmSummary> create(Ref ref) {
    final argument = this.argument as String;
    return hostCrmSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HostCrmSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostCrmSummaryHash() => r'446fd2c4a736f7611f1e86b1a86d205e15815c00';

final class HostCrmSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HostCrmSummary>, String> {
  HostCrmSummaryFamily._()
    : super(
        retry: null,
        name: r'hostCrmSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostCrmSummaryProvider call(String organizerId) =>
      HostCrmSummaryProvider._(argument: organizerId, from: this);

  @override
  String toString() => r'hostCrmSummaryProvider';
}
