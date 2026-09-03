import {createHmac} from "node:crypto";
import {lookup} from "node:dns/promises";
import {LookupAddress} from "node:dns";
import {request as httpsRequest} from "node:https";
import {BlockList, isIP} from "node:net";
import {HttpsError} from "firebase-functions/v2/https";
import {OrganizerAutomationEvent} from "./organizerAutomationSource";

const blocked = new BlockList();
for (const [address, prefix] of [
  ["0.0.0.0", 8],
  ["10.0.0.0", 8],
  ["100.64.0.0", 10],
  ["127.0.0.0", 8],
  ["169.254.0.0", 16],
  ["172.16.0.0", 12],
  ["192.0.0.0", 24],
  ["192.0.2.0", 24],
  ["192.88.99.0", 24],
  ["192.168.0.0", 16],
  ["198.18.0.0", 15],
  ["198.51.100.0", 24],
  ["203.0.113.0", 24],
  ["224.0.0.0", 4],
  ["240.0.0.0", 4],
] as const) {
  blocked.addSubnet(address, prefix, "ipv4");
}
const ipv6Global = new BlockList();
ipv6Global.addSubnet("2000::", 3, "ipv6");
for (const [address, prefix] of [
  ["2001::", 23],
  ["2001:db8::", 32],
  ["2002::", 16],
  ["3fff::", 20],
] as const) {
  blocked.addSubnet(address, prefix, "ipv6");
}

export function isPublicWebhookAddress(address: string): boolean {
  const family = isIP(address);
  return family === 4 ?
    !blocked.check(address, "ipv4") :
    family === 6 &&
        ipv6Global.check(address, "ipv6") &&
        !blocked.check(address, "ipv6");
}

export function publicWebhookUrl(value: string): URL {
  let url: URL;
  try {
    url = new URL(value);
  } catch {
    throw new HttpsError(
      "invalid-argument",
      "Enter a public HTTPS webhook URL.",
    );
  }
  const host = url.hostname.replace(/^\[|\]$/g, "");
  if (
    url.protocol !== "https:" ||
    url.username ||
    url.password ||
    url.hash ||
    (url.port && url.port !== "443") ||
    host === "localhost" ||
    host.endsWith(".localhost") ||
    (isIP(host) && !isPublicWebhookAddress(host))
  ) {
    throw new HttpsError("invalid-argument", "Use public HTTPS on port 443.");
  }
  return url;
}

export function signedWebhookRequest(params: {
  deliveryId: string;
  ruleId: string;
  ruleRevision: number;
  event: OrganizerAutomationEvent;
  secret: string;
  timestampMillis: number;
}): {body: string; headers: Record<string, string>} {
  const body = JSON.stringify({
    version: 1,
    deliveryId: params.deliveryId,
    ruleId: params.ruleId,
    ruleRevision: params.ruleRevision,
    event: {
      kind: params.event.kind,
      sourceId: params.event.sourceId,
      organizerId: params.event.organizerId,
      formId: params.event.formId,
      eventId: params.event.eventId,
      contactId: params.event.contactId,
      occurredAtMillis: params.event.occurredAt.toMillis(),
    },
  });
  const timestamp = String(Math.floor(params.timestampMillis / 1000));
  const signature = createHmac("sha256", params.secret)
    .update(`${timestamp}.${body}`)
    .digest("hex");
  return {
    body,
    headers: {
      "Content-Type": "application/json",
      "Content-Length": String(Buffer.byteLength(body)),
      "X-Catch-Delivery-Id": params.deliveryId,
      "Idempotency-Key": params.deliveryId,
      "X-Catch-Timestamp": timestamp,
      "X-Catch-Signature": `v1=${signature}`,
    },
  };
}

interface WebhookTransport {
  lookup: (hostname: string) => Promise<LookupAddress[]>;
  request: typeof httpsRequest;
}

async function boundedLookup(
  operation: Promise<LookupAddress[]>,
): Promise<LookupAddress[]> {
  let timer: ReturnType<typeof setTimeout> | undefined;
  try {
    return await Promise.race([
      operation,
      new Promise<never>((_resolve, reject) => {
        timer = setTimeout(
          () => reject(new Error("Webhook DNS timed out.")),
          5000,
        );
      }),
    ]);
  } finally {
    clearTimeout(timer);
  }
}

/** Pins validated DNS results to TLS; redirects are never followed. */
export async function deliverOrganizerAutomationWebhook(
  params: {
    url: string;
    secret: string;
    deliveryId: string;
    ruleId: string;
    ruleRevision: number;
    event: OrganizerAutomationEvent;
    timestampMillis: number;
  },
  deps: WebhookTransport = {
    lookup: (hostname) => lookup(hostname, {all: true, verbatim: true}),
    request: httpsRequest,
  },
): Promise<void> {
  const url = publicWebhookUrl(params.url);
  const hostname = url.hostname.replace(/^\[|\]$/g, "");
  const family = isIP(hostname);
  const addresses = family ?
    [{address: hostname, family}] :
    await boundedLookup(deps.lookup(hostname));
  if (
    !addresses.length ||
    addresses.some((row) => !isPublicWebhookAddress(row.address))
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Webhook DNS must resolve only to public addresses.",
    );
  }
  const chosen = addresses[0];
  const payload = signedWebhookRequest(params);
  let timer: ReturnType<typeof setTimeout> | undefined;
  await new Promise<void>((resolve, reject) => {
    const req = deps.request(
      url,
      {
        method: "POST",
        agent: false,
        family: chosen.family,
        headers: payload.headers,
        lookup: (_host, _options, callback) =>
          callback(null, chosen.address, chosen.family),
      },
      (response) => {
        let bytes = 0;
        response.on("data", (chunk: Buffer) => {
          bytes += chunk.length;
          if (bytes > 65536) {
            req.destroy(new Error("Webhook response too large."));
          }
        });
        response.on("error", reject);
        response.on("end", () => {
          const status = response.statusCode ?? 0;
          if (status >= 200 && status < 300) resolve();
          else {
            reject(
              new HttpsError(
                status === 429 || status >= 500 ?
                  "unavailable" :
                  "failed-precondition",
                `Webhook returned HTTP ${status}.`,
              ),
            );
          }
        });
      },
    );
    req.on("error", reject);
    req.setTimeout(5000, () => req.destroy(new Error("Webhook timed out.")));
    timer = setTimeout(
      () => req.destroy(new Error("Webhook deadline exceeded.")),
      5000,
    );
    req.end(payload.body);
  }).finally(() => clearTimeout(timer));
}
