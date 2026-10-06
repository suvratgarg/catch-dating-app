import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";
import {
  planPreCommitActions,
  PreCommitGeneratedArtifactError,
  runPreCommitGeneratedArtifacts,
} from "./pre_commit_generated_artifacts.mjs";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const graph = JSON.parse(fs.readFileSync(
  path.join(repoRoot, "tool/harness/component_graph.json"),
  "utf8",
));

test("every catalogued committed compile generator has a staged-source trigger", () => {
  const stagedPaths = [
    "contracts/callables/create_event.schema.json",
    "copy/event_success_questionnaires_en.json",
    "copy/native_en.json",
    "copy/notifications_en.json",
    "copy/structured_domain_copy_en.json",
    "lib/l10n/app_en.arb",
    "ios/Podfile.template",
  ];
  const plan = planPreCommitActions({graph, stagedPaths});
  assert.deepEqual(
    plan.triggeredGeneratorIds.sort(),
    graph.compileCodegen.map((generator) => generator.id).sort(),
  );
  assert.equal(plan.l10nInputChanged, true);
});

test("ARB generation, Dart formatting, explicit staging, and freshness checks stay ordered", () => {
  const calls = [];
  const result = runPreCommitGeneratedArtifacts({
    fileExists: (candidate) => candidate.endsWith(".dart"),
    graph,
    repoRoot: "/fixture",
    runCommand: (spec) => {
      calls.push({command: spec.command, args: spec.args});
      return {status: 0, stderr: "", stdout: ""};
    },
    stagedPaths: [
      "contracts/callables/create_event.schema.json",
      "lib/example.dart",
      "lib/l10n/app_en.arb",
    ],
    unstagedPaths: [],
  });

  assert.deepEqual(result.generated, ["flutter.l10n"]);
  assert.ok(result.formattedDartPaths.includes("lib/example.dart"));
  assert.deepEqual(result.checked, [
    "contracts.schema-projections",
    "admin.callable-validators",
    "flutter.l10n",
  ]);
  assert.deepEqual(calls.slice(0, 4), [
    {command: "/bin/sh", args: ["-c", "flutter gen-l10n"]},
    {
      command: "git",
      args: [
        "add",
        "--",
        "lib/l10n/generated/app_localizations.dart",
        "lib/l10n/generated/app_localizations_en.dart",
      ],
    },
    {
      command: "dart",
      args: [
        "format",
        "--",
        "lib/example.dart",
        "lib/l10n/generated/app_localizations.dart",
        "lib/l10n/generated/app_localizations_en.dart",
      ],
    },
    {
      command: "git",
      args: [
        "add",
        "--",
        "lib/example.dart",
        "lib/l10n/generated/app_localizations.dart",
        "lib/l10n/generated/app_localizations_en.dart",
      ],
    },
  ]);
});

test("partially staged Dart fails before formatting can stage unrelated work", () => {
  let commandCalls = 0;
  assert.throws(
    () => runPreCommitGeneratedArtifacts({
      graph,
      repoRoot: "/fixture",
      runCommand: () => {
        commandCalls += 1;
        return {status: 0, stderr: "", stdout: ""};
      },
      stagedPaths: ["lib/partial.dart"],
      unstagedPaths: ["lib/partial.dart"],
    }),
    (error) => error instanceof PreCommitGeneratedArtifactError &&
      /partially staged Dart files/u.test(error.message),
  );
  assert.equal(commandCalls, 0);
});

test("contract drift reports both exact regeneration commands", () => {
  const failures = [];
  for (const failedCommand of [
    "node tool/contracts/generate_schema_contracts.mjs --check",
    "npm --workspace catch-admin run check:callable-validators",
  ]) {
    assert.throws(
      () => runPreCommitGeneratedArtifacts({
        graph,
        repoRoot: "/fixture",
        runCommand: ({args, command}) => {
          const shellCommand = command === "/bin/sh" ? args[1] : "";
          return {status: shellCommand === failedCommand ? 1 : 0, stderr: "", stdout: ""};
        },
        stagedPaths: ["contracts/callables/create_event.schema.json"],
        unstagedPaths: [],
      }),
      (error) => {
        failures.push(error.message);
        return error instanceof PreCommitGeneratedArtifactError;
      },
    );
  }
  assert.match(
    failures.join("\n"),
    /node tool\/contracts\/generate_schema_contracts\.mjs/u,
  );
  assert.match(
    failures.join("\n"),
    /npm --workspace catch-admin run generate:callable-validators/u,
  );
});

test("Functions TypeScript changes require staged dependency closure", () => {
  const calls = [];
  const result = runPreCommitGeneratedArtifacts({
    graph,
    repoRoot: "/fixture",
    runCommand: (spec) => {
      calls.push({command: spec.command, args: spec.args});
      return {status: 0, stderr: "", stdout: ""};
    },
    stagedPaths: ["functions/src/catchMessaging/whatsappReplyStore.ts"],
    unstagedPaths: [],
  });
  assert.deepEqual(result.checked, ["functions.source-closure"]);
  assert.deepEqual(calls, [{
    command: "node",
    args: ["tool/firebase/check_functions_source_closure.mjs"],
  }]);
});

test("missing staged Functions dependencies reject the commit", () => {
  assert.throws(() => runPreCommitGeneratedArtifacts({
    graph,
    repoRoot: "/fixture",
    runCommand: ({command}) => ({status: command === "node" ? 1 : 0,
      stderr: "unresolved", stdout: ""}),
    stagedPaths: ["functions/src/index.ts"],
    unstagedPaths: [],
  }), (error) => error instanceof PreCommitGeneratedArtifactError &&
    /dependency closure is incomplete/u.test(error.message));
});


test("schema-generated Dart keeps exact generator ownership while source formats", () => {
  const calls = [];
  const result = runPreCommitGeneratedArtifacts({
    fileExists: () => true, graph, repoRoot: "/fixture",
    runCommand: (spec) => {
      calls.push({command: spec.command, args: spec.args});
      return {status: 0, stderr: "", stdout: ""};
    },
    stagedPaths: ["lib/example.dart",
      "lib/core/schema_contracts/generated/schemas/example.g.dart"],
    unstagedPaths: [],
  });
  assert.deepEqual(result.formattedDartPaths, ["lib/example.dart"]);
  assert.deepEqual(result.checked, ["contracts.schema-projections"]);
  assert.deepEqual(calls.find((call) => call.command === "dart").args,
    ["format", "--", "lib/example.dart"]);
});

test("stale generated Dart still rejects the commit without a formatter rewrite", () => {
  const calls = [];
  assert.throws(() => runPreCommitGeneratedArtifacts({
    fileExists: () => true, graph, repoRoot: "/fixture",
    runCommand: (spec) => {
      calls.push(spec);
      return {status: 1, stderr: "stale schema output", stdout: ""};
    },
    stagedPaths: ["lib/core/schema_contracts/generated/schemas/example.g.dart"],
    unstagedPaths: [],
  }), (error) => error instanceof PreCommitGeneratedArtifactError &&
    /Generated artifact drift/.test(error.message));
  assert.equal(calls.some((call) => call.command === "dart"), false);
  assert.equal(calls.some((call) => call.command === "git"), false);
  assert.deepEqual(calls[0].args,
    ["-c", "node tool/contracts/generate_schema_contracts.mjs --check"]);
});
