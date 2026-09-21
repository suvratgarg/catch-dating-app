import assert from "node:assert/strict";
import test from "node:test";
import {
  evaluateUploadIdentity, identityReadCommands, inspectUploadIdentity,
  inspectorPermissions, mergeUploadCors, parseArgs, provisioningCommands, signingPermission,
  uploadIdentityTarget,
} from "./form_upload_identity.mjs";
import {runEnvironmentReadiness} from "./check_environment_readiness.mjs";

const target = uploadIdentityTarget("dev", "catchdates-dev");
const member = `serviceAccount:${target.email}`;
const binding = (role, who = member) => ({role, members: [who]});
function readyState() {
  return {
    signingApi: [{config: {name: "iamcredentials.googleapis.com"}}],
    account: {email: target.email, disabled: false},
    role: {includedPermissions: [signingPermission], stage: "GA"},
    inspectorRole: {includedPermissions: inspectorPermissions, stage: "GA"},
    projectPolicy: {bindings: [binding("roles/datastore.user"),
      binding(target.inspectorRole, `serviceAccount:${target.deployer}`)]},
    bucket: {cors: mergeUploadCors(target)},
    bucketPolicy: {bindings: [binding("roles/storage.objectCreator")]},
    accountPolicy: {bindings: [binding(target.role),
      binding("roles/iam.serviceAccountUser", `serviceAccount:${target.deployer}`)]},
  };
}

test("dedicated upload account needs only create access and self signing", () => {
  const state = readyState();
  assert.equal(evaluateUploadIdentity(target, state).ready, true);
  state.projectPolicy.bindings.push(binding("roles/editor", "user:other@example.com"));
  assert.equal(evaluateUploadIdentity(target, state).ready, true);
  for (const key of ["bucket", "signingApi", "account", "role", "projectPolicy", "bucketPolicy", "accountPolicy"]) {
    const broken = {...readyState(), [key]: null};
    assert.equal(evaluateUploadIdentity(target, broken).ready, false, key);
  }
});

test("broader roles or shared runtime delegation fail closed without modifying IAM", () => {
  for (const mutate of [
    (s) => s.role.includedPermissions.push("iam.serviceAccounts.getAccessToken"),
    (s) => s.projectPolicy.bindings.push(binding("roles/editor")),
    (s) => s.bucketPolicy.bindings.push(binding("roles/storage.objectAdmin")),
    (s) => s.accountPolicy.bindings[0].members.push("serviceAccount:123-compute@developer.gserviceaccount.com"),
    (s) => {s.account.disabled = true;},
  ]) {
    const state = readyState(); mutate(state);
    const result = evaluateUploadIdentity(target, state);
    assert.equal(result.ready, false);
    assert.throws(() => provisioningCommands(target, result), /Refusing/);
  }
});

test("provisioning is explicit, idempotent, and never changes the default runtime", () => {
  assert.throws(() => parseArgs(["--env", "prod", "--apply"]), /allow-prod/);
  assert.equal(parseArgs(["--env", "prod"]).apply, false);
  assert.deepEqual(provisioningCommands(target, evaluateUploadIdentity(target, readyState())), []);
  const commands = provisioningCommands(target, evaluateUploadIdentity(target, {}));
  assert.equal(commands.length, 10);
  assert.equal(JSON.stringify(commands).includes("-compute@"), false);
  assert.equal(JSON.stringify(commands).includes("roles/iam.serviceAccountTokenCreator"), false);
  assert.equal(JSON.stringify(commands).includes("keys"), false);
});

test("metadata failures never become an apply plan", () => {
  assert.throws(() => inspectUploadIdentity(target, () => ({status: 1, stderr: "PERMISSION_DENIED"})), /Could not read/);
  assert.throws(() => inspectUploadIdentity(target, () => ({status: 0, stdout: "[]"})), /Invalid/);
});

test("deployment prerequisite rejects missing signing and passes configured identity", () => {
  const commands = identityReadCommands(target);
  const state = readyState();
  const manifest = {environments: ["dev"], requirements: [{
    id: "upload", kind: "form-upload-identity", environments: ["dev"],
    requiredWhen: {anyDeployTarget: ["functions:createOrganizerFormAssetIntent"]},
  }]};
  const runCommand = ({args}) => {
    if (args[0] === "projects" && args[1] === "describe") {
      return {status: 0, stdout: JSON.stringify({projectId: target.projectId, projectNumber: "123", lifecycleState: "ACTIVE"})};
    }
    const key = Object.keys(commands).find((k) => commands[k].every((v, i) => args[i] === v));
    assert.ok(key, args.join(" "));
    return {status: 0, stdout: JSON.stringify(state[key])};
  };
  const run = () => runEnvironmentReadiness({aliases: {dev: target.projectId},
    environments: ["dev"], manifest, targets: ["functions:createOrganizerFormAssetIntent"], runCommand});
  assert.equal(run().ready, true);
  state.accountPolicy.bindings.shift();
  assert.equal(run().ready, false);
});

test("browser POST CORS is limited to Catch origins and preserves other rules", () => {
  const existing = [{origin: ["https://other.example"], method: ["GET"]}];
  const merged = mergeUploadCors(target, existing);
  assert.deepEqual(merged[0], existing[0]);
  assert.deepEqual(merged[1].method, ["POST"]);
  assert.deepEqual(merged[1].origin, target.origins);
  assert.equal(merged[1].origin.includes("*"), false);
  assert.equal(mergeUploadCors(target, merged), merged);
});
