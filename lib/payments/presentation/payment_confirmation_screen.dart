import 'dart:async';

import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet_grabber.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/shared/event_joined_celebration_screen.dart';
import 'package:catch_dating_app/events/shared/event_share_card.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/payments/presentation/payment_confirmation_controller.dart';
import 'package:catch_dating_app/payments/presentation/payment_confirmation_keys.dart';
import 'package:catch_dating_app/payments/presentation/payment_confirmation_loading_screen.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

export 'package:catch_dating_app/payments/presentation/payment_confirmation_loading_screen.dart';

class PaymentConfirmationScreen extends ConsumerWidget {
  const PaymentConfirmationScreen({super.key, required this.data});

  final PaymentConfirmationData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(watchEventProvider(data.eventId));

    return CatchAsyncValueView<Event?>(
      value: eventAsync,
      loadingBuilder: (_) => const PaymentConfirmationLoadingScreen(),
      errorBuilder: (_, e, _) => Scaffold(
        body: CatchErrorState.fromError(
          e,
          context: AppErrorContext.payments,
          onRetry: () => ref.invalidate(watchEventProvider(data.eventId)),
        ),
      ),
      builder: (context, event) {
        if (event == null) {
          return Scaffold(
            body: CatchErrorState(
              title: context
                  .l10n
                  .paymentsPaymentConfirmationScreenTitleEventNotFound,
              message: context
                  .l10n
                  .paymentsPaymentConfirmationScreenMessageThisEventIsNo,
            ),
          );
        }
        if (data.isPendingExternalCheckout) {
          return PaymentPendingCheckoutController(data: data, event: event);
        }
        return PaymentConfirmationBodyController(data: data, event: event);
      },
    );
  }
}

class PaymentPendingCheckoutController extends ConsumerWidget {
  const PaymentPendingCheckoutController({
    super.key,
    required this.data,
    required this.event,
  });

  final PaymentConfirmationData data;
  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentAsync = ref.watch(watchPaymentProvider(data.paymentId));
    final payment = paymentAsync.asData?.value;
    if (payment != null &&
        payment.status == PaymentStatus.completed &&
        !payment.signUpFailed) {
      return PaymentConfirmationBodyController(
        data: PaymentConfirmationData(
          paymentId: payment.paymentId,
          orderId: payment.orderId,
          amountInPaise: payment.amount,
          currency: payment.currency,
          eventId: payment.eventId,
          provider: data.provider,
          checkoutUrl: data.checkoutUrl,
        ),
        event: event,
      );
    }

    final failed =
        payment?.status == PaymentStatus.failed ||
        payment?.signUpFailed == true;
    final controller = ref.watch(paymentConfirmationControllerProvider);
    return PaymentPendingCheckoutBody(
      data: data,
      event: event,
      failed: failed,
      providerLabel: _providerLabel(data.provider),
      onOpenCheckout: data.checkoutUrl == null
          ? null
          : () => unawaited(controller.openCheckout(data.checkoutUrl!)),
      onViewPaymentHistory: () =>
          context.goNamed(Routes.paymentHistoryScreen.name),
      onBackToEvent: () => context.goNamed(
        Routes.eventDetailScreen.name,
        pathParameters: {'clubId': event.clubId, 'eventId': event.id},
        extra: event,
      ),
    );
  }
}

class PaymentPendingCheckoutBody extends StatelessWidget {
  const PaymentPendingCheckoutBody({
    super.key,
    required this.data,
    required this.event,
    required this.failed,
    required this.providerLabel,
    required this.onViewPaymentHistory,
    required this.onBackToEvent,
    this.onOpenCheckout,
  });

