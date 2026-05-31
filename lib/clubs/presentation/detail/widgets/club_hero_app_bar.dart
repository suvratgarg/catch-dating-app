import 'dart:async';

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_share_card.dart';
import 'package:catch_dating_app/clubs/presentation/shared/club_transition_tags.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_detail_hero_backdrop.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/catch_viewport_curve_frame.dart';
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
    final topInset = MediaQuery.paddingOf(context).top;
    final hasCover = CatchDetailHeroBackdrop.hasImage(club.imageUrl);
    final mediaHeight = _heroMediaHeightFor(width, hasCover: hasCover);
    final moduleHeight =
        mediaHeight +
        (clubInteractionMediaInset * 2) +
        _heroCaptionExtentFor(width);
    final expandedHeight = (moduleHeight - topInset)
        .clamp(kToolbarHeight, moduleHeight)
        .toDouble();

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      backgroundColor: t.surface,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      title: CatchCollapsedSliverTitle(
        title: club.name,
        textKey: const ValueKey('club-detail-collapsed-title'),
        style: CatchTextStyles.clubDisplay(
          context,
          size: 28,
          height: 0.96,
          color: t.ink,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s2),
        child: CatchTopBarIconAction(
          icon: CatchIcons.arrowBackIosNewRounded,
          tooltip: 'Back',
          backgroundColor: CatchTokens.editorialDark.withValues(
            alpha: CatchOpacity.eventHeroOverlayScrim,
          ),
          foregroundColor: CatchTokens.editorialLight,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(
            top: CatchSpacing.s2,
            bottom: CatchSpacing.s2,
            right: CatchSpacing.s2,
          ),
          child: Builder(
            builder: (buttonContext) => CatchTopBarIconAction(
              icon: CatchIcons.platformShare(
                platform: Theme.of(context).platform,
              ),
              tooltip: 'Share club',
              backgroundColor: CatchTokens.editorialDark.withValues(
                alpha: CatchOpacity.eventHeroOverlayScrim,
              ),
              foregroundColor: CatchTokens.editorialLight,
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
        background: ClipRect(
          child: OverflowBox(
            alignment: Alignment.topCenter,
            minHeight: moduleHeight,
            maxHeight: moduleHeight,
            child: SizedBox(
              height: moduleHeight,
              child: Hero(
                tag: clubInteractionHeroTag(club.id),
                transitionOnUserGestures: true,
                child: Material(
                  color: Colors.transparent,
                  child: _ClubHeroModule(club: club, mediaHeight: mediaHeight),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double _heroMediaHeightFor(double width, {required bool hasCover}) {
  final mediaWidth = width - (clubInteractionMediaInset * 2);
  final aspectHeight = mediaWidth * 3 / 4;
  if (!hasCover) return width > CatchLayout.maxContentWidth ? 164 : 220;
  return width > CatchLayout.maxContentWidth
      ? aspectHeight.clamp(164, 260)
      : aspectHeight;
}

double _heroCaptionExtentFor(double width) {
  return width > CatchLayout.maxContentWidth ? 112 : 152;
}

class _ClubHeroModule extends StatelessWidget {
  const _ClubHeroModule({required this.club, required this.mediaHeight});

  final Club club;
  final double mediaHeight;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchViewportCurveFrame(
      key: const ValueKey('club-detail-viewport-curve-frame'),
      backgroundColor: t.surface,
      padding: clubInteractionMediaPadding,
      paddingKey: const ValueKey('club-detail-hero-padding'),
      child: CatchSurface(
        key: const ValueKey('club-detail-hero-frame'),
        backgroundColor: t.surface,
        radius: CatchRadius.lg,
        borderColor: t.surface,
        borderWidth: 2,
        clipBehavior: Clip.none,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: mediaHeight,
              child: CatchDetailHeroBackdrop(
                imageUrl: club.imageUrl,
                semanticLabel: '${club.name} cover photo',
                showScrim: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                0,
                CatchSpacing.s5,
                0,
                CatchSpacing.s4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    club.name,
                    key: const ValueKey('club-detail-expanded-title'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.clubDisplay(
                      context,
                      size: 46,
                      height: 0.90,
                      color: t.ink,
                    ),
                  ),
                  gapH10,
                  Row(
                    children: [
                      Icon(
                        CatchIcons.locationOnOutlined,
                        size: CatchIcon.md,
                        color: t.ink2,
                      ),
                      gapW6,
                      Expanded(
                        child: Text(
                          '${club.area}, ${cityLabel(club.location)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.bodyLead(
                            context,
                            color: t.ink2,
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
  await showClubShareCardSheet(context, club: club, share: share);
}
