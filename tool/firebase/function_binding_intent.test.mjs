import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import test from "node:test";
import {collectFunctionBindingIntent, runCli} from "./function_binding_intent.mjs";

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const base = {environment: "dev", projectId: "test-project", projectNumber: "123456",
  sourceSha: "a".repeat(40), consumers: ["selected"]};
const imports = `import {onRequest as request} from "firebase-functions/v2/https";
import {defineSecret as secret} from "firebase-functions/params";`;
const unresolved = /^Error: Function binding intent is unresolved\.$/u;
function fixture(t, files) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "function-binding-intent-"));
  t.after(() => fs.rmSync(root, {recursive: true, force: true}));
  for (const [name, content] of Object.entries(files)) {
    const filename = path.join(root, "functions/src", name);
    fs.mkdirSync(path.dirname(filename), {recursive: true});
    fs.writeFileSync(filename, content);
  }
  fs.writeFileSync(path.join(root, "functions/package-lock.json"), JSON.stringify({
    packages: {"node_modules/firebase-functions": {version: "7.4.0"}},
  }));
  return root;
}
const collect = (sourceRoot, overrides = {}) =>
  collectFunctionBindingIntent({...base, sourceRoot, ...overrides});

test("literal options, aliases, imports and spreads yield only binding names", (t) => {
  const sourceRoot = fixture(t, {
    "index.ts": `import {setGlobalOptions} from "firebase-functions";
      setGlobalOptions({secrets: ["GLOBAL_SECRET"], serviceAccount: "global-reader@"});
      export {impl as selected} from "./consumer";`,
    "consumer.ts": `${imports}
      import {key} from "./keys";
      const local = {serviceAccount: null, secrets: [key], labels: {private: "FAKE_PAYLOAD"}};
      export const impl = request({...local, timeoutSeconds: 30}, () => {});`,
    "keys.ts": `import {defineSecret} from "firebase-functions/params";
      export const key = defineSecret("LOCAL_SECRET");`,
    ".env.local": "FAKE_PRIVATE_FILE_DO_NOT_READ",
  });
  assert.deepEqual(collect(sourceRoot), {
    schemaVersion: 1, environment: base.environment, projectId: base.projectId,
    projectNumber: base.projectNumber, sourceSha: base.sourceSha,
    functions: [{consumer: "selected", platform: "gcfv2",
      serviceAccount: "123456-compute@developer.gserviceaccount.com",
      secretNames: ["LOCAL_SECRET"]}],
  });
  const output = JSON.stringify(collect(sourceRoot));
  for (const forbidden of ["FAKE_PAYLOAD", "FAKE_PRIVATE_FILE", "labels", "sourceRoot"])
    assert.equal(output.includes(forbidden), false);
});

test("known helper bodies and form identity shorthand are inspected, not assumed", (t) => {
  const sourceRoot = fixture(t, {
    "index.ts": `export {selected} from "./consumer";`,
    "consumer.ts": `${imports}
      import {appCheckCallableOptionsForFormUpload} from "./shared/organizerFormUploadIdentity";
      export const selected = request(appCheckCallableOptionsForFormUpload({secrets:["EXACT_SECRET"]}), () => {});`,
    "shared/callableOptions.ts": `export function appCheckCallableOptionsWithLimits(limits) {
      return {enforceAppCheck: true, ...limits}; }`,
    "shared/organizerFormUploadIdentity.ts": `import {appCheckCallableOptionsWithLimits} from "./callableOptions";
      export function appCheckCallableOptionsForFormUpload(limits) {
      return {...appCheckCallableOptionsWithLimits(limits), serviceAccount: "catch-form-upload@"}; }`,
  });
  assert.deepEqual(collect(sourceRoot).functions[0], {
    consumer: "selected", platform: "gcfv2",
    serviceAccount: "catch-form-upload@test-project.iam.gserviceaccount.com",
    secretNames: ["EXACT_SECRET"],
  });
  fs.appendFileSync(path.join(sourceRoot, "functions/src/shared/callableOptions.ts"),
    "\nappCheckCallableOptionsWithLimits = () => ({secrets:[]});");
  assert.throws(() => collect(sourceRoot), unresolved);
});

