import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/force_update/data/app_version_repository.dart';
import 'package:catch_dating_app/force_update/data/force_update_provider.dart';
import 'package:catch_dating_app/force_update/presentation/update_required_screen.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final forceUpdate = ref.watch(forceUpdateRequiredProvider);

    return MaterialApp.router(
      title: AppConfig.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: goRouter,
      builder: (context, child) {
        final content = _buildForceUpdateGate(ref, forceUpdate, child);

        if (!AppConfig.shouldShowEnvironmentBanner) {
          return content;
        }

        return Banner(
          location: BannerLocation.topStart,
          message: AppConfig.environmentBannerLabel,
          child: content,
        );
      },
    );
  }

  Widget _buildForceUpdateGate(
    WidgetRef ref,
    AsyncValue<bool> forceUpdate,
    Widget? child,
  ) {
    if (forceUpdate.hasValue) {
      return forceUpdate.requireValue
          ? const UpdateRequiredScreen()
          : (child ?? const SizedBox.shrink());
    }

    if (forceUpdate.hasError) {
      return _ForceUpdateCheckErrorScreen(
        error: forceUpdate.error,
        onRetry: () {
          ref.invalidate(watchAppVersionConfigProvider);
          ref.invalidate(currentAppVersionProvider);
          ref.invalidate(currentAppBuildNumberProvider);
          ref.invalidate(forceUpdateRequiredProvider);
        },
      );
    }

    return const _ForceUpdateCheckLoadingScreen();
  }
}

class _ForceUpdateCheckLoadingScreen extends StatelessWidget {
  const _ForceUpdateCheckLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ForceUpdateCheckErrorScreen extends StatelessWidget {
  const _ForceUpdateCheckErrorScreen({
    required this.error,
    required this.onRetry,
  });

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final diagnostic = forceUpdateDevelopmentDiagnostic(error);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 48),
                  const SizedBox(height: 24),
                  Text(
                    'Could not verify app version',
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Check your connection and try again.',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (diagnostic != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      diagnostic,
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
String? forceUpdateDevelopmentDiagnostic(Object? error) {
  if (AppConfig.environment.isProduction || error == null) {
    return null;
  }

  if (error is FirebaseException &&
      error.plugin == 'cloud_firestore' &&
      error.code == 'permission-denied') {
    return 'Dev diagnostic: config/app_config was denied. Check deployed Firestore rules and App Check for ${AppConfig.environmentName}; for a physical debug iPhone, register the printed App Check debug token in Firebase Console.';
  }

  return 'Dev diagnostic: ${error.runtimeType}: $error';
}
