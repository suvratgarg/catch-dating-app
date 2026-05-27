import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_capacity_presenter.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_visual_atoms.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventDateRailCard extends StatelessWidget {
  const EventDateRailCard({
    super.key,
    required this.event,
    required this.kicker,
    this.title,
    this.priceLabel,
    this.capacityLabel,
    this.statusLabel,
    this.onTap,
  });

  final Event event;
  final String kicker;
  final String? title;
  final String? priceLabel;
  final String? capacityLabel;
  final String? statusLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = eventActivityVisual(event.activityKind);
    final capacity = EventCapacityPresenter(event);
    final effectiveStatus = statusLabel?.trim();
    return CatchSurface(
      onTap: onTap,
      radius: CatchRadius.md,
      borderColor: t.line2,
      elevation: CatchSurfaceElevation.card,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DateRail(startTime: event.startTime),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  CatchSpacing.s4,
                  CatchSpacing.s4,
                  CatchSpacing.s3,
                  CatchSpacing.s4,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    EventActivityStamp(visual: visual),
                    gapW12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _MonoLabel(
                                  kicker.toUpperCase(),
                                  color: t.ink3,
                                ),
                              ),
                              if (effectiveStatus != null &&
                                  effectiveStatus.isNotEmpty) ...[
                                gapW8,
                                EventStatusPill(
                                  label: effectiveStatus,
                                  color: visual.accent,
                                ),
                              ],
                            ],
                          ),
                          gapH6,
                          Text(
                            title ?? event.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _serif(context, size: 27, height: 1),
                          ),
                          gapH8,
                          Row(
                            children: [
                              EventClockMark(
                                accent: visual.accent,
                                time: TimeOfDay.fromDateTime(event.startTime),
                              ),
                              gapW8,
                              Flexible(
                                child: Text(
                                  '${EventFormatters.time(event.startTime)} / ${priceLabel ?? _priceLabel(event)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: CatchTextStyles.mono(
                                    context,
                                    color: t.ink2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          gapH8,
                          Row(
                            children: [
                              Flexible(
                                child: _MonoLabel(
                                  capacityLabel ??
                                      capacity.goingAvailabilityLabel(),
                                  color: t.ink2,
                                ),
                              ),
                              gapW12,
                              Expanded(
                                child: EventCapacityProgress(
                                  color: visual.accent,
                                  value: capacity.progress,
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
            ),
            _AccentRail(color: visual.accent),
          ],
        ),
      ),
    );
  }
}

class _DateRail extends StatelessWidget {
  const _DateRail({required this.startTime});

  final DateTime startTime;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s4),
      decoration: BoxDecoration(
        color: t.raised,
        border: Border(right: BorderSide(color: t.line)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            EventFormatters.shortWeekday(startTime).toUpperCase(),
            style: CatchTextStyles.mono(context, color: t.ink3).copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          gapH4,
          Text(
            '${startTime.day}',
            style: _serif(context, size: 30, height: 0.9),
          ),
        ],
      ),
    );
  }
}

class _AccentRail extends StatelessWidget {
  const _AccentRail({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 7,
      child: DecoratedBox(decoration: BoxDecoration(color: color)),
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

TextStyle _serif(
  BuildContext context, {
  required double size,
  double height = 1.1,
  Color? color,
}) {
  return GoogleFonts.getFont(
    'Instrument Serif',
    fontSize: size,
    fontStyle: FontStyle.italic,
    height: height,
    letterSpacing: 0,
    color: color ?? CatchTokens.of(context).ink,
  );
}

String _priceLabel(Event event) => event.priceInPaise <= 0
    ? 'Free'
    : EventFormatters.priceInPaise(
        event.priceInPaise,
        currencyCode: event.currency,
      );
