import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/responsive/responsive_builder.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_action.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_metric_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_mono_label.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/domain/host_form.dart';
import 'package:catch_dating_app/hosts/domain/host_form_operations.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_renderer.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_responses_panel.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_screen.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _BuilderView { build, responses }

enum _BuilderAction { undo, redo, share, pause, resume, archive }

enum _SectionAction { edit, moveUp, moveDown, remove }

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
  _BuilderView _view = _BuilderView.build;
  bool _editingPublishedForm = false;

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
    final compact =
        MediaQuery.sizeOf(context).width <
        CatchLayout.formBuilderExpandedBreakpoint;
    final commandCenter =
        compact &&
        !_editingPublishedForm &&
        _view == _BuilderView.build &&
        editorValue?.editor.form.activeVersionId != null;

    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title: commandCenter || compact ? null : title,
        titleWidget: compact && !commandCenter
            ? Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.sectionTitle(context),
              )
            : null,
        subtitle: commandCenter || editorValue == null
            ? null
            : _saveLabel(context, editorValue),
        leadingType: CatchTopBarLeading.back,
        leadingActionVariant: CatchIconButtonVariant.plain,
        divider: scrolledUnder,
        bottom: commandCenter
            ? null
            : CatchTabRail<_BuilderView>(
                groupKey: const ValueKey('host-form-builder-tabs'),
                selected: _view,
                options: [
                  CatchOption(
                    value: _BuilderView.build,
                    label: context.l10n.hostFormBuildTab,
                  ),
                  CatchOption(
                    value: _BuilderView.responses,
                    label: context.l10n.hostFormResponsesTab(
                      count:
                          editorValue?.editor.form.submittedResponseCount ?? 0,
                    ),
                  ),
                ],
                onChanged: (view) => setState(() => _view = view),
              ),
        actions: [
          if (_view == _BuilderView.build && !commandCenter)
            CatchTopBarTextAction(
              label: context.l10n.hostFormPreview,
              foregroundColor: CatchTokens.of(context).ink,
              onPressed: editorValue == null ? null : _openPreview,
            ),
          if (editorValue != null &&
              _builderActions(context, editorValue).isNotEmpty)
            CatchActionMenu<_BuilderAction>(
              tooltip: context.l10n.hostFormsActions,
              variant: CatchIconButtonVariant.plain,
              items: _builderActions(context, editorValue),
              onSelected: (action) => _runBuilderAction(notifier, action),
            ),
        ],
      ),
      bottomNavigationBar: _HostFormBuilderBottomAction(
        state: editorValue,
        visible: _view == _BuilderView.build && !commandCenter,
        onReviewAndPublish: editorValue == null
            ? null
            : () => _reviewAndPublish(notifier, editorValue),
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
          builder: (context, value) => commandCenter
              ? CatchScreenBody(
                  key: const ValueKey('host-form-command-center'),
                  pb: CatchSpacing.s10,
                  child: _PublishedFormCommandCenter(
                    organizerId: widget.organizerId,
                    state: value,
                    onEdit: () => setState(() => _editingPublishedForm = true),
                    onReviewResponses: () =>
                        setState(() => _view = _BuilderView.responses),
                    onQuestions: () =>
                        setState(() => _editingPublishedForm = true),
                    onAudience: () => _showFormSettingsSheet(
                      context,
                      definition: value.editor.definition,
                      notifier: notifier,
                    ),
                    onShare: () =>
                        _runBuilderAction(notifier, _BuilderAction.share),
                    onPreview: _openPreview,
                  ),
                )
              : _view == _BuilderView.responses
              ? CatchScreenBody(
                  key: const ValueKey('host-form-builder-responses'),
                  pb: CatchSpacing.s10,
                  child: HostFormResponsesPanel(
                    organizerId: widget.organizerId,
                    formId: widget.formId,
                    formTitle: value.editor.definition.title,
                    showFormContext: false,
                  ),
                )
              : ComponentResponsiveBuilder(
                  breakpoint: CatchLayout.formBuilderExpandedBreakpoint,
                  compact: (context) => CatchScreenBody(
                    key: const ValueKey('host-form-builder-build'),
                    pb: CatchSpacing.s10,
                    child: _CompactFormEditor(
                      organizerId: widget.organizerId,
                      formId: widget.formId,
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
      if (state.canUndo)
        CatchActionMenuItem(
          value: _BuilderAction.undo,
          label: context.l10n.hostFormUndo,
          icon: CatchIcons.undoRounded,
        ),
      if (state.canRedo)
        CatchActionMenuItem(
          value: _BuilderAction.redo,
          label: context.l10n.hostFormRedo,
          icon: CatchIcons.redoRounded,
        ),
      if (state.editor.form.activeVersionId != null)
        CatchActionMenuItem(
          value: _BuilderAction.share,
          label: context.l10n.hostFormShare,
          icon: CatchIcons.share,
        ),
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

  void _openPreview() => context.pushNamed(
    Routes.hostFormPreviewScreen.name,
    pathParameters: {'formId': widget.formId},
    queryParameters: {'organizerId': widget.organizerId},
  );

  Future<void> _runBuilderAction(
    HostFormEditorController notifier,
    _BuilderAction action,
  ) async {
    switch (action) {
      case _BuilderAction.undo:
        notifier.undo();
      case _BuilderAction.redo:
        notifier.redo();
      case _BuilderAction.share:
        await context.pushNamed(
          Routes.hostFormShareScreen.name,
          pathParameters: {'formId': widget.formId},
          queryParameters: {'organizerId': widget.organizerId},
        );
      case _BuilderAction.pause ||
          _BuilderAction.resume ||
          _BuilderAction.archive:
        await _setLifecycle(notifier, action);
    }
  }

  Future<void> _reviewAndPublish(
    HostFormEditorController notifier,
    HostFormEditorState state,
  ) async {
    final definition = state.editor.definition;
    final questionCount = definition.sections.fold<int>(
      0,
      (count, section) => count + section.questions.length,
    );
    final shouldPublish = await showCatchBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => CatchBottomSheetScaffold(
        title: state.editor.form.status == HostFormLifecycleStatus.published
            ? context.l10n.hostFormReviewChangesTitle
            : context.l10n.hostFormReviewPublishTitle,
        subtitle: context.l10n.hostFormReviewPublishSubtitle,
        action: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CatchButton(
              label: context.l10n.hostFormPreview,
              variant: CatchButtonVariant.secondary,
              fullWidth: true,
              onPressed: () {
                Navigator.of(sheetContext).pop(false);
                _openPreview();
              },
            ),
            gapH8,
            CatchButton(
              label:
                  state.editor.form.status == HostFormLifecycleStatus.published
                  ? context.l10n.hostFormPublishChanges
                  : context.l10n.hostFormPublish,
              fullWidth: true,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
        child: CatchSection.containedFieldRows(
          children: [
            CatchField.read(
              title: context.l10n.hostFormQuestionsTitle,
              body: context.l10n.hostFormQuestionCount(count: questionCount),
            ),
            CatchField.read(
              title: context.l10n.hostFormIdentityLabel,
              body: hostFormIdentityLabel(context, definition.identityPolicy),
            ),
            CatchField.read(
              title: context.l10n.hostFormAvailability,
              body: _availabilitySummary(context, definition),
            ),
          ],
        ),
      ),
    );
    if (shouldPublish == true) await _publish(notifier);
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
      _BuilderAction.undo ||
      _BuilderAction.redo ||
      _BuilderAction.share => throw StateError('Expected a lifecycle action.'),
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

class _HostFormBuilderBottomAction extends StatelessWidget {
  const _HostFormBuilderBottomAction({
    required this.state,
    required this.visible,
    required this.onReviewAndPublish,
  });

  final HostFormEditorState? state;
  final bool visible;
  final VoidCallback? onReviewAndPublish;

  @override
  Widget build(BuildContext context) {
    final current = state;
    if (current == null ||
        !visible ||
        current.editor.form.status == HostFormLifecycleStatus.archived) {
      return const SizedBox.shrink();
    }
    final isLoading = current.operationInProgress;
    return CatchBottomAction(
      label: current.editor.form.status == HostFormLifecycleStatus.published
          ? context.l10n.hostFormReviewPublishChanges
          : context.l10n.hostFormReviewPublish,
      isLoading: isLoading,
      buttonShape: CatchButtonShape.rounded,
      onPressed: isLoading ? null : onReviewAndPublish,
    );
  }
}

class _PublishedFormCommandCenter extends ConsumerWidget {
  const _PublishedFormCommandCenter({
    required this.organizerId,
    required this.state,
    required this.onEdit,
    required this.onReviewResponses,
    required this.onQuestions,
    required this.onAudience,
    required this.onShare,
    required this.onPreview,
  });

  final String organizerId;
  final HostFormEditorState state;
  final VoidCallback onEdit;
  final VoidCallback onReviewResponses;
  final VoidCallback onQuestions;
  final VoidCallback onAudience;
  final VoidCallback onShare;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final form = state.editor.form;
    final definition = state.editor.definition;
    final questionCount = definition.sections.fold<int>(
      0,
      (count, section) => count + section.questions.length,
    );
    final responseRequest = HostFormResponseListRequest(
      organizerId: organizerId,
      formId: form.formId,
      statuses: const {HostFormResponseStatus.submitted},
      limit: 1,
    );
    final responses = ref.watch(
      hostFormResponsesControllerProvider(responseRequest),
    );
    final latestResponse = catchAsyncStateFromAsyncValue(
      responses,
    ).value?.responses.firstOrNull;
    final lifecycle = hostFormStatusLabel(context, form.status);
    final purpose = hostFormPurposeLabel(context, form.purpose);
    final accessibleStack = MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    final title = Text(
      definition.title,
      key: const ValueKey('host-form-command-center-title'),
      style: CatchTextStyles.eventTitle(context, color: t.ink),
    );
    final editAction = CatchTextButton(
      key: const ValueKey('host-form-command-center-edit'),
      label: context.l10n.hostFormsOpen,
      tone: CatchTextButtonTone.neutral,
      minimumSize: const Size(0, CatchSpacing.s10),
      padding: EdgeInsets.zero,
      textStyle: CatchTextStyles.labelL(
        context,
        color: t.ink,
      ).copyWith(decoration: TextDecoration.underline),
      onPressed: onEdit,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (accessibleStack) ...[
          title,
          gapH8,
          Align(alignment: Alignment.centerLeft, child: editAction),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: title),
              gapW12,
              editAction,
            ],
          ),
        gapH12,
        Row(
          children: [
            Flexible(child: CatchMonoLabel(lifecycle, color: t.ink2)),
            Padding(
              padding: CatchInsets.inlineHorizontal,
              child: Text(
                '·',
                style: CatchTextStyles.monoLabel(context, color: t.ink3),
              ),
            ),
            Flexible(child: CatchMonoLabel(purpose, color: t.ink2)),
          ],
        ),
        gapH32,
        CatchSurface.tinted(
          key: const ValueKey('host-form-response-command'),
          radius: CatchRadius.md,
          backgroundColor: t.primarySoft,
          padding: CatchInsets.contentRelaxed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (accessibleStack) ...[
                Text(
                  '${form.submittedResponseCount}',
                  style: CatchTextStyles.display(
                    context,
                    color: t.primary,
                  ).copyWith(fontSize: 56),
                ),
                gapH4,
                Text(
                  context.l10n.hostFormsViewResponses,
                  style: CatchTextStyles.headlineS(context, color: t.ink),
                ),
              ] else
                Row(
                  children: [
                    Text(
                      '${form.submittedResponseCount}',
                      style: CatchTextStyles.display(
                        context,
                        color: t.primary,
                      ).copyWith(fontSize: 56),
                    ),
                    gapW16,
                    Expanded(
                      child: Text(
                        context.l10n.hostFormsViewResponses,
                        style: CatchTextStyles.headlineS(context, color: t.ink),
                      ),
                    ),
                  ],
                ),
              gapH8,
              Text(
                context.l10n.hostFormResponsesSubtitle,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
              gapH20,
              CatchButton(
                label: context.l10n.hostFormsViewResponsesAction,
                shape: CatchButtonShape.rounded,
                fullWidth: true,
                onPressed: onReviewResponses,
              ),
            ],
          ),
        ),
        gapH24,
        CatchMetricStrip(
          key: const ValueKey('host-form-command-center-metrics'),
          backgroundColor: Colors.transparent,
          borderColor: Colors.transparent,
          items: [
            CatchMetricStripItem(
              value: '${form.submittedResponseCount}',
              label: context.l10n.hostFormsViewResponses,
            ),
            CatchMetricStripItem(
              value: '$questionCount',
              label: context.l10n.hostFormQuestionsTitle,
            ),
            CatchMetricStripItem(
              value: '${form.publishedVersion}',
              label: context.l10n.hostFormsStatusPublished,
            ),
          ],
        ),
        if (latestResponse != null) ...[
          gapH24,
          CatchFieldLanes.single(
            child: CatchField.nav(
              key: const ValueKey('host-form-command-center-recent-response'),
              title:
                  latestResponse.identity.primaryLabel ??
                  context.l10n.hostFormResponsesAnonymous,
              body:
                  latestResponse.sourceLabel ??
                  context.l10n.hostFormResponseTitle,
              emphasis: CatchFieldEmphasis.title,
              valueText: AppTimeFormatters.compactRelativeTime(
                latestResponse.submittedAt,
              ),
              divider: true,
              onTap: onReviewResponses,
            ),
          ),
        ],
        gapH24,
        CatchFieldLanes.divided(
          children: [
            CatchField.nav(
              title: context.l10n.hostFormQuestionsTitle,
              body: context.l10n.hostFormQuestionCount(count: questionCount),
              icon: CatchIcons.helpOutline,
              emphasis: CatchFieldEmphasis.title,
              onTap: onQuestions,
            ),
            CatchField.nav(
              title: context.l10n.hostFormIdentityLabel,
              body: hostFormIdentityLabel(context, definition.identityPolicy),
              icon: CatchIcons.verifiedUserOutlined,
              emphasis: CatchFieldEmphasis.title,
              onTap: onAudience,
            ),
            CatchField.nav(
              title: context.l10n.hostFormShare,
              icon: CatchIcons.share,
              emphasis: CatchFieldEmphasis.title,
              onTap: onShare,
            ),
            CatchField.nav(
              title: context.l10n.hostFormPreview,
              icon: CatchIcons.eye,
              emphasis: CatchFieldEmphasis.title,
              onTap: onPreview,
            ),
          ],
        ),
      ],
    );
  }
}

