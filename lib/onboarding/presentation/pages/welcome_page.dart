import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: t.heroGrad),
        child: Stack(
          children: [
            const Positioned.fill(child: _TrackPattern()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '● CATCH',
                      style: CatchTextStyles.labelSm(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Love arrives\nat mile\nthree.',
                      style: CatchTextStyles.displayXl(context).copyWith(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        height: 0.95,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Meet someone on a group run. Swipe on people you '
                      'actually ran with - not strangers 30 miles away.',
                      style: CatchTextStyles.bodyMd(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 26),
                    FilledButton(
                      onPressed: () =>
                          controller.goToStep(OnboardingStep.phone),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        backgroundColor: Colors.white,
                        foregroundColor: t.primary,
                        textStyle: CatchTextStyles.labelLg(context),
                      ),
                      child: const Text('Continue with phone'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackPattern extends StatelessWidget {
  const _TrackPattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _TrackPatternPainter());
  }
}

class _TrackPatternPainter extends CustomPainter {
  static const _stripeWidth = 5.0;
  static const _stripeGap = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..strokeWidth = _stripeWidth;

    _drawStripedCircle(
      canvas,
      center: Offset(size.width * 0.92, size.height * 0.12),
      radius: size.width * 0.34,
      paint: paint,
    );
    _drawStripedCircle(
      canvas,
      center: Offset(-size.width * 0.05, size.height * 0.88),
      radius: size.width * 0.42,
      paint: paint,
    );
  }

  void _drawStripedCircle(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Paint paint,
  }) {
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.6);

    for (var x = -radius * 2; x <= radius * 2; x += _stripeGap) {
      canvas.drawLine(Offset(x, -radius * 2), Offset(x, radius * 2), paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
