import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {compareFunctionFingerprints, FUNCTION_FINGERPRINT_SCHEMA} from "../firebase/function_release_fingerprints.mjs";
import {validateProvenanceManifest, provenanceDigest, validateCheckpointState, resolveFirstIncompleteStage} from "./delivery_core.mjs";
import {validateFunctionsDeployment, validateFunctionIdentity, readSuccessfulBaselineArchive,
  readMaterializedParamsSha256, liveFunctions, captureFunctionIdentities,
  FUNCTIONS_DEPLOYMENT_FILE} from "./firebase_functions_checkpoint.mjs";
import {gcloudIndexList, inspectIndexReadiness} from "../firebase/wait_firestore_indexes_ready.mjs";
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
  const r = INTAKE_PR596_RELEASE;
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
export async function readIntakeSnapshot({run = spawnSync, request = fetch, listIndexes = gcloudIndexList} = {}) {
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
  let selected = null, cursor = 0;
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
      if (fn.name === intakeSelectedName) {
        const config = fn.serviceConfig;
        selected = {identity: captureFunctionIdentities([fn], INTAKE_PR596_RELEASE.scope, [INTAKE_PR596_RELEASE.target])[0],
          runtime: {runtime: fn.buildConfig.runtime, entryPoint: fn.buildConfig.entryPoint,
            serviceAccount: config.serviceAccountEmail, memory: config.availableMemory,
            maxInstances: config.maxInstanceCount, secretBindings: (config.secretEnvironmentVariables ?? []).length + (config.secretVolumes ?? []).length,
            paramsSha256: config.environmentVariables?.CATCH_DEPLOY_CONFIG_SHA256 ?? null},
          iamSha256: digest(fn.iam), publicInvoker: (fn.iam.bindings ?? []).some((binding) =>
            binding.role === "roles/run.invoker" && !binding.condition && binding.members?.includes("allUsers"))};
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
  const protectedResources = {
    extensions: digest(await pages(`https://firebaseextensions.googleapis.com/v1beta/projects/${project}/instances`, "instances")),
    indexes: digest(listIndexes({projectId: project}).sort((a, b) => String(a.name).localeCompare(String(b.name)))),
    fields: digest([...fields.values()].sort((a, b) => a.name.localeCompare(b.name))),
    rules: digest(await pages(`https://firebaserules.googleapis.com/v1/projects/${project}/releases`, "releases")),
    remoteConfig: digest(await get(`https://firebaseremoteconfig.googleapis.com/v1/projects/${project}/remoteConfig`)),
    projectIam: digest(await get(`https://cloudresourcemanager.googleapis.com/v1/projects/${project}:getIamPolicy`,
      {method: "POST", body: JSON.stringify({options: {requestedPolicyVersion: 3}})})),
  };
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

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  (process.argv[2]?.startsWith("intake-") ? runIntakePr596ReleaseCli : runSalesPr543ReleaseCli)(process.argv.slice(2)).then((result) => console.log(JSON.stringify(result))).catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  });
}
