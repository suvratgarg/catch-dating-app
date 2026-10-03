import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";
import {
  assertMetadataOnlyCommand,
  buildFunctionBindingsCommand,
  observeFunctionBinding,
  parseSecretReference,
  validateCandidateBindings,
  buildProjectIdentityCommand,
  buildRequirementCommand,
  buildSecretRuntimeAccessCommand,
  classifyProjectIdentity,
  classifyRequirementResult,
  classifySecretRuntimeAccess,
  discoverDefineSecretNames,
  discoverDirectSecretReaders,
  executeReadinessCli,
  exitCodeForResults,
  parseArgs,
  parseFirebaseProjectAliases,
  resolveFirebaseProjectId,
  runEnvironmentReadiness,
  selectReadinessRequirements,
  validateEnvironmentReadinessManifest,
  validateReadinessSelectors,
} from "./check_environment_readiness.mjs";

const testDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(testDir, "../..");
const manifest = JSON.parse(fs.readFileSync(
  path.join(testDir, "environment_readiness.json"),
  "utf8",
));
const aliases = parseFirebaseProjectAliases(fs.readFileSync(
  path.join(repoRoot, ".firebaserc"),
  "utf8",
));

test("checked manifest validates offline without invoking gcloud", () => {
  let commandCalls = 0;
  const execution = executeReadinessCli(
    ["--manifest-only", "--json"],
    {
      repoRoot,
      runCommand: () => {
        commandCalls += 1;
        throw new Error("manifest-only must stay offline");
      },
    },
  );

  assert.equal(execution.exitCode, 0);
  assert.equal(execution.report.secretCount, 18);
  assert.equal(execution.report.requirementCount, 23);
  assert.equal(commandCalls, 0);
});

test("manifest completeness catches missing and dynamic defineSecret declarations", () => {
  const discoveries = discoverDefineSecretNames([
    {
      contents: `
        const first = defineSecret(
          "FIRST_SECRET"
        );
        const second = defineSecret(secretName);
      `,
      path: "functions/src/example.ts",
    },
  ]);
  assert.deepEqual([...discoveries.names], ["FIRST_SECRET"]);
  assert.deepEqual(discoveries.unsupported, ["functions/src/example.ts"]);

  const reduced = structuredClone(manifest);
  reduced.requirements = reduced.requirements.filter(
    (entry) => entry.name !== "ALGOLIA_WRITE_API_KEY",
  );
  assert.throws(
    () => executeReadinessCli(["--manifest-only"], {manifest: reduced, repoRoot}),
    (error) => error.exitCode === 64 &&
      /defineSecret is missing from the manifest: ALGOLIA_WRITE_API_KEY/u.test(
        error.message,
      ),
  );
});

test("usage is explicit and unsafe project/apply overrides are rejected", () => {
  for (const argv of [
    ["--project", "wrong-project", "--targets", "functions"],
    ["--env", "dev", "--targets", "functions", "--apply"],
    ["--env", "dev"],
    ["--all", "--env", "dev", "--targets", "functions"],
  ]) {
    assert.throws(
      () => parseArgs(argv),
      (error) => error.exitCode === 64,
    );
  }

  assert.deepEqual(
    parseArgs([
      "--env",
      "dev",
      "--targets",
      "functions:exploreSearch,storage",
      "--capabilities",
      "cross-paths",
    ]),
    {
      all: false,
      candidate: null,
      phase: "deployed",
      capabilities: ["cross-paths"],
      environment: "dev",
      help: false,
      json: false,
      manifestOnly: false,
      targets: ["functions:exploreSearch", "storage"],
    },
  );
});

test("Firebase environments resolve only through .firebaserc aliases", () => {
  assert.equal(
    resolveFirebaseProjectId({environment: "dev", aliases}),
    "catchdates-dev",
  );
  assert.equal(
    resolveFirebaseProjectId({environment: "staging", aliases}),
    "catchdates-staging",
  );
  assert.equal(
    resolveFirebaseProjectId({environment: "prod", aliases}),
    "catch-dating-app-64e51",
  );
  assert.throws(
    () => resolveFirebaseProjectId({environment: "preview", aliases}),
    (error) => error.exitCode === 64,
  );
});

