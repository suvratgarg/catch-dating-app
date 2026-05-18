/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {
  cohortIds,
  EventPolicyBundleDoc,
  quotePriceInPaise,
  quoteAttendeeCancellation,
} from "./eventPolicy";

test("quoteAttendeeCancellation follows attendee policy windows", () => {
  const startTimeMillis = Date.parse("2026-05-02T12:00:00.000Z");

  assert.deepEqual(
    quoteAttendeeCancellation({
      policy: policy("standard"),
      paidAmountInPaise: 40000,
      startTimeMillis,
      nowMillis: Date.parse("2026-05-01T11:00:00.000Z"),
    }),
    {
      remedy: "fullRefund",
      refundAmountInPaise: 40000,
      creditAmountInPaise: 0,
    }
  );
  assert.deepEqual(
    quoteAttendeeCancellation({
      policy: policy("standard"),
      paidAmountInPaise: 40000,
      startTimeMillis,
      nowMillis: Date.parse("2026-05-02T05:00:00.000Z"),
    }),
    {
      remedy: "platformCredit",
      refundAmountInPaise: 0,
      creditAmountInPaise: 20000,
    }
  );
  assert.deepEqual(
    quoteAttendeeCancellation({
      policy: policy("standard"),
      paidAmountInPaise: 40000,
      startTimeMillis,
      nowMillis: Date.parse("2026-05-02T07:00:00.000Z"),
    }),
    {
      remedy: "noRefund",
      refundAmountInPaise: 0,
      creditAmountInPaise: 0,
    }
  );
});

test(
  "quoteAttendeeCancellation releases waitlisted attendees without payment",
  () => {
    assert.deepEqual(
      quoteAttendeeCancellation({
        policy: policy("strict"),
        paidAmountInPaise: 40000,
        startTimeMillis: Date.parse("2026-05-02T12:00:00.000Z"),
        nowMillis: Date.parse("2026-05-02T11:00:00.000Z"),
        isWaitlisted: true,
      }),
      {
        remedy: "waitlistRelease",
        refundAmountInPaise: 0,
        creditAmountInPaise: 0,
      }
    );
  }
);

test("quotePriceInPaise includes same-cohort waitlist demand", () => {
  assert.equal(
    quotePriceInPaise({
      policy: {
        ...policy("standard"),
        pricing: {
          basePriceInPaise: 25000,
          cohortAdjustmentsInPaise: {},
          demandPricingRules: [{
            pricedCohortId: cohortIds.menInterestedInWomen,
            balancingCohortId: cohortIds.womenInterestedInMen,
            stepAdjustmentInPaise: 10000,
            maxAdjustmentInPaise: 30000,
            freeSkew: 1,
            demandStep: 1,
          }],
        },
      },
      cohortId: cohortIds.menInterestedInWomen,
      roster: {
        bookedCountsByCohort: {
          [cohortIds.menInterestedInWomen]: 2,
          [cohortIds.womenInterestedInMen]: 2,
        },
        waitlistedCountsByCohort: {
          [cohortIds.menInterestedInWomen]: 3,
        },
        totalBooked: 4,
      },
    }),
    55000
  );
});

function policy(
  policyId: EventPolicyBundleDoc["cancellation"]["policyId"]
): EventPolicyBundleDoc {
  return {
    version: 1,
    admission: {
      format: "open",
      capacityLimit: 20,
      waitlistPolicy: {mode: "rankedOffer", offerWindowMinutes: 20},
      inviteRequired: false,
      membershipRequired: false,
      manualApprovalRequired: false,
      privateAccessPolicy: {
        mode: "none",
        inviteCodeHint: null,
        privateLinkEnabled: false,
      },
      cohortCapacityLimits: {},
      balancedRatioPolicy: null,
    },
    pricing: {
      basePriceInPaise: 40000,
      cohortAdjustmentsInPaise: {},
      demandPricingRules: [],
    },
    cancellation: {policyId},
    settlement: {hostPayoutTiming: "afterEventCompletion"},
  };
}
