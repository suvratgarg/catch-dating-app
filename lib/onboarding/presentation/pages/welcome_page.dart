import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Logo / brand mark
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [t.primary, t.accent],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                'C',
                style: CatchTextStyles.displayLg(
                  context,
                ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Catch.',
            style: CatchTextStyles.displayLg(
              context,
            ).copyWith(color: t.ink, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Meet people who run.',
            style: CatchTextStyles.bodyLg(context, color: t.ink2),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 3),
          FilledButton.icon(
            onPressed: () => ref
                .read(onboardingControllerProvider.notifier)
                .goToStep(OnboardingStep.phone),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            icon: const Icon(Icons.phone_outlined),
            label: const Text('Continue with phone'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