test("target and capability filtering selects only relevant prerequisites", () => {
  const selected = (environment, targets, capabilities = []) =>
    selectReadinessRequirements({
      capabilities,
      environment,
      manifest,
      targets,
    });

  assert.deepEqual(
    selected("dev", ["functions:exploreSearch"]).map((entry) => entry.name),
    ["ALGOLIA_SEARCH_API_KEY"],
  );
  assert.equal(
    selected("dev", ["functions"]).filter(
      (entry) => entry.kind === "secret-version",
    ).length,
    18,
  );
  assert.equal(selected("dev", ["functions"]).length, 29);
  for (const environment of ["dev", "staging", "prod"]) {
    for (const [target, secrets] of [
      ["refreshProgramTravelLeg", ["FLIGHT_PROVIDER_CONFIG_VERSION"]],
      ["flightAlertWebhook", ["FLIGHT_PROVIDER_CONFIG_VERSION"]],
      ["refreshProgramFlightStatuses", ["FLIGHT_PROVIDER_CONFIG_VERSION"]],
      ["startSalesDemo", ["SALES_DEMO_GRANT_KEY"]],
      ["getSalesDemoSession", ["SALES_DEMO_GRANT_KEY"]],
      ["advanceSalesDemo", ["SALES_DEMO_GRANT_KEY"]],
      ["getSalesDemoSetup", ["SALES_DEMO_GRANT_KEY"]],
      ["prepareSalesDemoFormDraft", ["SALES_DEMO_GRANT_KEY"]],
      ["adminSaveSalesDemoBlueprint", ["SALES_DEMO_GRANT_KEY"]],
      ["adminReviewSalesDemoBlueprint", ["SALES_DEMO_GRANT_KEY"]],
      ["adminWithdrawSalesDemoBlueprint", ["SALES_DEMO_GRANT_KEY"]],
      ["adminIssueSalesDemoInvitation", ["SALES_DEMO_GRANT_KEY"]],
      ["adminRevokeSalesDemoInvitation", ["SALES_DEMO_GRANT_KEY"]],
      ["adminGetSalesDemoBlueprint", ["SALES_DEMO_GRANT_KEY"]],
      ["adminGetSalesDemoInvitation", ["SALES_DEMO_GRANT_KEY"]],
      ["getSalesDemoPreview", []],
      ["adminGetSalesDemoCapability", []],
      ["adminListSalesDemoBlueprints", []],
      ["adminListSalesDemoInvitations", []],
      ["expireSalesDemos", []],
    ]) {
      assert.deepEqual(
        selected(environment, [`functions:${target}`]).map((entry) => entry.name ?? entry.binding.parameter).sort(),
        secrets,
      );
    }
  }
  for (const target of [
    "functions:checkInEventRuntime",
    "functions:createEventVenueSession",
    "functions:selfCheckInAttendance",
    "functions:startEventSuccessFirstHelloMission",
  ]) {
    assert.deepEqual(
      selected("prod", [target]).map((entry) => entry.name),
      ["EVENT_VENUE_SESSION_SIGNING_KEY"],
    );
  }
  assert.deepEqual(
    selected("dev", ["functions:getCrossPathsSuggestions"])
      .map((entry) => entry.id),
    [
      "firestore.ttl.cross-paths-suggestion-exposures",
      "functions.secret.cross-paths-suggestion-signing-key",
    ],
  );
  assert.deepEqual(
    selected("dev", [], ["cross-paths"]).map((entry) => entry.id),
    ["firestore.ttl.cross-paths-suggestion-exposures"],
  );
  for (const target of [
    "functions:createOrganizerPost",
    "functions:dispatchPendingOrganizerFollowerUpdates",
  ]) {
    assert.deepEqual(
      selected("dev", [target]).map((entry) => entry.id),
      ["firestore.ttl.organizer-post-delivery-recipients"],
    );
  }
  assert.deepEqual(selected("dev", ["hosting"]), []);
});

test("Catch webhook requires its own secrets and active receipt TTL", () => {
  const expected = [
    "firestore.ttl.catch-whatsapp-webhook-events",
    "functions.secret.catch-whatsapp-app-secret",
    "functions.secret.catch-whatsapp-webhook-verify-token",
  ];
  for (const environment of ["dev", "staging", "prod"]) {
    const requirements = selectReadinessRequirements({
      manifest, environment, targets: ["functions:catchWhatsappWebhook"],
      capabilities: [],
    });
    assert.deepEqual(requirements.map((entry) => entry.id), expected);
    assert.equal(requirements[0].collectionGroup, "catchWhatsappWebhookEvents");
    assert.equal(requirements[0].field, "expiresAt");
    assert.deepEqual(requirements[0].acceptedStates, ["ACTIVE"]);
    assert.deepEqual(requirements.slice(1).map((entry) => entry.name), [
      "CATCH_WHATSAPP_APP_SECRET", "CATCH_WHATSAPP_WEBHOOK_VERIFY_TOKEN",
    ]);
    assert(requirements.every((entry) => entry.owner === "catch-messaging"));
  }
});

