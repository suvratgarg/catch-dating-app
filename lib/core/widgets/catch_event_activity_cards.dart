import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/motion/catch_transitions.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_mono_label.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/core/widgets/event_ticket_surface.dart';
import 'package:catch_dating_app/core/widgets/event_visual_atoms.dart';
import 'package:flutter/material.dart';

enum CatchEventCardVariant { ticket, spotlight, compact }

abstract final class CatchEventCardMetrics {
  static const double compactVisualSize = 72;
}

/// Production event card backed by the shared activity visual schema.
///
/// Use named constructors instead of separate public card classes so Explore,
/// Dashboard, and map-sheet event cards share one configurable component API.
class CatchEventCard extends StatelessWidget {
  const CatchEventCard.ticket({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.countdownLabel,
    required this.priceLabel,
    required this.capacityLabel,
    required this.activityKind,
    this.statusLabel,
    this.clockTime,
    this.width,
    this.heroTag,
    this.onTap,
  }) : variant = CatchEventCardVariant.ticket,
       supportingLabel = null,
       kicker = null,
       visualHeroTag = null;

  const CatchEventCard.spotlight({
    super.key,
    required this.title,
    required this.supportingLabel,
    required this.timeLabel,
    required this.countdownLabel,
    required this.priceLabel,
    required this.capacityLabel,
    required this.activityKind,
    this.kicker = "This week's pick",
    this.heroTag,
    this.visualHeroTag,
    this.onTap,
  }) : variant = CatchEventCardVariant.spotlight,
       subtitle = null,
       statusLabel = null,
       clockTime = null,
       width = null;

  const CatchEventCard.compact({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.countdownLabel,
    required this.priceLabel,
    required this.capacityLabel,
    required this.activityKind,
    this.statusLabel,
    this.clockTime,
    this.width,
    this.heroTag,
    this.onTap,
  }) : variant = CatchEventCardVariant.compact,
       supportingLabel = null,
       kicker = null,
       visualHeroTag = null;

