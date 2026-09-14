import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/welcome_page.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/contract_preview.dart';
import '../../support/phone_preview.dart';

@widgetbook.UseCase(
  name: 'Welcome scene states',
  type: WelcomeScene,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget welcomeSceneStates(BuildContext context) {
  return const WidgetbookWrapCatalogFrame(
    title: 'WelcomeScene',
    children: [
      WidgetbookPhoneStateCard(
        label: 'spinning',
        child: WidgetbookMaterialPhoneFrame(
          child: WelcomeScene(
            viewportWidth: 320,
            viewportHeight: 760,
            mediaPadding: EdgeInsets.only(
              top: WidgetbookPreviewLayout.onboardingWelcomeMediaTop,
              bottom: WidgetbookPreviewLayout.onboardingWelcomeMediaBottom,
            ),
            spinValue: 0.42,
            landingValue: 0,
            landed: false,
            onContinue: widgetbookNoop,
            onExplore: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'landed',
        child: WidgetbookMaterialPhoneFrame(
          child: WelcomeScene(
            viewportWidth: 320,
            viewportHeight: 760,
            mediaPadding: EdgeInsets.only(
              top: WidgetbookPreviewLayout.onboardingWelcomeMediaTop,
              bottom: WidgetbookPreviewLayout.onboardingWelcomeMediaBottom,
            ),
            spinValue: 1,
            landingValue: 1,
            landed: true,
            onContinue: widgetbookNoop,
            onExplore: widgetbookNoop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Welcome focus lockup states',
  type: WelcomeFocusLockup,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget welcomeFocusLockupStates(BuildContext context) {
  final socialRun =
      ActivityPalette.pigments[ActivityKind.socialRun] ??
      ActivityPalette.pigments[ActivityKind.openActivity]!;
  const maxWidth = WidgetbookPreviewLayout.onboardingWelcomeFocusWidth;

  return WidgetbookWrapCatalogFrame(
    title: 'WelcomeFocusLockup',
    children: [
      WidgetbookPhoneStateCard(
        label: 'static Catch_ handoff',
        child: ColoredBox(
          color: CatchTokens.light.bg,
          child: Padding(
            padding: const EdgeInsets.all(CatchSpacing.s4),
            child: WelcomeFocusLockup(
              catchColor: CatchTokens.light.ink,
              maxWidth: maxWidth,
              showBrandUnderscore: true,
            ),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'fixed the sunset 5K focus',
        child: ColoredBox(
          color: CatchTokens.editorialDark.bg,
          child: Padding(
            padding: const EdgeInsets.all(CatchSpacing.s4),
            child: WelcomeFocusLockup(
              phrase: 'the sunset 5K',
              catchColor: CatchTokens.editorialDark.ink,
              maxWidth: maxWidth,
              phraseColor: socialRun,
              underlineColor: socialRun,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Welcome reel band states',
  type: ReelBand,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget welcomeReelBandStates(BuildContext context) {
  return WidgetbookWrapCatalogFrame(
    title: 'ReelBand',
    children: [
      WidgetbookPhoneStateCard(
        label: 'spinning band',
        child: ColoredBox(
          color: CatchTokens.editorialDark.bg,
          child: const SizedBox(
            height: WidgetbookPreviewLayout.profileSectionPreviewHeight,
            child: ReelBand(
              viewportWidth: 320,
              spinValue: 0.5,
              landingValue: 0,
              landed: false,
            ),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'landed focus',
        child: ColoredBox(
          color: CatchTokens.editorialDark.bg,
          child: const SizedBox(
            height: WidgetbookPreviewLayout.profileSectionPreviewHeight,
            child: ReelBand(
              viewportWidth: 320,
              spinValue: 1,
              landingValue: 1,
              landed: true,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Welcome reel row states',
  type: ReelRow,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget welcomeReelRowStates(BuildContext context) {
  return WidgetbookWrapCatalogFrame(
    title: 'ReelRow',
    children: [
      WidgetbookPhoneStateCard(
        label: 'activity phrase',
        child: ColoredBox(
          color: CatchTokens.editorialDark.bg,
          child: const SizedBox(
            height: WidgetbookPreviewLayout.onboardingReelRowPreviewHeight,
            child: ReelRow(
              viewportWidth: 320,
              phrase: WelcomePhrase('the long table', ActivityKind.dinner),
              phraseIndex: 2,
              rowIndex: 2,
              trackOffset: 0,
              landingValue: 0,
              landed: false,
            ),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'landing phrase',
        child: ColoredBox(
          color: CatchTokens.editorialDark.bg,
          child: const SizedBox(
            height: WidgetbookPreviewLayout.onboardingReelRowPreviewHeight,
            child: ReelRow(
              viewportWidth: 320,
              phrase: WelcomePhrase('the sunset 5K', ActivityKind.socialRun),
              phraseIndex: welcomeLandingIndex,
              rowIndex: 2,
              trackOffset: 0,
              landingValue: 1,
              landed: true,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Welcome reveal states',
  type: RevealEntrance,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget welcomeRevealEntranceStates(BuildContext context) {
  return WidgetbookWrapCatalogFrame(
    title: 'RevealEntrance',
    children: [
      WidgetbookPhoneStateCard(
        label: 'settling',
        child: ColoredBox(
          color: CatchTokens.editorialDark.bg,
          child: Padding(
            padding: const EdgeInsets.all(CatchSpacing.s6),
            child: RevealEntrance(
              landingValue: 0.62,
              order: 0,
              child: Text(
                'Show up to something you would do anyway.',
                style: CatchTextStyles.proseM(
                  context,
                  color: CatchTokens.editorialWhite,
                ),
              ),
            ),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'visible',
        child: ColoredBox(
          color: CatchTokens.editorialDark.bg,
          child: Padding(
            padding: const EdgeInsets.all(CatchSpacing.s6),
            child: RevealEntrance(
              landingValue: 1,
              order: 1,
              child: Text(
                'Continue with phone',
                style: CatchTextStyles.labelL(
                  context,
                  color: CatchTokens.editorialWhite,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
