import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
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
    final palette = ProfileCardPalette.of(context);

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
                style: CatchTextStyles.displayL(
                  context,
                  color: palette.textPrimary,
                ),
              ),
            ),
            gapW8,
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '${profile.age}',
                style: CatchTextStyles.displayS(
                  context,
                  color: palette.textPrimary.withValues(alpha: 0.92),
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
                color: palette.textSecondary,
              ),
              gapW4,
              Text(
                cityLabel(profile.city),
                style: CatchTextStyles.labelL(
                  context,
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class GoalPill extends StatelessWidget {
  const GoalPill({super.key, required this.goal});

  final RelationshipGoal goal;

  @override
  Widget build(BuildContext context) {
    final palette = ProfileCardPalette.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: palette.accentSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.accent.withValues(alpha: 0.28)),
      ),
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
