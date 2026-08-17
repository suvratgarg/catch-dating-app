import assert from "node:assert/strict";
import test from "node:test";
import {
  organizerPublicationPatch,
  organizerPublicationRoute,
} from "./mutateOrganizer";
import {defaultOrganizerPublicSlug} from "./organizerIdentity";

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

test("publishing a legacy organizer derives a reservable website route", () => {
  const organizerId = "fJlZbx9BewUXsOZwQKv3";
  const slug = defaultOrganizerPublicSlug("Saket Run Club", organizerId);

  assert.deepEqual(
    organizerPublicationRoute(organizerId, {
      name: "Saket Run Club",
      location: "in-dl-delhi-ncr",
    }),
    {
      slug,
      citySlug: "delhi-ncr",
      canonicalPath: `/organizers/${slug}/`,
      needsIdentityPatch: true,
    }
  );
});

test("publishing preserves an existing organizer route identity", () => {
  assert.deepEqual(
    organizerPublicationRoute("organizer-one", {
      name: "Saket Run Club",
      location: "in-dl-delhi-ncr",
      publicPage: {
        slug: "saket-run-club",
        citySlug: "delhi-ncr",
        canonicalPath: "/organizers/saket-run-club/",
        publishStatus: "draft",
        indexStatus: "noindex",
        robots: "noindex, follow",
        seoTitle: null,
        seoDescription: null,
        lastRenderedAt: null,
      },
    }),
    {
      slug: "saket-run-club",
      citySlug: "delhi-ncr",
      canonicalPath: "/organizers/saket-run-club/",
      needsIdentityPatch: false,
    }
  );
});
