import assert from "node:assert/strict";
import {execFileSync} from "node:child_process";
import fs from "node:fs";
import test from "node:test";
import {
  deriveAppRoles,
  planAffected,
  resolveTargetCheckout,
  summarizeCoverage,
  validateComponentGraph,
} from "./lib/component_graph.mjs";

const graph = JSON.parse(
  fs.readFileSync(new URL("./component_graph.json", import.meta.url), "utf8"),
);
const rootManifest = JSON.parse(
  fs.readFileSync(new URL("../repository_root_manifest.json", import.meta.url), "utf8"),
);

function plan(path, mode = "pr", sourceGraph = graph) {
  return planAffected({changedPaths: [path], graph: sourceGraph, mode});
}

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

test("component graph validates and affected edges cannot authorize release", () => {
  assert.deepEqual(validateComponentGraph(graph), []);
  for (const profile of Object.values(graph.operationProfiles)) {
    for (const operation of Object.values(profile.affected)) {
      assert.deepEqual(operation.deployGroups ?? [], []);
      assert.deepEqual(operation.releaseRoles ?? [], []);
    }
  }
});

test("CI checkout requirements keep planner and docs narrow with a full fallback", () => {
  assert.deepEqual(graph.ciCheckout.planner, {
    mode: "sparse",
    fetchDepth: 0,
    coneMode: false,
    timeoutMinutes: 3,
    paths: [
      "/tool/harness.mjs",
      "/tool/harness/component_graph.json",
      "/tool/harness/lib/component_graph.mjs",
      "/tool/lib/repo_paths.mjs",
      "/tool/lib/tool_impact.mjs",
      "/tool/tools_manifest.json",
    ],
  });
  assert.deepEqual(resolveTargetCheckout({graph, target: "docs"}), {
    mode: "sparse",
    fetchDepth: 0,
    coneMode: false,
    timeoutMinutes: 3,
    paths: [
      "/tool/docs/check_doc_metadata.mjs",
    ],
  });
  assert.deepEqual(resolveTargetCheckout({graph, target: "policy_docs"}), {
    mode: "full",
    fetchDepth: 0,
    timeoutMinutes: 3,
  });
});

test("CI checkout requirements reject unsafe narrowing", () => {
  const cases = [
    {
      name: "unknown target",
      mutate(value) {
        value.ciCheckout.targetOverrides.unknown = clone(
          value.ciCheckout.targetOverrides.docs,
        );
      },
      expected: "unknown CI target",
    },
    {
      name: "narrow default",
      mutate(value) {
        value.ciCheckout.default = clone(value.ciCheckout.targetOverrides.docs);
      },
      expected: "undeclared targets widen safely",
    },
    {
      name: "empty paths",
      mutate(value) {
        value.ciCheckout.targetOverrides.docs.paths = [];
      },
      expected: "must not be empty",
    },
    {
      name: "duplicate paths",
      mutate(value) {
        value.ciCheckout.targetOverrides.docs.paths.push(
          value.ciCheckout.targetOverrides.docs.paths[0],
        );
      },
      expected: "contains duplicate",
    },
    {
      name: "absolute path",
      mutate(value) {
        value.ciCheckout.targetOverrides.docs.paths[0] = "etc/passwd";
      },
      expected: "unsafe or non-canonical root pattern",
    },
    {
      name: "path traversal",
      mutate(value) {
        value.ciCheckout.targetOverrides.docs.paths[0] = "/docs/../secret";
      },
      expected: "unsafe or non-canonical root pattern",
    },
    {
      name: "negated path",
      mutate(value) {
        value.ciCheckout.targetOverrides.docs.paths[0] = "/!docs/private";
      },
      expected: "unsafe or non-canonical root pattern",
    },
    {
      name: "multiline path",
      mutate(value) {
        value.ciCheckout.targetOverrides.docs.paths[0] = "/docs/safe\nunsafe";
      },
      expected: "unsafe or non-canonical root pattern",
    },
    {
      name: "invalid timeout",
      mutate(value) {
        value.ciCheckout.targetOverrides.docs.timeoutMinutes = 11;
      },
      expected: "integer from 1 through 10",
    },
    {
      name: "sparse fields on full checkout",
      mutate(value) {
        value.ciCheckout.default.paths = ["/README.md"];
      },
      expected: "only valid for sparse checkout",
    },
  ];

  for (const fixture of cases) {
    const invalid = clone(graph);
    fixture.mutate(invalid);
    assert.ok(
      validateComponentGraph(invalid).some((error) => error.includes(fixture.expected)),
      fixture.name,
    );
  }
});

