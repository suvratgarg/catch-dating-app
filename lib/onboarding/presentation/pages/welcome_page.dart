import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const d = CatchTokens.sunsetDark;
    final t = CatchTokens.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: t.heroGrad),
        child: Stack(
          children: [
            const Positioned.fill(child: _TrackPattern()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: CatchInsets.welcomeHero,
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CATCH',
                                style: CatchTextStyles.kicker(
                                  context,
                                  color: d.ink,
                                ),
                              ),
                              gapH12,
                              Image.asset(
                                'assets/branding/catch_icon.png',
                                width: CatchLayout.welcomeBrandMarkExtent,
                                height: CatchLayout.welcomeBrandMarkExtent,
                                semanticLabel: 'Catch',
                              ),
                              const Spacer(),
                              Text(
                                'Love arrives\nat mile\nthree.',
                                style: CatchTextStyles.display(
                                  context,
                                  color: d.ink,
                                ),
                              ),
                              gapH16,
                              Text(
                                'Meet someone on a group event. Catch people you '
                                'actually ran with - not strangers 30 miles away.',
                                style: CatchTextStyles.proseL(
                                  context,
                                  color: d.ink.withValues(
                                    alpha: CatchOpacity.welcomeHeroBody,
                                  ),
                                ),
                              ),
                              gapH24,
                              CatchButton(
                                label: 'Explore events',
                                onPressed: () => context.go('/clubs'),
                                variant: CatchButtonVariant.light,
                                size: CatchButtonSize.lg,
                                fullWidth: true,
                              ),
                              gapH12,
                              CatchButton(
                                label: 'Continue with phone',
                                onPressed: () =>
                                    context.go(_authLocation(context)),
                                variant: CatchButtonVariant.secondary,
                                size: CatchButtonSize.lg,
                                fullWidth: true,
                                backgroundColor: d.ink.withValues(
                                  alpha:
                                      CatchOpacity.welcomeSecondaryButtonFill,
                                ),
                                foregroundColor: d.ink,
                                borderColor: d.ink.withValues(
                                  alpha:
                                      CatchOpacity.welcomeSecondaryButtonBorder,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _authLocation(BuildContext context) {
  final from = _safeFrom(GoRouterState.of(context).uri.queryParameters['from']);
  if (from == null) return '/auth';

  return Uri(path: '/auth', queryParameters: {'from': from}).toString();
}

String? _safeFrom(String? from) {
  if (from == null || from.isEmpty || !from.startsWith('/')) return null;
  final uri = Uri.tryParse(from);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  return uri.toString();
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
      ..color = CatchTokens.editorialLight.withValues(
        alpha: CatchOpacity.welcomeTrackPattern,
      )
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