class _CompactFormEditor extends StatefulWidget {
  const _CompactFormEditor({
    required this.organizerId,
    required this.formId,
    required this.state,
    required this.notifier,
    required this.onSelectionChanged,
  });

  final String organizerId;
  final String formId;
  final HostFormEditorState state;
  final HostFormEditorController notifier;
  final void Function(int section, int? question) onSelectionChanged;

  @override
  State<_CompactFormEditor> createState() => _CompactFormEditorState();
}

class _CompactFormEditorState extends State<_CompactFormEditor> {
  String? _expandedQuestionId;

  @override
  Widget build(BuildContext context) {
    final definition = widget.state.editor.definition;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormStatusNotices(state: widget.state, notifier: widget.notifier),
        _CompactQuestionsStep(
          organizerId: widget.organizerId,
          formId: widget.formId,
          definition: definition,
          status: widget.state.editor.form.status,
          notifier: widget.notifier,
          expandedQuestionId: _expandedQuestionId,
          onQuestionExpansionChanged: (questionId) {
            setState(() {
              _expandedQuestionId = _expandedQuestionId == questionId
                  ? null
                  : questionId;
            });
          },
          onSelectionChanged: widget.onSelectionChanged,
        ),
        gapH24,
        _CompactFormSettingsEntry(
          definition: definition,
          notifier: widget.notifier,
        ),
        gapH24,
        _CompactPublishStep(state: widget.state),
      ],
    );
  }
}

