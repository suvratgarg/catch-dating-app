import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart'
    show CatchRadius, CatchSpacing;
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/public_profile/domain/profile_insights.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_card_style.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_reaction_controls.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_section_card.dart';
import 'package:flutter/material.dart';

class ProfileMatchSignalsSection extends StatelessWidget {
  const ProfileMatchSignalsSection({
    super.key,
    required this.confidenceSignals,
    required this.compatibilityReasons,
    this.reactionTarget,
    this.onReact,
  });

  final List<ProfileConfidenceSignal> confidenceSignals;
  final List<CompatibilityReason> compatibilityReasons;
  final ProfileReactionTarget? reactionTarget;
  final ProfileReactionCallback? onReact;

  @override
  Widget build(BuildContext context) {
    if (confidenceSignals.isEmpty && compatibilityReasons.isEmpty) {
      return const SizedBox.shrink();
    }

    final title = compatibilityReasons.isEmpty
        ? 'Profile signals'
        : 'Why you might click';

    return ProfileSectionCard(
      title: title,
      reactionTarget: reactionTarget,
      onReact: onReact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (confidenceSignals.isNotEmpty) ...[
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                for (final signal in confidenceSignals)
                  _ConfidenceSignalPill(signal: signal),
              ],
            ),
            if (compatibilityReasons.isNotEmpty) gapH14,
          ],
          for (final reason in compatibilityReasons.indexed) ...[
            _CompatibilityReasonRow(reason: reason.$2),
            if (reason.$1 < compatibilityReasons.length - 1) gapH10,
          ],
        ],
      ),
    );
  }
}

class _ConfidenceSignalPill extends StatelessWidget {
  const _ConfidenceSignalPill({required this.signal});

  final ProfileConfidenceSignal signal;

  @override
  Widget build(BuildContext context) {
    final palette = ProfileCardPalette.of(context);

    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: palette.accentSoft,
      borderColor: palette.accent.withValues(alpha: 0.22),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_confidenceIcon(signal.kind), size: 14, color: palette.accent),
          gapW6,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 190),
            child: Text(
              signal.label,
              style: CatchTextStyles.labelL(
                context,
                color: palette.textPrimary,
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

class _CompatibilityReasonRow extends StatelessWidget {
  const _CompatibilityReasonRow({required this.reason});

  final CompatibilityReason reason;

  @override
  Widget build(BuildContext context) {
    final palette = ProfileCardPalette.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchIconTile(
          icon: _compatibilityIcon(reason.kind),
          iconColor: palette.textSecondary,
          backgroundColor: palette.surfaceRaised,
          borderColor: palette.chipBorder,
          size: 26,
          iconSize: 14,
          radius: CatchRadius.pill,
        ),
        gapW10,
        Expanded(
          child: Text(
            reason.label,
            style: CatchTextStyles.bodyLead(
              context,
              color: palette.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

IconData _confidenceIcon(ProfileConfidenceSignalKind kind) {
  return switch (kind) {
    ProfileConfidenceSignalKind.completeProfile => Icons.verified_rounded,
    ProfileConfidenceSignalKind.sharedRun => Icons.directions_run_rounded,
    ProfileConfidenceSignalKind.easyOpeners =>
      Icons.chat_bubble_outline_rounded,
  };
}

IconData _compatibilityIcon(CompatibilityReasonKind kind) {
  return switch (kind) {
    CompatibilityReasonKind.sharedRun => Icons.event_available_rounded,
    CompatibilityReasonKind.relationshipGoal => Icons.favorite_border_rounded,
    CompatibilityReasonKind.runningReason => Icons.directions_run_rounded,
    CompatibilityReasonKind.runTime => Icons.wb_twilight_rounded,
    CompatibilityReasonKind.distance => Icons.straighten_rounded,
    CompatibilityReasonKind.pace => Icons.speed_rounded,
    CompatibilityReasonKind.language => Icons.translate_rounded,
    CompatibilityReasonKind.easyOpener => Icons.chat_bubble_outline_rounded,
  };
}
