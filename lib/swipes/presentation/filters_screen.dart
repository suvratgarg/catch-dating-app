import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_snackbar_listener.dart';
import 'package:catch_dating_app/swipes/presentation/filters_controller.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FiltersScreen extends ConsumerStatefulWidget {
  const FiltersScreen({super.key});

  @override
  ConsumerState<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends ConsumerState<FiltersScreen> {
  RangeValues? _ageRange;
  Set<Gender>? _interestedIn;
  bool _didResetMutation = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didResetMutation) return;
    _didResetMutation = true;
    FiltersController.saveFiltersMutation.reset(ref);
  }

  void _syncFromProfile(UserProfile user) {
    _ageRange ??= _ageRangeValues(user);
    _interestedIn ??= user.interestedInGenders.toSet();
  }

  Future<void> _save(UserProfile user) async {
    final ageRange = _ageRange!;
    try {
      await FiltersController.saveFiltersMutation.run(ref, (tx) async {
        await tx
            .get(filtersControllerProvider.notifier)
            .saveFilters(
              uid: user.uid,
              minAgePreference: ageRange.start.round(),
              maxAgePreference: preferredMatchAgeStorageValue(
                ageRange.end.round(),
              ),
              interestedInGenders: (_interestedIn ?? {})
                  .map((e) => e.name)
                  .toList(),
            );
      });
    } catch (_) {
      // MutationErrorSnackbarListener owns user-facing error display.
    }
  }

  void _reset(UserProfile user) {
    setState(() {
      _ageRange = _ageRangeValues(user);
      _interestedIn = user.interestedInGenders.toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(watchUserProfileProvider);
    final saveMutation = ref.watch(FiltersController.saveFiltersMutation);
    final saving = saveMutation.isPending;
    final t = CatchTokens.of(context);

    ref.listen(FiltersController.saveFiltersMutation, (prev, next) {
      if (prev?.isPending == true && next.isSuccess) {
        context.pop();
      }
    });

    return MutationErrorSnackbarListener(
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
              onPressed: profileAsync.asData?.value == null || saving
                  ? null
                  : () => _reset(profileAsync.asData!.value!),
            ),
          ],
        ),
        body: profileAsync.when(
          loading: () => const CatchLoadingIndicator(),
          error: (error, _) => CatchErrorState.fromError(
            error,
            context: AppErrorContext.profile,
            onRetry: () => ref.invalidate(watchUserProfileProvider),
          ),
          data: (user) {
            if (user == null) return const SizedBox.shrink();
            _syncFromProfile(user);

            final ageRange = _ageRange!;
            final interestedIn = _interestedIn!;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      CatchSpacing.s5,
                      0,
                      CatchSpacing.s5,
                      CatchSpacing.s5,
                    ),
                    children: [
                      _FilterSection(
                        title: 'Age',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FilterValue(
                              value:
                                  '${ageRange.start.round()} - ${formatPreferredMatchAge(ageRange.end.round())}',
                            ),
                            CatchRangeSlider(
                              key: SwipeKeys.ageRangeSlider,
                              min: minimumProfileAge.toDouble(),
                              max: preferredMatchAgeOpenEndedDisplayAge
                                  .toDouble(),
                              divisions:
                                  preferredMatchAgeOpenEndedDisplayAge -
                                  minimumProfileAge,
                              values: ageRange,
                              onChanged: (values) =>
                                  setState(() => _ageRange = values),
                            ),
                          ],
                        ),
                      ),
                      _FilterSection(
                        title: 'Interested in',
                        child: Wrap(
                          spacing: CatchSpacing.s2,
                          runSpacing: CatchSpacing.s2,
                          children: [
                            for (final gender in Gender.values)
                              CatchChip(
                                key: SwipeKeys.genderFilterChip(gender.name),
                                label: gender.label,
                                active: interestedIn.contains(gender),
                                onTap: () => setState(() {
                                  interestedIn.contains(gender)
                                      ? interestedIn.remove(gender)
                                      : interestedIn.add(gender);
                                }),
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
                    onPressed: saving ? null : () => _save(user),
                    isLoading: saving,
                    fullWidth: true,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static RangeValues _ageRangeValues(UserProfile user) {
    final range = normalizeAgePreferenceRange(
      minAgePreference: user.minAgePreference,
      maxAgePreference: user.maxAgePreference,
    );
    return RangeValues(
      range.minAge.toDouble(),
      range.maxAge
          .clamp(minimumProfileAge, preferredMatchAgeOpenEndedDisplayAge)
          .toDouble(),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Container(
      padding: CatchInsets.tileVerticalCompact,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.line)),
      ),
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

class _FilterValue extends StatelessWidget {
  const _FilterValue({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(value, style: CatchTextStyles.titleL(context));
  }
}
