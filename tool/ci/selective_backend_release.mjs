import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import {compareFunctionFingerprints, FUNCTION_FINGERPRINT_SCHEMA} from "../firebase/function_release_fingerprints.mjs";
import {validateProvenanceManifest} from "./delivery_core.mjs";
import {validateFunctionsDeployment, validateFunctionIdentity} from "./firebase_functions_checkpoint.mjs";

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
    assert.equal(additive(baselineIndexes, operatorIndexes).length,
      initialization.receipt.addedIndexCount);
    assert.deepEqual(indexInventory(operatorIndexes), indexInventory(candidateIndexes));
    assert.match(candidateBaseSha ?? "", shaPattern);
    assert.match(candidateParamsSha256 ?? "", hashPattern);
    assert.ok(impact.selectedTargets.length > 0);
    return {schema: "catch.selective-impact-plan/v1", scope: ledger.scope,
      baselineCommonSourceSha: ledger.coverageSourceSha, candidate: binding(impact.candidate),
      candidateBaseSha, candidateParamsSha256, ledgerSha256: digest(ledger), impactSha256: digest(impact),
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
  });
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
