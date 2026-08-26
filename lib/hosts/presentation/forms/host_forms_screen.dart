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
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_tabbed_screen.dart';
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

class _HostFormsScreenState extends ConsumerState<HostFormsScreen>
    with SingleTickerProviderStateMixin {
  Timer? _searchDebounce;
  String? _query;
  String? _responseQuery;
  HostFormLifecycleStatus? _status;
  late _HostFormsView _view;
  late final TabController _tabController;
  String? _responseFormId;

  @override
  void initState() {
    super.initState();
    _view = widget.initialResponses
        ? _HostFormsView.responses
        : _HostFormsView.forms;
    _tabController = TabController(
      length: _HostFormsView.values.length,
      initialIndex: _view.index,
      vsync: this,
    )..addListener(_handleTabChanged);
    _responseFormId = widget.initialFormId;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
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
    final activeSearchIsForms = _view == _HostFormsView.forms;
    final searchPlaceholder = activeSearchIsForms
        ? context.l10n.hostFormsSearch
        : context.l10n.hostFormResponsesSearch;

    return CatchTabbedScreenScaffold(
      title: context.l10n.hostNavigationForms,
      actions: activeSearchIsForms
          ? [
              CatchButton(
                key: const ValueKey('host-forms-create'),
                label: context.l10n.hostFormsCreate,
                icon: Icon(CatchIcons.add, size: CatchIcon.sm),
                size: CatchButtonSize.sm,
                onPressed: () => _openTemplates(selectedClub.id),
              ),
            ]
          : const [],
      search: CatchTopBarSearch(
        value: activeSearchIsForms ? _query ?? '' : _responseQuery ?? '',
        contract: activeSearchIsForms
            ? CatchContractConstraints.listOrganizerFormsCallablePayloadQuery
            : CatchContractConstraints
                  .listOrganizerFormResponsesCallablePayloadQuery,
        placeholder: searchPlaceholder,
        tooltip: searchPlaceholder,
        semanticLabel: searchPlaceholder,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onChanged: (value) => _scheduleSearch(_view, value),
        onSubmitted: (value) => _applySearch(_view, value),
      ),
      tabRail: CatchTabControllerRail<_HostFormsView>(
        controller: _tabController,
        groupKey: const ValueKey('host-forms-view-tabs'),
        options: [
          CatchOption(
            value: _HostFormsView.forms,
            label: context.l10n.hostFormsViewForms,
          ),
          CatchOption(
            value: _HostFormsView.responses,
            label: context.l10n.hostFormsViewResponses,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _HostFormsLibraryPage(
            request: request,
            directory: directory,
            query: _query,
            status: _status,
            onStatusChanged: (status) => setState(() => _status = status),
            onCreate: () => _openTemplates(selectedClub.id),
            onOpenForm: _openForm,
            onRowAction: (action, form) =>
                _handleRowAction(action, form, request),
          ),
          CatchTabbedPageScrollView(
            scrollKey: const PageStorageKey<String>('host-forms-responses'),
            constrainToContentWidth: true,
            slivers: [
              SliverPadding(
                padding: CatchInsets.pageBody.copyWith(bottom: 0),
                sliver: SliverToBoxAdapter(
                  child: HostFormResponsesPanel(
                    organizerId: selectedClub.id,
                    query: _responseQuery,
                    formId: _responseFormId,
                    onClearFormFilter: () => setState(() {
                      _responseFormId = null;
                    }),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _scheduleSearch(_HostFormsView view, String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      CatchMotion.searchDebounce,
      () => _applySearch(view, value),
    );
  }

  void _applySearch(_HostFormsView view, String value) {
    if (!mounted) return;
    final normalized = value.trim();
    setState(() {
      final query = normalized.isEmpty ? null : normalized;
      switch (view) {
        case _HostFormsView.forms:
          _query = query;
        case _HostFormsView.responses:
          _responseQuery = query;
      }
    });
  }

  void _handleTabChanged() {
    final nextView = _HostFormsView.values[_tabController.index];
    if (nextView == _view) return;
    _searchDebounce?.cancel();
    setState(() {
      _view = nextView;
      if (nextView == _HostFormsView.responses) _responseFormId = null;
    });
  }

  void _openTemplates(String organizerId) {
    context.pushNamed(
      Routes.hostFormTemplatesScreen.name,
      queryParameters: {'organizerId': organizerId},
    );
  }

  Future<void> _handleRowAction(
    _HostFormRowAction action,
    HostFormSummary form,
    HostFormListRequest request,
  ) async {
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

class _HostFormsLibraryPage extends ConsumerWidget {
  const _HostFormsLibraryPage({
    required this.request,
    required this.directory,
    required this.query,
    required this.status,
    required this.onStatusChanged,
    required this.onCreate,
    required this.onOpenForm,
    required this.onRowAction,
  });

  final HostFormListRequest request;
  final AsyncValue<HostFormsDirectoryState> directory;
  final String? query;
  final HostFormLifecycleStatus? status;
  final ValueChanged<HostFormLifecycleStatus?> onStatusChanged;
  final VoidCallback onCreate;
  final ValueChanged<HostFormSummary> onOpenForm;
  final Future<void> Function(_HostFormRowAction, HostFormSummary) onRowAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = CatchTokens.of(context);
    return CatchTabbedPageScrollView(
      scrollKey: const PageStorageKey<String>('host-forms-library'),
      constrainToContentWidth: true,
      slivers: [
        SliverPadding(
          padding: CatchInsets.pageBody.copyWith(bottom: 0),
          sliver: SliverList.list(
            children: [
              Text(
                context.l10n.hostFormsSubtitle,
                style: CatchTextStyles.supporting(context, color: tokens.ink2),
              ),
              gapH16,
              CatchOptionGroup<HostFormLifecycleStatus?>(
                options: [
                  CatchOption(
                    value: null,
                    label: context.l10n.hostFormsFilterAll,
                  ),
                  for (final candidate in HostFormLifecycleStatus.values)
                    CatchOption(
                      value: candidate,
                      label: hostFormStatusLabel(context, candidate),
                    ),
                ],
                selected: status,
                contractExemption:
                    'The lifecycle rail maps All to no status and every other '
                    'option to one item in the statuses array contract.',
                onChanged: onStatusChanged,
                scrollable: true,
                showDivider: false,
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
                    final unfiltered = query == null && status == null;
                    return CatchEmptyState(
                      icon: CatchIcons.descriptionOutlined,
                      title: unfiltered
                          ? context.l10n.hostFormsEmptyTitle
                          : context.l10n.hostFormsNoMatchesTitle,
                      message: unfiltered
                          ? context.l10n.hostFormsEmptyBody
                          : context.l10n.hostFormsNoMatchesBody,
                      action: unfiltered
                          ? CatchButton(
                              label: context.l10n.hostFormsCreate,
                              size: CatchButtonSize.sm,
                              onPressed: onCreate,
                            )
                          : null,
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CatchSection.fieldRows(
                        children: [
                          for (final form in state.forms)
                            CatchField.nav(
                              key: ValueKey('host-form-${form.formId}'),
                              title: form.title,
                              body: _hostFormSummaryBody(context, form),
                              valueText: AppTimeFormatters.compactRelativeTime(
                                form.lastResponseAt ?? form.updatedAt,
                              ),
                              onTap: () => onOpenForm(form),
                              action: CatchActionMenu<_HostFormRowAction>(
                                tooltip: context.l10n.hostFormsActions,
                                items: _hostFormRowActions(context, form),
                                onSelected: (action) =>
                                    onRowAction(action, form),
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
                      if (state.loadMoreError case final error?) ...[
                        gapH12,
                        CatchErrorState.fromError(
                          error,
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
          ),
        ),
      ],
    );
  }
}

String _hostFormSummaryBody(BuildContext context, HostFormSummary form) {
  final purpose = hostFormPurposeLabel(context, form.purpose);
  final status = hostFormStatusLabel(context, form.status);
  return context.l10n.hostFormsRowSummary(
    purpose: purpose,
    status: status,
    count: form.submittedResponseCount,
  );
}

List<CatchActionMenuItem<_HostFormRowAction>> _hostFormRowActions(
  BuildContext context,
  HostFormSummary form,
) => [
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
