import type {
  EventAssistancePolicy,
} from "../../shared/generated/eventAssistancePolicy";
import type {
  EventAssistanceCommand,
} from "../../shared/generated/eventAssistanceCommand";

type LateJoin = Extract<EventAssistancePolicy, {kind: "lateJoin"}>;
type JoinIntentPayload = Extract<
  EventAssistanceCommand, {kind: "setJoinIntent"}
>["payload"];
type CheckIn = Extract<EventAssistanceCommand, {kind: "checkInGuest"}>;

/** These rejected pairings must remain impossible after code generation. */
export function assertCorrelatedWireTypes(
  lateJoinConfig: LateJoin["config"],
  checkInPayload: CheckIn["payload"]
): void {
  // @ts-expect-error A check-in request cannot carry a late-joining policy.
  const invalidCheckIn: CheckIn["payload"] = lateJoinConfig;
  // @ts-expect-error Physical attendance cannot become a guest joining intent.
  const invalidIntent: JoinIntentPayload = checkInPayload;
  // @ts-expect-error Late joining requires an individual participation episode.
  const invalidScope: LateJoin["scope"] = {kind: "event", eventId: "event-1"};
  void [invalidCheckIn, invalidIntent, invalidScope];
}
