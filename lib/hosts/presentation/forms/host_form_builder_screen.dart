import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/responsive/responsive_builder.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_action.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/domain/host_form.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_renderer.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_screen.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _BuilderAction { pause, resume, archive }

class HostFormBuilderScreen extends ConsumerStatefulWidget {
  const HostFormBuilderScreen({
    super.key,
    required this.organizerId,
    required this.formId,
  });

  final String organizerId;
  final String formId;

  @override
  ConsumerState<HostFormBuilderScreen> createState() =>
      _HostFormBuilderScreenState();
}

class _HostFormBuilderScreenState extends ConsumerState<HostFormBuilderScreen> {
  int? _selectedSection;
  int? _selectedQuestion;

  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(
      hostFormEditorControllerProvider(widget.organizerId, widget.formId),
    );
    final editorValue = catchAsyncStateFromAsyncValue(editor).value;
    final title =
        editorValue?.editor.definition.title ??
        context.l10n.hostFormBuilderTitle;
    final notifier = ref.read(
      hostFormEditorControllerProvider(
        widget.organizerId,
        widget.formId,
      ).notifier,
    );

    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title: title,
        subtitle: editorValue == null ? null : _saveLabel(context, editorValue),
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
        actions: [
          CatchIconAction(
            icon: CatchIcons.undoRounded,
            tooltip: context.l10n.hostFormUndo,
            onPressed: editorValue?.canUndo ?? false ? notifier.undo : null,
          ),
          CatchIconAction(
            icon: CatchIcons.redoRounded,
            tooltip: context.l10n.hostFormRedo,
            onPressed: editorValue?.canRedo ?? false ? notifier.redo : null,
          ),
          if (editorValue?.editor.form.activeVersionId != null)
            CatchIconAction(
              icon: CatchIcons.share,
              tooltip: context.l10n.hostFormShare,
              onPressed: () => context.pushNamed(
                Routes.hostFormShareScreen.name,
                pathParameters: {'formId': widget.formId},
                queryParameters: {'organizerId': widget.organizerId},
              ),
            ),
          CatchIconAction(
            icon: CatchIcons.visibilityOutlined,
            tooltip: context.l10n.hostFormPreview,
            onPressed: editorValue == null
                ? null
                : () => context.pushNamed(
                    Routes.hostFormPreviewScreen.name,
                    pathParameters: {'formId': widget.formId},
                    queryParameters: {'organizerId': widget.organizerId},
                  ),
          ),
          if (editorValue != null &&
              _builderActions(context, editorValue).isNotEmpty)
            CatchActionMenu<_BuilderAction>(
              tooltip: context.l10n.hostFormsActions,
              items: _builderActions(context, editorValue),
              onSelected: (action) => _setLifecycle(notifier, action),
            ),
        ],
      ),
      bottomNavigationBar:
          editorValue == null ||
              editorValue.editor.form.status == HostFormLifecycleStatus.archived
          ? null
          : CatchBottomAction(
              label:
                  editorValue.editor.form.status ==
                      HostFormLifecycleStatus.published
                  ? context.l10n.hostFormPublishChanges
                  : context.l10n.hostFormPublish,
              isLoading: editorValue.operationInProgress,
              onPressed: editorValue.operationInProgress
                  ? null
                  : () => _publish(notifier),
              footnote: context.l10n.hostFormPublishHelp,
            ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: CatchAsyncValueView<HostFormEditorState>(
          value: editor,
          onRetry: notifier.reload,
          initialLoadTimeout: null,
          loadingBuilder: (_) =>
              const CatchPageBody(child: CatchSkeletonRows(count: 8)),
          errorBuilder: (_, error, _) => CatchPageBody(
            child: CatchErrorState.fromError(
              error,
              context: AppErrorContext.forms,
              onRetry: notifier.reload,
            ),
          ),
          builder: (context, value) => ComponentResponsiveBuilder(
            breakpoint: CatchLayout.formBuilderExpandedBreakpoint,
            compact: (context) => CatchScreenBody(
              pb: CatchSpacing.s10,
              child: _CompactFormEditor(
                state: value,
                notifier: notifier,
                onSelectionChanged: (section, question) => setState(() {
                  _selectedSection = section;
                  _selectedQuestion = question;
                }),
              ),
            ),
            expanded: (context) {
              final definition = value.editor.definition;
              final sectionIndex = _validSectionIndex(definition);
              final questionIndex = _validQuestionIndex(
                definition,
                sectionIndex,
              );
              return _ExpandedFormEditor(
                state: value,
                notifier: notifier,
                sectionIndex: sectionIndex,
                questionIndex: questionIndex,
                onSelectionChanged: (section, question) => setState(() {
                  _selectedSection = section;
                  _selectedQuestion = question;
                }),
              );
            },
          ),
        ),
      ),
    );
  }

  int? _validSectionIndex(HostFormDefinition definition) {
    if (definition.sections.isEmpty) return null;
    final selected = _selectedSection ?? 0;
    return selected.clamp(0, definition.sections.length - 1).toInt();
  }

  int? _validQuestionIndex(HostFormDefinition definition, int? sectionIndex) {
    if (sectionIndex == null) return null;
    final questions = definition.sections[sectionIndex].questions;
    if (questions.isEmpty || _selectedQuestion == null) return null;
    return _selectedQuestion!.clamp(0, questions.length - 1).toInt();
  }

  List<CatchActionMenuItem<_BuilderAction>> _builderActions(
    BuildContext context,
    HostFormEditorState state,
  ) {
    final status = state.editor.form.status;
    return [
      if (status == HostFormLifecycleStatus.published)
        CatchActionMenuItem(
          value: _BuilderAction.pause,
          label: context.l10n.hostFormsPause,
          icon: CatchIcons.pauseCircleOutlineRounded,
        ),
      if (status == HostFormLifecycleStatus.paused)
        CatchActionMenuItem(
          value: _BuilderAction.resume,
          label: context.l10n.hostFormsResume,
          icon: CatchIcons.playCircleOutlineRounded,
        ),
      if (status != HostFormLifecycleStatus.archived)
        CatchActionMenuItem(
          value: _BuilderAction.archive,
          label: context.l10n.hostFormsArchive,
          icon: CatchIcons.archiveOutlined,
          isDestructive: true,
        ),
    ];
  }

  Future<void> _publish(HostFormEditorController notifier) async {
    final published = await notifier.publish();
    if (!mounted) return;
    if (published) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.hostFormPublished)));
    } else if (ref
            .read(
              hostFormEditorControllerProvider(
                widget.organizerId,
                widget.formId,
              ),
            )
            .asData
            ?.value
            .error
        case final error?) {
      showCatchErrorSnackBar(context, error);
    }
  }

  Future<void> _setLifecycle(
    HostFormEditorController notifier,
    _BuilderAction action,
  ) async {
    final lifecycle = switch (action) {
      _BuilderAction.pause => HostFormLifecycleAction.pause,
      _BuilderAction.resume => HostFormLifecycleAction.resume,
      _BuilderAction.archive => HostFormLifecycleAction.archive,
    };
    final changed = await notifier.setLifecycle(lifecycle);
    if (!mounted || changed) return;
    final error = ref
        .read(
          hostFormEditorControllerProvider(widget.organizerId, widget.formId),
        )
        .asData
        ?.value
        .error;
    if (error != null) showCatchErrorSnackBar(context, error);
  }
}

class _CompactFormEditor extends StatelessWidget {
  const _CompactFormEditor({
    required this.state,
    required this.notifier,
    required this.onSelectionChanged,
  });

