import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/test.dart';

import '../../tool/architecture/check_ui_composition_contracts.dart';

void main() {
  registerDirectRouteFactoryProjectionTests();
  test(
    'imperative identity matches Node generation and ignores source formatting',
    () {
      final identity = imperativePageIdentity(
        sourcePath: 'lib/open.dart',
        presentationExpression: '(_) => const FixtureScreen( )',
        fullscreenDialogExpression: 'true',
      );
      expect(
        identity,
        'lib/open.dart:596bceec245cd3c8ada59e961cbfb7109c76626490ae131dc0fbc54acd8ca79d',
      );
      expect(
        imperativePageIdentity(
          sourcePath: 'lib/open.dart',
          presentationExpression: '(_) => const OtherScreen()',
          fullscreenDialogExpression: 'true',
        ),
        isNot(identity),
      );
      expect(
        imperativePageIdentity(
          sourcePath: 'lib/open.dart',
          presentationExpression: '(_) => const FixtureScreen()',
        ),
        isNot(identity),
      );
    },
  );

  test('screen schema accepts exactly the analyzer layout vocabulary', () {
    final schema =
        jsonDecode(
              File(
                'design/screens/catch.screens.schema.json',
              ).readAsStringSync(),
            )
            as Map<String, Object?>;
    final definitions = (schema[r'$defs'] as Map).cast<String, Object?>();
    final layoutExpression = (definitions['layoutExpression'] as Map)
        .cast<String, Object?>();
    final schemaExpressions = (layoutExpression['enum'] as List<Object?>)
        .cast<String>()
        .toSet();

    expect(schemaExpressions, catchScreenLayoutOwnerExpressions);
  });

  test('canonical layout constructors match the analyzer vocabulary', () {
    expect(
      canonicalLayoutConstructorVocabularyFailures(
        root: Directory.current.absolute.path,
      ),
      isEmpty,
    );
  });

  test('rejects an unregistered public layout constructor', () {
    final failures = canonicalLayoutConstructorVocabularyFailures(
      root: Directory(
        'test/tool/fixtures/layout_constructor_vocabulary',
      ).absolute.path,
    );

    expect(failures, hasLength(1));

    expect(
      failures,
      contains(
        allOf(
          contains(screenLayoutConstructorVocabularyCode),
          contains('CatchRootScreenScaffold.experimental'),
        ),
      ),
    );
  });

  test('accepts a section root with full-width section geometry', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'root',
        'expression': 'CatchRootScreenScaffold.sections',
        'bodyGeometry': 'fullBleed',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchRootScreenScaffold.sections(
    title: const Header(),
    children: const [Rows()],
  );
}
''',
    );

    expect(failures, isEmpty);
  });

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

  test('accepts both standard route-body branches of a conditional', () {
    expect(
      _evaluateRouteBody(
        'loading '
        '? CatchRouteBody.standardViewport(child: Center(child: content)) '
        ': CatchRouteBody.standardConstrained(child: content)',
      ),
      isEmpty,
    );
  });

  test('proves conditional route bodies through local values and helpers', () {
    expect(
      _evaluateRouteBody(
        'body',
        localDeclarations: 'final body = _body(loading);',
        helperDeclarations: '''
  Object _body(bool loading) => switch (loading) {
    true => CatchRouteBody.standardViewport(child: content),
    false => CatchRouteBody.standardConstrained(child: content),
  };
''',
      ),
      isEmpty,
    );
  });

  for (final invalidBody in <String>[
    'CatchRouteBody.fullBleed(child: content)',
    'const SizedBox()',
    'UnknownWrapper(child: CatchRouteBody.standard(child: content))',
    'unknownBody',
    'external.buildBody()',
  ]) {
    for (final invalidFirst in <bool>[true, false]) {
      test('rejects conditional standard route body $invalidBody '
          'in the ${invalidFirst ? 'first' : 'second'} branch', () {
        const standard = 'CatchRouteBody.standard(child: content)';
        final body = invalidFirst
            ? 'loading ? $invalidBody : $standard'
            : 'loading ? $standard : $invalidBody';
        expect(
          _evaluateRouteBody(body),
          contains(contains('CatchRouteBody typed constructor')),
        );
      });
    }
  }

  test('accepts conditional full-bleed route bodies', () {
    expect(
      _evaluateRouteBody(
        'loading ? CatchRouteBody.fullBleed(child: loadingContent) '
        ': CatchRouteBody.fullBleed(child: content)',
        geometry: 'full-bleed',
      ),
      isEmpty,
    );
  });

  test('rejects one standard branch in a full-bleed route', () {
    expect(
      _evaluateRouteBody(
        'loading ? CatchRouteBody.fullBleed(child: loadingContent) '
        ': CatchRouteBody.standard(child: content)',
        geometry: 'full-bleed',
      ),
      contains(contains('CatchRouteBody typed constructor')),
    );
  });

  test('accepts conditional typed geometry in a mixed route', () {
    expect(
      _evaluateRouteBody(
        'loading ? CatchRouteBody.standardViewport(child: content) '
        ': CatchRouteBody.fullBleed(child: content)',
        geometry: 'mixed',
      ),
      isEmpty,
    );
  });

  test('rejects an unknown branch in a mixed route', () {
    expect(
      _evaluateRouteBody(
        'loading ? CatchRouteBody.standardViewport(child: content) '
        ': unknownBody',
        geometry: 'mixed',
      ),
      contains(contains('CatchRouteBody typed constructor')),
    );
  });

  test(
    'retains standard paged-body geometry checks per conditional branch',
    () {
      const prefix =
          'loading ? CatchRouteBody.standardViewport(child: content) : ';
      expect(
        _evaluateRouteBody(
          '${prefix}CatchRouteBody.paged(pages: ['
          'CatchRouteBody.standard(child: content)])',
        ),
        isEmpty,
      );
      expect(
        _evaluateRouteBody(
          '${prefix}CatchRouteBody.paged(pages: ['
          'CatchRouteBody.standard(child: content), '
          'CatchRouteBody.fullBleed(child: content)])',
        ),
        contains(contains('CatchRouteBody typed constructor')),
      );
    },
  );

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
      child: CatchPageBody.screen(
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
          contains('CatchPageBody'),
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
        'expression': 'CatchRootScreenScaffold.standard',
        'bodyGeometry': 'standard',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchRootScreenScaffold.standard(
    children: [
      CatchPageBody.slivers(
        mode: CatchPageBodyMode.standard,
        children: const [SliverToBoxAdapter()],
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
          contains('CatchPageBody'),
          contains('CatchInsets.pageBody'),
        ),
      ),
    );
  });

  test('rejects the former loose ordinary root constructor', () {
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
    bodyLayout: CatchPageBodyMode.standard,
  );
}
''',
    );

    expect(failures, contains(contains('cannot be owned')));
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
        'expression': 'CatchRootScreenScrollView.fullBleed',
        'bodyGeometry': 'full-bleed',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() {
    Object buildMaster() => CatchRootScreenScrollView.fullBleed();

    return CatchScaffold.workspace(body: buildMaster());
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
  Object build() => CatchAsyncBoundary<Object>(
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
          'expression': 'CatchRootScreenScaffold.standard',
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

  test(
    'rejects registry geometry that disagrees with a closed constructor',
    () {
      final failures = evaluateLayoutOwnerContract(
        screenId: 'screen.fixture',
        owner: <String, Object?>{
          'symbol': 'ExampleScreen',
          'family': 'root',
          'expression': 'CatchRootScreenScaffold.fullBleed',
          'bodyGeometry': 'standard',
          'topEdge': 'safe-area',
        },
        declarationSource: '''
class ExampleScreen {
  Object build() => CatchRootScreenScaffold.fullBleed();
}
''',
      );

      expect(
        failures,
        contains(
          contains('must select the matching closed root-screen constructor'),
        ),
      );
    },
  );

  test('accepts one Stack root plane with conditional positioned overlays', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'root',
        'expression': 'CatchRootScreenScaffold.fullBleed',
        'bodyGeometry': 'full-bleed',
        'topEdge': 'header-owned',
      },
      declarationSource: '''
class ExampleScreen {
  Object build(bool showOverlay) => Stack(
    children: [
      CatchRootScreenScaffold.fullBleed(
        topEdge: CatchRootScreenScrollViewPlacement.headerOwned,
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
        'expression': 'CatchRootScreenScaffold.standard',
        'bodyGeometry': 'standard',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => Stack(
    children: [
      CatchRootScreenScaffold.standard(),
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
          children: [
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
            children: [const SliverToBoxAdapter()],
          ),
        ),
        CatchRootScreenPageSpec.scroll(
          page: CatchRootScreenPageScrollView.fullBleed(
            children: [
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
    children: [
      CatchPageBody.sliver(child: const SliverToBoxAdapter()),
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
          contains('CatchPageBody'),
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
        'StandardSemanticPage': 'CatchPageBodyMode.standard',
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
  Object build() => CatchScaffold.stepFlow(
    body: const SizedBox(),
  );
}
''');

    expect(
      instantiations.map((instantiation) => instantiation.signature),
      contains('CatchScaffold.stepFlow'),
    );
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

List<String> _evaluateRouteBody(
  String bodyExpression, {
  String geometry = 'standard',
  String localDeclarations = '',
  String helperDeclarations = '',
}) => evaluateLayoutOwnerContract(
  screenId: 'screen.fixture',
  owner: <String, Object?>{
    'symbol': 'ExampleScreen',
    'family': 'pushed-route',
    'expression': 'CatchRouteScaffold',
    'bodyGeometry': geometry,
    'topEdge': 'route-chrome',
  },
  declarationSource:
      '''
class ExampleScreen {
  Object build(bool loading) {
    $localDeclarations
    return CatchRouteScaffold(body: $bodyExpression);
  }
  $helperDeclarations
}
''',
);

void registerDirectRouteFactoryProjectionTests() {
  group('direct typed route-factory call-through', () {
    late Directory root;
    late AnalysisContextCollection collection;
    late ResolvedUnitResult resolved;

    setUpAll(() async {
      root = Directory.systemTemp.createTempSync('catch_route_factory_');
      void write(String path, String content) {
        final file = File('${root.path}/$path');
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(content);
      }

      write('packages/catch_ui/lib/src/patterns/catch_route_scaffold.dart', '''
class CatchRouteBody {
  const CatchRouteBody.standard({Object? child});
  const CatchRouteBody.standardViewport({Object? child});
  const CatchRouteBody.fullBleed({Object? child});
}
class CatchRouteScaffold {
  const CatchRouteScaffold({required CatchRouteBody body, Object? topBarBuilder});
}
''');
      write('lib/impostor.dart', '''
import '../packages/catch_ui/lib/src/patterns/catch_route_scaffold.dart' as canonical;
class CatchRouteBody extends canonical.CatchRouteBody {
  const CatchRouteBody() : super.standard();
}
canonical.CatchRouteScaffold route({required canonical.CatchRouteBody body}) =>
  canonical.CatchRouteScaffold(body: body);
canonical.CatchRouteScaffold _privateRoute({required canonical.CatchRouteBody body}) =>
  canonical.CatchRouteScaffold(body: body);
class CatchRouteScaffold {
  const CatchRouteScaffold({required canonical.CatchRouteBody body});
}
''');
      write('lib/fixture.dart', _directRouteFactoryFixture);
      collection = AnalysisContextCollection(
        includedPaths: [root.absolute.path],
        sdkPath: analysisDartSdkPath(),
      );
      final result = await collection
          .contextFor('${root.path}/lib/fixture.dart')
          .currentSession
          .getResolvedUnit('${root.path}/lib/fixture.dart');
      expect(result, isA<ResolvedUnitResult>());
      resolved = result as ResolvedUnitResult;
    });
    tearDownAll(() async {
      await collection.dispose();
      root.deleteSync(recursive: true);
    });

    List<String> check(String symbol) {
      final declaration = resolved.unit.declarations
          .whereType<ClassDeclaration>()
          .singleWhere((node) => node.namePart.typeName.lexeme == symbol);
      final source = expandDirectRouteFactoryCallsForOwner(
        root: root.absolute.path,
        result: resolved,
        declaration: declaration,
      );
      return evaluateLayoutOwnerContract(
        screenId: 'screen.factory.fixture',
        owner: <String, Object?>{
          'symbol': symbol,
          'family': 'pushed-route',
          'expression': 'CatchRouteScaffold',
          'bodyGeometry': 'standard',
          'topEdge': 'route-chrome',
        },
        declarationSource: source,
      );
    }

    for (final symbol in ['SameOwnerScreen', 'TopLevelScreen', 'AsyncScreen']) {
      test('proves direct caller bodies for $symbol', () {
        expect(check(symbol), isEmpty);
      });
    }
    for (final symbol in [
      'MixedCallsScreen',
      'ConditionalBodyScreen',
      'UnknownBodyScreen',
      'WrappedBodyScreen',
      'ForeignDescriptorScreen',
      'ForeignHelperScreen',
      'InaccessibleHelperScreen',
      'ForeignScaffoldScreen',
      'ShadowedHelperScreen',
      'InheritedHelperScreen',
      'ConditionalFactoryScreen',
      'IndirectFactoryScreen',
      'RecursiveFactoryScreen',
      'SubstitutedBodyScreen',
      'OptionalBodyScreen',
      'DeadHelperScreen',
      'BehaviorOnlyScreen',
      'NestedFactoryScreen',
    ]) {
      test('fails closed for $symbol', () {
        expect(check(symbol), isNotEmpty);
      });
    }
    for (final symbol in ['NestedPageBodyScreen', 'NestedInsetScreen']) {
      test('retains competing-geometry rejection for $symbol', () {
        expect(
          check(symbol),
          contains(contains('must not nest competing page geometry')),
        );
      });
    }
  });
}

const _directRouteFactoryFixture = r'''
import '../packages/catch_ui/lib/src/patterns/catch_route_scaffold.dart';
import 'impostor.dart' as impostor;

CatchRouteScaffold _sharedRoute({String? title, required CatchRouteBody body}) =>
  CatchRouteScaffold(body: body, topBarBuilder: () => title);
CatchRouteBody wrapBody(CatchRouteBody body) => body;
class CatchAsyncBoundary<T> {
  CatchAsyncBoundary({required Object Function() loadingBuilder,
    required Object Function() errorBuilder, required Object Function() builder});
}
class CatchPageBody { const CatchPageBody.screen({required Object child}); }
class CatchInsets { static const pageBody = Object(); }
class Padding { const Padding({required Object padding, required Object child}); }
class Button { const Button({required Object Function() onTap}); }

class SameOwnerScreen {
  Object build(bool loading) => loading
    ? _route(body: const CatchRouteBody.standardViewport())
    : _route(body: const CatchRouteBody.standard());
  CatchRouteScaffold _route({required CatchRouteBody body}) => CatchRouteScaffold(body: body);
}
class TopLevelScreen {
  Object build() => _sharedRoute(title: 'Title', body: const CatchRouteBody.standard());
}
class AsyncScreen {
  Object build() => CatchAsyncBoundary<Object>(
    loadingBuilder: () => _sharedRoute(body: const CatchRouteBody.standardViewport()),
    errorBuilder: () => _sharedRoute(body: const CatchRouteBody.standardViewport()),
    builder: () => _sharedRoute(body: const CatchRouteBody.standard()),
  );
}
class MixedCallsScreen {
  Object build(bool loading) => loading
    ? _route(body: const CatchRouteBody.standardViewport())
    : _route(body: const CatchRouteBody.fullBleed());
  CatchRouteScaffold _route({required CatchRouteBody body}) => CatchRouteScaffold(body: body);
}
class ConditionalBodyScreen {
  Object build(bool loading) => _sharedRoute(body: loading
    ? const CatchRouteBody.standard() : const CatchRouteBody.fullBleed());
}
class UnknownBodyScreen {
  Object build(CatchRouteBody body) => _sharedRoute(body: body);
}
class WrappedBodyScreen {
  Object build() => _sharedRoute(body: wrapBody(const CatchRouteBody.standard()));
}
class ForeignDescriptorScreen {
  Object build() => _sharedRoute(body: const impostor.CatchRouteBody());
}
class ForeignHelperScreen {
  Object build() => impostor.route(body: const CatchRouteBody.standard());
}
class InaccessibleHelperScreen {
  // Intentionally unresolved cross-library private target must fail closed.
  Object build() => impostor._privateRoute(body: const CatchRouteBody.standard());
}
class ForeignScaffoldScreen {
  Object build() => _route(body: const CatchRouteBody.standard());
  impostor.CatchRouteScaffold _route({required CatchRouteBody body}) =>
    impostor.CatchRouteScaffold(body: body);
}
class ShadowedHelperScreen {
  Object build() {
    CatchRouteScaffold _sharedRoute({required CatchRouteBody body}) =>
      CatchRouteScaffold(body: const CatchRouteBody.fullBleed());
    return _sharedRoute(body: const CatchRouteBody.standard());
  }
}
class ParentFactory {
  CatchRouteScaffold _route({required CatchRouteBody body}) => CatchRouteScaffold(body: body);
}
class InheritedHelperScreen extends ParentFactory {
  Object build() => _route(body: const CatchRouteBody.standard());
}
class ConditionalFactoryScreen {
  bool alternate = false;
  Object build() => _route(body: const CatchRouteBody.standard());
  CatchRouteScaffold _route({required CatchRouteBody body}) => alternate
    ? CatchRouteScaffold(body: body) : CatchRouteScaffold(body: const CatchRouteBody.fullBleed());
}
class IndirectFactoryScreen {
  Object build() => _indirect(body: const CatchRouteBody.standard());
  CatchRouteScaffold _indirect({required CatchRouteBody body}) => _route(body: body);
  CatchRouteScaffold _route({required CatchRouteBody body}) => CatchRouteScaffold(body: body);
}
class RecursiveFactoryScreen {
  Object build() => _route(body: const CatchRouteBody.standard());
  CatchRouteScaffold _route({required CatchRouteBody body}) => _route(body: body);
}
class SubstitutedBodyScreen {
  Object build() => _route(body: const CatchRouteBody.standard());
  CatchRouteScaffold _route({required CatchRouteBody body}) =>
    CatchRouteScaffold(body: const CatchRouteBody.fullBleed());
}
class OptionalBodyScreen {
  Object build() => _route(body: const CatchRouteBody.standard());
  CatchRouteScaffold _route({CatchRouteBody? body}) =>
    CatchRouteScaffold(body: body ?? const CatchRouteBody.fullBleed());
}
class DeadHelperScreen {
  Object build() => Object();
  CatchRouteScaffold _route({required CatchRouteBody body}) => CatchRouteScaffold(body: body);
}
class BehaviorOnlyScreen {
  Object build() => Button(onTap: () => _sharedRoute(body: const CatchRouteBody.standard()));
}
class NestedFactoryScreen {
  Object build() => _sharedRoute(body: CatchRouteBody.standard(
    child: _sharedRoute(body: const CatchRouteBody.standard())));
}
class NestedPageBodyScreen {
  Object build() => _sharedRoute(body: const CatchRouteBody.standard(
    child: CatchPageBody.screen(child: Object())));
}
class NestedInsetScreen {
  Object build() => _sharedRoute(body: const CatchRouteBody.standard(
    child: Padding(padding: CatchInsets.pageBody, child: Object())));
}
''';
