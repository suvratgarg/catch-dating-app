import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/swipes/presentation/filters_controller.dart';
import 'package:catch_dating_app/swipes/presentation/filters_screen_state.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

export 'package:catch_dating_app/swipes/presentation/filters_screen_state.dart';

class FiltersScreen extends ConsumerStatefulWidget {
  const FiltersScreen({super.key});

  @override
  ConsumerState<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends ConsumerState<FiltersScreen> {
  RangeValues? _draftAgeRange;
  Set<Gender>? _draftInterestedIn;
  bool _didResetMutation = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didResetMutation) return;
    _didResetMutation = true;
    FiltersController.saveFiltersMutation.reset(ref);
  }

  FiltersPreferencesState? _stateFor({
    required UserProfile? user,
    required bool saving,
  }) {
    if (user == null) return null;
    final state = FiltersPreferencesState.fromProfile(
      user: user,
      draftAgeRange: _draftAgeRange,
      draftInterestedIn: _draftInterestedIn,
      saving: saving,
    );
    _draftAgeRange ??= state.content.ageRange;
    _draftInterestedIn ??= state.content.interestedIn;
    return state;
  }

  Future<void> _save(FiltersPreferencesState state) async {
    final request = state.saveRequest;
    try {
      await FiltersController.saveFiltersMutation.run(ref, (tx) async {
        await tx
            .get(filtersControllerProvider.notifier)
            .saveFilters(
              uid: request.uid,
              minAgePreference: request.minAgePreference,
              maxAgePreference: request.maxAgePreference,
              interestedInGenders: request.interestedInGenderNames,
            );
      });
    } catch (_) {
      // CatchMutationErrorListener owns user-facing error display.
    }
  }

  void _reset(FiltersPreferencesState state) {
    setState(() {
      _draftAgeRange = state.savedAgeRange;
      _draftInterestedIn = state.savedInterestedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(watchUserProfileProvider);
    final saveMutation = ref.watch(FiltersController.saveFiltersMutation);
    final saving = saveMutation.isPending;
    final preferencesState = _stateFor(
      user: profileAsync.asData?.value,
      saving: saving,
    );
    VoidCallback? onReset;
    final resetState = preferencesState;
    if (resetState != null && resetState.resetEnabled) {
      onReset = () => _reset(resetState);
    }
    final t = CatchTokens.of(context);

    ref.listen(FiltersController.saveFiltersMutation, (prev, next) {
      if (prev?.isPending == true && next.isSuccess) {
        context.pop();
      }
    });

    return CatchMutationErrorListener(
      mutation: FiltersController.saveFiltersMutation,
      child: Scaffold(
        backgroundColor: t.bg,
        appBar: CatchTopBar(
          title: 'Filters',
          leading: CatchTopBarIconAction(
            icon: CatchIcons.closeRounded,
            tooltip: 'Close filters',
            onPressed: () => context.pop(),
          ),
          actions: [
            CatchTopBarTextAction(
              key: SwipeKeys.resetFiltersButton,
              label: 'Reset',
              onPressed: onReset,
            ),
          ],
        ),
        body: profileAsync.when(
          loading: () => const FiltersContentSkeleton(),
          error: (error, _) => CatchErrorState.fromError(
            error,
            context: AppErrorContext.profile,
            onRetry: () => ref.invalidate(watchUserProfileProvider),
          ),
          data: (user) {
            if (user == null) return const SizedBox.shrink();
            final state =
                _stateFor(user: user, saving: saving) ?? preferencesState!;

            return FiltersContent.fromState(
              state: state.content,
              onAgeRangeChanged: (values) =>
                  setState(() => _draftAgeRange = values),
              onGenderToggled: (gender) => setState(() {
                final next = {...state.content.interestedIn};
                if (!next.add(gender)) next.remove(gender);
                _draftInterestedIn = next;
              }),
              onApply: state.applyEnabled ? () => _save(state) : null,
            );
          },
        ),
      ),
    );
  }
}

class FiltersContent extends StatelessWidget {
  const FiltersContent({
    super.key,
    required this.ageRange,
    required this.interestedIn,
    required this.saving,
    required this.onAgeRangeChanged,
    required this.onGenderToggled,
    required this.onApply,
  });

  FiltersContent.fromState({
    super.key,
    required FiltersContentState state,
    required this.onAgeRangeChanged,
    required this.onGenderToggled,
    required this.onApply,
  }) : ageRange = state.ageRange,
       interestedIn = state.interestedIn,
       saving = state.saving;

  final RangeValues ageRange;
  final Set<Gender> interestedIn;
  final bool saving;
  final ValueChanged<RangeValues> onAgeRangeChanged;
  final ValueChanged<Gender> onGenderToggled;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s5,
              CatchSpacing.s2,
              CatchSpacing.s5,
              CatchSpacing.s5,
            ),
            children: [
              FiltersSection(
                title: 'Age',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FiltersValue(
                      value:
                          '${ageRange.start.round()} – ${formatPreferredMatchAge(ageRange.end.round())}',
                    ),
                    CatchRangeSlider(
                      key: SwipeKeys.ageRangeSlider,
                      min: minimumProfileAge.toDouble(),
                      max: preferredMatchAgeOpenEndedDisplayAge.toDouble(),
                      divisions:
                          preferredMatchAgeOpenEndedDisplayAge -
                          minimumProfileAge,
                      values: ageRange,
                      onChanged: onAgeRangeChanged,
                    ),
                  ],
                ),
              ),
              FiltersSection(
                title: 'Interested in',
                child: Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  children: [
                    for (final gender in Gender.values)
                      CatchSelectChip(
                        key: SwipeKeys.genderFilterChip(gender.name),
                        label: gender.label,
                        active: interestedIn.contains(gender),
                        onTap: () => onGenderToggled(gender),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        CatchBottomDock(
          includeSafeArea: false,
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            CatchSpacing.s3,
            CatchSpacing.s5,
            CatchSpacing.s5,
          ),
          child: CatchButton(
            key: SwipeKeys.applyFiltersButton,
            label: 'Apply filters',
            onPressed: saving ? null : onApply,
            isLoading: saving,
            fullWidth: true,
          ),
        ),
      ],
    );
  }
}

