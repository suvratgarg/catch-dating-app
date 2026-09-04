import assert from "node:assert/strict";
import {execFileSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {affectedFunctionTargets, productionPromotionEnvironment} from "./affected_function_targets.mjs";

const targets = ["functions:alpha", "functions:alphaAlias", "functions:beta", "functions:gamma"];

function fixture(t) {
  const root = fs.mkdtempSync(path.join(fs.realpathSync(os.tmpdir()), "affected-functions-"));
  t.after(() => fs.rmSync(root, {recursive: true, force: true}));
  const git = (...args) => execFileSync("git", ["-C", root, ...args], {encoding: "utf8"}).trim();
  git("init", "-q");
  git("config", "user.name", "Delivery test");
  git("config", "user.email", "delivery-test@example.invalid");
  const write = (name, text) => {
    const file = path.join(root, name);
    fs.mkdirSync(path.dirname(file), {recursive: true});
    fs.writeFileSync(file, text);
  };
  const files = {
    "functions/src/index.ts": [
      'import {setGlobalOptions} from "firebase-functions";',
      'import "./bootstrap";',
      'setGlobalOptions({region: "asia-south1"});',
      'export {alpha, alpha as alphaAlias} from "./alpha";',
      'export {beta} from "./beta";',
      'export {gamma} from "./gamma";',
    ].join("\n"),
    "functions/src/bootstrap.ts": 'import {config} from "./config"; console.log(config);',
    "functions/src/config.ts": "export const config = 1;",
    "functions/src/alpha.ts": 'import {shared} from "./shared"; export const alpha = shared;',
    "functions/src/beta.ts": 'import {shared} from "./shared"; export const beta = shared;',
    "functions/src/gamma.ts": "export const gamma = 1;",
    "functions/src/shared.ts": 'export {value as shared} from "./nested.js";',
    "functions/src/nested.ts": "export const value = 1;",
    "functions/package.json": '{"engines":{"node":"22"}}',
    "functions/tsconfig.json": '{"compilerOptions":{"rootDir":"src","module":"NodeNext"}}',
  };
  Object.entries(files).forEach(([name, text]) => write(name, text));
  const commit = () => {
    git("add", ".");
    git("commit", "-qm", "fixture", "--no-verify");
    return git("rev-parse", "HEAD");
  };
  const base = commit();
  const select = (options = {}) => affectedFunctionTargets({
    sourceRoot: root, baseSha: base, sourceSha: commit(), authorizedTargets: targets, ...options,
  });
  return {root, git, write, files, commit, base, select};
}

test("feature changes select its module exports and aliases, preserving package order", (t) => {
  const f = fixture(t);
  f.write("functions/src/alpha.ts", f.files["functions/src/alpha.ts"] + "\nconsole.log('updated');");
  const result = f.select();
  assert.equal(result.mode, "affected");
  assert.deepEqual(result.targets, targets.slice(0, 2));
});

test("shared transitive and re-export dependencies select every affected function", (t) => {
  const f = fixture(t);
  f.write("functions/src/nested.ts", "export const value = 2;");
  assert.deepEqual(f.select().targets, targets.slice(0, 3));
});

test("new and retargeted exports are selected without redeploying unrelated functions", (t) => {
  const f = fixture(t);
  f.write("functions/src/delta.ts", "export const delta = 1;");
  f.write("functions/src/index.ts",
    f.files["functions/src/index.ts"].replace("alpha, alpha as alphaAlias", "alpha") +
    '\nexport {beta as alphaAlias} from "./beta";\nexport {delta} from "./delta";');
  const result = f.select({authorizedTargets: [...targets, "functions:delta"]});
  assert.deepEqual(result.targets, ["functions:alphaAlias", "functions:delta"]);
});

test("test-only changes are explicit no-ops and do not broaden an empty target set", (t) => {
  const f = fixture(t);
  f.write("functions/test/alpha.test.ts", "it('test', () => {});");
  f.write("functions/src/unreachable.test.ts", "const x = require(dynamicName);");
  const result = f.select();
  assert.equal(result.mode, "no-op");
  assert.deepEqual(result.targets, []);
});

test("selection uses exact committed source and the whole base-to-source window", (t) => {
  const f = fixture(t);
  f.write("functions/src/alpha.ts", "export const alpha = 2;");
  f.commit();
  f.write("functions/src/gamma.ts", "export const gamma = 2;");
  const source = f.commit();
  f.write("functions/src/index.ts", "THIS DIRTY FILE MUST NOT BE READ");
  const result = affectedFunctionTargets({
    sourceRoot: f.root, baseSha: f.base, sourceSha: source, authorizedTargets: targets,
  });
  assert.deepEqual(result.targets, ["functions:alpha", "functions:alphaAlias", "functions:gamma"]);
});

test("removing an import selects its changed consumer; cycles terminate", (t) => {
  const f = fixture(t);
  f.write("functions/src/alpha.ts", "export const alpha = 2;");
  f.write("functions/src/nested.ts", 'import "./shared"; export const value = 2;');
  assert.deepEqual(f.select().targets, targets.slice(0, 3));
});

for (const [label, file, content] of [
  ["dependency lock", "functions/package-lock.json", "{}"],
  ["runtime", "functions/package.json", '{"engines":{"node":"24"}}'],
  ["compiler settings", "functions/tsconfig.json", "{}"],
  ["deploy config", "firebase.json", "{}"],
  ["runtime asset", "functions/src/template.html", "<b>Updated</b>"],
  ["global initialization", "functions/src/index.ts", 'console.log("global");'],
  ["global dependency", "functions/src/config.ts", "export const config = 2;"],
  ["unresolved import", "functions/src/alpha.ts", 'import "./missing"; export const alpha = 2;'],
  ["dynamic require", "functions/src/alpha.ts", 'const x = require(process.env.MODULE); export const alpha = x;'],
]) {
  test(`${label} retains the full authorized target set`, (t) => {
    const f = fixture(t);
    f.write(file, content);
    const result = f.select();
    assert.equal(result.mode, "full");
    assert.deepEqual(result.targets, targets);
  });
}

test("cumulative snapshots remain full and disabled targets cannot be added", (t) => {
  const f = fixture(t);
  f.write("functions/src/alpha.ts", "export const alpha = 2;");
  const limited = ["functions:alpha"];
  assert.deepEqual(f.select({fullSnapshot: true, authorizedTargets: limited}).targets, limited);
  assert.deepEqual(affectedFunctionTargets({
    sourceRoot: f.root, baseSha: f.base, sourceSha: f.base, authorizedTargets: limited,
  }).targets, limited);
});

test("pre-existing compiler aliases cannot hide dependencies from a later release", (t) => {
  const f = fixture(t);
  f.write("functions/tsconfig.json", '{"compilerOptions":{"paths":{"@internal/*":["src/*"]}}}');
  const base = f.commit();
  f.write("functions/src/alpha.ts", "export const alpha = 2;");
  const result = f.select({baseSha: base});
  assert.equal(result.mode, "full");
  assert.match(result.reason, /module resolution/);
});

test("missing commits and a non-ancestor base fail before target selection", (t) => {
  const f = fixture(t);
  f.write("functions/src/alpha.ts", "export const alpha = 2;");
  const source = f.commit();
  assert.throws(() => affectedFunctionTargets({
    sourceRoot: f.root, baseSha: source, sourceSha: f.base, authorizedTargets: targets,
  }));
  assert.throws(() => affectedFunctionTargets({
    sourceRoot: f.root, baseSha: "f".repeat(40), sourceSha: source, authorizedTargets: targets,
  }));
});

test("whole type-only imports, exports and import-equals do not create runtime edges", (t) => {
  const f = fixture(t);
  f.write("functions/src/alpha.ts", 'import type {Shape} from "./types"; export const alpha = 1;');
  f.write("functions/src/beta.ts", 'export type {Shape} from "./types"; export const beta = 1;');
  f.write("functions/src/gamma.ts", 'import type Types = require("./types"); export const gamma = 1;');
  f.write("functions/src/types.ts", 'export interface Shape {name: string}');
  const base = f.commit();
  f.write("functions/src/types.ts", 'export interface Shape {name: string; id: string}');
  assert.deepEqual(f.select({baseSha: base}).targets, []);
});

test("mixed and inline type imports retain runtime evaluation dependencies", (t) => {
  const f = fixture(t);
  f.write("functions/src/alpha.ts", 'import {type Shape, value} from "./types"; export const alpha = value;');
  f.write("functions/src/beta.ts", 'import {type Shape} from "./types"; export const beta = 1;');
  f.write("functions/src/types.ts", 'export interface Shape {name: string}; export const value = 1;');
  const base = f.commit();
  f.write("functions/src/types.ts", 'export interface Shape {name: string}; export const value = 2;');
  assert.deepEqual(f.select({baseSha: base}).targets, targets.slice(0, 3));
});

function modularSchemaFixture(t) {
  const f = fixture(t);
  for (const module of ["getOrganizerContactDetailInput", "createRazorpayOrderInput"]) {
    for (const folder of ["schemas", "validators"]) {
      const name = `functions/src/shared/generated/${folder}/${module}.ts`;
      f.write(name, fs.readFileSync(new URL(`../../${name}`, import.meta.url), "utf8"));
    }
  }
  const runtime = "functions/src/shared/generated/schemaValidationRuntime.ts";
  f.write(runtime, fs.readFileSync(new URL(`../../${runtime}`, import.meta.url), "utf8"));
  f.write("functions/src/alpha.ts", 'import {validateGetOrganizerContactDetailCallablePayload} from "./shared/generated/validators/getOrganizerContactDetailInput"; export const alpha = validateGetOrganizerContactDetailCallablePayload;');
  f.write("functions/src/beta.ts", 'import {validateCreateRazorpayOrderCallablePayload} from "./shared/generated/validators/createRazorpayOrderInput"; export const beta = validateCreateRazorpayOrderCallablePayload;');
  const base = f.commit();
  return {...f, base, runtime};
}

test("real generated customer schema selects its consumers and excludes payment functions", (t) => {
  const f = modularSchemaFixture(t);
  const name = "functions/src/shared/generated/schemas/getOrganizerContactDetailInput.ts";
  const text = fs.readFileSync(path.join(f.root, name), "utf8");
  assert.match(text, /"contactId"/);
  f.write(name, text.replace('"contactId": {', '"contactId": {"description": "Changed contact constraint",'));
  assert.deepEqual(f.select({baseSha: f.base}).targets, targets.slice(0, 2));
});

test("shared validation runtime changes select customer and payment consumers", (t) => {
  const f = modularSchemaFixture(t);
  f.write(f.runtime, fs.readFileSync(path.join(f.root, f.runtime), "utf8") + '\n// Runtime revision\n');
  assert.deepEqual(f.select({baseSha: f.base}).targets, targets.slice(0, 3));
});


function promotionFixture(t) {
  const f = fixture(t);
  f.write("functions/src/gamma.ts", "export function gamma(value: number) { return value + 1; }");
  const base = f.commit();
  return {...f, base, policy(options = {}) {
    return productionPromotionEnvironment({
      sourceRoot: f.root, baseSha: base, sourceSha: f.commit(), stages: ["functions"], ...options,
    });
  }};
}

test("ordinary implementation updates require explicit source review", (t) => {
  const f = fixture(t);
  const before = 'import {onRequest as serve} from "firebase-functions/v2/https"; export const gamma = serve((request, response) => { response.send(1); });';
  f.write("functions/src/gamma.ts", before);
  const base = f.commit();
  f.write("functions/src/gamma.ts", before.replace('send(1)', 'send(2)'));
  assert.equal(productionPromotionEnvironment({
    sourceRoot: f.root, baseSha: base, sourceSha: f.commit(), stages: ["functions"],
  }).environment, "prod");
});

for (const [label, file, content] of [
  ["exports", "functions/src/index.ts", 'export {gamma} from "./gamma";'],
  ["initialization", "functions/src/config.ts", "export const config = 2;"],
  ["imports", "functions/src/gamma.ts", 'import "./bootstrap"; export function gamma(value: number) { return value + 2; }'],
  ["permission logic", "functions/src/gamma.ts", "export function gamma(value: number) { requirePermission(value); return value; }"],
  ["authentication logic", "functions/src/gamma.ts", "export function gamma(value: number) { return request.auth.uid; }"],
  ["secrets", "functions/src/gamma.ts", 'const key = defineSecret("KEY"); export function gamma(value: number) { return value; }'],
  ["dependency update", "functions/package.json", '{"engines":{"node":"24"}}'],
  ["migration", "tool/data/migration.mjs", "console.log('migration');"],
  ["contract", "contracts/schemas/example.json", "{}"],
  ["new source", "functions/src/newHelper.ts", "export function helper() { return 1; }"],
]) {
  test(`${label} retains protected production`, (t) => {
    const f = promotionFixture(t);
    f.write(file, content);
    assert.equal(f.policy().environment, "prod");
  });
}

test("deletions and full snapshots retain production review", (t) => {
  const f = promotionFixture(t);
  fs.unlinkSync(path.join(f.root, "functions/src/gamma.ts"));
  assert.equal(f.policy().environment, "prod");
  assert.equal(productionPromotionEnvironment({
    sourceRoot: f.root, sourceSha: f.base, baseSha: f.base,
    stages: ["functions"], fullSnapshot: true,
  }).environment, "prod");
});

test("trigger options and security bodies cannot be hidden by handler-body normalization", (t) => {
  const f = fixture(t);
  f.write("functions/src/gamma.ts", 'export const gamma = onCall({invoker: "private"}, (request) => request.data);');
  const base = f.commit();
  f.write("functions/src/gamma.ts", 'export const gamma = onCall({invoker: "public"}, (request) => request.data);');
  assert.equal(productionPromotionEnvironment({
    sourceRoot: f.root, baseSha: base, sourceSha: f.commit(), stages: ["functions"],
  }).environment, "prod");
});

test("unchanged trigger options do not replace source review", (t) => {
  const f = fixture(t);
  const sdk = 'import {onCall} from "firebase-functions/v2/https"; ';
  f.write("functions/src/gamma.ts", sdk + 'export const gamma = onCall({region: "asia-south1"}, (request) => request.data + 1);');
  const base = f.commit();
  f.write("functions/src/gamma.ts", sdk + 'export const gamma = onCall({region: "asia-south1"}, (request) => request.data + 2);');
  const head = f.commit();
  f.write("functions/src/gamma.ts", "dirty bytes must not change approval");
  assert.equal(productionPromotionEnvironment({
    sourceRoot: f.root, baseSha: base, sourceSha: head, stages: ["functions"],
  }).environment, "prod");
  assert.equal(productionPromotionEnvironment({
    sourceRoot: f.root, baseSha: base, sourceSha: head, stages: ["functions", "firestore-rules"],
  }).environment, "prod");
});

for (const declaration of [
  "export function requireAuth() { return false; }",
  "export const enforceAppCheck = () => false;",
  "export class Permissions { check() { return false; } }",
  'import {authorization} from "./helper"; export function check() { return false; }',
]) {
  test(`security ownership outside the changed body retains review: ${declaration}`, (t) => {
    const f = fixture(t);
    f.write("functions/src/gamma.ts", declaration);
    const base = f.commit();
    f.write("functions/src/gamma.ts", declaration.replace("false", "true"));
    assert.equal(productionPromotionEnvironment({
      sourceRoot: f.root, baseSha: base, sourceSha: f.commit(), stages: ["functions"],
    }).environment, "prod");
  });
}

for (const [label, before, after] of [
  ["immediately invoked option factory",
    'export const gamma = onCall({timeoutSeconds: (() => 30)()}, (request) => request.data);',
    'export const gamma = onCall({timeoutSeconds: (() => 60)()}, (request) => request.data);'],
  ["helper used by initialization",
    'function runtimeWindow() { return 30; } export const gamma = onCall({timeoutSeconds: runtimeWindow()}, (request) => request.data);',
    'function runtimeWindow() { return 60; } export const gamma = onCall({timeoutSeconds: runtimeWindow()}, (request) => request.data);'],
  ["getter used by initialization",
    'class Settings { get region() { return "asia-south1"; } } const settings = new Settings(); export const gamma = onCall({region: settings.region}, (request) => request.data);',
    'class Settings { get region() { return "us-central1"; } } const settings = new Settings(); export const gamma = onCall({region: settings.region}, (request) => request.data);'],
]) {
  test(`${label} cannot be hidden by handler-body normalization`, (t) => {
    const f = fixture(t);
    const sdk = 'import {onCall} from "firebase-functions/v2/https"; ';
    f.write("functions/src/gamma.ts", sdk + before);
    const base = f.commit();
    f.write("functions/src/gamma.ts", sdk + after);
    assert.equal(productionPromotionEnvironment({
      sourceRoot: f.root, baseSha: base, sourceSha: f.commit(), stages: ["functions"],
    }).environment, "prod");
  });
}

test("a custom factory named onCall does not establish a runtime-only handler", (t) => {
  const f = fixture(t);
  f.write("functions/src/factory.ts", "export function onCall(callback: () => number) { callback(); return callback; }");
  const before = 'import {onCall} from "./factory"; export const gamma = onCall(() => 1);';
  f.write("functions/src/gamma.ts", before);
  const base = f.commit();
  f.write("functions/src/gamma.ts", before.replace("() => 1", "() => 2"));
  assert.equal(productionPromotionEnvironment({
    sourceRoot: f.root, baseSha: base, sourceSha: f.commit(), stages: ["functions"],
  }).environment, "prod");
});


test("only a verified Functions no-op can bypass review without source approval", (t) => {
  const f = promotionFixture(t);
  f.write("functions/src/gamma.test.ts", "// test only");
  const sourceSha = f.commit();
  const policy = (options = {}) => productionPromotionEnvironment({
    sourceRoot: f.root, baseSha: f.base, sourceSha, stages: ["functions"], ...options,
  });
  assert.equal(policy({noOp: true}).environment, "prod-backend");
  assert.equal(policy({noOp: true, fullSnapshot: true}).environment, "prod");
  assert.equal(policy({noOp: true, stages: ["functions", "storage-rules"]}).environment, "prod");
  assert.equal(policy().preMergeReviewEligible, true);
});
