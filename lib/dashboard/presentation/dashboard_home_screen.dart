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
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: Semantics(
          label: context.l10n.dashboardDashboardHomeScreenLabelHome,
          child: CustomScrollView(
            slivers: [
              ...CatchSliverHeader(
                title: CatchScreenHeaderTitle.block(
                  title: header.title(context.l10n),
                  actions: actions,
                ),
              ).buildSlivers(context),
              dashboardSliver,
              const CatchSliverTerminalPadding(),
            ],
          ),
        ),
      ),
    );
  }
}
