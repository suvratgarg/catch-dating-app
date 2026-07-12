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
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_graded_image.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/event_detail_display_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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
    final cells = _ticketStubCells(event, context.l10n);

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
                const CatchDivider.section(),
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
    final hints = _hintsFor(event, context.l10n);
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
    final steps = _itineraryFor(event, context.l10n);

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
        ? context.l10n.eventsEventDetailDesignPrimitivesVisiblecopyPinReady
        : context
              .l10n
              .eventsEventDetailDesignPrimitivesVisiblecopyPinDropsMorningOf;

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
                        child: MapPill(text: event.locationName, color: t.ink),
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
    final rows = _mechanismsFor(event, context.l10n);
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
              context.l10n.eventsEventDetailDesignPrimitivesTextEventPhotos,
              style: CatchTextStyles.monoLabelS(context, color: t.ink),
            ),
            const Spacer(),
            Text(
              context.l10n.eventsEventDetailDesignPrimitivesTextLengthUploaded(
                length: event.eventPhotos.length,
              ),
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

class TicketStubCellData {
  const TicketStubCellData({
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

  final TicketStubCellData cell;
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
                      style: CatchTextStyles.numericMeta(
                        context,
                        color: t.ink2,
                      ),
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
    return Column(
      children: [
        for (var index = 0; index < itemCount; index++) ...[
          if (index > 0) CatchDivider.fieldRow(indent: 0, color: dividerColor),
          itemBuilder(context, index),
        ],
      ],
    );
  }
}

class ItineraryStep {
  const ItineraryStep({
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

  final ItineraryStep step;
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
  const MapPill({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: CatchTokens.editorialWhite.withValues(
        alpha: CatchOpacity.overlayPillFill,
      ),
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

List<TicketStubCellData> _ticketStubCells(Event event, AppLocalizations l10n) {
  final locationDetail = event.locationNotes;
  return [
    TicketStubCellData(
      label: l10n.eventsEventDetailDesignPrimitivesLabelWhen,
      value: event.shortDateLabel,
      detail: event.compactTimeRangeLabel,
      icon: CatchIcons.calendarAdd,
    ),
    TicketStubCellData(
      label: l10n.eventsEventDetailDesignPrimitivesLabelWhere,
      value: event.locationName,
      detail: locationDetail == null || locationDetail.isEmpty
          ? null
          : locationDetail,
    ),
    TicketStubCellData(
      label: _levelLabelFor(event.activityKind, l10n),
      value: event.pace.label,
      detail: event.activitySummaryLabel,
    ),
  ];
}

List<String> _hintsFor(Event event, AppLocalizations l10n) {
  final remaining = event.spotsRemaining;
  final capacityHint = remaining == 0
      ? l10n.eventsEventDetailDesignPrimitivesVisiblecopyThisEventIsCurrently
      : remaining <= 3
      ? l10n.eventsEventDetailDesignPrimitivesVisiblecopyOnlyRemainingValue2Left(
          remaining: remaining,
          value2: remaining == 1
              ? l10n.eventsEventDetailDesignPrimitivesVisiblecopySpot
              : l10n.eventsEventDetailDesignPrimitivesVisiblecopySpots,
        )
      : l10n.eventsEventDetailDesignPrimitivesVisiblecopySpotslabelSpotsAreAlready(
          spotsLabel: event.spotsLabel,
        );
  return [
    capacityHint,
    _interactionHint(event.eventFormat.interactionModel, l10n),
  ];
}

List<ItineraryStep> _itineraryFor(Event event, AppLocalizations l10n) {
  final warmupTime = event.startTime.add(const Duration(minutes: 15));
  return [
    ItineraryStep(
      time: EventFormatters.time(event.startTime),
      title: l10n.eventsEventDetailDesignPrimitivesTitleGatherAtLocationname(
        locationName: event.locationName,
      ),
      detail: l10n.eventsEventDetailDesignPrimitivesDetailQuickHellosHostCheck,
    ),
    ItineraryStep(
      time: EventFormatters.time(warmupTime),
      title: event.eventFormat.label,
      detail: _activityPlanDetail(event, l10n),
    ),
    ItineraryStep(
      time: EventFormatters.time(event.endTime),
      title: l10n.eventsEventDetailDesignPrimitivesTitleWrapUp,
      detail: l10n
          .eventsEventDetailDesignPrimitivesDetailAttendeesCanLingerNaturally,
    ),
  ];
}

List<_MechanismRow> _mechanismsFor(Event event, AppLocalizations l10n) {
  final policy = event.effectiveEventPolicy;
  final rows = <_MechanismRow>[
    _MechanismRow(
      icon: policy.admissionPolicy.manualApprovalRequired
          ? CatchIcons.pendingActionsOutlined
          : CatchIcons.groupOutlined,
      title: _admissionTitle(policy.admissionPolicy, l10n),
      detail: _admissionSummary(policy.admissionPolicy, l10n),
    ),
  ];

  if (policy.admissionPolicy.waitlistPolicy.isEnabled || event.isFull) {
    rows.add(
      _MechanismRow(
        icon: CatchIcons.pendingActionsOutlined,
        title: l10n.eventsEventDetailDesignPrimitivesTitleIfItFillsA,
        detail: l10n.eventsEventDetailDesignPrimitivesDetailSpotsFreeUpIn,
      ),
    );
  }

  rows.add(
    _MechanismRow(
      icon: CatchIcons.receiptLongOutlined,
      title: l10n.eventsEventDetailDesignPrimitivesTitleTitleCancellation(
        title: policy.cancellationPolicy.title,
      ),
      detail: policy.cancellationPolicy.attendeeSummary,
    ),
  );

  return rows;
}

String _interactionHint(EventInteractionModel model, AppLocalizations l10n) {
  return switch (model) {
    EventInteractionModel.pacePods =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyTheFormatKeepsThe,
    EventInteractionModel.pairedRotations =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyRotationsGiveYouNatural,
    EventInteractionModel.teamRotations =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyTeamStructureCreatesLow,
    EventInteractionModel.seatedTable =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyASeatedFormatAnd,
    EventInteractionModel.freeFormMixer =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyHostNudgesKeepThe,
    EventInteractionModel.hostLedProgram =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyTheHostRunsThe,
    EventInteractionModel.openFormat =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyTheHostShapesThe,
  };
}

String _activityPlanDetail(Event event, AppLocalizations l10n) {
  return switch (event.eventFormat.interactionModel) {
    EventInteractionModel.pacePods =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyDistancekmAtATolowercase(
        distanceKm: EventFormatters.distanceKm(event.distanceKm),
        toLowerCase: event.pace.label.toLowerCase(),
      ),
    EventInteractionModel.pairedRotations =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyPairedOrCourtBased,
    EventInteractionModel.teamRotations =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyHostLedTeamsAnd,
    EventInteractionModel.seatedTable =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyATableLedFormat,
    EventInteractionModel.freeFormMixer =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyALooserMixerWith,
    EventInteractionModel.hostLedProgram =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyAHostLedActivity,
    EventInteractionModel.openFormat =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyTheHostAdaptsThe,
  };
}

String _levelLabelFor(ActivityKind activityKind, AppLocalizations l10n) {
  return switch (activityKind) {
    ActivityKind.socialRun ||
    ActivityKind.running ||
    ActivityKind.walking ||
    ActivityKind.cycling =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyPace,
    ActivityKind.pickleball ||
    ActivityKind.padel ||
    ActivityKind.tennis ||
    ActivityKind.badminton =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopySkill,
    ActivityKind.spinClass ||
    ActivityKind.yoga ||
    ActivityKind.strengthTraining =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyIntensity,
    ActivityKind.pubQuiz ||
    ActivityKind.barCrawl ||
    ActivityKind.dinner ||
    ActivityKind.singlesMixer ||
    ActivityKind.openActivity =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyEnergy,
  };
}

String _admissionTitle(EventAdmissionPolicy policy, AppLocalizations l10n) {
  return switch (policy.format) {
    EventAdmissionFormat.open =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyOpenSignUp,
    EventAdmissionFormat.inviteOnly =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyInviteOnly,
    EventAdmissionFormat.manualApproval =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyHostApproval,
    EventAdmissionFormat.fixedCohortCaps =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyCohortCaps,
    EventAdmissionFormat.balancedRatio =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyBalancedSingles,
    EventAdmissionFormat.membersOnly =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyMembersOnly,
  };
}

String _admissionSummary(EventAdmissionPolicy policy, AppLocalizations l10n) {
  return switch (policy.format) {
    EventAdmissionFormat.open =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyNoApprovalNeededRsvp(
        capacityLimit: policy.capacityLimit,
      ),
    EventAdmissionFormat.fixedCohortCaps =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyBookWithinTotalCapacity,
    EventAdmissionFormat.balancedRatio =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyStraightMenAndWomen,
    EventAdmissionFormat.inviteOnly =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyOnlyAttendeesWithThe,
    EventAdmissionFormat.manualApproval =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyRequestASpotFirst,
    EventAdmissionFormat.membersOnly =>
      l10n.eventsEventDetailDesignPrimitivesVisiblecopyOnlyActiveClubMembers,
  };
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
  const HostAvatar({super.key, required this.activity, this.photoUrl});

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
