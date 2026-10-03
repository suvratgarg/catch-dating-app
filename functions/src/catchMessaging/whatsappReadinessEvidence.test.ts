import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import {test} from "node:test";
import {catchReadinessEvidenceDecisionDigest, prepareCatchReadinessEvidence,
  loadProtectedCatchReadinessArchive} from "./whatsappReadinessEvidence";
import type {CatchReadinessEvidencePublication,
  CatchReadinessEvidenceSources} from "./whatsappReadinessEvidence";

const digest = (v: unknown): string => createHash("sha256")
  .update(JSON.stringify(v)).digest("hex");
function fixture() {
  const identity = {projectId: "catchdates-dev", wabaId: "123",
    phoneNumberId: "456", recipientUid: "recipient",
    endpointHash: "a".repeat(64)};
  const archiveBytes = Buffer.from(JSON.stringify({
    schema: "catch.whatsapp-history-archive/v1", identity,
    atomicIngressStartedAtMillis: 1000, segments: [{fromMillis: 0,
      throughMillis: 1000, records: [{messageId: "synthetic_message",
        receivedAtMillis: 900, endpointHash: identity.endpointHash,
        messageType: "text", text: "Synthetic support question",
        textTruncated: false}]}],
  }));
  const scope = {...identity, evidenceSha256: createHash("sha256")
    .update(archiveBytes).digest("hex")};
  const publication: CatchReadinessEvidencePublication = {
    approval: {schemaVersion: 1, approvalId: "review_1", state: "approved",
      approval: {approvalId: "review_1", action: "create", scope,
        reviewerUid: "owner", reviewedAtMillis: 2000, expiresAtMillis: 5000,
        atomicIngressStartedAtMillis: 1000, expectedRecordSha256: null},
      ingressEvidenceSha256: "b".repeat(64), consumedAtMillis: null,
      recordSha256: null},
    reviewSession: {projectId: identity.projectId, reviewerUid: "owner",
      roles: ["adminOwner"], disabled: false, authTimeMillis: 1500,
      tokensValidAfterMillis: 1400, observedAtMillis: 2000,
      tokenExpiresAtMillis: 5000, decisionSha256: "",
      authenticationAuditSha256: "c".repeat(64)},
    ingress: {document: {schemaVersion: 1,
      ingressId: "cwingress_" + digest([identity.projectId,
        identity.wabaId, identity.phoneNumberId]),
      projectId: identity.projectId, wabaId: identity.wabaId,
      phoneNumberId: identity.phoneNumberId, state: "active",
      atomicIngressStartedAtMillis: 1000, evidenceSha256: "b".repeat(64),
      verifiedAtMillis: 1800}, sourceAuditSha256: "b".repeat(64),
    deployedRevisionSha256: "d".repeat(64)},
    archive: {archiveBytes, trustedPin: {
      schema: "catch.whatsapp-history-audit-pin/v1", approvalId: "review_1",
      scope: {...scope}, sourceAuditSha256: "e".repeat(64),
      atomicIngressStartedAtMillis: 1000, coveredThroughMillis: 1000}},
  };
  publication.reviewSession.decisionSha256 =
    catchReadinessEvidenceDecisionDigest(publication.approval);
  const sources: CatchReadinessEvidenceSources = {
    actualProjectId: identity.projectId, now: () => 2500,
    loadAuthenticatedReview: async () => ({approval: publication.approval,
      reviewSession: publication.reviewSession}),
    loadVerifiedAtomicIngress: async () => publication.ingress,
    loadAuditedArchive: async () => publication.archive,
  };
  const reader = {actualProjectId: identity.projectId, now: () => 2500,
    loadImmutablePublication: async () => publication};
  return {publication, sources, reader};
}

test("prepares existing contracts without publishing or granting readiness",
  async () => {
    const f = fixture();
    const result = await prepareCatchReadinessEvidence("review_1", f.sources);
    assert.equal(result.approval.state, "approved");
    assert.deepEqual(Object.keys(result).sort(),
      ["approval", "archive", "ingress", "reviewSession"]);
    assert.notEqual(result.archive.archiveBytes,
      f.publication.archive.archiveBytes);
    const loaded = await loadProtectedCatchReadinessArchive(
      f.publication.approval.approval, f.reader);
    assert.deepEqual(Object.keys(loaded).sort(),
      ["archiveBytes", "trustedPin"]);
    assert.deepEqual(loaded.trustedPin, f.publication.archive.trustedPin);
  });