  final PaymentConfirmationData data;
  final Event event;
  final bool failed;
  final String providerLabel;
  final VoidCallback? onOpenCheckout;
  final VoidCallback onViewPaymentHistory;
  final VoidCallback onBackToEvent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
          Positioned.fill(child: PaymentCheckoutEventBackdrop(event: event)),
          Positioned.fill(
            child: ColoredBox(
              color: t.ink.withValues(alpha: CatchOpacity.paymentCheckoutScrim),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                reverse: true,
                child: PaymentCheckoutSheet(
                  data: data,
                  event: event,
                  failed: failed,
                  providerLabel: providerLabel,
                  onOpenCheckout: onOpenCheckout,
                  onViewPaymentHistory: onViewPaymentHistory,
                  onBackToEvent: onBackToEvent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentCheckoutEventBackdrop extends StatelessWidget {
  const PaymentCheckoutEventBackdrop({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = eventActivityVisual(event.activityKind, context: context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: CatchLayout.paymentCheckoutBackdropHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [visual.accent, visual.deep],
              ),
            ),
            child: Padding(
              padding: CatchInsets.pageBody.copyWith(
                top: CatchSpacing.s5,
                bottom: CatchSpacing.s5,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.headline(context, color: t.primaryInk),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: CatchInsets.pageBody.copyWith(
            top: CatchSpacing.s4,
            bottom: 0,
          ),
          child: Text(
            context.l10n
                .paymentsPaymentConfirmationScreenTextLongdatelabelTimerangelabelLocationnamePriceinpaise(
                  longDateLabel: event.longDateLabel,
                  timeRangeLabel: event.timeRangeLabel,
                  locationName: event.locationName,
                  priceInPaise: EventFormatters.priceInPaise(
                    event.priceInPaise,
                    currencyCode: event.currency,
                  ),
                  capacityLimit: event.capacityLimit,
                ),
            style: CatchTextStyles.proseM(context, color: t.ink2),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class PaymentCheckoutSheet extends StatelessWidget {
  const PaymentCheckoutSheet({
    super.key,
    required this.data,
    required this.event,
    required this.failed,
    required this.providerLabel,
    required this.onViewPaymentHistory,
    required this.onBackToEvent,
    this.onOpenCheckout,
  });

  final PaymentConfirmationData data;
  final Event event;
  final bool failed;
  final String providerLabel;
  final VoidCallback? onOpenCheckout;
  final VoidCallback onViewPaymentHistory;
  final VoidCallback onBackToEvent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final statusTone = failed ? CatchBadgeTone.danger : CatchBadgeTone.warning;
    final medallionColor = failed ? t.danger : t.primary;
    final medallionFill = failed
        ? t.danger.withValues(alpha: CatchOpacity.dangerFill)
        : t.primarySoft;
    final title = failed
        ? context.l10n.paymentsPaymentConfirmationScreenTitlePaymentNotCompleted
        : context.l10n.paymentsPaymentConfirmationScreenTitleCheckoutIsWaiting;
    final message = failed
        ? context.l10n
              .paymentsPaymentConfirmationScreenMessageProviderlabelDidNotComplete(
                providerLabel: providerLabel,
              )
        : context.l10n
              .paymentsPaymentConfirmationScreenMessageFinishPaymentInProviderlabel(
                providerLabel: providerLabel,
                providerLabel2: providerLabel,
              );

    return CatchSurface(
      backgroundColor: t.surface,
      borderColor: t.line,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(CatchRadius.heroCard),
      ),
      width: double.infinity,
      padding: CatchInsets.pageBody.copyWith(
        top: CatchSpacing.s3,
        bottom: CatchSpacing.s6,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: CatchLayout.maxContentWidth,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CatchBottomSheetGrabber(),
            gapH16,
            Align(
              alignment: Alignment.centerLeft,
              child: CatchSurface(
                width: CatchLayout.paymentCheckoutMedallionExtent,
                height: CatchLayout.paymentCheckoutMedallionExtent,
                radius: CatchRadius.pill,
                backgroundColor: medallionFill,
                borderWidth: 0,
                child: Icon(
                  failed
                      ? CatchIcons.errorOutlineRounded
                      : CatchIcons.receiptLongOutlined,
                  color: medallionColor,
                  size: 26,
                ),
              ),
            ),
            gapH14,
            Text(
              title,
              style: CatchTextStyles.headlineS(context, color: t.ink),
            ),
            gapH8,
            Text(
              message,
              style: CatchTextStyles.proseM(context, color: t.ink2),
            ),
            gapH18,
            CatchSurface(
              backgroundColor: t.bg,
              borderColor: t.line,
              radius: CatchRadius.md,
              padding: CatchInsets.content,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.sectionTitle(
                            context,
                            color: t.ink,
                          ),
                        ),
                        gapH4,
                        Text(
                          EventFormatters.priceInPaise(
                            data.amountInPaise,
                            currencyCode: data.currency,
                          ),
                          style: CatchTextStyles.mono(
                            context,
                            color: t.ink2,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  gapW12,
                  CatchBadge(
                    label: failed
                        ? context
                              .l10n
                              .paymentsPaymentConfirmationScreenLabelFailed
                        : context
                              .l10n
                              .paymentsPaymentConfirmationScreenLabelPending,
                    tone: statusTone,
                  ),
                ],
              ),
            ),
            gapH18,
            if (onOpenCheckout != null) ...[
              CatchButton(
                label: failed
                    ? context.l10n
                          .paymentsPaymentConfirmationScreenLabelTryProviderlabelAgain(
                            providerLabel: providerLabel,
                          )
                    : context.l10n
                          .paymentsPaymentConfirmationScreenLabelOpenProviderlabelCheckout(
                            providerLabel: providerLabel,
                          ),
                onPressed: onOpenCheckout,
                icon: Icon(CatchIcons.openInNewRounded),
                fullWidth: true,
              ),
              gapH10,
            ],
            CatchButton(
              label: context
                  .l10n
                  .paymentsPaymentConfirmationScreenLabelViewPaymentHistory,
              onPressed: onViewPaymentHistory,
              variant: CatchButtonVariant.secondary,
              icon: Icon(CatchIcons.receiptLongOutlined),
              fullWidth: true,
            ),
            gapH4,
            CatchButton(
              label: context
                  .l10n
                  .paymentsPaymentConfirmationScreenLabelBackToEvent,
              onPressed: onBackToEvent,
              variant: CatchButtonVariant.ghost,
              icon: Icon(CatchIcons.eventOutlined),
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}

String _providerLabel(String provider) {
  if (provider.isEmpty) return 'Checkout';
  return provider[0].toUpperCase() + provider.substring(1);
}

class PaymentConfirmationBodyController extends ConsumerWidget {
  const PaymentConfirmationBodyController({
    super.key,
    required this.data,
    required this.event,
  });

  final PaymentConfirmationData data;
  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubAsync = ref.watch(watchClubProvider(event.clubId));
    final clubName = clubAsync.asData?.value?.name;
    final controller = ref.watch(paymentConfirmationControllerProvider);
    final share = ref.watch(externalShareControllerProvider);

    return PaymentConfirmationBody(
      data: data,
      event: event,
      clubName: clubName,
      onAddToCalendar: () => unawaited(controller.addToCalendar(event)),
      onOpenDirections: () => unawaited(controller.openDirections(event)),
      onInviteFriend: () => unawaited(
        showEventShareCardSheet(context, event: event, share: share),
      ),
      onReferralShare: () => unawaited(
        showEventShareCardSheet(context, event: event, share: share),
      ),
      onViewEvent: () => context.goNamed(
        Routes.eventDetailScreen.name,
        pathParameters: {'clubId': event.clubId, 'eventId': event.id},
        extra: event,
      ),
      onBackHome: () => context.goNamed(Routes.dashboardScreen.name),
    );
  }
}

class PaymentConfirmationBody extends StatelessWidget {
  const PaymentConfirmationBody({
    super.key,
    required this.data,
    required this.event,
    required this.onAddToCalendar,
    required this.onOpenDirections,
    required this.onInviteFriend,
    required this.onReferralShare,
    required this.onViewEvent,
    required this.onBackHome,
    this.clubName,
  });

  final PaymentConfirmationData data;
  final Event event;
  final String? clubName;
  final VoidCallback onAddToCalendar;
  final VoidCallback onOpenDirections;
  final VoidCallback onInviteFriend;
  final VoidCallback onReferralShare;
  final VoidCallback onViewEvent;
  final VoidCallback onBackHome;

  static const double _iconBoxSize = CatchSpacing.s9;
  static const double _tileSpacing = CatchSpacing.s3;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final actions = [
      PaymentConfirmationAction(
        key: PaymentConfirmationKeys.addToCalendar,
        icon: CatchIcons.calendarMonthOutlined,
        label: context.l10n.paymentsPaymentConfirmationScreenLabelAddToCalendar,
        onPressed: onAddToCalendar,
      ),
      PaymentConfirmationAction(
        key: PaymentConfirmationKeys.directions,
        icon: CatchIcons.directionsOutlined,
        label: context.l10n.paymentsPaymentConfirmationScreenLabelGetDirections,
        onPressed: onOpenDirections,
      ),
      PaymentConfirmationAction(
        key: PaymentConfirmationKeys.inviteFriend,
        icon: CatchIcons.platformShare(platform: Theme.of(context).platform),
        label: context.l10n.paymentsPaymentConfirmationScreenLabelInviteFriend,
        onPressed: onInviteFriend,
      ),
    ];

    return EventJoinedCelebrationScreen(
      event: event,
      clubName: clubName,
      paymentData: data,
      supplementalChildren: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < actions.length; index++) ...[
              Expanded(
                child: Opacity(
                  opacity: actions[index].isEnabled ? 1 : 0.7,
                  child: KeyedSubtree(
                    key: actions[index].key,
                    child: Semantics(
                      label: actions[index].label,
                      child: CatchSurface(
                        onTap: actions[index].onPressed,
                        padding: CatchInsets.content,
                        radius: CatchRadius.md,
                        borderColor: t.line,
                        backgroundColor: t.surface,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CatchIconTile(
                              icon: actions[index].icon,
                              iconColor: t.primary,
                              backgroundColor: t.primarySoft,
                              borderColor: t.primarySoft,
                              size: _iconBoxSize,
                              iconSize: CatchIcon.md,
                              radius: CatchRadius.sm,
                            ),
                            gapH8,
                            Text(
                              actions[index].label,
                              style: CatchTextStyles.labelL(context),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (index < actions.length - 1)
                const SizedBox(width: _tileSpacing),
            ],
          ],
        ),
        const PaymentConfirmationHeadsUp(),
        PaymentReferralBanner(onShare: onReferralShare),
      ],
      backHomeKey: PaymentConfirmationKeys.backHome,
      onViewEvent: onViewEvent,
      onBackHome: onBackHome,
    );
  }
}

class PaymentConfirmationAction {
  const PaymentConfirmationAction({
    this.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final Key? key;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  bool get isEnabled => onPressed != null;
}

class PaymentConfirmationHeadsUp extends StatelessWidget {
  const PaymentConfirmationHeadsUp({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.primarySoft,
      padding: CatchInsets.tileContentCompact,
      radius: CatchRadius.md,
      borderWidth: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.paymentsPaymentConfirmationScreenTextHeadsUp,
            style: CatchTextStyles.labelM(context, color: t.primary),
          ),
          gapH6,
          Text(
            context.l10n.paymentsPaymentConfirmationScreenTextBringAWaterBottle,
            style: CatchTextStyles.proseM(context, color: t.ink),
          ),
        ],
      ),
    );
  }
}

class PaymentReferralBannerController extends ConsumerWidget {
  const PaymentReferralBannerController({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final share = ref.watch(externalShareControllerProvider);
    return PaymentReferralBanner(
      onShare: () => unawaited(
        showEventShareCardSheet(context, event: event, share: share),
      ),
    );
  }
}

class PaymentReferralBanner extends StatelessWidget {
  const PaymentReferralBanner({super.key, required this.onShare});

  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      key: PaymentConfirmationKeys.referralShare,
      onTap: onShare,
      padding: CatchInsets.tileContentCompact,
      radius: CatchRadius.md,
      borderColor: t.primary.withValues(
        alpha: CatchOpacity.paymentReferralBorder,
      ),
      borderWidth: 1.5,
      child: Row(
        children: [
          Icon(CatchIcons.groupAddOutlined, color: t.primary),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context
                      .l10n
                      .paymentsPaymentConfirmationScreenTextBringSomeoneYouActually,
                  style: CatchTextStyles.sectionTitle(context),
                ),
                gapH2,
                Text(
                  context
                      .l10n
                      .paymentsPaymentConfirmationScreenTextTheBestInvitesHappen,
                  style: CatchTextStyles.proseM(context, color: t.ink2),
                ),
              ],
            ),
          ),
          Text(
            context.l10n.paymentsPaymentConfirmationScreenTextShare,
            style: CatchTextStyles.labelL(context, color: t.primary),
          ),
        ],
      ),
    );
  }
}
