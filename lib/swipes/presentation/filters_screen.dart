import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_error_snack_bar.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/swipes/presentation/filters_controller.dart';
import 'package:catch_dating_app/swipes/presentation/filters_screen_state.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FiltersController.saveFiltersMutation.reset(ref);
    });
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
      // listenToCatchMutationErrors owns user-facing error display.
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

    listenToCatchMutationErrors(
      context,
      ref,
      mutations: [FiltersController.saveFiltersMutation],
    );
    return PopScope(
      canPop: !saving,
      child: CatchRouteScaffold(
        backgroundColor: t.bg,
        topBarBuilder: (context, scrolledUnder) => CatchTopBar(
          title: context.l10n.swipesFiltersScreenTitleFilters,
          emphasis: scrolledUnder
              ? CatchTopBarEmphasis.divided
              : CatchTopBarEmphasis.plain,
          leading: CatchIconAction.toolbar(
            icon: CatchIcons.closeRounded,
            tooltip: context.l10n.swipesFiltersScreenTooltipCloseFilters,
            onPressed: saving ? null : () => context.pop(),
          ),
          actions: [
            CatchButton.text(
              key: SwipeKeys.resetFiltersButton,
              label: context.l10n.swipesFiltersScreenLabelReset,
              onPressed: onReset,
            ),
          ],
        ),
        bottomNavigationBar: profileAsync.isLoading
            ? CatchDockSurface(
                includeSafeArea: false,
                padding: CatchInsets.formActionDock,
                child: CatchSkeleton.box(
                  width: double.infinity,
                  height: CatchLayout.buttonLgHeight,
                  radius: CatchRadius.pill,
                ),
              )
            : preferencesState == null
            ? null
            : CatchDockSurface(
                includeSafeArea: false,
                padding: CatchInsets.formActionDock,
                child: CatchButton(
                  key: SwipeKeys.applyFiltersButton,
                  label: context.l10n.swipesFiltersScreenLabelApplyFilters,
                  onPressed: preferencesState.applyEnabled
                      ? () => _save(preferencesState)
                      : null,
                  status: (saving)
                      ? CatchButtonStatus.loading
                      : CatchButtonStatus.idle,
                  fullWidth: true,
                ),
              ),
        body: CatchRouteBody.standard(
          child: profileAsync.when(
            loading: () => const FiltersContentSkeleton._route(),
            error: (error, _) => CatchLocalizedErrorState(
              error,
              context: AppErrorContext.profile,
              onRetry: () => ref.invalidate(watchUserProfileProvider),
            ),
            data: (user) {
              if (user == null) {
                return CatchStateViewport(
                  accountForBottomOverlay: false,
                  child: CatchEmptyState(
                    icon: CatchIcons.personOffOutlined,
                    title: context
                        .l10n
                        .userProfileProfileScreenTitleProfileNotAvailable,
                    message: context
                        .l10n
                        .userProfileProfileScreenMessageFinishOnboardingOrSign,
                    actions: [
                      CatchButton(
                        label: context.l10n.sharedActionTryAgain,
                        onPressed: () =>
                            ref.invalidate(watchUserProfileProvider),
                        leading: Icon(CatchIcons.refreshRounded),
                      ),
                    ],
                  ),
                );
              }
              final state = preferencesState!;
              return FiltersContent._routeFromState(
                state: state.content,
                onAgeRangeChanged: (values) =>
                    setState(() => _draftAgeRange = values),
                onGenderToggled: (gender) => setState(() {
                  final next = {...state.content.interestedIn};
                  if (!next.add(gender)) next.remove(gender);
                  _draftInterestedIn = next;
                }),
              );
            },
          ),
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
  }) : _routeOwned = false;

  FiltersContent.fromState({
    super.key,
    required FiltersContentState state,
    required this.onAgeRangeChanged,
    required this.onGenderToggled,
    required this.onApply,
  }) : ageRange = state.ageRange,
       interestedIn = state.interestedIn,
       saving = state.saving,
       _routeOwned = false;

  FiltersContent._routeFromState({
    required FiltersContentState state,
    required this.onAgeRangeChanged,
    required this.onGenderToggled,
  }) : ageRange = state.ageRange,
       interestedIn = state.interestedIn,
       saving = state.saving,
       onApply = null,
       _routeOwned = true;

  final RangeValues ageRange;
  final Set<Gender> interestedIn;
  final bool saving;
  final ValueChanged<RangeValues> onAgeRangeChanged;
  final ValueChanged<Gender> onGenderToggled;
  final VoidCallback? onApply;
  final bool _routeOwned;

  @override
  Widget build(BuildContext context) {
    final fields = CatchSectionList.responsive(
      emptyStateOmitted: true,
      items: [
        CatchSectionListItem(
          child: FiltersSection(
            title: context.l10n.swipesFiltersScreenTitleAge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FiltersValue(
                  value: context.l10n
                      .swipesFiltersScreenVisiblecopyRoundFormatpreferredmatchage(
                        round: ageRange.start.round(),
                        formatPreferredMatchAge: formatPreferredMatchAge(
                          ageRange.end.round(),
                        ),
                      ),
                ),
                CatchRangeInput(
                  key: SwipeKeys.ageRangeSlider,
                  minimumContract: CatchContractConstraints
                      .updateUserProfilePatchMinAgePreference,
                  maximumContract: CatchContractConstraints
                      .updateUserProfilePatchMaxAgePreference,
                  min: minimumProfileAge.toDouble(),
                  max: preferredMatchAgeOpenEndedDisplayAge.toDouble(),
                  divisions:
                      preferredMatchAgeOpenEndedDisplayAge - minimumProfileAge,
                  values: ageRange,
                  onChanged: saving ? null : onAgeRangeChanged,
                ),
              ],
            ),
          ),
        ),
        CatchSectionListItem(
          child: FiltersSection(
            title: context.l10n.swipesFiltersScreenTitleInterestedIn,
            child: Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                for (final gender in Gender.values)
                  CatchChip.selectable(
                    key: SwipeKeys.genderFilterChip(gender.name),
                    contract: CatchContractConstraints
                        .updateUserProfilePatchInterestedInGenders,
                    contractValue: gender.name,
                    label: gender.label,
                    selected: interestedIn.contains(gender),
                    onChanged: (_) => onGenderToggled(gender),
                    enabled: !saving,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
    if (_routeOwned) return fields;
    return Column(
      children: [
        Expanded(
          child: CatchPageBody.screen(pb: CatchSpacing.s5, child: fields),
        ),
        CatchDockSurface(
          includeSafeArea: false,
          padding: CatchInsets.pageBody.copyWith(
            top: CatchSpacing.s3,
            bottom: CatchSpacing.s5,
          ),
          child: CatchButton(
            key: SwipeKeys.applyFiltersButton,
            label: context.l10n.swipesFiltersScreenLabelApplyFilters,
            onPressed: saving ? null : onApply,
            status: (saving)
                ? CatchButtonStatus.loading
                : CatchButtonStatus.idle,
            fullWidth: true,
          ),
        ),
      ],
    );
  }
}

class FiltersContentSkeleton extends StatelessWidget {
  const FiltersContentSkeleton({super.key}) : _routeOwned = false;

  const FiltersContentSkeleton._route() : _routeOwned = true;

  final bool _routeOwned;

  @override
  Widget build(BuildContext context) {
    final fields = CatchSectionList.responsive(
      emptyStateOmitted: true,
      items: [
        CatchSectionListItem(
          child: FiltersSection(
            title: context.l10n.swipesFiltersScreenTitleAge,
            child: const AgeFilterSkeleton(),
          ),
        ),
        CatchSectionListItem(
          child: FiltersSection(
            title: context.l10n.swipesFiltersScreenTitleInterestedIn,
            child: const CatchSkeleton.chips(),
          ),
        ),
      ],
    );
    if (_routeOwned) return fields;
    return Column(
      children: [
        Expanded(
          child: CatchPageBody.screen(pb: CatchSpacing.s5, child: fields),
        ),
        CatchDockSurface(
          includeSafeArea: false,
          padding: CatchInsets.pageBody.copyWith(
            top: CatchSpacing.s3,
            bottom: CatchSpacing.s5,
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
