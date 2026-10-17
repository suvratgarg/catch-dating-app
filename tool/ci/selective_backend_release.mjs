import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {compareFunctionFingerprints, FUNCTION_FINGERPRINT_SCHEMA} from "../firebase/function_release_fingerprints.mjs";
import {createCheckpointState, validateProvenanceManifest, provenanceDigest, validateCheckpointState, resolveFirstIncompleteStage} from "./delivery_core.mjs";
import {validateFunctionsDeployment, validateFunctionIdentity, readSuccessfulBaselineArchive,
  readMaterializedParamsSha256, liveFunctions, captureFunctionIdentities,
  FUNCTIONS_DEPLOYMENT_SCHEMA, FUNCTIONS_DEPLOYMENT_FILE} from "./firebase_functions_checkpoint.mjs";
import {gcloudIndexList, inspectIndexReadiness, indexSignature} from "../firebase/wait_firestore_indexes_ready.mjs";
import {materializedNonSecretParams} from "../firebase/prepare_functions_params_for_deploy.mjs";
import {validateCandidateBindings, parseSecretReference, selectReadinessRequirements} from "../firebase/check_environment_readiness.mjs";
import readinessManifest from "../firebase/environment_readiness.json" with {type: "json"};
import salesSourceGuardedPaths from "./sales_pr543_source_guard.json" with {type: "json"};

export const SELECTIVE_RELEASE_SCHEMA = "catch.selective-backend-release/v1";
export const FUNCTION_LEDGER_SCHEMA = "catch.function-deployment-ledger/v1";
export const SELECTIVE_IMPACT_SCHEMA = "catch.selective-runtime-impact/v1";
const hashPattern = /^[0-9a-f]{64}$/;
const shaPattern = /^[0-9a-f]{40}$/;
const targetsPattern = /^functions:[A-Za-z][A-Za-z0-9_-]*$/;
const bindingKeys = ["sourceSha", "sourceCiRunId", "sourceCiRunAttempt", "packageSha256"];
const prepareKeys = ["baseline", "candidate", "packageBaseSha", "baselineEvidence", "candidateEvidence",
  "authorizedTargets", "baselineIndexes", "candidateIndexes", "coveredSources", "baselineParamsSha256", "candidateParamsSha256"];
const canonical = (value) => Array.isArray(value) ? value.map(canonical) :
  value && typeof value === "object" ? Object.fromEntries(Object.keys(value).sort().map((key) => [key, canonical(value[key])])) : value;