class _CompactQuestionsStep extends StatelessWidget {
  const _CompactQuestionsStep({
    required this.organizerId,
    required this.formId,
    required this.definition,
    required this.status,
    required this.notifier,
    required this.expandedQuestionId,
    required this.onQuestionExpansionChanged,
    required this.onSelectionChanged,
  });

  final String organizerId;
  final String formId;
  final HostFormDefinition definition;
  final HostFormLifecycleStatus status;
  final HostFormEditorController notifier;
  final String? expandedQuestionId;
  final ValueChanged<String> onQuestionExpansionChanged;
  final void Function(int section, int? question) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final questionCount = definition.sections.fold<int>(
      0,
      (count, section) => count + section.questions.length,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${hostFormStatusLabel(context, status)} · '
                  '${context.l10n.hostFormQuestionCount(count: questionCount)}'
              .toUpperCase(),
          style: CatchTextStyles.kickerLg(context, color: t.ink2),
        ),
        gapH12,
        Text(
          context.l10n.hostFormQuestionsTitle,
          style: CatchTextStyles.headline(context),
        ),
        gapH12,
        Text(
          context.l10n.hostFormQuestionsPromptHelp,
          style: CatchTextStyles.proseM(context, color: t.ink2),
        ),
        gapH24,
        for (final sectionEntry in definition.sections.indexed) ...[
          _CompactSectionOutline(
            organizerId: organizerId,
            formId: formId,
            definition: definition,
            sectionIndex: sectionEntry.$1,
            section: sectionEntry.$2,
            sectionCount: definition.sections.length,
            notifier: notifier,
            expandedQuestionId: expandedQuestionId,
            onQuestionExpansionChanged: onQuestionExpansionChanged,
            onSelectionChanged: onSelectionChanged,
          ),
          gapH20,
        ],
        CatchSection.fieldRows(
          children: [
            CatchField.add(
              title: context.l10n.hostFormAddSection,
              icon: CatchIcons.addRounded,
              onTap: notifier.addSection,
            ),
          ],
        ),
      ],
    );
  }
}