test("unknown selectors fail closed while exported no-prerequisite targets remain valid", () => {
  const functionTargets = new Set([
    "functions:createEvent",
    "functions:getCrossPathsSuggestions",
  ]);
  assert.doesNotThrow(() => validateReadinessSelectors({
    capabilities: [],
    functionTargets,
    manifest,
    targets: ["functions:createEvent", "hosting"],
  }));
  assert.throws(
    () => validateReadinessSelectors({
      capabilities: [],
      functionTargets,
      manifest,
      targets: ["functions:typo"],
    }),
    (error) => error.exitCode === 64 && /Unknown Firebase Function/u.test(
      error.message,
    ),
  );
  assert.throws(
    () => validateReadinessSelectors({
      capabilities: ["typo"],
      functionTargets,
      manifest,
      targets: [],
    }),
    (error) => error.exitCode === 64 && /Unknown environment capability/u.test(
      error.message,
    ),
  );
});

test("gcloud command construction is metadata-only and forbids secret access", () => {
  const secret = manifest.requirements.find(
    (entry) => entry.name === "CROSS_PATHS_SUGGESTION_SIGNING_KEY",
  );
  const ttl = manifest.requirements.find(
    (entry) => entry.kind === "firestore-ttl",
  );
  const commands = [
    buildProjectIdentityCommand("catchdates-dev"),
    buildRequirementCommand({projectId: "catchdates-dev", requirement: secret,
      reference: "projects/catchdates-dev/secrets/CROSS_PATHS_SUGGESTION_SIGNING_KEY/versions/1"}),
    buildSecretRuntimeAccessCommand({
      projectId: "catchdates-dev",
      projectNumber: "619661127800",
      requirement: secret,
    }),
    buildRequirementCommand({projectId: "catchdates-dev", requirement: ttl}),
  ];

  assert.deepEqual(commands[1].args.slice(0, 4), [
    "secrets",
    "versions",
    "describe",
    "1",
  ]);
  assert.ok(commands[1].args.includes("--secret=CROSS_PATHS_SUGGESTION_SIGNING_KEY"));
  assert.ok(commands[1].args.includes("--project=catchdates-dev"));
  assert.deepEqual(commands[2].args.slice(0, 3), [
    "secrets",
    "get-iam-policy",
    "CROSS_PATHS_SUGGESTION_SIGNING_KEY",
  ]);
  assert.ok(commands[2].args.includes("--project=catchdates-dev"));
  assert.deepEqual(commands[3].args.slice(0, 4), [
    "firestore",
    "fields",
    "ttls",
    "list",
  ]);
  assert.ok(commands[3].args.includes(
    "--collection-group=crossPathsSuggestionExposures",
  ));
  for (const command of commands) {
    assert.doesNotMatch(command.args.join(" "), /secrets versions access/iu);
  }
  assert.throws(
    () => assertMetadataOnlyCommand({
      args: ["secrets", "versions", "access", "latest"],
      command: "gcloud",
    }),
    /Secret payload access is forbidden/u,
  );
});

