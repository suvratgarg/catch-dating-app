import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_card_style.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

/// Overlaid at the bottom of the first profile photo. Shows public display
/// name, age, and city.
class NameOverlay extends StatelessWidget {
  const NameOverlay({super.key, required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                profile.name,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.displayL(context, color: Colors.white),
              ),
            ),
            gapW8,
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '${profile.age}',
                style: CatchTextStyles.displayS(
                  context,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ),
          ],
        ),
        if (profile.city != null) ...[
          gapH8,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.white.withValues(alpha: 0.86),
              ),
              gapW4,
              Text(
                cityLabel(profile.city),
                style: CatchTextStyles.labelL(
                  context,
                  color: Colors.white.withValues(alpha: 0.86),
                ),
              ),
            ],
          ),
        ],
        gapH14,
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            if (profile.relationshipGoal case final goal?)
              _HeroSignalChip(
                icon: Icons.favorite_border_rounded,
                label: goal.label,
              ),
            if (profile.hasCurrentRunPreferences)
              _HeroSignalChip(
                icon: Icons.speed_rounded,
                label: formatPaceRange(
                  profile.paceMinSecsPerKm,
                  profile.paceMaxSecsPerKm,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _HeroSignalChip extends StatelessWidget {
  const _HeroSignalChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: Colors.black.withValues(alpha: 0.32),
      borderColor: Colors.white.withValues(alpha: 0.20),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.90), size: 15),
          gapW6,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 210),
            child: Text(
              label,
              style: CatchTextStyles.labelL(
                context,
                color: Colors.white.withValues(alpha: 0.96),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class GoalPill extends StatelessWidget {
  const GoalPill({super.key, required this.goal});

  final RelationshipGoal goal;

  @override
  Widget build(BuildContext context) {
    final palette = ProfileCardPalette.of(context);

    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: palette.accentSoft,
      borderColor: palette.accent.withValues(alpha: 0.28),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_rounded, color: palette.accent, size: 14),
          gapW6,
          Text(
            goal.label,
            style: CatchTextStyles.labelL(context, color: palette.textPrimary),
          ),
        ],
      ),
    );
  }
}
