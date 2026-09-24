import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_error_snack_bar.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_sliver_error_state.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_configuration.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_summary.dart';
import 'package:catch_dating_app/hosts/domain/host_application_import.dart';
import 'package:catch_dating_app/hosts/domain/host_roster_import.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_applications_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/private_event_setup_capability.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_copy.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_responses_panel.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_no_organizer_empty_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_view.dart';
import 'package:catch_dating_app/hosts/presentation/host_organizer_selection_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'host_forms_account_binding.dart';
part 'host_forms_filter_sheet.dart';
part 'host_response_import.dart';

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
    this.initialContactId,
  });

  final String? initialOrganizerId;
  final bool initialResponses;
  final String? initialFormId;
  final String? initialContactId;

  @override
  ConsumerState<HostFormsScreen> createState() => _HostFormsScreenState();
}

class _HostFormsScreenState extends ConsumerState<HostFormsScreen>
    with SingleTickerProviderStateMixin {
  Timer? _searchDebounce;
  String? _query;
  String? _responseQuery;
  Set<HostFormLifecycleStatus> _statuses = const {};
  Set<HostFormPurpose> _purposes = const {};
  late HostAudienceView _view;
  late final TabController _tabController;
  String? _responseFormId;
  String? _responseContactId;
  bool _importing = false;
  int _importRevision = 0;
  bool _accountBound = false;
  String? _boundAccountId;
  int _accountGeneration = 0;

  void _completeResponseImport() {
    setState(() {
      _responseFormId = null;
      _responseContactId = null;
      _responseQuery = null;
      _importRevision++;
    });
    _syncRoute();
  }

  void _setImporting(bool value) => setState(() => _importing = value);

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
    _responseContactId = widget.initialContactId;
  }

  @override
  void didUpdateWidget(covariant HostFormsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFormId != widget.initialFormId ||
        oldWidget.initialOrganizerId != widget.initialOrganizerId) {
      _responseFormId = widget.initialFormId;
    }
    if (oldWidget.initialContactId != widget.initialContactId ||
        oldWidget.initialOrganizerId != widget.initialOrganizerId) {
      _responseContactId = widget.initialContactId;
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
    if (uidState.error != null) {
      return HostAudienceStateScaffold(
        selected: _view,
        scrollKey: const PageStorageKey<String>('host-forms-route-state'),
        slivers: [
          CatchLocalizedSliverErrorState(
            uidState.error!,
            context: AppErrorContext.auth,
            onRetry: () => ref.invalidate(uidProvider),
          ),
        ],
      );
    }
    if (!uidState.isSettledData) {
      return _loadingFormsRoute();
    }
    // A settled stream value can lag a live FirebaseAuth account change.
    if (uid != null && ref.watch(firebaseAuthProvider).currentUser?.uid != uid) {
      return _loadingFormsRoute();
    }
    _bindAccount(uid);
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
          CatchLocalizedSliverErrorState(
            clubsState.error!,
            context: AppErrorContext.club,
            onRetry: () => ref.invalidate(hostOperableClubsProvider(uid)),
          ),
        ],
      );
    }
    if (clubsState.isLoading) {
      return _loadingFormsRoute();
    }
    final clubs = clubsState.value ?? const <Club>[];
    if (clubs.isEmpty) {
      return HostAudienceNoOrganizerEmptyState(selected: _view);
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
      statuses: _statuses.isEmpty
          ? HostFormLifecycleStatus.values.toSet()
          : _statuses,
      purposes: _purposes,
      query: _query,
    );
    final directoryScope = (
      uid: uid,
      accountGeneration: _accountGeneration,
      request: request,
    );
    final scopedDirectory = catchAsyncStateFromAsyncValue(
      ref.watch(hostFormsAccountDirectoryProvider(directoryScope)),
    );
    if (scopedDirectory.error case final error?) {
      return HostAudienceStateScaffold(
        selected: _view,
        scrollKey: const PageStorageKey<String>('host-forms-route-state'),
        slivers: [
          CatchLocalizedSliverErrorState(
            error,
            context: AppErrorContext.forms,
            onRetry: () => ref.invalidate(
              hostFormsAccountDirectoryProvider(directoryScope),
            ),
          ),
        ],
      );
    }
    if (!scopedDirectory.isSettledData) {
      return HostAudienceStateScaffold(
        selected: _view,
        scrollKey: const PageStorageKey<String>('host-forms-route-state'),
        slivers: const [CatchStateViewport.sliverLoading()],
      );
    }
    final directory = ref.watch(hostFormsDirectoryControllerProvider(request));
    String? responseVersionId;
    if (canMountHostResponseQuery(
      enabled: privateEventSetupAvailable(),
      formId: _responseFormId,
      searchQuery: _responseQuery,
      contactId: _responseContactId,
    )) {
      final directoryState = catchAsyncStateFromAsyncValue(directory);
      responseVersionId = directoryState.isSettledData
          ? directoryState.value?.forms
              .where((form) => form.formId == _responseFormId)
              .firstOrNull?.activeVersionId
          : null;
      final responses = catchAsyncStateFromAsyncValue(
        ref.watch(hostFormResponsesControllerProvider(
          HostFormResponseListRequest(
            organizerId: selectedClub.id,
            formId: _responseFormId,
            includeApplications: true,
          ),
        )),
      );
      if (responses.isSettledData) {
        responseVersionId ??= responses.value?.versionScope?.activeVersionId;
      }
    }
    final activeSearchIsForms = _view == HostAudienceView.forms;
    final searchPlaceholder = activeSearchIsForms
        ? context.l10n.hostFormsSearch
        : context.l10n.hostFormResponsesSearch;

    return CatchRootScreenScaffold.withPrimaryRail(
      header: CatchRootScreenHeader.custom(
        HostAudienceHeader(
          organizerId: selectedClub.id,
          primaryAction: activeSearchIsForms
              ? CatchTopBarPrimaryButton(
                  key: const ValueKey('host-forms-create'),
                  label: context.l10n.hostFormsCreate,
                  icon: CatchIcons.add,
                  onPressed: () => _openTemplates(selectedClub.id),
                )
              : CatchTopBarPrimaryButton(
                  key: const ValueKey('host-responses-import'),
                  label: context.l10n.hostApplicationsImport,
                  icon: CatchIcons.downloadRounded,
                  onPressed: _importing
                      ? null
                      : () => _pickApplicationImport(selectedClub.id),
                ),
          search: CatchTopBarSearch(
            copy: catchSearchFieldCopy(context.l10n),
            value: activeSearchIsForms ? _query ?? '' : _responseQuery ?? '',
            contract: activeSearchIsForms
                ? CatchContractConstraints
                      .listOrganizerFormsCallablePayloadQuery
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
      ),
      actions: HostAudienceTabRail(
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
              statuses: _statuses,
              purposes: _purposes,
              onPurposesChanged: (values) => setState(() => _purposes = values),
              onStatusesChanged: (values) => setState(() => _statuses = values),
              onCreate: () => _openTemplates(selectedClub.id),
              onOpenForm: _openForm,
              onRowAction: (action, form) =>
                  _handleRowAction(action, form, request),
            ),
          ),
          CatchRootScreenPageSpec.scroll(
            page: CatchRootScreenPageScrollView.sections(
              scrollKey: const PageStorageKey<String>('host-forms-responses'),
              children: [
                HostFormResponsesPanel(
                  key: ValueKey('responses-$uid-import-$_importRevision'),
                  organizerId: selectedClub.id,
                  accountId: uid,
                  requireAccount: true,
                  queryCapability: responseVersionId == null ? null :
                      hostResponseQueryCapability(context.l10n,
                        versionId: responseVersionId),
                  query: _responseQuery,
                  contactId: _responseContactId,
                  onClearContactFilter: () {
                    setState(() => _responseContactId = null);
                    _syncRoute();
                  },
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
    if (_responseContactId case final contactId?) {
      query['contactId'] = contactId;
    } else {
      query.remove('contactId');
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
              copy: catchDialogCopy(context.l10n),
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
            copy: catchDialogCopy(context.l10n),
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
    required this.statuses,
    required this.purposes,
    required this.onPurposesChanged,
    required this.onStatusesChanged,
    required this.onCreate,
    required this.onOpenForm,
    required this.onRowAction,
  });

  final HostFormListRequest request;
  final AsyncValue<HostFormsDirectoryState> directory;
  final String? query;
  final Set<HostFormLifecycleStatus> statuses;
  final Set<HostFormPurpose> purposes;
  final ValueChanged<Set<HostFormPurpose>> onPurposesChanged;
  final ValueChanged<Set<HostFormLifecycleStatus>> onStatusesChanged;
  final VoidCallback onCreate;
  final ValueChanged<HostFormSummary> onOpenForm;
  final Future<void> Function(_HostFormRowAction, HostFormSummary) onRowAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CatchRootScreenPageScrollView.sections(
      scrollKey: const PageStorageKey<String>('host-forms-library'),
      children: [
        SliverToBoxAdapter(
          child: CatchSection.content(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CatchChoiceInput<String>.segmented(
                  options: [
                    CatchOption(
                      value: 'all',
                      label: context.l10n.hostFormsFilterAll,
                    ),
                    for (final candidate in [
                      HostFormLifecycleStatus.published,
                      HostFormLifecycleStatus.draft,
                      HostFormLifecycleStatus.paused,
                      HostFormLifecycleStatus.archived,
                    ])
                      if (candidate == HostFormLifecycleStatus.published ||
                          candidate == HostFormLifecycleStatus.draft ||
                          statuses.contains(candidate))
                        CatchOption(
                          value: candidate.name,
                          label: hostFormStatusLabel(context, candidate),
                        ),
                  ],
                  selected: statuses.isEmpty
                      ? 'all'
                      : statuses.length == 1
                      ? statuses.single.name
                      : null,
                  variant: CatchChoiceInputVariant.summary,
                  contractExemption:
                      'Quick presets replace the status set. A combined selection '
                      'has no single active preset.',
                  onChanged: (value) => onStatusesChanged(
                    value == 'all'
                        ? const {}
                        : {HostFormLifecycleStatus.values.byName(value)},
                  ),
                  scrollable: true,
                  showDivider: false,
                ),
                gapH16,
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: CatchSection.controls(
            sortLabel: context.l10n.hostAudienceRecentlyUpdated,
            filtersLabel: context.l10n.hostCustomersFilters,
            onFilters: () => _showHostFormsFilters(
              context,
              purposes: purposes,
              statuses: statuses,
              onPurposesChanged: onPurposesChanged,
              onStatusesChanged: onStatusesChanged,
            ),
            activeFilters: statuses.isEmpty && purposes.isEmpty
                ? null
                : [
                    for (final status in HostFormLifecycleStatus.values)
                      if (statuses.contains(status))
                        hostFormStatusLabel(context, status),
                    for (final purpose in HostFormPurpose.values)
                      if (purposes.contains(purpose))
                        hostFormPurposeLabel(context, purpose),
                  ].join(' · '),
            clearLabel: statuses.isEmpty && purposes.isEmpty
                ? null
                : context.l10n.hostCustomersClearFilter,
            onClear: statuses.isEmpty && purposes.isEmpty
                ? null
                : () {
                    onStatusesChanged(const {});
                    onPurposesChanged(const {});
                  },
          ),
        ),
        CatchAsyncBoundary<HostFormsDirectoryState>.sliver(
          value: directory,
          onRetry: () =>
              ref.invalidate(hostFormsDirectoryControllerProvider(request)),
          initialLoadTimeout: null,
          loadingBuilder: (_) => CatchSection.sliverLoadingRows(
            itemCount: 6,
            layoutBuilder: (_, _) => CatchRecordLayout.placeholder(
              icon: CatchIcons.descriptionOutlined,
              hasMetadata: true,
              factCount: 1,
            ),
          ),
          errorBuilder: (_, error, _, onBoundaryRetry) =>
              CatchLocalizedSliverErrorState(
                error,
                context: AppErrorContext.forms,
                fillRemaining: false,
                onRetry: onBoundaryRetry,
              ),
          builder: (context, state) {
            if (state.forms.isEmpty) {
              final unfiltered =
                  query == null && statuses.isEmpty && purposes.isEmpty;
              return SliverToBoxAdapter(
                child: CatchEmptyState(
                  icon: CatchIcons.descriptionOutlined,
                  title: unfiltered
                      ? context.l10n.hostFormsEmptyTitle
                      : context.l10n.hostFormsNoMatchesTitle,
                  message: unfiltered
                      ? context.l10n.hostFormsEmptyBody
                      : context.l10n.hostFormsNoMatchesBody,
                  actions: [
                    ?unfiltered
                        ? CatchButton(
                            label: context.l10n.hostFormsCreate,
                            size: CatchButtonSize.sm,
                            onPressed: onCreate,
                          )
                        : null,
                  ],
                ),
              );
            }
            return SliverMainAxisGroup(
              slivers: [
                CatchSection.sliverRows(
                  itemCount: state.forms.length,
                  indexForKeyBuilder: (key) {
                    final index = state.forms.indexWhere(
                      (form) => key == ValueKey('host-form-${form.formId}'),
                    );
                    return index < 0 ? null : index;
                  },
                  itemBuilder: (context, index) {
                    final form = state.forms[index];
                    return CatchField.navigate(
                      key: ValueKey('host-form-${form.formId}'),
                      content: CatchRecordLayout(
                        title: form.title,
                        icon: CatchIcons.descriptionOutlined,
                        metadata:
                            '${hostFormPurposeLabel(context, form.purpose)} · ${form.lastResponseAt == null ? context.l10n.hostAudienceFormEdited(time: AppTimeFormatters.compactRelativeTime(form.updatedAt)) : context.l10n.hostAudienceFormLastResponse(time: AppTimeFormatters.compactRelativeTime(form.lastResponseAt!))}',
                        facts: [
                          context.l10n.hostAudienceFormRecordStatus(
                            status: hostFormStatusLabel(context, form.status),
                            count: form.submittedResponseCount,
                          ),
                        ],
                      ),
                      onActivate: () => onOpenForm(form),
                      secondaryAction:
                          CatchFieldSecondaryAction.menu<_HostFormRowAction>(
                            label: context.l10n.hostFormsActions,
                            items: _hostFormRowActions(context, form),
                            onSelected: (action) => onRowAction(action, form),
                          ),
                    );
                  },
                ),
                if (state.canLoadMore)
                  CatchPageBody.sliver(
                    child: SliverToBoxAdapter(
                      child: CatchButton(
                        label: context.l10n.hostFormsLoadMore,
                        variant: CatchButtonVariant.secondary,
                        status: state.loadingMore
                            ? CatchButtonStatus.loading
                            : CatchButtonStatus.idle,
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
                    ),
                  ),
                if (state.loadMoreError case final error?)
                  CatchLocalizedSliverErrorState(
                    error,
                    context: AppErrorContext.forms,
                    fillRemaining: false,
                    onRetry: () => ref
                        .read(
                          hostFormsDirectoryControllerProvider(
                            request,
                          ).notifier,
                        )
                        .loadMore(),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

String _requestId(String prefix) =>
    '${prefix}_${DateTime.now().microsecondsSinceEpoch}';
