import 'dart:io';

import 'package:test/test.dart';

import '../../tool/architecture/check_ui_composition_contracts.dart';

void main() {
  test('flags raw Scaffold ownership', () {
    final lines = rawScaffoldLines('''
class ExampleScreen {
  Object build() => Scaffold(body: Content());
}
''');

    expect(lines, <int>[2]);
  });

  test(
    'analyzer rejects prefixed, aliased, direct, and indirect Scaffold ownership',
    () async {
      final sdkPath = analysisDartSdkPath();
      expect(File('$sdkPath/bin/dart').existsSync(), isTrue);
      expect(
        Directory('$sdkPath/lib/_internal').existsSync(),
        isTrue,
        reason: 'resolved analyzer SDK: $sdkPath',
      );
      final failures = await resolveScaffoldOwnershipFailuresForFile(
        root: Directory.current.absolute.path,
        relativePath: 'test/tool/fixtures/scaffold_ownership_fixture.dart',
      );

      expect(failures, contains(contains('construction resolves')));
      expect(failures, contains(contains('type alias resolves')));
      expect(failures, contains(contains('constructor tear-off resolves')));
      expect(
        failures.where(
          (failure) => failure.contains('subclasses Flutter Scaffold'),
        ),
        hasLength(2),
      );
      expect(failures, everyElement(contains(screenScaffoldOwnershipCode)));
    },
  );

  test('analysis contexts own root, Consumer, and Host production sources', () {
    final failures = analysisContextMembershipFailures(
      root: Directory.current.absolute.path,
      relativePaths: const <String>[
        'lib/app.dart',
        'apps/consumer/lib/consumer_platform_app.dart',
        'apps/host/lib/host_platform_app.dart',
      ],
    );

    expect(failures, isEmpty);
  });

  group('resolved layout terminal traversal', () {
    late Directory fixtureRoot;

    setUpAll(() {
      fixtureRoot = Directory.systemTemp.createTempSync(
        'catch_layout_terminal_',
      );
      final fixture = File('${fixtureRoot.path}/lib/fixture.dart');
      fixture.parent.createSync(recursive: true);
      fixture.writeAsStringSync(_resolvedLayoutTerminalFixture);
    });

    tearDownAll(() {
      fixtureRoot.deleteSync(recursive: true);
    });

    test(
      'follows Widget constructors, createState, State.build, and Widget methods',
      () async {
        final valid = await resolvedLayoutOwnerOnEveryBranch(
          root: fixtureRoot.path,
          relativePath: 'lib/fixture.dart',
          symbol: 'ResolvedRootScreen',
          acceptedSignatures: const <String>{'CatchRootScreenScaffold'},
        );

        expect(valid, isTrue);
      },
    );

    test('accepts an exact separately registered terminal owner', () async {
      final valid = await resolvedLayoutOwnerOnEveryBranch(
        root: fixtureRoot.path,
        relativePath: 'lib/fixture.dart',
        symbol: 'RegisteredDelegateScreen',
        acceptedSignatures: const <String>{'CatchRootScreenScaffold'},
        acceptedOwnerBindings: <DeclarationBinding>{
          const DeclarationBinding(
            file: 'lib/fixture.dart',
            symbol: 'RegisteredRootOwner',
          ),
        },
      );

      expect(valid, isTrue);
    });

    test('follows generic widget-builder wrappers', () async {
      final valid = await resolvedLayoutOwnerOnEveryBranch(
        root: fixtureRoot.path,
        relativePath: 'lib/fixture.dart',
        symbol: 'GenericBuilderWrapperScreen',
        acceptedSignatures: const <String>{'CatchRootScreenScaffold'},
      );

      expect(valid, isTrue);
    });

    test('rejects a rogue adapter branch', () async {
      final valid = await resolvedLayoutOwnerOnEveryBranch(
        root: fixtureRoot.path,
        relativePath: 'lib/fixture.dart',
        symbol: 'RogueAdapterScreen',
        acceptedSignatures: const <String>{'CatchRootScreenScaffold'},
      );

      expect(valid, isFalse);
    });

    test('rejects unresolved and external adapter terminals', () async {
      final unresolved = await resolvedLayoutOwnerOnEveryBranch(
        root: fixtureRoot.path,
        relativePath: 'lib/fixture.dart',
        symbol: 'UnresolvedAdapterScreen',
        acceptedSignatures: const <String>{'CatchRootScreenScaffold'},
      );
      final external = await resolvedLayoutOwnerOnEveryBranch(
        root: fixtureRoot.path,
        relativePath: 'lib/fixture.dart',
        symbol: 'ExternalAdapterScreen',
        acceptedSignatures: const <String>{'CatchRootScreenScaffold'},
      );

      expect(unresolved, isFalse);
      expect(external, isFalse);
    });

    test('rejects a mixed-family adapter terminal', () async {
      final valid = await resolvedLayoutOwnerOnEveryBranch(
        root: fixtureRoot.path,
        relativePath: 'lib/fixture.dart',
        symbol: 'MixedFamilyScreen',
        acceptedSignatures: const <String>{'CatchRootScreenScaffold'},
      );

      expect(valid, isFalse);
    });

    test('rejects cyclic Widget adapter graphs', () async {
      final valid = await resolvedLayoutOwnerOnEveryBranch(
        root: fixtureRoot.path,
        relativePath: 'lib/fixture.dart',
        symbol: 'CyclicAdapterScreen',
        acceptedSignatures: const <String>{'CatchRootScreenScaffold'},
      );

      expect(valid, isFalse);
    });
  });

  test('requires the registered top-bar expression', () {
    final screen = _screen();
    screen['topBar'] = <String, Object?>{
      'role': 'compact',
      'expression': 'CatchTopBar',
      'owner': 'CatchTopBar',
      'reason': 'fixture',
    };

    final result = evaluateSourceContract(screen, 'class ExampleScreen {}');

    expect(result, contains(contains(screenTopBarConformanceCode)));
  });

  test('rejects an owner outside the registered layout family', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'root',
        'expression': 'CatchRouteScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'safe-area',
      },
      declarationSource:
          'class ExampleScreen { CatchRouteScaffold build() => const CatchRouteScaffold(body: SizedBox()); }',
    );

    expect(failures, contains(contains(screenLayoutFamilyCode)));
  });

  test('requires header-owned roots to declare their top edge', () {
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
  Object build() => CatchRootScreenScaffold(
    bodyLayout: CatchScreenBodyLayout.fullBleed,
  );
}
''',
    );

    expect(failures, contains(contains('CatchRootScreenTopEdge.headerOwned')));
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
        'family': 'tabbed-root',
        'expression': 'CatchTabbedScreenScaffold',
        'bodyGeometry': 'mixed',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchTabbedScreenScaffold(
    body: CatchTabbedScreenBody.single(
      page: CatchTabbedPageSpec.scroll(
        bodyLayout: CatchScreenBodyLayout.fullBleed,
        page: FullBleedPage(),
      ),
    ),
  );

  Object deadPage() => CatchTabbedPageSpec.scroll(
    bodyLayout: CatchScreenBodyLayout.standard,
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
        'family': 'tabbed-root',
        'expression': 'CatchTabbedScreenScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build(bool loading) => CatchTabbedScreenScaffold(
    body: _body(loading),
  );

  Object _body(bool loading) => switch (loading) {
    true => CatchTabbedScreenBody.single(
      page: CatchTabbedPageSpec.scroll(
        bodyLayout: CatchScreenBodyLayout.standard,
        page: CatchTabbedPageScrollView(
          bodyLayout: CatchScreenBodyLayout.standard,
        ),
      ),
    ),
    false => CatchTabbedScreenBody.paged(
      pages: [
        CatchTabbedPageSpec.scroll(
          bodyLayout: CatchScreenBodyLayout.standard,
          page: CatchTabbedPageScrollView(
            bodyLayout: CatchScreenBodyLayout.standard,
          ),
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
        'family': 'tabbed-root',
        'expression': 'CatchTabbedScreenScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build(bool rogue) => CatchTabbedScreenScaffold(
    body: _body(rogue),
  );

  Object _body(bool rogue) => rogue
      ? const LegacyTabbedBody()
      : CatchTabbedScreenBody.single(
          page: CatchTabbedPageSpec.scroll(
            bodyLayout: CatchScreenBodyLayout.standard,
            page: CatchTabbedPageScrollView(
              bodyLayout: CatchScreenBodyLayout.standard,
            ),
          ),
        );
}
''',
    );

    expect(failures, contains(contains('tabbed-root bodies must use')));
  });

  test('rejects an unresolved tab body helper', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'tabbed-root',
        'expression': 'CatchTabbedScreenScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchTabbedScreenScaffold(
    body: external.buildBody(),
  );
}
''',
    );

    expect(failures, contains(contains('tabbed-root bodies must use')));
  });

  test('rejects a semantic tab page owner that lies about its role', () {
    final failures = evaluateTabbedPageOwnerContract(
      symbol: 'LyingPageOwner',
      declarationSource: '''
