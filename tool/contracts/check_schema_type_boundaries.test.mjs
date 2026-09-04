import assert from "node:assert/strict";
import test from "node:test";
import {schemaRuntimeImportErrors} from "./check_schema_type_boundaries.mjs";

const handler = "functions/src/organizers/organizerContacts.ts";

test("individual generated runtime modules and explicit type imports pass", () => {
  const source = `
    import {validateContact} from "../shared/generated/validators/contact";
    import {personFieldCatalog} from "../shared/generated/catalogs/personFieldCatalog";
    import type {Contact} from "../shared/generated/firestoreAdminTypes";
    export type {Contact} from "../shared/generated/firestoreAdminTypes";
  `;
  assert.deepEqual(schemaRuntimeImportErrors(source, handler), []);
});

test("aggregate runtime imports and re-exports fail the schema boundary", () => {
  for (const source of [
    'import {validateContact} from "../shared/generated/schemaValidators";',
    'export * from "../shared/generated/schemaRegistry.js";',
    'const catalog = require("../shared/generated/schemaRegistry");',
    'const validators = import("../shared/generated/schemaValidators.js");',
  ]) assert.equal(schemaRuntimeImportErrors(source, handler).length, 1, source);
});

test("Admin type imports must explicitly erase their runtime dependency", () => {
  for (const source of [
    'import {Contact} from "../shared/generated/firestoreAdminTypes";',
    'import {type Contact} from "../shared/generated/firestoreAdminTypes";',
    'const types = require("../shared/generated/firestoreAdminTypes");',
  ]) assert.equal(schemaRuntimeImportErrors(source, handler).length, 1, source);
});

test("aggregate inventories remain available to tests and ignore prose", () => {
  const source = 'import * as schemas from "./generated/schemaRegistry";';
  assert.deepEqual(schemaRuntimeImportErrors(source, "functions/src/shared/schemaContracts.test.ts"), []);
  assert.deepEqual(schemaRuntimeImportErrors(source, "functions/src/shared/generated/schemaValidators.ts"), []);
  assert.deepEqual(schemaRuntimeImportErrors('// '+source, handler), []);
});
