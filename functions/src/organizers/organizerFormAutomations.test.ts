import {strict as assert} from "node:assert";
import {describe, it} from "node:test";
import {
  OrganizerFormAutomationRuleDocument,
  OrganizerFormDocument,
  OrganizerFormResponseDocument,
} from
  "../shared/generated/firestoreAdminTypes";
import {
  formAutomationEventKind,
  updateConsequenceProjection,
} from "./organizerFormAutomations";
import {organizerFormFollowUpUnavailableMessage} from
  "./organizerFormConversions";

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

  it("separates manual conversion from configured automations", () => {
    assert.match(
      organizerFormFollowUpUnavailableMessage,
      /approved messaging template and recipient permission/
    );
  });

  it("tracks enabled action kinds once per rule", () => {
    const next = updateConsequenceProjection(
      projection(),
      null,
      rule(true, ["createCrmContact", "createCrmContact", "notifyTeam"])
    );
    assert.deepEqual(next?.enabledAutomationActionKinds, [
      "notifyTeam",
      "createCrmContact",
    ]);
    assert.equal(
      next?.enabledAutomationActionKindCounts.createCrmContact,
      1
    );
  });

  it("keeps an action visible while another enabled rule still owns it", () => {
    const current = projection();
    current.enabledAutomationActionKindCounts.createCrmContact = 2;
    current.enabledAutomationActionKinds = ["createCrmContact"];
    const next = updateConsequenceProjection(
      current,
      rule(true, ["createCrmContact"]),
      rule(false, ["createCrmContact"])
    );
    assert.equal(
      next?.enabledAutomationActionKindCounts.createCrmContact,
      1
    );
    assert.deepEqual(next?.enabledAutomationActionKinds, ["createCrmContact"]);
  });

  it("does not pretend a legacy projection is exact", () => {
    const current = {...projection(), coverage: "identityOnly" as const};
    assert.equal(
      updateConsequenceProjection(
        current,
        null,
        rule(true, ["notifyTeam"])
      ),
      current
    );
  });
});

function projection(): NonNullable<
  OrganizerFormDocument["consequenceProjection"]
  > {
  return {
    version: 1,
    coverage: "exact",
    identityPolicy: "emailVerified",
    enabledAutomationActionKinds: [],
    enabledAutomationActionKindCounts: {
      notifyTeam: 0,
      addOrganizerTag: 0,
      createCrmContact: 0,
      addApplicationQueue: 0,
      proposeEventAttendee: 0,
      signedWebhook: 0,
      campaignHandoff: 0,
    },
  };
}

function rule(
  enabled: boolean,
  kinds: OrganizerFormAutomationRuleDocument["actions"][number]["kind"][]
): OrganizerFormAutomationRuleDocument {
  return {
    enabled,
    actions: kinds.map((kind, index) => ({
      actionId: `action-${index}`,
      kind,
      tagId: null,
      eventId: null,
      webhookUrl: null,
      webhookSecret: null,
      channel: null,
    })),
  } as OrganizerFormAutomationRuleDocument;
}