  final HostFormEditorState state;
  final HostFormEditorController notifier;
  final void Function(int section, int? question) onSelectionChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _FormStatusNotices(state: state, notifier: notifier),
      _FormSettings(definition: state.editor.definition, notifier: notifier),
      gapH24,
      _SectionsEditor(
        definition: state.editor.definition,
        notifier: notifier,
        onSelectionChanged: onSelectionChanged,
      ),
    ],
  );
}

class _ExpandedFormEditor extends StatelessWidget {
  const _ExpandedFormEditor({
    required this.state,
    required this.notifier,
    required this.sectionIndex,
    required this.questionIndex,
    required this.onSelectionChanged,
  });

  final HostFormEditorState state;
  final HostFormEditorController notifier;
  final int? sectionIndex;
  final int? questionIndex;
  final void Function(int section, int? question) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final definition = state.editor.definition;
    return Column(
      children: [
        _FormStatusNotices(state: state, notifier: notifier, padded: true),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: CatchLayout.formBuilderOutlineWidth,
                child: SingleChildScrollView(
                  padding: CatchInsets.pageBody,
                  child: _FormOutline(
                    definition: definition,
                    selectedSection: sectionIndex,
                    selectedQuestion: questionIndex,
                    onSelected: onSelectionChanged,
                    notifier: notifier,
                  ),
                ),
              ),
              VerticalDivider(width: CatchStroke.hairline, color: t.line),
              Expanded(
                child: ColoredBox(
                  color: t.surface,
                  child: SingleChildScrollView(
                    padding: CatchInsets.pageBody,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: CatchLayout.maxContentWidth,
                        ),
                        child: HostFormRenderer(definition: definition),
                      ),
                    ),
                  ),
                ),
              ),
              VerticalDivider(width: CatchStroke.hairline, color: t.line),
              SizedBox(
                width: CatchLayout.formBuilderInspectorWidth,
                child: SingleChildScrollView(
                  padding: CatchInsets.pageBody,
                  child: _Inspector(
                    definition: definition,
                    sectionIndex: sectionIndex,
                    questionIndex: questionIndex,
                    notifier: notifier,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormStatusNotices extends StatelessWidget {
  const _FormStatusNotices({
    required this.state,
    required this.notifier,
    this.padded = false,
  });

  final HostFormEditorState state;
  final HostFormEditorController notifier;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final notices = <Widget>[
      if (state.saveState == HostFormSaveState.conflict) ...[
        CatchNotice(
          notice: CatchNoticeData(
            id: 'form-save-conflict',
            title: context.l10n.hostFormConflictTitle,
            message: context.l10n.hostFormConflictBody,
            tone: CatchNoticeTone.warning,
            actionLabel: context.l10n.hostFormReload,
            onAction: notifier.reload,
            duration: null,
          ),
        ),
        gapH12,
      ] else if (state.saveState == HostFormSaveState.failed) ...[
        CatchNotice(
          notice: CatchNoticeData(
            id: 'form-save-failed',
            title: context.l10n.hostFormSaveFailed,
            message: state.error?.toString(),
            tone: CatchNoticeTone.danger,
            actionLabel: context.l10n.hostFormRetrySave,
            onAction: () => notifier.saveNow(),
            duration: null,
          ),
        ),
        gapH12,
      ],
      if (state.editor.validationIssues.isNotEmpty) ...[
        CatchNotice(
          notice: CatchNoticeData(
            id: 'form-validation',
            title: context.l10n.hostFormValidationTitle(
              count: state.editor.validationIssues.length,
            ),
            message: state.editor.validationIssues.first.message,
            tone: state.hasBlockingValidationErrors
                ? CatchNoticeTone.danger
                : CatchNoticeTone.warning,
            duration: null,
            dismissible: false,
          ),
        ),
        gapH12,
      ],
    ];
    if (notices.isEmpty) return const SizedBox.shrink();
    final content = Column(children: notices);
    return padded
        ? Padding(padding: CatchInsets.formBuilderNotices, child: content)
        : content;
  }
}

class _FormSettings extends StatelessWidget {
  const _FormSettings({required this.definition, required this.notifier});

  final HostFormDefinition definition;
  final HostFormEditorController notifier;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CatchSection.fieldRows(
        title: context.l10n.hostFormSettings,
        first: true,
        children: [
          CatchField.input(
            key: ValueKey('form-title-${definition.title}'),
            title: context.l10n.hostFormTitleLabel,
            initialValue: definition.title,
            contractExemption:
                'The backend form definition validates this title.',
            onBlur: (value) => notifier.updateMetadata(title: value.trim()),
          ),
          CatchField.input(
            key: ValueKey('form-description-${definition.description}'),
            title: context.l10n.hostFormDescriptionLabel,
            initialValue: definition.description,
            contractExemption:
                'The backend form definition validates this optional description.',
            isOptional: true,
            maxLines: 3,
            onBlur: (value) => notifier.updateMetadata(
              description: value.trim(),
              clearDescription: value.trim().isEmpty,
            ),
          ),
          CatchField.select<HostFormPurpose>(
            title: context.l10n.hostFormPurposeLabel,
            contract: CatchContractConstraints
                .organizerFormDraftDocumentDefinitionPurpose,
            contractValue: (value) => value.name,
            values: HostFormPurpose.values,
            value: definition.purpose,
            itemLabel: (value) => hostFormPurposeLabel(context, value),
            onChanged: (value) => notifier.updateMetadata(purpose: value),
          ),
          CatchField.select<HostFormIdentityPolicy>(
            title: context.l10n.hostFormIdentityLabel,
            contract: CatchContractConstraints
                .organizerFormDraftDocumentDefinitionIdentityPolicy,
            contractValue: (value) => value.name,
            values: HostFormIdentityPolicy.values,
            value: definition.identityPolicy,
            itemLabel: (value) => hostFormIdentityLabel(context, value),
            onChanged: (value) =>
                notifier.updateMetadata(identityPolicy: value),
          ),
        ],
      ),
      gapH20,
      CatchSection.fieldRows(
        title: context.l10n.hostFormAppearance,
        children: [
          CatchField.select<HostFormAppearancePreset>(
            title: context.l10n.hostFormAppearancePreset,
            contract: CatchContractConstraints
                .organizerFormDraftDocumentDefinitionAppearancePreset,
            contractValue: (value) => value.name,
            values: HostFormAppearancePreset.values,
            value: definition.appearancePreset,
            itemLabel: (value) => _appearanceLabel(context, value),
            onChanged: (value) =>
                notifier.updateMetadata(appearancePreset: value),
          ),
          if (definition.appearancePreset == HostFormAppearancePreset.activity)
            CatchField.input(
              key: ValueKey('form-activity-${definition.activityKind}'),
              title: context.l10n.hostFormActivityKind,
              initialValue: definition.activityKind,
              isOptional: true,
              contractExemption:
                  'The backend form definition validates activity labels.',
              onBlur: (value) => notifier.updateMetadata(
                activityKind: value.trim(),
                clearActivityKind: value.trim().isEmpty,
              ),
            ),
        ],
      ),
      gapH20,
      CatchSection.fieldRows(
        title: context.l10n.hostFormAvailability,
        children: [
          _DateFormSchemaField(
            title: context.l10n.hostFormOpensAt,
            value: definition.opensAt,
            onChanged: (value) =>
                notifier.updateMetadata(opensAt: value, setOpensAt: true),
          ),
          _DateFormSchemaField(
            title: context.l10n.hostFormClosesAt,
            value: definition.closesAt,
            endOfDay: true,
            onChanged: (value) =>
                notifier.updateMetadata(closesAt: value, setClosesAt: true),
          ),
          CatchField.input(
            key: ValueKey('form-limit-${definition.responseLimit}'),
            title: context.l10n.hostFormResponseLimit,
            initialValue: definition.responseLimit?.toString(),
            isOptional: true,
            keyboardType: TextInputType.number,
            contractExemption: 'The form contract validates response limits.',
            onBlur: (value) => notifier.updateMetadata(
              responseLimit: _nullableInt(value),
              setResponseLimit: true,
            ),
          ),
          CatchField.input(
            key: ValueKey('form-closed-${definition.closedMessage}'),
            title: context.l10n.hostFormClosedMessage,
            initialValue: definition.closedMessage,
            isOptional: true,
            maxLines: 3,
            contractExemption: 'The form contract validates closed copy.',
            onBlur: (value) => notifier.updateMetadata(
              closedMessage: value.trim(),
              clearClosedMessage: value.trim().isEmpty,
            ),
          ),
        ],
      ),
      gapH20,
      CatchSection.fieldRows(
        title: context.l10n.hostFormConsent,
        children: [
          CatchField.input(
            key: ValueKey('form-consent-${definition.consentCopy}'),
            title: context.l10n.hostFormConsentCopy,
            initialValue: definition.consentCopy,
            maxLines: 4,
            contractExemption: 'The form contract validates consent copy.',
            onBlur: (value) =>
                notifier.updateMetadata(consentCopy: value.trim()),
          ),
          CatchField.input(
            key: ValueKey('form-consent-version-${definition.consentVersion}'),
            title: context.l10n.hostFormConsentVersion,
            initialValue: definition.consentVersion,
            contractExemption: 'The form contract validates consent versions.',
            onBlur: (value) =>
                notifier.updateMetadata(consentVersion: value.trim()),
          ),
          CatchField.input(
            key: ValueKey('form-retention-${definition.retentionCopy}'),
            title: context.l10n.hostFormRetentionCopy,
            initialValue: definition.retentionCopy,
            maxLines: 3,
            contractExemption: 'The form contract validates retention copy.',
            onBlur: (value) =>
                notifier.updateMetadata(retentionCopy: value.trim()),
          ),
        ],
      ),
      gapH20,
      CatchSection.fieldRows(
        title: context.l10n.hostFormCompletion,
        children: [
          CatchField.input(
            key: ValueKey('form-completion-${definition.completionTitle}'),
            title: context.l10n.hostFormCompletionTitleLabel,
            initialValue: definition.completionTitle,
            contractExemption:
                'The backend form definition validates completion copy.',
            onBlur: (value) =>
                notifier.updateMetadata(completionTitle: value.trim()),
          ),
          CatchField.input(
            key: ValueKey(
              'form-completion-message-${definition.completionMessage}',
            ),
            title: context.l10n.hostFormCompletionMessageLabel,
            initialValue: definition.completionMessage,
            isOptional: true,
            maxLines: 3,
            contractExemption:
                'The backend form definition validates completion copy.',
            onBlur: (value) => notifier.updateMetadata(
              completionMessage: value.trim(),
              clearCompletionMessage: value.trim().isEmpty,
            ),
          ),
          CatchField.select<HostFormCompletionAction>(
            title: context.l10n.hostFormCompletionActionLabel,
            contract: CatchContractConstraints
                .organizerFormDraftDocumentDefinitionCompletionActionKind,
            contractValue: (value) => value.name,
            values: HostFormCompletionAction.values,
            value: definition.completionAction,
            itemLabel: (value) => _completionActionLabel(context, value),
            onChanged: (value) => notifier.updateMetadata(
              completionAction: value,
              clearCompletionActionLabel:
                  value == HostFormCompletionAction.none,
              clearCompletionActionUrl:
                  value != HostFormCompletionAction.externalUrl,
            ),
          ),
          if (definition.completionAction != HostFormCompletionAction.none)
            CatchField.input(
              key: ValueKey(
                'form-completion-label-${definition.completionActionLabel}',
              ),
              title: context.l10n.hostFormCompletionButtonLabel,
              initialValue: definition.completionActionLabel,
              contractExemption:
                  'The form contract validates completion button labels.',
              onBlur: (value) => notifier.updateMetadata(
                completionActionLabel: value.trim(),
                clearCompletionActionLabel: value.trim().isEmpty,
              ),
            ),
          if (definition.completionAction ==
              HostFormCompletionAction.externalUrl)
            CatchField.input(
              key: ValueKey(
                'form-completion-url-${definition.completionActionUrl}',
              ),
              title: context.l10n.hostFormCompletionUrl,
              initialValue: definition.completionActionUrl,
              keyboardType: TextInputType.url,
              contractExemption:
                  'The form contract validates completion destinations.',
              onBlur: (value) => notifier.updateMetadata(
                completionActionUrl: value.trim(),
                clearCompletionActionUrl: value.trim().isEmpty,
              ),
            ),
        ],
      ),
      gapH20,
      CatchSection.fieldRows(
        title: context.l10n.hostFormLogic,
        footer: Text(
          context.l10n.hostFormLogicHelp,
          style: CatchTextStyles.supporting(context),
        ),
        children: [
          for (final ruleEntry in definition.logicRules.indexed)
            CatchField.action(
              title: _logicRuleSummary(context, definition, ruleEntry.$2),
              action: IconButton(
                tooltip: context.l10n.hostFormRemoveRule,
                icon: Icon(CatchIcons.deleteOutlineRounded),
                onPressed: () => notifier.removeLogicRule(ruleEntry.$1),
              ),
              onTap: null,
            ),
          CatchField.add(
            title: context.l10n.hostFormAddRule,
            onTap: () => _showLogicRuleBuilder(
              context,
              definition: definition,
              notifier: notifier,
            ),
          ),
        ],
      ),
    ],
  );
}

