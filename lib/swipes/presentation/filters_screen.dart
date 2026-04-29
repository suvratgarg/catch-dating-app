import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
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
      await ref
          .read(userProfileRepositoryProvider)
          .setUserProfile(
            userProfile: user.copyWith(
              minAgePreference: ageRange.start.round(),
              maxAgePreference: ageRange.end.round(),
              paceMinSecsPerKm: paceRange.start.round(),
              paceMaxSecsPerKm: paceRange.end.round(),
              interestedInGenders: (_interestedIn ?? {}).toList(),
              preferredDistances: (_distances ?? {}).toList(),
            ),
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
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (user) {
            if (user == null) return const SizedBox.shrink();
            _syncFromProfile(user);

            final ageRange = _ageRange!;
            final paceRange = _paceRange!;
            final interestedIn = _interestedIn!;
            final distances = _distances!;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CatchSpacing.screenH,
                    Sizes.p8,
                    CatchSpacing.screenH,
                    Sizes.p10,
                  ),
                  child: Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                      gapW12,
                      Expanded(
                        child: Text(
                          'Filters',
                          style: CatchTextStyles.displayMd(context),
                        ),
                      ),
                      TextButton(
                        onPressed: _saving ? null : () => _reset(user),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      CatchSpacing.screenH,
                      0,
                      CatchSpacing.screenH,
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
                                  '${_formatPace(paceRange.start)} - ${_formatPace(paceRange.end)} /km',
                            ),
                            RangeSlider(
                              min: 240,
                              max: 540,
                              divisions: 20,
                              values: paceRange,
                              labels: RangeLabels(
                                _formatPace(paceRange.start),
                                _formatPace(paceRange.end),
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
                              FilterChip(
                                label: Text(gender.label),
                                selected: interestedIn.contains(gender),
                                onSelected: (selected) => setState(() {
                                  selected
                                      ? interestedIn.add(gender)
                                      : interestedIn.remove(gender);
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
                              FilterChip(
                                label: Text(distance.label),
                                selected: distances.contains(distance),
                                onSelected: (selected) => setState(() {
                                  selected
                                      ? distances.add(distance)
                                      : distances.remove(distance);
                                }),
                              ),
                          ],
                        ),
                      ),
                      _FilterSection(
                        title: 'Only show verified runners',
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Coming with profile verification. Current matching remains based on shared run attendance.',
                                style: CatchTextStyles.bodySm(
                                  context,
                                  color: t.ink2,
                                ),
                              ),
                            ),
                            Switch.adaptive(value: false, onChanged: null),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    CatchSpacing.screenH,
                    Sizes.p12,
                    CatchSpacing.screenH,
                    Sizes.p20,
                  ),
                  decoration: BoxDecoration(
                    color: t.surface,
                    border: Border(top: BorderSide(color: t.line)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : () => _save(user),
                      child: _saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Apply filters'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _formatPace(double seconds) {
    final rounded = seconds.round();
    final minutes = rounded ~/ 60;
    final remainder = rounded % 60;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
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
            style: CatchTextStyles.labelSm(
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
    return Text(value, style: CatchTextStyles.displaySm(context));
  }
}
