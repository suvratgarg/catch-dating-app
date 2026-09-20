import type {DocumentSnapshot, Firestore, Transaction} from
  "firebase-admin/firestore";
import {validateEventDocument} from
  "../../shared/generated/validators/eventDocument";
import {validateEventAssistanceSettingDocument} from
  "../../shared/generated/validators/eventAssistanceSettingDocument";
import type {EventAssistanceSettingCallableResponse as Response} from
  "../../shared/generated/eventAssistanceSettingCallableResponse";
import {invalidSource} from "./groupProgressSource";
import {Setting, SettingScope, SETTINGS, settingId, settingSource} from
  "./policySettings";

/** Shared inheritance reader; callers authorize access separately. */
export async function readSettingState(db: Firestore, tx: Transaction,
  scope: SettingScope, eventSnapshot: DocumentSnapshot, clock: () => number) {
  const event = eventSnapshot.data();
  if (eventSnapshot.id !== scope.context.eventId ||
      !validateEventDocument(event) ||
      event.organizerId !== scope.context.organizerId) throw invalidSource();
  const parentScope = {...scope, groupId: "event:whole"};
  const ownSnap = await tx.get(db.collection(SETTINGS).doc(settingId(scope)));
  const parentSnap = scope.groupId === "event:whole" ? ownSnap :
    await tx.get(db.collection(SETTINGS).doc(settingId(parentScope)));
  const now = clock();
  if (!Number.isSafeInteger(now) || now < 0) throw invalidSource();
  const source = settingSource(event, eventSnapshot.createTime, scope, now);
  const parentSource = scope.groupId === "event:whole" ? source :
    settingSource(event, eventSnapshot.createTime, parentScope, now);
  return {scope: {context: scope.context, groupId: scope.groupId,
    workflowKind: scope.workflowKind}, source, parentSource, now,
  own: parseSetting(ownSnap.data(), scope, now),
  parent: parseSetting(parentSnap.data(), parentScope, now)};
}

export function parseSetting(value: unknown, scope: SettingScope,
  now: number): Setting | null {
  if (value === undefined) return null;
  if (!validateEventAssistanceSettingDocument(value) ||
      value.settingId !== settingId(scope) ||
      settingId(value) !== settingId(scope) ||
      value.createdAt > value.updatedAt || value.updatedAt > now ||
      (value.preference.kind === "configured" &&
        value.preference.template.kind !== value.workflowKind)) {
    throw invalidSource();
  }
  return value;
}

/** UI and worker must resolve exactly the same explicit preference. */
export function resolveSetting(state: Awaited<ReturnType<
  typeof readSettingState>>) {
  const {scope, own, parent, source, parentSource} = state;
  const direct = own && own.preference.kind !== "inherit" ? own : null;
  const inherited = scope.groupId !== "event:whole" && parent &&
    parent.preference.kind !== "inherit" ? parent : null;
  const selected = direct ?? inherited;
  const basis = direct ? source : parentSource;
  const preference = selected?.preference;
  const template = preference?.kind === "configured" ? preference.template :
    null;
  const disabled = preference?.kind === "disabled" ||
    template?.setting.kind === "disabled";
  const status: Response["view"]["status"] = !selected ? "unconfigured" :
    disabled ? "disabled" : selected.sourceHash !== basis.hash ?
      "sourceChanged" : "configured";
  return {selected, template, status};
}
