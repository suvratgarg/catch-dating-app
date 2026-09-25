// Signed household RSVP link tokens. The token authenticates one
// household's read-and-respond surface for one program without a
// session. It carries only document ids and an exclusive expiry —
// never names, phones, or emails. Format:
// `${base64url(payloadJson)}.${base64url(hmacSha256)}`.
import {createHmac, timingSafeEqual} from "node:crypto";

const TOKEN_VERSION = 1;
// Document ids in this codebase are bounded well under this ceiling.
const MAX_ID_LENGTH = 180;

export interface HouseholdTokenPayload {
  v: number;
  programId: string;
  householdId: string;
  // Exclusive expiry in epoch milliseconds.
  expiresAtMillis: number;
}

export interface MintHouseholdTokenParams {
  programId: string;
  householdId: string;
  expiresAtMillis: number;
}

export type VerifyHouseholdTokenResult = {
  ok: true;
  payload: HouseholdTokenPayload;
} | {
  ok: false;
  reason: "malformed" | "badSignature" | "expired";
};

export function mintHouseholdToken(
  params: MintHouseholdTokenParams,
  secret: string,
): string {
  requireSecret(secret);
  requireTokenId(params.programId, "programId");
  requireTokenId(params.householdId, "householdId");
  requireMillis(params.expiresAtMillis, "expiresAtMillis");
  const payload: HouseholdTokenPayload = {
    v: TOKEN_VERSION,
    programId: params.programId,
    householdId: params.householdId,
    expiresAtMillis: params.expiresAtMillis,
  };
  const encoded = Buffer.from(JSON.stringify(payload), "utf8")
    .toString("base64url");
  return `${encoded}.${sign(encoded, secret)}`;
}

export function verifyHouseholdToken(
  token: string,
  secret: string,
  now: number,
): VerifyHouseholdTokenResult {
  requireSecret(secret);
  requireMillis(now, "now");
  const [encoded, suppliedSignature, ...extra] = token.split(".");
  if (!encoded || !suppliedSignature || extra.length > 0) {
    return {ok: false, reason: "malformed"};
  }
  // Authenticate the encoded payload before parsing anything.
  const expected = Buffer.from(sign(encoded, secret));
  const supplied = Buffer.from(suppliedSignature);
  if (supplied.length !== expected.length ||
      !timingSafeEqual(supplied, expected)) {
    return {ok: false, reason: "badSignature"};
  }
  let payload: unknown;
  try {
    payload = JSON.parse(
      Buffer.from(encoded, "base64url").toString("utf8"));
  } catch {
    return {ok: false, reason: "malformed"};
  }
  if (!isHouseholdTokenPayload(payload)) {
    return {ok: false, reason: "malformed"};
  }
  // Expiry is exclusive: the token dies at expiresAtMillis.
  if (payload.expiresAtMillis <= now) {
    return {ok: false, reason: "expired"};
  }
  return {ok: true, payload};
}

function sign(encoded: string, secret: string): string {
  return createHmac("sha256", secret).update(encoded).digest("base64url");
}

function requireSecret(secret: string): void {
  if (typeof secret !== "string" || secret.length === 0) {
    throw new RangeError("Household token secret must be non-empty.");
  }
}

function requireMillis(value: number, label: string): void {
  if (!Number.isSafeInteger(value) || value < 1) {
    throw new RangeError(
      `${label} must be a positive safe integer of milliseconds.`);
  }
}

function isTokenId(value: unknown): value is string {
  return typeof value === "string" &&
    value.length >= 1 && value.length <= MAX_ID_LENGTH;
}

function requireTokenId(value: string, label: string): void {
  if (!isTokenId(value)) {
    throw new RangeError(
      `${label} must be a string of 1..${MAX_ID_LENGTH} characters.`);
  }
}

function isHouseholdTokenPayload(
  value: unknown,
): value is HouseholdTokenPayload {
  if (!value || typeof value !== "object") return false;
  const payload = value as HouseholdTokenPayload;
  return payload.v === TOKEN_VERSION &&
    isTokenId(payload.programId) &&
    isTokenId(payload.householdId) &&
    Number.isSafeInteger(payload.expiresAtMillis) &&
    payload.expiresAtMillis >= 1;
}
