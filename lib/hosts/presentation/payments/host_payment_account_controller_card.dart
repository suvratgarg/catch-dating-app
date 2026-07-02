import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_card.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_controller.dart';
import 'package:catch_dating_app/payments/data/host_payment_account_repository.dart';
import 'package:catch_dating_app/payments/domain/host_payment_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostPaymentAccountControllerCard extends ConsumerWidget {
  const HostPaymentAccountControllerCard({super.key, required this.club});

  final Club club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(uidProvider).asData?.value;
    final accountAsync = uid == null
        ? const AsyncValue<HostPaymentAccount?>.data(null)
        : ref.watch(watchHostPaymentAccountProvider(uid));
    final onboardingMutation = ref.watch(
      HostPaymentAccountController.startOnboardingMutation,
    );
    final refreshMutation = ref.watch(
      HostPaymentAccountController.refreshStatusMutation,
    );

    Future<void> startOnboarding({
      required String country,
      required String currency,
    }) async {
      if (ref
          .read(HostPaymentAccountController.startOnboardingMutation)
          .isPending) {
        return;
      }
      try {
        await HostPaymentAccountController.startOnboardingMutation.run(
          ref,
          (tx) => tx
              .get(hostPaymentAccountControllerProvider)
              .startOnboarding(country: country, defaultCurrency: currency),
        );
      } catch (error, stackTrace) {
        ref
            .read(errorLoggerProvider)
            .logError(
              error,
              stackTrace,
              reason: 'HostPaymentAccountControllerCard.startOnboarding failed',
            );
      }
    }

    Future<void> refresh() async {
      if (ref
          .read(HostPaymentAccountController.refreshStatusMutation)
          .isPending) {
        return;
      }
      try {
        await HostPaymentAccountController.refreshStatusMutation.run(
          ref,
          (tx) => tx.get(hostPaymentAccountControllerProvider).refreshStatus(),
        );
      } catch (error, stackTrace) {
        ref
            .read(errorLoggerProvider)
            .logError(
              error,
              stackTrace,
              reason: 'HostPaymentAccountControllerCard.refresh failed',
            );
      }
    }

    return CatchAsyncValueView<HostPaymentAccount?>(
      value: accountAsync,
      loadingBuilder: (_) => const HostPaymentAccountLoadingCard(),
      errorBuilder: (_, error, _) => HostPaymentAccountErrorCard(
        error: error,
        onRetry: uid == null
            ? null
            : () => ref.invalidate(watchHostPaymentAccountProvider(uid)),
      ),
      builder: (context, account) => HostPaymentAccountCard(
        club: club,
        account: account,
        actionErrorMessage: _firstActionErrorMessage(
          onboardingMutation,
          refreshMutation,
          context,
        ),
        onboardingPending: onboardingMutation.isPending,
        refreshPending: refreshMutation.isPending,
        onStartOnboarding: startOnboarding,
        onRefresh: refresh,
      ),
    );
  }

  String? _firstActionErrorMessage(
    MutationState onboardingMutation,
    MutationState refreshMutation,
    BuildContext context,
  ) {
    final failedMutation = onboardingMutation.hasError
        ? onboardingMutation
        : refreshMutation.hasError
        ? refreshMutation
        : null;
    if (failedMutation == null) return null;
    return mutationErrorMessage(
      failedMutation,
      context: AppErrorContext.payments,
    );
  }
}
