import 'dart:async';

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/payments/domain/host_payment_account.dart';
import 'package:flutter/material.dart';

typedef HostPaymentStartOnboarding =
    Future<void> Function({required String country, required String currency});

Future<void> _noopStartOnboarding({
  required String country,
  required String currency,
}) async {}

Future<void> _noopRefresh() async {}

class HostPaymentAccountCard extends StatelessWidget {
  const HostPaymentAccountCard({
    super.key,
    required this.club,
    this.account,
    this.loading = false,
    this.error,
    this.actionErrorMessage,
    this.onboardingPending = false,
    this.refreshPending = false,
    this.onRetry,
    this.onStartOnboarding = _noopStartOnboarding,
    this.onRefresh = _noopRefresh,
  });

  final Club club;
  final HostPaymentAccount? account;
  final bool loading;
  final Object? error;
  final String? actionErrorMessage;
  final bool onboardingPending;
  final bool refreshPending;
  final VoidCallback? onRetry;
  final HostPaymentStartOnboarding onStartOnboarding;
  final Future<void> Function() onRefresh;

  Future<void> _showPayoutsHandoff(
    BuildContext context,
    HostPaymentAccount? account,
    HostPaymentPresentation presentation,
  ) async {
    final t = CatchTokens.of(context);
    final derivedCountry = countryIsoCodeForCityName(club.location);
    final derivedCurrency = currencyCodeForCityName(club.location);
    final country = account?.country ?? derivedCountry;
    final currency = account?.defaultCurrency ?? derivedCurrency;

    await showCatchBottomSheet<void>(
      context: context,
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
          title: context.l10n.hostsHostPaymentAccountCardTitleSetUpPayouts,
          subtitle:
              context.l10n.hostsHostPaymentAccountCardSubtitlePoweredByStripe,
          action: CatchButton(
            label:
                context.l10n.hostsHostPaymentAccountCardLabelContinueToStripe,
            icon: Icon(CatchIcons.openInNewRounded),
            fullWidth: true,
            isLoading: onboardingPending,
            onPressed: onboardingPending
                ? null
                : () {
                    Navigator.of(sheetContext).pop();
                    unawaited(
                      onStartOnboarding(country: country, currency: currency),
                    );
                  },
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CatchBadge.functional(
                label: presentation.badge,
                tone: presentation.tone,
              ),
              gapH14,
              Text(
                context
                    .l10n
                    .hostsHostPaymentAccountCardTextCatchPaysHostsThrough,
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
                    CatchField.read(
                      title:
                          context.l10n.hostsHostPaymentAccountCardTitleCountry,
                      valueText: _countryLabel(country),
                      icon: CatchIcons.locationOnOutlined,
                    ),
                    CatchField.read(
                      title: context
                          .l10n
                          .hostsHostPaymentAccountCardTitleDefaultCurrency,
                      valueText: currency.toUpperCase(),
                      icon: CatchIcons.paymentsOutlined,
                      divider: true,
                    ),
                  ],
                ),
              ),
              gapH12,
              Text(
                context.l10n.hostsHostPaymentAccountCardTextWeWillRefreshYour,
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

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    if (loading) return const HostPaymentAccountLoadingCard();
    if (error != null) {
      return HostPaymentAccountErrorCard(error: error, onRetry: onRetry);
    }
    return HostPaymentAccountContentCard(
      account: account,
      actionErrorMessage: actionErrorMessage,
      onboardingPending: onboardingPending,
      refreshPending: refreshPending,
      onShowPayoutsHandoff: (account, presentation) =>
          _showPayoutsHandoff(context, account, presentation),
      onRefresh: onRefresh,
    );
  }
}

class HostPaymentAccountContentCard extends StatelessWidget {
  const HostPaymentAccountContentCard({
    super.key,
    required this.account,
    this.actionErrorMessage,
    required this.onboardingPending,
    required this.refreshPending,
    required this.onShowPayoutsHandoff,
    required this.onRefresh,
  });

  final HostPaymentAccount? account;
  final String? actionErrorMessage;
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
    final presentation = _presentation(account, context.l10n);
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.tileContentCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CatchSectionHeader(
                  title: context.l10n.hostsHostPaymentAccountCardTitlePayouts,
                ),
              ),
              CatchBadge.functional(
                label: presentation.badge,
                tone: presentation.tone,
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
                  CatchBadge(
                    label:
                        context.l10n.hostsHostPaymentAccountCardLabelRestricted,
                    tone: CatchBadgeTone.warning,
                  ),
              ],
            ),
          ],
          if (actionErrorMessage != null) ...[
            gapH12,
            CatchErrorBanner(message: actionErrorMessage!),
          ],
          gapH12,
          Row(
            children: [
              Expanded(
                child: CatchButton(
                  label: account == null
                      ? context
                            .l10n
                            .hostsHostPaymentAccountCardLabelSetUpPayouts
                      : context
                            .l10n
                            .hostsHostPaymentAccountCardLabelContinueSetup,
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
                  label: context.l10n.hostsHostPaymentAccountCardLabelRefresh,
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

  HostPaymentPresentation _presentation(
    HostPaymentAccount? account,
    AppLocalizations l10n,
  ) {
    if (account == null) {
      return HostPaymentPresentation(
        badge: l10n.hostsHostPaymentAccountCardVisiblecopyNotSetUp,
        tone: CatchBadgeTone.warning,
        title: l10n.hostsHostPaymentAccountCardTitleSetUpInternationalPayouts,
        body: l10n.hostsHostPaymentAccountCardBodyRequiredBeforePaidNon,
      );
    }
    if (account.canAcceptInternationalPayments) {
      return HostPaymentPresentation(
        badge: l10n.hostsHostPaymentAccountCardVisiblecopyReady,
        tone: CatchBadgeTone.success,
        title:
            l10n.hostsHostPaymentAccountCardTitleInternationalCheckoutIsReady,
        body: l10n.hostsHostPaymentAccountCardBodyNonInrPaidBookings,
      );
    }
    if (account.onboardingStatus == HostPaymentOnboardingStatus.restricted) {
      return HostPaymentPresentation(
        badge: l10n.hostsHostPaymentAccountCardVisiblecopyActionNeeded,
        tone: CatchBadgeTone.warning,
        title: l10n.hostsHostPaymentAccountCardTitleStripeNeedsMoreInformation,
        body:
            account.disabledReason ??
            l10n.hostsHostPaymentAccountCardBodyFinishTheOutstandingStripe,
      );
    }
    return HostPaymentPresentation(
      badge: l10n.hostsHostPaymentAccountCardVisiblecopyPending,
      tone: CatchBadgeTone.warning,
      title: l10n.hostsHostPaymentAccountCardTitleStripeOnboardingIsIn,
      body: l10n.hostsHostPaymentAccountCardBodyRefreshAfterCompletingStripe,
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
              Expanded(
                child: CatchSectionHeader(
                  title: context.l10n.hostsHostPaymentAccountCardTitlePayouts,
                ),
              ),
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
          CatchSectionHeader(
            title: context.l10n.hostsHostPaymentAccountCardTitlePayouts,
          ),
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
