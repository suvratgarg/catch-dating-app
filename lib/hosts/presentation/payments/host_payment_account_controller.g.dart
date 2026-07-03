// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_payment_account_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hostPaymentAccountController)
final hostPaymentAccountControllerProvider =
    HostPaymentAccountControllerProvider._();

final class HostPaymentAccountControllerProvider
    extends
        $FunctionalProvider<
          HostPaymentAccountActions,
          HostPaymentAccountActions,
          HostPaymentAccountActions
        >
    with $Provider<HostPaymentAccountActions> {
  HostPaymentAccountControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostPaymentAccountControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostPaymentAccountControllerHash();

  @$internal
  @override
  $ProviderElement<HostPaymentAccountActions> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HostPaymentAccountActions create(Ref ref) {
    return hostPaymentAccountController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HostPaymentAccountActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HostPaymentAccountActions>(value),
    );
  }
}

String _$hostPaymentAccountControllerHash() =>
    r'009bc28f98d079b05d31b129d3f82f2636d28e83';
