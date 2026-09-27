#!/usr/bin/env node
import fs from "node:fs/promises";
import path from "node:path";
import {FirebaseAdminCallableClient, callableBaseUrl} from "../../admin/callable-client.mjs";
import {FileOperationsStore} from "../../platform/storage/file-store.mjs";
import {freezeMigration, reviewMigration, applyReviewedMigration, readPrivateJson} from "./migration.mjs";

const [command, ...args] = process.argv.slice(2);
const usage = "freeze <mapped-source.json> <private-manifest.json> | " +
  "review <manifest.json> <private-review.json> | " +
  "apply <manifest.json> <review.json> <approved-review-hash> <private-state-dir> <private-result.json>";
try {
  if (!command || command === "--help") {
    console.log(usage);
  } else {
    const expected = {freeze: 2, review: 2, apply: 5}[command];
    if (!expected || args.length !== expected) throw new Error(usage);
    const input = await readPrivateJson(args[0]);
    let result;
    let output;
    if (command === "freeze") {
      result = freezeMigration(input);
      output = args[1];
    } else {
      const client = new FirebaseAdminCallableClient({
        baseUrl: callableBaseUrl({project: process.env.CATCH_ADMIN_FIREBASE_PROJECT,
          baseUrl: process.env.CATCH_ADMIN_CALLABLE_BASE_URL}),
        idToken: process.env.CATCH_ADMIN_ID_TOKEN,
        appCheckToken: process.env.CATCH_ADMIN_APP_CHECK_TOKEN,
      });
      if (command === "review") {
        result = await reviewMigration(input, client);
        output = args[1];
      } else {
        const store = await new FileOperationsStore(args[3]).initialize();
        result = await applyReviewedMigration({manifest: input,
          review: await readPrivateJson(args[1]), approvedReviewHash: args[2],
          client, store, owner: "reviewed-sales-migration"});
        output = args[4];
      }
    }
    const destination = path.resolve(output);
    await fs.writeFile(destination, JSON.stringify(result, null, 2) + "\n",
      {flag: "wx", mode: 0o600});
    console.log(JSON.stringify({output: destination,
      manifestHash: result.manifestHash, reviewHash: result.reviewHash,
      rowCount: result.rowCount, counts: result.counts}));
  }
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
