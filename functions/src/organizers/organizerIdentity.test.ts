import assert from "node:assert/strict";
import test from "node:test";
import {
  defaultOrganizerPublicSlug,
  normalizeOrganizerPublicSlug,
  requireFirestoreAutoId,
} from "./organizerIdentity";

test("accepts only Firestore auto-ids as reserved organizer identities", () => {
  assert.equal(
    requireFirestoreAutoId("AbCdEfGhIjKlMnOpQr12"),
    "AbCdEfGhIjKlMnOpQr12"
  );
  assert.throws(
    () => requireFirestoreAutoId("courtside"),
    /20-character Firestore auto-id/
  );
});

test("derives stable public slugs independently from document ids", () => {
  const first = defaultOrganizerPublicSlug(
    "Courtside Mumbai",
    "AbCdEfGhIjKlMnOpQr12"
  );
  const second = defaultOrganizerPublicSlug(
    "Courtside Mumbai",
    "ZyXwVuTsRqPoNmLkJi98"
  );
  assert.match(first, /^courtside-mumbai-[a-f0-9]{12}$/);
  assert.notEqual(first, second);
  assert.equal(
    normalizeOrganizerPublicSlug(" Courtside Mumbai "),
    "courtside-mumbai"
  );
});
