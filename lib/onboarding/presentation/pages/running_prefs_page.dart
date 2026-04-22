import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/common_widgets/error_banner.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
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

  String _formatPace(double secsPerKm) {
    final secs = secsPerKm.round();
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')}/km';
  }

  void _submit() {
    OnboardingController.completeMutation.run(ref, (tx) async {
      await tx.get(onboardingControllerProvider.notifier).complete(
        paceMinSecsPerKm: _paceRange.start.round(),
        paceMaxSecsPerKm: _paceRange.end.round(),
        preferredDistances: _distances.toList(),
        runningReasons: _reasons.toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(OnboardingController.completeMutation);
    final t = CatchTokens.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Text(
            'Your running style',
            style: CatchTextStyles.displaySm(context).copyWith(
              fontWeight: FontWeight.bold,
              color: t.ink,
            ),
          ),
          gapH8,
          Text(
            'Help us find compatible running partners.',
            style: CatchTextStyles.bodyMd(context, color: t.ink2),
          ),
          const SizedBox(height: 32),

          // ── Pace ──────────────────────────────────────────────────────────
          Text(
            'Comfortable pace',
            style: CatchTextStyles.labelMd(context, color: t.ink2),
          ),
          gapH8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatPace(_paceRange.start),
                style: CatchTextStyles.bodyMd(context, color: t.ink),
              ),
              Text(
                _formatPace(_paceRange.end),
                style: CatchTextStyles.bodyMd(context, color: t.ink),
              ),
            ],
          ),
          RangeSlider(
            values: _paceRange,
            min: 240, // 4:00/km
            max: 480, // 8:00/km
            divisions: 24,
            onChanged: (v) => setState(() => _paceRange = v),
          ),
          const SizedBox(height: 28),

          // ── Distances ─────────────────────────────────────────────────────
          Text(
            'Preferred distances',
            style: CatchTextStyles.labelMd(context, color: t.ink2),
          ),
          gapH12,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PreferredDistance.values.map((d) {
              final selected = _distances.contains(d);
              return FilterChip(
                label: Text(d.label),
                selected: selected,
                onSelected: (v) => setState(() {
                  if (v) {
                    _distances.add(d);
                  } else {
                    _distances.remove(d);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // ── Run reasons ───────────────────────────────────────────────────
          Text(
            'Why do you run?',
            style: CatchTextStyles.labelMd(context, color: t.ink2),
          ),
          gapH12,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RunReason.values.map((r) {
              final selected = _reasons.contains(r);
              return FilterChip(
                label: Text(r.label),
                selected: selected,
                onSelected: (v) => setState(() {
                  if (v) {
                    _reasons.add(r);
                  } else {
                    _reasons.remove(r);
                  }
                }),
              );
            }).toList(),
          ),

          if (mutation.hasError) ...[
            gapH16,
            ErrorBanner(
              message: (mutation as MutationError).error.toString(),
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
