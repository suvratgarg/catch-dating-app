part of 'host_audience_view.dart';

enum HostAudienceMenuAction { reviewDuplicates, export, automations }

/// Shared chrome owner for every Audience tab, including route states.
class HostAudienceScaffold extends StatelessWidget {
  const HostAudienceScaffold({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.body,
    this.organizerId,
    this.primaryAction,
    this.menuItems = const [],
    this.onMenuAction,
    this.search,
    this.selectionAnimation,
    this.animationOffset = 0,
  });

  final HostAudienceView selected;
  final ValueChanged<HostAudienceView> onChanged;
  final CatchRootScreenBody body;
  final String? organizerId;
  final CatchTopBarPrimaryButton? primaryAction;
  final List<CatchActionMenuItem<HostAudienceMenuAction>> menuItems;
  final ValueChanged<HostAudienceMenuAction>? onMenuAction;
  final CatchTopBarSearch? search;
  final Animation<double>? selectionAnimation;
  final double animationOffset;

  @override
  Widget build(BuildContext context) => CatchRootScreenScaffold.withPrimaryRail(
    header: CatchRootScreenHeader.title(
      title: context.l10n.hostNavigationAudience,
      actions: [
        ?primaryAction,
        if (organizerId != null)
          CatchActionMenu<HostAudienceMenuAction>(
            tooltip: context.l10n.hostCustomersMoreActions,
            items: [
              ...menuItems,
              CatchActionMenuItem(
                value: HostAudienceMenuAction.automations,
                label: context.l10n.hostFormAutomationsTitle,
                icon: CatchIcons.autoAwesomeOutlined,
              ),
            ],
            onSelected: (action) {
              if (action == HostAudienceMenuAction.automations) {
                context.pushNamed(
                  Routes.hostAudienceAutomationsScreen.name,
                  queryParameters: {'organizerId': organizerId!},
                );
              } else {
                onMenuAction?.call(action);
              }
            },
          ),
      ],
      search: search,
    ),
    actions: HostAudienceTabRail(
      selected: selected,
      selectionAnimation: selectionAnimation,
      selectionPosition: selectionAnimation == null
          ? selected.index.toDouble()
          : null,
      animationOffset: animationOffset,
      onChanged: onChanged,
    ),
    body: body,
  );
}
