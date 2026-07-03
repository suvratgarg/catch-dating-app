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
          label: 'Home',
          child: const CustomScrollView(slivers: [DashboardEmptySliverBody()]),
        ),
      ),
    );
  }
}
