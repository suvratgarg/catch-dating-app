import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/gender_interest_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/instagram_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/name_dob_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/photos_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/profile_prompts_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/running_prefs_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    super.key,
    this.profileCompletionOnly = false,
    this.runPreferencesOnly = false,
  });

  final bool profileCompletionOnly;
  final bool runPreferencesOnly;

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
      unawaited(
        ref
            .read(onboardingControllerProvider.notifier)
            .initStep(
              profileCompletionOnly: widget.profileCompletionOnly,
              runPreferencesOnly: widget.runPreferencesOnly,
            ),
      );
    });
  }

  @override
  void didUpdateWidget(covariant OnboardingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileCompletionOnly == widget.profileCompletionOnly &&
        oldWidget.runPreferencesOnly == widget.runPreferencesOnly) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(
        ref
            .read(onboardingControllerProvider.notifier)
            .initStep(
              profileCompletionOnly: widget.profileCompletionOnly,
              runPreferencesOnly: widget.runPreferencesOnly,
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(onboardingControllerProvider);
    final minStep = widget.runPreferencesOnly
        ? OnboardingStep.runningPrefs
        : widget.profileCompletionOnly &&
              data.step.index >= OnboardingStep.photos.index
        ? OnboardingStep.photos
        : data.step.minimumBackStep;
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
                        profileCompletionOnly: widget.profileCompletionOnly,
                        runPreferencesOnly: widget.runPreferencesOnly,
                        onBack: previousStep == null
                            ? null
                            : () => ref
                                  .read(onboardingControllerProvider.notifier)
                                  .goToStep(previousStep),
                      ),
                      gapH8,
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
      OnboardingStep.photos => PhotosPage(
        profileCompletionOnly: widget.profileCompletionOnly,
      ),
      OnboardingStep.prompts => ProfilePromptsPage(
        profileCompletionOnly: widget.profileCompletionOnly,
      ),
      OnboardingStep.runningPrefs => RunningPrefsPage(
        profileCompletionOnly: widget.profileCompletionOnly,
        runPreferencesOnly: widget.runPreferencesOnly,
      ),
    };
  }
}

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar({
    required this.step,
    required this.profileCompletionOnly,
    required this.runPreferencesOnly,
    required this.onBack,
  });

  final OnboardingStep step;
  final bool profileCompletionOnly;
  final bool runPreferencesOnly;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final socialOnly =
        profileCompletionOnly && step.index >= OnboardingStep.photos.index;
    final progressStep = runPreferencesOnly
        ? 0
        : socialOnly
        ? step.index - OnboardingStep.photos.index
        : step == OnboardingStep.genderInterest
        ? 1
        : 0;
    final progressTotal = runPreferencesOnly ? 1 : 2;
    final copy = step.headerCopy(
      profileCompletionOnly: profileCompletionOnly,
      runPreferencesOnly: runPreferencesOnly,
    );

    return CatchStepFlowHeader(
      title: copy.title,
      subtitle: copy.subtitle,
      currentStep: progressStep,
      totalSteps: progressTotal,
      onBack: onBack,
    );
  }
}
