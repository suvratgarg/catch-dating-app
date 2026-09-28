#!/usr/bin/env node
import fs from "node:fs/promises";
import path from "node:path";
import {FirebaseAdminCallableClient, callableBaseUrl} from "../../admin/callable-client.mjs";
import {FileOperationsStore} from "../../platform/storage/file-store.mjs";
import {freezeMigration, reviewMigration, applyReviewedMigration, readPrivateJson} from "./migration.mjs";
import {identityDecisionTemplate, prepareIdentityReview} from "./identity-review.mjs";
import {planMigrationCompensation} from "./compensation-plan.mjs";
import {applyReviewedCompensation, previewReviewedCompensation} from
  "./compensation.mjs";

const [command, ...args] = process.argv.slice(2);
const usage = "identity-template <mapped-source.json> <private-decisions.json> | " +
  "identity-review <mapped-source.json> <identity-decisions.json> <private-review.json> | " +
  "freeze <mapped-source.json> <private-manifest.json> | " +
  "review <manifest.json> <private-review.json> | " +
  "apply <manifest.json> <review.json> <approved-review-hash> <private-state-dir> <private-result.json> | " +
  "compensation-plan <manifest.json> <review.json> <receipts.json> <accounts.json> <related-records.json> <private-plan.json> | " +
  "compensation-preview <import-id> <organizer-id> <private-plan.json> | " +
  "compensation-apply <private-plan.json> <approved-preview-hash> <private-reason.json> <private-state-dir> <private-result.json>";
try {
  if (!command || command === "--help") {
    console.log(usage);
  } else {
    const expected = {"identity-template": 2, "identity-review": 3,
      freeze: 2, review: 2, apply: 5, "compensation-plan": 6,
      "compensation-preview": 3, "compensation-apply": 5}[command];
    if (!expected || args.length !== expected) throw new Error(usage);
    if (command === "compensation-preview" ||
      command === "compensation-apply") {
      const destination = path.resolve(args.at(-1));
      try {
        await fs.lstat(destination);
        throw new Error("Private compensation output already exists.");
      } catch (error) {
        if (error?.code !== "ENOENT") throw error;
      }
    }
    const input = command === "compensation-preview" ? null :
      await readPrivateJson(args[0]);
    let result;
    let output;
    if (command === "compensation-preview" ||
      command === "compensation-apply") {
      const client = new FirebaseAdminCallableClient({
        baseUrl: callableBaseUrl({project: process.env.CATCH_ADMIN_FIREBASE_PROJECT,
          baseUrl: process.env.CATCH_ADMIN_CALLABLE_BASE_URL}),
        idToken: process.env.CATCH_ADMIN_ID_TOKEN,
        appCheckToken: process.env.CATCH_ADMIN_APP_CHECK_TOKEN,
      });
      if (command === "compensation-preview") {
        result = await previewReviewedCompensation(client,
          {importId: args[0], organizerId: args[1]});
        output = args[2];
      } else {
        const reason = await readPrivateJson(args[2]);
        const store = await new FileOperationsStore(args[3]).initialize();
        result = await applyReviewedCompensation({plan: input,
          approvedPreviewHash: args[1], reason: reason.reason,
          client, store});
        output = args[4];
      }
    } else if (command === "identity-template") {
      result = identityDecisionTemplate(input);
      output = args[1];
    } else if (command === "identity-review") {
      result = prepareIdentityReview(input, await readPrivateJson(args[1]));
      output = args[2];
    } else if (command === "freeze") {
      result = freezeMigration(input);
      output = args[1];
    } else if (command === "compensation-plan") {
      result = planMigrationCompensation({manifest: input,
        review: await readPrivateJson(args[1]), receipts: await readPrivateJson(args[2]),
        currentAccounts: await readPrivateJson(args[3]),
        relatedRecords: await readPrivateJson(args[4])});
      output = args[5];
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
