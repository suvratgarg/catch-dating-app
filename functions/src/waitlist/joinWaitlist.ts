import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {onRequest} from "firebase-functions/v2/https";
import {checkIpRateLimit} from "../shared/rateLimit";

interface JoinWaitlistBody {
  fullName?: unknown;
  email?: unknown;
  city?: unknown;
  role?: unknown;
  instagram?: unknown;
  website?: unknown;
  hostApplication?: unknown;
  attribution?: unknown;
  analytics?: unknown;
}

interface NormalizedMarketingAnalytics {
  consent: Record<string, unknown> | null;
  eventId: string | null;
  formVariant: string | null;
  pagePath: string | null;
  pageTitle: string | null;
  submittedAt: string | null;
}

const allowedRoles = new Set(["member", "runner", "host", "both"]);
const localOrigins = [
  "http://localhost:5000",
  "http://localhost:5175",
  "http://localhost:8123",
  "http://localhost:4187",
  "http://127.0.0.1:5000",
  "http://127.0.0.1:5175",
  "http://127.0.0.1:8123",
  "http://127.0.0.1:4187",
];

const attributionValueKeys = new Set([
  "utm_source",
  "utm_medium",
  "utm_campaign",
  "utm_content",
  "utm_term",
  "gclid",
  "gbraid",
  "wbraid",
  "fbclid",
  "ttclid",
  "msclkid",
  "li_fat_id",
  "rdt_cid",
]);

/**
 * Returns the browser origins allowed to submit launch waitlist requests.
 * @param {string} projectId The active Google Cloud project id.
 * @return {Set<string>} Allowed origins for the project.
 */
export function waitlistAllowedOrigins(projectId: string): Set<string> {
  const firebaseHostingOrigins = [
    `https://${projectId}.web.app`,
    `https://${projectId}.firebaseapp.com`,
  ];

  if (projectId === "catch-dating-app-64e51") {
    return new Set([
      "https://catchdates.com",
      "https://www.catchdates.com",
      ...firebaseHostingOrigins,
      ...localOrigins,
    ]);
  }

  return new Set([
    ...firebaseHostingOrigins,
    ...localOrigins,
  ]);
}

/**
 * Resolves a request origin to a CORS response origin when allowed.
 * @param {string|undefined} origin The request Origin header.
 * @param {string} projectId The active Google Cloud project id.
 * @return {string|null} The allowed origin, or null.
 */
export function resolveWaitlistCorsOrigin(
  origin: string | undefined,
  projectId: string
): string | null {
  if (!origin) {
    return null;
  }

  return waitlistAllowedOrigins(projectId).has(origin) ? origin : null;
}

/**
 * Parses the incoming request body regardless of whether it arrives as JSON
 * text or an already-decoded object.
 * @param {unknown} rawBody The raw request body.
 * @return {JoinWaitlistBody} The parsed body.
 */
function parseBody(rawBody: unknown): JoinWaitlistBody {
  if (typeof rawBody === "string" && rawBody.trim()) {
    try {
      return JSON.parse(rawBody) as JoinWaitlistBody;
    } catch {
      return {};
    }
  }

  if (typeof rawBody === "object" && rawBody !== null) {
    return rawBody as JoinWaitlistBody;
  }

  return {};
}

/**
 * Trims and collapses repeated whitespace in a user-provided string.
 * @param {unknown} value The raw value.
 * @return {string} The normalized string value.
 */
function normalizeText(value: unknown): string {
  if (typeof value !== "string") {
    return "";
  }

  return value.trim().replace(/\s+/g, " ");
}

/**
 * Normalizes an email address for deduplication.
 * @param {unknown} value The raw email value.
 * @return {string} A lower-cased email string.
 */
function normalizeEmail(value: unknown): string {
  return normalizeText(value).toLowerCase();
}

/**
 * Validates a simple email shape for waitlist submissions.
 * @param {string} email The normalized email address.
 * @return {boolean} Whether the email looks valid.
 */
function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

/**
 * Validates the submitted city value.
 * @param {string} city The submitted city.
 * @return {boolean} Whether the city is usable.
 */