class _CompactFormSettingsEntry extends StatelessWidget {
  const _CompactFormSettingsEntry({
    required this.definition,
    required this.notifier,
  });

  final HostFormDefinition definition;
  final HostFormEditorController notifier;

  @override
  Widget build(BuildContext context) => CatchSection.fieldRows(
    children: [
      CatchField.nav(
        key: const ValueKey('host-form-settings-entry'),
        title: context.l10n.hostFormSettings,
        body: context.l10n.hostFormSettingsPromptHelp,
        icon: CatchIcons.settingsOutlined,
        onTap: () => _showFormSettingsSheet(
          context,
          definition: definition,
          notifier: notifier,
        ),
      ),
    ],
  );
}

Future<void> _showFormSettingsSheet(
  BuildContext context, {
  required HostFormDefinition definition,
  required HostFormEditorController notifier,
}) => showCatchBottomSheet<void>(
  context: context,
  builder: (sheetContext) => CatchBottomSheetScaffold(
    title: context.l10n.hostFormSettings,
    subtitle: context.l10n.hostFormSettingsPromptHelp,
    keyboardSafe: true,
    child: SizedBox(
      height: MediaQuery.sizeOf(sheetContext).height * 0.62,
      child: SingleChildScrollView(
        child: _FormSettings(definition: definition, notifier: notifier),
      ),
    ),
  ),
);

