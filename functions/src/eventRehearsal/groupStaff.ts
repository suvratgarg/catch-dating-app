import {HttpsError} from "firebase-functions/v2/https";
import {operationContentHash as hash} from "../operations/durableActions";
import {isOrganizerManager} from "../shared/organizerHosts";
import type {EventRehearsalDocument as Session} from
  "../shared/generated/firestoreAdminTypes";
import type {ControlEventRehearsalCallablePayload as Control} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import type {EventRehearsalBootstrapCallableResponse as Bootstrap} from
  "../shared/generated/eventRehearsalBootstrapCallableResponse";
import {GROUP_PERMISSIONS, GROUP_DUTY_PERMISSIONS, GroupPermission,
  assertGroupDutyAssignment, availableGroupDuties} from
  "../eventSuccess/operations/groupDutyPolicy";
import {practiceContext} from "./assistanceIdentity";
import type {PracticeCaseAuthority} from "./assistanceCases";

type State = NonNullable<Session["staff"]>;
type Review = NonNullable<Bootstrap["staffReview"]>;
type Command = NonNullable<Control["staff"]>;

/** Real Host credentials own the simulation, including its synthetic roles. */
export function requirePracticeHost(authority: PracticeCaseAuthority) {
  if (authority.practiceOperatorId ?
    authority.practiceOperatorId !== authority.actorUid ||
      !/^practice-staff:[A-Za-z0-9_-]{1,60}$/.test(authority.actorUid) ||
      !authority.hostUid :
    authority.hostUid !== undefined &&
      authority.hostUid !== authority.actorUid) {
    throw denied();
  }
  if (!isOrganizerManager(authority.organizer,
    authority.hostUid ?? authority.actorUid)) throw denied();
}
export function practiceIsManager(authority: PracticeCaseAuthority) {
  requirePracticeHost(authority);
  return authority.practiceOperatorId === undefined;
}

export function practiceStaffGroups(sessionId: string, session: Session) {
  const context = practiceContext(session, {sessionId});
  const route = session.setup.movementSimulation?.routePlan;
  const groups = [{groupId: "event:whole", label: "Whole event",
    source: {kind: "wholeEvent"}},
  ...(route?.groupStrategy === "paceGroups" ? route.paceGroups ?? [] : [])
    .map((g) => ({groupId: g.id, label: g.label, source: g}))];
  if (new Set(groups.map((g) => g.groupId)).size !== groups.length) {
    throw invalid();
  }
  return groups.map(({groupId, label, source}) => ({groupId, label,
    sourceHash: hash([context, route?.groupStrategy ?? null, source]),
    availableDuties: availableGroupDuties(groupId !== "event:whole")}));
}

export function practiceStaffState(sessionId: string, session: Session): State {
  const clockId = practiceContext(session, {sessionId}).clockId;
  const state = session.staff ?? {clockId, revision: 0, operators: []};
  const now = session.virtualNow.toMillis();
  const start = session.virtualStartedAt.toMillis();
  if (state.clockId !== clockId ||
      new Set(state.operators.map((o) => o.operatorId)).size !==
        state.operators.length ||
      (state.revision === 0 && state.operators.length !== 0) ||
      state.operators.some((o) => !o.displayName.trim() ||
        new Set(o.duties.map((d) => d.groupId)).size !== o.duties.length ||
        o.duties.some((d) => d.grantedAtMillis < start ||
          d.grantedAtMillis > now ||
          d.expiresAtMillis <= d.grantedAtMillis))) throw invalid();
  return state;
}

export function practiceRoleAuthority(sessionId: string, session: Session,
  host: PracticeCaseAuthority, practiceOperatorId?: string):
  PracticeCaseAuthority {
  requirePracticeHost(host);
  if (!practiceOperatorId) return host;
  if (!practiceStaffState(sessionId, session).operators.some((o) =>
    o.operatorId === practiceOperatorId)) throw denied();
  return {organizer: host.organizer, hostUid: host.hostUid ?? host.actorUid,
    actorUid: practiceOperatorId, practiceOperatorId};
}

/** Resolve a duty at virtual time using the live permission vocabulary. */
export function practiceGroupPermission(sessionId: string, session: Session,
  authority: PracticeCaseAuthority, groupId: string,
  permission: GroupPermission, operatorId = authority.actorUid): number | null {
  requirePracticeHost(authority);
  const group = practiceStaffGroups(sessionId, session).find((g) =>
    g.groupId === groupId);
  if (!group) return null;
  // The reserved namespace is always synthetic, even if an Auth UID collides.
  if (!operatorId.startsWith("practice-staff:")) {
    return isOrganizerManager(authority.organizer, operatorId) ?
      Number.MAX_SAFE_INTEGER : null;
  }
  const operator = practiceStaffState(sessionId, session).operators.find((o) =>
    o.operatorId === operatorId);
  const duty = operator?.duties.find((d) => d.groupId === groupId);
  const permissions: readonly GroupPermission[] = duty ?
    GROUP_DUTY_PERMISSIONS[duty.duty] : [];
  return duty && duty.sourceHash === group.sourceHash &&
    duty.expiresAtMillis > session.virtualNow.toMillis() &&
    permissions.includes(permission) ? duty.expiresAtMillis : null;
}

