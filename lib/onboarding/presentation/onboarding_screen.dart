import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(ref.read(onboardingControllerProvider.notifier).initStep());
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(onboardingControllerProvider);
    final t = CatchTokens.of(context);
    final minStep = data.step.minimumBackStep;
    final previousStep = data.step.previousWithin(minStep);
    final currentStep = KeyedSubtree(
      key: ValueKey(data.step),
      child: _buildStep(data.step),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) {
        if (previousStep != null) {
          ref
              .read(onboardingControllerProvider.notifier)
              .goToStep(previousStep);
        }
      },
      child: Scaffold(
        body: data.step == OnboardingStep.welcome
            ? currentStep
            : SafeArea(
                child: Column(
                  children: [
                    if (data.step.showsProgress) ...[
                      _OnboardingTopBar(
                        step: data.step,
                        tokens: t,
                        onBack: previousStep == null
                            ? null
                            : () => ref
                                  .read(onboardingControllerProvider.notifier)
                                  .goToStep(previousStep),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Expanded(child: currentStep),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStep(OnboardingStep step) {
    return switch (step) {
      OnboardingStep.welcome => const WelcomePage(),
      OnboardingStep.phone => const PhonePage(),
      OnboardingStep.otp => const OtpPage(),
      OnboardingStep.nameDob => const NameDobPage(),
      OnboardingStep.genderInterest => const GenderInterestPage(),
      OnboardingStep.photos => const PhotosPage(),
      OnboardingStep.runningPrefs => const RunningPrefsPage(),
    };
  }
}

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar({
    required this.step,
    required this.tokens,
    required this.onBack,
  });

  final OnboardingStep step;
  final CatchTokens tokens;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 8),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 44,
            child: onBack == null
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Back',
                    onPressed: onBack,
                    style: IconButton.styleFrom(
                      backgroundColor: tokens.surface,
                      foregroundColor: tokens.ink,
                    ),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ProgressBar(step: step, tokens: tokens),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.step, required this.tokens});

  final OnboardingStep step;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final total = OnboardingStep.values.length;

    return Row(
      children: [
        for (int i = 1; i < total; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              decoration: BoxDecoration(
                color: i <= step.index ? tokens.primary : tokens.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i < total - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }
}
