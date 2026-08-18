import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_action.dart';
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
    final editorValue = editor.asData?.value;
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
              context: AppErrorContext.club,
              onRetry: notifier.reload,
            ),
          ),
          builder: (context, value) => LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 1040) {
                return _expandedEditor(context, value, notifier);
              }
              return CatchScreenBody(
                pb: CatchSpacing.s10,
                child: _compactEditor(context, value, notifier),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _compactEditor(
    BuildContext context,
    HostFormEditorState state,
    HostFormEditorController notifier,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ..._statusNotices(context, state, notifier),
      _FormSettings(definition: state.editor.definition, notifier: notifier),
      gapH24,
      _SectionsEditor(
        definition: state.editor.definition,
        notifier: notifier,
        onSelectionChanged: (section, question) => setState(() {
          _selectedSection = section;
          _selectedQuestion = question;
        }),
      ),
    ],
  );

  Widget _expandedEditor(
    BuildContext context,
    HostFormEditorState state,
    HostFormEditorController notifier,
  ) {
    final t = CatchTokens.of(context);
    final definition = state.editor.definition;
    final sectionIndex = _validSectionIndex(definition);
    final questionIndex = _validQuestionIndex(definition, sectionIndex);
    return Column(
      children: [
        if (_statusNotices(context, state, notifier) case final notices
            when notices.isNotEmpty)
          Padding(
            padding: CatchInsets.pageBody.copyWith(bottom: CatchSpacing.s2),
            child: Column(children: notices),
          ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 260,
                child: SingleChildScrollView(
                  padding: CatchInsets.pageBody,
                  child: _FormOutline(
                    definition: definition,
                    selectedSection: sectionIndex,
                    selectedQuestion: questionIndex,
                    onSelected: (section, question) => setState(() {
                      _selectedSection = section;
                      _selectedQuestion = question;
                    }),
                    notifier: notifier,
                  ),
                ),
              ),
              VerticalDivider(width: 1, color: t.line),
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
              VerticalDivider(width: 1, color: t.line),
              SizedBox(
                width: 340,
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

  List<Widget> _statusNotices(
    BuildContext context,
    HostFormEditorState state,
    HostFormEditorController notifier,
  ) => [
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

class _FormSettings extends StatelessWidget {
  const _FormSettings({required this.definition, required this.notifier});

  final HostFormDefinition definition;
  final HostFormEditorController notifier;

  @override
  Widget build(BuildContext context) => CatchSection.fieldRows(
    title: context.l10n.hostFormSettings,
    first: true,
    children: [
      CatchField.input(
        key: ValueKey('form-title-${definition.title}'),
        title: context.l10n.hostFormTitleLabel,
        initialValue: definition.title,
        contractExemption: 'The backend form definition validates this title.',
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
        onChanged: (value) => notifier.updateMetadata(identityPolicy: value),
      ),
      CatchField.input(
        key: ValueKey('form-completion-${definition.completionTitle}'),
        title: context.l10n.hostFormCompletionTitleLabel,
        initialValue: definition.completionTitle,
        contractExemption:
            'The backend form definition validates completion copy.',
        onBlur: (value) =>
            notifier.updateMetadata(completionTitle: value.trim()),
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

class _QuestionEditor extends StatelessWidget {
  const _QuestionEditor({
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
  Widget build(BuildContext context) => CatchField.control(
    title: question.label,
    body: hostFormQuestionKindLabel(context, question.kind),
    contractExemption:
        'Disclosure container; nested question fields bind the form contract.',
    onOpenChanged: (open) {
      if (open) onSelected();
    },
    control: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchField.input(
          key: ValueKey(
            'question-label-${question.questionId}-${question.label}',
          ),
          title: context.l10n.hostFormQuestionLabel,
          initialValue: question.label,
          contractExemption: 'The backend form definition validates questions.',
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
          itemLabel: (value) => hostFormQuestionKindLabel(context, value),
          onChanged: (value) =>
              notifier.updateQuestion(sectionIndex, questionIndex, kind: value),
        ),
        CatchField.toggle(
          title: context.l10n.hostFormQuestionRequired,
          value: question.required,
          contractExemption: 'Requiredness is part of the form definition.',
          onChanged: (value) => notifier.updateQuestion(
            sectionIndex,
            questionIndex,
            required: value,
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
            contractExemption: 'The backend validates form choice options.',
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
            onTap: () => notifier.addOption(sectionIndex, questionIndex),
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
                    : () =>
                          notifier.moveQuestion(sectionIndex, questionIndex, 1),
              ),
            ),
          ],
        ),
        CatchButton(
          label: context.l10n.hostFormRemoveQuestion,
          variant: CatchButtonVariant.danger,
          fullWidth: true,
          onPressed: () => notifier.removeQuestion(sectionIndex, questionIndex),
        ),
      ],
    ),
  );
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
  final kind = await showModalBottomSheet<HostFormQuestionKind>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => ListView(
      shrinkWrap: true,
      padding: CatchInsets.pageBody,
      children: [
        Text(
          context.l10n.hostFormChooseQuestionType,
          style: CatchTextStyles.headlineS(context),
        ),
        gapH12,
        CatchSection.containedFieldRows(
          children: [
            for (final value in HostFormQuestionKind.values)
              CatchField.nav(
                title: hostFormQuestionKindLabel(context, value),
                onTap: () => Navigator.of(context).pop(value),
              ),
          ],
        ),
      ],
    ),
  );
  if (kind != null) onSelected(kind);
}

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
