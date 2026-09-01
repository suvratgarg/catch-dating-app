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
        child: CatchRootScreenScaffold(
          header: CatchScreenHeaderTitle.block(
            eyebrow: context.l10n.hostsHostClubsScaffoldKickerHostClubs,
            title: state.title(context.l10n),
            actions: [signOutAction],
          ),
          bodyLayout: CatchScreenBodyLayout.standard,
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
      child: CatchTabbedScreenScaffold(
        title: selectedClub.name,
        titleMaxLines: 2,
        rowCrossAxisAlignment: CrossAxisAlignment.start,
        actions: [signOutAction],
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
        semanticsLabel:
            context.l10n.hostsHostClubsScaffoldLabelClubWorkspaceTabs,
        semanticsHint: context.l10n.hostsHostClubsScaffoldBodyDragLeftOrRight,
        body: TabBarView(
          controller: _tabController,
          children: [
            CatchTabbedPageScrollView(
              scrollStateController: _pageScrollControllers[HostClubTab.edit],
              bodyLayout: CatchScreenBodyLayout.standard,
              constrainToContentWidth: true,
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
            CatchTabbedPageScrollView(
              scrollStateController:
                  _pageScrollControllers[HostClubTab.insights],
              bodyLayout: CatchScreenBodyLayout.standard,
              constrainToContentWidth: true,
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
            ColoredBox(
              color: t.surface,
              child: CatchTabbedPageScrollView(
                scrollStateController:
                    _pageScrollControllers[HostClubTab.preview],
                bodyLayout: CatchScreenBodyLayout.fullBleed,
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
