import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/programs/data/program_setup_repository.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:catch_dating_app/programs/presentation/program_workspace_controller.dart';
import 'package:catch_dating_app/routing/route_contract.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Organizer program workspace — program header, schedule day rail and
/// function management. Guests/team/import live on pushed sibling routes so
/// the schedule stays the focus here.
class ProgramWorkspaceScreen extends ConsumerWidget {
  const ProgramWorkspaceScreen({super.key, required this.programId});

  final String programId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(organizerProgramDetailProvider(programId));
    return CatchAsyncBoundary<OrganizerProgramDetail>(
      retainDataOn: const {},
      value: detailAsync,
      onRetry: () => ref.invalidate(organizerProgramDetailProvider(programId)),
      loadingBuilder: (_) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
          title: context.l10n.programsWorkspaceTitle,
          emphasis: scrolledUnder
              ? CatchTopBarEmphasis.divided
              : CatchTopBarEmphasis.plain,
          navigation: const CatchTopBarNavigation(
            mode: CatchTopBarNavigationMode.back,
          ),
        ),
        body: const CatchRouteBody.standardViewport(
          child: CatchStateViewport.loading(accountForBottomOverlay: false),
        ),
      ),
      errorBuilder: (_, error, _, onBoundaryRetry) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
          title: context.l10n.programsWorkspaceTitle,
          emphasis: scrolledUnder
              ? CatchTopBarEmphasis.divided
              : CatchTopBarEmphasis.plain,
          navigation: const CatchTopBarNavigation(
            mode: CatchTopBarNavigationMode.back,
          ),
        ),
        body: CatchRouteBody.standardViewport(
          child: CatchLocalizedErrorState(
            error,
            context: AppErrorContext.event,
            onRetry: onBoundaryRetry,
          ),
        ),
      ),
      builder: (context, detail) =>
          ProgramWorkspacePageBody(programDetail: detail),
    );
  }
}

class ProgramWorkspacePageBody extends ConsumerStatefulWidget {
  const ProgramWorkspacePageBody({super.key, required this.programDetail});

  final OrganizerProgramDetail programDetail;

  @override
  ConsumerState<ProgramWorkspacePageBody> createState() =>
      _ProgramWorkspacePageBodyState();
}

