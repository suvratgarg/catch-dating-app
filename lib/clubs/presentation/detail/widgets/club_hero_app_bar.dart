import 'dart:async';
import 'dart:math' as math;

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_share_card.dart';
import 'package:catch_dating_app/clubs/shared/catch_polaroid.dart';
import 'package:catch_dating_app/clubs/shared/club_transition_tags.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_detail_hero_backdrop.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ClubShareHandler =
    Future<void> Function(BuildContext context, Club club);

enum ClubHeroVariant { polaroid, masthead, full }

@visibleForTesting
ClubHeroVariant clubHeroVariantFor(Club club) {
  if (_clubHeroPrimaryPhotoUrl(club) != null) {
    return ClubHeroVariant.polaroid;
  }
  if (_clubHeroLogoUrl(club) != null) {
    return ClubHeroVariant.masthead;
  }
  // The DS ClubHero also defines a full variant, but there is no product or
  // domain trigger for it yet; production selection keeps it unreachable.
  return ClubHeroVariant.polaroid;
}

final EdgeInsets _clubHeroLeadingPadding = CatchInsets.pageHorizontal.copyWith(
  top: CatchSpacing.micro10,
  bottom: CatchSpacing.micro6,
  right: 0,
);
final EdgeInsets _clubHeroActionPadding = CatchInsets.pageHorizontal.copyWith(
  top: CatchSpacing.micro10,
  bottom: CatchSpacing.micro6,
  left: 0,
);

class ClubHeroAppBar extends StatelessWidget {
  const ClubHeroAppBar({
    super.key,
    required this.club,
    required this.isHost,
    this.locationLabel,
    this.onShareClub,
  });

