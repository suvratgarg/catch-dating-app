import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:catch_dating_app/programs/presentation/program_events_controller.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// One identifiable program destination. Its constituent events remain in the
/// program workspace rather than appearing as unrelated timeline duplicates.
class ProgramEventsRow extends StatelessWidget {
  const ProgramEventsRow({
    super.key,
    required this.program,
    required this.now,
    required this.onOpen,
    required this.onLifecycle,
    this.pending = false,
  });

  final OrganizerProgramListRow program;
  final DateTime now;
  final VoidCallback onOpen;
  final ValueChanged<ProgramLifecycleAction> onLifecycle;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final startsAt = program.startsAt;
    final endsAt = program.endsAt;
    return CatchField.navigate(
      key: ValueKey('host-program-row-${program.programId}'),
      onActivate: onOpen,
      content: CatchRecordLayout(
        title: program.title,
        icon: CatchIcons.calendarMonthOutlined,
        metadata: l10n.programsEventRowLabel,
        facts: [
          if (startsAt != null && endsAt != null)
            l10n.programsEventDateRange(
              start: AppTimeFormatters.shortDate(startsAt),
              end: AppTimeFormatters.shortDate(endsAt),
            ),
          program.functionCount == null
              ? l10n.programsEventCountUnavailable
              : l10n.programsEventCount(count: program.functionCount!),
          if (program.isArchived) l10n.programsEventArchived,
        ],
        description: program.anonymizedAt != null
            ? l10n.programsListAnonymized
            : program.isArchived && program.anonymizeAt != null
            ? l10n.programsListAnonymizesOn(
                date: AppTimeFormatters.shortDate(program.anonymizeAt!),
              )
            : null,
      ),
      secondaryAction: CatchFieldSecondaryAction.menu<ProgramLifecycleAction>(
        label: l10n.programsListRowActions,
        items: [
          if (program.isArchived)
            CatchActionMenuItem(
              value: ProgramLifecycleAction.unarchive,
              label: l10n.programsListUnarchiveAction,
              icon: CatchIcons.undoRounded,
              enabled: !pending && program.canUnarchiveAt(now),
              sublabel: program.anonymizedAt != null
                  ? l10n.programsListAnonymized
                  : program.canUnarchiveAt(now)
                  ? null
                  : l10n.programsListRestoreWindowExpiredReason,
            )
          else
            CatchActionMenuItem(
              value: ProgramLifecycleAction.archive,
              label: l10n.programsListArchiveAction,
              icon: CatchIcons.archiveOutlined,
              enabled: !pending,
            ),
        ],
        onSelected: onLifecycle,
      ),
    );
  }
}
