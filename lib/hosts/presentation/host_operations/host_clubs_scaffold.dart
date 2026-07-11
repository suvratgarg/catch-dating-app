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

class _HostClubsScaffoldState extends State<HostClubsScaffold> {
  late HostClubsScreenState _state;

  @override
  void initState() {
    super.initState();
    _state = HostClubsScreenState.resolve(
      clubs: widget.clubs,
      currentUid: widget.currentUid,
      selectedClubId: widget.initialClubId,
      selectedTab: _effectiveInitialTab,
    );
  }

  @override
  void didUpdateWidget(HostClubsScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    _state = HostClubsScreenState.resolve(
      clubs: widget.clubs,
      currentUid: widget.currentUid,
      selectedClubIndex: _state.selectedClubIndex,
      selectedClubId: _state.selectedClub?.id,
      selectedTab: _state.selectedTab,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final selectedClub = _state.selectedClub;
    final organizerMode =
        selectedClub != null && _state.selectedTab == HostClubTab.organizer;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: organizerMode
          ? null
          : HostOperationsTopBar(
              kicker: 'HOST CLUBS',
              title: _state.title,
              bottom: selectedClub == null
                  ? null
                  : CatchTabRail<HostClubTab>(
                      groupKey: _hostClubTabRailKey,
                      selected: _state.selectedTab,
                      onChanged: _selectTab,
                      options: const [
                        CatchOption(
                          value: HostClubTab.organizer,
                          label: 'Organizer',
                        ),
                        CatchOption(value: HostClubTab.edit, label: 'Edit'),
                        CatchOption(
                          value: HostClubTab.insights,
                          label: 'Insights',
                        ),
                        CatchOption(
                          value: HostClubTab.preview,
                          label: 'Preview',
                        ),
                      ],
                    ),
              actions: [
                if (_state.showClubPicker)
                  CatchTopBarMenuAction<int>(
                    tooltip: 'Switch club',
                    icon: CatchIcons.expandMoreRounded,
                    items: _hostClubSwitcherItems(_state),
                    onSelected: _selectClubIndex,
                  ),
              ],
            ),
      body: SafeArea(
        top: organizerMode,
        bottom: false,
        child: ListView(
          padding: organizerMode
              ? CatchInsets.pageBody.copyWith(top: CatchSpacing.s12)
              : CatchInsets.pageBodyUnderHeader,
          children: [
            if (selectedClub == null)
              HostEmptyActionCard(
                title: 'No host clubs yet',
                body:
                    'Create a club or accept a host invite to start managing events.',
                actions: [
                  CatchButton(
                    label: 'Create club',
                    icon: Icon(CatchIcons.addRounded, size: CatchIcon.md),
                    onPressed: () =>
                        context.pushNamed(Routes.hostCreateClubScreen.name),
                  ),
                ],
              )
            else
              switch (_state.selectedTab) {
                HostClubTab.edit => HostClubProfileCard(
                  club: selectedClub,
                  currentUid: _state.currentUid,
                  isOwner: _state.selectedClubIsOwner,
                  initialExpandedField: widget.initialExpandedEditField,
                  onPreviewClub: _openClubPreview,
                ),
                HostClubTab.organizer => HostClubOrganizerOverviewController(
                  club: selectedClub,
                  currentUid: _state.currentUid,
                  isOwner: _state.selectedClubIsOwner,
                  clubs: _state.clubs,
                  showClubPicker: _state.showClubPicker,
                  onSelectClubIndex: _selectClubIndex,
                  onSelectTab: _selectTab,
                  onPreviewClub: _openClubPreview,
                  onOpenSettings: _openHostSettings,
                ),
                HostClubTab.insights => HostClubInsightsPane(
                  club: selectedClub,
                  isOwner: _state.selectedClubIsOwner,
                ),
                HostClubTab.preview => HostClubPreviewPane(
                  club: selectedClub,
                  onPreviewClub: _openClubPreview,
                ),
              },
          ],
        ),
      ),
    );
  }

  HostClubTab get _effectiveInitialTab =>
      widget.initialExpandedEditField == null
      ? widget.initialTab
      : HostClubTab.edit;

  void _selectTab(HostClubTab tab) {
    if (tab == HostClubTab.insights &&
        _state.selectedTab != HostClubTab.insights &&
        _state.selectedClub != null) {
      context.pushNamed(
        Routes.hostInsightsScreen.name,
        pathParameters: {'clubId': _state.selectedClub!.id},
      );
      return;
    }
    setState(() => _state = _state.selectTab(tab));
  }

  void _selectClubIndex(int index) {
    setState(() => _state = _state.selectClubIndex(index));
  }

  void _openClubPreview(Club club) {
    context.pushNamed(
      Routes.hostClubDetailScreen.name,
      pathParameters: {'clubId': club.id},
      extra: club,
    );
  }

  void _openHostSettings() {
    context.pushNamed(Routes.hostSettingsScreen.name);
  }
}

List<CatchActionMenuItem<int>> _hostClubSwitcherItems(
  HostClubsScreenState state,
) {
  return [
    for (var index = 0; index < state.clubs.length; index++)
      CatchActionMenuItem(
        value: index,
        label:
            '${state.clubs[index].name} · '
            '${state.clubs[index].isOwnedBy(state.currentUid) ? 'Owner' : 'Host team'}',
      ),
  ];
}
