import assert from "node:assert/strict";
import test from "node:test";
import {organizerFixture} from "./organizerFixture.mjs";
import {projectPublicOrganizer} from "../../src/server/publicOrganizerProjection.ts";
import * as narrow from "./publicValidators.mjs";
import * as repository from "../../../tool/contracts/generated/schema_contract_validators.mjs";
const markets = new Set(["indore", "mumbai"]);
test("request DTO excludes contact, ownership identities and arbitrary nested data", () => {
  const data = organizerFixture();
  data.ownerUserId = "private-owner-marker";
  const listing = projectPublicOrganizer("next-proof", data, markets);
  assert(listing);
  const serialized = JSON.stringify(listing);
  for (const secret of [data.email, data.phoneNumber, "private-owner-marker"]) {
    if (secret) assert(!serialized.includes(secret));
  }
  data.publicProfile = {headline: "Public", facts: [{label: "Label", value: "Value", privateToken: "secret"}]};
  assert.equal(projectPublicOrganizer("next-proof", data, markets), null);
});
test("public publication and live market gates run on every projection", () => {
  const data = organizerFixture();
  assert(projectPublicOrganizer("next-proof", data, markets));
  for (const state of ["draft", "qa", "suppressed", "removed"]) {
    data.publicPage.publishStatus = state;
    assert.equal(projectPublicOrganizer("next-proof", data, markets), null);
  }
  data.publicPage.publishStatus = "published";
  data.publicPage.indexStatus = "noindex";
  data.publicPage.robots = "noindex, follow";
  assert(projectPublicOrganizer("next-proof", data, markets));
  assert.equal(projectPublicOrganizer("next-proof", data, new Set(["mumbai"])), null);
});
test("runtime validator adapter agrees with repository generated validators", () => {
  const valid = organizerFixture();
  for (const data of [valid, {...valid, name: 17}, {...valid, ownership: {state: "unknown"}}, null]) {
    assert.equal(narrow.validateOrganizerDocument(data), repository.validateOrganizerDocument(data));
  }
  const listing = projectPublicOrganizer("next-proof", valid, markets);
  for (const value of [listing, {...listing, privateToken: "no"}, {...listing, name: 123}, null]) {
    assert.equal(narrow.validateWebsiteHostListingProjection(value), repository.validateWebsiteHostListingProjection(value));
  }
});
