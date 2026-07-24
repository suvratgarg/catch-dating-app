import assert from "node:assert/strict";
import test from "node:test";

import {
  callableBaseUrl,
  FirebaseAdminCallableClient,
} from "../src/admin/callable-client.mjs";

test("admin callable client sends the Firebase callable envelope and tokens",
  async () => {
    let captured = null;
    const client = new FirebaseAdminCallableClient({
      baseUrl: "https://example.test/functions/",
      idToken: "id-token",
      appCheckToken: "app-check-token",
      fetchImpl: async (url, options) => {
        captured = {url, options};
        return new Response(JSON.stringify({result: {ok: true}}), {
          status: 200,
          headers: {"content-type": "application/json"},
        });
      },
    });
    assert.deepEqual(
      await client.invoke("adminGetOverview", {}, {
        executionId: "11111111-1111-4111-8111-111111111111",
      }),
      {ok: true}
    );
    assert.equal(captured.url, "https://example.test/functions/adminGetOverview");
    assert.equal(captured.options.headers.authorization, "Bearer id-token");
    assert.equal(
      captured.options.headers["x-firebase-appcheck"],
      "app-check-token"
    );
    assert.deepEqual(JSON.parse(captured.options.body), {data: {}});
  });

test("admin callable client exposes normalized remote failures", async () => {
  const client = new FirebaseAdminCallableClient({
    baseUrl: "https://example.test/functions",
    idToken: "id-token",
    appCheckToken: "app-check-token",
    fetchImpl: async () => new Response(JSON.stringify({
      error: {status: "PERMISSION_DENIED", message: "denied"},
    }), {status: 403}),
  });
  await assert.rejects(
    () => client.invoke("adminGetOverview", {}),
    {code: "ADMIN_CALLABLE_PERMISSION_DENIED", message: "denied"}
  );
});

test("admin callable URL requires a valid project or explicit base URL", () => {
  assert.equal(callableBaseUrl({
    project: "catch-project-123",
    region: "asia-south1",
  }), "https://asia-south1-catch-project-123.cloudfunctions.net");
  assert.throws(() => callableBaseUrl({project: "INVALID"}), {
    code: "ADMIN_CLI_PROJECT_INVALID",
  });
});
