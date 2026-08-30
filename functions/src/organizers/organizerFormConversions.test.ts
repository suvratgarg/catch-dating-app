import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {crmContactConversionTarget} from "./organizerFormConversions";

const submittedAt = admin.firestore.Timestamp.fromMillis(1_000);

test("new form contacts retain the form response provenance", () => {
  const target = crmContactConversionTarget({
    existingResultId: null,
    responseId: "response-1",
    formId: "form-1",
    submittedAt,
  });

  assert.match(target.contactId, /^formcontact_[a-f0-9]{32}$/u);
  assert.deepEqual(target.origin, {
    kind: "hostFormResponse",
    formId: "form-1",
    responseId: "response-1",
    observedAt: submittedAt,
  });
});

test("matched form contacts still append the form response provenance", () => {
  const target = crmContactConversionTarget({
    existingResultId: "contact-existing",
    responseId: "response-1",
    formId: "form-1",
    submittedAt,
  });

  assert.equal(target.contactId, "contact-existing");
  assert.equal(target.origin.kind, "hostFormResponse");
  assert.equal(target.origin.responseId, "response-1");
});
