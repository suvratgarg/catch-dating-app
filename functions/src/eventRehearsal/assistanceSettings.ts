import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor} from
  "../shared/generated/firestoreAdminTypes";
import type {ControlEventRehearsalCallablePayload as Control} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import type {EventRehearsalBootstrapCallableResponse as Bootstrap} from
  "../shared/generated/eventRehearsalBootstrapCallableResponse";
import {operationContentHash as hash} from "../operations/durableActions";
import {suggestedTemplate, templateTargetsAreCurrent} from
  "../eventSuccess/operations/policySettings";
import {practiceContext} from "./assistanceIdentity";
import {practiceMovementSource} from "./movementSource";
import {practiceIsManager} from "./groupStaff";
import type {PracticeCaseAuthority} from "./assistanceCases";

export type PracticeSettings = NonNullable<Session["assistanceSettings"]>;
export type PracticeSettingsCommand = NonNullable<Control["settings"]>;
export type PracticeSettingsReview = NonNullable<Bootstrap["settingsReview"]>;
export type PracticeSettingsGroup = PracticeSettingsReview["groups"][number];
export type PracticeRuntime = NonNullable<PracticeSettings["runtime"]>;

export function practiceSettingsState(sessionId: string,
  session: Session): PracticeSettings {
  const clockId = practiceContext(session, {sessionId}).clockId;
  const state = session.assistanceSettings ??
    {clockId, runtime: null, preferences: []};
  const groups = practiceMovementSource(sessionId, session,
    "event:whole").groups;
  if (state.clockId !== clockId ||
      new Set(state.preferences.map((p) => p.groupId)).size !==
        state.preferences.length || state.preferences.some((p) =>
    !groups.some((g) => g.groupId === p.groupId) ||
      p.groupId === "event:whole" && p.preference.kind === "inherit")) {
    throw invalid("Practice settings no longer match this run.");
  }
  return state;
}

export function practiceSettingsGroup(sessionId: string, session: Session,
  groupId: string): PracticeSettingsGroup {
  const state = practiceSettingsState(sessionId, session);
  const source = practiceMovementSource(sessionId, session, groupId);
  const own = state.preferences.find((p) => p.groupId === groupId)?.preference;
  const inherited = !own || own.kind === "inherit";
  const effective = inherited ? state.preferences.find((p) =>
    p.groupId === "event:whole")?.preference : own;
  const template = effective?.kind === "configured" ? effective.template : null;
  const disabled = effective?.kind === "disabled" ||
    template?.setting.kind === "disabled";
  const current = !template || templateTargetsAreCurrent(template,
    source.destinations.map((d) => d.target));
  return {groupId, label: source.groups.find((g) =>
    g.groupId === groupId)!.label,
  preference: own ?? {kind: "inherit"},
  effective: current ? template : null,
  status: disabled ? "disabled" : !current ? "sourceChanged" : template ?
    "configured" : "unconfigured",
  origin: !effective ? "none" : inherited || groupId === "event:whole" ?
    "event" : "group",
  setup: {eventEnd: source.endAt, destinations: source.destinations}};
}

export function practiceSettingsProjection(sessionId: string,
  session: Session, authority: PracticeCaseAuthority): PracticeSettingsReview {
  const source = practiceMovementSource(sessionId, session, "event:whole");
  const state = practiceSettingsState(sessionId, session);
  const suggested = suggestedTemplate("lateJoin");
  if (suggested?.kind !== "lateJoin") throw invalid("Missing practice rules.");
  const groups = source.groups.map((g) => practiceSettingsGroup(sessionId,
    session, g.groupId));
  return {context: source.context, setupRevision: session.setupRevision,
    runtimeRevision: session.runtimeRevision, serverTime: source.now,
    sourceHash: hash([source.context, groups.map((g) => [g.groupId, g.setup])]),
    canConfigure: practiceIsManager(authority) &&
      ["draft", "ready", "running", "paused"].includes(session.status) &&
      source.now < source.endAt,
    runtime: state.runtime, suggested, groups};
}

