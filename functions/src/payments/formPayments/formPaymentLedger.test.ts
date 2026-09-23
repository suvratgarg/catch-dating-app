import assert from "node:assert/strict";
import test from "node:test";
import type {CallableRequest} from "firebase-functions/v2/https";
import {createFormPaymentFixture} from "./formPaymentTestStore";
import {listOrganizerFormPaymentsHandler, projectLedgerRow} from
  "./formPaymentLedger";

const data = {organizerId: "org", formId: "form", statuses: [],
  cursor: null, limit: 20};
function request(input: unknown): CallableRequest<unknown> {
  return {auth: {uid: "host"}, data: input} as CallableRequest<unknown>;
}

test("ledger checks manager and form ownership before listing payments",
  async () => {
    const h = createFormPaymentFixture();
    let managers = 0;
    const deps = {db: () => h.db, rateLimit: async () => undefined,
      requireManager: async (): Promise<void> => {
        managers++;
        throw new Error("Not manager");
      }};
    await assert.rejects(listOrganizerFormPaymentsHandler(request(data), deps),
      /Not manager/u);
    assert.equal(managers, 1);
    deps.requireManager = async () => {
      managers++;
    };
    await assert.rejects(listOrganizerFormPaymentsHandler(
      request({...data, organizerId: "other"}), deps), /Form not found/u);
    await assert.rejects(listOrganizerFormPaymentsHandler(
      request({...data, cursor: "foreign-or-malformed"}), deps),
    /cursor is invalid/u);
    await assert.rejects(listOrganizerFormPaymentsHandler(
      request({...data, limit: 10000}), deps));
  });

test("ledger projects money and references without private respondent state",
  async () => {
    const h = createFormPaymentFixture();
    const {payment, paymentId} = await h.reserve();
    const row = projectLedgerRow(paymentId, payment);
    assert.equal(row.amountPaise, 10000);
    assert.equal(row.responseId, null);
    assert.equal(row.providerPaymentId, null);
    assert.equal("identity" in row, false);
    assert.equal("respondentUid" in row, false);
    assert.equal("draftId" in row, false);
    assert.equal("answersHash" in row, false);
    assert.equal("connectionId" in row, false);
    assert.equal("accountId" in row, false);
  });
