import assert from "node:assert/strict";
import test from "node:test";

import storybookConfig from "../.storybook/main.ts";

test("Storybook owns one public copy path and disables inherited Vite publicDir", async () => {
  assert.deepEqual(storybookConfig.staticDirs, ["../public"]);
  assert.equal(typeof storybookConfig.viteFinal, "function");

  const input = {
    publicDir: "public",
    resolve: {alias: {"@catch/test": "/tmp/catch-test"}},
  };
  const resolved = await storybookConfig.viteFinal(input, {
    configType: "PRODUCTION",
  });

  assert.equal(resolved.publicDir, false);
  assert.deepEqual(resolved.resolve, input.resolve);
});