class _CompactPublishStep extends StatelessWidget {
  const _CompactPublishStep({required this.state});

  final HostFormEditorState state;

  @override
  Widget build(BuildContext context) {
    final definition = state.editor.definition;
    final questionCount = definition.sections.fold<int>(
      0,
      (count, section) => count + section.questions.length,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CatchDivider.section(),
        Padding(
          padding: CatchInsets.contentVerticalMedium,
          child: Text(
            '${context.l10n.hostFormQuestionCount(count: questionCount)} · '
            '${context.l10n.hostFormPublishPrompt}',
            key: const ValueKey('host-form-readiness-summary'),
            textAlign: TextAlign.center,
            style: CatchTextStyles.supporting(context),
          ),
        ),
      ],
    );
  }
}

class _CompactSectionOutline extends StatelessWidget {
  const _CompactSectionOutline({
    required this.organizerId,
    required this.formId,
    required this.definition,
    required this.sectionIndex,
    required this.section,
    required this.sectionCount,
    required this.notifier,
    required this.expandedQuestionId,
    required this.onQuestionExpansionChanged,
    required this.onSelectionChanged,
  });

  final String organizerId;
  final String formId;
  final HostFormDefinition definition;
  final int sectionIndex;
  final HostFormSection section;
  final int sectionCount;
  final HostFormEditorController notifier;
  final String? expandedQuestionId;
  final ValueChanged<String> onQuestionExpansionChanged;
  final void Function(int section, int? question) onSelectionChanged;

  @override
  Widget build(BuildContext context) => CatchSection.fieldRows(
    title: section.title,
    first: sectionIndex == 0,
    trailing: CatchActionMenu<_SectionAction>(
      tooltip: context.l10n.hostFormSectionActions,
      variant: CatchIconButtonVariant.plain,
      items: [
        CatchActionMenuItem(
          value: _SectionAction.edit,
          label: context.l10n.hostFormEditSection,
          icon: CatchIcons.editOutlined,
        ),
        if (sectionIndex > 0)
          CatchActionMenuItem(
            value: _SectionAction.moveUp,
            label: context.l10n.hostFormMoveSectionUp,
            icon: CatchIcons.arrowUpwardRounded,
          ),
        if (sectionIndex < sectionCount - 1)
          CatchActionMenuItem(
            value: _SectionAction.moveDown,
            label: context.l10n.hostFormMoveSectionDown,
            icon: CatchIcons.arrowDownwardRounded,
          ),
        if (sectionCount > 1)
          CatchActionMenuItem(
            value: _SectionAction.remove,
            label: context.l10n.hostFormRemoveSection,
            icon: CatchIcons.deleteOutlineRounded,
            isDestructive: true,
          ),
      ],
      onSelected: (action) {
        switch (action) {
          case _SectionAction.edit:
            onSelectionChanged(sectionIndex, null);
            _showSectionEditorSheet(
              context,
              organizerId: organizerId,
              formId: formId,
              sectionIndex: sectionIndex,
              section: section,
              notifier: notifier,
            );
          case _SectionAction.moveUp:
            notifier.moveSection(sectionIndex, -1);
          case _SectionAction.moveDown:
            notifier.moveSection(sectionIndex, 1);
          case _SectionAction.remove:
            notifier.removeSection(sectionIndex);
        }
      },
    ),
    child: _CompactQuestionRows(
      organizerId: organizerId,
      formId: formId,
      definition: definition,
      sectionIndex: sectionIndex,
      section: section,
      notifier: notifier,
      expandedQuestionId: expandedQuestionId,
      onQuestionExpansionChanged: onQuestionExpansionChanged,
      onSelectionChanged: onSelectionChanged,
    ),
  );
}

