import assert from "node:assert/strict";
import test from "node:test";
import {
  extractGoRouterConfigurationBlock,
  extractImperativePageRoutesFromSource,
  extractRuntimeRouteEntries,
  extractRuntimeRouteGraph,
  imperativePagePresentationTarget,
  isUnnamedRedirectOnly,
  normalizePresentationExpression,
  routePresentationExpression,
  routePresentationTarget,
  routeRenderKind,
  validateRouteSourceForInventory,
} from "./check_route_inventory.mjs";

test("extracts returned and lifecycle-owned GoRouter configurations", () => {
  for (const source of [
    "return GoRouter(routes: const []);",
    "final router = GoRouter(routes: const []); ref.onDispose(router.dispose); return router;",
  ]) {
    const block = extractGoRouterConfigurationBlock(source);
    assert.match(block.body, /routes:\s*const \[\]/u);
  }
});

test("allows only an unnamed redirect-only legacy route", () => {
  assert.equal(isUnnamedRedirectOnly({
    redirectExpression: "(_, state) => legacyRedirect(state.uri)",
    builderExpression: "",
    pageBuilderExpression: "",
  }), true);
});

test("rejects unnamed routes that can render a page", () => {
  assert.equal(isUnnamedRedirectOnly({
    redirectExpression: "(_, state) => legacyRedirect(state.uri)",
    builderExpression: "(_, _) => const LegacyScreen()",
    pageBuilderExpression: "",
  }), false);
  assert.equal(isUnnamedRedirectOnly({
    redirectExpression: "",
    builderExpression: "",
    pageBuilderExpression: "",
  }), false);
});

test("classifies rendered and redirect-only route presentations", () => {
  assert.equal(routeRenderKind({
    redirectExpression: "(_, _) => '/new'",
    builderExpression: "",
    pageBuilderExpression: "",
  }), "redirect");
  assert.equal(routeRenderKind({
    redirectExpression: "",
    builderExpression: "(_, _) => const Screen()",
    pageBuilderExpression: "",
  }), "builder");
  assert.equal(routeRenderKind({
    redirectExpression: "",
    builderExpression: "",
    pageBuilderExpression: "(_, _) => const MaterialPage(child: Screen())",
  }), "pageBuilder");
});

test("normalizes the active route presentation expression", () => {
  assert.equal(routePresentationExpression({
    renderKind: "builder",
    redirectExpression: "(_, _) => '/new'",
    builderExpression: "(context, state) =>\n const Screen()",
    pageBuilderExpression: "",
  }), "(context,state)=>const Screen()");
  assert.equal(routePresentationExpression({
    renderKind: "pageBuilder",
    redirectExpression: "",
    builderExpression: "",
    pageBuilderExpression: "_eventDetailPage",
  }), "_eventDetailPage");
});

test("canonical presentation expressions ignore formatting but preserve strings", () => {
  assert.equal(
    normalizePresentationExpression(
      "(_, _) => Screen( label: 'hello world', values: const { 1, 2, }, )",
    ),
    "(_,_)=>Screen(label:'hello world',values:const{1,2})",
  );
  assert.equal(
    normalizePresentationExpression("final Event event => event"),
    "final Event event=>event",
  );
});

test("extracts deterministic presentation targets from route presentations", () => {
  assert.equal(
    routePresentationTarget("(context, state) => const Screen()"),
    "Screen",
  );
  assert.equal(routePresentationTarget("_eventDetailPage"), "_eventDetailPage");
  assert.equal(
    routePresentationTarget(
      "(context, state) { final id = state.pathParameters['id']; return DetailScreen(id: id); }",
    ),
    "DetailScreen",
  );
});

test("inventories generic imperative MaterialPageRoute presentations", () => {
  const routes = extractImperativePageRoutesFromSource(`
Future<void> open(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => const FeatureScreen(),
    ),
  );
}
`, "lib/feature/open.dart");

  assert.deepEqual(routes, [{
    siteId: "material-page:lib/feature/open.dart:1",
    sourcePath: "lib/feature/open.dart",
    line: 4,
    ordinal: 1,
    presentationExpression: "(_)=>const FeatureScreen()",
    presentationTarget: "FeatureScreen",
    fullscreenDialogExpression: "true",
  }]);
});

