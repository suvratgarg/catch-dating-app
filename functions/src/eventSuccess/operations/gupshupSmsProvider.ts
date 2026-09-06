import {SecretManagerServiceClient} from "@google-cloud/secret-manager";
import {operationContentHash} from "../../operations/durableActions";
import type {LiveDispatchPermit} from "./messageOutbox";
import type {RenderedSms, SmsConfig} from "./smsProtocol";
import {parseSmsConfig, smsEndpointId, smsSegments} from "./smsProtocol";
import {parseDeliveryAttempt} from "./messageProtocol";

export interface SmsCredentials {
  schema: "catch.event-sms-credential/v1";
  senderId: string;
  userid: string;
  password: string;
}
export type SmsSubmissionOutcome =
  | {kind: "accepted"; providerMessageId: string}
  | {kind: "rejected"; code: string;
      classification: "invalidRecipient" | "policy" | "suppressed"}
  | {kind: "uncertain"; reason: "transport" | "invalidResponse" |
      "providerPending"; code: string | null}
  | {kind: "withheld"; reason: "permitExpired"};

export function parseSmsCredentials(value: unknown,
  senderId: string): SmsCredentials {
  const v = value as Partial<SmsCredentials> | null;
  if (!v || typeof v !== "object" ||
      v.schema !== "catch.event-sms-credential/v1" ||
      v.senderId !== senderId || typeof v.userid !== "string" ||
      !/^[0-9]{1,30}$/.test(v.userid) || typeof v.password !== "string" ||
      v.password.length < 1 || v.password.length > 2048 ||
      Object.keys(v).sort().join(",") !== "password,schema,senderId,userid") {
    throw new Error("SMS credential unavailable or bound to another sender");
  }
  return v as SmsCredentials;
}

/** Exact numbered secret version; no token is stored in an outbox or error. */
export class SmsCredentialStore {
  constructor(private readonly client = new SecretManagerServiceClient()) {}

  async access(config: SmsConfig): Promise<SmsCredentials> {
    parseSmsConfig(config);
    try {
      const [version] = await this.client.accessSecretVersion({
        name: config.credentialVersion,
      });
      const data = version.payload?.data;
      if (!data || data.length > 8192) throw new Error("Invalid credential");
      return parseSmsCredentials(JSON.parse(data.toString("utf8")),
        config.senderId);
    } catch {
      throw new Error("SMS sender credential unavailable");
    }
  }
}

export function smsProviderCorrelation(attemptId: string): string {
  // Gupshup msg_id is alphanumeric correlation, NOT provider idempotency.
  return operationContentHash(["gupshup-sms", attemptId]);
}

/** HTTPS POST only. A lost response never triggers another submission here. */
export class GupshupSmsProvider {
  constructor(private readonly fetchImpl: typeof fetch = fetch,
    private readonly clock: () => number = Date.now) {}

