part of '../host_operations_screen.dart';

List<CatchOption<HostClubTab>> _hostClubTabOptions(BuildContext context) => [
  CatchOption(
    value: HostClubTab.edit,
    label: context.l10n.hostsHostClubsScaffoldLabelEdit,
  ),
  CatchOption(
    value: HostClubTab.insights,
    label: context.l10n.hostsHostClubsScaffoldLabelInsights,
  ),
  CatchOption(
    value: HostClubTab.preview,
    label: context.l10n.hostsHostClubsScaffoldLabelPreview,
  ),
];

/// Organizer route-state adapter that preserves the loaded workspace chrome.
///
/// Loading, auth, error, and no-organizer states replace only the tab body;
/// the route title, pinned peer rail, semantic body rhythm, responsive content
/// lane, scroll ownership, and shell terminal clearance stay on the canonical
/// tabbed-screen path.
class HostOrganizerStateScaffold extends StatelessWidget {
  const HostOrganizerStateScaffold({
    super.key,
    required this.selectedTab,
    required this.scrollKey,
    required this.slivers,
    this.actions = const <Widget>[],
  }) : assert(slivers.length > 0);

  final HostClubTab selectedTab;
  final PageStorageKey<String> scrollKey;
  final List<Widget> slivers;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return CatchRootScreenScaffold.withPrimaryRail(
      header: CatchRootScreenHeader.title(
        title: context.l10n.hostNavigationOrganizer,
        titleMaxLines: 2,
        rowCrossAxisAlignment: CrossAxisAlignment.start,
        actions: actions,
      ),
      primaryRail: CatchTabRail<HostClubTab>(
        groupKey: _hostClubTabRailKey,
        selected: selectedTab,
        selectionPosition: selectedTab.index.toDouble(),
        options: _hostClubTabOptions(context),
      ),
      semanticsLabel: context.l10n.hostsHostClubsScaffoldLabelClubWorkspaceTabs,
      body: CatchRootScreenBody.single(
        page: CatchRootScreenPageSpec.scroll(
          page: CatchRootScreenPageScrollView.standard(
            scrollKey: scrollKey,
            slivers: slivers,
          ),
        ),
      ),
    );
  }
}

class HostClubsScaffold extends ConsumerStatefulWidget {
  const HostClubsScaffold({
    super.key,
    required this.clubs,
    required this.currentUid,
    required this.initialTab,
    this.initialClubId,
    this.initialExpandedEditField,
  });

  final List<Club> clubs;
  final String currentUid;
  final String? initialClubId;
  final HostClubTab initialTab;
  final String? initialExpandedEditField;

  @override
  ConsumerState<HostClubsScaffold> createState() => _HostClubsScaffoldState();
}

