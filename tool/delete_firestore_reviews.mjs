#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath} from "node:url";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "..");
const requireFromFunctions = createRequire(
  path.join(repoRoot, "functions/package.json")
);
const admin = requireFromFunctions("firebase-admin");

const args = parseArgs(process.argv.slice(2));
if (args.help) {
  printHelp();
  process.exit(0);
}

if (args.emulatorHost) {
  process.env.FIRESTORE_EMULATOR_HOST = args.emulatorHost;
}

const projectId = resolveProjectId(args);
admin.initializeApp({projectId});
const db = admin.firestore();

const plan = await buildDeletionPlan(db, {projectId, emulatorHost: args.emulatorHost});

if (args.json) {
  console.log(JSON.stringify(plan, null, 2));
} else {
  printPlan(plan);
}

if (!args.apply) {
  process.exit(0);
}

if (!args.confirmDeleteAllReviews) {
  throw new Error(
    "--apply requires --confirm-delete-all-reviews to prevent accidental data loss."
  );
}

await applyDeletionPlan(db, plan);

const afterPlan = await buildDeletionPlan(db, {
  projectId,
  emulatorHost: args.emulatorHost,
  afterApply: true,
});

if (args.json) {
  console.log(JSON.stringify({applied: true, after: afterPlan}, null, 2));
} else {
  console.log("");
  console.log("Applied review deletion plan.");
  printPlan(afterPlan);
}

function parseArgs(argv) {
  const parsed = {
    env: null,
    project: null,
    emulatorHost: null,
    apply: false,
    confirmDeleteAllReviews: false,
    json: false,
    help: false,
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--apply") parsed.apply = true;
    else if (arg === "--confirm-delete-all-reviews") {
      parsed.confirmDeleteAllReviews = true;
    } else if (arg === "--emulator") {
      parsed.emulatorHost = "127.0.0.1:8080";
    } else if (arg === "--emulator-host") {
      parsed.emulatorHost = requireValue(argv, ++i, arg);
    } else if (arg === "--env") {
      parsed.env = requireValue(argv, ++i, arg);
    } else if (arg === "--project") {
      parsed.project = requireValue(argv, ++i, arg);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }

  return parsed;
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    throw new Error(`${flag} requires a value.`);
  }
  return value;
}

function resolveProjectId(parsed) {
  if (parsed.project) return parsed.project;
  if (parsed.env) {
    const firebaserc = JSON.parse(
      fs.readFileSync(path.join(repoRoot, ".firebaserc"), "utf8")
    );
    const project = firebaserc.projects?.[parsed.env];
    if (!project) {
      throw new Error(`No Firebase project alias found for env: ${parsed.env}`);
    }
    return project;
  }
  return process.env.GCLOUD_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT ||
    "catchdates-dev";
}

function printHelp() {
  console.log(`
Delete all Firestore reviews and reset derived review aggregates.

This tool is intentionally destructive only with explicit confirmation. Without
--apply it performs a dry-run relationship map.

Usage:
  node tool/delete_firestore_reviews.mjs --env dev
  node tool/delete_firestore_reviews.mjs --env prod --json
  node tool/delete_firestore_reviews.mjs --env dev --apply --confirm-delete-all-reviews
  node tool/delete_firestore_reviews.mjs --env dev --emulator

Options:
  --env <dev|staging|prod>       Resolve project id from .firebaserc.
  --project <firebase-project>   Explicit Firebase/GCP project id.
  --emulator                     Use FIRESTORE_EMULATOR_HOST=127.0.0.1:8080.
  --emulator-host <host:port>    Use a custom Firestore emulator host.
  --json                         Emit machine-readable JSON.
  --apply                        Delete reviews and reset derived aggregates.
  --confirm-delete-all-reviews   Required with --apply.
`);
}

