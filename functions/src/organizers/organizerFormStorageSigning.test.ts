import assert from "node:assert/strict";
import {execFile} from "node:child_process";
import {createServer} from "node:http";
import path from "node:path";
import test from "node:test";
import {promisify} from "node:util";
import {appCheckCallableOptionsForFormUpload} from
  "../shared/organizerFormUploadIdentity";

const run = promisify(execFile);

test("form upload signer accepts metadata response headers", async () => {
  const signer = "demo-signer@example.iam.gserviceaccount.com";
  const server = createServer((request, response) => {
    assert.equal(request.headers["metadata-flavor"], "Google");
    response.writeHead(200, {
      "Metadata-Flavor": "Google",
      "Content-Type": "text/plain",
    });
    response.end(signer);
  });
  await new Promise<void>((resolve) => server.listen(0, "127.0.0.1", resolve));
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  const host = `127.0.0.1:${address.port}`;
  try {
    // Resolve the metadata client actually used by Storage's signing path.
    // A blanket gaxios major override previously changed its header shape.
    const {stdout} = await run(process.execPath, ["-e", `
      const {createRequire} = require("node:module");
      const root = createRequire(process.argv[1]);
      const storage = createRequire(root.resolve("@google-cloud/storage"));
      const auth = createRequire(storage.resolve("google-auth-library"));
      auth("gcp-metadata").instance("service-accounts/default/email")
        .then((email) => process.stdout.write(email))
        .catch((error) => { console.error(error); process.exitCode = 1; });
    `, path.resolve(__dirname, "../../package.json")], {
      env: {
        PATH: process.env.PATH,
        GCE_METADATA_HOST: host,
        GCE_METADATA_IP: host,
        NO_PROXY: "*",
      },
      timeout: 10000,
    });
    assert.equal(stdout, signer);
  } finally {
    server.closeAllConnections();
    await new Promise<void>((resolve) => server.close(() => resolve()));
  }
});

test("upload intent uses its dedicated project identity", async () => {
  for (const project of ["catchdates-dev", "catch-dating-app-64e51"]) {
    const {stdout} = await run(process.execPath, ["-e", `
      const forms = require("./lib/organizers/organizerFormResponses");
      const upload = forms.createOrganizerFormAssetIntent;
      const trigger = upload.__trigger;
      process.stdout.write(JSON.stringify({
        account: trigger.serviceAccountEmail,
        timeout: upload.__endpoint.timeoutSeconds,
        other: forms.finalizeOrganizerFormAsset.__endpoint.serviceAccountEmail,
      }));
    `], {
      cwd: path.resolve(__dirname, "../.."),
      env: {...process.env, GCLOUD_PROJECT: project},
      timeout: 10000,
    });
    const result = JSON.parse(stdout);
    assert.equal(result.account,
      `catch-form-upload@${project}.iam.gserviceaccount.com`);
    assert.equal(result.timeout, 60);
    assert.ok(result.other == null);
  }
});

test("upload identity preserves shared App Check and invoker policy", () => {
  const options = appCheckCallableOptionsForFormUpload({timeoutSeconds: 60});
  assert.equal(options.enforceAppCheck, true);
  assert.equal(options.invoker, "public");
  assert.equal(options.timeoutSeconds, 60);
});
