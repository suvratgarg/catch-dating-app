import type {
  EventAssistanceLateJoinInput as LateJoinInput,
} from "../../shared/generated/eventAssistanceLateJoinInput";
import {
  validateEventAssistanceLateJoinInput,
} from "../../shared/generated/validators/eventAssistanceLateJoinInput";
import {assertLateJoinContext, evaluateLateJoinPolicy} from "./lateJoinPolicy";
export {assertNever, destinationAllowed} from "./lateJoinPolicy";

/** Validate untrusted wire input before resolving any operational facts. */
export function parseLateJoinInput(value: unknown): LateJoinInput {
  if (!validateEventAssistanceLateJoinInput(value)) {
    throw new Error("Invalid late-join input");
  }
  assertLateJoinContext(value);
  return value;
}

export function evaluateLateJoin(input: LateJoinInput) {
  return evaluateLateJoinPolicy(parseLateJoinInput(input));
}
