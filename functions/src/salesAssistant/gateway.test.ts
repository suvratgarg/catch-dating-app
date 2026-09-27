import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import {test} from "node:test";
import type {Request, Response} from "express";
import {HttpsError} from "firebase-functions/v2/https";
import {executeSalesRead} from "../admin/sales/service";
import {AssistantGatewayDeps, createSalesAssistantGateway} from "./gateway";

const NOW = new Date("2026-09-28T10:00:00.000Z");

class MemoryDb {
  readonly docs = new Map<string, Record<string, unknown>>();
  collection(name: string) {
    return {doc: (id: string) => {
      const path = `${name}/${id}`;
      return {
        path, id,
        get: async () => ({exists: this.docs.has(path),
          data: () => this.docs.get(path)}),
        set: async (value: Record<string, unknown>) => {
          this.docs.set(path, value);
        },
        create: async (value: Record<string, unknown>) => {
          if (this.docs.has(path)) throw new Error("duplicate");
          this.docs.set(path, value);
        },
        update: async (value: Record<string, unknown>) => {
          this.docs.set(path, {...this.docs.get(path), ...value});
        },
      };
    }};
  }
  async runTransaction<T>(callback: (tx: {
    get(ref: {path: string}): Promise<{exists: boolean;
      data(): Record<string, unknown> | undefined}>;
    set(ref: {path: string}, value: Record<string, unknown>): void;
    create(ref: {path: string}, value: Record<string, unknown>): void;
    update(ref: {path: string}, value: Record<string, unknown>): void;
  }) => Promise<T>): Promise<T> {
    const pending: Array<[string, Record<string, unknown>]> = [];
    const result = await callback({
      get: async (ref) => ({exists: this.docs.has(ref.path),
        data: () => this.docs.get(ref.path)}),
      set: (ref, value) => pending.push([ref.path, value]),
      create: (ref, value) => {
        if (this.docs.has(ref.path)) throw new Error("duplicate");
        pending.push([ref.path, value]);
      },
      update: (ref, value) => pending.push([ref.path,
        {...this.docs.get(ref.path), ...value}]),
    });
    pending.forEach(([path, value]) => this.docs.set(path, value));
    return result;
  }
}

function fixture() {
  const db = new MemoryDb();
  db.docs.set("assistantClients/client-1", {
    active: true, authUid: "client-uid",
  });
  db.docs.set("assistantDelegations/delegation-1", {
    actorUid: "employee-uid", clientId: "client-1",
    allowedActions: ["hosts.get", "fields.setValue"],
    organizerIds: ["host-one"], fieldIds: ["sales.demo_language"],
    expiresAt: "2026-09-29T10:00:00.000Z", revoked: false,
    maxRequestsPerMinute: 2, maxRequestsPerDay: 10,
  });
  const dispatched: Array<{action: string; uid: string}> = [];
  const deps: AssistantGatewayDeps = {
    db: db as unknown as FirebaseFirestore.Firestore,
    verifyIdToken: async (value) => ({uid: value === "c".repeat(32) ?
      "client-uid" : value === "o".repeat(32) ?
        "owner-uid" : "employee-uid"}),
    getUser: async (uid) => ({disabled: false, customClaims:
      uid === "employee-uid" ? {admin: true} :
        uid === "owner-uid" ? {adminOwner: true} : {}}),
    executeRead: async (_db, principal, action) => {
      dispatched.push({action, uid: principal.uid});
      return {organizerId: "host-one"};
    },
    executeAction: async (_db, principal, action) => {
      dispatched.push({action, uid: principal.uid});
      return {receiptId: "receipt-1"};
    },
    now: () => NOW,
  };
  return {db, deps, dispatched};
}

function request(path: string, body: Record<string, unknown>,
  headers: Record<string, string> = {}): Request {
  return {
    method: "POST", path, body,
    headers: {
      "authorization": `Bearer ${"c".repeat(32)}`,
      "x-assistant-client-id": "client-1",
      "x-assistant-delegation-id": "delegation-1",
      ...headers,
    },
    is: () => "application/json",
  } as unknown as Request;
}

