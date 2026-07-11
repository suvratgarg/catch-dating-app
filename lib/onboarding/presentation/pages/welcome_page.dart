import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_fonts.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/routing/go_router.dart' as app_router;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key, this.playIntro = true});

  static const splashTapTargetKey = ValueKey<String>(
    'welcome-splash-tap-target',
  );

  /// Allows tests and deterministic capture tools to render the landed state.
  final bool playIntro;

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage>
    with TickerProviderStateMixin {
  late final AnimationController _spinController;
  late final AnimationController _landingController;
  late final Listenable _sceneListenable;

  bool _started = false;
  bool _landed = false;
  bool _shownLogged = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: CatchMotion.welcomeReel,
    )..addStatusListener(_handleSpinStatus);
    _landingController = AnimationController(
      vsync: this,
      duration: CatchMotion.welcomeLandingReveal,
    );
    _sceneListenable = Listenable.merge([_spinController, _landingController]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final renderLandedImmediately = _shouldRenderLandedImmediately(context);
    _logShown(
      renderLandedImmediately
          ? MediaQuery.of(context).disableAnimations
                ? 'reduced_motion'
                : 'direct'
          : 'animated',
    );
    if (renderLandedImmediately) {
      _land(immediate: true, notify: _started);
      return;
    }
    if (!_started && !_landed) {
      _started = true;
      _spinController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant WelcomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playIntro && !widget.playIntro) {
      _land(immediate: true);
    }
  }

  @override
  void dispose() {
    _spinController
      ..removeStatusListener(_handleSpinStatus)
      ..dispose();
    _landingController.dispose();
    super.dispose();
  }

  void _handleSpinStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_landed) {
      _land(immediate: false);
    }
  }

  bool _shouldRenderLandedImmediately(BuildContext context) {
    return !widget.playIntro || MediaQuery.of(context).disableAnimations;
  }

  void _skip() {
    if (!_landed) {
      _logSkipped();
      _land(immediate: false);
    }
  }

  void _land({required bool immediate, bool notify = true}) {
    final wasLanded = _landed;
    _started = true;
    _landed = true;
    _spinController.stop();
    _spinController.value = 1;
    if (immediate) {
      _landingController.value = 1;
    } else if (_landingController.value == 0) {
      HapticFeedback.selectionClick();
      _landingController.forward();
    }
    if (notify && mounted && !wasLanded) {
      setState(() {});
    }
  }

  void _logShown(String motion) {
    if (_shownLogged) return;
    _shownLogged = true;
    ref
        .read(appAnalyticsProvider)
        .logEvent(
          AnalyticsEvents.welcomeSplashShown,
          parameters: {AnalyticsParameters.splashMotion: motion},
        );
  }

  void _logSkipped() {
    ref
        .read(appAnalyticsProvider)
        .logEvent(
          AnalyticsEvents.welcomeSplashSkipped,
          parameters: {AnalyticsParameters.splashMotion: 'animated'},
        );
  }

  void _logCta(String cta) {
    ref
        .read(appAnalyticsProvider)
        .logEvent(
          AnalyticsEvents.welcomeCtaTapped,
          parameters: {AnalyticsParameters.cta: cta},
        );
  }

  @override
  Widget build(BuildContext context) {
    const d = CatchTokens.editorialDark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: d.bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: ColoredBox(
        color: d.bg,
        child: Semantics(
          button: !_landed,
          label: _landed ? null : 'Skip welcome animation',
          onTap: _landed ? null : _skip,
          child: GestureDetector(
            key: WelcomePage.splashTapTargetKey,
            behavior: HitTestBehavior.opaque,
            onTap: _landed ? null : _skip,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final media = MediaQuery.of(context);
                final size = Size(
                  constraints.hasBoundedWidth
                      ? constraints.maxWidth
                      : media.size.width,
                  constraints.hasBoundedHeight
                      ? constraints.maxHeight
                      : media.size.height,
                );
                final sceneWidth = math.min(
                  size.width,
                  CatchLayout.welcomeMaxWidth,
                );

                return AnimatedBuilder(
                  animation: _sceneListenable,
                  builder: (context, _) {
                    return Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: sceneWidth,
                        height: size.height,
                        child: WelcomeScene(
                          viewportHeight: size.height,
                          mediaPadding: media.padding,
                          spinValue: _spinController.value,
                          landingValue: _landingController.value,
                          landed: _landed,
                          onContinue: () {
                            _logCta('continue_phone');
                            context.go(_authLocation(context));
                          },
                          onExplore: () {
                            _logCta('see_whats_on');
                            context.goNamed(
                              app_router.Routes.exploreScreen.name,
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeScene extends StatelessWidget {
  const WelcomeScene({
    super.key,
    required this.viewportHeight,
    required this.mediaPadding,
    required this.spinValue,
    required this.landingValue,
    required this.landed,
    required this.onContinue,
    required this.onExplore,
  });

  final double viewportHeight;
  final EdgeInsets mediaPadding;
  final double spinValue;
  final double landingValue;
  final bool landed;
  final VoidCallback onContinue;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    const tokens = CatchTokens.editorialDark;
    final wheelTop = math.max(
      CatchLayout.welcomeReelTop,
      mediaPadding.top + CatchSpacing.s1,
    );
    final reelHeight = math.min(
      CatchLayout.welcomeReelHeight,
      math.max(0.0, viewportHeight - wheelTop),
    );
    final catchTop = wheelTop + CatchLayout.welcomeReelCatchFocusTop;
    final buttonsBottom = math.max(
      CatchLayout.welcomeButtonsBottom,
      mediaPadding.bottom + CatchSpacing.s4,
    );
    final ctaTop =
        viewportHeight - buttonsBottom - CatchLayout.welcomeCtaApproxHeight;
    final minBodyTop = catchTop + CatchLayout.welcomeHeadlineToBodyGap;
    final maxBodyTop = math.max(
      minBodyTop,
      ctaTop -
          CatchLayout.welcomeMinBodyToCtaGap -
          CatchLayout.welcomeCtaApproxHeight,
    );
    final bodyTop = math
        .min(CatchLayout.welcomeBodyTop, maxBodyTop)
        .clamp(minBodyTop, CatchLayout.welcomeBodyTop)
        .toDouble();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: wheelTop,
          height: reelHeight,
          child: ReelBand(
            spinValue: spinValue,
            landingValue: landingValue,
            landed: landed,
          ),
        ),
        Positioned(
          left: CatchLayout.welcomeReelCatchLeft,
          top: catchTop,
          child: Text('Catch', style: _WelcomeType.headline(tokens.ink)),
        ),
        if (landed) ...[
          Positioned(
            left: CatchLayout.welcomeBodyHorizontalPadding,
            right: CatchLayout.welcomeBodyHorizontalPadding,
            top: bodyTop,
            child: RevealEntrance(
              landingValue: landingValue,
              order: 0,
              child: Text(
                'Show up to something you\'d do anyway \u2014 a long run, '
                'a long table, trivia night. Match only with the people who '
                'were actually there.',
                style: _WelcomeType.body(tokens.ink),
              ),
            ),
          ),
          Positioned(
            left: CatchLayout.welcomeBodyHorizontalPadding,
            right: CatchLayout.welcomeBodyHorizontalPadding,
            bottom: buttonsBottom,
            child: IgnorePointer(
              ignoring: landingValue < 0.4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RevealEntrance(
                    landingValue: landingValue,
                    order: 1,
                    child: CatchButton(
                      label: 'Continue with phone',
                      onPressed: onContinue,
                      size: CatchButtonSize.lg,
                      fullWidth: true,
                      backgroundColor: tokens.primary,
                      foregroundColor: tokens.primaryInk,
                    ),
                  ),
                  const SizedBox(height: CatchLayout.welcomeButtonGap),
                  RevealEntrance(
                    landingValue: landingValue,
                    order: 2,
                    child: CatchButton(
                      label: 'See what\'s on',
                      onPressed: onExplore,
                      variant: CatchButtonVariant.secondary,
                      size: CatchButtonSize.lg,
                      fullWidth: true,
                      backgroundColor: Colors.transparent,
                      foregroundColor: tokens.ink,
                      borderColor: tokens.line2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ReelBand extends StatelessWidget {
  const ReelBand({
    super.key,
    required this.spinValue,
    required this.landingValue,
    required this.landed,
  });

  final double spinValue;
  final double landingValue;
  final bool landed;

  @override
  Widget build(BuildContext context) {
    final offset = _welcomeTrackOffset(spinValue: spinValue, landed: landed);
    final trackHeight =
        welcomePhraseBank.length * CatchLayout.welcomeReelRowHeight;

    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CatchWelcomeColors.reelMaskClear,
            CatchWelcomeColors.reelMaskOpaque,
            CatchWelcomeColors.reelMaskOpaque,
            CatchWelcomeColors.reelMaskClear,
          ],
          stops: [
            0,
            CatchOpacity.welcomeReelMaskLead,
            CatchOpacity.welcomeReelMaskTail,
            1,
          ],
        ).createShader(bounds);
      },
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: trackHeight * 2,
          maxHeight: trackHeight * 2,
          child: Transform.translate(
            offset: Offset(0, -offset),
            child: SizedBox(
              height: trackHeight * 2,
              child: Column(
                children: [
                  for (var copy = 0; copy < 2; copy += 1)
                    for (
                      var index = 0;
                      index < welcomePhraseBank.length;
                      index += 1
                    )
                      ReelRow(
                        phrase: welcomePhraseBank[index],
                        phraseIndex: index,
                        rowIndex: copy * welcomePhraseBank.length + index,
                        trackOffset: offset,
                        landingValue: landingValue,
                        landed: landed,
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReelRow extends StatelessWidget {
  const ReelRow({
    super.key,
    required this.phrase,
    required this.phraseIndex,
    required this.rowIndex,
    required this.trackOffset,
    required this.landingValue,
    required this.landed,
  });

  final WelcomePhrase phrase;
  final int phraseIndex;
  final int rowIndex;
  final double trackOffset;
  final double landingValue;
  final bool landed;

  @override
  Widget build(BuildContext context) {
    const tokens = CatchTokens.editorialDark;
    final center = CatchLayout.welcomeReelRowCenter(
      rowIndex: rowIndex,
      trackOffset: trackOffset,
    );
    final distance = center - CatchLayout.welcomeReelFocus;
    final absDistance = distance.abs();
    final inFocus = CatchLayout.welcomeReelRowIsFocused(distance);
    final isLandingFocus =
        landed && phraseIndex == welcomeLandingIndex && inFocus;
    final pigment =
        ActivityPalette.pigments[phrase.activityKind] ??
        ActivityPalette.pigments[ActivityKind.openActivity]!;
    final mutedPigment = Color.lerp(
      tokens.ink3,
      pigment,
      CatchOpacity.welcomeReelDecolorPigment,
    )!;
    final dimOpacity = math.max(
      CatchOpacity.welcomeReelDimMin,
      1 - (absDistance / CatchLayout.welcomeReelDimRange),
    );
    final nonFocusFade = _durationProgress(
      landingValue,
      CatchMotion.welcomeNonFocusFade,
    );
    final colorCool = _durationProgress(
      landingValue,
      CatchMotion.welcomeTextCool,
    );
    final textColor = isLandingFocus
        ? Color.lerp(pigment, tokens.ink, colorCool)!
        : inFocus
        ? pigment
        : mutedPigment;
    final rowOpacity = landed && !isLandingFocus
        ? dimOpacity * (1 - nonFocusFade)
        : dimOpacity;
    final periodOpacity = inFocus ? 1.0 : 0.0;
    final style = _WelcomeType.headline(textColor).copyWith(
      decoration: inFocus ? TextDecoration.underline : TextDecoration.none,
      decorationColor: pigment,
      decorationThickness: 4,
      decorationStyle: TextDecorationStyle.solid,
    );

    return SizedBox(
      height: CatchLayout.welcomeReelRowHeight,
      child: Opacity(
        opacity: rowOpacity.clamp(0, 1).toDouble(),
        child: Padding(
          padding: CatchInsets.welcomeReelRow,
          child: Align(
            alignment: Alignment.topLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: phrase.object),
                  TextSpan(
                    text: '.',
                    style: style.copyWith(
                      color: textColor.withValues(alpha: periodOpacity),
                    ),
                  ),
                ],
                style: style,
              ),
              maxLines: 2,
              overflow: TextOverflow.clip,
              softWrap: true,
            ),
          ),
        ),
      ),
    );
  }
}

class RevealEntrance extends StatelessWidget {
  const RevealEntrance({
    super.key,
    required this.landingValue,
    required this.order,
    required this.child,
  });

  final double landingValue;
  final int order;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final progress = _revealProgress(landingValue, order);

    return Opacity(
      opacity: progress,
      child: Transform.translate(
        offset: Offset(0, (1 - progress) * CatchLayout.welcomeRevealOffsetY),
        child: child,
      ),
    );
  }
}

double _welcomeTrackOffset({required double spinValue, required bool landed}) {
  final trackH = welcomePhraseBank.length * CatchLayout.welcomeReelRowHeight;
  final base =
      CatchLayout.welcomeReelLandingOffset(welcomeLandingIndex) % trackH;
  if (landed) return base;

  final eased = _welcomeSpinEase(spinValue, CatchMotion.welcomeSpinCurvePower);
  final endY = base + (CatchMotion.welcomeReelSpins * trackH);
  return (endY * eased) % trackH;
}

double _welcomeSpinEase(double progress, double curvePower) {
  if (progress <= 0) return 0;
  if (progress >= 1) return 1;
  final a = math.pow(progress, curvePower).toDouble();
  final b = math.pow(1 - progress, curvePower).toDouble();
  return a / (a + b);
}

double _revealProgress(double value, int order) {
  final totalMs = CatchMotion.welcomeLandingReveal.inMilliseconds;
  final startMs =
      CatchMotion.welcomeRevealStart.inMilliseconds +
      (order * CatchMotion.welcomeRevealStagger.inMilliseconds);
  final endMs = startMs + CatchMotion.welcomeRevealSettle.inMilliseconds;
  final start = startMs / totalMs;
  final end = endMs / totalMs;
  final raw = ((value - start) / (end - start)).clamp(0, 1).toDouble();
  return CatchMotion.welcomeRevealCurve.transform(raw);
}

class WelcomePhrase {
  const WelcomePhrase(this.object, this.activityKind);

  final String object;
  final ActivityKind activityKind;
}

abstract final class _WelcomeType {
  static TextStyle headline(Color color) => CatchFonts.voice(
    fontSize: 36,
    height: 1.02,
    color: color,
    letterSpacing: -0.5,
  );

  static TextStyle body(Color color) => CatchFonts.voice(
    fontSize: 15,
    height: 1.48,
    color: color.withValues(alpha: CatchOpacity.welcomeIntroBody),
    fontWeight: FontWeight.w400,
  );
}

double _durationProgress(double value, Duration duration) {
  final end =
      duration.inMilliseconds / CatchMotion.welcomeLandingReveal.inMilliseconds;
  return (value / end).clamp(0, 1).toDouble();
}

const welcomePhraseBank = <WelcomePhrase>[
  WelcomePhrase('the 6:30 run', ActivityKind.socialRun),
  WelcomePhrase('the long table', ActivityKind.dinner),
  WelcomePhrase('Tuesday trivia', ActivityKind.pubQuiz),
  WelcomePhrase('Sunday doubles', ActivityKind.padel),
  WelcomePhrase('the sunset 5K', ActivityKind.running),
  WelcomePhrase('the climb', ActivityKind.strengthTraining),
  WelcomePhrase('the record fair', ActivityKind.barCrawl),
  WelcomePhrase('the gallery', ActivityKind.yoga),
  WelcomePhrase('morning swim', ActivityKind.cycling),
  WelcomePhrase('the supper club', ActivityKind.dinner),
  WelcomePhrase('someone\'s eye', ActivityKind.singlesMixer),
  WelcomePhrase('someone real', ActivityKind.socialRun),
];

const welcomeLandingIndex = 11;

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
