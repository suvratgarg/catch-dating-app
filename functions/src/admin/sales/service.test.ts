import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import path from "node:path";
import Ajv from "ajv";
import addFormats from "ajv-formats";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {executeSalesAction, executeSalesRead} from "./service";
import {qualificationPolicyHash} from "./qualificationPolicy";
import type {SalesServiceDeps} from "./service";
import type {SalesPrincipal} from "./types";

type Doc = Record<string, unknown>;
class FakeRef {
  constructor(
    readonly db: FakeDb,
    readonly path: string,
  ) {}
  get id() {
    return this.path.split("/").at(-1) ?? "";
  }
  collection(name: string) {
    return new FakeCollection(this.db, `${this.path}/${name}`);
  }
  async get() {
    const data = this.db.docs.get(this.path);
    return {exists: data !== undefined, data: () => structuredClone(data)};
  }
}
class FakeCollection {
  constructor(
    readonly db: FakeDb,
    readonly path: string,
  ) {}
  doc(id?: string) {
    return new FakeRef(this.db, `${this.path}/${id ?? `auto${++this.db.seq}`}`);
  }
  where(field: string, _op: string, value: unknown) {
    return new FakeQuery(this.db, this.path, [[field, value]]);
  }
}
class FakeQuery {
  private max = 1000;
  constructor(
    readonly db: FakeDb,
    readonly path: string,
    readonly filters: Array<[string, unknown]>,
  ) {}
  where(field: string, _op: string, value: unknown) {
    return new FakeQuery(this.db, this.path, [...this.filters, [field, value]]);
  }
  limit(value: number) {
    this.max = value;
    return this;
  }
  orderBy() {
    return this;
  }
  async get() {
    const docs = [...this.db.docs.entries()]
      .filter(
        ([path, data]) =>
          path.startsWith(`${this.path}/`) &&
          path.slice(this.path.length + 1).indexOf("/") === -1 &&
          this.filters.every(([field, value]) => data[field] === value),
      )
      .slice(0, this.max)
      .map(([path, data]) => ({
        id: path.split("/").at(-1),
        data: () => structuredClone(data),
      }));
    return {size: docs.length, docs};
  }
}
class FakeDb {
  seq = 0;
  readonly docs = new Map<string, Doc>();
  collection(name: string) {
    return new FakeCollection(this, name);
  }
  async runTransaction<T>(run: (tx: FakeTx) => Promise<T>) {
    const tx = new FakeTx(this);
    const result = await run(tx);
    tx.commit();
    return result;
  }
}
class FakeTx {
  private writes: Array<() => void> = [];
  constructor(readonly db: FakeDb) {}
  async get(ref: FakeRef | FakeQuery) {
    if (this.writes.length > 0) throw new Error("Firestore read after write");
    if (ref instanceof FakeQuery) return ref.get();
    const data = this.db.docs.get(ref.path);
    return {exists: data !== undefined, data: () => structuredClone(data)};
  }
  create(ref: FakeRef, value: Doc) {
    this.writes.push(() => {
      if (this.db.docs.has(ref.path)) throw new Error("duplicate create");
      this.db.docs.set(ref.path, structuredClone(value));
    });
  }
  set(ref: FakeRef, value: Doc) {
    this.writes.push(() => this.db.docs.set(ref.path, structuredClone(value)));
  }
  commit() {
    for (const write of this.writes) write();
  }
}

const employee: SalesPrincipal = {uid: "admin-1", roles: ["admin"]};
const support: SalesPrincipal = {uid: "support-1", roles: ["support"]};
function fixture() {
  const db = new FakeDb();
  db.docs.set("organizers/org-1", {name: "Example Host", cityName: "Delhi"});
  const deps: SalesServiceDeps = {
    firestore: () => db as unknown as FirebaseFirestore.Firestore,
    now: () => new Date("2026-09-28T00:00:00.000Z"),
  };
  return {db, deps};
}
const create = {organizerId: "org-1", requestId: "req-create-0001"};

