// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_payment_account_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hostPaymentAccountRepository)
final hostPaymentAccountRepositoryProvider =
    HostPaymentAccountRepositoryProvider._();

final class HostPaymentAccountRepositoryProvider
    extends
        $FunctionalProvider<
          HostPaymentAccountRepository,
          HostPaymentAccountRepository,
          HostPaymentAccountRepository
        >
    with $Provider<HostPaymentAccountRepository> {
  HostPaymentAccountRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostPaymentAccountRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostPaymentAccountRepositoryHash();

  @$internal
  @override
  $ProviderElement<HostPaymentAccountRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HostPaymentAccountRepository create(Ref ref) {
    return hostPaymentAccountRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HostPaymentAccountRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HostPaymentAccountRepository>(value),
    );
  }
}

String _$hostPaymentAccountRepositoryHash() =>
    r'c3f84498968d318c993f04ff28098ba27bd60d06';

@ProviderFor(watchHostPaymentAccount)
final watchHostPaymentAccountProvider = WatchHostPaymentAccountFamily._();

final class WatchHostPaymentAccountProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostPaymentAccount?>,
          HostPaymentAccount?,
          Stream<HostPaymentAccount?>
        >
    with
        $FutureModifier<HostPaymentAccount?>,
        $StreamProvider<HostPaymentAccount?> {
  WatchHostPaymentAccountProvider._({
    required WatchHostPaymentAccountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchHostPaymentAccountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchHostPaymentAccountHash();

  @override
  String toString() {
    return r'watchHostPaymentAccountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<HostPaymentAccount?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<HostPaymentAccount?> create(Ref ref) {
    final argument = this.argument as String;
    return watchHostPaymentAccount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchHostPaymentAccountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchHostPaymentAccountHash() =>
    r'232413775af7966205a8594091cc0d1dce2c79ec';

final class WatchHostPaymentAccountFamily extends $Family
    with $FunctionalFamilyOverride<Stream<HostPaymentAccount?>, String> {
  WatchHostPaymentAccountFamily._()
    : super(
        retry: null,
        name: r'watchHostPaymentAccountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchHostPaymentAccountProvider call(String uid) =>
      WatchHostPaymentAccountProvider._(argument: uid, from: this);

  @override
  String toString() => r'watchHostPaymentAccountProvider';
}
