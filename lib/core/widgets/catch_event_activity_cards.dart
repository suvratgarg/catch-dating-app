import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/motion/catch_transitions.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_mono_label.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/core/widgets/event_ticket_surface.dart';
import 'package:catch_dating_app/core/widgets/event_visual_atoms.dart';
import 'package:flutter/material.dart';

/// Production event card backed by the shared activity visual schema.
///
/// Use the ticket constructor for recommendation-style event cards that need
/// the shared activity backdrop, ticket edge, and event metadata atoms.
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
                          subtitle,
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
