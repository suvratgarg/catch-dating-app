import assert from "node:assert/strict";
import {execFileSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  createBoundedFirebaseConfig,
  prepareFirebaseDelivery,
  verifyFirebaseDelivery,
} from "./package_firebase_delivery.mjs";

const sourceSha = "a".repeat(40);
const baseSha = "b".repeat(40);
const sourceCiRunId = "12345";
const sourceCiRunAttempt = "2";
const functionTargets = ["functions:alpha", "functions:beta"];
const requiredCiTarget = Object.freeze({
  functions: "functions",
  "firestore-indexes": "contracts",
  "firestore-rules": "firestore_rules",
  "storage-rules": "firestore_rules",
});

function fixture(deployGroups = ["functions", "firestore-indexes"]) {
  const root = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), "catch-firebase-package-")));
  const source = path.join(root, "source");
  const output = path.join(source, "build/package");
  const functionsLibDir = path.join(source, "build/tested-functions-lib");
  fs.mkdirSync(functionsLibDir, {recursive: true});
  fs.mkdirSync(path.join(source, "functions/scripts"), {recursive: true});
  fs.mkdirSync(path.join(source, "functions/src"), {recursive: true});
  fs.mkdirSync(path.join(source, "tool/firebase"), {recursive: true});
  fs.writeFileSync(path.join(source, "firebase.json"), JSON.stringify({
    functions: {source: "functions", codebase: "default", predeploy: ["npm test"]},
    firestore: {
      database: "(default)",
      indexes: "firestore.indexes.json",
      rules: "firestore.rules",
      predeploy: ["test"],
    },
    storage: {rules: "storage.rules"},
    hosting: [{public: "dist", predeploy: ["build"]}],
    remoteconfig: {template: "remote.json"},
    extensions: {demo: "publisher/demo@1.0.0"},
  }));
  fs.writeFileSync(path.join(source, ".firebaserc"), JSON.stringify({
    projects: {dev: "catch-dev", staging: "catch-staging", prod: "catch-prod"},
    etags: {catch: {extensionInstances: {demo: "unsafe"}}},
  }));
  for (const file of ["firestore.indexes.json", "firestore.rules", "storage.rules"]) {
    fs.writeFileSync(path.join(source, file), "fixture\n");
  }
  fs.writeFileSync(path.join(source, "functions/package.json"), JSON.stringify({
    name: "functions",
    main: "lib/index.js",
    engines: {node: "24"},
    scripts: {
      build: "tsc",
      postinstall: "node unsafe.cjs",
      "sync:callable-invokers": "node scripts/set-callable-invokers-public.cjs",
    },
    dependencies: {"firebase-functions": "1.0.0"},
  }));
  fs.writeFileSync(path.join(source, "functions/package-lock.json"), "{}\n");
  fs.writeFileSync(path.join(functionsLibDir, "index.js"),
    "exports.alpha = true; exports.beta = true;\n");
  fs.writeFileSync(
    path.join(source, "functions/src/index.ts"),
    'export { alpha, beta } from "./fixture";\n',
  );
  fs.writeFileSync(
    path.join(source, "tool/firebase/list_firebase_function_targets.mjs"),
    'throw new Error("historical tooling must not execute");\n',
  );
  fs.writeFileSync(
    path.join(source, "functions/scripts/set-callable-invokers-public.cjs"),
    "module.exports = {};\n",
  );
  const impactPlanPath = path.join(root, "impact-plan.json");
  fs.writeFileSync(impactPlanPath, JSON.stringify({
    schemaVersion: "0.2.0",
    graphStatus: "required",
    mode: "main",
    complete: true,
    sourceSha,
    baseSha,
    sourceCiRunId,
    sourceCiRunAttempt,
    operations: {
      ciTargets: [...new Set(deployGroups.map((group) => requiredCiTarget[group]).filter(Boolean))],
      deployGroups,
    },
  }));
  return {root, source, output, functionsLibDir, impactPlanPath};
}

function prepare(work, overrides = {}) {
  const plan = prepareFirebaseDelivery({
    sourceRoot: work.source,
    impactPlanPath: work.impactPlanPath,
    sourceSha,
    baseSha,
    sourceCiRunId,
    sourceCiRunAttempt,
    stageDir: work.output,
    functionTargets,
    functionsLibDir: work.functionsLibDir,
    ...overrides,
  });
  const provenanceManifestPath = path.join(work.root, "firebase-provenance.json");
  fs.writeFileSync(provenanceManifestPath, JSON.stringify({
    schema: "catch.delivery-provenance/v2",
    sourceSha,
    sourceCiRunId,
    sourceCiRunAttempt,
    artifact: {name: "firebase-backend.tar.gz", sizeBytes: 1, sha256: "c".repeat(64)},
    stages: plan.stages,
  }));
  return {plan, provenanceManifestPath};
}