class _HostClubsScaffoldState extends ConsumerState<HostClubsScaffold>
    with SingleTickerProviderStateMixin {
  static const _editorRevealAlignment = 0.08;

  late HostClubTab _selectedTab;
  late final TabController _tabController;
  final GlobalKey _profileSectionsKey = GlobalKey();
  final Map<HostClubTab, CatchRootScreenPageScrollController>
  _pageScrollControllers = {
    for (final tab in HostClubTab.values)
      tab: CatchRootScreenPageScrollController(),
  };
  final Map<HostClubTab, double> _pageScrollOffsets = {};
  final HostClubInsightsRefreshController _insightsRefreshController =
      HostClubInsightsRefreshController();
  bool _didRevealInitialEditor = false;

  @override
  void initState() {
    super.initState();
    _selectedTab = _effectiveInitialTab;
    _tabController = TabController(
      length: HostClubTab.values.length,
      initialIndex: HostClubTab.values.indexOf(_selectedTab),
      vsync: this,
    )..addListener(_handleTabControllerChanged);
  }

  @override
  void didUpdateWidget(HostClubsScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialExpandedEditField != widget.initialExpandedEditField ||
        oldWidget.initialClubId != widget.initialClubId) {
      _didRevealInitialEditor = false;
    }
    final selectedIndex = HostClubTab.values.indexOf(_selectedTab);
    if (_tabController.index != selectedIndex) {
      _tabController.index = selectedIndex;
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabControllerChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final signOutMutation = ref.watch(AuthSessionController.signOutMutation);
    final signOutAction = CatchIconAction(
      key: const ValueKey<String>('host-organizer-sign-out'),
      tooltip: context.l10n.hostsHostClubTeamScreenTitleSignOut,
      icon: CatchIcons.logoutRounded,
      onPressed: signOutMutation.isPending ? null : () => unawaited(_signOut()),
    );
    final selectedOrganizerId = ref.watch(
      hostOrganizerSelectionProvider(widget.currentUid),
    );
    final state = HostClubsScreenState.resolve(
      clubs: widget.clubs,
      currentUid: widget.currentUid,
      selectedClubId: selectedOrganizerId ?? widget.initialClubId,
      selectedTab: _selectedTab,
    );
    final selectedClub = state.selectedClub;
    if (selectedClub == null) {
      return CatchMutationErrorListener(
        mutation: AuthSessionController.signOutMutation,
        errorContext: AppErrorContext.auth,
        child: HostOrganizerStateScaffold(
          selectedTab: _selectedTab,
          scrollKey: const PageStorageKey<String>('host-organizer-empty-state'),
          actions: [signOutAction],
          slivers: [
            CatchSliverEmptyState(
              icon: CatchIcons.groupsOutlined,
              title: context.l10n.hostsHostClubsScaffoldTitleNoHostClubsYet,
              message: context.l10n.hostsHostClubsScaffoldBodyCreateAClubOr,
              action: CatchButton(
                label: context.l10n.hostsHostClubsScaffoldLabelCreateClub,
                icon: Icon(CatchIcons.addRounded, size: CatchIcon.md),
                size: CatchButtonSize.sm,
                onPressed: () =>
                    context.pushNamed(Routes.hostCreateClubScreen.name),
              ),
            ),
          ],
        ),
      );
    }

    _scheduleInitialEditorReveal();

    return CatchMutationErrorListener(
      mutation: AuthSessionController.signOutMutation,
      errorContext: AppErrorContext.auth,
      child: CatchRootScreenScaffold.withPrimaryRail(
        header: CatchRootScreenHeader.title(
          title: selectedClub.name,
          titleMaxLines: 2,
          rowCrossAxisAlignment: CrossAxisAlignment.start,
          actions: [signOutAction],
        ),
        primaryRail: CatchTabControllerRail<HostClubTab>(
          controller: _tabController,
          groupKey: _hostClubTabRailKey,
          options: _hostClubTabOptions(context),
        ),
        semanticsLabel:
            context.l10n.hostsHostClubsScaffoldLabelClubWorkspaceTabs,
        semanticsHint: context.l10n.hostsHostClubsScaffoldBodyDragLeftOrRight,
        body: CatchRootScreenBody.paged(
          controller: _tabController,
          pages: [
            CatchRootScreenPageSpec.scroll(
              page: CatchRootScreenPageScrollView.standard(
                scrollStateController: _pageScrollControllers[HostClubTab.edit],
                scrollKey: PageStorageKey(
                  'host-club-${selectedClub.id}-edit-scroll',
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      width: double.infinity,
                      child: KeyedSubtree(
                        key: _profileSectionsKey,
                        child: HostClubEditTab(
                          key: ValueKey('host-club-${selectedClub.id}-edit'),
                          club: selectedClub,
                          currentUid: state.currentUid,
                          isOwner: state.selectedClubIsOwner,
                          initialExpandedField: widget.initialExpandedEditField,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CatchRootScreenPageSpec.scroll(
              page: CatchRootScreenPageScrollView.standard(
                scrollStateController:
                    _pageScrollControllers[HostClubTab.insights],
                onRefresh: _insightsRefreshController.refresh,
                scrollKey: PageStorageKey(
                  'host-club-${selectedClub.id}-insights-scroll',
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      width: double.infinity,
                      child: HostClubInsightsPane(
                        key: ValueKey('host-club-${selectedClub.id}-insights'),
                        club: selectedClub,
                        refreshController: _insightsRefreshController,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CatchRootScreenPageSpec.surface(
              backgroundColor: t.surface,
              page: CatchRootScreenPageScrollView.fullBleed(
                scrollStateController:
                    _pageScrollControllers[HostClubTab.preview],
                scrollKey: PageStorageKey(
                  'host-club-${selectedClub.id}-preview-scroll',
                ),
                slivers: [
                  ClubDetailReadOnlyPreviewSliver(
                    initialClub: selectedClub,
                    currentUid: state.currentUid,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    final mutation = ref.read(AuthSessionController.signOutMutation);
    if (mutation.isPending) return;
    try {
      await AuthSessionController.signOutMutation.run(
        ref,
        (tx) async => tx.get(authSessionControllerProvider.notifier).signOut(),
      );
    } catch (_) {
      // CatchMutationErrorListener owns user-facing error display.
      return;
    }
    if (mounted) context.go(Routes.startScreen.path);
  }

  HostClubTab get _effectiveInitialTab =>
      widget.initialExpandedEditField == null
      ? widget.initialTab
      : HostClubTab.edit;

  void _handleTabControllerChanged() {
    final tab = HostClubTab.values[_tabController.index];
    if (!mounted) return;
    if (tab != _selectedTab) {
      final previousTab = _selectedTab;
      final previousOffset = _pageScrollControllers[previousTab]
          ?.captureOffset();
      if (previousOffset != null) {
        _pageScrollOffsets[previousTab] = previousOffset;
      }
      setState(() => _selectedTab = tab);
    }
    if (!_tabController.indexIsChanging && _tabController.offset == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _pageScrollControllers[tab]?.restoreOffset(_pageScrollOffsets[tab]);
      });
    }
  }

  void _scheduleInitialEditorReveal() {
    if (_didRevealInitialEditor || widget.initialExpandedEditField == null) {
      return;
    }
    _didRevealInitialEditor = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final editorContext = _profileSectionsKey.currentContext;
      if (editorContext == null) {
        _didRevealInitialEditor = false;
        return;
      }
      unawaited(
        Scrollable.ensureVisible(
          editorContext,
          alignment: _editorRevealAlignment,
        ),
      );
    });
  }
}