function isValidCity(city: string): boolean {
  return city.length >= 2 && city.length <= 80;
}

/**
 * Normalizes an optional Instagram handle.
 * @param {unknown} value The raw handle value.
 * @return {string|null} The normalized handle, or null when absent.
 */
function normalizeInstagram(value: unknown): string | null {
  const handle = normalizeText(value).replace(/\s+/g, "");
  if (!handle) {
    return null;
  }

  return handle.startsWith("@") ? handle : `@${handle}`;
}

/**
 * Normalizes launch waitlist roles from current and legacy marketing forms.
 * @param {string} role The submitted role.
 * @return {string} Canonical role stored in Firestore.
 */
export function normalizeWaitlistRole(role: string): string {
  return role === "runner" ? "member" : role;
}

/**
 * Normalizes a bounded optional marketing text field.
 * @param {unknown} value The raw field value.
 * @param {number} maxLength Maximum accepted length.
 * @return {string|null} The normalized text, or null.
 */
function normalizeOptionalMarketingText(
  value: unknown,
  maxLength = 512
): string | null {
  const text = normalizeText(value);
  if (!text) {
    return null;
  }
  return text.slice(0, maxLength);
}

/**
 * Normalizes a bounded string array from a marketing form.
 * @param {unknown} value Raw array payload.
 * @param {number} maxItems Maximum accepted values.
 * @param {number} maxLength Maximum length per value.
 * @return {string[]} Sanitized string values.
 */
function normalizeMarketingStringArray(
  value: unknown,
  maxItems = 12,
  maxLength = 120
): string[] {
  if (!Array.isArray(value)) {
    return [];
  }

  const normalized = value
    .map((item) => normalizeOptionalMarketingText(item, maxLength))
    .filter((item): item is string => Boolean(item));
  return [...new Set(normalized)].slice(0, maxItems);
}

/**
 * Normalizes the richer host application packet from the marketing site.
 * @param {unknown} value Raw host application payload.
 * @return {Record<string, unknown>|null} Sanitized host application payload.
 */
export function normalizeHostApplication(
  value: unknown
): Record<string, unknown> | null {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return null;
  }

  const raw = value as Record<string, unknown>;
  const application = {
    organizationName: normalizeOptionalMarketingText(
      raw.organizationName,
      140
    ),
    organizationType: normalizeOptionalMarketingText(
      raw.organizationType,
      80
    ),
    operatingCity: normalizeOptionalMarketingText(raw.operatingCity, 80),
    communityLink: normalizeOptionalMarketingText(raw.communityLink, 512),
    formats: normalizeMarketingStringArray(raw.formats, 10, 80),
    eventCadence: normalizeOptionalMarketingText(raw.eventCadence, 80),
    nextEventName: normalizeOptionalMarketingText(raw.nextEventName, 160),
    nextEventDate: normalizeOptionalMarketingText(raw.nextEventDate, 80),
    eventLocation: normalizeOptionalMarketingText(raw.eventLocation, 180),
    expectedCapacity: normalizeOptionalMarketingText(
      raw.expectedCapacity,
      40
    ),
    priceRange: normalizeOptionalMarketingText(raw.priceRange, 80),
    admissionModel: normalizeOptionalMarketingText(raw.admissionModel, 80),
    waitlistPlan: normalizeOptionalMarketingText(raw.waitlistPlan, 80),
    paymentReadiness: normalizeOptionalMarketingText(
      raw.paymentReadiness,
      120
    ),
    eventSuccessModules: normalizeMarketingStringArray(
      raw.eventSuccessModules,
      16,
      120
    ),
    hostGoals: normalizeOptionalMarketingText(raw.hostGoals, 1000),
    operatingNotes: normalizeOptionalMarketingText(raw.operatingNotes, 1000),
  };

  const hasValue = Object.values(application).some((item) =>
    Array.isArray(item) ? item.length > 0 : Boolean(item)
  );
  return hasValue ? application : null;
}

/**
 * Normalizes a bounded string map while allowing only known attribution keys.
 * @param {unknown} value Raw attribution values object.
 * @return {Record<string, string>} Sanitized attribution values.
 */
