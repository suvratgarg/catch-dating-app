import {HttpsError} from "firebase-functions/v2/https";
import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import {isOrganizerManager} from "../../shared/organizerHosts";
import type {OrganizerDocument} from
  "../../shared/generated/firestoreAdminTypes";
import {validateEventDocument} from
  "../../shared/generated/validators/eventDocument";
import {validateOrganizerDocument} from
  "../../shared/generated/validators/organizerDocument";
import {validateEventAssistanceSettingDocument} from
  "../../shared/generated/validators/eventAssistanceSettingDocument";
import {validateEventAssistanceSettingReceiptDocument} from
  "../../shared/generated/validators/eventAssistanceSettingReceiptDocument";
import {validateGetEventAssistanceSettingCallablePayload} from
  "../../shared/generated/validators/getEventAssistanceSettingInput";
import {validateSetEventAssistanceSettingCallablePayload} from
  "../../shared/generated/validators/setEventAssistanceSettingInput";
import {validateEventAssistanceSettingCallableResponse} from
  "../../shared/generated/validators/eventAssistanceSettingOutput";
import type {EventAssistanceSettingCallableResponse as Response} from
  "../../shared/generated/eventAssistanceSettingCallableResponse";
import {invalidSource} from "./groupProgressSource";
import {
  Setting, SettingScope, SETTINGS, SETTING_RECEIPTS,
  settingId, settingSource, suggestedTemplate, templateTargetsAreCurrent,
} from "./policySettings";

/** Saves preferences; execution and provider authority remain separate. */
export class EventAssistanceSettingsStore {
  constructor(private readonly db: Firestore,
    private readonly clock: () => number = Date.now) {}

  async get(actorUid: string, input: unknown): Promise<Response> {
    if (!validateGetEventAssistanceSettingCallablePayload(input)) {
      throw new HttpsError("invalid-argument",
        "Invalid assistance setting scope.");
    }
    return this.db.runTransaction(async (tx) =>
      response("read", await this.read(tx, actorUid, input)));
  }

  async set(actorUid: string, input: unknown): Promise<Response> {
    if (!validateSetEventAssistanceSettingCallablePayload(input) ||
        (input.preference.kind === "configured" &&
          input.preference.template.kind !== input.workflowKind)) {
      throw new HttpsError("invalid-argument",
        "Invalid assistance preference.");
    }
    const requestHash = operationContentHash([actorUid, input]);
    const receiptId = "setting-action:" + operationContentHash([
      input.context, input.groupId, input.workflowKind, input.requestId]);
    return this.db.runTransaction(async (tx) => {
      const state = await this.read(tx, actorUid, input);
      const receiptRef = this.db.collection(SETTING_RECEIPTS).doc(receiptId);
      const receipt = (await tx.get(receiptRef)).data();
      const now = this.clock();
      if (!Number.isSafeInteger(now) || now < state.now) throw invalidSource();
      state.now = now;
      if (receipt !== undefined) {
        if (!validateEventAssistanceSettingReceiptDocument(receipt) ||
            receipt.receiptId !== receiptId ||
            receipt.settingId !== state.own?.settingId ||
            receipt.requestHash !== requestHash ||
            receipt.revision > state.own.revision ||
            receipt.createdAt > now) throw conflict();
        return response("replayed", state, receipt.revision);
      }
      if (input.expectedRevision !== (state.own?.revision ?? 0) ||
          input.expectedSourceHash !== state.source.hash) throw conflict();
      if (input.preference.kind === "configured" &&
          input.preference.template.setting.kind === "enabled" &&
          !templateTargetsAreCurrent(input.preference.template,
            state.source.destinations.map((d) => d.target))) {
        throw new HttpsError("failed-precondition",
          "Choose joining destinations from the current event setup.");
      }
      const own: Setting = {schemaVersion: 1, settingId: settingId(input),
        context: input.context, groupId: input.groupId,
        workflowKind: input.workflowKind,
        revision: (state.own?.revision ?? 0) + 1,
        preference: input.preference, sourceHash: state.source.hash,
        updatedBy: actorUid, createdAt: state.own?.createdAt ?? now,
        updatedAt: now};
      parseSetting(own, input, now);
      const savedReceipt = {receiptId, settingId: own.settingId,
        requestHash, revision: own.revision, createdAt: now};
      if (!validateEventAssistanceSettingReceiptDocument(savedReceipt)) {
        throw invalidSource();
      }
      const result = response("applied", {...state, own}, own.revision);
      tx.set(this.db.collection(SETTINGS).doc(own.settingId), own);
      tx.create(receiptRef, savedReceipt);
      return result;
    });
  }

  private async read(tx: Transaction, actorUid: string, scope: SettingScope) {
    const parentScope = {...scope, groupId: "event:whole"};
    const [eventSnap, organizerSnap, ownSnap] = await tx.getAll(
      this.db.collection("events").doc(scope.context.eventId),
      this.db.collection("organizers").doc(scope.context.organizerId),
      this.db.collection(SETTINGS).doc(settingId(scope)));
    const parentSnap = scope.groupId === "event:whole" ? ownSnap :
      await tx.get(this.db.collection(SETTINGS).doc(settingId(parentScope)));
    const event = eventSnap.data();
    const organizer = organizerSnap.data();
    if (!validateEventDocument(event) ||
        event.organizerId !== scope.context.organizerId ||
        !validateOrganizerDocument(organizer)) throw invalidSource();
    if (!isOrganizerManager(organizer as unknown as OrganizerDocument,
      actorUid)) {
      throw new HttpsError("permission-denied",
        "Only organizer managers can configure assistance.");
    }
    const now = this.clock();
    if (!Number.isSafeInteger(now) || now < 0) throw invalidSource();
    const source = settingSource(event, eventSnap.createTime, scope, now);
    const parentSource = scope.groupId === "event:whole" ? source :
      settingSource(event, eventSnap.createTime, parentScope, now);
    return {scope: {context: scope.context, groupId: scope.groupId,
      workflowKind: scope.workflowKind}, source, parentSource, now,
    own: parseSetting(ownSnap.data(), scope, now),
    parent: parseSetting(parentSnap.data(), parentScope, now)};
  }
}

function parseSetting(value: unknown, scope: SettingScope,
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

type State = {
  scope: SettingScope; now: number; own: Setting | null;
  parent: Setting | null;
  source: ReturnType<typeof settingSource>;
  parentSource: ReturnType<typeof settingSource>;
};
function response(outcome: Response["outcome"], state: State,
  operationRevision: number | null = null): Response {
  const {scope, own, parent, now, source, parentSource} = state;
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
  const value: Response = {outcome, operationRevision,
    view: {...scope, serverTime: now, sourceHash: source.hash,
      ownRevision: own?.revision ?? 0, own,
      origin: !selected ? "none" : selected.groupId === "event:whole" ?
        "event" : "group", status,
      effective: status === "configured" || disabled ? template : null,
      suggested: suggestedTemplate(scope.workflowKind)}};
  if (!validateEventAssistanceSettingCallableResponse(value)) {
    throw invalidSource();
  }
  return value;
}

function conflict(): HttpsError {
  return new HttpsError("aborted",
    "Assistance settings changed. Refresh and retry.");
}
