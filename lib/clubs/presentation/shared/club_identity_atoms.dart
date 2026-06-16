import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

String clubMemberCountLabel(Club club) {
  final count = club.memberCount;
  if (count == 1) return '1 member';
  if (count > 0) return '$count members';
  return 'New club';
}

List<String> visibleClubTags(
  Club club, {
  int? limit,
  bool excludeLocationTags = true,
}) {
  final locationNames = excludeLocationTags
      ? {
          club.location.toLowerCase(),
          cityLabel(club.location).toLowerCase(),
          club.area.toLowerCase(),
        }
      : const <String>{};
  final tags = club.tags
      .where((tag) {
        final normalized = tag.trim().toLowerCase();
        return normalized.isNotEmpty && !locationNames.contains(normalized);
      })
      .toList(growable: false);
  if (limit == null || tags.length <= limit) return tags;
  return tags.take(limit).toList(growable: false);
}

class ClubMemberSeal extends StatelessWidget {
  const ClubMemberSeal({
    super.key,
    required this.label,
    required this.accent,
    this.compact = false,
  });

  final String label;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final size = compact
        ? CatchLayout.clubMemberSealCompactExtent
        : CatchLayout.clubMemberSealExtent;
    final displayLabel = label.replaceFirst(' ', '\n');

    return CatchSurface(
      width: size,
      height: size,
      radius: CatchRadius.pill,
      backgroundColor: t.surface.withValues(
        alpha: compact
            ? CatchOpacity.clubMemberSealCompactFill
            : CatchOpacity.clubMemberSealFill,
      ),
      borderColor: accent.withValues(alpha: CatchOpacity.clubMemberSealBorder),
      borderWidth: CatchStroke.clubMemberSeal,
      child: Padding(
        padding: CatchInsets.iconChipContent,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              displayLabel,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: CatchTextStyles.clubMemberSeal(
                context,
                color: compact ? CatchClubColors.compactMemberSealInk : accent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ClubTagWrap extends StatelessWidget {
  const ClubTagWrap({
    super.key,
    required this.tags,
    this.tone = CatchBadgeTone.brand,
    this.size = CatchBadgeSize.sm,
    this.uppercase = true,
  });

  final List<String> tags;
  final CatchBadgeTone tone;
  final CatchBadgeSize size;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.micro6,
      runSpacing: CatchSpacing.micro6,
      children: [
        for (final tag in tags)
          CatchBadge(label: tag, tone: tone, size: size, uppercase: uppercase),
      ],
    );
  }
}

class ClubHostIdentityLine extends StatelessWidget {
  const ClubHostIdentityLine({
    super.key,
    required this.hostName,
    this.hostAvatarUrl,
    this.eyebrow = 'HOSTED BY',
    this.avatarSize = 28,
    this.trailing,
  });

  final String hostName;
  final String? hostAvatarUrl;
  final String eyebrow;
  final double avatarSize;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        ClubHostAvatar(
          name: hostName,
          imageUrl: hostAvatarUrl,
          size: avatarSize,
        ),
        gapW10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                eyebrow,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.kicker(context, color: t.ink3),
              ),
              gapH2,
              Text(
                hostName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.labelM(context, color: t.ink),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[gapW10, trailing!],
      ],
    );
  }
}

class ClubHostAvatar extends StatelessWidget {
  const ClubHostAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 32,
    this.borderWidth = 0,
    this.borderColor,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final double borderWidth;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return CatchPersonAvatar(
      size: size,
      name: name,
      imageUrl: imageUrl,
      borderWidth: borderWidth,
      borderColor: borderColor,
    );
  }
}

class ClubHostRoleBadge extends StatelessWidget {
  const ClubHostRoleBadge({super.key, required this.role});

  final ClubHostRole role;

  @override
  Widget build(BuildContext context) {
    return CatchBadge(
      label: role == ClubHostRole.owner ? 'Owner' : 'Host',
      tone: role == ClubHostRole.owner
          ? CatchBadgeTone.brand
          : CatchBadgeTone.neutral,
    );
  }
}

class ClubRatingPill extends StatelessWidget {
  const ClubRatingPill({super.key, required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s2,
        vertical: CatchSpacing.micro3,
      ),
      radius: CatchRadius.pill,
      backgroundColor: t.gold.withValues(alpha: CatchOpacity.clubRatingFill),
      borderColor: t.gold.withValues(alpha: CatchOpacity.clubRatingBorder),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CatchIcons.rated, size: CatchIcon.rating, color: t.gold),
          gapW2,
          Text(
            rating.toStringAsFixed(1),
            style: CatchTextStyles.labelL(context, color: t.ink),
          ),
        ],
      ),
    );
  }
}
