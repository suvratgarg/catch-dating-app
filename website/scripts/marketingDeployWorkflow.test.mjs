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
const exactBuildWorkflow = fs.readFileSync(
  path.join(repoRoot, ".github", "workflows", "_web-hosting-build.yml"),
  "utf8"
);
const exactPromoteWorkflow = fs.readFileSync(
  path.join(repoRoot, ".github", "workflows", "_web-hosting-promote.yml"),
  "utf8"
);
const packageJson = JSON.parse(
  fs.readFileSync(path.join(websiteRoot, "package.json"), "utf8")
);

test("production snapshot materializes organizer projections before its one uncredentialed exact build", () => {
  assert.equal(
    packageJson.scripts["materialize:organizer-listings:deploy"],
    "node scripts/generateOrganizerListings.mjs " +
      "--firestore-project catch-dating-app-64e51 && " +
      "node scripts/generateOrganizerListings.mjs " +
      "--firestore-project catch-dating-app-64e51 --include-demo " +
      "--output src/generated/hostListings.demo.json && " +
      "npm run check:organizer-listings"
  );

  const materializeStep = exactBuildWorkflow.indexOf(
    "- name: Materialize the production organizer projection"
  );
  const buildStep = exactBuildWorkflow.indexOf(
    "- name: Build the exact production marketing bytes once"
  );

  assert.ok(materializeStep >= 0, "Firestore materialization step must exist");
  assert.ok(
    buildStep > materializeStep,
    "the exact Vite build must run after Firestore projections are materialized"
  );

  const materializeContract = exactBuildWorkflow.slice(materializeStep, buildStep);
  assert.match(
    materializeContract,
    /run: npm --workspace catch-marketing run materialize:organizer-listings:deploy/u
  );
  assert.doesNotMatch(materializeContract, /organizer-claim-target-readiness/u);
  assert.match(exactBuildWorkflow,
    /GCP_WEB_HOSTING_READONLY_WORKLOAD_IDENTITY_PROVIDER/u);
  assert.match(exactBuildWorkflow,
    /GCP_WEB_HOSTING_READONLY_SERVICE_ACCOUNT_EMAIL/u);
  const packageBuild = exactBuildWorkflow.slice(
    exactBuildWorkflow.indexOf("  build:")
  );
  assert.match(packageBuild,
    /actions\/artifacts\/\$SNAPSHOT_ARTIFACT_ID\/zip/u);
  assert.doesNotMatch(packageBuild,
    /google-github-actions\/auth|id-token: write|materialize:organizer-listings:deploy/u);
  assert.doesNotMatch(
    surfaceValidationWorkflow,
    /check_promotion_bridge\.mjs/u,
    "marketing validation must not invoke the retired repo-backed promotion bridge"
  );
  assert.match(workflow, /uses: \.\/\.github\/workflows\/_web-hosting-build\.yml/u);
  assert.match(workflow, /uses: \.\/\.github\/workflows\/_web-hosting-promote\.yml/u);
  assert.match(exactBuildWorkflow, /package_web_hosting\.mjs prepare/u);
  assert.match(exactPromoteWorkflow,
    /working-directory: build\/web-delivery\/package[\s\S]*--config firebase\.json/u);
  assert.doesNotMatch(exactPromoteWorkflow,
    /materialize:organizer-listings:deploy|vite build|web:marketing:build/u);
});
