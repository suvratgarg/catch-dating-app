/**
 * Text moderation: banned-word filter for user-generated content.
 *
 * This module provides a lightweight, zero-dependency content filter that
 * checks text against a configurable list of banned terms. It is designed to
 * run inside Cloud Functions triggers (Firestore onCreate, onUpdate) and
 * callable handlers without calling an external API.
 *
 * ## Architecture
 *
 * The word list is split into two tiers:
 *
 *   **BLOCK** — Terms that trigger immediate rejection (hate speech, slurs,
 *   sexually explicit content, credible threats). Content containing these
 *   terms is either deleted or replaced with a placeholder.
 *
 *   **FLAG** — Terms that are suspicious but could be false positives
 *   (mild profanity, drug references, suggestive language). Content
 *   containing only these terms is written to the moderation queue for
 *   human review but not deleted.
 *
 * ## Usage
 *
 * ```ts
 * import {moderateText} from "../moderation/textFilter";
 *
 * const result = moderateText("some text to check");
 * // => { action: "block" | "flag" | "allow", matches: string[] }
 * ```
 *
 * The word lists are hardcoded here so they can be updated via deployment.
 * For runtime configurability without a deploy, add a Firestore document
 * at `config/moderation` that this module reads on cold start.
 */

// ── Block-list terms (immediate rejection) ────────────────────────────────

const BLOCK_TERMS: ReadonlySet<string> = new Set([
  // Hate speech — racial / ethnic slurs
  "nigger", "nigga", "kike", "chink", "paki", "gook", "wetback",
  "sandnigger", "raghead",

  // Hate speech — homophobic / transphobic slurs
  "faggot", "fag", "tranny", "shemale",

  // Hate speech — casteist slurs (India-relevant)
  "chamar", "bhangi", "chura",

  // Hate speech — religious slurs (India-relevant)
  "mulla", "kafir",

  // Sexually explicit content
  "incest", "pedo", "pedophile", "bestiality", "zoophile",

  // Credible threats / violence
  "i will kill you", "i will find you and kill",
  "i know where you live and",

  // Self-harm encouragement
  "kill yourself", "kys", "go kill yourself",
]);

// ── Flag-list terms (human review) ────────────────────────────────────────

const FLAG_TERMS: ReadonlySet<string> = new Set([
  // Mild profanity — flag, don't block
  "fuck", "shit", "bitch", "bastard", "asshole", "dick",
  "bhenchod", "madarchod", "behenchod", "chutiya", "harami",

  // Drug references
  "cocaine", "heroin", "meth", "lsd", "ecstasy", "weed", "marijuana",
  "ganja", "charas",

  // Sexual solicitation / commercial
  "escort", "prostitute", "hooker", "call girl",

  // Suspicious off-platform solicitation
  "whatsapp me", "add me on snap", "instagram dm",
  "telegram me", "dm me on insta",

  // Gambling / scams
  "casino", "betting", "lottery", "lucky draw", "send me money",
  "earn money fast", "work from home earn",

  // Personal info sharing (PII attempt)
  "my aadhaar", "my pan card", "my passport number",
]);

// ── Public API ────────────────────────────────────────────────────────────

/** Result of text moderation. */
export interface ModerationResult {
  /** What action to take. */
  action: "block" | "flag" | "allow";
  /** List of matching terms (lowercased). */
  matches: string[];
}

/**
 * Checks text against block and flag lists.
 *
 * Matching is case-insensitive and detects substrings. A single block-list
 * match causes `action: "block"`. Flag-list matches only cause `action:
 * "flag"` when no block-list term matched.
 *
 * @param text — Input text. Empty / whitespace-only strings return `allow`.
 * @return ModerationResult with the recommended action and matched terms.
 */
export function moderateText(text: string | undefined | null): ModerationResult {
  if (!text || text.trim().length === 0) {
    return {action: "allow", matches: []};
  }

  const lower = text.toLowerCase();
  const matches: string[] = [];

  // Check block terms first — these are always a block action.
  for (const term of BLOCK_TERMS) {
    if (lower.includes(term)) {
      matches.push(term);
    }
  }

  if (matches.length > 0) {
    return {action: "block", matches};
  }

  // Check flag terms — these trigger human review.
  for (const term of FLAG_TERMS) {
    if (lower.includes(term)) {
      matches.push(term);
    }
  }

  if (matches.length > 0) {
    return {action: "flag", matches};
  }

  return {action: "allow", matches: []};
}

/**
 * Returns true when text should be blocked (contains a block-list term).
 * Convenience wrapper around {@link moderateText}.
 */
export function isBlocked(text: string | undefined | null): boolean {
  return moderateText(text).action === "block";
}
