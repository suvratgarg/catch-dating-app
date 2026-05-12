import 'dart:async';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/shared/run_club_cover_fallback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final width = MediaQuery.of(context).size.width;
    // Shorter hero on landscape / tablets so content below is visible.
    final expandedHeight = width > 600 ? 180.0 : 260.0;

    return SliverAppBar(
      expandedHeight: expandedHeight,
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
              onPressed: () => unawaited(
                onShareClub != null
                    ? onShareClub!(buttonContext, club)
                    : shareRunClub(
                        buttonContext,
                        club,
                        ProviderScope.containerOf(
                          buttonContext,
                          listen: false,
                        ).read(externalShareControllerProvider),
                      ),
              ),
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
                        cityLabel(club.location),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      if (club.rating > 0) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.star_rounded, size: 14, color: t.gold),
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

Future<void> shareRunClub(
  BuildContext context,
  RunClub club,
  ExternalShareController share,
) async {
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  final uri = AppDeepLinks.runClub(club.id);

  try {
    await share.shareText(
      text:
          'Check out ${club.name}, a run club in ${club.area}, ${cityLabel(club.location)}: ${uri.toString()}',
      subject: club.name,
      origin: origin,
    );
  } on Object catch (error, stackTrace) {
    final actionError = ExternalActionException(
      'Failed to share run club',
      cause: error,
      stackTrace: stackTrace,
    );

    if (context.mounted) {
      ProviderScope.containerOf(context, listen: false)
          .read(errorLoggerProvider)
          .logAppException(
            normalizeBackendError(
              actionError,
              stackTrace: stackTrace,
              context: const BackendErrorContext(
                service: BackendService.external,
                action: 'share run club',
                resource: 'share_sheet',
              ),
            ),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open share sheet.')),
      );
    }
  }
}
