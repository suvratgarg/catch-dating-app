import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
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
    final size = compact ? 64.0 : 70.0;
    final displayLabel = label.replaceFirst(' ', '\n');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: t.surface.withValues(alpha: compact ? 0.90 : 0.72),
        border: Border.all(color: accent.withValues(alpha: 0.46), width: 2),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            displayLabel,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: CatchTextStyles.labelM(
              context,
              color: compact ? const Color(0xFF244646) : accent,
            ).copyWith(height: 1.05),
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
      spacing: 6,
      runSpacing: 6,
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
                style: CatchTextStyles.mono(
                  context,
                  color: t.ink3,
                ).copyWith(fontSize: 11, fontWeight: FontWeight.w700),
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
    return PersonAvatar(
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

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s2,
        vertical: CatchSpacing.micro3,
      ),
      decoration: BoxDecoration(
        color: t.gold.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(CatchRadius.pill),
        border: Border.all(color: t.gold.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CatchIcons.rated, size: 13, color: t.gold),
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
