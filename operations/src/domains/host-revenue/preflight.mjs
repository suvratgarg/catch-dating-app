import {createHash} from "node:crypto";
import {isDeepStrictEqual} from "node:util";
import Ajv from "ajv";

export const MAX_INPUT_BYTES = 1_048_576;
export const MAX_ROWS = 500;
const MAX_HISTORICAL_NODES = 2_000;
const ID = {type: "string", minLength: 1, maxLength: 96, pattern: "^[A-Za-z0-9][A-Za-z0-9._:-]*$"};
const LABEL = {type: "string", minLength: 1, maxLength: 160};
const REF = {type: "string", minLength: 1, maxLength: 96, pattern: ID.pattern};
const SOURCE_REF = {
  type: "object", additionalProperties: false,
  required: ["sourceId", "documentId", "location"],
  properties: {sourceId: ID, documentId: LABEL, location: LABEL},
};

export function createRevenuePreflight(configuration) {
  const policy = structuredClone(configuration);
  assertPolicy(policy);
  deepFreeze(policy);
const factorSchema = {
  oneOf: [
    {type: "object", additionalProperties: false, required: ["state", "value", "evidenceRefs"],
      properties: {state: {const: "known"}, value: {type: "integer", minimum: 0, maximum: 5},
        evidenceRefs: {type: "array", minItems: 1, maxItems: 8, uniqueItems: true, items: REF}}},
    {type: "object", additionalProperties: false, required: ["state", "reason"],
      properties: {state: {const: "unknown"}, reason: LABEL}},
  ],
};
const ROW_SCHEMA = {
  type: "object", additionalProperties: false,
  required: ["sourceRowId", "sourceRef", "cohortIds", "marketId", "workflowIds", "eventTypeIds",
    "identityKeys", "evidenceRefs", "qualification", "factors", "historicalScores"],
  oneOf: [
    {required: ["organizerId"], not: {required: ["candidateId"]}},
    {required: ["candidateId"], not: {required: ["organizerId"]}},
  ],
  properties: {
    sourceRowId: ID,
    sourceRef: SOURCE_REF,
    organizerId: ID,
    candidateId: ID,
    cohortIds: {type: "array", minItems: 1, maxItems: 12, uniqueItems: true, items: ID},
    marketId: ID,
    workflowIds: {type: "array", maxItems: 20, uniqueItems: true, items: ID},
    eventTypeIds: {type: "array", maxItems: 20, uniqueItems: true, items: ID},
    identityKeys: {type: "array", maxItems: 12, items: {
      type: "object", additionalProperties: false, required: ["kind", "value"],
      properties: {kind: {enum: ["platformId", "domain", "socialHandle"]}, value: LABEL},
    }},
    evidenceRefs: {type: "array", maxItems: 50, items: {
      type: "object", additionalProperties: false,
      required: ["evidenceId", "sourceRef", "sourceRootId", "kind"],
      properties: {evidenceId: ID, sourceRef: SOURCE_REF, sourceRootId: ID,
        kind: {enum: ["identity", "recurrence", "operating", "other"]}},
    }},
    qualification: {type: "object", additionalProperties: false,
      required: ["firstPartyIdentityEvidenceRef", "recurrenceEvidenceRef", "operatingSignals"],
      properties: {
        firstPartyIdentityEvidenceRef: {anyOf: [REF, {type: "null"}]},
        recurrenceEvidenceRef: {anyOf: [REF, {type: "null"}]},
        operatingSignals: {type: "array", maxItems: 12, items: {
          type: "object", additionalProperties: false, required: ["signalId", "evidenceRef"],
          properties: {signalId: ID, evidenceRef: REF},
        }},
      }},
    factors: {type: "object", additionalProperties: false,
      required: policy.factors.map((factor) => factor.id),
      properties: Object.fromEntries(policy.factors.map((factor) => [factor.id, factorSchema]))},
    historicalScores: {type: "array", maxItems: 10, items: {
      type: "object", additionalProperties: false, required: ["modelId", "modelVersion", "original"],
      properties: {modelId: ID, modelVersion: ID, original: {type: "object"}},
    }},
  },
};
const INPUT_SCHEMA = {type: "object", additionalProperties: false,
  required: ["schemaVersion", "rows"],
  properties: {schemaVersion: {const: 1}, rows: {type: "array", maxItems: MAX_ROWS}},
};
const ajv = new Ajv({allErrors: true, strict: true, strictRequired: false});
const validateInput = ajv.compile(INPUT_SCHEMA);
const validateRow = ajv.compile(ROW_SCHEMA);
const validateFactors = ajv.compile(ROW_SCHEMA.properties.factors);
const validateIdentityKey = ajv.compile(ROW_SCHEMA.properties.identityKeys.items);
const validateEvidenceRef = ajv.compile(ROW_SCHEMA.properties.evidenceRefs.items);

function evaluateFit(factors) {
  if (!validateFactors(factors)) throw new Error(`Invalid factors: ${issues(validateFactors.errors).join("; ")}`);
  const missingFactors = policy.factors.filter(({id}) => factors[id].state === "unknown")
    .map(({id}) => id);
  const complete = missingFactors.length === 0;
  const score = complete ? policy.factors.reduce((sum, {id, weight}) =>
    sum + weight * factors[id].value / policy.ratingMaximum, 0) : null;
  return {
    modelId: policy.modelId,
    modelVersion: policy.modelVersion,
    policyStatus: policy.status,
    status: complete ? "complete" : "needsResearch",
    score: score === null ? null : Math.round(score * 100) / 100,
    coverage: {knownFactors: policy.factors.length - missingFactors.length,
      totalFactors: policy.factors.length},
    missingFactors,
  };
}

function preflightJson(bytes) {
  if (!Buffer.isBuffer(bytes)) throw new TypeError("Input must be file bytes.");
  if (bytes.length > MAX_INPUT_BYTES) throw new Error(`Input exceeds ${MAX_INPUT_BYTES} bytes.`);
  const inputHash = createHash("sha256").update(bytes).digest("hex");
  let input;
  try { input = JSON.parse(new TextDecoder("utf-8", {fatal: true}).decode(bytes)); } catch {
    throw new Error("Input must be valid UTF-8 JSON.");
  }
  if (!validateInput(input)) throw new Error(`Invalid input envelope: ${issues(validateInput.errors).join("; ")}`);
  const rows = input.rows.map((row, index) => reviewRow(row, index));
  detectCrossRowConflicts(rows);
  for (const row of rows) finalizeDisposition(row);
  return {
    schemaVersion: 1,
    inputHash,
    policy: {modelId: policy.modelId, modelVersion: policy.modelVersion,
      status: policy.status, hash: createHash("sha256").update(JSON.stringify(policy)).digest("hex")},
    effectsApplied: false,
    runtimeAuthority: "read_only",
    totals: {rows: rows.length,
      dispositions: rows.reduce((counts, row) => {
        counts[row.disposition] = (counts[row.disposition] ?? 0) + 1;
        return counts;
      }, {evaluated: 0, needs_research: 0, review_required: 0, invalid_input: 0})},
    rows: rows.map(({raw: _raw, ...row}) => row),
  };
}

function reviewRow(raw, index) {
  const sourcePointer = validSourcePointer(raw?.sourceRef) ?
    {sourceId: raw.sourceRef.sourceId, documentId: raw.sourceRef.documentId,
      location: raw.sourceRef.location} : `/rows/${index}`;
  const row = {index, sourcePointer,
    sourceRowId: validId(raw?.sourceRowId) ? raw.sourceRowId : null,
    organizerId: validId(raw?.organizerId) ? raw.organizerId : null,
    candidateId: validId(raw?.candidateId) ? raw.candidateId : null,
    cohortIds: Array.isArray(raw?.cohortIds) ? raw.cohortIds.filter(validId).slice(0, 12) : [],
    disposition: "invalid_input", fit: null, evidence: null,
    outreachEligibility: {status: "blocked", reasons: ["invalid_input"]},
    historicalScores: [], reviewReasons: [], raw};
  const errors = [];
  if (!validateRow(raw)) errors.push(...issues(validateRow.errors));
  if (errors.length === 0) {
    try { assertHistoricalBounds(raw.historicalScores); } catch (error) { errors.push(error.message); }
  }
  if (errors.length) {
    row.reviewReasons.push(...errors.map((detail) => ({code: "invalid_input", detail})));
    return row;
  }
  row.historicalScores = raw.historicalScores.map((score) => ({
    ...score,
    comparableToCurrent: false,
    support: supportedHistory(score) ? "documented_historical" : "unsupported_model_version",
  }));
  if (row.historicalScores.some((score) => score.support === "unsupported_model_version")) {
    row.reviewReasons.push({code: "unsupported_historical_model", detail: "Original score retained without comparison."});
  }
  const evidenceById = new Map();
  for (const ref of raw.evidenceRefs) {
    const existing = evidenceById.get(ref.evidenceId);
    if (existing && !isDeepStrictEqual(existing, ref)) {
      row.reviewReasons.push({code: "conflicting_evidence", detail: ref.evidenceId});
    }
    evidenceById.set(ref.evidenceId, ref);
  }
  const cited = [
    ...policy.factors.flatMap(({id}) => raw.factors[id].state === "known" ? raw.factors[id].evidenceRefs : []),
    raw.qualification.firstPartyIdentityEvidenceRef,
    raw.qualification.recurrenceEvidenceRef,
    ...raw.qualification.operatingSignals.map((signal) => signal.evidenceRef),
  ].filter(Boolean);
  for (const ref of new Set(cited)) {
    if (!evidenceById.has(ref)) row.reviewReasons.push({code: "missing_evidence_ref", detail: ref});
  }
  const identity = evidenceById.get(raw.qualification.firstPartyIdentityEvidenceRef)?.kind === "identity";
  const recurrence = evidenceById.get(raw.qualification.recurrenceEvidenceRef)?.kind === "recurrence";
  const operatingSignals = raw.qualification.operatingSignals
    .map(({signalId, evidenceRef}) => ({signalId, ref: evidenceById.get(evidenceRef)}))
    .filter(({ref}) => ref?.kind === "operating");
  const signalIds = new Set(operatingSignals.map(({signalId}) => signalId));
  const operatingRoots = new Set(operatingSignals.map(({ref}) => ref.sourceRootId));
  const missing = [];
  if (!identity) missing.push("first_party_identity");
  if (!recurrence) missing.push("recurrence");
  if (signalIds.size < 2 || operatingRoots.size < 2) missing.push("two_distinct_operating_signals");
  row.evidence = {identity, recurrence, distinctOperatingSignals: signalIds.size,
    distinctOperatingSources: operatingRoots.size,
    sufficient: missing.length === 0, missing};
  row.fit = evaluateFit(raw.factors);
  return row;
}

function detectCrossRowConflicts(rows) {
  const bySource = new Map();
  const byOrganizer = new Map();
  const byIdentity = new Map();
  const evidence = new Map();
  for (const row of rows) {
    if (row.sourceRowId) addGroup(bySource, row.sourceRowId, row);
    if (row.organizerId) addGroup(byOrganizer, row.organizerId, row);
    const raw = row.raw;
    if (row.organizerId || row.candidateId) {
      for (const key of Array.isArray(raw?.identityKeys) ? raw.identityKeys : []) {
        if (validateIdentityKey(key)) {
          addGroup(byIdentity, `${key.kind}\u0000${key.value.toLowerCase()}`, row);
        }
      }
    }
    for (const ref of Array.isArray(raw?.evidenceRefs) ? raw.evidenceRefs : []) {
      if (validateEvidenceRef(ref)) {
        if (!evidence.has(ref.evidenceId)) evidence.set(ref.evidenceId, []);
        evidence.get(ref.evidenceId).push({row, ref});
      }
    }
  }
  for (const group of bySource.values()) if (group.length > 1) {
    for (const row of group) row.reviewReasons.push({code: "duplicate_source_row_id", detail: row.sourceRowId});
  }
  for (const group of byOrganizer.values()) if (group.length > 1) {
    for (const row of group) row.reviewReasons.push({code: "repeated_organizer_id", detail: row.organizerId});
  }
  for (const group of byIdentity.values()) {
    if (new Set(group.map((row) => row.organizerId ?
      `organizer:${row.organizerId}` : `candidate:${row.candidateId}`)).size > 1) {
      for (const row of group) row.reviewReasons.push({code: "conflicting_identity_key", detail: "Explicit identity key maps to different records."});
    }
  }
  for (const [id, entries] of evidence) {
    if (entries.some(({ref}) => !isDeepStrictEqual(ref, entries[0].ref))) {
      for (const {row} of entries) {
        if (!row.reviewReasons.some((reason) => reason.code === "conflicting_evidence" && reason.detail === id)) {
          row.reviewReasons.push({code: "conflicting_evidence", detail: id});
        }
      }
    }
  }
}

function finalizeDisposition(row) {
  const reasons = new Set(row.reviewReasons.map(({code}) => code));
  if (reasons.has("invalid_input") || reasons.has("missing_evidence_ref") ||
      reasons.has("duplicate_source_row_id") || reasons.has("conflicting_evidence")) {
    row.disposition = "invalid_input";
    row.fit = null;
    row.evidence = null;
    row.outreachEligibility = {status: "blocked", reasons: [...reasons]};
  } else if (reasons.size || !row.evidence.sufficient) {
    row.disposition = "review_required";
    row.outreachEligibility = {status: "blocked", reasons: [...reasons, ...row.evidence.missing]};
  } else if (row.fit.status === "needsResearch") {
    row.disposition = "needs_research";
    row.outreachEligibility = {status: "not_assessed", reasons: ["offline_contact_policy_not_assessed"]};
  } else {
    row.disposition = "evaluated";
    row.outreachEligibility = {status: "not_assessed", reasons: ["offline_contact_policy_not_assessed"]};
  }
}

function supportedHistory(score) {
  return policy.historicalModels[score.modelId]?.documentedVersion === score.modelVersion;
}

function addGroup(map, key, row) {
  if (!map.has(key)) map.set(key, []);
  if (!map.get(key).includes(row)) map.get(key).push(row);
}

function validSourcePointer(value) {
  return !!value && typeof value === "object" &&
    validId(value.sourceId) && ["documentId", "location"].every((key) =>
      typeof value[key] === "string" && value[key].length > 0 && value[key].length <= 160);
}

function validId(value) {
  return typeof value === "string" && value.length <= 96 &&
    /^[A-Za-z0-9][A-Za-z0-9._:-]*$/.test(value);
}

function issues(errors) {
  return errors.map((error) => `${error.instancePath || "/"} ${error.message}${
    error.params.additionalProperty ? `: ${error.params.additionalProperty}` : ""}`);
}

function assertHistoricalBounds(scores) {
  let nodes = 0;
  function visit(value, depth) {
    if (++nodes > MAX_HISTORICAL_NODES || depth > 8) throw new Error("Historical score object exceeds structural bounds.");
    if (typeof value === "string" && value.length > 512) throw new Error("Historical score string exceeds 512 characters.");
    if (Array.isArray(value)) {
      if (value.length > 50) throw new Error("Historical score array exceeds 50 entries.");
      for (const item of value) visit(item, depth + 1);
    } else if (value && typeof value === "object") {
      if (Object.keys(value).length > 50) throw new Error("Historical score object exceeds 50 fields.");
      for (const [key, item] of Object.entries(value)) {
        const normalized = key.toLowerCase().replaceAll(/[^a-z0-9]/g, "");
        if (key.length > 96 || FORBIDDEN_HISTORICAL_FIELDS.has(normalized) ||
          /^(?:owner|ownership|claim|publish|publication|payment|charge|billing|send|dispatch|permission|credential|secret|token|apikey|providerpayload|rawpayload)/.test(normalized) ||
          /^(?:accessgrant|contactendpoint|contactemail|contactphone|firebaseuid|userid|auth)/.test(normalized)) {
          throw new Error(`Forbidden historical score field: ${key}`);
        }
        visit(item, depth + 1);
      }
    } else if (typeof value === "number" && !Number.isFinite(value)) {
      throw new Error("Historical score number is not finite.");
    }
  }
  for (const score of scores) visit(score.original, 0);
}

const FORBIDDEN_HISTORICAL_FIELDS = new Set([
  "proto", "constructor", "prototype", "owner", "ownership", "claim", "claimstatus",
  "publish", "publication", "publicationstatus", "payment", "paymentstatus", "charge",
  "billing", "send", "sendmessage", "dispatch", "contactendpoint", "accessgrant",
  "permission", "credential", "secret", "token", "apikey", "providerpayload", "rawpayload",
]);

return Object.freeze({policy, evaluateFit, preflightJson});
}

