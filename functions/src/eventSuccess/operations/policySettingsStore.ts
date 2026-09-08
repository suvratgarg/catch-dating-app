import {runAssistanceTransaction as transact} from "./transactionCallback";
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
import {parseSetting, resolveSetting, readSettingState} from
  "./policySettingsReader";

/** Saves preferences; execution and provider authority remain separate. */
export class EventAssistanceSettingsStore {
  constructor(private readonly db: Firestore,
    private readonly clock: () => number = Date.now) {}

  async get(actorUid: string, input: unknown): Promise<Response> {
    if (!validateGetEventAssistanceSettingCallablePayload(input)) {
      throw new HttpsError("invalid-argument",
        "Invalid assistance setting scope.");
    }
    return transact(this.db, async (tx) =>
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
    return transact(this.db, async (tx) => {
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
    const [eventSnap, organizerSnap] = await tx.getAll(
      this.db.collection("events").doc(scope.context.eventId),
      this.db.collection("organizers").doc(scope.context.organizerId));
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
    return readSettingState(this.db, tx, scope, eventSnap, this.clock);
  }
}

type State = {
  scope: SettingScope; now: number; own: Setting | null;
  parent: Setting | null;
  source: ReturnType<typeof settingSource>;
  parentSource: ReturnType<typeof settingSource>;
};
function response(outcome: Response["outcome"], state: State,
  operationRevision: number | null = null): Response {
  const {scope, own, now, source} = state;
  const {selected, template, status} = resolveSetting(state);
  const value: Response = {outcome, operationRevision,
    view: {...scope, serverTime: now, sourceHash: source.hash,
      ownRevision: own?.revision ?? 0, own,
      origin: !selected ? "none" : selected.groupId === "event:whole" ?
        "event" : "group", status,
      effective: status === "configured" || status === "disabled" ?
        template : null,
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
