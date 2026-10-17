import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import {spawn, spawnSync} from "node:child_process";
import test from "node:test";
import {FileOperationsStore} from "../src/platform/storage/file-store.mjs";

const storeUrl = new URL("../src/platform/storage/file-store.mjs", import.meta.url).href;
const action = {schemaVersion: 1, actionId: "action-one", runId: "run-one",
  type: "test", at: "2026-10-17T00:00:00.000Z", actor: {kind: "test"},
  payload: {value: 1}};

// Faults are installed in a separate process at the real filesystem boundary.
// No production injection seam or provider runtime is needed for crash proof.
const worker = `
import fs from "node:fs/promises";
import {FileOperationsStore} from ${JSON.stringify(storeUrl)};
const [root, mode, kind, value] = process.argv.slice(1);
const originalWrite = fs.writeFile;
const originalLink = fs.link;
const originalRemove = fs.rm;
const selected = file => String(file).includes("/" + kind + "/");
const die = () => process.kill(process.pid, "SIGKILL");
globalThis.fetch = () => { throw new Error("Network is forbidden in this fixture"); };
fs.writeFile = async (file, content, options) => {
  if (selected(file) && ["partial-death", "write-failure", "write-cleanup-failure"].includes(mode)) {
    await originalWrite(file, String(content).slice(0, 7), options);
    if (mode === "partial-death") die();
    throw Object.assign(new Error("injected partial write"), {code: "EIO"});
  }
  return originalWrite(file, content, options);
};
fs.link = async (source, target) => {
  if (selected(target) && mode === "prelink-death") die();
  if (selected(target) && mode === "link-failure") {
    throw Object.assign(new Error("injected link failure"), {code: "EIO"});
  }
  await originalLink(source, target);
  if (selected(target) && mode === "postlink-death") die();
};
fs.rm = async (file, options) => {
  if (selected(file) && String(file).endsWith(".tmp") && mode.includes("cleanup-failure")) {
    throw Object.assign(new Error("injected cleanup failure"), {code: "EACCES"});
  }
  return originalRemove(file, options);
};
try {
  const store = await new FileOperationsStore(root).initialize();
  const input = {...${JSON.stringify(action)}, payload: {value: Number(value)}};
  const result = kind === "runs" ? await store.createRun({runId: "run-one",
    mode: "shadow", status: "planned", budget: {limits: {workItems: 1}}}) :
    kind === "idempotency" ? await store.recordIdempotency("request-one", {runId: "run-one"}) :
    await store.appendAction(input);
  console.log(JSON.stringify({ok: true, result}));
} catch (error) {
  console.log(JSON.stringify({ok: false, code: error.code, message: error.message}));
  process.exitCode = 1;
}
`;

async function fixture(t) {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "catch-publication-"));
  t.after(() => fs.rm(root, {recursive: true, force: true}));
  return root;
}

function args(root, mode = "normal", kind = "actions", value = 1) {
  return ["--input-type=module", "-e", worker, root, mode, kind, String(value)];
}

function run(root, mode = "normal", kind = "actions", value = 1) {
  const result = spawnSync(process.execPath, args(root, mode, kind, value), {
    encoding: "utf8", timeout: 10_000,
  });
  assert.equal(result.error, undefined);
  return {...result, reply: result.stdout ? JSON.parse(result.stdout) : null};
}

function concurrent(root, value) {
  return new Promise((resolve, reject) => {
    const child = spawn(process.execPath, args(root, "normal", "actions", value), {
      stdio: ["ignore", "pipe", "pipe"], timeout: 10_000,
    });
    let stdout = "";
    let stderr = "";
    child.stdout.on("data", chunk => { stdout += chunk; });
    child.stderr.on("data", chunk => { stderr += chunk; });
    child.on("error", reject);
    child.on("close", (status, signal) => {
      try {
        assert.equal(signal, null, stderr);
        resolve({status, reply: JSON.parse(stdout)});
      } catch (error) { reject(error); }
    });
  });
}

