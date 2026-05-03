import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/chip_field.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/widgets/onboarding_step_header.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunningPrefsPage extends ConsumerStatefulWidget {
  const RunningPrefsPage({super.key});

  @override
  ConsumerState<RunningPrefsPage> createState() => _RunningPrefsPageState();
}

class _RunningPrefsPageState extends ConsumerState<RunningPrefsPage> {
  RangeValues _paceRange = const RangeValues(300, 420); // secs/km
  final Set<PreferredDistance> _distances = {};
  final Set<RunReason> _reasons = {};
  bool _didSeedFromProfile = false;

  void _submit() {
    OnboardingController.completeMutation.run(ref, (tx) async {
      await tx
          .get(onboardingControllerProvider.notifier)
          .complete(
            paceMinSecsPerKm: _paceRange.start.round(),
            paceMaxSecsPerKm: _paceRange.end.round(),
            preferredDistances: _distances.toList(),
            runningReasons: _reasons.toList(),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileStreamProvider).asData?.value;
    final mutation = ref.watch(OnboardingController.completeMutation);
    final t = CatchTokens.of(context);

    if (!_didSeedFromProfile && userProfile != null) {
      _didSeedFromProfile = true;
      _paceRange = RangeValues(
        userProfile.paceMinSecsPerKm.toDouble(),
        userProfile.paceMaxSecsPerKm.toDouble(),
      );
      _distances
        ..clear()
        ..addAll(userProfile.preferredDistances);
      _reasons
        ..clear()
        ..addAll(userProfile.runningReasons);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          const OnboardingStepHeader(
            title: 'Your running style',
            subtitle: 'Help us find compatible running partners.',
          ),
          const SizedBox(height: 32),

          // ── Pace ──────────────────────────────────────────────────────────
          Text(
            'Comfortable pace',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: t.ink2),
          ),
          gapH8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${formatPace(_paceRange.start)}/km',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: t.ink),
              ),
              Text(
                '${formatPace(_paceRange.end)}/km',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: t.ink),
              ),
            ],
          ),
          RangeSlider(
            values: _paceRange,
            min: 240, // 4:00/km
            max: 540, // 9:00/km
            divisions: 20,
            onChanged: (next) {
              OnboardingController.completeMutation.reset(ref);
              setState(() => _paceRange = next);
            },
          ),
          const SizedBox(height: 28),

          // ── Distances ─────────────────────────────────────────────────────
          ChipField<PreferredDistance>(
            label: 'Preferred distances',
            isOptional: true,
            values: PreferredDistance.values,
            selected: _distances,
            multiSelect: true,
            onChanged: (next) {
              OnboardingController.completeMutation.reset(ref);
              setState(() {
                _distances
                  ..clear()
                  ..addAll(next);
              });
            },
          ),
          const SizedBox(height: 28),

          // ── Run reasons ───────────────────────────────────────────────────
          ChipField<RunReason>(
            label: 'Why do you run?',
            isOptional: true,
            values: RunReason.values,
            selected: _reasons,
            multiSelect: true,
            onChanged: (next) {
              OnboardingController.completeMutation.reset(ref);
              setState(() {
                _reasons
                  ..clear()
                  ..addAll(next);
              });
            },
          ),

          if (mutation.hasError) ...[
            gapH16,
            ErrorBanner(
              message: mutationErrorMessage(mutation),
            ),
          ],
          const SizedBox(height: 40),
          CatchButton(
            label: 'Start catching',
            onPressed: _submit,
            isLoading: mutation.isPending,
            fullWidth: true,
            size: CatchButtonSize.lg,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
