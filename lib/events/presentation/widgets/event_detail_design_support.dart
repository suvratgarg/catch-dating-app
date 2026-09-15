part of 'event_detail_design_primitives.dart';

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

List<ItineraryStep> _itineraryFor(Event event) {
  return event.itinerary
      .map(
        (entry) => ItineraryStep(
          time: EventFormatters.time(entry.startsAt(event.startTime)),
          title: entry.title,
          detail: _itineraryDetail(entry.description, entry.location?.name),
        ),
      )
      .toList(growable: false);
}

String? _itineraryDetail(String? description, String? locationName) {
  final location = locationName?.trim();
  final detail = description?.trim();
  final parts = <String>[
    if (location != null && location.isNotEmpty) location,
    if (detail != null && detail.isNotEmpty) detail,
  ];
  return parts.isEmpty ? null : parts.join(' · ');
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
