import 'dart:math';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_banner.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment_features.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_summary.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Host editor over published question metadata and aggregate roster coverage.
/// No participant answer or identity is present in its data contract.
class EventSuccessAssignmentFeaturesSection extends StatefulWidget {
  const EventSuccessAssignmentFeaturesSection({
    super.key,
    required this.eventId,
    required this.viewerUid,
    required this.enabled,
    required this.sequenceUnsupported,
    required this.formsState,
    required this.onLoadMoreForms,
    required this.onPreview,
    required this.onSave,
  });

  final String eventId;
  final String? viewerUid;
  final bool enabled;
  final bool sequenceUnsupported;
  final CatchAsyncState<List<HostFormSummary>> formsState;
  final VoidCallback? onLoadMoreForms;
  final Future<EventSuccessAssignmentFeaturePreview> Function({
    required String eventId,
    required List<EventSuccessAssignmentFeatureRule> rules,
    required List<String> sourceFormIds,
  }) onPreview;
  final Future<EventSuccessAssignmentFeatureSaveResult> Function({
    required String eventId,
    required int expectedRevision,
    required String requestId,
    required List<EventSuccessAssignmentFeatureRule> rules,
  }) onSave;

  @override
  State<EventSuccessAssignmentFeaturesSection> createState() =>
      _EventSuccessAssignmentFeaturesSectionState();
}

