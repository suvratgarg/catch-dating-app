part of 'dashboard_screen.dart';

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({
    super.key,
    required this.header,
    required this.dashboardSliver,
    this.actions = const <Widget>[],
  });

  final DashboardHomeHeaderModel header;
  final Widget dashboardSliver;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return CatchRootScreenScaffold(
      header: CatchScreenHeaderTitle.block(
        title: header.title(context.l10n),
        actions: actions,
      ),
      bodyLayout: CatchScreenBodyLayout.standard,
      constrainToContentWidth: true,
      semanticsLabel: context.l10n.dashboardDashboardHomeScreenLabelHome,
      slivers: [dashboardSliver],
    );
  }
}
