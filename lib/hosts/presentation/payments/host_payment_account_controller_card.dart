import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_card.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/payments/data/host_payment_account_repository.dart';
import 'package:catch_dating_app/payments/domain/host_payment_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostPaymentAccountControllerCard extends ConsumerWidget {
  const HostPaymentAccountControllerCard({super.key, required this.club});

  final Club club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final uid = uidAsync.asData?.value;
    final accountAsync = switch (uidAsync) {
      AsyncData(:final value) =>
        value == null
            ? const AsyncValue<HostPaymentAccount?>.data(null)
            : ref.watch(watchHostPaymentAccountProvider(value)),
      AsyncError(:final error, :final stackTrace) =>
        AsyncValue<HostPaymentAccount?>.error(error, stackTrace),
      _ => const AsyncValue<HostPaymentAccount?>.loading(),
    };
    final onboardingMutation = ref.watch(
      HostPaymentAccountController.startOnboardingMutation,
    );
    final refreshMutation = ref.watch(
      HostPaymentAccountController.refreshStatusMutation,
    );
    final failedMutation = onboardingMutation.hasError
        ? onboardingMutation
        : refreshMutation.hasError
        ? refreshMutation
        : null;
    final actionErrorMessage = failedMutation == null
        ? null
        : mutationErrorMessage(
            failedMutation,
            l10n: context.l10n,
            context: AppErrorContext.payments,
          );

    Future<void> startOnboarding({
      required String country,
      required String currency,
    }) async {
      final failureReason = context
          .l10n
          .hostsHostPaymentAccountControllerCardVisiblecopyHostpaymentaccountcontrollercardStartonboardingFailed;
      if (onboardingMutation.isPending) {
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
            .logError(error, stackTrace, reason: failureReason);
      }
    }

    Future<void> refresh() async {
      final failureReason = context
          .l10n
          .hostsHostPaymentAccountControllerCardVisiblecopyHostpaymentaccountcontrollercardRefreshFailed;
      if (refreshMutation.isPending) {
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
            .logError(error, stackTrace, reason: failureReason);
      }
    }

    return CatchAsyncValueView<HostPaymentAccount?>(
      value: accountAsync,
      onRetry: uid == null
          ? null
          : () => ref.invalidate(watchHostPaymentAccountProvider(uid)),
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
        actionErrorMessage: actionErrorMessage,
        onboardingPending: onboardingMutation.isPending,
        refreshPending: refreshMutation.isPending,
        onStartOnboarding: startOnboarding,
        onRefresh: refresh,
      ),
    );
  }
}