class LyingPageOwner implements CatchTabbedPageOwner {
  CatchScreenBodyLayout get bodyLayout => CatchScreenBodyLayout.standard;

  Object build() => CatchTabbedPageScrollView(
    bodyLayout: CatchScreenBodyLayout.fullBleed,
  );

  Object deadHelper() => CatchTabbedPageScrollView(
    bodyLayout: CatchScreenBodyLayout.standard,
  );
}
''',
    );

    expect(failures, contains(contains('must forward its declared')));
  });

  test('rejects a rogue semantic tab page return branch', () {
    final failures = evaluateTabbedPageOwnerContract(
      symbol: 'BranchingPageOwner',
      declarationSource: '''
class BranchingPageOwner implements CatchTabbedPageOwner {
  CatchScreenBodyLayout get bodyLayout => CatchScreenBodyLayout.standard;

  Object build(bool rogue) {
    if (rogue) return const SizedBox();
    return CatchTabbedPageScrollView(bodyLayout: bodyLayout);
  }
}
''',
    );

    expect(
      failures,
      contains(contains('every semantic tab page owner build/return terminal')),
    );
  });

  test('rejects an inline tab page whose role disagrees with its spec', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'tabbed-root',
        'expression': 'CatchTabbedScreenScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchTabbedScreenScaffold(
    body: CatchTabbedScreenBody.single(
      page: CatchTabbedPageSpec.scroll(
        bodyLayout: CatchScreenBodyLayout.standard,
        page: CatchTabbedPageScrollView(
          bodyLayout: CatchScreenBodyLayout.fullBleed,
        ),
      ),
    ),
  );
}
''',
    );

    expect(failures, contains(contains('must match its CatchTabbedPageSpec')));
  });

  test('rejects nested page geometry inside an inline standard tab page', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'tabbed-root',
        'expression': 'CatchTabbedScreenScaffold',
        'bodyGeometry': 'standard',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchTabbedScreenScaffold(
    body: CatchTabbedScreenBody.single(
      page: CatchTabbedPageSpec.scroll(
        bodyLayout: CatchScreenBodyLayout.standard,
        page: CatchTabbedPageScrollView(
          bodyLayout: CatchScreenBodyLayout.standard,
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
          contains('standard tab page content'),
          contains('CatchInsets.pageBody'),
        ),
      ),
    );
  });

  test('does not inspect deliberate full-bleed tab page geometry', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'tabbed-root',
        'expression': 'CatchTabbedScreenScaffold',
        'bodyGeometry': 'mixed',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchTabbedScreenScaffold(
    body: CatchTabbedScreenBody.paged(
      pages: [
        CatchTabbedPageSpec.scroll(
          bodyLayout: CatchScreenBodyLayout.standard,
          page: CatchTabbedPageScrollView(
            bodyLayout: CatchScreenBodyLayout.standard,
            slivers: [const SliverToBoxAdapter()],
          ),
        ),
        CatchTabbedPageSpec.scroll(
          bodyLayout: CatchScreenBodyLayout.fullBleed,
          page: CatchTabbedPageScrollView(
            bodyLayout: CatchScreenBodyLayout.fullBleed,
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
    final failures = evaluateTabbedPageOwnerContract(
      symbol: 'SemanticPageOwner',
      declarationSource: '''
class SemanticPageOwner implements CatchTabbedPageOwner {
  CatchScreenBodyLayout get bodyLayout => CatchScreenBodyLayout.standard;

  Object build() => CatchTabbedPageScrollView(
    bodyLayout: bodyLayout,
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
          contains('semantic tab page content'),
          contains('CatchSliverPageBody'),
        ),
      ),
    );
  });

  test('rejects a semantic tab page whose role disagrees with its spec', () {
    final failures = evaluateLayoutOwnerContract(
      screenId: 'screen.fixture',
      owner: <String, Object?>{
        'symbol': 'ExampleScreen',
        'family': 'tabbed-root',
        'expression': 'CatchTabbedScreenScaffold',
        'bodyGeometry': 'full-bleed',
        'topEdge': 'safe-area',
      },
      declarationSource: '''
class ExampleScreen {
  Object build() => CatchTabbedScreenScaffold(
    body: CatchTabbedScreenBody.single(
      page: CatchTabbedPageSpec.scroll(
        bodyLayout: CatchScreenBodyLayout.fullBleed,
        page: StandardSemanticPage(),
      ),
    ),
  );
}
''',
      semanticTabbedPageOwnerRoles: const <String, String>{
        'StandardSemanticPage': 'CatchScreenBodyLayout.standard',
      },
    );

    expect(
      failures,
      contains(contains('semantic CatchTabbedPageOwner must match')),
    );
  });

  test('rejects a tab page hidden behind an unresolved variable', () {
    final failures = _evaluateIndirectTabPageOwner('someVariable');

    expect(failures, contains(contains('must resolve directly')));
  });

  test('rejects a tab page hidden behind an unresolved helper', () {
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
      'family': 'tabbed-root',
      'expression': 'CatchTabbedScreenScaffold',
      'bodyGeometry': 'standard',
      'topEdge': 'safe-area',
    },
    declarationSource:
        '''
class ExampleScreen {
  Object build() => CatchTabbedScreenScaffold(
    body: CatchTabbedScreenBody.single(
      page: CatchTabbedPageSpec.scroll(
        bodyLayout: CatchScreenBodyLayout.standard,
        page: $pageExpression,
      ),
    ),
  );
}
''',
  );
}

const _resolvedLayoutTerminalFixture = r'''
abstract class Widget {}

abstract class StatelessWidget extends Widget {
  Widget build();
}

abstract class StatefulWidget extends Widget {
  State createState();
}

abstract class State extends Widget {
  Widget build();
}

class CatchRootScreenScaffold extends Widget {}
class CatchRouteScaffold extends Widget {}
class SizedBox extends Widget {}

class ResolvedRootScreen extends StatelessWidget {
  Widget build() => ResolvedStatefulAdapter();
}

class ResolvedStatefulAdapter extends StatefulWidget {
  State createState() => ResolvedStatefulAdapterState();
}

class ResolvedStatefulAdapterState extends State {
  Widget build() => _buildRoot();
  Widget _buildRoot() => CatchRootScreenScaffold();
}

class RegisteredDelegateScreen extends StatelessWidget {
  Widget build() => RegisteredRootOwner();
}

class RegisteredRootOwner extends Widget {}

class CatchAsyncValueView<T> extends Widget {
  CatchAsyncValueView({
    required Widget Function() loadingBuilder,
    required Widget Function(T) builder,
  });
}

class GenericBuilderWrapperScreen extends StatelessWidget {
  Widget build() => CatchAsyncValueView<int>(
    loadingBuilder: () => CatchRootScreenScaffold(),
    builder: (_) => CatchRootScreenScaffold(),
  );
}

class RogueAdapterScreen extends StatelessWidget {
  Widget build() => RogueAdapter();
}

class RogueAdapter extends StatelessWidget {
  bool rogue = false;

  Widget build() => rogue
      ? CatchRootScreenScaffold()
      : SizedBox();
}

class UnresolvedAdapterScreen extends StatelessWidget {
  Widget build() => missingOwner();
}

class ExternalAdapterScreen extends StatelessWidget {
  Widget build() => Object() as dynamic;
}

class MixedFamilyScreen extends StatelessWidget {
  Widget build() => MixedFamilyAdapter();
}

class MixedFamilyAdapter extends StatelessWidget {
  Widget build() => CatchRouteScaffold();
}

class CyclicAdapterScreen extends StatelessWidget {
  Widget build() => CyclicAdapterA();
}

class CyclicAdapterA extends StatelessWidget {
  Widget build() => CyclicAdapterB();
}

class CyclicAdapterB extends StatelessWidget {
  Widget build() => CyclicAdapterA();
}
''';

Map<String, Object?> _screen() => <String, Object?>{
  'id': 'screen.fixture',
  'source': <String, Object?>{
    'file': 'lib/fixture.dart',
    'symbol': 'ExampleScreen',
  },
  'shell': <String, Object?>{
    'owner': 'consumer',
    'nestedScaffoldAllowed': false,
    'reason': 'fixture',
  },
  'topBar': <String, Object?>{
    'role': 'shell',
    'expression': 'shell-owned',
    'owner': 'CatchAdaptiveTabScaffold',
    'reason': 'fixture',
  },
  'statePolicy': <String, Object?>{
    'requiredStates': <String>['data'],
    'owner': 'fixture',
  },
  'states': <Map<String, Object?>>[
    <String, Object?>{'kind': 'populated'},
  ],
};
