import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:catch_dating_app/core/widgets/settings_row.dart';
import 'package:catch_dating_app/payments/data/host_payment_account_repository.dart';
import 'package:catch_dating_app/payments/domain/host_payment_account.dart';
import 'package:flutter/material.dart';
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
  Object? _error;
  bool _onboardingPending = false;
  bool _refreshPending = false;

  Future<void> _showPayoutsHandoff(
    HostPaymentAccount? account,
    _HostPaymentPresentation presentation,
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
            isLoading: _onboardingPending,
            onPressed: _onboardingPending
                ? null
                : () {
                    Navigator.of(sheetContext).pop();
                    unawaited(_startOnboarding());
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
                    CatchSettingsRow(
                      label: 'Country',
                      value: _countryLabel(country),
                      icon: CatchIcons.locationOnOutlined,
                      showChevron: false,
                    ),
                    CatchSettingsRow(
                      label: 'Default currency',
                      value: currency.toUpperCase(),
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

  Future<void> _startOnboarding() async {
    setState(() {
      _error = null;
      _onboardingPending = true;
    });
    try {
      final link = await ref
          .read(hostPaymentAccountRepositoryProvider)
          .createOnboardingLink(
            country: countryIsoCodeForCityName(widget.club.location),
            defaultCurrency: currencyCodeForCityName(widget.club.location),
          );
      await ref
          .read(externalLinkControllerProvider)
          .openExternal(link.onboardingUrl);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _onboardingPending = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _error = null;
      _refreshPending = true;
    });
    try {
      await ref
          .read(hostPaymentAccountRepositoryProvider)
          .refreshStripeStatus();
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _refreshPending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(uidProvider).asData?.value;
    final accountAsync = uid == null
        ? const AsyncValue<HostPaymentAccount?>.data(null)
        : ref.watch(watchHostPaymentAccountProvider(uid));
    final account = accountAsync.asData?.value;
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
          if (_error != null) ...[
            gapH12,
            CatchErrorBanner(message: appErrorMessage(_error!)),
          ],
          gapH12,
          Row(
            children: [
              Expanded(
                child: CatchButton(
                  label: account == null ? 'Set up payouts' : 'Continue setup',
                  onPressed: _onboardingPending
                      ? null
                      : () => unawaited(
                          _showPayoutsHandoff(account, presentation),
                        ),
                  isLoading: _onboardingPending,
                  icon: Icon(CatchIcons.paymentsOutlined),
                ),
              ),
              if (account != null) ...[
                gapW10,
                CatchButton(
                  label: 'Refresh',
                  onPressed: _refreshPending
                      ? null
                      : () => unawaited(_refresh()),
                  isLoading: _refreshPending,
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

  _HostPaymentPresentation _presentation(HostPaymentAccount? account) {
    if (account == null) {
      return const _HostPaymentPresentation(
        badge: 'Not set up',
        tone: CatchBadgeTone.warning,
        title: 'Set up international payouts',
        body:
            'Required before paid non-INR events can accept checkout through Stripe.',
      );
    }
    if (account.canAcceptInternationalPayments) {
      return const _HostPaymentPresentation(
        badge: 'Ready',
        tone: CatchBadgeTone.success,
        title: 'International checkout is ready',
        body:
            'Non-INR paid bookings can route through Stripe for this host account.',
      );
    }
    if (account.onboardingStatus == HostPaymentOnboardingStatus.restricted) {
      return _HostPaymentPresentation(
        badge: 'Action needed',
        tone: CatchBadgeTone.warning,
        title: 'Stripe needs more information',
        body:
            account.disabledReason ??
            'Finish the outstanding Stripe requirements to accept payments.',
      );
    }
    return const _HostPaymentPresentation(
      badge: 'Pending',
      tone: CatchBadgeTone.warning,
      title: 'Stripe onboarding is in progress',
      body:
          'Refresh after completing Stripe onboarding to update checkout readiness.',
    );
  }
}

class _HostPaymentPresentation {
  const _HostPaymentPresentation({
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
