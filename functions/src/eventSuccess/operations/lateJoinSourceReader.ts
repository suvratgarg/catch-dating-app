import type {Firestore, Transaction} from "firebase-admin/firestore";
import type {EventAssistanceLateJoinInput as Input} from
  "../../shared/generated/eventAssistanceLateJoinInput";
import {validateEventDocument} from
  "../../shared/generated/validators/eventDocument";
import {validateEventAttendeeDocument} from
  "../../shared/generated/validators/eventAttendeeDocument";
import {operationContentHash} from "../../operations/durableActions";
import {guestCollections, guestIdentity, parseGuest,
  guestSourceFactsFromSnapshots} from "./guestRecords";
import {MEMBERSHIPS, membershipIdentity, parseMembership} from
  "./membershipReader";
import {groupDutySource} from "./groupStaffAuthority";
import {readGroupProgressState} from "./groupProgressReader";
import {invalidSource, projectGroupProgress, timestampEvidence} from
  "./groupProgressSource";
import {bindPolicyTemplate} from "./policySettings";
import {readSettingState, resolveSetting} from "./policySettingsReader";
import {parseLateJoinInput} from "./lateJoin";

export type LateJoinSourceScope = {
  context: Extract<Input["context"], {mode: "live"}>;
  attendeeId: string;
};
/** Incomplete: channel eligibility and history are not domain facts. */
export type LateJoinDomainFacts = Pick<Input, "eventId" |
  "eventOpen" | "departureConfirmed" | "now" | "setting" | "policy" |
  "guidance"> & {context: LateJoinSourceScope["context"];
  guest: Omit<Input["guest"], "deliveryEligibility">};
export type LateJoinSourceResult =
  | {kind: "notReady"; reason: "episodeMissing" | "guestSourceChanged" |
      "membershipMissing" | "membershipSourceChanged" | "unconfigured" |
      "disabled" | "settingSourceChanged" | "eventClosed" |
      "runtimeNotLive" | "progressUnconfirmed" | "progressSourceChanged" |
      "destinationUnavailable"; observedAt: number}
  | {kind: "ready"; facts: LateJoinDomainFacts; sourceHash: string;
      groupId: string; settingId: string; settingRevision: number};

/**
 * Trusted worker reader. Read-only and bounded by document identities, never
 * initializes participation, selects a pending transfer, or grants send rights.
 * External callers must authorize the event and guest before using this reader.
 */
