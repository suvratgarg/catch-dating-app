import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/location_service.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/force_update/data/app_version_config_provider.dart';
import 'package:catch_dating_app/force_update/data/force_update_provider.dart';
import 'package:catch_dating_app/force_update/presentation/force_update_diagnostics.dart';
import 'package:catch_dating_app/force_update/presentation/update_required_screen.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final forceUpdate = ref.watch(forceUpdateRequiredProvider);
    ref.watch(locationInitializerProvider);

    return MaterialApp.router(
      title: AppConfig.appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        CountryLocalizations.getDelegate(enableLocalization: false),
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: goRouter,
      builder: (context, child) {
        final content = _ForceUpdateLifecycleWrapper(
          ref: ref,
          child: _buildForceUpdateGate(ref, forceUpdate, child),
        );

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
          ref
              .read(firebaseRemoteConfigProvider)
              .fetchAndActivate()
              .whenComplete(() {
            ref.invalidate(appVersionConfigProvider);
            ref.invalidate(appPackageInfoProvider);
            ref.invalidate(forceUpdateRequiredProvider);
          });
        },
      );
    }

    return const _ForceUpdateCheckLoadingScreen();
  }
}

/// Re-fetches Remote Config when the app is foregrounded so the force-update
/// gate stays fresh during long-running app sessions.
class _ForceUpdateLifecycleWrapper extends StatefulWidget {
  const _ForceUpdateLifecycleWrapper({
    required this.ref,
    required this.child,
  });

  final WidgetRef ref;
  final Widget child;

  @override
  State<_ForceUpdateLifecycleWrapper> createState() =>
      _ForceUpdateLifecycleWrapperState();
}

class _ForceUpdateLifecycleWrapperState
    extends State<_ForceUpdateLifecycleWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.ref
          .read(firebaseRemoteConfigProvider)
          .fetchAndActivate()
          .then((_) {
        if (mounted) {
          widget.ref.invalidate(appVersionConfigProvider);
          widget.ref.invalidate(forceUpdateRequiredProvider);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
                  CatchButton(
                    label: 'Try again',
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    fullWidth: true,
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
