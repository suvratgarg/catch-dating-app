import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_step_progress.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/gender_interest_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/instagram_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/name_dob_page.dart';
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
                        onBack: previousStep == null
                            ? null
                            : () => ref
                                  .read(onboardingControllerProvider.notifier)
                                  .goToStep(previousStep),
                      ),
                      const SizedBox(height: 16),
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
      OnboardingStep.nameDob => const NameDobPage(),
      OnboardingStep.genderInterest => const GenderInterestPage(),
      OnboardingStep.instagram => const InstagramPage(),
      OnboardingStep.photos => const PhotosPage(),
      OnboardingStep.runningPrefs => const RunningPrefsPage(),
    };
  }
}

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar({required this.step, required this.onBack});

  final OnboardingStep step;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final progressStep = step.index - 1;
    final progressTotal = OnboardingStep.values.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox.square(
                dimension: 40,
                child: onBack == null
                    ? const SizedBox.shrink()
                    : IconBtn(
                        onTap: onBack,
                        child: Tooltip(
                          message: 'Back',
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: t.ink,
                          ),
                        ),
                      ),
              ),
              Expanded(
                child: Text(
                  step.appBarTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: CatchTextStyles.titleM(context, color: t.ink),
                ),
              ),
              const SizedBox.square(dimension: 40),
            ],
          ),
          const SizedBox(height: 16),
          CatchStepProgress(
            currentStep: progressStep,
            totalSteps: progressTotal,
          ),
        ],
      ),
    );
  }
}
