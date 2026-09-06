part of 'host_customers_screen.dart';

class HostSavedAudienceEditorScreen extends ConsumerWidget {
  const HostSavedAudienceEditorScreen({
    super.key,
    required this.organizerId,
    this.audienceId,
    this.initialAudience,
  });

  final String organizerId;
  final String? audienceId;
  final HostSavedAudience? initialAudience;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplied = initialAudience;
    if (supplied != null) {
      return HostSavedAudienceWorkspace(audience: supplied);
    }
    if (audienceId == null) {
      return _HostSavedAudienceEditorForm(
        organizerId: organizerId,
        initialAudience: supplied,
      );
    }
    final audiences = ref.watch(hostAllSavedAudiencesProvider(organizerId));
    return CatchAsyncValueView<HostSavedAudiencePage>(
      value: audiences,
      onRetry: () => ref.invalidate(hostAllSavedAudiencesProvider(organizerId)),
      initialLoadTimeout: null,
      loadingBuilder: (_) =>
          HostLoadingScreen(title: context.l10n.hostSavedAudiencesManage),
      errorBuilder: (_, error, _) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchScreenTopBar(
          context: context,
          title: context.l10n.hostSavedAudiencesManage,
          leadingType: CatchTopBarLeading.back,
          divider: scrolledUnder,
        ),
        body: CatchRouteBody.standardViewport(
          child: CatchErrorState.fromError(
            error,
            context: AppErrorContext.customers,
            onRetry: () =>
                ref.invalidate(hostAllSavedAudiencesProvider(organizerId)),
          ),
        ),
      ),
      builder: (context, page) {
        final audience = page.audiences
            .where((item) => item.audienceId == audienceId)
            .firstOrNull;
        if (audience == null) {
          return CatchRouteScaffold(
            topBarBuilder: (context, scrolledUnder) => CatchScreenTopBar(
              context: context,
              title: context.l10n.hostSavedAudiencesManage,
              leadingType: CatchTopBarLeading.back,
              divider: scrolledUnder,
            ),
            body: CatchRouteBody.standardViewport(
              child: CatchErrorState.fromError(
                StateError(context.l10n.hostSavedAudienceNotFound),
                context: AppErrorContext.customers,
                onRetry: () =>
                    ref.invalidate(hostAllSavedAudiencesProvider(organizerId)),
              ),
            ),
          );
        }
        return HostSavedAudienceWorkspace(audience: audience);
      },
    );
  }
}

class _HostSavedAudienceEditorForm extends ConsumerStatefulWidget {
  const _HostSavedAudienceEditorForm({
    required this.organizerId,
    required this.initialAudience,
    this.onSaved,
  });

  final String organizerId;
  final HostSavedAudience? initialAudience;
  final ValueChanged<HostSavedAudience>? onSaved;

  @override
  ConsumerState<_HostSavedAudienceEditorForm> createState() =>
      _HostSavedAudienceEditorFormState();
}

