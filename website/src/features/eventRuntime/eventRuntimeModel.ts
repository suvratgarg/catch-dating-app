import type {EventRuntimeBootstrap} from "../../firebase";
import {eventRuntimeCopy, eventRuntimeQuestionnairePacks} from "../../content/eventRuntime";

export type {EventRuntimeBootstrap};
export type EventRuntimeParticipant = NonNullable<EventRuntimeBootstrap["participant"]>;
export type EventRuntimeGender = NonNullable<
  EventRuntimeParticipant["runtimeProfile"]["gender"]
>;

export interface EventRuntimeQuestion {
  id: string;
  prompt: string;
  options: Array<{id: string; label: string}>;
}

export interface EventRuntimeQuestionnaire {
  title: string;
  questions: EventRuntimeQuestion[];
}

export function resolveEventRuntimeQuestionnaire(
  config: EventRuntimeBootstrap["event"]["questionnaireConfig"]
): EventRuntimeQuestionnaire {
  if (config?.customQuestions?.length) {
    return {
      title: config.customTitle?.trim() || eventRuntimeCopy.compatibilityTitle,
      questions: config.customQuestions,
    };
  }
  const templateId = config?.templateId ?? "balanced";
  const pack = eventRuntimeQuestionnairePacks[
    templateId as keyof typeof eventRuntimeQuestionnairePacks
  ] ?? eventRuntimeQuestionnairePacks.balanced;
  return {
    title: pack.title,
    questions: pack.questions.map((question) => ({
      ...question,
      options: [...question.options],
    })),
  };
}

export function eventRuntimeStageForParticipant(
  participant: EventRuntimeBootstrap["participant"]
): "profile" | "approval" | "runtime" | "unavailable" {
  if (!participant || ["needsClaim", "needsInput"].includes(participant.accessStatus)) {
    return "profile";
  }
  if (participant.accessStatus === "pendingApproval") return "approval";
  if (participant.accessStatus === "ready") return "runtime";
  return "unavailable";
}

export function normalizeRuntimePhone(value: string): string {
  return value.replace(/[\s()-]/gu, "");
}

export function eventRuntimeError(error: unknown): string {
  switch (errorCode(error)) {
    case "auth/invalid-verification-code":
      return eventRuntimeCopy.invalidCode;
    case "auth/code-expired":
    case "auth/session-expired":
      return eventRuntimeCopy.verificationExpired;
    case "auth/too-many-requests":
    case "auth/quota-exceeded":
    case "functions/resource-exhausted":
      return eventRuntimeCopy.tooManyRequests;
    case "functions/failed-precondition":
    case "functions/not-found":
      return eventRuntimeCopy.eventUnavailable;
    default:
      return eventRuntimeCopy.genericError;
  }
}

function errorCode(error: unknown): string {
  if (typeof error !== "object" || error === null || !("code" in error)) return "";
  return typeof error.code === "string" ? error.code : "";
}