class FiltersContentSkeleton extends StatelessWidget {
  const FiltersContentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s5,
              CatchSpacing.s2,
              CatchSpacing.s5,
              CatchSpacing.s5,
            ),
            children: const [
              FiltersSection(title: 'Age', child: AgeFilterSkeleton()),
              FiltersSection(
                title: 'Interested in',
                child: GenderFilterSkeleton(),
              ),
            ],
          ),
        ),
        CatchBottomDock(
          includeSafeArea: false,
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            CatchSpacing.s3,
            CatchSpacing.s5,
            CatchSpacing.s5,
          ),
          child: CatchSkeleton.box(
            width: double.infinity,
            height: CatchLayout.buttonLgHeight,
            radius: CatchRadius.pill,
          ),
        ),
      ],
    );
  }
}

class AgeFilterSkeleton extends StatelessWidget {
  const AgeFilterSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
        gapH16,
        Stack(
          alignment: Alignment.center,
          children: [
            CatchSkeleton.box(
              width: double.infinity,
              height: CatchStroke.selection,
              radius: CatchRadius.pill,
            ),
            Row(
              children: [
                CatchSkeleton.circle(size: CatchSpacing.s6),
                const Spacer(),
                CatchSkeleton.circle(size: CatchSpacing.s6),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class GenderFilterSkeleton extends StatelessWidget {
  const GenderFilterSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        CatchSkeleton.box(
          width: CatchSpacing.s16 + CatchSpacing.s7,
          height: CatchSpacing.s9,
          radius: CatchRadius.pill,
        ),
        CatchSkeleton.box(
          width: CatchSpacing.s16 + CatchSpacing.s10,
          height: CatchSpacing.s9,
          radius: CatchRadius.pill,
        ),
        CatchSkeleton.box(
          width: CatchSpacing.s16 + CatchSpacing.s4,
          height: CatchSpacing.s9,
          radius: CatchRadius.pill,
        ),
      ],
    );
  }
}

class FiltersSection extends StatelessWidget {
  const FiltersSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: CatchInsets.tileVerticalCompact,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: CatchTextStyles.kicker(context, color: t.ink3),
          ),
          gapH10,
          child,
        ],
      ),
    );
  }
}

class FiltersValue extends StatelessWidget {
  const FiltersValue({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(value, style: CatchTextStyles.titleL(context));
  }
}
