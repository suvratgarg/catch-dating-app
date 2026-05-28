import 'dart:math' as math;

import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_ticket_surface.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_capacity_presenter.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_visual_atoms.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const double _dateRailWidth = 66;
const double _ticketNotchRadius = 12;
const double _ticketNotchDepth = 8;

enum EventDateRailCardStripPosition { single, first, middle, last }

class EventDateRailCard extends StatelessWidget {
  const EventDateRailCard({
    super.key,
    required this.event,
    required this.kicker,
    this.title,
    this.supportingLabel,
    this.priceLabel,
    this.capacityLabel,
    this.statusLabel,
    this.stripPosition = EventDateRailCardStripPosition.single,
    this.heroTag,
    this.onTap,
  });

  final Event event;
  final String kicker;
  final String? title;
  final String? supportingLabel;
  final String? priceLabel;
  final String? capacityLabel;
  final String? statusLabel;
  final EventDateRailCardStripPosition stripPosition;
  final Object? heroTag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = eventActivityVisual(event.activityKind);
    final capacity = EventCapacityPresenter(event);
    final effectiveStatus = statusLabel?.trim();
    final effectiveSupporting = supportingLabel?.trim();
    final perforationTop =
        stripPosition == EventDateRailCardStripPosition.single ||
            stripPosition == EventDateRailCardStripPosition.first
        ? CatchSpacing.s4
        : 0.0;
    final perforationBottom =
        stripPosition == EventDateRailCardStripPosition.single ||
            stripPosition == EventDateRailCardStripPosition.last
        ? CatchSpacing.s4
        : 0.0;
    final showStatusPill =
        effectiveStatus != null &&
        effectiveStatus.isNotEmpty &&
        effectiveStatus.toLowerCase() != 'full';
    final card = PhysicalShape(
      clipper: _DateRailTicketClipper(position: stripPosition),
      clipBehavior: Clip.antiAlias,
      color: t.surface,
      elevation: stripPosition == EventDateRailCardStripPosition.single ? 4 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.14),
      child: CatchSurface(
        onTap: onTap,
        radius: CatchRadius.md,
        elevation: CatchSurfaceElevation.none,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.none,
        child: Stack(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DateRail(startTime: event.startTime, color: visual.accent),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        CatchSpacing.s4,
                        CatchSpacing.s3,
                        CatchSpacing.s4,
                        CatchSpacing.s3,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              EventActivityStamp(
                                visual: visual,
                                size: 26,
                                iconSize: 14,
                              ),
                              gapW8,
                              Expanded(
                                child: _MonoLabel(
                                  kicker.toUpperCase(),
                                  color: t.ink3,
                                ),
                              ),
                              if (showStatusPill) ...[
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
                            style: CatchTextStyles.eventDisplay(
                              context,
                              size: 25,
                              height: 1.02,
                            ),
                          ),
                          if (effectiveSupporting != null &&
                              effectiveSupporting.isNotEmpty) ...[
                            gapH4,
                            Text(
                              effectiveSupporting,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: CatchTextStyles.supporting(
                                context,
                                color: t.ink2,
                              ).copyWith(height: 1.2),
                            ),
                          ],
                          gapH8,
                          Row(
                            children: [
                              EventClockMark(
                                accent: visual.accent,
                                time: TimeOfDay.fromDateTime(event.startTime),
                                size: 17,
                              ),
                              gapW8,
                              Flexible(
                                child: Text(
                                  '${EventFormatters.time(event.startTime)} · ${priceLabel ?? _priceLabel(event)}',
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
                          _MonoLabel(
                            capacityLabel ?? capacity.goingAvailabilityLabel(),
                            color: t.ink2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: _dateRailWidth,
              top: perforationTop,
              bottom: perforationBottom,
              child: IgnorePointer(
                child: _PerforationLine(color: t.ink.withValues(alpha: 0.22)),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _DateRailTicketBorderPainter(
                    color: t.line2,
                    position: stripPosition,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return heroTag == null
        ? card
        : eventHeroSurface(tag: heroTag!, child: card);
  }
}

Path _dateRailTicketPath(
  Size size, {
  required EventDateRailCardStripPosition position,
}) {
  final shapeTop =
      position == EventDateRailCardStripPosition.single ||
      position == EventDateRailCardStripPosition.first;
  final shapeBottom =
      position == EventDateRailCardStripPosition.single ||
      position == EventDateRailCardStripPosition.last;
  final radius = math.min(CatchRadius.md, size.shortestSide / 2);
  final notchCenterX = math.min(
    math.max(_dateRailWidth, radius + _ticketNotchRadius),
    size.width - radius - _ticketNotchRadius,
  );
  const circleKappa = 0.5522847498;
  final notchLeft = notchCenterX - _ticketNotchRadius;
  final notchRight = notchCenterX + _ticketNotchRadius;
  final bottom = size.height;

  final path = Path();
  path.moveTo(shapeTop ? radius : 0, 0);
  if (shapeTop) {
    path
      ..lineTo(notchLeft, 0)
      ..cubicTo(
        notchLeft,
        circleKappa * _ticketNotchDepth,
        notchCenterX - circleKappa * _ticketNotchRadius,
        _ticketNotchDepth,
        notchCenterX,
        _ticketNotchDepth,
      )
      ..cubicTo(
        notchCenterX + circleKappa * _ticketNotchRadius,
        _ticketNotchDepth,
        notchRight,
        circleKappa * _ticketNotchDepth,
        notchRight,
        0,
      )
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius);
  } else {
    path.lineTo(size.width, 0);
  }

  path.lineTo(size.width, bottom - (shapeBottom ? radius : 0));
  if (shapeBottom) {
    path.quadraticBezierTo(size.width, bottom, size.width - radius, bottom);
  }

  if (shapeBottom) {
    path
      ..lineTo(notchRight, bottom)
      ..cubicTo(
        notchRight,
        bottom - circleKappa * _ticketNotchDepth,
        notchCenterX + circleKappa * _ticketNotchRadius,
        bottom - _ticketNotchDepth,
        notchCenterX,
        bottom - _ticketNotchDepth,
      )
      ..cubicTo(
        notchCenterX - circleKappa * _ticketNotchRadius,
        bottom - _ticketNotchDepth,
        notchLeft,
        bottom - circleKappa * _ticketNotchDepth,
        notchLeft,
        bottom,
      )
      ..lineTo(radius, bottom)
      ..quadraticBezierTo(0, bottom, 0, bottom - radius);
  } else {
    path
      ..lineTo(0, bottom)
      ..lineTo(0, bottom);
  }

  path.lineTo(0, shapeTop ? radius : 0);
  if (shapeTop) {
    path.quadraticBezierTo(0, 0, radius, 0);
  }
  return path..close();
}

class _DateRailTicketClipper extends CustomClipper<Path> {
  const _DateRailTicketClipper({required this.position});

  final EventDateRailCardStripPosition position;

  @override
  Path getClip(Size size) => _dateRailTicketPath(size, position: position);

  @override
  bool shouldReclip(covariant _DateRailTicketClipper oldClipper) {
    return oldClipper.position != position;
  }
}

class _DateRailTicketBorderPainter extends CustomPainter {
  const _DateRailTicketBorderPainter({
    required this.color,
    required this.position,
  });

  final Color color;
  final EventDateRailCardStripPosition position;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(_dateRailTicketPath(size, position: position), paint);
  }

  @override
  bool shouldRepaint(covariant _DateRailTicketBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.position != position;
  }
}

class _PerforationLine extends StatelessWidget {
  const _PerforationLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      child: CustomPaint(painter: _PerforationPainter(color: color)),
    );
  }
}

class _PerforationPainter extends CustomPainter {
  const _PerforationPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    var y = 0.5;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + 2.2), paint);
      y += 7;
    }
  }

  @override
  bool shouldRepaint(covariant _PerforationPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DateRail extends StatelessWidget {
  const _DateRail({required this.startTime, required this.color});

  final DateTime startTime;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final onColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : t.ink;
    return Container(
      width: _dateRailWidth,
      padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s4),
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            EventFormatters.shortWeekday(startTime).toUpperCase(),
            style: CatchTextStyles.mono(context, color: onColor).copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              color: onColor.withValues(alpha: 0.76),
            ),
          ),
          gapH4,
          Text(
            '${startTime.day}',
            style: CatchTextStyles.eventDisplay(
              context,
              size: 31,
              height: 0.9,
              color: onColor,
            ),
          ),
          gapH3,
          Text(
            EventFormatters.shortMonth(startTime).toUpperCase(),
            style: CatchTextStyles.mono(context, color: onColor).copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              color: onColor.withValues(alpha: 0.76),
            ),
          ),
        ],
      ),
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

String _priceLabel(Event event) => event.priceInPaise <= 0
    ? 'Free'
    : EventFormatters.priceInPaise(
        event.priceInPaise,
        currencyCode: event.currency,
      );
