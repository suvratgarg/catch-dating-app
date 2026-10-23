import {HttpsError} from "firebase-functions/v2/https";

/**
 * Visitor-facing content policy for organizer public fields.
 *
 * The public organizer page renders `description`, the SEO fields,
 * `publicProfile` and `publicSources`. Operator-authored writes (intake
 * drafts, admin edits, publication and data repairs) check this policy
 * before saving. Fit rationale, evidence checklists, raw intake requests and
 * claim/index workflow state belong in the private intake records, the
 * structured `claim`/`ownership`/`publicPage` authority and the audited
 * review note, never in copy a visitor reads.
 */
export interface OrganizerPublicContent {
  description?: string | null;
  publicPage?: {
    seoTitle?: string | null;
    seoDescription?: string | null;
  } | null;
  publicProfile?: {
    headline?: string | null;
    summary?: string | null;
    sourceSummary?: string | null;
    formats?: string[];
    facts?: Array<{label: string; value: string}>;
    eventEvidence?: Array<{
      title: string;
      summary: string;
      facts: string[];
      sourceLabel: string;
    }>;
  } | null;
  publicSources?: Array<{
    label: string;
    detail: string;
    href: string | null;
  }> | null;
}

export type OrganizerPublicContentRule =
  | "operator_wording"
  | "authority_fact"
  | "source_without_public_link"
  | "duplicate_source_link";

export interface OrganizerPublicContentIssue {
  field: string;
  rule: OrganizerPublicContentRule;
  match?: string;
}

// Phrases that describe Catch's own intake, claim and indexing pipeline.
// Kept narrow so organizer-written copy ("calorie intake") still passes.
const operatorWording: readonly RegExp[] = [
  /\bunclaimed (?:profile|listing|page|organi[sz]er|seed|entry)\b/iu,
  /\bseed (?:listing|input|profile|club|entry|data)\b/iu,
  /\b(?:owner|admin|editorial|manual|operator) review(?:s|ed|er|ing)?\b/iu,
  /\bowner[- ]safe\b/iu,
  /\bno-?index(?:ed)?\b/iu,
  /\bout of search\b/iu,
  /\b(?:claim|index(?:ing)?|verification|publication) (?:state|status)\b/iu,
  /\bverified public facts\b/iu,
  /\b(?:organi[sz]er|supply|reviewed) intake\b/iu,
  /\bintake (?:evidence|review|batch|candidate|request)\b/iu,
  /\bsource[- ]backed\b/iu,
  /\b(?:missing|publication) evidence\b/iu,
  /\bdiscovered (?:through|via|from|on) (?:a |an |the )?public\b/iu,
  /\b(?:embedded|structured) (?:event |page )?data\b/iu,
  /\bfit notes?\b/iu,
];

// Claim, index, ownership, verification and publication state render from
// the structured authority; a free-text fact restating it goes stale.
const authorityFactLabel = new RegExp(
  "^(?:claim(?: state| status)?|index(?:ing| status)?" +
    "|ownership(?: state)?|verification(?: status)?" +
    "|publi(?:sh|cation)(?: state| status)?)$",
  "iu"
);

/**
 * Returns the operator phrase a public text uses, if any.
 * @param {string | null | undefined} text Candidate public text.
 * @return {string | null} The matched phrase.
 */
export function operatorWordingIn(
  text: string | null | undefined
): string | null {
  if (typeof text !== "string" || text.length === 0) return null;
  for (const pattern of operatorWording) {
    const match = pattern.exec(text);
    if (match) return match[0];
  }
  return null;
}

/**
 * Returns whether a public fact label restates workflow authority.
 * @param {string} label Fact label.
 * @return {boolean} True for claim/index/ownership/publication labels.
 */
export function isAuthorityFactLabel(label: string): boolean {
  return authorityFactLabel.test(label.trim());
}

/**
 * Returns whether a public source carries a link a visitor can open.
 * @param {string | null | undefined} href Source link.
 * @return {boolean} True for an absolute http(s) URL.
 */
export function isPublicSourceLink(href: string | null | undefined): boolean {
  if (typeof href !== "string" || href.trim().length === 0) return false;
  try {
    const url = new URL(href);
    return url.protocol === "https:" || url.protocol === "http:";
  } catch {
    return false;
  }
}

