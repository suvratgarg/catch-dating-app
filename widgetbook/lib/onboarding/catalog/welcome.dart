import 'package:catch_dating_app/onboarding/presentation/pages/welcome_page.dart';
import 'package:catch_dating_app/onboarding/presentation/start_welcome_route_screen.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/phone_preview.dart';

@widgetbook.UseCase(
  name: 'Splash states',
  type: WelcomePage,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget welcomePageStates(BuildContext context) {
  return WidgetbookWrapCatalogFrame(
    title: 'WelcomePage',
    children: const [
      WidgetbookPhoneStateCard(
        label: 'animated reel',
        child: WidgetbookMaterialPhoneFrame(child: WelcomePage()),
      ),
      WidgetbookPhoneStateCard(
        label: 'landed',
        child: WidgetbookMaterialPhoneFrame(
          child: WelcomePage(playIntro: false),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'reduced motion',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookPhoneMediaOverride(
            disableAnimations: true,
            child: WelcomePage(),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'text scale 2',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookPhoneMediaOverride(
            textScale: 2,
            child: WelcomePage(playIntro: false),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Route surface',
  type: StartWelcomeRouteScreen,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget startWelcomeRouteScreen(BuildContext context) {
  return const WidgetbookMaterialPhoneFrame(
    child: StartWelcomeRouteScreen(playIntro: false),
  );
}
