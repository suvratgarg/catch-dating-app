import assert from 'node:assert/strict';
import test from 'node:test';
import {assertTarget, existing, personas, plan, target} from './live_fixture.mjs';
import {buildRsvpFormDefinition} from './form_definition.mjs';
const journal = () => ({target, receipts: {}});
const form = () => ({...target, organizer: {organizerId: target.organizerId},
  availabilityStatus: 'active', definition: {...buildRsvpFormDefinition(), identityPolicy: 'anonymous'}});

test('five fixed personas complement existing applicants without reusing identity', () => {
  assert.equal(personas.length, 5);
  assert.equal(new Set(personas.map(p => p.answers.email)).size, 5);
  assert.ok(personas.every(p => !existing.includes(p.name)));
  assert.ok(personas.every(p => /@example\.com$/.test(p.answers.email)));
  assert.ok(personas.every(p => /^\+1202555010[4-8]$/.test(p.answers.phone)));
  assert.deepEqual(new Set(['Mumbai','Bangalore','Hyderabad',...personas.map(p=>p.city)]),
    new Set(['Mumbai','Bangalore','Hyderabad','Ahmedabad','Dubai']));
});
test('confirmed receipts are skipped while uncertain writes block replay', () => {
  const value = journal();
  value.receipts.priya = {status: 'submitted', responseId: 'r-1'};
  assert.equal(plan(value)[0].action, 'skip-submitted');
  value.receipts.dev = {status: 'attempting'};
  assert.throws(() => plan(value), /uncertain/);
  assert.throws(() => plan(journal(), 'maya'), /Unknown persona/);
  assert.throws(() => plan({...journal(), target: {...target, formId:'other'}}), /another target/);
});
test('live form scope, version, identity policy and question changes fail closed', () => {
  assert.doesNotThrow(() => assertTarget(form()));
  for (const patch of [{formId:'other'}, {version:3}, {availabilityStatus:'closed'},
    {organizer:{organizerId:'other'}}, {publicFormId:'other'}]) {
    assert.throws(() => assertTarget({...form(), ...patch}), /authorized/);
  }
  const value = form(); value.definition.identityPolicy = 'emailOrPhoneVerified';
  assert.throws(() => assertTarget(value), /authorized/);
  const changed = form(); changed.definition.sections[0].questions.pop();
  assert.throws(() => assertTarget(changed), /contract changed/);
});
