part of 'dashboard_screen.dart';

class DashboardEmptyHomeScreen extends StatelessWidget {
  const DashboardEmptyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchRootScreenScaffold.fullBleed(
      header: const SizedBox.shrink(),
      semanticsLabel: context.l10n.dashboardDashboardEmptyHomeScreenLabelHome,
      slivers: const [DashboardEmptySliverBody()],
    );
  }
}
