import test from "node:test";
import assert from "node:assert/strict";
import {
  buildInventory,
  classifyTest,
  inferTestKind,
  inferTestOwner,
  looksLikeExecutableTest,
  renderInventory,
} from "./test_inventory.mjs";

test("classifies every first-party executable test surface", () => {
  const cases = new Map([
    ["test/auth/login_test.dart", "flutter_unit_widget"],
    ["integration_test/app_shell_test.dart", "flutter_integration"],
    ["apps/consumer/test/health_test.dart", "flutter_consumer_app"],
    ["apps/host/test/app_test.dart", "flutter_host_app"],
    ["functions/src/admin/foo.test.ts", "functions_source"],
    ["functions/test/firestore.rules.test.cjs", "firebase_rules"],
    ["functions/test/callable.test.cjs", "functions_harness"],
    ["admin/src/App.test.tsx", "web_admin"],
    ["website/scripts/postbuild.test.mjs", "web_marketing"],
    ["packages/web-ui/src/button.test.tsx", "web_shared_ui"],
    ["operations/test/workflow.test.mjs", "operations"],
    ["tool/copy/catalog_test.mjs", "tooling"],
    ["tool/copy/catalog.test.mjs", "tooling"],
    ["tool/design/contract_test.dart", "tooling"],
    ["tool/wrapper.test.sh", "tooling"],
  ]);
  for (const [file, category] of cases) {
    assert.equal(looksLikeExecutableTest(file), true, file);
    assert.equal(classifyTest(file), category, file);
  }
  assert.equal(looksLikeExecutableTest("functions/lib/admin/foo.test.js"), false);
  assert.equal(classifyTest("functions/lib/admin/foo.test.js"), null);
  assert.equal(looksLikeExecutableTest("test/support/helpers.dart"), false);
  assert.equal(looksLikeExecutableTest("test/group_tests.dart"), false);
});

test("infers behavioral owner and test kind without mirroring every folder", () => {
  assert.equal(inferTestOwner("test/profile/card_test.dart"), "flutter/user_profile");
  assert.equal(
    inferTestOwner(
      "admin/src/features/safety/controllers/useSafety.test.tsx",
    ),
    "admin/safety",
  );
  assert.equal(
    inferTestKind("test/goldens/card_test.dart"),
    "golden",
  );
});

test("inventory is deterministic and carries lifecycle ownership", () => {
  const inventory = buildInventory(
    ["test/z_test.dart", "test/a_test.dart"],
    {
      lifecycle: {
        exceptionalTests: [
          {
            path: "test/z_test.dart",
            owner: "flutter/special",
            lifecycle: "compatibility",
          },
        ],
      },
    },
  );
  assert.deepEqual(inventory.categories.flutter_unit_widget.files, [
    "test/a_test.dart",
    "test/z_test.dart",
  ]);
  assert.equal(inventory.schemaVersion, 2);
  assert.equal(inventory.entries[1].owner, "flutter/special");
  assert.equal(inventory.entries[1].lifecycle, "compatibility");
  assert.deepEqual(inventory.lifecycle.counts, {
    active: 1,
    compatibility: 1,
  });
  assert.equal(renderInventory(inventory).endsWith("\n"), true);
});

test("known-bad executable test outside the classifier fails closed", () => {
  assert.equal(
    looksLikeExecutableTest("apps/unknown/test/example_test.dart"),
    true,
  );
  assert.throws(
    () =>
      buildInventory(
        ["tool/new/check.spec.ts"],
        {lifecycle: {exceptionalTests: []}},
      ),
    /not classified/u,
  );
});
