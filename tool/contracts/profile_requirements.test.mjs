import assert from 'node:assert/strict';
import fs from 'node:fs';
import test from 'node:test';
import {profileRequirementsOutputs} from './generate_schema_contracts.mjs';
const read = (file) => JSON.parse(fs.readFileSync(new URL(`../../contracts/${file}`, import.meta.url)));
const catalog = read('catalogs/profile_requirements.json');
const schema = read('firestore/users.schema.json');

test('all generated clients agree and tracked capability outputs are current', () => {
  const outputs = profileRequirementsOutputs(catalog, schema);
  assert.equal(outputs[0].content, outputs[1].content);
  for (const output of outputs) {
    assert.equal(fs.readFileSync(new URL(`../../${output.path}`, import.meta.url), 'utf8'), output.content);
  }
});

test('following and unrestricted booking do not request social profile information', () => {
  assert.deepEqual(catalog.capabilities.account.required, ['name', 'phoneNumber']);
  for (const capability of ['organizerFollow', 'eventBooking']) {
    assert.equal(catalog.capabilities[capability].extends, 'account');
    assert.deepEqual(catalog.capabilities[capability].required, []);
  }
  assert.deepEqual(catalog.eventRequirements.ageRestricted, ['dateOfBirth']);
  assert.ok(catalog.capabilities.socialDiscovery.required.includes('profilePhotos'));
  assert.ok(catalog.optionalAccountFields.includes('dateOfBirth'));
});

test('invalid references and cyclic inheritance fail generation', () => {
  const cycle = structuredClone(catalog);
  cycle.capabilities.account.extends = 'organizerFollow';
  assert.throws(() => profileRequirementsOutputs(cycle, schema), /inheritance/);
  const unknown = structuredClone(catalog);
  unknown.capabilities.account.required.push('inventedField');
  assert.throws(() => profileRequirementsOutputs(unknown, schema), /Unknown profile field/);
  const contradictory = structuredClone(catalog);
  contradictory.capabilities.account.required.push('dateOfBirth');
  assert.throws(() => profileRequirementsOutputs(contradictory, schema), /Optional account fields/);
});