  final Club club;
  final bool isHost;
  final String? locationLabel;
  final ClubShareHandler? onShareClub;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final width = MediaQuery.of(context).size.width;
    final topInset = MediaQuery.paddingOf(context).top;
    final variant = clubHeroVariantFor(club);
    final hasCover = _clubHeroPrimaryPhotoUrl(club) != null;
    final mediaHeight = _heroMediaHeightFor(width, hasCover: hasCover);
    final resolvedLocationLabel = locationLabel ?? _clubLocationLabel(club);
    final kickerLabel = _clubHeroKicker(club);
    final captionExtent = _heroCaptionExtentFor(
      context,
      width,
      kickerLabel: kickerLabel,
      title: club.name,
      locationLabel: resolvedLocationLabel,
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
      leadingWidth: CatchSpacing.s16,
      title: CatchCollapsedSliverTitle(
        title: club.name,
        textKey: ValueKey(
          context.l10n.clubsClubHeroAppBarTitleClubDetailCollapsedTitle,
        ),
        style: CatchTextStyles.clubDisplay(
          context,
          size: CatchLayout.clubDetailHeroCollapsedTitleSize,
          height: CatchLayout.clubDetailHeroCollapsedTitleLineHeight,
          color: t.ink,
        ),
      ),
      leading: Padding(
        padding: _clubHeroLeadingPadding,
        child: CatchIconAction(
          icon: CatchIcons.arrowBackIosNewRounded,
          tooltip: context.l10n.clubsClubHeroAppBarTooltipBack,
          variant: CatchIconButtonVariant.float,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        Padding(
          padding: _clubHeroActionPadding,
          child: Builder(
            builder: (buttonContext) => CatchIconAction(
              icon: CatchIcons.platformShare(
                platform: Theme.of(context).platform,
              ),
              tooltip: context.l10n.clubsClubHeroAppBarTooltipShareClub,
              variant: CatchIconButtonVariant.float,
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
                  child: ClubHeroModule(
                    club: club,
                    variant: variant,
                    mediaHeight: mediaHeight,
                    captionExtent: captionExtent,
                    kickerLabel: kickerLabel,
                    locationLabel: resolvedLocationLabel,
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
  required String kickerLabel,
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

  final kickerPainter = TextPainter(
    text: TextSpan(
      text: kickerLabel,
      style: CatchTextStyles.monoLabelS(context, color: t.ink),
    ),
    maxLines: 1,
    ellipsis: '...',
    textDirection: textDirection,
    textScaler: textScaler,
  )..layout(maxWidth: captionWidth);
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
      kickerPainter.height +
      CatchSpacing.s2 +
      titlePainter.height +
      CatchLayout.clubDetailHeroTitleLocationGap +
      locationRowHeight +
      CatchLayout.clubDetailHeroTitleBottomPadding +
      CatchLayout.clubDetailHeroCaptionSlack;
}

class ClubHeroModule extends StatelessWidget {
  const ClubHeroModule({
    super.key,
    required this.club,
    required this.variant,
    required this.mediaHeight,
    required this.captionExtent,
    required this.kickerLabel,
    required this.locationLabel,
  });

  final Club club;
  final ClubHeroVariant variant;
  final double mediaHeight;
  final double captionExtent;
  final String kickerLabel;
  final String locationLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final module = switch (variant) {
      ClubHeroVariant.polaroid => _buildPolaroid(context),
      ClubHeroVariant.masthead => _buildMasthead(context),
      ClubHeroVariant.full => _buildFull(context),
    };

    return ColoredBox(
      key: const ValueKey('club-detail-hero-module'),
      color: t.surface,
      child: module,
    );
  }

  Padding _buildPolaroid(BuildContext context) {
    final photoUrl = _clubHeroPrimaryPhotoUrl(club);

    return Padding(
      key: const ValueKey('club-detail-hero-polaroid-padding'),
      padding: clubInteractionMediaPadding,
      child: SizedBox(
        key: const ValueKey('club-detail-hero-polaroid-frame'),
        height: mediaHeight + captionExtent,
        child: CatchPolaroid(
          media: photoUrl == null
              ? ClubPolaroidArtwork(club: club)
              : CatchDetailHeroBackdrop(
                  imageUrl: photoUrl,
                  semanticLabel: context.l10n
                      .clubsClubHeroAppBarSemanticlabelNameCoverPhoto(
                        name: club.name,
                      ),
                  showScrim: false,
                ),
          caption: locationLabel,
          title: club.name,
          titleMaxLines: 2,
          showArrow: false,
        ),
      ),
    );
  }

  Padding _buildMasthead(BuildContext context) {
    final t = CatchTokens.of(context);
    final logoUrl = _clubHeroLogoUrl(club);

    return Padding(
      key: const ValueKey('club-detail-hero-masthead-padding'),
      padding: clubInteractionMediaPadding,
      child: CatchSurface(
        key: const ValueKey('club-detail-hero-masthead'),
        height: mediaHeight + captionExtent,
        borderColor: t.line,
        radius: CatchLayout.clubPolaroidRadius,
        backgroundColor: t.surface,
        padding: CatchInsets.tileContent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    kickerLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.monoLabelS(context, color: t.ink),
                  ),
                ),
                gapW12,
                CatchPersonAvatar(
                  key: const ValueKey('club-detail-hero-logo-seal'),
                  size: CatchSpacing.s16,
                  name: club.name,
                  imageUrl: logoUrl,
                  borderWidth: CatchStroke.hairline,
                  borderColor: t.line,
                ),
              ],
            ),
            const Spacer(),
            Text(
              club.name,
              key: ValueKey(
                context.l10n.clubsClubHeroAppBarTextClubDetailExpandedTitle,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.clubDisplay(
                context,
                size: CatchLayout.clubDetailHeroExpandedTitleSize,
                height: CatchLayout.clubDetailHeroExpandedTitleLineHeight,
                color: t.ink,
              ),
            ),
            const SizedBox(height: CatchLayout.clubDetailHeroTitleLocationGap),
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
    );
  }

  Column _buildFull(BuildContext context) {
    final t = CatchTokens.of(context);
    final resolvedMediaPadding = clubInteractionMediaPadding.resolve(
      Directionality.of(context),
    );
    final viewportTopRadius = _clubHeroViewportTopCornerRadius(
      MediaQuery.of(context),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRSuperellipse(
          key: const ValueKey('club-detail-viewport-curve-frame'),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          clipper: _ClubHeroViewportCurveClipper(
            padding: resolvedMediaPadding,
            viewportTopRadius: viewportTopRadius,
            cornerRadius: CatchRadius.lg,
          ),
          child: ColoredBox(
            color: t.surface,
            child: Padding(
              key: const ValueKey('club-detail-hero-padding'),
              padding: clubInteractionMediaPadding,
              child: CatchSurface(
                key: const ValueKey('club-detail-hero-frame'),
                backgroundColor: t.surface,
                borderColor: t.surface,
                borderWidth: 2,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  height: mediaHeight,
                  child: CatchDetailHeroBackdrop(
                    imageUrl: _clubHeroPrimaryPhotoUrl(club),
                    semanticLabel: context.l10n
                        .clubsClubHeroAppBarSemanticlabelNameCoverPhoto(
                          name: club.name,
                        ),
                    showScrim: false,
                  ),
                ),
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
                kickerLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.monoLabelS(context, color: t.ink),
              ),
              gapH8,
              Text(
                club.name,
                key: ValueKey(
                  context.l10n.clubsClubHeroAppBarTextClubDetailExpandedTitle,
                ),
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
    );
  }
}

String? _clubHeroPrimaryPhotoUrl(Club club) =>
    _trimmedOrNull(club.primaryClubPhotoUrl);

String? _clubHeroLogoUrl(Club club) => _trimmedOrNull(club.logoPhotoUrl);

String? _trimmedOrNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

String _clubHeroKicker(Club club) {
  final parts = [
    club.area.trim(),
    cityLabel(club.location).trim(),
  ].where((part) => part.isNotEmpty).toList(growable: false);
  if (parts.isEmpty) return 'CLUB';
  return parts.join(' · ').toUpperCase();
}

String _clubLocationLabel(Club club) =>
    '${club.area}, ${cityLabel(club.location)}';

double _clubHeroViewportTopCornerRadius(MediaQueryData mediaQuery) {
  const fallbackRadius = CatchRadius.lg;
  final shortestSide = mediaQuery.size.shortestSide;
  final topInset = mediaQuery.padding.top;
  if (shortestSide <= 0 || topInset <= 0) return fallbackRadius;

  final maxRadius = math.max(fallbackRadius, shortestSide * 0.18);
  final derivedRadius = topInset * 1.08;
  return derivedRadius.clamp(fallbackRadius, maxRadius).toDouble();
}

class _ClubHeroViewportCurveClipper extends CustomClipper<RSuperellipse> {
  const _ClubHeroViewportCurveClipper({
    required this.padding,
    required this.viewportTopRadius,
    required this.cornerRadius,
  });

  final EdgeInsets padding;
  final double viewportTopRadius;
  final double cornerRadius;

  @override
  RSuperellipse getClip(Size size) {
    final left = padding.left.clamp(0.0, size.width / 2).toDouble();
    final top = padding.top.clamp(0.0, size.height / 2).toDouble();
    final right = math.max(left, size.width - padding.right);
    final bottom = math.max(top, size.height - padding.bottom);
    final rect = Rect.fromLTRB(left, top, right, bottom);
    if (rect.isEmpty) {
      return RSuperellipse.fromRectAndCorners(Offset.zero & size);
    }

    final topDeflate = math.min(left, top);
    final topRadius = math.max(cornerRadius, viewportTopRadius - topDeflate);
    final maxCorner = rect.shortestSide / 2;

    return RSuperellipse.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(math.min(topRadius, maxCorner)),
      topRight: Radius.circular(math.min(topRadius, maxCorner)),
      bottomLeft: Radius.circular(math.min(cornerRadius, maxCorner)),
      bottomRight: Radius.circular(math.min(cornerRadius, maxCorner)),
    );
  }

  @override
  bool shouldReclip(_ClubHeroViewportCurveClipper oldClipper) {
    return padding != oldClipper.padding ||
        viewportTopRadius != oldClipper.viewportTopRadius ||
        cornerRadius != oldClipper.cornerRadius;
  }
}

Future<void> shareClub(
  BuildContext context,
  Club club,
  ExternalShareController share,
) async {
  await showClubShareCardSheet(context, club: club, share: share);
}
