import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/shared/run_club_cover_fallback.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

typedef RunClubShareHandler =
    Future<void> Function(BuildContext context, RunClub club);

class ClubHeroAppBar extends StatelessWidget {
  const ClubHeroAppBar({
    super.key,
    required this.club,
    required this.isHost,
    this.onShareClub,
  });

  final RunClub club;
  final bool isHost;
  final RunClubShareHandler? onShareClub;

  static const _expandedHeight = 260.0;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return SliverAppBar(
      expandedHeight: _expandedHeight,
      pinned: true,
      backgroundColor: t.surface,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CatchTopBarIconAction(
          icon: Icons.arrow_back_ios_new_rounded,
          tooltip: 'Back',
          backgroundColor: Colors.black.withValues(alpha: 0.35),
          foregroundColor: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
          child: Builder(
            builder: (buttonContext) => CatchTopBarIconAction(
              icon: Icons.ios_share_rounded,
              tooltip: 'Share club',
              backgroundColor: Colors.black.withValues(alpha: 0.35),
              foregroundColor: Colors.white,
              onPressed: () =>
                  unawaited((onShareClub ?? shareRunClub)(buttonContext, club)),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            club.imageUrl != null
                ? Image.network(
                    club.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => RunClubCoverFallback(club: club),
                  )
                : RunClubCoverFallback(club: club),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: CatchSpacing.s5,
              right: CatchSpacing.s5,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isHost)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: CatchBadge(
                        label: 'HOST',
                        tone: CatchBadgeTone.live,
                        uppercase: true,
                      ),
                    ),
                  Text(
                    club.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        club.location.label,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      if (club.rating > 0) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: t.gold,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          club.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
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

Future<void> shareRunClub(BuildContext context, RunClub club) async {
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  final uri = AppDeepLinks.runClub(club.id);

  try {
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Check out ${club.name}, a run club in ${club.area}, ${club.location.label}: ${uri.toString()}',
        subject: club.name,
        sharePositionOrigin: origin,
      ),
    );
  } on Object catch (error, stack) {
    debugPrint('[ERROR] ClubHeroAppBar share failed: $error\n$stack');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open share sheet.')),
    );
  }
}