test("secret runtime IAM fails closed before Firebase can mutate policy", () => {
  const requirement = manifest.requirements.find(
    (entry) => entry.name === "CROSS_PATHS_SUGGESTION_SIGNING_KEY",
  );
  const projectNumber = "619661127800";
  const member =
    "serviceAccount:619661127800-compute@developer.gserviceaccount.com";
  const classify = (bindings) => classifySecretRuntimeAccess({
    serviceAccount: "619661127800-compute@developer.gserviceaccount.com",
    requirement,
    result: {
      status: 0,
      stderr: "",
      stdout: JSON.stringify({bindings}),
    },
  });

  const ready = classify([{
    members: [member],
    role: "roles/secretmanager.secretAccessor",
  }]);
  assert.equal(ready.status, "ready");
  assert.equal(ready.reason, "runtime-secret-access-present");
  assert.deepEqual(ready.metadata, {
    roles: ["roles/secretmanager.secretAccessor"],
    serviceAccount: "619661127800-compute@developer.gserviceaccount.com",
    evidenceScope: "secret-policy-only",
  });

  const vaultRequirement = manifest.requirements.find(
    (entry) => entry.name === "ORGANIZER_WHATSAPP_ACCESS_TOKENS",
  );
  const vaultReady = classifySecretRuntimeAccess({
    serviceAccount: "619661127800-compute@developer.gserviceaccount.com",
    requirement: {...vaultRequirement, runtimeRoles: vaultRequirement.runtimeRolesByConsumer.completeOrganizerWhatsappConnection},
    result: {
      status: 0,
      stderr: "",
      stdout: JSON.stringify({bindings: [
        {
          members: [member],
          role: "roles/secretmanager.secretAccessor",
        },
        {
          members: [member],
          role: "roles/secretmanager.secretVersionManager",
        },
      ]}),
    },
  });
  assert.equal(vaultReady.status, "ready");
  const vaultMissingManager = classifySecretRuntimeAccess({
    serviceAccount: "619661127800-compute@developer.gserviceaccount.com",
    requirement: {...vaultRequirement, runtimeRoles: vaultRequirement.runtimeRolesByConsumer.completeOrganizerWhatsappConnection},
    result: {
      status: 0,
      stderr: "",
      stdout: JSON.stringify({bindings: [{
        members: [member],
        role: "roles/secretmanager.secretAccessor",
      }]}),
    },
  });
  assert.equal(vaultMissingManager.status, "not-ready");
  assert.deepEqual(vaultMissingManager.metadata.missingRoles, [
    "roles/secretmanager.secretVersionManager",
  ]);

  const absent = classify([]);
  assert.equal(absent.status, "not-ready");
  assert.equal(absent.reason, "runtime-secret-access-unproven");

  const wrongRole = classify([{
    members: [member],
    role: "roles/secretmanager.viewer",
  }]);
  assert.equal(wrongRole.status, "not-ready");

  const conditional = classify([{
    condition: {expression: "request.time < timestamp('2026-08-09T00:00:00Z')"},
    members: [member],
    role: "roles/secretmanager.secretAccessor",
  }]);
  assert.equal(conditional.status, "not-ready");

  const invalid = classifySecretRuntimeAccess({
    serviceAccount: "619661127800-compute@developer.gserviceaccount.com",
    requirement,
    result: {status: 0, stderr: "", stdout: "[]"},
  });
  assert.equal(invalid.status, "unknown");
  assert.equal(invalid.reason, "invalid-metadata-response");
});

test("secret metadata classification never returns payload fields", () => {
  const requirement = manifest.requirements.find((entry) => entry.name === "CROSS_PATHS_SUGGESTION_SIGNING_KEY");
  const reference = "projects/catchdates-dev/secrets/CROSS_PATHS_SUGGESTION_SIGNING_KEY/versions/7";
  const classify = (payload) => classifyRequirementResult({requirement, reference,
    projectId: "catchdates-dev", projectNumber: "123", result: metadata(payload)});
  const ready = classify({name: reference, state: "ENABLED", payload: "must-never-escape"});
  assert.equal(ready.status, "ready");
  assert.deepEqual(ready.metadata, {reference, state: "ENABLED"});
  assert.doesNotMatch(JSON.stringify(ready), /must-never-escape/u);
  assert.equal(classify({name: reference, state: "DISABLED"}).status, "not-ready");
  assert.equal(classify({name: reference.replace("/7", "/8"), state: "ENABLED"}).status, "unknown");
  assert.equal(classify([{name: reference, state: "DISABLED"},
    {name: reference.replace("/7", "/8"), state: "ENABLED"}]).status, "unknown");
  for (const [stderr, status, reason] of [["NOT_FOUND", "not-ready", "resource-not-found"],
    ["PERMISSION_DENIED", "unknown", "permission-denied"]]) {
    const result = classifyRequirementResult({requirement, reference, projectId: "catchdates-dev",
      result: {status: 1, stderr, stdout: ""}});
    assert.equal(result.status, status); assert.equal(result.reason, reason);
  }
});

test("TTL metadata distinguishes ACTIVE, missing, and transitional policies", () => {
  const requirement = manifest.requirements.find(
    (entry) => entry.kind === "firestore-ttl",
  );
  const classifyState = (state) => classifyRequirementResult({
    requirement,
    result: {
      status: 0,
      stderr: "",
      stdout: JSON.stringify([{
        name: "projects/demo/databases/(default)/collectionGroups/" +
          "crossPathsSuggestionExposures/fields/expiresAt",
        ttlConfig: {state},
      }]),
    },
  });

  assert.equal(classifyState("ACTIVE").status, "ready");
  assert.equal(classifyState("CREATING").status, "not-ready");
  assert.equal(classifyState("NEEDS_REPAIR").status, "not-ready");
  assert.equal(
    classifyRequirementResult({
      requirement,
      result: {status: 0, stderr: "", stdout: "[]"},
    }).reason,
    "ttl-policy-missing",
  );
});

