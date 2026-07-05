part of '../host_operations_screen.dart';

class HostAuthRequiredScreen extends StatelessWidget {
  const HostAuthRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchErrorScaffold(
      title: 'Sign in required',
      message: 'Sign in to manage host operations.',
      retryLabel: 'Sign in',
      onRetry: () => context.go(Routes.authScreen.path),
    );
  }
}