const digest = (value) => createHash("sha256").update(JSON.stringify(canonical(value))).digest("hex");
// Full source/compiled evidence can exceed the maximum JavaScript string size.
// Stream the same canonical JSON encoding, retaining every validated input.
function impactInputDigest(value) {
  const hash = createHash("sha256");
  let chunks = []; let size = 0;
  const append = (text) => {
    chunks.push(text); size += text.length;
    if (size >= 65536) {hash.update(chunks.join("")); chunks = []; size = 0;}
  };
  const visit = (entry) => {
    if (Array.isArray(entry)) {
      append("[");
      entry.forEach((item, index) => {if (index) append(","); visit(item);});
      append("]");
    } else if (entry && typeof entry === "object") {
      append("{");
      Object.keys(entry).sort().forEach((key, index) => {
        if (index) append(",");
        append(JSON.stringify(key)); append(":"); visit(entry[key]);
      });
      append("}");
    } else append(JSON.stringify(entry));
  };
  visit(value); hash.update(chunks.join(""));
  return hash.digest("hex");
}
// Validation errors never expose rejected payloads through AssertionError.actual,
// parser causes, or diffs. These APIs accept metadata, not parameter values.
function safe(action) {
  try { return action(); } catch { throw new Error("Invalid selective backend release evidence."); }
}
function exactKeys(value, names) {
  assert.ok(value && typeof value === "object" && !Array.isArray(value));
  assert.ok([Object.prototype, null].includes(Object.getPrototypeOf(value)));
  assert.deepEqual(Reflect.ownKeys(value).sort(), [...names].sort());
  assert.ok(Object.values(Object.getOwnPropertyDescriptors(value)).every((descriptor) => "value" in descriptor));
}
function binding(value) {
  exactKeys(value, bindingKeys);
  assert.match(value.sourceSha ?? "", shaPattern);
  assert.match(value.sourceCiRunId ?? "", /^[1-9][0-9]*$/);
  assert.match(value.sourceCiRunAttempt ?? "", /^[1-9][0-9]*$/);
  assert.match(value.packageSha256 ?? "", hashPattern);
  return structuredClone(value);
}
function manifestBinding(input, expected) {
  const manifest = validateProvenanceManifest(input);
  assert.deepEqual({sourceSha: manifest.sourceSha, sourceCiRunId: manifest.sourceCiRunId,
    sourceCiRunAttempt: manifest.sourceCiRunAttempt, packageSha256: manifest.artifact.sha256}, binding(expected));
  return manifest;
}
function targetList(value, {empty = false} = {}) {
  assert.ok(Array.isArray(value) && (empty || value.length) && value.length <= 2000);
  assert.ok(value.every((target) => typeof target === "string" && targetsPattern.test(target)));
  assert.equal(new Set(value).size, value.length);
  assert.deepEqual(value, [...value].sort());
  return value;
}
function fingerprints(value, expectedTargets) {
  exactKeys(value, ["schema", "functions"]);
  assert.equal(value.schema, FUNCTION_FINGERPRINT_SCHEMA);
  exactKeys(value.functions, expectedTargets);
  for (const target of expectedTargets) {
    const row = value.functions[target];
    exactKeys(row, ["sha256", "dependencies", "unknown"]);
    assert.match(row.sha256 ?? "", hashPattern);
    assert.ok(Array.isArray(row.dependencies) && row.dependencies.length > 0 && row.dependencies.length <= 50000);
    const names = [];
    for (const pair of row.dependencies) {
      assert.ok(Array.isArray(pair) && pair.length === 2);
      assert.match(pair[0] ?? "", /^[A-Za-z0-9_@.$/#:-]{1,1024}$/);
      assert.match(pair[1] ?? "", hashPattern);
      names.push(pair[0]);
    }
    assert.equal(new Set(names).size, names.length);
    assert.deepEqual(names, [...names].sort((a, b) => a.localeCompare(b)));
    // Recompute the analyzer's dependency digest; a claimed sha256 alone cannot
    // turn changed dependencies into an unchanged Function.
    assert.equal(row.sha256, createHash("sha256").update(JSON.stringify(row.dependencies)).digest("hex"));
    assert.ok(Array.isArray(row.unknown) && row.unknown.length <= 50000);
    assert.ok(row.unknown.every((name) => typeof name === "string" &&
      /^[A-Za-z0-9_@.$/#-]{1,1024}:(?:dynamic-module-load|indirect-code-load)$/.test(name)));
    assert.equal(new Set(row.unknown).size, row.unknown.length);
    assert.deepEqual(row.unknown, [...row.unknown].sort());
  }
  return value;
}
function fingerprintEvidence(value, expected, targets) {
  exactKeys(value, ["sourceSha", "packageSha256", "source", "compiled", "runtimeConfigurationSha256"]);
  assert.equal(value.sourceSha, expected.sourceSha);
  assert.equal(value.packageSha256, expected.packageSha256);
  assert.match(value.runtimeConfigurationSha256 ?? "", hashPattern);
  fingerprints(value.source, targets); fingerprints(value.compiled, targets);
  assert.deepEqual(value.source, value.compiled);
  return value;
}
function fieldPath(value) { assert.match(value ?? "", /^[A-Za-z_][A-Za-z0-9_.-]{0,511}$/); }
function queryScope(value) { assert.ok(["COLLECTION", "COLLECTION_GROUP"].includes(value)); }
function indexField(field, override = false) {
  const choices = ["order", "mode", "arrayConfig"].filter((key) => Object.hasOwn(field, key));
  assert.equal(choices.length, 1);
  exactKeys(field, [override ? "queryScope" : "fieldPath", choices[0]]);
  if (override) queryScope(field.queryScope); else fieldPath(field.fieldPath);
  if (choices[0] === "arrayConfig") assert.equal(field.arrayConfig, "CONTAINS");
  else assert.ok(["ASCENDING", "DESCENDING"].includes(field[choices[0]]));
  return { [override ? "queryScope" : "fieldPath"]: field[override ? "queryScope" : "fieldPath"],
    [choices[0] === "mode" ? "order" : choices[0]]: field[choices[0]] };
}
function indexContract(index) {
  exactKeys(index, ["collectionGroup", "queryScope", "fields"]);
  fieldPath(index.collectionGroup); queryScope(index.queryScope);
  assert.ok(Array.isArray(index.fields) && index.fields.length >= 2 && index.fields.length <= 32);
  const fields = index.fields.map((field) => indexField(field));
  assert.equal(new Set(fields.map((field) => field.fieldPath)).size, fields.length);
  return {collectionGroup: index.collectionGroup, queryScope: index.queryScope, fields};
}
function indexInventory(value) {
  exactKeys(value, ["indexes", "fieldOverrides"]);
  assert.ok(Array.isArray(value.indexes) && value.indexes.length <= 10000);
  assert.ok(Array.isArray(value.fieldOverrides) && value.fieldOverrides.length <= 10000);
  const indexes = value.indexes.map(indexContract);
  const fieldOverrides = value.fieldOverrides.map((override) => {
    const ttl = Object.hasOwn(override, "ttl");
    exactKeys(override, ["collectionGroup", "fieldPath", "indexes", ...(ttl ? ["ttl"] : [])]);
    fieldPath(override.collectionGroup); fieldPath(override.fieldPath);
    if (ttl) assert.equal(typeof override.ttl, "boolean");
    assert.ok(Array.isArray(override.indexes) && override.indexes.length <= 6);
    const entries = override.indexes.map((field) => indexField(field, true));
    assert.equal(new Set(entries.map((entry) => JSON.stringify(entry))).size, entries.length);
    return {collectionGroup: override.collectionGroup, fieldPath: override.fieldPath,
      ...(ttl ? {ttl: override.ttl} : {}), indexes: entries};
  });
  assert.equal(new Set(indexes.map((index) => JSON.stringify(index))).size, indexes.length);
  assert.equal(new Set(fieldOverrides.map((field) => `${field.collectionGroup}:${field.fieldPath}`)).size, fieldOverrides.length);
  return {indexes, fieldOverrides};
}
function additive(before, after) {
  const old = indexInventory(before); const next = indexInventory(after);
  assert.deepEqual(old.fieldOverrides, next.fieldOverrides);
  const existing = new Set(old.indexes.map((index) => JSON.stringify(index)));
  const additions = new Map(next.indexes.map((index) => [JSON.stringify(index), index]));
  assert.ok([...existing].every((key) => additions.has(key)));
  return [...additions].filter(([key]) => !existing.has(key)).map(([, index]) => index);
}
export function additiveIndexChanges(before, after) { return safe(() => additive(before, after)); }

function prepare(input) {
  exactKeys(input, prepareKeys);
  const {baseline, candidate, packageBaseSha, baselineEvidence, candidateEvidence, authorizedTargets,
    baselineIndexes, candidateIndexes, coveredSources, baselineParamsSha256, candidateParamsSha256} = input;
  binding(baseline); binding(candidate); targetList(authorizedTargets);
  assert.notEqual(baseline.sourceSha, candidate.sourceSha);
  assert.match(packageBaseSha ?? "", shaPattern);
  fingerprintEvidence(baselineEvidence, baseline, authorizedTargets);
  fingerprintEvidence(candidateEvidence, candidate, authorizedTargets);
  assert.equal(candidateEvidence.runtimeConfigurationSha256, baselineEvidence.runtimeConfigurationSha256);
  assert.match(baselineParamsSha256 ?? "", hashPattern);
  assert.match(candidateParamsSha256 ?? "", hashPattern);
  assert.equal(candidateParamsSha256, baselineParamsSha256);
  const source = compareFunctionFingerprints(baselineEvidence.source, candidateEvidence.source, {authorizedTargets});
  const compiled = compareFunctionFingerprints(baselineEvidence.compiled, candidateEvidence.compiled, {authorizedTargets});
  assert.deepEqual(source, compiled);
  // The trusted CLI supplies the exact Git-derived oldest-to-newest interval.
  // Hexadecimal SHA order is not ancestry order. Completion compares this whole
  // sequence against independently rederived preparation, including its end.
  assert.ok(Array.isArray(coveredSources) && coveredSources.length && coveredSources.length <= 10000);
  assert.ok(coveredSources.every((sha) => typeof sha === "string" && shaPattern.test(sha)));
  assert.equal(new Set(coveredSources).size, coveredSources.length);
  assert.equal(coveredSources.at(-1), candidate.sourceSha);
  assert.ok(!coveredSources.includes(baseline.sourceSha));
  const indexes = additive(baselineIndexes, candidateIndexes);
  return {schema: SELECTIVE_RELEASE_SCHEMA, baseline: binding(baseline), candidate: binding(candidate), packageBaseSha,
    fingerprintEvidenceSha256: digest({baselineEvidence, candidateEvidence}),
    runtimeConfigurationSha256: candidateEvidence.runtimeConfigurationSha256, paramsSha256: candidateParamsSha256,
    indexes, indexContractSha256: digest(indexInventory(candidateIndexes)), coveredSources: [...coveredSources],
    targets: [...source.targets], unchangedTargets: [...source.unchangedTargets],
    stages: [...(indexes.length ? ["firestore-indexes"] : []), ...(source.targets.length ? ["functions"] : [])]};
}
// A projection never edits the candidate package's historical base or CI plan.
export function prepareSelectiveRelease(input) { return safe(() => prepare(input)); }
// Read-only impact classification. A dependency lock change can affect every
// existing export even when compiled JS is byte-identical. Selection is an
// operator input; deferred impact remains explicit and never becomes an
// unchanged-function claim or deployment authorization.
export function assessSelectiveRuntimeImpact(input) {
  return safe(() => {
    exactKeys(input, ["baseline", "candidate", "baselineEvidence", "candidateEvidence",
      "baselineTargets", "candidateTargets", "baselineLockSha256", "candidateLockSha256", "selectedTargets"]);
    const {baseline, candidate, baselineEvidence, candidateEvidence, baselineTargets, candidateTargets,
      baselineLockSha256, candidateLockSha256, selectedTargets} = input;
    binding(baseline); binding(candidate);
    targetList(baselineTargets); targetList(candidateTargets); targetList(selectedTargets, {empty: true});
    assert.match(baselineLockSha256 ?? "", hashPattern);
    assert.match(candidateLockSha256 ?? "", hashPattern);
    fingerprintEvidence(baselineEvidence, baseline, baselineTargets);
    fingerprintEvidence(candidateEvidence, candidate, candidateTargets);
    assert.equal(baselineEvidence.runtimeConfigurationSha256, candidateEvidence.runtimeConfigurationSha256);
    const candidateSet = new Set(candidateTargets);
    assert.ok(baselineTargets.every((target) => candidateSet.has(target)), "Deletion needs separate authority.");
    const baselineSet = new Set(baselineTargets);
    // The full evidence was validated above, including matching source and
    // compiled snapshots. An unresolved *deferred* closure must remain visible
    // as impacted; only a selected closure needs resolution before selection.
    const codeChangedTargets = baselineTargets.filter((target) =>
      baselineEvidence.source.functions[target].sha256 !== candidateEvidence.source.functions[target].sha256);
    const dependencyDrift = baselineLockSha256 !== candidateLockSha256;
    const addedTargets = candidateTargets.filter((target) => !baselineSet.has(target));
    const impactedTargets = [...new Set([...(dependencyDrift ? baselineTargets : codeChangedTargets), ...addedTargets])].sort();
    const impacted = new Set(impactedTargets);
    assert.ok(selectedTargets.every((target) => impacted.has(target)), "Selector includes an unaffected Function.");
    for (const target of selectedTargets) {
      assert.equal(candidateEvidence.source.functions[target].unknown.length, 0,
        "Selected runtime closure is unresolved.");
      if (baselineSet.has(target)) assert.equal(baselineEvidence.source.functions[target].unknown.length, 0,
        "Selected baseline closure is unresolved.");
    }
    const selected = new Set(selectedTargets);
    const deferredUnresolvedTargets = impactedTargets.filter((target) => !selected.has(target) &&
      (candidateEvidence.source.functions[target].unknown.length ||
        baselineSet.has(target) && baselineEvidence.source.functions[target].unknown.length));
    return {schema: SELECTIVE_IMPACT_SCHEMA, baseline: binding(baseline), candidate: binding(candidate),
      baselineLockSha256, candidateLockSha256, dependencyDrift,
      codeChangedTargets, addedTargets, impactedTargets,
      selectedTargets: [...selectedTargets], deferredImpactedTargets: impactedTargets.filter((target) => !selected.has(target)),
      deferredUnresolvedTargets,
      retainedBaselineTargets: baselineTargets.filter((target) => !selected.has(target))};
  });
}
function validatePlan(plan) {
  exactKeys(plan, ["schema", "baseline", "candidate", "packageBaseSha", "fingerprintEvidenceSha256",
    "runtimeConfigurationSha256", "paramsSha256", "indexes", "indexContractSha256", "coveredSources", "targets", "unchangedTargets", "stages"]);
  assert.equal(plan.schema, SELECTIVE_RELEASE_SCHEMA);
  binding(plan.baseline); binding(plan.candidate);
  assert.match(plan.packageBaseSha ?? "", shaPattern);
  for (const name of ["fingerprintEvidenceSha256", "runtimeConfigurationSha256", "paramsSha256", "indexContractSha256"])
    assert.match(plan[name] ?? "", hashPattern);
  targetList(plan.targets, {empty: true}); targetList(plan.unchangedTargets, {empty: true});
  targetList([...plan.targets, ...plan.unchangedTargets].sort());
  assert.ok(Array.isArray(plan.indexes)); plan.indexes.forEach(indexContract);
  assert.ok(Array.isArray(plan.coveredSources) && plan.coveredSources.length);
  assert.ok(plan.coveredSources.every((sha) => typeof sha === "string" && shaPattern.test(sha)));
  assert.equal(new Set(plan.coveredSources).size, plan.coveredSources.length);
  assert.equal(plan.coveredSources.at(-1), plan.candidate.sourceSha);
  assert.ok(!plan.coveredSources.includes(plan.baseline.sourceSha));
  assert.deepEqual(plan.stages, [...(plan.indexes.length ? ["firestore-indexes"] : []), ...(plan.targets.length ? ["functions"] : [])]);
}
function validateLedger(ledger) {
  exactKeys(ledger, ["schema", "scope", "coverageSourceSha", "runtimeConfigurationSha256", "functions"]);
  assert.equal(ledger.schema, FUNCTION_LEDGER_SCHEMA);
  assert.match(ledger.coverageSourceSha ?? "", shaPattern);
  assert.match(ledger.runtimeConfigurationSha256 ?? "", hashPattern);
  assert.ok(Array.isArray(ledger.functions) && ledger.functions.length && ledger.functions.length <= 2000);
  targetList(ledger.functions.map((row) => row.target));
  for (const row of ledger.functions) {
    exactKeys(row, ["target", "fingerprintSha256", ...bindingKeys, "paramsSha256", "deployment"]);
    binding(Object.fromEntries(bindingKeys.map((key) => [key, row[key]])));
    for (const key of ["fingerprintSha256", "paramsSha256"]) assert.match(row[key] ?? "", hashPattern);
    validateFunctionIdentity(row.deployment, {scope: ledger.scope, target: row.target});
  }
  return ledger;
}
export function initializeFunctionLedger(input) {
  return safe(() => {
    exactKeys(input, ["deployment", "manifest", "scope", "fingerprints", "configSha256", "expectedParamsSha256", "expectedBaseSha"]);
    const {deployment, manifest: rawManifest, scope, fingerprints: snapshot, configSha256,
      expectedParamsSha256, expectedBaseSha} = input;
    const manifest = validateProvenanceManifest(rawManifest);
    assert.match(configSha256 ?? "", hashPattern);
    assert.match(expectedParamsSha256 ?? "", hashPattern); assert.match(expectedBaseSha ?? "", shaPattern);
    targetList(deployment.targets); fingerprints(snapshot, deployment.targets);
    validateFunctionsDeployment(deployment, {manifest, scope, baseSha: expectedBaseSha,
      selectedTargets: deployment.targets, paramsSha256: expectedParamsSha256});
    const result = {schema: FUNCTION_LEDGER_SCHEMA, scope, coverageSourceSha: manifest.sourceSha,
      runtimeConfigurationSha256: configSha256, functions: deployment.targets.map((target, index) => ({target,
        fingerprintSha256: snapshot.functions[target].sha256, sourceSha: manifest.sourceSha,
        sourceCiRunId: manifest.sourceCiRunId, sourceCiRunAttempt: manifest.sourceCiRunAttempt,
        packageSha256: manifest.artifact.sha256, paramsSha256: expectedParamsSha256,
        deployment: validateFunctionIdentity(deployment.functions[index], {scope, target})}))};
    return validateLedger(result);
  });
}
// Reconstruct the ledger after a bounded operator release from both immutable
// package proofs and the independently captured live receipt. The common
// coverage source remains the last source represented by every prior row;
// each row retains its actual newer source/package/params when selected.
export function initializeMixedFunctionLedger(input) {
  return safe(() => {
    exactKeys(input, ["baseline", "operator", "scope", "receipt", "allLiveIdentities"]);
    const {baseline, operator, scope, receipt, allLiveIdentities} = input;
    const sourceKeys = ["manifest", "deployment", "evidence", "paramsSha256", "baseSha"];
    exactKeys(baseline, sourceKeys); exactKeys(operator, sourceKeys);
    const prior = validateProvenanceManifest(baseline.manifest);
    const promoted = validateProvenanceManifest(operator.manifest);
    assert.notEqual(prior.sourceSha, promoted.sourceSha);
    const allTargets = targetList(baseline.deployment.targets);
    const selectedTargets = targetList(operator.deployment.targets);
    assert.ok(selectedTargets.every((target) => allTargets.includes(target)));
    assert.match(baseline.paramsSha256 ?? "", hashPattern);
    assert.match(operator.paramsSha256 ?? "", hashPattern);
    assert.match(baseline.baseSha ?? "", shaPattern);
    assert.match(operator.baseSha ?? "", shaPattern);
    validateFunctionsDeployment(baseline.deployment, {manifest: prior, scope, baseSha: baseline.baseSha,
      selectedTargets: allTargets, paramsSha256: baseline.paramsSha256});
    validateFunctionsDeployment(operator.deployment, {manifest: promoted, scope, baseSha: operator.baseSha,
      selectedTargets, paramsSha256: operator.paramsSha256});
    fingerprintEvidence(baseline.evidence,
      {sourceSha: prior.sourceSha, packageSha256: prior.artifact.sha256}, allTargets);
    fingerprintEvidence(operator.evidence,
      {sourceSha: promoted.sourceSha, packageSha256: promoted.artifact.sha256}, allTargets);
    assert.equal(baseline.evidence.runtimeConfigurationSha256, operator.evidence.runtimeConfigurationSha256);
    exactKeys(receipt, ["schema", "scope", "packageSha256", "selectedTargets", "retainedTargetCount",
      "addedIndexCount", "functions"]);
    assert.equal(receipt.schema, "catch.operator-prod-selective-receipt/v1");
    assert.equal(receipt.scope, scope);
    assert.equal(receipt.packageSha256, promoted.artifact.sha256);
    assert.deepEqual(receipt.selectedTargets, selectedTargets);
    assert.equal(receipt.retainedTargetCount, allTargets.length - selectedTargets.length);
    assert.ok(Number.isSafeInteger(receipt.addedIndexCount) && receipt.addedIndexCount >= 0);
    assert.ok(Array.isArray(receipt.functions) && receipt.functions.length === allTargets.length);
    const selected = new Map(selectedTargets.map((target, index) => [target, operator.deployment.functions[index]]));
    const result = {schema: FUNCTION_LEDGER_SCHEMA, scope, coverageSourceSha: prior.sourceSha,
      runtimeConfigurationSha256: baseline.evidence.runtimeConfigurationSha256,
      functions: allTargets.map((target, index) => {
        const row = receipt.functions[index];
        exactKeys(row, ["target", "sourceSha", "deployment"]);
        assert.equal(row.target, target);
        const updated = selected.has(target);
        const source = updated ? promoted : prior;
        const proof = updated ? selected.get(target) : baseline.deployment.functions[index];
        assert.equal(row.sourceSha, source.sourceSha);
        assert.deepEqual(validateFunctionIdentity(row.deployment, {scope, target}), proof);
        if (updated) assert.notDeepEqual(proof, baseline.deployment.functions[index]);
        const fingerprint = updated ? operator.evidence.source.functions[target] : baseline.evidence.source.functions[target];
        assert.deepEqual(fingerprint.unknown, []);
        return {target, fingerprintSha256: fingerprint.sha256, sourceSha: source.sourceSha,
          sourceCiRunId: source.sourceCiRunId, sourceCiRunAttempt: source.sourceCiRunAttempt,
          packageSha256: source.artifact.sha256,
          paramsSha256: updated ? operator.paramsSha256 : baseline.paramsSha256,
          deployment: structuredClone(proof)};
      })};
    validateLedger(result);
    verifyIdentities(result, allLiveIdentities);
    return result;
  });
}
// The source/package comparison may conservatively mark retained Functions as
// impacted by dependency drift. This plan keeps them deferred with their real
// prior bindings; it never promotes the package's full Function inventory.
export function prepareMixedImpactRelease(input) {
  return safe(() => {
    exactKeys(input, ["initialization", "impactInput", "candidateManifest", "candidateBaseSha",
      "candidateParamsSha256", "baselineIndexes", "operatorIndexes", "candidateIndexes"]);
    const {initialization, impactInput, candidateManifest, candidateBaseSha, candidateParamsSha256,
      baselineIndexes, operatorIndexes, candidateIndexes} = input;
    const ledger = initializeMixedFunctionLedger(initialization);
    const impact = assessSelectiveRuntimeImpact(impactInput);
    manifestBinding(initialization.baseline.manifest, impact.baseline);
    manifestBinding(candidateManifest, impact.candidate);
    assert.deepEqual(impactInput.baselineEvidence, initialization.baseline.evidence);
    assert.deepEqual(impactInput.baselineTargets, ledger.functions.map((row) => row.target));
    const indexContracts = {baseline: indexInventory(baselineIndexes), operator: indexInventory(operatorIndexes),
      candidate: indexInventory(candidateIndexes)};
    assert.equal(additive(baselineIndexes, operatorIndexes).length,
      initialization.receipt.addedIndexCount);
    assert.deepEqual(indexContracts.operator, indexContracts.candidate);
    assert.match(candidateBaseSha ?? "", shaPattern);
    assert.match(candidateParamsSha256 ?? "", hashPattern);
    assert.ok(impact.selectedTargets.length > 0);
    assert.ok(impact.addedTargets.every((target) => impact.selectedTargets.includes(target)),
      "A new Function requires a selected deployment before ledger completion.");
    return {schema: "catch.selective-impact-plan/v1", scope: ledger.scope,
      baselineCommonSourceSha: ledger.coverageSourceSha, candidate: binding(impact.candidate),
      candidateBaseSha, candidateParamsSha256, ledgerSha256: digest(ledger), impactSha256: digest(impact),
      impactInputSha256: impactInputDigest(impactInput), indexContractSha256: digest(indexContracts),
      operatorReceiptSha256: digest(initialization.receipt),
      selectedTargets: [...impact.selectedTargets], deferredImpactedTargets: [...impact.deferredImpactedTargets],
      retainedDeploymentTargets: ledger.functions.map((row) => row.target)
        .filter((target) => !impact.selectedTargets.includes(target))};
  });
}
export function completeMixedImpactRelease(input) {
  return safe(() => {
    exactKeys(input, ["preparation", "plan", "candidateDeployment", "allLiveIdentities"]);
    const {preparation, plan, candidateDeployment, allLiveIdentities} = input;
    assert.deepEqual(plan, prepareMixedImpactRelease(preparation));
    const ledger = initializeMixedFunctionLedger(preparation.initialization);
    return completeImpactLedger({preparation, plan, ledger, candidateDeployment, allLiveIdentities});
  });
}

function completeImpactLedger({preparation, plan, ledger, candidateDeployment, allLiveIdentities}) {
  const impact = assessSelectiveRuntimeImpact(preparation.impactInput);
  const manifest = manifestBinding(preparation.candidateManifest, plan.candidate);
  validateFunctionsDeployment(candidateDeployment, {manifest, scope: plan.scope,
    baseSha: plan.candidateBaseSha, selectedTargets: plan.selectedTargets,
    paramsSha256: plan.candidateParamsSha256});
  const selected = new Map(plan.selectedTargets.map((target, index) => [target, candidateDeployment.functions[index]]));
  const old = new Map(ledger.functions.map((row) => [row.target, row]));
  const functions = preparation.impactInput.candidateTargets.map((target) => {
    const prior = old.get(target);
    if (!selected.has(target)) {
      assert.ok(prior, "A new Function cannot be deferred without a deployment.");
      return structuredClone(prior);
    }
    const deployment = validateFunctionIdentity(selected.get(target), {scope: plan.scope, target});
    if (prior) assert.notDeepEqual(deployment, prior.deployment);
    const fingerprint = preparation.impactInput.candidateEvidence.source.functions[target];
    assert.deepEqual(fingerprint.unknown, []);
    return {target, fingerprintSha256: fingerprint.sha256, ...binding(plan.candidate),
      paramsSha256: plan.candidateParamsSha256, deployment};
  });
  const result = validateLedger({...structuredClone(ledger), functions});
  verifyIdentities(result, allLiveIdentities);
  assert.deepEqual(impact.deferredImpactedTargets, plan.deferredImpactedTargets);
  return {ledger: result, coverage: {schema: "catch.selective-impact-coverage/v1", scope: plan.scope,
    baselineCommonSourceSha: ledger.coverageSourceSha, candidate: binding(plan.candidate),
    selectedTargets: [...plan.selectedTargets], deferredImpactedTargets: [...plan.deferredImpactedTargets],
    retainedDeploymentTargets: [...plan.retainedDeploymentTargets],
    planSha256: digest(plan), ledgerSha256: digest(result)}};
}

// This adapter authenticates the actual successful rebaseline archive. It does
// not manufacture an operator receipt or grant index deployment authority.
async function baselineImpactPreparation(input, {request} = {}) {
  baselineImpactInputShape(input);
  const baselineArchive = structuredClone(input.baselineArchive);
  const manifest = structuredClone(input.baseline.manifest);
  const scope = input.scope;
  const entries = await readSuccessfulBaselineArchive({...baselineArchive, manifest, scope, request});
  assert.deepEqual(input.baselineArchive, baselineArchive);
  assert.deepEqual(input.baseline.manifest, manifest);
  assert.equal(input.scope, scope);
  return {...baselineImpactPlan(input, entries), entries};
}

function baselineImpactInputShape(input) {
  exactKeys(input, ["baselineArchive", "baseline", "scope", "impactInput", "candidateManifest",
    "candidateBaseSha", "paramsFile", "baselineIndexes", "candidateIndexes"]);
  exactKeys(input.baselineArchive, ["repository", "repositoryId", "runId", "runAttempt", "artifactId", "artifactDigest"]);
  exactKeys(input.baseline, ["manifest", "evidence", "paramsSha256", "baseSha"]);
}

function baselineImpactPlan(input, entries) {
  baselineImpactInputShape(input);
  const {baselineArchive, baseline, scope, impactInput, candidateManifest, candidateBaseSha,
    paramsFile, baselineIndexes, candidateIndexes} = input;
  const ledger = initializeFunctionLedger({deployment: entries[FUNCTIONS_DEPLOYMENT_FILE],
    manifest: baseline.manifest, scope, fingerprints: baseline.evidence.source,
    configSha256: baseline.evidence.runtimeConfigurationSha256,
    expectedParamsSha256: baseline.paramsSha256, expectedBaseSha: baseline.baseSha});
  const impact = assessSelectiveRuntimeImpact(impactInput);
  manifestBinding(baseline.manifest, impact.baseline);
  const candidate = manifestBinding(candidateManifest, impact.candidate);
  assert.deepEqual(candidate.stages, ["functions"], "This route only authorizes Functions.");
  assert.deepEqual(impactInput.baselineEvidence, baseline.evidence);
  assert.deepEqual(impactInput.baselineTargets, ledger.functions.map((row) => row.target));
  assert.match(candidateBaseSha ?? "", shaPattern);
  const projectId = scope.split(":")[2];
  const candidateParamsSha256 = readMaterializedParamsSha256(paramsFile, projectId);
  assert.equal(candidateParamsSha256, baseline.paramsSha256, "Fresh materialized baseline params changed.");
  assert.ok(impact.selectedTargets.length > 0);
  assert.ok(impact.addedTargets.every((target) => impact.selectedTargets.includes(target)),
    "A new Function requires a selected deployment before ledger completion.");
  const indexContracts = {baseline: indexInventory(baselineIndexes), candidate: indexInventory(candidateIndexes)};
  const additions = additive(baselineIndexes, candidateIndexes);
  const plan = {schema: "catch.baseline-selective-impact-plan/v1", scope,
    baselineCommonSourceSha: ledger.coverageSourceSha, candidate: binding(impact.candidate),
    candidateBaseSha, candidateParamsSha256, ledgerSha256: digest(ledger), impactSha256: digest(impact),
    impactInputSha256: impactInputDigest(impactInput), indexContractSha256: digest(indexContracts),
    baselineArchiveSha256: digest(baselineArchive), stages: ["functions"],
    indexReadiness: {scope, database: "(default)", indexes: additions},
    selectedTargets: [...impact.selectedTargets], deferredImpactedTargets: [...impact.deferredImpactedTargets],
    retainedDeploymentTargets: ledger.functions.map((row) => row.target)
      .filter((target) => !impact.selectedTargets.includes(target))};
  return {plan, ledger, impact, projectId};
}

export async function prepareBaselineImpactRelease(input, dependencies = {}) {
  try {
    const {plan, ledger, impact, projectId, entries} = await baselineImpactPreparation(input, dependencies);
    const functions = await (dependencies.readFunctions ?? liveFunctions)(projectId,
      input.impactInput.baselineTargets, {absentTargets: impact.addedTargets});
    // Also check injected collectors' returned metadata for unexpected additions.
    assert.ok(impact.addedTargets.every((target) => !functions.some((fn) =>
      fn.name === `projects/${projectId}/locations/asia-south1/functions/${target.slice(10)}`)));
    verifyLedgerLiveIdentities(ledger, captureFunctionIdentities(functions, plan.scope, input.impactInput.baselineTargets));
    assert.deepEqual(baselineImpactPlan(input, entries).plan, plan);
    return plan;
  } catch { throw new Error("Invalid selective backend release evidence."); }
}

export async function completeBaselineImpactRelease(input, dependencies = {}) {
  try {
    exactKeys(input, ["preparation", "plan", "candidateDeployment"]);
    const preparation = input.preparation;
    // Only small receipts are copied. Revalidate the full potentially multi-GB
    // preparation synchronously after collectors; no caller input is trusted
    // across an await merely because it matched the plan beforehand.
    const plan = structuredClone(input.plan);
    const candidateDeployment = structuredClone(input.candidateDeployment);
    const {plan: expected, projectId, entries} = await baselineImpactPreparation(preparation, dependencies);
    assert.deepEqual(plan, expected);
    const functions = await (dependencies.readFunctions ?? liveFunctions)(projectId, preparation.impactInput.candidateTargets);
    const allLiveIdentities = captureFunctionIdentities(functions, plan.scope, preparation.impactInput.candidateTargets);
    // Read only the independently scoped index metadata; READY is a
    // postcondition, never permission to add a stage to the Functions package.
    const liveIndexes = await (dependencies.readIndexes ?? gcloudIndexList)({projectId, database: "(default)"});
    assert.ok(Array.isArray(liveIndexes));
    const prefix = `projects/${projectId}/databases/(default)/collectionGroups/`;
    assert.ok(liveIndexes.every((index) => {
      if (typeof index.name !== "string" || !index.name.startsWith(prefix)) return false;
      const match = /^([A-Za-z_][A-Za-z0-9_.-]*)\/indexes\/[A-Za-z0-9_-]+$/.exec(index.name.slice(prefix.length));
      return match && (index.collectionGroup === undefined || index.collectionGroup === match[1]);
    }));
    const readiness = inspectIndexReadiness({indexes: plan.indexReadiness.indexes}, liveIndexes);
    assert.equal(readiness.complete, true);
    const final = baselineImpactPlan(preparation, entries);
    assert.deepEqual(final.plan, plan);
    const result = completeImpactLedger({preparation, plan, ledger: final.ledger, candidateDeployment, allLiveIdentities});
    return {...result, coverage: {...result.coverage,
      indexReadiness: {scope: plan.scope, database: "(default)",
        indexContractSha256: plan.indexContractSha256, readyIndexCount: readiness.ready.length}}};
  } catch { throw new Error("Invalid selective backend release evidence."); }
}
function verifyIdentities(ledger, identities) {
  validateLedger(ledger);
  assert.ok(Array.isArray(identities) && identities.length === ledger.functions.length);
  const expected = ledger.functions.map((row) => row.deployment).sort((a, b) => a.name.localeCompare(b.name));
  // Matching exact allowlisted row shapes also rejects unrequested metadata.
  const ordered = [...identities].sort((a, b) => a.name.localeCompare(b.name));
  assert.deepEqual(ordered, expected);
  return true;
}
export function verifyLedgerLiveIdentities(ledger, identities) { return safe(() => verifyIdentities(ledger, identities)); }
export function completeSelectiveRelease(input) {
  return safe(() => {
    exactKeys(input, ["plan", "preparation", "ledger", "deployment", "manifest", "baselineManifest", "candidateFingerprints",
      "expectedCandidateParamsSha256", "allLiveIdentities", "readyIndexContracts"]);
    const {plan, preparation, ledger, deployment, manifest: rawManifest, baselineManifest, candidateFingerprints,
      expectedCandidateParamsSha256, allLiveIdentities, readyIndexContracts} = input;
    validatePlan(plan);
    assert.deepEqual(plan, prepare(preparation));
    manifestBinding(baselineManifest, plan.baseline);
    const manifest = manifestBinding(rawManifest, plan.candidate); // Required even for a true no-op.
    validateLedger(ledger);
    assert.equal(ledger.coverageSourceSha, plan.baseline.sourceSha);
    assert.equal(ledger.runtimeConfigurationSha256, plan.runtimeConfigurationSha256);
    assert.match(expectedCandidateParamsSha256 ?? "", hashPattern);
    assert.equal(expectedCandidateParamsSha256, plan.paramsSha256);
    const allTargets = [...plan.targets, ...plan.unchangedTargets].sort();
    assert.deepEqual(ledger.functions.map((row) => row.target), allTargets);
    fingerprints(candidateFingerprints, allTargets);
    assert.deepEqual(candidateFingerprints, preparation.candidateEvidence.source);
    assert.ok(Array.isArray(readyIndexContracts));
    const ready = readyIndexContracts.map(indexContract).map((index) => JSON.stringify(index));
    assert.equal(new Set(ready).size, ready.length);
    assert.ok(plan.indexes.every((index) => ready.includes(JSON.stringify(index))));
    for (const row of ledger.functions) {
      assert.equal(row.fingerprintSha256, preparation.baselineEvidence.source.functions[row.target].sha256);
      assert.equal(row.paramsSha256, preparation.baselineParamsSha256);
    }
    if (plan.targets.length) validateFunctionsDeployment(deployment, {manifest, scope: ledger.scope,
      baseSha: plan.packageBaseSha, selectedTargets: plan.targets, paramsSha256: expectedCandidateParamsSha256});
    else assert.equal(deployment, null);
    const selected = new Map(plan.targets.map((target, index) => [target, deployment.functions[index]]));
    const functions = ledger.functions.map((row) => {
      const fingerprint = candidateFingerprints.functions[row.target].sha256;
      if (!selected.has(row.target)) {
        assert.equal(row.fingerprintSha256, fingerprint);
        return structuredClone(row); // Its real old source/package/run/revision stays intact.
      }
      assert.notDeepEqual(selected.get(row.target), row.deployment);
      return {...row, fingerprintSha256: fingerprint, ...binding(plan.candidate), paramsSha256: expectedCandidateParamsSha256,
        deployment: validateFunctionIdentity(selected.get(row.target), {scope: ledger.scope, target: row.target})};
    });
    const result = {...structuredClone(ledger), coverageSourceSha: plan.candidate.sourceSha, functions};
    verifyIdentities(result, allLiveIdentities);
    return {ledger: result, coverage: {schema: "catch.selective-backend-coverage/v1", scope: ledger.scope,
      baseline: binding(plan.baseline), candidate: binding(plan.candidate), coveredSources: [...plan.coveredSources],
      planSha256: digest(plan), ledgerSha256: digest(result), indexContractSha256: plan.indexContractSha256,
      deployedTargets: [...plan.targets], retainedTargets: [...plan.unchangedTargets]}};
  });
}

// One protected projection of the immutable PR543-compatible main package. The
// historical 601-Function plan remains unchanged on disk; this profile only
// narrows its execution plan to the reviewed Sales closure and Firestore rules.
export const SALES_PR543_RELEASE = Object.freeze({
  sourceSha: "c0a213bd9663f69ed1f8df3b5bad9284930e5339",
  baseSha: "63f13abe6fbc6051771ea6eeab1d147a956f0be5",
  sourceCiRunId: "37560236235",
  sourceCiRunAttempt: "1",
  packageSha256: "594dcd96b724a1a81c0545a015c6099277e35475d30aa0969e4540b1dee319e5",
  scope: "firebase:prod:catch-dating-app-64e51",
  projectId: "catch-dating-app-64e51",
  targets: Object.freeze([
    "functions:adminApplySalesPrivacyBatch",
    "functions:adminAssignSalesPartner",
    "functions:adminBuildSalesOutreachInput",
    "functions:adminCopySalesOutreachDraft",
    "functions:adminGenerateSalesOutreachDraft",
    "functions:adminGetSalesDemoPartnerReview",
    "functions:adminGetSalesIntelligenceCatalog",
    "functions:adminGetSalesIntelligenceScore",
    "functions:adminGetSalesOutreachDraft",
    "functions:adminGetSalesOutreachDraftJob",
    "functions:adminGetSalesPrivacyCase",
    "functions:adminLinkSalesInboundIntent",
    "functions:adminListSalesInboundIntents",
    "functions:adminListSalesOutreachDrafts",
    "functions:adminPreviewSalesPrivacyPlan",
    "functions:adminRestrictSalesOrganizer",
    "functions:adminReviewSalesIntelligenceClause",
    "functions:adminReviewSalesOutreachDraft",
    "functions:adminReviewSalesPrivacyPlan",
    "functions:adminReviewSalesPrivacyPolicy",
    "functions:adminRevokeSalesPartnerAccess",
    "functions:adminSaveSalesFactorAssessment",
    "functions:adminSaveSalesIntelligenceClause",
    "functions:adminSaveSalesIntelligencePolicy",
    "functions:adminSaveSalesScoreSnapshot",
    "functions:adminShareSalesDemoPartnerReview",
    "functions:copySalesPartnerOutreachDraft",
    "functions:createSalesDemoContinuation",
    "functions:decideSalesPartnerAssignment",
    "functions:expireSalesDemos",
    "functions:generateSalesPartnerOutreach",
    "functions:getSalesDemoContinuation",
    "functions:getSalesPartnerDemoReviews",
    "functions:getSalesPartnerOutreachDraft",
    "functions:getSalesPartnerOutreachJob",
    "functions:getSalesPartnerPreparation",
    "functions:getSalesPartnerWorkspace",
    "functions:nominateSalesOrganizer",
    "functions:prepareSalesDemoContinuationForm",
    "functions:proposeSalesPartnerDemoWording",
    "functions:recordSalesPartnerManualSend",
    "functions:registerSalesPartner",
    "functions:reviewSalesPartnerOutreachDraft",
    "functions:updateSalesPartnerAssignment",
  ]),
  addedTargets: Object.freeze([
    "functions:adminAssignSalesPartner",
    "functions:adminGetSalesDemoPartnerReview",
    "functions:adminRevokeSalesPartnerAccess",
    "functions:adminShareSalesDemoPartnerReview",
    "functions:copySalesPartnerOutreachDraft",
    "functions:createSalesDemoContinuation",
    "functions:decideSalesPartnerAssignment",
    "functions:generateSalesPartnerOutreach",
    "functions:getSalesDemoContinuation",
    "functions:getSalesPartnerDemoReviews",
    "functions:getSalesPartnerOutreachDraft",
    "functions:getSalesPartnerOutreachJob",
    "functions:getSalesPartnerPreparation",
    "functions:getSalesPartnerWorkspace",
    "functions:nominateSalesOrganizer",
    "functions:prepareSalesDemoContinuationForm",
    "functions:proposeSalesPartnerDemoWording",
    "functions:recordSalesPartnerManualSend",
    "functions:registerSalesPartner",
    "functions:reviewSalesPartnerOutreachDraft",
    "functions:updateSalesPartnerAssignment",
  ]),
});
export const SALES_PR543_RETAINED_TARGETS = Object.freeze(SALES_PR543_RELEASE.targets
  .filter((target) => !SALES_PR543_RELEASE.addedTargets.includes(target)));

// PR575 changes only protected operator CLI planning. Neither module is in
// index.ts's runtime closure (including initialization of every re-export).
// Bind that reviewed separation to exact Git objects, never a path exclusion.
export const SALES_SOURCE_CHECKPOINT = "6256356bb9b41dbb5727354f5cb77384773c0454";
export const SALES_SOURCE_GUARDED_PATHS = Object.freeze(salesSourceGuardedPaths);
export const SALES_SOURCE_DELTA = Object.freeze([
  Object.freeze({path: "functions/src/catchMessaging/whatsappOperatorSetup.ts",
    candidateGitBlob: "e0e2ce455c5f08ccc73003a051f4471c15ea0238",
    mergedGitBlob: "2a2b8b3bf9e5b95f8ca33f7f5bb49cea6a9ffc98"}),
  Object.freeze({path: "functions/src/catchMessaging/whatsappOperatorSetup.test.ts",
    candidateGitBlob: "d8aec1c0c2b9a82d45a879f054090d68563b9158",
    mergedGitBlob: "de98ec81ac63692a73040b639da582e4f6e7ebcc"}),
]);

export function verifySalesSourceCompatibility(evidence) {
  assert.equal(evidence.sourceSha, SALES_PR543_RELEASE.sourceSha);
  assert.match(evidence.currentSha, shaPattern);
  assert.equal(evidence.sourceAncestor, true);
  assert.equal(evidence.checkpointAncestor, true);
  assert.deepEqual([...evidence.changedPaths].sort(), SALES_SOURCE_DELTA.map((row) => row.path).sort());
  assert.deepEqual(evidence.currentDifference, []);
  assert.equal(evidence.rows.length, SALES_SOURCE_DELTA.length);
  for (const row of SALES_SOURCE_DELTA) {
    assert.deepEqual(evidence.rows.find((entry) => entry.path === row.path),
      {...row, candidateMode: "100644", checkpointMode: "100644"});
  }
  return {sourceSha: SALES_PR543_RELEASE.sourceSha, compatibilityCheckpoint: SALES_SOURCE_CHECKPOINT};
}

export function checkSalesGitCompatibility(sourceSha, currentSha, cwd = process.cwd()) {
  assert.equal(sourceSha, SALES_PR543_RELEASE.sourceSha);
  assert.match(currentSha, shaPattern);
  const git = (args) => {
    const result = spawnSync("git", args, {cwd, encoding: "utf8", timeout: 10000, maxBuffer: 1024 * 1024});
    assert.ifError(result.error);
    assert.equal(result.status, 0, "Sales compatibility Git proof failed.");
    return result.stdout;
  };
  for (const sha of [sourceSha, currentSha, SALES_SOURCE_CHECKPOINT]) {
    assert.equal(git(["rev-parse", "--verify", `${sha}^{commit}`]).trim(), sha);
  }
  git(["merge-base", "--is-ancestor", sourceSha, currentSha]);
  git(["merge-base", "--is-ancestor", SALES_SOURCE_CHECKPOINT, currentSha]);
  const differences = (before, after) => git([
    "diff", "--name-only", "--no-renames", "-z", before, after, "--", ...SALES_SOURCE_GUARDED_PATHS,
  ]).split("\0").filter(Boolean);
  const entry = (sha, file) => {
    const match = /^(\d{6}) blob ([0-9a-f]{40})\t/.exec(git(["ls-tree", sha, "--", file]).trim());
    assert.ok(match, "Sales compatibility requires regular tracked source.");
    return {mode: match[1], blob: match[2]};
  };
  const rows = SALES_SOURCE_DELTA.map(({path}) => {
    const candidate = entry(sourceSha, path);
    const checkpoint = entry(SALES_SOURCE_CHECKPOINT, path);
    return {path, candidateGitBlob: candidate.blob, mergedGitBlob: checkpoint.blob,
      candidateMode: candidate.mode, checkpointMode: checkpoint.mode};
  });
  return verifySalesSourceCompatibility({sourceSha, currentSha, sourceAncestor: true, checkpointAncestor: true,
    changedPaths: differences(sourceSha, SALES_SOURCE_CHECKPOINT), rows,
    currentDifference: differences(SALES_SOURCE_CHECKPOINT, currentSha)});
}

// Only the original authenticated recovery artifacts may enter this route.
// The workflow independently authenticates producer, archive digest and before
// proof; this mode cannot create missing proof or deploy/repair Functions.
export function checkSalesCheckpointSource(sourceSha, currentSha, cwd, runId, runAttempt) {
  assert.equal(sourceSha, SALES_PR543_RELEASE.sourceSha);
  assert.equal(runId, "37576714164");
  assert.equal(runAttempt, "1");
  assert.match(currentSha, shaPattern);
  const git = (args) => {
    const result = spawnSync("git", args, {cwd, encoding: "utf8", timeout: 10000, maxBuffer: 1024 * 1024});
    assert.ifError(result.error);
    assert.equal(result.status, 0, "Sales checkpoint rules/source proof failed.");
    return result.stdout;
  };
  for (const sha of [sourceSha, currentSha]) {
    assert.equal(git(["rev-parse", "--verify", `${sha}^{commit}`]).trim(), sha);
  }
  git(["merge-base", "--is-ancestor", sourceSha, currentSha]);
  git(["diff", "--quiet", sourceSha, currentSha, "--", "firestore.rules", "firebase.json", ".firebaserc"]);
  const rules = git(["ls-tree", sourceSha, "--", "firestore.rules"]).trim();
  assert.match(rules, /^100644 blob [0-9a-f]{40}\tfirestore\.rules$/);
  return {checkpointOnly: true};
}

export async function verifySalesCheckpointOnly(input, {
  readLive = liveFunctions, readPolicy, checkReadiness, checkParity,
} = {}) {
  const manifest = salesManifest(input.manifest);
  prepareSalesPr543Release(input);
  const state = validateCheckpointState(manifest, input.checkpoint, SALES_PR543_RELEASE.scope);
  assert.ok(state.stageCheckpoints.some((row) => row.stage === "functions"),
    "Sales checkpoint-only recovery requires an existing Functions checkpoint.");
  assert.equal(resolveFirstIncompleteStage(manifest, state, SALES_PR543_RELEASE.scope).stage, input.stage);
  assert.ok(["functions", "firestore-rules"].includes(input.stage));
  assert.ok(Buffer.isBuffer(input.acceptedRules) && Buffer.isBuffer(input.packagedRules));
  assert.ok(input.acceptedRules.equals(input.packagedRules), "Packaged rules must match the accepted source bytes.");
  validateFunctionsDeployment(input.deployment, {manifest, scope: SALES_PR543_RELEASE.scope,
    baseSha: SALES_PR543_RELEASE.baseSha, selectedTargets: SALES_PR543_RELEASE.targets,
    paramsSha256: input.expectedParamsSha256});
  validateSalesPr543Before(input.before);
  assert.equal(typeof readPolicy, "function");
  assert.equal(typeof checkReadiness, "function");
  assert.equal(typeof checkParity, "function");
  const functions = await readLive(SALES_PR543_RELEASE.projectId, SALES_PR543_RELEASE.targets);
  completeSalesPr543Release({...input, functions});
  for (const [index, target] of SALES_PR543_RELEASE.targets.entries()) {
    if (target === "functions:expireSalesDemos") continue; // The sole scheduled target.
    const policy = await readPolicy(input.deployment.functions[index].service);
    assert.deepEqual(policy?.bindings, [{role: "roles/run.invoker", members: ["allUsers"]}],
      "Sales callable IAM differs from its intended public invoker policy; repair is forbidden.");
  }
  await checkParity();
  await checkReadiness();
  // Fence drift during the IAM/readiness reads immediately before returning
  // authority for the rules-only executor.
  completeSalesPr543Release({...input,
    functions: await readLive(SALES_PR543_RELEASE.projectId, SALES_PR543_RELEASE.targets)});
  return {checkpointOnly: true, functionsDeploymentAllowed: false, iamRepairAllowed: false,
    verifiedFunctions: 44, authorizedStage: input.stage};
}

const bytesDigest = (bytes) => createHash("sha256").update(bytes).digest("hex");
const salesFail = () => { throw new Error("Invalid Sales PR543 selective release evidence."); };
const salesSafe = (action) => { try { return action(); } catch { return salesFail(); } };
const salesSame = (a, b) => assert.deepEqual(a, b);
const salesExactKeys = (value, names) => {
  assert.ok(value && typeof value === "object" && !Array.isArray(value));
  salesSame(Object.keys(value).sort(), [...names].sort());
};
const salesManifest = (raw) => {
  const manifest = validateProvenanceManifest(raw);
  assert.equal(manifest.sourceSha, SALES_PR543_RELEASE.sourceSha);
  assert.equal(manifest.sourceCiRunId, SALES_PR543_RELEASE.sourceCiRunId);
  assert.equal(manifest.sourceCiRunAttempt, SALES_PR543_RELEASE.sourceCiRunAttempt);
  salesSame(manifest.stages, ["functions", "firestore-rules"]);
  assert.equal(manifest.artifact.name, "firebase-backend.tar.gz");
  assert.equal(manifest.artifact.sizeBytes, 8144024);
  assert.equal(manifest.artifact.sha256, SALES_PR543_RELEASE.packageSha256);
  return manifest;
};

export function prepareSalesPr543Release({packagePlan, manifest: rawManifest}) {
  return salesSafe(() => {
    salesManifest(rawManifest);
    const release = SALES_PR543_RELEASE;
    assert.equal(packagePlan.sourceSha, release.sourceSha);
    assert.equal(packagePlan.baseSha, release.baseSha);
    assert.equal(packagePlan.sourceCiRunId, release.sourceCiRunId);
    assert.equal(packagePlan.sourceCiRunAttempt, release.sourceCiRunAttempt);
    assert.equal(packagePlan.schema, "catch.firebase-delivery-plan/v2");
    salesSame(packagePlan.deployGroups, ["firestore-rules", "functions"]);
    salesSame(packagePlan.stages, ["functions", "firestore-rules"]);
    assert.equal(packagePlan.targets?.length, 2);
    assert.equal(packagePlan.targets[1], "firestore:rules");
    const historical = packagePlan.targets[0]?.split(",");
    assert.equal(historical?.length, 601);
    assert.equal(new Set(historical).size, 601);
    assert.ok(historical.every((target) => /^functions:[A-Za-z][A-Za-z0-9_-]*$/u.test(target)));
    salesSame(historical, [...historical].sort());
    assert.ok(release.targets.every((target) => historical.includes(target)));
    salesSame(release.targets, [...release.targets].sort());
    salesSame(release.addedTargets, [...release.addedTargets].sort());
    assert.ok(release.addedTargets.every((target) => release.targets.includes(target)));
    assert.equal(SALES_PR543_RETAINED_TARGETS.length, 23);
    return {...structuredClone(packagePlan), targets: [release.targets.join(","), "firestore:rules"]};
  });
}

export function verifySalesPr543Params(file) {
  return salesSafe(() => {
    assert.equal(path.basename(file), `.env.${SALES_PR543_RELEASE.projectId}`);
    const stat = fs.lstatSync(file);
    assert.ok(stat.isFile() && !stat.isSymbolicLink() && stat.size < 1024 * 1024);
    assert.equal(stat.mode & 0o077, 0);
    return {paramsSha256: readMaterializedParamsSha256(file, SALES_PR543_RELEASE.projectId)};
  });
}

export function captureSalesPr543Before({manifest: rawManifest, packagePlan, functions}) {
  return salesSafe(() => {
    prepareSalesPr543Release({packagePlan, manifest: rawManifest});
    return {schema: "catch.sales-pr543-before/v1", scope: SALES_PR543_RELEASE.scope,
      sourceSha: SALES_PR543_RELEASE.sourceSha, packageSha256: SALES_PR543_RELEASE.packageSha256,
      selectedTargets: [...SALES_PR543_RELEASE.targets], absentTargets: [...SALES_PR543_RELEASE.addedTargets],
      functions: captureFunctionIdentities(functions, SALES_PR543_RELEASE.scope, SALES_PR543_RETAINED_TARGETS)};
  });
}

function salesBefore(value) {
  salesExactKeys(value, ["schema", "scope", "sourceSha", "packageSha256", "selectedTargets", "absentTargets", "functions"]);
  assert.equal(value.schema, "catch.sales-pr543-before/v1");
  assert.equal(value.scope, SALES_PR543_RELEASE.scope);
  assert.equal(value.sourceSha, SALES_PR543_RELEASE.sourceSha);
  assert.equal(value.packageSha256, SALES_PR543_RELEASE.packageSha256);
  salesSame(value.selectedTargets, SALES_PR543_RELEASE.targets);
  salesSame(value.absentTargets, SALES_PR543_RELEASE.addedTargets);
  assert.ok(Array.isArray(value.functions) && value.functions.length === SALES_PR543_RETAINED_TARGETS.length);
  value.functions.forEach((identity, index) => validateFunctionIdentity(identity,
    {scope: SALES_PR543_RELEASE.scope, target: SALES_PR543_RETAINED_TARGETS[index]}));
  return structuredClone(value);
}

export function validateSalesPr543Before(value) {
  return salesSafe(() => salesBefore(value));
}

export function completeSalesPr543Release({manifest: rawManifest, packagePlan, before, deployment,
  expectedParamsSha256, functions}) {
  return salesSafe(() => {
    const manifest = salesManifest(rawManifest);
    prepareSalesPr543Release({packagePlan, manifest});
    before = salesBefore(before);
    assert.match(expectedParamsSha256 ?? "", /^[0-9a-f]{64}$/u);
    validateFunctionsDeployment(deployment, {manifest, scope: SALES_PR543_RELEASE.scope,
      baseSha: SALES_PR543_RELEASE.baseSha, selectedTargets: SALES_PR543_RELEASE.targets,
      paramsSha256: expectedParamsSha256});
    const actual = captureFunctionIdentities(functions, SALES_PR543_RELEASE.scope, SALES_PR543_RELEASE.targets);
    salesSame(actual, deployment.functions);
    const actualByTarget = new Map(SALES_PR543_RELEASE.targets.map((target, index) => [target, actual[index]]));
    SALES_PR543_RETAINED_TARGETS.forEach((target, index) => {
      assert.notEqual(actualByTarget.get(target).revision, before.functions[index].revision);
      assert.notEqual(actualByTarget.get(target).build, before.functions[index].build);
    });
    return {schema: "catch.sales-pr543-selected-receipt/v1", scope: SALES_PR543_RELEASE.scope,
      sourceSha: SALES_PR543_RELEASE.sourceSha, packageSha256: SALES_PR543_RELEASE.packageSha256,
      selectedTargets: [...SALES_PR543_RELEASE.targets], addedTargets: [...SALES_PR543_RELEASE.addedTargets],
      paramsSha256: expectedParamsSha256, beforeSha256: bytesDigest(JSON.stringify(before)), functions: actual,
      rulesTarget: "firestore:rules", coverage: "selected-physical-identities-and-exact-rules-only"};
  });
}

const salesRead = (file) => JSON.parse(fs.readFileSync(file, "utf8"));
const salesWrite = (file, value) => fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`, {flag: "wx", mode: 0o600});
const salesOptions = (args) => {
  const result = {};
  for (let index = 0; index < args.length; index += 2) {
    assert.ok(args[index]?.startsWith("--") && args[index + 1]);
    const key = args[index].slice(2);
    assert.ok(!Object.hasOwn(result, key));
    result[key] = args[index + 1];
  }
  return result;
};

export async function runSalesPr543ReleaseCli(argv, {readLive = liveFunctions, runCommand = spawnSync} = {}) {
  try {
    const [command, ...rest] = argv;
    assert.ok(["checkpoint-source", "checkpoint-only", "source", "prepare", "params", "stage", "before", "verify-before", "complete"].includes(command));
    const args = salesOptions(rest);
    salesExactKeys(args, command === "checkpoint-source" ? ["source-sha", "current-main", "source-root", "run-id", "run-attempt"] :
      command === "checkpoint-only" ? ["manifest", "package-plan", "before", "deployment", "checkpoint",
        "params-file", "stage", "source-root", "package-root", "current-main", "run-id", "run-attempt", "readiness-candidate"] :
      command === "source" ? ["source-sha", "current-main", "source-root"] :
      command === "params" ? ["params-file"] :
      command === "stage" ? ["stage", "target"] :
      command === "verify-before" ? ["manifest", "package-plan", "before"] :
      command === "complete" ? ["manifest", "package-plan", "before", "deployment", "params-sha256", "output"] :
        ["manifest", "package-plan", "output"]);
    if (command === "source") return checkSalesGitCompatibility(
      args["source-sha"], args["current-main"], args["source-root"]);
    if (command === "checkpoint-source") return checkSalesCheckpointSource(
      args["source-sha"], args["current-main"], args["source-root"], args["run-id"], args["run-attempt"]);
    if (command === "checkpoint-only") {
      checkSalesCheckpointSource(SALES_PR543_RELEASE.sourceSha, args["current-main"], args["source-root"],
        args["run-id"], args["run-attempt"]);
      const execute = (name, options) => {
        const result = runCommand(name, options, {encoding: "utf8", timeout: 120000, maxBuffer: 1024 * 1024});
        assert.ifError(result.error);
        assert.equal(result.status, 0, "Sales checkpoint-only metadata verification failed.");
        return result.stdout;
      };
      const sourceRoot = path.resolve(args["source-root"]);
      const target = SALES_PR543_RELEASE.targets.join(",");
      return await verifySalesCheckpointOnly({manifest: salesRead(args.manifest), packagePlan: salesRead(args["package-plan"]),
        before: salesRead(args.before), deployment: salesRead(args.deployment), checkpoint: salesRead(args.checkpoint),
        stage: args.stage, expectedParamsSha256: verifySalesPr543Params(args["params-file"]).paramsSha256,
        acceptedRules: Buffer.from(execute("git", ["-C", sourceRoot, "show", `${SALES_PR543_RELEASE.sourceSha}:firestore.rules`])),
        packagedRules: fs.readFileSync(path.join(args["package-root"], "firestore.rules"))}, {
        readLive,
        readPolicy: async (service) => JSON.parse(execute("gcloud", ["run", "services", "get-iam-policy",
          service.split("/").at(-1), "--project", SALES_PR543_RELEASE.projectId,
          "--region", "asia-south1", "--format=json"])),
        checkParity: async () => execute(process.execPath, [path.join(path.dirname(fileURLToPath(import.meta.url)),
          "../firebase/check_deploy_parity.mjs"), "--env", "prod", "--repo-root", sourceRoot, "--targets", target]),
        checkReadiness: async () => execute(process.execPath, [path.join(path.dirname(fileURLToPath(import.meta.url)),
          "../firebase/check_environment_readiness.mjs"), "--env", "prod", "--targets", target,
        "--source-root", sourceRoot, "--source-sha", SALES_PR543_RELEASE.sourceSha,
        "--candidate", args["readiness-candidate"], "--phase", "deployed"]),
      });
    }
    if (command === "params") return verifySalesPr543Params(args["params-file"]);
    if (command === "stage") {
      if (args.stage === "functions") assert.equal(args.target, SALES_PR543_RELEASE.targets.join(","));
      else {
        assert.equal(args.stage, "firestore-rules");
        assert.equal(args.target, "firestore:rules");
      }
      return {authorizedStage: args.stage};
    }
    const manifest = salesRead(args.manifest);
    const packagePlan = salesRead(args["package-plan"]);
    if (command === "verify-before") {
      prepareSalesPr543Release({packagePlan, manifest});
      validateSalesPr543Before(salesRead(args.before));
      return {verifiedBefore: true, existingFunctions: 23, absentFunctions: 21};
    }
    if (command === "prepare") {
      salesWrite(args.output, prepareSalesPr543Release({packagePlan, manifest}));
      return {prepared: true, selectedFunctions: 44, selectedRules: 1};
    }
    if (command === "before") {
      const functions = await readLive(SALES_PR543_RELEASE.projectId, SALES_PR543_RETAINED_TARGETS,
        {absentTargets: SALES_PR543_RELEASE.addedTargets});
      salesWrite(args.output, captureSalesPr543Before({manifest, packagePlan, functions}));
      return {verifiedBefore: true, existingFunctions: 23, absentFunctions: 21};
    }
    const functions = await readLive(SALES_PR543_RELEASE.projectId, SALES_PR543_RELEASE.targets);
    const result = completeSalesPr543Release({manifest, packagePlan, functions,
      before: salesRead(args.before), deployment: salesRead(args.deployment),
      expectedParamsSha256: args["params-sha256"]});
    salesWrite(args.output, result);
    return {verifiedComplete: true, selectedFunctions: 44, selectedRules: 1};
  } catch { return salesFail(); }
}

// Fixed PR596 release profile. This is not a generic target or recovery API.
export const INTAKE_PR596_RELEASE = Object.freeze({
  sourceSha: "ceab9d8abf5de7ad383260739032e0e1603d45ff",
  baseSha: "6f3532cdff471f8025a03d38516aeada7c207cfc",
  sourceCiRunId: "37777899024", sourceCiRunAttempt: "1",
  artifactId: 11551444925,
  artifactSha256: "434c0ba77ad5260a90e9edd2008fd8842f4d307c7389e19d12e0a55b6dcad2b9",
  provenanceSha256: "439e80f9469f34935e188d49503b2803cde137a4e3c7f9ceb7a0c11f7fb25bfe",
  checkpointSha: "61a5b1e497acae1b9819c2123815d703e2142172",
  projectId: "catch-dating-app-64e51", scope: "firebase:prod:catch-dating-app-64e51",
  target: "functions:adminListIntakeOperations",
});
export const INTAKE_SOURCE_GUARDED_PATHS = Object.freeze([
  "functions", "firebase.json", ".firebaserc", "firestore.rules", "firestore.indexes.json", "storage.rules",
]);
export const INTAKE_SOURCE_DELTA = Object.freeze([
  {
    "path": "functions/scripts/operations/catch-whatsapp-session-handoff.cjs",
    "candidateMode": "100644",
    "candidateGitBlob": "888ca2f061c4caf81d49a37d563b97e7367b97ad",
    "checkpointMode": "100644",
    "checkpointGitBlob": "db1ffe83d0660a331b31b0921354d84ffbe00a4a"
  },
  {
    "path": "functions/scripts/operations/catch-whatsapp-session-handoff.md",
    "candidateMode": "100644",
    "candidateGitBlob": "fc5af68b041dedb5884356d54935cadf634bd91d",
    "checkpointMode": "100644",
    "checkpointGitBlob": "7098e22c9c0da31176ae9e8d1ffa4d2a9b454807"
  },
  {
    "path": "functions/src/catchMessaging/whatsappOperatorSetup.test.ts",
    "candidateMode": "100644",
    "candidateGitBlob": "de98ec81ac63692a73040b639da582e4f6e7ebcc",
    "checkpointMode": "100644",
    "checkpointGitBlob": "324f1187bc75f20586efe8e39f9da88ee0a71f3f"
  },
  {
    "path": "functions/src/catchMessaging/whatsappOperatorSetup.ts",
    "candidateMode": "100644",
    "candidateGitBlob": "2a2b8b3bf9e5b95f8ca33f7f5bb49cea6a9ffc98",
    "checkpointMode": "100644",
    "checkpointGitBlob": "a6db6cf3cf83987649cbdaff08636c26d636ce30"
  },
  {
    "path": "functions/test/operations-catch-whatsapp-session-handoff.test.cjs",
    "candidateMode": "100644",
    "candidateGitBlob": "a071a0c9c4af5facb93d9c2874bf5f7cf5f83f8e",
    "checkpointMode": "100644",
    "checkpointGitBlob": "a71e889b9cad812c29882828a4199763a461e3a3"
  }
]);

export function verifyIntakeSourceCompatibility(evidence) {
  const r = INTAKE_PR596_RELEASE;
  assert.equal(evidence.sourceSha, r.sourceSha);
  assert.match(evidence.currentSha, shaPattern);
  assert.equal(evidence.sourceAncestor, true);
  assert.equal(evidence.checkpointAncestor, true);
  assert.deepEqual(evidence.changedPaths.slice().sort(), INTAKE_SOURCE_DELTA.map((row) => row.path).sort());
  assert.deepEqual(evidence.currentDifference, []);
  assert.deepEqual(evidence.rows.slice().sort((a, b) => a.path.localeCompare(b.path)),
    INTAKE_SOURCE_DELTA.slice().sort((a, b) => a.path.localeCompare(b.path)));
  return {sourceSha: r.sourceSha, compatibilityCheckpoint: r.checkpointSha};
}
export function checkIntakeGitCompatibility(currentSha, cwd = process.cwd()) {
  const r = INTAKE_PR596_RELEASE;
  assert.match(currentSha, shaPattern);
  const git = (args) => {
    const result = spawnSync("git", args, {cwd, encoding: "utf8", timeout: 10000, maxBuffer: 1024 * 1024});
    assert.ifError(result.error); assert.equal(result.status, 0, "Intake source compatibility is unproven.");
    return result.stdout;
  };
  for (const sha of [r.sourceSha, r.checkpointSha, currentSha]) {
    assert.equal(git(["rev-parse", "--verify", `${sha}^{commit}`]).trim(), sha);
    git(["merge-base", "--is-ancestor", sha, currentSha]);
  }
  const difference = (a, b) => git(["diff", "--name-only", "--no-renames", "-z", a, b,
    "--", ...INTAKE_SOURCE_GUARDED_PATHS]).split("\0").filter(Boolean);
  const entry = (sha, file) => {
    const match = /^(\d{6}) blob ([0-9a-f]{40})\t/.exec(git(["ls-tree", sha, "--", `:(literal)${file}`]));
    assert.ok(match); return {mode: match[1], blob: match[2]};
  };
  const rows = INTAKE_SOURCE_DELTA.map(({path}) => {
    const candidate = entry(r.sourceSha, path), checkpoint = entry(r.checkpointSha, path);
    return {path, candidateMode: candidate.mode, candidateGitBlob: candidate.blob,
      checkpointMode: checkpoint.mode, checkpointGitBlob: checkpoint.blob};
  });
  return verifyIntakeSourceCompatibility({sourceSha: r.sourceSha, currentSha, sourceAncestor: true,
    checkpointAncestor: true, changedPaths: difference(r.sourceSha, r.checkpointSha), rows,
    currentDifference: difference(r.checkpointSha, currentSha)});
}
export function verifyIntakeArtifactMetadata(artifact) {
  const r = INTAKE_PR596_RELEASE;
  assert.equal(artifact.id, r.artifactId); assert.equal(artifact.expired, false);
  assert.equal(artifact.name, `firebase-delivery-${r.sourceSha}-1`);
  assert.equal(artifact.digest, `sha256:${r.artifactSha256}`);
  assert.equal(artifact.workflow_run?.id, Number(r.sourceCiRunId));
  assert.equal(artifact.workflow_run?.head_sha, r.sourceSha);
  return {artifactId: r.artifactId, artifactSha256: r.artifactSha256};
}
export function verifyIntakeProvenance(raw) {
  assert.equal(provenanceDigest(raw), INTAKE_PR596_RELEASE.provenanceSha256);
  return validateProvenanceManifest(raw);
}
export function prepareIntakePr596Release({packagePlan, manifest: raw}) {
  const r = INTAKE_PR596_RELEASE, manifest = validateProvenanceManifest(raw);
  for (const value of [manifest, packagePlan]) {
    assert.equal(value.sourceSha, r.sourceSha); assert.equal(value.sourceCiRunId, r.sourceCiRunId);
    assert.equal(value.sourceCiRunAttempt, r.sourceCiRunAttempt); assert.deepEqual(value.stages, ["functions"]);
  }
  assert.equal(packagePlan.schema, "catch.firebase-delivery-plan/v2");
  assert.equal(packagePlan.baseSha, r.baseSha); assert.deepEqual(packagePlan.deployGroups, ["functions"]);
  assert.equal(manifest.artifact.name, "firebase-backend.tar.gz");
  assert.equal(packagePlan.targets?.length, 1);
  const targets = packagePlan.targets[0].split(",");
  targetList(targets); assert.ok(targets.includes(r.target));
  return {...structuredClone(packagePlan), targets: [r.target]};
}
const intakeSelectedName = `projects/${INTAKE_PR596_RELEASE.projectId}/locations/asia-south1/functions/adminListIntakeOperations`;
function intakeSnapshot(value) {
  exactKeys(value, ["schema", "projectId", "functions", "protectedResources", "selected"]);
  assert.equal(value.schema, "catch.intake-pr596-metadata/v1");
  assert.equal(value.projectId, INTAKE_PR596_RELEASE.projectId);
  assert.ok(Array.isArray(value.functions) && value.functions.length > 0 && value.functions.length <= 3000);
  const names = value.functions.map((row) => {
    exactKeys(row, ["name", "sha256"]); assert.match(row.sha256, hashPattern);
    assert.match(row.name, /^projects\/catch-dating-app-64e51\/locations\/[a-z0-9-]+\/functions\/[A-Za-z0-9_-]+$/);
    return row.name;
  });
  assert.equal(new Set(names).size, names.length); assert.deepEqual(names, names.slice().sort((a, b) => a.localeCompare(b)));
  exactKeys(value.protectedResources, ["extensions", "indexes", "fields", "rules", "remoteConfig", "projectIam"]);
  for (const hash of Object.values(value.protectedResources)) assert.match(hash, hashPattern);
  if (value.selected !== null) {
    exactKeys(value.selected, ["identity", "runtime", "iamSha256", "publicInvoker"]);
    validateFunctionIdentity(value.selected.identity, {scope: INTAKE_PR596_RELEASE.scope, target: INTAKE_PR596_RELEASE.target});
    assert.ok(names.includes(intakeSelectedName)); assert.match(value.selected.iamSha256, hashPattern);
  } else assert.ok(!names.includes(intakeSelectedName));
  return value;
}
export function verifyIntakePreservation(before, after, {completed = false, paramsSha256} = {}) {
  intakeSnapshot(before); intakeSnapshot(after);
  const retained = (snapshot) => snapshot.functions.filter((row) => row.name !== intakeSelectedName);
  assert.deepEqual(retained(after), retained(before), "An unselected Function/Extension identity or configuration changed.");
  assert.deepEqual(after.protectedResources, before.protectedResources, "An unselected cloud resource changed.");
  if (!completed) assert.deepEqual(after, before, "Metadata changed before the one permitted invocation.");
  else {
    assert.ok(after.selected); assert.equal(after.selected.publicInvoker, true);
    const runtime = after.selected.runtime;
    exactKeys(runtime, ["runtime", "entryPoint", "serviceAccount", "memory", "maxInstances", "secretBindings", "paramsSha256"]);
    assert.equal(runtime.runtime, "nodejs24"); assert.equal(runtime.entryPoint, "adminListIntakeOperations");
    assert.equal(runtime.serviceAccount, "574779808785-compute@developer.gserviceaccount.com");
    assert.equal(runtime.memory, "512Mi"); assert.equal(runtime.maxInstances, 50); assert.equal(runtime.secretBindings, 0);
    assert.match(paramsSha256, hashPattern); assert.equal(runtime.paramsSha256, paramsSha256);
    if (before.selected) {
      assert.equal(after.selected.iamSha256, before.selected.iamSha256, "Selected IAM policy changed.");
      assert.notEqual(after.selected.identity.build, before.selected.identity.build, "Existing Function build did not change.");
      assert.notEqual(after.selected.identity.revision, before.selected.identity.revision, "Existing serving revision did not change.");
      assert.notDeepEqual(after.selected.identity.source, before.selected.identity.source, "Existing uploaded source did not change.");
    }
  }
  return {selectedTarget: INTAKE_PR596_RELEASE.target, retainedFunctions: retained(before).length,
    protectedResourcesUnchanged: true, completed, coverage: "one-selected-function-only"};
}
export function verifyIntakeParams(file, provenance, expectedBinding) {
  return verifyProtectedParams(file, provenance, expectedBinding, INTAKE_PR596_RELEASE);
}
function verifyProtectedParams(file, provenance, expectedBinding, r) {
  assert.equal(provenance.version, 1); assert.equal(provenance.projectId, r.projectId);
  assert.equal(provenance.sourceSha, r.sourceSha); assert.match(provenance.paramsSha256, hashPattern);
  const materializedSha256 = readMaterializedParamsSha256(file, r.projectId);
  const bytes = fs.readFileSync(file);
  const marker = Buffer.from(`CATCH_DEPLOY_CONFIG_SHA256=${JSON.stringify(provenance.paramsSha256)}\n`);
  assert.ok(bytes.length > marker.length && bytes.subarray(-marker.length).equals(marker), "Verified configuration marker missing.");
  const contents = bytes.subarray(0, bytes.length - marker.length);
  assert.ok(!contents.includes(Buffer.from("CATCH_DEPLOY_CONFIG_SHA256=")), "Duplicate configuration marker.");
  assert.equal(bytesDigest(contents), provenance.paramsSha256, "Materialized parameters differ from approved provenance.");
  const result = {materializedSha256, configurationSha256: provenance.paramsSha256};
  if (expectedBinding) assert.deepEqual(result, expectedBinding, "Parameter bytes changed at the mutation boundary.");
  return result;
}
export function completeIntakePr596Release({manifest, packagePlan, before, after, deployment, paramsBinding}) {
  verifyIntakeProvenance(manifest); prepareIntakePr596Release({manifest, packagePlan});
  const r = INTAKE_PR596_RELEASE;
  const result = verifyIntakePreservation(before, after, {completed: true, paramsSha256: paramsBinding.configurationSha256});
  validateFunctionsDeployment(deployment, {manifest, scope: r.scope, baseSha: r.baseSha,
    selectedTargets: [r.target], paramsSha256: paramsBinding.materializedSha256});
  assert.deepEqual(deployment.functions, [after.selected.identity], "Live serving identity differs from bound deployment proof.");
  return {...r, ...result, paramsBinding, deployment, snapshot: after};
}
export async function readIntakeSnapshot(options = {}) {
  return readProtectedSnapshot(options);
}
export async function readCat165Snapshot(options = {}) {
  return readProtectedSnapshot(options, true);
}
async function readProtectedSnapshot({run = spawnSync, request = fetch, listIndexes = gcloudIndexList} = {}, cat165 = false) {
  const project = INTAKE_PR596_RELEASE.projectId;
  const tokenResult = run("gcloud", ["auth", "print-access-token"], {encoding: "utf8", timeout: 30000, maxBuffer: 1024 * 1024});
  assert.ifError(tokenResult.error); assert.equal(tokenResult.status, 0, "Metadata authentication unavailable.");
  const token = String(tokenResult.stdout ?? "").trim(); assert.ok(token && !/[\r\n]/.test(token));
  const get = async (url, init = {}) => {
    const response = await request(url, {...init, headers: {Authorization: `Bearer ${token}`, "Content-Type": "application/json"},
      signal: AbortSignal.timeout(30000)});
    assert.ok(response.ok, `Read-only metadata failed: HTTP ${response.status}.`); return response.json();
  };
  const pages = async (url, field, extra = {}, pageSize = "100") => {
    const rows = [], seen = new Set(); let cursor = "";
    do {
      assert.ok(seen.size < 30 && !seen.has(cursor)); seen.add(cursor);
      const response = await get(`${url}?${new URLSearchParams({...extra, pageSize, ...(cursor ? {pageToken: cursor} : {})})}`);
      assert.deepEqual(response.unreachable ?? [], []); assert.ok(Array.isArray(response[field] ?? []));
      rows.push(...(response[field] ?? [])); cursor = response.nextPageToken ?? ""; assert.equal(typeof cursor, "string");
    } while (cursor);
    return rows.sort((a, b) => String(a.name).localeCompare(String(b.name)));
  };
  // Hash complete metadata in memory; parameter values and tokens never enter receipts or logs.
  const functions = await pages(`https://cloudfunctions.googleapis.com/v2/projects/${project}/locations/-/functions`, "functions");
  assert.ok(functions.length > 0 && new Set(functions.map((fn) => fn.name)).size === functions.length);
  let selected = cat165 ? [] : null, cursor = 0;
  const selectedTargets = cat165 ? CAT165_RELEASE.targets : [INTAKE_PR596_RELEASE.target];
  await Promise.all(Array.from({length: 5}, async () => {
    while (cursor < functions.length) {
      const fn = functions[cursor++];
      assert.match(fn.name, /^projects\/catch-dating-app-64e51\/locations\/[a-z0-9-]+\/functions\/[A-Za-z0-9_-]+$/);
      if (fn.environment === "GEN_2") {
        const service = fn.serviceConfig?.service;
        assert.match(service, /^projects\/catch-dating-app-64e51\/locations\/[a-z0-9-]+\/services\/[a-z0-9-]+$/);
        fn.runService = await get(`https://run.googleapis.com/v2/${service}`);
        fn.iam = await get(`https://run.googleapis.com/v2/${service}:getIamPolicy?options.requestedPolicyVersion=3`);
      } else {
        assert.equal(fn.environment, "GEN_1");
        fn.iam = await get(`https://cloudfunctions.googleapis.com/v1/${fn.name}:getIamPolicy?options.requestedPolicyVersion=3`);
      }
      // Eventarc criteria have no evaluation order; retain every complete filter.
      if (Array.isArray(fn.eventTrigger?.eventFilters)) fn.eventTrigger.eventFilters.sort((a, b) =>
        JSON.stringify(canonical(a)).localeCompare(JSON.stringify(canonical(b))));
      const target = `functions:${fn.name.split("/").at(-1)}`;
      if (selectedTargets.includes(target)) {
        assert.equal(fn.name, `projects/${project}/locations/asia-south1/functions/${target.slice(10)}`);
        const config = fn.serviceConfig;
        const record = {identity: captureFunctionIdentities([fn], INTAKE_PR596_RELEASE.scope, [target])[0],
          runtime: {runtime: fn.buildConfig.runtime, entryPoint: fn.buildConfig.entryPoint,
            serviceAccount: config.serviceAccountEmail, memory: config.availableMemory,
            maxInstances: config.maxInstanceCount, secretBindings: (config.secretEnvironmentVariables ?? []).length + (config.secretVolumes ?? []).length,
            paramsSha256: config.environmentVariables?.CATCH_DEPLOY_CONFIG_SHA256 ?? null},
          iamSha256: digest(fn.iam), publicInvoker: (fn.iam.bindings ?? []).some((binding) =>
            binding.role === "roles/run.invoker" && !binding.condition && binding.members?.includes("allUsers"))};
        if (cat165) {
          // Preserve provider flags, secret versions, routing and resource limits;
          // only the source-bound configuration marker may change.
          const environment = {...config.environmentVariables};
          delete environment.CATCH_DEPLOY_CONFIG_SHA256;
          const stableConfig = {...config, environmentVariables: environment};
          for (const key of ["service", "revision", "uri", "gcfUri"]) delete stableConfig[key];
          record.configurationSha256 = digest({service: stableConfig,
            buildEnvironment: fn.buildConfig.environmentVariables ?? {}, eventTrigger: fn.eventTrigger ?? null});
          assert.equal((config.secretVolumes ?? []).length, 0, "CAT165 cannot change secret volume bindings.");
          record.secretReferences = (config.secretEnvironmentVariables ?? []).map((binding) => {
            const reference = parseSecretReference(`projects/${binding.projectId}/secrets/${binding.secret}/versions/${binding.version}`,
              project, "574779808785");
            assert.ok(reference); assert.equal(binding.key, reference.secret);
            return {key: binding.key, reference: reference.reference};
          }).sort((a, b) => a.key.localeCompare(b.key));
          record.parameterValuesSha256 = digest(materializedNonSecretParams.map((key) => [key, environment[key] ?? null]));
          selected.push(record);
        } else selected = record;
      }
    }
  }));
  const fields = new Map();
  for (const filter of ["indexConfig.usesAncestorConfig:false", "ttlConfig:*"]) {
    for (const field of await pages(`https://firestore.googleapis.com/v1/projects/${project}/databases/(default)/collectionGroups/-/fields`, "fields", {filter}, "0")) {
      assert.equal(typeof field.name, "string");
      if (fields.has(field.name)) assert.deepEqual(field, fields.get(field.name));
      fields.set(field.name, field);
    }
  }
  const liveIndexes = listIndexes({projectId: project}).sort((a, b) => String(a.name).localeCompare(String(b.name)));
  const protectedResources = {
    extensions: digest(await pages(`https://firebaseextensions.googleapis.com/v1beta/projects/${project}/instances`, "instances")),
    indexes: digest(liveIndexes),
    fields: digest([...fields.values()].sort((a, b) => a.name.localeCompare(b.name))),
    rules: digest(await pages(`https://firebaserules.googleapis.com/v1/projects/${project}/releases`, "releases")),
    remoteConfig: digest(await get(`https://firebaseremoteconfig.googleapis.com/v1/projects/${project}/remoteConfig`)),
    projectIam: digest(await get(`https://cloudresourcemanager.googleapis.com/v1/projects/${project}:getIamPolicy`,
      {method: "POST", body: JSON.stringify({options: {requestedPolicyVersion: 3}})})),
  };
  if (cat165) {
    selected.sort((a, b) => a.identity.name.localeCompare(b.identity.name));
    const wanted = indexSignature(CAT165_INDEX, {desired: true});
    const added = liveIndexes.filter((index) => indexSignature(index) === wanted);
    assert.ok(added.length <= 1, "Duplicate CAT165 index.");
    protectedResources.indexes = digest(liveIndexes.filter((index) => indexSignature(index) !== wanted));
    return cat165Snapshot({schema: "catch.cat165-metadata/v2", projectId: project,
      reviewed: captureFunctionIdentities(functions, CAT165_RELEASE.scope, cat165ReviewedTargets()),
      functions: functions.map((fn) => ({name: fn.name, sha256: digest(fn)})), protectedResources, selected,
      index: added[0] ?? null});
  }
  return intakeSnapshot({schema: "catch.intake-pr596-metadata/v1", projectId: project,
    functions: functions.map((fn) => ({name: fn.name, sha256: digest(fn)})), protectedResources, selected});
}
export async function runIntakePr596ReleaseCli(argv, {readSnapshot = readIntakeSnapshot} = {}) {
  const [command, ...rest] = argv, args = salesOptions(rest), r = INTAKE_PR596_RELEASE;
  const commandKeys = {"intake-source": ["current-main", "source-root"], "intake-artifact": ["metadata"],
    "intake-provenance": ["manifest"], "intake-archive": ["archive"],
    "intake-prepare": ["manifest", "package-plan", "output"], "intake-before": ["output"],
    "intake-params": ["params-file", "provenance", "output"],
    "intake-verify-params": ["params-file", "provenance", "binding"],
    "intake-verify-before": ["before"],
    "intake-complete": ["before", "params-file", "params-provenance", "params-binding", "manifest", "package-plan", "deployment", "output"]};
  assert.ok(Object.hasOwn(commandKeys, command)); exactKeys(args, commandKeys[command]);
  if (command === "intake-source") return checkIntakeGitCompatibility(args["current-main"], args["source-root"]);
  if (command === "intake-artifact") return verifyIntakeArtifactMetadata(salesRead(args.metadata));
  if (command === "intake-provenance") {verifyIntakeProvenance(salesRead(args.manifest)); return {provenanceVerified: true};}
  if (command === "intake-archive") {
    assert.equal(bytesDigest(fs.readFileSync(args.archive)), r.artifactSha256); return {archiveVerified: true};
  }
  if (command === "intake-prepare") {
    const manifest = salesRead(args.manifest); verifyIntakeProvenance(manifest);
    salesWrite(args.output, prepareIntakePr596Release({manifest, packagePlan: salesRead(args["package-plan"])}));
    return {selectedTarget: r.target};
  }
  if (command === "intake-params" || command === "intake-verify-params") {
    const binding = verifyIntakeParams(args["params-file"], salesRead(args.provenance),
      command === "intake-verify-params" ? salesRead(args.binding) : undefined);
    if (command === "intake-params") salesWrite(args.output, binding);
    return {paramsBound: true};
  }
  const snapshot = await readSnapshot();
  if (command === "intake-before") {salesWrite(args.output, intakeSnapshot(snapshot)); return {captured: true};}
  const before = salesRead(args.before);
  const result = command === "intake-complete" ? completeIntakePr596Release({before, after: snapshot,
    manifest: salesRead(args.manifest), packagePlan: salesRead(args["package-plan"]), deployment: salesRead(args.deployment),
    paramsBinding: verifyIntakeParams(args["params-file"], salesRead(args["params-provenance"]), salesRead(args["params-binding"]))}) :
    verifyIntakePreservation(before, snapshot);
  if (command === "intake-complete") salesWrite(args.output, result);
  return result;
}

// Reviewed CAT165 projection, not an impact analyzer or full-source baseline.
export const CAT165_RELEASE = Object.freeze({
  sourceSha: "25c8454c9f3a2f35dc3bc4d2f16da6b95b84123a",
  baseSha: "08f2cf44b1a28180dcc6757ac57d0bbceebeb5f2",
  sourceCiRunId: "38778849364", sourceCiRunAttempt: "1", artifactId: 11995458204,
  artifactSha256: "543bf0e766acf2979a9c852daf7009fc8e4ad016f8b0eecab2dada770e484766",
  packageSha256: "e33226c7df14645d174a38cbe794b07468822bc7cabacc3ea7ff86bd3a4023fb",
  provenanceSha256: "42e260ac3103b398c0dfcdfd1859735faac7861a005d2a1214d1f7364cf6a377",
  projectId: "catch-dating-app-64e51", scope: "firebase:prod:catch-dating-app-64e51",
  targetsSha256: "e3504acd685e899c82a55ee0fc3126340c87ffaf31588d411ef6fab0ac7acecb",
  targets: Object.freeze([
    "functions:applyProgramFunctionInvitations",
    "functions:archiveProgram",
    "functions:armOrganizerMoment",
    "functions:claimProgramStaffInvite",
    "functions:createProgramWalkIn",
    "functions:deleteProgramGuestGroup",
    "functions:dispatchProgramTrip",
    "functions:getOrganizerProgram",
    "functions:getProgramArrivalsRoster",
    "functions:getProgramAttendanceReport",
    "functions:getProgramFunctionDoorView",
    "functions:getProgramHotelInbound",
    "functions:getProgramHotelRooms",
    "functions:getProgramStakeholderCounts",
    "functions:getProgramTransportPlan",
    "functions:getProgramWorkAccess",
    "functions:grantProgramStaff",
    "functions:importProgramManifest",
    "functions:importWeddingPhoneContacts",
    "functions:inviteProgramStaff",
    "functions:issueProgramHouseholdRsvpLink",
    "functions:listMyHostAssignments",
    "functions:listOrganizerMoments",
    "functions:listOrganizerPrograms",
    "functions:listProgramGuestGroups",
    "functions:listProgramGuests",
    "functions:listProgramHouseholds",
    "functions:listProgramStaff",
    "functions:listProgramStaffAttention",
    "functions:listProgramTrips",
    "functions:listTransportVendors",
    "functions:manageProgramLodging",
    "functions:markProgramTripArrived",
    "functions:onOrganizerApplicationAutomated",
    "functions:onOrganizerAttendanceAutomated",
    "functions:onOrganizerFormResponseAutomated",
    "functions:organizerMomentSweep",
    "functions:pauseOrganizerMoment",
    "functions:programTravelLegMoments",
    "functions:recordProgramDoorJournal",
    "functions:recordProgramFunctionRsvp",
    "functions:refreshProgramTravelLeg",
    "functions:resumeOrganizerMoment",
    "functions:retryOrganizerAutomations",
    "functions:revokeProgramStaff",
    "functions:revokeProgramStaffInvite",
    "functions:runOrganizerMoment",
    "functions:setProgramTravelReadiness",
    "functions:unarchiveProgram",
    "functions:updateOrganizerProgram",
    "functions:upsertOrganizerMoment",
    "functions:upsertProgramFunction",
    "functions:upsertProgramGuest",
    "functions:upsertProgramGuestGroup",
    "functions:upsertProgramHotel",
    "functions:upsertProgramHousehold",
    "functions:upsertProgramPickupPoint",
    "functions:upsertProgramRoomBlock",
    "functions:upsertProgramStay",
    "functions:upsertProgramTravelLeg",
    "functions:upsertProgramTravelParty",
    "functions:voidProgramTrip"
]),
  deferredTargets: Object.freeze([
    "functions:createOrganizerFormAutomation",
    "functions:createOrganizerProgram",
    "functions:flightAlertWebhook",
    "functions:getProgramHouseholdRsvpView",
    "functions:listOrganizerFormAutomationRuns",
    "functions:onEventAssistanceWhatsappEventCreated",
    "functions:programHouseholdItineraryIcs",
    "functions:refreshProgramFlightStatuses",
    "functions:setOrganizerFormAutomationState",
    "functions:submitProgramHouseholdRsvp",
    "functions:upsertTransportVendor"
]),
});
// Historical evidence, not a fresh observation. See PR617#issuecomment-6203197509.
// Programs build/bucket/object are explicitly observation-only; all fields are pinned.
function freezeCat165Evidence(value) {
  if (value && typeof value === "object") {
    Object.values(value).forEach(freezeCat165Evidence); Object.freeze(value);
  }
  return value;
}
export const CAT165_PREDECESSORS = freezeCat165Evidence({
  "schema": "catch.cat165-reviewed-serving-predecessors-handoff/v1",
  "projectId": "catch-dating-app-64e51",
  "region": "asia-south1",
  "candidateSourceSha": "25c8454c9f3a2f35dc3bc4d2f16da6b95b84123a",
  "selectedTargetsSha256": "e3504acd685e899c82a55ee0fc3126340c87ffaf31588d411ef6fab0ac7acecb",
  "fullEvidenceSha256": "484611bfe433088f9f7cd11528851dd53d15f628b354e62e83f5f4249827c345",
  "metadataObservation": {
    "date": "2026-10-15",
    "sha256": "89eebeb814fa515884c3afb4dc86ff3939d1d5b65e500dd4badfeb7dfcf07ca9",
    "freshness": "Historical reviewed snapshot; compare against fresh metadata before any mutation"
  },
  "cohorts": {
    "baseline647": {
      "sourceSha": "647e39e4476693d6565318cb1d5c5223f3b781f7",
      "receiptSha256": "9f411302df3f0c913157893ec7aba8dbf3a6172926311f085f617f316c8b2875",
      "receiptProvenance": {
        "manifestSha256": "87e65816dc0dce359cad193c1b72355cbc3414b266bd83a778235a5b3468efe1",
        "sourceSha": "647e39e4476693d6565318cb1d5c5223f3b781f7",
        "sourceCiRunId": "37206844099",
        "sourceCiRunAttempt": "1",
        "artifactSha256": "da0a4a1ccdc81727f7fa043b25f7ba8beac20e2f4fb48e435f09704ed9283cd3"
      },
      "receiptFieldCoverage": [
        "revision",
        "build",
        "source.bucket",
        "source.object",
        "source.generation"
      ]
    },
    "programs6f08": {
      "sourceSha": "6f08e7b5606e28a00a715e35c7eb11e438bfdd16",
      "receiptSha256": "7e2c713c18a0cbfa024cb2b0793ceb672c52405bd45410a107cb768da2c69c99",
      "receiptProvenance": {
        "schema": "catch.programs-exact-functions-operator-receipt/v1",
        "result": "six-functions-deployed-and-selected-state-verified",
        "verifiedAt": "2026-10-07T09:59:31.151Z",
        "sourceSha": "6f08e7b5606e28a00a715e35c7eb11e438bfdd16",
        "sourceCiRunId": 37595101537,
        "sourceCiRunAttempt": 2,
        "artifactId": 11472776152,
        "artifactDigest": "sha256:db6423e8c79459bd7b6408c8d9b6421ab4e94cad73011db637ec0aa105aad782",
        "backendArchiveSha256": "18d13bbfe83a3463060eaad0d8a2cf50499ed60d03943e64ca1d749aa53987f8"
      },
      "receiptFieldCoverage": [
        "revision",
        "source.generation"
      ],
      "observationOnlyFields": [
        "build",
        "source.bucket",
        "source.object"
      ]
    },
    "contacts137": {
      "sourceSha": "137d74096c32ec884cfb358ae79b930f303cbb3e",
      "receiptSha256": "db0c4febf7842b4c6b287e0079713d974cf379bcfcec73dec1ceb0c4522f114a",
      "receiptProvenance": {
        "sourceSha": "137d74096c32ec884cfb358ae79b930f303cbb3e",
        "packageArtifactId": 11463329764,
        "packageSha256": "59ac13ab78140132f345c07c4148a887d463e9f4b2a26ae207401ab5c3d00fc3",
        "verifiedAt": "2026-10-07T08:00:12.349Z"
      },
      "receiptFieldCoverage": [
        "revision",
        "build",
        "source.bucket",
        "source.object",
        "source.generation"
      ]
    }
  },
  "counts": {
    "baseline647": {
      "selected": 56,
      "deferred": 10
    },
    "programs6f08": {
      "selected": 5,
      "deferred": 1
    },
    "contacts137": {
      "selected": 1,
      "deferred": 0
    }
  },
  "mustRemainAbsent": [
    "anonymizeDueProgramsSweep"
  ],
  "rows": [
    {"function":"applyProgramFunctionInvitations","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/applyProgramFunctionInvitations","revision":"applyprogramfunctioninvitations-00005-qiz","build":"projects/574779808785/locations/asia-south1/builds/9404ebe8-e5da-4464-b7c6-bb55f6c5924e","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791133787820089","object":"applyProgramFunctionInvitations/function-source.zip"}}},
    {"function":"archiveProgram","disposition":"selected","cohort":"programs6f08","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/archiveProgram","revision":"archiveprogram-00002-noc","build":"projects/574779808785/locations/asia-south1/builds/43b1e888-a192-4401-a749-378aad52f129","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791366814941466","object":"archiveProgram/function-source.zip"}}},
    {"function":"armOrganizerMoment","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/armOrganizerMoment","revision":"armorganizermoment-00005-zex","build":"projects/574779808785/locations/asia-south1/builds/516c85bb-8c37-4b2d-86c5-06ef3a8fd100","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791133917965250","object":"armOrganizerMoment/function-source.zip"}}},
    {"function":"claimProgramStaffInvite","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/claimProgramStaffInvite","revision":"claimprogramstaffinvite-00008-zew","build":"projects/574779808785/locations/asia-south1/builds/6eca2a3a-5421-4ab0-adfb-316257e09a7b","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791134049277256","object":"claimProgramStaffInvite/function-source.zip"}}},
    {"function":"createOrganizerFormAutomation","disposition":"deferred","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/createOrganizerFormAutomation","revision":"createorganizerformautomation-00030-voq","build":"projects/574779808785/locations/asia-south1/builds/b373c185-d036-46a3-87bf-b18ed62370bc","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791134438018955","object":"createOrganizerFormAutomation/function-source.zip"}}},
    {"function":"createOrganizerProgram","disposition":"deferred","cohort":"programs6f08","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/createOrganizerProgram","revision":"createorganizerprogram-00010-buj","build":"projects/574779808785/locations/asia-south1/builds/43b1e888-a192-4401-a749-378aad52f129","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791366739312796","object":"createOrganizerProgram/function-source.zip"}}},
    {"function":"createProgramWalkIn","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/createProgramWalkIn","revision":"createprogramwalkin-00003-den","build":"projects/574779808785/locations/asia-south1/builds/b373c185-d036-46a3-87bf-b18ed62370bc","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791134438750836","object":"createProgramWalkIn/function-source.zip"}}},
    {"function":"deleteProgramGuestGroup","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/deleteProgramGuestGroup","revision":"deleteprogramguestgroup-00003-zay","build":"projects/574779808785/locations/asia-south1/builds/360b61a2-e615-4992-af3a-8bf8ba2a42ad","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791134697879977","object":"deleteProgramGuestGroup/function-source.zip"}}},
    {"function":"dispatchProgramTrip","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/dispatchProgramTrip","revision":"dispatchprogramtrip-00008-vub","build":"projects/574779808785/locations/asia-south1/builds/360b61a2-e615-4992-af3a-8bf8ba2a42ad","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791134697873871","object":"dispatchProgramTrip/function-source.zip"}}},
    {"function":"flightAlertWebhook","disposition":"deferred","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/flightAlertWebhook","revision":"flightalertwebhook-00005-nom","build":"projects/574779808785/locations/asia-south1/builds/871d4f7d-ec18-44ab-8cca-8dab60f6c3c7","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791134830123205","object":"flightAlertWebhook/function-source.zip"}}},
    {"function":"getOrganizerProgram","disposition":"selected","cohort":"programs6f08","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/getOrganizerProgram","revision":"getorganizerprogram-00010-vos","build":"projects/574779808785/locations/asia-south1/builds/43b1e888-a192-4401-a749-378aad52f129","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791366815217655","object":"getOrganizerProgram/function-source.zip"}}},
    {"function":"getProgramArrivalsRoster","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/getProgramArrivalsRoster","revision":"getprogramarrivalsroster-00008-moq","build":"projects/574779808785/locations/asia-south1/builds/f539484d-8a95-44a5-93cc-c148eb880821","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791135737371119","object":"getProgramArrivalsRoster/function-source.zip"}}},
    {"function":"getProgramAttendanceReport","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/getProgramAttendanceReport","revision":"getprogramattendancereport-00001-pib","build":"projects/574779808785/locations/asia-south1/builds/f539484d-8a95-44a5-93cc-c148eb880821","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791135736387331","object":"getProgramAttendanceReport/function-source.zip"}}},
    {"function":"getProgramFunctionDoorView","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/getProgramFunctionDoorView","revision":"getprogramfunctiondoorview-00003-gaj","build":"projects/574779808785/locations/asia-south1/builds/f539484d-8a95-44a5-93cc-c148eb880821","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791135737607595","object":"getProgramFunctionDoorView/function-source.zip"}}},
    {"function":"getProgramHotelInbound","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/getProgramHotelInbound","revision":"getprogramhotelinbound-00008-siz","build":"projects/574779808785/locations/asia-south1/builds/f539484d-8a95-44a5-93cc-c148eb880821","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791135737769505","object":"getProgramHotelInbound/function-source.zip"}}},
    {"function":"getProgramHotelRooms","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/getProgramHotelRooms","revision":"getprogramhotelrooms-00001-qed","build":"projects/574779808785/locations/asia-south1/builds/f539484d-8a95-44a5-93cc-c148eb880821","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791135735205995","object":"getProgramHotelRooms/function-source.zip"}}},
    {"function":"getProgramHouseholdRsvpView","disposition":"deferred","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/getProgramHouseholdRsvpView","revision":"getprogramhouseholdrsvpview-00005-mug","build":"projects/574779808785/locations/asia-south1/builds/c140975e-16d9-4674-ba7e-43812e3c7563","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791135874484525","object":"getProgramHouseholdRsvpView/function-source.zip"}}},
    {"function":"getProgramStakeholderCounts","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/getProgramStakeholderCounts","revision":"getprogramstakeholdercounts-00001-huf","build":"projects/574779808785/locations/asia-south1/builds/c140975e-16d9-4674-ba7e-43812e3c7563","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791135803514076","object":"getProgramStakeholderCounts/function-source.zip"}}},
    {"function":"getProgramTransportPlan","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/getProgramTransportPlan","revision":"getprogramtransportplan-00008-quc","build":"projects/574779808785/locations/asia-south1/builds/c140975e-16d9-4674-ba7e-43812e3c7563","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791135874342932","object":"getProgramTransportPlan/function-source.zip"}}},
    {"function":"getProgramWorkAccess","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/getProgramWorkAccess","revision":"getprogramworkaccess-00008-giy","build":"projects/574779808785/locations/asia-south1/builds/c140975e-16d9-4674-ba7e-43812e3c7563","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791135874702411","object":"getProgramWorkAccess/function-source.zip"}}},
    {"function":"grantProgramStaff","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/grantProgramStaff","revision":"grantprogramstaff-00008-dal","build":"projects/574779808785/locations/asia-south1/builds/cef892a2-8511-47ac-9da3-671d9f5e7722","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791135993928933","object":"grantProgramStaff/function-source.zip"}}},
    {"function":"importProgramManifest","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/importProgramManifest","revision":"importprogrammanifest-00008-ten","build":"projects/574779808785/locations/asia-south1/builds/cef892a2-8511-47ac-9da3-671d9f5e7722","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791135993938991","object":"importProgramManifest/function-source.zip"}}},
    {"function":"importWeddingPhoneContacts","disposition":"selected","cohort":"contacts137","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/importWeddingPhoneContacts","revision":"importweddingphonecontacts-00001-yab","build":"projects/574779808785/locations/asia-south1/builds/156661f9-5318-4c96-8101-922c96e3b877","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791359767765765","object":"importWeddingPhoneContacts/function-source.zip"}}},
    {"function":"inviteProgramStaff","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/inviteProgramStaff","revision":"inviteprogramstaff-00008-mec","build":"projects/574779808785/locations/asia-south1/builds/cef892a2-8511-47ac-9da3-671d9f5e7722","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791135992840038","object":"inviteProgramStaff/function-source.zip"}}},
    {"function":"issueProgramHouseholdRsvpLink","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/issueProgramHouseholdRsvpLink","revision":"issueprogramhouseholdrsvplink-00005-laf","build":"projects/574779808785/locations/asia-south1/builds/cef892a2-8511-47ac-9da3-671d9f5e7722","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791135994410210","object":"issueProgramHouseholdRsvpLink/function-source.zip"}}},
    {"function":"listMyHostAssignments","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/listMyHostAssignments","revision":"listmyhostassignments-00005-gob","build":"projects/574779808785/locations/asia-south1/builds/68b91447-bb0c-4e22-862a-c06faa977d62","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791136254218168","object":"listMyHostAssignments/function-source.zip"}}},
    {"function":"listOrganizerFormAutomationRuns","disposition":"deferred","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/listOrganizerFormAutomationRuns","revision":"listorganizerformautomationruns-00030-biq","build":"projects/574779808785/locations/asia-south1/builds/c1c1a32e-9360-4e37-9ce6-f4f61e18463f","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791136373193813","object":"listOrganizerFormAutomationRuns/function-source.zip"}}},
    {"function":"listOrganizerMoments","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/listOrganizerMoments","revision":"listorganizermoments-00005-qur","build":"projects/574779808785/locations/asia-south1/builds/c1c1a32e-9360-4e37-9ce6-f4f61e18463f","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791136374655033","object":"listOrganizerMoments/function-source.zip"}}},
    {"function":"listOrganizerPrograms","disposition":"selected","cohort":"programs6f08","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/listOrganizerPrograms","revision":"listorganizerprograms-00010-hoj","build":"projects/574779808785/locations/asia-south1/builds/43b1e888-a192-4401-a749-378aad52f129","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791366815004383","object":"listOrganizerPrograms/function-source.zip"}}},
    {"function":"listProgramGuestGroups","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/listProgramGuestGroups","revision":"listprogramguestgroups-00003-hik","build":"projects/574779808785/locations/asia-south1/builds/67b837af-cb33-4bc6-ba6c-735939d34679","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791136501801404","object":"listProgramGuestGroups/function-source.zip"}}},
    {"function":"listProgramGuests","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/listProgramGuests","revision":"listprogramguests-00009-num","build":"projects/574779808785/locations/asia-south1/builds/67b837af-cb33-4bc6-ba6c-735939d34679","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791136501560859","object":"listProgramGuests/function-source.zip"}}},
    {"function":"listProgramHouseholds","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/listProgramHouseholds","revision":"listprogramhouseholds-00009-sup","build":"projects/574779808785/locations/asia-south1/builds/67b837af-cb33-4bc6-ba6c-735939d34679","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791136502949306","object":"listProgramHouseholds/function-source.zip"}}},
    {"function":"listProgramStaff","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/listProgramStaff","revision":"listprogramstaff-00008-kad","build":"projects/574779808785/locations/asia-south1/builds/67b837af-cb33-4bc6-ba6c-735939d34679","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791136502976285","object":"listProgramStaff/function-source.zip"}}},
    {"function":"listProgramStaffAttention","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/listProgramStaffAttention","revision":"listprogramstaffattention-00001-veb","build":"projects/574779808785/locations/asia-south1/builds/5c91f7b9-8d44-4806-80ea-74561d708e41","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791136568434637","object":"listProgramStaffAttention/function-source.zip"}}},
    {"function":"listProgramTrips","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/listProgramTrips","revision":"listprogramtrips-00008-bay","build":"projects/574779808785/locations/asia-south1/builds/5c91f7b9-8d44-4806-80ea-74561d708e41","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791136631137189","object":"listProgramTrips/function-source.zip"}}},
    {"function":"listTransportVendors","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/listTransportVendors","revision":"listtransportvendors-00008-wef","build":"projects/574779808785/locations/asia-south1/builds/5c91f7b9-8d44-4806-80ea-74561d708e41","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791136631353959","object":"listTransportVendors/function-source.zip"}}},
    {"function":"manageProgramLodging","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/manageProgramLodging","revision":"manageprogramlodging-00001-rum","build":"projects/574779808785/locations/asia-south1/builds/d4c1fa53-0d35-4665-81bf-0ac6b3cc90bc","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791136697731288","object":"manageProgramLodging/function-source.zip"}}},
    {"function":"markProgramTripArrived","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/markProgramTripArrived","revision":"markprogramtriparrived-00008-duy","build":"projects/574779808785/locations/asia-south1/builds/d4c1fa53-0d35-4665-81bf-0ac6b3cc90bc","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791136761978875","object":"markProgramTripArrived/function-source.zip"}}},
    {"function":"onEventAssistanceWhatsappEventCreated","disposition":"deferred","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/onEventAssistanceWhatsappEventCreated","revision":"oneventassistancewhatsappeventcreated-00010-cus","build":"projects/574779808785/locations/asia-south1/builds/e12d7a64-3a87-4400-92cd-aa010fe1349f","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791137021504158","object":"onEventAssistanceWhatsappEventCreated/function-source.zip"}}},
    {"function":"onOrganizerApplicationAutomated","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/onOrganizerApplicationAutomated","revision":"onorganizerapplicationautomated-00017-kes","build":"projects/574779808785/locations/asia-south1/builds/fad97569-07d1-4f4f-8fd5-57f08b2ed08d","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791137325552942","object":"onOrganizerApplicationAutomated/function-source.zip"}}},
    {"function":"onOrganizerAttendanceAutomated","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/onOrganizerAttendanceAutomated","revision":"onorganizerattendanceautomated-00017-hac","build":"projects/574779808785/locations/asia-south1/builds/fad97569-07d1-4f4f-8fd5-57f08b2ed08d","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791137327679730","object":"onOrganizerAttendanceAutomated/function-source.zip"}}},
    {"function":"onOrganizerFormResponseAutomated","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/onOrganizerFormResponseAutomated","revision":"onorganizerformresponseautomated-00030-kad","build":"projects/574779808785/locations/asia-south1/builds/fad97569-07d1-4f4f-8fd5-57f08b2ed08d","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791137326812941","object":"onOrganizerFormResponseAutomated/function-source.zip"}}},
    {"function":"organizerMomentSweep","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/organizerMomentSweep","revision":"organizermomentsweep-00006-dav","build":"projects/574779808785/locations/asia-south1/builds/cf59031d-af04-4228-b917-b33ac34aa147","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791137459985770","object":"organizerMomentSweep/function-source.zip"}}},
    {"function":"pauseOrganizerMoment","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/pauseOrganizerMoment","revision":"pauseorganizermoment-00005-cim","build":"projects/574779808785/locations/asia-south1/builds/cf59031d-af04-4228-b917-b33ac34aa147","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791137460352774","object":"pauseOrganizerMoment/function-source.zip"}}},
    {"function":"programHouseholdItineraryIcs","disposition":"deferred","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/programHouseholdItineraryIcs","revision":"programhouseholditineraryics-00005-lum","build":"projects/574779808785/locations/asia-south1/builds/2e5b6319-4912-4418-a67c-24d337bd1c11","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791137730546633","object":"programHouseholdItineraryIcs/function-source.zip"}}},
    {"function":"programTravelLegMoments","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/programTravelLegMoments","revision":"programtravellegmoments-00005-deh","build":"projects/574779808785/locations/asia-south1/builds/2e5b6319-4912-4418-a67c-24d337bd1c11","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791137729513883","object":"programTravelLegMoments/function-source.zip"}}},
    {"function":"recordProgramDoorJournal","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/recordProgramDoorJournal","revision":"recordprogramdoorjournal-00005-xom","build":"projects/574779808785/locations/asia-south1/builds/0128c977-dbc9-4b7d-bc40-8fa9890a0a0b","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791137982580584","object":"recordProgramDoorJournal/function-source.zip"}}},
    {"function":"recordProgramFunctionRsvp","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/recordProgramFunctionRsvp","revision":"recordprogramfunctionrsvp-00005-xas","build":"projects/574779808785/locations/asia-south1/builds/0128c977-dbc9-4b7d-bc40-8fa9890a0a0b","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791137982603172","object":"recordProgramFunctionRsvp/function-source.zip"}}},
    {"function":"refreshProgramFlightStatuses","disposition":"deferred","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/refreshProgramFlightStatuses","revision":"refreshprogramflightstatuses-00008-qup","build":"projects/574779808785/locations/asia-south1/builds/0128c977-dbc9-4b7d-bc40-8fa9890a0a0b","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791137982595750","object":"refreshProgramFlightStatuses/function-source.zip"}}},
    {"function":"refreshProgramTravelLeg","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/refreshProgramTravelLeg","revision":"refreshprogramtravelleg-00008-nij","build":"projects/574779808785/locations/asia-south1/builds/b36e2cd6-f1a1-4d7b-8bc6-552a4574cc9b","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791138124446215","object":"refreshProgramTravelLeg/function-source.zip"}}},
    {"function":"resumeOrganizerMoment","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/resumeOrganizerMoment","revision":"resumeorganizermoment-00005-fid","build":"projects/574779808785/locations/asia-south1/builds/00c3023a-4ae8-4c24-a7c1-ca96811bc329","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791138396840359","object":"resumeOrganizerMoment/function-source.zip"}}},
    {"function":"retryOrganizerAutomations","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/retryOrganizerAutomations","revision":"retryorganizerautomations-00017-zus","build":"projects/574779808785/locations/asia-south1/builds/00c3023a-4ae8-4c24-a7c1-ca96811bc329","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791138397065768","object":"retryOrganizerAutomations/function-source.zip"}}},
    {"function":"revokeProgramStaff","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/revokeProgramStaff","revision":"revokeprogramstaff-00008-yiv","build":"projects/574779808785/locations/asia-south1/builds/00c3023a-4ae8-4c24-a7c1-ca96811bc329","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791138396974106","object":"revokeProgramStaff/function-source.zip"}}},
    {"function":"revokeProgramStaffInvite","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/revokeProgramStaffInvite","revision":"revokeprogramstaffinvite-00008-rov","build":"projects/574779808785/locations/asia-south1/builds/00c3023a-4ae8-4c24-a7c1-ca96811bc329","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791138397100746","object":"revokeProgramStaffInvite/function-source.zip"}}},
    {"function":"runOrganizerMoment","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/runOrganizerMoment","revision":"runorganizermoment-00005-zox","build":"projects/574779808785/locations/asia-south1/builds/ca760e70-5a37-43d2-9b2b-a2db6306cbf2","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791138520916118","object":"runOrganizerMoment/function-source.zip"}}},
    {"function":"setOrganizerFormAutomationState","disposition":"deferred","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/setOrganizerFormAutomationState","revision":"setorganizerformautomationstate-00030-xec","build":"projects/574779808785/locations/asia-south1/builds/7ac580ed-3266-4b58-bc33-1a9be31e9dcf","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791138779400775","object":"setOrganizerFormAutomationState/function-source.zip"}}},
    {"function":"setProgramTravelReadiness","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/setProgramTravelReadiness","revision":"setprogramtravelreadiness-00008-qis","build":"projects/574779808785/locations/asia-south1/builds/7ac580ed-3266-4b58-bc33-1a9be31e9dcf","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791138779013119","object":"setProgramTravelReadiness/function-source.zip"}}},
    {"function":"submitProgramHouseholdRsvp","disposition":"deferred","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/submitProgramHouseholdRsvp","revision":"submitprogramhouseholdrsvp-00005-bef","build":"projects/574779808785/locations/asia-south1/builds/1686a5d2-788c-40e9-8237-fdccb6dcb172","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791139047536505","object":"submitProgramHouseholdRsvp/function-source.zip"}}},
    {"function":"unarchiveProgram","disposition":"selected","cohort":"programs6f08","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/unarchiveProgram","revision":"unarchiveprogram-00002-gup","build":"projects/574779808785/locations/asia-south1/builds/43b1e888-a192-4401-a749-378aad52f129","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791366815446658","object":"unarchiveProgram/function-source.zip"}}},
    {"function":"updateOrganizerProgram","disposition":"selected","cohort":"programs6f08","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/updateOrganizerProgram","revision":"updateorganizerprogram-00010-qun","build":"projects/574779808785/locations/asia-south1/builds/43b1e888-a192-4401-a749-378aad52f129","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791366814781860","object":"updateOrganizerProgram/function-source.zip"}}},
    {"function":"upsertOrganizerMoment","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/upsertOrganizerMoment","revision":"upsertorganizermoment-00005-yin","build":"projects/574779808785/locations/asia-south1/builds/88d860ae-c0d0-4820-9733-f5f038d86ca7","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791139434190511","object":"upsertOrganizerMoment/function-source.zip"}}},
    {"function":"upsertProgramFunction","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/upsertProgramFunction","revision":"upsertprogramfunction-00008-zag","build":"projects/574779808785/locations/asia-south1/builds/88d860ae-c0d0-4820-9733-f5f038d86ca7","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791139432600540","object":"upsertProgramFunction/function-source.zip"}}},
    {"function":"upsertProgramGuest","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/upsertProgramGuest","revision":"upsertprogramguest-00009-sor","build":"projects/574779808785/locations/asia-south1/builds/88d860ae-c0d0-4820-9733-f5f038d86ca7","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791139434164187","object":"upsertProgramGuest/function-source.zip"}}},
    {"function":"upsertProgramGuestGroup","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/upsertProgramGuestGroup","revision":"upsertprogramguestgroup-00003-lay","build":"projects/574779808785/locations/asia-south1/builds/88d860ae-c0d0-4820-9733-f5f038d86ca7","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791139433697784","object":"upsertProgramGuestGroup/function-source.zip"}}},
    {"function":"upsertProgramHotel","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/upsertProgramHotel","revision":"upsertprogramhotel-00008-jol","build":"projects/574779808785/locations/asia-south1/builds/d3f2e4e1-da33-4d65-b824-04093772b355","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791139558994577","object":"upsertProgramHotel/function-source.zip"}}},
    {"function":"upsertProgramHousehold","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/upsertProgramHousehold","revision":"upsertprogramhousehold-00009-daj","build":"projects/574779808785/locations/asia-south1/builds/d3f2e4e1-da33-4d65-b824-04093772b355","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791139560480225","object":"upsertProgramHousehold/function-source.zip"}}},
    {"function":"upsertProgramPickupPoint","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/upsertProgramPickupPoint","revision":"upsertprogrampickuppoint-00008-qis","build":"projects/574779808785/locations/asia-south1/builds/d3f2e4e1-da33-4d65-b824-04093772b355","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791139558978868","object":"upsertProgramPickupPoint/function-source.zip"}}},
    {"function":"upsertProgramRoomBlock","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/upsertProgramRoomBlock","revision":"upsertprogramroomblock-00001-siy","build":"projects/574779808785/locations/asia-south1/builds/d3f2e4e1-da33-4d65-b824-04093772b355","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791139559091652","object":"upsertProgramRoomBlock/function-source.zip"}}},
    {"function":"upsertProgramStay","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/upsertProgramStay","revision":"upsertprogramstay-00001-leg","build":"projects/574779808785/locations/asia-south1/builds/d3f2e4e1-da33-4d65-b824-04093772b355","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791139498203102","object":"upsertProgramStay/function-source.zip"}}},
    {"function":"upsertProgramTravelLeg","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/upsertProgramTravelLeg","revision":"upsertprogramtravelleg-00008-raw","build":"projects/574779808785/locations/asia-south1/builds/d3f2e4e1-da33-4d65-b824-04093772b355","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791139560306379","object":"upsertProgramTravelLeg/function-source.zip"}}},
    {"function":"upsertProgramTravelParty","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/upsertProgramTravelParty","revision":"upsertprogramtravelparty-00008-niw","build":"projects/574779808785/locations/asia-south1/builds/d3f2e4e1-da33-4d65-b824-04093772b355","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791139560120549","object":"upsertProgramTravelParty/function-source.zip"}}},
    {"function":"upsertTransportVendor","disposition":"deferred","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/upsertTransportVendor","revision":"upserttransportvendor-00008-wux","build":"projects/574779808785/locations/asia-south1/builds/d3f2e4e1-da33-4d65-b824-04093772b355","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791139560100412","object":"upsertTransportVendor/function-source.zip"}}},
    {"function":"voidProgramTrip","disposition":"selected","cohort":"baseline647","identity":{"name":"projects/catch-dating-app-64e51/locations/asia-south1/functions/voidProgramTrip","revision":"voidprogramtrip-00008-lay","build":"projects/574779808785/locations/asia-south1/builds/974b8480-03d2-43b9-a306-d72017ef1a47","source":{"bucket":"gcf-v2-sources-574779808785-asia-south1","generation":"1791139694941026","object":"voidProgramTrip/function-source.zip"}}}
  ]
});
function cat165ReviewedTargets() {
  return [...CAT165_RELEASE.targets, ...CAT165_RELEASE.deferredTargets].sort();
}
export function verifyCat165Predecessors(snapshot) {
  cat165Snapshot(snapshot);
  const evidence = CAT165_PREDECESSORS;
  assert.equal(evidence.candidateSourceSha, CAT165_RELEASE.sourceSha);
  assert.equal(evidence.selectedTargetsSha256, CAT165_RELEASE.targetsSha256);
  assert.deepEqual(evidence.rows.map((row) => `functions:${row.function}`).sort(), cat165ReviewedTargets());
  for (const disposition of ["selected", "deferred"]) {
    assert.deepEqual(evidence.rows.filter((row) => row.disposition === disposition).map((row) => `functions:${row.function}`).sort(),
      disposition === "selected" ? CAT165_RELEASE.targets : [...CAT165_RELEASE.deferredTargets].sort());
  }
  for (const row of evidence.rows) {
    const observed = snapshot.reviewed.find((identity) => identity.name === row.identity.name);
    assert.deepEqual({name: observed.name, revision: observed.revision, build: observed.build, source: observed.source},
      row.identity, `CAT165 reviewed predecessor changed: ${row.function}. Investigate before mutation.`);
  }
  for (const name of evidence.mustRemainAbsent) {
    assert.ok(!snapshot.functions.some((fn) => fn.name.split("/").at(-1) === name), "CAT165 dormant Function must remain absent.");
  }
  return {reviewedPredecessors: 73, evidenceSha256: evidence.fullEvidenceSha256};
}
export const CAT165_INDEX = Object.freeze({collectionGroup: "organizerPrograms", queryScope: "COLLECTION",
  fields: Object.freeze([{fieldPath: "organizerId", order: "ASCENDING"},
    {fieldPath: "createdBy", order: "ASCENDING"}, {fieldPath: "startsAt", order: "DESCENDING"}].map(Object.freeze))});
