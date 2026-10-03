import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import test from "node:test";
import {verifyCatchWhatsappHistoryArchive as verify} from
  "./whatsappHistoryArchiveVerifier";
import type {ArchiveReadinessApproval, TrustedCatchHistoryArchivePin} from
  "./whatsappHistoryArchiveVerifier";
const hash = (value: string | Uint8Array): string =>
  createHash("sha256").update(value).digest("hex");
function fixture() {
  const identity = {projectId: "catchdates-dev", wabaId: "123",
    phoneNumberId: "456", recipientUid: "recipient", endpointHash: hash("+1")};
  const record = {messageId: "wamid.synthetic1", receivedAtMillis: 150,
    endpointHash: identity.endpointHash, messageType: "text",
    text: "Please help with my account", textTruncated: false};
  const archive = {schema: "catch.whatsapp-history-archive/v1", identity,
    atomicIngressStartedAtMillis: 200, segments: [
      {fromMillis: 0, throughMillis: 100, records: [] as typeof record[]},
      {fromMillis: 100, throughMillis: 200, records: [record]},
    ]};
  const approval: ArchiveReadinessApproval = {approvalId: "review1",
    action: "create", scope: {...identity, evidenceSha256: ""},
    atomicIngressStartedAtMillis: 200, reviewedAtMillis: 210,
    expiresAtMillis: 1000};
  const trustedPin: TrustedCatchHistoryArchivePin = {
    schema: "catch.whatsapp-history-audit-pin/v1", approvalId: "review1",
    scope: {...approval.scope}, sourceAuditSha256: hash("synthetic audit"),
    atomicIngressStartedAtMillis: 200, coveredThroughMillis: 200};
  const input = {archiveBytes: Buffer.from(""), approval, trustedPin,
    nowMillis: 220};
  function pin(bytes = Buffer.from(JSON.stringify(archive))) {
    input.archiveBytes = bytes;
    approval.scope.evidenceSha256 = hash(bytes);
    trustedPin.scope.evidenceSha256 = hash(bytes);
    return input;
  }
  pin();
  return {archive, record, input, pin};
}
const rejected = (run: () => unknown) => assert.throws(run,
  {message: "Catch historical archive verification unavailable."});

