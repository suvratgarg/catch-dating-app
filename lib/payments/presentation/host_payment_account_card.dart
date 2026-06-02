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
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
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
              const Expanded(child: SectionHeader(title: 'Payouts')),
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
                CatchBadge(
                  label: account.defaultCurrency,
                ),
                CatchBadge(
                  label: account.country,
                ),
                if (account.disabledReason != null)
                  const CatchBadge(label: 'Restricted', tone: CatchBadgeTone.warning),
              ],
            ),
          ],
          if (_error != null) ...[
            gapH12,
            ErrorBanner(message: appErrorMessage(_error!)),
          ],
          gapH12,
          Row(
            children: [
              Expanded(
                child: CatchButton(
                  label: account == null ? 'Set up payouts' : 'Continue setup',
                  onPressed: _onboardingPending
                      ? null
                      : () => unawaited(_startOnboarding()),
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

  ({String badge, CatchBadgeTone tone, String title, String body})
  _presentation(HostPaymentAccount? account) {
    if (account == null) {
      return (
        badge: 'Not set up',
        tone: CatchBadgeTone.warning,
        title: 'Set up international payouts',
        body:
            'Required before paid non-INR events can accept checkout through Stripe.',
      );
    }
    if (account.canAcceptInternationalPayments) {
      return (
        badge: 'Ready',
        tone: CatchBadgeTone.success,
        title: 'International checkout is ready',
        body:
            'Non-INR paid bookings can route through Stripe for this host account.',
      );
    }
    if (account.onboardingStatus == HostPaymentOnboardingStatus.restricted) {
      return (
        badge: 'Action needed',
        tone: CatchBadgeTone.warning,
        title: 'Stripe needs more information',
        body:
            account.disabledReason ??
            'Finish the outstanding Stripe requirements to accept payments.',
      );
    }
    return (
      badge: 'Pending',
      tone: CatchBadgeTone.warning,
      title: 'Stripe onboarding is in progress',
      body:
          'Refresh after completing Stripe onboarding to update checkout readiness.',
    );
  }
}
