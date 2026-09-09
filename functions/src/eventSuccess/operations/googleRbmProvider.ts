import {GOOGLE_RBM_MAX_BYTES, rbmErrorMatches, rbmRecord, rbmSendBody,
  rbmTime, rbmUrl, rbmUuid} from "./googleRbmProtocol";
import type {GoogleRbmCapabilitiesOutcome, GoogleRbmFailure, GoogleRbmRequest,
  GoogleRbmRevokeOutcome, GoogleRbmSendOutcome, GoogleRbmSendRequest} from
  "./googleRbmProtocol";

type Exchange = GoogleRbmFailure | {kind: "response"; status: number;
  body: Record<string, unknown>};
const INVALID: GoogleRbmFailure = {kind: "notSent", reason: "invalidRequest"};

/**
 * Low-level wire adapter; caller must own consent, budget and durable claiming.
 * No default transport, credentials, retry, fallback or registered executor.
 */
export class GoogleRbmProvider {
  constructor(private readonly fetchImpl: typeof fetch,
    private readonly clock: () => number = Date.now) {}

  async getCapabilities(input: GoogleRbmRequest & {requestId: string}):
    Promise<GoogleRbmCapabilitiesOutcome> {
    const url = rbmUrl(input, "/capabilities");
    if (!url || !rbmUuid(input.requestId)) return {...INVALID};
    url.searchParams.set("requestId", input.requestId);
    const result = await this.exchange(input, url, "GET");
    if (result.kind !== "response") return result;
    const {status, body} = result;
    if (status === 404 && rbmErrorMatches(body, 404, "NOT_FOUND")) {
      // This also covers an unlaunched agent or unavailable network.
      return {kind: "unreachable", reason: "agentOrRecipientUnavailable"};
    }
    if (status !== 200) return httpFailure(status);
    const features = body.features === undefined ? [] : body.features;
    if (body.error !== undefined || !Array.isArray(features) ||
        features.length > 128 || features.some((f) =>
      typeof f !== "string" || f.trim() !== f ||
          !/^[A-Z][A-Z0-9_]{0,127}$/.test(f))) {
      return invalidResponse(status);
    }
    return {kind: "reachable", supportsOpenUrl:
      features.includes("ACTION_OPEN_URL")};
  }

  async sendText(input: GoogleRbmSendRequest): Promise<GoogleRbmSendOutcome> {
    const url = rbmUrl(input, "/agentMessages");
    if (!url) return {...INVALID};
    const body = rbmSendBody(input, this.clock());
    if (!body) return {...INVALID};
    const providerMessageId = input.messageId;
    const name = "phones/" + input.phoneE164 + "/agentMessages/" +
      providerMessageId;
    const expiresAt = input.expiresAt;
    url.searchParams.set("messageId", providerMessageId);
    const result = await this.exchange({...input,
      deadline: Math.min(input.deadline, expiresAt)}, url, "POST", body);
    if (result.kind !== "response") return result;
    if (result.status === 200) {
      const value = result.body;
      if (value.error !== undefined || value.name !== name ||
          typeof value.expireTime !== "string" ||
          Date.parse(value.expireTime) !== expiresAt) {
        return invalidResponse(result.status);
      }
      // Acceptance can mean queued for an offline recipient. Never delivered.
      return {kind: "accepted", providerMessageId};
    }
    if (result.status === 400 &&
        rbmErrorMatches(result.body, 400, "INVALID_ARGUMENT")) {
      return {kind: "rejected", reason: "invalidArgument", httpStatus: 400};
    }
    if (result.status === 404 &&
        rbmErrorMatches(result.body, 404, "NOT_FOUND")) {
      return {kind: "rejected", reason: "agentOrRecipientUnavailable",
        httpStatus: 404};
    }
    return httpFailure(result.status);
  }

  async revoke(input: GoogleRbmRequest & {messageId: string}):
    Promise<GoogleRbmRevokeOutcome> {
    if (!rbmUuid(input?.messageId)) return {...INVALID};
    const providerMessageId = input.messageId;
    const url = rbmUrl(input, "/agentMessages/" + providerMessageId);
    if (!url) return {...INVALID};
    const result = await this.exchange(input, url, "DELETE");
    if (result.kind !== "response") return result;
    if (result.status !== 200) return httpFailure(result.status);
    if (Object.keys(result.body).length) return invalidResponse(result.status);
    // Even HTTP 200 can race with delivery. This never grants SMS fallback.
    return {kind: "revocationRequested", providerMessageId};
  }

  private async exchange(input: GoogleRbmRequest, url: URL,
    method: "GET" | "POST" | "DELETE", body?: string): Promise<Exchange> {
    // Recheck after preparation, immediately before the single network request.
    const now = this.clock();
    if (!rbmTime(now)) return {...INVALID};
    if (now >= input.deadline) {
      return {kind: "notSent", reason: "deadlineExpired"};
    }
    try {
      const response = await this.fetchImpl(url.toString(), {
        method, body, redirect: "error",
        headers: {"Authorization": "Bearer " + input.accessToken,
          "Content-Type": "application/json", "Accept": "application/json"},
        signal: AbortSignal.timeout(Math.min(10_000, input.deadline - now)),
      });
      const parsed = await boundedJson(response);
      return parsed ?
        {kind: "response", status: response.status, body: parsed} :
        invalidResponse(response.status);
    } catch {
      // Exceptions can contain bearer tokens, phone numbers and guest links.
      return {kind: "unknown", reason: "transport", httpStatus: null};
    }
  }
}

function httpFailure(status: number): GoogleRbmFailure {
  return {kind: "unknown", reason: status === 409 ? "duplicate" : "http",
    httpStatus: status};
}

function invalidResponse(status: number): GoogleRbmFailure {
  return {kind: "unknown", reason: "invalidResponse", httpStatus: status};
}

async function boundedJson(response: Response):
  Promise<Record<string, unknown> | null> {
  const reader = response.body?.getReader();
  if (!reader) return null;
  const chunks: Uint8Array[] = [];
  let size = 0;
  try {
    if (!/^application\/json(?:\s*;|$)/i.test(
      response.headers.get("content-type") ?? "")) return null;
    for (;;) {
      const {done, value} = await reader.read();
      if (done) break;
      size += value.length;
      if (size > GOOGLE_RBM_MAX_BYTES) return null;
      chunks.push(value);
    }
    const text = new TextDecoder("utf-8", {fatal: true})
      .decode(Buffer.concat(chunks));
    return rbmRecord(JSON.parse(text));
  } catch {
    return null;
  } finally {
    await reader.cancel().catch(() => undefined);
    reader.releaseLock();
  }
}