test("nightly full mode selects every declared validation component without deploy authority", () => {
  const result = planAffected({changedPaths: [], graph, mode: "nightly", full: true});
  assert.equal(result.full, true);
  assert.equal(result.directComponents.length, graph.components.length);
  assert.deepEqual(result.operations.deployGroups, []);
  assert.deepEqual(result.operations.releaseRoles, []);
  assert.ok(result.operations.ciTargets.includes("flutter"));
  assert.ok(result.operations.ciTargets.includes("functions"));
  assert.ok(result.operations.ciTargets.includes("tools"));
});

test("full mode cannot grant main or release authority", () => {
  for (const mode of ["main", "release"]) {
    assert.throws(
      () => planAffected({changedPaths: [], graph, mode, full: true}),
      /validation-only and requires nightly mode/,
    );
  }
});

test("ordinary and root documentation use the single docs lane", () => {
  for (const path of ["docs/product_notes.md", "README.md", "TESTS.md"]) {
    const result = plan(path);
    assert.deepEqual(result.directComponents, ["docs.ordinary"]);
    assert.deepEqual(result.operations.ciTargets, ["docs"]);
    assert.equal(result.complete, true);
  }
});

test("terminal generated Markdown does not collide with ordinary docs", () => {
  const result = plan("lib/core/schema_contracts/generated/INDEX.md");
  assert.equal(result.complete, true);
  assert.deepEqual(result.directComponents, ["contracts.generated.flutter"]);
});

test("agent policy remains distinct from ordinary documentation", () => {
  const result = plan("AGENTS.md");
  assert.deepEqual(result.directComponents, ["policy.agent"]);
  assert.deepEqual(result.operations.ciTargets, ["policy_docs"]);
  assert.deepEqual(result.operations.checkIds, [
    "docs:metadata",
    "meta:enforcement-integrity",
  ]);
});

test("terminal Functions documentation never inherits deploy authority", () => {
  const result = plan("functions/README.md", "main");
  assert.deepEqual(result.directComponents, ["backend.functions-doc"]);
  assert.deepEqual(result.operations.ciTargets, ["functions"]);
  assert.deepEqual(result.operations.deployGroups, []);
});

test("root operations README keeps its explicit workflow owner", () => {
  const result = plan("operations/README.md");
  assert.deepEqual(result.directComponents, ["operations.workflow-doc"]);
  assert.deepEqual(result.operations.ciTargets, ["functions", "operations", "tools"]);
});

test("shared Flutter presentation change selects tests and role-bounded web smoke", () => {
  const path = "lib/features/explore/presentation/explore_page.dart";
  const v2Plan = plan(path);

  assert.deepEqual(v2Plan.directComponents, ["app.shared"]);
  assert.deepEqual(v2Plan.affectedComponents, ["app.consumer", "app.host"]);
  assert.deepEqual(v2Plan.operations.ciTargets, ["flutter", "flutter_web_smoke"]);
  assert.deepEqual(v2Plan.operations.buildTargets, [
    "consumer-web-smoke",
    "host-web-smoke",
  ]);
});

test("host-only Flutter source selects only Flutter and the host web smoke lane", () => {
  const result = plan("lib/hosts/presentation/host_home.dart");
  assert.deepEqual(result.directComponents, ["app.host"]);
  assert.deepEqual(result.affectedComponents, []);
  assert.deepEqual(result.operations.ciTargets, ["flutter", "flutter_web_smoke"]);
  assert.deepEqual(result.operations.buildTargets, ["host-web-smoke"]);
  assert.deepEqual(deriveAppRoles(result), ["host"]);
});

test("platform builds without explicit role metadata conservatively compile both apps", () => {
  const result = plan("android/gradle.properties");
  assert.deepEqual(result.operations.ciTargets, ["flutter_build_android"]);
  assert.deepEqual(deriveAppRoles(result), ["consumer", "host"]);
});

test("native and Firebase role fixtures retain platform-specific validation", () => {
  const nativeHost = plan("android/app/src/hostProd/AndroidManifest.xml", "main");
  assert.deepEqual(nativeHost.directComponents, ["app.native.android.host"]);
  assert.deepEqual(nativeHost.operations.ciTargets, ["flutter_build_android"]);
  assert.deepEqual(nativeHost.operations.releaseRoles, ["host"]);

  const firebaseConsumer = plan("firebase/prod/android/google-services.json", "main");
  assert.deepEqual(firebaseConsumer.directComponents, ["infra.firebase.consumer-android"]);
  assert.deepEqual(firebaseConsumer.operations.ciTargets, ["flutter_build_android", "tools"]);
  assert.deepEqual(firebaseConsumer.operations.releaseRoles, ["consumer"]);

  const firebaseRoot = plan("firebase.json", "main");
  assert.deepEqual(firebaseRoot.directComponents, ["infra.firebase"]);
  assert.deepEqual(firebaseRoot.operations.deployGroups, []);

  const packageIos = plan("apps/host/ios/Runner/Info.plist", "main");
  assert.deepEqual(packageIos.directComponents, ["app.host.native.ios"]);
  assert.deepEqual(packageIos.operations.ciTargets, ["flutter_build_ios"]);
  assert.deepEqual(packageIos.operations.releaseRoles, ["host"]);

  const packageAndroid = plan(
    "apps/consumer/android/app/src/main/AndroidManifest.xml",
    "main",
  );
  assert.deepEqual(packageAndroid.directComponents, ["app.consumer.native.android"]);
  assert.deepEqual(packageAndroid.operations.ciTargets, ["flutter_build_android"]);
  assert.deepEqual(packageAndroid.operations.releaseRoles, ["consumer"]);

  const packageBoundary = plan("apps/host/pubspec.yaml");
  assert.deepEqual(packageBoundary.directComponents, ["app.host.dependencies"]);
  assert.deepEqual(packageBoundary.operations.ciTargets, [
    "flutter",
    "flutter_build_android",
    "flutter_build_ios",
    "flutter_build_web",
    "visual_integration",
  ]);
});

