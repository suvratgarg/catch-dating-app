import 'package:test/test.dart';

import '../../tool/architecture/check_ui_composition_contracts.dart';

void main() {
  test('accepts a governed standard route owner', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'pushed-route',
        'expression': 'CatchRouteScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'route-chrome',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchRouteScaffold(
    body: CatchRouteBody.standard(child: const SizedBox()),
  );
}
''',
    );

    expect(failures, isEmpty);
  });

  test('rejects nested page geometry inside a standard route body', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'pushed-route',
        'expression': 'CatchRouteScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'route-chrome',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchRouteScaffold(
    body: CatchRouteBody.standard(
      child: CatchScreenBody(
        child: Padding(
          padding: CatchInsets.pageBody,
          child: const SizedBox(),
        ),
      ),
    ),
  );
}
''',
    );

    expect(
      failures,
      contains(
        allOf(
          contains('must not nest competing page geometry'),
          contains('CatchScreenBody'),
          contains('CatchInsets.pageBody'),
        ),
      ),
    );
  });

  test('follows a local standard-body child to competing page insets', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'pushed-route',
        'expression': 'CatchRouteScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'route-chrome',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() {
    final content = Padding(
      padding: CatchInsets.pageHorizontal,
      child: const SizedBox(),
    );
    return CatchRouteScaffold(
      body: CatchRouteBody.standard(child: content),
    );
  }
}
''',
    );

    expect(
      failures,
      contains(
        allOf(
          contains('must not nest competing page geometry'),
          contains('CatchInsets.pageHorizontal'),
        ),
      ),
    );
  });

  test('rejects nested page geometry inside an ordinary standard root', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'root',
        'expression': 'CatchRootScreenScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchRootScreenScaffold(
    bodyLayout: CatchScreenBodyLayout.standard,
    slivers: [
      CatchSliverScreenBody(
        layout: CatchScreenBodyLayout.standard,
        slivers: const [SliverToBoxAdapter()],
      ),
      SliverPadding(
        padding: CatchInsets.pageBody,
        sliver: const SliverToBoxAdapter(),
      ),
    ],
  );
}
''',
    );

    expect(
      failures,
      contains(
        allOf(
          contains('standard root content'),
          contains('CatchSliverScreenBody'),
          contains('CatchInsets.pageBody'),
        ),
      ),
    );
  });

  test('allows component insets and ignores dead competing geometry', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'pushed-route',
        'expression': 'CatchRouteScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'route-chrome',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchRouteScaffold(
    body: CatchRouteBody.standard(
      child: Padding(
        padding: CatchInsets.contentDense,
        child: const SizedBox(),
      ),
    ),
  );

  Object deadHelper() => CatchRouteBody.standard(
    child: CatchPageBody(child: const SizedBox()),
  );
}
''',
    );

    expect(failures, isEmpty);
  });

  test('follows a reachable local layout-owner builder', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'adaptive-workspace',
        'expression': 'CatchRootScreenScrollView',
        'bodyGeometry': 'full-bleed',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() {
    Object buildMaster() => CatchRootScreenScrollView(
      bodyLayout: CatchScreenBodyLayout.fullBleed,
    );

    return CatchScreenScaffold.workspace(body: buildMaster());
  }
}
''',
    );

    expect(failures, isEmpty);
  });

  test('rejects a standard owner mentioned only by a dead helper', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'pushed-route',
        'expression': 'CatchRouteScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'route-chrome',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => const SizedBox();

  Object deadHelper() => CatchRouteScaffold(
    body: CatchRouteBody.standard(child: const SizedBox()),
  );
}
''',
    );

    expect(failures, contains(contains('build/return tree')));
  });

  test('rejects one rogue build return beside a canonical terminal', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'pushed-route',
        'expression': 'CatchRouteScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'route-chrome',
      },
      declarationSource: '''