function normalizeAttributionValues(value: unknown): Record<string, string> {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return {};
  }

  const result: Record<string, string> = {};
  for (const [key, raw] of Object.entries(value)) {
    if (!attributionValueKeys.has(key)) continue;
    const normalized = normalizeOptionalMarketingText(raw, 240);
    if (normalized) {
      result[key] = normalized;
    }
  }
  return result;
}

/**
 * Normalizes a first-touch or last-touch attribution block.
 * @param {unknown} value Raw touch payload.
 * @return {Record<string, unknown>|null} Sanitized touch payload.
 */
function normalizeAttributionTouch(
  value: unknown
): Record<string, unknown> | null {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return null;
  }

  const raw = value as Record<string, unknown>;
  return {
    capturedAt: normalizeOptionalMarketingText(raw.capturedAt, 80),
    landingPath: normalizeOptionalMarketingText(raw.landingPath, 512),
    landingUrl: normalizeOptionalMarketingText(raw.landingUrl, 1024),
    referrer: normalizeOptionalMarketingText(raw.referrer, 1024),
    values: normalizeAttributionValues(raw.values),
  };
}

/**
 * Normalizes attribution from the marketing website.
 * @param {unknown} value Raw attribution payload.
 * @return {Record<string, unknown>|null} Sanitized attribution payload.
 */
export function normalizeMarketingAttribution(
  value: unknown
): Record<string, unknown> | null {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return null;
  }

  const raw = value as Record<string, unknown>;
  const firstTouch = normalizeAttributionTouch(raw.firstTouch);
  const lastTouch = normalizeAttributionTouch(raw.lastTouch);
  if (!firstTouch && !lastTouch) {
    return null;
  }

  return {
    firstTouch,
    lastTouch,
  };
}

/**
 * Normalizes consent details sent by the marketing website.
 * @param {unknown} value Raw consent payload.
 * @return {Record<string, unknown>|null} Sanitized consent payload.
 */
function normalizeMarketingConsent(
  value: unknown
): Record<string, unknown> | null {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return null;
  }

  const raw = value as Record<string, unknown>;
  return {
    analytics: raw.analytics === true,
    choice: normalizeOptionalMarketingText(raw.choice, 40),
    marketing: raw.marketing === true,
    updatedAt: normalizeOptionalMarketingText(raw.updatedAt, 80),
  };
}

/**
 * Normalizes analytics metadata from the marketing website.
 * @param {unknown} value Raw analytics payload.
 * @return {NormalizedMarketingAnalytics|null} Sanitized analytics payload.
 */
export function normalizeMarketingAnalytics(
  value: unknown
): NormalizedMarketingAnalytics | null {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return null;
  }

  const raw = value as Record<string, unknown>;
  return {
    consent: normalizeMarketingConsent(raw.consent),
    eventId: normalizeOptionalMarketingText(raw.eventId, 160),
    formVariant: normalizeOptionalMarketingText(raw.formVariant, 40),
    pagePath: normalizeOptionalMarketingText(raw.pagePath, 512),
    pageTitle: normalizeOptionalMarketingText(raw.pageTitle, 240),
    submittedAt: normalizeOptionalMarketingText(raw.submittedAt, 80),
  };
}

/**
 * Sets CORS headers for the waitlist endpoint.
 * @param {Object} request The request-like object.
 * @param {Object} response The response-like object.
 * @return {boolean} Whether the request origin is allowed.
 */
function setCorsHeaders(request: {
  get: (header: string) => string | undefined;
}, response: {
  set: (header: string, value: string) => void;
}): boolean {
  const origin = request.get("origin");
  const projectId = process.env.GCLOUD_PROJECT ?? process.env.GCP_PROJECT ?? "";
  const allowedOrigin = resolveWaitlistCorsOrigin(origin, projectId);

  if (allowedOrigin) {
    response.set("Access-Control-Allow-Origin", allowedOrigin);
  }

  response.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  response.set("Access-Control-Allow-Headers", "Content-Type");
  response.set("Vary", "Origin");

  return !origin || allowedOrigin !== null;
}

/**
 * Stores a waitlist submission for catchdates.com launch access.
 */