test("static collection never executes initialization, I/O, handlers or env reads", (t) => {
  const sourceRoot = fixture(t, {"index.ts": `${imports}
    import fs from "node:fs";
    fs.readFileSync("/private/not-a-real-credential");
    globalThis.fetch("https://network-call-must-never-run.invalid");
    throw new Error("FAKE_SECRET_SENTINEL");
    export const selected = request({labels:{value:process.env.FAKE_PRIVATE}}, () => {throw new Error("no");});`});
  const result = collect(sourceRoot);
  assert.deepEqual(result.functions[0].secretNames, []);
  const script = path.join(repo, "tool/firebase/function_binding_intent.mjs");
  const child = spawnSync(process.execPath, [script, "--source-root", sourceRoot,
    "--env", "dev", "--project", "test-project", "--project-number", "123456",
    "--source-sha", base.sourceSha, "--consumers", "selected"], {
    encoding: "utf8", env: {}, timeout: 10000,
  });
  assert.equal(child.status, 0);
  assert.deepEqual(JSON.parse(child.stdout), result);
  assert.equal(child.stderr, "");
});

test("unknown option helpers, spreads and dynamic identities fail closed", (t) => {
  for (const expression of ["unknown()", "{...process.env}",
    "{serviceAccount: process.env.FAKE_PRIVATE}", "{serviceAccount: `reader@${process.env.PROJECT}.iam.gserviceaccount.com`}",
    "{secrets: [process.env.FAKE_PRIVATE]}", "{secrets: [secret(process.env.FAKE_PRIVATE)]}",
    "{['service' + 'Account']: 'reader@'}", "{get serviceAccount(){return 'reader@';}}",
    "{preserveExternalChanges:true}", "{preserveExternalChanges:'truthy'}", "{omit:true}",
    "{secrets:['EXACT_SECRET','EXACT_SECRET']}", "{serviceAccount: {expression:'unknown'}}"]) {
    const sourceRoot = fixture(t, {"index.ts": `${imports}
      export const selected = request(${expression}, () => {});`});
    assert.throws(() => collect(sourceRoot), unresolved);
  }
});

test("source option mutation and escaping references cannot masquerade as literals", (t) => {
  for (const mutation of ["options.serviceAccount = 'different-reader@';",
    "options.secrets.push('OTHER_SECRET');", "delete options.serviceAccount;",
    "Object.assign(options, {serviceAccount:'different-reader@'});", "unknown(options);"]) {
    const sourceRoot = fixture(t, {"index.ts": `${imports}
      const options={serviceAccount:'reader@', secrets:[]};
      ${mutation}
      export const selected=request(options,()=>{});`});
    assert.throws(() => collect(sourceRoot), unresolved);
  }
});

test("unresolved, v1, malformed and circular exports never infer default identity", (t) => {
  for (const source of [`export {selected} from './missing';`,
    `export const selected = () => {};`,
    `import {onRequest as request} from 'firebase-functions/v1/https';
      export const selected=request({},()=>{});`,
    `${imports} const a=b; const b=a; export const selected=request(a,()=>{});`,
    `${imports} export const selected=request({},()=>{}); export const selected=1;`]) {
    assert.throws(() => collect(fixture(t, {"index.ts": source})), unresolved);
  }
});

test("global option ordering and other-module global setters are unsupported", (t) => {
  for (const files of [
    {"index.ts": `export {selected} from './consumer';
      import {setGlobalOptions} from 'firebase-functions';
      setGlobalOptions({serviceAccount:'reader@'});`,
    "consumer.ts": `${imports} export const selected=request(()=>{});`},
    {"index.ts": `${imports} export const selected=request(()=>{});`,
      "other.ts": `import {setGlobalOptions} from 'firebase-functions'; setGlobalOptions({});`},
  ]) assert.throws(() => collect(fixture(t, files)), unresolved);
});

