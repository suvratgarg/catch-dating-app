import {HttpsError} from "firebase-functions/v2/https";
import type {Firestore, Transaction} from "firebase-admin/firestore";
import type {MessageRecord} from "./messageOutbox";
import type {DispatchGate} from "./messagingPolicy";
import {ASSISTANCE_POLICY_VERSION} from "./policySettings";
import {readSettingState, resolveSetting} from "./policySettingsReader";

type Intent = Extract<MessageRecord["intent"],
  {kind: "operationalNotice"}>;

/** Recheck the manager-owned policy snapshot before reserving or claiming. */
export async function readOperationalNoticeDispatchPolicy(db: Firestore,
  tx: Transaction, intent: MessageRecord["intent"], now: number):
  Promise<DispatchGate | null> {
  if (intent.kind !== "operationalNotice" || !intent.automation) return null;
  const stop = (): DispatchGate => ({kind: "stop", reason: "hostStopped"});
  const binding = intent.automation;
  if (intent.context.mode !== "live" ||
      binding.policyVersion !== ASSISTANCE_POLICY_VERSION) return stop();
  const expected = purposePolicy(intent);
  if (!expected) return stop();
  try {
    const event = await tx.get(db.collection("events").doc(intent.eventId));
    const state = await readSettingState(db, tx, {
      context: intent.context, groupId: binding.groupId,
      workflowKind: expected.workflowKind,
    }, event, () => now);
    const resolved = resolveSetting(state);
    const template = resolved.template;
    if (resolved.status !== "configured" || !resolved.selected || !template ||
        resolved.selected.settingId !== binding.settingId ||
        resolved.selected.revision !== binding.settingRevision ||
        template.kind !== expected.workflowKind ||
        template.config.templateIntent !== expected.templateIntent ||
        template.setting.kind !== "enabled" ||
        template.setting.authority !== "executeWithinPolicy" ||
        intent.expiresAt > intent.createdAt +
          template.config.expiryMinutes * 60_000) return stop();
    return {kind: "allow", checkedAt: now,
      validUntil: Math.min(now + 30_000, intent.expiresAt),
      instructionRevision: intent.instructionRevision};
  } catch (error) {
    if (error instanceof HttpsError && error.code === "failed-precondition") {
      return stop();
    }
    throw error;
  }
}

function purposePolicy(intent: Intent): {
  workflowKind: "planChangeCommunication" | "postEventFollowUp";
  templateIntent: "planChange" | "followUp";
} | null {
  if (intent.noticeKind === "planChanged" &&
      intent.workflow.kind === "planChangeCommunication") {
    return {workflowKind: "planChangeCommunication",
      templateIntent: "planChange"};
  }
  if (intent.noticeKind === "followUp" &&
      intent.workflow.kind === "postEventFollowUp") {
    return {workflowKind: "postEventFollowUp", templateIntent: "followUp"};
  }
  return null;
}
