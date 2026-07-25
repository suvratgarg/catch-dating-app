import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {
  declaredPackageNamesFromPubspec,
  pluginNamesFromMetadata,
  scanAppPackageGraphs,
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

test("fresh checkouts validate package boundaries without generated Flutter metadata", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-app-graphs-"));
  try {
    for (const [role, dependencies] of Object.entries({
      consumer: ["catch_dating_app", "health", "razorpay_flutter"],
      host: ["catch_dating_app"],
    })) {
      const projectRoot = path.join(root, "apps", role);
      fs.mkdirSync(projectRoot, {recursive: true});
      fs.writeFileSync(
        path.join(projectRoot, "pubspec.yaml"),
        [
          `name: catch_${role}_app`,
          "resolution: workspace",
          "dependencies:",
          ...dependencies.map((name) => `  ${name}: any`),
          "",
        ].join("\n"),
      );
    }

    const result = scanAppPackageGraphs({root});
    assert.deepEqual(result.findings, []);
    assert.equal(
      result.reports.consumer.pluginMetadataSource,
      "declared-policy-plugins",
    );
    assert.equal(result.reports.consumer.hasHealth, true);
    assert.equal(result.reports.host.hasHealth, false);
  } finally {
    fs.rmSync(root, {recursive: true, force: true});
  }
});
