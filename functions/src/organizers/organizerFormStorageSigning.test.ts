import assert from "node:assert/strict";
import {execFile} from "node:child_process";
import {createServer} from "node:http";
import path from "node:path";
import test from "node:test";
import {promisify} from "node:util";

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
