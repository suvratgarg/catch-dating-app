import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_flow_state.dart';
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
    final flowState = OnboardingFlowState.from(
      l10n: context.l10n,
      data: data,
      profileCompletionOnly: widget.profileCompletionOnly,
      runPreferencesOnly: widget.runPreferencesOnly,
    );
    final currentStep = KeyedSubtree(
      key: ValueKey(flowState.step),
      child: OnboardingStepContent(
        step: flowState.step,
        profileCompletionOnly: widget.profileCompletionOnly,
        runPreferencesOnly: widget.runPreferencesOnly,
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) {
        final previousStep = flowState.previousStep;
        if (previousStep != null) {
          ref
              .read(onboardingControllerProvider.notifier)
              .goToStep(previousStep);
        }
      },
      child: Scaffold(
        body: flowState.showsWelcome
            ? currentStep
            : SafeArea(
                child: Column(
                  children: [
                    if (flowState.topBar case final topBarState?) ...[
                      OnboardingTopBar(
                        state: topBarState,
                        onBack: flowState.previousStep == null
                            ? null
                            : () => ref
                                  .read(onboardingControllerProvider.notifier)
                                  .goToStep(flowState.previousStep!),
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
}

class OnboardingStepContent extends StatelessWidget {
  const OnboardingStepContent({
    super.key,
    required this.step,
    required this.profileCompletionOnly,
    required this.runPreferencesOnly,
  });

  final OnboardingStep step;
  final bool profileCompletionOnly;
  final bool runPreferencesOnly;

  @override
  Widget build(BuildContext context) {
    return switch (step) {
      OnboardingStep.welcome => const WelcomePage(),
      OnboardingStep.nameDob => const NameDobPage(),
      OnboardingStep.genderInterest => const GenderInterestPage(),
      OnboardingStep.instagram => const InstagramPage(),
      OnboardingStep.photos => PhotosPage(
        profileCompletionOnly: profileCompletionOnly,
      ),
      OnboardingStep.prompts => ProfilePromptsPage(
        profileCompletionOnly: profileCompletionOnly,
      ),
      OnboardingStep.runningPrefs => RunningPrefsPage(
        profileCompletionOnly: profileCompletionOnly,
        runPreferencesOnly: runPreferencesOnly,
      ),
    };
  }
}

class OnboardingTopBar extends StatelessWidget {
  const OnboardingTopBar({
    super.key,
    required this.state,
    required this.onBack,
  });

  final OnboardingTopBarState state;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return CatchStepHeader(
      title: state.title,
      subtitle: state.subtitle,
      step: state.stepNumber,
      total: state.stepTotal,
      onBack: state.canGoBack ? onBack : null,
    );
  }
}
