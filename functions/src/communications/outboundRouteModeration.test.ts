import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {upsertOrganizerCampaignHandler} from
  "../organizers/organizerCampaigns";
import {sendOrganizerWhatsappTestHandler} from
  "../organizers/organizerMessagingSetup";
import {sendOrganizerWhatsappReplyHandler} from
  "../organizers/organizerWhatsappThreads";

function request(data: Record<string, unknown>): CallableRequest<unknown> {
  return {
    auth: {uid: "host-1", token: {}} as CallableRequest["auth"],
    data,
    rawRequest: {} as CallableRequest["rawRequest"],
  } as CallableRequest<unknown>;
}

function unreachableDeps<T>(): T {
  return new Proxy({}, {
    get: () => {
      throw new Error("Outbound moderation must run before dependencies.");
    },
  }) as T;
}

function rejectsManagedContent(error: unknown): boolean {
  return error instanceof HttpsError &&
    error.code === "invalid-argument" &&
    error.message.includes("cannot be delivered");
}

test(
  "organizer campaign variables fail closed before persistence",
  async () => {
    await assert.rejects(
      upsertOrganizerCampaignHandler(
        request({
          organizerId: "organizer-1",
          requestId: "request-1",
          name: "August regulars",
          messageClass: "organizerUpdate",
          savedAudienceId: "audience-1",
          connectionId: "connection-1",
          templateId: "template-1",
          templateVariables: {body: "kill yourself"},
        }),
        unreachableDeps<NonNullable<Parameters<
          typeof upsertOrganizerCampaignHandler
        >[1]>>(),
      ),
      rejectsManagedContent,
    );
  },
);

test("WhatsApp test variables fail closed before provider access", async () => {
  await assert.rejects(
    sendOrganizerWhatsappTestHandler(
      request({
        organizerId: "organizer-1",
        connectionId: "connection-1",
        templateId: "template-1",
        toE164: "+919876543210",
        templateVariables: {body: "kill yourself"},
      }),
      unreachableDeps<NonNullable<Parameters<
        typeof sendOrganizerWhatsappTestHandler
      >[1]>>(),
    ),
    rejectsManagedContent,
  );
});

test(
  "WhatsApp free-form replies fail closed before provider access",
  async () => {
    await assert.rejects(
      sendOrganizerWhatsappReplyHandler(
        request({
          organizerId: "organizer-1",
          threadId: "thread-1",
          body: "kill yourself",
          expectedLastInboundAtMillis: 1,
          idempotencyKey: "reply-key-1",
        }),
        unreachableDeps<NonNullable<Parameters<
          typeof sendOrganizerWhatsappReplyHandler
        >[1]>>(),
      ),
      rejectsManagedContent,
    );
  },
);