export async function readLateJoinSource(db: Firestore, tx: Transaction,
  scope: LateJoinSourceScope, now: number): Promise<LateJoinSourceResult> {
  const {context, attendeeId} = scope;
  const guestId = guestIdentity(context, attendeeId);
  if (!Number.isSafeInteger(now) || now < 0) throw invalidSource();
  const [eventSnap, attendeeSnap, guestSnap, memberSnap] = await tx.getAll(
    db.collection("events").doc(context.eventId),
    db.collection("eventAttendees").doc(attendeeId),
    db.collection(guestCollections.guests).doc(guestId),
    db.collection(MEMBERSHIPS).doc(membershipIdentity(scope)));
  const event = eventSnap.data();
  const attendee = attendeeSnap.data();
  if (!validateEventDocument(event) ||
      event.organizerId !== context.organizerId ||
      !validateEventAttendeeDocument(attendee) ||
      attendee.eventId !== context.eventId ||
      attendee.organizerId !== context.organizerId) throw invalidSource();
  const source = guestSourceFactsFromSnapshots(context, attendeeId,
    eventSnap, attendeeSnap);
  const held = (reason: Extract<LateJoinSourceResult,
    {kind: "notReady"}>["reason"]): LateJoinSourceResult =>
    ({kind: "notReady", reason, observedAt: now});
  if (!guestSnap.exists) return held("episodeMissing");
  const guest = parseGuest(guestSnap.data());
  if (guest.guestId !== guestId || guest.updatedAt > now) throw invalidSource();
  if (guest.lifecycle !== "active" ||
      guest.sourceGeneration !== source.sourceGeneration ||
      guest.attendeeGeneration !== source.attendeeGeneration) {
    return held("guestSourceChanged");
  }
  // Accepted membership continues to own guidance during an unacknowledged
  // handover. A saved pace preference is not an accepted group assignment.
  let groupId = "event:whole";
  let membership = null;
  const route = event.eventFormat.activityDetails?.routePlan;
  if (route?.groupStrategy === "paceGroups") {
    if (!memberSnap.exists) return held("membershipMissing");
    membership = parseMembership(memberSnap.data(), scope, now);
    if (membership.sourceGeneration !== source.sourceGeneration ||
        membership.attendeeGeneration !== source.attendeeGeneration ||
        membership.episodeId !== guest.episodeId) {
      return held("membershipSourceChanged");
    }
    if (!membership.accepted) return held("membershipMissing");
    groupId = membership.accepted.groupId;
    // Missing/edited accepted groups require host review; never fall back to
    // whole-event directions or the proposed receiving group.
    if (groupId === "event:whole" || !route.paceGroups?.some((g) =>
      g.id === groupId)) return held("membershipSourceChanged");
    const group = groupDutySource(context, groupId, event,
      eventSnap.createTime);
    if (!group.paceGroup ||
        membership.accepted.groupSourceHash !== group.hash) {
      return held("membershipSourceChanged");
    }
  }
  const settings = await readSettingState(db, tx,
    {context, groupId, workflowKind: "lateJoin"}, eventSnap, () => now);
  const resolved = resolveSetting(settings);
  if (resolved.status !== "configured") {
    return held(resolved.status === "sourceChanged" ? "settingSourceChanged" :
      resolved.status);
  }
  const template = resolved.template;
  if (!template || template.kind !== "lateJoin" || !resolved.selected) {
    throw invalidSource();
  }
  const progress = await readGroupProgressState(db, tx, context, groupId,
    () => now);
  const view = projectGroupProgress(progress.source, progress.progress, now);
  if (!view.eventOpen) return held("eventClosed");
  if (!view.runtimeLive) return held("runtimeNotLive");
  if (view.freshness === "sourceChanged") return held("progressSourceChanged");
  const policy = bindPolicyTemplate(template,
    {kind: "guest", eventId: context.eventId, attendeeId,
      episodeId: guest.episodeId}, view.destinations.map((d) => d.target),
    view.guidance?.destination ?? null);
  if (!policy) {
    return held(view.freshness === "unconfirmed" ?
      "progressUnconfirmed" : "destinationUnavailable");
  }
  if (policy.kind !== "lateJoin") throw invalidSource();
  const attendanceStamp = timestampEvidence(attendee.updatedAt);
  const attendanceUpdatedAt = attendanceStamp._seconds * 1000 +
    attendanceStamp._nanoseconds / 1_000_000;
  if (attendanceUpdatedAt > now) throw invalidSource();
  const facts: LateJoinDomainFacts = {context, eventId: context.eventId,
    now, eventOpen: view.eventOpen, departureConfirmed: !!view.guidance,
    policy: policy.config, setting: policy.setting,
    guest: {attendeeId, episodeId: guest.episodeId,
      admission: attendee.status === "registered" ||
        attendee.status === "checkedIn" ? "admitted" :
        attendee.status === "cancelled" ? "declined" : "pending",
      attendance: {kind: "known", value: {
        checkedIn: attendee.status === "checkedIn"},
      revision: attendee.attendanceRevision ?? 0,
      observedAt: now, source: "system"},
      intention: guest.intention, participation: guest.participation.state},
    guidance: view.guidance ? {kind: "known", value: view.guidance,
      revision: view.guidance.revision,
      observedAt: view.progress!.confirmedAt, source: "host"} :
      {kind: "unknown", reason: "notConfirmed"}};
  return {kind: "ready", facts, groupId,
    settingId: resolved.selected.settingId,
    settingRevision: resolved.selected.revision,
    sourceHash: operationContentHash([scope, source.sourceGeneration,
      source.attendeeGeneration, facts, guest.revision, membership,
      settings.own, settings.parent, progress.source.sourceHash])};
}

/** Required evidence; never default missing history or consent. */
export interface LateJoinCommunicationFacts {
  scope: LateJoinSourceScope;
  episodeId: string;
  observedAt: number;
  deliveryEligibility: Input["guest"]["deliveryEligibility"];
  lastMessage: Input["lastMessage"];
  messagesThisEpisode: number;
  responseDeadline: number | null;
}

/** Join same-transaction facts before the existing canonical evaluator. */
export function completeLateJoinInput(source: Extract<LateJoinSourceResult,
  {kind: "ready"}>, communication: LateJoinCommunicationFacts): Input {
  const {facts} = source;
  if (operationContentHash(communication.scope) !== operationContentHash({
    context: facts.context, attendeeId: facts.guest.attendeeId}) ||
      communication.episodeId !== facts.guest.episodeId ||
      communication.observedAt !== facts.now) {
    throw new Error("Late-join communication facts are outside this snapshot");
  }
  return parseLateJoinInput({...facts,
    guest: {...facts.guest,
      deliveryEligibility: communication.deliveryEligibility},
    lastMessage: communication.lastMessage,
    messagesThisEpisode: communication.messagesThisEpisode,
    ...(communication.responseDeadline === null ? {} :
      {responseDeadline: communication.responseDeadline})});
}
