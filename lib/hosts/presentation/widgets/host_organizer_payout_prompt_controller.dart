import 'package:catch_dating_app/hosts/presentation/widgets/host_organizer_payout_prompt.dart';
import 'package:catch_dating_app/payments/data/host_payment_account_repository.dart';
import 'package:catch_dating_app/payments/domain/host_payment_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostOrganizerPayoutPromptController extends ConsumerWidget {
  const HostOrganizerPayoutPromptController({
    super.key,
    required this.uid,
    required this.onManagePayouts,
  });

  final String uid;
  final VoidCallback onManagePayouts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(watchHostPaymentAccountProvider(uid));
    return HostOrganizerPayoutPrompt(
      state: _stateFor(accountAsync),
      onManagePayouts: onManagePayouts,
    );
  }

  HostOrganizerPayoutPromptState _stateFor(
    AsyncValue<HostPaymentAccount?> accountAsync,
  ) {
    final account = accountAsync.asData?.value;
    if (account?.canAcceptInternationalPayments == true) {
      return const HostOrganizerPayoutPromptState.hidden();
    }
    if (accountAsync.isLoading && !accountAsync.hasValue) {
      return const HostOrganizerPayoutPromptState.loading();
    }
    if (accountAsync.hasError) {
      return const HostOrganizerPayoutPromptState.error();
    }
    return const HostOrganizerPayoutPromptState.setupRequired();
  }
}
