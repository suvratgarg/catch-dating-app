import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/presentation/catch_adaptive_tab_scaffold.dart';
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
      currentIndex: 2,
      unreadCount: 12,
      onDestinationSelected: (_) {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Adaptive placement',
  type: CatchAdaptiveTabScaffold,
  path: '[App shell]',
)
Widget catchAdaptiveTabScaffoldState(BuildContext context) {
  return const _ShellCatalog(
    title: 'CatchAdaptiveTabScaffold',
    contractId: 'catch.adaptive_tab_scaffold',
    child: _AdaptiveTabScaffoldDemo(),
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

class _AdaptiveTabScaffoldDemo extends StatefulWidget {
  const _AdaptiveTabScaffoldDemo();

  @override
  State<_AdaptiveTabScaffoldDemo> createState() =>
      _AdaptiveTabScaffoldDemoState();
}

class _AdaptiveTabScaffoldDemoState extends State<_AdaptiveTabScaffoldDemo> {
  TargetPlatform _platform = TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    final isIos = _platform == TargetPlatform.iOS;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SegmentedButton<TargetPlatform>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: TargetPlatform.iOS,
                label: Text('iOS · floating'),
              ),
              ButtonSegment(
                value: TargetPlatform.android,
                label: Text('Android · anchored'),
              ),
            ],
            selected: {_platform},
            onSelectionChanged: (selection) {
              setState(() => _platform = selection.single);
            },
          ),
        ),
        gapH20,
        _AdaptiveTabScaffoldFrame(
          platform: _platform,
          title: isIos ? 'iOS · floating' : 'Android · anchored',
          behavior: isIos
              ? 'The body extends behind the pill and publishes the complete '
                    'physical obstruction to the active tab.'
              : 'Scaffold reserves the navigation-bar viewport, so the active '
                    'tab publishes no overlay obstruction.',
        ),
      ],
    );
  }
}

class _AdaptiveTabScaffoldFrame extends StatelessWidget {
  const _AdaptiveTabScaffoldFrame({
    required this.platform,
    required this.title,
    required this.behavior,
  });

  final TargetPlatform platform;
  final String title;
  final String behavior;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: CatchTextStyles.titleS(context)),
        gapH4,
        Text(behavior, style: CatchTextStyles.supporting(context)),
        gapH10,
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.lg),
            child: SizedBox(
              width: 390,
              height: 360,
              child: Theme(
                data: AppTheme.light.copyWith(platform: platform),
                child: MediaQuery(
                  data: const MediaQueryData(
                    size: Size(390, 360),
                    padding: EdgeInsets.only(bottom: 34),
                    viewPadding: EdgeInsets.only(bottom: 34),
                  ),
                  child: CatchAdaptiveTabScaffold(
                    activeIndex: appShellClubsTabIndex,
                    navigationBar: AppShellNavigationBar(
                      currentIndex: appShellClubsTabIndex,
                      unreadCount: 3,
                      onDestinationSelected: _ignoreIndex,
                    ),
                    body: _AdaptiveShellBody(
                      placement: platform == TargetPlatform.iOS
                          ? 'Floating overlay'
                          : 'Anchored viewport',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdaptiveShellBody extends StatelessWidget {
  const _AdaptiveShellBody({required this.placement});

  final String placement;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final obstruction = AppShellActiveTab.bottomOverlayInsetOf(context);
    return ColoredBox(
      color: t.bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s4,
          CatchSpacing.s4,
          CatchSpacing.s4,
          0,
        ),
        children: [
          Text(placement, style: CatchTextStyles.headlineS(context)),
          gapH4,
          Text(
            'Published overlay: ${obstruction.toStringAsFixed(0)} px',
            style: CatchTextStyles.supporting(context, color: t.ink3),
          ),
          gapH16,
          CatchSurface.card(
            child: Text(
              'Tab content owns one scroll terminal. The shell only publishes '
              'placement and obstruction.',
              style: CatchTextStyles.bodyM(context),
            ),
          ),
          gapH12,
          CatchSurface.tinted(
            child: Text(
              obstruction > 0
                  ? 'The floating pill overlays this body.'
                  : 'The navigation bar sits outside this body.',
              style: CatchTextStyles.supporting(context),
            ),
          ),
          gapH32,
          Text(
            'Body terminal',
            textAlign: TextAlign.center,
            style: CatchTextStyles.supporting(context, color: t.ink3),
          ),
          gapH20,
        ],
      ),
    );
  }
}

void _ignoreIndex(int _) {}

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
