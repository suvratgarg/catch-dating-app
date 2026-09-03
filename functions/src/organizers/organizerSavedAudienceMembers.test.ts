import assert from "node:assert/strict";
import test from "node:test";
import {savedAudienceMemberPage} from "./organizerSavedAudienceMembers";

const input = {organizerId: "org-1", audienceId: "group-1", revision: 1,
  rows: ["a", "b", "c"].map((contactId) => ({contactId})), limit: 2};

test("member pages exhaust the exact set without omissions or duplicates",
  () => {
    const first = savedAudienceMemberPage(input);
    const last = savedAudienceMemberPage({...input, cursor: first.nextCursor});
    assert.deepEqual([...first.rows, ...last.rows], input.rows);
    assert.equal(last.nextCursor, null);
  });

test("changed members, rule revision and foreign scope invalidate the cursor",
  () => {
    const cursor = savedAudienceMemberPage(input).nextCursor;
    for (const changed of [{rows: input.rows.slice(1)}, {revision: 2},
      {organizerId: "other"}, {audienceId: "other"}]) {
      assert.throws(() => savedAudienceMemberPage({...input, ...changed,
        cursor}),
      {code: "aborted"});
    }
    assert.throws(() => savedAudienceMemberPage({...input, cursor: "garbage"}),
      {code: "invalid-argument"});
  });
