part of 'dashboard_screen.dart';

class DashboardLoadingScreen extends StatelessWidget {
  const DashboardLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: DashboardLoadingHeader()),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: CatchLayout.maxContentWidth,
                  ),
                  child: const CatchSectionStack(
                    padding: CatchInsets.pageBodyUnderHeader,
                    gap: CatchSpacing.micro18,
                    children: [DashboardFocusLoadingCard()],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
