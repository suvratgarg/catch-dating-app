import 'dart:math' as math;

import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_mono_label.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/core/widgets/event_ticket_surface.dart';
import 'package:catch_dating_app/core/widgets/event_visual_atoms.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_capacity_labels.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:flutter/material.dart';

const double _dateRailWidth = CatchLayout.eventDateRailWidth;
const double _ticketNotchRadius = CatchSpacing.s3;
const double _ticketNotchDepth = CatchSpacing.s2;

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
    final visual = eventActivityVisual(event.activityKind, context: context);
    final capacity = EventCapacityLabels(event);
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
    final physicalElevation =
        stripPosition == EventDateRailCardStripPosition.single
        ? CatchElevation.physicalTicket
        : 0.0;
    final ticket = PhysicalShape(
      clipper: _DateRailTicketClipper(position: stripPosition),
      clipBehavior: Clip.antiAlias,
      color: t.surface,
      shadowColor: CatchElevation.physicalShadow,
      child: CatchSurface(
        onTap: onTap,
        radius: CatchRadius.md,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DateRail(startTime: event.startTime, color: visual.accent),
                  Expanded(
                    child: Padding(
                      padding: CatchInsets.listBody,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              EventActivityStamp(
                                visual: visual,
                                size: 26,
                                iconSize: CatchIcon.sm,
                              ),
                              gapW8,
                              Expanded(
                                child: CatchMonoLabel(
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
                              ),
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
                          CatchMonoLabel(
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
                child: PerforationLine(color: t.ticketPerforationLine),
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
    final card = physicalElevation == 0
        ? ticket
        : CustomPaint(
            painter: _DateRailTicketShadowPainter(
              color: CatchElevation.physicalShadow,
              elevation: physicalElevation,
              position: stripPosition,
            ),
            child: ticket,
          );
    return heroTag == null
        ? card
        : EventHeroSurface(tag: heroTag!, child: card);
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

class _DateRailTicketShadowPainter extends CustomPainter {
  const _DateRailTicketShadowPainter({
    required this.color,
    required this.elevation,
    required this.position,
  });

  final Color color;
  final double elevation;
  final EventDateRailCardStripPosition position;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || elevation <= 0) return;
    canvas.drawShadow(
      _dateRailTicketPath(size, position: position),
      color,
      elevation,
      false,
    );
  }

  @override
  bool shouldRepaint(covariant _DateRailTicketShadowPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.elevation != elevation ||
        oldDelegate.position != position;
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

class PerforationLine extends StatelessWidget {
  const PerforationLine({super.key, required this.color});

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

class DateRail extends StatelessWidget {
  const DateRail({super.key, required this.startTime, required this.color});

  final DateTime startTime;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final onColor = t.onFill(color);
    final mutedOnColor = t.onFillMuted(color);
    return Container(
      width: _dateRailWidth,
      padding: CatchInsets.tileVertical,
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            EventFormatters.shortWeekday(startTime).toUpperCase(),
            style: CatchTextStyles.monoLabelS(context, color: mutedOnColor),
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
            style: CatchTextStyles.monoLabelS(context, color: mutedOnColor),
          ),
        ],
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
