import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {checkParamsCoverage, discoverDeclaredParams} from
  "./check_functions_params_coverage.mjs";

function fixture(sources) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-params-coverage-"));
  const sourceDir = path.join(directory, "src");
  fs.mkdirSync(sourceDir, {recursive: true});
  for (const [name, contents] of Object.entries(sources)) {
    const file = path.join(sourceDir, name);
    fs.mkdirSync(path.dirname(file), {recursive: true});
    fs.writeFileSync(file, contents);
  }
  return directory;
}

test("multiline declarations are discovered with their file", () => {
  const functionsDir = fixture({
    "ops/rcsLiveConfig.ts":
      'export const flag = defineBoolean(\n  "EVENT_ASSISTANCE_RCS_ENABLED", {default: false});\n',
  });
  const declared = discoverDeclaredParams(functionsDir);
  assert.deepEqual([...declared.keys()], ["EVENT_ASSISTANCE_RCS_ENABLED"]);
  assert.deepEqual(declared.get("EVENT_ASSISTANCE_RCS_ENABLED"),
    [path.join("src", "ops", "rcsLiveConfig.ts")]);
});

test("defineSecret declarations are excluded from dotenv coverage", () => {
  const functionsDir = fixture({
    "secrets.ts":
      'export const key = defineSecret(\n  "ORGANIZER_WHATSAPP_ACCESS_TOKENS"\n);\n',
  });
  const declared = discoverDeclaredParams(functionsDir);
  assert.equal(declared.size, 0);
  const result = checkParamsCoverage({functionsDir});
  assert.deepEqual(result.uncovered, []);
});

test("a declared param missing from the materialized set fails", () => {
  const functionsDir = fixture({
    "newFeature.ts": 'export const gate = defineBoolean("BRAND_NEW_GATE");\n',
  });
  const result = checkParamsCoverage({functionsDir});
  assert.deepEqual(result.uncovered, [{
    name: "BRAND_NEW_GATE",
    files: [path.join("src", "newFeature.ts")],
  }]);
});

test("materialized params pass coverage", () => {
  const functionsDir = fixture({
    "search.ts":
      'export const appId = defineString("ALGOLIA_APPLICATION_ID");\n' +
      'export const rcs = defineBoolean("EVENT_ASSISTANCE_RCS_ENABLED", {default: false});\n',
  });
  const result = checkParamsCoverage({functionsDir});
  assert.deepEqual(result.uncovered, []);
  assert.equal(result.declared.size, 2);
});

test("env-file mode requires every declared param to have a value", () => {
  const functionsDir = fixture({
    "flags.ts":
      'export const rcs = defineBoolean("EVENT_ASSISTANCE_RCS_ENABLED");\n' +
      'export const sms = defineBoolean("EVENT_ASSISTANCE_SMS_REPORTS_ENABLED");\n',
  });
  const envFile = path.join(functionsDir, ".env.demo-project");
  fs.writeFileSync(envFile, 'EVENT_ASSISTANCE_RCS_ENABLED="false"\n');
  const incomplete = checkParamsCoverage({functionsDir, envFile});
  assert.deepEqual(incomplete.uncovered, []);
  assert.deepEqual(incomplete.envMissing, ["EVENT_ASSISTANCE_SMS_REPORTS_ENABLED"]);
  fs.writeFileSync(envFile,
    'EVENT_ASSISTANCE_RCS_ENABLED="false"\nEVENT_ASSISTANCE_SMS_REPORTS_ENABLED="true"\n');
  const complete = checkParamsCoverage({functionsDir, envFile});
  assert.deepEqual(complete.envMissing, []);
});

test("env-file mode fails closed when the dotenv file is absent", () => {
  const functionsDir = fixture({
    "flags.ts": 'export const rcs = defineBoolean("EVENT_ASSISTANCE_RCS_ENABLED");\n',
  });
  assert.throws(() => checkParamsCoverage({
    functionsDir,
    envFile: path.join(functionsDir, ".env.missing"),
  }), /dotenv file is missing/);
});


test("source parsing supports aliases, namespaces, generic calls and every scalar type", () => {
  const functionsDir = fixture({
    "params.ts": `import {defineBoolean as flag} from "firebase-functions/params";
import * as params from "firebase-functions/params";
const one = flag("ONE");
const two = params.defineFloat("TWO");
const three = defineString<string>("THREE");
const four = defineInt /* comment */ ("FOUR");
const five = defineList(\`FIVE\`);
// defineString("COMMENT_ONLY")
const text = 'defineString("STRING_ONLY")';
const secret = params.defineSecret("NOT_DOTENV");
`,
  });
  assert.deepEqual([...discoverDeclaredParams(functionsDir).keys()],
    ["ONE", "TWO", "THREE", "FOUR", "FIVE"]);
});

test("dynamic names and invalid source fail closed", () => {
  for (const source of [
    'const gate = defineBoolean(dynamicName);',
    'const gate = defineBoolean("prefix" + name);',
    'const gate = defineBoolean(',
  ]) {
    assert.throws(() => discoverDeclaredParams(fixture({"params.ts": source})),
      /literal name|Unable to parse/);
  }
});

test("empty dotenv values fail coverage and duplicate keys fail closed", () => {
  const functionsDir = fixture({
    "params.ts": 'const id = defineString("ALGOLIA_APPLICATION_ID");',
  });
  const envFile = path.join(functionsDir, ".env.demo-project");
  for (const value of ["", '""', "''", "# comment"]) {
    fs.writeFileSync(envFile, `ALGOLIA_APPLICATION_ID=${value}\n`);
    assert.deepEqual(checkParamsCoverage({functionsDir, envFile}).envMissing,
      ["ALGOLIA_APPLICATION_ID"]);
  }
  fs.writeFileSync(envFile, 'ALGOLIA_APPLICATION_ID="valid"\nALGOLIA_APPLICATION_ID=\n');
  assert.throws(() => checkParamsCoverage({functionsDir, envFile}), /Duplicate dotenv/);
});


test("indirect factory references cannot silently escape coverage", () => {
  for (const source of [
    'import {defineBoolean as flag} from "firebase-functions/params"; const factory = flag;',
    'import * as params from "firebase-functions/params"; const factory = params.defineString;',
    'import * as params from "firebase-functions/params"; params["defineString"]("HIDDEN");',
  ]) {
    assert.throws(() => discoverDeclaredParams(fixture({"params.ts": source})),
      /called directly|explicit members/);
  }
});
