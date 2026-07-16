part of 'dashboard_screen.dart';

class DashboardErrorScreen extends StatelessWidget {
  const DashboardErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            CatchSliverErrorState.fromError(
              error,
              context: AppErrorContext.dashboard,
              onRetry: onRetry,
            ),
            const CatchSliverTerminalPadding(),
          ],
        ),
      ),
    );
  }
}
