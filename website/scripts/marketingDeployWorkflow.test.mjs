import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";

const scriptsRoot = path.dirname(fileURLToPath(import.meta.url));
const websiteRoot = path.resolve(scriptsRoot, "..");
const repoRoot = path.resolve(websiteRoot, "..");
const workflow = fs.readFileSync(
  path.join(repoRoot, ".github", "workflows", "marketing-website.yml"),
  "utf8"
);
const surfaceValidationWorkflow = fs.readFileSync(
  path.join(repoRoot, ".github", "workflows", "react-surface-validation.yml"),
  "utf8"
);
const packageJson = JSON.parse(
  fs.readFileSync(path.join(websiteRoot, "package.json"), "utf8")
);

test("production deploy materializes organizer projections from Firestore before Firebase predeploy", () => {
  assert.equal(
    packageJson.scripts["materialize:organizer-listings:deploy"],
    "node scripts/generateOrganizerListings.mjs " +
      "--firestore-project catch-dating-app-64e51 --no-seeds && " +
      "node scripts/generateOrganizerListings.mjs " +
      "--firestore-project catch-dating-app-64e51 --no-seeds --include-demo " +
      "--output src/generated/hostListings.demo.json && " +
      "npm run check:organizer-listings"
  );

  const materializeStep = workflow.indexOf(
    "- name: Materialize production organizer listings from Firestore"
  );
  const deployStep = workflow.indexOf("- name: Deploy production marketing site");

  assert.ok(materializeStep >= 0, "Firestore materialization step must exist");
  assert.ok(
    deployStep > materializeStep,
    "Firebase predeploy must run after Firestore projections are materialized"
  );

  const materializeContract = workflow.slice(materializeStep, deployStep);
  assert.match(
    materializeContract,
    /run: npm --workspace catch-marketing run materialize:organizer-listings:deploy/u
  );
  assert.doesNotMatch(materializeContract, /organizer-claim-target-readiness/u);
  assert.doesNotMatch(
    surfaceValidationWorkflow,
    /check_promotion_bridge\.mjs/u,
    "marketing validation must not invoke the retired repo-backed promotion bridge"
  );
});
