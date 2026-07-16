part of 'dashboard_screen.dart';

class DashboardEmptyHomeScreen extends StatelessWidget {
  const DashboardEmptyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: Semantics(
          label: context.l10n.dashboardDashboardEmptyHomeScreenLabelHome,
          child: const CustomScrollView(
            slivers: [DashboardEmptySliverBody(), CatchSliverTerminalPadding()],
          ),
        ),
      ),
    );
  }
}
