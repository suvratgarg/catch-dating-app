import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/auth/presentation/auth_error_message.dart';
import 'package:catch_dating_app/common_widgets/chip_field.dart';
import 'package:catch_dating_app/common_widgets/error_banner.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/widgets/onboarding_step_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
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

  String _formatPace(double secsPerKm) {
    final secs = secsPerKm.round();
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')}/km';
  }

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
    final appUser = ref.watch(appUserStreamProvider).asData?.value;
    final mutation = ref.watch(OnboardingController.completeMutation);
    final t = CatchTokens.of(context);

    if (!_didSeedFromProfile && appUser != null) {
      _didSeedFromProfile = true;
      _paceRange = RangeValues(
        appUser.paceMinSecsPerKm.toDouble(),
        appUser.paceMaxSecsPerKm.toDouble(),
      );
      _distances
        ..clear()
        ..addAll(appUser.preferredDistances);
      _reasons
        ..clear()
        ..addAll(appUser.runningReasons);
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
                _formatPace(_paceRange.start),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: t.ink),
              ),
              Text(
                _formatPace(_paceRange.end),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: t.ink),
              ),
            ],
          ),
          RangeSlider(
            values: _paceRange,
            min: 240, // 4:00/km
            max: 480, // 8:00/km
            divisions: 24,
            onChanged: (next) {
              OnboardingController.completeMutation.reset(ref);
              setState(() => _paceRange = next);
            },
          ),
          const SizedBox(height: 28),

          // ── Distances ─────────────────────────────────────────────────────
          ChipField<PreferredDistance>(
            label: 'Preferred distances',
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
              message: authErrorMessage((mutation as MutationError).error),
            ),
          ],
          const SizedBox(height: 40),
          FilledButton(
            onPressed: mutation.isPending ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: mutation.isPending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Start catching'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
