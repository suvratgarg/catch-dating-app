import 'dart:async';

import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_joined_celebration_screen.dart';
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

    return eventAsync.when(
      loading: () => const Scaffold(body: CatchLoadingIndicator()),
      error: (e, _) => Scaffold(
        body: CatchErrorState.fromError(
          e,
          context: AppErrorContext.payments,
          onRetry: () => ref.invalidate(watchEventProvider(data.eventId)),
        ),
      ),
      data: (event) {
        if (event == null) {
          return const Scaffold(
            body: CatchErrorState(
              title: 'Event not found',
              message: 'This event is no longer available.',
            ),
          );
        }
        return _ConfirmationBody(data: data, event: event);
      },
    );
  }
}

class _ConfirmationBody extends ConsumerWidget {
  const _ConfirmationBody({required this.data, required this.event});

  final PaymentConfirmationData data;
  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubAsync = ref.watch(watchClubProvider(event.clubId));
    final clubName = clubAsync.asData?.value?.name;

    return EventJoinedCelebrationScreen(
      event: event,
      clubName: clubName,
      paymentData: data,
      supplementalChildren: [
        _QuickActions(event: event),
        const _HeadsUp(),
        _ReferralBanner(event: event),
      ],
      backHomeKey: PaymentConfirmationKeys.backHome,
      onViewEvent: () => context.goNamed(
        Routes.eventDetailScreen.name,
        pathParameters: {'clubId': event.clubId, 'eventId': event.id},
        extra: event,
      ),
      onBackHome: () => context.goNamed(Routes.dashboardScreen.name),
    );
  }
}

class _QuickActions extends ConsumerWidget {
  const _QuickActions({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(paymentConfirmationControllerProvider);

    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            key: PaymentConfirmationKeys.addToCalendar,
            icon: Icons.calendar_month_outlined,
            label: 'Add to calendar',
            onTap: () => unawaited(controller.addToCalendar(event)),
          ),
        ),
        gapW8,
        Expanded(
          child: _ActionTile(
            key: PaymentConfirmationKeys.directions,
            icon: Icons.directions_outlined,
            label: 'Get directions',
            onTap: () => unawaited(controller.openDirections(event)),
          ),
        ),
        gapW8,
        Expanded(
          child: _ActionTile(
            key: PaymentConfirmationKeys.inviteFriend,
            icon: Icons.ios_share_rounded,
            label: 'Invite a friend',
            onTap: () => unawaited(controller.inviteFriend(event)),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        vertical: CatchSpacing.s3,
        horizontal: CatchSpacing.s2,
      ),
      radius: CatchRadius.sm + 4,
      borderColor: t.line,
      child: Column(
        children: [
          Icon(icon, size: 20, color: t.primary),
          gapH6,
          Text(
            label,
            style: CatchTextStyles.labelS(context, color: t.ink),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HeadsUp extends StatelessWidget {
  const _HeadsUp();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.primarySoft,
      padding: const EdgeInsets.all(Sizes.p14),
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
            style: CatchTextStyles.bodyS(context, color: t.ink),
          ),
        ],
      ),
    );
  }
}

class _ReferralBanner extends ConsumerWidget {
  const _ReferralBanner({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final controller = ref.watch(paymentConfirmationControllerProvider);

    return CatchSurface(
      key: PaymentConfirmationKeys.referralShare,
      onTap: () => unawaited(controller.shareReferral(event)),
      padding: const EdgeInsets.all(Sizes.p14),
      radius: CatchRadius.md,
      borderColor: t.line2,
      borderWidth: 1.5,
      child: Row(
        children: [
          const Text('🤝', style: TextStyle(fontSize: 24)),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bring a friend, event together',
                  style: CatchTextStyles.titleS(context),
                ),
                gapH2,
                Text(
                  'Share the link for a friend discount',
                  style: CatchTextStyles.bodyS(context),
                ),
              ],
            ),
          ),
          Text(
            'Share →',
            style: CatchTextStyles.labelL(context, color: t.primary),
          ),
        ],
      ),
    );
  }
}
