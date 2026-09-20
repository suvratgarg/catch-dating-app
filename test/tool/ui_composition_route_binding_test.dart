import 'package:test/test.dart';

import '../../tool/architecture/check_ui_composition_contracts.dart';

void main() {
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
