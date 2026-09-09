import 'package:test/test.dart';

import '../../tool/architecture/check_ui_composition_contracts.dart';

void main() {
  for (final body in [
    'CatchPageBody(child: SizedBox())',
    'CatchPageBody.formStep(child: SizedBox())',
    'CatchPageBody.screen(child: SizedBox())',
    'CatchPageBody.sliver(child: SliverToBoxAdapter())',
    'CatchPageBody.slivers(mode: CatchPageBodyMode.standard, children: [SliverToBoxAdapter()])',
  ]) {
    test('$body cannot duplicate a standard route gutter', () {
      expect(
        terminalStandardBodyGeometryConflicts('''
class ExampleScreen {
  Object build() => CatchRouteScaffold(
    body: CatchRouteBody.standard(child: $body),
  );
}
'''),
        isNotEmpty,
      );
    });
  }
  for (final variant in ['scrolling', 'fixed']) {
    test('standalone $variant screen body satisfies its geometry owner', () {
      expect(
        _standalone(
          'CatchPageBody.screen(variant: CatchPageBodyVariant.$variant, child: SizedBox())',
        ),
        isEmpty,
      );
    });
  }
  test('inset-only body cannot replace a standalone screen body', () {
    expect(
      _standalone('CatchPageBody(child: SizedBox())'),
      contains(contains('CatchPageBody.screen')),
    );
  });
}

List<String> _standalone(String body) => evaluateLayoutOwnerContract(
  screenId: 'screen.fixture',
  owner: {
    'symbol': 'ExampleScreen',
    'family': 'standalone',
    'expression': 'CatchScaffold.standalone',
    'bodyGeometry': 'standard',
    'topEdge': 'safe-area',
  },
  declarationSource:
      '''
class ExampleScreen {
  Object build() => CatchScaffold.standalone(body: $body);
}
''',
);