class _EventSuccessAssignmentFeaturesSectionState
    extends State<EventSuccessAssignmentFeaturesSection>
    with WidgetsBindingObserver {
  EventSuccessAssignmentFeaturePreview? _preview;
  List<EventSuccessAssignmentFeatureRule> _rules = const [];
  String? _selectedFormId;
  String? _requestId;
  Object? _error;
  bool _loading = false;
  bool _saving = false;
  bool _dirty = false;
  bool _conflict = false;
  bool _resumed = true;
  int _generation = 0;
  BuildContext? _ownedSheetContext;

  bool get _canRead =>
      _resumed && widget.viewerUid != null && widget.enabled &&
      !widget.sequenceUnsupported;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load(resetDraft: true);
    });
  }

  @override
  void didUpdateWidget(covariant EventSuccessAssignmentFeaturesSection old) {
    super.didUpdateWidget(old);
    if (old.eventId != widget.eventId ||
        old.viewerUid != widget.viewerUid ||
        old.enabled != widget.enabled ||
        old.sequenceUnsupported != widget.sequenceUnsupported) {
      _clear();
      if (_canRead) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _load(resetDraft: true);
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;
    if (resumed == _resumed) return;
    _resumed = resumed;
    _clear();
    if (resumed && _canRead) _load(resetDraft: true);
  }

  void _clear() {
    _dismissOwnedSheet();
    _generation++;
    if (!mounted) return;
    setState(() {
      _preview = null;
      _rules = const [];
      _selectedFormId = null;
      _requestId = null;
      _error = null;
      _loading = false;
      _saving = false;
      _dirty = false;
      _conflict = false;
    });
  }

  @override
  void dispose() {
    _dismissOwnedSheet();
    _generation++;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _dismissOwnedSheet() {
    final sheet = _ownedSheetContext;
    _ownedSheetContext = null;
    if (sheet != null && sheet.mounted &&
        ModalRoute.of(sheet)?.isCurrent == true) {
      Navigator.of(sheet).pop();
    }
  }

  Future<void> _load({required bool resetDraft}) async {
    if (!_canRead) return;
    final generation = ++_generation;
    final eventId = widget.eventId;
    final uid = widget.viewerUid;
    final sourceIds = _selectedFormId == null
        ? const <String>[] : <String>[_selectedFormId!];
    final draft = List<EventSuccessAssignmentFeatureRule>.of(_rules);
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      var next = await widget.onPreview(
        eventId: eventId,
        rules: resetDraft ? const [] : draft,
        sourceFormIds: sourceIds,
      );
      if (resetDraft && next.savedRules.isNotEmpty) {
        next = await widget.onPreview(
          eventId: eventId,
          rules: next.savedRules,
          sourceFormIds: sourceIds,
        );
      }
      if (!mounted || generation != _generation || !_canRead ||
          widget.eventId != eventId || widget.viewerUid != uid ||
          next.eventId != eventId) return;
      setState(() {
        _preview = next;
        if (resetDraft) {
          _rules = List.unmodifiable(next.savedRules);
          _dirty = false;
          _requestId = null;
        }
        _conflict = false;
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted || generation != _generation || !_canRead ||
          widget.eventId != eventId || widget.viewerUid != uid) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  void _changeRules(List<EventSuccessAssignmentFeatureRule> rules) {
    setState(() {
      _rules = List.unmodifiable(rules);
      _dirty = true;
      _requestId = null;
      _preview = null;
      _conflict = false;
    });
    _load(resetDraft: false);
  }

  Future<void> _save() async {
    final preview = _preview;
    if (!_canRead || preview == null || !_dirty || _loading || _saving) return;
    final generation = ++_generation;
    final eventId = widget.eventId;
    final uid = widget.viewerUid;
    final requestId = _requestId ?? _newRequestId();
    _requestId = requestId;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = await widget.onSave(
        eventId: eventId,
        expectedRevision: preview.revision,
        requestId: requestId,
        rules: _rules,
      );
      if (!mounted || generation != _generation || !_canRead ||
          widget.eventId != eventId || widget.viewerUid != uid ||
          saved.eventId != eventId) return;
      setState(() {
        _saving = false;
        _dirty = false;
        _requestId = null;
      });
      await _load(resetDraft: true);
    } on Object catch (error) {
      if (!mounted || generation != _generation || !_canRead ||
          widget.eventId != eventId || widget.viewerUid != uid) return;
      setState(() {
        _saving = false;
        _error = error;
        _conflict = error is AppException && error.code == 'aborted';
      });
    }
  }

  String _newRequestId() {
    final random = Random.secure();
    return 'afreq_${List.generate(20, (_) =>
      random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
  }

  Future<void> _chooseForm() async {
    final forms = widget.formsState.value
            ?.where((form) => form.activeVersionId != null)
            .toList(growable: false) ??
        const <HostFormSummary>[];
    if (forms.isEmpty) return;
    final selected = await showCatchBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        _ownedSheetContext = sheetContext;
        return CatchSheet.standard(
          title: sheetContext.l10n.eventMatchingHostSelectForm,
          child: CatchSectionList(
            emptyStateOmitted: true,
            children: [
              CatchSection.fieldRows(
                first: true,
                children: [
                  for (final form in forms)
                    CatchField.nav(
                      copy: catchFieldCopy(sheetContext.l10n),
                      title: form.title,
                      body: form.activeVersionId,
                      onTap: () => Navigator.of(sheetContext).pop(form.formId),
                    ),
                ],
              ),
              if (widget.onLoadMoreForms != null)
                CatchButton(
                  label: sheetContext.l10n.eventMatchingHostLoadMore,
                  onPressed: () {
                    widget.onLoadMoreForms?.call();
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
    _ownedSheetContext = null;
    if (!mounted || selected == null || !_canRead) return;
    setState(() => _selectedFormId = selected);
    await _load(resetDraft: false);
  }

  Future<void> _editRule(
    EventSuccessAssignmentFeatureSource source,
    EventSuccessAssignmentFeatureQuestion question,
    EventSuccessAssignmentFeatureRule? current,
  ) async {
    final updated = await showCatchBottomSheet<EventSuccessAssignmentFeatureRule>(
      context: context,
      builder: (sheetContext) {
        _ownedSheetContext = sheetContext;
        return _AssignmentFeatureRuleSheet(
          source: source,
          question: question,
          current: current,
        );
      },
    );
    _ownedSheetContext = null;
    if (!mounted || !_canRead || updated == null) return;
    final next = _rules.where((item) => item.featureId != updated.featureId)
        .toList()..add(updated);
    _changeRules(next);
  }

  @override
  Widget build(BuildContext context) {
    if (!_resumed || widget.viewerUid == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final preview = _preview;
    final sources = preview?.sources ?? const <EventSuccessAssignmentFeatureSource>[];
    final selectedSources = sources.where((source) =>
        source.formId == _selectedFormId && source.isActiveVersion).toList();
    final selected = selectedSources.isEmpty ? null : selectedSources.first;
    final coverage = {for (final row in preview?.coverage ??
        const <EventSuccessAssignmentFeatureCoverage>[]) row.featureId: row};

    return CatchSection.fieldRows(
      title: l10n.eventMatchingHostTitle,
      children: [
        CatchField.content(
          copy: catchFieldCopy(l10n),
          title: l10n.eventMatchingHostTitle,
          body: l10n.eventMatchingHostDescription,
        ),
        if (widget.sequenceUnsupported)
          CatchField.content(
            copy: catchFieldCopy(l10n),
            title: l10n.eventMatchingHostUnsupported,
            body: l10n.eventMatchingCoverageNote,
          )
        else if (!widget.enabled)
          CatchField.content(
            copy: catchFieldCopy(l10n),
            title: l10n.eventMatchingHostRefresh,
            body: l10n.eventMatchingHostDescription,
          )
        else ...[
          if (_loading)
            CatchField.content(
              copy: catchFieldCopy(l10n),
              title: l10n.eventMatchingHostPreview,
              body: l10n.eventMatchingCoverageNote,
            ),
          if (_conflict)
            CatchField.content(
              copy: catchFieldCopy(l10n),
              title: l10n.eventMatchingHostConflict,
              body: l10n.eventMatchingHostRefresh,
            ),
          if (_error != null && !_conflict)
            CatchLocalizedErrorBanner(_error!, context: AppErrorContext.event),
          if (widget.formsState.hasError)
            CatchLocalizedErrorBanner(
              widget.formsState.error!, context: AppErrorContext.event,
            ),
          if (!_loading && widget.formsState.hasData &&
              (widget.formsState.value?.isEmpty ?? true))
            CatchField.content(
              copy: catchFieldCopy(l10n),
              title: l10n.eventMatchingHostNoForms,
              body: l10n.eventMatchingHostDescription,
            ),
          CatchField.nav(
            copy: catchFieldCopy(l10n),
            title: l10n.eventMatchingHostSelectForm,
            valueText: selected?.formTitle,
            onTap: _loading || _saving ? null : _chooseForm,
          ),
          if (selected != null) ...[
            if (selected.questions.isEmpty)
              CatchField.content(
                copy: catchFieldCopy(l10n),
                title: l10n.eventMatchingHostNoQuestions,
                body: l10n.eventMatchingHostActiveVersion,
              ),
            for (final question in selected.questions)
              CatchField.nav(
                copy: catchFieldCopy(l10n),
                title: question.label,
                body: l10n.eventMatchingHostActiveVersion,
                valueText: _rules.any((item) =>
                    item.formId == selected.formId &&
                    item.versionId == selected.versionId &&
                    item.questionId == question.questionId)
                    ? l10n.eventMatchingHostSavedRules : null,
                onTap: _rules.length >= 8 && !_rules.any((item) =>
                    item.formId == selected.formId &&
                    item.versionId == selected.versionId &&
                    item.questionId == question.questionId)
                    ? null
                    : () => _editRule(selected, question,
                        _rules.where((item) =>
                            item.formId == selected.formId &&
                            item.versionId == selected.versionId &&
                            item.questionId == question.questionId).firstOrNull),
              ),
          ],
          if (_rules.length >= 8)
            CatchField.content(
              copy: catchFieldCopy(l10n),
              title: l10n.eventMatchingHostLimit,
              body: l10n.eventMatchingHostDescription,
            ),
          for (final rule in _rules)
            ...[
              CatchField.content(
                copy: catchFieldCopy(l10n),
                title: _questionLabel(sources, rule) ??
                    l10n.eventMatchingUnavailable,
                body: _modeLabel(context, rule.mode),
                valueText: coverage[rule.featureId] == null ? null :
                    l10n.eventMatchingHostCoverage(
                      usable: coverage[rule.featureId]!.usableCount,
                      roster: preview!.rosterCount,
                    ),
              ),
              CatchField.nav(
                copy: catchFieldCopy(l10n),
                title: l10n.eventMatchingHostRemove,
                body: _questionLabel(sources, rule) ??
                    l10n.eventMatchingUnavailable,
                onTap: _saving ? null : () => _removeRule(rule.featureId),
              ),
            ],
          CatchField.content(
            copy: catchFieldCopy(l10n),
            title: l10n.eventMatchingCoverageNote,
            body: l10n.eventMatchingHostDescription,
          ),
          CatchButton(
            label: l10n.eventMatchingHostRefresh,
            onPressed: _loading || _saving ? null :
                () => _load(resetDraft: !_conflict),
          ),
          if (_dirty)
            CatchButton(
              label: l10n.eventMatchingHostSave,
              fullWidth: true,
              onPressed: _preview == null || _loading || _saving || _conflict
                  ? null : _save,
            ),
        ],
      ],
    );
  }

  String? _questionLabel(
    List<EventSuccessAssignmentFeatureSource> sources,
    EventSuccessAssignmentFeatureRule rule,
  ) {
    for (final source in sources) {
      if (source.formId != rule.formId ||
          source.versionId != rule.versionId) continue;
      for (final question in source.questions) {
        if (question.questionId == rule.questionId) return question.label;
      }
    }
    return null;
  }

  String _modeLabel(BuildContext context, String mode) => switch (mode) {
    'preferSimilar' => context.l10n.eventMatchingHostSimilar,
    'preferDifferent' => context.l10n.eventMatchingHostDifferent,
    _ => context.l10n.eventMatchingHostBalance,
  };

  void _removeRule(String featureId) {
    _changeRules(_rules.where((rule) => rule.featureId != featureId).toList());
  }
}

class _AssignmentFeatureRuleSheet extends StatefulWidget {
  const _AssignmentFeatureRuleSheet({
    required this.source,
    required this.question,
    this.current,
  });

  final EventSuccessAssignmentFeatureSource source;
  final EventSuccessAssignmentFeatureQuestion question;
  final EventSuccessAssignmentFeatureRule? current;

  @override
  State<_AssignmentFeatureRuleSheet> createState() =>
      _AssignmentFeatureRuleSheetState();
}

class _AssignmentFeatureRuleSheetState
    extends State<_AssignmentFeatureRuleSheet> {
  late String _kind = widget.current?.kind ?? switch (widget.question.kind) {
    'multiChoice' => 'set',
    'number' => 'number',
    _ => 'category',
  };
  late String _mode = widget.current?.mode ?? 'preferSimilar';
  late double _weight = widget.current?.weight ?? 1;
  late List<String> _ordinalOrder = widget.current?.scoreByOptionId == null
      ? widget.question.options.map((item) => item.optionId).toList()
      : (widget.question.options.map((item) => item.optionId).toList()
          ..sort((a, b) => (widget.current!.scoreByOptionId![a] ?? 0)
              .compareTo(widget.current!.scoreByOptionId![b] ?? 0)));
  late final TextEditingController _minimum = TextEditingController(
    text: (widget.current?.minimum ?? widget.question.minNumber)?.toString(),
  );
  late final TextEditingController _maximum = TextEditingController(
    text: (widget.current?.maximum ?? widget.question.maxNumber)?.toString(),
  );
  bool _invalid = false;

  @override
  void dispose() {
    _minimum.dispose();
    _maximum.dispose();
    super.dispose();
  }

  void _submit() {
    try {
      final rule = EventSuccessAssignmentFeatureRule.fromPublishedQuestion(
        source: widget.source,
        question: widget.question,
        kind: _kind,
        mode: _mode,
        weight: _weight,
        ordinalOrder: _kind == 'ordinal' ? _ordinalOrder : null,
        minimum: _kind == 'number' ?
            double.tryParse(_minimum.text.trim()) : null,
        maximum: _kind == 'number' ?
            double.tryParse(_maximum.text.trim()) : null,
      );
      Navigator.of(context).pop(rule);
    } on ArgumentError {
      setState(() => _invalid = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kinds = widget.question.kind == 'singleChoice'
        ? const ['category', 'ordinal']
        : [widget.question.kind == 'number' ? 'number' : 'set'];
    return CatchSheet.standard(
      title: widget.question.label,
      subtitle: widget.source.formTitle,
      child: CatchSectionList(
        emptyStateOmitted: true,
        children: [
          CatchSection.fieldRows(
            first: true,
            children: [
              CatchField<String>.select(
                copy: catchFieldCopy(l10n),
                title: l10n.eventMatchingHostTransform,
                contract: CatchContractConstraints
                    .configureEventAssignmentFeaturesCallablePayloadRulesItemsKind,
                values: kinds,
                itemLabelBuilder: (kind) => switch (kind) {
                  'set' => l10n.eventMatchingHostSet,
                  'number' => l10n.eventMatchingHostNumber,
                  'ordinal' => l10n.eventMatchingHostOrdinal,
                  _ => l10n.eventMatchingHostCategory,
                },
                value: _kind,
                onChanged: (kind) {
                  if (kind != null) setState(() => _kind = kind);
                },
              ),
              CatchField<String>.select(
                copy: catchFieldCopy(l10n),
                title: l10n.eventMatchingHostPreference,
                contract: CatchContractConstraints
                    .configureEventAssignmentFeaturesCallablePayloadRulesItemsMode,
                values: const [
                  'preferSimilar', 'preferDifferent', 'balanceAcrossGroups',
                ],
                itemLabelBuilder: (mode) => switch (mode) {
                  'preferDifferent' => l10n.eventMatchingHostDifferent,
                  'balanceAcrossGroups' => l10n.eventMatchingHostBalance,
                  _ => l10n.eventMatchingHostSimilar,
                },
                value: _mode,
                onChanged: (mode) {
                  if (mode != null) setState(() => _mode = mode);
                },
              ),
              CatchField.stepper(
                copy: catchFieldCopy(l10n),
                title: l10n.eventMatchingHostWeight,
                contract: CatchContractConstraints
                    .configureEventAssignmentFeaturesCallablePayloadRulesItemsWeight,
                value: _weight,
                min: 0,
                max: 100,
                step: 1,
                decreaseSemanticLabel: l10n.eventMatchingHostDecreaseWeight,
                increaseSemanticLabel: l10n.eventMatchingHostIncreaseWeight,
                onChanged: (weight) => setState(() => _weight =
                    weight.toDouble()),
              ),
              if (_kind == 'number') ...[
                if (widget.question.minNumber == null ||
                    widget.question.maxNumber == null)
                  CatchField.content(
                    copy: catchFieldCopy(l10n),
                    title: l10n.eventMatchingHostMissingBounds,
                    body: l10n.eventMatchingHostValidation,
                  ),
                CatchField.input(
                  copy: catchFieldCopy(l10n),
                  title: l10n.eventMatchingHostMinimum,
                  contract: CatchContractConstraints
                      .configureEventAssignmentFeaturesCallablePayloadRulesItemsMinimum,
                  controller: _minimum,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true,
                  ),
                ),
                CatchField.input(
                  copy: catchFieldCopy(l10n),
                  title: l10n.eventMatchingHostMaximum,
                  contract: CatchContractConstraints
                      .configureEventAssignmentFeaturesCallablePayloadRulesItemsMaximum,
                  controller: _maximum,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true,
                  ),
                ),
              ],
              if (_kind == 'ordinal')
                for (var index = 0; index < _ordinalOrder.length; index++)
                  CatchField.nav(
                    copy: catchFieldCopy(l10n),
                    title: widget.question.options.firstWhere((option) =>
                        option.optionId == _ordinalOrder[index]).label,
                    body: l10n.eventMatchingHostMoveEarlier,
                    valueText: '${index + 1}',
                    onTap: index == 0 ? null : () => setState(() {
                      final item = _ordinalOrder.removeAt(index);
                      _ordinalOrder.insert(index - 1, item);
                    }),
                  ),
              if (_invalid)
                CatchField.content(
                  copy: catchFieldCopy(l10n),
                  title: l10n.eventMatchingHostValidation,
                  body: l10n.eventMatchingHostDescription,
                ),
            ],
          ),
          CatchButton(
            label: widget.current == null
                ? l10n.eventMatchingHostAddQuestion
                : l10n.eventMatchingHostSave,
            fullWidth: true,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