test("result aggregation preserves confirmed-not-ready versus unknown exits", () => {
  assert.equal(exitCodeForResults([{status: "ready"}]), 0);
  assert.equal(exitCodeForResults([
    {status: "ready"},
    {status: "unknown"},
  ]), 2);
  assert.equal(exitCodeForResults([
    {status: "unknown"},
    {status: "not-ready"},
  ]), 2);
});

test("injected runner receives resolved project and returns a known-missing exit", () => {
  const commands = [];
  const report = runEnvironmentReadiness({
    aliases,
    capabilities: ["cross-paths"],
    environments: ["staging"],
    manifest,
    runCommand: (spec) => {
      commands.push(spec);
      if (spec.args[0] === "projects") {
        return {
          status: 0,
          stderr: "",
          stdout: JSON.stringify({
            lifecycleState: "ACTIVE",
            projectId: "catchdates-staging",
            projectNumber: "123",
          }),
        };
      }
      if (spec.args[0] === "functions") return metadata([fakeFunction("getCrossPathsSuggestions",
        "CROSS_PATHS_SUGGESTION_SIGNING_KEY", "catchdates-staging")]);
      if (spec.args[0] === "secrets") {
        if (spec.args[1] === "versions") {
          return {status: 1, stderr: "NOT_FOUND", stdout: ""};
        }
        return {
          status: 0,
          stderr: "",
          stdout: JSON.stringify({bindings: []}),
        };
      }
      return {
        status: 0,
        stderr: "",
        stdout: JSON.stringify([{
          name: "projects/demo/databases/(default)/collectionGroups/" +
            "crossPathsSuggestionExposures/fields/expiresAt",
          ttlConfig: {state: "ACTIVE"},
        }]),
      };
    },
    targets: ["functions:getCrossPathsSuggestions"],
  });

  assert.equal(report.exitCode, 1);
  assert.equal(report.status, "not-ready");
  assert.equal(commands.length, 5);
  assert.ok(commands.slice(1).every((spec) =>
    spec.args.includes("--project=catchdates-staging")));
  assert.ok(commands.every((spec) =>
    !spec.args.join(" ").includes("secrets versions access")));
});

test("live CLI distinguishes ready from indeterminate metadata", () => {
  const readyExecution = executeReadinessCli(
    [
      "--env",
      "staging",
      "--targets",
      "functions:exploreSearch",
      "--json",
    ],
    {
      repoRoot,
      runCommand: readyMetadataRunner,
    },
  );
  assert.equal(readyExecution.exitCode, 0);
  assert.equal(readyExecution.report.environments[0].projectId,
    "catchdates-staging");

  const unknownExecution = executeReadinessCli(
    ["--env", "dev", "--targets", "functions:exploreSearch"],
    {
      repoRoot,
      runCommand: (spec) => {
        if (spec.args[0] === "projects") {
          return readyProjectMetadata(spec.args[2]);
        }
        return {status: 1, stderr: "PERMISSION_DENIED", stdout: ""};
      },
    },
  );
  assert.equal(unknownExecution.exitCode, 2);
  assert.equal(unknownExecution.report.status, "unknown");
});

test("metadata timeout remains indeterminate and deployment-blocking", () => {
  const execution = executeReadinessCli(
    ["--env", "dev", "--targets", "functions:exploreSearch"],
    {
      repoRoot,
      runCommand: (spec) => {
        if (spec.args[0] === "projects") {
          return readyProjectMetadata(spec.args[2]);
        }
        return {
          error: {code: "ETIMEDOUT"},
          status: null,
          stderr: "",
          stdout: "",
        };
      },
    },
  );
  assert.equal(execution.exitCode, 2);
  assert.equal(execution.report.status, "unknown");
  assert.ok(execution.report.environments[0].results
    .filter((result) => result.kind === "secret-version")
    .every((result) => result.reason === "metadata-command-timeout"));
});

test("project identity mismatch is confirmed not-ready", () => {
  const result = classifyProjectIdentity({
    projectId: "catchdates-dev",
    result: {
      status: 0,
      stderr: "",
      stdout: JSON.stringify({
        lifecycleState: "ACTIVE",
        projectId: "catchdates-staging",
        projectNumber: "123",
      }),
    },
  });
  assert.equal(result.status, "not-ready");
  assert.equal(result.metadata.projectIdMatches, false);
});

test("minimal manifest validation rejects duplicate ids", () => {
  const duplicate = structuredClone(manifest);
  duplicate.requirements.push(structuredClone(duplicate.requirements[0]));
  assert.throws(
    () => validateEnvironmentReadinessManifest(duplicate),
    (error) => error.exitCode === 64 && /duplicate id/u.test(error.message),
  );
});

