import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/gender_interest_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/name_dob_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/otp_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/phone_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/photos_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/running_prefs_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();

  static const _totalSteps = 7; // 0..6

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingControllerProvider.notifier).initStep();
      final step = ref.read(onboardingControllerProvider).step;
      if (step > 0) _pageController.jumpToPage(step);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(onboardingControllerProvider);
    final t = CatchTokens.of(context);

    // Animate page whenever step changes
    ref.listen(
      onboardingControllerProvider.select((d) => d.step),
      (prev, step) {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            step,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOut,
          );
        }
      },
    );

    // Minimum step the back button can reach (prevents going back past auth)
    final minStep = _minStep(data);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) {
        if (data.step > minStep) {
          ref
              .read(onboardingControllerProvider.notifier)
              .goToStep(data.step - 1);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (data.step > 0) ...[
                _ProgressBar(step: data.step, total: _totalSteps, tokens: t),
                const SizedBox(height: 8),
              ],
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    WelcomePage(),
                    PhonePage(),
                    OtpPage(),
                    NameDobPage(),
                    GenderInterestPage(),
                    PhotosPage(),
                    RunningPrefsPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _minStep(OnboardingData data) {
    // Once profile steps start (step 3+), prevent backing into OTP/phone steps.
    if (data.step >= 3) return 3;
    return 0;
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.step,
    required this.total,
    required this.tokens,
  });

  final int step;
  final int total;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          for (int i = 1; i < total; i++) ...[
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3,
                decoration: BoxDecoration(
                  color: i <= step ? tokens.primary : tokens.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (i < total - 1) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}
