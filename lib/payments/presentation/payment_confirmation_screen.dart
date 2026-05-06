import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/payments/presentation/payment_confirmation_controller.dart';
import 'package:catch_dating_app/payments/presentation/payment_confirmation_keys.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_joined_celebration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PaymentConfirmationScreen extends ConsumerWidget {
  const PaymentConfirmationScreen({super.key, required this.data});

  final PaymentConfirmationData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runAsync = ref.watch(watchRunProvider(data.runId));

    return runAsync.when(
      loading: () => const Scaffold(body: CatchLoadingIndicator()),
      error: (e, _) => Scaffold(
        body: CatchErrorState.fromError(
          e,
          context: AppErrorContext.payments,
          onRetry: () => ref.invalidate(watchRunProvider(data.runId)),
        ),
      ),
      data: (run) {
        if (run == null) {
          return const Scaffold(
            body: CatchErrorState(
              title: 'Run not found',
              message: 'This run is no longer available.',
            ),
          );
        }
        return _ConfirmationBody(data: data, run: run);
      },
    );
  }
}

class _ConfirmationBody extends ConsumerWidget {
  const _ConfirmationBody({required this.data, required this.run});

  final PaymentConfirmationData data;
  final Run run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubAsync = ref.watch(watchRunClubProvider(run.runClubId));
    final clubName = clubAsync.asData?.value?.name;

    return RunJoinedCelebrationScreen(
      run: run,
      clubName: clubName,
      paymentData: data,
      supplementalChildren: [
        _QuickActions(run: run),
        const _HeadsUp(),
        _ReferralBanner(run: run),
      ],
      backHomeKey: PaymentConfirmationKeys.backHome,
      onViewRun: () => context.goNamed(
        Routes.runDetailScreen.name,
        pathParameters: {'runClubId': run.runClubId, 'runId': run.id},
      ),
      onBackHome: () => context.goNamed(Routes.dashboardScreen.name),
    );
  }
}

class _QuickActions extends ConsumerWidget {
  const _QuickActions({required this.run});

  final Run run;

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
            onTap: () => unawaited(controller.addToCalendar(run)),
          ),
        ),
        gapW8,
        Expanded(
          child: _ActionTile(
            key: PaymentConfirmationKeys.directions,
            icon: Icons.directions_outlined,
            label: 'Get directions',
            onTap: () => unawaited(controller.openDirections(run)),
          ),
        ),
        gapW8,
        Expanded(
          child: _ActionTile(
            key: PaymentConfirmationKeys.inviteFriend,
            icon: Icons.ios_share_rounded,
            label: 'Invite a friend',
            onTap: () => unawaited(controller.inviteFriend(run)),
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
            'Catches unlock automatically when the run finishes — '
            'keep your phone charged.',
            style: CatchTextStyles.bodyS(context, color: t.ink),
          ),
        ],
      ),
    );
  }
}

class _ReferralBanner extends ConsumerWidget {
  const _ReferralBanner({required this.run});

  final Run run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final controller = ref.watch(paymentConfirmationControllerProvider);

    return CatchSurface(
      key: PaymentConfirmationKeys.referralShare,
      onTap: () => unawaited(controller.shareReferral(run)),
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
                  'Bring a friend, run together',
                  style: CatchTextStyles.titleS(context),
                ),
                gapH2,
                Text(
                  'Share the link · they get ₹100 off',
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
