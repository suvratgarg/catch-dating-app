#!/usr/bin/env node
import {createHash, randomUUID} from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

export const PROVENANCE_SCHEMA = "catch.delivery-provenance/v2";
export const CHECKPOINT_SCHEMA = "catch.delivery-checkpoints/v2";

const SHA_RE = /^[0-9a-f]{40}$/;
const DIGEST_RE = /^[0-9a-f]{64}$/;
const RUN_ID_RE = /^[1-9][0-9]*$/;
const STAGE_RE = /^[a-z][a-z0-9._-]*$/;
const POSTCONDITION_STATUSES = new Set(["passed", "failed"]);
const MAX_SCOPE_LENGTH = 256;

export class DeliveryError extends Error {
  constructor(code, message) {
    super(message);
    this.name = "DeliveryError";
    this.code = code;
  }
}

function fail(code, message) {
  throw new DeliveryError(code, message);
}

function assertObject(value, label) {
  if (value === null || Array.isArray(value) || typeof value !== "object") {
    fail("invalid_document", `${label} must be an object.`);
  }
}

function assertKeys(value, keys, label) {
  assertObject(value, label);
  const actual = Object.keys(value).sort();
  const expected = [...keys].sort();
  if (actual.length !== expected.length ||
      actual.some((key, index) => key !== expected[index])) {
    fail("invalid_document", `${label} must contain exactly: ${expected.join(", ")}.`);
  }
}

function sourceSha(value, label = "source SHA") {
  if (typeof value !== "string" || !SHA_RE.test(value)) {
    fail("invalid_source_sha", `${label} must be exactly 40 lowercase hexadecimal characters.`);
  }
  return value;
}

function sourceCiRunId(value, label = "source CI run id") {
  const normalized = typeof value === "number" && Number.isSafeInteger(value)
    ? String(value)
    : value;
  if (typeof normalized !== "string" || !RUN_ID_RE.test(normalized)) {
    fail("invalid_ci_run_id", `${label} must be a positive decimal identifier.`);
  }
  return normalized;
}

function sourceCiRunAttempt(value, label = "source CI run attempt") {
  const normalized = typeof value === "number" && Number.isSafeInteger(value)
    ? String(value)
    : value;
  if (typeof normalized !== "string" || !RUN_ID_RE.test(normalized)) {
    fail("invalid_ci_run_attempt", `${label} must be a positive decimal identifier.`);
  }
  return normalized;
}

function digest(value, label = "SHA-256") {
  if (typeof value !== "string" || !DIGEST_RE.test(value)) {
    fail("invalid_digest", `${label} must be exactly 64 lowercase hexadecimal characters.`);
  }
  return value;
}

function checkpointScope(value) {
  if (typeof value !== "string" || value.trim() === "" || value !== value.trim() ||
      value.length > MAX_SCOPE_LENGTH || /[\0\r\n]/.test(value)) {
    fail(
      "invalid_checkpoint_scope",
      `Checkpoint scope must be a non-empty single-line string of at most ${MAX_SCOPE_LENGTH} characters.`,
    );
  }
  return value;
}

function stages(value) {
  if (!Array.isArray(value) || value.length === 0) {
    fail("invalid_stages", "At least one ordered deploy stage is required.");
  }
  const seen = new Set();
  return value.map((stage, index) => {
    if (typeof stage !== "string" || !STAGE_RE.test(stage)) {
      fail("invalid_stage", `Stage ${index + 1} must match ${STAGE_RE}.`);
    }
    if (seen.has(stage)) {
      fail("duplicate_stage", `Deploy stage '${stage}' appears more than once.`);
    }
    seen.add(stage);
    return stage;
  });
}

function artifactMetadata(value) {
  assertKeys(value, ["name", "sha256", "sizeBytes"], "artifact");
  if (typeof value.name !== "string" || value.name.trim() === "" ||
      value.name !== path.basename(value.name)) {
    fail("invalid_artifact_name", "Artifact name must be a non-empty basename.");
  }
  if (!Number.isSafeInteger(value.sizeBytes) || value.sizeBytes < 0) {
    fail("invalid_artifact_size", "Artifact sizeBytes must be a non-negative safe integer.");
  }
  return {
    name: value.name,
    sizeBytes: value.sizeBytes,
    sha256: digest(value.sha256, "artifact SHA-256"),
  };
}