test("requires admin and canonical organizer", async () => {
  const {db, deps} = fixture();
  await assert.rejects(
    executeSalesAction(support, "hosts.create", create, deps),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied",
  );
  assert.equal(db.docs.size, 1);
  await assert.rejects(
    executeSalesAction(
      employee,
      "hosts.create",
      {...create, organizerId: "missing"},
      deps,
    ),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "not-found",
  );
});

test("import accounts for rows without public writes", async () => {
  const {db, deps} = fixture();
  const packet = {
    sourceId: "sheet-a",
    contentHash: "a".repeat(64),
    mappingVersion: "mapping-v1",
    rows: [
      {
        sourceRowId: "sheet-a:1",
        organizerId: "org-1",
        name: "Example Host",
        researchStatus: "qualified",
        originalScore: {model: "legacy", score: 72},
      },
      {
        sourceRowId: "sheet-a:1",
        organizerId: "org-1",
        name: "Example Host",
        researchStatus: "qualified",
      },
      {
        sourceRowId: "sheet-a:2",
        organizerId: null,
        name: "Unknown Host",
        researchStatus: "new",
      },
    ],
  };
  const preview = await executeSalesRead(
    employee,
    "imports.preview",
    packet,
    deps,
  );
  assert.deepEqual(preview.counts, {
    created: 1,
    matched: 0,
    duplicate: 1,
    unresolved: 1,
    rejected: 0,
  });
  assert.equal(preview.effectsApplied, false);
  const applied = await executeSalesAction(
    employee,
    "imports.apply",
    {
      ...packet,
      requestId: "req-import-0001",
      previewHash: preview.previewHash,
    },
    deps,
  );
  assert.equal((applied.counts as Doc).created, 1);
  assert.equal(
    db.docs.get("organizerSalesAccounts/org-1")?.researchStatus,
    "needs_research",
  );
  assert.equal(db.docs.get("organizers/org-1")?.name, "Example Host");
  const second = await executeSalesRead(
    employee,
    "imports.preview",
    packet,
    deps,
  );
  assert.equal((second.counts as Doc).duplicate, 2);
  assert.equal((second.counts as Doc).unresolved, 1);
});

test("import rejects state change after preview", async () => {
  const {db, deps} = fixture();
  const packet = {
    sourceId: "sheet-b",
    contentHash: "b".repeat(64),
    mappingVersion: "mapping-v1",
    rows: [
      {
        sourceRowId: "sheet-b:1",
        organizerId: "org-1",
        name: "Example Host",
        researchStatus: "new",
      },
    ],
  };
  const preview = await executeSalesRead(
    employee,
    "imports.preview",
    packet,
    deps,
  );
  await executeSalesAction(employee, "hosts.create", create, deps);
  await assert.rejects(
    executeSalesAction(
      employee,
      "imports.apply",
      {
        ...packet,
        requestId: "req-import-0002",
        previewHash: preview.previewHash,
      },
      deps,
    ),
    (error: unknown) => error instanceof HttpsError && error.code === "aborted",
  );
  assert.equal(
    [...db.docs.keys()].filter((key) => key.startsWith("salesImportJobs/"))
      .length,
    0,
  );
});

test("intent link creates private follow-up", async () => {
  const {db, deps} = fixture();
  db.docs.set("salesInboundIntents/intent-1", {
    schemaVersion: 1,
    classification: "sales_private",
    revision: 1,
    status: "needs_identity_review",
    organizerId: null,
    intentId: "intent-1",
    fullName: "Synthetic Person",
  });
  const linked = await executeSalesAction(
    employee,
    "intents.link",
    {
      intentId: "intent-1",
      organizerId: "org-1",
      requestId: "req-link-0001",
      expectedRevision: 1,
    },
    deps,
  );
  assert.equal((linked.intent as Doc).status, "linked");
  assert.equal((linked.task as Doc).kind, "research");
  assert.equal(db.docs.get("organizers/org-1")?.name, "Example Host");
  assert.equal(
    db.docs.get("organizerSalesAccounts/org-1")?.classification,
    "sales_private",
  );
  assert.equal(
    (
      await executeSalesAction(
        employee,
        "intents.link",
        {
          intentId: "intent-1",
          organizerId: "org-1",
          requestId: "req-link-0001",
          expectedRevision: 1,
        },
        deps,
      )
    ).receipt !== undefined,
    true,
  );
});

