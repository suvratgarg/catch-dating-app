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
    return CatchRootScreenScaffold.standard(
      header: const SizedBox.shrink(),
      slivers: [
        CatchLocalizedSliverErrorState(
          error,
          context: AppErrorContext.dashboard,
          onRetry: onRetry,
        ),
      ],
    );
  }
}
