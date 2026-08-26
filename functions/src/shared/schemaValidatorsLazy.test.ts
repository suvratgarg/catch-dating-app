import assert from "node:assert/strict";
import test from "node:test";

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
      const validators = await import("./generated/schemaValidators.js");

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
        validators.validateGetOrganizerContactDetailCallablePayload(
          validDetailPayload
        ),
        true
      );
      assert.equal(compileCount, 1);

      assert.equal(
        validators.validateGetOrganizerContactDetailCallablePayload(
          validDetailPayload
        ),
        true
      );
      assert.equal(compileCount, 1, "the same validator must be reused");

      assert.equal(
        validators.validateGetOrganizerContactDetailCallablePayload({}),
        false
      );
      assert.ok(
        (validators.validateGetOrganizerContactDetailCallablePayload.errors
          ?.length ?? 0) > 0,
        "lazy validators must expose Ajv errors"
      );

      assert.equal(
        validators.validateListOrganizerContactsCallablePayload({
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