class ExampleScreen {
  Object build(bool rogue) {
    if (rogue) return const SizedBox();
    return CatchRouteScaffold(
      body: CatchRouteBody.standard(child: const SizedBox()),
    );
  }
}
''',
    );

    expect(failures, contains(contains('every ExampleScreen build/return')));
  });

  test('rejects a canonical owner hidden in a behavior callback', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'pushed-route',
        'expression': 'CatchRouteScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'route-chrome',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => GestureDetector(
    onTap: () => CatchRouteScaffold(
      body: CatchRouteBody.standard(child: const SizedBox()),
    ),
    child: const SizedBox(),
  );
}
''',
    );

    expect(failures, contains(contains('does not instantiate')));
  });

  test('rejects an unapproved callback merely named builder', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'pushed-route',
        'expression': 'CatchRouteScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'route-chrome',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => BehaviorOnlyWrapper(
    builder: () => CatchRouteScaffold(
      body: CatchRouteBody.standard(child: const SizedBox()),
    ),
    child: const SizedBox(),
  );
}
''',
    );

    expect(failures, contains(contains('does not instantiate')));
  });

  test('accepts canonical terminals in every widget-builder callback', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'pushed-route',
        'expression': 'CatchRouteScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'route-chrome',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchAsyncValueView(
    loadingBuilder: (_) => CatchRouteScaffold(
      body: CatchRouteBody.standard(child: const SizedBox()),
    ),
    errorBuilder: (_, __, ___) => CatchRouteScaffold(
      body: CatchRouteBody.standard(child: const SizedBox()),
    ),
    builder: (_, __) => CatchRouteScaffold(
      body: CatchRouteBody.standard(child: const SizedBox()),
    ),
  );
}
''',
    );

    expect(failures, isEmpty);
  });

  test('accepts a separately contracted same-family state delegate', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'pushed-route',
        'expression': 'CatchRouteScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'route-chrome',
      },
      terminalOwnerDelegates: const <String>{'ExampleLoadingScreen'},
      declarationSource: '''
class ExampleScreen {
  Object build(bool loading) {
    if (loading) return const ExampleLoadingScreen();
    return CatchRouteScaffold(
      body: CatchRouteBody.standard(child: const SizedBox()),
    );
  }
}
''',
    );

    expect(failures, isEmpty);
  });

  test(
    'resolved terminal proof cannot replace a direct owner construction',
    () {
      final failures = evaluateLayoutOwnerContract(
        screenId: 'screen.fixture',
        owner: <String, Object?>{
          'symbol': 'ExampleScreen',
          'family': 'root',
          'expression': 'CatchRootScreenScaffold',
          'bodyGeometry': 'standard',
          'topEdge': 'safe-area',
        },
        declarationSource: '''
class ExampleScreen {
  Object build() => const RegisteredRootDelegate();
}
''',
        resolvedTerminalOwnerProof: true,
      );

      expect(failures, contains(contains('does not instantiate')));
    },
  );

  test('resolved terminal proof cannot bless wrong direct body geometry', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'root',
        'expression': 'CatchRootScreenScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build(bool loading) => loading
      ? CatchRootScreenScaffold(
          bodyLayout: CatchScreenBodyLayout.fullBleed,
        )
      : const RegisteredRootDelegate();
}
''',
      resolvedTerminalOwnerProof: true,
    );

    expect(
      failures,
      contains(
        contains('must explicitly select CatchScreenBodyLayout.standard'),
      ),
    );
  });

  test('accepts one Stack root plane with conditional positioned overlays', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'root',
        'expression': 'CatchRootScreenScaffold',
        'bodyGeometry': 'full-bleed',
        'topEdge': 'header-owned',
      },
      declarationSource: '''
class ExampleScreen {
  Object build(bool showOverlay) => Stack(
    children: [
      CatchRootScreenScaffold(
        bodyLayout: CatchScreenBodyLayout.fullBleed,
        topEdge: CatchRootScreenTopEdge.headerOwned,
      ),
      if (showOverlay) Positioned(child: const MapLauncher()),
    ],
  );
}
''',
    );

    expect(failures, isEmpty);
  });

  test('rejects a second non-positioned Stack screen plane', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'root',
        'expression': 'CatchRootScreenScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => Stack(
    children: [
      CatchRootScreenScaffold(
        bodyLayout: CatchScreenBodyLayout.standard,
      ),
      const SizedBox.expand(),
    ],
  );
}
''',
    );

    expect(failures, contains(contains('every ExampleScreen build/return')));
  });

  test('does not follow a same-named helper through a qualified call', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'pushed-route',
        'expression': 'CatchRouteScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'route-chrome',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => external.buildPane();

  Object buildPane() => CatchRouteScaffold(
    body: CatchRouteBody.standard(child: const SizedBox()),
  );
}
''',
    );

    expect(failures, contains(contains('does not instantiate')));
  });

  test('rejects a rogue conditional child branch around an owner', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'pushed-route',
        'expression': 'CatchRouteScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'route-chrome',
      },
      declarationSource: '''
