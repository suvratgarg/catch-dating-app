import {strict as assert} from "node:assert";
import {describe, it} from "node:test";
import {OrganizerFormResponseDocument} from
  "../shared/generated/firestoreAdminTypes";
import {formAutomationEventKind} from "./organizerFormAutomations";

const response = (
  status: OrganizerFormResponseDocument["status"]
): OrganizerFormResponseDocument => ({status} as OrganizerFormResponseDocument);

describe("organizer form automation lifecycle", () => {
  it("fires once when an immutable submitted response is created", () => {
    assert.equal(
      formAutomationEventKind(undefined, response("submitted")),
      "submitted"
    );
    assert.equal(
      formAutomationEventKind(response("submitted"), response("submitted")),
      null
    );
  });

  it("fires once when a submitted response is withdrawn", () => {
    assert.equal(
      formAutomationEventKind(response("submitted"), response("withdrawn")),
      "withdrawn"
    );
    assert.equal(
      formAutomationEventKind(response("withdrawn"), response("withdrawn")),
      null
    );
    assert.equal(
      formAutomationEventKind(undefined, response("withdrawn")),
      null
    );
  });
});
