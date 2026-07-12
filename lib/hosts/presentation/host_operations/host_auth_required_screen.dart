part of '../host_operations_screen.dart';

class HostAuthRequiredScreen extends StatelessWidget {
  const HostAuthRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchErrorScaffold(
      title: context.l10n.hostsHostAuthRequiredScreenTitleSignInRequired,
      message: context.l10n.hostsHostAuthRequiredScreenMessageSignInToManage,
      retryLabel: context.l10n.hostsHostAuthRequiredScreenVisiblecopySignIn,
      onRetry: () => context.go(Routes.authScreen.path),
    );
  }
}