export const joinWaitlist = onRequest(
  {region: "asia-south1"},
  async (request, response) => {
    if (!setCorsHeaders(request, response)) {
      response.status(403).json({error: "Origin not allowed."});
      return;
    }

    if (request.method === "OPTIONS") {
      response.status(204).send("");
      return;
    }

    if (request.method !== "POST") {
      response.status(405).json({error: "Method not allowed."});
      return;
    }

    const body = parseBody(request.body);
    const fullName = normalizeText(body.fullName);
    const email = normalizeEmail(body.email);
    const city = normalizeText(body.city);
    const submittedRole = normalizeText(body.role).toLowerCase();
    const role = normalizeWaitlistRole(submittedRole);
    const instagram = normalizeInstagram(body.instagram);
    const honeypot = normalizeText(body.website);
    const hostApplication = normalizeHostApplication(body.hostApplication);
    const marketingAttribution = normalizeMarketingAttribution(
      body.attribution
    );
    const marketingAnalytics = normalizeMarketingAnalytics(body.analytics);

    const clientIp = request.get("x-forwarded-for")?.split(",")[0]?.trim() ??
      request.ip ??
      "unknown";

    if (!checkIpRateLimit(clientIp)) {
      response.status(429).json({
        error: "Too many requests. Please try again later.",
      });
      return;
    }

    if (honeypot) {
      logger.info("Waitlist honeypot tripped", {email});
      response.status(200).json({ok: true, alreadyJoined: false});
      return;
    }

    if (fullName.length < 2 || fullName.length > 100) {
      response.status(400).json({error: "Please enter your full name."});
      return;
    }

    if (!isValidEmail(email)) {
      response.status(400).json({error: "Please enter a valid email."});
      return;
    }

    if (!isValidCity(city)) {
      response.status(400).json({
        error: "Please tell us which city you event in.",
      });
      return;
    }

    if (!allowedRoles.has(submittedRole)) {
      response.status(400).json({error: "Please choose how you're joining."});
      return;
    }

    const waitlistRef = admin
      .firestore()
      .collection("launchWaitlist")
      .doc(Buffer.from(email).toString("base64url"));

    const referrer = normalizeText(request.get("referer"));
    const userAgent = normalizeText(request.get("user-agent"));
    const conversionEventId = marketingAnalytics?.eventId ??
      `waitlist_${Date.now()}_${waitlistRef.id}`;
    const conversionName =
      marketingAnalytics?.formVariant === "host" || role === "host" ?
        "host_lead_submitted" :
        "waitlist_submitted";
    const conversionRef = admin
      .firestore()
      .collection("marketingConversionEvents")
      .doc(conversionEventId);
    let alreadyJoined = false;

    await admin.firestore().runTransaction(async (transaction) => {
      const existing = await transaction.get(waitlistRef);
      const baseData = {
        fullName,
        email,
        city,
        role,
        instagram,
        source: "catchdates.com",
        referrer: referrer || null,
        userAgent: userAgent || null,
        hostApplication,
        marketingAnalytics,
        marketingAttribution,
      };

      if (existing.exists) {
        alreadyJoined = true;
        transaction.update(waitlistRef, {
          ...baseData,
          lastSubmittedAt: admin.firestore.FieldValue.serverTimestamp(),
          submissionCount: admin.firestore.FieldValue.increment(1),
        });
        return;
      }

      transaction.create(waitlistRef, {
        ...baseData,
        status: "pending",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        lastSubmittedAt: admin.firestore.FieldValue.serverTimestamp(),
        submissionCount: 1,
      });

      transaction.set(conversionRef, {
        analytics: marketingAnalytics,
        attribution: marketingAttribution,
        city,
        consent: marketingAnalytics?.consent ?? null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        eventId: conversionEventId,
        eventName: conversionName,
        leadId: waitlistRef.id,
        leadPath: waitlistRef.path,
        hostApplication,
        role,
        source: "catchdates.com",
        status: "readyForReview",
        standardEvent: "Lead",
      });
    });

    logger.info("Waitlist submission stored", {
      email,
      city,
      role,
      alreadyJoined,
    });

    response.status(200).json({
      ok: true,
      alreadyJoined,
    });
  }
);