function ownerRequest(path: string, body: Record<string, unknown>): Request {
  const req = request(path, body,
    {authorization: `Bearer ${"o".repeat(32)}`});
  if (path.startsWith("/v1/clients/")) req.method = "PUT";
  return req;
}

function auditCount(db: MemoryDb): number {
  return [...db.docs.keys()].filter((path) =>
    path.startsWith("adminAuditLogs/assistant_")).length;
}

async function call(deps: AssistantGatewayDeps, req: Request) {
  let status = 0;
  let body: Record<string, unknown> = {};
  const res = {
    set: () => res,
    status: (value: number) => {
      status = value; return res;
    },
    json: (value: Record<string, unknown>) => {
      body = value; return res;
    },
  } as unknown as Response;
  await createSalesAssistantGateway(deps)(req, res);
  return {status, body};
}

test("scoped employee and bound client use the sales service", async () => {
  const {deps, dispatched} = fixture();
  const result = await call(deps, request("/v1/actions/hosts.get",
    {organizerId: "host-one"}));
  assert.equal(result.status, 200);
  assert.deepEqual(dispatched, [{action: "hosts.get", uid: "employee-uid"}]);
});

test("revoked, expired and mismatched client authority fail", async () => {
  const {db, deps, dispatched} = fixture();
  const delegation = db.docs.get("assistantDelegations/delegation-1")!;
  delegation.revoked = true;
  assert.equal((await call(deps, request("/v1/actions/hosts.get",
    {organizerId: "host-one"}))).status, 403);
  delegation.revoked = false;
  delegation.expiresAt = "2026-09-27T10:00:00.000Z";
  assert.equal((await call(deps, request("/v1/actions/hosts.get",
    {organizerId: "host-one"}))).status, 403);
  delegation.expiresAt = "2026-09-29T10:00:00.000Z";
  db.docs.get("assistantClients/client-1")!.authUid = "wrong-client";
  assert.equal((await call(deps, request("/v1/actions/hosts.get",
    {organizerId: "host-one"}))).status, 403);
  assert.equal(dispatched.length, 0);
});

test("cross-host, undelegated action and field write are denied", async () => {
  const {deps, dispatched} = fixture();
  const attempts = [
    request("/v1/actions/hosts.get", {organizerId: "host-two"}),
    request("/v1/actions/activities.log", {organizerId: "host-one",
      requestId: "request-123"}),
    request("/v1/actions/fields.setValue", {organizerId: "host-one",
      requestId: "request-123", fieldId: "sales.secret_field", value: "x"}),
  ];
  for (const attempt of attempts) {
    assert.equal((await call(deps, attempt)).status, 403);
  }
  assert.equal(dispatched.length, 0);
});

test("namespaced private field write reaches the shared service", async () => {
  const {deps, dispatched} = fixture();
  const result = await call(deps, request("/v1/actions/fields.setValue", {
    organizerId: "host-one", requestId: "request-123",
    expectedRevision: 1, fieldId: "sales.demo_language", value: "Hindi",
  }));
  assert.equal(result.status, 200);
  assert.deepEqual(dispatched, [{action: "fields.setValue",
    uid: "employee-uid"}]);
});

test("delegation budget stops requests before dispatch", async () => {
  const {deps, dispatched} = fixture();
  const req = request("/v1/actions/hosts.get", {organizerId: "host-one"});
  assert.equal((await call(deps, req)).status, 200);
  assert.equal((await call(deps, req)).status, 200);
  assert.equal((await call(deps, req)).status, 429);
  assert.equal(dispatched.length, 2);
});

test("current employee role loss denies valid delegation", async () => {
  const {deps, dispatched} = fixture();
  deps.getUser = async () => ({disabled: false, customClaims: {}});
  assert.equal((await call(deps, request("/v1/actions/hosts.get",
    {organizerId: "host-one"}))).status, 403);
  assert.equal(dispatched.length, 0);
});

