// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_confirmation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(paymentConfirmationController)
final paymentConfirmationControllerProvider =
    PaymentConfirmationControllerProvider._();

final class PaymentConfirmationControllerProvider
    extends
        $FunctionalProvider<
          PaymentConfirmationController,
          PaymentConfirmationController,
          PaymentConfirmationController
        >
    with $Provider<PaymentConfirmationController> {
  PaymentConfirmationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentConfirmationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentConfirmationControllerHash();

  @$internal
  @override
  $ProviderElement<PaymentConfirmationController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaymentConfirmationController create(Ref ref) {
    return paymentConfirmationController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentConfirmationController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentConfirmationController>(
        value,
      ),
    );
  }
}

String _$paymentConfirmationControllerHash() =>
    r'9ba8d00bd1a8a90f8b11d974e8df3b23ca66c372';
