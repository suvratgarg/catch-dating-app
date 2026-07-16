import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/event_detail_information_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/locations/shared/catch_map_preview.dart';
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
    this.enableNetworkTiles = true,
  });

  final Event event;
  final VoidCallback? onTap;
  final Color? surfaceColor;
  final Color? borderColor;
  final bool enableNetworkTiles;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final canOpen = onTap != null;
    final coordinate = LocationCoordinate(
      event.effectiveStartingPointLat,
      event.effectiveStartingPointLng,
    );
    final trailingLabel =
        context.l10n.eventsEventDetailDesignPrimitivesActionViewMap;

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
              color: surfaceColor ?? t.surface,
              border: Border.all(color: borderColor ?? t.line),
              borderRadius: BorderRadius.circular(CatchRadius.md),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CatchRadius.md - 1),
              child: Column(
                children: [
                  Expanded(
                    child: CatchMapPreview(
                      coordinate: coordinate,
                      fallbackLabel:
                          context.l10n.eventsEventPinsMapLabelEventMapPreview,
                      enableNetworkTiles: enableNetworkTiles,
                    ),
                  ),
                  CatchDivider.fieldRow(indent: 0, color: borderColor),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CatchSpacing.s3,
                      vertical: CatchSpacing.s2,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.locationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CatchTextStyles.labelL(
                              context,
                              color: t.ink,
                            ),
                          ),
                        ),
                        gapW8,
                        Text(
                          trailingLabel.toUpperCase(),
                          maxLines: 1,
                          style: CatchTextStyles.monoLabelS(
                            context,
                            color: t.ink2,
                          ),
                        ),
                        if (canOpen) ...[
                          gapW4,
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
      ),
    );
  }
}

class EventDetailMechanismList extends StatelessWidget {
  const EventDetailMechanismList({
    super.key,
    required this.rows,
    required this.activityKind,
    this.dividerColor,
    this.titleColor,
    this.bodyColor,
  });

  final List<EventDetailFactRow> rows;
  final ActivityKind activityKind;
  final Color? dividerColor;
  final Color? titleColor;
  final Color? bodyColor;

  @override
  Widget build(BuildContext context) {
    return EventDetailFactList.stacked(
      rows: rows,
      activityKind: activityKind,
      dividerColor: dividerColor,
      titleColor: titleColor,
      bodyColor: bodyColor,
    );
  }
}

class EventDetailGoodToKnowList extends StatelessWidget {
  const EventDetailGoodToKnowList({
    super.key,
    required this.rows,
    required this.activityKind,
    this.dividerColor,
    this.titleColor,
    this.bodyColor,
  });

  final List<EventDetailFactRow> rows;
  final ActivityKind activityKind;
  final Color? dividerColor;
  final Color? titleColor;
  final Color? bodyColor;

  @override
  Widget build(BuildContext context) {
    return EventDetailFactList.inline(
      rows: rows,
      activityKind: activityKind,
      dividerColor: dividerColor,
      titleColor: titleColor,
      bodyColor: bodyColor,
    );
  }
}

/// Flat Event Detail fact rows with structural stacked and inline modes.
///
/// Callers supply only rows resolved by [EventDetailInformationState]. The
/// named constructors keep typography and icon treatment tied to the section
/// role rather than exposing independent visual switches.
class EventDetailFactList extends StatelessWidget {
  const EventDetailFactList.stacked({
    super.key,
    required this.rows,
    required this.activityKind,
    this.dividerColor,
    this.titleColor,
    this.bodyColor,
  }) : _inline = false,
       _useActivityColor = true;

  const EventDetailFactList.inline({
    super.key,
    required this.rows,
    required this.activityKind,
    this.dividerColor,
    this.titleColor,
    this.bodyColor,
  }) : _inline = true,
       _useActivityColor = false;

  final List<EventDetailFactRow> rows;
  final ActivityKind activityKind;
  final Color? dividerColor;
  final Color? titleColor;
  final Color? bodyColor;
  final bool _inline;
  final bool _useActivityColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activity = ActivityPalette.resolve(context, activityKind);

    return HairlineList(
      itemCount: rows.length,
      dividerColor: dividerColor,
      itemBuilder: (context, index) {
        final row = rows[index];
        final resolvedTitleColor = titleColor ?? t.ink;
        final resolvedBodyColor = bodyColor ?? t.ink2;
        final iconColor = _useActivityColor ? activity.deep : resolvedBodyColor;

        return Padding(
          padding: EdgeInsets.only(
            top: index == 0 ? 0 : CatchSpacing.s3,
            bottom: index == rows.length - 1 ? 0 : CatchSpacing.s3,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: CatchIcon.row,
                child: Icon(
                  _eventDetailFactIcon(row.icon, activityIcon: activity.glyph),
                  size: CatchIcon.md,
                  color: iconColor,
                ),
              ),
              gapW8,
              Expanded(
                child: _inline
                    ? Text.rich(
                        TextSpan(
                          style: CatchTextStyles.supporting(
                            context,
                            color: resolvedBodyColor,
                          ),
                          children: [
                            TextSpan(
                              text: _inlineFactLead(row.title),
                              style: CatchTextStyles.fieldRowTitle(
                                context,
                                color: resolvedTitleColor,
                              ),
                            ),
                            TextSpan(text: row.body),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.title,
                            style: CatchTextStyles.fieldRowTitle(
                              context,
                              color: resolvedTitleColor,
                            ),
                          ),
                          gapH2,
                          Text(
                            row.body,
                            style: CatchTextStyles.supporting(
                              context,
                              color: resolvedBodyColor,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _inlineFactLead(String title) {
  final trimmed = title.trim();
  final hasTerminalPunctuation =
      trimmed.endsWith('.') || trimmed.endsWith('?') || trimmed.endsWith('!');
  return '$trimmed${hasTerminalPunctuation ? ' ' : '. '}';
}

IconData _eventDetailFactIcon(
  EventDetailFactIcon icon, {
  required IconData activityIcon,
}) {
  return switch (icon) {
    EventDetailFactIcon.openSignup => CatchIcons.personAddAlt1Outlined,
    EventDetailFactIcon.inviteOnly => CatchIcons.keyOutlined,
    EventDetailFactIcon.hostApproval => CatchIcons.personSearchOutlined,
    EventDetailFactIcon.cohortCaps => CatchIcons.groupsOutlined,
    EventDetailFactIcon.balancedBooking => CatchIcons.balanceOutlined,
    EventDetailFactIcon.membersOnly => CatchIcons.cardMembershipOutlined,
    EventDetailFactIcon.waitlist => CatchIcons.hourglassEmptyRounded,
    EventDetailFactIcon.pricing => CatchIcons.priceChangeOutlined,
    EventDetailFactIcon.requirements => CatchIcons.ruleOutlined,
    EventDetailFactIcon.activity => activityIcon,
    EventDetailFactIcon.attendance => CatchIcons.qrCode2Outlined,
    EventDetailFactIcon.cancellation => CatchIcons.refreshRounded,
  };
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
