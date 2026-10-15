import assert from 'node:assert/strict';
import test from 'node:test';
import {hostSectionCompositionProblems} from '../../tool/design/check_host_section_composition.mjs';

for (const recipe of ['contained', 'plain', 'divided']) {
  test(`rejects reintroducing ${recipe} on migrated surfaces`, () => {
    assert.equal(hostSectionCompositionProblems(`CatchSection.${recipe}(child: Column(children: []))`, 'screen.dart').length, 1);
  });
}
test('rejects local empty-state anatomy', () => {
  assert.equal(hostSectionCompositionProblems('CatchEmptyState(message: copy)', 'screen.dart').length, 1);
});
test('allows owned sections, field groups and item actions', () => {
  assert.deepEqual(hostSectionCompositionProblems(`
    CatchSection.collection(children: [], emptyMessage: copy);
    CatchSection.status(title: title, message: copy);
    CatchSection.action(title: title, message: copy);
    CatchSection.fieldRows(children: [CatchField.navigate(content: layout)]);
    CatchSection.containedFieldRows(children: fields);
    CatchButton(label: itemEdit, onPressed: edit);
  `, 'screen.dart'), []);
});
test('ignores comments and string examples and reports the source line', () => {
  const source = `// CatchSection.plain()\n/* CatchEmptyState() */\n'CatchSection.contained()';\nCatchSection.divided();`;
  const problems = hostSectionCompositionProblems(source, 'screen.dart');
  assert.equal(problems.length, 1);
  assert.match(problems[0], /^screen.dart:4:/);
});

test('rejects ad hoc surface/card section stacks', () => {
  for (const symbol of ['CatchSurface', 'CatchSurface.card', 'Card']) assert.equal(hostSectionCompositionProblems(`${symbol}(child: Column(children: []))`, 'screen.dart').length, 1);
});
