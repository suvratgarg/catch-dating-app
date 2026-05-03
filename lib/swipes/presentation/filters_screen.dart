import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/firestore_error_message.dart';
import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
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
  RangeValues? _paceRange;
  Set<Gender>? _interestedIn;
  Set<PreferredDistance>? _distances;
  bool _saving = false;

  void _syncFromProfile(UserProfile user) {
    _ageRange ??= _rangeValues(
      user.minAgePreference,
      user.maxAgePreference,
      min: 18,
      max: 99,
    );
    _paceRange ??= _rangeValues(
      user.paceMinSecsPerKm,
      user.paceMaxSecsPerKm,
      min: 240,
      max: 540,
    );
    _interestedIn ??= user.interestedInGenders.toSet();
    _distances ??= user.preferredDistances.toSet();
  }

  Future<void> _save(UserProfile user) async {
    final ageRange = _ageRange!;
    final paceRange = _paceRange!;
    setState(() => _saving = true);
    try {
      await ref.read(userProfileRepositoryProvider).updateUserProfile(
        uid: user.uid,
        fields: {
          'minAgePreference': ageRange.start.round(),
          'maxAgePreference': ageRange.end.round(),
          'paceMinSecsPerKm': paceRange.start.round(),
          'paceMaxSecsPerKm': paceRange.end.round(),
          'interestedInGenders':
              (_interestedIn ?? {}).map((e) => e.name).toList(),
          'preferredDistances':
              (_distances ?? {}).map((e) => e.name).toList(),
        },
      );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _reset(UserProfile user) {
    setState(() {
      _ageRange = _rangeValues(
        user.minAgePreference,
        user.maxAgePreference,
        min: 18,
        max: 99,
      );
      _paceRange = _rangeValues(
        user.paceMinSecsPerKm,
        user.paceMaxSecsPerKm,
        min: 240,
        max: 540,
      );
      _interestedIn = user.interestedInGenders.toSet();
      _distances = user.preferredDistances.toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: CatchTopBar(
        title: 'Filters',
        leading: CatchTopBarIconAction(
          icon: Icons.close_rounded,
          tooltip: 'Close filters',
          onPressed: () => context.pop(),
        ),
        actions: [
          CatchTopBarTextAction(
            label: 'Reset',
            onPressed: profileAsync.asData?.value == null || _saving
                ? null
                : () => _reset(profileAsync.asData!.value!),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(firestoreErrorMessage(error))),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          _syncFromProfile(user);

          final ageRange = _ageRange!;
          final paceRange = _paceRange!;
          final interestedIn = _interestedIn!;
          final distances = _distances!;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    CatchSpacing.s5,
                    0,
                    CatchSpacing.s5,
                    Sizes.p20,
                  ),
                  children: [
                    _FilterSection(
                      title: 'Pace range',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FilterValue(
                            value:
                                '${formatPace(paceRange.start)} - ${formatPace(paceRange.end)} /km',
                          ),
                          RangeSlider(
                            min: 240,
                            max: 540,
                            divisions: 20,
                            values: paceRange,
                            labels: RangeLabels(
                              formatPace(paceRange.start),
                              formatPace(paceRange.end),
                            ),
                            onChanged: (values) =>
                                setState(() => _paceRange = values),
                          ),
                        ],
                      ),
                    ),
                    _FilterSection(
                      title: 'Age',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FilterValue(
                            value:
                                '${ageRange.start.round()} - ${ageRange.end.round()}',
                          ),
                          RangeSlider(
                            min: 18,
                            max: 99,
                            divisions: 81,
                            values: ageRange,
                            labels: RangeLabels(
                              '${ageRange.start.round()}',
                              '${ageRange.end.round()}',
                            ),
                            onChanged: (values) =>
                                setState(() => _ageRange = values),
                          ),
                        ],
                      ),
                    ),
                    _FilterSection(
                      title: 'Interested in',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final gender in Gender.values)
                            CatchChip(
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
                    _FilterSection(
                      title: 'Run type',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final distance in PreferredDistance.values)
                            CatchChip(
                              label: distance.label,
                              active: distances.contains(distance),
                              onTap: () => setState(() {
                                distances.contains(distance)
                                    ? distances.remove(distance)
                                    : distances.add(distance);
                              }),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(
                  CatchSpacing.s5,
                  Sizes.p12,
                  CatchSpacing.s5,
                  Sizes.p20,
                ),
                decoration: BoxDecoration(
                  color: t.surface,
                  border: Border(top: BorderSide(color: t.line)),
                ),
                child: CatchButton(
                  label: 'Apply filters',
                  onPressed: () => _save(user),
                  isLoading: _saving,
                  fullWidth: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static RangeValues _rangeValues(
    int start,
    int end, {
    required int min,
    required int max,
  }) {
    final normalizedStart = start <= end ? start : end;
    final normalizedEnd = start <= end ? end : start;
    return RangeValues(
      normalizedStart.clamp(min, max).toDouble(),
      normalizedEnd.clamp(min, max).toDouble(),
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
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: CatchTextStyles.labelM(
              context,
              color: t.ink3,
            ).copyWith(letterSpacing: 0.7),
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
