import type {EventAssistanceSmsWithdrawalCallableResponse} from "../../shared/contracts/generated/eventAssistanceSmsWithdrawalCallableResponse";
import type {EventWhatsappWithdrawalCallableResponse} from "../../shared/contracts/generated/eventWhatsappWithdrawalCallableResponse";
import type {EventRcsWithdrawalCallableResponse} from "../../shared/contracts/generated/eventRcsWithdrawalOutput";

type Response = EventAssistanceSmsWithdrawalCallableResponse |
  EventWhatsappWithdrawalCallableResponse | EventRcsWithdrawalCallableResponse;
const preferences = {enabled: true, disabled: true, expired: true} satisfies
  Record<Response["view"]["preference"], true>;
const outcomes = {read: true, applied: true, replayed: true, conflict: true} satisfies
  Record<Response["outcome"], true>;
const record = (value: unknown): value is Record<string, unknown> =>
  typeof value === "object" && value !== null && !Array.isArray(value);
const integer = (value: unknown, minimum: number): value is number =>
  typeof value === "number" && Number.isSafeInteger(value) && value >= minimum;

/** Only the closed preference view can enter a bearer page's query cache. */
export function messageWithdrawalResponse(value: unknown, operation: "read" | "mutation"): Response {
  const invalid = () => new Error("Invalid event message preference response");
  if (!record(value) || Object.keys(value).sort().join(",") !== "outcome,view" ||
      typeof value.outcome !== "string" || !Object.hasOwn(outcomes, value.outcome) ||
      (operation === "read") !== (value.outcome === "read") || !record(value.view)) throw invalid();
  const view = value.view;
  if (Object.keys(view).sort().join(",") !== "expiresAt,preference,revision,serverTime" ||
      !integer(view.revision, 1) || !integer(view.serverTime, 0) ||
      !integer(view.expiresAt, 0) || typeof view.preference !== "string" ||
      !Object.hasOwn(preferences, view.preference)) throw invalid();
  return {outcome: value.outcome as Response["outcome"], view: {
    revision: view.revision, serverTime: view.serverTime, expiresAt: view.expiresAt,
    preference: view.preference as Response["view"]["preference"],
  }};
}
