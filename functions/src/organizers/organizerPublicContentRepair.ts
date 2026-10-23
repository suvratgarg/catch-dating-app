import crypto from "node:crypto";
import {
  isAuthorityFactLabel,
  isPublicSourceLink,
  organizerPublicContentIssues,
  sourceLinkKey,
  type OrganizerPublicContent,
  type OrganizerPublicContentIssue,
} from "./organizerPublicContent";
import {validateOrganizerDocument} from
  "../shared/generated/validators/organizerDocument";
import {schemaErrorMessages} from
  "../shared/generated/schemaValidationRuntime";

/** Fields a reviewed replacement may set during a public-content repair. */
export const organizerPublicContentReplacementFields = [
  "description",
  "publicPage.seoTitle",
  "publicPage.seoDescription",
  "publicProfile.headline",
  "publicProfile.summary",
  "publicProfile.sourceSummary",
  "publicProfile.facts",
  "publicProfile.eventEvidence",
  "publicSources",
] as const;

/**
 * Operator-only lists that left the organizer contract. Stored documents keep
 * them until this repair deletes them; readers that validate the contract
 * (the website projection, Event Success stores) reject documents that still
 * carry them.
 */
export const retiredOrganizerPublicFields = [
  "publicProfile.fitNotes",
  "publicProfile.missingEvidence",
] as const;

export interface OrganizerPublicContentRepairPlan {
  path: string;
  /** Firestore dot-path values to set; empty when nothing changes. */
  patch: Record<string, unknown>;
  /** Firestore dot paths to delete. */
  deletes: string[];
  /** Current stored value of every patched or deleted field. */
  before: Record<string, unknown>;
  /** Wording issues left after the patch; a reviewed replacement fixes them. */
  remainingIssues: OrganizerPublicContentIssue[];
  /** Contract errors the patched document still has. */
  schemaErrors: string[];
  /** Contract errors the patch would introduce; apply refuses these. */
  schemaRegressions: string[];
  /** Binds an apply to the reviewed `before` state, patch and deletes. */
  hash: string;
}

type DocumentData = Record<string, unknown>;

/**
 * Plans the cleanup of one organizer's public fields. Retired operator lists
 * are deleted and authority facts plus sources without a distinct public link
 * are removed mechanically; wording issues need a reviewed replacement value.
 * @param {string} path Organizer document path.
 * @param {DocumentData} organizer Stored organizer document.
 * @param {DocumentData} replacements Reviewed dot-path replacement values.
 * @return {OrganizerPublicContentRepairPlan} Deterministic repair plan.
 */
export function planOrganizerPublicContentRepair(
  path: string,
  organizer: DocumentData,
  replacements: DocumentData = {}
): OrganizerPublicContentRepairPlan {
  const allowed = new Set<string>(organizerPublicContentReplacementFields);
  for (const field of Object.keys(replacements)) {
    if (!allowed.has(field)) {
      throw new Error(`${path}: ${field} is not a replaceable public field.`);
    }
  }
  const candidate: DocumentData = {...replacements};
  const read = (field: string) =>
    field in candidate ? candidate[field] : valueAt(organizer, field);

  const facts = read("publicProfile.facts");
  if (Array.isArray(facts)) {
    candidate["publicProfile.facts"] = facts.filter((fact) =>
      !isAuthorityFactLabel(String((fact as DocumentData)?.label ?? "")));
  }
  const sources = read("publicSources");
  if (Array.isArray(sources)) {
    const seen = new Set<string>();
    candidate.publicSources = sources.filter((source) => {
      const href = (source as DocumentData)?.href;
      if (!isPublicSourceLink(href as string | null)) return false;
      const key = sourceLinkKey(href as string);
      if (seen.has(key)) return false;
      seen.add(key);
      return true;
    });
  }

  const patch: DocumentData = {};
  const before: DocumentData = {};
  for (const [field, value] of Object.entries(candidate)) {
    const current = valueAt(organizer, field);
    if (stableJson(current) === stableJson(value)) continue;
    patch[field] = value;
    before[field] = current ?? null;
  }
  const deletes = retiredOrganizerPublicFields.filter((field) =>
    valueAt(organizer, field) !== undefined);
  for (const field of deletes) before[field] = valueAt(organizer, field);

  const next = withDotPatch(organizer, patch, deletes);
  const schemaErrors = contractErrors(next);
  const existing = new Set(contractErrors(organizer));
  return {
    path,
    patch,
    deletes,
    before,
    remainingIssues: organizerPublicContentIssues(
      next as OrganizerPublicContent
    ),
    schemaErrors,
    schemaRegressions: schemaErrors.filter((error) => !existing.has(error)),
    hash: crypto.createHash("sha256")
      .update(stableJson({path, before, patch, deletes}))
      .digest("hex"),
  };
}

