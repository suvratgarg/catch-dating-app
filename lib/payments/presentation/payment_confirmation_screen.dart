import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/detail_row.dart';
import 'package:catch_dating_app/core/widgets/catch_error_text.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentConfirmationScreen extends ConsumerWidget {
  const PaymentConfirmationScreen({super.key, required this.data});

  final PaymentConfirmationData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runAsync = ref.watch(watchRunProvider(data.runId));

    return Scaffold(
      body: runAsync.when(
        loading: () => const CatchLoadingIndicator(),
        error: (e, _) => CatchErrorText(e),
        data: (run) {
          if (run == null) {
            return const Center(child: Text('Run not found.'));
          }
          return _ConfirmationBody(
            data: data,
            run: run,
          );
        },
      ),
    );
  }
}

class _ConfirmationBody extends ConsumerWidget {
  const _ConfirmationBody({required this.data, required this.run});

  final PaymentConfirmationData data;
  final Run run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final clubAsync = ref.watch(watchRunClubProvider(run.runClubId));
    final clubName = clubAsync.asData?.value?.name;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroSection(data: data, run: run),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Sizes.p20,
                    Sizes.p20,
                    Sizes.p20,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _RunSummaryCard(
                        data: data,
                        run: run,
                        clubName: clubName,
                      ),
                      gapH14,
                      const _QuickActions(),
                      gapH18,
                      _HeadsUp(t: t),
                      gapH14,
                      const _ReferralBanner(),
                      // Extra space so content clears the sticky CTA.
                      SizedBox(height: 100 + bottomPadding),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _StickyBackToHome(t: t, bottomPadding: bottomPadding),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.data, required this.run});

  final PaymentConfirmationData data;
  final Run run;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final amount = RunFormatters.priceInPaise(data.amountInPaise);

    return Container(
      decoration: BoxDecoration(
        gradient: t.heroGrad,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(CatchRadius.lg + 8),
          bottomRight: Radius.circular(CatchRadius.lg + 8),
        ),
      ),
      child: Stack(
        children: [
          // Dot pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: CustomPaint(
                painter: _DotPatternPainter(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              Sizes.p20,
              MediaQuery.paddingOf(context).top + Sizes.p24,
              Sizes.p20,
              Sizes.p32,
            ),
            child: Column(
              children: [
                // Checkmark circle
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                gapH16,
                // "YOU'RE IN" label
                Text(
                  "You're in",
                  style: CatchTextStyles.labelM(
                    context,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                gapH6,
                // Run title
                Text(
                  run.title,
                  style: CatchTextStyles.displayL(
                    context,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                gapH8,
                // Payment ID
                Text(
                  'Booking confirmed · payment ID ${data.paymentId}',
                  style: CatchTextStyles.bodyS(
                    context,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                  textAlign: TextAlign.center,
                ),
                gapH6,
                Text(
                  amount,
                  style: CatchTextStyles.titleM(
                    context,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RunSummaryCard extends StatelessWidget {
  const _RunSummaryCard({
    required this.data,
    required this.run,
    required this.clubName,
  });

  final PaymentConfirmationData data;
  final Run run;
  final String? clubName;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final amount = RunFormatters.priceInPaise(data.amountInPaise);
    // Refund deadline: 12 hours before run start
    final refundDeadline = run.startTime.subtract(const Duration(hours: 12));

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(CatchRadius.md),
      ),
      padding: const EdgeInsets.all(Sizes.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Club photo placeholder
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(CatchRadius.sm + 4),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8A5B), Color(0xFFFF3E6F)],
                  ),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: Colors.white70,
                  size: 24,
                ),
              ),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (clubName != null) ...[
                      Text(
                        clubName!,
                        style: CatchTextStyles.labelM(context, color: t.ink3),
                      ),
                      gapH2,
                    ],
                    Text(
                      run.title,
                      style: CatchTextStyles.titleM(context),
                    ),
                    gapH2,
                    Text(
                      '${run.longDateLabel} · ${run.timeRangeLabel}',
                      style: CatchTextStyles.bodyS(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          gapH14,
          Divider(color: t.line, height: 1),
          gapH14,
          DetailRow(label: 'Where', value: run.meetingPoint),
          gapH10,
          DetailRow(
            label: 'Distance',
            value: '${run.distanceLabel} · ${run.pace.label.toLowerCase()} pace',
          ),
          gapH10,
          DetailRow(label: 'Paid', value: '$amount · UPI'),
          gapH10,
          DetailRow(
            label: 'Refund',
            value:
                'Full refund until ${RunFormatters.shortWeekday(refundDeadline)} ${RunFormatters.time(refundDeadline)}',
          ),
        ],
      ),
    );
  }
}


class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ActionTile(emoji: '📅', label: 'Add to\ncalendar')),
        gapW8,
        Expanded(child: _ActionTile(emoji: '📍', label: 'Get\ndirections')),
        gapW8,
        Expanded(child: _ActionTile(emoji: '👋', label: 'Invite a\nfriend')),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.emoji, required this.label});

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${label.replaceAll('\n', ' ')} coming soon'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(CatchRadius.sm + 4),
        ),
        padding: const EdgeInsets.symmetric(vertical: Sizes.p12, horizontal: Sizes.p8),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            gapH6,
            Text(
              label,
              style: CatchTextStyles.labelS(context, color: t.ink),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeadsUp extends StatelessWidget {
  const _HeadsUp({required this.t});

  final CatchTokens t;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: t.primarySoft,
        borderRadius: BorderRadius.circular(CatchRadius.md),
      ),
      padding: const EdgeInsets.all(Sizes.p14),
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

class _ReferralBanner extends StatelessWidget {
  const _ReferralBanner();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Share link coming soon'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CatchRadius.md),
          border: Border.all(color: t.line2, width: 1.5),
        ),
        padding: const EdgeInsets.all(Sizes.p14),
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
      ),
    );
  }
}

class _StickyBackToHome extends StatelessWidget {
  const _StickyBackToHome({
    required this.t,
    required this.bottomPadding,
  });

  final CatchTokens t;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: t.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: t.line, height: 1, thickness: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(
              Sizes.p16,
              Sizes.p12,
              Sizes.p16,
              Sizes.p12 + bottomPadding,
            ),
            child: CatchButton(
              label: 'Back to home',
              onPressed: () => Navigator.of(context).popUntil(
                (route) => route.isFirst,
              ),
              variant: CatchButtonVariant.secondary,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple dot pattern painter for the hero section background texture.
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 40.0;
    const dotRadius = 1.5;
    final paint = Paint()..color = Colors.white;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
