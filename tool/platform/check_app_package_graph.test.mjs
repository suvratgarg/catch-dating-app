import assert from "node:assert/strict";
import test from "node:test";

import {
  declaredPackageNamesFromPubspec,
  pluginNamesFromMetadata,
  validateRoleGraph,
} from "./check_app_package_graph.mjs";

test("parses direct package declarations and plugin metadata", () => {
  const declaredPackages = declaredPackageNamesFromPubspec(
    "dependencies:\n  flutter:\n    sdk: flutter\n  health: ^13.3.1\ndev_dependencies:\n  test: any\n",
  );
  const pluginPackages = pluginNamesFromMetadata(
    JSON.stringify({
      plugins: {
        ios: [{name: "health"}],
        android: [{name: "razorpay_flutter"}],
      },
    }),
  );
  assert.deepEqual([...declaredPackages].sort(), ["flutter", "health"]);
  assert.deepEqual([...pluginPackages].sort(), ["health", "razorpay_flutter"]);
});

test("rejects consumer SDKs in the Host graph", () => {
  assert.deepEqual(
    validateRoleGraph({
      role: "host",
      declaredPackages: new Set(["health", "path"]),
      pluginPackages: new Set(["health"]),
    }),
    [
      "host: forbidden package 'health' is present.",
      "host: forbidden native plugin 'health' is present.",
    ],
  );
});
