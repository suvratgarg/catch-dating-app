/* eslint-disable require-jsdoc */
import {HttpsError} from "firebase-functions/v2/https";
import {EventDoc, UserProfileDoc} from "../shared/firestore";

export const cohortIds = {
  menInterestedInWomen: "menInterestedInWomen",
  womenInterestedInMen: "womenInterestedInMen",
  queerOrOpen: "queerOrOpen",
  nonBinaryOrOther: "nonBinaryOrOther",
} as const;

export type EventCohortId = typeof cohortIds[keyof typeof cohortIds];

export type EventAdmissionFormat =
  | "open"
  | "inviteOnly"
  | "manualApproval"
  | "fixedCohortCaps"
  | "balancedRatio"
  | "membersOnly";

export type EventWaitlistMode =
  | "disabled"
  | "rankedOffer"
  | "broadcastFirstComeFirstServed"
  | "manualReview";

export type EventOutOfRatioCohortPolicy =
  | "admitWithinGeneralCapacity"
  | "waitlist"
  | "manualReview"
  | "reject";

export type EventCancellationPolicyId = "flexible" | "standard" | "strict";

export type EventCancellationRemedy =
  | "fullRefund"
  | "platformCredit"
  | "noRefund"
  | "waitlistRelease";

export interface EventPolicyBundleDoc {
  version: number;
  admission: {
    format: EventAdmissionFormat;
    capacityLimit: number;
    waitlistPolicy?: {
      mode: EventWaitlistMode;
      offerWindowMinutes: number;
    };
    inviteRequired?: boolean;
    membershipRequired?: boolean;
    manualApprovalRequired?: boolean;
    cohortCapacityLimits?: Record<string, number>;
    balancedRatioPolicy?: {
      leftCohortId: string;
      rightCohortId: string;
      maxSkew: number;
      openingBufferPerCohort: number;
      outOfRatioCohortPolicy: EventOutOfRatioCohortPolicy;
    } | null;
  };
  pricing: {
    basePriceInPaise: number;
    cohortAdjustmentsInPaise?: Record<string, number>;
    demandPricingRules?: Array<{
      pricedCohortId: string;
      balancingCohortId: string;
      stepAdjustmentInPaise: number;
      maxAdjustmentInPaise: number;
      freeSkew: number;
      demandStep: number;
    }>;
  };
  cancellation: {
    policyId: EventCancellationPolicyId;
  };
  settlement: {
    hostPayoutTiming: "afterEventCompletion";
  };
}

export interface EventRosterSnapshot {
  bookedCountsByCohort: Record<string, number>;
  totalBooked: number;
}

export function eventPolicyFromEvent(event: EventDoc): EventPolicyBundleDoc {
  const policy = (event as EventDoc & {
    eventPolicy?: EventPolicyBundleDoc | null;
  }).eventPolicy;
  if (policy) return normalizePolicy(policy);
  return legacyPolicyFromEvent(event);
}

export function normalizePolicy(policy: EventPolicyBundleDoc):
  EventPolicyBundleDoc {
  return {
    version: 1,
    admission: {
      format: policy.admission?.format ?? "open",
      capacityLimit: Math.max(1, Math.trunc(
        policy.admission?.capacityLimit ?? 1
      )),
      waitlistPolicy: policy.admission?.waitlistPolicy ?? {
        mode: "rankedOffer",
        offerWindowMinutes: 20,
      },
      inviteRequired: policy.admission?.inviteRequired === true,
      membershipRequired: policy.admission?.membershipRequired === true,
      manualApprovalRequired:
        policy.admission?.manualApprovalRequired === true,
      cohortCapacityLimits: sanitizeCountMap(
        policy.admission?.cohortCapacityLimits
      ),
      balancedRatioPolicy: policy.admission?.balancedRatioPolicy ?? null,
    },
    pricing: {
      basePriceInPaise: Math.max(0, Math.trunc(
        policy.pricing?.basePriceInPaise ?? 0
      )),
      cohortAdjustmentsInPaise: sanitizeAmountMap(
        policy.pricing?.cohortAdjustmentsInPaise
      ),
      demandPricingRules: policy.pricing?.demandPricingRules ?? [],
    },
    cancellation: {
      policyId: policy.cancellation?.policyId ?? "standard",
    },
    settlement: {
      hostPayoutTiming: "afterEventCompletion",
    },
  };
}

