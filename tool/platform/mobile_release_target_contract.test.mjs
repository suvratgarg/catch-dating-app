import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

import {
  planAffected,
  validateComponentGraph,
} from "../harness/lib/component_graph.mjs";

const graph = JSON.parse(
  fs.readFileSync(new URL("../harness/component_graph.json", import.meta.url), "utf8"),
);
const signedTargets = new Set([
  "consumer-android",
  "consumer-ios",
  "host-android",
  "host-ios",
]);

function plan(paths, mode = "main") {
  return planAffected({
    changedPaths: Array.isArray(paths) ? paths : [paths],
    graph,
    mode,
  });
}

test("every mobile release owner declares exact target, role, and platform validation", () => {
  assert.deepEqual(validateComponentGraph(graph), []);

  for (const [profileId, profile] of Object.entries(graph.operationProfiles)) {
    for (const [mode, operation] of Object.entries(profile.direct)) {
      const targets = operation.releaseTargets ?? [];
      if (targets.length === 0) continue;

      assert.ok(["main", "release"].includes(mode), `${profileId}.${mode}`);
      assert.ok(targets.every((target) => signedTargets.has(target)), `${profileId}.${mode}`);

      const targetRoles = [...new Set(targets.map((target) => target.split("-")[0]))].sort();
      assert.deepEqual(operation.releaseRoles, targetRoles, `${profileId}.${mode}`);

      for (const target of targets) {
        const platform = target.split("-")[1];
        if (mode === "main") {
          assert.ok(
            operation.ciTargets.includes(`flutter_build_${platform}`),
            `${profileId}.${mode}.${target}`,
          );
        } else {
          assert.ok(operation.buildTargets.includes(target), `${profileId}.${mode}.${target}`);
        }
      }
    }
  }
});

test("native and Firebase owners authorize only their role-platform intersection", () => {
  const fixtures = [
    ["apps/host/ios/Runner/Info.plist", ["host-ios"]],
    ["apps/host/android/app/src/main/AndroidManifest.xml", ["host-android"]],
    ["apps/consumer/ios/Runner/Info.plist", ["consumer-ios"]],
    ["apps/consumer/android/app/src/main/AndroidManifest.xml", ["consumer-android"]],
    ["firebase/prod/host/ios/GoogleService-Info.plist", ["host-ios"]],
    ["firebase/prod/host/android/google-services.json", ["host-android"]],
    ["firebase/prod/ios/GoogleService-Info.plist", ["consumer-ios"]],
    ["firebase/prod/android/google-services.json", ["consumer-android"]],
    ["ios/Runner.xcodeproj/project.pbxproj", ["consumer-ios", "host-ios"]],
    ["android/gradle.properties", ["consumer-android", "host-android"]],
  ];

  for (const [path, targets] of fixtures) {
    assert.deepEqual(plan(path).operations.releaseTargets, targets, path);
  }
});

test("mobile package policy changes rebuild all signed installable targets", () => {
  const result = plan("tool/platform/mobile_package_policy.json");

  assert.deepEqual(result.directComponents, ["app.build-control"]);
  assert.deepEqual(result.operations.releaseTargets, [
    "consumer-android",
    "consumer-ios",
    "host-android",
    "host-ios",
  ]);
  assert.deepEqual(result.operations.releaseRoles, ["consumer", "host"]);
});

test("mixed platform changes do not expand role compatibility into a Cartesian product", () => {
  const result = plan([
    "apps/host/ios/Runner/Info.plist",
    "apps/consumer/android/app/src/main/AndroidManifest.xml",
  ]);

  assert.deepEqual(result.operations.releaseRoles, ["consumer", "host"]);
  assert.deepEqual(result.operations.releaseTargets, ["consumer-android", "host-ios"]);
  assert.equal(result.operations.releaseTargets.includes("consumer-ios"), false);
  assert.equal(result.operations.releaseTargets.includes("host-android"), false);
});

test("web-native and desktop ownership remains buildable but cannot sign mobile artifacts", () => {
  const fixtures = [
    ["apps/host/web/index.html", ["host-web"]],
    ["apps/consumer/web/index.html", ["consumer-web"]],
    ["web/index.html", ["consumer-web", "host-web"]],
    ["macos/Runner/Info.plist", ["consumer-web", "host-web"]],
  ];

  for (const [path, buildTargets] of fixtures) {
    const result = plan(path, "release");
    assert.deepEqual(result.operations.buildTargets, buildTargets, path);
    assert.deepEqual(result.operations.releaseTargets, [], path);
    assert.deepEqual(result.operations.releaseRoles, [], path);
  }
});
