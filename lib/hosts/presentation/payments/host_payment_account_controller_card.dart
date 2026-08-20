import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
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
    final uid = catchAsyncStateFromAsyncValue(uidAsync).value;
    final accountsAsync = switch (uidAsync) {
      AsyncData(:final value) =>
        value == null
            ? const AsyncValue<List<HostPaymentAccount>>.data([])
            : ref.watch(watchHostPaymentAccountsProvider(value)),
      AsyncError(:final error, :final stackTrace) =>
        AsyncValue<List<HostPaymentAccount>>.error(error, stackTrace),
      _ => const AsyncValue<List<HostPaymentAccount>>.loading(),
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
      required HostPaymentProvider provider,
      required String country,
      required String currency,
      RazorpayHostOnboardingDetails? razorpayDetails,
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
              .startOnboarding(
                provider: provider,
                country: country,
                defaultCurrency: currency,
                razorpayDetails: razorpayDetails,
              ),
        );
      } catch (error, stackTrace) {
        ref
            .read(errorLoggerProvider)
            .logError(error, stackTrace, reason: failureReason);
      }
    }

    Future<void> refresh(HostPaymentProvider provider) async {
      final failureReason = context
          .l10n
          .hostsHostPaymentAccountControllerCardVisiblecopyHostpaymentaccountcontrollercardRefreshFailed;
      if (refreshMutation.isPending) {
        return;
      }
      try {
        await HostPaymentAccountController.refreshStatusMutation.run(
          ref,
          (tx) => tx
              .get(hostPaymentAccountControllerProvider)
              .refreshStatus(provider),
        );
      } catch (error, stackTrace) {
        ref
            .read(errorLoggerProvider)
            .logError(error, stackTrace, reason: failureReason);
      }
    }

    return CatchAsyncValueView<List<HostPaymentAccount>>(
      value: accountsAsync,
      onRetry: uid == null
          ? null
          : () => ref.invalidate(watchHostPaymentAccountsProvider(uid)),
      loadingBuilder: (_) => const HostPaymentAccountLoadingCard(),
      errorBuilder: (_, error, _) => HostPaymentAccountErrorCard(
        error: error,
        onRetry: uid == null
            ? null
            : () => ref.invalidate(watchHostPaymentAccountsProvider(uid)),
      ),
      builder: (context, accounts) => HostPaymentAccountCard(
        club: club,
        accounts: accounts,
        actionErrorMessage: actionErrorMessage,
        onboardingPending: onboardingMutation.isPending,
        refreshPending: refreshMutation.isPending,
        onStartOnboarding: startOnboarding,
        onRefresh: refresh,
      ),
    );
  }
}
