import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_form_keys.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/running_prefs_page_state.dart';
import 'package:catch_dating_app/onboarding/shared/onboarding_step_layout.dart';
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
    required AppLocalizations l10n,
    String? completeErrorMessage,
  }) {
    return OnboardingRunningPrefsState.fromDraft(
      paceRange: _paceRange,
      distances: _distances,
      reasons: _reasons,
      runTimes: _runTimes,
      l10n: l10n,
      runPreferencesOnly: widget.runPreferencesOnly,
      isCompleting: isCompleting,
      completeErrorMessage: completeErrorMessage,
    );
  }

  void _submit() {
    if (ref.read(OnboardingController.completeMutation).isPending) return;
    final intent = _stateFor(
      isCompleting: false,
      l10n: context.l10n,
    ).submitIntent();
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
      l10n: context.l10n,
      completeErrorMessage: mutation.hasError
          ? mutationErrorMessage(mutation, l10n: context.l10n)
          : null,
    );

    return OnboardingRunningPrefsStep(
      state: state,
      callbacks: OnboardingRunningPrefsCallbacks(
        onPaceChanged: (next) {
          if (mutation.isPending) return;
          ref
              .read(onboardingControllerProvider.notifier)
              .clearCompleteErrorIfIdle();
          setState(() => _paceRange = next);
        },
        onDistancesChanged: (next) {
          if (mutation.isPending) return;
          ref
              .read(onboardingControllerProvider.notifier)
              .clearCompleteErrorIfIdle();
          setState(() {
            _distances
              ..clear()
              ..addAll(next);
          });
        },
        onReasonsChanged: (next) {
          if (mutation.isPending) return;
          ref
              .read(onboardingControllerProvider.notifier)
              .clearCompleteErrorIfIdle();
          setState(() {
            _reasons
              ..clear()
              ..addAll(next);
          });
        },
        onRunTimesChanged: (next) {
          if (mutation.isPending) return;
          ref
              .read(onboardingControllerProvider.notifier)
              .clearCompleteErrorIfIdle();
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
        CatchSectionList(
          emptyStateOmitted: true,
          gap: CatchSpacing.s4,
          children: [
            CatchSection.fieldRows(
              first: true,
              children: [
                // Composite exception: paired pace labels, range slider, and
                // boundary captions must remain one coordinated control.
                CatchField.control(
                  key: OnboardingFormKeys.runningPace,
                  title: context
                      .l10n
                      .onboardingRunningPrefsPageTextTypicalPacePerKm,
                  contract: CatchContractConstraints
                      .updateUserProfilePatchActivityPreferencesRunningPaceMinSecsPerKm,
                  body: context.l10n.onboardingRunningPrefsPageBodyPaceRange(
                    minPace: state.minPaceLabel,
                    maxPace: state.maxPaceLabel,
                  ),
                  icon: CatchIcons.directionsRunRounded,
                  initiallyOpen: true,
                  control: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              state.minPaceLabel,
                              style: CatchTextStyles.statDisplay(
                                context,
                                color: t.ink,
                              ),
                            ),
                          ),
                          Text(
                            '-',
                            style: CatchTextStyles.mono(context, color: t.ink3),
                          ),
                          Flexible(
                            child: Text(
                              state.maxPaceLabel,
                              style: CatchTextStyles.statDisplay(
                                context,
                                color: t.ink,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      gapH12,
                      CatchRangeSlider(
                        minimumContract: CatchContractConstraints
                            .updateUserProfilePatchActivityPreferencesRunningPaceMinSecsPerKm,
                        maximumContract: CatchContractConstraints
                            .updateUserProfilePatchActivityPreferencesRunningPaceMaxSecsPerKm,
                        values: state.paceRange,
                        min: 240,
                        max: 540,
                        divisions: 20,
                        onChanged: state.requestControlsEnabled
                            ? callbacks.onPaceChanged
                            : null,
                      ),
                      gapH4,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n.onboardingRunningPrefsPageText400Fast,
                            style: CatchTextStyles.badge(
                              context,
                              color: t.ink3,
                            ),
                          ),
                          Text(
                            context.l10n.onboardingRunningPrefsPageText900Easy,
                            style: CatchTextStyles.badge(
                              context,
                              color: t.ink3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                CatchField.choices<PreferredDistance>(
                  key: OnboardingFormKeys.runningDistances,
                  title: context
                      .l10n
                      .onboardingRunningPrefsPageLabelFavouriteDistances,
                  contract: CatchContractConstraints
                      .updateUserProfilePatchActivityPreferencesRunningPreferredDistances,
                  contractValue: (value) => value.name,
                  body: _orderedSelectionLabels(
                    PreferredDistance.values,
                    state.distances,
                    (value) => value.label,
                  ),
                  values: PreferredDistance.values,
                  itemLabel: (value) => value.label,
                  selected: state.distances,
                  onSelectionChanged: state.requestControlsEnabled
                      ? callbacks.onDistancesChanged
                      : null,
                  multi: true,
                  enabled: state.requestControlsEnabled,
                  initiallyOpen: true,
                  isOptional: true,
                ),
                CatchField.choices<RunReason>(
                  key: OnboardingFormKeys.runningReasons,
                  title: state.reasonLabel,
                  contract: CatchContractConstraints
                      .updateUserProfilePatchActivityPreferencesRunningRunningReasons,
                  contractValue: (value) => value.name,
                  body: _orderedSelectionLabels(
                    RunReason.values,
                    state.reasons,
                    (value) => value.label,
                  ),
                  values: RunReason.values,
                  itemLabel: (value) => value.label,
                  selected: state.reasons,
                  onSelectionChanged: state.requestControlsEnabled
                      ? callbacks.onReasonsChanged
                      : null,
                  multi: true,
                  enabled: state.requestControlsEnabled,
                  initiallyOpen: true,
                  isOptional: true,
                ),
                CatchField.choices<PreferredRunTime>(
                  key: OnboardingFormKeys.runningTimes,
                  title: state.runTimesLabel,
                  contract: CatchContractConstraints
                      .updateUserProfilePatchActivityPreferencesRunningPreferredRunTimes,
                  contractValue: (value) => value.name,
                  body: _orderedSelectionLabels(
                    PreferredRunTime.values,
                    state.runTimes,
                    (value) => value.label,
                  ),
                  values: PreferredRunTime.values,
                  itemLabel: (value) => value.label,
                  selected: state.runTimes,
                  onSelectionChanged: state.requestControlsEnabled
                      ? callbacks.onRunTimesChanged
                      : null,
                  multi: true,
                  enabled: state.requestControlsEnabled,
                  initiallyOpen: true,
                  isOptional: true,
                ),
              ],
            ),
            if (state.hasCompleteError)
              CatchSection.plain(
                child: CatchErrorBanner(message: state.completeErrorMessage!),
              ),
          ],
        ),
      ],
    );
  }
}

String? _orderedSelectionLabels<T>(
  Iterable<T> values,
  Set<T> selected,
  String Function(T value) labelFor,
) {
  final labels = values
      .where(selected.contains)
      .map(labelFor)
      .toList(growable: false);
  return labels.isEmpty ? null : labels.join(', ');
}
