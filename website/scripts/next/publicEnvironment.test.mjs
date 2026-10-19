import assert from "node:assert/strict";
import test from "node:test";
import {productionIndexing, validatePublicRuntimeEnvironment} from "../../src/server/publicEnvironment.ts";
test("previews deny indexing and production cannot use fixture/dev readers", () => {
  assert.equal(productionIndexing({}), false);
  assert.equal(productionIndexing({CATCH_WEBSITE_STAGE: "preview"}), false);
  assert.equal(productionIndexing({CATCH_WEBSITE_STAGE: "production"}), true);
  assert.throws(() => validatePublicRuntimeEnvironment({CATCH_WEBSITE_STAGE: "production"}));
  assert.throws(() => validatePublicRuntimeEnvironment({CATCH_WEBSITE_STAGE: "production", CATCH_PUBLIC_FIRESTORE_PROJECT: "catchdates-dev"}));
  assert.throws(() => validatePublicRuntimeEnvironment({CATCH_WEBSITE_STAGE: "production", CATCH_PUBLIC_FIRESTORE_PROJECT: "catch-dating-app-64e51", FIRESTORE_EMULATOR_HOST: "127.0.0.1:8765"}));
  validatePublicRuntimeEnvironment({CATCH_WEBSITE_STAGE: "production", CATCH_PUBLIC_FIRESTORE_PROJECT: "catch-dating-app-64e51"});
});
