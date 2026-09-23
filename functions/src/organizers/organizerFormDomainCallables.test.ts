import {strict as assert} from "node:assert";
import {describe, it} from "node:test";
import {parseDomainRequest} from "./organizerFormDomainCallables";

describe("organizer form domain management input", () => {
  it("accepts exact action-specific fields", () => {
    assert.deepEqual(parseDomainRequest({action: "reserve",
      hostname: "apply.client.example", organizerId: "organizer-a",
      formId: "form-a"}), {action: "reserve",
      hostname: "apply.client.example", organizerId: "organizer-a",
      formId: "form-a"});
    assert.deepEqual(parseDomainRequest({action: "verify",
      hostname: "apply.client.example", organizerId: "organizer-a"}),
    {action: "verify", hostname: "apply.client.example",
      organizerId: "organizer-a"});
  });

  it("rejects client-supplied hosting or certificate authority", () => {
    for (const request of [
      {action: "reserve", hostname: "apply.client.example",
        organizerId: "organizer-a", formId: "form-a",
        expectedCname: "attacker.example"},
      {action: "certificateReady", hostname: "apply.client.example",
        organizerId: "organizer-a"},
      {action: "verify", hostname: "app.catchdates.com",
        organizerId: "organizer-a"},
      {action: "revoke", hostname: "apply.client.example",
        organizerId: "organizer-a", formId: "form-a"},
    ]) assert.throws(() => parseDomainRequest(request));
  });
});
