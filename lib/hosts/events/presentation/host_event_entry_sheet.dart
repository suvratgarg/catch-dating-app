import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

Future<HostEventEntryIntent?> showHostEventEntrySheet({
  required BuildContext context,
  required HostEventEntryState state,
}) {
  assert(state.hasOrganizer, 'Event entry requires an organizer.');
  return showCatchBottomSheet<HostEventEntryIntent>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(CatchRadius.lg)),
    ),
    builder: (sheetContext) => HostEventEntrySheet(state: state),
  );
}

class HostEventEntrySheet extends StatelessWidget {
  const HostEventEntrySheet({super.key, required this.state});

  final HostEventEntryState state;

  @override
  Widget build(BuildContext context) {
    return CatchBottomSheetScaffold(
      key: const ValueKey<String>('host-event-entry-sheet'),
      title: context.l10n.hostsHostEventsListLabelNewEvent,
      subtitle:
          context.l10n.hostsHostEventEntrySheetSubtitleChooseHowYouWantToStart,
      child: CatchSection.containedFieldGroups(
        groups: [
          if (state.continueIntents.isNotEmpty)
            CatchSectionFieldGroup(
              title:
                  context.l10n.hostsHostEventEntrySheetSectionContinueExisting,
              children: [
                for (final intent in state.continueIntents)
                  _HostEventEntryRow(
                    intent: intent,
                    state: state,
                    onTap: () => Navigator.of(context).pop(intent),
                  ),
              ],
            ),
          CatchSectionFieldGroup(
            title: context.l10n.hostsHostEventEntrySheetSectionStartNew,
            children: [
              for (final intent in state.startIntents)
                _HostEventEntryRow(
                  intent: intent,
                  state: state,
                  onTap: () => Navigator.of(context).pop(intent),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HostEventEntryRow extends StatelessWidget {
  const _HostEventEntryRow({
    required this.intent,
    required this.state,
    required this.onTap,
  });

  final HostEventEntryIntent intent;
  final HostEventEntryState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CatchFieldLanes.single(
      child: CatchField.action(
        key: ValueKey<String>('host-event-entry-${intent.name}'),
        title: _title(context),
        body: _body(context),
        icon: _icon,
        emphasis: CatchFieldEmphasis.title,
        onTap: onTap,
      ),
    );
  }

  String _title(BuildContext context) => switch (intent) {
    HostEventEntryIntent.resumeDraft =>
      context.l10n.hostsHostEventEntrySheetTitleContinueDraft,
    HostEventEntryIntent.repeatLastEvent =>
      context.l10n.hostsHostEventEntrySheetTitleRepeatLastEvent,
    HostEventEntryIntent.createWithCatchBookings =>
      context.l10n.hostsHostEventEntrySheetTitleSellTicketsWithCatch,
    HostEventEntryIntent.createFromGuestList =>
      context.l10n.hostsHostEventsListLabelUseGuestList,
  };

  String _body(BuildContext context) => switch (intent) {
    HostEventEntryIntent.resumeDraft when state.hasMultipleDrafts =>
      context.l10n.hostsHostEventEntrySheetBodySavedDraftCount(
        count: state.drafts.length,
      ),
    HostEventEntryIntent.resumeDraft => state.mostRecentDraft?.summary ?? '',
    HostEventEntryIntent.repeatLastEvent =>
      context.l10n.hostsHostEventEntrySheetBodyReuseEventSetup(
        eventTitle: state.repeatSource?.title ?? '',
      ),
    HostEventEntryIntent.createWithCatchBookings =>
      context.l10n.hostsHostEventEntrySheetBodyTicketsWaitlistAndPayments,
    HostEventEntryIntent.createFromGuestList =>
      context.l10n.hostsHostEventEntrySheetBodyImportCsvOrXlsx,
  };

  IconData get _icon => switch (intent) {
    HostEventEntryIntent.resumeDraft => CatchIcons.editNoteRounded,
    HostEventEntryIntent.repeatLastEvent => CatchIcons.refresh,
    HostEventEntryIntent.createWithCatchBookings =>
      CatchIcons.confirmationNumberOutlined,
    HostEventEntryIntent.createFromGuestList => CatchIcons.cloudUploadOutlined,
  };
}
