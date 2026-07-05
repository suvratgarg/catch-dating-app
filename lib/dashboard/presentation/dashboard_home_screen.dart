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
          label: 'Home',
          child: CustomScrollView(
            slivers: [
              ...CatchSliverHeader(
                title: DashboardHeaderContent(
                  eyebrow: header.eyebrow,
                  title: header.title,
                  actions: actions,
                ),
              ).buildSlivers(context),
              dashboardSliver,
            ],
          ),
        ),
      ),
    );
  }
}
