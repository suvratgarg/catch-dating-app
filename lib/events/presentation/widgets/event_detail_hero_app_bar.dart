import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_photo_header.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_ticket_surface.dart';
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
  final EventDetailPresentationMode presentationMode;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final width = MediaQuery.of(context).size.width;
    final isTicketPresentation =
        presentationMode != EventDetailPresentationMode.standard;
    final isSpotlight =
        presentationMode == EventDetailPresentationMode.spotlightDark;
    final expandedHeight = isTicketPresentation
        ? (width > 600 ? 360.0 : 430.0)
        : (width > 600 ? 220.0 : 260.0);
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
        textKey: const ValueKey('event-detail-collapsed-title'),
        style: CatchTextStyles.eventDisplay(
          context,
          size: 26,
          height: 0.95,
          color: collapsedForeground,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CatchTopBarIconAction(
          icon: CatchIcons.backArrow,
          tooltip: 'Back',
          backgroundColor: Colors.black.withValues(alpha: 0.35),
          onPressed: onBack,
          foregroundColor: Colors.white,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Builder(
            builder: (buttonContext) => CatchTopBarIconAction(
              icon: CatchIcons.platformShare(
                platform: Theme.of(context).platform,
              ),
              tooltip: 'Share event',
              backgroundColor: Colors.black.withValues(alpha: 0.35),
              onPressed: () => onShare(buttonContext),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        if (showAddToCalendar)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
            child: Builder(
              builder: (buttonContext) => CatchTopBarIconAction(
                icon: CatchIcons.calendarAdd,
                tooltip: 'Add to calendar',
                backgroundColor: Colors.black.withValues(alpha: 0.35),
                onPressed: () => onAddToCalendar(buttonContext),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
          child: CatchTopBarIconAction(
            icon: isSaved ? CatchIcons.saved : CatchIcons.savedOutlined,
            tooltip: isSaved ? 'Unsave event' : 'Save event',
            backgroundColor: Colors.black.withValues(alpha: 0.35),
            onPressed: savePending ? null : onToggleSaved,
            foregroundColor: Colors.white,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: isTicketPresentation
            ? _EventDetailTicketHeroSurface(
                event: event,
                presentationMode: presentationMode,
                heroTag: heroTag,
              )
            : _LegacyEventHeroSurface(event: event),
      ),
    );
  }
}

class _LegacyEventHeroSurface extends StatelessWidget {
  const _LegacyEventHeroSurface({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        EventPhotoHeader(event: event),
        Positioned(
          left: CatchSpacing.s5,
          right: CatchSpacing.s5,
          bottom: CatchSpacing.s5,
          child: Text(
            event.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.displayL(context, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _EventDetailTicketHeroSurface extends StatelessWidget {
  const _EventDetailTicketHeroSurface({
    required this.event,
    required this.presentationMode,
    this.heroTag,
  });

  final Event event;
  final EventDetailPresentationMode presentationMode;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final surface = _EventDetailTicketSurface(
      event: event,
      presentationMode: presentationMode,
    );
    if (heroTag == null) return surface;
    return eventHeroSurface(tag: heroTag!, child: surface);
  }
}

class _EventDetailTicketSurface extends StatelessWidget {
  const _EventDetailTicketSurface({
    required this.event,
    required this.presentationMode,
  });

  final Event event;
  final EventDetailPresentationMode presentationMode;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = eventActivityVisual(event.activityKind);
    final isSpotlight =
        presentationMode == EventDetailPresentationMode.spotlightDark;
    final bodyColor = isSpotlight ? t.ink : t.surface;
    final titleColor = isSpotlight ? t.primaryInk : t.ink;
    final metaColor = isSpotlight
        ? t.primaryInk.withValues(alpha: 0.72)
        : t.ink2;
    final lineColor = isSpotlight
        ? Colors.white.withValues(alpha: 0.13)
        : t.line2;

    return ColoredBox(
      color: bodyColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompactFlight = constraints.maxHeight < 360;
          final visualHeight =
              (constraints.maxHeight * (isCompactFlight ? 0.48 : 0.62))
                  .clamp(96.0, 290.0)
                  .toDouble();
          final bodyPadding = isCompactFlight
              ? const EdgeInsets.fromLTRB(
                  CatchSpacing.s4,
                  CatchSpacing.s2,
                  CatchSpacing.s4,
                  CatchSpacing.s3,
                )
              : const EdgeInsets.fromLTRB(
                  CatchSpacing.s5,
                  CatchSpacing.s4,
                  CatchSpacing.s5,
                  CatchSpacing.s5,
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
                    EventActivityBackdrop(
                      visual: visual,
                      dense: true,
                      iconAlignment: Alignment.centerRight,
                      iconSize: 220,
                      iconOpacity: 0.15,
                      patternOpacity: 0.24,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.10),
                            Colors.black.withValues(
                              alpha: isSpotlight ? 0.52 : 0.34,
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
                                _HeroActivityBadge(visual: visual),
                                const Spacer(),
                                _HeroTimeChip(event: event),
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
                              size: isCompactFlight ? 30 : 42,
                              height: 0.92,
                              color: titleColor,
                            ),
                          ),
                          if (!isCompactFlight) ...[
                            gapH10,
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

class _HeroActivityBadge extends StatelessWidget {
  const _HeroActivityBadge({required this.visual});

  final EventActivityVisualSpec visual;

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      width: 56,
      height: 56,
      borderRadius: BorderRadius.circular(28),
      backgroundColor: Colors.white.withValues(alpha: 0.18),
      borderColor: Colors.white.withValues(alpha: 0.42),
      child: Icon(visual.icon, color: Colors.white, size: 26),
    );
  }
}

class _HeroTimeChip extends StatelessWidget {
  const _HeroTimeChip({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s3,
        vertical: CatchSpacing.s2,
      ),
      radius: CatchRadius.md,
      backgroundColor: Colors.black.withValues(alpha: 0.62),
      borderWidth: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            EventFormatters.shortWeekday(event.startTime).toUpperCase(),
            style: CatchTextStyles.mono(
              context,
              color: Colors.white70,
            ).copyWith(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          gapH2,
          Text(
            EventFormatters.time(event.startTime),
            style: CatchTextStyles.titleM(
              context,
              color: Colors.white,
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
