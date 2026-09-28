import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/programs/data/program_setup_repository.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:catch_dating_app/programs/presentation/program_workspace_controller.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Household × function RSVP grid for the organizer workspace. One function
/// is selected at a time; each household card lists members with their join
/// state and a segmented RSVP editor that writes through
/// `recordProgramFunctionRsvp`.
class ProgramGuestsScreen extends ConsumerWidget {
  const ProgramGuestsScreen({super.key, required this.programId});

  final String programId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(organizerProgramDetailProvider(programId));
    final guestsAsync = ref.watch(programGuestListProvider(programId));
    return CatchAsyncBoundary<OrganizerProgramDetail>(
      retainDataOn: const {},
      value: detailAsync,
      onRetry: () => ref.invalidate(organizerProgramDetailProvider(programId)),
      loadingBuilder: (_) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
          title: context.l10n.programsGuestsTitle,
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
          title: context.l10n.programsGuestsTitle,
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
      builder: (context, detail) => CatchAsyncBoundary<ProgramGuestListPage>(
        retainDataOn: const {},
        value: guestsAsync,
        onRetry: () => ref.invalidate(programGuestListProvider(programId)),
        loadingBuilder: (_) => CatchRouteScaffold(
          topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
            title: detail.program.title,
            subtitle: context.l10n.programsGuestsTitle,
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
            title: detail.program.title,
            subtitle: context.l10n.programsGuestsTitle,
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
        builder: (context, page) => ProgramGuestsPageBody(
          programId: programId,
          programDetail: detail,
          guestPage: page,
        ),
      ),
    );
  }
}

class ProgramGuestsPageBody extends ConsumerStatefulWidget {
  const ProgramGuestsPageBody({
    super.key,
    required this.programId,
    required this.programDetail,
    required this.guestPage,
  });

  final String programId;
  final OrganizerProgramDetail programDetail;
  final ProgramGuestListPage guestPage;

  @override
  ConsumerState<ProgramGuestsPageBody> createState() =>
      _ProgramGuestsPageBodyState();
}

class _ProgramGuestsPageBodyState extends ConsumerState<ProgramGuestsPageBody> {
  String? _selectedFunctionId;
  String? _pendingGuestKey;
  Object? _mutationError;

  OrganizerFunctionDetail? get _selectedFunction {
    final functions = widget.programDetail.functions;
    if (functions.isEmpty) return null;
    for (final fn in functions) {
      if (fn.functionId == _selectedFunctionId) return fn;
    }
    return functions.first;
  }

  /// Join rows keyed `guestId:functionId` for O(1) cell lookups.
  Map<String, ProgramFunctionGuestRow> get _joinIndex {
    final index = <String, ProgramFunctionGuestRow>{};
    for (final row in widget.guestPage.functionGuests) {
      index['${row.guestId}:${row.functionId}'] = row;
    }
    return index;
  }

  void _refresh() {
    ref.invalidate(programGuestListProvider(widget.programId));
    ref.invalidate(organizerProgramDetailProvider(widget.programId));
  }

