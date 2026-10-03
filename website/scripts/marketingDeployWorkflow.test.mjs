import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import {planAffected} from "../../tool/harness/lib/component_graph.mjs";
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
const rootPackageJson = JSON.parse(
  fs.readFileSync(path.join(repoRoot, "package.json"), "utf8")
);

for (const {name, skipBuild, script} of [
  {name: "Build marketing website", skipBuild: false, script: "build"},
  {
    name: "Validate marketing build prerequisites without emitting a bundle",
    skipBuild: true,
    script: "typecheck",
  },
]) {
  test(`marketing ${script} retains the sole organizer and route prerequisite gate`, () => {
    const step = surfaceValidationWorkflow.split(/\n      - /u)
      .find((candidate) => candidate.startsWith(`name: ${name}\n`));
    assert.ok(step, `${name} must run in the shared validation workflow`);
    assert.ok(step.includes(
      `if: \${{ inputs.surface == 'marketing' && ${skipBuild ? "" : "!"}inputs.skip_deployable_build }}`
    ));
    assert.match(step, new RegExp(`^        run: npm run web:marketing:${script}$`, "mu"));
    assert.doesNotMatch(step, /continue-on-error/u);
    assert.equal(
      rootPackageJson.scripts[`web:marketing:${script}`],
      `npm --workspace catch-marketing run ${script}`
    );
    // npm's typecheck lifecycle owns these gates for both validation modes
    // and standalone builds. Keep failure propagation before Vite/postbuild.
    assert.ok(packageJson.scripts.build.startsWith("npm run typecheck && "));
    const prerequisites = packageJson.scripts.pretypecheck.split(" && ");
    for (const check of ["check:organizer-listings", "check:routes"]) {
      assert.equal(prerequisites.filter((command) => command === `npm run ${check}`).length, 1);
      assert.ok(packageJson.scripts[check], `${check} must remain a standalone command`);
      assert.ok(!surfaceValidationWorkflow.includes(`run: npm --workspace catch-marketing run ${check}\n`),
        `${check} must not run again outside pretypecheck`);
    }
    assert.ok(prerequisites.every((command) => /^npm run [\w:-]+$/u.test(command)),
      "pretypecheck must stop at a failed prerequisite");
  });
}

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


test("capture-only native edits validate in CI without triggering a production Marketing build", () => {
  const ci = fs.readFileSync(path.join(repoRoot, ".github/workflows/ci.yml"), "utf8");
  const capture = fs.readFileSync(path.join(repoRoot, ".github/workflows/capture-freshness-ci.yml"), "utf8");
  const graph = JSON.parse(fs.readFileSync(path.join(repoRoot, "tool/harness/component_graph.json"), "utf8"));
  for (const input of ["lib/**", "test/**", "pubspec.yaml", "pubspec.lock",
    "packages/*/pubspec.yaml", "packages/*/lib/**", "packages/*/assets/**", "tool/ui_capture/**"]) {
    assert.ok(!workflow.includes(`      - "${input}"`), `Capture-only input must not deploy: ${input}`);
    const changedPath = input.replace("packages/*", "packages/catch_ui").replace("**", "example.dart");
    const plan = planAffected({changedPaths: [changedPath], graph, mode: "main"});
    assert.ok(plan.complete, `Uncovered capture input: ${changedPath}`);
    assert.ok(plan.operations.ciTargets.includes("capture_freshness"), `Missing capture obligation: ${changedPath}`);
  }
  assert.match(ci, /uses: \.\/\.github\/workflows\/capture-freshness-ci\.yml/u);
  assert.match(capture, /run: node tool\/marketing\/sync_website_media\.mjs --check/u);
  assert.match(capture, /run: node tool\/marketing\/export_app_screenshots\.mjs --check-design-json/u);
  assert.doesNotMatch(capture, /continue-on-error|--update|--update-goldens/u);
  const mediaStep = surfaceValidationWorkflow.split(/\n      - /u)
    .find(step => step.startsWith("name: Check marketing media\n"));
  assert.match(mediaStep, /!inputs\.capture_freshness_in_ci/u);
  assert.match(mediaStep, /run: node tool\/marketing\/sync_website_media\.mjs --check/u);
});
