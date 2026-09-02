part of 'dashboard_screen.dart';

class DashboardLoadingScreen extends StatelessWidget {
  const DashboardLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatchRootScreenScaffold(
      header: DashboardLoadingHeader(),
      bodyLayout: CatchScreenBodyLayout.standard,
      constrainToContentWidth: true,
      slivers: [SliverToBoxAdapter(child: DashboardFocusLoadingCard())],
    );
  }
}