test("client gaining an admin role loses delegated access", async () => {
  const {deps, dispatched} = fixture();
  const getUser = deps.getUser;
  deps.getUser = async (uid) => uid === "client-uid" ?
    {disabled: false, customClaims: {admin: true}} : getUser(uid);
  assert.equal((await call(deps, request("/v1/actions/hosts.get",
    {organizerId: "host-one"}))).status, 403);
  assert.equal(dispatched.length, 0);
});

test("scope narrowed during a read prevents its response", async () => {
  for (const changedScope of ["organizerIds", "fieldIds"] as const) {
    const {db, deps} = fixture();
    deps.executeRead = async () => {
      db.docs.get("assistantDelegations/delegation-1")![changedScope] =
        changedScope === "organizerIds" ? ["host-two"] : [];
      return {rows: [{organizerId: "host-one"}]};
    };
    const result = await call(deps, request("/v1/actions/hosts.get",
      {organizerId: "host-one"}));
    assert.equal(result.status, 403);
  }
});

test("opportunity assignee is accepted by gateway domain routing", async () => {
  const {db, deps, dispatched} = fixture();
  db.docs.get("assistantDelegations/delegation-1")!.allowedActions =
    ["opportunities.upsert"];
  const result = await call(deps,
    request("/v1/actions/opportunities.upsert", {
      organizerId: "host-one", requestId: "request-123",
      expectedRevision: 0,
      fields: {motion: "pilot", stage: "new_enquiry",
        ownerUid: "employee-uid", nextStep: null, nextStepAt: null},
    }));
  assert.equal(result.status, 200);
  assert.deepEqual(dispatched, [{action: "opportunities.upsert",
    uid: "employee-uid"}]);
});

test("UTF-8 byte limit applies before service dispatch", async () => {
  const {deps, dispatched} = fixture();
  const result = await call(deps, request("/v1/actions/hosts.get", {
    organizerId: "host-one", padding: "🙂".repeat(5000),
  }));
  assert.equal(result.status, 413);
  assert.equal(dispatched.length, 0);
});

test("revoked token and disabled client registry deny access", async () => {
  const {db, deps, dispatched} = fixture();
  const originalVerify = deps.verifyIdToken;
  deps.verifyIdToken = async (value) => {
    if (value === "c".repeat(32)) throw new Error("revoked");
    return originalVerify(value);
  };
  const req = request("/v1/actions/hosts.get",
    {organizerId: "host-one"});
  assert.equal((await call(deps, req)).status, 401);
  deps.verifyIdToken = originalVerify;
  db.docs.get("assistantClients/client-1")!.active = false;
  assert.equal((await call(deps, req)).status, 403);
  assert.equal(dispatched.length, 0);
});

test("revocation after authentication prevents a mutation commit", async () => {
  const {db, deps, dispatched} = fixture();
  deps.executeAction = async (firestore, principal, action, _payload, _now,
    authorization) => {
    db.docs.get("assistantDelegations/delegation-1")!.revoked = true;
    await firestore.runTransaction(async (tx) => {
      await authorization.authorizeInTransaction(
        tx, firestore, principal, action, "host-one", "sales.demo_language");
    });
    dispatched.push({action, uid: principal.uid});
    return {receiptId: "should-not-exist"};
  };
  const result = await call(deps, request("/v1/actions/fields.setValue", {
    organizerId: "host-one", requestId: "request-123",
    expectedRevision: 1, fieldId: "sales.demo_language", value: "Hindi",
  }));
  assert.equal(result.status, 403);
  assert.equal(dispatched.length, 0);
});

test("receipt lookup requires its own delegated action", async () => {
  const {deps, dispatched} = fixture();
  const result = await call(deps, request("/v1/actions/receipts.get",
    {requestId: "request-123"}));
  assert.equal(result.status, 403);
  assert.equal(dispatched.length, 0);
});

