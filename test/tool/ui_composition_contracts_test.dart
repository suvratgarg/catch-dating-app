import 'package:flutter_test/flutter_test.dart';

import '../../tool/architecture/check_ui_composition_contracts.dart';

void main() {
  test('flags a nested scaffold on a shell-reachable screen', () {
    final result = evaluateSourceContract(_screen(), '''
class ExampleScreen {
  Object build() => Scaffold(body: Content());
}
''');

    expect(result.hardFailures, isEmpty);
    expect(result.findings, hasLength(1));
    expect(result.findings.single['code'], screenNestedScaffoldCode);
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

    expect(
      result.hardFailures,
      contains(contains(screenTopBarConformanceCode)),
    );
  });
}

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
