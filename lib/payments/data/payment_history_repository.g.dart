// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_history_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(paymentHistoryRepository)
final paymentHistoryRepositoryProvider = PaymentHistoryRepositoryProvider._();

final class PaymentHistoryRepositoryProvider
    extends
        $FunctionalProvider<
          PaymentHistoryRepository,
          PaymentHistoryRepository,
          PaymentHistoryRepository
        >
    with $Provider<PaymentHistoryRepository> {
  PaymentHistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentHistoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentHistoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<PaymentHistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaymentHistoryRepository create(Ref ref) {
    return paymentHistoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentHistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentHistoryRepository>(value),
    );
  }
}

String _$paymentHistoryRepositoryHash() =>
    r'f4635c7ef15e50e3bc68933627e632ec2873f0a4';

@ProviderFor(paymentsForUser)
final paymentsForUserProvider = PaymentsForUserFamily._();

final class PaymentsForUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Payment>>,
          List<Payment>,
          Stream<List<Payment>>
        >
    with $FutureModifier<List<Payment>>, $StreamProvider<List<Payment>> {
  PaymentsForUserProvider._({
    required PaymentsForUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'paymentsForUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paymentsForUserHash();

  @override
  String toString() {
    return r'paymentsForUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Payment>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Payment>> create(Ref ref) {
    final argument = this.argument as String;
    return paymentsForUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentsForUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paymentsForUserHash() => r'0a2f81b071e098bf6083eef45e1fb406d126c78d';

final class PaymentsForUserFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Payment>>, String> {
  PaymentsForUserFamily._()
    : super(
        retry: null,
        name: r'paymentsForUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PaymentsForUserProvider call(String userId) =>
      PaymentsForUserProvider._(argument: userId, from: this);

  @override
  String toString() => r'paymentsForUserProvider';
}
