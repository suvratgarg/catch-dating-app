import 'dart:math';

import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_departure_draft.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Searchable, bounded observation choices. Nothing is selected by attendance.
class EventAssistanceDepartureRosterSection extends StatefulWidget {
  const EventAssistanceDepartureRosterSection({
    super.key,
    required this.guests,
    required this.selectedIds,
    required this.onChanged,
  });
  final List<EventAssistanceDepartureGuest> guests;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;
  @override
  State<EventAssistanceDepartureRosterSection> createState() =>
      _EventAssistanceDepartureRosterSectionState();
}

class _EventAssistanceDepartureRosterSectionState
    extends State<EventAssistanceDepartureRosterSection> {
  String _search = '';
  int _page = 0;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final matches = widget.guests
        .where(
          (g) => g.name.toLowerCase().contains(_search.trim().toLowerCase()),
        )
        .toList();
    final page = min(_page, max(0, (matches.length - 1) ~/ 12));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.eventAssistanceDepartureRosterBody,
          style: CatchTextStyles.supporting(context),
        ),
        gapH8,
        Text(
          l10n.eventAssistanceDepartureSelected(
            count: widget.selectedIds.length,
          ),
          style: CatchTextStyles.supporting(context),
        ),
        gapH8,
        CatchSearchField.expanded(
          copy: catchSearchFieldCopy(l10n),
          value: _search,
          placeholder: l10n.eventAssistanceDepartureSearch,
          contractExemption:
              'Local filtering of the already authorized departure roster; no query or command is sent.',
          onChanged: (value) => setState(() {
            _search = value;
            _page = 0;
          }),
        ),
        if (matches.isEmpty) ...[
          gapH8,
          Text(
            l10n.eventAssistanceDepartureNoGuests,
            style: CatchTextStyles.supporting(context),
          ),
        ],
        for (final guest in matches.skip(page * 12).take(12))
          Semantics(
            container: true,
            excludeSemantics: true,
            checked: widget.selectedIds.contains(guest.id),
            enabled:
                widget.selectedIds.length < 1000 ||
                widget.selectedIds.contains(guest.id),
            label: guest.name,
            onTap:
                widget.selectedIds.length < 1000 ||
                    widget.selectedIds.contains(guest.id)
                ? () => _toggle(guest.id)
                : null,
            child: CatchRowPressSurface(
              key: ValueKey('departure.guest.${guest.id}'),
              semanticButton: false,
              onTap:
                  widget.selectedIds.length < 1000 ||
                      widget.selectedIds.contains(guest.id)
                  ? () => _toggle(guest.id)
                  : null,
              child: Padding(
                padding: CatchInsets.contentVertical,
                child: Row(
                  children: [
                    Icon(
                      widget.selectedIds.contains(guest.id)
                          ? CatchIcons.checkCircle
                          : CatchIcons.circle,
                    ),
                    gapW12,
                    Expanded(
                      child: Text(
                        guest.name,
                        style: CatchTextStyles.labelL(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (matches.length > 12)
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
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

  void _toggle(String id) {
    final selected = {...widget.selectedIds};
    if (!selected.remove(id)) {
      if (selected.length >= 1000) return;
      selected.add(id);
    }
    widget.onChanged(selected);
  }
}
