import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_card_style.dart';
import 'package:catch_dating_app/user_profile/domain/profile_readiness.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

/// Overlaid at the bottom of the first profile photo. Shows public display
/// name, age, and city.
class NameOverlay extends StatelessWidget {
  const NameOverlay({super.key, required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    const d = CatchTokens.sunsetDark;
    final running = profile.activityPreferences.running;
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
                style: CatchTextStyles.headline(context, color: d.ink),
              ),
            ),
            gapW8,
            Padding(
              padding: const EdgeInsets.only(bottom: CatchSpacing.micro3),
              child: Text(
                '${profile.age}',
                style: CatchTextStyles.titleL(
                  context,
                  color: d.ink.withValues(
                    alpha: CatchOpacity.eventSuccessArrivalHighlight,
                  ),
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
                CatchIcons.locationOnOutlined,
                size: CatchIcon.xs,
                color: d.ink.withValues(alpha: CatchOpacity.profileHeroMuted),
              ),
              gapW4,
              Text(
                cityLabel(profile.city),
                style: CatchTextStyles.labelL(
                  context,
                  color: d.ink.withValues(alpha: CatchOpacity.profileHeroMuted),
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
                icon: CatchIcons.favoriteBorderRounded,
                label: goal.label,
              ),
            if (running.hasCurrentRunPreferences)
              _HeroSignalChip(
                icon: CatchIcons.speedRounded,
                label: formatPaceRange(
                  running.paceMinSecsPerKm,
                  running.paceMaxSecsPerKm,
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
    const d = CatchTokens.sunsetDark;
    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: d.overlay,
      borderColor: d.ink.withValues(alpha: CatchOpacity.revealGlowBase),
      padding: const EdgeInsets.symmetric(
        horizontal: CatchLayout.heroSignalChipHorizontalPadding,
        vertical: CatchLayout.heroSignalChipVerticalPadding,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: d.ink.withValues(alpha: CatchOpacity.eventSuccessPanelFill),
            size: CatchIcon.heroSignalChip,
          ),
          gapW6,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 210),
            child: Text(
              label,
              style: CatchTextStyles.labelL(
                context,
                color: d.ink.withValues(alpha: CatchOpacity.passButtonFill),
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
      borderColor: palette.accent.withValues(
        alpha: CatchOpacity.gradientBandSoft,
      ),
      padding: CatchInsets.compactLabelContent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CatchIcons.favoriteRounded,
            color: palette.accent,
            size: CatchIcon.sm,
          ),
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