test("actual sales receipt read enforces client and field scope", async () => {
  const {db, deps} = fixture();
  const delegation = db.docs.get("assistantDelegations/delegation-1")!;
  delegation.allowedActions = ["receipts.get", "fields.setValue"];
  delegation.maxRequestsPerMinute = 10;
  const requestId = "request-123";
  const hash = createHash("sha256")
    .update(`employee-uid\u0000${requestId}`).digest("hex");
  const receiptPath = `salesActionReceipts/${hash}`;
  db.docs.set(receiptPath, {
    actorUid: "employee-uid", clientId: "client-1",
    clientAuthUid: "client-uid", delegationId: "delegation-1",
    organizerId: "host-one", action: "fields.setValue",
    result: {fieldId: "sales.demo_language", value: "Hindi"},
  });
  deps.executeRead = (_db, principal, action, payload, authorization) =>
    executeSalesRead(principal, action as "receipts.get", payload, {
      firestore: () => _db, now: () => NOW, ...authorization,
    });
  const req = request("/v1/actions/receipts.get", {requestId});
  assert.equal((await call(deps, req)).status, 200);
  delegation.fieldIds = [];
  assert.equal((await call(deps, req)).status, 403);
  delegation.fieldIds = ["sales.demo_language"];
  db.docs.get(receiptPath)!.clientAuthUid = "other-client";
  assert.equal((await call(deps, req)).status, 403);
});

test("business errors retain their HTTP meaning", async () => {
  for (const [code, status] of [
    ["invalid-argument", 400], ["aborted", 409],
    ["permission-denied", 403],
  ] as const) {
    const {deps} = fixture();
    deps.executeRead = async () => {
      throw new HttpsError(code, "Domain rejected request.");
    };
    const result = await call(deps, request("/v1/actions/hosts.get",
      {organizerId: "host-one"}));
    assert.equal(result.status, status);
  }
});

test("only current owner may issue and revoke delegation", async () => {
  const {db, deps, dispatched} = fixture();
  const issue = request("/v1/delegations", {
    requestId: "request-issue-2", expectedRevision: 0,
    delegationId: "delegation-2", actorUid: "employee-uid",
    clientId: "client-1", organizerIds: ["host-one"],
    allowedActions: ["hosts.get"], expiresAt: "2026-09-29T10:00:00.000Z",
    maxRequestsPerMinute: 2, maxRequestsPerDay: 10,
  });
  assert.equal((await call(deps, issue)).status, 403);
  issue.headers.authorization = `Bearer ${"o".repeat(32)}`;
  const issued = await call(deps, issue);
  assert.equal(issued.status, 200, JSON.stringify(issued.body));
  assert.equal(db.docs.get("assistantDelegations/delegation-2")?.issuedByUid,
    "owner-uid");
  const use = request("/v1/actions/hosts.get", {organizerId: "host-one"},
    {"x-assistant-delegation-id": "delegation-2"});
  const used = await call(deps, use);
  assert.equal(used.status, 200, JSON.stringify(used.body));
  const revoke = request("/v1/delegations/delegation-2/revoke",
    {requestId: "request-revoke-2", expectedRevision: 1},
    {authorization: `Bearer ${"o".repeat(32)}`});
  assert.equal((await call(deps, revoke)).status, 200);
  assert.equal((await call(deps, use)).status, 403);
  assert.equal(dispatched.length, 1);
});

test("delayed client enable retry cannot undo a later disable", async () => {
  const {db, deps} = fixture();
  const enable = ownerRequest("/v1/clients/client-2", {
    requestId: "request-enable-2", expectedRevision: 0,
    authUid: "client-uid", active: true,
  });
  const first = await call(deps, enable);
  assert.equal(first.status, 200);
  const disable = await call(deps,
    ownerRequest("/v1/clients/client-2", {
      requestId: "request-disable-2", expectedRevision: 1,
      authUid: "client-uid", active: false,
    }));
  assert.equal(disable.status, 200);
  const retried = await call(deps, enable);
  assert.deepEqual(retried.body, first.body);
  assert.equal(db.docs.get("assistantClients/client-2")?.active, false);
  assert.equal(db.docs.get("assistantClients/client-2")?.revision, 2);
  assert.equal(auditCount(db), 2);
  const stale = await call(deps,
    ownerRequest("/v1/clients/client-2", {
      requestId: "request-stale-2", expectedRevision: 1,
      authUid: "client-uid", active: true,
    }));
  assert.equal(stale.status, 409);
  assert.equal(auditCount(db), 2);
});