test("shared React primitives expand to both web consumers", () => {
  const result = plan("packages/web-ui/src/Button.tsx");
  assert.deepEqual(result.directComponents, ["web.shared"]);
  assert.deepEqual(result.affectedComponents, ["web.admin", "web.marketing"]);
  assert.deepEqual(result.operations.ciTargets, ["admin", "marketing", "tools"]);
});

test("Flutter field adoption stays on the Flutter design lane", () => {
  const result = plan("design/components/flutter_field_surface_adoption.json");
  assert.deepEqual(result.directComponents, ["app.design-field-adoption"]);
  assert.deepEqual(result.affectedComponents, []);
  assert.deepEqual(result.operations.ciTargets, [
    "flutter",
    "tools",
    "visual_integration",
  ]);
});

test("authored contracts expand to every declared validation consumer", () => {
  const result = plan("contracts/users/v1.schema.json");
  assert.deepEqual(result.directComponents, ["contracts.source"]);
  assert.deepEqual(result.affectedComponents, [
    "app.contract-consumer",
    "backend.firestore-indexes",
    "backend.firestore-rules",
    "backend.functions",
    "backend.storage-rules",
    "operations.contract-consumer",
    "web.admin",
    "web.marketing",
  ]);
  assert.deepEqual(result.operations.ciTargets, [
    "admin",
    "contracts",
    "firestore_rules",
    "flutter",
    "functions",
    "marketing",
    "operations",
  ]);
  assert.deepEqual(result.operations.codegenIds, [
    "contracts.schema-projections",
  ]);
});

test("callable contracts select both schema and admin validator codegen", () => {
  const result = plan("contracts/callables/update_event_payload.schema.json");
  assert.deepEqual(result.operations.codegenIds, [
    "admin.callable-validators",
    "contracts.schema-projections",
  ]);
});

test("generated Flutter bindings validate Flutter without expanding upstream", () => {
  const result = plan("lib/core/schema_contracts/generated/schema_paths.dart");
  assert.deepEqual(result.directComponents, ["contracts.generated.flutter"]);
  assert.deepEqual(result.affectedComponents, []);
  assert.deepEqual(result.operations.ciTargets, ["flutter"]);
  assert.deepEqual(result.operations.codegenIds, ["contracts.schema-projections"]);
});

test("only direct ownership can authorize deploy groups", () => {
  const functionsPlan = plan("functions/src/index.ts", "main");
  assert.deepEqual(functionsPlan.operations.deployGroups, ["functions"]);
  assert.deepEqual(functionsPlan.operationSources.deployGroups, [{
    component: "backend.functions",
    relationship: "direct",
    value: "functions",
  }]);

  const contractPlan = plan("contracts/users/v1.schema.json", "main");
  assert.deepEqual(contractPlan.operations.deployGroups, []);
});

test("Firebase mutations are authorized by exact direct owners", () => {
  const expectations = [
    ["firestore.indexes.json", ["firestore-indexes"], ["contracts"]],
    ["firestore.rules", ["firestore-rules"], ["contracts", "firestore_rules"]],
    ["storage.rules", ["storage-rules"], ["contracts", "firestore_rules"]],
  ];
  for (const [path, deployGroups, ciTargets] of expectations) {
    const result = plan(path, "main");
    assert.deepEqual(result.operations.deployGroups, deployGroups);
    assert.deepEqual(result.operations.ciTargets, ciTargets);
  }

  const extension = plan("extensions/export-bigquery.env", "main");
  assert.deepEqual(extension.directComponents, ["infra.firebase.extensions"]);
  assert.deepEqual(extension.operations.deployGroups, []);
});