test("missing provenance inputs, private path imports and raw errors stay opaque", (t) => {
  const sourceRoot = fixture(t, {"index.ts": `${imports}
    export const selected=request({},()=>{});`});
  for (const overrides of [{sourceSha: ""}, {projectNumber: "unknown"},
    {projectId: "private value"}, {consumers: []}, {consumers: ["selected","selected"]},
    {consumers: ["FAKE_PRIVATE\n"]}, {environment: "other"}]) {
    assert.throws(() => collect(sourceRoot, overrides), unresolved);
  }
  assert.throws(() => runCli(["--unknown", "FAKE_PRIVATE"]), unresolved);
  fs.writeFileSync(path.join(sourceRoot, "functions/src/index.ts"),
    `export {selected} from '../../../FAKE_PRIVATE';`);
  assert.throws(() => collect(sourceRoot), unresolved);
});

test("current manifest consumers and direct readers resolve from current source", () => {
  const manifest = JSON.parse(fs.readFileSync(path.join(repo,
    "tool/firebase/environment_readiness.json"), "utf8"));
  const consumers = [...new Set(manifest.requirements
    .filter((r) => r.kind === "secret-version")
    .flatMap((r) => r.requiredWhen.anyDeployTarget ?? [])
    .filter((v) => v.startsWith("functions:")).map((v) => v.slice(10)))];
  assert.ok(consumers.length > 0);
  consumers.push("refreshProgramFlightStatuses", "refreshProgramTravelLeg",
    "eventAssistanceRcsWebhook", "onAssistanceWorkChanged",
    "evaluateDueEventAssistanceWork", "adminSendCatchWhatsappReply");
  const result = collect(repo, {consumers: [...new Set(consumers)]});
  assert.equal(result.functions.length, new Set(consumers).size);
  const byName = new Map(result.functions.map((f) => [f.consumer, f]));
  assert.deepEqual(byName.get("createRazorpayOrder").secretNames, ["RAZORPAY_KEY_SECRET"]);
  assert.deepEqual(byName.get("stripeWebhook").secretNames, ["STRIPE_SECRET_KEY", "STRIPE_WEBHOOK_SECRET"]);
  assert.deepEqual(byName.get("refreshProgramFlightStatuses").secretNames, []);
  // Readiness used to require payment keys here after source moved refunds out.
  assert.deepEqual(byName.get("cancelEvent").secretNames, []);
  for (const row of result.functions) {
    assert.deepEqual(Object.keys(row), ["consumer", "platform", "serviceAccount", "secretNames"]);
    assert.equal(row.serviceAccount, "123456-compute@developer.gserviceaccount.com");
  }
});

test("literal readiness manifest matches selected source consumers", () => {
  const manifest = JSON.parse(fs.readFileSync(path.join(repo,
    "tool/firebase/environment_readiness.json"), "utf8"));
  const requirements = manifest.requirements.filter((r) => r.kind === "secret-version");
  const consumers = [...new Set([
    ...requirements.flatMap((r) => r.requiredWhen.anyDeployTarget ?? [])
      .filter((v) => v.startsWith("functions:")).map((v) => v.slice(10)),
    // Source regressions: these existing secret consumers were omitted entirely.
    "reviewOrganizerApplication", "convertOrganizerFormResponse",
    "onOrganizerFormResponseAutomated", "onOrganizerApplicationAutomated",
    "onOrganizerAttendanceAutomated", "retryOrganizerAutomations",
    "sendOrganizerWhatsappReply", "onNativeCancellationRefund",
    "recoverNativeCancellationRefunds",
  ])];
  assert.ok(consumers.length > 0);
  const intent = collect(repo, {consumers});
  const mismatches = intent.functions.flatMap((row) => {
    const declared = requirements.filter((r) =>
      r.requiredWhen.anyDeployTarget?.includes(`functions:${row.consumer}`))
      .map((r) => r.name).sort();
    return JSON.stringify(declared) === JSON.stringify(row.secretNames) ? [] :
      [{consumer: row.consumer, manifest: declared, source: row.secretNames}];
  });
  assert.deepEqual(mismatches, [], "Literal readiness must follow authored source bindings");
});


test("unreviewed SDK semantics cannot establish a source default identity", (t) => {
  const sourceRoot = fixture(t, {"index.ts": `${imports}
    export const selected=request({},()=>{});`});
  fs.writeFileSync(path.join(sourceRoot, "functions/package-lock.json"),
    JSON.stringify({packages:{"node_modules/firebase-functions":{version:"99.0.0"}}}));
  assert.throws(() => collect(sourceRoot), unresolved);
});
