import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/presentation/host_app_shell.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Guest shell', type: AppShell, path: '[App shell]')
Widget appShellGuestState(BuildContext context) {
  return const _ShellCatalog(
    title: 'AppShell',
    contractId: 'app.shell.consumer',
    child: _DeviceFrame(child: _ShellRouteScope()),
  );
}

@widgetbook.UseCase(name: 'Host shell', type: HostAppShell, path: '[App shell]')
Widget hostAppShellGuestState(BuildContext context) {
  return const _ShellCatalog(
    title: 'HostAppShell',
    contractId: 'app.shell.host',
    child: _DeviceFrame(child: _ShellRouteScope(host: true)),
  );
}

@widgetbook.UseCase(
  name: 'Guest CTA',
  type: GuestAuthCtaBar,
  path: '[App shell]',
)
Widget guestAuthCtaBarState(BuildContext context) {
  return const _ShellCatalog(
    title: 'GuestAuthCtaBar',
    contractId: 'component.app_shell.guest_auth_cta',
    child: GuestAuthCtaBar(),
  );
}

@widgetbook.UseCase(
  name: 'Navigation bar',
  type: AppShellNavigationBar,
  path: '[App shell]',
)
Widget appShellNavigationBarState(BuildContext context) {
  return _ShellCatalog(
    title: 'AppShellNavigationBar',
    contractId: 'component.app_shell.navigation_bar',
    child: AppShellNavigationBar(
      currentIndex: 3,
      unreadCount: 12,
      onDestinationSelected: (_) {},
    ),
  );
}

class _ShellRouteScope extends StatefulWidget {
  const _ShellRouteScope({this.host = false});

  final bool host;

  @override
  State<_ShellRouteScope> createState() => _ShellRouteScopeState();
}

class _ShellRouteScopeState extends State<_ShellRouteScope> {
  late final GoRouter _router = GoRouter(
    initialLocation: widget.host ? '/host/events' : Routes.exploreScreen.path,
    routes: [
      GoRoute(
        path: Routes.authScreen.path,
        builder: (_, state) => Scaffold(
          body: Center(
            child: Text(
              'Auth ${state.uri.queryParameters['from'] ?? ''}',
              style: CatchTextStyles.bodyM(context),
            ),
          ),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) => widget.host
            ? HostAppShell(navigationShell: navigationShell)
            : AppShell(navigationShell: navigationShell),
        branches: widget.host
            ? [
                _branch('/host/events', 'Events'),
                _branch('/host/clubs', 'Clubs'),
                _branch('/host/inbox', 'Inbox'),
                _branch('/host/account', 'Account'),
              ]
            : [
                _branch(Routes.dashboardScreen.path, 'Home'),
                _branch(Routes.exploreScreen.path, 'Explore'),
                _branch(Routes.swipeHubScreen.path, 'Catches'),
                _branch(Routes.matchesListScreen.path, 'Chats'),
                _branch(Routes.profileScreen.path, 'Profile'),
              ],
      ),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        uidProvider.overrideWith((ref) => Stream<String?>.value(null)),
        watchUserProfileProvider.overrideWith((ref) => Stream.value(null)),
        appConnectivityProvider.overrideWith((ref) => Stream.value(const [])),
        appAnalyticsProvider.overrideWithValue(
          AppAnalytics(
            reporter: _NoOpAnalyticsReporter(),
            shouldCollect: false,
          ),
        ),
        errorLoggerProvider.overrideWithValue(
          ErrorLogger(crashReporter: null, shouldReportErrors: false),
        ),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: _router),
    );
  }
}

StatefulShellBranch _branch(String path, String label) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        builder: (_, _) => Scaffold(
          body: Center(
            child: Text(label, style: const TextStyle(fontSize: 18)),
          ),
        ),
      ),
    ],
  );
}

class _ShellCatalog extends StatelessWidget {
  const _ShellCatalog({
    required this.title,
    required this.contractId,
    required this.child,
  });

  final String title;
  final String contractId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ColoredBox(
      color: t.bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(CatchSpacing.s5),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: CatchTextStyles.headline(context)),
                gapH4,
                Text(
                  contractId,
                  style: CatchTextStyles.supporting(context, color: t.ink3),
                ),
                gapH20,
                CatchSurface(borderColor: t.line, child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(CatchRadius.lg),
      child: SizedBox(width: 390, height: 640, child: child),
    );
  }
}

final class _NoOpAnalyticsReporter implements AnalyticsReporter {
  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {}

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setUserId(String? userId) async {}
}