test("manifest accepts only terminal prerequisite states", () => {
  const unsafeSecret = structuredClone(manifest);
  unsafeSecret.requirements[0].acceptedStates.push("DISABLED");
  assert.throws(
    () => validateEnvironmentReadinessManifest(unsafeSecret),
    /must accept only ENABLED/u,
  );

  const unsafeTtl = structuredClone(manifest);
  unsafeTtl.requirements.find((entry) => entry.kind === "firestore-ttl")
    .acceptedStates.push("CREATING");
  assert.throws(
    () => validateEnvironmentReadinessManifest(unsafeTtl),
    /must accept only ACTIVE/u,
  );
});

test("backend promotion selects targets before credentials and checks readiness before runtime installation", () => {
  for (const workflowPath of [".github/workflows/_firebase-promote.yml"]) {
    const source = fs.readFileSync(path.join(repoRoot, workflowPath), "utf8");
    const auth = source.indexOf("name: Authenticate to Google Cloud");
    const parser = source.indexOf("name: Install the pinned source-analysis parser");
    const selection = source.indexOf("--affected-functions true");
    const readiness = source.indexOf(
      "name: Verify environment prerequisites for the approved targets",
    );
    assert.ok(auth >= 0, `${workflowPath} authenticates before probing`);
    assert.ok(parser >= 0 && selection > parser && auth > selection,
      `${workflowPath} resolves affected targets before credentials`);
    const parserStep = source.slice(parser, source.indexOf("\n      - ", parser));
    assert.match(parserStep, /npm ci --ignore-scripts --workspaces=false/);
    assert.ok(readiness > auth, `${workflowPath} probes after authentication`);
    for (const expensiveStep of [
      "run: npm install -g firebase-tools@",
      "npm --prefix build/delivery/deploy-tree/functions ci",
      "./tool/deploy_firebase_targets.sh",
    ]) {
      const expensiveIndex = source.indexOf(expensiveStep);
      assert.ok(
        expensiveIndex > readiness,
        `${workflowPath} runs readiness before ${expensiveStep}`,
      );
    }
  }
});

function readyMetadataRunner(spec) {
  if (spec.args[0] === "projects") {
    return readyProjectMetadata(spec.args[2]);
  }
  if (spec.args[0] === "secrets" && spec.args[1] === "get-iam-policy") {
    const projectNumber = "123";
    return {
      status: 0,
      stderr: "",
      stdout: JSON.stringify({
        bindings: [{
          members: [
            `serviceAccount:${projectNumber}-compute@developer.gserviceaccount.com`,
          ],
          role: "roles/secretmanager.secretAccessor",
        }],
      }),
    };
  }
  if (spec.args[0] === "functions") return metadata([fakeFunction("exploreSearch", "ALGOLIA_SEARCH_API_KEY", "catchdates-staging")]);
  const project = spec.args.find((arg) => arg.startsWith("--project=")).slice(10);
  const secret = spec.args.find((arg) => arg.startsWith("--secret=")).slice(9);
  return metadata({name: `projects/${project}/secrets/${secret}/versions/${spec.args[3]}`, state: "ENABLED"});
}

function readyProjectMetadata(projectId) {
  return {
    status: 0,
    stderr: "",
    stdout: JSON.stringify({
      lifecycleState: "ACTIVE",
      projectId,
      projectNumber: "123",
    }),
  };
}

function metadata(value) { return {status: 0, stderr: "", stdout: JSON.stringify(value)}; }
function fakeFunction(consumer, secret, project = "catchdates-dev", version = "1") {
  return {name: `projects/${project}/locations/asia-south1/functions/${consumer}`, state: "ACTIVE",
    serviceConfig: {serviceAccountEmail: "123-compute@developer.gserviceaccount.com",
      secretEnvironmentVariables: [{key: secret, secret, projectId: project, version}]}};
}

