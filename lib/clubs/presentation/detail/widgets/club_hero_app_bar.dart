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
    final locationLabel = '${club.area}, ${cityLabel(club.location)}';
    final captionExtent = _heroCaptionExtentFor(
      context,
      width,
      title: club.name,
      locationLabel: locationLabel,
    );
    final moduleHeight =
        mediaHeight + (clubInteractionMediaInset * 2) + captionExtent;
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
          size: CatchLayout.clubDetailHeroCollapsedTitleSize,
          height: CatchLayout.clubDetailHeroCollapsedTitleLineHeight,
          color: t.ink,
        ),
      ),
      leading: Padding(
        padding: CatchInsets.iconChipContent,
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
                  child: _ClubHeroModule(
                    club: club,
                    mediaHeight: mediaHeight,
                    locationLabel: locationLabel,
                  ),
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
  final aspectHeight = mediaWidth * CatchLayout.clubDetailHeroCoverHeightRatio;
  if (!hasCover) {
    return width > CatchLayout.maxContentWidth
        ? CatchLayout.clubDetailHeroNoCoverWideHeight
        : CatchLayout.clubDetailHeroNoCoverPhoneHeight;
  }
  return width > CatchLayout.maxContentWidth
      ? aspectHeight.clamp(
          CatchLayout.clubDetailHeroCoverWideMinHeight,
          CatchLayout.clubDetailHeroCoverWideMaxHeight,
        )
      : aspectHeight;
}

double _heroCaptionExtentFor(
  BuildContext context,
  double width, {
  required String title,
  required String locationLabel,
}) {
  final t = CatchTokens.of(context);
  final textDirection = Directionality.of(context);
  final textScaler = MediaQuery.textScalerOf(context);
  final captionWidth = CatchLayout.detailScreenContentWidthFor(width);
  final locationTextWidth = CatchLayout.clubDetailHeroLocationTextWidthFor(
    captionWidth,
  );

  final titlePainter = TextPainter(
    text: TextSpan(
      text: title,
      style: CatchTextStyles.clubDisplay(
        context,
        size: CatchLayout.clubDetailHeroExpandedTitleSize,
        height: CatchLayout.clubDetailHeroExpandedTitleLineHeight,
        color: t.ink,
      ),
    ),
    maxLines: 2,
    ellipsis: '...',
    textDirection: textDirection,
    textScaler: textScaler,
  )..layout(maxWidth: captionWidth);
  final locationPainter = TextPainter(
    text: TextSpan(
      text: locationLabel,
      style: CatchTextStyles.bodyLead(context, color: t.ink2),
    ),
    maxLines: 1,
    ellipsis: '...',
    textDirection: textDirection,
    textScaler: textScaler,
  )..layout(maxWidth: locationTextWidth);
  final locationRowHeight = locationPainter.height > CatchIcon.md
      ? locationPainter.height
      : CatchIcon.md;

  return CatchLayout.clubDetailHeroTitleTopPadding +
      titlePainter.height +
      CatchLayout.clubDetailHeroTitleLocationGap +
      locationRowHeight +
      CatchLayout.clubDetailHeroTitleBottomPadding +
      CatchLayout.clubDetailHeroCaptionSlack;
}

class _ClubHeroModule extends StatelessWidget {
  const _ClubHeroModule({
    required this.club,
    required this.mediaHeight,
    required this.locationLabel,
  });

  final Club club;
  final double mediaHeight;
  final String locationLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return ColoredBox(
      key: const ValueKey('club-detail-hero-module'),
      color: t.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchViewportCurveFrame(
            key: const ValueKey('club-detail-viewport-curve-frame'),
            backgroundColor: t.surface,
            padding: clubInteractionMediaPadding,
            paddingKey: const ValueKey('club-detail-hero-padding'),
            child: CatchSurface(
              key: const ValueKey('club-detail-hero-frame'),
              backgroundColor: t.surface,
              borderColor: t.surface,
              borderWidth: 2,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                height: mediaHeight,
                child: CatchDetailHeroBackdrop(
                  imageUrl: club.imageUrl,
                  semanticLabel: '${club.name} cover photo',
                  showScrim: false,
                ),
              ),
            ),
          ),
          Padding(
            key: const ValueKey('club-detail-hero-caption'),
            padding: const EdgeInsets.fromLTRB(
              CatchLayout.detailScreenHorizontalPadding,
              CatchLayout.clubDetailHeroTitleTopPadding,
              CatchLayout.detailScreenHorizontalPadding,
              CatchLayout.clubDetailHeroTitleBottomPadding,
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
                    size: CatchLayout.clubDetailHeroExpandedTitleSize,
                    height: CatchLayout.clubDetailHeroExpandedTitleLineHeight,
                    color: t.ink,
                  ),
                ),
                const SizedBox(
                  height: CatchLayout.clubDetailHeroTitleLocationGap,
                ),
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
                        locationLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.bodyLead(context, color: t.ink2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