export function legacyPolicyFromEvent(event: EventDoc): EventPolicyBundleDoc {
  const maxMen = event.constraints?.maxMen;
  const maxWomen = event.constraints?.maxWomen;
  const hasCaps = maxMen != null || maxWomen != null;
  return {
    version: 1,
    admission: {
      format: hasCaps ? "fixedCohortCaps" : "open",
      capacityLimit: event.capacityLimit,
      waitlistPolicy: {
        mode: "rankedOffer",
        offerWindowMinutes: 20,
      },
      inviteRequired: false,
      membershipRequired: false,
      manualApprovalRequired: false,
      cohortCapacityLimits: {
        ...(maxMen != null ? {[cohortIds.menInterestedInWomen]: maxMen} : {}),
        ...(maxWomen != null ?
          {[cohortIds.womenInterestedInMen]: maxWomen} :
          {}),
      },
      balancedRatioPolicy: null,
    },
    pricing: {
      basePriceInPaise: event.priceInPaise,
      cohortAdjustmentsInPaise: {},
      demandPricingRules: [],
    },
    cancellation: {policyId: "standard"},
    settlement: {hostPayoutTiming: "afterEventCompletion"},
  };
}

export function cohortIdForUser(user: UserProfileDoc): EventCohortId {
  const interests = new Set(user.interestedInGenders ?? []);
  if (user.gender === "man" && interests.size === 1 &&
      interests.has("woman")) {
    return cohortIds.menInterestedInWomen;
  }
  if (user.gender === "woman" && interests.size === 1 &&
      interests.has("man")) {
    return cohortIds.womenInterestedInMen;
  }
  if (user.gender === "nonBinary" || user.gender === "other") {
    return cohortIds.nonBinaryOrOther;
  }
  return cohortIds.queerOrOpen;
}

export function rosterFromEvent(event: EventDoc): EventRosterSnapshot {
  const storedCohortCounts = (event as EventDoc & {
    cohortCounts?: Record<string, number> | null;
  }).cohortCounts;
  const bookedCountsByCohort = storedCohortCounts &&
    Object.keys(storedCohortCounts).length > 0 ?
    sanitizeCountMap(storedCohortCounts) :
    legacyCohortCounts(event);
  const totalBooked = event.bookedCount ??
    Object.values(bookedCountsByCohort).reduce((sum, count) => sum + count, 0);
  return {bookedCountsByCohort, totalBooked};
}

export function quotePriceInPaise(params: {
  policy: EventPolicyBundleDoc;
  cohortId: string;
  roster: EventRosterSnapshot;
  includeRequestedAttendee?: boolean;
}): number {
  const includeRequestedAttendee = params.includeRequestedAttendee ?? true;
  const pricing = params.policy.pricing;
  let amount = pricing.basePriceInPaise;
  amount += pricing.cohortAdjustmentsInPaise?.[params.cohortId] ?? 0;

  for (const rule of pricing.demandPricingRules ?? []) {
    if (params.cohortId !== rule.pricedCohortId) continue;
    const pricedDemand =
      (params.roster.bookedCountsByCohort[rule.pricedCohortId] ?? 0) +
      (includeRequestedAttendee ? 1 : 0);
    const balancingDemand =
      params.roster.bookedCountsByCohort[rule.balancingCohortId] ?? 0;
    const excessDemand = pricedDemand - balancingDemand - rule.freeSkew;
    if (excessDemand <= 0) continue;
    const steps = Math.ceil(excessDemand / Math.max(1, rule.demandStep));
    amount += Math.min(rule.maxAdjustmentInPaise,
      rule.stepAdjustmentInPaise * steps);
  }

  return Math.max(0, Math.trunc(amount));
}

export function quoteAttendeeCancellation(params: {
  policy: EventPolicyBundleDoc;
  paidAmountInPaise: number;
  startTimeMillis: number;
  nowMillis: number;
  isWaitlisted?: boolean;
}): {
  remedy: EventCancellationRemedy;
  refundAmountInPaise: number;
  creditAmountInPaise: number;
} {
  if (params.isWaitlisted) {
    return {
      remedy: "waitlistRelease",
      refundAmountInPaise: 0,
      creditAmountInPaise: 0,
    };
  }

  const paidAmount = Math.max(0, Math.trunc(params.paidAmountInPaise));
  if (paidAmount === 0) {
    return {
      remedy: "fullRefund",
      refundAmountInPaise: 0,
      creditAmountInPaise: 0,
    };
  }

  const window = cancellationWindow(params.policy.cancellation.policyId);
  const beforeStartMillis = params.startTimeMillis - params.nowMillis;
  if (beforeStartMillis >= window.fullRefundBeforeStartMillis) {
    return {
      remedy: "fullRefund",
      refundAmountInPaise: paidAmount,
      creditAmountInPaise: 0,
    };
  }
  if (beforeStartMillis >= window.creditBeforeStartMillis &&
      window.creditPercent > 0) {
    return {
      remedy: "platformCredit",
      refundAmountInPaise: 0,
      creditAmountInPaise: Math.trunc(paidAmount * window.creditPercent / 100),
    };
  }
  return {
    remedy: "noRefund",
    refundAmountInPaise: 0,
    creditAmountInPaise: 0,
  };
}