test("finds a screen nested inside an imperative Consumer builder", () => {
  assert.equal(
    imperativePagePresentationTarget(
      "(context) => Consumer(builder: (_, ref, _) => MatchCelebrationDialog(match: match))",
    ),
    "MatchCelebrationDialog",
  );
});

test("does not inventory modal sheets or dialogs as imperative pages", () => {
  const routes = extractImperativePageRoutesFromSource(`
showDialog<void>(context: context, builder: (_) => const AlertDialog());
showModalBottomSheet<void>(
  context: context,
  builder: (_) => const SheetBody(),
);
`, "lib/feature/modals.dart");

  assert.deepEqual(routes, []);
});

test("discovers arrow-bodied route helpers instead of dropping their routes", () => {
  const source = `
GoRouter buildRouter() {
  return GoRouter(
  routes: [
    ...fixtureRoutes(),
  ],
);
}

List<GoRoute> fixtureRoutes() => [
  GoRoute(
    path: Routes.fixture.path,
    name: Routes.fixture.name,
    builder: (_, _) => const FixtureScreen(),
  ),
];
`;
  const graph = extractRuntimeRouteGraph(
    source,
    extractGoRouterConfigurationBlock(source),
  );
  const routes = extractRuntimeRouteEntries(graph.text, [
    {id: "fixture", path: "/fixture"},
  ]);

  assert.deepEqual(graph.routeHelperNames, ["fixtureRoutes"]);
  assert.deepEqual(routes.map((route) => route.id), ["fixture"]);
});

test("fails closed on imported or prebuilt route collections", () => {
  const variableSource = `return GoRouter(routes: [...importedRoutes]);`;
  assert.throws(
    () => extractRuntimeRouteGraph(
      variableSource,
      extractGoRouterConfigurationBlock(variableSource),
    ),
    /imported or prebuilt spread collection `importedRoutes`/u,
  );

  const helperSource = `return GoRouter(routes: [...importedRoutes()]);`;
  assert.throws(
    () => extractRuntimeRouteGraph(
      helperSource,
      extractGoRouterConfigurationBlock(helperSource),
    ),
    /no locally declared typed route factory could be resolved/u,
  );

  const prebuiltHelperSource = `
return GoRouter(routes: [...localRoutes()]);
List<GoRoute> localRoutes() => importedRoutes;
`;
  assert.throws(
    () => extractRuntimeRouteGraph(
      prebuiltHelperSource,
      extractGoRouterConfigurationBlock(prebuiltHelperSource),
    ),
    /does not construct a supported route or delegate/u,
  );
});

test("fails closed on route constructor typedefs", () => {
  assert.throws(
    () => validateRouteSourceForInventory(
      "typedef AppRoute = GoRoute;\nAppRoute(path: '/hidden');",
      "lib/routing/go_router.dart",
    ),
    /route constructor typedefs are not inventory-safe \(GoRoute\)/u,
  );
  assert.throws(
    () => validateRouteSourceForInventory(
      "typedef AppPage<T> = MaterialPageRoute<T>;",
      "lib/feature/open.dart",
    ),
    /route constructor typedefs are not inventory-safe \(MaterialPageRoute\)/u,
  );
});

test("fails closed on GoRoute definitions outside the canonical graph", () => {
  assert.throws(
    () => validateRouteSourceForInventory(
      "final route = router.GoRoute(path: '/hidden');",
      "lib/feature/imported_routes.dart",
    ),
    /GoRoute construction is outside lib\/routing\/go_router\.dart/u,
  );
});

test("fails closed on unsupported full-screen PageRoute constructors", () => {
  for (const routeType of ["CupertinoPageRoute", "PageRouteBuilder"]) {
    assert.throws(
      () => extractImperativePageRoutesFromSource(
        `${routeType}<void>(builder: (_) => const FixtureScreen())`,
        "lib/feature/open.dart",
      ),
      new RegExp(`${routeType} is a full-screen PageRoute`, "u"),
    );
  }
});
