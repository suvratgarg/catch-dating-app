import {createHash} from "node:crypto";
import {stableStringify} from "../../platform/canonical-json.mjs";
import {invariant} from "../../platform/errors.mjs";

const id = /^[A-Za-z0-9][A-Za-z0-9._:-]{0,95}$/u;
const hash = /^[a-f0-9]{64}$/u;
const digest = value => createHash("sha256").update(stableStringify(value)).digest("hex");

export function identityDecisionTemplate(source) {
  invariant(id.test(source?.sourceId) && hash.test(source?.contentHash) &&
    Array.isArray(source?.rows), "INVALID_IDENTITY_REVIEW", "A private source is required.");
  return {schemaVersion: 1, sourceId: source.sourceId,
    contentHash: source.contentHash, sourceHash: digest(source),
    reviewVersion: "review-v1", decisions: []};
}

/** Offline join of explicit human identity decisions to immutable source rows. */
export function prepareIdentityReview(source, decisions) {
  invariant(id.test(source?.sourceId) && hash.test(source?.contentHash) &&
    id.test(source?.mappingVersion) && Array.isArray(source?.rows),
  "INVALID_IDENTITY_REVIEW", "A versioned private source is required.");
  invariant(decisions?.schemaVersion === 1 &&
    decisions.sourceId === source.sourceId &&
    decisions.contentHash === source.contentHash &&
    decisions.sourceHash === digest(source) &&
    id.test(decisions.reviewVersion) && Array.isArray(decisions.decisions),
  "INVALID_IDENTITY_REVIEW", "Decisions must bind the exact private source.");
  const sourceRows = new Set();
  for (const row of source.rows) {
    invariant(id.test(row.sourceRowId) && !sourceRows.has(row.sourceRowId),
      "INVALID_IDENTITY_REVIEW", "Source row IDs must be unique.");
    sourceRows.add(row.sourceRowId);
  }
  const byRow = new Map();
  for (const decision of decisions.decisions) {
    invariant(sourceRows.has(decision.sourceRowId) && !byRow.has(decision.sourceRowId),
      "INVALID_IDENTITY_REVIEW", "Each decision must name one known source row.");
    invariant(["matched", "unresolved", "ambiguous"].includes(decision.status),
      "INVALID_IDENTITY_REVIEW", "Unknown identity decision.");
    invariant(Array.isArray(decision.cohortIds) && decision.cohortIds.length > 0 &&
      decision.cohortIds.length <= 30 &&
      decision.cohortIds.every(value => id.test(value)) &&
      new Set(decision.cohortIds).size === decision.cohortIds.length,
    "INVALID_IDENTITY_REVIEW", "Review each row's cohort memberships explicitly.");
    if (decision.status === "matched") {
      invariant(id.test(decision.organizerId) &&
        Array.isArray(decision.evidenceRefs) && decision.evidenceRefs.length > 0 &&
        decision.evidenceRefs.length <= 12 &&
        decision.evidenceRefs.every(value => id.test(value)) &&
        new Set(decision.evidenceRefs).size === decision.evidenceRefs.length,
      "INVALID_IDENTITY_REVIEW", "A canonical match needs an ID and evidence references.");
    } else {
      invariant(decision.organizerId === null || decision.organizerId === undefined,
        "INVALID_IDENTITY_REVIEW", "Unresolved identities cannot name a canonical organizer.");
    }
    invariant(decision.candidateOrganizerIds === undefined ||
      (Array.isArray(decision.candidateOrganizerIds) &&
        decision.candidateOrganizerIds.length <= 12 &&
        decision.candidateOrganizerIds.every(value => id.test(value)) &&
        new Set(decision.candidateOrganizerIds).size === decision.candidateOrganizerIds.length),
    "INVALID_IDENTITY_REVIEW", "Candidate IDs must be distinct review references.");
    byRow.set(decision.sourceRowId, structuredClone(decision));
  }
  const rows = source.rows.map(row => {
    const decision = byRow.get(row.sourceRowId);
    return {sourceRowId: row.sourceRowId, status: decision?.status ?? "unreviewed",
      organizerId: decision?.status === "matched" ? decision.organizerId : null,
      cohortIds: decision?.cohortIds ?? [],
      evidenceRefs: decision?.evidenceRefs ?? [],
      candidateOrganizerIds: decision?.candidateOrganizerIds ?? []};
  });
  const counts = Object.fromEntries(["matched", "unresolved", "ambiguous", "unreviewed"]
    .map(status => [status, rows.filter(row => row.status === status).length]));
  const material = {schemaVersion: 1, sourceId: source.sourceId,
    contentHash: source.contentHash, reviewVersion: decisions.reviewVersion,
    sourceHash: digest(source), decisionHash: digest(decisions), counts, rows,
    mappedSource: {...structuredClone(source),
      mappingVersion: decisions.reviewVersion,
      rows: source.rows.map(row => ({...structuredClone(row),
        cohortIds: byRow.get(row.sourceRowId)?.cohortIds ?? [],
        organizerId: byRow.get(row.sourceRowId)?.status === "matched" ?
          byRow.get(row.sourceRowId).organizerId : null}))}};
  return {...material, reviewHash: digest(material)};
}
