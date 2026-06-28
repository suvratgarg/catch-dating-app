import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_controller.dart';
import 'package:catch_dating_app/payments/data/host_payment_account_repository.dart';
import 'package:catch_dating_app/payments/domain/host_payment_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostPaymentAccountCard extends ConsumerStatefulWidget {
  const HostPaymentAccountCard({super.key, required this.club});

  final Club club;

  @override
  ConsumerState<HostPaymentAccountCard> createState() =>
      _HostPaymentAccountCardState();
}

class _HostPaymentAccountCardState
    extends ConsumerState<HostPaymentAccountCard> {
  Future<void> _showPayoutsHandoff(
    HostPaymentAccount? account,
    HostPaymentPresentation presentation,
    bool onboardingPending,
  ) async {
    final t = CatchTokens.of(context);
    final derivedCountry = countryIsoCodeForCityName(widget.club.location);
    final derivedCurrency = currencyCodeForCityName(widget.club.location);
    final country = account?.country ?? derivedCountry;
    final currency = account?.defaultCurrency ?? derivedCurrency;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: t.bg,
      barrierColor: t.overlay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(CatchRadius.lg),
        ),
      ),
      builder: (sheetContext) {
        final sheetTokens = CatchTokens.of(sheetContext);
        return CatchBottomSheetScaffold(
          title: 'Set up payouts',
          subtitle: 'Powered by Stripe',
          action: CatchButton(
            label: 'Continue to Stripe',
            icon: Icon(CatchIcons.openInNewRounded),
            fullWidth: true,
            isLoading: onboardingPending,
            onPressed: onboardingPending
                ? null
                : () {
                    Navigator.of(sheetContext).pop();
                    unawaited(
                      _startOnboarding(country: country, currency: currency),
                    );
                  },
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CatchBadge(
                label: presentation.badge,
                tone: presentation.tone,
                uppercase: true,
              ),
              gapH14,
              Text(
                'Catch pays hosts through Stripe. Finish a short verification on Stripe, then come back here before paid non-INR events can take checkout.',
                style: CatchTextStyles.supporting(
                  sheetContext,
                  color: sheetTokens.ink2,
                ),
              ),
              gapH16,
              CatchSurface(
                tone: CatchSurfaceTone.raised,
                borderColor: sheetTokens.line2,
                padding: const EdgeInsets.symmetric(
                  horizontal: CatchSpacing.s3,
                ),
                child: Column(
                  children: [
                    CatchField(
                      title: 'Country',
                      valueText: _countryLabel(country),
                      icon: CatchIcons.locationOnOutlined,
                      showChevron: false,
                    ),
                    CatchField(
                      title: 'Default currency',
                      valueText: currency.toUpperCase(),
                      icon: CatchIcons.paymentsOutlined,
                      divider: true,
                      showChevron: false,
                    ),
                  ],
                ),
              ),
              gapH12,
              Text(
                'We will refresh your payout status when you return.',
                textAlign: TextAlign.center,
                style: CatchTextStyles.supporting(
                  sheetContext,
                  color: sheetTokens.ink3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startOnboarding({
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
    } catch (_) {}
  }

  Future<void> _refresh() async {
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
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
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
    return CatchAsyncValueView<HostPaymentAccount?>(
      value: accountAsync,
      loadingBuilder: (_) => const HostPaymentAccountLoadingCard(),
      errorBuilder: (_, error, _) => HostPaymentAccountErrorCard(
        error: error,
        onRetry: uid == null
            ? null
            : () => ref.invalidate(watchHostPaymentAccountProvider(uid)),
      ),
      builder: (context, account) => HostPaymentAccountContentCard(
        account: account,
        actionError: _firstErrorMutation(onboardingMutation, refreshMutation),
        onboardingPending: onboardingMutation.isPending,
        refreshPending: refreshMutation.isPending,
        onShowPayoutsHandoff: (account, presentation) => _showPayoutsHandoff(
          account,
          presentation,
          onboardingMutation.isPending,
        ),
        onRefresh: _refresh,
      ),
    );
  }

  MutationState? _firstErrorMutation(
    MutationState onboardingMutation,
    MutationState refreshMutation,
  ) {
    if (onboardingMutation.hasError) return onboardingMutation;
    if (refreshMutation.hasError) return refreshMutation;
    return null;
  }
}

class HostPaymentAccountContentCard extends StatelessWidget {
  const HostPaymentAccountContentCard({
    super.key,
    required this.account,
    required this.actionError,
    required this.onboardingPending,
    required this.refreshPending,
    required this.onShowPayoutsHandoff,
    required this.onRefresh,
  });

  final HostPaymentAccount? account;
  final MutationState? actionError;
  final bool onboardingPending;
  final bool refreshPending;
  final Future<void> Function(
    HostPaymentAccount? account,
    HostPaymentPresentation presentation,
  )
  onShowPayoutsHandoff;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final account = this.account;
    final presentation = _presentation(account);
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.tileContentCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: CatchSectionHeader(title: 'Payouts')),
              CatchBadge(
                label: presentation.badge,
                tone: presentation.tone,
                uppercase: true,
              ),
            ],
          ),
          gapH10,
          Text(
            presentation.title,
            style: CatchTextStyles.sectionTitle(context),
          ),
          gapH4,
          Text(
            presentation.body,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          if (account != null) ...[
            gapH10,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                CatchBadge(label: account.defaultCurrency),
                CatchBadge(label: account.country),
                if (account.disabledReason != null)
                  const CatchBadge(
                    label: 'Restricted',
                    tone: CatchBadgeTone.warning,
                  ),
              ],
            ),
          ],
          if (actionError != null) ...[
            gapH12,
            CatchErrorBanner(
              message: mutationErrorMessage(
                actionError!,
                context: AppErrorContext.payments,
              ),
            ),
          ],
          gapH12,
          Row(
            children: [
              Expanded(
                child: CatchButton(
                  label: account == null ? 'Set up payouts' : 'Continue setup',
                  onPressed: onboardingPending
                      ? null
                      : () => unawaited(
                          onShowPayoutsHandoff(account, presentation),
                        ),
                  isLoading: onboardingPending,
                  icon: Icon(CatchIcons.paymentsOutlined),
                ),
              ),
              if (account != null) ...[
                gapW10,
                CatchButton(
                  label: 'Refresh',
                  onPressed: refreshPending
                      ? null
                      : () => unawaited(onRefresh()),
                  isLoading: refreshPending,
                  variant: CatchButtonVariant.secondary,
                  icon: Icon(CatchIcons.refreshRounded),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  HostPaymentPresentation _presentation(HostPaymentAccount? account) {
    if (account == null) {
      return const HostPaymentPresentation(
        badge: 'Not set up',
        tone: CatchBadgeTone.warning,
        title: 'Set up international payouts',
        body:
            'Required before paid non-INR events can accept checkout through Stripe.',
      );
    }
    if (account.canAcceptInternationalPayments) {
      return const HostPaymentPresentation(
        badge: 'Ready',
        tone: CatchBadgeTone.success,
        title: 'International checkout is ready',
        body:
            'Non-INR paid bookings can route through Stripe for this host account.',
      );
    }
    if (account.onboardingStatus == HostPaymentOnboardingStatus.restricted) {
      return HostPaymentPresentation(
        badge: 'Action needed',
        tone: CatchBadgeTone.warning,
        title: 'Stripe needs more information',
        body:
            account.disabledReason ??
            'Finish the outstanding Stripe requirements to accept payments.',
      );
    }
    return const HostPaymentPresentation(
      badge: 'Pending',
      tone: CatchBadgeTone.warning,
      title: 'Stripe onboarding is in progress',
      body:
          'Refresh after completing Stripe onboarding to update checkout readiness.',
    );
  }
}

class HostPaymentAccountLoadingCard extends StatelessWidget {
  const HostPaymentAccountLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.tileContentCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: CatchSectionHeader(title: 'Payouts')),
              CatchSkeleton.box(
                width: CatchLayout.skeletonStatusPillWidth,
                height: CatchSpacing.s6,
                radius: CatchRadius.pill,
              ),
            ],
          ),
          gapH14,
          CatchSkeleton.text(width: CatchLayout.skeletonTextLongWidth),
          gapH8,
          CatchSkeleton.textBlock(lines: 2),
          gapH14,
          CatchSkeleton.box(
            height: CatchLayout.hostPaymentActionSkeletonHeight,
            radius: CatchRadius.sm,
          ),
        ],
      ),
    );
  }
}

class HostPaymentAccountErrorCard extends StatelessWidget {
  const HostPaymentAccountErrorCard({
    super.key,
    required this.error,
    this.onRetry,
  });

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.tileContentCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CatchSectionHeader(title: 'Payouts'),
          gapH12,
          CatchErrorState.fromError(
            error,
            context: AppErrorContext.payments,
            mode: CatchErrorStateMode.compact,
            onRetry: onRetry,
          ),
        ],
      ),
    );
  }
}

class HostPaymentPresentation {
  const HostPaymentPresentation({
    required this.badge,
    required this.tone,
    required this.title,
    required this.body,
  });

  final String badge;
  final CatchBadgeTone tone;
  final String title;
  final String body;
}

String _countryLabel(String countryCode) {
  return switch (countryCode.toUpperCase()) {
    'IN' => 'India',
    _ => countryCode.toUpperCase(),
  };
}