function verify(work, provenanceManifestPath, overrides = {}) {
  return verifyFirebaseDelivery({
    sourceRoot: work.source,
    packageDir: work.output,
    sourceSha,
    baseSha,
    sourceCiRunId,
    sourceCiRunAttempt,
    provenanceManifestPath,
    functionTargets,
    ...overrides,
  });
}

test("affected execution narrows a verified historical package without changing its bytes or stages", (t) => {
  const work = fixture();
  t.after(() => fs.rmSync(work.root, {recursive: true, force: true}));
  const git = (...args) => execFileSync("git", ["-C", work.source, ...args], {encoding: "utf8"}).trim();
  git("init", "-q");
  git("config", "user.name", "Delivery test");
  git("config", "user.email", "delivery-test@example.invalid");
  fs.writeFileSync(path.join(work.source, "functions/tsconfig.json"), '{"compilerOptions":{"rootDir":"src"}}');
  fs.writeFileSync(path.join(work.source, "functions/src/index.ts"),
    'export {alpha} from "./alpha"; export {beta} from "./beta";');
  for (const name of ["alpha", "beta"]) {
    fs.writeFileSync(path.join(work.source, `functions/src/${name}.ts`), `export const ${name} = 1;`);
  }
  git("add", ".");
  git("commit", "-qm", "base", "--no-verify");
  const actualBase = git("rev-parse", "HEAD");
  fs.writeFileSync(path.join(work.source, "functions/src/alpha.ts"), "export const alpha = 2;");
  git("add", ".");
  git("commit", "-qm", "alpha update", "--no-verify");
  const actualSource = git("rev-parse", "HEAD");
  const impact = JSON.parse(fs.readFileSync(work.impactPlanPath, "utf8"));
  impact.baseSha = actualBase;
  impact.sourceSha = actualSource;
  fs.writeFileSync(work.impactPlanPath, JSON.stringify(impact));
  const binding = {baseSha: actualBase, sourceSha: actualSource};
  const {plan, provenanceManifestPath} = prepare(work, binding);
  const provenance = JSON.parse(fs.readFileSync(provenanceManifestPath, "utf8"));
  provenance.sourceSha = actualSource;
  fs.writeFileSync(provenanceManifestPath, JSON.stringify(provenance));
  const inventoryBefore = fs.readFileSync(path.join(work.output, "delivery-inventory.json"));
  const planBefore = fs.readFileSync(path.join(work.output, "delivery-plan.json"));
  const result = verify(work, provenanceManifestPath, {...binding, selectAffectedFunctions: true});
  assert.equal(result.functionSelection.mode, "affected");
  assert.deepEqual(result.targets, ["firestore:indexes", "functions:alpha"]);
  assert.deepEqual(result.stages, plan.stages);
  assert.deepEqual(fs.readFileSync(path.join(work.output, "delivery-inventory.json")), inventoryBefore);
  assert.deepEqual(fs.readFileSync(path.join(work.output, "delivery-plan.json")), planBefore);
  assert.deepEqual(verify(work, provenanceManifestPath, binding).targets, plan.targets);
  fs.appendFileSync(path.join(work.output, "functions/lib/index.js"), "\ntampered()");
  assert.throws(() => verify(work, provenanceManifestPath, {
    ...binding, selectAffectedFunctions: true,
  }), /inventory/);
});

test("creates a canonical bounded no-predeploy Firebase configuration", () => {
  const config = createBoundedFirebaseConfig({
    functions: {source: "functions", codebase: "default", predeploy: ["build"]},
    firestore: {
      database: "(default)",
      indexes: "firestore.indexes.json",
      rules: "firestore.rules",
      predeploy: ["test"],
    },
    hosting: [{public: "dist"}],
    extensions: {demo: "demo"},
  }, ["functions", "firestore:indexes"]);
  assert.deepEqual(config, {
    functions: {source: "functions", codebase: "default"},
    firestore: {database: "(default)", indexes: "firestore.indexes.json"},
  });
  assert.doesNotMatch(JSON.stringify(config), /predeploy|hosting|extensions|rules/);
});

