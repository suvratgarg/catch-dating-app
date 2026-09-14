part of 'dashboard_screen.dart';

class DashboardLoadingScreen extends StatelessWidget {
  const DashboardLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchRootScreenScaffold.standard(
      title: const DashboardLoadingHeader(),
      children: const [SliverToBoxAdapter(child: DashboardFocusLoadingCard())],
    );
  }
}
