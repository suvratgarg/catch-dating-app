import {MetaWhatsappProvider} from "../organizers/organizerWhatsappProvider";
import {assertCatchReplyEnabled} from "./whatsappReply";
import type {CatchReplyConfig, PreparedCatchReply} from "./whatsappReply";

/**
 * Catch-only credential envelope. No organizer vault, subscription, account
 * grant or default credential/provider I/O. The composition root supplies
 * the pinned secret-version reader and transport only after scoped approval.
 */
export async function prepareCatchReplyProvider(config: CatchReplyConfig,
  deps: {
    readCredential: (version: string) => Promise<string>;
    fetch: typeof fetch;
    now: () => number;
  }): Promise<PreparedCatchReply> {
  assertCatchReplyEnabled(config);
  const parts = config.credentialVersionResource.split("/");
  if (parts.length !== 6 || parts[0] !== "projects" ||
      !/^[A-Za-z0-9:-]+$/u.test(parts[1]) || parts[2] !== "secrets" ||
      parts[3] !== "CATCH_WHATSAPP_ACCESS_TOKEN" || parts[4] !== "versions" ||
      !/^[1-9][0-9]*$/u.test(parts[5]) ||
      /\s/u.test(config.credentialVersionResource) ||
      !/^v[1-9][0-9]*\.[0-9]+$/u.test(config.graphVersion)) {
    throw new Error("Catch sender credential unavailable.");
  }
  let accessToken: string;
  try {
    const raw = await deps.readCredential(config.credentialVersionResource);
    if (raw.length > 8192) throw new Error("Invalid credential size");
    const value = JSON.parse(raw);
    if (!value || typeof value !== "object" || Array.isArray(value) ||
        Object.keys(value).sort().join(",") !==
          "accessToken,phoneNumberId,schema,wabaId" ||
        value.schema !== "catch.whatsapp-sender-token/v1" ||
        value.wabaId !== config.wabaId ||
        value.phoneNumberId !== config.phoneNumberId ||
        typeof value.accessToken !== "string" || !value.accessToken ||
        value.accessToken.length > 4096 || /\s/u.test(value.accessToken)) {
      throw new Error("Invalid credential binding");
    }
    accessToken = value.accessToken;
  } catch {
    throw new Error("Catch sender credential unavailable.");
  }
  const provider = new MetaWhatsappProvider({appId: "", appSecret: "",
    configId: "", graphVersion: config.graphVersion}, deps.fetch, deps.now);
  const phoneNumberId = config.phoneNumberId;
  const recipientE164 = config.recipientE164;
  let consumed = false;
  return {
    send: async (body, deadline) => {
      if (consumed) throw new Error("Prepared Catch reply already consumed.");
      consumed = true;
      try {
        return (await provider.sendText({accessToken, phoneNumberId,
          toE164: recipientE164, body, deadline})).providerMessageId;
      } finally {
        accessToken = "";
      }
    },
  };
}