test("observed bindings reject aliases, other projects and missing identities without exposing environment values", () => {
  const requirement = manifest.requirements.find((entry) => entry.name === "ALGOLIA_SEARCH_API_KEY");
  const fn = fakeFunction("exploreSearch", requirement.name);
  const observe = (value) => observeFunctionBinding({requirement, consumer: "exploreSearch",
    functions: [value], projectId: "catchdates-dev", projectNumber: "123"});
  assert.equal(observe(fn).reference, "projects/catchdates-dev/secrets/ALGOLIA_SEARCH_API_KEY/versions/1");
  for (const [field, value] of [["version", "latest"], ["version", "0"],
    ["projectId", "other-project"], ["secret", "OTHER_SECRET"]]) {
    const copy = structuredClone(fn); copy.serviceConfig.secretEnvironmentVariables[0][field] = value;
    assert.equal(observe(copy).reason, "invalid-selected-secret-reference");
  }
  const copy = structuredClone(fn); delete copy.serviceConfig.serviceAccountEmail;
  copy.serviceConfig.environmentVariables = {PRIVATE_KEY: "do-not-print-this"};
  assert.equal(observe(copy).reason, "runtime-identity-unobserved");
  assert.doesNotMatch(JSON.stringify(observe(copy)), /do-not-print-this|PRIVATE_KEY/u);
  assert.equal(parseSecretReference("projects/123/secrets/KEY/versions/1", "catchdates-dev"), null);
  assert.ok(parseSecretReference("projects/123/secrets/KEY/versions/1", "catchdates-dev", "123"));
});

test("disabled optional configuration performs no secret query; enabled configuration without a reference fails", () => {
  const requirement = {id: "functions.reference.fake", kind: "secret-reference", owner: "fake",
    binding: {parameter: "FAKE_CONFIG_VERSION", enabledParameter: "FAKE_ENABLED", optional: true},
    requiredWhen: {anyDeployTarget: ["functions:fakeConsumer"]}, environments: ["dev"], acceptedStates: ["ENABLED"]};
  const run = (params) => {
    const commands = [];
    const fn = fakeFunction("fakeConsumer", "unused"); fn.serviceConfig.environmentVariables = params;
    const report = runEnvironmentReadiness({aliases, environments: ["dev"], targets: ["functions:fakeConsumer"],
      manifest: {...manifest, requirements: [requirement]}, runCommand(spec) {
        commands.push(spec);
        if (spec.args[0] === "projects") return readyProjectMetadata("catchdates-dev");
        if (spec.args[0] === "functions") return metadata([fn]);
        throw new Error("inactive must not probe secrets");
      }});
    assert.equal(commands.length, 2); return report;
  };
  const inactive = run({FAKE_CONFIG_VERSION: " ", FAKE_ENABLED: "false", SECRET: "fake-never-print"});
  assert.equal(inactive.exitCode, 0);
  assert.equal(inactive.environments[0].results[1].status, "inactive");
  assert.doesNotMatch(JSON.stringify(inactive), /fake-never-print/u);
  const active = run({FAKE_CONFIG_VERSION: " ", FAKE_ENABLED: "true"});
  assert.equal(active.exitCode, 1);
  assert.equal(active.environments[0].results[1].reason, "active-reference-missing");
  assert.equal(run({FAKE_CONFIG_VERSION: "RAW-SECRET-DO-NOT-PRINT"}).exitCode, 1);
});

test("IAM uses the explicit identity and catches a reader inheriting the provisioner grant", () => {
  const requirement = {id: "fake", name: "FAKE_CONFIG", runtimeRoles: ["roles/secretmanager.secretAccessor"]};
  const serviceAccount = "reader@catchdates-dev.iam.gserviceaccount.com";
  const result = metadata({bindings: ["roles/secretmanager.secretAccessor", "roles/secretmanager.secretVersionManager"]
    .map((role) => ({role, members: [`serviceAccount:${serviceAccount}`]}))});
  assert.equal(classifySecretRuntimeAccess({requirement, result}).reason, "runtime-identity-unobserved");
  const excessive = classifySecretRuntimeAccess({requirement, serviceAccount, result});
  assert.equal(excessive.status, "not-ready");
  assert.equal(excessive.reason, "runtime-secret-permission-leakage");
  assert.deepEqual(excessive.metadata.excessiveRoles, ["roles/secretmanager.secretVersionManager"]);
  assert.equal(classifySecretRuntimeAccess({requirement, serviceAccount: "other@catchdates-dev.iam.gserviceaccount.com", result}).status, "not-ready");
});