class ExampleScreen {
  Object build(bool rogue) => Decorator(
    child: rogue
        ? const SizedBox()
        : CatchRouteScaffold(
            body: CatchRouteBody.standard(child: const SizedBox()),
          ),
  );
}
''',
    );

    expect(failures, contains(contains('every ExampleScreen build/return')));
  });

  test('a dead standard helper cannot bless a full-bleed returned route', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'pushed-route',
        'expression': 'CatchRouteScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'route-chrome',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchRouteScaffold(
    body: CatchRouteBody.fullBleed(child: const SizedBox()),
  );

  Object deadHelper() => CatchRouteScaffold(
    body: CatchRouteBody.standard(child: const SizedBox()),
  );
}
''',
    );

    expect(failures, contains(contains('CatchRouteBody typed constructor')));
  });

  test('rejects mixed tab geometry supplied only by a dead page helper', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'root',
        'expression': 'CatchRootScreenScaffold.withPrimaryRail',
        'bodyGeometry': 'mixed',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchRootScreenScaffold.withPrimaryRail(
    body: CatchRootScreenBody.single(
      page: CatchRootScreenPageSpec.scroll(
        page: CatchRootScreenPageScrollView.fullBleed(),
      ),
    ),
  );

  Object deadPage() => CatchRootScreenPageSpec.scroll(
    page: StandardPage(),
  );
}
''',
    );

    expect(failures, contains(contains('must expose both standard')));
  });

  test('accepts typed tab bodies returned by a same-owner switch helper', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'root',
        'expression': 'CatchRootScreenScaffold.withPrimaryRail',
        'bodyGeometry': 'standard',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build(bool loading) => CatchRootScreenScaffold.withPrimaryRail(
    body: _body(loading),
  );

  Object _body(bool loading) => switch (loading) {
    true => CatchRootScreenBody.single(
      page: CatchRootScreenPageSpec.scroll(
        page: CatchRootScreenPageScrollView.standard(),
      ),
    ),
    false => CatchRootScreenBody.paged(
      pages: [
        CatchRootScreenPageSpec.scroll(
          page: CatchRootScreenPageScrollView.standard(),
        ),
      ],
    ),
  };
}
''',
    );

    expect(failures, isEmpty);
  });

  test('rejects a rogue branch in a same-owner tab body helper', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'root',
        'expression': 'CatchRootScreenScaffold.withPrimaryRail',
        'bodyGeometry': 'standard',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build(bool rogue) => CatchRootScreenScaffold.withPrimaryRail(
    body: _body(rogue),
  );

  Object _body(bool rogue) => rogue
      ? const LegacyTabbedBody()
      : CatchRootScreenBody.single(
          page: CatchRootScreenPageSpec.scroll(
            page: CatchRootScreenPageScrollView.standard(),
          ),
        );
}
''',
    );

    expect(failures, contains(contains('root primary-rail bodies must use')));
  });

  test('rejects an unresolved tab body helper', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'root',
        'expression': 'CatchRootScreenScaffold.withPrimaryRail',
        'bodyGeometry': 'standard',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchRootScreenScaffold.withPrimaryRail(
    body: external.buildBody(),
  );
}
''',
    );

    expect(failures, contains(contains('root primary-rail bodies must use')));
  });

  test('rejects a semantic root page owner with mixed geometry terminals', () {
    final failures = evaluateRootPageOwnerContract(
      symbol: 'MixedPageOwner',
      declarationSource: '''
class MixedPageOwner implements CatchRootScreenPageOwner {
  Object build(bool standard) => standard
      ? CatchRootScreenPageScrollView.standard()
      : CatchRootScreenPageScrollView.fullBleed();
}
''',
    );

    expect(failures, contains(contains('one consistent')));
  });

  test('rejects a rogue semantic root page return branch', () {
    final failures = evaluateRootPageOwnerContract(
      symbol: 'BranchingPageOwner',
      declarationSource: '''
class BranchingPageOwner implements CatchRootScreenPageOwner {
  Object build(bool rogue) {
    if (rogue) return const SizedBox();
    return CatchRootScreenPageScrollView.standard();
  }
}
''',
    );

    expect(
      failures,
      contains(
        contains('every semantic root page owner build/return terminal'),
      ),
    );
  });

  test('derives an inline root page role from the page owner', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'root',
        'expression': 'CatchRootScreenScaffold.withPrimaryRail',
        'bodyGeometry': 'standard',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchRootScreenScaffold.withPrimaryRail(
    body: CatchRootScreenBody.single(
      page: CatchRootScreenPageSpec.scroll(
        page: CatchRootScreenPageScrollView.fullBleed(),
      ),
    ),
  );
}
''',
    );

    expect(
      failures,
      contains(contains('standard root primary-rail bodies must select only')),
    );
  });

  test('rejects nested page geometry inside an inline standard root page', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'root',
        'expression': 'CatchRootScreenScaffold.withPrimaryRail',
        'bodyGeometry': 'standard',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchRootScreenScaffold.withPrimaryRail(
    body: CatchRootScreenBody.single(
      page: CatchRootScreenPageSpec.scroll(
        page: CatchRootScreenPageScrollView.standard(
          slivers: [
            SliverPadding(
              padding: CatchInsets.pageBody,
              sliver: const SliverToBoxAdapter(),
            ),
          ],
        ),
      ),
    ),
  );
}
''',
    );

    expect(
      failures,
      contains(
        allOf(
          contains('standard root page content'),
          contains('CatchInsets.pageBody'),
        ),
      ),
    );
  });

  test('does not inspect deliberate full-bleed root page geometry', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'root',
        'expression': 'CatchRootScreenScaffold.withPrimaryRail',
        'bodyGeometry': 'mixed',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchRootScreenScaffold.withPrimaryRail(
    body: CatchRootScreenBody.paged(
      pages: [
        CatchRootScreenPageSpec.scroll(
          page: CatchRootScreenPageScrollView.standard(
            slivers: [const SliverToBoxAdapter()],
          ),
        ),
        CatchRootScreenPageSpec.scroll(
          page: CatchRootScreenPageScrollView.fullBleed(
            slivers: [
              SliverPadding(
                padding: CatchInsets.pageBody,
                sliver: const SliverToBoxAdapter(),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
''',
    );

    expect(failures, isEmpty);
  });

  test('rejects nested page geometry in a semantic standard tab owner', () {
    final failures = evaluateRootPageOwnerContract(
      symbol: 'SemanticPageOwner',
      declarationSource: '''
class SemanticPageOwner implements CatchRootScreenPageOwner {
  Object build() => CatchRootScreenPageScrollView.standard(
    slivers: [
      CatchSliverPageBody(sliver: const SliverToBoxAdapter()),
    ],
  );
}
''',
    );

    expect(
      failures,
      contains(
        allOf(
          contains('semantic root page content'),
          contains('CatchSliverPageBody'),
        ),
      ),
    );
  });

  test('derives a semantic root page role from the page owner', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'root',
        'expression': 'CatchRootScreenScaffold.withPrimaryRail',
        'bodyGeometry': 'full-bleed',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchRootScreenScaffold.withPrimaryRail(
    body: CatchRootScreenBody.single(
      page: CatchRootScreenPageSpec.scroll(
        page: StandardSemanticPage(),
      ),
    ),
  );
}
''',
      semanticRootPageOwnerRoles: const <String, String>{
        'StandardSemanticPage': 'CatchScreenBodyLayout.standard',
      },
    );

    expect(
      failures,
      contains(
        contains('full-bleed root primary-rail bodies must select only'),
      ),
    );
  });

  test('rejects a root page hidden behind an unresolved variable', () {
    final failures = _evaluateIndirectTabPageOwner('someVariable');

    expect(failures, contains(contains('must resolve directly')));
  });

  test('rejects a root page hidden behind an unresolved helper', () {
    final failures = _evaluateIndirectTabPageOwner('helper()');

    expect(failures, contains(contains('must resolve directly')));
  });

  test('does not accept a layout expression mentioned only in a comment', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'pushed-route',
        'expression': 'CatchRouteScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'route-chrome',
      },
      declarationSource: '''
class ExampleScreen {
  // CatchRouteScaffold is the intended owner.
  Object build() => const SizedBox();
}
''',
    );

    expect(failures, contains(contains('does not instantiate')));
  });

  test('collects named-constructor layout owners from the AST', () {
    final instantiations = layoutOwnerInstantiations('''
class ExampleScreen {
  Object build() => CatchScreenScaffold.stepFlow(
    body: const SizedBox(),
  );
}
''');

    expect(
      instantiations.map((instantiation) => instantiation.signature),
      contains('CatchScreenScaffold.stepFlow'),
    );
  });

  test('rejects alias metadata for a route that renders a builder', () {
    final failures = evaluateRouteCoveragePresentationContracts(
      coverageRows: <Map<String, Object?>>[
        <String, Object?>{
          'routeId': 'renderedAlias',
          'status': 'alias',
          'canonicalRouteId': 'canonical',
        },
      ],
      renderKindByRoute: const <String, String>{'renderedAlias': 'builder'},
    );

    expect(failures, contains(contains('cannot use alias coverage')));
  });

  test('requires redirect-only routes to use alias coverage', () {
    final failures = evaluateRouteCoveragePresentationContracts(
      coverageRows: <Map<String, Object?>>[
        <String, Object?>{'routeId': 'legacyRedirect', 'status': 'contracted'},
      ],
      renderKindByRoute: const <String, String>{'legacyRedirect': 'redirect'},
    );

    expect(failures, contains(contains('must use alias coverage')));
  });

  test('requires every inventory route to have one coverage contract', () {
    final failures = evaluateRouteCoveragePresentationContracts(
      coverageRows: <Map<String, Object?>>[
        <String, Object?>{'routeId': 'covered', 'status': 'contracted'},
      ],
      renderKindByRoute: const <String, String>{
        'covered': 'builder',
        'missing': 'builder',
      },
    );

    expect(failures, contains(contains('missing')));
    expect(failures, contains(contains('has no coverage contract')));
  });

  test('rejects duplicate route coverage rows', () {
    final failures = evaluateRouteCoveragePresentationContracts(
      coverageRows: <Map<String, Object?>>[
        <String, Object?>{'routeId': 'duplicate', 'status': 'contracted'},
        <String, Object?>{'routeId': 'duplicate', 'status': 'contracted'},
      ],
      renderKindByRoute: const <String, String>{'duplicate': 'builder'},
    );

    expect(failures, contains(contains('must be unique')));
  });

  test('rejects planned routes from the zero-debt composition gate', () {
    final failures = evaluateRouteCoveragePresentationContracts(
      coverageRows: <Map<String, Object?>>[
        <String, Object?>{'routeId': 'plannedRoute', 'status': 'planned'},
      ],
      renderKindByRoute: const <String, String>{'plannedRoute': 'builder'},
    );

    expect(failures, contains(contains('planned coverage cannot bypass')));
  });

  test('rejects incompatible layout families for one rendered route', () {
    final failures = evaluateLayoutFamilyConsistency(
      screenId: 'screen.fixture',
      owners: <Map<String, Object?>>[
        <String, Object?>{
          'routes': <String>['fixtureRoute'],
          'family': 'pushed-route',
        },
        <String, Object?>{
          'routes': <String>['fixtureRoute'],
          'family': 'standalone',
        },
      ],
    );

    expect(failures, contains(contains('mixes layout families')));
  });

  test('requires every registered owner to be reachable from its GoRoute', () {
    final reachableOwner = const DeclarationBinding(
      file: 'lib/feature/reachable_screen.dart',
      symbol: 'ReachableScreen',
    );
    final missingOwner = const DeclarationBinding(
      file: 'lib/feature/dead_screen.dart',
      symbol: 'DeadScreen',
    );

    final failures = evaluateRouteOwnerReachability(
      routeId: 'fixtureRoute',
      renderKind: 'builder',
      presentationExpression: '(_, _) => const ReachableScreen()',
      presentationTarget: 'ReachableScreen',
      requiredOwners: <DeclarationBinding>[reachableOwner, missingOwner],
      reachableDeclarations: <DeclarationBinding>{reachableOwner},
    );

    expect(failures, contains(contains(screenRouteOwnerBindingCode)));
    expect(failures, contains(contains('DeadScreen')));
  });

  test('accepts resolved reachability for every registered route owner', () {
    final owner = const DeclarationBinding(
      file: 'lib/feature/screen.dart',
      symbol: 'FeatureScreen',
    );

    final failures = evaluateRouteOwnerReachability(
      routeId: 'fixtureRoute',
      renderKind: 'pageBuilder',
      presentationExpression: '_featurePage',
      presentationTarget: '_featurePage',
      requiredOwners: <DeclarationBinding>[owner],
      reachableDeclarations: <DeclarationBinding>{owner},
    );

    expect(failures, isEmpty);
  });

  test('fails closed when generated presentation metadata is absent', () {
    final failures = evaluateRouteOwnerReachability(
      routeId: 'fixtureRoute',
      renderKind: 'builder',
      presentationExpression: null,
      presentationTarget: null,
      requiredOwners: const <DeclarationBinding>[],
      reachableDeclarations: const <DeclarationBinding>{},
    );

    expect(failures, hasLength(2));
    expect(failures, everyElement(contains(screenRouteOwnerBindingCode)));
  });

  test('requires every imperative page target to have a typed contract', () {
    final failures = evaluateImperativePageContractCoverage(
      inventoryRows: <Map<String, Object?>>[
        <String, Object?>{
          'siteId': 'material-page:lib/feature.dart:1',
          'sourcePath': 'lib/feature.dart',
          'ordinal': 1,
          'presentationExpression': '(_) => const UnregisteredScreen()',
          'presentationTarget': 'UnregisteredScreen',
        },
      ],
      imperativePageContracts: const <String, Object?>{},
    );

    expect(failures, contains(contains('has no typed layout contract')));
  });

  test('rejects an imperative page contract with no production target', () {
    final failures = evaluateImperativePageContractCoverage(
      inventoryRows: const <Map<String, Object?>>[],
      imperativePageContracts: <String, Object?>{
        'OrphanScreen': <String, Object?>{
          'owners': <Map<String, Object?>>[
            <String, Object?>{'family': 'pushed-route'},
          ],
        },
      },
    );

    expect(
      failures,
      contains(contains('has no generated MaterialPageRoute target')),
    );
  });

  test('requires imperative MaterialPageRoute owner reachability', () {
    const owner = DeclarationBinding(
      file: 'lib/feature/owner.dart',
      symbol: 'FeatureOwner',
    );
    final failures = evaluateImperativePageOwnerReachability(
      siteId: 'material-page:lib/feature.dart:1',
      presentationExpression: '(_) => const FeatureScreen()',
      presentationTarget: 'FeatureScreen',
      requiredOwners: const <DeclarationBinding>[owner],
      reachableDeclarations: const <DeclarationBinding>{},
    );

    expect(failures, contains(contains('not reachable')));
    expect(failures, everyElement(contains(screenRouteOwnerBindingCode)));
  });
}

List<String> _evaluateIndirectTabPageOwner(String pageExpression) {
  return evaluateLayoutOwnerContract(
    screenId: 'screen.fixture',
    owner: <String, Object?>{
      'symbol': 'ExampleScreen',
      'family': 'root',
      'expression': 'CatchRootScreenScaffold.withPrimaryRail',
      'bodyGeometry': 'standard',
      'topEdge': 'safe-area',
    },
    declarationSource:
        '''
class ExampleScreen {
  Object build() => CatchRootScreenScaffold.withPrimaryRail(
    body: CatchRootScreenBody.single(
      page: CatchRootScreenPageSpec.scroll(
        page: $pageExpression,
      ),
    ),
  );
}
''',
  );
}