test("deploy groups require their mandatory CI validation targets", () => {
  const unsafe = clone(graph);
  unsafe.operationProfiles["functions-source"].direct.main.ciTargets = [];
  const errors = validateComponentGraph(unsafe);
  assert.ok(errors.some((error) =>
    error.includes('deploy group "functions" requires CI target "functions"')
  ));
});

test("unknown paths fail closed in required planning commands", () => {
  const result = plan("unowned/new.file");
  assert.equal(result.complete, false);
  assert.deepEqual(result.unknownPaths, ["unowned/new.file"]);
  assert.deepEqual(result.operations.ciTargets, []);
});

test("overlapping component ownership is reported as ambiguous", () => {
  const invalidOwnership = clone(graph);
  invalidOwnership.components.push({
    id: "app.overlap-fixture",
    owner: "test",
    risk: "standard",
    operationProfile: "app-shared",
    pathType: "component",
    ownedPaths: {include: ["lib/features/**"]},
    dependsOn: [],
    alsoAffects: [],
  });
  const result = plan(
    "lib/features/explore/presentation/explore_page.dart",
    "pr",
    invalidOwnership,
  );
  assert.equal(result.complete, false);
  assert.deepEqual(result.ambiguousPaths, [{
    path: "lib/features/explore/presentation/explore_page.dart",
    kind: "component",
    matches: ["app.overlap-fixture", "app.shared"],
  }]);
});

test("compile-codegen rejects mutation and network commands", () => {
  const unsafe = clone(graph);
  unsafe.compileCodegen[0].checkCommand = "firebase deploy --check";
  const errors = validateComponentGraph(unsafe);
  assert.ok(errors.some((error) => error.includes("unsupported executable")));
  assert.ok(errors.some((error) => error.includes("network or deployment CLI")));
  assert.ok(errors.some((error) => error.includes("forbidden mutation token")));
});

test("graph validation rejects release authority on an affected edge", () => {
  const unsafe = clone(graph);
  unsafe.operationProfiles["app-host"].affected.main = {releaseRoles: ["host"]};
  const errors = validateComponentGraph(unsafe);
  assert.ok(errors.some((error) =>
    error.includes("cannot authorize release from an affected edge")
  ));
});

test("graph validation rejects unknown tool check ids when the manifest is supplied", () => {
  const invalid = clone(graph);
  invalid.operationProfiles.docs.direct.pr.checkIds = ["missing:check"];
  const errors = validateComponentGraph(invalid, {
    knownCheckIds: new Set(rootManifest.relationships.flatMap(
      (relationship) => relationship.checks ?? [],
    )),
  });
  assert.ok(errors.some((error) => error.includes('unknown tool check id "missing:check"')));
});

test("generator scripts and generated outputs select their declared freshness checks", () => {
  const schemaScript = plan("tool/contracts/generate_schema_contracts.mjs");
  assert.deepEqual(schemaScript.operations.codegenIds, ["contracts.schema-projections"]);

  const adminScript = plan("admin/scripts/generateCallableValidators.mjs");
  assert.deepEqual(adminScript.operations.codegenIds, ["admin.callable-validators"]);

  const notificationCatalog = plan("copy/notifications_en.json");
  assert.deepEqual(notificationCatalog.directComponents, ["content.notification"]);
  assert.deepEqual(notificationCatalog.operations.ciTargets, ["functions"]);
  assert.deepEqual(notificationCatalog.operations.codegenIds, ["copy.notification"]);

  const nativeCatalog = plan("copy/native_en.json");
  assert.deepEqual(nativeCatalog.directComponents, ["content.native"]);
  assert.deepEqual(nativeCatalog.operations.ciTargets, ["flutter_build_ios"]);
  assert.deepEqual(nativeCatalog.operations.codegenIds, ["copy.native"]);

  const generatedNotification = plan(
    "functions/src/shared/generated/notificationCopyEn.ts",
  );
  assert.ok(generatedNotification.operations.codegenIds.includes("copy.notification"));
});

test("coverage summary quantifies unknown and ambiguous ownership", () => {
  const summary = summarizeCoverage({
    paths: ["README.md", "lib/example.dart", "unowned/new.file"],
    graph,
  });
  assert.deepEqual(summary, {
    totalPaths: 3,
    mappedPaths: 2,
    unknownPathCount: 1,
    ambiguousPathCount: 0,
    coveragePercent: 66.7,
    unknownByRoot: {unowned: 1},
    unknownPathSample: ["unowned/new.file"],
    ambiguousPathSample: [],
  });
});

test("every tracked path has exactly one terminal classification or component owner", () => {
  const paths = execFileSync("git", ["ls-files"], {encoding: "utf8"})
    .split(/\r?\n/)
    .filter(Boolean);
  const summary = summarizeCoverage({paths, graph});
  assert.equal(summary.coveragePercent, 100);
  assert.equal(summary.unknownPathCount, 0);
  assert.equal(summary.ambiguousPathCount, 0);
});
