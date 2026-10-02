import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {crmContactConversionTarget, convertOrganizerFormResponseHandler} from
  "./organizerFormConversions";
import type {CallableRequest} from "firebase-functions/v2/https";
import {AudienceTestStore} from "./organizerAudienceTestStore";

const submittedAt = admin.firestore.Timestamp.fromMillis(1_000);

test("new form contacts retain the form response provenance", () => {
  const target = crmContactConversionTarget({
    existingResultId: null,
    responseId: "response-1",
    formId: "form-1",
    submittedAt,
  });

  assert.match(target.contactId, /^formcontact_[a-f0-9]{32}$/u);
  assert.deepEqual(target.origin, {
    kind: "hostFormResponse",
    formId: "form-1",
    responseId: "response-1",
    observedAt: submittedAt,
  });
});

test("matched form contacts still append the form response provenance", () => {
  const target = crmContactConversionTarget({
    existingResultId: "contact-existing",
    responseId: "response-1",
    formId: "form-1",
    submittedAt,
  });

  assert.equal(target.contactId, "contact-existing");
  assert.equal(target.origin.kind, "hostFormResponse");
  assert.equal(target.origin.responseId, "response-1");
});

type Data = Record<string, unknown>;
function clone<T>(value: T): T {
  if (value instanceof admin.firestore.Timestamp) return value;
  if (Array.isArray(value)) return value.map(clone) as T;
  if (value && typeof value === "object") {
    return Object.fromEntries(Object.entries(value).map(([key, item]) =>
      [key, clone(item)])) as T;
  }
  return value;
}

/** Detached snapshots, buffered writes and optimistic read-set retries. */
class ConversionStore extends AudienceTestStore {
  beforeCommit?: (writes: string[]) => Promise<void>;
  attempts = 0;
  override snapshot(ref: Parameters<AudienceTestStore["snapshot"]>[0]) {
    const snapshot = super.snapshot(ref);
    const data = clone(snapshot.data());
    return {...snapshot, data: () => clone(data)};
  }
  override async runTransaction<T>(
    body: Parameters<AudienceTestStore["runTransaction"]>[0]
  ): Promise<T> {
    const conflict = new Error("Retry changed transaction read set");
    for (let attempt = 0; attempt < 10; attempt++) {
      this.attempts++;
      try {
        return await super.runTransaction(async (tx) => {
          const reads = new Map<string, string>();
          const writes: string[] = [];
          const fingerprint = (path: string) => JSON.stringify(
            path.includes("/") ? this.docs[path] :
              Object.entries(this.docs).filter(([key]) =>
                key.startsWith(path + "/")));
          const result = await body({...tx,
            get: async (ref) => {
              reads.set(ref.path, fingerprint(ref.path));
              return tx.get(ref);
            },
            create: (ref, data) => {
              writes.push(ref.path);
              tx.create(ref, data);
            },
            set: (ref, data, options) => {
              writes.push(ref.path);
              tx.set(ref, data, options);
            },
            update: (ref, data) => {
              writes.push(ref.path);
              tx.update(ref, data);
            },
          });
          const barrier = this.beforeCommit;
          this.beforeCommit = undefined;
          await barrier?.(writes);
          if ([...reads].some(([path, value]) =>
            value !== fingerprint(path))) throw conflict;
          return result as T;
        });
      } catch (error) {
        if (error !== conflict) throw error;
      }
    }
    throw new Error("Transaction did not settle");
  }
}

function conversionFixture(kind: "application" | "crmContact") {
  const store = new ConversionStore({
    "organizers/org1": {ownerUserId: "owner", hostUserIds: ["manager"],
      hostProfiles: []},
    "organizerForms/form1": {organizerId: "org1"},
    "organizerFormVersions/version1": {organizerId: "org1", formId: "form1",
      definition: {purpose: "application", defaultTargetKind: "organizer",
        defaultTargetId: null, sections: [{questions: [{questionId: "answer",
          kind: "shortText", canonicalFieldId: null, privacyClass: "private",
          hostPresentation: "answer"}]}]}},
    "organizerFormResponses/response1": {organizerId: "org1", formId: "form1",
      versionId: "version1", status: "submitted", withdrawnAt: null,
      respondentUid: "person", submittedAt, consentVersion: "v1",
      identity: {displayName: "Ada", email: "ada@example.com", phoneE164: null,
        origin: "submitted"},
      answerSnapshots: [{questionId: "answer", key: "answer", label: "Answer",
        answer: "Private response"}]},
  });
  const deps = {firestore: () => store.asFirestore(),
    checkRateLimit: async () => undefined, timestamp: () => submittedAt,
    identitySecret: () => "synthetic-test-identity-key-at-least-32-chars"};
  const convert = (overrides: Data = {}) =>
    convertOrganizerFormResponseHandler({
      auth: {uid: "manager", token: {}}, data: {organizerId: "org1",
        responseId: "response1", kind, eventId: null, overrides,
        requestId: "request-123"},
    } as CallableRequest<unknown>, deps);
  const withdraw = () => Object.assign(
    store.docs["organizerFormResponses/response1"],
    {status: "withdrawn", withdrawnAt: submittedAt});
  const records = (collection: string) => Object.entries(store.docs)
    .filter(([path]) => path.startsWith(collection + "/"));
  return {store, convert, withdraw, records, deps};
}