test("create is private, idempotent and strict", async () => {
  const {db, deps} = fixture();
  const first = await executeSalesAction(
    employee,
    "hosts.create",
    create,
    deps,
  );
  assert.equal((first.account as Doc).revision, 1);
  assert.equal(db.docs.get("organizers/org-1")?.name, "Example Host");
  assert.equal(
    db.docs.get("organizerSalesAccounts/org-1")?.classification,
    "sales_private",
  );
  const replay = await executeSalesAction(
    employee,
    "hosts.create",
    create,
    deps,
  );
  assert.deepEqual(replay, first);
  await assert.rejects(
    executeSalesAction(
      employee,
      "hosts.create",
      {...create, organizerId: "org-2"},
      deps,
    ),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "already-exists",
  );
  assert.equal(
    [...db.docs.keys()].filter((key) => key.startsWith("adminAuditLogs/"))
      .length,
    1,
  );
});

test("revision conflict and strict nested payload rejection", async () => {
  const {deps} = fixture();
  await executeSalesAction(employee, "hosts.create", create, deps);
  await assert.rejects(
    executeSalesAction(
      employee,
      "hosts.update",
      {
        organizerId: "org-1",
        requestId: "req-update-0001",
        expectedRevision: 0,
        patch: {summary: "Reviewed"},
      },
      deps,
    ),
    (error: unknown) => error instanceof HttpsError && error.code === "aborted",
  );
  await assert.rejects(
    executeSalesAction(
      employee,
      "hosts.update",
      {
        organizerId: "org-1",
        requestId: "req-update-0002",
        expectedRevision: 1,
        patch: {summary: "Reviewed", publicVisibility: true},
      },
      deps,
    ),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "invalid-argument",
  );
});

test("delegated replay cannot cross identity", async () => {
  const {deps} = fixture();
  const scoped: SalesPrincipal = {
    ...employee,
    clientId: "client-1",
    delegationId: "grant-1",
    organizerIds: ["org-1"],
    allowedActions: ["hosts.create"],
  };
  const delegatedDeps: SalesServiceDeps = {
    ...deps,
    authorizeInTransaction: async () => undefined,
    authorizeRead: async () => undefined,
  };
  await executeSalesAction(scoped, "hosts.create", create, delegatedDeps);
  await assert.rejects(
    executeSalesAction(
      {...scoped, delegationId: "grant-2"},
      "hosts.create",
      create,
      delegatedDeps,
    ),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied",
  );
  await assert.rejects(
    executeSalesAction(
      {...scoped, organizerIds: []},
      "hosts.create",
      create,
      delegatedDeps,
    ),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied",
  );
});

test("revoked delegation blocks replay and writes", async () => {
  const {db, deps} = fixture();
  const scoped: SalesPrincipal = {
    ...employee,
    clientId: "client-1",
    clientAuthUid: "service-1",
    delegationId: "grant-1",
    organizerIds: ["org-1"],
    allowedActions: ["hosts.create", "hosts.update"],
  };
  let active = true;
  const delegatedDeps: SalesServiceDeps = {
    ...deps,
    authorizeInTransaction: async () => {
      if (!active) {
        throw new HttpsError("permission-denied", "Delegation revoked.");
      }
    },
    authorizeRead: async () => undefined,
  };
  await executeSalesAction(scoped, "hosts.create", create, delegatedDeps);
  active = false;
  await assert.rejects(
    executeSalesAction(scoped, "hosts.create", create, delegatedDeps),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied",
  );
  await assert.rejects(
    executeSalesAction(
      scoped,
      "hosts.update",
      {
        organizerId: "org-1",
        requestId: "req-update-0003",
        expectedRevision: 1,
        patch: {summary: "Should not commit"},
      },
      delegatedDeps,
    ),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied",
  );
  assert.equal(db.docs.get("organizerSalesAccounts/org-1")?.revision, 1);
});

