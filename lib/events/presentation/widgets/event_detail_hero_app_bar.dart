import 'package:catch_dating_app/core/motion/catch_transitions.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_event_thumbnail.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/core/widgets/event_ticket_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_photo_header.dart';
import 'package:catch_dating_app/events/shared/event_detail_route_transition.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class EventDetailHeroAppBar extends StatelessWidget {
  const EventDetailHeroAppBar({
    super.key,
    required this.event,
    required this.isSaved,
    required this.savePending,
    required this.onBack,
    required this.onShare,
    required this.onToggleSaved,
    required this.showAddToCalendar,
    required this.onAddToCalendar,
    this.showShareAction = true,
    this.presentationMode = EventDetailPresentationMode.standard,
    this.heroTag,
  });

  final Event event;
  final bool isSaved;
  final bool savePending;
  final VoidCallback onBack;
  final ValueChanged<BuildContext> onShare;
  final VoidCallback onToggleSaved;
  final bool showAddToCalendar;
  final ValueChanged<BuildContext> onAddToCalendar;
  final bool showShareAction;
  final EventDetailPresentationMode presentationMode;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    const d = CatchTokens.dark;
    final t = CatchTokens.of(context);
    final width = MediaQuery.of(context).size.width;
    final isTicketPresentation =
        presentationMode != EventDetailPresentationMode.standard;
    final isSpotlight =
        presentationMode == EventDetailPresentationMode.spotlightDark;
    final overlayScrim = CatchTokens.editorialBlack.withValues(
      alpha: CatchOpacity.eventHeroOverlayScrim,
    );
    final expandedHeight = _expandedHeightFor(
      width: width,
      isTicketPresentation: isTicketPresentation,
    );
    final collapsedBackground = isSpotlight ? t.ink : t.surface;
    final collapsedForeground = isSpotlight ? t.primaryInk : t.ink;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      backgroundColor: collapsedBackground,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      title: CatchCollapsedSliverTitle(
        title: event.title,
        textKey: ValueKey(
          context
              .l10n
              .eventsEventDetailHeroAppBarTitleEventDetailCollapsedTitle,
        ),
        style: CatchTextStyles.eventDisplay(
          context,
          size: 26,
          height: 0.95,
          color: collapsedForeground,
        ),
      ),
      leadingWidth: CatchSpacing.screenPx + CatchIconButton.navSize,
      leading: Padding(
        padding: CatchInsets.topBarLeadingAction,
        child: CatchIconAction(
          icon: CatchIcons.backArrow,
          tooltip: context.l10n.eventsEventDetailHeroAppBarTooltipBack,
          backgroundColor: overlayScrim,
          onPressed: onBack,
          foregroundColor: d.ink,
        ),
      ),
      actions: [
        Padding(
          padding: CatchInsets.topBarTrailingActions,
          child: CatchTopBarActionGroup(
            actions: [
              if (showShareAction)
                Builder(
                  builder: (buttonContext) => CatchIconAction(
                    icon: CatchIcons.platformShare(
                      platform: Theme.of(context).platform,
                    ),
                    tooltip: context
                        .l10n
                        .eventsEventDetailHeroAppBarTooltipShareEvent,
                    backgroundColor: overlayScrim,
                    onPressed: () => onShare(buttonContext),
                    foregroundColor: d.ink,
                  ),
                ),
              if (showAddToCalendar)
                Builder(
                  builder: (buttonContext) => CatchIconAction(
                    icon: CatchIcons.calendarAdd,
                    tooltip: context
                        .l10n
                        .eventsEventDetailHeroAppBarTooltipAddToCalendar,
                    backgroundColor: overlayScrim,
                    onPressed: () => onAddToCalendar(buttonContext),
                    foregroundColor: d.ink,
                  ),
                ),
              CatchIconAction(
                icon: isSaved ? CatchIcons.saved : CatchIcons.savedOutlined,
                tooltip: isSaved
                    ? context.l10n.eventsEventDetailHeroAppBarTooltipUnsaveEvent
                    : context.l10n.eventsEventDetailHeroAppBarTooltipSaveEvent,
                backgroundColor: overlayScrim,
                onPressed: savePending ? null : onToggleSaved,
                foregroundColor: d.ink,
              ),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: isTicketPresentation
            ? EventDetailTicketHeroSurface(
                event: event,
                presentationMode: presentationMode,
                heroTag: heroTag,
              )
            : EventPhotoHeroSurface(event: event),
      ),
    );
  }
}

