export type GuardRailResult = {
  allowed: true;
} | {
  allowed: false;
  reason: "momentLimitReached" | "householdDailyCapReached";
};

export function checkMomentLimit(input: {
  armedMomentsForFunction: number;
  maxPerFunction: number | null;
}): GuardRailResult {
  requireCount(input.armedMomentsForFunction);
  if (input.maxPerFunction === null) return {allowed: true};
  requireCount(input.maxPerFunction);
  if (input.armedMomentsForFunction >= input.maxPerFunction) {
    return {allowed: false, reason: "momentLimitReached"};
  }
  return {allowed: true};
}

export function checkHouseholdDailyBudget(input: {
  sentTodayForHousehold: number;
  capPerDay: number;
}): GuardRailResult {
  requireCount(input.sentTodayForHousehold);
  requireCount(input.capPerDay);
  if (input.sentTodayForHousehold >= input.capPerDay) {
    return {allowed: false, reason: "householdDailyCapReached"};
  }
  return {allowed: true};
}

function requireCount(value: number): void {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new RangeError("Guard-rail counts must be non-negative integers.");
  }
}
