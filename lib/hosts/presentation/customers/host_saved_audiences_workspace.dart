part of 'host_customers_screen.dart';

enum _HostSavedAudienceMembership { all, automatic, manual }

class HostSavedAudiencesWorkspace extends ConsumerWidget
    implements CatchRootScreenPageOwner {
  const HostSavedAudiencesWorkspace({
    super.key,
    required this.organizerId,
    required this.query,
    required this.onOpen,
  });

  final String organizerId;
  final String? query;
  final ValueChanged<HostSavedAudience> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      CatchRootScreenPageScrollView.sections(
        scrollKey: const PageStorageKey<String>('host-customers-audiences'),
        onRefresh: () async {
          ref.invalidate(hostSavedAudiencesProvider(organizerId));
          ref.invalidate(hostAllSavedAudiencesProvider(organizerId));
          await ref.read(hostAllSavedAudiencesProvider(organizerId).future);
        },
        children: [
          HostSavedAudiencesDirectory(
            organizerId: organizerId,
            query: query,
            onOpen: onOpen,
          ),
        ],
      );
}

class HostSavedAudiencesDirectory extends ConsumerStatefulWidget {
  const HostSavedAudiencesDirectory({
    super.key,
    required this.organizerId,
    required this.query,
    required this.onOpen,
  });

  final String organizerId;
  final String? query;
  final ValueChanged<HostSavedAudience> onOpen;

  @override
  ConsumerState<HostSavedAudiencesDirectory> createState() =>
      _HostSavedAudiencesDirectoryState();
}

