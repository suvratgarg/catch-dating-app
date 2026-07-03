part of 'dashboard_screen.dart';

class DashboardErrorScreen extends StatelessWidget {
  const DashboardErrorScreen({
    super.key,
    required this.error,
    required this.fallbackMessage,
    required this.onRetry,
  });

  final Object error;
  final String fallbackMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (error is AppException) {
      return CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.dashboard,
        onRetry: onRetry,
      );
    }
    return CatchErrorScaffold(
      title: 'Dashboard unavailable',
      message: fallbackMessage,
      onRetry: onRetry,
    );
  }
}
