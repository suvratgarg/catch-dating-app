import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip_field.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/running_prefs_page_state.dart';
import 'package:catch_dating_app/onboarding/shared/onboarding_step_layout.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const EdgeInsets _pacePreferenceCardPadding = EdgeInsets.fromLTRB(
  CatchSpacing.s4,
  CatchSpacing.s4,
  CatchSpacing.s4,
  CatchSpacing.s3,
);

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _seedFromProfile();
    });
  }

  void _seedFromProfile() {
    final userProfile = ref.read(watchUserProfileProvider).asData?.value;
    if (userProfile == null) return;
    setState(() {
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
    });
  }

  OnboardingRunningPrefsState _stateFor({
    required bool isCompleting,
    String? completeErrorMessage,
  }) {
    return OnboardingRunningPrefsState.fromDraft(
      paceRange: _paceRange,
      distances: _distances,
      reasons: _reasons,
      runTimes: _runTimes,
      runPreferencesOnly: widget.runPreferencesOnly,
      isCompleting: isCompleting,
      completeErrorMessage: completeErrorMessage,
    );
  }

  void _submit() {
    final intent = _stateFor(isCompleting: false).submitIntent();
    OnboardingController.completeMutation.run(ref, (tx) async {
      await tx
          .get(onboardingControllerProvider.notifier)
          .completeRunPreferences(
            paceMinSecsPerKm: intent.paceMinSecsPerKm,
            paceMaxSecsPerKm: intent.paceMaxSecsPerKm,
            preferredDistances: intent.preferredDistances,
            runningReasons: intent.runningReasons,
            preferredRunTimes: intent.preferredRunTimes,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(OnboardingController.completeMutation);
    final state = _stateFor(
      isCompleting: mutation.isPending,
      completeErrorMessage: mutation.hasError
          ? mutationErrorMessage(mutation, l10n: context.l10n)
          : null,
    );

    return OnboardingRunningPrefsStep(
      state: state,
      callbacks: OnboardingRunningPrefsCallbacks(
        onPaceChanged: (next) {
          OnboardingController.completeMutation.reset(ref);
          setState(() => _paceRange = next);
        },
        onDistancesChanged: (next) {
          OnboardingController.completeMutation.reset(ref);
          setState(() {
            _distances
              ..clear()
              ..addAll(next);
          });
        },
        onReasonsChanged: (next) {
          OnboardingController.completeMutation.reset(ref);
          setState(() {
            _reasons
              ..clear()
              ..addAll(next);
          });
        },
        onRunTimesChanged: (next) {
          OnboardingController.completeMutation.reset(ref);
          setState(() {
            _runTimes
              ..clear()
              ..addAll(next);
          });
        },
        onContinue: _submit,
      ),
    );
  }
}

class OnboardingRunningPrefsStep extends StatelessWidget {
  const OnboardingRunningPrefsStep({
    super.key,
    required this.state,
    required this.callbacks,
  });

  final OnboardingRunningPrefsState state;
  final OnboardingRunningPrefsCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return OnboardingStepLayout(
      footer: CatchButton(
        label: state.footerLabel,
        onPressed: state.canSubmit ? callbacks.onContinue : null,
        isLoading: state.isCompleting,
        icon: Icon(CatchIcons.checkRounded),
        fullWidth: true,
        size: CatchButtonSize.lg,
      ),
      children: [
        // ── Pace ──────────────────────────────────────────────────────────
        Text(
          context.l10n.onboardingRunningPrefsPageTextTypicalPacePerKm,
          style: CatchTextStyles.monoLabel(context, color: t.ink2),
        ),
        gapH8,
        CatchSurface(
          radius: CatchRadius.md,
          borderColor: t.line,
          backgroundColor: t.surface,
          padding: _pacePreferenceCardPadding,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      state.minPaceLabel,
                      style: CatchTextStyles.statDisplay(context, color: t.ink),
                    ),
                  ),
                  Text(
                    '-',
                    style: CatchTextStyles.mono(context, color: t.ink3),
                  ),
                  Flexible(
                    child: Text(
                      state.maxPaceLabel,
                      style: CatchTextStyles.statDisplay(context, color: t.ink),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              gapH12,
              CatchRangeSlider(
                values: state.paceRange,
                min: 240, // 4:00/km
                max: 540, // 9:00/km
                divisions: 20,
                onChanged: callbacks.onPaceChanged,
              ),
              gapH4,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.onboardingRunningPrefsPageText400Fast,
                    style: CatchTextStyles.badge(context, color: t.ink3),
                  ),
                  Text(
                    context.l10n.onboardingRunningPrefsPageText900Easy,
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
          label: context.l10n.onboardingRunningPrefsPageLabelFavouriteDistances,
          isOptional: true,
          values: PreferredDistance.values,
          selected: state.distances,
          multiSelect: true,
          onChanged: callbacks.onDistancesChanged,
        ),
        gapH20,

        // ── Event reasons ───────────────────────────────────────────────────
        CatchChipField<RunReason>(
          label: state.reasonLabel,
          isOptional: true,
          values: RunReason.values,
          selected: state.reasons,
          multiSelect: true,
          onChanged: callbacks.onReasonsChanged,
        ),
        gapH20,

        // ── Time of day ───────────────────────────────────────────────────
        CatchChipField<PreferredRunTime>(
          label: state.runTimesLabel,
          isOptional: true,
          values: PreferredRunTime.values,
          selected: state.runTimes,
          multiSelect: true,
          onChanged: callbacks.onRunTimesChanged,
        ),

        if (state.hasCompleteError) ...[
          gapH16,
          CatchErrorBanner(message: state.completeErrorMessage!),
        ],
      ],
    );
  }
}