class _SectionsEditor extends StatelessWidget {
  const _SectionsEditor({
    required this.definition,
    required this.notifier,
    required this.onSelectionChanged,
  });

  final HostFormDefinition definition;
  final HostFormEditorController notifier;
  final void Function(int section, int? question) onSelectionChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final sectionEntry in definition.sections.indexed) ...[
        _SectionEditor(
          sectionIndex: sectionEntry.$1,
          section: sectionEntry.$2,
          sectionCount: definition.sections.length,
          notifier: notifier,
          onSelectionChanged: onSelectionChanged,
        ),
        gapH20,
      ],
      CatchButton(
        label: context.l10n.hostFormAddSection,
        icon: Icon(CatchIcons.addRounded, size: CatchIcon.sm),
        variant: CatchButtonVariant.secondary,
        fullWidth: true,
        onPressed: notifier.addSection,
      ),
    ],
  );
}

class _SectionEditor extends StatelessWidget {
  const _SectionEditor({
    required this.sectionIndex,
    required this.section,
    required this.sectionCount,
    required this.notifier,
    required this.onSelectionChanged,
  });

  final int sectionIndex;
  final HostFormSection section;
  final int sectionCount;
  final HostFormEditorController notifier;
  final void Function(int section, int? question) onSelectionChanged;