for (const kind of ["application", "crmContact"] as const) {
  test(`${kind}: withdrawal before commit creates no destination or snapshot`,
    async () => {
      const h = conversionFixture(kind);
      h.store.beforeCommit = async () => {
        h.withdraw();
      };
      await assert.rejects(h.convert(), {code: "failed-precondition"});
      for (const collection of ["organizerApplications",
        "organizerApplicationResponses", "organizerContacts",
        "organizerContactOrigins", "organizerContactIdentityLinks"]) {
        assert.equal(h.records(collection).length, 0, collection);
      }
    });

  test(`${kind}: revoked actor cannot create a destination`, async () => {
    const h = conversionFixture(kind);
    h.store.beforeCommit = async () => {
      h.store.docs["organizers/org1"].hostUserIds = [];
    };
    await assert.rejects(h.convert(), {code: "permission-denied"});
    assert.equal(h.records("organizerApplications").length, 0);
    assert.equal(h.records("organizerApplicationResponses").length, 0);
    assert.equal(h.records("organizerContactOrigins").length, 0);
  });
}

for (const kind of ["application", "crmContact"] as const) {
  test(`${kind}: concurrent changed overrides settle one immutable result`,
    async () => {
      const h = conversionFixture(kind);
      let winner: Awaited<ReturnType<typeof h.convert>> | undefined;
      h.store.beforeCommit = async () => {
        winner = await h.convert({displayName: "Winner"});
      };
      const result = await h.convert({displayName: "Delayed attempt"});
      assert.deepEqual(result, winner);
      assert.equal(result.fields.find((field) =>
        field.destinationField === "displayName")?.value, "Winner");
      const collection = kind === "application" ?
        "organizerApplications" : "organizerContacts";
      assert.equal(h.records(collection).length, 1);
      assert.equal(h.records(collection)[0][1][kind === "application" ?
        "applicantDisplayName" : "displayName"], "Winner");
      assert.equal(h.records("organizerFormConversionReceipts").length, 1);
      if (kind === "crmContact") {
        assert.equal(h.records("organizerContactOrigins").length, 1);
        assert.equal(h.records("organizerContactNotes").length, 1);
        assert.equal(h.records("organizerAudienceSummaries")[0][1]
          .contactCount, 1);
      } else {
        assert.equal(h.records("organizerApplicationResponses").length, 1);
      }
      h.withdraw();
      const before = clone(h.store.docs);
      assert.deepEqual(await h.convert({displayName: "Later"}), result);
      assert.deepEqual(h.store.docs, before, "Replay writes nothing");
    });

  for (const status of ["pending", "failed"] as const) {
    test(`${kind}: recovers ${status} receipt after destination committed`,
      async () => {
        const h = conversionFixture(kind);
        const completed = await h.convert({displayName: "Original review"});
        const [receiptPath, receipt] =
          h.records("organizerFormConversionReceipts")[0];
        Object.assign(receipt, {status, resultId: null, completedAt: null});
        h.withdraw();
        const before = clone(h.store.docs);
        const recovered = await h.convert({displayName: "Changed retry"});
        assert.deepEqual(recovered, completed);
        delete before[receiptPath];
        const after = clone(h.store.docs);
        delete after[receiptPath];
        assert.deepEqual(after, before, "Recovery changes only the receipt");
      });
  }

  test(`${kind}: failed commit leaves no orphaned destination`, async () => {
    const h = conversionFixture(kind);
    const before = clone(h.store.docs);
    h.store.beforeCommit = async (writes) => {
      assert.ok(writes.some((path) =>
        path.startsWith("organizerFormConversionReceipts/")));
      throw new Error("Synthetic commit failure");
    };
    await assert.rejects(h.convert(), /Synthetic commit failure/);
    assert.deepEqual(h.store.docs, before);
    assert.equal((await h.convert()).status, "completed");
  });

  test(`${kind}: deleted actor cannot commit or replay`, async () => {
    const h = conversionFixture(kind);
    h.store.beforeCommit = async () => {
      h.store.docs["deletedUsers/manager"] = {status: "deleted"};
    };
    await assert.rejects(h.convert(), {code: "permission-denied"});
    assert.equal(h.records("organizerFormConversionReceipts").length, 0);
    delete h.store.docs["deletedUsers/manager"];
    await h.convert();
    h.store.docs["deletedUsers/manager"] = {status: "deleted"};
    await assert.rejects(h.convert(), {code: "permission-denied"});
  });

  test(`${kind}: source version ownership changes reject commit`, async () => {
    const h = conversionFixture(kind);
    h.store.beforeCommit = async () => {
      h.store.docs["organizerFormVersions/version1"].organizerId = "foreign";
    };
    await assert.rejects(h.convert(), {code: "not-found"});
    assert.equal(h.records("organizerFormConversionReceipts").length, 0);
    assert.equal(h.records("organizerApplicationResponses").length, 0);
    assert.equal(h.records("organizerContactOrigins").length, 0);
  });

  test(`${kind}: pending receipt retains reviewed overrides before first write`,
    async () => {
      const h = conversionFixture(kind);
      const completed = await h.convert({displayName: "Saved review"});
      const [receiptPath, receipt] =
        h.records("organizerFormConversionReceipts")[0];
      const fresh = conversionFixture(kind);
      fresh.store.docs[receiptPath] = {...receipt, status: "pending",
        resultId: null, completedAt: null};
      const result = await fresh.convert({displayName: "Changed retry"});
      assert.deepEqual(result, completed);
      const collection = kind === "application" ?
        "organizerApplications" : "organizerContacts";
      assert.equal(fresh.records(collection)[0][1][kind === "application" ?
        "applicantDisplayName" : "displayName"], "Saved review");
    });
}

