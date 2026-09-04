import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import {
  csvCell,
  buildContactTimeline,
  decodeContactCursor,
  encodeContactCursor,
  exactContactCountFromSummary,
  listContactsMatchCountResult,
  manualContactDetailsEditable,
  manualContactHasIdentityEndpoint,
  organizerContactReadCallableLimits,
  resolveManualTags,
  summarizeContactRevenue,
  summarizeContactRevenueFacts,
} from "./organizerContacts";
import type {
  OrganizerAudienceSummaryDocument,
  OrganizerContactTagVocabularyDocument,
  OrganizerManualSendTaskDocument,
  OrganizerWhatsappMessageDocument,
  PaymentDocument,
} from "../shared/generated/firestoreAdminTypes";
import {validateCreateOrganizerContactCallablePayload} from
  "../shared/generated/schemaValidators";

test("customer timeline joins sources newest-first without overstating handoff",
  () => {
    const at = (millis: number) =>
      admin.firestore.Timestamp.fromMillis(millis);
    const manualTask = {
      organizerId: "organizer-1",
      taskId: "task-1",
      contactId: "contact-1",
      sourceKind: "individualConversation",
      sourceId: "contact-1",
      intent: "individualConversation",
      routeId: "personalWhatsappHandoff",
      deliveryMode: "byHand",
      status: "handoffOpened",
      active: true,
      revision: 2,
      idempotencyKey: "request-123",
      requestHash: "a".repeat(64),
      displayNameSnapshot: "Asha",
      endpointE164Snapshot: "+919876543210",
      endpointHash: "b".repeat(64),
      permissionSnapshot: {
        whatsappStatus: "optedIn",
        adminSuppressed: false,
        recordedAt: at(2_000),
      },
      capabilitySnapshot: {version: 1, managedRouteAvailable: false},
      prefillText: "Hello",
      prefillHash: "c".repeat(64),
      openCount: 1,
      createdByUid: "manager-1",
      updatedByUid: "manager-1",
      createdAt: at(2_000),
      updatedAt: at(4_000),
      openedAt: at(4_000),
      hostMarkedSentAt: null,
      skippedAt: null,
      cancelledAt: null,
      supersededAt: null,
      expiresAt: at(10_000),
    } satisfies OrganizerManualSendTaskDocument;
    const whatsappMessage = {
      schemaVersion: 1,
      messageId: "message-1",
      threadId: "thread-1",
      organizerId: "organizer-1",
      contactId: "contact-1",
      connectionId: "connection-1",
      direction: "inbound",
      body: "Thanks!",
      providerMessageId: "wamid.1",
      actorUid: null,
      occurredAt: at(5_000),
      createdAt: at(5_000),
      expiresAt: at(10_000),
    } satisfies OrganizerWhatsappMessageDocument;

    const result = buildContactTimeline({
      forms: [{
        kind: "form",
        timelineId: "form-1",
        responseId: "response-1",
        formId: "form-1",
        formTitle: "Quiz sign-up",
        action: "submitted",
        answeredQuestionCount: 4,
        occurredAtMillis: 1_000,
      }],
      events: [],
      sends: [],
      manualSendTasks: [manualTask],
      whatsappMessages: [whatsappMessage],
      catchReplies: [],
      formsCoverage: "exact",
      eventsCoverage: "exact",
      sendsCoverage: "exact",
      repliesCoverage: "partial",
      repliesTruncated: false,
    });

    assert.deepEqual(result.timeline.map((entry) => entry.kind), [
      "reply",
      "send",
      "form",
    ]);
    const manual = result.timeline[1];
    assert.equal(manual.kind, "send");
    if (manual.kind !== "send") throw new Error("Expected send entry.");
    assert.equal(manual.deliveryMode, "byHand");
    assert.equal(manual.observation, "hostOpened");
    assert.equal(manual.status, "handoffOpened");
    assert.equal(result.coverage.replies, "partial");
    assert.equal(
      result.coverage.replyObservation,
      "catchAndManagedWhatsappOnly"
    );
  });

const callableResourceTestName =
  "contact read callables reserve startup memory and bounded concurrency";
test(callableResourceTestName, () => {
  assert.deepEqual(organizerContactReadCallableLimits, {
    timeoutSeconds: 60,
    memory: "512MiB",
    maxInstances: 20,
    concurrency: 20,
  });
});

