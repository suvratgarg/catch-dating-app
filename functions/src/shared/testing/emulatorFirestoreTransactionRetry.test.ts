import assert from "node:assert/strict";
import {randomUUID} from "node:crypto";
import {Readable} from "node:stream";
import test, {TestContext} from "node:test";
import {deleteApp, initializeApp} from "firebase-admin/app";
import type {Transaction} from "firebase-admin/firestore";
import type {OrganizerDocument} from "../generated/firestoreAdminTypes";
import {isOrganizerManager} from "../organizerHosts";
import {getEmulatorFirestore} from "./emulatorFirestore";

interface RpcRequest {
  documents?: string[];
  newTransaction?: {readWrite?: {retryTransaction?: Uint8Array}};
  transaction?: Uint8Array;
  writes?: Array<{
    update?: {name: string; fields: Record<string, unknown>};
    currentDocument?: {exists?: boolean};
  }>;
}

/** Test-only injection at SDK RPC funnels. Transaction, DocumentReader,
 * WriteBatch, backoff, callback replay and authorization remain real.
 * This does not exercise the GAX streaming retry implementation or a server.
 */
interface RpcTransport {
  requestStream(method: string, bidirectional: boolean,
    request: RpcRequest): Promise<Readable>;
  request(method: string, request: RpcRequest): Promise<unknown>;
}