const POLICY_FACTOR = {type: "object", additionalProperties: false,
  required: ["id", "weight"], properties: {
    id: ID, weight: {type: "integer", minimum: 1, maximum: 100},
  }};
const POLICY_SCHEMA = {
  type: "object", additionalProperties: false,
  required: ["schemaVersion", "modelId", "modelVersion", "status", "ratingMinimum",
    "ratingMaximum", "factors", "historicalModels", "crosswalk"],
  properties: {
    schemaVersion: {const: 1}, modelId: ID, modelVersion: ID, status: {const: "shadow"},
    ratingMinimum: {const: 0}, ratingMaximum: {const: 5},
    factors: {type: "array", minItems: 7, maxItems: 7, items: POLICY_FACTOR},
    historicalModels: {type: "object", maxProperties: 20, propertyNames: ID,
      additionalProperties: {type: "object", additionalProperties: false,
        required: ["documentedVersion"], properties: {
          documentedVersion: {anyOf: [ID, {type: "null"}]}, sourceName: LABEL,
          formulaStatus: LABEL,
          factors: {type: "array", minItems: 1, maxItems: 20, items: POLICY_FACTOR},
        }}},
    crosswalk: {type: "array", maxItems: 40, items: {
      type: "object", additionalProperties: false,
      required: ["currentFactor", "historicalModel", "historicalFactor", "relationship", "conversion"],
      properties: {currentFactor: ID, historicalModel: ID, historicalFactor: ID,
        relationship: LABEL, conversion: {type: "null"}},
    }},
  },
};
const validatePolicy = new Ajv({strict: true}).compile(POLICY_SCHEMA);
function assertPolicy(value) {
  if (!validatePolicy(value) ||
    new Set(value.factors.map(({id}) => id)).size !== 7 ||
    value.factors.some(({id}) => ["__proto__", "constructor", "prototype"].includes(id)) ||
    value.factors.reduce((sum, {weight}) => sum + weight, 0) !== 100) {
    throw new Error("Invalid bounded seven-factor shadow policy.");
  }
}

function deepFreeze(value) {
  if (value && typeof value === "object") {
    for (const nested of Object.values(value)) deepFreeze(nested);
    Object.freeze(value);
  }
  return value;
}
