/**
 * Per-user rate limiting for callable Cloud Functions.
 *
 * Uses Firestore transactions to atomically read-and-increment a counter
 * for each (uid, action, timeWindow) tuple. If the counter exceeds the
 * configured limit for that action, the request is rejected with a
 * `resource-exhausted` HttpsError.
 *
 * ## Usage
 *
 * ```ts
 * import {checkRateLimit} from "../shared/rateLimit";
 *
 * // Inside a callable handler:
 * await checkRateLimit(
 *   admin.firestore(),
 *   request.auth!.uid,
 *   "createClub",
 *   {maxRequests: 5, windowMs: 60 * 60 * 1000}  // 5 per hour
 * );
 * ```
 *
 * ## Data model
 *
 * Rate-limit counters are stored in `rateLimits/{key}` where `key` is
 * `${uid}_${action}_${windowKey}`. Documents auto-expire via TTL
 * (`expiresAt` field) so they don't accumulate. You must create a
 * Firestore TTL policy on the `expiresAt` field in the `rateLimits`
 * collection (Firebase Console → Firestore → TTL Policies).
 *
 * ## Trade-offs
 *
 * - **Transaction-based:** Each rate-limited request incurs one Firestore
 *   transaction read + write (~10-20ms). This is fast enough for callable
 *   functions but adds latency proportional to Firestore load.
 * - **Window alignment:** The `windowKey` is `Math.floor(now / windowMs)`,
 *   so a 1-minute window starts at wall-clock minute boundaries (e.g.,
 *   12:34:00–12:34:59). This is simpler than a sliding window and avoids
 *   the need for per-second precision.
 * - **Not a hard guarantee:** Firestore transactions can retry under
 *   contention. At extremely high throughput (>200 req/s for a single
 *   user), counters may slightly exceed limits. For a dating app, this is
 *   acceptable — the goal is abuse prevention, not billing precision.
 */