test("contact cursors round trip every query plan", () => {
  for (const cursor of [
    {
      version: 2 as const,
      organizerId: "organizer-1",
      plan: "people" as const,
      sort: "lastSeen" as const,
      search: null,
      value: "1720000000000",
      contactId: "contact-1",
      segmentId: null,
      manualTagId: null,
    },
    {
      version: 2 as const,
      organizerId: "organizer-1",
      plan: "search" as const,
      sort: "name" as const,
      search: "asha",
      value: "asha",
      contactId: "contact-2",
      segmentId: null,
      manualTagId: null,
    },
    {
      version: 2 as const,
      organizerId: "organizer-1",
      plan: "segment" as const,
      sort: "mostAttended" as const,
      search: null,
      value: "7",
      contactId: "contact-3",
      segmentId: "repeat_attendee",
      manualTagId: null,
    },
    {
      version: 2 as const,
      organizerId: "organizer-1",
      plan: "manualTag" as const,
      sort: "name" as const,
      search: null,
      value: "zara",
      contactId: "contact-4",
      segmentId: null,
      manualTagId: "a".repeat(32),
    },
  ]) {
    assert.deepEqual(
      decodeContactCursor(encodeContactCursor(cursor)),
      cursor
    );
  }
});

test("legacy contact cursors fail instead of changing sort semantics", () => {
  const legacyCursor = Buffer.from(JSON.stringify({
    plan: "people",
    value: "1720000000000",
    contactId: "contact-1",
    segmentId: null,
    manualTagId: null,
  })).toString("base64url");

  assert.throws(
    () => decodeContactCursor(legacyCursor),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "invalid-argument"
  );
});

test("manual tags reuse case-insensitive vocabulary entries", () => {
  const now = admin.firestore.Timestamp.fromMillis(1_000);
  const vocabulary: OrganizerContactTagVocabularyDocument = {
    organizerId: "organizer-1",
    tags: [{
      tagId: "a".repeat(32),
      label: "VIP",
      normalizedLabel: "vip",
      createdByUid: "manager-1",
      createdAt: now,
    }],
    updatedAt: now,
  };
  const resolved = resolveManualTags({
    organizerId: "organizer-1",
    labels: [" vip ", "Brings   friends"],
    vocabulary,
    actorUid: "manager-2",
    now,
  });

  assert.equal(resolved.vocabulary.tags.length, 2);
  assert.deepEqual(resolved.manualTags.map((tag) => tag.label), [
    "VIP",
    "Brings friends",
  ]);
  assert.equal(resolved.manualTags[0].tagId, "a".repeat(32));
});

test("manual tag caps fail with explicit organizer and contact errors", () => {
  const now = admin.firestore.Timestamp.fromMillis(1_000);
  assert.throws(
    () => resolveManualTags({
      organizerId: "organizer-1",
      labels: ["1", "2", "3", "4", "5", "6"],
      vocabulary: undefined,
      actorUid: "manager-1",
      now,
    }),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "invalid-argument" &&
      error.message === "A contact can have at most 5 manual tags."
  );
  const vocabulary: OrganizerContactTagVocabularyDocument = {
    organizerId: "organizer-1",
    tags: Array.from({length: 20}, (_, index) => ({
      tagId: index.toString(16).padStart(32, "0"),
      label: `Tag ${index}`,
      normalizedLabel: `tag ${index}`,
      createdByUid: "manager-1",
      createdAt: now,
    })),
    updatedAt: now,
  };
  assert.throws(
    () => resolveManualTags({
      organizerId: "organizer-1",
      labels: ["New tag"],
      vocabulary,
      actorUid: "manager-1",
      now,
    }),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "failed-precondition" &&
      error.message === "An organizer can have at most 20 manual tags."
  );
});

test("only unlinked organizer-created contacts expose endpoint editing", () => {
  assert.equal(manualContactDetailsEditable({
    primarySource: "hostManual",
    identityState: "unlinked",
  }), true);
  assert.equal(manualContactDetailsEditable({
    primarySource: "hostImport",
    identityState: "unlinked",
  }), false);
  assert.equal(manualContactDetailsEditable({
    primarySource: "hostManual",
    identityState: "verified",
  }), false);
});

