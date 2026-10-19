import assert from "node:assert/strict";
import test from "node:test";
import {requestHostname, isCatchWebsiteHost, isCatchIndexingHost} from "../../src/app/surfaceHostPolicy.ts";
test("Host parsing does not grant unknown/custom tenants a marketing surface", () => {
  assert.equal(requestHostname("forms.client.example:3107"), "forms.client.example");
  assert.equal(isCatchWebsiteHost(requestHostname("forms.client.example:3107")), false);
  assert.equal(isCatchWebsiteHost(requestHostname("catchdates.com:443")), true);
  assert.equal(isCatchWebsiteHost(requestHostname("CATCHDATES.COM")), true);
  assert.equal(isCatchWebsiteHost(requestHostname("catchdates-dev--preview.web.app")), true);
  assert.equal(isCatchWebsiteHost(requestHostname("unknown.web.app")), false);
  for (const bad of [null, "", "catchdates.com@evil.example", "catchdates.com/", "catchdates.com#evil", "catchdates.com evil", "catchdates.com\\evil"]) {
    assert.equal(requestHostname(bad), null);
  }
});

test("production images still deny indexing on preview, default and custom hosts", () => {
  for (const host of ["catchdates.com", "www.catchdates.com"]) assert.equal(isCatchIndexingHost(host), true);
  for (const host of [null, "localhost", "catch-dating-app-64e51.web.app", "catch-dating-app-64e51--next-release-abc.web.app", "forms.client.example", "catchdates.com.evil.example"]) assert.equal(isCatchIndexingHost(host), false);
});