class _CompactQuestionRows extends StatelessWidget {
  const _CompactQuestionRows({
    required this.organizerId,
    required this.formId,
    required this.definition,
    required this.sectionIndex,
    required this.section,
    required this.notifier,
    required this.expandedQuestionId,
    required this.onQuestionExpansionChanged,
    required this.onSelectionChanged,
  });

  final String organizerId;
  final String formId;
  final HostFormDefinition definition;
  final int sectionIndex;
  final HostFormSection section;
  final HostFormEditorController notifier;
  final String? expandedQuestionId;
  final ValueChanged<String> onQuestionExpansionChanged;
  final void Function(int section, int? question) onSelectionChanged;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ReorderableListView.builder(
        key: ValueKey('form-section-${section.sectionId}-questions'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        itemCount: section.questions.length,
        onReorderItem: (oldIndex, newIndex) {
          final targetIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
          notifier.moveQuestion(sectionIndex, oldIndex, targetIndex - oldIndex);
        },
        itemBuilder: (context, questionIndex) {
          final question = section.questions[questionIndex];
          final expanded = expandedQuestionId == question.questionId;
          return Column(
            key: ValueKey('form-question-${question.questionId}'),
            mainAxisSize: MainAxisSize.min,
            children: [
              CatchFieldLanes.single(
                child: CatchField.sortable(
                  title: question.label,
                  metadata: _questionSummary(context, question),
                  reorderHandle: section.questions.length > 1
                      ? ReorderableDragStartListener(
                          index: questionIndex,
                          child: Tooltip(
                            message: context.l10n.hostFormReorderQuestion,
                            child: SizedBox.square(
                              key: ValueKey(
                                'form-question-${question.questionId}-drag',
                              ),
                              dimension: CatchSpacing.s11,
                              child: Icon(CatchIcons.dragIndicatorRounded),
                            ),
                          ),
                        )
                      : const SizedBox.square(dimension: CatchSpacing.s11),
                  onTap: () {
                    onSelectionChanged(sectionIndex, questionIndex);
                    onQuestionExpansionChanged(question.questionId);
                  },
                ),
              ),
              AnimatedSize(
                duration: MediaQuery.maybeOf(context)?.disableAnimations == true
                    ? CatchMotion.none
                    : CatchMotion.base,
                curve: CatchMotion.easeOutCubicCurve,
                alignment: Alignment.topCenter,
                child: expanded
                    ? Padding(
                        key: ValueKey(
                          'form-question-${question.questionId}-editor',
                        ),
                        padding: CatchInsets.sectionItemBottomGap,
                        child: _QuestionEditFields(
                          sectionIndex: sectionIndex,
                          questionIndex: questionIndex,
                          question: question,
                          questionCount: section.questions.length,
                          sections: definition.sections,
                          notifier: notifier,
                          compact: true,
                          onRemoved: () =>
                              onQuestionExpansionChanged(question.questionId),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
      CatchFieldLanes.single(
        child: CatchField.add(
          key: ValueKey('form-section-${section.sectionId}-add-question'),
          title: context.l10n.hostFormAddQuestion,
          icon: CatchIcons.addRounded,
          onTap: () => _showQuestionTypePicker(
            context,
            onSelected: (kind) => notifier.addQuestion(sectionIndex, kind),
          ),
        ),
      ),
    ],
  );
}

Future<void> _showSectionEditorSheet(
  BuildContext context, {
  required String organizerId,
  required String formId,
  required int sectionIndex,
  required HostFormSection section,
  required HostFormEditorController notifier,
}) => showCatchBottomSheet<void>(
  context: context,
  builder: (sheetContext) => Consumer(
    builder: (sheetContext, ref, _) {
      final liveDefinition = catchAsyncStateFromAsyncValue(
        ref.watch(hostFormEditorControllerProvider(organizerId, formId)),
      ).value?.editor.definition;
      final liveSectionIndex =
          liveDefinition?.sections.indexWhere(
            (candidate) => candidate.sectionId == section.sectionId,
          ) ??
          -1;
      final currentSection = liveSectionIndex < 0
          ? section
          : liveDefinition!.sections[liveSectionIndex];
      final currentSectionIndex = liveSectionIndex < 0
          ? sectionIndex
          : liveSectionIndex;
      return CatchBottomSheetScaffold(
        title: context.l10n.hostFormEditSection,
        subtitle: context.l10n.hostFormQuestionCount(
          count: currentSection.questions.length,
        ),
        keyboardSafe: true,
        child: CatchSection.containedFieldRows(
          children: [
            CatchField.input(
              key: ValueKey(
                'section-title-sheet-${currentSection.sectionId}-${currentSection.title}',
              ),
              title: context.l10n.hostFormSectionTitleLabel,
              initialValue: currentSection.title,
              autofocus: true,
              contractExemption:
                  'The backend form definition validates sections.',
              onBlur: (value) => notifier.updateSection(
                currentSectionIndex,
                title: value.trim(),
              ),
            ),
          ],
        ),
      );
    },
  ),
);

String _questionSummary(BuildContext context, HostFormQuestion question) =>
    context.l10n.hostFormQuestionSummary(
      type: hostFormQuestionKindLabel(context, question.kind),
      requirement: question.required
          ? context.l10n.hostFormRequiredShort
          : context.l10n.hostFormOptionalShort,
    );

String _availabilitySummary(
  BuildContext context,
  HostFormDefinition definition,
) {
  final opensAt = definition.opensAt;
  final closesAt = definition.closesAt;
  if (opensAt == null && closesAt == null) {
    return context.l10n.hostFormAvailabilityAlwaysOpen;
  }
  final localizations = MaterialLocalizations.of(context);
  final opensLabel = opensAt == null
      ? null
      : context.l10n.hostFormAvailabilityOpens(
          date: localizations.formatMediumDate(opensAt.toLocal()),
        );
  final closesLabel = closesAt == null
      ? null
      : context.l10n.hostFormAvailabilityCloses(
          date: localizations.formatMediumDate(closesAt.toLocal()),
        );
  return [opensLabel, closesLabel].whereType<String>().join(' · ');
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
        CatchField.nav(
          key: ValueKey(questionEntry.$2.questionId),
          title: questionEntry.$2.label,
          body: _questionSummary(context, questionEntry.$2),
          onTap: () => onSelectionChanged(sectionIndex, questionEntry.$1),
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

class _QuestionEditFields extends StatelessWidget {
  const _QuestionEditFields({
    required this.sectionIndex,
    required this.questionIndex,
    required this.question,
    required this.questionCount,
    required this.sections,
    required this.notifier,
    this.compact = false,
    this.onRemoved,
  });

  final int sectionIndex;
  final int questionIndex;
  final HostFormQuestion question;
  final int questionCount;
  final List<HostFormSection> sections;
  final HostFormEditorController notifier;
  final bool compact;
  final VoidCallback? onRemoved;

  @override
  Widget build(BuildContext context) {
    final primaryFields = <Widget>[
      CatchFieldLanes.single(
        child: CatchField.input(
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
      if (sections.length > 1)
        CatchField.select<int>(
          key: ValueKey(
            'question-section-${question.questionId}-$sectionIndex',
          ),
          title: context.l10n.hostFormMoveToSection,
          contractExemption:
              'Moves an existing question between sections without changing '
              'a schema-backed field value.',
          values: List<int>.generate(sections.length, (index) => index),
          value: sectionIndex,
          itemLabel: (index) => sections[index].title,
          onChanged: (targetSectionIndex) {
            if (targetSectionIndex == null ||
                targetSectionIndex == sectionIndex) {
              return;
            }
            notifier.moveQuestionToSection(
              questionId: question.questionId,
              targetSectionIndex: targetSectionIndex,
            );
          },
        ),
      CatchFieldLanes.single(
        child: CatchField.input(
          key: ValueKey(
            'question-help-${question.questionId}-${question.helpText}',
          ),
          title: context.l10n.hostFormQuestionHelpLabel,
          initialValue: question.helpText,
          isOptional: true,
          maxLines: 3,
          contractExemption: 'The form contract validates question help.',
          onBlur: (value) => notifier.updateQuestion(
            sectionIndex,
            questionIndex,
            helpText: value.trim(),
            clearHelpText: value.trim().isEmpty,
          ),
        ),
      ),
      CatchFieldLanes.single(
        child: CatchField.toggle(
          title: context.l10n.hostFormQuestionRequired,
          value: question.required,
          contractExemption: 'Requiredness is part of the form definition.',
          onChanged: (value) => notifier.updateQuestion(
            sectionIndex,
            questionIndex,
            required: value,
          ),
        ),
      ),
    ];
    final advancedFields = <Widget>[
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
        itemLabel: (value) => _presentationLabel(context, value),
        onChanged: (value) => notifier.updateQuestion(
          sectionIndex,
          questionIndex,
          hostPresentation: value,
        ),
      ),
      for (final optionEntry in question.options.indexed)
        CatchFieldLanes.single(
          child: CatchField.input(
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
        ),
      if (question.options.isNotEmpty)
        CatchFieldLanes.single(
          child: CatchField.add(
            title: context.l10n.hostFormAddOption,
            onTap: () => notifier.addOption(sectionIndex, questionIndex),
          ),
        ),
      _QuestionValidationFormSchemaFields(
        sectionIndex: sectionIndex,
        questionIndex: questionIndex,
        question: question,
        notifier: notifier,
      ),
    ];
    return CatchSection.fieldRows(
      first: true,
      children: [
        ...primaryFields,
        if (compact)
          CatchField.control(
            title: context.l10n.hostFormAdvancedQuestionSettings,
            body: context.l10n.hostFormAdvancedQuestionSettingsHelp,
            contractExemption:
                'Disclosure groups advanced fields from the form definition.',
            control: CatchFieldLanes.divided(children: advancedFields),
          )
        else
          ...advancedFields,
        if (!compact)
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
          onPressed: () {
            notifier.removeQuestion(sectionIndex, questionIndex);
            onRemoved?.call();
          },
        ),
      ],
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
        CatchField.select<HostFormPatternPreset>(
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
        if (validation.patternPreset != null)
          CatchFieldLanes.single(
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
    return CatchFieldLanes.custom(
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
  Widget build(BuildContext context) => CatchFieldLanes.single(
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
  Widget build(BuildContext context) => CatchFieldLanes.single(
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
    return _QuestionEditFields(
      sectionIndex: sectionIndex!,
      questionIndex: questionIndex!,
      question: question,
      questionCount: section.questions.length,
      sections: definition.sections,
      notifier: notifier,
    );
  }
}

Future<void> _showQuestionTypePicker(
  BuildContext context, {
  required ValueChanged<HostFormQuestionKind> onSelected,
}) async {
  const recommended = [
    HostFormQuestionKind.shortText,
    HostFormQuestionKind.phone,
    HostFormQuestionKind.longText,
    HostFormQuestionKind.singleChoice,
  ];
  final more = HostFormQuestionKind.values
      .where((value) => !recommended.contains(value))
      .toList(growable: false);
  final kind = await showCatchBottomSheet<HostFormQuestionKind>(
    context: context,
    builder: (sheetContext) => CatchBottomSheetScaffold(
      title: context.l10n.hostFormChooseQuestionType,
      subtitle: context.l10n.hostFormChooseQuestionTypeHelp,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.65,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CatchSection.fieldRows(
                title: context.l10n.hostFormRecommendedQuestionTypes,
                first: true,
                children: [
                  for (final value in recommended)
                    CatchField.nav(
                      title: hostFormQuestionKindLabel(context, value),
                      onTap: () => Navigator.of(sheetContext).pop(value),
                    ),
                ],
              ),
              gapH20,
              CatchSection.fieldRows(
                title: context.l10n.hostFormMoreQuestionTypes,
                children: [
                  for (final value in more)
                    CatchField.nav(
                      title: hostFormQuestionKindLabel(context, value),
                      onTap: () => Navigator.of(sheetContext).pop(value),
                    ),
                ],
              ),
            ],
          ),
        ),
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
  Widget build(BuildContext context) => CatchFieldLanes.single(
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
