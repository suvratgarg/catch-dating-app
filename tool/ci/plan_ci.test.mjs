import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {
  planCi,
  validateCiPlanning,
  writeGithubOutputs,
} from "./plan_ci.mjs";

const manifest = JSON.parse(
  fs.readFileSync("tool/repository_root_manifest.json", "utf8"),
);
const planning = manifest.ciPlanning;

test("CI planning contract is internally valid", () => {
  assert.deepEqual(validateCiPlanning(planning), []);
});

test("admin-only changes do not invoke Flutter or mobile releases", () => {
  const plan = planCi({
    changedPaths: ["admin/src/features/intake/OrganizerIntake.tsx"],
    ciPlanning: planning,
  });
  assert.equal(plan.enabled.admin, true);
  assert.equal(plan.enabled.flutter, false);
  assert.equal(plan.enabled.flutter_build_ios, false);
  assert.deepEqual(plan.mobileReleaseRoles, []);
  assert.equal(plan.backendDeployRequired, false);
  assert.deepEqual(plan.unmatchedPaths, []);
});

test("host-only app source selects Host mobile work", () => {
  const plan = planCi({
    changedPaths: ["lib/hosts/presentation/host_home_screen.dart"],
    ciPlanning: planning,
  });
  assert.equal(plan.enabled.flutter, true);
  assert.equal(plan.enabled.flutter_build_ios, true);
  assert.deepEqual(plan.appRoles, ["host"]);
  assert.deepEqual(plan.mobileReleaseRoles, ["host"]);
});

test("independent app package roots select only their owning role", () => {
  const hostPlan = planCi({
    changedPaths: ["apps/host/ios/Runner/Info.plist"],
    ciPlanning: planning,
  });
  assert.deepEqual(hostPlan.appRoles, ["host"]);
  assert.deepEqual(hostPlan.mobileReleaseRoles, ["host"]);

  const consumerPlan = planCi({
    changedPaths: ["apps/consumer/lib/razorpay_checkout_adapter.dart"],
    ciPlanning: planning,
  });
  assert.deepEqual(consumerPlan.appRoles, ["consumer"]);
  assert.deepEqual(consumerPlan.mobileReleaseRoles, ["consumer"]);
});

test("shared Flutter source selects both mobile roles", () => {
  const plan = planCi({
    changedPaths: ["lib/core/config/app_config.dart"],
    ciPlanning: planning,
  });
  assert.deepEqual(plan.mobileReleaseRoles, ["consumer", "host"]);
});

test("mobile build control changes rebuild both installable roles", () => {
  for (const changedPath of [
    "tool/app_targets.json",
    "tool/env/dart_defines/prod.json",
    "tool/platform/configure_apple_flavors.rb",
  ]) {
    const plan = planCi({changedPaths: [changedPath], ciPlanning: planning});
    assert.equal(plan.enabled.tools, true, changedPath);
    assert.equal(plan.enabled.flutter_build_android, true, changedPath);
    assert.equal(plan.enabled.flutter_build_ios, true, changedPath);
    assert.deepEqual(plan.mobileReleaseRoles, ["consumer", "host"], changedPath);
  }
});

test("role and platform Firebase metadata selects only its owning build", () => {
  const hostPlan = planCi({
    changedPaths: ["firebase/prod/host/ios/GoogleService-Info.plist"],
    ciPlanning: planning,
  });
  assert.equal(hostPlan.enabled.flutter_build_ios, true);
  assert.equal(hostPlan.enabled.flutter_build_android, false);
  assert.deepEqual(hostPlan.mobileReleaseRoles, ["host"]);

  const consumerPlan = planCi({
    changedPaths: ["firebase/dev/android/google-services.json"],
    ciPlanning: planning,
  });
  assert.equal(consumerPlan.enabled.flutter_build_android, true);
  assert.equal(consumerPlan.enabled.flutter_build_ios, false);
  assert.deepEqual(consumerPlan.mobileReleaseRoles, ["consumer"]);
});

test("contracts validate consumers without authorizing store mutation", () => {
  const plan = planCi({
    changedPaths: ["contracts/firestore/users.schema.json"],
    ciPlanning: planning,
  });
  assert.equal(plan.enabled.contracts, true);
  assert.equal(plan.enabled.functions, true);
  assert.equal(plan.enabled.flutter, true);
  assert.deepEqual(plan.mobileReleaseRoles, []);
  assert.equal(plan.backendDeployRequired, true);
});