test("missing protected sources and caller proof objects fail closed",
  async () => {
    const f = fixture();
    await assert.rejects(prepareCatchReadinessEvidence({
      sessionCurrent: true, completeHistory: true} as unknown as string,
    f.sources));
    for (const key of ["loadAuthenticatedReview", "loadVerifiedAtomicIngress",
      "loadAuditedArchive"] as const) {
      const g = fixture();
      g.sources[key] = async () => null;
      await assert.rejects(
        prepareCatchReadinessEvidence("review_1", g.sources));
    }
  });

test("review binds owner, project, token cutoff, time and exact decision",
  async () => {
    const edits: Array<(p: CatchReadinessEvidencePublication) => void> = [
      (p) => p.reviewSession.projectId = "foreign-project",
      (p) => p.reviewSession.reviewerUid = "other",
      (p) => p.reviewSession.roles = ["support"],
      (p) => p.reviewSession.disabled = true,
      (p) => p.reviewSession.tokensValidAfterMillis = 1501,
      (p) => p.reviewSession.authTimeMillis = 2001,
      (p) => p.reviewSession.observedAtMillis = 1999,
      (p) => p.reviewSession.tokenExpiresAtMillis = 4999,
      (p) => p.reviewSession.authTimeMillis = NaN,
      (p) => p.reviewSession.authenticationAuditSha256 = "",
      (p) => p.approval.approval.scope.recipientUid = "other",
      (p) => p.approval.approval.atomicIngressStartedAtMillis = 999,
      (p) => p.approval.approval.expiresAtMillis = 4500,
      (p) => p.approval.ingressEvidenceSha256 = "f".repeat(64),
      (p) => p.approval.state = "consumed",
    ];
    for (const edit of edits) {
      const f = fixture();
      edit(f.publication);
      await assert.rejects(
        prepareCatchReadinessEvidence("review_1", f.sources));
    }
    const f = fixture();
    f.sources.actualProjectId = "foreign-project";
    await assert.rejects(prepareCatchReadinessEvidence("review_1", f.sources));
    f.sources.actualProjectId = "catchdates-dev";
    f.sources.now = () => 5000;
    await assert.rejects(prepareCatchReadinessEvidence("review_1", f.sources));
  });

test("ingress source proof and archive audit cannot be substituted",
  async () => {
    const edits: Array<(p: CatchReadinessEvidencePublication) => void> = [
      (p) => p.ingress.sourceAuditSha256 = "f".repeat(64),
      (p) => p.ingress.deployedRevisionSha256 = "",
      (p) => p.ingress.document.state = "revoked",
      (p) => p.ingress.document.projectId = "foreign-project",
      (p) => p.ingress.document.atomicIngressStartedAtMillis = 999,
      (p) => p.ingress.document.verifiedAtMillis = 999,
      (p) => p.ingress.document.verifiedAtMillis = 2001,
      (p) => p.archive.trustedPin.sourceAuditSha256 = "",
      (p) => p.archive.trustedPin.scope.endpointHash = "f".repeat(64),
      (p) => p.archive.trustedPin.coveredThroughMillis = 999,
      (p) => p.archive.archiveBytes[0] = 0,
    ];
    for (const edit of edits) {
      const f = fixture();
      edit(f.publication);
      await assert.rejects(
        prepareCatchReadinessEvidence("review_1", f.sources));
    }
  });

test("dependency mutation cannot rewrite earlier evidence or returned bytes",
  async () => {
    const f = fixture();
    const expected = structuredClone(f.publication);
    f.sources.loadVerifiedAtomicIngress = async (arg) => {
      arg.approval.reviewerUid = "mutated_argument";
      f.publication.approval.approval.reviewerUid = "mutated_original";
      return f.publication.ingress;
    };
    f.sources.loadAuditedArchive = async (arg) => {
      arg.scope.recipientUid = "mutated_argument";
      f.publication.ingress.document.state = "revoked";
      return f.publication.archive;
    };
    const result = await prepareCatchReadinessEvidence("review_1", f.sources);
    assert.deepEqual(result, expected);
    f.publication.archive.archiveBytes.fill(0);
    assert.deepEqual(result.archive.archiveBytes,
      expected.archive.archiveBytes);
  });