  async send(input: {
    permit: LiveDispatchPermit; config: SmsConfig;
    credentials: SmsCredentials; phoneE164: string; rendered: RenderedSms;
  }): Promise<SmsSubmissionOutcome> {
    const {permit, config, credentials, phoneE164, rendered} = input;
    parseSmsConfig(config);
    parseSmsCredentials(credentials, config.senderId);
    parseDeliveryAttempt(permit.attempt);
    const binding = permit.attempt.binding;
    if (permit.intent.context.mode !== "live" ||
        permit.attempt.mode !== "live" ||
        binding.routeId !== "catchEventSms" || binding.provider !== "gupshup" ||
        binding.senderId !== config.senderId ||
        binding.bindingRevision !== config.revision ||
        binding.fallbackOwner !== "catch" ||
        binding.recipientEndpointId !== smsEndpointId(permit.intent.context,
          permit.intent.attendeeId, phoneE164) ||
        permit.attempt.state.kind !== "unknown" ||
        !/^\+91[6-9][0-9]{9}$/.test(phoneE164)) {
      throw new Error("SMS submission does not match its dispatch permit");
    }
    const approved = config.templates.find((t) =>
      t.templateId === rendered.template.templateId && t.status === "approved");
    const length = smsSegments(rendered.text);
    if (!approved || operationContentHash(approved) !==
        operationContentHash(rendered.template) ||
        length.encoding !== rendered.encoding ||
        length.segments !== rendered.segments ||
        length.units !== rendered.units ||
        length.segments > config.maxSegments ||
        rendered.maxCostMicros !==
          length.segments * config.quote.maxMicrosPerSegment ||
        rendered.payloadHash !== operationContentHash([config.senderId,
          config.revision, approved.templateId, approved.revision,
          rendered.text, length.encoding])) {
      throw new Error("SMS submission material changed after preparation");
    }
    const form = new URLSearchParams({
      userid: credentials.userid, password: credentials.password,
      send_to: phoneE164.slice(1), msg: rendered.text, method: "sendMessage",
      msg_type: rendered.encoding === "gsm7" ? "text" : "Unicode_Text",
      format: "TEXT", auth_scheme: "plain", v: "1.1", mask: config.mask,
      principalEntityId: config.principalEntityId,
      dltTemplateId: rendered.template.dltTemplateId,
      msg_id: smsProviderCorrelation(permit.attempt.attemptId),
    });
    // Check immediately before I/O, after credential loading and transaction.
    const now = this.clock();
    const deadline = Math.min(permit.validUntil, rendered.validUntil);
    if (!Number.isSafeInteger(now) || now < permit.attempt.state.at ||
        now >= deadline) return {kind: "withheld", reason: "permitExpired"};
    try {
      const response = await this.fetchImpl(
        "https://enterprise.smsgupshup.com/GatewayAPI/rest", {
          method: "POST", redirect: "error",
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: form.toString(),
          signal: AbortSignal.timeout(Math.min(10_000, deadline - now)),
        });
      const text = await boundedResponse(response);
      if (!response.ok) {
        return {kind: "uncertain", reason: "transport", code: null};
      }
      return parseGupshupSubmission(text, phoneE164);
    } catch {
      // Provider errors can echo phones, passwords and bearer links.
      return {kind: "uncertain", reason: "transport", code: null};
    }
  }
}

export function parseGupshupSubmission(text: string,
  phoneE164: string): SmsSubmissionOutcome {
  const parts = text.trim().split("|").map((p) => p.trim());
  if (parts.length !== 3 || text.length > 8192 || /[\r\n]/.test(text.trim())) {
    return {kind: "uncertain", reason: "invalidResponse", code: null};
  }
  const [status, middle, last] = parts;
  if (status === "success" && middle === phoneE164.slice(1) &&
      /^[0-9]+-[0-9]+$/.test(last) && last.length <= 512) {
    return {kind: "accepted", providerMessageId: last};
  }
  if (status !== "error" || !/^\d{3}$/.test(middle)) {
    return {kind: "uncertain", reason: "invalidResponse", code: null};
  }
  if (middle === "105") {
    return {kind: "rejected", code: middle, classification: "invalidRecipient"};
  }
  if (middle === "163") {
    return {kind: "rejected", code: middle, classification: "suppressed"};
  }
  // Explicit account/template/input rejections require operator resolution.
  if (["101", "102", "103", "104", "106", "107", "108", "109", "110",
    "113", "114", "123", "124", "127", "130", "131", "132", "138",
    "139", "140", "141", "142", "143", "145", "170", "171", "172",
    "175", "239", "240"].includes(middle)) {
    return {kind: "rejected", code: middle, classification: "policy"};
  }
  // 125 explicitly resubmits automatically; 100/117 and unknown codes also
  // provide no reliable proof of non-delivery. They never enable fallback.
  return {kind: "uncertain", reason: "providerPending", code: middle};
}

async function boundedResponse(response: Response): Promise<string> {
  const reader = response.body?.getReader();
  if (!reader) return "";
  const chunks: Uint8Array[] = [];
  let size = 0;
  try {
    for (;;) {
      const {done, value} = await reader.read();
      if (done) break;
      size += value.length;
      if (size > 8192) throw new Error("Oversized SMS response");
      chunks.push(value);
    }
    return Buffer.concat(chunks).toString("utf8");
  } finally {
    await reader.cancel().catch(() => undefined);
    reader.releaseLock();
  }
}
