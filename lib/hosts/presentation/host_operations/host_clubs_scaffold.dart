part of '../host_operations_screen.dart';

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
  final Map<HostClubTab, CatchTabbedPageScrollController>
  _pageScrollControllers = {
    for (final tab in HostClubTab.values)
      tab: CatchTabbedPageScrollController(),
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
      return Scaffold(
        backgroundColor: t.bg,
        appBar: CatchScreenTopBar(
          context: context,
          eyebrow: context.l10n.hostsHostClubsScaffoldKickerHostClubs,
          title: state.title(context.l10n),
          border: true,
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
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
              const CatchSliverTerminalPadding(),
            ],
          ),
        ),
      );
    }

    _scheduleInitialEditorReveal();

    return CatchTabbedScreenScaffold(
      title: selectedClub.name,
      tabRail: CatchTabControllerRail<HostClubTab>(
        controller: _tabController,
        groupKey: _hostClubTabRailKey,
        options: [
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
        ],
      ),
      semanticsLabel: context.l10n.hostsHostClubsScaffoldLabelClubWorkspaceTabs,
      semanticsHint: context.l10n.hostsHostClubsScaffoldBodyDragLeftOrRight,
      body: TabBarView(
        controller: _tabController,
        children: [
          CatchTabbedPageScrollView(
            scrollStateController: _pageScrollControllers[HostClubTab.edit],
            constrainToContentWidth: true,
            scrollKey: PageStorageKey(
              'host-club-${selectedClub.id}-edit-scroll',
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: CatchInsets.pageBody.copyWith(bottom: 0),
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
              ),
            ],
          ),
          CatchTabbedPageScrollView(
            scrollStateController: _pageScrollControllers[HostClubTab.insights],
            constrainToContentWidth: true,
            onRefresh: _insightsRefreshController.refresh,
            scrollKey: PageStorageKey(
              'host-club-${selectedClub.id}-insights-scroll',
            ),
            slivers: [
              SliverPadding(
                padding: CatchInsets.pageBody.copyWith(bottom: 0),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    width: double.infinity,
                    child: HostClubInsightsPane(
                      key: ValueKey('host-club-${selectedClub.id}-insights'),
                      club: selectedClub,
                      refreshController: _insightsRefreshController,
                    ),
                  ),
                ),
              ),
            ],
          ),
          ColoredBox(
            color: t.surface,
            child: CatchTabbedPageScrollView(
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
    );
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