  @override
  Widget build(BuildContext context) => CatchSection.fieldRows(
    title: context.l10n.hostFormSectionNumber(number: sectionIndex + 1),
    first: sectionIndex == 0,
    children: [
      CatchField.input(
        key: ValueKey('section-title-${section.sectionId}-${section.title}'),
        title: context.l10n.hostFormSectionTitleLabel,
        initialValue: section.title,
        contractExemption: 'The backend form definition validates sections.',
        onFocusChanged: (focused) {
          if (focused) onSelectionChanged(sectionIndex, null);
        },
        onBlur: (value) =>
            notifier.updateSection(sectionIndex, title: value.trim()),
      ),
      for (final questionEntry in section.questions.indexed)
        _QuestionEditor(
          key: ValueKey(questionEntry.$2.questionId),
          sectionIndex: sectionIndex,
          questionIndex: questionEntry.$1,
          question: questionEntry.$2,
          questionCount: section.questions.length,
          notifier: notifier,
          onSelected: () => onSelectionChanged(sectionIndex, questionEntry.$1),
        ),
      CatchField.add(
        title: context.l10n.hostFormAddQuestion,
        icon: CatchIcons.addRounded,
        onTap: () => _showQuestionTypePicker(
          context,
          onSelected: (kind) => notifier.addQuestion(sectionIndex, kind),
        ),
      ),
      CatchField.action(
        title: context.l10n.hostFormMoveSectionUp,
        icon: CatchIcons.arrowUpwardRounded,
        onTap: sectionIndex == 0
            ? null
            : () => notifier.moveSection(sectionIndex, -1),
      ),
      CatchField.action(
        title: context.l10n.hostFormMoveSectionDown,
        icon: CatchIcons.arrowDownwardRounded,
        onTap: sectionIndex == sectionCount - 1
            ? null
            : () => notifier.moveSection(sectionIndex, 1),
      ),
      CatchField.action(
        title: context.l10n.hostFormRemoveSection,
        icon: CatchIcons.deleteOutlineRounded,
        tone: CatchFieldTone.danger,
        onTap: sectionCount <= 1
            ? null
            : () => notifier.removeSection(sectionIndex),
      ),
    ],
  );
}

class _QuestionEditor extends StatefulWidget {
  const _QuestionEditor({
    super.key,
    required this.sectionIndex,
    required this.questionIndex,
    required this.question,
    required this.questionCount,
    required this.notifier,
    required this.onSelected,
  });

  final int sectionIndex;
  final int questionIndex;
  final HostFormQuestion question;
  final int questionCount;
  final HostFormEditorController notifier;
  final VoidCallback onSelected;