/** Commit an event command with its receipt and actor evaluations. */
export function preparePracticeSettings(sessionId: string, session: Session,
  actors: readonly Actor[], command: PracticeSettingsCommand,
  authority: PracticeCaseAuthority): PracticeSettings {
  const review = practiceSettingsProjection(sessionId, session, authority);
  if (!practiceIsManager(authority)) {
    throw new HttpsError("permission-denied",
      "Only the Host can change rules.");
  }
  if (!review.canConfigure ||
      review.sourceHash !== command.expectedSourceHash) {
    throw new HttpsError("aborted", "Review the current practice settings.");
  }
  const state = structuredClone(practiceSettingsState(sessionId, session));
  if (command.kind === "pause") {
    if (!state.runtime) throw invalid("Configure practice updates first.");
    state.runtime.status = "paused";
    return state;
  }
  if (command.kind === "setRule") {
    const group = review.groups.find((g) => g.groupId === command.groupId);
    if (!group || command.groupId === "event:whole" &&
        command.preference.kind === "inherit") {
      throw invalid("Choose a configured group and explicit event rule.");
    }
    if (command.preference.kind === "configured") {
      const template = command.preference.template;
      const cutoff = template.config.cutoff;
      if (template.setting.kind === "enabled" &&
          (!templateTargetsAreCurrent(template,
            group.setup.destinations.map((d) => d.target)) ||
          cutoff.kind === "time" &&
          (cutoff.at <= review.serverTime ||
            cutoff.at > group.setup.eventEnd))) {
        throw invalid("Review the joining destination and cutoff.");
      }
      if (template.setting.kind === "enabled" && state.runtime &&
          template.config.unanswered === "hostReviewAtDeadline" &&
          state.runtime.configuration.responseDeadline === null) {
        throw invalid("Configure a response deadline before using this rule.");
      }
    }
    state.preferences = state.preferences.filter((p) =>
      p.groupId !== command.groupId);
    if (command.preference.kind !== "inherit") {
      state.preferences.push({groupId: command.groupId,
        preference: structuredClone(command.preference)});
    }
    return state;
  }
  const configuration = structuredClone(command.configuration);
  const endAt = review.groups[0].setup.eventEnd;
  if (configuration.responseDeadline !== null &&
      (configuration.responseDeadline <= review.serverTime ||
        configuration.responseDeadline > endAt) ||
      review.groups.some((g) => g.status === "configured" &&
        g.effective?.config.unanswered === "hostReviewAtDeadline") &&
        configuration.responseDeadline === null ||
      configuration.deliveryPolicy.maxAttemptsPerRoute >
        configuration.deliveryPolicy.maxAttempts) {
    throw invalid("Review the practice timing and delivery limits.");
  }
  const choices = configuration.laterChoices ?? [];
  const targets = review.groups.flatMap((g) =>
    g.setup.destinations.map((d) => hash(d.target)));
  if (new Set(choices.map((c) => hash(c.target))).size !== choices.length ||
      choices.some((c) =>
        !c.label.trim() || !targets.includes(hash(c.target)))) {
    throw invalid("Choose distinct joining points from the practice setup.");
  }
  for (const actor of actors) {
    const recipe = actor.assistanceAutomation;
    if (recipe?.origin !== "eventSettings") continue;
    if (recipe.nextOutcomeIndex > configuration.outcomes.length ||
        recipe.outcomes.slice(0, recipe.nextOutcomeIndex).some((o, i) =>
          hash(o) !== hash(configuration.outcomes[i]))) {
      throw invalid("Consumed practice outcomes cannot be rewritten.");
    }
  }
  state.runtime = {status: "enabled", configuration};
  return state;
}
function invalid(message: string) {
  return new HttpsError("failed-precondition", message);
}