/**
 * Normalizes a public source link for duplicate detection.
 * @param {string} href Public source link.
 * @return {string} Comparable link.
 */
export function sourceLinkKey(href: string): string {
  const url = new URL(href);
  url.hash = "";
  return url.toString().replace(/\/$/u, "").toLowerCase();
}

/**
 * Lists every place the given organizer content breaks the public policy.
 * Absent fields are skipped, so callers can check a partial patch.
 * @param {OrganizerPublicContent} content Organizer document or patch.
 * @return {OrganizerPublicContentIssue[]} Policy issues in field order.
 */
export function organizerPublicContentIssues(
  content: OrganizerPublicContent
): OrganizerPublicContentIssue[] {
  const issues: OrganizerPublicContentIssue[] = [];
  const checkText = (field: string, text: string | null | undefined) => {
    const match = operatorWordingIn(text);
    if (match) issues.push({field, rule: "operator_wording", match});
  };

  checkText("description", content.description);
  checkText("publicPage.seoTitle", content.publicPage?.seoTitle);
  checkText("publicPage.seoDescription", content.publicPage?.seoDescription);

  const profile = content.publicProfile ?? {};
  checkText("publicProfile.headline", profile.headline);
  checkText("publicProfile.summary", profile.summary);
  checkText("publicProfile.sourceSummary", profile.sourceSummary);
  (profile.formats ?? []).forEach((format, index) =>
    checkText(`publicProfile.formats[${index}]`, format));
  (profile.facts ?? []).forEach((fact, index) => {
    if (isAuthorityFactLabel(fact.label)) {
      issues.push({
        field: `publicProfile.facts[${index}]`,
        rule: "authority_fact",
        match: fact.label,
      });
      return;
    }
    checkText(`publicProfile.facts[${index}].label`, fact.label);
    checkText(`publicProfile.facts[${index}].value`, fact.value);
  });
  (profile.eventEvidence ?? []).forEach((event, index) => {
    const prefix = `publicProfile.eventEvidence[${index}]`;
    checkText(`${prefix}.title`, event.title);
    checkText(`${prefix}.summary`, event.summary);
    checkText(`${prefix}.sourceLabel`, event.sourceLabel);
    event.facts.forEach((fact, factIndex) =>
      checkText(`${prefix}.facts[${factIndex}]`, fact));
  });

  const seenLinks = new Set<string>();
  (content.publicSources ?? []).forEach((source, index) => {
    const prefix = `publicSources[${index}]`;
    const field = `${prefix}.href`;
    if (!isPublicSourceLink(source.href)) {
      issues.push({field, rule: "source_without_public_link"});
    } else {
      const key = sourceLinkKey(source.href as string);
      if (seenLinks.has(key)) {
        issues.push({field, rule: "duplicate_source_link"});
      }
      seenLinks.add(key);
    }
    checkText(`${prefix}.label`, source.label);
    checkText(`${prefix}.detail`, source.detail);
  });
  return issues;
}

/**
 * Throws when operator content would reach organizer public fields.
 * @param {OrganizerPublicContent} content Organizer document or patch.
 * @param {string} action Write being attempted, for the error message.
 */
export function assertOrganizerPublicContent(
  content: OrganizerPublicContent,
  action: string
): void {
  const issues = organizerPublicContentIssues(content);
  if (issues.length === 0) return;
  throw new HttpsError(
    "failed-precondition",
    `${action} would put operator content in organizer public fields: ` +
      `${describeOrganizerPublicContentIssues(issues)}. Keep intake ` +
      "evidence and review context in the intake record or the review note.",
    {issues}
  );
}

/**
 * Formats issues for an operator-facing message.
 * @param {OrganizerPublicContentIssue[]} issues Policy issues.
 * @return {string} Compact issue list.
 */
export function describeOrganizerPublicContentIssues(
  issues: OrganizerPublicContentIssue[]
): string {
  return issues.map((issue) => {
    const reason = issueReasons[issue.rule];
    return issue.match ?
      `${issue.field} (${reason}: "${issue.match}")` :
      `${issue.field} (${reason})`;
  }).join(", ");
}

const issueReasons: Record<OrganizerPublicContentRule, string> = {
  operator_wording: "intake wording",
  authority_fact: "restates claim/index state",
  source_without_public_link: "no public link",
  duplicate_source_link: "repeats another source link",
};
