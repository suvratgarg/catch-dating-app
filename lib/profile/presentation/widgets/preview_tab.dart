import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/presentation/profile_card.dart';
import 'package:flutter/material.dart';

class PreviewTab extends StatelessWidget {
  const PreviewTab({super.key, required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Padding(
      padding: const EdgeInsets.all(Sizes.p16),
      child: Column(
        children: [
          _RunningIdentityCard(profile: profile, tokens: t),
          gapH16,
          Expanded(child: ProfileCard(profile: profile)),
        ],
      ),
    );
  }
}

class _RunningIdentityCard extends StatelessWidget {
  const _RunningIdentityCard({required this.profile, required this.tokens});

  final PublicProfile profile;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    return Container(
      padding: const EdgeInsets.all(Sizes.p18),
      decoration: BoxDecoration(
        color: t.ink,
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RUN PROFILE',
            style: CatchTextStyles.labelM(
              context,
              color: t.surface.withValues(alpha: 0.72),
            ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
          gapH8,
          Text(
            '${profile.name.split(' ').first} runs ${_formatPaceRange(profile)}',
            style: CatchTextStyles.displayM(context, color: t.surface),
          ),
          gapH14,
          Row(
            children: [
              _RunStatPill(
                label: 'Pace',
                value: _formatPaceRange(profile),
                tokens: t,
              ),
              gapW8,
              _RunStatPill(
                label: 'Distance',
                value: _formatDistanceSummary(profile),
                tokens: t,
              ),
            ],
          ),
          if (profile.runningReasons.isNotEmpty) ...[
            gapH12,
            Text(
              profile.runningReasons.map((r) => r.label).join(' · '),
              style: CatchTextStyles.bodyS(
                context,
                color: t.surface.withValues(alpha: 0.76),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _RunStatPill extends StatelessWidget {
  const _RunStatPill({
    required this.label,
    required this.value,
    required this.tokens,
  });

  final String label;
  final String value;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: CatchTextStyles.bodyS(
                context,
                color: t.surface.withValues(alpha: 0.64),
              ),
            ),
            gapH2,
            Text(
              value,
              style: CatchTextStyles.mono(context, color: t.surface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPaceRange(PublicProfile profile) {
  return '${formatPace(profile.paceMinSecsPerKm)}-${formatPace(profile.paceMaxSecsPerKm)}/km';
}

String _formatDistanceSummary(PublicProfile profile) {
  if (profile.preferredDistances.isEmpty) return 'Any run';
  return profile.preferredDistances.map((d) => d.label).take(2).join(', ');
}