export function validateProvenanceManifest(value) {
  assertKeys(
    value,
    [
      "artifact",
      "schema",
      "sourceCiRunAttempt",
      "sourceCiRunId",
      "sourceSha",
      "stages",
    ],
    "provenance manifest",
  );
  if (value.schema !== PROVENANCE_SCHEMA) {
    fail("invalid_schema", `Expected provenance schema '${PROVENANCE_SCHEMA}'.`);
  }
  return {
    schema: PROVENANCE_SCHEMA,
    sourceSha: sourceSha(value.sourceSha),
    sourceCiRunId: sourceCiRunId(value.sourceCiRunId),
    sourceCiRunAttempt: sourceCiRunAttempt(value.sourceCiRunAttempt),
    artifact: artifactMetadata(value.artifact),
    stages: stages(value.stages),
  };
}

function stableJson(value) {
  if (Array.isArray(value)) {
    return `[${value.map(stableJson).join(",")}]`;
  }
  if (value !== null && typeof value === "object") {
    return `{${Object.keys(value).sort().map((key) =>
      `${JSON.stringify(key)}:${stableJson(value[key])}`).join(",")}}`;
  }
  return JSON.stringify(value);
}

export function provenanceDigest(value) {
  const manifest = validateProvenanceManifest(value);
  return createHash("sha256").update(stableJson(manifest)).digest("hex");
}

async function sha256Descriptor(fileHandle) {
  const hash = createHash("sha256");
  const buffer = Buffer.allocUnsafe(64 * 1024);
  let position = 0;
  while (true) {
    const {bytesRead} = await fileHandle.read(buffer, 0, buffer.length, position);
    if (bytesRead === 0) {
      break;
    }
    hash.update(buffer.subarray(0, bytesRead));
    position += bytesRead;
  }
  return hash.digest("hex");
}

function stableArtifactMetadata(stat) {
  return {
    dev: stat.dev,
    ino: stat.ino,
    mode: stat.mode,
    nlink: stat.nlink,
    size: stat.size,
    mtimeNs: stat.mtimeNs,
    ctimeNs: stat.ctimeNs,
  };
}

function sameArtifactMetadata(before, after) {
  return Object.keys(before).every((key) => before[key] === after[key]);
}

async function inspectedArtifact(filePath) {
  let fileHandle;
  try {
    fileHandle = await fs.promises.open(
      filePath,
      fs.constants.O_RDONLY | fs.constants.O_NOFOLLOW,
    );
  } catch (error) {
    if (error?.code === "ELOOP") {
      fail("artifact_symlink", `Artifact '${filePath}' must not be a symbolic link.`);
    }
    fail("artifact_unreadable", `Cannot read artifact '${filePath}': ${error.message}`);
  }

  try {
    const beforeStat = await fileHandle.stat({bigint: true});
    if (!beforeStat.isFile()) {
      fail("artifact_not_file", `Artifact '${filePath}' must be a regular file.`);
    }
    if (beforeStat.size > BigInt(Number.MAX_SAFE_INTEGER)) {
      fail("invalid_artifact_size", `Artifact '${filePath}' is too large to represent safely.`);
    }
    const before = stableArtifactMetadata(beforeStat);
    const sha256 = await sha256Descriptor(fileHandle);
    const after = stableArtifactMetadata(await fileHandle.stat({bigint: true}));
    if (!sameArtifactMetadata(before, after)) {
      fail(
        "artifact_changed_during_read",
        `Artifact '${filePath}' changed while it was being inspected.`,
      );
    }
    return {
      name: path.basename(filePath),
      sizeBytes: Number(beforeStat.size),
      sha256,
    };
  } catch (error) {
    if (error instanceof DeliveryError) {
      throw error;
    }
    fail("artifact_unreadable", `Cannot inspect artifact '${filePath}': ${error.message}`);
  } finally {
    await fileHandle.close().catch(() => {});
  }
}

