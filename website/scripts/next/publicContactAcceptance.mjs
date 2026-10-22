import assert from "node:assert/strict";
import {spawn} from "node:child_process";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {prepareStandalone} from "./prepareStandalone.mjs";

if (process.env.FIRESTORE_EMULATOR_HOST !== "127.0.0.1:8765") {
  throw new Error("Isolated demo-catch-nextjs Firestore emulator required");
}
const root = fileURLToPath(new URL("../../", import.meta.url));
await prepareStandalone(root);
const app = initializeApp({projectId: "demo-catch-nextjs"}, "public-contact-acceptance");
const ref = getFirestore(app).doc("config/publicContact");
const previous = await ref.get();
const port = 3127;
const server = spawn(process.execPath, ["server.js"], {
  cwd: path.join(root, ".next/standalone/website"),
  env: {...process.env, HOSTNAME: "127.0.0.1", PORT: String(port),
    CATCH_WEBSITE_STAGE: "preview", CATCH_PUBLIC_FIRESTORE_PROJECT: "demo-catch-nextjs"},
  stdio: ["ignore", "pipe", "pipe"],
});
let serverOutput = "";
server.stdout.on("data", bytes => {serverOutput += bytes.toString();});
server.stderr.on("data", bytes => {serverOutput += bytes.toString();});
const origin = `http://127.0.0.1:${port}`;

async function verify(email, absentEmail) {
  for (const route of ["/help/", "/privacy/", "/terms/"]) {
    const response = await fetch(origin + route);
    assert.equal(response.status, 200, `${route}: ${response.status} ${serverOutput}`);
    const html = await response.text();
    assert.ok(html.includes(email), `${route} omitted visible ${email}`);
    assert.equal((html.match(new RegExp(`mailto:${email.replaceAll(".", "\\.")}`, "gu")) ?? []).length,
      2, `${route} mailto mismatch`);
    if (absentEmail) assert.ok(!html.includes(absentEmail), `${route} retained ${absentEmail}`);
  }
}

try {
  for (let attempt = 0; attempt < 100; attempt++) {
    if (server.exitCode !== null) throw new Error(`Standalone exited: ${serverOutput}`);
    try {if ((await fetch(origin + "/help/")).status === 200) break;} catch {}
    if (attempt === 99) throw new Error(`Standalone did not start: ${serverOutput}`);
    await new Promise(resolve => setTimeout(resolve, 100));
  }
  await ref.set({schemaVersion: 1, revision: 1, supportEmail: "suvrat.garg@gmail.com"});
  await verify("suvrat.garg@gmail.com", "suvrat@catchdates.com");
  await ref.set({schemaVersion: 1, revision: 2, supportEmail: "support@example.org"});
  await verify("support@example.org", "suvrat.garg@gmail.com");
  await ref.set({schemaVersion: 1, revision: 3, supportEmail: "other@example.org"});
  await verify("other@example.org", "support@example.org");
  await ref.set({schemaVersion: 1, revision: 4, supportEmail: "bad@example.org", privateField: "no"});
  await verify("suvrat.garg@gmail.com", "bad@example.org");
  await ref.delete();
  await verify("suvrat.garg@gmail.com", "other@example.org");
  console.log("Public contact acceptance passed: one running Next build observed successive Firestore edits and safe fallbacks on all three routes.");
} finally {
  server.kill("SIGTERM");
  if (previous.exists) await ref.set(previous.data()); else await ref.delete();
  await app.delete();
}
