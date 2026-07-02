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
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/dashboard/shared/quick_actions.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/event_joined_celebration_screen.dart';
import 'package:catch_dating_app/events/shared/event_share_card.dart';
import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/payments/presentation/payment_confirmation_controller.dart';
import 'package:catch_dating_app/payments/presentation/payment_confirmation_keys.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
          return const Scaffold(
            body: CatchErrorState(
              title: 'Event not found',
              message: 'This event is no longer available.',
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

class PaymentConfirmationLoadingScreen extends StatelessWidget {
  const PaymentConfirmationLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: CatchInsets.pageBody,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: CatchSkeleton.circle(size: CatchIcon.forceUpdate)),
              gapH24,
              Center(
                child: CatchSkeleton.text(
                  width: CatchLayout.skeletonTextTitleWidth,
                ),
              ),
              gapH12,
              CatchSkeleton.textBlock(lines: 2),
              gapH24,
              CatchSurface(
                padding: CatchInsets.content,
                borderColor: t.line,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CatchSkeleton.text(
                      width: CatchLayout.skeletonTextTitleWidth,
                    ),
                    gapH8,
                    CatchSkeleton.text(
                      width: CatchLayout.skeletonTextShortWidth,
                    ),
                    gapH16,
                    CatchSkeleton.card(
                      height: CatchLayout.skeletonCardCompactHeight,
                    ),
                  ],
                ),
              ),
              gapH20,
              Row(
                children: [
                  for (var index = 0; index < 3; index++) ...[
                    Expanded(
                      child: CatchSkeleton.card(
                        height: CatchLayout.skeletonCardCompactHeight,
                      ),
                    ),
                    if (index < 2) gapW8,
                  ],
                ],
              ),
              gapH20,
              CatchSkeleton.card(height: CatchLayout.buttonLgHeight),
            ],
          ),
        ),
      ),
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
              padding: const EdgeInsets.all(CatchSpacing.s5),
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
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            CatchSpacing.s4,
            CatchSpacing.s5,
            0,
          ),
          child: Text(
            '${event.longDateLabel} · ${event.timeRangeLabel} · '
            '${event.locationName}. '
            '${EventFormatters.priceInPaise(event.priceInPaise, currencyCode: event.currency)} · '
            '${event.capacityLimit} spots.',
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
    final title = failed ? 'Payment not completed' : 'Checkout is waiting';
    final message = failed
        ? '$providerLabel did not complete this booking. If money moved, it '
              'stays visible in payment history while support resolves it.'
        : 'Finish payment in $providerLabel. Your spot is reserved only after '
              '$providerLabel confirms the payment and Catch writes the booking.';

    return CatchSurface(
      backgroundColor: t.surface,
      borderColor: t.line,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(CatchRadius.heroCard),
      ),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s3,
        CatchSpacing.s5,
        CatchSpacing.s6,
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
                    label: failed ? 'Failed' : 'Pending',
                    tone: statusTone,
                  ),
                ],
              ),
            ),
            gapH18,
            if (onOpenCheckout != null) ...[
              CatchButton(
                label: failed
                    ? 'Try $providerLabel again'
                    : 'Open $providerLabel checkout',
                onPressed: onOpenCheckout,
                icon: Icon(CatchIcons.openInNewRounded),
                fullWidth: true,
              ),
              gapH10,
            ],
            CatchButton(
              label: 'View payment history',
              onPressed: onViewPaymentHistory,
              variant: CatchButtonVariant.secondary,
              icon: Icon(CatchIcons.receiptLongOutlined),
              fullWidth: true,
            ),
            gapH4,
            CatchButton(
              label: 'Back to event',
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

  @override
  Widget build(BuildContext context) {
    return EventJoinedCelebrationScreen(
      event: event,
      clubName: clubName,
      paymentData: data,
      supplementalChildren: [
        QuickActions(
          columns: 3,
          actions: [
            DashboardQuickAction(
              key: PaymentConfirmationKeys.addToCalendar,
              icon: CatchIcons.calendarMonthOutlined,
              label: 'Add to calendar',
              onPressed: onAddToCalendar,
            ),
            DashboardQuickAction(
              key: PaymentConfirmationKeys.directions,
              icon: CatchIcons.directionsOutlined,
              label: 'Get directions',
              onPressed: onOpenDirections,
            ),
            DashboardQuickAction(
              key: PaymentConfirmationKeys.inviteFriend,
              icon: CatchIcons.platformShare(
                platform: Theme.of(context).platform,
              ),
              label: 'Invite friend',
              onPressed: onInviteFriend,
            ),
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
            'HEADS UP',
            style: CatchTextStyles.labelM(context, color: t.primary),
          ),
          gapH6,
          Text(
            'Bring a water bottle and arrive by the meeting time. '
            'Catches unlock automatically when the event finishes — '
            'keep your phone charged.',
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
                  'Bring someone you actually want there',
                  style: CatchTextStyles.sectionTitle(context),
                ),
                gapH2,
                Text(
                  'The best invites happen while the plan still feels fresh.',
                  style: CatchTextStyles.proseM(context, color: t.ink2),
                ),
              ],
            ),
          ),
          Text(
            'Share',
            style: CatchTextStyles.labelL(context, color: t.primary),
          ),
        ],
      ),
    );
  }
}
