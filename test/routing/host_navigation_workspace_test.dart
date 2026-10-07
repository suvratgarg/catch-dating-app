import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/routing/host_navigation_workspace.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../test_pump_helpers.dart';

void main() {
  testWidgets('navigator anchor does not mount a second production index', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HostWorkspaceRouteScope(
          navigatorRoot: true,
          panes: const [],
          onBack: () {},
          child: HostWorkspaceIndexScreen(
            root: Routes.hostEventsScreen,
            uri: Uri(path: Routes.hostEventsScreen.path),
          ),
        ),
      ),
    );
    // Mounting a second index would also attempt to resolve its providers.
    expect(find.byType(CatchNavigationViewport), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test(
    'every Host named route belongs to one of the five workspace branches',
    () {
      final graph = hostWorkspaceRouteGraph(AppAnalytics());
      expect(graph.branches, hasLength(5));
      final names = <String>[];
      void visit(RouteBase route) {
        if (route is GoRoute) {
          expect(route.parentNavigatorKey, isNull, reason: route.name);
          if (route.name != null) names.add(route.name!);
        }
        for (final child in route.routes) {
          visit(child);
        }
      }

      for (final branch in graph.branches) {
        expect(branch.routes.single, isA<ShellRoute>());
        visit(branch.routes.single);
      }
      expect(names.toSet(), {
        for (final route in Routes.values)
          if (route.audience == AppRouteAudience.host) route.name,
      });
      expect(names.length, names.toSet().length);
    },
  );

  testWidgets(
    'routed panes keep index state, nested Back and push results across widths',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1400, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final draft = TextEditingController();
      addTearDown(draft.dispose);
      final router = GoRouter(
        initialLocation: '/index',
        routes: [
          ShellRoute(
            builder: (context, state, child) => HostWorkspaceRouteScope.route(
              index: HostNavigationWorkspace.panes(
                compactPaneId: 'index',
                panes: [
                  CatchWorkspacePane(
                    id: 'index',
                    child: Material(
                      child: TextField(
                        key: const ValueKey('index-draft'),
                        controller: draft,
                      ),
                    ),
                  ),
                ],
              ),
              navigator: child,
              selectedRoute: state.uri.path == '/index' ? null : state.uri.path,
              ancestors: [
                if (state.uri.path == '/record')
                  const CatchWorkspacePane(
                    id: 'detail',
                    child: Material(child: Text('Detail ancestor')),
                  ),
              ],
              onBack: () => context.canPop()
                  ? context.pop('saved')
                  : context.go('/index'),
            ),
            routes: [
              GoRoute(
                path: '/index',
                builder: (context, _) =>
                    HostWorkspaceRouteScope.isNavigatorRoot(context)
                    ? const SizedBox.shrink()
                    : const Material(child: Text('Duplicate root index')),
              ),
              GoRoute(
                path: '/detail',
                builder: (_, _) => const Material(child: Text('Detail')),
              ),
              GoRoute(
                path: '/record',
                builder: (context, _) => const Material(
                  child: Column(
                    children: [
                      Text('Record'),
                      CatchTopBar.route(
                        title: 'Record',
                        navigation: CatchTopBarNavigation(
                          mode: CatchTopBarNavigationMode.back,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      );
      await pumpFeatureUi(tester);
      expect(
        find.text('Duplicate root index', skipOffstage: false),
        findsNothing,
      );
      await tester.enterText(
        find.byKey(const ValueKey('index-draft')),
        'Keep this draft',
      );
      final indexElement = tester.element(
        find.byKey(const ValueKey('index-draft')),
      );
      final detailResult = router.push<String>('/detail');
      await pumpFeatureUi(tester);
      expect(find.text('Detail'), findsOneWidget);
      expect(
        find.text('Duplicate root index', skipOffstage: false),
        findsNothing,
      );
      expect(
        tester.element(find.byKey(const ValueKey('index-draft'))),
        same(indexElement),
      );
      final result = router.push<String>('/record');
      await pumpFeatureUi(tester);
      expect(find.text('Detail ancestor'), findsOneWidget);
      expect(find.text('Record'), findsNWidgets(2));
      tester.view.physicalSize = const Size(390, 844);
      await pumpFeatureUi(tester);
      expect(find.byKey(const ValueKey('index-draft')), findsNothing);
      expect(find.text('Detail ancestor'), findsNothing);
      await tester.tap(find.byTooltip('Back'));
      await pumpFeatureUi(tester);
      expect(await result, 'saved');
      expect(find.text('Detail'), findsOneWidget);
      router.pop('closed');
      await pumpFeatureUi(tester);
      expect(await detailResult, 'closed');
      expect(find.text('Keep this draft'), findsOneWidget);
      expect(
        tester.element(find.byKey(const ValueKey('index-draft'))),
        same(indexElement),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