test("loader rebinds exact approval and returns isolated private bytes",
  async () => {
    const f = fixture();
    const expected = structuredClone(f.publication.approval.approval);
    const altered = {...expected, reviewerUid: "other"};
    await assert.rejects(loadProtectedCatchReadinessArchive(altered, f.reader));
    f.reader.loadImmutablePublication = async () => {
      expected.scope.recipientUid = "mutated_during_await";
      return f.publication;
    };
    const result = await loadProtectedCatchReadinessArchive(expected, f.reader);
    result.archiveBytes.fill(0);
    assert.notEqual(f.publication.archive.archiveBytes[0], 0);
  });

test("dependency failure and uncertainty do not retry or publish",
  async () => {
    const f = fixture();
    let calls = 0;
    f.sources.loadAuthenticatedReview = async () => {
      calls++;
      throw new Error("unavailable protected source");
    };
    await assert.rejects(prepareCatchReadinessEvidence("review_1", f.sources));
    assert.equal(calls, 1);
  });


test("unexpected private fields are rejected at every evidence boundary",
  async () => {
    const targets: Array<(p: CatchReadinessEvidencePublication) => object> = [
      (p) => p, (p) => p.reviewSession, (p) => p.ingress,
      (p) => p.archive, (p) => p.archive.trustedPin,
      (p) => p.approval, (p) => p.ingress.document,
    ];
    for (const target of targets) {
      const f = fixture();
      Object.assign(target(f.publication), {accessToken: "private-value"});
      await assert.rejects(loadProtectedCatchReadinessArchive(
        f.publication.approval.approval, f.reader),
      {message: "Protected Catch readiness evidence unavailable."});
    }
    const f = fixture();
    f.sources.loadAuthenticatedReview = async () => ({
      approval: f.publication.approval,
      reviewSession: f.publication.reviewSession, accessToken: "private-value",
    });
    await assert.rejects(prepareCatchReadinessEvidence("review_1", f.sources),
      {message: "Protected Catch readiness evidence unavailable."});
    const g = fixture();
    g.publication.reviewSession.roles = ["adminOwner", "private-value"];
    await assert.rejects(prepareCatchReadinessEvidence("review_1", g.sources));
  });

test("protected loader exceptions never expose content, token or endpoint",
  async () => {
    const f = fixture();
    const privateFailure = async (): Promise<never> => {
      throw new Error("synthetic-private-body token +15555550123");
    };
    for (const key of ["loadAuthenticatedReview", "loadVerifiedAtomicIngress",
      "loadAuditedArchive"] as const) {
      const g = fixture();
      g.sources[key] = privateFailure;
      await assert.rejects(prepareCatchReadinessEvidence("review_1", g.sources),
        {message: "Protected Catch readiness evidence unavailable."});
    }
    f.reader.loadImmutablePublication = privateFailure;
    await assert.rejects(loadProtectedCatchReadinessArchive(
      f.publication.approval.approval, f.reader),
    {message: "Protected Catch readiness evidence unavailable."});
  });


test("canonical multiple owner roles work; duplicates and nested values fail",
  async () => {
    const f = fixture();
    f.publication.reviewSession.roles = ["adminOwner", "support"];
    const result = await prepareCatchReadinessEvidence("review_1", f.sources);
    assert.deepEqual(result.reviewSession.roles, ["adminOwner", "support"]);
    for (const roles of [["adminOwner", "adminOwner"],
      ["adminOwner", {accessToken: "private-value"}]]) {
      Object.assign(f.publication.reviewSession, {roles});
      await assert.rejects(
        prepareCatchReadinessEvidence("review_1", f.sources));
    }
  });


test("shared archive backing is detached by both preparation and loading",
  async () => {
    for (const operation of ["prepare", "load"]) {
      const f = fixture();
      const bytes = f.publication.archive.archiveBytes;
      const shared = new Uint8Array(new SharedArrayBuffer(bytes.byteLength));
      shared.set(bytes);
      f.publication.archive.archiveBytes = shared;
      const archive = operation === "prepare" ?
        (await prepareCatchReadinessEvidence("review_1", f.sources)).archive :
        await loadProtectedCatchReadinessArchive(
          f.publication.approval.approval, f.reader);
      shared.fill(0);
      assert.deepEqual(archive.archiveBytes, Uint8Array.from(bytes));
      assert.equal(archive.archiveBytes.buffer instanceof SharedArrayBuffer,
        false);
    }
  });
