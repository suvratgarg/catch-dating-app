import assert from "node:assert/strict";
import test from "node:test";
import {isEventPubliclyAccessible} from "./eventPublicationAccess";

test("publication preserves legacy reads and denies incomplete setup states",
  () => {
    assert.equal(isEventPubliclyAccessible({status: "active"}), true);
    assert.equal(isEventPubliclyAccessible({publicationState: "published",
      setupRevision: 2}), true);
    for (const publicationState of ["private", null, undefined, "public", ""]) {
      assert.equal(isEventPubliclyAccessible({publicationState}), false);
    }
    for (const setupRevision of [1, 0, null, undefined]) {
      assert.equal(isEventPubliclyAccessible({setupRevision}), false);
    }
  });
