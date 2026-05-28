import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_ticket_surface.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_visual_atoms.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Production ticket-style event card backed by the shared activity visual
/// schema. The schema is presentation-only and can change without data
/// migration as long as events keep exposing [ActivityKind].
class CatchEventTicketCard extends StatelessWidget {
  const CatchEventTicketCard({
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
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final String countdownLabel;
  final String priceLabel;
  final String capacityLabel;
  final ActivityKind activityKind;
  final String? statusLabel;
  final TimeOfDay? clockTime;
  final double? width;
  final Object? heroTag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = eventActivityVisual(activityKind);
    final status = statusLabel?.trim();
    final card = SizedBox(
      width: width,
      child: PhysicalShape(
        clipper: const EventTicketShapeClipper(
          cornerRadius: CatchRadius.lg,
          notchRadius: eventTicketNotchRadius,
          notchDepth: eventTicketNotchDepth,
          notchCenterY: eventTicketMediaHeight + eventTicketDividerHeight / 2,
        ),
        clipBehavior: Clip.antiAlias,
        color: t.surface,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.16),
        child: CatchSurface(
          onTap: onTap,
          padding: EdgeInsets.zero,
          radius: CatchRadius.lg,
          elevation: CatchSurfaceElevation.none,
          clipBehavior: Clip.none,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: eventTicketMediaHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    EventActivityBackdrop(visual: visual),
                    Positioned(
                      left: CatchSpacing.s4,
                      bottom: CatchSpacing.s4,
                      child: _OutlineStamp(label: visual.label),
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
                          time: clockTime ?? _parseClockTimeLabel(timeLabel),
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
                          child: _MonoLabel(
                            '$timeLabel / $countdownLabel',
                            color: t.primary,
                          ),
                        ),
                        gapW8,
                        Text(
                          priceLabel,
                          style: CatchTextStyles.labelL(context, color: t.ink),
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
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                    gapH12,
                    _MonoLabel(capacityLabel, color: t.ink2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return heroTag == null
        ? card
        : eventHeroSurface(tag: heroTag!, child: card);
  }
}

class CatchEventSpotlightCard extends StatelessWidget {
  const CatchEventSpotlightCard({
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
  });

  final String title;
  final String supportingLabel;
  final String timeLabel;
  final String countdownLabel;
  final String priceLabel;
  final String capacityLabel;
  final ActivityKind activityKind;
  final String kicker;
  final Object? heroTag;
  final Object? visualHeroTag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = eventActivityVisual(activityKind);
    final backdrop = EventActivityBackdrop(
      visual: visual,
      dense: true,
      iconSize: 180,
      iconOpacity: 0.16,
      patternOpacity: 0.26,
    );
    final card = CatchSurface(
      onTap: onTap,
      padding: EdgeInsets.zero,
      radius: CatchRadius.lg,
      borderColor: t.line2,
      elevation: CatchSurfaceElevation.card,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
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
                  child: _RoundGlyph(icon: visual.icon),
                ),
                Positioned(
                  top: CatchSpacing.s4,
                  right: CatchSpacing.s4,
                  child: _DarkTimeChip(
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
                  _MonoLabel(
                    kicker.toUpperCase(),
                    color: t.primarySoft.withValues(alpha: 0.72),
                  ),
                  gapH8,
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.eventDisplay(
                      context,
                      size: 30,
                      height: 1.0,
                      color: t.primaryInk,
                    ),
                  ),
                  gapH10,
                  Text(
                    supportingLabel,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.bodyM(
                      context,
                      color: t.primaryInk.withValues(alpha: 0.76),
                    ),
                  ),
                  gapH16,
                  Row(
                    children: [
                      Icon(CatchIcons.group, size: 18, color: visual.accent),
                      gapW8,
                      Expanded(
                        child: _MonoLabel(
                          capacityLabel,
                          color: t.primaryInk.withValues(alpha: 0.82),
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
        : eventHeroSurface(tag: heroTag!, child: card);
  }
}

class _OutlineStamp extends StatelessWidget {
  const _OutlineStamp({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Transform.rotate(
      angle: -0.08,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: t.accent, width: 1.5),
          color: t.primaryInk.withValues(alpha: 0.12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CatchSpacing.s2,
            vertical: CatchSpacing.s1,
          ),
          child: _MonoLabel(label.toUpperCase(), color: t.accent),
        ),
      ),
    );
  }
}

class _DarkTimeChip extends StatelessWidget {
  const _DarkTimeChip({required this.label, required this.sublabel});

  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(CatchRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s3,
          vertical: CatchSpacing.s2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _MonoLabel(sublabel.toUpperCase(), color: Colors.white70),
            gapH2,
            Text(
              label,
              style: CatchTextStyles.titleM(
                context,
                color: Colors.white,
              ).copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundGlyph extends StatelessWidget {
  const _RoundGlyph({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
      ),
      child: Icon(icon, color: Colors.white, size: 26),
    );
  }
}

class _MonoLabel extends StatelessWidget {
  const _MonoLabel(this.label, {required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.ibmPlexMono(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.15,
        color: color,
      ),
    );
  }
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