test("qualification uses private policy and independent sources", async () => {
  const {db, deps} = fixture();
  await executeSalesAction(employee, "hosts.create", create, deps);
  const rules = [
    {
      ruleId: "example-a",
      claimKey: "identity",
      sourceTypes: ["first_party"],
      confidence: ["high"],
      minimumCount: 1,
      distinctSignalIds: false,
      distinctSourceRoots: false,
      maxAgeDays: 30,
    },
    {
      ruleId: "example-b",
      claimKey: "operation",
      sourceTypes: ["first_party"],
      confidence: ["high"],
      minimumCount: 2,
      distinctSignalIds: true,
      distinctSourceRoots: true,
      maxAgeDays: 30,
    },
  ];
  const policyId = "synthetic-test-policy";
  const version = "v1";
  db.docs.set("salesSettings/qualificationPolicy", {
    schemaVersion: 1,
    classification: "sales_private",
    status: "active",
    policyId,
    version,
    rules,
    policyHash: qualificationPolicyHash({policyId, version, rules}),
  });
  const base = {
    organizerId: "org-1",
    sourceType: "first_party",
    observedAt: "2026-09-27T00:00:00.000Z",
    confidence: "high",
  };
  for (const [index, claimKey] of [
    "identity",
    "recurrence",
    "operation",
    "operation",
  ].entries()) {
    await executeSalesAction(
      employee,
      "evidence.add",
      {
        ...base,
        claimKey,
        requestId: `req-evidence-${index}`,
        sourceRef: index < 2 ? `source-${index}` : "same-source",
        ...(index >= 2 ? {signalId: `signal-${index}`} : {}),
      },
      deps,
    );
  }
  const qualify = {
    organizerId: "org-1",
    requestId: "req-qualify-1",
    expectedRevision: 1,
    patch: {researchStatus: "qualified"},
  };
  await assert.rejects(
    executeSalesAction(employee, "hosts.update", qualify, deps),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "failed-precondition",
  );
  await executeSalesAction(
    employee,
    "evidence.add",
    {
      ...base,
      claimKey: "operation",
      signalId: "signal-5",
      sourceRef: "new-source",
      requestId: "req-evidence-5",
    },
    deps,
  );
  const result = await executeSalesAction(
    employee,
    "hosts.update",
    qualify,
    deps,
  );
  assert.equal((result.account as Doc).researchStatus, "qualified");
  assert.equal(db.docs.get("organizerSalesAccounts/org-1")?.revision, 2);
});

test("contact read stays scoped and hides endpoints", async () => {
  const {db, deps} = fixture();
  db.docs.set("organizers/org-2", {name: "Other Host"});
  await executeSalesAction(employee, "hosts.create", create, deps);
  await executeSalesAction(
    employee,
    "hosts.create",
    {organizerId: "org-2", requestId: "req-create-0002"},
    deps,
  );
  const created = await executeSalesAction(
    employee,
    "contacts.upsert",
    {
      organizerId: "org-1",
      requestId: "req-contact-1",
      expectedRevision: 0,
      contact: {displayName: "Synthetic Contact"},
      relationship: {
        role: "owner",
        decisionInfluence: "decision_maker",
        primary: true,
        endpoints: [
          {
            kind: "email",
            value: "contact@example.test",
            verificationStatus: "unverified",
          },
        ],
      },
    },
    deps,
  );
  const contactId = (created.contact as Doc).contactId;
  await executeSalesAction(
    employee,
    "contacts.upsert",
    {
      organizerId: "org-2",
      requestId: "req-contact-2",
      expectedRevision: 0,
      contactId,
      linkExisting: true,
      contact: {displayName: "Synthetic Contact"},
      relationship: {
        role: "advisor",
        decisionInfluence: "influencer",
        primary: false,
        endpoints: [
          {kind: "phone", value: "5550100", verificationStatus: "unverified"},
        ],
      },
    },
    deps,
  );
  const scoped: SalesPrincipal = {
    ...employee,
    clientId: "client-1",
    clientAuthUid: "service-1",
    delegationId: "grant-1",
    organizerIds: ["org-1"],
    allowedActions: ["contacts.list"],
    readEndpoints: false,
  };
  const delegatedDeps: SalesServiceDeps = {
    ...deps,
    authorizeInTransaction: async () => undefined,
    authorizeRead: async () => undefined,
  };
  const response = await executeSalesRead(
    scoped,
    "contacts.list",
    {organizerId: "org-1"},
    delegatedDeps,
  );
  assert.equal((response.rows as Doc[]).length, 1);
  assert.equal(
    ((response.rows as Doc[])[0].relationship as Doc).endpoints,
    undefined,
  );
  await assert.rejects(
    executeSalesRead(
      scoped,
      "contacts.list",
      {organizerId: "org-2"},
      delegatedDeps,
    ),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied",
  );
});

