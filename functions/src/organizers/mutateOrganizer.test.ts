import assert from "node:assert/strict";
import test from "node:test";
import {organizerPublicationPatch} from "./mutateOrganizer";

test("publishing maps one owner intent to governed discovery fields", () => {
  assert.deepEqual(organizerPublicationPatch(true), {
    "appVisibility": "discoverable",
    "publicPage.publishStatus": "published",
    "publicPage.indexStatus": "indexReady",
    "publicPage.robots": "index, follow",
  });
});

test(
  "unpublishing preserves the workspace behind private discovery fields",
  () => {
    assert.deepEqual(organizerPublicationPatch(false), {
      "appVisibility": "hidden",
      "publicPage.publishStatus": "draft",
      "publicPage.indexStatus": "noindex",
      "publicPage.robots": "noindex, follow",
    });
  }
);