for (const kind of ["actions", "runs", "idempotency"]) {
  for (const mode of ["partial-death", "prelink-death"]) {
    test(`${kind}: death during ${mode} never publishes incomplete canonical state`, async t => {
      const root = await fixture(t);
      const crashed = run(root, mode, kind);
      assert.equal(crashed.signal, "SIGKILL", JSON.stringify(crashed.reply));
      const files = await fs.readdir(path.join(root, kind), {recursive: true});
      assert.equal(files.some(file => file.endsWith(".json")), false);
      const replay = run(root, "normal", kind);
      assert.equal(replay.status, 0, JSON.stringify(replay.reply));
      const store = new FileOperationsStore(root);
      if (kind === "actions") assert.deepEqual(await store.listActions("run-one"), [action]);
      if (kind === "runs") assert.equal((await store.getRun("run-one")).revision, 1);
      if (kind === "idempotency") assert.equal((await store.getIdempotency("request-one")).runId, "run-one");
    });
  }
}

test("death after exclusive publication retains a complete replayable action", async t => {
  const root = await fixture(t);
  assert.equal(run(root, "postlink-death").signal, "SIGKILL");
  const store = new FileOperationsStore(root);
  assert.deepEqual(await store.listActions("run-one"), [action]);
  assert.equal(run(root).status, 0);
  assert.equal(run(root, "normal", "actions", 2).reply.code, "ACTION_CONFLICT");
  assert.deepEqual(await store.listActions("run-one"), [action]);
});

test("independent concurrent writers retain exactly one immutable value", async t => {
  const root = await fixture(t);
  const results = await Promise.all([concurrent(root, 1), concurrent(root, 2)]);
  assert.equal(results.filter(result => result.status === 0).length, 1);
  assert.equal(results.find(result => result.status !== 0).reply.code, "ACTION_CONFLICT");
  const [stored] = await new FileOperationsStore(root).listActions("run-one");
  assert.ok([1, 2].includes(stored.payload.value));
  assert.equal(run(root, "normal", "actions", stored.payload.value).status, 0);
  assert.deepEqual(await fs.readdir(path.join(root, "actions", "run-one")), ["action-one.json"]);
});

test("concurrent identical writes in one process replay without temporary-name collisions", async t => {
  const root = await fixture(t);
  const store = await new FileOperationsStore(root).initialize();
  const results = await Promise.all(Array.from({length: 8}, () => store.appendAction(action)));
  assert.deepEqual(results, Array(8).fill(action));
  assert.deepEqual(await store.listActions("run-one"), [action]);
  assert.deepEqual(await fs.readdir(path.join(root, "actions", "run-one")), ["action-one.json"]);
});

test("successful publication retains private permissions and cleans temporary files", async t => {
  const root = await fixture(t);
  assert.equal(run(root).status, 0);
  const directory = path.join(root, "actions", "run-one");
  assert.deepEqual(await fs.readdir(directory), ["action-one.json"]);
  assert.equal((await fs.stat(path.join(directory, "action-one.json"))).mode & 0o777, 0o600);
});

for (const mode of ["write-failure", "link-failure"]) {
  test(`${mode} removes its incomplete temporary file and permits retry`, async t => {
    const root = await fixture(t);
    assert.equal(run(root, mode).reply.code, "EIO");
    assert.deepEqual(await fs.readdir(path.join(root, "actions", "run-one")), []);
    assert.equal(run(root).status, 0);
  });
}

test("temporary cleanup failure cannot change publication or conflict outcomes", async t => {
  const root = await fixture(t);
  assert.equal(run(root, "cleanup-failure").status, 0);
  const conflict = run(root, "cleanup-failure", "actions", 2);
  assert.equal(conflict.reply.code, "ACTION_CONFLICT");
  assert.deepEqual(await new FileOperationsStore(root).listActions("run-one"), [action]);
  assert.equal(run(root).status, 0);
});

test("temporary cleanup failure preserves the original write error", async t => {
  const root = await fixture(t);
  assert.equal(run(root, "write-cleanup-failure").reply.code, "EIO");
  assert.deepEqual(await new FileOperationsStore(root).listActions("run-one"), []);
  assert.equal(run(root).status, 0);
});

test("pre-existing corrupt canonical evidence is rejected without replacement", async t => {
  const root = await fixture(t);
  const directory = path.join(root, "actions", "run-one");
  await fs.mkdir(directory, {recursive: true});
  const file = path.join(directory, "action-one.json");
  await fs.writeFile(file, "{partial", {mode: 0o600});
  assert.equal(run(root).reply.code, "CORRUPT_STATE");
  assert.equal(await fs.readFile(file, "utf8"), "{partial");
  assert.deepEqual(await fs.readdir(directory), ["action-one.json"]);
});
