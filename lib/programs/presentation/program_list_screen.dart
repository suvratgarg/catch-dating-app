import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/hosts/presentation/host_organizer_selection_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/programs/data/program_setup_repository.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:catch_dating_app/programs/presentation/program_workspace_controller.dart';
import 'package:catch_dating_app/routing/route_contract.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';

/// Organizer's program index — the multi-day programs they coordinate. Entry
/// point for the W1 workspace (schedule, RSVP grid, team, import).
class ProgramListScreen extends ConsumerWidget {
  const ProgramListScreen({super.key, this.initialOrganizerId});

  final String? initialOrganizerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidState = catchAsyncStateFromAsyncValue(ref.watch(uidProvider));
    final uid = uidState.value;
    if (uid == null) {
      final error = uidState.error;
      return CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
          title: context.l10n.programsListTitle,
          emphasis: scrolledUnder
              ? CatchTopBarEmphasis.divided
              : CatchTopBarEmphasis.plain,
          navigation: const CatchTopBarNavigation(
            mode: CatchTopBarNavigationMode.back,
          ),
        ),
        body: CatchRouteBody.standardViewport(
          child: error != null
              ? CatchLocalizedErrorState(
                  error,
                  context: AppErrorContext.auth,
                  onRetry: () => ref.invalidate(uidProvider),
                )
              : const CatchStateViewport.loading(
                  accountForBottomOverlay: false,
                ),
        ),
      );
    }
    final clubsAsync = ref.watch(hostOperableClubsProvider(uid));
    final selectedOrganizerId = ref.watch(hostOrganizerSelectionProvider(uid));
    final organizer = resolveSelectedHostOrganizer(
      catchAsyncStateFromAsyncValue(clubsAsync).value ?? const [],
      selectedOrganizerId: selectedOrganizerId,
      preferredOrganizerId: selectedOrganizerId == null
          ? initialOrganizerId
          : null,
    );
    return CatchAsyncBoundary<List<Club>>(
      retainDataOn: const {},
      value: clubsAsync,
      onRetry: () => ref.invalidate(hostOperableClubsProvider(uid)),
      loadingBuilder: (_) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
          title: context.l10n.programsListTitle,
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
          title: context.l10n.programsListTitle,
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
      builder: (context, _) => organizer == null
          ? CatchRouteScaffold(
              topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
                title: context.l10n.programsListTitle,
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
                    child: CatchEmptyState(
                      icon: CatchIcons.groupsOutlined,
                      title: context.l10n.programsListNoOrganizerTitle,
                      message: context.l10n.programsListNoOrganizerMessage,
                    ),
                  ),
                ],
              ),
            )
          : ProgramListPageBody(
              organizerId: organizer.id,
              organizerName: organizer.name,
            ),
    );
  }
}

class ProgramListPageBody extends ConsumerStatefulWidget {
  const ProgramListPageBody({
    super.key,
    required this.organizerId,
    required this.organizerName,
  });

  final String organizerId;
  final String organizerName;

  @override
  ConsumerState<ProgramListPageBody> createState() =>
      _ProgramListPageBodyState();
}

class _ProgramListPageBodyState extends ConsumerState<ProgramListPageBody> {
  @override
  Widget build(BuildContext context) {
    final programsAsync = ref.watch(organizerProgramListProvider(widget.organizerId));
    return CatchAsyncBoundary<List<OrganizerProgramSummary>>(
      retainDataOn: const {},
      value: programsAsync,
      onRetry: () => ref.invalidate(organizerProgramListProvider(widget.organizerId)),
      loadingBuilder: (_) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
          title: context.l10n.programsListTitle,
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
          title: context.l10n.programsListTitle,
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
      builder: (context, programs) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
          title: context.l10n.programsListTitle,
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
                title: context.l10n.programsListTitle,
                subtitle: widget.organizerName,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CatchButton(
                      label: context.l10n.programsListCreateLabel,
                      leading: Icon(CatchIcons.addRounded, size: CatchIcon.md),
                      onPressed: () => _createProgram(context),
                    ),
                    const SizedBox(height: CatchSpacing.s3),
                    if (programs.isEmpty)
                      CatchEmptyState(
                        icon: CatchIcons.calendarMonthOutlined,
                        title: context.l10n.programsListEmptyTitle,
                        message: context.l10n.programsListEmptyMessage,
                      )
                    else
                      for (final program in programs)
                        CatchFieldRow.standard(
                          leading: Icon(CatchIcons.eventAvailable),
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                program.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: CatchSpacing.s2),
                              Wrap(
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
                                ],
                              ),
                            ],
                          ),
                          trailing: Icon(CatchIcons.chevronRightRounded),
                          onTap: () => context.pushNamed(
                            Routes.hostProgramWorkspaceScreen.name,
                            pathParameters: {'programId': program.programId},
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createProgram(BuildContext context) async {
    final draft = await showDialog<ProgramCreateDraft>(
      context: context,
      builder: (_) => const ProgramCreateDialog(),
    );
    if (draft == null || !context.mounted) return;
    final result = await ref
        .read(programWorkspaceControllerProvider.notifier)
        .createProgram(
          organizerId: widget.organizerId,
          kind: draft.kind.name,
          title: draft.title,
          timezone: draft.timezone,
          startsAt: draft.startsAt,
          endsAt: draft.endsAt,
        );
    ref.invalidate(organizerProgramListProvider(widget.organizerId));
    if (!context.mounted) return;
    unawaited(
      context.pushNamed(
        Routes.hostProgramWorkspaceScreen.name,
        pathParameters: {'programId': result.entityId},
      ),
    );
  }
}

