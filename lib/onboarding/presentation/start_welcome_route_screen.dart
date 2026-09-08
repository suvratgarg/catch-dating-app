import 'package:catch_dating_app/onboarding/presentation/pages/welcome_page.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Route-level surface owner for the logged-out Welcome experience.
///
/// [WelcomePage] stays embeddable by onboarding and bootstrap compositions;
/// this adapter deterministically owns the standalone `/start` viewport.
class StartWelcomeRouteScreen extends StatelessWidget {
  const StartWelcomeRouteScreen({super.key, this.playIntro = true});

  final bool playIntro;

  @override
  Widget build(BuildContext context) {
    return CatchScreenScaffold.standalone(
      safeArea: CatchScreenSafeArea.none,
      body: WelcomePage(playIntro: playIntro),
    );
  }
}
