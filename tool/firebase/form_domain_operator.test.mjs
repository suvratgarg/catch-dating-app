import assert from "node:assert/strict";
import test from "node:test";
import {configuredDomainTarget, parseDomainOperatorArgs, verifyDomainProviderTarget} from "./form_domain_operator.mjs";

const base = ["--env", "prod", "--hostname", "forms.client.example"];
const owner = ["--organizer-id", "organizer-1", "--form-id", "form-1", "--requested-by-manager", "manager-1"];
const activate = [...base, "--action", "activate", ...owner, "--generation", "2", "--site-key", "public_site_key_for_website"];

test("operator defaults read-only and production apply requires an explicit guard", () => {
  const status = parseDomainOperatorArgs(base);
  assert.equal(status.action, "status"); assert.equal(status.apply, false);
  const plan = parseDomainOperatorArgs(activate);
  assert.equal(plan.apply, false); assert.equal(plan.generation, 2);
  assert.throws(() => parseDomainOperatorArgs([...activate, "--apply"]), /allow-prod/);
  assert.equal(parseDomainOperatorArgs([...activate, "--apply", "--allow-prod"]).apply, true);
  assert.throws(() => parseDomainOperatorArgs([...base, "--apply", "--allow-prod"]), /Status cannot/);
});

test("operator arguments reject duplicates, missing values and ambiguous generation", () => {
  for (const args of [[], ["--env", "dev"], [...base, "--env", "dev"], [...base, "--site-key"],
    [...base, "--unknown"], [...base, "--action", "delete-everything"],
    [...base, "--action", "reserve"], [...base, "--action", "verify", ...owner],
    [...base, "--action", "reserve", ...owner, "--generation", "1"],
    [...base, "--action", "activate", ...owner, "--generation", "1"]]) {
    assert.throws(() => parseDomainOperatorArgs(args));
  }
  for (const generation of ["0", "-1", "01", "1.5", "1e3", "9007199254740992"]) {
    assert.throws(() => parseDomainOperatorArgs([...base, "--action", "verify", ...owner, "--generation", generation]), /positive safe/);
  }
});

test("configured production target is the marketing site and dev has no invented fallback", () => {
  const target = configuredDomainTarget(parseDomainOperatorArgs(base));
  assert.equal(target.projectId, "catch-dating-app-64e51");
  assert.equal(target.siteId, "catch-dating-app-64e51");
  assert.equal(target.expectedCname, "catch-dating-app-64e51.web.app");
  assert.equal(target.hostname, "forms.client.example");
  assert.throws(() => configuredDomainTarget(parseDomainOperatorArgs(["--env", "dev", "--hostname", "forms.client.example"])), /exactly one marketing/);
  assert.throws(() => configuredDomainTarget(parseDomainOperatorArgs([...base.slice(0, 3), "Forms.client.example"])), /canonical subdomain/);
});

test("live target verification must bind project ID, number, active state and exact site", async () => {
  const target = configuredDomainTarget(parseDomainOperatorArgs(base));
  const project = {name: `projects/${target.projectNumber}`, projectId: target.projectId, state: "ACTIVE"};
  const site = {name: target.parent, defaultUrl: `https://${target.siteId}.web.app`};
  for (const [first, second, expected] of [
    [project, site, true], [{...project, name: "projects/999999"}, site, false],
    [{...project, projectId: "other-project"}, site, false], [{...project, state: "DELETE_REQUESTED"}, site, false],
    [project, {...site, name: "projects/999/sites/other"}, false],
    [project, {...site, defaultUrl: "https://catchdates-host.web.app"}, false],
  ]) {
    const calls = [];
    const run = () => verifyDomainProviderTarget(target, {request: async (config) => {
      calls.push(config); return {status: 200, data: calls.length === 1 ? first : second};
    }});
    if (expected) assert.equal((await run()).siteId, target.siteId);
    else await assert.rejects(run, /does not match/);
    assert.ok(calls.every((call) => call.method === "GET" && call.retry === false && call.maxRedirects === 0));
  }
});
