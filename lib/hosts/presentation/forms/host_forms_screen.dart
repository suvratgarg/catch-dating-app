import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_record_row.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_selection_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/domain/host_form.dart';
import 'package:catch_dating_app/hosts/domain/host_form_operations.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_responses_panel.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_view.dart';
import 'package:catch_dating_app/hosts/presentation/host_organizer_selection_controller.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  HostFormPurpose? _purpose;
  late HostAudienceView _view;
  late final TabController _tabController;
  String? _responseFormId;

  @override
  void initState() {
    super.initState();
    _view = widget.initialResponses
        ? HostAudienceView.responses
        : HostAudienceView.forms;
    _tabController = TabController(
      length: 2,
      initialIndex: _view == HostAudienceView.forms ? 0 : 1,
      vsync: this,
    )..addListener(_handleTabChanged);
    _responseFormId = widget.initialFormId;
  }

  @override
  void didUpdateWidget(covariant HostFormsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFormId != widget.initialFormId ||
        oldWidget.initialOrganizerId != widget.initialOrganizerId) {
      _responseFormId = widget.initialFormId;
    }
    if (oldWidget.initialOrganizerId != widget.initialOrganizerId) {
      _searchDebounce?.cancel();
      _query = null;
      _responseQuery = null;
    }
    if (oldWidget.initialResponses != widget.initialResponses) {
      _tabController.animateTo(widget.initialResponses ? 1 : 0);
    }
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
      return HostAudienceStateScaffold(
        selected: _view,
        scrollKey: const PageStorageKey<String>('host-forms-route-state'),
        slivers: [
          CatchSliverErrorState.fromError(
            uidState.error!,
            context: AppErrorContext.auth,
            onRetry: () => ref.invalidate(uidProvider),
          ),
        ],
      );
    }
    if (uidState.isLoading) {
      return HostAudienceStateScaffold(
        selected: _view,
        scrollKey: const PageStorageKey<String>('host-forms-route-state'),
        slivers: const [
          CatchSliverStateViewport(
            child: HostRouteLoadingBody(padding: EdgeInsets.zero),
          ),
        ],
      );
    }
    if (uid == null) {
      return HostAudienceStateScaffold(
        selected: _view,
        scrollKey: const PageStorageKey<String>('host-forms-route-state'),
        slivers: [
          CatchSliverErrorState(
            title: context.l10n.hostsHostAuthRequiredScreenTitleSignInRequired,
            message:
                context.l10n.hostsHostAuthRequiredScreenMessageSignInToManage,
            retryLabel:
                context.l10n.hostsHostAuthRequiredScreenVisiblecopySignIn,
            onRetry: () => context.go(Routes.authScreen.path),
          ),
        ],
      );
    }

    final clubsAsync = ref.watch(hostOperableClubsProvider(uid));
    final clubsState = catchAsyncStateFromAsyncValue(clubsAsync);
    if (clubsState.hasError) {
      return HostAudienceStateScaffold(
        selected: _view,
        scrollKey: const PageStorageKey<String>('host-forms-route-state'),
        slivers: [
          CatchSliverErrorState.fromError(
            clubsState.error!,
            context: AppErrorContext.club,
            onRetry: () => ref.invalidate(hostOperableClubsProvider(uid)),
          ),
        ],
      );
    }
    if (clubsState.isLoading) {
      return HostAudienceStateScaffold(
        selected: _view,
        scrollKey: const PageStorageKey<String>('host-forms-route-state'),
        slivers: const [
          CatchSliverStateViewport(
            child: HostRouteLoadingBody(padding: EdgeInsets.zero),
          ),
        ],
      );
    }
    final clubs = clubsState.value ?? const <Club>[];
    if (clubs.isEmpty) {
      return HostFormsNoOrganizer(selected: _view);
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
      purposes: _purpose == null ? const {} : {_purpose!},
      query: _query,
    );
    final directory = ref.watch(hostFormsDirectoryControllerProvider(request));
    final activeSearchIsForms = _view == HostAudienceView.forms;
    final searchPlaceholder = activeSearchIsForms
        ? context.l10n.hostFormsSearch
        : context.l10n.hostFormResponsesSearch;

    return CatchRootScreenScaffold.withPrimaryRail(
      header: CatchRootScreenHeader.title(
        title: context.l10n.hostNavigationAudience,
        actions: activeSearchIsForms
            ? [
                CatchTopBarPrimaryAction(
                  key: const ValueKey('host-forms-create'),
                  label: context.l10n.hostFormsCreate,
                  icon: CatchIcons.add,
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
      ),
      primaryRail: HostAudienceTabRail(
        selected: _view,
        selectionAnimation: _tabController.animation!,
        animationOffset: 2,
        onChanged: (view) => _selectAudienceView(view, selectedClub.id),
      ),
      body: CatchRootScreenBody.paged(
        controller: _tabController,
        pages: [
          CatchRootScreenPageSpec.scroll(
            page: _HostFormsLibraryPage(
              request: request,
              directory: directory,
              query: _query,
              status: _status,
              purpose: _purpose,
              onPurposeChanged: (purpose) => setState(() => _purpose = purpose),
              onStatusChanged: (status) => setState(() => _status = status),
              onCreate: () => _openTemplates(selectedClub.id),
              onOpenForm: _openForm,
              onRowAction: (action, form) =>
                  _handleRowAction(action, form, request),
            ),
          ),
          CatchRootScreenPageSpec.scroll(
            page: CatchRootScreenPageScrollView.standard(
              scrollKey: const PageStorageKey<String>('host-forms-responses'),
              slivers: [
                SliverToBoxAdapter(
                  child: HostFormResponsesPanel(
                    organizerId: selectedClub.id,
                    query: _responseQuery,
                    formId: _responseFormId,
                    onFormChanged: (formId) {
                      setState(() => _responseFormId = formId);
                      _syncRoute();
                    },
                    onClearFormFilter: () {
                      setState(() => _responseFormId = null);
                      _syncRoute();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _scheduleSearch(HostAudienceView view, String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      CatchMotion.searchDebounce,
      () => _applySearch(view, value),
    );
  }

  void _applySearch(HostAudienceView view, String value) {
    if (!mounted) return;
    final normalized = value.trim();
    setState(() {
      final query = normalized.isEmpty ? null : normalized;
      switch (view) {
        case HostAudienceView.forms:
          _query = query;
        case HostAudienceView.responses:
          _responseQuery = query;
        case HostAudienceView.people:
        case HostAudienceView.audiences:
          return;
      }
    });
  }

  void _handleTabChanged() {
    final nextView = _tabController.index == 0
        ? HostAudienceView.forms
        : HostAudienceView.responses;
    if (nextView == _view) return;
    _searchDebounce?.cancel();
    setState(() {
      _view = nextView;
    });
    _syncRoute();
  }

  void _syncRoute() {
    final router = GoRouter.maybeOf(context);
    if (router == null) return;
    final uri = router.routeInformationProvider.value.uri;
    if (uri.path != Routes.hostAudienceScreen.path) return;
    final query = {...uri.queryParameters, 'view': _view.name};
    if (_responseFormId case final formId?) {
      query['formId'] = formId;
    } else {
      query.remove('formId');
    }
    final next = uri.replace(queryParameters: query);
    if (next != uri) router.replace(next.toString());
  }

  void _selectAudienceView(HostAudienceView view, String organizerId) {
    if (view == HostAudienceView.forms || view == HostAudienceView.responses) {
      _tabController.animateTo(view == HostAudienceView.forms ? 0 : 1);
      return;
    }
    context.goNamed(
      Routes.hostAudienceScreen.name,
      queryParameters: {'view': view.name, 'organizerId': organizerId},
    );
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

class _HostFormsLibraryPage extends ConsumerWidget
    implements CatchRootScreenPageOwner {
  const _HostFormsLibraryPage({
    required this.request,
    required this.directory,
    required this.query,
    required this.status,
    required this.purpose,
    required this.onPurposeChanged,
    required this.onStatusChanged,
    required this.onCreate,
    required this.onOpenForm,
    required this.onRowAction,
  });

  final HostFormListRequest request;
  final AsyncValue<HostFormsDirectoryState> directory;
  final String? query;
  final HostFormLifecycleStatus? status;
  final HostFormPurpose? purpose;
  final ValueChanged<HostFormPurpose?> onPurposeChanged;
  final ValueChanged<HostFormLifecycleStatus?> onStatusChanged;
  final VoidCallback onCreate;
  final ValueChanged<HostFormSummary> onOpenForm;
  final Future<void> Function(_HostFormRowAction, HostFormSummary) onRowAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CatchRootScreenPageScrollView.standard(
      scrollKey: const PageStorageKey<String>('host-forms-library'),
      maxContentExtent: CatchLayout.hostFormsDirectoryPageMaxExtent,
      slivers: [
        SliverList.list(
          children: [
            CatchOptionGroup<HostFormLifecycleStatus?>(
              options: [
                CatchOption(
                  value: null,
                  label: context.l10n.hostFormsFilterAll,
                ),
                for (final candidate in [
                  HostFormLifecycleStatus.published,
                  HostFormLifecycleStatus.draft,
                  if (status == HostFormLifecycleStatus.paused ||
                      status == HostFormLifecycleStatus.archived)
                    status!,
                ])
                  CatchOption(
                    value: candidate,
                    label: hostFormStatusLabel(context, candidate),
                  ),
              ],
              selected: status,
              variant: CatchOptionGroupVariant.summary,
              contractExemption:
                  'The lifecycle rail maps All to no status and every other '
                  'option to one item in the statuses array contract.',
              onChanged: onStatusChanged,
              scrollable: true,
              showDivider: false,
            ),
            gapH16,
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: CatchSpacing.s4,
              children: [
                CatchButton.command(
                  label: purpose == null
                      ? context.l10n.hostAudienceAllPurposes
                      : hostFormPurposeLabel(context, purpose!),
                  icon: Icon(CatchIcons.descriptionOutlined),
                  onPressed: () => _selectPurpose(context),
                ),
                CatchButton.command(
                  label: context.l10n.hostCustomersFilters,
                  icon: Icon(CatchIcons.tune),
                  onPressed: () => _selectStatus(context),
                ),
              ],
            ),
            gapH8,
            CatchAsyncValueView<HostFormsDirectoryState>(
              value: directory,
              onRetry: () =>
                  ref.invalidate(hostFormsDirectoryControllerProvider(request)),
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
                  final unfiltered =
                      query == null && status == null && purpose == null;
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
                    CatchSection.divided(
                      first: true,
                      children: [
                        for (final form in state.forms)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: CatchRecordRow(
                                  key: ValueKey('host-form-${form.formId}'),
                                  title: form.title,
                                  icon: CatchIcons.descriptionOutlined,
                                  metadata:
                                      '${hostFormPurposeLabel(context, form.purpose)} · ${form.lastResponseAt == null ? context.l10n.hostAudienceFormEdited(time: AppTimeFormatters.compactRelativeTime(form.updatedAt)) : context.l10n.hostAudienceFormLastResponse(time: AppTimeFormatters.compactRelativeTime(form.lastResponseAt!))}',
                                  facts: [
                                    context.l10n.hostAudienceFormRecordStatus(
                                      status: hostFormStatusLabel(
                                        context,
                                        form.status,
                                      ),
                                      count: form.submittedResponseCount,
                                    ),
                                  ],
                                  onTap: () => onOpenForm(form),
                                ),
                              ),
                              CatchActionMenu<_HostFormRowAction>(
                                tooltip: context.l10n.hostFormsActions,
                                items: _hostFormRowActions(context, form),
                                onSelected: (action) =>
                                    onRowAction(action, form),
                              ),
                            ],
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
      ],
    );
  }

  Future<void> _selectPurpose(BuildContext context) async {
    final selected = await showCatchSelectionSheet<String>(
      context: context,
      title: context.l10n.hostAudienceFormPurposeFilter,
      value: purpose?.name ?? 'all',
      items: [
        CatchSelectionMenuItem(
          value: 'all',
          label: context.l10n.hostAudienceAllPurposes,
        ),
        for (final candidate in HostFormPurpose.values)
          CatchSelectionMenuItem(
            value: candidate.name,
            label: hostFormPurposeLabel(context, candidate),
          ),
      ],
    );
    if (selected != null && context.mounted) {
      onPurposeChanged(
        selected == 'all' ? null : HostFormPurpose.values.byName(selected),
      );
    }
  }

  Future<void> _selectStatus(BuildContext context) async {
    final selected = await showCatchSelectionSheet<String>(
      context: context,
      title: context.l10n.hostAudienceFormStatusFilter,
      value: status?.name ?? 'all',
      items: [
        CatchSelectionMenuItem(
          value: 'all',
          label: context.l10n.hostAudienceAllStatuses,
        ),
        for (final candidate in HostFormLifecycleStatus.values)
          CatchSelectionMenuItem(
            value: candidate.name,
            label: hostFormStatusLabel(context, candidate),
          ),
      ],
    );
    if (selected != null && context.mounted) {
      onStatusChanged(
        selected == 'all'
            ? null
            : HostFormLifecycleStatus.values.byName(selected),
      );
    }
  }
}

String hostFormConsequenceSummary(BuildContext context, HostFormSummary form) {
  final projection = form.consequences;
  if (projection.coverage == HostFormConsequenceCoverage.unavailable) {
    return [
      context.l10n.hostFormConsequencesUnavailable,
      if (form.purpose == HostFormPurpose.application)
        context.l10n.hostFormConsequenceApplicationReview,
    ].join(' · ');
  }
  final parts = <String>[
    _hostFormIdentityConsequence(context, projection.identityPolicy),
  ];
  if (projection.coverage == HostFormConsequenceCoverage.identityOnly) {
    parts.add(context.l10n.hostFormAutomationConsequencesUnavailable);
    return parts.join(' · ');
  }
  final actions = projection.enabledAutomationActionKinds;
  if (actions.contains(HostFormAutomationActionKind.createCrmContact)) {
    parts.add(context.l10n.hostFormConsequenceCreatesCustomer);
  }
  if (form.purpose == HostFormPurpose.application ||
      actions.contains(HostFormAutomationActionKind.addApplicationQueue)) {
    parts.add(context.l10n.hostFormConsequenceApplicationReview);
  }
  if (actions.contains(HostFormAutomationActionKind.proposeEventAttendee)) {
    parts.add(context.l10n.hostFormConsequenceProposesAttendee);
  }
  if (actions.contains(HostFormAutomationActionKind.addOrganizerTag)) {
    parts.add(context.l10n.hostFormConsequenceAppliesTags);
  }
  if (actions.contains(HostFormAutomationActionKind.notifyTeam)) {
    parts.add(context.l10n.hostFormConsequenceNotifiesTeam);
  }
  if (actions.contains(HostFormAutomationActionKind.signedWebhook)) {
    parts.add(context.l10n.hostFormConsequenceCallsWebhook);
  }
  if (actions.contains(HostFormAutomationActionKind.campaignHandoff)) {
    parts.add(context.l10n.hostFormConsequencePreparesSend);
  }
  if (parts.length == 1) {
    parts.add(context.l10n.hostFormConsequenceFormsOnly);
  }
  return parts.join(' · ');
}

String _hostFormIdentityConsequence(
  BuildContext context,
  HostFormIdentityPolicy? policy,
) => switch (policy) {
  HostFormIdentityPolicy.anonymous =>
    context.l10n.hostFormConsequenceIdentityAnonymous,
  HostFormIdentityPolicy.emailVerified =>
    context.l10n.hostFormConsequenceIdentityEmail,
  HostFormIdentityPolicy.phoneVerified =>
    context.l10n.hostFormConsequenceIdentityPhone,
  HostFormIdentityPolicy.emailOrPhoneVerified =>
    context.l10n.hostFormConsequenceIdentityEmailOrPhone,
  HostFormIdentityPolicy.catchAccount =>
    context.l10n.hostFormConsequenceIdentityCatchAccount,
  null => context.l10n.hostFormConsequenceIdentityUnknown,
};

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
  const HostFormsNoOrganizer({
    super.key,
    this.selected = HostAudienceView.forms,
    this.onChanged,
  });

  final HostAudienceView selected;
  final ValueChanged<HostAudienceView>? onChanged;

  @override
  Widget build(BuildContext context) {
    return HostAudienceStateScaffold(
      selected: selected,
      scrollKey: const PageStorageKey<String>('host-forms-no-organizer'),
      onChanged: onChanged,
      slivers: [
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
      ],
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