export async function sha256File(filePath) {
  return (await inspectedArtifact(filePath)).sha256;
}

export async function createProvenanceManifest({
  artifactPath,
  artifactName = path.basename(artifactPath ?? ""),
  sourceSha: expectedSha,
  sourceCiRunId: expectedRunId,
  sourceCiRunAttempt: expectedRunAttempt,
  stages: orderedStages,
}) {
  const inspected = await inspectedArtifact(artifactPath);
  if (artifactName !== inspected.name) {
    fail(
      "artifact_name_mismatch",
      `Artifact basename '${inspected.name}' does not match declared name '${artifactName}'.`,
    );
  }
  return validateProvenanceManifest({
    schema: PROVENANCE_SCHEMA,
    sourceSha: expectedSha,
    sourceCiRunId: expectedRunId,
    sourceCiRunAttempt: expectedRunAttempt,
    artifact: {
      name: artifactName,
      sizeBytes: inspected.sizeBytes,
      sha256: inspected.sha256,
    },
    stages: orderedStages,
  });
}

export async function verifyDeliveryArtifact({
  manifest: inputManifest,
  artifactPath,
  expectedSourceSha,
  expectedSourceCiRunId,
  expectedSourceCiRunAttempt,
}) {
  const manifest = validateProvenanceManifest(inputManifest);
  const expectedSha = sourceSha(expectedSourceSha, "expected source SHA");
  const expectedRunId = sourceCiRunId(expectedSourceCiRunId, "expected source CI run id");
  const expectedRunAttempt = sourceCiRunAttempt(
    expectedSourceCiRunAttempt,
    "expected source CI run attempt",
  );
  if (manifest.sourceSha !== expectedSha) {
    fail(
      "source_sha_mismatch",
      `Manifest source SHA ${manifest.sourceSha} does not match expected SHA ${expectedSha}.`,
    );
  }
  if (manifest.sourceCiRunId !== expectedRunId) {
    fail(
      "ci_run_id_mismatch",
      `Manifest CI run ${manifest.sourceCiRunId} does not match expected run ${expectedRunId}.`,
    );
  }
  if (manifest.sourceCiRunAttempt !== expectedRunAttempt) {
    fail(
      "ci_run_attempt_mismatch",
      `Manifest CI run attempt ${manifest.sourceCiRunAttempt} does not match expected attempt ${expectedRunAttempt}.`,
    );
  }
  const inspected = await inspectedArtifact(artifactPath);
  if (inspected.name !== manifest.artifact.name) {
    fail(
      "artifact_name_mismatch",
      `Artifact basename '${inspected.name}' does not match manifest name '${manifest.artifact.name}'.`,
    );
  }
  if (inspected.sizeBytes !== manifest.artifact.sizeBytes ||
      inspected.sha256 !== manifest.artifact.sha256) {
    fail(
      "artifact_digest_mismatch",
      `Artifact does not match manifest SHA-256 ${manifest.artifact.sha256}.`,
    );
  }
  return {
    ok: true,
    provenanceSha256: provenanceDigest(manifest),
    sourceSha: manifest.sourceSha,
    sourceCiRunId: manifest.sourceCiRunId,
    sourceCiRunAttempt: manifest.sourceCiRunAttempt,
    artifactSha256: inspected.sha256,
  };
}

function provenanceBinding(manifest) {
  return {
    manifestSha256: provenanceDigest(manifest),
    sourceSha: manifest.sourceSha,
    sourceCiRunId: manifest.sourceCiRunId,
    sourceCiRunAttempt: manifest.sourceCiRunAttempt,
    artifactSha256: manifest.artifact.sha256,
  };
}

export function createCheckpointState(inputManifest, scope) {
  const manifest = validateProvenanceManifest(inputManifest);
  return {
    schema: CHECKPOINT_SCHEMA,
    scope: checkpointScope(scope),
    provenance: provenanceBinding(manifest),
    stageCheckpoints: [],
  };
}