  Future<void> _recordRsvp(ProgramGuestRow guest, String status) async {
    final fn = _selectedFunction;
    if (fn == null) return;
    setState(() {
      _pendingGuestKey = guest.guestId;
      _mutationError = null;
    });
    try {
      await ref
          .read(programWorkspaceControllerProvider.notifier)
          .recordFunctionRsvp(
            programId: widget.programId,
            functionId: fn.functionId,
            guestId: guest.guestId,
            rsvpStatus: status,
            allowUninvited: true,
          );
      _refresh();
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
    } finally {
      if (mounted) setState(() => _pendingGuestKey = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = widget.guestPage;
    final selectedFn = _selectedFunction;
    final joinIndex = _joinIndex;
    final guestsByHousehold = <String?, List<ProgramGuestRow>>{};
    for (final guest in page.guests) {
      guestsByHousehold.putIfAbsent(guest.householdId, () => []).add(guest);
    }
    final householdById = {for (final h in page.households) h.householdId: h};
    final householdIds = page.households
        .where((h) => guestsByHousehold.containsKey(h.householdId))
        .map((h) => h.householdId)
        .toList(growable: false);
    final unaffiliated = guestsByHousehold[null] ?? const [];

    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
        title: widget.programDetail.program.title,
        subtitle: context.l10n.programsGuestsTitle,
        emphasis: scrolledUnder
            ? CatchTopBarEmphasis.divided
            : CatchTopBarEmphasis.plain,
        navigation: const CatchTopBarNavigation(
          mode: CatchTopBarNavigationMode.back,
        ),
      ),
      body: CatchRouteBody.standardSections(
        sections: [
          if (widget.programDetail.functions.length > 1)
            CatchSectionListItem(
              child: CatchChoiceInput<String>.segmented(
                scrollable: true,
                options: [
                  for (final fn in widget.programDetail.functions)
                    CatchOption(value: fn.functionId, label: fn.name),
                ],
                selected: selectedFn?.functionId,
                contractExemption:
                    'Picks which function column the matrix inspects; RSVP writes carry their own functionId per cell.',
                onChanged: (id) => setState(() => _selectedFunctionId = id),
              ),
            ),
          if (_mutationError != null)
            CatchSectionListItem(
              child: CatchBanner(
                title: context.l10n.programsGuestsMutationFailed,
                message: appErrorMessage(
                  _mutationError!,
                  l10n: context.l10n,
                  context: AppErrorContext.event,
                ),
                icon: CatchIcons.info,
                tone: CatchBannerTone.danger,
              ),
            ),
          CatchSectionListItem(
            child: CatchSection.contained(
              title: context.l10n.programsGuestsGridTitle,
              subtitle: selectedFn == null
                  ? null
                  : context.l10n.programsGuestsGridSubtitle(
                      function: selectedFn.name,
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CatchButton(
                    label: context.l10n.programsGuestsAddGuest,
                    leading: Icon(CatchIcons.addRounded, size: CatchIcon.md),
                    variant: CatchButtonVariant.secondary,
                    onPressed: () => _addGuest(context),
                  ),
                  const SizedBox(height: CatchSpacing.s3),
                  if (page.guests.isEmpty)
                    CatchEmptyState(
                      icon: CatchIcons.groupsOutlined,
                      title: context.l10n.programsGuestsEmptyTitle,
                      message: context.l10n.programsGuestsEmptyMessage,
                    )
                  else ...[
                    for (final householdId in householdIds)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            householdById[householdId]!.label,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          gapH8,
                          for (final member in guestsByHousehold[householdId]!)
                            ProgramGuestsFunctionRow(
                              guest: member,
                              functions: widget.programDetail.functions,
                              selectedFunction: selectedFn,
                              joinIndex: joinIndex,
                              pending: _pendingGuestKey == member.guestId,
                              onRsvp: _recordRsvp,
                            ),
                          gapH12,
                        ],
                      ),
                    if (unaffiliated.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.programsGuestsNoHousehold,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          gapH8,
                          for (final member in unaffiliated)
                            ProgramGuestsFunctionRow(
                              guest: member,
                              functions: widget.programDetail.functions,
                              selectedFunction: selectedFn,
                              joinIndex: joinIndex,
                              pending: _pendingGuestKey == member.guestId,
                              onRsvp: _recordRsvp,
                            ),
                        ],
                      ),
                  ],
                ],
              ),
            ),
          ),
          CatchSectionListItem(
            child: CatchSection.contained(
              title: context.l10n.programsGuestsGroupsTitle,
              subtitle: context.l10n.programsGuestsGroupsSubtitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CatchButton(
                    label: context.l10n.programsGuestsGroupNew,
                    leading: Icon(CatchIcons.addRounded, size: CatchIcon.md),
                    variant: CatchButtonVariant.secondary,
                    onPressed: () => _addGroup(context),
                  ),
                  const SizedBox(height: CatchSpacing.s2),
                  if (page.groups.isEmpty)
                    Text(
                      context.l10n.programsGuestsGroupsEmpty,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    for (final group in page.groups)
                      CatchFieldRow.standard(
                        leading: Icon(CatchIcons.group),
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.label,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: CatchSpacing.s1),
                            Text(
                              '${group.dimension} · '
                              '${context.l10n.programsGuestsGroupMembers(count: group.memberCount)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (group.hotelId != null)
                              Text(
                                context.l10n.programsGuestsGroupHotelSummary(
                                  hotel:
                                      widget.programDetail.hotels
                                          .where(
                                            (hotel) =>
                                                hotel.hotelId == group.hotelId,
                                          )
                                          .firstOrNull
                                          ?.name ??
                                      context
                                          .l10n
                                          .programsGuestsHotelUnavailable,
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CatchIconAction.icon(
                              icon: CatchIcons.editOutlined,
                              variant: CatchIconActionVariant.plain,
                              tooltip: context.l10n.programsGuestsGroupEdit,
                              onPressed: () => _editGroup(context, group),
                            ),
                            CatchIconAction.icon(
                              icon: CatchIcons.deleteOutline,
                              variant: CatchIconActionVariant.plain,
                              accent: CatchTokens.of(context).danger,
                              tooltip: context.l10n.programsGuestsGroupDelete,
                              onPressed: () => _deleteGroup(context, group),
                            ),
                          ],
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

  Future<void> _addGuest(BuildContext context) async {
    final draft = await showDialog<_GuestDraft>(
      context: context,
      builder: (_) => ProgramGuestEditDialog(
        households: widget.guestPage.households,
        groups: widget.guestPage.groups,
      ),
    );
    if (draft == null || !mounted) return;
    setState(() => _mutationError = null);
    try {
      await ref
          .read(programWorkspaceControllerProvider.notifier)
          .upsertGuest(
            programId: widget.programId,
            displayName: draft.displayName,
            householdId: draft.householdId,
            groupIds: draft.groupIds,
            phoneE164: draft.phoneE164,
            email: draft.email,
          );
      _refresh();
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
    }
  }

  Future<void> _addGroup(BuildContext context) => _editGroup(context, null);

  Future<void> _editGroup(
    BuildContext context,
    ProgramGuestGroupRow? group,
  ) async {
    final draft =
        await showDialog<({String label, String dimension, String? hotelId})>(
          context: context,
          builder: (_) => ProgramGuestGroupEditDialog(
            hotels: widget.programDetail.hotels,
            group: group,
          ),
        );
    if (draft == null || !mounted) return;
    setState(() => _mutationError = null);
    try {
      await ref
          .read(programWorkspaceControllerProvider.notifier)
          .upsertGuestGroup(
            programId: widget.programId,
            label: draft.label,
            dimension: draft.dimension,
            groupId: group?.groupId,
            expectedRevision: group?.revision,
            hotelId: draft.hotelId == group?.hotelId ? null : draft.hotelId,
            clearHotel: group?.hotelId != null && draft.hotelId == null,
          );
      _refresh();
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
    }
  }

  Future<void> _deleteGroup(
    BuildContext context,
    ProgramGuestGroupRow group,
  ) async {
    final confirmed = await showCatchConfirmDialog(
      copy: catchDialogCopy(context.l10n),
      context: context,
      title: context.l10n.programsGuestsGroupDeleteTitle,
      message: context.l10n.programsGuestsGroupDeleteMessage(
        label: group.label,
      ),
      confirmLabel: context.l10n.programsGuestsGroupDelete,
      danger: true,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _mutationError = null);
    try {
      await ref
          .read(programWorkspaceControllerProvider.notifier)
          .deleteGuestGroup(
            programId: widget.programId,
            groupId: group.groupId,
            expectedRevision: group.revision,
          );
      _refresh();
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
    }
  }
}

/// One guest row: per-function status chips for the whole program plus the
/// RSVP editor for the currently selected function.
class ProgramGuestsFunctionRow extends StatelessWidget {
  const ProgramGuestsFunctionRow({
    super.key,
    required this.guest,
    required this.functions,
    required this.selectedFunction,
    required this.joinIndex,
    required this.pending,
    required this.onRsvp,
  });

  final ProgramGuestRow guest;
  final List<OrganizerFunctionDetail> functions;
  final OrganizerFunctionDetail? selectedFunction;
  final Map<String, ProgramFunctionGuestRow> joinIndex;
  final bool pending;
  final void Function(ProgramGuestRow guest, String status) onRsvp;

  @override
  Widget build(BuildContext context) {
    final selected = selectedFunction;
    final join = selected == null
        ? null
        : joinIndex['${guest.guestId}:${selected.functionId}'];
    return CatchFieldRow.standard(
      leading: Icon(CatchIcons.personOutlineRounded),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            guest.displayName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: CatchSpacing.s2),
          Wrap(
            spacing: CatchSpacing.s1,
            runSpacing: CatchSpacing.s1,
            children: [
              for (final fn in functions)
                Builder(
                  builder: (context) {
                    final join = joinIndex['${guest.guestId}:${fn.functionId}'];
                    final status = join == null
                        ? 'pending'
                        : join.invited
                        ? join.rsvpStatus
                        : 'notInvited';
                    return CatchBadge(
                      label: '${fn.name}: $status',
                      tone: _guestStatusTone(
                        status,
                        isSelected: fn.functionId == selected?.functionId,
                      ),
                    );
                  },
                ),
            ],
          ),
          if (selected != null) ...[
            const SizedBox(height: CatchSpacing.s2),
            if (pending)
              const Column(children: [gapH8, CatchLoadingIndicator(), gapH8])
            else
              CatchChoiceInput<String>.segmented(
                options: [
                  CatchOption(
                    value: 'attending',
                    label: context.l10n.programsDoorRsvpAttending,
                  ),
                  CatchOption(
                    value: 'maybe',
                    label: context.l10n.programsDoorRsvpMaybe,
                  ),
                  CatchOption(
                    value: 'declined',
                    label: context.l10n.programsDoorRsvpDeclined,
                  ),
                  CatchOption(
                    value: 'pending',
                    label: context.l10n.programsDoorRsvpPending,
                  ),
                ],
                selected: join?.rsvpStatus ?? 'pending',
                contract: CatchContractConstraints
                    .recordProgramFunctionRsvpCallablePayloadRsvpStatus,
                contractValueBuilder: (status) => status,
                onChanged: (status) => onRsvp(guest, status),
              ),
          ],
        ],
      ),
    );
  }
}

CatchBadgeTone _guestStatusTone(String status, {required bool isSelected}) {
  return switch (status) {
    'attending' => CatchBadgeTone.success,
    'declined' => CatchBadgeTone.danger,
    'maybe' => CatchBadgeTone.warning,
    'notInvited' => CatchBadgeTone.neutral,
    _ => isSelected ? CatchBadgeTone.brand : CatchBadgeTone.neutral,
  };
}

class _GuestDraft {
  const _GuestDraft({
    required this.displayName,
    this.householdId,
    this.groupIds,
    this.phoneE164,
    this.email,
  });

  final String displayName;
  final String? householdId;
  final List<String>? groupIds;
  final String? phoneE164;
  final String? email;
}

class ProgramGuestEditDialog extends StatefulWidget {
  const ProgramGuestEditDialog({
    super.key,
    required this.households,
    required this.groups,
  });

  final List<ProgramHouseholdRow> households;
  final List<ProgramGuestGroupRow> groups;

  @override
  State<ProgramGuestEditDialog> createState() => _ProgramGuestEditDialogState();
}

class _ProgramGuestEditDialogState extends State<ProgramGuestEditDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String? _householdId;
  final Set<String> _groupIds = {};

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(
      _GuestDraft(
        displayName: name,
        householdId: _householdId,
        groupIds: _groupIds.isEmpty ? null : (_groupIds.toList()..sort()),
        phoneE164: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => CatchDialog<void>(
    title: context.l10n.programsGuestsAddGuest,
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
          title: context.l10n.programsGuestsNameLabel,
          controller: _nameController,
          contract: CatchContractConstraints
              .upsertProgramGuestCallablePayloadDisplayName,
          textCapitalization: TextCapitalization.words,
        ),
        CatchField.input(
          copy: catchFieldCopy(context.l10n),
          title: context.l10n.programsGuestsPhoneLabel,
          controller: _phoneController,
          contract: CatchContractConstraints
              .upsertProgramGuestCallablePayloadPhoneE164,
          keyboardType: TextInputType.phone,
        ),
        CatchField.input(
          copy: catchFieldCopy(context.l10n),
          title: context.l10n.programsGuestsEmailLabel,
          controller: _emailController,
          contract:
              CatchContractConstraints.upsertProgramGuestCallablePayloadEmail,
          keyboardType: TextInputType.emailAddress,
        ),
        if (widget.households.isNotEmpty) ...[
          gapH8,
          Text(
            context.l10n.programsGuestsHouseholdLabel,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          for (final household in widget.households)
            CatchFieldRow.standard(
              body: Text(
                household.label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: _householdId == household.householdId
                  ? Icon(CatchIcons.checkRounded, size: CatchIcon.md)
                  : null,
              onTap: () => setState(
                () => _householdId = _householdId == household.householdId
                    ? null
                    : household.householdId,
              ),
            ),
        ],
        if (widget.groups.isNotEmpty) ...[
          gapH8,
          Text(
            context.l10n.programsGuestsGroupsTitle,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          for (final group in widget.groups)
            CatchFieldRow.standard(
              body: Text(
                '${group.label} · ${group.dimension}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: _groupIds.contains(group.groupId)
                  ? Icon(CatchIcons.checkRounded, size: CatchIcon.md)
                  : null,
              onTap: () => setState(
                () => _groupIds.contains(group.groupId)
                    ? _groupIds.remove(group.groupId)
                    : _groupIds.add(group.groupId),
              ),
            ),
        ],
      ],
    ),
  );
}

class ProgramGuestGroupEditDialog extends StatefulWidget {
  const ProgramGuestGroupEditDialog({
    super.key,
    required this.hotels,
    this.group,
  });

  final List<ProgramHotel> hotels;
  final ProgramGuestGroupRow? group;

  @override
  State<ProgramGuestGroupEditDialog> createState() =>
      _ProgramGuestGroupEditDialogState();
}

class _ProgramGuestGroupEditDialogState
    extends State<ProgramGuestGroupEditDialog> {
  final _labelController = TextEditingController();
  final _dimensionController = TextEditingController();
  String? _hotelId;

  @override
  void initState() {
    super.initState();
    _labelController.text = widget.group?.label ?? '';
    _dimensionController.text = widget.group?.dimension ?? '';
    _hotelId = widget.group?.hotelId;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _dimensionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CatchDialog<void>(
    title: widget.group == null
        ? context.l10n.programsGuestsGroupNew
        : context.l10n.programsGuestsGroupEdit,
    actions: [
      CatchButton(
        label: context.l10n.coreCatchAdaptiveDialogVisiblecopyCancel,
        variant: CatchButtonVariant.secondary,
        onPressed: () => Navigator.of(context).pop(),
      ),
      CatchButton(
        label: context.l10n.programsWorkspaceFunctionSave,
        onPressed: () {
          final label = _labelController.text.trim();
          final dimension = _dimensionController.text.trim();
          if (label.isEmpty || dimension.isEmpty) return;
          Navigator.of(
            context,
          ).pop((label: label, dimension: dimension, hotelId: _hotelId));
        },
      ),
    ],
    child: CatchSection.containedFieldRows(
      children: [
        CatchField.input(
          key: const ValueKey('program-guest-group-label'),
          copy: catchFieldCopy(context.l10n),
          title: context.l10n.programsGuestsGroupLabel,
          controller: _labelController,
          contract: CatchContractConstraints
              .upsertProgramGuestGroupCallablePayloadLabel,
          textCapitalization: TextCapitalization.words,
        ),
        CatchField.input(
          key: const ValueKey('program-guest-group-dimension'),
          copy: catchFieldCopy(context.l10n),
          title: context.l10n.programsGuestsGroupDimension,
          controller: _dimensionController,
          contract: CatchContractConstraints
              .upsertProgramGuestGroupCallablePayloadDimension,
          inputHint: context.l10n.programsGuestsGroupDimensionHint,
        ),
        if (widget.hotels.isNotEmpty || widget.group?.hotelId != null)
          CatchField<String>.choices(
            key: const ValueKey('program-guest-group-hotel'),
            copy: catchFieldCopy(context.l10n),
            title: context.l10n.programsGuestsGroupHotel,
            contract: CatchContractConstraints
                .upsertProgramGuestGroupCallablePayloadHotelId,
            contractValueBuilder: (value) => value,
            values: [
              for (final hotel in widget.hotels) hotel.hotelId,
              if (widget.group?.hotelId case final existingId?)
                if (!widget.hotels.any((hotel) => hotel.hotelId == existingId))
                  existingId,
            ],
            itemLabelBuilder: (hotelId) =>
                widget.hotels
                    .where((hotel) => hotel.hotelId == hotelId)
                    .firstOrNull
                    ?.name ??
                context.l10n.programsGuestsHotelUnavailable,
            selected: {?_hotelId},
            allowEmptySelection: true,
            emptyValueText: context.l10n.programsGuestsGroupNoHotel,
            onSelectionChanged: (selection) =>
                setState(() => _hotelId = selection.firstOrNull),
          )
        else
          Text(
            context.l10n.programsGuestsNoHotelsAvailable,
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    ),
  );
}
