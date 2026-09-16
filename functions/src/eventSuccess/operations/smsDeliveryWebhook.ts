import type {Response} from "express";
import {getFirestore} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import {defineBoolean} from "firebase-functions/params";
import {onRequest, Request} from "firebase-functions/v2/https";
import {parseSmsDeliveryReport, SmsDeliveryReportStore,
  SmsReportResult} from "./smsDeliveryReports";

export const eventSmsReportsEnabled = defineBoolean(
  "EVENT_ASSISTANCE_SMS_REPORTS_ENABLED", {default: false});

interface Dependencies {
  enabled: () => boolean;
  receive: (query: Record<string, string>) => Promise<SmsReportResult>;
  failed: () => void;
}
const defaults: Dependencies = {
  enabled: () => eventSmsReportsEnabled.value(),
  receive: (query) => new SmsDeliveryReportStore(getFirestore()).receive(query),
  // Errors may contain provider URLs, phones and per-attempt credentials.
  failed: () => logger.error("Event SMS delivery report processing failed"),
};
const fields = new Set(["msg_id", "extra", "externalId", "deliveredTS",
  "status", "cause", "errCode", "phoneNo", "noOfFrags", "mask"]);

/** Decode documented GET fields and reject duplicate parameters. */
function reportQuery(url: string): Record<string, string> | null {
  if (!url.startsWith("/") || /[\r\n#]/.test(url)) return null;
  const at = url.indexOf("?");
  if (at < 0) return null;
  const query: Record<string, string> = Object.create(null);
  for (const [key, value] of new URLSearchParams(url.slice(at + 1))) {
    if (!fields.has(key) || Object.hasOwn(query, key)) return null;
    query[key] = value;
  }
  return parseSmsDeliveryReport(query) ? query : null;
}

/** The per-attempt echo authenticates one report, not a provider account. */
export async function eventAssistanceSmsDeliveryWebhookHandler(
  request: Request, response: Response, deps: Dependencies = defaults
): Promise<void> {
  response.set({"Cache-Control": "private, no-store, max-age=0",
    "Pragma": "no-cache", "Content-Type": "text/plain; charset=utf-8",
    "X-Content-Type-Options": "nosniff", "Referrer-Policy": "no-referrer"});
  const unavailable = () => {
    response.set("Retry-After", "30");
    response.status(503).send("Unavailable");
  };
  try {
    if (!deps.enabled()) return unavailable();
    if (request.method !== "GET") {
      response.set("Allow", "GET");
      response.status(405).send("Method not allowed");
      return;
    }
    const url = request.originalUrl;
    if (typeof url !== "string" || Buffer.byteLength(url, "utf8") > 4096) {
      response.status(414).send("Request target too long");
      return;
    }
    const length = request.headers["content-length"];
    if (request.headers["transfer-encoding"] !== undefined ||
        length !== undefined && length !== "0" ||
        request.rawBody !== undefined &&
          (!Buffer.isBuffer(request.rawBody) || request.rawBody.length > 0)) {
      response.status(400).send("Invalid report");
      return;
    }
    // Do not trust Express query coercion, forwarded identity headers, or body.
    const query = reportQuery(url);
    if (!query) {
      response.status(400).send("Invalid report");
      return;
    }
    const result = await deps.receive(query);
    if (result.kind === "rejected") {
      response.status(403).send("Invalid report");
      return;
    }
    // Indeterminate reports do not prove failure or authorize another send.
    // Acknowledge only after the receiver has finished its durable work.
    response.status(200).send("ok");
  } catch {
    deps.failed();
    unavailable();
  }
}

// Activation also needs verified HTTPS callback configuration and platform
// request-log exclusion/redaction: application logging cannot redact edge URLs.
export const eventAssistanceSmsDeliveryWebhook = onRequest(
  {maxInstances: 5, concurrency: 20, timeoutSeconds: 30},
  (request, response) =>
    eventAssistanceSmsDeliveryWebhookHandler(request, response));