test("manual contacts require at least one identity endpoint", () => {
  assert.equal(manualContactHasIdentityEndpoint({
    phoneE164: "+919876543210",
    email: null,
  }), true);
  assert.equal(manualContactHasIdentityEndpoint({
    phoneE164: null,
    email: "customer@example.com",
  }), true);
  assert.equal(manualContactHasIdentityEndpoint({
    phoneE164: null,
    email: null,
  }), false);

  assert.equal(validateCreateOrganizerContactCallablePayload({
    organizerId: "organizer-1",
    displayName: "Name only",
  }), false);
  assert.equal(validateCreateOrganizerContactCallablePayload({
    organizerId: "organizer-1",
    displayName: "Phone contact",
    phoneE164: "+919876543210",
  }), true);
  assert.equal(validateCreateOrganizerContactCallablePayload({
    organizerId: "organizer-1",
    displayName: "Email contact",
    email: "contact@example.com",
  }), true);
});

test("CRM CSV cells neutralize spreadsheet formulas and quote safely", () => {
  assert.equal(csvCell("=HYPERLINK(\"https://bad\")"),
    "\"'=HYPERLINK(\"\"https://bad\"\")\"");
  assert.equal(csvCell("Asha, Rao"), "\"Asha, Rao\"");
  assert.equal(csvCell("ordinary"), "ordinary");
});

test("contact cursor rejects malformed and unrecognized values", () => {
  assert.throws(
    () => decodeContactCursor("not-a-cursor"),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "invalid-argument"
  );
  const unsupported = Buffer.from(JSON.stringify({
    plan: "all",
    value: "x",
    contactId: "contact-1",
    segmentId: null,
  })).toString("base64url");
  assert.throws(() => decodeContactCursor(unsupported));
});

test("contact match counts never present a lower bound as exact", () => {
  assert.deepEqual(listContactsMatchCountResult(37, 8), {
    matchCount: 37,
    matchCountCoverage: "exact",
  });
  assert.deepEqual(listContactsMatchCountResult(null, 8), {
    matchCount: 8,
    matchCountCoverage: "atLeast",
  });
  assert.equal(exactContactCountFromSummary(undefined), null);
  assert.equal(exactContactCountFromSummary({
    contactCount: 12,
    sourceCoverage: "partial",
  } as OrganizerAudienceSummaryDocument), null);
  assert.equal(exactContactCountFromSummary({
    contactCount: 12,
    sourceCoverage: "exact",
  } as OrganizerAudienceSummaryDocument), 12);
});

test("customer revenue includes completed organizer payments only", () => {
  const timestamp = {toMillis: () => 1700000000000} as
    FirebaseFirestore.Timestamp;
  const payment = (
    eventId: string,
    status: PaymentDocument["status"],
    amountMinor: number
  ): PaymentDocument => ({
    userId: "user-1",
    orderId: `${eventId}-${status}`,
    paymentId: `${eventId}-${status}`,
    eventId,
    amount: amountMinor,
    amountMinor,
    currency: "INR",
    status,
    signUpFailed: false,
    createdAt: timestamp,
  });
  const revenue = summarizeContactRevenue([
    payment("event-1", "completed", 25000),
    payment("event-1", "refunded", 25000),
    payment("other-event", "completed", 90000),
  ], new Set(["event-1"]), "exact");

  assert.deepEqual(revenue, {
    coverage: "exact",
    amounts: [{
      currency: "INR",
      amountMinor: 25000,
      factCount: 1,
      sources: [{
        source: "catchPayment",
        amountMinor: 25000,
        factCount: 1,
      }],
    }],
  });
});

const importedRevenueTestName =
  "customer revenue keeps imported and estimated provenance together";
test(importedRevenueTestName, () => {
  const result = summarizeContactRevenueFacts({
    coverage: "exact",
    facts: [
      {
        eventId: "event-1",
        currency: "INR",
        amountMinor: 120000,
        source: "hostImport",
        factCount: 1,
        allocation: "sharedOrder",
      },
      {
        eventId: "event-2",
        currency: "INR",
        amountMinor: 90000,
        source: "hostEstimate",
        factCount: 1,
        allocation: "perAttendee",
      },
    ],
  });

  assert.equal(result.revenue.amounts[0].amountMinor, 210000);
  assert.deepEqual(
    result.revenue.amounts[0].sources.map((source) => source.source),
    ["hostEstimate", "hostImport"]
  );
  assert.deepEqual(result.byEvent.get("event-1"), [{
    currency: "INR",
    amountMinor: 120000,
    source: "hostImport",
    factCount: 1,
    allocation: "sharedOrder",
  }]);
});
