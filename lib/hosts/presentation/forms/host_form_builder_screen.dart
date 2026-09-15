import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_error_snack_bar.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_configuration.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_definition.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_question.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_section.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_copy.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_metrics.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_question_section.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_renderer.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_responses_panel.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_settings_section_list.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum HostFormWorkspaceView { overview, questions, responses, settings }

enum _BuilderAction { preview, share, settings, pause, resume, archive }

enum _SectionAction { edit, moveUp, moveDown, remove }

class HostFormBuilderScreen extends ConsumerStatefulWidget {
  const HostFormBuilderScreen({
    super.key,
    required this.organizerId,
    required this.formId,
    this.initialView,
  });

  final String organizerId;
  final String formId;
  final HostFormWorkspaceView? initialView;

  @override
  ConsumerState<HostFormBuilderScreen> createState() =>
      _HostFormBuilderScreenState();
}

class _HostFormBuilderScreenState extends ConsumerState<HostFormBuilderScreen> {
  int? _selectedSection;
  int? _selectedQuestion;
  HostFormWorkspaceView? _view;

  @override
  void initState() {
    super.initState();
    _view = widget.initialView;
  }

  @override
  void didUpdateWidget(covariant HostFormBuilderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.formId != widget.formId ||
        oldWidget.organizerId != widget.organizerId) {
      _selectedSection = null;
      _selectedQuestion = null;
      _view = widget.initialView;
    } else if (oldWidget.initialView != widget.initialView) {
      _view = widget.initialView;
    }
  }

  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(
      hostFormEditorControllerProvider(widget.organizerId, widget.formId),
    );
    final editorValue = catchAsyncStateFromAsyncValue(editor).value;
    final notifier = ref.read(
      hostFormEditorControllerProvider(
        widget.organizerId,
        widget.formId,
      ).notifier,
    );
    final compact =
        MediaQuery.sizeOf(context).width <
        CatchFormWorkspaceTokens.formBuilderExpandedBreakpoint;
    final view =
        _view ??
        (editorValue?.editor.form.activeVersionId == null
            ? HostFormWorkspaceView.questions
            : HostFormWorkspaceView.overview);
    final settings = view == HostFormWorkspaceView.settings;

    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title: settings
            ? context.l10n.hostFormSettings
            : context.l10n.hostAudienceFormWorkspaceTitle,
        subtitle: settings && editorValue != null
            ? hostFormSaveLabel(context, editorValue)
            : null,
        navigation: const CatchTopBarNavigation(
          mode: CatchTopBarNavigationMode.back,
        ),
        emphasis: scrolledUnder
            ? CatchTopBarEmphasis.divided
            : CatchTopBarEmphasis.plain,
        actions: [
          if (view == HostFormWorkspaceView.questions && compact)
            CatchIconAction.toolbar(
              icon: CatchIcons.visibilityOutlined,
              tooltip: context.l10n.hostFormPreview,
              onPressed: editorValue == null ? null : _openPreview,
            ),
          if (view == HostFormWorkspaceView.questions &&
              !compact &&
              editorValue != null &&
              editorValue.editor.form.status !=
                  HostFormLifecycleStatus.archived)
            CatchTopBarPrimaryButton(
              label:
                  editorValue.editor.form.status ==
                      HostFormLifecycleStatus.published
                  ? context.l10n.hostFormReviewPublishChanges
                  : context.l10n.hostFormReviewPublish,
              icon: CatchIcons.checkCircleOutlineRounded,
              onPressed: editorValue.operationInProgress
                  ? null
                  : () => _reviewAndPublish(notifier, editorValue),
            ),
          if (editorValue != null &&
              _builderActions(
                context,
                editorValue,
                includePreview: !compact,
              ).isNotEmpty)
            CatchActionMenu<_BuilderAction>(
              tooltip: context.l10n.hostFormsActions,
              items: _builderActions(
                context,
                editorValue,
                includePreview: !compact,
              ),
              onSelected: (action) => _runBuilderAction(notifier, action),
            ),
        ],
      ),
      footer: _HostFormBuilderBottomAction(
        state: editorValue,
        visible: compact && view == HostFormWorkspaceView.questions,
        onReviewAndPublish: editorValue == null
            ? null
            : () => _reviewAndPublish(notifier, editorValue),
      ),
      body: CatchRouteBody.fullBleed(
        child: SafeArea(
          top: false,
          bottom: false,
          child: CatchAsyncBoundary<HostFormEditorState>(
            value: editor,
            onRetry: notifier.reload,
            initialLoadTimeout: null,
            loadingBuilder: (_) =>
                const CatchPageBody(child: CatchSkeleton.rows(count: 8)),
            errorBuilder: (_, error, _, onBoundaryRetry) => CatchPageBody(
              child: CatchLocalizedErrorState(
                error,
                context: AppErrorContext.forms,
                onRetry: onBoundaryRetry,
              ),
            ),
            builder: (context, value) {
              final header = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HostFormWorkspaceHeader(
                    state: value,
                    selected: view,
                    onChanged: (next) => setState(() => _view = next),
                  ),
                  if ((view == HostFormWorkspaceView.questions || settings) &&
                      (value.canUndo || value.canRedo)) ...[
                    gapH12,
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: CatchSpacing.s2,
                      children: [
                        CatchIconAction(
                          tooltip: context.l10n.hostFormUndo,
                          onPressed: value.canUndo && !value.operationInProgress
                              ? notifier.undo
                              : null,
                          child: Icon(CatchIcons.undoRounded),
                        ),
                        CatchIconAction(
                          tooltip: context.l10n.hostFormRedo,
                          onPressed: value.canRedo && !value.operationInProgress
                              ? notifier.redo
                              : null,
                          child: Icon(CatchIcons.redoRounded),
                        ),
                      ],
                    ),
                  ],
                ],
              );
              if (!compact && view == HostFormWorkspaceView.questions) {
                final definition = value.editor.definition;
                final sectionIndex = _validSectionIndex(definition);
                return Column(
                  children: [
                    CatchPageBody.screen(
                      variant: CatchPageBodyVariant.fixed,
                      pb: CatchSpacing.s4,
                      child: header,
                    ),
                    Expanded(
                      child: _ExpandedFormEditor(
                        state: value,
                        notifier: notifier,
                        sectionIndex: sectionIndex,
                        questionIndex: _validQuestionIndex(
                          definition,
                          sectionIndex,
                        ),
                        onSelectionChanged: (section, question) => setState(() {
                          _selectedSection = section;
                          _selectedQuestion = question;
                        }),
                      ),
                    ),
                  ],
                );
              }
              return CatchPageBody.screen(
                key: ValueKey('host-form-builder-${view.name}'),
                pb: CatchSpacing.s10,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: CatchLayout.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header,
                        gapH24,
                        switch (view) {
                          HostFormWorkspaceView.overview =>
                            HostFormWorkspaceOverview(
                              organizerId: widget.organizerId,
                              state: value,
                              onQuestions: () => setState(
                                () => _view = HostFormWorkspaceView.questions,
                              ),
                              onReviewResponses: () => setState(
                                () => _view = HostFormWorkspaceView.responses,
                              ),
                              onSettings: () => _openFormSettings(
                                context,
                                organizerId: widget.organizerId,
                                formId: widget.formId,
                              ),
                              onShare: () => _runBuilderAction(
                                notifier,
                                _BuilderAction.share,
                              ),
                              onPreview: _openPreview,
                            ),
                          HostFormWorkspaceView.questions => _CompactFormEditor(
                            organizerId: widget.organizerId,
                            formId: widget.formId,
                            state: value,
                            notifier: notifier,
                            onSelectionChanged: (section, question) =>
                                setState(() {
                                  _selectedSection = section;
                                  _selectedQuestion = question;
                                }),
                          ),
                          HostFormWorkspaceView.responses =>
                            HostFormResponsesPanel(
                              organizerId: widget.organizerId,
                              formId: widget.formId,
                              formTitle: value.editor.definition.title,
                              showFormContext: false,
                            ),
                          HostFormWorkspaceView.settings => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _FormStatusNotices(
                                state: value,
                                notifier: notifier,
                              ),
                              HostFormSettingsSectionList(
                                definition: value.editor.definition,
                                notifier: notifier,
                              ),
                            ],
                          ),
                        },
                      ],
                    ),
                  ),
                ),
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
    HostFormEditorState state, {
    required bool includePreview,
  }) {
    final status = state.editor.form.status;
    return [
      CatchActionMenuItem(
        value: _BuilderAction.settings,
        label: context.l10n.hostFormSettings,
        icon: CatchIcons.settingsOutlined,
      ),
      if (includePreview)
        CatchActionMenuItem(
          value: _BuilderAction.preview,
          label: context.l10n.hostFormPreview,
          icon: CatchIcons.visibilityOutlined,
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
      case _BuilderAction.settings:
        await _openFormSettings(
          context,
          organizerId: widget.organizerId,
          formId: widget.formId,
        );
      case _BuilderAction.preview:
        _openPreview();
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
      builder: (sheetContext) => CatchSheet(
        mode: CatchSheetMode.scrollable,
        title: state.editor.form.status == HostFormLifecycleStatus.published
            ? context.l10n.hostFormReviewChangesTitle
            : context.l10n.hostFormReviewPublishTitle,
        subtitle: context.l10n.hostFormReviewPublishSubtitle,
        footer: Column(
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
              copy: catchFieldCopy(context.l10n),
              title: context.l10n.hostFormQuestionsTitle,
              body: context.l10n.hostFormQuestionCount(count: questionCount),
            ),
            CatchField.read(
              copy: catchFieldCopy(context.l10n),
              title: context.l10n.hostFormIdentityLabel,
              body: hostFormIdentityLabel(context, definition.identityPolicy),
            ),
            CatchField.read(
              copy: catchFieldCopy(context.l10n),
              title: context.l10n.hostFormConsequencesTitle,
              body: hostFormBuilderConsequenceSummary(
                context,
                purpose: definition.purpose,
                identityPolicy: definition.identityPolicy,
                consequences: state.editor.form.consequences,
              ),
              bodyMaxLines: 8,
            ),
            CatchField.read(
              copy: catchFieldCopy(context.l10n),
              title: context.l10n.hostFormMessagingPermissionTitle,
              body: context.l10n.hostFormConsequenceNoMessagingPermission,
              bodyMaxLines: 4,
            ),
            CatchField.read(
              copy: catchFieldCopy(context.l10n),
              title: context.l10n.hostFormAvailability,
              body: hostFormAvailabilitySummary(context, definition),
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
      showCatchSnackBar(context, context.l10n.hostFormPublished);
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
      _BuilderAction.preview ||
      _BuilderAction.settings ||
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
    return CatchDockSurface.primary(
      label: current.editor.form.status == HostFormLifecycleStatus.published
          ? context.l10n.hostFormReviewPublishChanges
          : context.l10n.hostFormReviewPublish,
      isLoading: isLoading,
      buttonMode: CatchButtonMode.rounded,
      onPressed: isLoading ? null : onReviewAndPublish,
    );
  }
}

class HostFormWorkspaceHeader extends StatelessWidget {
  const HostFormWorkspaceHeader({
    super.key,
    required this.state,
    required this.selected,
    required this.onChanged,
  });
  final HostFormEditorState state;
  final HostFormWorkspaceView selected;
  final ValueChanged<HostFormWorkspaceView> onChanged;

  @override
  Widget build(BuildContext context) {
    final form = state.editor.form;
    if (selected == HostFormWorkspaceView.settings) {
      return Text(
        state.editor.definition.title,
        style: CatchTextStyles.supporting(context),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          state.editor.definition.title,
          key: const ValueKey('host-form-command-center-title'),
          style: CatchTextStyles.titleL(context),
        ),
        gapH8,
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CatchBadge.status(
              label: hostFormStatusLabel(context, form.status),
              tone: form.status == HostFormLifecycleStatus.published
                  ? CatchBadgeTone.success
                  : CatchBadgeTone.neutral,
            ),
            Text(
              form.activeVersionId == null
                  ? hostFormSaveLabel(context, state)
                  : context.l10n.hostAudienceFormVersionContext(
                      purpose: hostFormPurposeLabel(context, form.purpose),
                      version: form.publishedVersion,
                    ),
              style: CatchTextStyles.supporting(context),
            ),
          ],
        ),
        gapH24,
        CatchPageTabBar<HostFormWorkspaceView>(
          groupKey: const ValueKey('host-form-builder-tabs'),
          selected: selected,
          options: [
            CatchOption(
              value: HostFormWorkspaceView.overview,
              label: context.l10n.hostAudienceFormOverview,
            ),
            CatchOption(
              value: HostFormWorkspaceView.questions,
              label: context.l10n.hostFormQuestionsTitle,
            ),
            CatchOption(
              value: HostFormWorkspaceView.responses,
              label: context.l10n.hostFormsViewResponses,
            ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class HostFormWorkspaceOverview extends ConsumerWidget {
  const HostFormWorkspaceOverview({
    super.key,
    required this.organizerId,
    required this.state,
    required this.onQuestions,
    required this.onReviewResponses,
    required this.onSettings,
    required this.onShare,
    required this.onPreview,
  });
  final String organizerId;
  final HostFormEditorState state;
  final VoidCallback onQuestions;
  final VoidCallback onReviewResponses;
  final VoidCallback onSettings;
  final VoidCallback onShare;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = state.editor.form;
    final questionCount = state.editor.definition.sections.fold<int>(
      0,
      (count, section) => count + section.questions.length,
    );
    final request = HostFormResponseListRequest(
      organizerId: organizerId,
      formId: form.formId,
      statuses: const {HostFormResponseStatus.submitted},
      limit: 1,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HostFormMetrics(
          key: const ValueKey('host-form-command-center-metrics'),
          items: [
            (
              value: '${form.submittedResponseCount}',
              label: context.l10n.hostFormsViewResponses,
            ),
            (
              value: '$questionCount',
              label: context.l10n.hostFormQuestionsTitle,
            ),
          ],
        ),
        gapH24,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CatchButton(
                label: form.activeVersionId != null
                    ? context.l10n.hostFormShare
                    : context.l10n.hostAudienceEditQuestions,
                mode: CatchButtonMode.rounded,
                fullWidth: true,
                onPressed: form.activeVersionId != null ? onShare : onQuestions,
              ),
            ),
            gapW12,
            Expanded(
              child: CatchButton(
                label: context.l10n.hostFormPreview,
                variant: CatchButtonVariant.secondary,
                mode: CatchButtonMode.rounded,
                fullWidth: true,
                onPressed: onPreview,
              ),
            ),
          ],
        ),
        if (form.activeVersionId != null) ...[
          gapH32,
          CatchSection.divided(
            title: context.l10n.hostAudienceLatestResponse,
            first: true,
            child: CatchAsyncBoundary<HostFormResponsesState>(
              value: ref.watch(hostFormResponsesControllerProvider(request)),
              onRetry: () =>
                  ref.invalidate(hostFormResponsesControllerProvider(request)),
              loadingBuilder: (_) => const CatchSkeleton.rows(count: 1),
              errorBuilder: (_, error, _, onBoundaryRetry) =>
                  CatchLocalizedErrorState(
                    error,
                    context: AppErrorContext.formResponses,
                    mode: CatchErrorStateMode.compact,
                    onRetry: onBoundaryRetry,
                  ),
              builder: (context, value) {
                final response = value.responses.firstOrNull;
                if (response == null) {
                  return Text(
                    context.l10n.hostFormResponsesEmptyBody,
                    style: CatchTextStyles.supporting(context),
                  );
                }
                return CatchPersonRow.directory(
                  key: const ValueKey(
                    'host-form-command-center-recent-response',
                  ),
                  data: CatchPersonRowData(
                    name:
                        response.identity.primaryLabel ??
                        context.l10n.hostFormResponsesAnonymous,
                    seed: response.responseId,
                  ),
                  meta: Text(
                    response.sourceLabel ??
                        context.l10n.hostFormResponseDirectSource,
                    style: CatchTextStyles.supporting(context),
                  ),
                  body: Text(
                    AppTimeFormatters.compactRelativeTime(response.submittedAt),
                    style: CatchTextStyles.recordContext(context),
                  ),
                  onTap: () => context.pushNamed(
                    Routes.hostFormResponseDetailScreen.name,
                    pathParameters: {'responseId': response.responseId},
                    queryParameters: {'organizerId': organizerId},
                  ),
                );
              },
            ),
          ),
          CatchButton.command(
            label: context.l10n.hostFormsViewResponsesAction,
            leading: Icon(CatchIcons.forwardArrow),
            onPressed: onReviewResponses,
          ),
        ],
        gapH24,
        CatchSection.fieldRows(
          children: [
            if (form.activeVersionId != null)
              CatchField.nav(
                copy: catchFieldCopy(context.l10n),
                title: context.l10n.hostFormsAnalyticsAction,
                icon: CatchIcons.insightsOutlined,
                emphasis: CatchFieldEmphasis.title,
                onTap: () => context.pushNamed(
                  Routes.hostFormAnalyticsScreen.name,
                  pathParameters: {'formId': form.formId},
                  queryParameters: {'organizerId': organizerId},
                ),
              ),
            CatchField.nav(
              copy: catchFieldCopy(context.l10n),
              title: context.l10n.hostFormSettings,
              icon: CatchIcons.settingsOutlined,
              emphasis: CatchFieldEmphasis.title,
              onTap: onSettings,
            ),
            CatchField.nav(
              copy: catchFieldCopy(context.l10n),
              title: context.l10n.hostFormsAutomationsAction,
              icon: CatchIcons.autoAwesomeOutlined,
              emphasis: CatchFieldEmphasis.title,
              onTap: () => context.pushNamed(
                Routes.hostFormAutomationsScreen.name,
                pathParameters: {'formId': form.formId},
                queryParameters: {'organizerId': organizerId},
              ),
            ),
          ],
        ),
        gapH24,
        CatchSection.divided(
          title: context.l10n.hostFormConsequencesTitle,
          child: Text(
            hostFormConsequenceSummary(context, form),
            style: CatchTextStyles.supporting(context),
          ),
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
          organizerId: widget.organizerId,
          formId: widget.formId,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
              copy: catchFieldCopy(context.l10n),
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
    required this.organizerId,
    required this.formId,
  });
  final String organizerId;
  final String formId;
  @override
  Widget build(BuildContext context) => CatchSection.fieldRows(
    children: [
      CatchField.nav(
        copy: catchFieldCopy(context.l10n),
        key: const ValueKey('host-form-settings-entry'),
        title: context.l10n.hostFormSettings,
        icon: CatchIcons.settingsOutlined,
        emphasis: CatchFieldEmphasis.title,
        onTap: () => _openFormSettings(
          context,
          organizerId: organizerId,
          formId: formId,
        ),
      ),
      CatchField.nav(
        copy: catchFieldCopy(context.l10n),
        title: context.l10n.hostAudienceQuestionPreview,
        icon: CatchIcons.visibilityOutlined,
        emphasis: CatchFieldEmphasis.title,
        onTap: () => context.pushNamed(
          Routes.hostFormPreviewScreen.name,
          pathParameters: {'formId': formId},
          queryParameters: {'organizerId': organizerId},
        ),
      ),
    ],
  );
}

Future<void> _openFormSettings(
  BuildContext context, {
  required String organizerId,
  required String formId,
}) => context.pushNamed(
  Routes.hostFormBuilderScreen.name,
  pathParameters: {'formId': formId},
  queryParameters: {
    'organizerId': organizerId,
    'view': HostFormWorkspaceView.settings.name,
  },
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
      variant: CatchIconActionVariant.plain,
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
                  copy: catchFieldCopy(context.l10n),
                  title: question.label,
                  metadata: hostFormQuestionSummary(context, question),
                  leading: section.questions.length > 1
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
                        child: HostFormQuestionSection(
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
          copy: catchFieldCopy(context.l10n),
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
      return CatchSheet(
        title: context.l10n.hostFormEditSection,
        subtitle: context.l10n.hostFormQuestionCount(
          count: currentSection.questions.length,
        ),
        keyboardSafe: true,
        child: CatchSection.containedFieldRows(
          children: [
            CatchField.input(
              copy: catchFieldCopy(context.l10n),
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
                width: CatchFormWorkspaceTokens.formBuilderOutlineWidth,
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
                width: CatchFormWorkspaceTokens.formBuilderInspectorWidth,
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
          dismissLabel: context.l10n.coreCatchNoticeTooltipDismiss,
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
          dismissLabel: context.l10n.coreCatchNoticeTooltipDismiss,
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
          dismissLabel: context.l10n.coreCatchNoticeTooltipDismiss,
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
        copy: catchFieldCopy(context.l10n),
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
          copy: catchFieldCopy(context.l10n),
          key: ValueKey(questionEntry.$2.questionId),
          title: questionEntry.$2.label,
          body: hostFormQuestionSummary(context, questionEntry.$2),
          onTap: () => onSelectionChanged(sectionIndex, questionEntry.$1),
        ),
      CatchField.add(
        copy: catchFieldCopy(context.l10n),
        title: context.l10n.hostFormAddQuestion,
        icon: CatchIcons.addRounded,
        onTap: () => _showQuestionTypePicker(
          context,
          onSelected: (kind) => notifier.addQuestion(sectionIndex, kind),
        ),
      ),
      CatchField.action(
        copy: catchFieldCopy(context.l10n),
        title: context.l10n.hostFormMoveSectionUp,
        icon: CatchIcons.arrowUpwardRounded,
        onTap: sectionIndex == 0
            ? null
            : () => notifier.moveSection(sectionIndex, -1),
      ),
      CatchField.action(
        copy: catchFieldCopy(context.l10n),
        title: context.l10n.hostFormMoveSectionDown,
        icon: CatchIcons.arrowDownwardRounded,
        onTap: sectionIndex == sectionCount - 1
            ? null
            : () => notifier.moveSection(sectionIndex, 1),
      ),
      CatchField.action(
        copy: catchFieldCopy(context.l10n),
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
              copy: catchFieldCopy(context.l10n),
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
                copy: catchFieldCopy(context.l10n),
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
      return HostFormSettingsSectionList(
        definition: definition,
        notifier: notifier,
      );
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
    return HostFormQuestionSection(
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
    builder: (sheetContext) => CatchSheet(
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
                      copy: catchFieldCopy(context.l10n),
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
                      copy: catchFieldCopy(context.l10n),
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