test("CRM endpoint match cannot append new provenance after withdrawal",
  async () => {
    const h = conversionFixture("crmContact");
    h.store.docs["organizerContacts/matched"] = {organizerId: "org1",
      displayName: "Existing", email: "ada@example.com", linkedUid: null,
      deletedAt: null, hiddenAt: null, mergedIntoContactId: null,
      sourceCount: 1, revision: 1};
    h.store.beforeCommit = async () => {
      h.withdraw();
    };
    await assert.rejects(h.convert(), {code: "failed-precondition"});
    assert.equal(h.records("organizerContactOrigins").length, 0);
    assert.equal(h.store.docs["organizerContacts/matched"].sourceCount, 1);
  });

test("system application projection retains transaction source authority",
  async () => {
    const h = conversionFixture("application");
    const project = () => convertOrganizerFormResponseHandler({
      auth: {uid: "system_form_application_projection", token: {}},
      data: {organizerId: "org1", responseId: "response1", kind: "application",
        eventId: null, overrides: {}, requestId: "system-projection"},
    } as CallableRequest<unknown>, {...h.deps, requireManagerAuthority: false});
    h.store.beforeCommit = async () => {
      h.withdraw();
    };
    await assert.rejects(project(), {code: "failed-precondition"});
    assert.equal(h.records("organizerApplicationResponses").length, 0);
    Object.assign(h.store.docs["organizerFormResponses/response1"],
      {status: "submitted", withdrawnAt: null});
    assert.equal((await project()).status, "completed");
  });

for (const kind of ["application", "crmContact"] as const) {
  test(`${kind}: completed replay still requires current manager authority`,
    async () => {
      const h = conversionFixture(kind);
      await h.convert();
      const before = clone(h.store.docs);
      h.store.beforeCommit = async () => {
        h.store.docs["organizers/org1"].hostUserIds = [];
      };
      await assert.rejects(h.convert(), {code: "permission-denied"});
      before["organizers/org1"].hostUserIds = [];
      assert.deepEqual(h.store.docs, before);
    });

  test(`${kind}: withdrawal committed before transaction fails closed`,
    async () => {
      const h = conversionFixture(kind);
      const original = h.store.runTransaction.bind(h.store);
      h.store.runTransaction = async (body) => {
        h.withdraw();
        return original(body);
      };
      await assert.rejects(h.convert(), {code: "failed-precondition"});
      assert.equal(h.records("organizerApplicationResponses").length, 0);
      assert.equal(h.records("organizerContactOrigins").length, 0);
    });
}

test("CRM adds a matched contact's provenance once", async () => {
  const h = conversionFixture("crmContact");
  h.store.docs["organizerContacts/matched"] = {organizerId: "org1",
    displayName: "Existing", email: "ada@example.com", linkedUid: null,
    deletedAt: null, hiddenAt: null, mergedIntoContactId: null,
    sourceCount: 1, revision: 1};
  const result = await h.convert();
  assert.equal(result.resultId, "matched");
  assert.deepEqual(await h.convert(), result);
  assert.equal(h.records("organizerContacts").length, 1);
  assert.equal(h.records("organizerContactOrigins").length, 1);
  assert.equal(h.store.docs["organizerContacts/matched"].sourceCount, 2);
});

for (const status of ["completed", "pending", "failed"] as const) {
  test(`CRM ${status} replay cannot authorize a new attendee handoff`,
    async () => {
      const h = conversionFixture("crmContact");
      await h.convert();
      h.records("organizerFormConversionReceipts")[0][1].status = status;
      h.store.docs["events/event1"] = {organizerId: "org1", clubId: "org1",
        status: "published", eventFormat: {activityKind: "singlesMixer"}};
      h.store.beforeCommit = async () => {
        h.withdraw();
      };
      await assert.rejects(convertOrganizerFormResponseHandler({
        auth: {uid: "manager", token: {}}, data: {organizerId: "org1",
          responseId: "response1", kind: "eventAttendeeProposal",
          eventId: "event1", overrides: {}, requestId: "handoff-request"},
      } as CallableRequest<unknown>, h.deps), {code: "failed-precondition"});
      assert.equal(h.records("eventAttendees").length, 0);
      assert.equal(h.records("organizerContactOrigins").length, 1);
    });
}
