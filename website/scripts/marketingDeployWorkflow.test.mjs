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
const packageJson = JSON.parse(
  fs.readFileSync(path.join(websiteRoot, "package.json"), "utf8")
);

test("production deploy materializes receipt-aware organizer projections before Firebase predeploy", () => {
  assert.equal(
    packageJson.scripts["materialize:organizer-listings:deploy"],
    "npm run generate:organizer-listings && " +
      "npm run generate:organizer-listings:demo && " +
      "npm run check:organizer-listings"
  );

  const readinessStep = workflow.indexOf(
    "- name: Read production organizer claim readiness"
  );
  const materializeStep = workflow.indexOf(
    "- name: Materialize verified production organizer listings"
  );
  const deployStep = workflow.indexOf("- name: Deploy production marketing site");

  assert.ok(readinessStep >= 0, "production readiness read step must exist");
  assert.ok(
    materializeStep > readinessStep,
    "receipt-aware projections must be materialized after the production read"
  );
  assert.ok(
    deployStep > materializeStep,
    "Firebase predeploy must run after receipt-aware projections are materialized"
  );

  const materializeContract = workflow.slice(materializeStep, deployStep);
  assert.match(
    materializeContract,
    /ORGANIZER_CLAIM_TARGET_PROJECT_ID: catch-dating-app-64e51/u
  );
  assert.match(
    materializeContract,
    /ORGANIZER_CLAIM_TARGET_RECEIPT: \/tmp\/organizer-claim-target-readiness\.json/u
  );
  assert.match(
    materializeContract,
    /run: npm --workspace catch-marketing run materialize:organizer-listings:deploy/u
  );
});