double _expandedHeightFor({
  required double width,
  required bool isTicketPresentation,
}) {
  if (isTicketPresentation) {
    return width > CatchLayout.maxContentWidth
        ? CatchLayout.eventDetailHeroTicketWideHeight
        : CatchLayout.eventDetailHeroTicketPhoneHeight;
  }

  if (width > CatchLayout.maxContentWidth) {
    return CatchLayout.eventDetailHeroStandardWideHeight;
  }

  return (width * CatchLayout.eventDetailHeroStandardHeightRatio)
      .clamp(
        CatchLayout.eventDetailHeroStandardMinHeight,
        CatchLayout.eventDetailHeroStandardMaxHeight,
      )
      .toDouble();
}

class EventPhotoHeroSurface extends StatelessWidget {
  const EventPhotoHeroSurface({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    const d = CatchTokens.dark;
    final visual = eventActivityVisual(event.activityKind, context: context);
    return Stack(
      fit: StackFit.expand,
      children: [
        EventPhotoHeader(event: event),
        Positioned(
          left: CatchSpacing.s5,
          right: CatchSpacing.s5,
          bottom: CatchLayout.eventDetailHeroTitleBottomInset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: HeroActivityBadge(visual: visual),
              ),
              const SizedBox(height: CatchSpacing.s3),
              Text(
                event.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.eventDisplay(
                  context,
                  size: CatchLayout.eventDetailHeroStandardTitleSize,
                  height: CatchLayout.eventDetailTicketTitleLineHeight,
                  weight: FontWeight.w700,
                  color: d.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EventDetailTicketHeroSurface extends StatelessWidget {
  const EventDetailTicketHeroSurface({
    super.key,
    required this.event,
    required this.presentationMode,
    this.heroTag,
  });

  final Event event;
  final EventDetailPresentationMode presentationMode;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final surface = EventDetailTicketSurface(
      event: event,
      presentationMode: presentationMode,
    );
    final tag = heroTag;
    if (tag == null) return surface;
    return catchHeroSurface(tag: tag, child: surface);
  }
}

class EventDetailTicketSurface extends StatelessWidget {
  const EventDetailTicketSurface({
    super.key,
    required this.event,
    required this.presentationMode,
  });

  final Event event;
  final EventDetailPresentationMode presentationMode;

  @override
  Widget build(BuildContext context) {
    const d = CatchTokens.dark;
    final t = CatchTokens.of(context);
    final visual = eventActivityVisual(event.activityKind, context: context);
    final isSpotlight =
        presentationMode == EventDetailPresentationMode.spotlightDark;
    final bodyColor = isSpotlight ? t.ink : t.surface;
    final titleColor = isSpotlight ? t.primaryInk : t.ink;
    final metaColor = isSpotlight
        ? t.primaryInk.withValues(alpha: CatchOpacity.eventHeroMutedInk)
        : t.ink2;
    final lineColor = isSpotlight ? d.line : t.line2;

    return ColoredBox(
      color: bodyColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompactFlight =
              constraints.maxHeight <
              CatchLayout.eventDetailTicketCompactHeightThreshold;
          final visualHeight =
              (constraints.maxHeight *
                      (isCompactFlight
                          ? CatchLayout.eventDetailTicketVisualCompactRatio
                          : CatchLayout.eventDetailTicketVisualExpandedRatio))
                  .clamp(
                    CatchLayout.eventDetailTicketVisualMinHeight,
                    CatchLayout.eventDetailTicketVisualMaxHeight,
                  )
                  .toDouble();
          final bodyPadding = isCompactFlight
              ? const EdgeInsets.fromLTRB(
                  CatchSpacing.s4,
                  CatchSpacing.s2,
                  CatchSpacing.s4,
                  CatchSpacing.s3,
                )
              : CatchInsets.pageBody.copyWith(
                  top: CatchSpacing.s4,
                  bottom: CatchSpacing.s5,
                );
          final bodyWidth = constraints.maxWidth > bodyPadding.horizontal
              ? constraints.maxWidth - bodyPadding.horizontal
              : 0.0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: visualHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CatchEventThumbnail(
                      photoUrl: event.photoUrl,
                      pace: event.pace,
                      activityKind: event.activityKind,
                      scrim: CatchEventThumbnailScrim.none,
                      iconAlignment: Alignment.centerRight,
                      fallbackIconSize: CatchLayout.eventHeroBackdropIconSize,
                      fallbackIconOpacity: 0.15,
                      fallbackPatternOpacity: 0.24,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            CatchTokens.editorialBlack.withValues(
                              alpha: CatchOpacity.eventHeroGradientMidScrim,
                            ),
                            CatchTokens.editorialBlack.withValues(
                              alpha: isSpotlight
                                  ? CatchOpacity.eventHeroSpotlightBottomScrim
                                  : CatchOpacity.eventHeroGradientBottomScrim,
                            ),
                          ],
                          stops: const [0, 0.52, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: CatchSpacing.s5,
                      right: CatchSpacing.s5,
                      bottom: CatchSpacing.s5,
                      child: isCompactFlight
                          ? const SizedBox.shrink()
                          : Row(
                              children: [
                                HeroActivityBadge(visual: visual),
                                const Spacer(),
                                HeroTimeChip(event: event),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              EventTicketPerforatedDivider(lineColor: lineColor),
              Expanded(
                child: Padding(
                  padding: bodyPadding,
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: bodyWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            event.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: CatchTextStyles.eventDisplay(
                              context,
                              size: isCompactFlight
                                  ? CatchLayout
                                        .eventDetailTicketTitleCompactSize
                                  : CatchLayout
                                        .eventDetailTicketTitleExpandedSize,
                              height:
                                  CatchLayout.eventDetailTicketTitleLineHeight,
                              weight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                          if (!isCompactFlight) ...[
                            const SizedBox(
                              height: CatchLayout.detailScreenInlineRowGap,
                            ),
                            Text(
                              _heroSubtitle(event),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: CatchTextStyles.supporting(
                                context,
                                color: metaColor,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class HeroActivityBadge extends StatelessWidget {
  const HeroActivityBadge({super.key, required this.visual});

  final EventActivityVisualSpec visual;

  @override
  Widget build(BuildContext context) {
    const d = CatchTokens.dark;
    // Design-system EventHero activity tag: frosted pill carrying the activity
    // glyph + label (the only chroma is the glyph; chrome stays neutral).
    return CatchSurface(
      padding: CatchInsets.compactLabelContent,
      radius: CatchRadius.pill,
      backgroundColor: d.ink.withValues(alpha: CatchOpacity.lightOverlayFill),
      borderColor: d.ink.withValues(alpha: CatchOpacity.lightOverlayBorder),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            visual.icon,
            color: d.ink,
            size: CatchLayout.activityChipIconSize,
          ),
          const SizedBox(width: CatchSpacing.micro6),
          Text(
            visual.label.toUpperCase(),
            style: CatchTextStyles.monoLabel(context, color: d.ink),
          ),
        ],
      ),
    );
  }
}

class HeroTimeChip extends StatelessWidget {
  const HeroTimeChip({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    const d = CatchTokens.dark;
    return CatchSurface(
      padding: CatchInsets.compactControlContent,
      radius: CatchRadius.md,
      backgroundColor: d.ink.withValues(alpha: CatchOpacity.subtleFill),
      borderWidth: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            EventFormatters.shortWeekday(event.startTime).toUpperCase(),
            style: CatchTextStyles.monoLabel(
              context,
              color: d.ink.withValues(alpha: CatchOpacity.eventHeroMutedInk),
            ),
          ),
          gapH2,
          Text(
            EventFormatters.time(event.startTime),
            style: CatchTextStyles.sectionTitle(
              context,
              color: d.ink,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

String _heroSubtitle(Event event) {
  final price = event.priceInPaise <= 0
      ? 'Free'
      : EventFormatters.priceInPaise(
          event.priceInPaise,
          currencyCode: event.currency,
        );
  return '${event.locationName} - ${event.activitySummaryLabel} - $price';
}