class ProgramCreateDraft {
  const ProgramCreateDraft({
    required this.title,
    required this.kind,
    required this.timezone,
    required this.startsAt,
    required this.endsAt,
  });

  final String title;
  final ProgramKind kind;
  final String timezone;
  final DateTime startsAt;
  final DateTime endsAt;
}

class ProgramCreateDialog extends StatefulWidget {
  const ProgramCreateDialog({super.key});

  @override
  State<ProgramCreateDialog> createState() => _ProgramCreateDialogState();
}

class _ProgramCreateDialogState extends State<ProgramCreateDialog> {
  final _titleController = TextEditingController();
  final _timezoneController = TextEditingController();
  ProgramKind _kind = ProgramKind.wedding;
  DateTime? _startsAt;
  DateTime? _endsAt;

  @override
  void initState() {
    super.initState();
    FlutterTimezone.getLocalTimezone().then((timezone) {
      if (mounted && _timezoneController.text.isEmpty) {
        setState(() => _timezoneController.text = timezone.identifier);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showCatchDatePicker(
      copy: catchDatePickerCopy(context.l10n),
      context: context,
      initialDate: isStart ? (_startsAt ?? now) : (_endsAt ?? _startsAt ?? now),
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _startsAt = picked;
        if (_endsAt == null || _endsAt!.isBefore(picked)) {
          _endsAt = picked;
        }
      } else {
        _endsAt = picked.isBefore(_startsAt ?? picked)
            ? (_startsAt ?? picked)
            : picked;
      }
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    final timezone = _timezoneController.text.trim();
    final startsAt = _startsAt;
    final endsAt = _endsAt;
    if (title.isEmpty || timezone.isEmpty || startsAt == null) return;
    Navigator.of(context).pop(
      ProgramCreateDraft(
        title: title,
        kind: _kind,
        timezone: timezone,
        startsAt: startsAt,
        endsAt: endsAt ?? startsAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => CatchDialog<void>(
    title: context.l10n.programsCreateTitle,
    actions: [
      CatchButton(
        label: context.l10n.coreCatchAdaptiveDialogVisiblecopyCancel,
        variant: CatchButtonVariant.secondary,
        onPressed: () => Navigator.of(context).pop(),
      ),
      CatchButton(label: context.l10n.programsCreateSubmit, onPressed: _submit),
    ],
    child: CatchSection.containedFieldRows(
      children: [
        CatchField.input(
          copy: catchFieldCopy(context.l10n),
          title: context.l10n.programsCreateNameLabel,
          controller: _titleController,
          contract: CatchContractConstraints
              .createOrganizerProgramCallablePayloadTitle,
          inputHint: context.l10n.programsCreateNameHint,
          textCapitalization: TextCapitalization.words,
        ),
        CatchChoiceInput<ProgramKind>.segmented(
          options: [
            for (final kind in ProgramKind.values)
              CatchOption(value: kind, label: kind.name),
          ],
          selected: _kind,
          onChanged: (kind) => setState(() => _kind = kind),
        ),
        CatchField.input(
          copy: catchFieldCopy(context.l10n),
          title: context.l10n.programsCreateTimezoneLabel,
          controller: _timezoneController,
          contract: CatchContractConstraints
              .createOrganizerProgramCallablePayloadTimezone,
          inputHint: context.l10n.programsCreateTimezoneHint,
        ),
        CatchFieldRow.standard(
          leading: Icon(CatchIcons.calendarTodayOutlined),
          body: Text(
            _startsAt == null
                ? context.l10n.programsCreateStartLabel
                : AppTimeFormatters.shortDate(_startsAt!),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: Icon(CatchIcons.chevronRightRounded),
          onTap: () => _pickDate(isStart: true),
        ),
        CatchFieldRow.standard(
          leading: Icon(CatchIcons.calendarMonthOutlined),
          body: Text(
            _endsAt == null
                ? context.l10n.programsCreateEndLabel
                : AppTimeFormatters.shortDate(_endsAt!),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: Icon(CatchIcons.chevronRightRounded),
          onTap: () => _pickDate(isStart: false),
        ),
      ],
    ),
  );
}