async function retryProbe(t: TestContext, revoke: boolean) {
  const originalHost = process.env.FIRESTORE_EMULATOR_HOST;
  process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:65534";
  t.after(() => {
    if (originalHost === undefined) delete process.env.FIRESTORE_EMULATOR_HOST;
    else process.env.FIRESTORE_EMULATOR_HOST = originalHost;
  });
  const app = initializeApp({projectId: "demo-catch-offline-transaction"},
    "offline-transaction-" + randomUUID());
  t.after(async () => deleteApp(app));
  const db = getEmulatorFirestore(app);
  const runner = db.runTransaction;
  const transport = db as unknown as RpcTransport;
  const authority = db.doc("organizers/example");
  const item = db.doc("workItems/example");
  const receipt = db.doc("receipts/example");
  const documentRoot = "projects/" + app.options.projectId +
    "/databases/(default)/documents/";
  const authorityName = documentRoot + authority.path;
  const itemName = documentRoot + item.path;
  const receiptName = documentRoot + receipt.path;
  const firstToken = Buffer.from("offline-attempt-A");
  const secondToken = Buffer.from("offline-attempt-B");
  const starts: RpcRequest[] = [];
  const sourceTokens: Uint8Array[] = [];
  const rollbacks: Uint8Array[] = [];
  const commits: RpcRequest[] = [];
  const wrappers: Transaction[] = [];
  const checks: Array<{revision: number; allowed: boolean}> = [];
  const clock = {seconds: 1800000000, nanos: 0};
  let authorityRevision = 1;
  let injectedAborts = 0;
  const authorizationDenied = new Error("Current organizer authority denied");
  const document = (name: string, fields: Record<string, unknown>,
    transaction?: Uint8Array) => Readable.from([{
    found: {name, fields, createTime: clock, updateTime: clock},
    readTime: clock, transaction,
  }], {objectMode: true});

  t.mock.method(transport, "requestStream", async (method: string,
    bidirectional: boolean, request: RpcRequest) => {
    assert.equal(method, "batchGetDocuments");
    assert.equal(bidirectional, false);
    assert.equal(request.documents?.length, 1);
    if (request.documents![0] === authorityName) {
      starts.push(request);
      assert.ok(request.newTransaction?.readWrite);
      assert.equal(request.transaction, undefined);
      const token = authorityRevision === 1 ? firstToken : secondToken;
      return document(authorityName, {
        ownerUserId: {stringValue: authorityRevision === 1 ? "actor" : "other"},
        hostUserId: {nullValue: 0},
        hostUserIds: {arrayValue: {values:
          authorityRevision === 2 && !revoke ? [{stringValue: "actor"}] : []}},
        authorityRevision: {integerValue: String(authorityRevision)},
        // A stale display snapshot cannot replace revoked canonical IDs.
        hostProfiles: {arrayValue: {values: [{mapValue: {fields: {
          uid: {stringValue: "actor"},
        }}}]}},
      }, token);
    }
    assert.equal(request.documents![0], itemName);
    assert.ok(request.transaction);
    assert.equal(request.newTransaction, undefined);
    sourceTokens.push(request.transaction);
    if (injectedAborts === 0) {
      assert.deepEqual(request.transaction, firstToken);
      injectedAborts++;
      authorityRevision = 2;
      throw Object.assign(new Error("Synthetic transaction lock timeout."),
        {code: 10});
    }
    assert.deepEqual(request.transaction, secondToken);
    return document(itemName, {count: {integerValue: "7"}});
  });

  t.mock.method(transport, "request", async (method: string,
    request: RpcRequest) => {
    if (method === "rollback") {
      assert.ok(request.transaction);
      rollbacks.push(request.transaction);
      return {};
    }
    assert.equal(method, "commit");
    assert.deepEqual(request.transaction, secondToken);
    assert.equal(request.writes?.length, 2);
    commits.push(request);
    return {commitTime: clock,
      writeResults: [{updateTime: clock}, {updateTime: clock}]};
  });

  const work = () => db.runTransaction(async (transaction) => {
    wrappers.push(transaction);
    const current = await transaction.get(authority);
    const allowed = isOrganizerManager(current.data() as OrganizerDocument,
      "actor");
    const revision = current.get("authorityRevision") as number;
    checks.push({revision, allowed});
    if (!allowed) throw authorizationDenied;
    const source = await transaction.get(item);
    transaction.update(item, {count: source.get("count") + 1,
      authorityRevision: revision});
    transaction.create(receipt, {authorityRevision: revision});
    return revision;
  }, {maxAttempts: 2});

  if (revoke) {
    await assert.rejects(work(), (error) => error === authorizationDenied);
  } else {
    assert.equal(await work(), 2);
  }
  assert.equal(db.runTransaction, runner);
  assert.equal(injectedAborts, 1);
  assert.equal(wrappers.length, 2);
  // The SDK reuses its wrapper, but starts a new server transaction attempt.
  assert.equal(wrappers[0], wrappers[1]);
  assert.equal(starts.length, 2);
  assert.deepEqual(starts[0].newTransaction, {readWrite: {}});
  assert.deepEqual(starts[1].newTransaction,
    {readWrite: {retryTransaction: firstToken}});
  assert.notDeepEqual(firstToken, secondToken);
  assert.deepEqual(checks, [{revision: 1, allowed: true},
    {revision: 2, allowed: !revoke}]);

  if (revoke) {
    assert.deepEqual(sourceTokens, [firstToken]);
    assert.deepEqual(rollbacks, [firstToken, secondToken]);
    assert.equal(commits.length, 0);
  } else {
    assert.deepEqual(sourceTokens, [firstToken, secondToken]);
    assert.deepEqual(rollbacks, [firstToken]);
    assert.equal(commits.length, 1);
    const writes = commits[0].writes!;
    assert.deepEqual(writes.map((write) => write.update?.name),
      [itemName, receiptName]);
    for (const write of writes) {
      const value = write.update!.fields.authorityRevision as
        {integerValue: string | number};
      assert.equal(String(value.integerValue), "2");
    }
    assert.deepEqual(writes[1].currentDocument, {exists: false});
  }
  t.diagnostic(JSON.stringify({injectedAborts,
    callbackAttempts: wrappers.length,
    canonicalAuthorityChecks: checks, freshAttemptToken: "offline-attempt-B",
    successfulCommitRequests: commits.length,
    writesInSuccessfulCommit: commits[0]?.writes?.length ?? 0}));
}

test("SDK read abort reruns authorization and commits one atomic batch",
  async (t) => retryProbe(t, false));

test("SDK read abort cannot reuse authorization after canonical revocation",
  async (t) => retryProbe(t, true));