export const CAT165_SOURCE_GUARDED_PATHS = Object.freeze([
  ...INTAKE_SOURCE_GUARDED_PATHS, "operations", "contracts", "tool/ci/package_firebase_delivery.mjs",
  "tool/firebase", "tool/deploy_firebase_targets.sh", "tool/firebase_with_env.sh", "tool/ci/toolchain.env",
  "tool/ci/delivery_core.mjs", "tool/ci/firebase_functions_checkpoint.mjs", "tool/ci/backend_source_review.mjs",
  "package.json", "package-lock.json",
]);
export function checkCat165GitCompatibility(currentSha, cwd = process.cwd()) {
  assert.match(currentSha, shaPattern);
  const git = (args) => {
    const r = spawnSync("git", args, {cwd, encoding: "utf8", timeout: 10000, maxBuffer: 1024 * 1024});
    assert.ifError(r.error); assert.equal(r.status, 0, "CAT165 source compatibility is unproven."); return r.stdout;
  };
  for (const sha of [CAT165_RELEASE.sourceSha, currentSha]) assert.equal(git(["rev-parse", "--verify", `${sha}^{commit}`]).trim(), sha);
  git(["merge-base", "--is-ancestor", CAT165_RELEASE.sourceSha, currentSha]);
  assert.equal(git(["diff", "--name-only", "--no-renames", CAT165_RELEASE.sourceSha, currentSha,
    "--", ...CAT165_SOURCE_GUARDED_PATHS]), "", "CAT165 runtime, asset, lock or protected executor drift.");
  return {sourceSha: CAT165_RELEASE.sourceSha, currentSha};
}
export function verifyCat165ArtifactMetadata(artifact) {
  const r = CAT165_RELEASE;
  assert.equal(artifact.id, r.artifactId); assert.equal(artifact.expired, false);
  assert.equal(artifact.name, `firebase-delivery-${r.sourceSha}-1`);
  assert.equal(artifact.digest, `sha256:${r.artifactSha256}`);
  assert.equal(artifact.workflow_run?.id, Number(r.sourceCiRunId)); assert.equal(artifact.workflow_run?.head_sha, r.sourceSha);
  return {artifactId: r.artifactId, artifactSha256: r.artifactSha256};
}
export function verifyCat165Provenance(raw) {
  assert.equal(provenanceDigest(raw), CAT165_RELEASE.provenanceSha256);
  return validateProvenanceManifest(raw);
}
export function prepareCat165Release({manifest: raw, packagePlan, indexes}) {
  const r = CAT165_RELEASE, manifest = validateProvenanceManifest(raw);
  assert.equal(bytesDigest(Buffer.from(r.targets.join("\n") + "\n")), r.targetsSha256);
  assert.equal(r.targets.length, 62); targetList(r.targets);
  assert.ok(!r.targets.some((t) => r.deferredTargets.includes(t) || t === "functions:anonymizeDueProgramsSweep"));
  for (const value of [manifest, packagePlan]) {
    assert.equal(value.sourceSha, r.sourceSha); assert.equal(value.sourceCiRunId, r.sourceCiRunId);
    assert.equal(value.sourceCiRunAttempt, "1"); assert.deepEqual(value.stages, ["firestore-indexes", "functions"]);
  }
  assert.equal(manifest.artifact.name, "firebase-backend.tar.gz"); assert.equal(manifest.artifact.sha256, r.packageSha256);
  assert.equal(packagePlan.schema, "catch.firebase-delivery-plan/v2"); assert.equal(packagePlan.baseSha, r.baseSha);
  assert.deepEqual(packagePlan.deployGroups, ["firestore-indexes", "functions"]);
  assert.equal(packagePlan.targets.length, 2); assert.equal(packagePlan.targets[0], "firestore:indexes");
  const available = packagePlan.targets[1].split(","); targetList(available);
  assert.ok(r.targets.every((target) => available.includes(target)), "Selected target absent from immutable package authority.");
  assert.ok(Array.isArray(indexes?.indexes));
  assert.equal(indexes.indexes.filter((index) => digest(index) === digest(CAT165_INDEX)).length, 1);
  return {...structuredClone(packagePlan), targets: ["firestore:indexes", r.targets.join(",")],
    selectedIndexes: {indexes: [structuredClone(CAT165_INDEX)], fieldOverrides: []},
    impactedDeferredTargets: [...r.deferredTargets], coverage: "cat165-selected-only", privacyAcceptanceComplete: false};
}
function cat165Names() {
  return CAT165_RELEASE.targets.map((target) => `projects/${CAT165_RELEASE.projectId}/locations/asia-south1/functions/${target.slice(10)}`);
}
function cat165Snapshot(value) {
  exactKeys(value, ["schema", "projectId", "functions", "protectedResources", "selected", "reviewed", "index"]);
  assert.equal(value.schema, "catch.cat165-metadata/v2"); assert.equal(value.projectId, CAT165_RELEASE.projectId);
  assert.ok(Array.isArray(value.functions) && value.functions.length >= 62 && value.functions.length <= 3000);
  const names = value.functions.map((row) => {
    exactKeys(row, ["name", "sha256"]); assert.match(row.sha256, hashPattern);
    assert.match(row.name, /^projects\/catch-dating-app-64e51\/locations\/[a-z0-9-]+\/functions\/[A-Za-z0-9_-]+$/); return row.name;
  });
  assert.equal(new Set(names).size, names.length); assert.deepEqual(names, [...names].sort((a,b) => a.localeCompare(b)));
  exactKeys(value.protectedResources, ["extensions", "indexes", "fields", "rules", "remoteConfig", "projectIam"]);
  for (const hash of Object.values(value.protectedResources)) assert.match(hash, hashPattern);
  assert.ok(Array.isArray(value.reviewed)); assert.equal(value.reviewed.length, 73);
  value.reviewed.forEach((identity, i) => {
    validateFunctionIdentity(identity, {scope: CAT165_RELEASE.scope, target: cat165ReviewedTargets()[i]});
    assert.ok(names.includes(identity.name), "Reviewed Function missing from live inventory.");
  });
  assert.equal(value.selected.length, 62);
  value.selected.forEach((record, i) => {
    exactKeys(record, ["identity", "runtime", "iamSha256", "publicInvoker", "configurationSha256", "parameterValuesSha256", "secretReferences"]);
    validateFunctionIdentity(record.identity, {scope: CAT165_RELEASE.scope, target: CAT165_RELEASE.targets[i]});
    assert.ok(names.includes(record.identity.name)); assert.match(record.iamSha256, hashPattern);
    assert.deepEqual(record.identity, value.reviewed.find((identity) => identity.name === record.identity.name),
      "Selected and reviewed identity projections disagree.");
    assert.ok(Array.isArray(record.secretReferences));
    assert.equal(record.secretReferences.length, record.runtime.secretBindings);
    for (const binding of record.secretReferences) {
      exactKeys(binding, ["key", "reference"]);
      assert.equal(parseSecretReference(binding.reference, CAT165_RELEASE.projectId)?.secret, binding.key);
    }
    assert.equal(new Set(record.secretReferences.map((binding) => binding.key)).size, record.secretReferences.length);
    assert.match(record.configurationSha256, hashPattern); assert.match(record.parameterValuesSha256, hashPattern); assert.equal(typeof record.publicInvoker, "boolean");
    exactKeys(record.runtime, ["runtime", "entryPoint", "serviceAccount", "memory", "maxInstances", "secretBindings", "paramsSha256"]);
    const eventOrSchedule = ["onOrganizerApplicationAutomated", "onOrganizerAttendanceAutomated",
      "onOrganizerFormResponseAutomated", "organizerMomentSweep", "programTravelLegMoments", "retryOrganizerAutomations"];
    if (!eventOrSchedule.includes(CAT165_RELEASE.targets[i].slice(10))) {
      assert.equal(record.publicInvoker, true, "CAT165 callable IAM must already match the source public invoker policy.");
    }
  });
  if (value.index !== null) {
    assert.match(value.index.name ?? "", /^projects\/catch-dating-app-64e51\/databases\/\(default\)\/collectionGroups\/organizerPrograms\/indexes\/[A-Za-z0-9_-]+$/);
    assert.equal(indexSignature(value.index), indexSignature(CAT165_INDEX, {desired: true}));
  }
  return value;
}
export function verifyCat165Preservation(before, after, {phase = "before", paramsSha256} = {}) {
  verifyCat165Predecessors(before); cat165Snapshot(after); assert.ok(["before", "indexed", "completed"].includes(phase));
  assert.equal(before.index, null, "One-time CAT165 profile requires the reviewed index to be absent before invocation.");
  const selected = new Set(cat165Names());
  const retained = (s) => s.functions.filter((f) => !selected.has(f.name));
  assert.deepEqual(retained(after), retained(before), "An unselected Function or Extension changed.");
  assert.deepEqual(after.reviewed.filter((fn) => !selected.has(fn.name)), before.reviewed.filter((fn) => !selected.has(fn.name)),
    "A reviewed deferred serving identity changed.");
  assert.deepEqual(after.protectedResources, before.protectedResources, "A retained index, field, rule, flag or IAM resource changed.");
  if (phase === "before") assert.deepEqual(after, before, "Predeployment metadata drift.");
  else {
    assert.ok(after.index); assert.equal(after.index.state, "READY", "The exact additive index must be READY.");
    if (phase === "indexed") {
      assert.deepEqual(after.functions, before.functions); assert.deepEqual(after.selected, before.selected);
    } else {
      assert.match(paramsSha256, hashPattern);
      after.selected.forEach((record, i) => {
        const prior = before.selected[i];
        assert.equal(record.iamSha256, prior.iamSha256, "Selected IAM policy changed.");
        assert.equal(record.configurationSha256, prior.configurationSha256, "Provider flags, secret versions or selected configuration changed.");
        assert.equal(record.runtime.runtime, "nodejs24"); assert.equal(record.runtime.entryPoint, CAT165_RELEASE.targets[i].slice(10));
        assert.equal(record.runtime.paramsSha256, paramsSha256);
        assert.notEqual(record.identity.build, prior.identity.build, "Selected build did not change.");
        assert.notEqual(record.identity.revision, prior.identity.revision, "Selected serving revision did not change.");
        assert.notDeepEqual(record.identity.source, prior.identity.source, "Selected uploaded source did not change.");
      });
    }
  }
  return {coverage: "cat165-selected-only", selectedTargets: [...CAT165_RELEASE.targets],
    impactedDeferredTargets: [...CAT165_RELEASE.deferredTargets], retainedFunctions: retained(before).length,
    protectedResourcesUnchanged: true, phase, privacyAcceptanceComplete: false,
    legacyHouseholdBearerLimitation: "Previously minted household tokens retain access and consent submission until expiry."};
}
export function verifyCat165Params(file, provenance, expectedBinding) {
  return verifyProtectedParams(file, provenance, expectedBinding, CAT165_RELEASE);
}
export function verifyCat165ParameterPreservation(before, contents) {
  return safe(() => {
    verifyCat165Predecessors(before);
    const values = new Map();
    for (const line of contents.trimEnd().split("\n")) {
      const match = /^([A-Z][A-Z0-9_]*)=(.*)$/.exec(line); assert.ok(match); assert.ok(!values.has(match[1]));
      const value = JSON.parse(match[2]); assert.equal(typeof value, "string"); values.set(match[1], value);
    }
    assert.deepEqual([...values.keys()].sort(), [...materializedNonSecretParams, "CATCH_DEPLOY_CONFIG_SHA256"].sort());
    const expected = digest(materializedNonSecretParams.map((key) => [key, values.get(key)]));
    assert.ok(before.selected.every((record) => record.parameterValuesSha256 === expected));
    return {selectedParametersUnchanged: true};
  });
}
export function verifyCat165BindingPreservation(before, candidate) {
  return safe(() => {
    verifyCat165Predecessors(before);
    validateCandidateBindings(candidate, {environment: "prod", projectId: CAT165_RELEASE.projectId,
      sourceSha: CAT165_RELEASE.sourceSha, manifest: readinessManifest});
    assert.deepEqual(candidate.functions.map((fn) => `functions:${fn.consumer}`).sort(), CAT165_RELEASE.targets);
    const requirements = selectReadinessRequirements({manifest: readinessManifest, environment: "prod", targets: CAT165_RELEASE.targets});
    const expected = requirements.filter((requirement) => ["secret-version", "secret-reference"].includes(requirement.kind))
      .flatMap((requirement) => requirement.requiredWhen.anyDeployTarget.filter((target) => CAT165_RELEASE.targets.includes(target))
        .map((target) => `${requirement.id}:${target.slice(10)}`)).sort();
    assert.deepEqual(candidate.bindings.map((binding) => `${binding.requirementId}:${binding.consumer}`).sort(), expected);
    before.selected.forEach((record, i) => {
      const consumer = CAT165_RELEASE.targets[i].slice(10);
      assert.equal(candidate.functions.find((fn) => fn.consumer === consumer).serviceAccount, record.runtime.serviceAccount);
      const proposed = candidate.bindings.filter((binding) => binding.consumer === consumer &&
        requirements.some((requirement) => requirement.id === binding.requirementId && requirement.kind === "secret-version"))
        .map((binding) => ({key: parseSecretReference(binding.reference, CAT165_RELEASE.projectId).secret, reference: binding.reference}))
        .sort((a, b) => a.key.localeCompare(b.key));
      assert.deepEqual(proposed, record.secretReferences, "CAT165 must not rebind any SecretParam version.");
    });
    return {selectedSecretVersionsUnchanged: true};
  });
}
export function prepareCat165Deployment({manifest, snapshot, paramsBinding}) {
  cat165Snapshot(snapshot);
  const r = CAT165_RELEASE;
  const deployment = {schema: FUNCTIONS_DEPLOYMENT_SCHEMA, scope: r.scope,
    provenance: createCheckpointState(manifest, r.scope).provenance, baseSha: r.baseSha,
    targets: [...r.targets], paramsSha256: paramsBinding.materializedSha256,
    functions: snapshot.selected.map((record) => record.identity)};
  return validateFunctionsDeployment(deployment, {manifest, scope: r.scope, baseSha: r.baseSha,
    selectedTargets: r.targets, paramsSha256: paramsBinding.materializedSha256});
}
export function completeCat165Release({manifest, packagePlan, indexes, before, after, deployment, paramsBinding}) {
  verifyCat165Provenance(manifest); prepareCat165Release({manifest, packagePlan, indexes});
  const r = CAT165_RELEASE;
  const result = verifyCat165Preservation(before, after, {phase: "completed", paramsSha256: paramsBinding.configurationSha256});
  validateFunctionsDeployment(deployment, {manifest, scope: r.scope, baseSha: r.baseSha,
    selectedTargets: r.targets, paramsSha256: paramsBinding.materializedSha256});
  assert.deepEqual(deployment.functions, after.selected.map((record) => record.identity));
  return {...r, ...result, paramsBinding, deployment, snapshot: after};
}
export async function runCat165ReleaseCli(argv, {readSnapshot = readCat165Snapshot} = {}) {
  const [command, ...rest] = argv, args = salesOptions(rest), r = CAT165_RELEASE;
  const commandKeys = {"cat165-source": ["current-main", "source-root"], "cat165-artifact": ["metadata"],
    "cat165-provenance": ["manifest"], "cat165-archive": ["archive"],
    "cat165-prepare": ["manifest", "package-plan", "indexes", "output", "selected-indexes"],
    "cat165-before": ["output"], "cat165-verify-before": ["before"], "cat165-verify-indexed": ["before"],
    "cat165-params": ["params-file", "provenance", "output"], "cat165-verify-params": ["params-file", "provenance", "binding"],
    "cat165-targets": [], "cat165-verify-config": ["before", "params-file", "provenance", "binding", "candidate"],
    "cat165-complete": ["before", "params-file", "params-provenance", "params-binding", "manifest", "package-plan", "indexes", "deployment-output", "output"]};
  assert.ok(Object.hasOwn(commandKeys, command)); exactKeys(args, commandKeys[command]);
  if (command === "cat165-targets") return {targets: r.targets, targetsSha256: r.targetsSha256};
  if (command === "cat165-source") return checkCat165GitCompatibility(args["current-main"], args["source-root"]);
  if (command === "cat165-artifact") return verifyCat165ArtifactMetadata(salesRead(args.metadata));
  if (command === "cat165-provenance") {verifyCat165Provenance(salesRead(args.manifest)); return {provenanceVerified: true};}
  if (command === "cat165-archive") {assert.equal(bytesDigest(fs.readFileSync(args.archive)), r.artifactSha256); return {archiveVerified: true};}
  if (command === "cat165-prepare") {
    const manifest = salesRead(args.manifest); verifyCat165Provenance(manifest);
    const plan = prepareCat165Release({manifest, packagePlan: salesRead(args["package-plan"]), indexes: salesRead(args.indexes)});
    salesWrite(args.output, plan); salesWrite(args["selected-indexes"], plan.selectedIndexes); return {targets: r.targets};
  }
  if (["cat165-params", "cat165-verify-params"].includes(command)) {
    const binding = verifyCat165Params(args["params-file"], salesRead(args.provenance),
      command === "cat165-verify-params" ? salesRead(args.binding) : undefined);
    if (command === "cat165-params") salesWrite(args.output, binding); return {paramsBound: true};
  }
  if (command === "cat165-verify-config") {
    const binding = verifyCat165Params(args["params-file"], salesRead(args.provenance), salesRead(args.binding));
    const before = salesRead(args.before), candidate = salesRead(args.candidate);
    assert.equal(candidate.paramsSha256, binding.configurationSha256);
    verifyCat165BindingPreservation(before, candidate);
    return verifyCat165ParameterPreservation(before, fs.readFileSync(args["params-file"], "utf8"));
  }
  const snapshot = await readSnapshot();
  if (command === "cat165-before") {
    const predecessors = verifyCat165Predecessors(snapshot);
    assert.equal(snapshot.index, null); salesWrite(args.output, snapshot); return {captured: true, ...predecessors};
  }
  const before = salesRead(args.before);
  if (command !== "cat165-complete") return verifyCat165Preservation(before, snapshot,
    {phase: command === "cat165-verify-indexed" ? "indexed" : "before"});
  const manifest = salesRead(args.manifest);
  const paramsBinding = verifyCat165Params(args["params-file"], salesRead(args["params-provenance"]), salesRead(args["params-binding"]));
  const deployment = prepareCat165Deployment({manifest, snapshot, paramsBinding});
  const result = completeCat165Release({before, after: snapshot, manifest,
    packagePlan: salesRead(args["package-plan"]), indexes: salesRead(args.indexes), deployment, paramsBinding});
  salesWrite(args["deployment-output"], deployment); salesWrite(args.output, result); return result;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  (process.argv[2]?.startsWith("cat165-") ? runCat165ReleaseCli : process.argv[2]?.startsWith("intake-") ? runIntakePr596ReleaseCli : runSalesPr543ReleaseCli)(process.argv.slice(2)).then((result) => console.log(JSON.stringify(result))).catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  });
}