import {HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

// ── Types ──────────────────────────────────────────────────────────────────

export interface RateLimitConfig {
  /** Maximum allowed requests in the window. */
  maxRequests: number;
  /** Window duration in milliseconds. */
  windowMs: number;
}

// ── Pre-defined limits ─────────────────────────────────────────────────────

/** Limits for each callable/HTTP endpoint keyed by action name. */
export const RATE_LIMITS: Record<string, RateLimitConfig> = {
  // 10/min
  createRazorpayOrder: {maxRequests: 10, windowMs: 60 * 1000},
  verifyRazorpayPayment: {maxRequests: 10, windowMs: 60 * 1000},
  createStripeCheckoutSession: {maxRequests: 10, windowMs: 60 * 1000},
  createStripeHostOnboardingLink: {maxRequests: 5, windowMs: 60 * 1000},
  refreshStripeHostPaymentAccount: {maxRequests: 20, windowMs: 60 * 1000},
  createEvent: {maxRequests: 10, windowMs: 60 * 1000},
  updateEvent: {maxRequests: 30, windowMs: 60 * 1000},
  cancelEvent: {maxRequests: 10, windowMs: 60 * 1000},
  deleteEvent: {maxRequests: 10, windowMs: 60 * 1000},
  signUpForFreeEvent: {maxRequests: 10, windowMs: 60 * 1000},
  cancelEventSignUp: {maxRequests: 10, windowMs: 60 * 1000},
  joinEventWaitlist: {maxRequests: 10, windowMs: 60 * 1000},
  leaveEventWaitlist: {maxRequests: 10, windowMs: 60 * 1000},
  createEventWaitlistOffers: {maxRequests: 30, windowMs: 60 * 1000},
  acceptEventWaitlistOffer: {maxRequests: 10, windowMs: 60 * 1000},
  declineEventWaitlistOffer: {maxRequests: 10, windowMs: 60 * 1000},
  decideEventJoinRequest: {maxRequests: 30, windowMs: 60 * 1000},
  joinClub: {maxRequests: 30, windowMs: 60 * 1000},
  leaveClub: {maxRequests: 30, windowMs: 60 * 1000},
  addClubHost: {maxRequests: 20, windowMs: 60 * 1000},
  removeClubHost: {maxRequests: 20, windowMs: 60 * 1000},
  archiveClub: {maxRequests: 10, windowMs: 60 * 1000},
  deleteClub: {maxRequests: 10, windowMs: 60 * 1000},
  // 30/min (host toggling attendance for a group)
  markEventAttendance: {maxRequests: 30, windowMs: 60 * 1000},
  // 5/min
  selfCheckInAttendance: {maxRequests: 5, windowMs: 60 * 1000},
  fetchEventSuccessWingmanCandidates: {maxRequests: 30, windowMs: 60 * 1000},
  submitEventSuccessWingmanRequest: {maxRequests: 10, windowMs: 60 * 1000},
  withdrawEventSuccessWingmanRequest: {maxRequests: 10, windowMs: 60 * 1000},
  // Places is keystroke-driven, so it needs a higher cap than mutations.
  placesAutocomplete: {maxRequests: 60, windowMs: 60 * 1000},
  placeDetails: {maxRequests: 30, windowMs: 60 * 1000},
  reportUser: {maxRequests: 5, windowMs: 60 * 1000},
  // 10/min
  blockUser: {maxRequests: 10, windowMs: 60 * 1000},
  unblockUser: {maxRequests: 10, windowMs: 60 * 1000},
  // 60/min because profile editing can save one field per sheet interaction.
  updateUserProfile: {maxRequests: 60, windowMs: 60 * 1000},
  // 3/hour
  createClub: {maxRequests: 3, windowMs: 60 * 60 * 1000},
  requestAccountDeletion: {maxRequests: 3, windowMs: 60 * 60 * 1000},
  createPublicClubReview: {maxRequests: 5, windowMs: 60 * 60 * 1000},
  // Admin/internal callables. Generous limits — these are role-gated and
  // audit-logged, so the cap is defense-in-depth against a compromised admin
  // token or a runaway client, not a primary control.
  adminGetOverview: {maxRequests: 30, windowMs: 60 * 1000},
  adminGetClubDetails: {maxRequests: 60, windowMs: 60 * 1000},
  adminSetClubIndexStatus: {maxRequests: 30, windowMs: 60 * 1000},
  adminDecideOrganizerIntake: {maxRequests: 30, windowMs: 60 * 1000},
  adminRecordOrganizerCuration: {maxRequests: 30, windowMs: 60 * 1000},
  adminDecideOrganizerEventCandidate: {
    maxRequests: 30,
    windowMs: 60 * 1000,
  },
  adminResolveOrganizerEventLocation: {
    maxRequests: 30,
    windowMs: 60 * 1000,
  },
  adminDecideOrganizerPolicyGap: {
    maxRequests: 30,
    windowMs: 60 * 1000,
  },
  adminDecideAccessApplication: {maxRequests: 30, windowMs: 60 * 1000},
  adminUpdateClubDetails: {maxRequests: 30, windowMs: 60 * 1000},
  requestSuvbotDemoOperation: {maxRequests: 20, windowMs: 60 * 1000},
  listSuvbotDemoActions: {maxRequests: 60, windowMs: 60 * 1000},
};

/** Default limit: 30/min for actions not explicitly listed above. */
export const DEFAULT_RATE_LIMIT: RateLimitConfig = {
  maxRequests: 30,
  windowMs: 60 * 1000,
};

/** Actions already warned about (once per instance) to avoid log spam. */
const warnedMissingRateLimitActions = new Set<string>();

// ── Implementation ─────────────────────────────────────────────────────────

/**
 * Checks whether [uid] has exceeded the rate limit for [action].
 *
 * Reads and increments a counter inside a Firestore transaction, which
 * guarantees atomicity — two concurrent requests for the same user/action
 * cannot both pass the limit.
 *
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} uid Authenticated user ID.
 * @param {string} action Action name (key in `RATE_LIMITS`).
 * @param {RateLimitConfig=} config Optional rate-limit config.
 * @throws {HttpsError} `resource-exhausted` when limit exceeded.
 */
export async function checkRateLimit(
  db: FirebaseFirestore.Firestore,
  uid: string,
  action: string,
  config?: RateLimitConfig
): Promise<void> {
  // Surface actions that silently fall back to the loose default so a missing
  // RATE_LIMITS registration is visible instead of degrading limits unnoticed.
  let limit = config ?? RATE_LIMITS[action];
  if (limit === undefined) {
    if (!warnedMissingRateLimitActions.has(action)) {
      warnedMissingRateLimitActions.add(action);
      logger.warn(
        "checkRateLimit: action has no explicit RATE_LIMITS entry; " +
          "using DEFAULT_RATE_LIMIT. Register it in RATE_LIMITS.",
        {action, default: DEFAULT_RATE_LIMIT}
      );
    }
    limit = DEFAULT_RATE_LIMIT;
  }
  const windowKey = Math.floor(Date.now() / limit.windowMs);
  const docId = `${uid}_${action}_${windowKey}`;

  const docRef = db.collection("rateLimits").doc(docId);

  const allowed = await db.runTransaction(async (tx) => {
    const doc = await tx.get(docRef);
    const currentCount: number = doc.exists ? (doc.data()?.count ?? 0) : 0;

    if (currentCount >= limit.maxRequests) {
      return false;
    }

    tx.set(docRef, {
      count: currentCount + 1,
      uid,
      action,
      windowKey,
      expiresAt: admin.firestore.Timestamp.fromMillis(
        Date.now() + limit.windowMs
      ),
    }, {merge: true});

    return true;
  });

  if (!allowed) {
    const windowSeconds = Math.round(limit.windowMs / 1000);
    throw new HttpsError(
      "resource-exhausted",
      `Rate limit exceeded for ${action}. ` +
      `Limit: ${limit.maxRequests} per ${windowSeconds}s. ` +
      "Please wait and try again."
    );
  }
}

// ── In-memory rate limiter for unauthenticated endpoints ────────────────────

/**
 * Simple in-memory rate limiter for the public `joinWaitlist` HTTP endpoint.
 *
 * Tracks request counts per IP address in a `Map`. Entries expire after
 * `windowMs`. This is intentionally simple — it does not survive function
 * cold starts (the map resets on each new instance) and does not coordinate
 * across instances. For a low-volume waitlist endpoint, this is sufficient
 * to stop scripted spam.
 */
const ipCounters = new Map<string, {count: number; resetAt: number}>();

/**
 * Checks whether [ip] has exceeded the in-memory rate limit.
 * @param {string} ip Client IP address.
 * @param {number} maxRequests Max requests per window.
 * @param {number} windowMs Window duration in milliseconds.
 * @return {boolean} `true` if the request is allowed.
 */
export function checkIpRateLimit(
  ip: string,
  maxRequests = 3,
  windowMs: number = 60 * 60 * 1000 // 3 per hour
): boolean {
  const now = Date.now();
  const entry = ipCounters.get(ip);

  if (!entry || now > entry.resetAt) {
    ipCounters.set(ip, {count: 1, resetAt: now + windowMs});
    return true;
  }

  if (entry.count >= maxRequests) {
    return false;
  }

  entry.count++;
  return true;
}
