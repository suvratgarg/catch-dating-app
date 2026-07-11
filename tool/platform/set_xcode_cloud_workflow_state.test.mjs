import assert from "node:assert/strict";
import crypto from "node:crypto";
import test from "node:test";
import {
  createAppStoreConnectToken,
  selectXcodeCloudWorkflow,
  setXcodeCloudWorkflowState,
} from "./set_xcode_cloud_workflow_state.mjs";

function jsonResponse(payload) {
  return {ok: true, status: 200, statusText: "OK", text: async () => JSON.stringify(payload)};
}

test("App Store Connect token uses ES256 JWT claims", () => {
  const {privateKey} = crypto.generateKeyPairSync("ec", {namedCurve: "prime256v1"});
  const token = createAppStoreConnectToken({
    keyId: "KEY123",
    issuerId: "issuer",
    privateKey,
    now: 1_700_000_000_000,
  });
  const [header, payload, signature] = token.split(".");
  assert.deepEqual(JSON.parse(Buffer.from(header, "base64url")), {alg: "ES256", kid: "KEY123", typ: "JWT"});
  assert.equal(JSON.parse(Buffer.from(payload, "base64url")).aud, "appstoreconnect-v1");
  assert.ok(signature.length > 20);
});

test("Xcode Cloud workflow selection rejects ambiguous names", () => {
  assert.throws(() => selectXcodeCloudWorkflow([], "Catch | Default"), /found 0/u);
});

test("Xcode Cloud workflow state patch disables the selected workflow", async () => {
  const requests = [];
  const responses = [
    jsonResponse({data: {id: "product-1"}}),
    jsonResponse({data: [{id: "workflow-1", attributes: {name: "Catch | Default", isEnabled: true}}]}),
    jsonResponse({data: {id: "workflow-1", attributes: {isEnabled: false}}}),
  ];
  const fetchImpl = async (url, options) => {
    requests.push({url, options});
    return responses.shift();
  };
  const result = await setXcodeCloudWorkflowState({
    appId: "6765646860",
    workflowName: "Catch | Default",
    enabled: false,
    token: "jwt",
    fetchImpl,
    apply: true,
  });
  assert.equal(result.changed, true);
  assert.equal(requests[2].options.method, "PATCH");
  assert.equal(JSON.parse(requests[2].options.body).data.attributes.isEnabled, false);
});

test("Xcode Cloud workflow state patch fails without API confirmation", async () => {
  const responses = [
    jsonResponse({data: {id: "product-1"}}),
    jsonResponse({data: [{id: "workflow-1", attributes: {name: "Catch | Default", isEnabled: true}}]}),
    jsonResponse({data: {id: "workflow-1", attributes: {isEnabled: true}}}),
  ];
  await assert.rejects(
    setXcodeCloudWorkflowState({
      appId: "6765646860",
      workflowName: "Catch | Default",
      enabled: false,
      token: "jwt",
      fetchImpl: async () => responses.shift(),
      apply: true,
    }),
    /did not confirm/u,
  );
});
