import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/domain/host_form.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_responses_panel.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_organizer_selection_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _HostFormsView { forms, responses }

enum _HostFormRowAction {
  open,
  responses,
  analytics,
  automations,
  duplicate,
  pause,
  resume,
  archive,
  delete,
}

class HostFormsScreen extends ConsumerStatefulWidget {
  const HostFormsScreen({
    super.key,
    this.initialOrganizerId,
    this.initialResponses = false,
    this.initialFormId,
  });

  final String? initialOrganizerId;
  final bool initialResponses;
  final String? initialFormId;

  @override
  ConsumerState<HostFormsScreen> createState() => _HostFormsScreenState();
}

class _HostFormsScreenState extends ConsumerState<HostFormsScreen> {
  Timer? _searchDebounce;
  String? _query;
  HostFormLifecycleStatus? _status;
  late _HostFormsView _view;
  String? _responseFormId;
  String? _responseFormTitle;

  @override
  void initState() {
    super.initState();
    _view = widget.initialResponses
        ? _HostFormsView.responses
        : _HostFormsView.forms;
    _responseFormId = widget.initialFormId;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uidAsync = ref.watch(uidProvider);
    final uidState = catchAsyncStateFromAsyncValue(uidAsync);
    final uid = uidState.value;
    if (uidState.hasError) {
      return CatchErrorScaffold.fromError(
        uidState.error!,
        context: AppErrorContext.auth,
        onRetry: () => ref.invalidate(uidProvider),
      );
    }
    if (uidState.isLoading) {
      return HostLoadingScreen(title: context.l10n.hostNavigationForms);
    }
    if (uid == null) return const HostAuthRequiredScreen();

    final clubsAsync = ref.watch(hostOperableClubsProvider(uid));
    final clubsState = catchAsyncStateFromAsyncValue(clubsAsync);
    if (clubsState.hasError) {
      return CatchErrorScaffold.fromError(
        clubsState.error!,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(hostOperableClubsProvider(uid)),
      );
    }
    if (clubsState.isLoading) {
      return HostLoadingScreen(title: context.l10n.hostNavigationForms);
    }
    final clubs = clubsState.value ?? const <Club>[];
    if (clubs.isEmpty) {
      return const HostFormsNoOrganizer();
    }
    final selectedOrganizerId = ref.watch(hostOrganizerSelectionProvider(uid));
    final selectedClub = resolveSelectedHostOrganizer(
      clubs,
      selectedOrganizerId: selectedOrganizerId,
      preferredOrganizerId: selectedOrganizerId == null
          ? widget.initialOrganizerId
          : null,
    )!;
    final request = HostFormListRequest(
      organizerId: selectedClub.id,
      statuses: _status == null ? const {} : {_status!},
      query: _query,
    );
    final directory = ref.watch(hostFormsDirectoryControllerProvider(request));
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: CatchScreenHeaderTitle.block(
                title: context.l10n.hostNavigationForms,
                actions: _view == _HostFormsView.forms
                    ? [
                        CatchButton(
                          key: const ValueKey('host-forms-create'),
                          label: context.l10n.hostFormsCreate,
                          icon: Icon(CatchIcons.add, size: CatchIcon.sm),
                          size: CatchButtonSize.sm,
                          onPressed: () => context.pushNamed(
                            Routes.hostFormTemplatesScreen.name,
                            queryParameters: {'organizerId': selectedClub.id},
                          ),
                        ),
                      ]
                    : const [],
              ),
            ),
            SliverPadding(
              padding: CatchInsets.pageHorizontal,
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      CatchChip.selectable(
                        label: context.l10n.hostFormsViewForms,
                        selected: _view == _HostFormsView.forms,
                        contractExemption:
                            'Local workspace view selection has no backend enum.',
                        onChanged: (_) =>
                            setState(() => _view = _HostFormsView.forms),
                      ),
                      gapW8,
                      CatchChip.selectable(
                        label: context.l10n.hostFormsViewResponses,
                        selected: _view == _HostFormsView.responses,
                        contractExemption:
                            'Local workspace view selection has no backend enum.',
                        onChanged: (_) => setState(() {
                          _view = _HostFormsView.responses;
                          _responseFormId = null;
                          _responseFormTitle = null;
                        }),
                      ),
                    ],
                  ),
                  gapH16,
                  if (_view == _HostFormsView.responses)
                    HostFormResponsesPanel(
                      organizerId: selectedClub.id,
                      formId: _responseFormId,
                      formTitle: _responseFormTitle,
                      onClearFormFilter: () => setState(() {
                        _responseFormId = null;
                        _responseFormTitle = null;
                      }),
                    )
                  else ...[
                    Text(
                      context.l10n.hostFormsSubtitle,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                    gapH16,
                    CatchSearchField(
                      key: const ValueKey('host-forms-search'),
                      mode: CatchSearchFieldMode.expanded,
                      value: _query ?? '',
                      contract: CatchContractConstraints
                          .listOrganizerFormsCallablePayloadQuery,
                      placeholder: context.l10n.hostFormsSearch,
                      semanticLabel: context.l10n.hostFormsSearch,
                      textInputAction: TextInputAction.search,
                      onChanged: _scheduleSearch,
                      onSubmitted: _applySearch,
                      onCloseSearch: () => _applySearch(''),
                    ),
                    gapH12,
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          CatchChip.selectable(
                            label: context.l10n.hostFormsFilterAll,
                            selected: _status == null,
                            contractExemption:
                                'All intentionally omits the optional status filter.',
                            onChanged: (_) => setState(() => _status = null),
                          ),
                          for (final status
                              in HostFormLifecycleStatus.values) ...[
                            gapW8,
                            CatchChip.selectable(
                              label: hostFormStatusLabel(context, status),
                              selected: _status == status,
                              contract: CatchContractConstraints
                                  .listOrganizerFormsCallablePayloadStatusesItems,
                              contractValue: status.name,
                              onChanged: (_) =>
                                  setState(() => _status = status),
                            ),
                          ],
                        ],
                      ),
                    ),
                    gapH16,
                    CatchAsyncValueView<HostFormsDirectoryState>(
                      value: directory,
                      onRetry: () => ref.invalidate(
                        hostFormsDirectoryControllerProvider(request),
                      ),
                      initialLoadTimeout: null,
                      loadingBuilder: (_) => const CatchSkeletonRows(count: 6),
                      errorBuilder: (_, error, _) => CatchErrorState.fromError(
                        error,
                        context: AppErrorContext.forms,
                        mode: CatchErrorStateMode.compact,
                        onRetry: () => ref.invalidate(
                          hostFormsDirectoryControllerProvider(request),
                        ),
                      ),
                      builder: (context, state) {
                        if (state.forms.isEmpty) {
                          return CatchEmptyState(
                            icon: CatchIcons.descriptionOutlined,
                            title: _query == null && _status == null
                                ? context.l10n.hostFormsEmptyTitle
                                : context.l10n.hostFormsNoMatchesTitle,
                            message: _query == null && _status == null
                                ? context.l10n.hostFormsEmptyBody
                                : context.l10n.hostFormsNoMatchesBody,
                            action: _query == null && _status == null
                                ? CatchButton(
                                    label: context.l10n.hostFormsCreate,
                                    size: CatchButtonSize.sm,
                                    onPressed: () => context.pushNamed(
                                      Routes.hostFormTemplatesScreen.name,
                                      queryParameters: {
                                        'organizerId': selectedClub.id,
                                      },
                                    ),
                                  )
                                : null,
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CatchSection.containedFieldRows(
                              children: [
                                for (final form in state.forms)
                                  CatchField.nav(
                                    key: ValueKey('host-form-${form.formId}'),
                                    title: form.title,
                                    body: _formSummaryBody(context, form),
                                    valueText:
                                        AppTimeFormatters.compactRelativeTime(
                                          form.lastResponseAt ?? form.updatedAt,
                                        ),
                                    onTap: () => _openForm(form),
                                    action: CatchActionMenu<_HostFormRowAction>(
                                      tooltip: context.l10n.hostFormsActions,
                                      items: _rowActions(context, form),
                                      onSelected: (action) => _handleRowAction(
                                        action,
                                        form,
                                        request,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (state.canLoadMore) ...[
                              gapH16,
                              CatchButton(
                                label: context.l10n.hostFormsLoadMore,
                                variant: CatchButtonVariant.secondary,
                                isLoading: state.loadingMore,
                                fullWidth: true,
                                onPressed: state.loadingMore
                                    ? null
                                    : () => ref
                                          .read(
                                            hostFormsDirectoryControllerProvider(
                                              request,
                                            ).notifier,
                                          )
                                          .loadMore(),
                              ),
                            ],
                            if (state.loadMoreError != null) ...[
                              gapH12,
                              CatchErrorState.fromError(
                                state.loadMoreError!,
                                context: AppErrorContext.forms,
                                mode: CatchErrorStateMode.compact,
                                onRetry: () => ref
                                    .read(
                                      hostFormsDirectoryControllerProvider(
                                        request,
                                      ).notifier,
                                    )
                                    .loadMore(),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            const CatchSliverTerminalPadding(),
          ],
        ),
      ),
    );
  }

  void _scheduleSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      CatchMotion.searchDebounce,
      () => _applySearch(value),
    );
  }

  void _applySearch(String value) {
    if (!mounted) return;
    final normalized = value.trim();
    setState(() => _query = normalized.isEmpty ? null : normalized);
  }

  String _formSummaryBody(BuildContext context, HostFormSummary form) {
    final purpose = hostFormPurposeLabel(context, form.purpose);
    final status = hostFormStatusLabel(context, form.status);
    return context.l10n.hostFormsRowSummary(
      purpose: purpose,
      status: status,
      count: form.submittedResponseCount,
    );
  }

  List<CatchActionMenuItem<_HostFormRowAction>> _rowActions(
    BuildContext context,
    HostFormSummary form,
  ) => [
    CatchActionMenuItem(
      value: _HostFormRowAction.open,
      label: context.l10n.hostFormsOpen,
      icon: CatchIcons.edit,
    ),
    if (form.submittedResponseCount > 0)
      CatchActionMenuItem(
        value: _HostFormRowAction.responses,
        label: context.l10n.hostFormsViewResponsesAction,
        icon: CatchIcons.descriptionOutlined,
      ),
    if (form.activeVersionId != null)
      CatchActionMenuItem(
        value: _HostFormRowAction.analytics,
        label: context.l10n.hostFormsAnalyticsAction,
        icon: CatchIcons.insightsOutlined,
      ),
    if (form.activeVersionId != null)
      CatchActionMenuItem(
        value: _HostFormRowAction.automations,
        label: context.l10n.hostFormsAutomationsAction,
        icon: CatchIcons.autoAwesomeOutlined,
      ),
    CatchActionMenuItem(
      value: _HostFormRowAction.duplicate,
      label: context.l10n.hostFormsDuplicate,
      icon: CatchIcons.contentCopyRounded,
    ),
    if (form.canPause)
      CatchActionMenuItem(
        value: _HostFormRowAction.pause,
        label: context.l10n.hostFormsPause,
        icon: CatchIcons.pauseCircleOutlineRounded,
      ),
    if (form.canResume)
      CatchActionMenuItem(
        value: _HostFormRowAction.resume,
        label: context.l10n.hostFormsResume,
        icon: CatchIcons.playCircleOutlineRounded,
      ),
    if (form.status != HostFormLifecycleStatus.archived)
      CatchActionMenuItem(
        value: _HostFormRowAction.archive,
        label: context.l10n.hostFormsArchive,
        icon: CatchIcons.archiveOutlined,
      ),
    if (form.canDeleteDraft)
      CatchActionMenuItem(
        value: _HostFormRowAction.delete,
        label: context.l10n.hostFormsDeleteDraft,
        icon: CatchIcons.deleteOutlineRounded,
        isDestructive: true,
      ),
  ];

  Future<void> _handleRowAction(
    _HostFormRowAction action,
    HostFormSummary form,
    HostFormListRequest request,
  ) async {
    if (action == _HostFormRowAction.open) {
      _openForm(form);
      return;
    }
    if (action == _HostFormRowAction.responses) {
      setState(() {
        _view = _HostFormsView.responses;
        _responseFormId = form.formId;
        _responseFormTitle = form.title;
      });
      return;
    }
    if (action == _HostFormRowAction.analytics) {
      await context.pushNamed(
        Routes.hostFormAnalyticsScreen.name,
        pathParameters: {'formId': form.formId},
        queryParameters: {'organizerId': form.organizerId},
      );
      return;
    }
    if (action == _HostFormRowAction.automations) {
      await context.pushNamed(
        Routes.hostFormAutomationsScreen.name,
        pathParameters: {'formId': form.formId},
        queryParameters: {'organizerId': form.organizerId},
      );
      return;
    }
    try {
      switch (action) {
        case _HostFormRowAction.open:
        case _HostFormRowAction.responses:
        case _HostFormRowAction.analytics:
        case _HostFormRowAction.automations:
          break;
        case _HostFormRowAction.duplicate:
          final duplicate = await ref
              .read(hostFormsControllerProvider)
              .duplicate(source: form, requestId: _requestId('duplicate'));
          if (!mounted) return;
          ref.invalidate(hostFormsDirectoryControllerProvider(request));
          await context.pushNamed(
            Routes.hostFormBuilderScreen.name,
            pathParameters: {'formId': duplicate.form.formId},
            queryParameters: {'organizerId': form.organizerId},
          );
          return;
        case _HostFormRowAction.pause:
        case _HostFormRowAction.resume:
        case _HostFormRowAction.archive:
          final lifecycleAction = switch (action) {
            _HostFormRowAction.pause => HostFormLifecycleAction.pause,
            _HostFormRowAction.resume => HostFormLifecycleAction.resume,
            _ => HostFormLifecycleAction.archive,
          };
          if (lifecycleAction == HostFormLifecycleAction.archive) {
            final confirmed = await showCatchConfirmDialog(
              context: context,
              title: context.l10n.hostFormsArchiveConfirmTitle,
              message: context.l10n.hostFormsArchiveConfirmBody,
              confirmLabel: context.l10n.hostFormsArchive,
              danger: true,
            );
            if (confirmed != true) return;
          }
          await ref
              .read(hostFormsControllerProvider)
              .setLifecycle(form: form, action: lifecycleAction);
          ref.invalidate(hostFormsDirectoryControllerProvider(request));
          return;
        case _HostFormRowAction.delete:
          final confirmed = await showCatchConfirmDialog(
            context: context,
            title: context.l10n.hostFormsDeleteConfirmTitle,
            message: context.l10n.hostFormsDeleteConfirmBody,
            confirmLabel: context.l10n.hostFormsDeleteDraft,
            danger: true,
          );
          if (confirmed != true) return;
          await ref.read(hostFormsControllerProvider).deleteDraft(form);
          ref.invalidate(hostFormsDirectoryControllerProvider(request));
          return;
      }
    } on Object catch (error) {
      if (!mounted) return;
      showCatchErrorSnackBar(context, error);
    }
  }

  void _openForm(HostFormSummary form) {
    context.pushNamed(
      Routes.hostFormBuilderScreen.name,
      pathParameters: {'formId': form.formId},
      queryParameters: {'organizerId': form.organizerId},
    );
  }
}

class HostFormsNoOrganizer extends StatelessWidget {
  const HostFormsNoOrganizer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: CatchScreenHeaderTitle.block(
                title: context.l10n.hostNavigationForms,
              ),
            ),
            CatchSliverEmptyState(
              icon: CatchIcons.descriptionOutlined,
              title: context.l10n.hostFormsNoOrganizerTitle,
              message: context.l10n.hostFormsNoOrganizerBody,
              action: CatchButton(
                label: context.l10n.hostFormsCreateOrganizer,
                size: CatchButtonSize.sm,
                onPressed: () =>
                    context.pushNamed(Routes.hostCreateClubScreen.name),
              ),
            ),
            const CatchSliverTerminalPadding(),
          ],
        ),
      ),
    );
  }
}

String hostFormStatusLabel(
  BuildContext context,
  HostFormLifecycleStatus status,
) => switch (status) {
  HostFormLifecycleStatus.draft => context.l10n.hostFormsStatusDraft,
  HostFormLifecycleStatus.published => context.l10n.hostFormsStatusPublished,
  HostFormLifecycleStatus.paused => context.l10n.hostFormsStatusPaused,
  HostFormLifecycleStatus.archived => context.l10n.hostFormsStatusArchived,
};

String hostFormPurposeLabel(BuildContext context, HostFormPurpose purpose) =>
    switch (purpose) {
      HostFormPurpose.application => context.l10n.hostFormsPurposeApplication,
      HostFormPurpose.registration => context.l10n.hostFormsPurposeRegistration,
      HostFormPurpose.intake => context.l10n.hostFormsPurposeIntake,
      HostFormPurpose.waiver => context.l10n.hostFormsPurposeWaiver,
      HostFormPurpose.feedback => context.l10n.hostFormsPurposeFeedback,
      HostFormPurpose.survey => context.l10n.hostFormsPurposeSurvey,
    };

String _requestId(String prefix) =>
    '${prefix}_${DateTime.now().microsecondsSinceEpoch}';