test("account suppression blocks outbound tasks", async () => {
  const {db, deps} = fixture();
  await executeSalesAction(employee, "hosts.create", create, deps);
  const held = await executeSalesAction(
    employee,
    "accounts.setSuppression",
    {
      organizerId: "org-1",
      requestId: "req-hold-0001",
      expectedRevision: 1,
      status: "suppressed",
      reason: "Business opt-out recorded by employee",
    },
    deps,
  );
  assert.equal((held.account as Doc).suppressionStatus, "suppressed");
  await assert.rejects(
    executeSalesAction(
      employee,
      "tasks.upsert",
      {
        organizerId: "org-1",
        requestId: "req-task-0001",
        expectedRevision: 0,
        task: {
          kind: "follow_up",
          title: "Do not schedule",
          dueAt: null,
          ownerUid: "admin-1",
          status: "open",
        },
      },
      deps,
    ),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "failed-precondition",
  );
  assert.equal(
    [...db.docs.keys()].filter((key) =>
      key.startsWith("salesSuppressionDecisions/"),
    ).length,
    1,
  );
});

test("contact draft review needs linked evidence", async () => {
  const {db, deps} = fixture();
  await executeSalesAction(employee, "hosts.create", create, deps);
  const created = await executeSalesAction(
    employee,
    "contacts.upsert",
    {
      organizerId: "org-1",
      requestId: "req-contact-3",
      expectedRevision: 0,
      contact: {displayName: "Synthetic Contact"},
      relationship: {
        role: "operator",
        decisionInfluence: "operator",
        primary: true,
        endpoints: [
          {
            kind: "email",
            value: "safe@example.test",
            verificationStatus: "unverified",
          },
        ],
      },
    },
    deps,
  );
  const contactId = (created.contact as Doc).contactId as string;
  const evidence = await executeSalesAction(
    employee,
    "evidence.add",
    {
      organizerId: "org-1",
      contactId,
      requestId: "req-evidence-contact-1",
      claimKey: "identity",
      sourceType: "human_note",
      sourceRef: "synthetic:staff-review",
      observedAt: "2026-09-27T00:00:00Z",
      confidence: "medium",
    },
    deps,
  );
  const evidenceId = (evidence.evidence as Doc).evidenceId;
  await assert.rejects(
    executeSalesAction(
      employee,
      "contacts.setContactability",
      {
        organizerId: "org-1",
        contactId,
        requestId: "req-review-0001",
        expectedRevision: 1,
        status: "draft_reviewed",
        reason: "Reviewed for draft only",
        evidenceId: "evidence-missing",
      },
      deps,
    ),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "failed-precondition",
  );
  const review = await executeSalesAction(
    employee,
    "contacts.setContactability",
    {
      organizerId: "org-1",
      contactId,
      requestId: "req-review-0002",
      expectedRevision: 1,
      status: "draft_reviewed",
      reason: "Reviewed for draft only",
      evidenceId,
    },
    deps,
  );
  assert.equal((review.relationship as Doc).sendAuthority, false);
  const task = await executeSalesAction(
    employee,
    "tasks.upsert",
    {
      organizerId: "org-1",
      requestId: "req-task-0002",
      expectedRevision: 0,
      task: {
        kind: "follow_up",
        title: "Prepare a manual draft",
        dueAt: null,
        ownerUid: "admin-1",
        status: "open",
        contactId,
      },
    },
    deps,
  );
  assert.equal((task.task as Doc).contactId, contactId);
  // Explicit removal must be checked as the final persisted value, rather
  // than validating the prior contact and then overwriting it with null.
  await assert.rejects(executeSalesAction(employee, "tasks.upsert", {
    organizerId: "org-1",
    taskId: (task.task as Doc).taskId,
    requestId: "req-task-remove-contact",
    expectedRevision: 1,
    task: {
      kind: "follow_up", title: "Keep reviewed contact", dueAt: null,
      ownerUid: "admin-1", status: "open", contactId: null,
    },
  }, deps), (error: unknown) =>
    error instanceof HttpsError && error.code === "failed-precondition");
  const storedTask = db.docs.get(`salesTasks/${(task.task as Doc).taskId}`);
  assert.equal(storedTask?.contactId, contactId);
  const retained = await executeSalesAction(employee, "tasks.upsert", {
    organizerId: "org-1",
    taskId: (task.task as Doc).taskId,
    requestId: "req-task-retain-contact",
    expectedRevision: 1,
    task: {
      kind: "follow_up", title: "Keep reviewed contact", dueAt: null,
      ownerUid: "admin-1", status: "open",
    },
  }, deps);
  assert.equal((retained.task as Doc).contactId, contactId);

  await executeSalesAction(
    employee,
    "contacts.setContactability",
    {
      organizerId: "org-1",
      contactId,
      requestId: "req-review-0003",
      expectedRevision: 2,
      status: "suppressed",
      reason: "Opted out",
    },
    deps,
  );
  await assert.rejects(
    executeSalesAction(
      employee,
      "tasks.upsert",
      {
        organizerId: "org-1",
        taskId: (task.task as Doc).taskId,
        requestId: "req-task-0003",
        expectedRevision: 2,
        task: {
          kind: "follow_up",
          title: "Blocked after opt-out",
          dueAt: null,
          ownerUid: "admin-1",
          status: "open",
          contactId,
        },
      },
      deps,
    ),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "failed-precondition",
  );
  assert.equal(db.docs.get("organizers/org-1")?.name, "Example Host");
});

