import 'package:flutter/material.dart';

class OnboardingInstagramState {
  const OnboardingInstagramState({required this.handleText});

  factory OnboardingInstagramState.fromDraft({required String? handle}) {
    return OnboardingInstagramState(handleText: handle ?? '');
  }

  final String handleText;

  OnboardingInstagramSubmitIntent continueIntent({required String handle}) {
    final trimmed = handle.trim();
    return OnboardingInstagramSubmitIntent(
      instagramHandle: trimmed.isEmpty ? null : trimmed,
    );
  }

  OnboardingInstagramSubmitIntent get skipIntent {
    return const OnboardingInstagramSubmitIntent(instagramHandle: null);
  }
}

class OnboardingInstagramSubmitIntent {
  const OnboardingInstagramSubmitIntent({required this.instagramHandle});

  final String? instagramHandle;
}

class OnboardingInstagramTextControllers {
  const OnboardingInstagramTextControllers({required this.handle});

  final TextEditingController handle;
}

class OnboardingInstagramCallbacks {
  const OnboardingInstagramCallbacks({
    required this.onContinue,
    required this.onSkip,
  });

  final VoidCallback onContinue;
  final VoidCallback onSkip;
}