async function buildDeletionPlan(firestore, metadata) {
  const [reviewDocs, runClubDocs, runDocs, userDocs] = await Promise.all([
    readCollection(firestore.collection("reviews")),
    readCollection(firestore.collection("runClubs")),
    readCollection(firestore.collection("runs")),
    readCollection(firestore.collection("users")),
  ]);

  const affectedRunClubIds = new Set();
  const affectedRunIds = new Set();
  const affectedReviewerUserIds = new Set();
  const missingRunIdReviewPaths = [];
  const missingClubReviewPaths = [];
  const missingRunReviewPaths = [];

  for (const review of reviewDocs) {
    const data = review.data;
    if (isNonEmptyString(data.runClubId)) {
      affectedRunClubIds.add(data.runClubId);
    } else {
      missingClubReviewPaths.push(review.path);
    }
    if (isNonEmptyString(data.runId)) {
      affectedRunIds.add(data.runId);
    } else {
      missingRunIdReviewPaths.push(review.path);
    }
    if (isNonEmptyString(data.reviewerUserId)) {
      affectedReviewerUserIds.add(data.reviewerUserId);
    }
  }

  const runClubsById = byId(runClubDocs);
  const runsById = byId(runDocs);
  const usersById = byId(userDocs);

  for (const runId of affectedRunIds) {
    if (!runsById.has(runId)) missingRunReviewPaths.push(`runs/${runId}`);
  }

  const runClubAggregateResets = runClubDocs
    .filter((doc) =>
      affectedRunClubIds.has(doc.id) ||
      numberOrZero(doc.data.rating) !== 0 ||
      numberOrZero(doc.data.reviewCount) !== 0
    )
    .map((doc) => ({
      path: doc.path,
      before: {
        rating: numberOrZero(doc.data.rating),
        reviewCount: numberOrZero(doc.data.reviewCount),
      },
      after: {rating: 0, reviewCount: 0},
      reason: affectedRunClubIds.has(doc.id) ?
        "has-review-docs" :
        "stale-nonzero-aggregate",
    }));

  const runReferenceFields = inspectReferenceFields(
    [...affectedRunIds]
      .map((id) => runsById.get(id))
      .filter(Boolean),
    reviewDocs,
    "run"
  );
  const userReferenceFields = inspectReferenceFields(
    [...affectedReviewerUserIds]
      .map((id) => usersById.get(id))
      .filter(Boolean),
    reviewDocs,
    "user"
  );

  return {
    projectId: metadata.projectId,
    emulatorHost: metadata.emulatorHost ?? null,
    generatedAt: new Date().toISOString(),
    mode: metadata.afterApply ? "post-apply-check" : "dry-run",
    summary: {
      reviewDocumentsToDelete: reviewDocs.length,
      affectedRunClubs: affectedRunClubIds.size,
      affectedRuns: affectedRunIds.size,
      affectedReviewerUsers: affectedReviewerUserIds.size,
      runClubAggregateResets: runClubAggregateResets.length,
      missingRunIdReviews: missingRunIdReviewPaths.length,
      runReferenceFieldsFound: runReferenceFields.length,
      userReferenceFieldsFound: userReferenceFields.length,
    },
    reviewDocuments: reviewDocs.map((doc) => ({
      path: doc.path,
      runClubId: doc.data.runClubId ?? null,
      runId: doc.data.runId ?? null,
      reviewerUserId: doc.data.reviewerUserId ?? null,
      rating: doc.data.rating ?? null,
    })),
    affectedRunClubIds: [...affectedRunClubIds].sort(),
    affectedRunIds: [...affectedRunIds].sort(),
    affectedReviewerUserIds: [...affectedReviewerUserIds].sort(),
    runClubAggregateResets,
    runReferenceFields,
    userReferenceFields,
    warnings: [
      ...missingClubReviewPaths.map((pathValue) => ({
        path: pathValue,
        code: "review-missing-run-club-id",
        message: "Review has no runClubId; deletion still removes it.",
      })),
      ...missingRunIdReviewPaths.map((pathValue) => ({
        path: pathValue,
        code: "legacy-review-without-run-id",
        message: "Review has no runId; no run document reference can be cleared.",
      })),
      ...missingRunReviewPaths.map((pathValue) => ({
        path: pathValue,
        code: "review-run-missing",
        message: "Review references a run document that does not exist.",
      })),
    ],
  };
}

async function applyDeletionPlan(firestore, plan) {
  const writes = [];

  for (const review of plan.reviewDocuments) {
    writes.push((batch) => batch.delete(firestore.doc(review.path)));
  }

  for (const reset of plan.runClubAggregateResets) {
    writes.push((batch) => batch.set(
      firestore.doc(reset.path),
      {rating: 0, reviewCount: 0},
      {merge: true}
    ));
  }

  for (const field of [
    ...plan.runReferenceFields,
    ...plan.userReferenceFields,
  ]) {
    if (!field.safeReset) continue;
    writes.push((batch) => batch.update(
      firestore.doc(field.path),
      {[field.field]: field.resetValue}
    ));
  }

  for (let i = 0; i < writes.length; i += 450) {
    const batch = firestore.batch();
    for (const write of writes.slice(i, i + 450)) {
      write(batch);
    }
    await batch.commit();
  }
}

async function readCollection(collectionRef) {
  const snap = await collectionRef.get();
  return snap.docs.map((doc) => ({
    id: doc.id,
    path: doc.ref.path,
    data: doc.data(),
  }));
}

