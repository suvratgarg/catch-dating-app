import 'package:test/test.dart';

import '../../tool/architecture/check_ui_composition_contracts.dart';

void main() {
  for (final recipe in {
    'page': 'CatchSectionList.page(items: [], emptyStateOmitted: true)',
    'default inset':
        'CatchSectionList.inset(children: [], emptyStateOmitted: true)',
  }.entries) {
    test('section ${recipe.key} cannot duplicate standard route geometry', () {
      expect(_conflicts(recipe.value), isNotEmpty);
    });
  }
  for (final recipe in {
    'plain': 'CatchSectionList(children: [], emptyStateOmitted: true)',
    'responsive':
        'CatchSectionList.responsive(items: [], emptyStateOmitted: true)',
    'zero inset':
        'CatchSectionList.inset(padding: EdgeInsets.zero, children: [], emptyStateOmitted: true)',
  }.entries) {
    test('section ${recipe.key} preserves the standard route gutter owner', () {
      expect(_conflicts(recipe.value), isEmpty);
    });
  }
}

List<String> _conflicts(String child) =>
    terminalStandardBodyGeometryConflicts('''
class ExampleScreen {
  Object build() => CatchRouteScaffold(
    body: CatchRouteBody.standard(child: $child),
  );
}
''');