  final CatchEventCardVariant variant;
  final String title;
  final String? subtitle;
  final String? supportingLabel;
  final String timeLabel;
  final String countdownLabel;
  final String priceLabel;
  final String capacityLabel;
  final ActivityKind activityKind;
  final String? statusLabel;
  final String? kicker;
  final TimeOfDay? clockTime;
  final double? width;
  final Object? heroTag;
  final Object? visualHeroTag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      CatchEventCardVariant.ticket => _buildTicket(context),
      CatchEventCardVariant.spotlight => _buildSpotlight(context),
      CatchEventCardVariant.compact => _buildCompact(context),
    };
  }

  Widget _buildTicket(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = eventActivityVisual(activityKind, context: context);
    final status = statusLabel?.trim();
    final card = SizedBox(
      width: width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mediaHeight = constraints.hasBoundedWidth
              ? constraints.maxWidth * 10 / 16
              : 136.0; // fallback when unconstrained (should not happen)
          final notchCenterY = mediaHeight + eventTicketDividerHeight / 2;
          return PhysicalShape(
            clipper: EventTicketShapeClipper(
              cornerRadius: CatchRadius.lg,
              notchRadius: eventTicketNotchRadius,
              notchDepth: eventTicketNotchDepth,
              notchCenterY: notchCenterY,
            ),
            clipBehavior: Clip.antiAlias,
            color: t.surface,
            elevation: CatchElevation.physicalTicket,
            child: CatchSurface(
              onTap: onTap,
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: CatchAspectRatio.activityCard,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        EventActivityBackdrop(visual: visual),
                        Positioned(
                          left: CatchSpacing.s4,
                          bottom: CatchSpacing.s4,
                          child: _buildOutlineStamp(context, visual.label),
                        ),
                        if (status != null && status.isNotEmpty)
                          Positioned(
                            top: CatchSpacing.s3,
                            right: CatchSpacing.s3,
                            left: CatchSpacing.s3,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: EventStatusPill(
                                label: status,
                                color: visual.accent,
                                tone: EventStatusPillTone.dark,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const EventTicketPerforatedDivider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      CatchSpacing.s4,
                      CatchSpacing.s3,
                      CatchSpacing.s4,
                      CatchSpacing.s4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            EventClockMark(
                              accent: visual.accent,
                              time:
                                  clockTime ?? _parseClockTimeLabel(timeLabel),
                              size: 38,
                              ringColor: t.ink2,
                              hourStrokeWidth: 2.2,
                              minuteStrokeWidth: 1.7,
                              hourLengthFactor: 0.52,
                              minuteLengthFactor: 0.78,
                              centerDotRadius: 2.2,
                            ),
                            gapW10,
                            Expanded(
                              child: CatchMonoLabel(
                                '$timeLabel / $countdownLabel',
                                color: t.primary,
                              ),
                            ),
                            gapW8,
                            Text(
                              priceLabel,
                              style: CatchTextStyles.labelL(
                                context,
                                color: t.ink,
                              ),
                            ),
                          ],
                        ),
                        gapH10,
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.eventDisplay(
                            context,
                            size: 24,
                            height: 1.02,
                          ),
                        ),
                        gapH6,
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.supporting(
                            context,
                            color: t.ink2,
                          ),
                        ),
                        gapH12,
                        CatchMonoLabel(capacityLabel, color: t.ink2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    return heroTag == null
        ? card
        : catchHeroSurface(tag: heroTag!, child: card);
  }

  Widget _buildSpotlight(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = eventActivityVisual(activityKind, context: context);
    final backdrop = EventActivityBackdrop(
      visual: visual,
      dense: true,
      iconSize: CatchLayout.eventCardBackdropIconSize,
      iconOpacity: 0.16,
      patternOpacity: 0.26,
    );
    final card = CatchSurface(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderColor: t.line2,
      elevation: CatchSurfaceElevation.card,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: CatchAspectRatio.wide16x9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (visualHeroTag == null || heroTag != null)
                  backdrop
                else
                  Hero(
                    tag: visualHeroTag!,
                    transitionOnUserGestures: true,
                    child: backdrop,
                  ),
                Positioned(
                  top: CatchSpacing.s4,
                  left: CatchSpacing.s4,
                  child: _buildRoundGlyph(visual.icon),
                ),
                Positioned(
                  top: CatchSpacing.s4,
                  right: CatchSpacing.s4,
                  child: _buildDarkTimeChip(
                    context,
                    label: timeLabel,
                    sublabel: countdownLabel,
                  ),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(color: t.ink),
            child: Padding(
              padding: const EdgeInsets.all(CatchSpacing.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CatchMonoLabel(
                    kicker!.toUpperCase(),
                    color: t.primarySoft.withValues(
                      alpha: CatchOpacity.scrimFill,
                    ),
                  ),
                  gapH8,
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.eventDisplay(
                      context,
                      size: 30,
                      color: t.primaryInk,
                    ),
                  ),
                  gapH10,
                  Text(
                    supportingLabel!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.supporting(
                      context,
                      color: t.primaryInk.withValues(
                        alpha: CatchOpacity.onFillMuted,
                      ),
                    ),
                  ),
                  gapH16,
                  Row(
                    children: [
                      Icon(
                        CatchIcons.group,
                        size: CatchIcon.md,
                        color: visual.accent,
                      ),
                      gapW8,
                      Expanded(
                        child: CatchMonoLabel(
                          capacityLabel,
                          color: t.primaryInk.withValues(
                            alpha: CatchOpacity.primaryInkProminent,
                          ),
                        ),
                      ),
                      Text(
                        priceLabel,
                        style: CatchTextStyles.labelL(
                          context,
                          color: t.primaryInk,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return heroTag == null
        ? card
        : catchHeroSurface(tag: heroTag!, child: card);
  }

  Widget _buildCompact(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = eventActivityVisual(activityKind, context: context);
    final status = statusLabel?.trim();
    final card = SizedBox(
      width: width,
      child: CatchSurface(
        onTap: onTap,
        padding: const EdgeInsets.all(CatchSpacing.s3),
        borderColor: t.line2,
        elevation: CatchSurfaceElevation.card,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(CatchRadius.md),
              child: SizedBox.square(
                dimension: CatchEventCardMetrics.compactVisualSize,
                child: EventActivityBackdrop(
                  visual: visual,
                  dense: true,
                  iconSize: CatchIcon.lg,
                  patternOpacity: 0.24,
                ),
              ),
            ),
            gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CatchMonoLabel(
                          '$timeLabel / $countdownLabel',
                          color: t.primary,
                        ),
                      ),
                      if (status != null && status.isNotEmpty) ...[
                        gapW8,
                        EventStatusPill(label: status, color: visual.accent),
                      ],
                    ],
                  ),
                  gapH6,
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.fieldRowTitle(context),
                  ),
                  gapH3,
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                  ),
                  gapH6,
                  Row(
                    children: [
                      Expanded(
                        child: CatchMonoLabel(capacityLabel, color: t.ink2),
                      ),
                      gapW8,
                      Text(
                        priceLabel,
                        style: CatchTextStyles.labelL(context, color: t.ink),
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
    return heroTag == null
        ? card
        : catchHeroSurface(tag: heroTag!, child: card);
  }
}

Widget _buildOutlineStamp(BuildContext context, String label) {
  final t = CatchTokens.of(context);
  return Transform.rotate(
    angle: -0.08,
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: t.accent, width: 1.5),
        color: t.primaryInk.withValues(alpha: CatchOpacity.subtleFill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s2,
          vertical: CatchSpacing.s1,
        ),
        child: CatchMonoLabel(label.toUpperCase(), color: t.accent),
      ),
    ),
  );
}

Widget _buildDarkTimeChip(
  BuildContext context, {
  required String label,
  required String sublabel,
}) {
  final t = CatchTokens.of(context);
  return CatchSurface(
    radius: CatchRadius.md,
    backgroundColor: t.darkScrimFill,
    borderWidth: 0,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s3,
        vertical: CatchSpacing.s2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          CatchMonoLabel(sublabel.toUpperCase(), color: t.darkMutedInk),
          gapH2,
          Text(
            label,
            style: CatchTextStyles.sectionTitle(
              context,
              color: t.darkPillInk,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );
}

Widget _buildRoundGlyph(IconData icon) {
  return CatchSurface(
    width: CatchLayout.eventActivityGlyphExtent,
    height: CatchLayout.eventActivityGlyphExtent,
    radius: CatchRadius.pill,
    backgroundColor: CatchTokens.editorialLight.withValues(
      alpha: CatchOpacity.lightOverlayFill,
    ),
    borderColor: CatchTokens.editorialLight.withValues(
      alpha: CatchOpacity.lightOverlayBorder,
    ),
    child: Icon(
      icon,
      color: CatchTokens.editorialLight,
      size: CatchLayout.eventActivityGlyphIconSize,
    ),
  );
}

TimeOfDay _parseClockTimeLabel(String label) {
  final match = RegExp(
    r'^\s*(\d{1,2})(?::(\d{2}))?\s*([aApP][mM])?\s*$',
  ).firstMatch(label);
  if (match == null) return const TimeOfDay(hour: 12, minute: 0);

  var hour = int.tryParse(match.group(1) ?? '') ?? 12;
  final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
  final meridiem = match.group(3)?.toLowerCase();
  if (minute < 0 || minute > 59) return const TimeOfDay(hour: 12, minute: 0);

  if (meridiem == 'pm' && hour != 12) {
    hour += 12;
  } else if (meridiem == 'am' && hour == 12) {
    hour = 0;
  }
  if (hour < 0 || hour > 23) return const TimeOfDay(hour: 12, minute: 0);
  return TimeOfDay(hour: hour, minute: minute);
}