class _ProgramWorkspacePageBodyState
    extends ConsumerState<ProgramWorkspacePageBody> {
  int _selectedDayIndex = 0;

  List<DateTime> get _days {
    final days = <DateTime>{};
    for (final fn in widget.programDetail.functions) {
      days.add(DateUtils.dateOnly(fn.startsAt));
    }
    final sorted = days.toList()..sort();
    return sorted;
  }

  List<OrganizerFunctionDetail> _functionsOn(DateTime day) =>
      widget.programDetail.functions
          .where((fn) => DateUtils.isSameDay(fn.startsAt, day))
          .toList(growable: false)
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

  @override
  Widget build(BuildContext context) {
    final detail = widget.programDetail;
    final program = detail.program;
    final days = _days;
    if (_selectedDayIndex >= days.length && days.isNotEmpty) {
      _selectedDayIndex = 0;
    }
    final selectedDay = days.isEmpty ? null : days[_selectedDayIndex];
    final dayFunctions = selectedDay == null
        ? const <OrganizerFunctionDetail>[]
        : _functionsOn(selectedDay);

    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
        title: context.l10n.programsWorkspaceTitle,
        emphasis: scrolledUnder
            ? CatchTopBarEmphasis.divided
            : CatchTopBarEmphasis.plain,
        navigation: const CatchTopBarNavigation(
          mode: CatchTopBarNavigationMode.back,
        ),
      ),
      body: CatchRouteBody.standardSections(
        sections: [
          CatchSectionListItem(
            child: CatchSection.contained(
              title: program.title,
              subtitle:
                  '${AppTimeFormatters.shortDate(program.startsAt)} – '
                  '${AppTimeFormatters.shortDate(program.endsAt)} · '
                  '${program.timezone}',
              child: Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: [
                  CatchBadge(label: program.kind.name),
                  CatchBadge(
                    label: program.status.name,
                    tone: program.status == ProgramStatus.active
                        ? CatchBadgeTone.success
                        : CatchBadgeTone.neutral,
                  ),
                  CatchBadge(
                    label: context.l10n.programsWorkspaceStatsGuests(
                      count: detail.counts['guests'] ?? 0,
                    ),
                  ),
                  CatchBadge(
                    label: context.l10n.programsWorkspaceStatsHouseholds(
                      count: detail.counts['households'] ?? 0,
                    ),
                  ),
                  CatchBadge(
                    label: context.l10n.programsWorkspaceStatsLegs(
                      count: detail.counts['inboundLegs'] ?? 0,
                    ),
                  ),
                  CatchBadge(
                    label: context.l10n.programsWorkspaceStatsStaff(
                      count: detail.counts['activeStaff'] ?? 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          CatchSectionListItem(
            child: CatchSection.contained(
              title: context.l10n.programsWorkspaceScheduleTitle,
              subtitle: context.l10n.programsWorkspaceScheduleSubtitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (days.length > 1) ...[
                    CatchChoiceInput<int>.segmented(
                      scrollable: true,
                      options: [
                        for (var i = 0; i < days.length; i++)
                          CatchOption(
                            value: i,
                            label: context.l10n.programsWorkspaceDayLabel(
                              index: i + 1,
                              date: AppTimeFormatters.weekdayDayMonth(days[i]),
                            ),
                          ),
                      ],
                      selected: _selectedDayIndex,
                      contractExemption:
                          'Local day-rail filter over the schedule; no payload field is written from the selection.',
                      onChanged: (index) =>
                          setState(() => _selectedDayIndex = index),
                    ),
                    gapH12,
                  ],
                  CatchButton(
                    label: context.l10n.programsWorkspaceFunctionNew,
                    leading: Icon(CatchIcons.addRounded, size: CatchIcon.md),
                    variant: CatchButtonVariant.secondary,
                    onPressed: () => _editFunction(context, null),
                  ),
                  const SizedBox(height: CatchSpacing.s2),
                  if (dayFunctions.isEmpty) ...[
                    gapH16,
                    Text(
                      days.isEmpty
                          ? context.l10n.programsWorkspaceNoFunctions
                          : context.l10n.programsWorkspaceDayEmpty,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    gapH16,
                  ] else
                    for (final fn in dayFunctions)
                      ProgramWorkspaceFunctionTile(
                        function: fn,
                        onEdit: () => _editFunction(context, fn),
                        onInvitations: () => _editInvitations(context, fn),
                      ),
                ],
              ),
            ),
          ),
          CatchSectionListItem(
            child: CatchSection.contained(
              title: context.l10n.programsWorkspaceManageTitle,
              child: Column(
                children: [
                  CatchFieldRow.standard(
                    leading: Icon(CatchIcons.groupsOutlined),
                    body: Text(
                      context.l10n.programsWorkspaceGuestsTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: Icon(CatchIcons.chevronRightRounded),
                    onTap: () => context.pushNamed(
                      Routes.hostProgramGuestsScreen.name,
                      pathParameters: {'programId': program.programId},
                    ),
                  ),
                  CatchFieldRow.standard(
                    leading: Icon(CatchIcons.workOutlineRounded),
                    body: Text(
                      context.l10n.programsWorkspaceTeamTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: Icon(CatchIcons.chevronRightRounded),
                    onTap: () => context.pushNamed(
                      Routes.hostProgramTeamScreen.name,
                      pathParameters: {'programId': program.programId},
                    ),
                  ),
                  CatchFieldRow.standard(
                    leading: Icon(CatchIcons.cloudUploadOutlined),
                    body: Text(
                      context.l10n.programsWorkspaceImportTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: Icon(CatchIcons.chevronRightRounded),
                    onTap: () => context.pushNamed(
                      Routes.hostProgramImportScreen.name,
                      pathParameters: {'programId': program.programId},
                    ),
                  ),
                ],
              ),
            ),
          ),
          CatchSectionListItem(
            child: CatchSection.contained(
              title: context.l10n.programsWorkspaceCommunicationsTitle,
              child: Column(
                children: [
                  CatchFieldRow.standard(
                    leading: Icon(CatchIcons.autoAwesomeOutlined),
                    body: Text(
                      context.l10n.programsWorkspaceMomentsTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: Icon(CatchIcons.chevronRightRounded),
                    onTap: () => context.pushNamed(
                      Routes.hostProgramMomentsScreen.name,
                      pathParameters: {'programId': program.programId},
                      queryParameters: {'title': program.title},
                    ),
                  ),
                  CatchFieldRow.standard(
                    leading: Icon(CatchIcons.forumOutlined),
                    body: Text(
                      context.l10n.programsWorkspaceInboxTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: Icon(CatchIcons.chevronRightRounded),
                    onTap: () => context.pushNamed(
                      Routes.hostInboxScreen.name,
                      queryParameters: {
                        'programId': program.programId,
                        'organizerId': program.organizerId,
                      },
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

  Future<void> _editFunction(
    BuildContext context,
    OrganizerFunctionDetail? existing,
  ) async {
    final draft = await showDialog<ProgramFunctionDraft>(
      context: context,
      builder: (_) => ProgramFunctionEditDialog(existing: existing),
    );
    if (draft == null || !mounted) return;
    await ref
        .read(programWorkspaceControllerProvider.notifier)
        .upsertFunction(
          programId: widget.programDetail.program.programId,
          functionId: existing?.functionId,
          expectedRevision: existing?.revision,
          name: draft.name,
          startsAt: draft.startsAt,
          endsAt: draft.endsAt,
          venueName: draft.venueName,
          venueNotes: draft.venueNotes,
          status: draft.status.name,
        );
    if (!mounted) return;
    ref.invalidate(
      organizerProgramDetailProvider(widget.programDetail.program.programId),
    );
  }

  Future<void> _editInvitations(
    BuildContext context,
    OrganizerFunctionDetail fn,
  ) async {
    var mode = fn.invitationMode;
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => CatchDialog<void>(
          title: context.l10n.programsWorkspaceFunctionInvitations,
          actions: [
            CatchButton(
              label: context.l10n.coreCatchAdaptiveDialogVisiblecopyCancel,
              variant: CatchButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
            CatchButton(
              label: context.l10n.programsWorkspaceFunctionSave,
              onPressed: () => Navigator.of(context).pop(mode),
            ),
          ],
          child: CatchSection.containedFieldRows(
            children: [
              CatchChoiceInput<String>.segmented(
                options: [
                  CatchOption(
                    value: 'allGuests',
                    label: context.l10n.programsGuestsInviteModeAll,
                  ),
                  CatchOption(
                    value: 'selectedGuests',
                    label: context.l10n.programsGuestsInviteModeSelected,
                  ),
                ],
                selected: mode,
                contract: CatchContractConstraints
                    .applyProgramFunctionInvitationsCallablePayloadInvitationMode,
                contractValueBuilder: (value) => value,
                onChanged: (value) => setDialogState(() => mode = value),
              ),
              if (mode == 'selectedGuests') ...[
                gapH12,
                Text(
                  context.l10n.programsGuestsInviteSelectionHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
    if (selected == null || selected == fn.invitationMode || !mounted) return;
    await ref
        .read(programWorkspaceControllerProvider.notifier)
        .applyFunctionInvitations(
          programId: widget.programDetail.program.programId,
          functionId: fn.functionId,
          invitationMode: selected,
          expectedRevision: fn.revision,
        );
    if (!mounted) return;
    ref.invalidate(
      organizerProgramDetailProvider(widget.programDetail.program.programId),
    );
  }
}

class ProgramWorkspaceFunctionTile extends StatelessWidget {
  const ProgramWorkspaceFunctionTile({
    super.key,
    required this.function,
    required this.onEdit,
    required this.onInvitations,
  });

  final OrganizerFunctionDetail function;
  final VoidCallback onEdit;
  final VoidCallback onInvitations;

  @override
  Widget build(BuildContext context) {
    final fn = function;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchFieldRow.standard(
          leading: Icon(CatchIcons.eventAvailable),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fn.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: CatchSpacing.s1),
              Text(
                '${AppTimeFormatters.time(fn.startsAt)} – '
                '${AppTimeFormatters.time(fn.endsAt)} · ${fn.venueName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: CatchSpacing.s2),
              Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: [
                  CatchBadge(
                    label: fn.status.name,
                    tone: fn.status == ProgramFunctionStatus.scheduled
                        ? CatchBadgeTone.brand
                        : CatchBadgeTone.neutral,
                  ),
                  CatchBadge(
                    label: context.l10n.programsWorkspaceInvitations(
                      mode: fn.isSelectedGuests
                          ? context.l10n.programsGuestsInviteModeSelected
                          : context.l10n.programsGuestsInviteModeAll,
                    ),
                  ),
                  if (fn.checkInEnabled)
                    CatchBadge(
                      label: context.l10n.programsWorkspaceCheckedIn(
                        checked: fn.checkedInCount ?? 0,
                        expected: fn.expectedCount ?? 0,
                      ),
                      tone: CatchBadgeTone.success,
                    ),
                  if (fn.dressCode != null && fn.dressCode!.isNotEmpty)
                    CatchBadge(label: fn.dressCode!),
                ],
              ),
              if (fn.instructions != null && fn.instructions!.isNotEmpty) ...[
                gapH8,
                Text(
                  fn.instructions!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              gapH12,
              Wrap(
                spacing: CatchSpacing.s2,
                children: [
                  CatchButton(
                    label: context.l10n.programsWorkspaceFunctionEdit,
                    leading: Icon(CatchIcons.editOutlined, size: CatchIcon.sm),
                    variant: CatchButtonVariant.secondary,
                    size: CatchButtonSize.sm,
                    onPressed: onEdit,
                  ),
                  CatchButton(
                    label: context.l10n.programsWorkspaceFunctionInvitations,
                    leading: Icon(CatchIcons.sendRounded, size: CatchIcon.sm),
                    variant: CatchButtonVariant.secondary,
                    size: CatchButtonSize.sm,
                    onPressed: onInvitations,
                  ),
                ],
              ),
            ],
          ),
        ),
        gapH8,
      ],
    );
  }
}

class ProgramFunctionDraft {
  const ProgramFunctionDraft({
    required this.name,
    required this.startsAt,
    required this.endsAt,
    required this.venueName,
    required this.status,
    this.venueNotes,
  });

  final String name;
  final DateTime startsAt;
  final DateTime endsAt;
  final String venueName;
  final String? venueNotes;
  final ProgramFunctionStatus status;
}

class ProgramFunctionEditDialog extends StatefulWidget {
  const ProgramFunctionEditDialog({super.key, this.existing});

  final OrganizerFunctionDetail? existing;

  @override
  State<ProgramFunctionEditDialog> createState() =>
      _ProgramFunctionEditDialogState();
}

class _ProgramFunctionEditDialogState extends State<ProgramFunctionEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _venueController;
  late final TextEditingController _notesController;
  late ProgramFunctionStatus _status;
  DateTime? _startsAt;
  DateTime? _endsAt;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _venueController = TextEditingController(text: existing?.venueName ?? '');
    _notesController = TextEditingController();
    _status = existing?.status ?? ProgramFunctionStatus.scheduled;
    _startsAt = existing?.startsAt;
    _endsAt = existing?.endsAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final base = isStart ? _startsAt : _endsAt;
    final initial = base ?? DateTime.now();
    final date = await showCatchDatePicker(
      copy: catchDatePickerCopy(context.l10n),
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 2),
      lastDate: DateTime(initial.year + 5),
    );
    if (date == null || !mounted) return;
    final time = await showCatchTimePicker(
      copy: catchTimePickerCopy(context.l10n),
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    setState(() {
      final combined = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (isStart) {
        _startsAt = combined;
        if (_endsAt != null && _endsAt!.isBefore(combined)) {
          _endsAt = combined.add(const Duration(hours: 2));
        }
      } else {
        _endsAt = combined.isBefore(_startsAt ?? combined)
            ? (_startsAt ?? combined).add(const Duration(hours: 2))
            : combined;
      }
    });
  }

  void _submit() {
    final name = _nameController.text.trim();
    final venue = _venueController.text.trim();
    final startsAt = _startsAt;
    final endsAt = _endsAt;
    if (name.isEmpty || venue.isEmpty || startsAt == null || endsAt == null) {
      return;
    }
    Navigator.of(context).pop(
      ProgramFunctionDraft(
        name: name,
        startsAt: startsAt,
        endsAt: endsAt,
        venueName: venue,
        venueNotes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        status: _status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => CatchDialog<void>(
    title: widget.existing == null
        ? context.l10n.programsWorkspaceFunctionNew
        : context.l10n.programsWorkspaceFunctionEdit,
    actions: [
      CatchButton(
        label: context.l10n.coreCatchAdaptiveDialogVisiblecopyCancel,
        variant: CatchButtonVariant.secondary,
        onPressed: () => Navigator.of(context).pop(),
      ),
      CatchButton(
        label: context.l10n.programsWorkspaceFunctionSave,
        onPressed: _submit,
      ),
    ],
    child: CatchSection.containedFieldRows(
      children: [
        CatchField.input(
          copy: catchFieldCopy(context.l10n),
          title: context.l10n.programsWorkspaceFunctionName,
          controller: _nameController,
          contract:
              CatchContractConstraints.upsertProgramFunctionCallablePayloadName,
          textCapitalization: TextCapitalization.words,
        ),
        CatchField.input(
          copy: catchFieldCopy(context.l10n),
          title: context.l10n.programsWorkspaceFunctionVenue,
          controller: _venueController,
          contract: CatchContractConstraints
              .upsertProgramFunctionCallablePayloadVenueName,
          textCapitalization: TextCapitalization.words,
        ),
        CatchFieldRow.standard(
          leading: Icon(CatchIcons.scheduleOutlined),
          body: Text(
            _startsAt == null
                ? context.l10n.programsWorkspaceFunctionStarts
                : AppTimeFormatters.dateTime(_startsAt!),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: Icon(CatchIcons.chevronRightRounded),
          onTap: () => _pickDateTime(isStart: true),
        ),
        CatchFieldRow.standard(
          leading: Icon(CatchIcons.scheduleOutlined),
          body: Text(
            _endsAt == null
                ? context.l10n.programsWorkspaceFunctionEnds
                : AppTimeFormatters.dateTime(_endsAt!),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: Icon(CatchIcons.chevronRightRounded),
          onTap: () => _pickDateTime(isStart: false),
        ),
        CatchChoiceInput<ProgramFunctionStatus>.segmented(
          options: [
            for (final status in ProgramFunctionStatus.values)
              CatchOption(value: status, label: status.name),
          ],
          selected: _status,
          contract: CatchContractConstraints
              .upsertProgramFunctionCallablePayloadStatus,
          contractValueBuilder: (status) => status.name,
          onChanged: (status) => setState(() => _status = status),
        ),
        CatchField.input(
          copy: catchFieldCopy(context.l10n),
          title: context.l10n.programsWorkspaceFunctionVenueNotes,
          controller: _notesController,
          contract: CatchContractConstraints
              .upsertProgramFunctionCallablePayloadVenueNotes,
          maxLines: 3,
        ),
      ],
    ),
  );
}