class _HostSavedAudiencesDirectoryState
    extends ConsumerState<HostSavedAudiencesDirectory> {
  _HostSavedAudienceMembership _membership = _HostSavedAudienceMembership.all;
  bool _byName = true;
  String get organizerId => widget.organizerId;
  String? get query => widget.query;
  ValueChanged<HostSavedAudience> get onOpen => widget.onOpen;

  @override
  Widget build(BuildContext context) {
    final audiences = ref.watch(hostAllSavedAudiencesProvider(organizerId));
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: CatchSection.controls(
            sortLabel: context.l10n.hostCustomersSortControl(
              label: _byName
                  ? context.l10n.hostCustomersSortName
                  : context.l10n.hostAudienceRecentlyChecked,
            ),
            onSort: _chooseSort,
            filtersLabel: context.l10n.hostCustomersFilters,
            onFilters: _chooseMembership,
            activeFilters: _membership == _HostSavedAudienceMembership.all
                ? null
                : _membership == _HostSavedAudienceMembership.manual
                ? context.l10n.hostAudienceManualGroup
                : context.l10n.hostAudienceAutomaticGroup,
            clearLabel: _membership == _HostSavedAudienceMembership.all
                ? null
                : context.l10n.hostCustomersClearFilter,
            onClear: _membership == _HostSavedAudienceMembership.all
                ? null
                : () => setState(
                    () => _membership = _HostSavedAudienceMembership.all,
                  ),
          ),
        ),
        CatchAsyncBoundary<HostSavedAudiencePage>.sliver(
          value: audiences,
          onRetry: () =>
              ref.invalidate(hostAllSavedAudiencesProvider(organizerId)),
          initialLoadTimeout: null,
          loadingBuilder: (_) => CatchSection.sliverLoadingRows(
            itemCount: 4,
            layoutBuilder: (_, _) => CatchRecordLayout.placeholder(
              icon: CatchIcons.groupsOutlined,
              hasMetadata: true,
              factCount: 1,
            ),
          ),
          errorBuilder: (_, error, _, onBoundaryRetry) =>
              CatchLocalizedSliverErrorState(
                error,
                context: AppErrorContext.customers,
                fillRemaining: false,
                onRetry: onBoundaryRetry,
              ),
          builder: (context, page) {
            final visible =
                _matchingSavedAudiences(page.audiences, query)
                    .where(
                      (audience) => switch (_membership) {
                        _HostSavedAudienceMembership.automatic =>
                          !audience.definition.isStatic,
                        _HostSavedAudienceMembership.manual =>
                          audience.definition.isStatic,
                        _HostSavedAudienceMembership.all => true,
                      },
                    )
                    .toList()
                  ..sort(
                    (a, b) => _byName
                        ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
                        : (b.lastPreviewAt ?? DateTime(0)).compareTo(
                            a.lastPreviewAt ?? DateTime(0),
                          ),
                  );
            return SliverMainAxisGroup(
              slivers: [
                CatchSection.sliverRows(
                  key: const ValueKey('host-saved-audiences-directory'),
                  itemCount: visible.length,
                  indexForKeyBuilder: (key) {
                    final index = visible.indexWhere(
                      (audience) =>
                          key ==
                          ValueKey(
                            'host-saved-audience-${audience.audienceId}',
                          ),
                    );
                    return index < 0 ? null : index;
                  },
                  itemBuilder: (context, index) {
                    final audience = visible[index];
                    return CatchField.navigate(
                      key: ValueKey(
                        'host-saved-audience-${audience.audienceId}',
                      ),
                      content: CatchRecordLayout(
                        title: audience.name,
                        facts: [_savedAudienceDirectoryBody(context, audience)],
                        icon: CatchIcons.groupsOutlined,
                        metadata: audience.definition.isStatic
                            ? context.l10n.hostAudienceManualGroup
                            : context.l10n.hostAudienceAutomaticGroup,
                      ),
                      onActivate: () => onOpen(audience),
                    );
                  },
                ),
                if (visible.isEmpty)
                  SliverToBoxAdapter(
                    child: CatchEmptyState(
                      icon: CatchIcons.groupsOutlined,
                      title:
                          query == null &&
                              _membership == _HostSavedAudienceMembership.all
                          ? context.l10n.hostSavedAudiencesEmptyTitle
                          : context.l10n.hostSavedAudiencesSearchEmptyTitle,
                      message:
                          query == null &&
                              _membership == _HostSavedAudienceMembership.all
                          ? context.l10n.hostSavedAudiencesEmptyBody
                          : context.l10n.hostSavedAudiencesSearchEmptyBody,
                      variant: CatchEmptyStateVariant.inline,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _chooseSort() async {
    final selected = await showCatchSelectionSheet<bool>(
      context: context,
      title: context.l10n.hostCustomersSort,
      value: _byName,
      items: [
        CatchSelectionMenuItem(
          value: true,
          label: context.l10n.hostCustomersSortName,
        ),
        CatchSelectionMenuItem(
          value: false,
          label: context.l10n.hostAudienceRecentlyChecked,
        ),
      ],
    );
    if (selected != null && mounted) setState(() => _byName = selected);
  }

  Future<void> _chooseMembership() async {
    final selected =
        await showCatchSelectionSheet<_HostSavedAudienceMembership>(
          context: context,
          title: context.l10n.hostAudienceMembershipMode,
          value: _membership,
          items: [
            CatchSelectionMenuItem(
              value: _HostSavedAudienceMembership.all,
              label: context.l10n.hostAudienceAllGroups,
            ),
            CatchSelectionMenuItem(
              value: _HostSavedAudienceMembership.automatic,
              label: context.l10n.hostAudienceAutomaticGroup,
            ),
            CatchSelectionMenuItem(
              value: _HostSavedAudienceMembership.manual,
              label: context.l10n.hostAudienceManualGroup,
            ),
          ],
        );
    if (selected != null && mounted) setState(() => _membership = selected);
  }
}

List<HostSavedAudience> _matchingSavedAudiences(
  List<HostSavedAudience> audiences,
  String? query,
) {
  final normalized = query?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return audiences;
  return audiences
      .where((audience) => audience.name.toLowerCase().contains(normalized))
      .toList(growable: false);
}

String _savedAudienceDirectoryBody(
  BuildContext context,
  HostSavedAudience audience,
) {
  final count = audience.lastPreviewMatchCount;
  final countLabel = count == null
      ? context.l10n.hostSavedAudienceNeverPreviewed
      : context.l10n.hostSavedAudiencePeopleCount(count: count);
  final checked = audience.lastPreviewAt;
  return checked == null
      ? countLabel
      : '$countLabel · ${context.l10n.hostAudienceGroupChecked(date: DateFormat.MMMd().format(checked))}';
}
