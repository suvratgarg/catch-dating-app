/** Transient Google wire types. These are not sender or dispatch authority. */
export interface GoogleRbmRequest {
  region: "asia" | "europe" | "us";
  agentId: string;
  accessToken: string;
  phoneE164: string;
  deadline: number;
}

export type GoogleRbmSuggestion =
  {reply: {text: string; postbackData: string}} |
  {action: {text: string; postbackData: string; openUrlAction: {url: string}}};

export interface GoogleRbmSendRequest extends GoogleRbmRequest {
  messageId: string;
  contentMessage: {text: string; suggestions: GoogleRbmSuggestion[]};
  expiresAt: number;
}

export type GoogleRbmFailure =
  | {kind: "notSent"; reason: "invalidRequest" | "deadlineExpired"}
  | {kind: "unknown"; reason: "transport" | "invalidResponse" |
      "http" | "duplicate"; httpStatus: number | null};

export type GoogleRbmSendOutcome = GoogleRbmFailure |
  {kind: "accepted"; providerMessageId: string} |
  {kind: "rejected"; reason: "invalidArgument" |
    "agentOrRecipientUnavailable"; httpStatus: 400 | 404};

export type GoogleRbmCapabilitiesOutcome = GoogleRbmFailure |
  {kind: "reachable"; supportsOpenUrl: boolean} |
  {kind: "unreachable"; reason: "agentOrRecipientUnavailable"};

/** A DELETE acknowledgement is deliberately not a non-delivery receipt. */
export type GoogleRbmRevokeOutcome = GoogleRbmFailure |
  {kind: "revocationRequested"; providerMessageId: string};

export const GOOGLE_RBM_MAX_BYTES = 64 * 1024;
const MAX_EXPIRY_MILLIS = 15 * 24 * 60 * 60 * 1000;
const ORIGINS = {
  asia: "https://asia-rcsbusinessmessaging.googleapis.com",
  europe: "https://europe-rcsbusinessmessaging.googleapis.com",
  us: "https://us-rcsbusinessmessaging.googleapis.com",
} as const;

export function rbmRecord(value: unknown): Record<string, unknown> | null {
  return value && typeof value === "object" && !Array.isArray(value) ?
    value as Record<string, unknown> : null;
}

function textValue(value: unknown, max: number): value is string {
  return typeof value === "string" && value.length > 0 &&
    value.length <= max &&
    Buffer.from(value, "utf8").toString("utf8") === value;
}

function exactKeys(value: Record<string, unknown>, keys: string): boolean {
  return Object.keys(value).sort().join(",") === keys;
}

export function rbmTime(value: unknown): value is number {
  return Number.isSafeInteger(value) && (value as number) >= 0 &&
    (value as number) <= 253402300799999;
}

export function rbmUuid(value: unknown): value is string {
  return typeof value === "string" && value.length === 36 &&
    /^[a-f0-9]{8}-[a-f0-9]{4}-[1-5][a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$/
      .test(value);
}

/** Encode validated path/query values; never accept an arbitrary origin. */
export function rbmUrl(input: GoogleRbmRequest, suffix: string): URL | null {
  if (!input || !Object.hasOwn(ORIGINS, input.region) ||
      !textValue(input.agentId, 512) ||
      /\s/.test(input.agentId) ||
      !/^[A-Za-z0-9][A-Za-z0-9._@-]*$/.test(input.agentId) ||
      !textValue(input.accessToken, 4096) ||
      /\s/.test(input.accessToken) ||
      !/^[A-Za-z0-9._~+/-]+=*$/.test(input.accessToken) ||
      typeof input.phoneE164 !== "string" ||
      !/^\+[1-9][0-9]{7,14}$/.test(input.phoneE164) ||
      /\s/.test(input.phoneE164) || !rbmTime(input.deadline)) return null;
  const url = new URL(ORIGINS[input.region] + "/v1/phones/" +
    encodeURIComponent(input.phoneE164) + suffix);
  url.searchParams.set("agentId", input.agentId);
  return url;
}

function suggestion(value: unknown): GoogleRbmSuggestion | null {
  const v = rbmRecord(value);
  if (!v) return null;
  const isReply = exactKeys(v, "reply");
  if (!isReply && !exactKeys(v, "action")) return null;
  const option = rbmRecord(isReply ? v.reply : v.action);
  if (!option || !exactKeys(option, isReply ? "postbackData,text" :
    "openUrlAction,postbackData,text") || !textValue(option.text, 25) ||
    !option.text.trim() || !textValue(option.postbackData, 2048)) return null;
  const base = {text: option.text, postbackData: option.postbackData};
  if (isReply) return {reply: base};
  const action = rbmRecord(option.openUrlAction);
  if (!action || !exactKeys(action, "url") ||
      !textValue(action.url, 2048) || /[\s\\]/.test(action.url)) return null;
  try {
    const url = new URL(action.url);
    if (url.protocol !== "https:" || url.username || url.password) return null;
  } catch {
    return null;
  }
  return {action: {...base, openUrlAction: {url: action.url}}};
}

/** Copy supported fields; never serialize unknown fields or a toJSON hook. */
export function rbmSendBody(input: GoogleRbmSendRequest,
  now: number): string | null {
  const content = rbmRecord(input.contentMessage);
  if (!rbmUuid(input.messageId) || !rbmTime(input.expiresAt) ||
      !rbmTime(now) || input.expiresAt - now > MAX_EXPIRY_MILLIS ||
      !content || !exactKeys(content, "suggestions,text") ||
      !textValue(content.text, 3072) || !content.text.trim() ||
      !Array.isArray(content.suggestions) ||
      content.suggestions.length > 11) {
    return null;
  }
  const suggestions: GoogleRbmSuggestion[] = [];
  const correlations = new Set<string>();
  for (const value of content.suggestions) {
    const parsed = suggestion(value);
    if (!parsed) return null;
    const postback = "reply" in parsed ? parsed.reply.postbackData :
      parsed.action.postbackData;
    if (correlations.has(postback)) return null;
    correlations.add(postback);
    suggestions.push(parsed);
  }
  const body = JSON.stringify({
    contentMessage: {text: content.text, suggestions},
    messageTrafficType: "TRANSACTION",
    expireTime: new Date(input.expiresAt).toISOString()});
  return Buffer.byteLength(body) <= GOOGLE_RBM_MAX_BYTES ? body : null;
}

export function rbmErrorMatches(body: Record<string, unknown>,
  code: number, status: string): boolean {
  const error = rbmRecord(body.error);
  return error?.code === code && error.status === status;
}
