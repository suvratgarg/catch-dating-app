import 'dart:math';

import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_checkpoint.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// The immutable departure remains the denominator, including missing records.
class EventAssistanceCheckpointRosterSection extends StatefulWidget {
  const EventAssistanceCheckpointRosterSection({
    super.key,
    required this.members,
    required this.names,
    required this.selectedIds,
    required this.onChanged,
    this.enabled = true,
  });
  final List<AssistanceCheckpointMember> members;
  final Map<String, String> names;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;
  final bool enabled;
  @override
  State<EventAssistanceCheckpointRosterSection> createState() =>
      _EventAssistanceCheckpointRosterSectionState();
}

class _EventAssistanceCheckpointRosterSectionState
    extends State<EventAssistanceCheckpointRosterSection> {
  String _search = '';
  int _page = 0;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final matches = widget.members
        .where(
          (m) =>
              (widget.names[m.attendeeId] ??
                      l10n.eventAssistanceCheckpointUnknownGuest)
                  .toLowerCase()
                  .contains(_search.trim().toLowerCase()),
        )
        .toList();
    final page = min(_page, max(0, (matches.length - 1) ~/ 12));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchSearchField.expanded(
          copy: catchSearchFieldCopy(l10n),
          value: _search,
          placeholder: l10n.eventAssistanceDepartureSearch,
          contractExemption:
              'Local search of the reviewed original departure roster.',
          onChanged: (value) => setState(() {
            _search = value;
            _page = 0;
          }),
        ),
        if (matches.isEmpty) ...[
          gapH8,
          Text(l10n.eventAssistanceDepartureNoGuests),
        ],
        for (final member in matches.skip(page * 12).take(12))
          EventAssistanceCheckpointGuestRow(
            key: ValueKey('checkpoint.guest.${member.attendeeId}'),
            member: member,
            name: widget.names[member.attendeeId],
            selected: widget.selectedIds.contains(member.attendeeId),
            enabled:
                widget.enabled &&
                widget.names.containsKey(member.attendeeId) &&
                (member.canAddObservation || member.accountedFor),
            onTap: () {
              final next = {...widget.selectedIds};
              if (!next.remove(member.attendeeId)) next.add(member.attendeeId);
              widget.onChanged(next);
            },
          ),
        if (matches.length > 12)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              CatchButton(
                label: l10n.eventAssistanceDeparturePreviousPeople,
                variant: CatchButtonVariant.ghost,
                onPressed: page == 0
                    ? null
                    : () => setState(() => _page = page - 1),
              ),
              CatchButton(
                label: l10n.eventAssistanceDepartureNextPeople,
                variant: CatchButtonVariant.ghost,
                onPressed: (page + 1) * 12 >= matches.length
                    ? null
                    : () => setState(() => _page = page + 1),
              ),
            ],
          ),
      ],
    );
  }
}

class EventAssistanceCheckpointGuestRow extends StatelessWidget {
  const EventAssistanceCheckpointGuestRow({
    super.key,
    required this.member,
    required this.name,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });
  final AssistanceCheckpointMember member;
  final String? name;
  final bool selected, enabled;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = name ?? l10n.eventAssistanceCheckpointUnknownGuest;
    final detail = name == null
        ? l10n.eventAssistanceCheckpointUnknownGuestBody
        : !member.canAddObservation
        ? l10n.eventAssistanceCheckpointVisitChanged
        : member.accountedFor
        ? selected
              ? l10n.eventAssistanceCheckpointEarlierObservation
              : l10n.eventAssistanceCheckpointRemovingObservation
        : selected
        ? l10n.eventAssistanceCheckpointSelectedObservation
        : l10n.eventAssistanceCheckpointNotObserved;
    return Semantics(
      container: true,
      excludeSemantics: true,
      checked: selected,
      enabled: enabled,
      label: '$label. $detail',
      onTap: enabled ? onTap : null,
      child: CatchRowPressSurface(
        semanticButton: false,
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(selected ? CatchIcons.checkCircle : CatchIcons.circle),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: CatchTextStyles.labelL(context)),
                    gapH4,
                    Text(detail, style: CatchTextStyles.supporting(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