test("packages the tested Functions output and exact bounded CI plan once", (t) => {
  const work = fixture();
  t.after(() => fs.rmSync(work.root, {recursive: true, force: true}));
  const {plan, provenanceManifestPath} = prepare(work);
  assert.deepEqual(plan.stages, ["firestore-indexes", "functions"]);
  assert.ok(fs.existsSync(path.join(work.output, "functions/lib/index.js")));
  assert.ok(fs.existsSync(path.join(work.output, "firestore.indexes.json")));
  assert.equal(fs.existsSync(path.join(work.output, "firestore.rules")), false);
  assert.ok(fs.existsSync(path.join(work.output, "delivery-inventory.json")));
  assert.deepEqual(readJson(path.join(work.output, ".firebaserc")), {
    projects: {dev: "catch-dev", staging: "catch-staging", prod: "catch-prod"},
  });
  assert.deepEqual(readJson(path.join(work.output, "functions/package.json")).scripts, {
    "sync:callable-invokers": "node scripts/set-callable-invokers-public.cjs",
  });
  assert.deepEqual(verify(work, provenanceManifestPath), plan);
});

test("verification rejects payload tampering and every delivery binding mismatch", (t) => {
  const work = fixture(["functions"]);
  t.after(() => fs.rmSync(work.root, {recursive: true, force: true}));
  const {provenanceManifestPath} = prepare(work);
  for (const [key, value, pattern] of [
    ["sourceSha", "c".repeat(40), /sourceSha/],
    ["baseSha", "d".repeat(40), /baseSha/],
    ["sourceCiRunId", "999", /sourceCiRunId/],
    ["sourceCiRunAttempt", "3", /sourceCiRunAttempt/],
  ]) {
    assert.throws(() => verify(work, provenanceManifestPath, {[key]: value}), pattern);
  }
  fs.appendFileSync(path.join(work.output, "impact-plan.json"), " \n");
  assert.throws(() => verify(work, provenanceManifestPath), /inventory/);
});

test("automatic packaging rejects untrusted or under-validated deployment groups", (t) => {
  const untrusted = fixture(["remoteconfig"]);
  t.after(() => fs.rmSync(untrusted.root, {recursive: true, force: true}));
  assert.throws(() => prepare(untrusted), /not allowed/);

  const underValidated = fixture(["functions"]);
  t.after(() => fs.rmSync(underValidated.root, {recursive: true, force: true}));
  const impact = readJson(underValidated.impactPlanPath);
  impact.operations.ciTargets = [];
  fs.writeFileSync(underValidated.impactPlanPath, JSON.stringify(impact));
  assert.throws(() => prepare(underValidated), /requires successful 'functions'/);
});

test("stage preparation refuses authored, existing, overlapping, and symlinked paths before deletion", (t) => {
  const work = fixture(["firestore-indexes"]);
  t.after(() => fs.rmSync(work.root, {recursive: true, force: true}));
  const marker = path.join(work.source, "marker.txt");
  fs.writeFileSync(marker, "keep\n");
  for (const unsafeStage of [
    work.source,
    path.join(work.source, "firebase-package"),
    path.join(work.source, "build"),
  ]) {
    assert.throws(() => prepare(work, {stageDir: unsafeStage}), /stageDir|descendant|already exist/);
    assert.equal(fs.readFileSync(marker, "utf8"), "keep\n");
  }
  const alias = path.join(work.source, "build-alias");
  fs.symlinkSync(path.join(work.source, "build"), alias);
  assert.throws(() => prepare(work, {stageDir: path.join(alias, "package")}),
    /symlink|sourceRoot\/build/);
});

test("packaging rejects external Firebase paths and symlinked payload inputs", (t) => {
  const external = fixture(["functions"]);
  t.after(() => fs.rmSync(external.root, {recursive: true, force: true}));
  const config = readJson(path.join(external.source, "firebase.json"));
  config.functions.source = "../../outside-runtime";
  fs.writeFileSync(path.join(external.source, "firebase.json"), JSON.stringify(config));
  assert.throws(() => prepare(external), /canonical package-relative path/);

  const symlinked = fixture(["functions"]);
  t.after(() => fs.rmSync(symlinked.root, {recursive: true, force: true}));
  fs.symlinkSync("/etc/hosts", path.join(symlinked.functionsLibDir, "external.js"));
  assert.throws(() => prepare(symlinked), /must not be a symlink/);
});

test("verification derives Function targets from an independent expected export set", (t) => {
  const work = fixture(["functions"]);
  t.after(() => fs.rmSync(work.root, {recursive: true, force: true}));
  const {provenanceManifestPath} = prepare(work);
  assert.throws(() => verify(work, provenanceManifestPath, {
    functionTargets: ["functions:alpha", "functions:beta", "functions:gamma"],
  }), /targets do not match/);
});

