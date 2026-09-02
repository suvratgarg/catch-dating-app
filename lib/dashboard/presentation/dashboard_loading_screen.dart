part of 'dashboard_screen.dart';

class DashboardLoadingScreen extends StatelessWidget {
  const DashboardLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchRootScreenScaffold(
      header: const DashboardLoadingHeader(),
      bodyLayout: CatchScreenBodyLayout.standard,
      constrainToContentWidth: true,
      slivers: const [SliverToBoxAdapter(child: DashboardFocusLoadingCard())],
    );
  }
}