/**
 * Hashes a set of document plans so an apply can name what was reviewed.
 * @param {OrganizerPublicContentRepairPlan[]} plans Document plans.
 * @return {string} Order-independent plan-set hash.
 */
export function organizerPublicContentPlanSetHash(
  plans: OrganizerPublicContentRepairPlan[]
): string {
  return crypto.createHash("sha256")
    .update(plans.map((plan) => plan.hash).sort().join("\n"))
    .digest("hex");
}

/**
 * Lists organizer contract errors for a document.
 * @param {DocumentData} value Organizer document.
 * @return {string[]} Schema error messages.
 */
function contractErrors(value: DocumentData): string[] {
  return validateOrganizerDocument(value) ?
    [] :
    schemaErrorMessages(validateOrganizerDocument);
}

/**
 * Reads a dot path from a document.
 * @param {DocumentData} value Document.
 * @param {string} field Dot path.
 * @return {unknown} Stored value or undefined.
 */
function valueAt(value: DocumentData, field: string): unknown {
  let cursor: unknown = value;
  for (const segment of field.split(".")) {
    if (!cursor || typeof cursor !== "object") return undefined;
    cursor = (cursor as DocumentData)[segment];
  }
  return cursor;
}

/**
 * Applies a Firestore dot-path update and deletes to a copy of a document.
 * @param {DocumentData} value Document.
 * @param {DocumentData} patch Dot-path values to set.
 * @param {readonly string[]} deletes Dot paths to delete.
 * @return {DocumentData} Patched copy.
 */
function withDotPatch(
  value: DocumentData,
  patch: DocumentData,
  deletes: readonly string[]
): DocumentData {
  const next: DocumentData = {...value};
  const parentOf = (field: string) => {
    const segments = field.split(".");
    let cursor = next;
    for (const segment of segments.slice(0, -1)) {
      const child = cursor[segment];
      cursor[segment] = child && typeof child === "object" ?
        {...(child as DocumentData)} :
        {};
      cursor = cursor[segment] as DocumentData;
    }
    return {parent: cursor, key: segments[segments.length - 1]};
  };
  for (const [field, fieldValue] of Object.entries(patch)) {
    const {parent, key} = parentOf(field);
    parent[key] = fieldValue;
  }
  for (const field of deletes) {
    const {parent, key} = parentOf(field);
    delete parent[key];
  }
  return next;
}

/**
 * Serializes a value with sorted object keys.
 * @param {unknown} value Any JSON-like value, including Firestore timestamps.
 * @return {string} Stable JSON.
 */
function stableJson(value: unknown): string {
  if (value === undefined) return "null";
  if (Array.isArray(value)) return `[${value.map(stableJson).join(",")}]`;
  if (value && typeof value === "object") {
    const record = value as DocumentData;
    return `{${Object.keys(record).sort().map((key) =>
      `${JSON.stringify(key)}:${stableJson(record[key])}`).join(",")}}`;
  }
  return JSON.stringify(value);
}