test("verification reads historical exports as data without executing historical tooling", (t) => {
  const work = fixture(["functions"]);
  t.after(() => fs.rmSync(work.root, {recursive: true, force: true}));
  const {plan, provenanceManifestPath} = prepare(work);
  assert.deepEqual(verifyFirebaseDelivery({
    sourceRoot: work.source,
    packageDir: work.output,
    sourceSha,
    baseSha,
    sourceCiRunId,
    sourceCiRunAttempt,
    provenanceManifestPath,
  }), plan);
});

test("verification accepts a legacy dormant target set but returns the reduced effective plan", (t) => {
  const work = fixture(["functions"]);
  t.after(() => fs.rmSync(work.root, {recursive: true, force: true}));
  fs.writeFileSync(
    path.join(work.source, "functions/src/index.ts"),
    'export { alpha, beta, sendEventReminders } from "./fixture";\n',
  );
  fs.writeFileSync(
    path.join(work.functionsLibDir, "index.js"),
    "exports.alpha = true; exports.beta = true; exports.sendEventReminders = true;\n",
  );
  const legacyFunctionTargets = [
    "functions:alpha",
    "functions:beta",
    "functions:sendEventReminders",
  ];
  const {plan, provenanceManifestPath} = prepare(work, {
    functionTargets: legacyFunctionTargets,
  });
  assert.match(plan.targets[0], /functions:sendEventReminders/u);

  const effectivePlan = verifyFirebaseDelivery({
    sourceRoot: work.source,
    packageDir: work.output,
    sourceSha,
    baseSha,
    sourceCiRunId,
    sourceCiRunAttempt,
    provenanceManifestPath,
  });
  assert.deepEqual(effectivePlan.targets, ["functions:alpha,functions:beta"]);
  assert.deepEqual(
    {...effectivePlan, targets: plan.targets},
    plan,
  );
});

test("combined verification rejects reordered, omitted, or extra provenance stages", (t) => {
  const work = fixture();
  t.after(() => fs.rmSync(work.root, {recursive: true, force: true}));
  const {plan, provenanceManifestPath} = prepare(work);
  for (const stages of [
    [...plan.stages].reverse(),
    plan.stages.slice(0, 1),
    [...plan.stages, "firestore-rules"],
  ]) {
    const provenance = readJson(provenanceManifestPath);
    provenance.stages = stages;
    fs.writeFileSync(provenanceManifestPath, JSON.stringify(provenance));
    assert.throws(() => verify(work, provenanceManifestPath), /stages do not exactly match/);
  }
});

test("a disposable runtime tree may add only node_modules while authored bytes stay exact", (t) => {
  const work = fixture(["functions"]);
  t.after(() => fs.rmSync(work.root, {recursive: true, force: true}));
  const {plan, provenanceManifestPath} = prepare(work);
  const deployTree = path.join(work.source, "build/deploy-tree");
  fs.cpSync(work.output, deployTree, {recursive: true});
  fs.mkdirSync(path.join(deployTree, "functions/node_modules/demo"), {recursive: true});
  fs.writeFileSync(path.join(deployTree, "functions/node_modules/demo/index.js"), "module.exports = 1;\n");
  fs.mkdirSync(path.join(deployTree, "functions/node_modules/.bin"), {recursive: true});
  fs.symlinkSync("../demo/index.js", path.join(deployTree, "functions/node_modules/.bin/demo"));
  assert.deepEqual(verify(work, provenanceManifestPath, {
    packageDir: deployTree,
    allowRuntimeDependencies: true,
    trustedPackageDir: work.output,
  }), plan);

  fs.appendFileSync(path.join(deployTree, "functions/lib/index.js"), "// mutated\n");
  assert.throws(() => verify(work, provenanceManifestPath, {
    packageDir: deployTree,
    allowRuntimeDependencies: true,
    trustedPackageDir: work.output,
  }), /inventory/);

  fs.copyFileSync(
    path.join(work.output, "functions/lib/index.js"),
    path.join(deployTree, "functions/lib/index.js"),
  );
  fs.writeFileSync(path.join(deployTree, "unexpected.txt"), "no\n");
  assert.throws(() => verify(work, provenanceManifestPath, {
    packageDir: deployTree,
    allowRuntimeDependencies: true,
    trustedPackageDir: work.output,
  }), /inventory/);
});

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}