test("candidate readiness is distinct from deployed equivalence and preserves exact source provenance", () => {
  const requirement = manifest.requirements.find((entry) => entry.name === "ALGOLIA_SEARCH_API_KEY");
  const sourceSha = "a".repeat(40);
  const candidate = {version: 1, environment: "staging", projectId: "catchdates-staging", sourceSha,
    bindings: [{requirementId: requirement.id, consumer: "exploreSearch", active: true,
      serviceAccount: "123-compute@developer.gserviceaccount.com",
      reference: "projects/catchdates-staging/secrets/ALGOLIA_SEARCH_API_KEY/versions/2"}]};
  const options = {aliases, environments: ["staging"], manifest, sourceSha, candidate,
    targets: ["functions:exploreSearch"], runCommand: readyMetadataRunner};
  const proposed = runEnvironmentReadiness({...options, phase: "candidate"});
  assert.equal(proposed.exitCode, 0);
  assert.equal(proposed.environments[0].results[1].metadata.deployedMatchesCandidate, false);
  assert.equal(proposed.providerUsabilityVerified, false);
  const deployed = runEnvironmentReadiness({...options, phase: "deployed"});
  assert.equal(deployed.exitCode, 1);
  assert.equal(deployed.environments[0].results[1].reason, "deployed-binding-outdated");
  for (const mutate of [
    (c) => { c.sourceSha = "b".repeat(40); },
    (c) => { c.bindings[0].consumer = "unsupportedConsumer"; },
    (c) => { c.bindings[0].reference = "projects/other-project/secrets/KEY/versions/2"; },
    (c) => { c.bindings[0].reference = "projects/catchdates-staging/secrets/ALGOLIA_SEARCH_API_KEY/versions/latest"; },
    (c) => { c.environmentVariables = {SECRET: "must-never-escape"}; },
    (c) => { c.bindings[0].payload = "must-never-escape"; },
  ]) {
    const copy = structuredClone(candidate); mutate(copy);
    assert.throws(() => validateCandidateBindings(copy, {environment: "staging", projectId: "catchdates-staging", sourceSha, manifest}),
      (error) => error.exitCode === 64 && !error.message.includes("must-never-escape"));
  }
});

test("offline direct-reader coverage rejects omitted and unsupported consumers", () => {
  const reduced = structuredClone(manifest); reduced.directReaders.shift();
  assert.throws(() => executeReadinessCli(["--manifest-only"], {manifest: reduced, repoRoot}),
    /Direct secret reader is missing from manifest/u);
  const unsupported = structuredClone(manifest); unsupported.directReaders[0].consumers.push("missingFunction");
  assert.throws(() => executeReadinessCli(["--manifest-only"], {manifest: unsupported, repoRoot}),
    /unsupported direct-reader consumer/u);
  assert.deepEqual([...discoverDirectSecretReaders([
    {path: "functions/src/direct.ts", contents: "client.accessSecretVersion({name});"},
    {path: "functions/src/delegated.ts", contents: "readRcsSecret(client, version);"},
  ])], ["functions/src/direct.ts", "functions/src/delegated.ts"]);
});

test("metadata projections only request reference and activation fields, never the whole environment", () => {
  const command = buildFunctionBindingsCommand({projectId: "catchdates-dev", requirements: [
    {binding: {parameter: "FLIGHT_PROVIDER_CONFIG_VERSION", enabledParameter: "FLIGHT_ENABLED"}},
  ]});
  const format = command.args.find((arg) => arg.startsWith("--format="));
  assert.match(format, /environmentVariables.FLIGHT_PROVIDER_CONFIG_VERSION/u);
  assert.doesNotMatch(format, /environmentVariables[,)]/u);
  assert.doesNotMatch(format, /payload|value|private_key/iu);
});

test("a disabled gated consumer may retain a valid reference without checking its version", () => {
  const requirement = {kind: "secret-reference", binding: {parameter: "CONFIG_VERSION",
    enabledParameter: "FEATURE_ENABLED", optional: true}};
  const fn = fakeFunction("example", "UNUSED");
  fn.serviceConfig.environmentVariables = {FEATURE_ENABLED: "false",
    CONFIG_VERSION: "projects/catchdates-dev/secrets/RETAINED/versions/1"};
  const binding = observeFunctionBinding({requirement, consumer: "example", functions: [fn],
    projectId: "catchdates-dev", projectNumber: "123"});
  assert.equal(binding.active, false);
  assert.equal(binding.status, "inactive");
  assert.equal(binding.reference, fn.serviceConfig.environmentVariables.CONFIG_VERSION);
});

test("broad secret administrator grants cannot pass as reader-only permission", () => {
  const serviceAccount = "reader@catchdates-dev.iam.gserviceaccount.com";
  const result = classifySecretRuntimeAccess({serviceAccount,
    requirement: {id: "fake", name: "FAKE"}, result: metadata({bindings:
      ["roles/secretmanager.secretAccessor", "roles/secretmanager.admin"].map((role) =>
        ({role, members: [`serviceAccount:${serviceAccount}`]}))})});
  assert.equal(result.reason, "runtime-secret-permission-leakage");
});
