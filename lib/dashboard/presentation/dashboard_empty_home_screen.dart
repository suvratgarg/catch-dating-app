part of 'dashboard_screen.dart';

class DashboardEmptyHomeScreen extends StatelessWidget {
  const DashboardEmptyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchRootScreenScaffold(
      header: const SizedBox.shrink(),
      bodyLayout: CatchScreenBodyLayout.fullBleed,
      semanticsLabel: context.l10n.dashboardDashboardEmptyHomeScreenLabelHome,
      slivers: const [DashboardEmptySliverBody()],
    );
  }
}