export function requirePracticeGroupPermission(sessionId: string,
  session: Session, authority: PracticeCaseAuthority, groupId: string,
  permission: GroupPermission): number {
  const until = practiceGroupPermission(sessionId, session, authority,
    groupId, permission);
  if (until === null) throw denied();
  return until;
}

export function practiceStaffProjection(sessionId: string, session: Session,
  authority: PracticeCaseAuthority): Review {
  requirePracticeHost(authority);
  const state = practiceStaffState(sessionId, session);
  const groups = practiceStaffGroups(sessionId, session);
  const now = session.virtualNow.toMillis();
  return {clockId: state.clockId, revision: state.revision,
    sourceHash: hash([state, groups]),
    hostUid: authority.hostUid ?? authority.actorUid,
    actorUid: authority.actorUid,
    practiceOperatorId: authority.practiceOperatorId ?? null,
    serverTime: now,
    canAssign: practiceIsManager(authority) &&
      ["draft", "ready", "running", "paused"].includes(session.status) &&
      now < session.virtualStartedAt.toMillis() +
        session.setup.durationMinutes * 60000 && session.actionCount < 500,
    operators: state.operators,
    groups: groups.map((g) => ({...g,
      availableDuties: [...g.availableDuties],
      permissions: GROUP_PERMISSIONS.filter((p) =>
        practiceGroupPermission(sessionId, session, authority, g.groupId, p) !==
          null),
      validUntil: practiceGroupPermission(sessionId, session, authority,
        g.groupId, "readProgress") ?? 0}))};
}

/** One session write under the parent revision and action receipt. */
export function preparePracticeStaffChange(sessionId: string, session: Session,
  authority: PracticeCaseAuthority, command: Command): State {
  if (!practiceIsManager(authority)) throw denied();
  const view = practiceStaffProjection(sessionId, session, authority);
  if (command.expectedRevision !== view.revision ||
      command.expectedSourceHash !== view.sourceHash) {
    throw new HttpsError("aborted", "Practice staff changed. Review it again.");
  }
  const group = view.groups.find((g) => g.groupId === command.groupId);
  const prior = view.operators.find((o) => o.operatorId === command.operatorId);
  const displayName = command.displayName.trim();
  if (!displayName || isOrganizerManager(authority.organizer,
    command.operatorId)) throw invalid();
  const duties = (prior?.duties ?? []).filter((d) =>
    d.groupId !== command.groupId);
  if (command.decision.kind === "assign") {
    const d = command.decision;
    const end = session.virtualStartedAt.toMillis() +
      session.setup.durationMinutes * 60000;
    if (!group) throw invalid();
    assertGroupDutyAssignment({canAssign: view.canAssign,
      paceGroup: group.groupId !== "event:whole", now: view.serverTime,
      endAt: end}, d);
    if ((!prior && view.operators.length >= 50) || duties.length >= 20) {
      throw new HttpsError("resource-exhausted",
        "Practice staff limit reached.");
    }
    duties.push({groupId: command.groupId, duty: d.duty,
      sourceHash: group.sourceHash, expiresAtMillis: d.expiresAtMillis,
      grantedBy: authority.actorUid, grantedAtMillis: view.serverTime});
  } else if (!prior) {
    throw new HttpsError("failed-precondition",
      "This practice operator has no saved duty.");
  }
  if (session.actionCount >= 500 || session.runtimeRevision >= 2147483647 ||
      view.revision >= Number.MAX_SAFE_INTEGER) throw invalid();
  const operator = {operatorId: command.operatorId, displayName,
    duties: duties.sort((a, b) => a.groupId.localeCompare(b.groupId))};
  return {clockId: view.clockId, revision: view.revision + 1,
    operators: [...view.operators.filter((o) =>
      o.operatorId !== operator.operatorId), operator]
      .sort((a, b) => a.operatorId.localeCompare(b.operatorId))};
}

function invalid() {
  return new HttpsError("failed-precondition", "Practice staff needs review.");
}
function denied() {
  return new HttpsError("permission-denied",
    "This practice role has no current duty for the group action.");
}