function byId(docs) {
  return new Map(docs.map((doc) => [doc.id, doc]));
}

function inspectReferenceFields(docs, reviews, kind) {
  const reviewIds = new Set(reviews.map((doc) => doc.id));
  const runIds = new Set(
    reviews
      .map((doc) => doc.data.runId)
      .filter(isNonEmptyString)
  );
  const runClubIds = new Set(
    reviews
      .map((doc) => doc.data.runClubId)
      .filter(isNonEmptyString)
  );

  const candidateFields = kind === "run" ?
    ["reviewIds", "reviewCount", "rating", "averageRating"] :
    [
      "reviewIds",
      "reviewedRunIds",
      "reviewedRunClubIds",
      "reviewCount",
      "rating",
      "averageRating",
    ];

  const found = [];
  for (const doc of docs) {
    for (const field of candidateFields) {
      if (!Object.prototype.hasOwnProperty.call(doc.data, field)) continue;
      const value = doc.data[field];
      found.push({
        path: doc.path,
        field,
        type: Array.isArray(value) ? "array" : typeof value,
        valuePreview: previewValue(value),
        safeReset: isSafelyResettableReferenceField(field, value),
        resetValue: resetValueForField(field, value, {
          reviewIds,
          runIds,
          runClubIds,
        }),
      });
    }
  }
  return found;
}

function isSafelyResettableReferenceField(field, value) {
  if (["reviewCount", "rating", "averageRating"].includes(field)) {
    return typeof value === "number";
  }
  if (["reviewIds", "reviewedRunIds", "reviewedRunClubIds"].includes(field)) {
    return Array.isArray(value);
  }
  return false;
}

function resetValueForField(field, value, refs) {
  if (["reviewCount", "rating", "averageRating"].includes(field)) {
    return 0;
  }
  if (field === "reviewIds" && Array.isArray(value)) {
    return value.filter((item) => !refs.reviewIds.has(item));
  }
  if (field === "reviewedRunIds" && Array.isArray(value)) {
    return value.filter((item) => !refs.runIds.has(item));
  }
  if (field === "reviewedRunClubIds" && Array.isArray(value)) {
    return value.filter((item) => !refs.runClubIds.has(item));
  }
  return null;
}

function previewValue(value) {
  if (Array.isArray(value)) {
    return value.slice(0, 10);
  }
  if (value && typeof value === "object") {
    return Object.keys(value).slice(0, 10);
  }
  return value;
}

function numberOrZero(value) {
  return typeof value === "number" ? value : 0;
}

function isNonEmptyString(value) {
  return typeof value === "string" && value.length > 0;
}

function printPlan(plan) {
  console.log(`Project: ${plan.projectId}`);
  if (plan.emulatorHost) console.log(`Emulator: ${plan.emulatorHost}`);
  console.log(`Mode: ${plan.mode}`);
  console.log("");
  console.log("Summary:");
  for (const [key, value] of Object.entries(plan.summary)) {
    console.log(`  ${key}: ${value}`);
  }
  console.log("");

  if (plan.reviewDocuments.length > 0) {
    console.log("Review documents:");
    for (const review of plan.reviewDocuments) {
      console.log(
        `  - ${review.path} ` +
        `(club=${review.runClubId ?? "none"}, ` +
        `run=${review.runId ?? "none"}, ` +
        `reviewer=${review.reviewerUserId ?? "none"}, ` +
        `rating=${review.rating ?? "none"})`
      );
    }
    console.log("");
  }

  if (plan.runClubAggregateResets.length > 0) {
    console.log("Run club aggregate resets:");
    for (const reset of plan.runClubAggregateResets) {
      console.log(
        `  - ${reset.path}: ` +
        `${reset.before.rating}/${reset.before.reviewCount} -> 0/0 ` +
        `(${reset.reason})`
      );
    }
    console.log("");
  }

  if (plan.runReferenceFields.length > 0) {
    console.log("Run review reference fields found:");
    for (const field of plan.runReferenceFields) {
      console.log(
        `  - ${field.path}.${field.field} ` +
        `type=${field.type} safeReset=${field.safeReset}`
      );
    }
    console.log("");
  }

  if (plan.userReferenceFields.length > 0) {
    console.log("User review reference fields found:");
    for (const field of plan.userReferenceFields) {
      console.log(
        `  - ${field.path}.${field.field} ` +
        `type=${field.type} safeReset=${field.safeReset}`
      );
    }
    console.log("");
  }

  if (plan.warnings.length > 0) {
    console.log("Warnings:");
    for (const warning of plan.warnings) {
      console.log(`  - [${warning.code}] ${warning.path}: ${warning.message}`);
    }
    console.log("");
  }
}
