import assert from "node:assert/strict";
import test from "node:test";
import {createRequire} from "node:module";

import Ajv, {AnySchema} from "ajv";

test(
  "generated schema validators compile lazily and cache per schema",
  async () => {
    const originalCompile = Ajv.prototype.compile;
    let compileCount = 0;
    Ajv.prototype.compile = function(
      this: Ajv,
      schema: AnySchema,
      meta?: boolean
    ) {
      compileCount += 1;
      return originalCompile.call(this, schema, meta);
    } as typeof originalCompile;

    try {
      const runtimeRequire = createRequire(__filename);
      const before = new Set(Object.keys(runtimeRequire.cache));
      const detail = await import(
        "./generated/validators/getOrganizerContactDetailInput.js"
      );
      const loadedSchemas = Object.keys(runtimeRequire.cache).filter((file) =>
        !before.has(file) && file.includes("/generated/schemas/")
      );
      assert.deepEqual(loadedSchemas, [runtimeRequire.resolve(
        "./generated/schemas/getOrganizerContactDetailInput.js"
      )], "loading one validator must load only its own schema");
      assert.ok(!Object.keys(runtimeRequire.cache).some((file) =>
        /\/generated\/schema(?:Registry|Validators)\.js$/.test(file)
      ), "individual validators must not load aggregate registries");

      assert.equal(
        compileCount,
        0,
        "module import must not compile every schema"
      );

      const validDetailPayload = {
        organizerId: "organizer-1",
        contactId: "contact-1",
      };
      assert.equal(
        detail.validateGetOrganizerContactDetailCallablePayload(
          validDetailPayload
        ),
        true
      );
      assert.equal(compileCount, 1);

      assert.equal(
        detail.validateGetOrganizerContactDetailCallablePayload(
          validDetailPayload
        ),
        true
      );
      assert.equal(compileCount, 1, "the same validator must be reused");

      assert.equal(
        detail.validateGetOrganizerContactDetailCallablePayload({}),
        false
      );
      assert.ok(
        (detail.validateGetOrganizerContactDetailCallablePayload.errors
          ?.length ?? 0) > 0,
        "lazy validators must expose Ajv errors"
      );

      const list = await import(
        "./generated/validators/listOrganizerContactsInput.js"
      );
      assert.equal(
        list.validateListOrganizerContactsCallablePayload({
          organizerId: "organizer-1",
        }),
        true
      );
      assert.equal(compileCount, 2, "a second schema compiles independently");
    } finally {
      Ajv.prototype.compile = originalCompile;
    }
  }
);
