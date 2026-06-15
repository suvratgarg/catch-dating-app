import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
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
  const RunningPrefsPage({
    super.key,
    this.profileCompletionOnly = false,
    this.runPreferencesOnly = false,
  });

  final bool profileCompletionOnly;
  final bool runPreferencesOnly;

  @override
  ConsumerState<RunningPrefsPage> createState() => _RunningPrefsPageState();
}

class _RunningPrefsPageState extends ConsumerState<RunningPrefsPage> {
  RangeValues _paceRange = const RangeValues(300, 420); // secs/km
  final Set<PreferredDistance> _distances = {};
  final Set<RunReason> _reasons = {};
  final Set<PreferredRunTime> _runTimes = {};
  bool _didSeedFromProfile = false;

  void _submit() {
    OnboardingController.completeMutation.run(ref, (tx) async {
      await tx
          .get(onboardingControllerProvider.notifier)
          .completeRunPreferences(
            paceMinSecsPerKm: _paceRange.start.round(),
            paceMaxSecsPerKm: _paceRange.end.round(),
            preferredDistances: _distances.toList(),
            runningReasons: _reasons.toList(),
            preferredRunTimes: _runTimes.toList(),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(watchUserProfileProvider).asData?.value;
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
      _runTimes
        ..clear()
        ..addAll(userProfile.preferredRunTimes);
    }

    return OnboardingStepFrame(
      footer: CatchButton(
        label: widget.runPreferencesOnly
            ? 'Continue booking'
            : 'Save run preferences',
        onPressed: _submit,
        isLoading: mutation.isPending,
        icon: Icon(CatchIcons.checkRounded),
        fullWidth: true,
        size: CatchButtonSize.lg,
      ),
      children: [
        OnboardingStepHeader(
          title: widget.profileCompletionOnly
              ? 'Finish your Catches profile'
              : widget.runPreferencesOnly
              ? 'Set your run preferences'
              : 'Your running style',
          subtitle: widget.profileCompletionOnly
              ? 'These are optional, but they help us rank compatible people in Catches.'
              : widget.runPreferencesOnly
              ? 'We only ask for these before run events so hosts can plan pace groups and distances.'
              : 'Help us find compatible running partners.',
        ),
        gapH20,

        // ── Pace ──────────────────────────────────────────────────────────
        Text(
          'TYPICAL PACE · PER KM',
          style: CatchTextStyles.monoLabel(context, color: t.ink2),
        ),
        gapH8,
        CatchSurface(
          radius: CatchRadius.md,
          borderColor: t.line,
          backgroundColor: t.surface,
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s4,
            CatchSpacing.s4,
            CatchSpacing.s4,
            CatchSpacing.s3,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${formatPace(_paceRange.start)}/km',
                      style: CatchTextStyles.statDisplay(context, color: t.ink),
                    ),
                  ),
                  Text(
                    '-',
                    style: CatchTextStyles.mono(context, color: t.ink3),
                  ),
                  Flexible(
                    child: Text(
                      '${formatPace(_paceRange.end)}/km',
                      style: CatchTextStyles.statDisplay(context, color: t.ink),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              gapH12,
              CatchRangeSlider(
                values: _paceRange,
                min: 240, // 4:00/km
                max: 540, // 9:00/km
                divisions: 20,
                onChanged: (next) {
                  OnboardingController.completeMutation.reset(ref);
                  setState(() => _paceRange = next);
                },
              ),
              gapH4,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '4:00 FAST',
                    style: CatchTextStyles.badge(context, color: t.ink3),
                  ),
                  Text(
                    '9:00 EASY',
                    style: CatchTextStyles.badge(context, color: t.ink3),
                  ),
                ],
              ),
            ],
          ),
        ),
        gapH20,

        // ── Distances ─────────────────────────────────────────────────────
        CatchChipField<PreferredDistance>(
          label: 'FAVOURITE DISTANCES',
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
        gapH20,

        // ── Event reasons ───────────────────────────────────────────────────
        CatchChipField<RunReason>(
          label: widget.runPreferencesOnly
              ? 'Why do you run?'
              : 'WHY DO YOU RUN?',
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
        gapH20,

        // ── Time of day ───────────────────────────────────────────────────
        CatchChipField<PreferredRunTime>(
          label: widget.runPreferencesOnly
              ? 'FAVOURITE RUN TIMES'
              : 'FAVOURITE EVENT TIMES',
          isOptional: true,
          values: PreferredRunTime.values,
          selected: _runTimes,
          multiSelect: true,
          onChanged: (next) {
            OnboardingController.completeMutation.reset(ref);
            setState(() {
              _runTimes
                ..clear()
                ..addAll(next);
            });
          },
        ),

        if (mutation.hasError) ...[
          gapH16,
          CatchErrorBanner(message: mutationErrorMessage(mutation)),
        ],
      ],
    );
  }
}