export function resolveCheckpointArtifactDecision(value) {
  const normalized = typeof value === "string" && /^[0-9]+$/u.test(value)
    ? Number(value)
    : value;
  if (!Number.isSafeInteger(normalized) || normalized < 0) {
    fail(
      "invalid_checkpoint_artifact_count",
      "Checkpoint artifact count must be a non-negative safe integer.",
    );
  }
  if (normalized > 1) {
    fail(
      "ambiguous_checkpoint_artifact",
      `Expected at most one exact checkpoint artifact, found ${normalized}.`,
    );
  }
  return {
    artifactCount: normalized,
    restartFromFirstStage: normalized === 0,
    shouldRestore: normalized === 1,
  };
}

function validatedPostcondition(value, label) {
  assertObject(value, label);
  const allowed = value.detail === undefined ? ["status"] : ["detail", "status"];
  assertKeys(value, allowed, label);
  if (!POSTCONDITION_STATUSES.has(value.status)) {
    fail("invalid_postcondition", `${label}.status must be 'passed' or 'failed'.`);
  }
  if (value.detail !== undefined &&
      (typeof value.detail !== "string" || value.detail.trim() === "")) {
    fail("invalid_postcondition", `${label}.detail must be a non-empty string when present.`);
  }
  return value.detail === undefined
    ? {status: value.status}
    : {status: value.status, detail: value.detail};
}

function assertBinding(actual, expected) {
  assertKeys(
    actual,
    [
      "artifactSha256",
      "manifestSha256",
      "sourceCiRunAttempt",
      "sourceCiRunId",
      "sourceSha",
    ],
    "checkpoint provenance",
  );
  for (const key of Object.keys(expected)) {
    if (actual[key] !== expected[key]) {
      fail(
        "checkpoint_provenance_mismatch",
        `Checkpoint ${key} does not match the supplied provenance manifest.`,
      );
    }
  }
}

export function validateCheckpointState(inputManifest, value, scope) {
  const manifest = validateProvenanceManifest(inputManifest);
  const expectedScope = checkpointScope(scope);
  assertKeys(value, ["provenance", "schema", "scope", "stageCheckpoints"], "checkpoint state");
  if (value.schema !== CHECKPOINT_SCHEMA) {
    fail("invalid_schema", `Expected checkpoint schema '${CHECKPOINT_SCHEMA}'.`);
  }
  const actualScope = checkpointScope(value.scope);
  if (actualScope !== expectedScope) {
    fail(
      "checkpoint_scope_mismatch",
      `Checkpoint scope '${actualScope}' does not match requested scope '${expectedScope}'.`,
    );
  }
  assertBinding(value.provenance, provenanceBinding(manifest));
  if (!Array.isArray(value.stageCheckpoints)) {
    fail("invalid_checkpoints", "stageCheckpoints must be an array.");
  }
  if (value.stageCheckpoints.length > manifest.stages.length) {
    fail("invalid_checkpoints", "Checkpoint state has more entries than deploy stages.");
  }
  const normalized = value.stageCheckpoints.map((entry, index) => {
    assertKeys(entry, ["postcondition", "stage"], `stage checkpoint ${index + 1}`);
    if (entry.stage !== manifest.stages[index]) {
      fail(
        "checkpoint_out_of_order",
        `Checkpoint ${index + 1} must be for stage '${manifest.stages[index]}'.`,
      );
    }
    const postcondition = validatedPostcondition(
      entry.postcondition,
      `stage checkpoint ${index + 1} postcondition`,
    );
    if (postcondition.status === "failed" && index !== value.stageCheckpoints.length - 1) {
      fail("checkpoint_out_of_order", "A failed stage must be the final checkpoint entry.");
    }
    return {stage: entry.stage, postcondition};
  });
  return {
    schema: CHECKPOINT_SCHEMA,
    scope: actualScope,
    provenance: {...value.provenance},
    stageCheckpoints: normalized,
  };
}