export function assertPolicyAllowsSignup(params: {
  policy: EventPolicyBundleDoc;
  cohortId: string;
  roster: EventRosterSnapshot;
}) {
  const admission = params.policy.admission;
  if (params.roster.totalBooked >= admission.capacityLimit) {
    throw new HttpsError("failed-precondition", "This event is now full.");
  }

  const cohortLimit = admission.cohortCapacityLimits?.[params.cohortId];
  if (cohortLimit != null &&
      (params.roster.bookedCountsByCohort[params.cohortId] ?? 0) >=
        cohortLimit) {
    throw new HttpsError(
      "failed-precondition",
      "A matching spot is not available right now. Join the waitlist."
    );
  }

  const ratio = admission.balancedRatioPolicy;
  if (admission.format !== "balancedRatio" || !ratio) return;

  const applies = params.cohortId === ratio.leftCohortId ||
    params.cohortId === ratio.rightCohortId;
  if (!applies) {
    if (ratio.outOfRatioCohortPolicy === "admitWithinGeneralCapacity") {
      return;
    }
    throw new HttpsError(
      "failed-precondition",
      "This booking needs host review."
    );
  }

  const counterpartId = params.cohortId === ratio.leftCohortId ?
    ratio.rightCohortId :
    ratio.leftCohortId;
  const currentCount =
    params.roster.bookedCountsByCohort[params.cohortId] ?? 0;
  const counterpartCount =
    params.roster.bookedCountsByCohort[counterpartId] ?? 0;
  const nextCount = currentCount + 1;

  if (counterpartCount === 0 &&
      currentCount < ratio.openingBufferPerCohort) {
    return;
  }
  if (nextCount <= counterpartCount + ratio.maxSkew) return;

  throw new HttpsError(
    "failed-precondition",
    "A balanced spot is not available right now. Join the waitlist."
  );
}

export function incrementCount(
  counts: Record<string, number>,
  key: string
): Record<string, number> {
  return {...counts, [key]: (counts[key] ?? 0) + 1};
}

export function decrementCount(
  counts: Record<string, number>,
  key: string
): Record<string, number> {
  return {...counts, [key]: Math.max(0, (counts[key] ?? 0) - 1)};
}

function legacyCohortCounts(event: EventDoc): Record<string, number> {
  const genderCounts = event.genderCounts ?? {};
  const nonBinaryOrOther =
    (genderCounts.nonBinary ?? 0) + (genderCounts.other ?? 0);
  return {
    ...(genderCounts.man ? {
      [cohortIds.menInterestedInWomen]: genderCounts.man,
    } : {}),
    ...(genderCounts.woman ? {
      [cohortIds.womenInterestedInMen]: genderCounts.woman,
    } : {}),
    ...(nonBinaryOrOther ? {
      [cohortIds.nonBinaryOrOther]: nonBinaryOrOther,
    } : {}),
  };
}

function sanitizeCountMap(value?: Record<string, number> | null):
  Record<string, number> {
  if (!value) return {};
  return Object.fromEntries(
    Object.entries(value)
      .filter(([, count]) => Number.isFinite(count))
      .map(([key, count]) => [key, Math.max(0, Math.trunc(count))])
  );
}

function sanitizeAmountMap(value?: Record<string, number> | null):
  Record<string, number> {
  if (!value) return {};
  return Object.fromEntries(
    Object.entries(value)
      .filter(([, amount]) => Number.isFinite(amount))
      .map(([key, amount]) => [key, Math.trunc(amount)])
  );
}

function cancellationWindow(policyId: EventCancellationPolicyId): {
  fullRefundBeforeStartMillis: number;
  creditBeforeStartMillis: number;
  creditPercent: number;
} {
  const hourMillis = 60 * 60 * 1000;
  switch (policyId) {
  case "flexible":
    return {
      fullRefundBeforeStartMillis: 6 * hourMillis,
      creditBeforeStartMillis: hourMillis,
      creditPercent: 100,
    };
  case "strict":
    return {
      fullRefundBeforeStartMillis: 72 * hourMillis,
      creditBeforeStartMillis: 24 * hourMillis,
      creditPercent: 50,
    };
  case "standard":
  default:
    return {
      fullRefundBeforeStartMillis: 24 * hourMillis,
      creditBeforeStartMillis: 6 * hourMillis,
      creditPercent: 50,
    };
  }
}
