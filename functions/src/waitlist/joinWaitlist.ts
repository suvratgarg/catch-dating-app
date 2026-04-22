import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {onRequest} from "firebase-functions/v2/https";

interface JoinWaitlistBody {
  fullName?: unknown;
  email?: unknown;
  city?: unknown;
  role?: unknown;
  instagram?: unknown;
  website?: unknown;
}

const allowedRoles = new Set(["runner", "host", "both"]);

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
 * Sets permissive CORS headers for the waitlist endpoint.
 * @param {Object} response The response-like object.
 * @return {void}
 */
function setCorsHeaders(response: {
  set: (header: string, value: string) => void;
}) {
  response.set("Access-Control-Allow-Origin", "*");
  response.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  response.set("Access-Control-Allow-Headers", "Content-Type");
  response.set("Vary", "Origin");
}

/**
 * Stores a waitlist submission for catchdates.com launch access.
 */
export const joinWaitlist = onRequest(
  {region: "asia-south1"},
  async (request, response) => {
    setCorsHeaders(response);

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
    const role = normalizeText(body.role).toLowerCase();
    const instagram = normalizeInstagram(body.instagram);
    const honeypot = normalizeText(body.website);

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
        error: "Please tell us which city you run in.",
      });
      return;
    }

    if (!allowedRoles.has(role)) {
      response.status(400).json({error: "Please choose how you're joining."});
      return;
    }

    const waitlistRef = admin
      .firestore()
      .collection("launchWaitlist")
      .doc(Buffer.from(email).toString("base64url"));

    const referrer = normalizeText(request.get("referer"));
    const userAgent = normalizeText(request.get("user-agent"));
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