test("manual sent-elsewhere log has no provider effect", async () => {
  const {deps} = fixture();
  await executeSalesAction(employee, "hosts.create", create, deps);
  await assert.rejects(
    executeSalesAction(
      employee,
      "activities.log",
      {
        organizerId: "org-1",
        requestId: "req-manual-0001",
        type: "outreach_sent_manual",
        occurredAt: "2026-09-27T00:00:00Z",
        note: "Sent separately",
        channel: "email",
      },
      deps,
    ),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "invalid-argument",
  );
  const logged = await executeSalesAction(
    employee,
    "activities.log",
    {
      organizerId: "org-1",
      requestId: "req-manual-0002",
      type: "outreach_sent_manual",
      occurredAt: "2026-09-27T00:00:00Z",
      note: "Sent separately",
      channel: "email",
      attestation: "sent_elsewhere_by_actor",
    },
    deps,
  );
  assert.equal((logged.activity as Doc).outcome, "actor_attested_sent");
  assert.equal((logged.activity as Doc).providerConfirmed, false);
});

test("assistant suggestions require review before qualification", async () => {
  const {db, deps} = fixture();
  await executeSalesAction(employee, "hosts.create", create, deps);
  const rules = [{ruleId: "synthetic-identity", claimKey: "identity",
    sourceTypes: ["first_party"], confidence: ["high"], minimumCount: 1,
    distinctSignalIds: false, distinctSourceRoots: false, maxAgeDays: 30}];
  const policy = {policyId: "synthetic-policy", version: "v1", rules};
  db.docs.set("salesSettings/qualificationPolicy", {...policy,
    schemaVersion: 1, classification: "sales_private", status: "active",
    policyHash: qualificationPolicyHash(policy)});
  const assistant: SalesPrincipal = {...employee, clientId: "helper",
    clientAuthUid: "service-1", delegationId: "grant-1",
    organizerIds: ["org-1"], allowedActions: ["evidence.propose",
      "evidence.add", "evidence.reviewProposal"]};
  const delegated = {...deps, authorizeRead: async () => undefined,
    authorizeInTransaction: async () => undefined};
  const input = {organizerId: "org-1", requestId: "proposal-request-1",
    claimKey: "identity", sourceType: "first_party",
    sourceRef: "https://example.test/about", observedAt: "2026-09-27T00:00:00Z",
    confidence: "high", excerpt: "Synthetic source observation"};
  const result = await executeSalesAction(assistant,
    "evidence.propose", input, delegated);
  const proposal = result.proposal as Doc;
  assert.equal(proposal.status, "pending");
  assert.equal(proposal.reviewerUid, null);
  assert.equal(proposal.clientId, "helper");
  assert.equal([...db.docs.keys()].filter((k) => k.startsWith("salesEvidence/"))
    .length, 0);
  assert.deepEqual(await executeSalesAction(assistant,
    "evidence.propose", input, delegated), result);
  await assert.rejects(executeSalesAction(assistant, "evidence.propose",
    {...input, organizerId: "org-2"}, delegated), /outside Sales scope/);
  await assert.rejects(executeSalesAction(assistant, "evidence.add",
    {...input, requestId: "direct-review-1"}, delegated), /employee session/);
  const qualify = {organizerId: "org-1", requestId: "qualify-proposal-1",
    expectedRevision: 1, patch: {researchStatus: "qualified"}};
  await assert.rejects(executeSalesAction(employee, "hosts.update", qualify,
    deps), /evidence is incomplete/);
  const review = {organizerId: "org-1", requestId: "review-proposal-1",
    proposalId: proposal.proposalId, expectedRevision: 1, decision: "accept",
    reason: "Checked source and dates"};
  await assert.rejects(executeSalesAction(assistant, "evidence.reviewProposal",
    review, delegated), /employee session/);
  await assert.rejects(executeSalesAction(employee, "evidence.reviewProposal",
    {...review, organizerId: "org-2"}, deps), /not found/);
  const accepted = await executeSalesAction(employee, "evidence.reviewProposal",
    review, deps);
  assert.equal((accepted.proposal as Doc).status, "accepted");
  assert.equal((accepted.evidence as Doc).reviewerUid, employee.uid);
  assert.deepEqual(await executeSalesAction(employee, "evidence.reviewProposal",
    review, deps), accepted);
  await assert.rejects(executeSalesAction(employee, "evidence.reviewProposal",
    {...review, requestId: "review-proposal-2"}, deps), /changed since review/);
  const qualified = await executeSalesAction(employee, "hosts.update", qualify,
    deps);
  assert.equal((qualified.account as Doc).researchStatus, "qualified");
  const ajv = new Ajv({strict: false});
  addFormats(ajv);
  for (const [collection, schema] of [
    ["salesEvidenceProposals", "sales_evidence_proposals"],
    ["salesEvidence", "sales_evidence"],
    ["salesActionReceipts", "sales_action_receipts"],
  ]) {
    const validate = ajv.compile(JSON.parse(readFileSync(path.resolve(__dirname,
      `../../../../contracts/firestore/${schema}.schema.json`), "utf8")));
    for (const [key, value] of db.docs) {
      if (key.startsWith(`${collection}/`)) {
        assert.ok(validate(value), ajv.errorsText(validate.errors));
      }
    }
  }
});

test("expired suggestions fail and rejection stays private", async () => {
  const {db, deps} = fixture();
  await executeSalesAction(employee, "hosts.create", create, deps);
  const proposed = await executeSalesAction(employee, "evidence.propose", {
    organizerId: "org-1", requestId: "expired-proposal-1", claimKey: "other",
    sourceType: "human_note", sourceRef: "synthetic:old-note",
    observedAt: "2026-09-20T00:00:00Z", validThrough: "2026-09-21T00:00:00Z",
    confidence: "low",
  }, deps);
  const review = {organizerId: "org-1", proposalId:
    (proposed.proposal as Doc).proposalId, requestId: "expired-review-1",
  expectedRevision: 1, decision: "accept", reason: "Reviewed"};
  await assert.rejects(executeSalesAction(employee, "evidence.reviewProposal",
    review, deps), /expired/);
  const rejected = await executeSalesAction(employee, "evidence.reviewProposal",
    {...review, decision: "reject"}, deps);
  assert.equal((rejected.proposal as Doc).status, "rejected");
  assert.equal(rejected.evidence, null);
  assert.equal([...db.docs.keys()].filter((k) => k.startsWith("salesEvidence/"))
    .length, 0);
});
