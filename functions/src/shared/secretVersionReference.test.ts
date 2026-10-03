import assert from "node:assert/strict";
import test from "node:test";
import {runtimeProjectNumber, SecretVersionReferenceGuard} from
  "./secretVersionReference";

test("pins version and secret before resolving project aliases", async () => {
  let calls = 0;
  const guard = new SecretVersionReferenceGuard(() => "local-project",
    async () => {
      calls++; return "123456";
    });
  const ref = "projects/local-project/secrets/VAULT/versions/7";
  await guard.assert(ref, "VAULT");
  assert.equal(calls, 0);
  for (const invalid of [ref.replace("local-project", "other-project"),
    ref.replace("VAULT", "UNRELATED"), ref.replace("/7", "/latest"),
    ref.replace("/7", "/active"), ref.replace("/7", "/0"),
    ref.replace("/7", "/01"), ref + "\n", ref + "/extra"]) {
    await assert.rejects(guard.assert(invalid, "VAULT"),
      /^Error: Secret version reference unavailable\.$/);
  }
  assert.equal(calls, 0);
  await guard.assert(ref.replace("local-project", "123456"), "VAULT");
  await guard.assert(ref.replace("local-project", "123456"), "VAULT");
  await assert.rejects(guard.assert(ref.replace("local-project", "654321"),
    "VAULT"), /^Error: Secret version reference unavailable\.$/);
  assert.equal(calls, 1);
});

test("missing project and unavailable alias proof fail closed without payloads",
  async () => {
    const ref = "projects/123456/secrets/VAULT/versions/7";
    let calls = 0;
    const resolve = async () => {
      calls++; throw new Error("private-details");
    };
    await assert.rejects(new SecretVersionReferenceGuard(() => undefined,
      resolve).assert(ref, "VAULT"),
    /^Error: Secret version reference unavailable\.$/);
    assert.equal(calls, 0);
    const guard = new SecretVersionReferenceGuard(() => "local-project",
      resolve);
    for (let i = 0; i < 2; i++) {
      await assert.rejects(guard.assert(ref, "VAULT"),
        /^Error: Secret version reference unavailable\.$/);
    }
    assert.equal(calls, 2); // Failed metadata is not cached forever.
  });

test("runtime metadata proof uses fixed URLs and verifies project and flavor",
  async () => {
    const urls: string[] = [];
    const fetchImpl: typeof fetch = async (url, options) => {
      urls.push(String(url));
      assert.deepEqual(options?.headers, {"Metadata-Flavor": "Google"});
      assert.equal(options?.redirect, "error");
      assert.ok(options?.signal);
      return new Response(String(url).endsWith("/project-id") ?
        "local-project" : "123456", {headers: {"Metadata-Flavor": "Google"}});
    };
    assert.equal(await runtimeProjectNumber("local-project", fetchImpl),
      "123456");
    assert.deepEqual(urls, [
      "http://metadata.google.internal/computeMetadata/v1/project/project-id",
      "http://metadata.google.internal/computeMetadata/v1/project/numeric-project-id",
    ]);
    await assert.rejects(runtimeProjectNumber("other-project", fetchImpl),
      /^Error: Secret version reference unavailable\.$/);
    for (const response of [new Response("local-project"),
      new Response("123456\n", {headers: {"Metadata-Flavor": "Google"}}),
      new Response("private-details", {status: 403})]) {
      await assert.rejects(runtimeProjectNumber("local-project",
        async () => response),
      /^Error: Secret version reference unavailable\.$/);
    }
  });
