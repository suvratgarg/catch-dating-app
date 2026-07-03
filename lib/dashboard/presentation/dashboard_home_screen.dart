part of 'dashboard_screen.dart';

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({
    super.key,
    required this.header,
    required this.dashboardSliver,
    this.notificationAction,
  });

  final DashboardHomeHeaderModel header;
  final Widget dashboardSliver;
  final Widget? notificationAction;

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
              ...DashboardSliverHeader(
                eyebrow: header.eyebrow,
                title: header.title,
                actions: [?notificationAction],
              ).buildSlivers(context),
              dashboardSliver,
            ],
          ),
        ),
      ),
    );
  }
}