test("pinned bytes produce scoped provenance, not activation", () => {
  const {input} = fixture();
  const result = verify(input);
  assert.equal(result.historyFromMillis, 0);
  assert.equal(result.coveredThroughMillis, 200);
  assert.deepEqual(result.scope, input.approval.scope);
  assert.match(result.provenanceSha256, /^[a-f0-9]{64}$/u);
  input.trustedPin.sourceAuditSha256 = hash("different independent audit");
  assert.notEqual(verify(input).provenanceSha256, result.provenanceSha256);
  input.approval.scope.recipientUid = "changed-after-validation";
  assert.equal(result.scope.recipientUid, "recipient");
  assert.equal("state" in result, false);
});
test("missing pin/audit and modified bytes cannot authorize", () => {
  const {input} = fixture();
  rejected(() => verify({...input,
    trustedPin: undefined as unknown as TrustedCatchHistoryArchivePin}));
  rejected(() => verify({...input, trustedPin: {...input.trustedPin,
    sourceAuditSha256: ""}}));
  input.archiveBytes = Buffer.from(input.archiveBytes.toString()
    .replace("Please help", "Other body"));
  rejected(() => verify(input));
});
test("all independent scope and approval bindings are enforced", () => {
  for (const field of ["projectId", "wabaId", "phoneNumberId",
    "recipientUid", "endpointHash", "evidenceSha256"] as const) {
    const {input} = fixture();
    input.trustedPin.scope[field] += "1";
    rejected(() => verify(input));
  }
  for (const change of [{approvalId: "other"},
    {atomicIngressStartedAtMillis: 199}, {coveredThroughMillis: 201},
    {schema: "unsupported"}]) {
    const {input} = fixture();
    Object.assign(input.trustedPin, change);
    rejected(() => verify(input));
  }
});
test("archive cannot substitute recipient, sender, project or cutover", () => {
  for (const field of ["projectId", "wabaId", "phoneNumberId",
    "recipientUid", "endpointHash"] as const) {
    const f = fixture();
    f.archive.identity[field] += "1";
    rejected(() => verify(f.pin()));
  }
  const f = fixture();
  f.archive.atomicIngressStartedAtMillis++;
  rejected(() => verify(f.pin()));
});
test("canonical STOP variants fail even with pinned bytes", () => {
  for (const text of ["STOP", " unsubscribe ", "EnD", "quit", "cancel",
    "\n\tSTOP\r"]) {
    const f = fixture();
    f.record.text = text;
    rejected(() => verify(f.pin()));
  }
});
test("unsupported, truncated and oversize records fail closed", () => {
  for (const change of [{messageType: "interactive"}, {messageType: "image"},
    {textTruncated: true}, {text: ""}, {text: "a".repeat(4097)}, {text: null},
    {text: 42}, {endpointHash: hash("different endpoint")},
    {receivedAtMillis: 99}, {receivedAtMillis: 200}, {receivedAtMillis: 150.5},
    {messageId: ""}, {messageId: "bad\nidentifier"}, {hiddenText: "STOP"}]) {
    const f = fixture();
    Object.assign(f.record, change);
    rejected(() => verify(f.pin()));
  }
});
test("epoch omissions, gaps, overlaps and missing coverage fail", () => {
  for (const alter of [
    (f: ReturnType<typeof fixture>) => f.archive.segments[0].fromMillis++,
    (f: ReturnType<typeof fixture>) => f.archive.segments[1].fromMillis++,
    (f: ReturnType<typeof fixture>) => f.archive.segments[1].fromMillis--,
    (f: ReturnType<typeof fixture>) => f.archive.segments[1].throughMillis--,
    (f: ReturnType<typeof fixture>) => f.archive.segments[1].throughMillis++,
    (f: ReturnType<typeof fixture>) => f.archive.segments.reverse(),
  ]) {
    const f = fixture();
    alter(f);
    rejected(() => verify(f.pin()));
  }
});
test("empty retained history never creates a clearance", () => {
  const f = fixture();
  f.archive.segments[1].records = [];
  rejected(() => verify(f.pin()));
  f.archive.segments = [];
  rejected(() => verify(f.pin()));
});
test("duplicate IDs and reordered records cannot mask conflicting STOP", () => {
  const f = fixture();
  f.archive.segments[1].records.push({...f.record});
  rejected(() => verify(f.pin()));
  f.archive.segments[1].records[1].messageId = "unique";
  f.archive.segments[1].records[1].receivedAtMillis = 149;
  rejected(() => verify(f.pin()));
});
test("duplicate IDs across intervals cannot be silently deduplicated", () => {
  const f = fixture();
  f.archive.segments[0].records.push({...f.record, receivedAtMillis: 50});
  rejected(() => verify(f.pin()));
});
test("malformed JSON, duplicate keys and extra fields fail safely", () => {
  const f = fixture();
  const json = JSON.stringify(f.archive);
  for (const text of ["not json", json + " ", json.replace(
    "\"text\":\"Please help with my account\"",
    "\"text\":\"STOP\",\"text\":\"Please help with my account\""),
  json.replace("\"segments\":", "\"completeHistory\":true,\"segments\":")]) {
    rejected(() => verify(f.pin(Buffer.from(text))));
  }
  rejected(() => verify(f.pin(Buffer.concat([
    Buffer.from([0xef, 0xbb, 0xbf]), Buffer.from(json),
  ]))));
  rejected(() => verify(f.pin(Buffer.from([0xff, 0xff]))));
  rejected(() => verify(f.pin(Buffer.from(
    "[".repeat(20000) + "0" + "]".repeat(20000)))));
  rejected(() => verify(f.pin(Buffer.alloc(8 * 1024 * 1024 + 1))));
});
test("future, expired, invalid and revoke approvals fail", () => {
  for (const change of [{reviewedAtMillis: 221}, {expiresAtMillis: 220},
    {expiresAtMillis: 86400211}, {atomicIngressStartedAtMillis: 211},
    {atomicIngressStartedAtMillis: 0}, {action: "revoke"},
    {reviewedAtMillis: NaN}, {expiresAtMillis: Infinity}]) {
    const {input} = fixture();
    Object.assign(input.approval, change);
    rejected(() => verify(input));
  }
});
