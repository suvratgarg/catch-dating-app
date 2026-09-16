part of 'event_success_room_map.dart';

class EventSuccessAttendeeSpatialRow extends StatelessWidget {
  const EventSuccessAttendeeSpatialRow({
    super.key,
    required this.assignment,
    required this.profile,
    required this.selected,
    required this.pending,
    required this.canDrag,
    required this.onSelect,
  });
  final EventSuccessAssignment assignment;
  final PublicProfile? profile;
  final bool selected;
  final bool pending;
  final bool canDrag;
  final Future<void> Function(EventSuccessAssignment assignment) onSelect;
  @override
  Widget build(BuildContext context) {
    final row = CatchSection.containedRows(
      children: [
        CatchField.navigate(
          onActivate: () => unawaited(onSelect(assignment)),
          states: {
            if (pending) WidgetState.disabled,
            if (selected) WidgetState.selected,
          },
          content: CatchPersonLayout(
            name: profile?.name ?? assignment.displayTitle,
            imageUrl: profile?.primaryPhotoThumbnailUrl,
            supportingText: assignment.layoutUnitId,
            badges: [
              if (!(assignment.layoutUnitId == null))
                CatchRowBadge(
                  label:
                      assignment.confirmedLayoutUnitId ==
                          assignment.layoutUnitId
                      ? context.l10n.eventSuccessRoomMapConfirmed
                      : context.l10n.eventSuccessRoomMapAssigned,
                  tone:
                      assignment.confirmedLayoutUnitId ==
                          assignment.layoutUnitId
                      ? CatchBadgeTone.success
                      : CatchBadgeTone.brand,
                ),
            ],
          ),
        ),
      ],
    );
    if (!canDrag || !selected) return row;
    return Draggable<String>(
      data: assignment.uid,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: CatchLayout.maxContentWidth, child: row),
      ),
      childWhenDragging: Opacity(
        opacity: CatchOpacity.disabledControl,
        child: row,
      ),
      child: row,
    );
  }
}
