import assert from 'node:assert/strict';
import test from 'node:test';
import {renderDartDomainFile} from './generate_domain_classes.mjs';

const spec = {
  schema: 'fixture.schema.json', output: 'event.dart', className: 'Event',
  classes: [{name: 'Event', requiredPointer: '/allOf/0/else/required', fields: [
    {name: 'organizerId', dartType: 'String'},
    {name: 'title', dartType: 'String'},
    {name: 'description', dartType: 'String'},
  ]}],
};
const schema = () => ({type: 'object', required: ['organizerId'], properties: {
  organizerId: {type: 'string'}, title: {type: 'string'},
  description: {type: ['string', 'null']},
}, allOf: [{else: {required: ['title', 'description']}}]});

test('published projection preserves root required fields and branch nullability', () => {
  const value = schema();
  const source = renderDartDomainFile(spec, value, value);
  assert.match(source, /required String organizerId/);
  assert.match(source, /required String title/);
  assert.match(source, /String\? description/);
  value.allOf[0].else.required = [];
  assert.match(renderDartDomainFile(spec, value, value), /String\? title/);
});

test('removed contract field fails generation instead of retaining a stale DTO', () => {
  const value = schema();
  delete value.properties.title;
  assert.throws(() => renderDartDomainFile(spec, value, value), /declared field "title"/);
});

test('reserved Dart enum names keep their schema wire value', () => {
  const value = schema();
  value.properties.kind = {enum: ['stop', 'break', 'finish']};
  const source = renderDartDomainFile({...spec, enums: [{
    name: 'Kind', schemaPointer: '/properties/kind', renames: {break: 'breakTime'},
  }]}, value, value);
  assert.match(source, /@JsonValue\('break'\)\n  breakTime/);
});
