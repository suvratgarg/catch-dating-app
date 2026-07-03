import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/payments/data/host_payment_account_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_payment_account_controller.g.dart';

@riverpod
HostPaymentAccountActions hostPaymentAccountController(Ref ref) =>
    HostPaymentAccountController(ref);

abstract interface class HostPaymentAccountActions {
  Future<void> startOnboarding({
    required String country,
    required String defaultCurrency,
  });

  Future<void> refreshStatus();
}

class HostPaymentAccountController implements HostPaymentAccountActions {
  const HostPaymentAccountController(this._ref);

  static final startOnboardingMutation = Mutation<void>();
  static final refreshStatusMutation = Mutation<void>();

  final Ref _ref;

  @override
  Future<void> startOnboarding({
    required String country,
    required String defaultCurrency,
  }) async {
    requireSignedInUid(_ref, action: 'set up payouts');
    final link = await _ref
        .read(hostPaymentAccountRepositoryProvider)
        .createOnboardingLink(
          country: country,
          defaultCurrency: defaultCurrency,
        );
    final opened = await _ref
        .read(externalLinkControllerProvider)
        .openExternal(link.onboardingUrl);
    if (!opened) {
      throw const ExternalActionException('Could not open Stripe onboarding.');
    }
  }

  @override
  Future<void> refreshStatus() async {
    final uid = requireSignedInUid(_ref, action: 'refresh payouts');
    await _ref.read(hostPaymentAccountRepositoryProvider).refreshStripeStatus();
    _ref.invalidate(watchHostPaymentAccountProvider(uid));
  }
}
