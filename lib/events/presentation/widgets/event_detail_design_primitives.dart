import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_map_pin.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_graded_image.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:flutter/material.dart';

class EventDetailTicketStubBand extends StatelessWidget {
  const EventDetailTicketStubBand({
    super.key,
    required this.event,
    this.notchBackgroundColor,
  });

  final Event event;
  final Color? notchBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final cells = _ticketStubCells(event);

    return ColoredBox(
      color: t.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: CatchLayout.eventDetailTicketStubBandHeight,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var index = 0; index < cells.length; index++)
                        Expanded(
                          child: TicketStubCell(
                            cell: cells[index],
                            showDivider: index > 0,
                          ),
                        ),
                    ],
                  ),
                ),
                Divider(color: t.line, height: 1, thickness: 1),
              ],
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _TicketStubNotchPainter(
                    color: notchBackgroundColor ?? t.bg,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventDetailHintList extends StatelessWidget {
  const EventDetailHintList({
    super.key,
    required this.event,
    this.textColor,
    this.dividerColor,
  });

  final Event event;
  final Color? textColor;
  final Color? dividerColor;

  @override
  Widget build(BuildContext context) {
    final hints = _hintsFor(event);
    final t = CatchTokens.of(context);
    final activity = ActivityPalette.resolve(context, event.activityKind);

    return HairlineList(
      itemCount: hints.length,
      dividerColor: dividerColor,
      itemBuilder: (context, index) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: CatchSurface(
              width: CatchLayout.eventDetailHintDotExtent,
              height: CatchLayout.eventDetailHintDotExtent,
              radius: CatchRadius.pill,
              backgroundColor: activity.accent,
              borderWidth: 0,
              child: const SizedBox.shrink(),
            ),
          ),
          gapW12,
          Expanded(
            child: Text(
              hints[index],
              style: CatchTextStyles.hint(context, color: textColor ?? t.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class EventDetailItinerary extends StatelessWidget {
  const EventDetailItinerary({
    super.key,
    required this.event,
    this.titleColor,
    this.detailColor,
    this.dotBackgroundColor,
  });

  final Event event;
  final Color? titleColor;
  final Color? detailColor;
  final Color? dotBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activity = ActivityPalette.resolve(context, event.activityKind);
    final steps = _itineraryFor(event);

    return Column(
      children: [
        for (var index = 0; index < steps.length; index++)
          ItineraryRow(
            step: steps[index],
            isLast: index == steps.length - 1,
            accent: activity.accent,
            railColor: t.line2,
            titleColor: titleColor,
            detailColor: detailColor,
            dotBackgroundColor: dotBackgroundColor,
          ),
      ],
    );
  }
}

class EventDetailMapCard extends StatelessWidget {
  const EventDetailMapCard({
    super.key,
    required this.event,
    this.onTap,
    this.surfaceColor,
    this.borderColor,
  });

  final Event event;
  final VoidCallback? onTap;
  final Color? surfaceColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activity = ActivityPalette.resolve(context, event.activityKind);
    final canOpen = event.hasExactStartingPoint && onTap != null;
    final note = event.hasExactStartingPoint
        ? 'PIN READY'
        : 'PIN DROPS MORNING-OF';

    return Semantics(
      button: canOpen,
      label: event.locationName,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(CatchRadius.md),
          onTap: canOpen ? onTap : null,
          child: Ink(
            height: CatchLayout.eventDetailMapCardHeight,
            decoration: BoxDecoration(
              color: surfaceColor ?? activity.soft,
              border: Border.all(color: borderColor ?? t.line),
              borderRadius: BorderRadius.circular(CatchRadius.md),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapGridPainter(
                      lineColor: t.surface.withValues(alpha: 0.52),
                      routeColor: activity.accent.withValues(alpha: 0.24),
                    ),
                  ),
                ),
                Center(
                  child: CatchActivityMapPin(
                    activityKind: event.activityKind,
                    selected: true,
                  ),
                ),
                Positioned(
                  left: CatchSpacing.s2,
                  right: CatchSpacing.s2,
                  bottom: CatchSpacing.s2,
                  child: Row(
                    children: [
                      Expanded(
                        child: MapPill(
                          text: event.locationName,
                          color: t.ink,
                        ),
                      ),
                      gapW8,
                      MapPill(text: note, color: t.ink2),
                      if (canOpen) ...[
                        gapW8,
                        Icon(
                          CatchIcons.chevronRightRounded,
                          color: t.ink2,
                          size: CatchIcon.xs,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EventDetailMechanismList extends StatelessWidget {
  const EventDetailMechanismList({
    super.key,
    required this.event,
    this.dividerColor,
  });

  final Event event;
  final Color? dividerColor;

  @override
  Widget build(BuildContext context) {
    final rows = _mechanismsFor(event);
    final activity = ActivityPalette.resolve(context, event.activityKind);

    return HairlineList(
      itemCount: rows.length,
      dividerColor: dividerColor,
      itemBuilder: (context, index) {
        final row = rows[index];
        return CatchField.read(
          icon: row.icon,
          iconColor: activity.deep,
          title: row.title,
          body: row.detail.isEmpty ? null : row.detail,
        );
      },
    );
  }
}

const _photoStripTileCount = 3;

class EventDetailPhotoStrip extends StatelessWidget {
  const EventDetailPhotoStrip({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activity = ActivityPalette.resolve(context, event.activityKind);
    final photos = event.eventPhotos.take(_photoStripTileCount).toList();
    if (photos.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            for (var index = 0; index < _photoStripTileCount; index++) ...[
              Expanded(
                child: EventDetailPhotoStripTile(
                  index: index,
                  photo: index < photos.length ? photos[index] : null,
                  backgroundColor: activity.soft,
                  iconColor: activity.deep,
                  icon: activity.glyph,
                ),
              ),
              if (index != _photoStripTileCount - 1) gapW8,
            ],
          ],
        ),
        gapH8,
        Row(
          children: [
            Text(
              'EVENT PHOTOS',
              style: CatchTextStyles.monoLabelS(context, color: t.ink),
            ),
            const Spacer(),
            Text(
              '${event.eventPhotos.length} UPLOADED',
              style: CatchTextStyles.monoLabelS(context, color: t.ink3),
            ),
          ],
        ),
      ],
    );
  }
}

class EventDetailPhotoStripTile extends StatelessWidget {
  const EventDetailPhotoStripTile({
    super.key,
    required this.index,
    required this.photo,
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
  });

  final int index;
  final UploadedPhoto? photo;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: ValueKey('event-photo-strip-tile-$index'),
      height: CatchLayout.eventDetailPhotoStripTileHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CatchRadius.infoTile),
        child: photo == null
            ? ColoredBox(
                key: ValueKey('event-photo-strip-placeholder-$index'),
                color: backgroundColor,
                child: Icon(icon, color: iconColor, size: CatchIcon.lg),
              )
            : ColoredBox(
                color: backgroundColor,
                child: CatchNetworkImage(
                  photo!.thumbnailOrUrl,
                  key: ValueKey('event-photo-strip-image-$index'),
                  errorBuilder: (_, _, _) =>
                      Icon(icon, color: iconColor, size: CatchIcon.lg),
                ),
              ),
      ),
    );
  }
}

class _TicketStubCellData {
  const _TicketStubCellData({
    required this.label,
    required this.value,
    this.detail,
    this.icon,
  });

  final String label;
  final String value;
  final String? detail;
  final IconData? icon;
}

class TicketStubCell extends StatelessWidget {
  const TicketStubCell({
    super.key,
    required this.cell,
    required this.showDivider,
  });

  final _TicketStubCellData cell;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Stack(
      children: [
        if (showDivider)
          Positioned.fill(
            child: CustomPaint(painter: _VerticalDashedPainter(color: t.line2)),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            showDivider ? CatchSpacing.s3 : CatchSpacing.s5,
            CatchSpacing.s2,
            CatchSpacing.s3,
            CatchSpacing.s2,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cell.label.toUpperCase(),
                    style: CatchTextStyles.monoLabelS(context),
                  ),
                  gapH6,
                  Text(
                    cell.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.mono(
                      context,
                      color: t.ink,
                    ).copyWith(fontWeight: FontWeight.w700, height: 1.25),
                  ),
                  if (cell.detail != null) ...[
                    const SizedBox(height: CatchSpacing.micro2),
                    Text(
                      cell.detail!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.numericMeta(context, color: t.ink2),
                    ),
                  ],
                ],
              ),
              if (cell.icon != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(cell.icon, size: 15, color: t.ink3),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class HairlineList extends StatelessWidget {
  const HairlineList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.dividerColor,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Color? dividerColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      children: [
        for (var index = 0; index < itemCount; index++) ...[
          if (index > 0)
            Divider(
              color: dividerColor ?? t.line,
              height: CatchLayout.eventDetailHairlineDividerHeight,
              thickness: 1,
            ),
          itemBuilder(context, index),
        ],
      ],
    );
  }
}

class _ItineraryStep {
  const _ItineraryStep({
    required this.time,
    required this.title,
    required this.detail,
  });

  final String time;
  final String title;
  final String detail;
}

class ItineraryRow extends StatelessWidget {
  const ItineraryRow({
    super.key,
    required this.step,
    required this.isLast,
    required this.accent,
    required this.railColor,
    this.titleColor,
    this.detailColor,
    this.dotBackgroundColor,
  });

  final _ItineraryStep step;
  final bool isLast;
  final Color accent;
  final Color railColor;
  final Color? titleColor;
  final Color? detailColor;
  final Color? dotBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: CatchLayout.eventDetailItineraryTimeColumnWidth,
            child: Text(
              step.time,
              style: CatchTextStyles.mono(
                context,
                color: t.ink,
              ).copyWith(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: CatchLayout.eventDetailItineraryRailColumnWidth,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: CatchSurface(
                    width: CatchLayout.eventDetailItineraryDotExtent,
                    height: CatchLayout.eventDetailItineraryDotExtent,
                    radius: CatchRadius.pill,
                    backgroundColor: dotBackgroundColor ?? t.surface,
                    borderColor: accent,
                    borderWidth: 2,
                    child: const SizedBox.shrink(),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: SizedBox(
                        width: 1.5,
                        child: ColoredBox(color: railColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          gapW8,
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : CatchSpacing.s3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: CatchTextStyles.fieldRowTitle(
                      context,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: CatchSpacing.micro2),
                  Text(
                    step.detail,
                    style: CatchTextStyles.supporting(
                      context,
                      color: detailColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapPill extends StatelessWidget {
  const MapPill({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: CatchTokens.editorialLight.withValues(alpha: 0.93),
      borderWidth: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s3,
        vertical: CatchSpacing.s2,
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: CatchTextStyles.monoLabelS(context, color: color),
      ),
    );
  }
}

class _MechanismRow {
  const _MechanismRow({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;
}

class _TicketStubNotchPainter extends CustomPainter {
  const _TicketStubNotchPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final y = size.height / 2;
    canvas.drawCircle(Offset(-8, y), 14, paint);
    canvas.drawCircle(Offset(size.width + 8, y), 14, paint);
  }

  @override
  bool shouldRepaint(covariant _TicketStubNotchPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _VerticalDashedPainter extends CustomPainter {
  const _VerticalDashedPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    var y = CatchSpacing.s2;
    while (y < size.height - CatchSpacing.s2) {
      canvas.drawLine(Offset(0, y), Offset(0, y + 5), paint);
      y += 11;
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalDashedPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _MapGridPainter extends CustomPainter {
  const _MapGridPainter({required this.lineColor, required this.routeColor});

  final Color lineColor;
  final Color routeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    for (var x = 18.0; x < size.width; x += 34) {
      canvas.drawLine(Offset(x, 0), Offset(x - 22, size.height), linePaint);
    }
    for (var y = 16.0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 18), linePaint);
    }

    final routePaint = Paint()
      ..color = routeColor
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.72)
      ..cubicTo(
        size.width * 0.26,
        size.height * 0.34,
        size.width * 0.52,
        size.height * 0.80,
        size.width * 0.70,
        size.height * 0.40,
      )
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.22,
        size.width * 0.90,
        size.height * 0.32,
        size.width * 0.94,
        size.height * 0.24,
      );
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor ||
      oldDelegate.routeColor != routeColor;
}

List<_TicketStubCellData> _ticketStubCells(Event event) {
  final locationDetail = event.locationNotes;
  return [
    _TicketStubCellData(
      label: 'When',
      value: event.shortDateLabel,
      detail: event.compactTimeRangeLabel,
      icon: CatchIcons.calendarAdd,
    ),
    _TicketStubCellData(
      label: 'Where',
      value: event.locationName,
      detail: locationDetail == null || locationDetail.isEmpty
          ? null
          : locationDetail,
    ),
    _TicketStubCellData(
      label: _levelLabelFor(event.activityKind),
      value: event.pace.label,
      detail: event.activitySummaryLabel,
    ),
  ];
}

List<String> _hintsFor(Event event) {
  final remaining = event.spotsRemaining;
  final capacityHint = remaining == 0
      ? 'This event is currently full; the waitlist keeps priority order.'
      : remaining <= 3
      ? 'Only $remaining ${remaining == 1 ? 'spot' : 'spots'} left before sign-ups move to waitlist.'
      : '${event.spotsLabel} spots are already spoken for.';
  return [capacityHint, _interactionHint(event.eventFormat.interactionModel)];
}

List<_ItineraryStep> _itineraryFor(Event event) {
  final warmupTime = event.startTime.add(const Duration(minutes: 15));
  return [
    _ItineraryStep(
      time: EventFormatters.time(event.startTime),
      title: 'Gather at ${event.locationName}',
      detail: 'Quick hellos, host check-in, and the plan for the group.',
    ),
    _ItineraryStep(
      time: EventFormatters.time(warmupTime),
      title: event.eventFormat.label,
      detail: _activityPlanDetail(event),
    ),
    _ItineraryStep(
      time: EventFormatters.time(event.endTime),
      title: 'Wrap up',
      detail:
          'Attendees can linger naturally; private follow-up unlocks after.',
    ),
  ];
}

List<_MechanismRow> _mechanismsFor(Event event) {
  final policy = event.effectiveEventPolicy;
  final rows = <_MechanismRow>[
    _MechanismRow(
      icon: policy.admissionPolicy.manualApprovalRequired
          ? CatchIcons.pendingActionsOutlined
          : CatchIcons.groupOutlined,
      title: _admissionTitle(policy.admissionPolicy),
      detail: _admissionSummary(policy.admissionPolicy),
    ),
  ];

  if (policy.admissionPolicy.waitlistPolicy.isEnabled || event.isFull) {
    rows.add(
      _MechanismRow(
        icon: CatchIcons.pendingActionsOutlined,
        title: 'If it fills, a waitlist',
        detail: 'Spots free up in order as capacity changes or people cancel.',
      ),
    );
  }

  rows.add(
    _MechanismRow(
      icon: CatchIcons.receiptLongOutlined,
      title: '${policy.cancellationPolicy.title} cancellation',
      detail: policy.cancellationPolicy.attendeeSummary,
    ),
  );

  return rows;
}

String _interactionHint(EventInteractionModel model) {
  return switch (model) {
    EventInteractionModel.pacePods =>
      'The format keeps the pace conversational, with regroup points so nobody gets stranded.',
    EventInteractionModel.pairedRotations =>
      'Rotations give you natural one-on-one moments without managing the room yourself.',
    EventInteractionModel.teamRotations =>
      'Team structure creates low-pressure reasons to talk throughout the event.',
    EventInteractionModel.seatedTable =>
      'A seated format and host cues make the first conversation easier.',
    EventInteractionModel.freeFormMixer =>
      'Host nudges keep the room moving when it needs a little structure.',
    EventInteractionModel.hostLedProgram =>
      'The host runs the arc, so you can just show up and follow the moment.',
    EventInteractionModel.openFormat =>
      'The host shapes the format around the room and venue.',
  };
}

String _activityPlanDetail(Event event) {
  return switch (event.eventFormat.interactionModel) {
    EventInteractionModel.pacePods =>
      '${EventFormatters.distanceKm(event.distanceKm)} at a ${event.pace.label.toLowerCase()} pace, with host-led regroup points.',
    EventInteractionModel.pairedRotations =>
      'Paired or court-based rotations keep the activity moving and social.',
    EventInteractionModel.teamRotations =>
      'Host-led teams and rotations create a clear rhythm for the group.',
    EventInteractionModel.seatedTable =>
      'A table-led format with built-in prompts and host cues.',
    EventInteractionModel.freeFormMixer =>
      'A looser mixer with host nudges when the room needs direction.',
    EventInteractionModel.hostLedProgram =>
      'A host-led activity with clear arrival, activity, and follow-up moments.',
    EventInteractionModel.openFormat =>
      'The host adapts the format to the group and venue.',
  };
}

String _levelLabelFor(ActivityKind activityKind) {
  return switch (activityKind) {
    ActivityKind.socialRun ||
    ActivityKind.running ||
    ActivityKind.walking ||
    ActivityKind.cycling => 'Pace',
    ActivityKind.pickleball ||
    ActivityKind.padel ||
    ActivityKind.tennis ||
    ActivityKind.badminton => 'Skill',
    ActivityKind.spinClass ||
    ActivityKind.yoga ||
    ActivityKind.strengthTraining => 'Intensity',
    ActivityKind.pubQuiz ||
    ActivityKind.barCrawl ||
    ActivityKind.dinner ||
    ActivityKind.singlesMixer ||
    ActivityKind.openActivity => 'Energy',
  };
}

String _admissionTitle(EventAdmissionPolicy policy) {
  return switch (policy.format) {
    EventAdmissionFormat.open => 'Open sign-up',
    EventAdmissionFormat.inviteOnly => 'Invite only',
    EventAdmissionFormat.manualApproval => 'Host approval',
    EventAdmissionFormat.fixedCohortCaps => 'Cohort caps',
    EventAdmissionFormat.balancedRatio => 'Balanced singles',
    EventAdmissionFormat.membersOnly => 'Members only',
  };
}

String _admissionSummary(EventAdmissionPolicy policy) {
  return switch (policy.format) {
    EventAdmissionFormat.open =>
      'No approval needed; RSVP until ${policy.capacityLimit} spots are filled.',
    EventAdmissionFormat.fixedCohortCaps =>
      'Book within total capacity while cohort caps keep the room balanced.',
    EventAdmissionFormat.balancedRatio =>
      'Straight men and women are balanced within a small tolerance; other cohorts book within total capacity.',
    EventAdmissionFormat.inviteOnly =>
      'Only attendees with the host invite can book this event.',
    EventAdmissionFormat.manualApproval =>
      'Request a spot first; the host reviews requests before confirming.',
    EventAdmissionFormat.membersOnly =>
      'Only active club members can book this event.',
  };
}

/// One value/label data pair in an [EventDetailHostCard] stat strip
/// (design-system `HostStat`). [value] and [label] are pre-formatted; [label]
/// is rendered uppercased mono.
@immutable
class EventDetailHostStat {
  const EventDetailHostStat({required this.value, required this.label});

  /// Mono figure, e.g. `"23"` or `"92%"`.
  final String value;

  /// Mono label, e.g. `"RUNS"` (rendered uppercased).
  final String label;
}

/// Design-system "your hosts" card (`components/events/HostCard`): a graded
/// avatar on the activity gradient, the condensed host name with a pigment
/// verified seal, a mono meta line, an optional three-up stat strip, and two
/// hairline secondary actions (Message host / View club).
class EventDetailHostCard extends StatelessWidget {
  const EventDetailHostCard({
    super.key,
    required this.activityKind,
    required this.hostName,
    this.photoUrl,
    this.meta,
    this.verified = true,
    this.stats = const <EventDetailHostStat>[],
    this.messageLabel = 'Message host',
    this.clubLabel = 'View club',
    this.onMessage,
    this.onViewClub,
    this.surfaceColor,
    this.borderColor,
    this.nameColor,
    this.metaColor,
    this.statValueColor,
    this.statLabelColor,
    this.dividerColor,
  });

  /// Colors the verified seal and the avatar gradient fallback.
  final ActivityKind activityKind;
  final String hostName;

  /// Graded avatar photo; omit for the pigment-gradient fallback.
  final String? photoUrl;

  /// Mono meta line, already uppercased (e.g. `HOSTING SINCE FEB 2026`).
  final String? meta;
  final bool verified;
  final List<EventDetailHostStat> stats;
  final String messageLabel;
  final String clubLabel;
  final VoidCallback? onMessage;
  final VoidCallback? onViewClub;

  /// Optional surface-style overrides so the card can sit on the dark spotlight
  /// detail surface; each falls back to the light token when null.
  final Color? surfaceColor;
  final Color? borderColor;
  final Color? nameColor;
  final Color? metaColor;
  final Color? statValueColor;
  final Color? statLabelColor;
  final Color? dividerColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activity = ActivityPalette.resolve(context, activityKind);
    final hasActions = onMessage != null || onViewClub != null;

    return CatchSurface(
      backgroundColor: surfaceColor,
      borderColor: borderColor ?? t.line2,
      radius: CatchRadius.md,
      padding: const EdgeInsets.all(CatchSpacing.micro14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HostAvatar(activity: activity, photoUrl: photoUrl),
              const SizedBox(width: CatchSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            hostName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                CatchTextStyles.name(
                                  context,
                                  color: nameColor,
                                ).copyWith(
                                  fontSize: CatchLayout.eventDetailHostNameSize,
                                ),
                          ),
                        ),
                        if (verified) ...[
                          const SizedBox(width: CatchSpacing.micro6),
                          Icon(
                            CatchIcons.sealCheck,
                            size: CatchLayout.eventDetailHostSealSize,
                            color: activity.accent,
                          ),
                        ],
                      ],
                    ),
                    if (meta != null && meta!.isNotEmpty) ...[
                      const SizedBox(height: CatchSpacing.s1),
                      Text(
                        meta!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.monoLabelS(
                          context,
                          color: metaColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: CatchSpacing.s3),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: dividerColor ?? t.line)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: CatchSpacing.s3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final stat in stats)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stat.value,
                              style:
                                  CatchTextStyles.numericLarge(
                                    context,
                                    color: statValueColor,
                                  ).copyWith(
                                    fontSize: CatchLayout
                                        .eventDetailHostStatValueSize,
                                  ),
                            ),
                            const SizedBox(height: CatchSpacing.s1),
                            Text(
                              stat.label.toUpperCase(),
                              style:
                                  CatchTextStyles.monoLabel(
                                    context,
                                    color: statLabelColor ?? t.ink3,
                                  ).copyWith(
                                    fontSize: CatchLayout
                                        .eventDetailHostStatLabelSize,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (hasActions) ...[
            const SizedBox(height: CatchSpacing.s3),
            Row(
              children: [
                if (onMessage != null)
                  Expanded(
                    child: CatchButton(
                      label: messageLabel,
                      onPressed: onMessage,
                      variant: CatchButtonVariant.secondary,
                      size: CatchButtonSize.sm,
                      fullWidth: true,
                      icon: Icon(CatchIcons.chatCircle),
                    ),
                  ),
                if (onMessage != null && onViewClub != null)
                  const SizedBox(width: CatchSpacing.s2),
                if (onViewClub != null)
                  Expanded(
                    child: CatchButton(
                      label: clubLabel,
                      onPressed: onViewClub,
                      variant: CatchButtonVariant.secondary,
                      size: CatchButtonSize.sm,
                      fullWidth: true,
                      icon: Icon(CatchIcons.arrowUpRight),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// The 46px host avatar — a graded photo over the activity-pigment gradient,
/// or the bare gradient when no photo is supplied.
class HostAvatar extends StatelessWidget {
  const HostAvatar({
    super.key,
    required this.activity,
    this.photoUrl,
  });

  final CatchActivity activity;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    return SizedBox.square(
      dimension: CatchLayout.eventDetailHostAvatarExtent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            transform: const GradientRotation(150 * math.pi / 180),
            colors: [activity.accent, activity.deep],
          ),
        ),
        child: url == null || url.isEmpty
            ? null
            : ClipOval(child: CatchGradedImage(child: CatchNetworkImage(url))),
      ),
    );
  }
}
