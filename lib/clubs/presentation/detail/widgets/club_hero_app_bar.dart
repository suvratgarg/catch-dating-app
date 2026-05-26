import 'dart:async';

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_detail_hero_backdrop.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ClubShareHandler =
    Future<void> Function(BuildContext context, Club club);

class ClubHeroAppBar extends StatelessWidget {
  const ClubHeroAppBar({
    super.key,
    required this.club,
    required this.isHost,
    this.onShareClub,
  });

  final Club club;
  final bool isHost;
  final ClubShareHandler? onShareClub;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final width = MediaQuery.of(context).size.width;
    final hasCover = CatchDetailHeroBackdrop.hasImage(club.imageUrl);
    // Shorter hero on landscape / tablets so content below is visible.
    final expandedHeight = width > 600
        ? (hasCover ? 172.0 : 144.0)
        : (hasCover ? 224.0 : 176.0);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      backgroundColor: t.surface,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CatchTopBarIconAction(
          icon: CatchIcons.arrowBackIosNewRounded,
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
              icon: CatchIcons.platformShare(
                platform: Theme.of(context).platform,
              ),
              tooltip: 'Share club',
              backgroundColor: Colors.black.withValues(alpha: 0.35),
              foregroundColor: Colors.white,
              onPressed: () => unawaited(
                onShareClub != null
                    ? onShareClub!(buttonContext, club)
                    : shareClub(
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
            CatchDetailHeroBackdrop(
              imageUrl: club.imageUrl,
              semanticLabel: '${club.name} cover photo',
            ),
            Positioned(
              left: CatchSpacing.s5,
              right: CatchSpacing.s5,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    club.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.displayL(
                      context,
                      color: Colors.white,
                    ),
                  ),
                  gapH8,
                  Row(
                    children: [
                      Icon(
                        CatchIcons.locationOnOutlined,
                        size: 16,
                        color: Colors.white70,
                      ),
                      gapW4,
                      Expanded(
                        child: Text(
                          '${club.area}, ${cityLabel(club.location)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.supporting(
                            context,
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                      ),
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

Future<void> shareClub(
  BuildContext context,
  Club club,
  ExternalShareController share,
) async {
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  final uri = AppDeepLinks.club(club.id);

  try {
    await share.shareText(
      text:
          'Check out ${club.name}, a club in ${club.area}, ${cityLabel(club.location)}: ${uri.toString()}',
      subject: club.name,
      origin: origin,
    );
  } on Object catch (error, stackTrace) {
    final actionError = ExternalActionException(
      'Failed to share club',
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
                action: 'share club',
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