class _HostSavedAudienceEditorFormState
    extends ConsumerState<_HostSavedAudienceEditorForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late HostSavedAudienceJoin _join;
  late List<_AudienceRuleDraft> _rules;
  HostSavedAudience? _audience;
  String? _pendingCreateRequestId;
  bool _busy = false;
  Object? _previewError;
  late bool _static;
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _audience = widget.initialAudience;
    _static = _audience?.definition.isStatic ?? false;
    _selectedIds = {...?_audience?.definition.selectedContactIds};
    _nameController = TextEditingController(text: _audience?.name ?? '');
    _join = _audience?.definition.join ?? HostSavedAudienceJoin.all;
    _rules = (_audience?.definition.predicates ?? const [])
        .where((predicate) => predicate is! HostSavedAudienceStaticMembers)
        .map(_AudienceRuleDraft.fromPredicate)
        .toList(growable: true);
    if (_rules.isEmpty) _rules.add(_AudienceRuleDraft.defaults());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = ref.watch(
      hostSavedAudienceFilterOptionsProvider(widget.organizerId),
    );
    final editing = _audience != null;
    return PopScope(
      canPop: !_busy,
      child: CatchRouteScaffold(
        resizeToAvoidBottomInset: true,
        topBarBuilder: (context, scrolledUnder) => CatchScreenTopBar(
          context: context,
          title: editing
              ? context.l10n.hostAudienceEditGroup
              : context.l10n.hostSavedAudienceNew,
          leadingType: CatchTopBarLeading.back,
          divider: scrolledUnder,
        ),
        bottomNavigationBar: CatchBottomAction(
          label: editing
              ? context.l10n.hostAudienceSaveCheckMembership
              : context.l10n.hostAudienceCreateCheckMembership,
          buttonKey: const ValueKey('host-saved-audience-save'),
          isLoading: _busy,
          onPressed: _busy ? null : _save,
        ),
        body: CatchRouteBody.standard(
          child: CatchAsyncValueView<HostSavedAudienceFilterOptions>(
            value: options,
            errorContext: AppErrorContext.customers,
            onRetry: () => ref.invalidate(
              hostSavedAudienceFilterOptionsProvider(widget.organizerId),
            ),
            builder: (context, filterOptions) {
              final manualTags = filterOptions.tags
                  .map(
                    (tag) => HostCustomerManualTag(
                      tagId: tag.tagId,
                      label: tag.label,
                    ),
                  )
                  .toList();
              return Form(
                key: _formKey,
                child: CatchResponsiveSectionLayout(
                  sections: [
                    CatchResponsiveSectionItem(
                      child: CatchSection.fieldRows(
                        title: context.l10n.hostSavedAudienceDetails,
                        children: [
                          CatchField.input(
                            key: const ValueKey('host-saved-audience-name'),
                            title: context.l10n.hostSavedAudienceName,
                            contract: CatchContractConstraints
                                .upsertOrganizerSavedAudienceCallablePayloadName,
                            controller: _nameController,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            enabled: !_busy,
                            validator: (value) => (value ?? '').trim().isEmpty
                                ? context.l10n.hostSavedAudienceNameRequired
                                : null,
                          ),
                          CatchField.select<HostSavedAudienceMembershipMode>(
                            key: const ValueKey('host-saved-audience-mode'),
                            title: context.l10n.hostAudienceMembershipMode,
                            contractExemption:
                                'Chooses the staticMembers-only definition or the dynamic predicate vocabulary, validated by the saved-audience callable.',
                            values: HostSavedAudienceMembershipMode.values,
                            itemLabel: (value) =>
                                value == HostSavedAudienceMembershipMode.rules
                                ? context.l10n.hostAudienceRuleMembership
                                : context.l10n.hostAudienceStaticMembership,
                            value: _static
                                ? HostSavedAudienceMembershipMode.selectedPeople
                                : HostSavedAudienceMembershipMode.rules,
                            enabled: !_busy,
                            onChanged: (value) {
                              if (value != null) {
                                setState(
                                  () => _static =
                                      value ==
                                      HostSavedAudienceMembershipMode
                                          .selectedPeople,
                                );
                              }
                            },
                          ),
                          if (!_static)
                            CatchField.select<HostSavedAudienceJoin>(
                              key: const ValueKey('host-saved-audience-join'),
                              title: context.l10n.hostSavedAudienceMatch,
                              contract: CatchContractConstraints
                                  .upsertOrganizerSavedAudienceCallablePayloadDefinitionJoin,
                              contractValue: (value) => value.name,
                              values: HostSavedAudienceJoin.values,
                              itemLabel: (value) => switch (value) {
                                HostSavedAudienceJoin.all =>
                                  context.l10n.hostSavedAudienceMatchAll,
                                HostSavedAudienceJoin.any =>
                                  context.l10n.hostSavedAudienceMatchAny,
                              },
                              value: _join,
                              enabled: !_busy,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _join = value);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                    if (_static)
                      CatchResponsiveSectionItem(
                        child: HostStaticAudienceMembersEditor(
                          organizerId: widget.organizerId,
                          selectedIds: _selectedIds,
                          enabled: !_busy,
                          onChanged: (ids) =>
                              setState(() => _selectedIds = ids),
                        ),
                      ),
                    if (!_static)
                      for (var index = 0; index < _rules.length; index++)
                        CatchResponsiveSectionItem(
                          child: _HostSavedAudienceRuleSection(
                            key: ValueKey('host-saved-audience-rule-$index'),
                            number: index + 1,
                            draft: _rules[index],
                            manualTags: manualTags,
                            filterOptions: filterOptions,
                            enabled: !_busy,
                            canRemove: _rules.length > 1,
                            onChanged: (draft) =>
                                setState(() => _rules[index] = draft),
                            onRemove: () =>
                                setState(() => _rules.removeAt(index)),
                          ),
                        ),
                    if (!_static && _rules.length < 8)
                      CatchResponsiveSectionItem(
                        child: CatchSection.fieldRows(
                          children: [
                            CatchField.add(
                              key: const ValueKey(
                                'host-saved-audience-add-rule',
                              ),
                              title: context.l10n.hostSavedAudienceAddRule,
                              icon: CatchIcons.add,
                              onTap: _busy
                                  ? null
                                  : () => setState(
                                      () => _rules.add(
                                        _AudienceRuleDraft.defaults(),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    CatchResponsiveSectionItem(
                      child: CatchSection.divided(
                        title: context.l10n.hostAudienceWhoWillBelong,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_static)
                              Text(
                                context.l10n.hostAudienceSelectedCount(
                                  count: _selectedIds.length,
                                ),
                                style: CatchTextStyles.recordBody(context),
                              )
                            else ...[
                              Text(
                                _join == HostSavedAudienceJoin.all
                                    ? context.l10n.hostSavedAudienceMatchAll
                                    : context.l10n.hostSavedAudienceMatchAny,
                                style: CatchTextStyles.recordContext(context),
                              ),
                              for (final rule in _rules)
                                if (rule.toPredicate()
                                    case final predicate?) ...[
                                  gapH8,
                                  Text(
                                    _savedAudienceRuleSummary(
                                      context,
                                      predicate,
                                      filterOptions,
                                    ),
                                    style: CatchTextStyles.recordBody(context),
                                  ),
                                ],
                            ],
                            gapH12,
                            Text(
                              context.l10n.hostAudienceMembershipCheckOnSave,
                              style: CatchTextStyles.supporting(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_previewError case final error?)
                      CatchResponsiveSectionItem(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              context.l10n.hostAudienceSavedPreviewFailed,
                              style: CatchTextStyles.recordTitle(context),
                            ),
                            gapH8,
                            CatchErrorState.fromError(
                              error,
                              context: AppErrorContext.customers,
                              onRetry: _busy ? null : _refreshPreview,
                            ),
                          ],
                        ),
                      ),
                    if (_audience case final audience?)
                      CatchResponsiveSectionItem(
                        child: CatchSection.fieldRows(
                          title: context.l10n.hostSavedAudienceCurrentPreview,
                          footer: Text(
                            context.l10n.hostAudienceSavedGroupPreviewHelp,
                            style: CatchTextStyles.supporting(context),
                          ),
                          children: [
                            CatchField.read(
                              title: context.l10n.hostSavedAudiencePeople,
                              body: _savedAudienceDirectoryBody(
                                context,
                                audience,
                              ),
                            ),
                            CatchField.action(
                              key: const ValueKey(
                                'host-saved-audience-refresh-preview',
                              ),
                              title: context.l10n.hostSavedAudiencePreview,
                              onTap: _busy ? null : _refreshPreview,
                            ),
                          ],
                        ),
                      ),
                    if (_audience != null)
                      CatchResponsiveSectionItem(
                        child: CatchSection.fieldRows(
                          children: [
                            CatchField.action(
                              key: const ValueKey(
                                'host-saved-audience-archive',
                              ),
                              title: context.l10n.hostSavedAudienceArchive,
                              body: context.l10n.hostSavedAudienceArchiveBody,
                              tone: CatchFieldTone.danger,
                              onTap: _busy ? null : _archive,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_busy || !(_formKey.currentState?.validate() ?? false)) return;
    final predicates = _static
        ? <HostSavedAudiencePredicate?>[
            HostSavedAudienceStaticMembers(_selectedIds.toList()..sort()),
          ]
        : _rules.map((rule) => rule.toPredicate()).toList();
    if (predicates.any((predicate) => predicate == null)) {
      showCatchErrorSnackBar(
        context,
        StateError(context.l10n.hostSavedAudienceCompleteRules),
        errorContext: AppErrorContext.customers,
      );
      return;
    }
    setState(() => _busy = true);
    var savedSuccessfully = false;
    try {
      final controller = ref.read(hostAudienceControllerProvider);
      final requestId = _audience == null
          ? _pendingCreateRequestId ??= _newSavedAudienceRequestId()
          : _newSavedAudienceRequestId();
      final saved = await controller.saveAudience(
        organizerId: widget.organizerId,
        audienceId: _audience?.audienceId,
        expectedRevision: _audience?.revision,
        requestId: requestId,
        name: _nameController.text.trim(),
        definition: HostSavedAudienceDefinition(
          join: _static ? HostSavedAudienceJoin.all : _join,
          predicates: predicates.cast<HostSavedAudiencePredicate>(),
        ),
      );
      savedSuccessfully = true;
      if (!mounted) return;
      setState(() {
        _audience = saved;
        _pendingCreateRequestId = null;
        _previewError = null;
      });
      ref.invalidate(hostSavedAudiencesProvider(widget.organizerId));
      ref.invalidate(hostAllSavedAudiencesProvider(widget.organizerId));
      final preview = await controller.previewAudience(
        organizerId: widget.organizerId,
        audience: saved,
      );
      ref.invalidate(hostSavedAudiencesProvider(widget.organizerId));
      ref.invalidate(hostAllSavedAudiencesProvider(widget.organizerId));
      if (mounted) {
        if (widget.onSaved case final onSaved?) {
          onSaved(preview.audience);
        } else {
          context.pop(preview.audience);
        }
      }
    } on Object catch (error) {
      if (mounted && savedSuccessfully) {
        setState(() => _previewError = error);
      } else if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.customers,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refreshPreview() async {
    final audience = _audience;
    if (_busy || audience == null) return;
    setState(() => _busy = true);
    try {
      final preview = await ref
          .read(hostAudienceControllerProvider)
          .previewAudience(organizerId: widget.organizerId, audience: audience);
      ref.invalidate(hostSavedAudiencesProvider(widget.organizerId));
      ref.invalidate(hostAllSavedAudiencesProvider(widget.organizerId));
      if (mounted) {
        setState(() {
          _audience = preview.audience;
          _previewError = null;
        });
      }
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.customers,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _archive() async {
    final audience = _audience;
    if (_busy || audience == null) return;
    final confirmed = await showCatchConfirmDialog(
      context: context,
      title: context.l10n.hostSavedAudienceArchiveTitle,
      message: context.l10n.hostSavedAudienceArchiveBody,
      confirmLabel: context.l10n.hostSavedAudienceArchive,
      danger: true,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(hostAudienceControllerProvider)
          .archiveAudience(organizerId: widget.organizerId, audience: audience);
      ref.invalidate(hostSavedAudiencesProvider(widget.organizerId));
      ref.invalidate(hostAllSavedAudiencesProvider(widget.organizerId));
      if (mounted) context.pop(audience);
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.customers,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

String _newSavedAudienceRequestId() =>
    '${DateTime.now().microsecondsSinceEpoch}-audience-editor';

class _HostSavedAudienceRuleSection extends StatelessWidget {
  const _HostSavedAudienceRuleSection({
    super.key,
    required this.number,
    required this.draft,
    required this.manualTags,
    required this.filterOptions,
    required this.enabled,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final int number;
  final _AudienceRuleDraft draft;
  final List<HostCustomerManualTag> manualTags;
  final HostSavedAudienceFilterOptions filterOptions;
  final bool enabled;
  final bool canRemove;
  final ValueChanged<_AudienceRuleDraft> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final kinds = _AudienceRuleKind.values
        .where(
          (kind) =>
              kind != _AudienceRuleKind.manualTag ||
              manualTags.isNotEmpty ||
              draft.kind == _AudienceRuleKind.manualTag,
        )
        .toList(growable: false);
    return CatchSection.fieldRows(
      title: context.l10n.hostSavedAudienceCondition(number: number),
      trailing: !canRemove
          ? null
          : CatchTextButton(
              label: context.l10n.hostSavedAudienceRemoveRule,
              tone: CatchTextButtonTone.danger,
              onPressed: enabled ? onRemove : null,
            ),
      children: [
        CatchField.select<_AudienceRuleKind>(
          key: ValueKey('host-saved-audience-rule-type-$number'),
          title: context.l10n.hostSavedAudienceRuleType,
          contract: CatchContractConstraints
              .upsertOrganizerSavedAudienceCallablePayloadDefinitionPredicatesItemsKind,
          contractValue: (value) => value.wireValue,
          values: kinds,
          itemLabel: (value) => _audienceRuleKindLabel(context, value),
          value: draft.kind,
          enabled: enabled,
          onChanged: (value) {
            if (value != null) onChanged(draft.withKind(value, manualTags));
          },
        ),
        ...switch (draft.kind) {
          _AudienceRuleKind.spend ||
          _AudienceRuleKind.applicationStatus ||
          _AudienceRuleKind.formAnswer ||
          _AudienceRuleKind.attendedEvent => [
            HostAudienceSourceRuleFields(
              kind: switch (draft.kind) {
                _AudienceRuleKind.spend => HostAudienceSourceRuleKind.spend,
                _AudienceRuleKind.applicationStatus =>
                  HostAudienceSourceRuleKind.applicationStatus,
                _AudienceRuleKind.attendedEvent =>
                  HostAudienceSourceRuleKind.attendedEvent,
                _ => HostAudienceSourceRuleKind.formAnswer,
              },
              predicate: draft.sourcePredicate,
              options: filterOptions,
              enabled: enabled,
              onChanged: (value) =>
                  onChanged(draft.copyWith(sourcePredicate: value)),
            ),
          ],
          _AudienceRuleKind.computedSegment => [
            CatchField.select<HostAudienceSegment>(
              title: context.l10n.hostSavedAudienceSegment,
              contract: CatchContractConstraints
                  .upsertOrganizerSavedAudienceCallablePayloadDefinitionPredicatesItemsSegmentId,
              contractValue: (value) => value.wireValue,
              values: HostAudienceSegment.values,
              itemLabel: (value) => _customerFilterLabel(
                context,
                hostCustomerFilterForAudienceSegment(value),
              ),
              value: draft.segment,
              enabled: enabled,
              onChanged: (value) {
                if (value != null) onChanged(draft.copyWith(segment: value));
              },
            ),
          ],
          _AudienceRuleKind.manualTag => [
            CatchField.select<HostCustomerManualTag>(
              title: context.l10n.hostSavedAudienceTag,
              contract: CatchContractConstraints
                  .upsertOrganizerSavedAudienceCallablePayloadDefinitionPredicatesItemsManualTagId,
              contractValue: (value) => value.tagId,
              values: manualTags,
              itemLabel: (value) => value.label,
              value: manualTags
                  .where((tag) => tag.tagId == draft.manualTagId)
                  .firstOrNull,
              hintText: context.l10n.hostSavedAudienceChooseTag,
              enabled: enabled && manualTags.isNotEmpty,
              onChanged: (value) {
                if (value != null) {
                  onChanged(draft.copyWith(manualTagId: value.tagId));
                }
              },
            ),
          ],
          _AudienceRuleKind.attendanceCount => [
            CatchField.select<HostSavedAudienceAttendanceOperator>(
              title: context.l10n.hostSavedAudienceAttendanceComparison,
              contract: CatchContractConstraints
                  .upsertOrganizerSavedAudienceCallablePayloadDefinitionPredicatesItemsOperator,
              contractValue: (value) => value.name,
              values: HostSavedAudienceAttendanceOperator.values,
              itemLabel: (value) => switch (value) {
                HostSavedAudienceAttendanceOperator.atLeast =>
                  context.l10n.hostSavedAudienceAtLeast,
                HostSavedAudienceAttendanceOperator.atMost =>
                  context.l10n.hostSavedAudienceAtMost,
              },
              value: draft.operator,
              enabled: enabled,
              onChanged: (value) {
                if (value != null) onChanged(draft.copyWith(operator: value));
              },
            ),
            CatchField.stepper(
              title: context.l10n.hostSavedAudienceEventsAttended,
              contract: CatchContractConstraints
                  .upsertOrganizerSavedAudienceCallablePayloadDefinitionPredicatesItemsEventCount,
              value: draft.amount,
              unit: context.l10n.hostSavedAudienceEventsUnit,
              decreaseSemanticLabel:
                  context.l10n.hostSavedAudienceDecreaseCount,
              increaseSemanticLabel:
                  context.l10n.hostSavedAudienceIncreaseCount,
              enabled: enabled,
              onChanged: (value) =>
                  onChanged(draft.copyWith(amount: value.toInt())),
            ),
          ],
          _AudienceRuleKind.lastSeenWithinDays => [
            CatchField.stepper(
              title: context.l10n.hostSavedAudienceLastSeenWithin,
              contract: CatchContractConstraints
                  .upsertOrganizerSavedAudienceCallablePayloadDefinitionPredicatesItemsDays,
              value: draft.amount,
              unit: context.l10n.hostSavedAudienceDaysUnit,
              decreaseSemanticLabel: context.l10n.hostSavedAudienceDecreaseDays,
              increaseSemanticLabel: context.l10n.hostSavedAudienceIncreaseDays,
              enabled: enabled,
              onChanged: (value) =>
                  onChanged(draft.copyWith(amount: value.toInt())),
            ),
          ],
          _AudienceRuleKind.campaignReachable => [
            CatchField.read(
              title: context.l10n.hostSavedAudienceManagedReach,
              body: context.l10n.hostSavedAudienceManagedReachBody,
            ),
          ],
        },
      ],
    );
  }
}

enum _AudienceRuleKind {
  computedSegment('computedSegment'),
  manualTag('manualTag'),
  attendanceCount('attendanceCount'),
  lastSeenWithinDays('lastSeenWithinDays'),
  campaignReachable('reachableForIntent'),
  spend('spend'),
  applicationStatus('applicationStatus'),
  formAnswer('formAnswer'),
  attendedEvent('attendedEvent');

  const _AudienceRuleKind(this.wireValue);
  final String wireValue;
}

class _AudienceRuleDraft {
  const _AudienceRuleDraft({
    required this.kind,
    required this.segment,
    required this.manualTagId,
    required this.operator,
    required this.amount,
    this.sourcePredicate,
  });

  factory _AudienceRuleDraft.defaults() => const _AudienceRuleDraft(
    kind: _AudienceRuleKind.computedSegment,
    segment: HostAudienceSegment.regular,
    manualTagId: null,
    operator: HostSavedAudienceAttendanceOperator.atLeast,
    amount: 1,
  );

  factory _AudienceRuleDraft.fromPredicate(
    HostSavedAudiencePredicate predicate,
  ) => switch (predicate) {
    HostSavedAudienceStaticMembers() => throw StateError(
      'Static members do not use the rule editor.',
    ),
    HostSavedAudienceSpend() => _AudienceRuleDraft.defaults().copyWith(
      kind: _AudienceRuleKind.spend,
      sourcePredicate: predicate,
    ),
    HostSavedAudienceApplicationStatusRule() =>
      _AudienceRuleDraft.defaults().copyWith(
        kind: _AudienceRuleKind.applicationStatus,
        sourcePredicate: predicate,
      ),
    HostSavedAudienceFormAnswer() => _AudienceRuleDraft.defaults().copyWith(
      kind: _AudienceRuleKind.formAnswer,
      sourcePredicate: predicate,
    ),
    HostSavedAudienceAttendedEvent() => _AudienceRuleDraft.defaults().copyWith(
      kind: _AudienceRuleKind.attendedEvent,
      sourcePredicate: predicate,
    ),
    HostSavedAudienceComputedSegment(:final segment) => _AudienceRuleDraft(
      kind: _AudienceRuleKind.computedSegment,
      segment: segment,
      manualTagId: null,
      operator: HostSavedAudienceAttendanceOperator.atLeast,
      amount: 1,
    ),
    HostSavedAudienceManualTag(:final manualTagId) => _AudienceRuleDraft(
      kind: _AudienceRuleKind.manualTag,
      segment: HostAudienceSegment.regular,
      manualTagId: manualTagId,
      operator: HostSavedAudienceAttendanceOperator.atLeast,
      amount: 1,
    ),
    HostSavedAudienceAttendanceCount(:final operator, :final eventCount) =>
      _AudienceRuleDraft(
        kind: _AudienceRuleKind.attendanceCount,
        segment: HostAudienceSegment.regular,
        manualTagId: null,
        operator: operator,
        amount: eventCount,
      ),
    HostSavedAudienceLastSeenWithinDays(:final days) => _AudienceRuleDraft(
      kind: _AudienceRuleKind.lastSeenWithinDays,
      segment: HostAudienceSegment.regular,
      manualTagId: null,
      operator: HostSavedAudienceAttendanceOperator.atLeast,
      amount: days,
    ),
    HostSavedAudienceCampaignReachable() => const _AudienceRuleDraft(
      kind: _AudienceRuleKind.campaignReachable,
      segment: HostAudienceSegment.regular,
      manualTagId: null,
      operator: HostSavedAudienceAttendanceOperator.atLeast,
      amount: 1,
    ),
  };

  final _AudienceRuleKind kind;
  final HostAudienceSegment segment;
  final String? manualTagId;
  final HostSavedAudienceAttendanceOperator operator;
  final int amount;
  final HostSavedAudiencePredicate? sourcePredicate;

  _AudienceRuleDraft withKind(
    _AudienceRuleKind next,
    List<HostCustomerManualTag> manualTags,
  ) => copyWith(
    kind: next,
    sourcePredicate:
        next == _AudienceRuleKind.spend &&
            sourcePredicate is! HostSavedAudienceSpend
        ? const HostSavedAudienceSpend(
            operator: HostSavedAudienceAttendanceOperator.atLeast,
            currency: 'INR',
            amountMinor: 100000,
          )
        : sourcePredicate,
    manualTagId: next == _AudienceRuleKind.manualTag
        ? manualTagId ?? manualTags.firstOrNull?.tagId
        : manualTagId,
    amount: next == _AudienceRuleKind.lastSeenWithinDays
        ? amount.clamp(1, 3650)
        : amount,
  );

  _AudienceRuleDraft copyWith({
    _AudienceRuleKind? kind,
    HostAudienceSegment? segment,
    String? manualTagId,
    HostSavedAudienceAttendanceOperator? operator,
    int? amount,
    HostSavedAudiencePredicate? sourcePredicate,
  }) => _AudienceRuleDraft(
    kind: kind ?? this.kind,
    segment: segment ?? this.segment,
    manualTagId: manualTagId ?? this.manualTagId,
    operator: operator ?? this.operator,
    amount: amount ?? this.amount,
    sourcePredicate: sourcePredicate ?? this.sourcePredicate,
  );

  HostSavedAudiencePredicate? toPredicate() => switch (kind) {
    _AudienceRuleKind.spend =>
      sourcePredicate is HostSavedAudienceSpend ? sourcePredicate : null,
    _AudienceRuleKind.applicationStatus =>
      sourcePredicate is HostSavedAudienceApplicationStatusRule
          ? sourcePredicate
          : null,
    _AudienceRuleKind.formAnswer =>
      sourcePredicate is HostSavedAudienceFormAnswer ? sourcePredicate : null,
    _AudienceRuleKind.attendedEvent =>
      sourcePredicate is HostSavedAudienceAttendedEvent
          ? sourcePredicate
          : null,
    _AudienceRuleKind.computedSegment => HostSavedAudienceComputedSegment(
      segment,
    ),
    _AudienceRuleKind.manualTag =>
      manualTagId == null ? null : HostSavedAudienceManualTag(manualTagId!),
    _AudienceRuleKind.attendanceCount => HostSavedAudienceAttendanceCount(
      operator: operator,
      eventCount: amount,
    ),
    _AudienceRuleKind.lastSeenWithinDays => HostSavedAudienceLastSeenWithinDays(
      amount,
    ),
    _AudienceRuleKind.campaignReachable =>
      const HostSavedAudienceCampaignReachable(),
  };
}

String _audienceRuleKindLabel(BuildContext context, _AudienceRuleKind kind) =>
    switch (kind) {
      _AudienceRuleKind.spend => context.l10n.hostAudienceSpend,
      _AudienceRuleKind.applicationStatus =>
        context.l10n.hostAudienceRuleApplication,
      _AudienceRuleKind.formAnswer => context.l10n.hostAudienceRuleFormAnswer,
      _AudienceRuleKind.attendedEvent =>
        context.l10n.hostAudienceRuleNamedEvent,
      _AudienceRuleKind.computedSegment =>
        context.l10n.hostSavedAudienceRuleSegment,
      _AudienceRuleKind.manualTag => context.l10n.hostSavedAudienceRuleTag,
      _AudienceRuleKind.attendanceCount =>
        context.l10n.hostSavedAudienceRuleAttendance,
      _AudienceRuleKind.lastSeenWithinDays =>
        context.l10n.hostSavedAudienceRuleLastSeen,
      _AudienceRuleKind.campaignReachable =>
        context.l10n.hostSavedAudienceRuleManagedReach,
    };