test("uncertain issue replays after revoke without reactivation", async () => {
  const {db, deps} = fixture();
  const issue = ownerRequest("/v1/delegations", {
    requestId: "request-issue-3", expectedRevision: 0,
    delegationId: "delegation-3", actorUid: "employee-uid",
    clientId: "client-1", allowedActions: ["hosts.get"],
    organizerIds: ["host-one"], expiresAt: "2026-09-29T10:00:00.000Z",
    maxRequestsPerMinute: 2, maxRequestsPerDay: 10,
  });
  const first = await call(deps, issue);
  assert.equal(first.status, 200);
  const revoke = ownerRequest("/v1/delegations/delegation-3/revoke", {
    requestId: "request-revoke-3", expectedRevision: 1,
  });
  const revoked = await call(deps, revoke);
  assert.equal(revoked.status, 200);
  deps.now = () => new Date("2026-10-02T10:00:00.000Z");
  const replayIssue = await call(deps, issue);
  assert.deepEqual(replayIssue.body, first.body);
  assert.equal(db.docs.get("assistantDelegations/delegation-3")?.revoked,
    true);
  assert.equal(db.docs.get("assistantDelegations/delegation-3")?.revision,
    2);
  const replayRevoke = await call(deps, revoke);
  assert.deepEqual(replayRevoke.body, revoked.body);
  assert.equal(db.docs.get("assistantDelegations/delegation-3")?.revokedAt,
    (revoked.body.result as Record<string, unknown>).revokedAt);
  assert.equal(auditCount(db), 2);
});

test("management request id binds target and material", async () => {
  const {db, deps} = fixture();
  const first = ownerRequest("/v1/clients/client-3", {
    requestId: "request-register-3", expectedRevision: 0,
    authUid: "client-uid", active: true,
  });
  assert.equal((await call(deps, first)).status, 200);
  const changed = ownerRequest("/v1/clients/client-3", {
    requestId: "request-register-3", expectedRevision: 0,
    authUid: "client-uid", active: false,
  });
  assert.equal((await call(deps, changed)).status, 409);
  const otherTarget = ownerRequest("/v1/clients/client-4", {
    requestId: "request-register-3", expectedRevision: 0,
    authUid: "client-uid", active: true,
  });
  assert.equal((await call(deps, otherTarget)).status, 409);
  assert.equal(db.docs.has("assistantClients/client-4"), false);
  assert.equal(auditCount(db), 1);
});

test("owner role loss denies management receipt replay", async () => {
  const {deps} = fixture();
  const command = ownerRequest("/v1/clients/client-5", {
    requestId: "request-register-5", expectedRevision: 0,
    authUid: "client-uid", active: true,
  });
  assert.equal((await call(deps, command)).status, 200);
  const original = deps.getUser;
  deps.getUser = async (uid) => uid === "owner-uid" ?
    {disabled: false, customClaims: {}} : original(uid);
  assert.equal((await call(deps, command)).status, 403);
});

test("owner can read exact connection state and own receipt", async () => {
  const {deps} = fixture();
  const command = ownerRequest("/v1/clients/client-6", {
    requestId: "request-register-6", expectedRevision: 0,
    authUid: "client-uid", active: true,
  });
  assert.equal((await call(deps, command)).status, 200);
  const clientRead = ownerRequest("/v1/clients/client-6", {});
  clientRead.method = "GET";
  const client = await call(deps, clientRead);
  assert.equal(client.status, 200);
  assert.equal((client.body.result as Record<string, unknown>).revision, 1);
  const receiptRead = ownerRequest(
    "/v1/management/receipts/request-register-6", {});
  receiptRead.method = "GET";
  const receipt = await call(deps, receiptRead);
  assert.equal(receipt.status, 200);
  assert.equal((receipt.body.result as Record<string, unknown>).action,
    "assistant.clients.set");
  const other = request("/v1/management/receipts/request-register-6", {},
    {authorization: `Bearer ${"e".repeat(32)}`});
  other.method = "GET";
  assert.equal((await call(deps, other)).status, 403);
});