test("generated schema bindings validate Flutter without platform builds or store releases", () => {
  for (const changedPath of [
    "lib/core/schema_contracts/generated/schemas/admin_record_event_intake_review_decision_callable_payload.g.dart",
    "lib/core/schema_contracts/generated/schemas/event_intake_review_decision_document.g.dart",
    "lib/core/schema_contracts/generated/schemas/operation_work_item.g.dart",
  ]) {
    const plan = planCi({changedPaths: [changedPath], ciPlanning: planning});
    assert.equal(plan.pathMatches[changedPath], "generated-schema-contract-bindings");
    assert.equal(plan.enabled.flutter, true);
    assert.equal(plan.enabled.flutter_build_android, false);
    assert.equal(plan.enabled.flutter_build_ios, false);
    assert.equal(plan.enabled.flutter_build_web, false);
    assert.deepEqual(plan.mobileReleaseRoles, []);
    assert.equal(plan.backendDeployRequired, false);
  }
});

test("backend validation and Firebase deploy authorization are independent", () => {
  const controlPlanePlan = planCi({
    changedPaths: [".github/workflows/ci.yml"],
    ciPlanning: planning,
  });
  assert.equal(controlPlanePlan.enabled.functions, true);
  assert.equal(controlPlanePlan.enabled.firestore_rules, true);
  assert.equal(controlPlanePlan.backendDeployRequired, false);

  for (const changedPath of [
    "functions/src/index.ts",
    "firestore.rules",
    "contracts/firestore/users.schema.json",
    "firebase.json",
  ]) {
    const plan = planCi({changedPaths: [changedPath], ciPlanning: planning});
    assert.equal(plan.backendDeployRequired, true, changedPath);
  }
});

test("documentation changes use lightweight repository and derived-state lanes", () => {
  const plan = planCi({
    changedPaths: ["docs/release_operations.md"],
    ciPlanning: planning,
  });
  assert.equal(plan.enabled.tools, true);
  assert.equal(plan.enabled.doc_state, true);
  assert.equal(plan.enabled.flutter, false);
});

test("full mode selects every validation target but no store release role", () => {
  const plan = planCi({changedPaths: [], ciPlanning: planning, full: true});
  assert.ok(Object.values(plan.enabled).every(Boolean));
  assert.deepEqual(plan.appRoles, ["consumer", "host"]);
  assert.deepEqual(plan.mobileReleaseRoles, []);
});

test("unknown paths fail closed", () => {
  const plan = planCi({
    changedPaths: ["unowned/example.txt"],
    ciPlanning: planning,
  });
  assert.deepEqual(plan.unmatchedPaths, ["unowned/example.txt"]);
});

test("GitHub outputs stay bounded for large monorepo diffs", () => {
  const plan = planCi({
    changedPaths: Array.from(
      {length: 5000},
      (_, index) => `admin/src/generated/file_${index}.tsx`,
    ),
    ciPlanning: planning,
  });
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-ci-plan-"));
  const outputPath = path.join(directory, "github-output.txt");
  try {
    writeGithubOutputs(outputPath, plan);
    const output = fs.readFileSync(outputPath, "utf8");
    assert.ok(output.length < 4096);
    assert.doesNotMatch(output, /file_4999/);
    assert.doesNotMatch(output, /^plan=/m);
  } finally {
    fs.rmSync(directory, {recursive: true, force: true});
  }
});

test("reusable fanout workflows do not cancel sibling lanes", () => {
  for (const workflow of [
    ".github/workflows/app-build-matrix.yml",
    ".github/workflows/flutter-ci.yml",
    ".github/workflows/operations-ci.yml",
    ".github/workflows/tools-ci.yml",
    ".github/workflows/visual-integration-ci.yml",
  ]) {
    const source = fs.readFileSync(workflow, "utf8");
    assert.doesNotMatch(
      source,
      /^concurrency:\s*\n\s+group:.*github\.workflow/m,
      `${workflow} must inherit concurrency from the CI orchestrator; in a called workflow github.workflow is the caller name, so sibling lanes otherwise cancel one another`,
    );
  }
});