export function resolveFirstIncompleteStage(inputManifest, inputState, scope) {
  const manifest = validateProvenanceManifest(inputManifest);
  const state = validateCheckpointState(manifest, inputState, scope);
  for (let index = 0; index < manifest.stages.length; index += 1) {
    const checkpoint = state.stageCheckpoints[index];
    if (checkpoint?.postcondition.status !== "passed") {
      return {
        complete: false,
        index,
        stage: manifest.stages[index],
        status: checkpoint?.postcondition.status ?? "pending",
      };
    }
  }
  return {complete: true, index: null, stage: null, status: "complete"};
}

export function recordStageCheckpoint({
  manifest: inputManifest,
  state: inputState,
  scope,
  stage,
  status,
  detail,
}) {
  const manifest = validateProvenanceManifest(inputManifest);
  const state = validateCheckpointState(manifest, inputState, scope);
  const requestedIndex = manifest.stages.indexOf(stage);
  if (requestedIndex === -1) {
    fail("unknown_stage", `Stage '${stage}' is not in the provenance manifest.`);
  }
  const postcondition = validatedPostcondition(
    detail === undefined ? {status} : {status, detail},
    `stage '${stage}' postcondition`,
  );
  const next = resolveFirstIncompleteStage(manifest, state, scope);
  if (requestedIndex < next.index || next.complete) {
    const prior = state.stageCheckpoints[requestedIndex];
    if (prior?.postcondition.status === "passed" && postcondition.status === "passed") {
      return {state, changed: false, idempotent: true};
    }
    fail("stage_already_passed", `Stage '${stage}' already passed and cannot be regressed.`);
  }
  if (requestedIndex > next.index) {
    fail(
      "checkpoint_out_of_order",
      `Stage '${stage}' cannot be checkpointed before '${next.stage}' passes.`,
    );
  }
  const updated = structuredClone(state);
  const checkpoint = {stage, postcondition};
  if (updated.stageCheckpoints[requestedIndex]) {
    updated.stageCheckpoints[requestedIndex] = checkpoint;
  } else {
    updated.stageCheckpoints.push(checkpoint);
  }
  return {
    state: validateCheckpointState(manifest, updated, scope),
    changed: true,
    idempotent: false,
  };
}

export async function readJsonFile(filePath, label = "JSON file") {
  try {
    return JSON.parse(await fs.promises.readFile(filePath, "utf8"));
  } catch (error) {
    fail("invalid_json_file", `Cannot read ${label} '${filePath}': ${error.message}`);
  }
}

export async function writeJsonAtomic(filePath, value, {beforeRename} = {}) {
  const target = path.resolve(filePath);
  const directory = path.dirname(target);
  await fs.promises.mkdir(directory, {recursive: true});
  const temporary = path.join(directory, `.${path.basename(target)}.${process.pid}.${randomUUID()}.tmp`);
  let fileHandle;
  try {
    fileHandle = await fs.promises.open(temporary, "wx", 0o600);
    await fileHandle.writeFile(`${JSON.stringify(value, null, 2)}\n`, "utf8");
    await fileHandle.sync();
    await fileHandle.close();
    fileHandle = undefined;
    if (beforeRename !== undefined) {
      if (typeof beforeRename !== "function") {
        fail("invalid_fault_injector", "beforeRename must be a function when provided.");
      }
      await beforeRename({targetPath: target, temporaryPath: temporary});
    }
    await fs.promises.rename(temporary, target);
  } finally {
    await fileHandle?.close().catch(() => {});
    await fs.promises.unlink(temporary).catch(() => {});
  }
}

function parseOptions(argv) {
  const options = {};
  for (let index = 0; index < argv.length; index += 2) {
    const flag = argv[index];
    const value = argv[index + 1];
    if (!flag?.startsWith("--") || value === undefined || value.startsWith("--")) {
      fail("invalid_cli", `Expected --name value pairs; received '${flag ?? ""}'.`);
    }
    const key = flag.slice(2);
    if (options[key] !== undefined) {
      fail("invalid_cli", `Option '--${key}' was provided more than once.`);
    }
    options[key] = value;
  }
  return options;
}