  @override
  State<_QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<_QuestionEditor> {
  bool _open = false;

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) widget.onSelected();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final notifier = widget.notifier;
    final sectionIndex = widget.sectionIndex;
    final questionIndex = widget.questionIndex;
    final questionCount = widget.questionCount;
    final duration = MediaQuery.maybeOf(context)?.disableAnimations == true
        ? Duration.zero
        : CatchFieldTokens.standard;
    return _HostFormSchemaBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchField.content(
            title: question.label,
            body: hostFormQuestionKindLabel(context, question.kind),
            onTap: _toggle,
            showChevron: false,
            action: Icon(
              _open
                  ? CatchIcons.expandLessRounded
                  : CatchIcons.expandMoreRounded,
              size: CatchIcon.sm,
            ),
          ),
          AnimatedSize(
            duration: duration,
            curve: CatchMotion.standardCurve,
            alignment: Alignment.topCenter,
            child: !_open
                ? const SizedBox.shrink()
                : CatchSection.fieldRows(
                    first: true,
                    children: [
                      CatchField.input(
                        key: ValueKey(
                          'question-label-${question.questionId}-${question.label}',
                        ),
                        title: context.l10n.hostFormQuestionLabel,
                        initialValue: question.label,
                        contractExemption:
                            'The backend form definition validates questions.',
                        onBlur: (value) => notifier.updateQuestion(
                          sectionIndex,
                          questionIndex,
                          label: value.trim(),
                        ),
                      ),
                      CatchField.select<HostFormQuestionKind>(
                        title: context.l10n.hostFormQuestionType,
                        contract: CatchContractConstraints
                            .organizerFormDraftDocumentDefinitionSectionsItemsQuestionsItemsKind,
                        contractValue: (value) => value.name,
                        values: HostFormQuestionKind.values,
                        value: question.kind,
                        itemLabel: (value) =>
                            hostFormQuestionKindLabel(context, value),
                        onChanged: (value) => notifier.updateQuestion(
                          sectionIndex,
                          questionIndex,
                          kind: value,
                        ),
                      ),
                      CatchField.input(
                        key: ValueKey(
                          'question-help-${question.questionId}-${question.helpText}',
                        ),
                        title: context.l10n.hostFormQuestionHelpLabel,
                        initialValue: question.helpText,
                        isOptional: true,
                        maxLines: 3,
                        contractExemption:
                            'The form contract validates question help.',
                        onBlur: (value) => notifier.updateQuestion(
                          sectionIndex,
                          questionIndex,
                          helpText: value.trim(),
                          clearHelpText: value.trim().isEmpty,
                        ),
                      ),
                      CatchField.toggle(
                        title: context.l10n.hostFormQuestionRequired,
                        value: question.required,
                        contractExemption:
                            'Requiredness is part of the form definition.',
                        onChanged: (value) => notifier.updateQuestion(
                          sectionIndex,
                          questionIndex,
                          required: value,
                        ),
                      ),
                      CatchField.select<HostFormPrivacyClass>(
                        title: context.l10n.hostFormPrivacyLabel,
                        contract: CatchContractConstraints
                            .organizerFormDraftDocumentDefinitionSectionsItemsQuestionsItemsPrivacyClass,
                        contractValue: (value) => value.name,
                        values: HostFormPrivacyClass.values,
                        value: question.privacyClass,
                        itemLabel: (value) => _privacyLabel(context, value),
                        onChanged: (value) => notifier.updateQuestion(
                          sectionIndex,
                          questionIndex,
                          privacyClass: value,
                        ),
                      ),
                      CatchField.select<HostFormPrefillPolicy>(
                        title: context.l10n.hostFormPrefillLabel,
                        contract: CatchContractConstraints
                            .organizerFormDraftDocumentDefinitionSectionsItemsQuestionsItemsPrefillPolicy,
                        contractValue: (value) => value.name,
                        values: HostFormPrefillPolicy.values,
                        value: question.prefillPolicy,
                        itemLabel: (value) => _prefillLabel(context, value),
                        onChanged: (value) => notifier.updateQuestion(
                          sectionIndex,
                          questionIndex,
                          prefillPolicy: value,
                        ),
                      ),
                      CatchField.select<HostFormPresentation>(
                        title: context.l10n.hostFormPresentationLabel,
                        contract: CatchContractConstraints
                            .organizerFormDraftDocumentDefinitionSectionsItemsQuestionsItemsHostPresentation,
                        contractValue: (value) => value.name,
                        values: HostFormPresentation.values,
                        value: question.hostPresentation,
                        itemLabel: (value) =>
                            _presentationLabel(context, value),
                        onChanged: (value) => notifier.updateQuestion(
                          sectionIndex,
                          questionIndex,
                          hostPresentation: value,
                        ),
                      ),
                      for (final optionEntry in question.options.indexed)
                        CatchField.input(
                          key: ValueKey(
                            'question-option-${question.questionId}-${optionEntry.$2.optionId}',
                          ),
                          title: context.l10n.hostFormOptionNumber(
                            number: optionEntry.$1 + 1,
                          ),
                          initialValue: optionEntry.$2.label,
                          contractExemption:
                              'The backend validates form choice options.',
                          onBlur: (value) => notifier.updateOption(
                            sectionIndex,
                            questionIndex,
                            optionEntry.$1,
                            label: value.trim(),
                          ),
                        ),
                      if (question.options.isNotEmpty)
                        CatchField.add(
                          title: context.l10n.hostFormAddOption,
                          onTap: () =>
                              notifier.addOption(sectionIndex, questionIndex),
                        ),
                      _QuestionValidationFormSchemaFields(
                        sectionIndex: sectionIndex,
                        questionIndex: questionIndex,
                        question: question,
                        notifier: notifier,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CatchButton(
                              label: context.l10n.hostFormMoveUp,
                              variant: CatchButtonVariant.ghost,
                              onPressed: questionIndex == 0
                                  ? null
                                  : () => notifier.moveQuestion(
                                      sectionIndex,
                                      questionIndex,
                                      -1,
                                    ),
                            ),
                          ),
                          gapW8,
                          Expanded(
                            child: CatchButton(
                              label: context.l10n.hostFormMoveDown,
                              variant: CatchButtonVariant.ghost,
                              onPressed: questionIndex == questionCount - 1
                                  ? null
                                  : () => notifier.moveQuestion(
                                      sectionIndex,
                                      questionIndex,
                                      1,
                                    ),
                            ),
                          ),
                        ],
                      ),
                      CatchButton(
                        label: context.l10n.hostFormRemoveQuestion,
                        variant: CatchButtonVariant.danger,
                        fullWidth: true,
                        onPressed: () => notifier.removeQuestion(
                          sectionIndex,
                          questionIndex,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _QuestionValidationFormSchemaFields extends StatelessWidget {
  const _QuestionValidationFormSchemaFields({
    required this.sectionIndex,
    required this.questionIndex,
    required this.question,
    required this.notifier,
  });

  final int sectionIndex;
  final int questionIndex;
  final HostFormQuestion question;
  final HostFormEditorController notifier;

  @override
  Widget build(BuildContext context) {
    final validation = question.validation;
    void update(HostFormQuestionValidation next) =>
        notifier.updateQuestion(sectionIndex, questionIndex, validation: next);
    final fields = <Widget>[];
    if (question.kind == HostFormQuestionKind.shortText ||
        question.kind == HostFormQuestionKind.longText) {
      fields.addAll([
        _NumberFormSchemaField(
          fieldKey: 'min-length',
          questionId: question.questionId,
          title: context.l10n.hostFormMinimumLength,
          value: validation.minLength,
          onChanged: (value) => update(validation.copyWith(minLength: value)),
        ),
        _NumberFormSchemaField(
          fieldKey: 'max-length',
          questionId: question.questionId,
          title: context.l10n.hostFormMaximumLength,
          value: validation.maxLength,
          onChanged: (value) => update(validation.copyWith(maxLength: value)),
        ),
        _HostFormSchemaBoundary(
          child: CatchField.select<HostFormPatternPreset>(
            title: context.l10n.hostFormPatternLabel,
            contract: CatchContractConstraints
                .organizerFormDraftDocumentDefinitionSectionsItemsQuestionsItemsValidationPatternPreset,
            contractValue: (value) => value.name,
            values: HostFormPatternPreset.values,
            value: validation.patternPreset,
            hintText: context.l10n.hostFormPatternNone,
            itemLabel: (value) => _patternLabel(context, value),
            onChanged: (value) {
              if (value != null) {
                update(validation.copyWith(patternPreset: value));
              }
            },
          ),
        ),
        if (validation.patternPreset != null)
          _HostFormSchemaBoundary(
            child: CatchField.action(
              title: context.l10n.hostFormPatternNone,
              icon: CatchIcons.closeRounded,
              onTap: () => update(validation.copyWith(patternPreset: null)),
            ),
          ),
      ]);
    }
    if (question.kind == HostFormQuestionKind.number) {
      fields.addAll([
        _NumberFormSchemaField(
          fieldKey: 'min-number',
          questionId: question.questionId,
          title: context.l10n.hostFormMinimumNumber,
          value: validation.minNumber,
          decimal: true,
          onChanged: (value) => update(validation.copyWith(minNumber: value)),
        ),
        _NumberFormSchemaField(
          fieldKey: 'max-number',
          questionId: question.questionId,
          title: context.l10n.hostFormMaximumNumber,
          value: validation.maxNumber,
          decimal: true,
          onChanged: (value) => update(validation.copyWith(maxNumber: value)),
        ),
      ]);
    }
    if (question.kind == HostFormQuestionKind.date) {
      fields.addAll([
        _TextValidationFormSchemaField(
          fieldKey: 'earliest-date',
          questionId: question.questionId,
          title: context.l10n.hostFormEarliestDate,
          value: validation.earliestDate,
          onChanged: (value) =>
              update(validation.copyWith(earliestDate: value)),
        ),
        _TextValidationFormSchemaField(
          fieldKey: 'latest-date',
          questionId: question.questionId,
          title: context.l10n.hostFormLatestDate,
          value: validation.latestDate,
          onChanged: (value) => update(validation.copyWith(latestDate: value)),
        ),
      ]);
    }
    if (question.kind == HostFormQuestionKind.multiChoice) {
      fields.addAll([
        _NumberFormSchemaField(
          fieldKey: 'min-selections',
          questionId: question.questionId,
          title: context.l10n.hostFormMinimumSelections,
          value: validation.minSelections,
          onChanged: (value) =>
              update(validation.copyWith(minSelections: value)),
        ),
        _NumberFormSchemaField(
          fieldKey: 'max-selections',
          questionId: question.questionId,
          title: context.l10n.hostFormMaximumSelections,
          value: validation.maxSelections,
          onChanged: (value) =>
              update(validation.copyWith(maxSelections: value)),
        ),
      ]);
    }
    if (question.kind == HostFormQuestionKind.file) {
      fields.addAll([
        _NumberFormSchemaField(
          fieldKey: 'max-files',
          questionId: question.questionId,
          title: context.l10n.hostFormMaximumFiles,
          value: validation.maxFileCount,
          onChanged: (value) =>
              update(validation.copyWith(maxFileCount: value)),
        ),
        _NumberFormSchemaField(
          fieldKey: 'max-file-size',
          questionId: question.questionId,
          title: context.l10n.hostFormMaximumFileMegabytes,
          value: validation.maxFileSizeBytes == null
              ? null
              : validation.maxFileSizeBytes! ~/ (1024 * 1024),
          onChanged: (value) => update(
            validation.copyWith(
              maxFileSizeBytes: value == null ? null : value * 1024 * 1024,
            ),
          ),
        ),
        _TextValidationFormSchemaField(
          fieldKey: 'mime-types',
          questionId: question.questionId,
          title: context.l10n.hostFormAllowedFileTypes,
          value: validation.allowedMimeTypes.join(', '),
          onChanged: (value) => update(
            validation.copyWith(
              allowedMimeTypes: value == null
                  ? const []
                  : value
                        .split(',')
                        .map((item) => item.trim().toLowerCase())
                        .where((item) => item.isNotEmpty)
                        .toSet()
                        .toList(growable: false),
            ),
          ),
        ),
      ]);
    }
    fields.add(
      _TextValidationFormSchemaField(
        fieldKey: 'custom-error',
        questionId: question.questionId,
        title: context.l10n.hostFormCustomError,
        value: validation.customError,
        onChanged: (value) => update(validation.copyWith(customError: value)),
      ),
    );
    return _HostFormSchemaBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: fields,
      ),
    );
  }
}

class _NumberFormSchemaField extends StatelessWidget {
  const _NumberFormSchemaField({
    required this.fieldKey,
    required this.questionId,
    required this.title,
    required this.value,
    required this.onChanged,
    this.decimal = false,
  });

  final String fieldKey;
  final String questionId;
  final String title;
  final num? value;
  final ValueChanged<num?> onChanged;
  final bool decimal;

  @override
  Widget build(BuildContext context) => _HostFormSchemaBoundary(
    child: CatchField.input(
      key: ValueKey('$fieldKey-$questionId-$value'),
      title: title,
      initialValue: value?.toString(),
      isOptional: true,
      keyboardType: TextInputType.numberWithOptions(
        decimal: decimal,
        signed: decimal,
      ),
      contractExemption: 'The form contract validates numeric answer limits.',
      onBlur: (text) => onChanged(
        text.trim().isEmpty
            ? null
            : decimal
            ? num.tryParse(text.trim())
            : int.tryParse(text.trim()),
      ),
    ),
  );
}

class _TextValidationFormSchemaField extends StatelessWidget {
  const _TextValidationFormSchemaField({
    required this.fieldKey,
    required this.questionId,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String fieldKey;
  final String questionId;
  final String title;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => _HostFormSchemaBoundary(
    child: CatchField.input(
      key: ValueKey('$fieldKey-$questionId-$value'),
      title: title,
      initialValue: value,
      isOptional: true,
      contractExemption: 'The form contract validates this answer rule.',
      onBlur: (text) => onChanged(text.trim().isEmpty ? null : text.trim()),
    ),
  );
}

class _HostFormSchemaBoundary extends StatelessWidget {
  const _HostFormSchemaBoundary({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class _FormOutline extends StatelessWidget {
  const _FormOutline({
    required this.definition,
    required this.selectedSection,
    required this.selectedQuestion,
    required this.onSelected,
    required this.notifier,
  });

  final HostFormDefinition definition;
  final int? selectedSection;
  final int? selectedQuestion;
  final void Function(int section, int? question) onSelected;
  final HostFormEditorController notifier;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        context.l10n.hostFormOutline,
        style: CatchTextStyles.sectionTitle(context),
      ),
      gapH12,
      CatchSection.containedFieldRows(
        children: [
          for (final sectionEntry in definition.sections.indexed) ...[
            CatchField.nav(
              title: sectionEntry.$2.title,
              body: context.l10n.hostFormQuestionCount(
                count: sectionEntry.$2.questions.length,
              ),
              emphasis:
                  selectedSection == sectionEntry.$1 && selectedQuestion == null
                  ? CatchFieldEmphasis.title
                  : CatchFieldEmphasis.body,
              onTap: () => onSelected(sectionEntry.$1, null),
            ),
            for (final questionEntry in sectionEntry.$2.questions.indexed)
              CatchField.nav(
                title: questionEntry.$2.label,
                body: hostFormQuestionKindLabel(context, questionEntry.$2.kind),
                emphasis:
                    selectedSection == sectionEntry.$1 &&
                        selectedQuestion == questionEntry.$1
                    ? CatchFieldEmphasis.title
                    : CatchFieldEmphasis.body,
                onTap: () => onSelected(sectionEntry.$1, questionEntry.$1),
              ),
          ],
        ],
      ),
      gapH12,
      CatchButton(
        label: context.l10n.hostFormAddSection,
        variant: CatchButtonVariant.secondary,
        onPressed: notifier.addSection,
      ),
    ],
  );
}

class _Inspector extends StatelessWidget {
  const _Inspector({
    required this.definition,
    required this.sectionIndex,
    required this.questionIndex,
    required this.notifier,
  });

  final HostFormDefinition definition;
  final int? sectionIndex;
  final int? questionIndex;
  final HostFormEditorController notifier;

  @override
  Widget build(BuildContext context) {
    if (sectionIndex == null) {
      return _FormSettings(definition: definition, notifier: notifier);
    }
    final section = definition.sections[sectionIndex!];
    if (questionIndex == null) {
      return _SectionEditor(
        sectionIndex: sectionIndex!,
        section: section,
        sectionCount: definition.sections.length,
        notifier: notifier,
        onSelectionChanged: (_, _) {},
      );
    }
    final question = section.questions[questionIndex!];
    return _QuestionEditor(
      sectionIndex: sectionIndex!,
      questionIndex: questionIndex!,
      question: question,
      questionCount: section.questions.length,
      notifier: notifier,
      onSelected: () {},
    );
  }
}

Future<void> _showQuestionTypePicker(
  BuildContext context, {
  required ValueChanged<HostFormQuestionKind> onSelected,
}) async {
  final kind = await showCatchBottomSheet<HostFormQuestionKind>(
    context: context,
    builder: (context) => CatchBottomSheetScaffold(
      title: context.l10n.hostFormChooseQuestionType,
      child: CatchSection.containedFieldRows(
        children: [
          for (final value in HostFormQuestionKind.values)
            CatchField.nav(
              title: hostFormQuestionKindLabel(context, value),
              onTap: () => Navigator.of(context).pop(value),
            ),
        ],
      ),
    ),
  );
  if (kind != null) onSelected(kind);
}

class _DateFormSchemaField extends StatelessWidget {
  const _DateFormSchemaField({
    required this.title,
    required this.value,
    required this.onChanged,
    this.endOfDay = false,
  });

  final String title;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool endOfDay;

  @override
  Widget build(BuildContext context) => _HostFormSchemaBoundary(
    child: CatchField.action(
      title: title,
      body: value == null
          ? context.l10n.hostFormDateNotSet
          : MaterialLocalizations.of(
              context,
            ).formatMediumDate(value!.toLocal()),
      action: value == null
          ? null
          : IconButton(
              tooltip: context.l10n.hostFormClearDate,
              icon: Icon(CatchIcons.closeRounded),
              onPressed: () => onChanged(null),
            ),
      onTap: () async {
        final now = DateTime.now();
        final selected = await showDatePicker(
          context: context,
          initialDate: value?.toLocal() ?? now,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 10, 12, 31),
        );
        if (selected != null) {
          final local = endOfDay
              ? DateTime(
                  selected.year,
                  selected.month,
                  selected.day,
                  23,
                  59,
                  59,
                  999,
                )
              : DateTime(selected.year, selected.month, selected.day);
          onChanged(local.toUtc());
        }
      },
    ),
  );
}

int? _nullableInt(String value) =>
    value.trim().isEmpty ? null : int.tryParse(value.trim());

String _appearanceLabel(
  BuildContext context,
  HostFormAppearancePreset value,
) => switch (value) {
  HostFormAppearancePreset.editorial =>
    context.l10n.hostFormAppearanceEditorial,
  HostFormAppearancePreset.minimal => context.l10n.hostFormAppearanceMinimal,
  HostFormAppearancePreset.activity => context.l10n.hostFormAppearanceActivity,
};

String _completionActionLabel(
  BuildContext context,
  HostFormCompletionAction value,
) => switch (value) {
  HostFormCompletionAction.none => context.l10n.hostFormCompletionActionNone,
  HostFormCompletionAction.externalUrl =>
    context.l10n.hostFormCompletionActionExternal,
  HostFormCompletionAction.event => context.l10n.hostFormCompletionActionEvent,
  HostFormCompletionAction.eventRuntime =>
    context.l10n.hostFormCompletionActionRuntime,
};

String _privacyLabel(BuildContext context, HostFormPrivacyClass value) =>
    switch (value) {
      HostFormPrivacyClass.contact => context.l10n.hostFormPrivacyContact,
      HostFormPrivacyClass.profile => context.l10n.hostFormPrivacyProfile,
      HostFormPrivacyClass.sensitive => context.l10n.hostFormPrivacySensitive,
      HostFormPrivacyClass.organizerCustom =>
        context.l10n.hostFormPrivacyCustom,
    };

String _prefillLabel(BuildContext context, HostFormPrefillPolicy value) =>
    switch (value) {
      HostFormPrefillPolicy.never => context.l10n.hostFormPrefillNever,
      HostFormPrefillPolicy.participantReviewRequired =>
        context.l10n.hostFormPrefillReview,
    };

String _presentationLabel(
  BuildContext context,
  HostFormPresentation value,
) => switch (value) {
  HostFormPresentation.detailOnly => context.l10n.hostFormPresentationDetail,
  HostFormPresentation.filterable => context.l10n.hostFormPresentationFilter,
  HostFormPresentation.sortable => context.l10n.hostFormPresentationSort,
};

String _patternLabel(BuildContext context, HostFormPatternPreset value) =>
    switch (value) {
      HostFormPatternPreset.lettersAndSpaces =>
        context.l10n.hostFormPatternLetters,
      HostFormPatternPreset.alphanumeric =>
        context.l10n.hostFormPatternAlphanumeric,
      HostFormPatternPreset.postalCode => context.l10n.hostFormPatternPostal,
      HostFormPatternPreset.handle => context.l10n.hostFormPatternHandle,
    };

String _logicOperatorLabel(
  BuildContext context,
  HostFormLogicOperator value,
) => switch (value) {
  HostFormLogicOperator.equals => context.l10n.hostFormOperatorEquals,
  HostFormLogicOperator.notEquals => context.l10n.hostFormOperatorNotEquals,
  HostFormLogicOperator.contains => context.l10n.hostFormOperatorContains,
  HostFormLogicOperator.notContains => context.l10n.hostFormOperatorNotContains,
  HostFormLogicOperator.greaterThan => context.l10n.hostFormOperatorGreater,
  HostFormLogicOperator.lessThan => context.l10n.hostFormOperatorLess,
  HostFormLogicOperator.answered => context.l10n.hostFormOperatorAnswered,
  HostFormLogicOperator.notAnswered => context.l10n.hostFormOperatorNotAnswered,
};

String _logicActionLabel(
  BuildContext context,
  HostFormLogicAction value,
) => switch (value) {
  HostFormLogicAction.showQuestion => context.l10n.hostFormActionShowQuestion,
  HostFormLogicAction.hideQuestion => context.l10n.hostFormActionHideQuestion,
  HostFormLogicAction.showSection => context.l10n.hostFormActionShowSection,
  HostFormLogicAction.hideSection => context.l10n.hostFormActionHideSection,
  HostFormLogicAction.routeToSection => context.l10n.hostFormActionRouteSection,
  HostFormLogicAction.finish => context.l10n.hostFormActionFinish,
};

String _logicRuleSummary(
  BuildContext context,
  HostFormDefinition definition,
  HostFormLogicRule rule,
) {
  final questions = definition.sections
      .expand((section) => section.questions)
      .toList(growable: false);
  final source = questions
      .where((question) => question.questionId == rule.condition.questionId)
      .map((question) => question.label)
      .firstOrNull;
  final target = rule.targetQuestionId == null
      ? definition.sections
            .where((section) => section.sectionId == rule.targetSectionId)
            .map((section) => section.title)
            .firstOrNull
      : questions
            .where((question) => question.questionId == rule.targetQuestionId)
            .map((question) => question.label)
            .firstOrNull;
  return [
    source,
    _logicOperatorLabel(context, rule.condition.operator),
    _logicActionLabel(context, rule.action),
    target,
  ].whereType<String>().join(' · ');
}

Future<void> _showLogicRuleBuilder(
  BuildContext context, {
  required HostFormDefinition definition,
  required HostFormEditorController notifier,
}) async {
  final questions = definition.sections
      .expand((section) => section.questions)
      .toList(growable: false);
  if (questions.isEmpty) return;
  var sourceId = questions.first.questionId;
  var operator = HostFormLogicOperator.equals;
  var action = HostFormLogicAction.showQuestion;
  var expectedText = '';
  String? expectedChoice;
  String? targetQuestionId = questions.length > 1
      ? questions[1].questionId
      : null;
  String? targetSectionId = definition.sections.first.sectionId;
  await showCatchBottomSheet<void>(
    context: context,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setState) {
        final source = questions.firstWhere(
          (question) => question.questionId == sourceId,
        );
        final operators = _operatorsFor(source.kind);
        if (!operators.contains(operator)) operator = operators.first;
        final needsValue =
            operator != HostFormLogicOperator.answered &&
            operator != HostFormLogicOperator.notAnswered;
        final choiceValues = switch (source.kind) {
          HostFormQuestionKind.singleChoice ||
          HostFormQuestionKind.multiChoice =>
            source.options.map((option) => option.value).toList(),
          HostFormQuestionKind.boolean => const ['true', 'false'],
          _ => const <String>[],
        };
        if (choiceValues.isNotEmpty && !choiceValues.contains(expectedChoice)) {
          expectedChoice = choiceValues.first;
        }
        final targetQuestions = questions
            .where((question) => question.questionId != sourceId)
            .toList(growable: false);
        if (!targetQuestions.any(
          (question) => question.questionId == targetQuestionId,
        )) {
          targetQuestionId = targetQuestions.firstOrNull?.questionId;
        }
        final sourceSectionIndex = definition.sections.indexWhere(
          (section) => section.questions.any(
            (question) => question.questionId == sourceId,
          ),
        );
        final targetSections = definition.sections.indexed
            .where(
              (entry) =>
                  action != HostFormLogicAction.routeToSection ||
                  entry.$1 > sourceSectionIndex,
            )
            .map((entry) => entry.$2)
            .toList(growable: false);
        if (!targetSections.any(
          (section) => section.sectionId == targetSectionId,
        )) {
          targetSectionId = targetSections.firstOrNull?.sectionId;
        }
        final questionAction =
            action == HostFormLogicAction.showQuestion ||
            action == HostFormLogicAction.hideQuestion;
        final sectionAction =
            action == HostFormLogicAction.showSection ||
            action == HostFormLogicAction.hideSection ||
            action == HostFormLogicAction.routeToSection;
        final expectedValues = !needsValue
            ? const <Object?>[]
            : source.kind == HostFormQuestionKind.boolean
            ? <Object?>[expectedChoice == 'true']
            : source.kind == HostFormQuestionKind.number
            ? <Object?>[num.tryParse(expectedText)]
            : choiceValues.isNotEmpty
            ? <Object?>[expectedChoice]
            : <Object?>[expectedText.trim()];
        final canSave =
            (!needsValue ||
                expectedValues.every(
                  (value) => value != null && value.toString().isNotEmpty,
                )) &&
            (!questionAction || targetQuestionId != null) &&
            (!sectionAction || targetSectionId != null);
        return CatchBottomSheetScaffold(
          title: context.l10n.hostFormAddRule,
          keyboardSafe: true,
          action: CatchButton(
            label: context.l10n.hostFormRuleSave,
            fullWidth: true,
            onPressed: !canSave
                ? null
                : () {
                    notifier.addLogicRule(
                      questionId: sourceId,
                      operator: operator,
                      expectedValues: expectedValues,
                      action: action,
                      targetQuestionId: questionAction
                          ? targetQuestionId
                          : null,
                      targetSectionId: sectionAction ? targetSectionId : null,
                    );
                    Navigator.of(sheetContext).pop();
                  },
          ),
          child: SingleChildScrollView(
            child: CatchSection.containedFieldRows(
              children: [
                CatchField.select<String>(
                  key: ValueKey('logic-source-$sourceId'),
                  title: context.l10n.hostFormRuleQuestion,
                  contract: CatchContractConstraints
                      .organizerFormDraftDocumentDefinitionLogicRulesItemsConditionsItemsQuestionId,
                  contractValue: (value) => value,
                  values: questions
                      .map((question) => question.questionId)
                      .toList(),
                  value: sourceId,
                  itemLabel: (value) => questions
                      .firstWhere((question) => question.questionId == value)
                      .label,
                  onChanged: (value) => setState(() {
                    if (value == null) return;
                    sourceId = value;
                    expectedText = '';
                    expectedChoice = null;
                  }),
                ),
                CatchField.select<HostFormLogicOperator>(
                  key: ValueKey('logic-operator-$operator-$sourceId'),
                  title: context.l10n.hostFormRuleOperator,
                  contract: CatchContractConstraints
                      .organizerFormDraftDocumentDefinitionLogicRulesItemsConditionsItemsOperator,
                  contractValue: (value) => value.name,
                  values: operators,
                  value: operator,
                  itemLabel: (value) => _logicOperatorLabel(context, value),
                  onChanged: (value) {
                    if (value != null) setState(() => operator = value);
                  },
                ),
                if (needsValue && choiceValues.isNotEmpty)
                  CatchField.select<String>(
                    key: ValueKey('logic-value-$sourceId-$expectedChoice'),
                    title: context.l10n.hostFormRuleValue,
                    contract: CatchContractConstraints
                        .organizerFormDraftDocumentDefinitionLogicRulesItemsConditionsItemsExpectedValuesItems,
                    contractValue: (value) => value,
                    values: choiceValues,
                    value: expectedChoice!,
                    itemLabel: (value) =>
                        source.kind == HostFormQuestionKind.boolean
                        ? value == 'true'
                              ? context.l10n.hostFormRuleTrue
                              : context.l10n.hostFormRuleFalse
                        : source.options
                              .firstWhere((option) => option.value == value)
                              .label,
                    onChanged: (value) =>
                        setState(() => expectedChoice = value),
                  )
                else if (needsValue)
                  CatchField.input(
                    key: ValueKey('logic-value-$sourceId'),
                    title: context.l10n.hostFormRuleValue,
                    initialValue: expectedText,
                    keyboardType: source.kind == HostFormQuestionKind.number
                        ? const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          )
                        : TextInputType.text,
                    contractExemption:
                        'The form contract validates comparison values.',
                    onChanged: (value) => setState(() => expectedText = value),
                  ),
                CatchField.select<HostFormLogicAction>(
                  key: ValueKey('logic-action-$action'),
                  title: context.l10n.hostFormRuleAction,
                  contract: CatchContractConstraints
                      .organizerFormDraftDocumentDefinitionLogicRulesItemsAction,
                  contractValue: (value) => value.name,
                  values: HostFormLogicAction.values,
                  value: action,
                  itemLabel: (value) => _logicActionLabel(context, value),
                  onChanged: (value) {
                    if (value != null) setState(() => action = value);
                  },
                ),
                if (questionAction && targetQuestions.isNotEmpty)
                  CatchField.select<String>(
                    title: context.l10n.hostFormRuleTargetQuestion,
                    contract: CatchContractConstraints
                        .organizerFormDraftDocumentDefinitionLogicRulesItemsTargetQuestionId,
                    contractValue: (value) => value,
                    values: targetQuestions
                        .map((question) => question.questionId)
                        .toList(),
                    value: targetQuestionId!,
                    itemLabel: (value) => targetQuestions
                        .firstWhere((question) => question.questionId == value)
                        .label,
                    onChanged: (value) =>
                        setState(() => targetQuestionId = value),
                  ),
                if (sectionAction && targetSections.isNotEmpty)
                  CatchField.select<String>(
                    title: context.l10n.hostFormRuleTargetSection,
                    contract: CatchContractConstraints
                        .organizerFormDraftDocumentDefinitionLogicRulesItemsTargetSectionId,
                    contractValue: (value) => value,
                    values: targetSections
                        .map((section) => section.sectionId)
                        .toList(),
                    value: targetSectionId!,
                    itemLabel: (value) => targetSections
                        .firstWhere((section) => section.sectionId == value)
                        .title,
                    onChanged: (value) =>
                        setState(() => targetSectionId = value),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

List<HostFormLogicOperator> _operatorsFor(HostFormQuestionKind kind) =>
    switch (kind) {
      HostFormQuestionKind.number => const [
        HostFormLogicOperator.equals,
        HostFormLogicOperator.notEquals,
        HostFormLogicOperator.greaterThan,
        HostFormLogicOperator.lessThan,
        HostFormLogicOperator.answered,
        HostFormLogicOperator.notAnswered,
      ],
      HostFormQuestionKind.multiChoice => const [
        HostFormLogicOperator.contains,
        HostFormLogicOperator.notContains,
        HostFormLogicOperator.answered,
        HostFormLogicOperator.notAnswered,
      ],
      HostFormQuestionKind.singleChoice ||
      HostFormQuestionKind.boolean => const [
        HostFormLogicOperator.equals,
        HostFormLogicOperator.notEquals,
        HostFormLogicOperator.answered,
        HostFormLogicOperator.notAnswered,
      ],
      _ => const [
        HostFormLogicOperator.equals,
        HostFormLogicOperator.notEquals,
        HostFormLogicOperator.contains,
        HostFormLogicOperator.notContains,
        HostFormLogicOperator.answered,
        HostFormLogicOperator.notAnswered,
      ],
    };

String _saveLabel(BuildContext context, HostFormEditorState state) =>
    switch (state.saveState) {
      HostFormSaveState.saved => context.l10n.hostFormSaved,
      HostFormSaveState.dirty => context.l10n.hostFormUnsaved,
      HostFormSaveState.saving => context.l10n.hostFormSaving,
      HostFormSaveState.conflict => context.l10n.hostFormSaveConflict,
      HostFormSaveState.failed => context.l10n.hostFormSaveFailed,
    };

String hostFormIdentityLabel(
  BuildContext context,
  HostFormIdentityPolicy policy,
) => switch (policy) {
  HostFormIdentityPolicy.anonymous => context.l10n.hostFormIdentityAnonymous,
  HostFormIdentityPolicy.emailVerified => context.l10n.hostFormIdentityEmail,
  HostFormIdentityPolicy.phoneVerified => context.l10n.hostFormIdentityPhone,
  HostFormIdentityPolicy.emailOrPhoneVerified =>
    context.l10n.hostFormIdentityEmailOrPhone,
  HostFormIdentityPolicy.catchAccount =>
    context.l10n.hostFormIdentityCatchAccount,
};

String hostFormQuestionKindLabel(
  BuildContext context,
  HostFormQuestionKind kind,
) => switch (kind) {
  HostFormQuestionKind.shortText => context.l10n.hostFormTypeShortText,
  HostFormQuestionKind.longText => context.l10n.hostFormTypeLongText,
  HostFormQuestionKind.singleChoice => context.l10n.hostFormTypeSingleChoice,
  HostFormQuestionKind.multiChoice => context.l10n.hostFormTypeMultiChoice,
  HostFormQuestionKind.date => context.l10n.hostFormTypeDate,
  HostFormQuestionKind.phone => context.l10n.hostFormTypePhone,
  HostFormQuestionKind.email => context.l10n.hostFormTypeEmail,
  HostFormQuestionKind.url => context.l10n.hostFormTypeUrl,
  HostFormQuestionKind.number => context.l10n.hostFormTypeNumber,
  HostFormQuestionKind.boolean => context.l10n.hostFormTypeBoolean,
  HostFormQuestionKind.file => context.l10n.hostFormTypeFile,
  HostFormQuestionKind.acknowledgement =>
    context.l10n.hostFormTypeAcknowledgement,
  HostFormQuestionKind.signature => context.l10n.hostFormTypeSignature,
};
