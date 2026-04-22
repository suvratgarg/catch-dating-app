import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum RunClubListTileVariant {
  /// List row: avatar · name/subtitle · Follow chip. Used in "Nearby".
  rowTile,

  /// 220 px wide horizontal-scroll card. Used in "Your clubs".
  scrollCard,

  /// 160 × 160 portrait card with gradient overlay. Used in "For you".
  portraitCard,

  /// Full-width tall card with photo, tags, activity strip. Used in directory.
  directory,

  /// Circular 58 px avatar chip with name label. Used as a filter chip row.
  avatarChip,
}

class RunClubListTile extends StatelessWidget {
  const RunClubListTile({
    super.key,
    required this.club,
    this.variant = RunClubListTileVariant.rowTile,
    this.isJoined = false,
    this.isActive = false,
    this.onFollow,
  });

  final RunClub club;
  final RunClubListTileVariant variant;
  final bool isJoined;

  /// Only used by [RunClubListTileVariant.avatarChip].
  final bool isActive;

  /// Only used by [RunClubListTileVariant.rowTile].
  final VoidCallback? onFollow;

  void _openDetail(BuildContext context) => context.pushNamed(
        Routes.runClubDetailScreen.name,
        pathParameters: {'runClubId': club.id},
        extra: club,
      );

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      RunClubListTileVariant.rowTile =>
        _RowTile(club: club, isJoined: isJoined, onTap: () => _openDetail(context), onFollow: onFollow),
      RunClubListTileVariant.scrollCard =>
        _ScrollCard(club: club, isJoined: isJoined, onTap: () => _openDetail(context)),
      RunClubListTileVariant.portraitCard =>
        _PortraitCard(club: club, onTap: () => _openDetail(context)),
      RunClubListTileVariant.directory =>
        _DirectoryCard(club: club, isJoined: isJoined, onTap: () => _openDetail(context)),
      RunClubListTileVariant.avatarChip =>
        _AvatarChip(club: club, isActive: isActive, onTap: () => _openDetail(context)),
    };
  }
}

// ── Row tile ──────────────────────────────────────────────────────────────────

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.club,
    required this.isJoined,
    this.onTap,
    this.onFollow,
  });

  final RunClub club;
  final bool isJoined;
  final VoidCallback? onTap;
  final VoidCallback? onFollow;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final subtitle = isJoined
        ? (club.nextRunLabel ?? 'Next run coming up')
        : '${club.area} · ${club.memberCount} runners';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 54,
                height: 54,
                child: _ClubImage(imageUrl: club.imageUrl, seed: club.id),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(club.name,
                      style: CatchTextStyles.labelLg(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: CatchTextStyles.caption(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onFollow,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(CatchRadius.button),
                  border: Border.all(color: t.line2),
                ),
                child: Text('Follow',
                    style: CatchTextStyles.labelMd(context, color: t.ink2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scroll card (Your clubs) — 220 px wide ────────────────────────────────────

class _ScrollCard extends StatelessWidget {
  const _ScrollCard({
    required this.club,
    required this.isJoined,
    this.onTap,
  });

  final RunClub club;
  final bool isJoined;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(CatchRadius.cardLg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 110,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ClubImage(imageUrl: club.imageUrl, seed: club.id),
                  if (isJoined)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 14, color: Colors.black),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(club.name,
                      style: CatchTextStyles.labelLg(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (isJoined) ...[
                    const SizedBox(height: 2),
                    Text(club.nextRunLabel ?? 'Next run coming up',
                        style: CatchTextStyles.caption(context,
                            color: t.primary)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Portrait card (For you) — 160 × 160 ──────────────────────────────────────

class _PortraitCard extends StatelessWidget {
  const _PortraitCard({required this.club, this.onTap});

  final RunClub club;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CatchRadius.cardLg),
        child: SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _ClubImage(imageUrl: club.imageUrl, seed: club.id),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.4, 1.0],
                    colors: [Colors.transparent, Color(0xCC000000)],
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${club.memberCount} runners',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      club.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      club.location.label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Directory card ────────────────────────────────────────────────────────────

class _DirectoryCard extends StatelessWidget {
  const _DirectoryCard({
    required this.club,
    required this.isJoined,
    this.onTap,
  });

  final RunClub club;
  final bool isJoined;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(CatchRadius.cardLg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ClubImage(imageUrl: club.imageUrl, seed: club.id),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.4, 1.0],
                        colors: [
                          Color(0x40000000),
                          Colors.transparent,
                          Color(0x1A000000),
                        ],
                      ),
                    ),
                  ),
                  if (isJoined)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius:
                              BorderRadius.circular(CatchRadius.button),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded,
                                size: 12, color: Colors.black),
                            SizedBox(width: 4),
                            Text(
                              'JOINED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(club.name,
                            style: CatchTextStyles.displaySm(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (club.rating > 0) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.star_rounded, size: 13, color: t.gold),
                        const SizedBox(width: 2),
                        Text(club.rating.toStringAsFixed(1),
                            style:
                                CatchTextStyles.caption(context, color: t.ink2)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${club.area} · ${club.memberCount} runners',
                    style: CatchTextStyles.caption(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar chip ───────────────────────────────────────────────────────────────

class _AvatarChip extends StatelessWidget {
  const _AvatarChip({
    required this.club,
    required this.isActive,
    this.onTap,
  });

  final RunClub club;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? t.primary : t.line2,
                  width: isActive ? 3 : 1,
                ),
              ),
              padding: EdgeInsets.all(isActive ? 2 : 0),
              child: ClipOval(
                child: _ClubImage(imageUrl: club.imageUrl, seed: club.id),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              club.name,
              style: CatchTextStyles.labelSm(
                context,
                color: isActive ? t.primary : t.ink2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared image helper ───────────────────────────────────────────────────────

class _ClubImage extends StatelessWidget {
  const _ClubImage({required this.imageUrl, required this.seed});

  final String? imageUrl;
  final String seed;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => PersonAvatar(size: double.infinity, name: seed);
}
