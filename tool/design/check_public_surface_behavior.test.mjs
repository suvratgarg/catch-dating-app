import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";
import {repoRoot} from "../lib/repo_paths.mjs";
import {
  validateContractSchema,
  validatePublicSurfaceBehavior,
} from "./check_public_surface_behavior.mjs";

const matrixPath = `${repoRoot}/design/public_surface_behavior.json`;
const schemaPath = `${repoRoot}/design/public_surface_behavior.schema.json`;
const baseMatrix = JSON.parse(fs.readFileSync(matrixPath, "utf8"));
const schema = JSON.parse(fs.readFileSync(schemaPath, "utf8"));

test("validates the repository public surface behavior contract", () => {
  assert.deepEqual(validateContractSchema(baseMatrix, schema), []);
  assert.deepEqual(
    validatePublicSurfaceBehavior({matrix: baseMatrix, root: repoRoot}),
    [],
  );
});

test("rejects schema drift and undeclared contract fields", () => {
  const matrix = cloneMatrix();
  matrix.unownedInventory = true;
  assert.match(validateContractSchema(matrix, schema).join("\n"), /additional properties/u);
});

test("rejects source-backed enum drift", () => {
  const matrix = cloneMatrix();
  dimension(matrix, "organizer.claimState").values.pop();
  assert.match(
    errorsFor(matrix),
    /dimension organizer\.claimState: values must exactly match/u,
  );
});

test("rejects Dart booking-resolver enum drift", () => {
  const matrix = cloneMatrix();
  dimension(matrix, "event.availability").values.push("inventedAvailability");
  assert.match(
    errorsFor(matrix),
    /dimension event\.availability: values must exactly match/u,
  );
});

test("rejects duplicate configuration tuples", () => {
  const matrix = cloneMatrix();
  const surface = surfaceFor(matrix, "app.explore");
  const duplicate = structuredClone(surface.configurations[0]);
  duplicate.id = "app.explore.duplicateCrawled";
  surface.configurations.push(duplicate);
  assert.match(errorsFor(matrix), /duplicate decision tuple/u);
});

test("rejects a missing action expectation", () => {
  const matrix = cloneMatrix();
  const configuration = surfaceFor(matrix, "app.eventDetail").configurations[0];
  delete configuration.expectations["event.signup"];
  assert.match(errorsFor(matrix), /expectations: missing event\.signup/u);
});

test("rejects an unexpected action expectation", () => {
  const matrix = cloneMatrix();
  const configuration = surfaceFor(matrix, "web.organizerListing").configurations[0];
  configuration.expectations["event.unownedAction"] = {disposition: "visibleWeb"};
  assert.match(errorsFor(matrix), /expectations: unexpected event\.unownedAction/u);
});

test("rejects unknown route and screen references", () => {
  const matrix = cloneMatrix();
  const surface = surfaceFor(matrix, "app.organizerDetail");
  surface.routeIds = ["inventedOrganizerRoute"];
  surface.screenIds = ["screen.invented.organizer"];
  const errors = errorsFor(matrix);
  assert.match(errors, /unknown app route inventedOrganizerRoute/u);
  assert.match(errors, /unknown app screen screen\.invented\.organizer/u);
});

test("rejects evidence that no longer contains its asserted contract", () => {
  const matrix = cloneMatrix();
  surfaceFor(matrix, "web.claim").evidence[0].contains.push(
    "invented claim behavior proof",
  );
  assert.match(
    errorsFor(matrix),
    /must contain "invented claim behavior proof"/u,
  );
});

test("rejects a missing existing proof harness", () => {
  const matrix = cloneMatrix();
  const harness = matrix.proofHarnesses.find(
    (entry) => entry.id === "app.publicSurfaceBehavior",
  );
  harness.status = "existing";
  assert.match(
    errorsFor(matrix),
    /proof harness app\.publicSurfaceBehavior: missing evidence file/u,
  );
});

test("rejects a proof harness that omits a referenced surface", () => {
  const matrix = cloneMatrix();
  const harness = matrix.proofHarnesses.find(
    (entry) => entry.id === "web.publicSurfaceBehavior",
  );
  harness.surfaceIds = harness.surfaceIds.filter(
    (surfaceId) => surfaceId !== "web.claim",
  );
  assert.match(
    errorsFor(matrix),
    /web\.publicSurfaceBehavior does not register web\.claim/u,
  );
});

test("rejects a declared absence once its forbidden route exists", () => {
  const matrix = cloneMatrix();
  const absence = matrix.absentSurfaces.find(
    (entry) => entry.id === "web.eventDetail",
  );
  absence.forbiddenRouteIds = ["home"];
  assert.match(
    errorsFor(matrix),
    /route home now exists; replace the declared absence/u,
  );
});

test("rejects a surface with no actionable outcome", () => {
  const matrix = cloneMatrix();
  const surface = surfaceFor(matrix, "web.homeOrganizerDiscovery");
  for (const configuration of surface.configurations) {
    for (const expectation of Object.values(configuration.expectations)) {
      expectation.disposition = "visibleReadOnly";
    }
  }
  assert.match(errorsFor(matrix), /at least one configuration must have an actionable outcome/u);
});

function cloneMatrix() {
  return structuredClone(baseMatrix);
}

function dimension(matrix, id) {
  return matrix.dimensions.find((entry) => entry.id === id);
}

function surfaceFor(matrix, id) {
  return matrix.surfaces.find((entry) => entry.id === id);
}

function errorsFor(matrix) {
  return validatePublicSurfaceBehavior({matrix, root: repoRoot}).join("\n");
}