function option(options, key) {
  if (!options[key]) {
    fail("missing_option", `Missing required option '--${key}'.`);
  }
  return options[key];
}

function assertDistinctFiles(outputPath, inputs) {
  const output = path.resolve(outputPath);
  for (const [label, inputPath] of inputs) {
    if (output === path.resolve(inputPath)) {
      fail("unsafe_output_path", `Output path must not overwrite the ${label}.`);
    }
  }
}

async function verifiedInputs(options) {
  const manifest = validateProvenanceManifest(
    await readJsonFile(option(options, "manifest"), "provenance manifest"),
  );
  const verification = await verifyDeliveryArtifact({
    manifest,
    artifactPath: option(options, "artifact"),
    expectedSourceSha: option(options, "source-sha"),
    expectedSourceCiRunId: option(options, "ci-run-id"),
    expectedSourceCiRunAttempt: option(options, "ci-run-attempt"),
  });
  return {manifest, verification};
}

async function checkpointState(checkpointPath, manifest, scope) {
  try {
    return validateCheckpointState(
      manifest,
      await readJsonFile(checkpointPath, "checkpoint state"),
      scope,
    );
  } catch (error) {
    if (error.code === "invalid_json_file" && !fs.existsSync(checkpointPath)) {
      return createCheckpointState(manifest, scope);
    }
    throw error;
  }
}

export async function executeDeliveryCli(argv, {writeOutput = console.log} = {}) {
  const [command, ...optionArgs] = argv;
  const options = parseOptions(optionArgs);
  let result;
  if (command === "manifest") {
    const manifest = await createProvenanceManifest({
      artifactPath: option(options, "artifact"),
      artifactName: options["artifact-name"],
      sourceSha: option(options, "source-sha"),
      sourceCiRunId: option(options, "ci-run-id"),
      sourceCiRunAttempt: option(options, "ci-run-attempt"),
      stages: option(options, "stages").split(",").map((stage) => stage.trim()),
    });
    const outputPath = option(options, "out");
    assertDistinctFiles(outputPath, [["artifact", option(options, "artifact")]]);
    await writeJsonAtomic(outputPath, manifest);
    result = {ok: true, command, outputPath, provenanceSha256: provenanceDigest(manifest)};
  } else if (command === "restore-decision") {
    result = {
      ok: true,
      command,
      ...resolveCheckpointArtifactDecision(option(options, "artifact-count")),
    };
  } else if (["verify", "next", "checkpoint"].includes(command)) {
    const {manifest, verification} = await verifiedInputs(options);
    if (command === "verify") {
      result = {...verification, command};
    } else {
      const checkpointPath = option(options, "checkpoint");
      const scope = option(options, "scope");
      assertDistinctFiles(checkpointPath, [
        ["artifact", option(options, "artifact")],
        ["provenance manifest", option(options, "manifest")],
      ]);
      let state = await checkpointState(checkpointPath, manifest, scope);
      if (command === "checkpoint") {
        const recorded = recordStageCheckpoint({
          manifest,
          state,
          scope,
          stage: option(options, "stage"),
          status: option(options, "status"),
          detail: options.detail,
        });
        state = recorded.state;
        if (recorded.changed) {
          await writeJsonAtomic(checkpointPath, state);
        }
        result = {
          ok: true,
          command,
          changed: recorded.changed,
          idempotent: recorded.idempotent,
          scope,
          next: resolveFirstIncompleteStage(manifest, state, scope),
          ...verification,
        };
      } else {
        result = {
          ok: true,
          command,
          scope,
          next: resolveFirstIncompleteStage(manifest, state, scope),
          ...verification,
        };
      }
    }
  } else {
    fail(
      "invalid_cli",
      "Command must be one of: manifest, verify, restore-decision, next, checkpoint.",
    );
  }
  writeOutput(JSON.stringify(result));
  return result;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  executeDeliveryCli(process.argv.slice(2)).catch((error) => {
    console.error(JSON.stringify({
      ok: false,
      code: error.code ?? "unexpected_error",
      message: error.message,
    }));
    process.exitCode = 1;
  });
}
