import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/startup/catch_startup_animation_scope.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_scene_viewport.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart' as app_router;
import 'package:catch_tokens/catch_tokens.dart';
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
                ? context.l10n.onboardingWelcomePageVisiblecopyReducedMotion
                : context.l10n.onboardingWelcomePageVisiblecopyDirect
          : context.l10n.onboardingWelcomePageVisiblecopyAnimated,
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
    return !widget.playIntro ||
        MediaQuery.of(context).disableAnimations ||
        (CatchStartupAnimationScope.maybeOf(
              context,
            )?.consumerWelcomeReelPlayed ??
            false);
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
          parameters: {
            AnalyticsParameters.splashMotion:
                context.l10n.onboardingWelcomePageVisiblecopyAnimated,
          },
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
          label: _landed
              ? null
              : context.l10n.onboardingWelcomePageLabelSkipWelcomeAnimation,
          onTap: _landed ? null : _skip,
          child: GestureDetector(
            key: WelcomePage.splashTapTargetKey,
            behavior: HitTestBehavior.opaque,
            onTap: _landed ? null : _skip,
            child: CatchSceneViewport(
              maxWidth: CatchWelcomeTokens.welcomeMaxWidth,
              builder: (context, viewport) => AnimatedBuilder(
                animation: _sceneListenable,
                builder: (context, _) {
                  return WelcomeScene(
                    viewportWidth: viewport.width,
                    viewportHeight: viewport.height,
                    mediaPadding: viewport.mediaPadding,
                    spinValue: _spinController.value,
                    landingValue: _landingController.value,
                    landed: _landed,
                    onContinue: () {
                      _logCta(
                        context
                            .l10n
                            .onboardingWelcomePageVisiblecopyContinuePhone,
                      );
                      context.go(_authLocation(context));
                    },
                    onExplore: () {
                      _logCta(
                        context.l10n.onboardingWelcomePageVisiblecopySeeWhatsOn,
                      );
                      context.goNamed(app_router.Routes.exploreScreen.name);
                    },
                  );
                },
              ),
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
    required this.viewportWidth,
    required this.viewportHeight,
    required this.mediaPadding,
    required this.spinValue,
    required this.landingValue,
    required this.landed,
    required this.onContinue,
    required this.onExplore,
    this.showLandingContent = true,
  });

  static const catchWordKey = ValueKey<String>('welcome-reel-catch-word');

  final double viewportWidth;
  final double viewportHeight;
  final EdgeInsets mediaPadding;
  final double spinValue;
  final double landingValue;
  final bool landed;
  final VoidCallback onContinue;
  final VoidCallback onExplore;
  final bool showLandingContent;

  @override
  Widget build(BuildContext context) {
    const tokens = CatchTokens.editorialDark;
    final sceneWidth = viewportWidth;
    final wheelTop = CatchWelcomeTokens.welcomeReelTopFor(mediaPadding);
    final reelHeight = math.min(
      CatchWelcomeTokens.welcomeReelHeight,
      math.max(0.0, viewportHeight - wheelTop),
    );
    final catchTop = CatchWelcomeTokens.welcomeReelCatchTopFor(mediaPadding);
    final catchLeft = CatchWelcomeTokens.welcomeReelCatchLeftForWidth(sceneWidth);
    final rightInset = CatchWelcomeTokens.welcomeReelRightForWidth(sceneWidth);
    final focusedPhraseIndex = welcomeFocusedPhraseIndex(
      spinValue: spinValue,
      landed: landed,
    );
    final focusedPhrase = welcomePhraseBank[focusedPhraseIndex];
    final pigment =
        ActivityPalette.pigments[focusedPhrase.activityKind] ??
        ActivityPalette.pigments[ActivityKind.openActivity]!;
    final colorCool = _durationProgress(
      landingValue,
      CatchMotion.welcomeTextCool,
    );
    final phraseColor = landed && focusedPhraseIndex == welcomeLandingIndex
        ? Color.lerp(pigment, tokens.ink, colorCool)!
        : pigment;
    final buttonsBottom = math.max(
      CatchWelcomeTokens.welcomeButtonsBottom,
      mediaPadding.bottom + CatchSpacing.s4,
    );
    final ctaTop =
        viewportHeight - buttonsBottom - CatchWelcomeTokens.welcomeCtaApproxHeight;
    final minBodyTop = catchTop + CatchWelcomeTokens.welcomeHeadlineToBodyGap;
    final maxBodyTop = math.max(
      minBodyTop,
      ctaTop -
          CatchWelcomeTokens.welcomeMinBodyToCtaGap -
          CatchWelcomeTokens.welcomeCtaApproxHeight,
    );
    final bodyTop = math
        .min(CatchWelcomeTokens.welcomeBodyTop, maxBodyTop)
        .clamp(minBodyTop, CatchWelcomeTokens.welcomeBodyTop)
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
            viewportWidth: sceneWidth,
            spinValue: spinValue,
            landingValue: landingValue,
            landed: landed,
            hideFocusedPhrase: true,
          ),
        ),
        Positioned(
          key: WelcomeScene.catchWordKey,
          left: catchLeft,
          right: rightInset,
          top: catchTop,
          child: AnimatedSwitcher(
            duration: CatchMotion.fast,
            switchInCurve: CatchMotion.easeOutCurve,
            switchOutCurve: CatchMotion.easeInCubicCurve,
            layoutBuilder: (currentChild, previousChildren) => Stack(
              alignment: Alignment.topLeft,
              clipBehavior: Clip.none,
              children: [...previousChildren, ?currentChild],
            ),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: WelcomeFocusLockup(
              key: ValueKey<int>(focusedPhraseIndex),
              phrase: focusedPhrase.object,
              catchColor: tokens.ink,
              maxWidth: sceneWidth - catchLeft - rightInset,
              phraseColor: phraseColor,
              underlineColor: pigment,
            ),
          ),
        ),
        if (landed && showLandingContent) ...[
          Positioned(
            left: CatchWelcomeTokens.welcomeBodyHorizontalPadding,
            right: CatchWelcomeTokens.welcomeBodyHorizontalPadding,
            top: bodyTop,
            child: RevealEntrance(
              landingValue: landingValue,
              order: 0,
              child: Text(
                context.l10n.onboardingWelcomePageTextShowUpToSomething,
                style: CatchTextStyles.welcomeIntroBody(
                  context,
                  color: tokens.ink.withValues(
                    alpha: CatchOpacity.welcomeIntroBody,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: CatchWelcomeTokens.welcomeBodyHorizontalPadding,
            right: CatchWelcomeTokens.welcomeBodyHorizontalPadding,
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
                      label: context
                          .l10n
                          .onboardingWelcomePageLabelContinueWithPhone,
                      onPressed: onContinue,
                      size: CatchButtonSize.lg,
                      fullWidth: true,
                      backgroundColor: tokens.primary,
                      foregroundColor: tokens.primaryInk,
                    ),
                  ),
                  const SizedBox(height: CatchWelcomeTokens.welcomeButtonGap),
                  RevealEntrance(
                    landingValue: landingValue,
                    order: 2,
                    child: CatchButton(
                      label: context.l10n.onboardingWelcomePageLabelSeeWhatSOn,
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

/// The fixed grammatical focus slot shared by the Consumer boot handoff and
/// the moving Welcome reel.
///
/// `Catch` and the active phrase are painted as one line with a literal space,
/// so their alphabetic baseline cannot drift. The underline is positioned from
/// the measured phrase glyph box and never participates in the text baseline.
class WelcomeFocusLockup extends StatelessWidget {
  const WelcomeFocusLockup({
    super.key,
    required this.catchColor,
    required this.maxWidth,
    this.phrase,
    this.phraseColor,
    this.underlineColor,
    this.showBrandUnderscore = false,
  }) : assert(
         phrase == null || (phraseColor != null && underlineColor != null),
       );

  static const textKey = ValueKey<String>('welcome-focus-lockup-text');
  static const underlineKey = ValueKey<String>(
    'welcome-focus-lockup-underline',
  );

  final String? phrase;
  final Color catchColor;
  final double maxWidth;
  final Color? phraseColor;
  final Color? underlineColor;
  final bool showBrandUnderscore;

  @override
  Widget build(BuildContext context) {
    final style = CatchTextStyles.welcomeReelHeadline(
      context,
      color: catchColor,
    );
    final textDirection = Directionality.of(context);
    final textScaler = _welcomeReelTextScaler(context);
    final catchLabel = context.l10n.onboardingWelcomePageTextCatch;
    final phraseText = phrase == null ? null : '$phrase.';
    final children = <InlineSpan>[
      TextSpan(text: catchLabel, style: style),
      if (showBrandUnderscore)
        TextSpan(
          text: '_',
          style: style.copyWith(color: CatchWelcomeColors.wordmarkBlank),
        ),
      if (phraseText != null) ...[
        TextSpan(text: ' ', style: style),
        TextSpan(
          text: phraseText,
          style: style.copyWith(color: phraseColor),
        ),
      ],
    ];
    final lockupSpan = TextSpan(children: children);
    final painter = TextPainter(
      text: lockupSpan,
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    final phraseStart = phraseText == null ? null : catchLabel.length + 1;
    final phraseBoxes = phraseStart == null
        ? const <TextBox>[]
        : painter.getBoxesForSelection(
            TextSelection(
              baseOffset: phraseStart,
              // Keep the rule under the phrase glyphs, not the terminal period.
              extentOffset: phraseStart + phrase!.length,
            ),
          );
    final phraseBox = phraseBoxes.isEmpty ? null : phraseBoxes.first;
    final underlineTop = painter.height + CatchWelcomeTokens.welcomeReelUnderlineGap;
    final contentHeight = phraseBox == null
        ? painter.height
        : math.max(
            painter.height,
            underlineTop + CatchWelcomeTokens.welcomeReelUnderlineThickness,
          );

    final fitScale = painter.width <= 0
        ? 1.0
        : math.min(1.0, maxWidth / painter.width);
    final fittedWidth = painter.width * fitScale;
    final fittedHeight = contentHeight * fitScale;
    final semanticLabel = phraseText == null
        ? catchLabel
        : '$catchLabel $phraseText';

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: fittedWidth,
        height: fittedHeight,
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: painter.width,
          maxWidth: painter.width,
          minHeight: contentHeight,
          maxHeight: contentHeight,
          child: Transform.scale(
            scale: fitScale,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: painter.width,
              height: contentHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Text.rich(
                    key: WelcomeFocusLockup.textKey,
                    lockupSpan,
                    style: style,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    textScaler: textScaler,
                  ),
                  if (phraseBox != null)
                    Positioned(
                      left: phraseBox.left,
                      top: underlineTop,
                      width: phraseBox.right - phraseBox.left,
                      height: CatchWelcomeTokens.welcomeReelUnderlineThickness,
                      child: ColoredBox(
                        key: WelcomeFocusLockup.underlineKey,
                        color: underlineColor!,
                      ),
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

TextScaler _welcomeReelTextScaler(BuildContext context) {
  final requestedScale = MediaQuery.textScalerOf(context).scale(1);
  return TextScaler.linear(
    requestedScale.clamp(1.0, CatchWelcomeTokens.welcomeReelMaxTextScale),
  );
}

class ReelBand extends StatelessWidget {
  const ReelBand({
    super.key,
    this.viewportWidth = CatchWelcomeTokens.welcomeReferenceWidth,
    required this.spinValue,
    required this.landingValue,
    required this.landed,
    this.hideFocusedPhrase = false,
  });

  final double viewportWidth;
  final double spinValue;
  final double landingValue;
  final bool landed;
  final bool hideFocusedPhrase;

  @override
  Widget build(BuildContext context) {
    final offset = _welcomeTrackOffset(spinValue: spinValue, landed: landed);
    final trackHeight =
        welcomePhraseBank.length * CatchWelcomeTokens.welcomeReelRowHeight;

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
                        viewportWidth: viewportWidth,
                        phrase: welcomePhraseBank[index],
                        phraseIndex: index,
                        rowIndex: copy * welcomePhraseBank.length + index,
                        trackOffset: offset,
                        landingValue: landingValue,
                        landed: landed,
                        hideWhenFocused: hideFocusedPhrase,
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
    required this.viewportWidth,
    required this.phrase,
    required this.phraseIndex,
    required this.rowIndex,
    required this.trackOffset,
    required this.landingValue,
    required this.landed,
    this.hideWhenFocused = false,
  });

  static const focusedPhraseKey = ValueKey<String>(
    'welcome-reel-focused-phrase',
  );
  static const focusedUnderlineKey = ValueKey<String>(
    'welcome-reel-focused-underline',
  );

  final double viewportWidth;
  final WelcomePhrase phrase;
  final int phraseIndex;
  final int rowIndex;
  final double trackOffset;
  final double landingValue;
  final bool landed;
  final bool hideWhenFocused;

  @override
  Widget build(BuildContext context) {
    const tokens = CatchTokens.editorialDark;
    final center = CatchWelcomeTokens.welcomeReelRowCenter(
      rowIndex: rowIndex,
      trackOffset: trackOffset,
    );
    final distance = center - CatchWelcomeTokens.welcomeReelFocus;
    final absDistance = distance.abs();
    final inFocus = CatchWelcomeTokens.welcomeReelRowIsFocused(distance);
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
      1 - (absDistance / CatchWelcomeTokens.welcomeReelDimRange),
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
    final periodOpacity = inFocus && !hideWhenFocused ? 1.0 : 0.0;
    final style = CatchTextStyles.welcomeReelHeadline(
      context,
      color: textColor,
    );

    final effectiveOpacity = hideWhenFocused && inFocus ? 0.0 : rowOpacity;

    return SizedBox(
      height: CatchWelcomeTokens.welcomeReelRowHeight,
      child: Opacity(
        opacity: effectiveOpacity.clamp(0, 1).toDouble(),
        child: Padding(
          padding: EdgeInsets.only(
            left: CatchWelcomeTokens.welcomeReelObjectLeftForWidth(viewportWidth),
            right: CatchWelcomeTokens.welcomeReelRightForWidth(viewportWidth),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Text.rich(
                  key: inFocus ? focusedPhraseKey : null,
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
                  ),
                  style: style,
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                  softWrap: true,
                  textScaler: _welcomeReelTextScaler(context),
                ),
                if (inFocus && !hideWhenFocused)
                  Positioned(
                    key: focusedUnderlineKey,
                    left: 0,
                    right: 0,
                    bottom:
                        -CatchWelcomeTokens.welcomeReelUnderlineGap -
                        CatchWelcomeTokens.welcomeReelUnderlineThickness,
                    height: CatchWelcomeTokens.welcomeReelUnderlineThickness,
                    child: ColoredBox(color: pigment),
                  ),
              ],
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
        offset: Offset(0, (1 - progress) * CatchWelcomeTokens.welcomeRevealOffsetY),
        child: child,
      ),
    );
  }
}

double _welcomeTrackOffset({required double spinValue, required bool landed}) {
  final trackH = welcomePhraseBank.length * CatchWelcomeTokens.welcomeReelRowHeight;
  final base =
      CatchWelcomeTokens.welcomeReelLandingOffset(welcomeLandingIndex) % trackH;
  if (landed) return base;

  final eased = _welcomeSpinEase(spinValue, CatchMotion.welcomeSpinCurvePower);
  final endY = base + (CatchMotion.welcomeReelSpins * trackH);
  return (endY * eased) % trackH;
}

int welcomeFocusedPhraseIndex({
  required double spinValue,
  required bool landed,
}) {
  final offset = _welcomeTrackOffset(spinValue: spinValue, landed: landed);
  final centeredRow =
      ((offset +
                  CatchWelcomeTokens.welcomeReelFocus -
                  CatchWelcomeTokens.welcomeReelRowHalfHeight) /
              CatchWelcomeTokens.welcomeReelRowHeight)
          .round();
  return centeredRow % welcomePhraseBank.length;
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

const welcomeLandingIndex = 4;

String _authLocation(BuildContext context) {
  final from = _safeFrom(
    GoRouterState.of(
      context,
    ).uri.queryParameters[context.l10n.onboardingWelcomePageVisiblecopyFrom],
  );
  if (from == null) return context.l10n.onboardingWelcomePageVisiblecopyAuth;

  return Uri(
    path: context.l10n.onboardingWelcomePageVisiblecopyAuth,
    queryParameters: {'from': from},
  ).toString();
}

String? _safeFrom(String? from) {
  if (from == null || from.isEmpty || !from.startsWith('/')) return null;
  final uri = Uri.tryParse(from);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  return uri.toString();
}
