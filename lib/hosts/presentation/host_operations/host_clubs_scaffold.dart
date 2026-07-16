part of '../host_operations_screen.dart';

class HostClubsScaffold extends StatefulWidget {
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
  State<HostClubsScaffold> createState() => _HostClubsScaffoldState();
}

class _HostClubsScaffoldState extends State<HostClubsScaffold>
    with SingleTickerProviderStateMixin {
  static const _editorRevealAlignment = 0.08;

  late HostClubsScreenState _state;
  late final TabController _tabController;
  final GlobalKey _profileSectionsKey = GlobalKey();
  bool _didRevealInitialEditor = false;

  @override
  void initState() {
    super.initState();
    _state = HostClubsScreenState.resolve(
      clubs: widget.clubs,
      currentUid: widget.currentUid,
      selectedClubId: widget.initialClubId,
      selectedTab: _effectiveInitialTab,
    );
    _tabController = TabController(
      length: HostClubTab.values.length,
      initialIndex: HostClubTab.values.indexOf(_state.selectedTab),
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
    _state = HostClubsScreenState.resolve(
      clubs: widget.clubs,
      currentUid: widget.currentUid,
      selectedClubIndex: _state.selectedClubIndex,
      selectedClubId: _state.selectedClub?.id,
      selectedTab: _state.selectedTab,
    );
    final selectedIndex = HostClubTab.values.indexOf(_state.selectedTab);
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
    final selectedClub = _state.selectedClub;
    if (selectedClub == null) {
      return Scaffold(
        backgroundColor: t.bg,
        appBar: CatchScreenTopBar(
          eyebrow: context.l10n.hostsHostClubsScaffoldKickerHostClubs,
          title: _state.title(context.l10n),
          border: true,
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: ListView(
            padding: CatchInsets.pageBodyUnderHeader.copyWith(bottom: 0),
            children: [
              HostEmptyActionCard(
                title: context.l10n.hostsHostClubsScaffoldTitleNoHostClubsYet,
                body: context.l10n.hostsHostClubsScaffoldBodyCreateAClubOr,
                actions: [
                  CatchButton(
                    label: context.l10n.hostsHostClubsScaffoldLabelCreateClub,
                    icon: Icon(CatchIcons.addRounded, size: CatchIcon.md),
                    onPressed: () =>
                        context.pushNamed(Routes.hostCreateClubScreen.name),
                  ),
                ],
              ),
              const CatchScrollTerminalPadding(),
            ],
          ),
        ),
      );
    }

    _scheduleInitialEditorReveal();

    return CatchTabbedScreenScaffold(
      title: selectedClub.name,
      actions: [
        if (_state.showClubPicker)
          CatchTopBarMenuAction<int>(
            tooltip: context.l10n.hostsHostClubsScaffoldTooltipSwitchClub,
            icon: CatchIcons.expandMoreRounded,
            items: _hostClubSwitcherItems(_state, context.l10n),
            onSelected: _selectClubIndex,
          ),
      ],
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
            scrollKey: PageStorageKey(
              'host-club-${selectedClub.id}-edit-scroll',
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HostClubOrganizerOverviewController(
                      key: ValueKey(
                        'host-club-${selectedClub.id}-edit-summary',
                      ),
                      club: selectedClub,
                      currentUid: _state.currentUid,
                      isOwner: _state.selectedClubIsOwner,
                      onOpenEditor: _openEditorSections,
                      onOpenSettings: _openHostSettings,
                    ),
                    Padding(
                      padding: CatchInsets.pageBodyUnderHeader.copyWith(
                        bottom: 0,
                      ),
                      child: KeyedSubtree(
                        key: _profileSectionsKey,
                        child: HostClubProfileCard(
                          key: ValueKey('host-club-${selectedClub.id}-edit'),
                          club: selectedClub,
                          currentUid: _state.currentUid,
                          isOwner: _state.selectedClubIsOwner,
                          initialExpandedField: widget.initialExpandedEditField,
                          onPreviewClub: () => _selectTab(HostClubTab.preview),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          CatchTabbedPageScrollView(
            scrollKey: PageStorageKey(
              'host-club-${selectedClub.id}-insights-scroll',
            ),
            slivers: [
              SliverPadding(
                padding: CatchInsets.pageBodyUnderHeader.copyWith(bottom: 0),
                sliver: SliverToBoxAdapter(
                  child: HostClubInsightsPane(
                    key: ValueKey('host-club-${selectedClub.id}-insights'),
                    club: selectedClub,
                  ),
                ),
              ),
            ],
          ),
          ColoredBox(
            color: t.surface,
            child: CatchTabbedPageScrollView(
              scrollKey: PageStorageKey(
                'host-club-${selectedClub.id}-preview-scroll',
              ),
              slivers: [
                ClubDetailReadOnlyPreviewSliver(
                  initialClub: selectedClub,
                  currentUid: _state.currentUid,
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

  void _selectTab(HostClubTab tab) {
    final index = HostClubTab.values.indexOf(tab);
    if (_tabController.index == index) return;
    _tabController.animateTo(index);
  }

  void _selectClubIndex(int index) {
    setState(() {
      _state = _state.selectClubIndex(index);
      _didRevealInitialEditor = false;
    });
  }

  void _handleTabControllerChanged() {
    final tab = HostClubTab.values[_tabController.index];
    if (tab == _state.selectedTab || !mounted) return;
    setState(() => _state = _state.selectTab(tab));
  }

  void _openHostSettings() {
    context.pushNamed(Routes.hostSettingsScreen.name);
  }

  void _openEditorSections() {
    final editorContext = _profileSectionsKey.currentContext;
    if (editorContext == null) return;
    unawaited(
      Scrollable.ensureVisible(
        editorContext,
        alignment: _editorRevealAlignment,
        duration: MediaQuery.maybeOf(context)?.disableAnimations == true
            ? Duration.zero
            : CatchMotion.pageStep,
        curve: CatchMotion.standardCurve,
      ),
    );
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
          duration: Duration.zero,
        ),
      );
    });
  }
}

List<CatchActionMenuItem<int>> _hostClubSwitcherItems(
  HostClubsScreenState state,
  AppLocalizations l10n,
) {
  final items = <CatchActionMenuItem<int>>[];
  for (var index = 0; index < state.clubs.length; index++) {
    final club = state.clubs[index];
    final roleLabel = club.isOwnedBy(state.currentUid)
        ? l10n.hostsHostClubsScaffoldVisiblecopyOwner
        : l10n.hostsHostClubsScaffoldVisiblecopyHostTeam;
    items.add(
      CatchActionMenuItem(
        value: index,
        label: l10n.hostsHostClubsScaffoldLabelNameRolelabel(
          name: club.name,
          roleLabel: roleLabel,
        ),
      ),
    );
  }
  return items;
}
