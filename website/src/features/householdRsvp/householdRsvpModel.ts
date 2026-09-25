import type {GetProgramHouseholdRsvpViewCallablePayload as Credential} from "../../shared/contracts/generated/getProgramHouseholdRsvpViewCallablePayload";
import type {ProgramHouseholdRsvpViewCallableResponse as View} from "../../shared/contracts/generated/programHouseholdRsvpViewCallableResponse";
import type {SubmitProgramHouseholdRsvpCallablePayload as Submission} from "../../shared/contracts/generated/submitProgramHouseholdRsvpCallablePayload";

export type {Credential, View};
export type MemberView = View["members"][number];
export type MemberFunctionView = MemberView["functions"][number];
export type RsvpStatus = MemberFunctionView["rsvpStatus"];
export type ResponseDraft = Submission["responses"][number];

const TOKEN_PATTERN = /^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/;

/**
 * Route-owned credential. The signed link token is only ever accepted from the
 * path parameter, never from query parameters, so it cannot leak via
 * analytics or referer captures the way an accidental query token could.
 */
export function householdRsvpCredential(
  householdToken: string | undefined,
): Credential | null {
  if (!householdToken || householdToken.length < 16 ||
      householdToken.length > 512 || !TOKEN_PATTERN.test(householdToken)) {
    return null;
  }
  return {token: householdToken};
}

const draftKey = (guestId: string, functionId: string) =>
  JSON.stringify([guestId, functionId]);


export function draftFor(
  drafts: ReadonlyMap<string, ResponseDraft>,
  guestId: string,
  functionId: string,
): ResponseDraft | undefined {
  return drafts.get(draftKey(guestId, functionId));
}

export function withResponseDraft(
  drafts: ReadonlyMap<string, ResponseDraft>,
  guestId: string,
  functionId: string,
  patch: Partial<ResponseDraft>,
): Map<string, ResponseDraft> {
  const next = new Map(drafts);
  const current = next.get(draftKey(guestId, functionId)) ?? {
    guestId, functionId, rsvpStatus: "pending" as RsvpStatus,
    partySize: null, responseNote: null,
  };
  next.set(draftKey(guestId, functionId), {...current, ...patch});
  return next;
}

/**
 * Builds the full draft map from the server view. Submitting sends every
 * member/function pair so the payload is deterministic and the server can
 * apply it atomically.
 */
export function draftsFromView(view: View): Map<string, ResponseDraft> {
  const drafts = new Map<string, ResponseDraft>();
  for (const member of view.members) {
    for (const fn of member.functions) {
      drafts.set(draftKey(member.guestId, fn.functionId), {
        guestId: member.guestId,
        functionId: fn.functionId,
        rsvpStatus: fn.rsvpStatus,
        partySize: fn.partySize ?? null,
        responseNote: fn.responseNote ?? null,
      });
    }
  }
  return drafts;
}

export function draftChanged(
  draft: ResponseDraft,
  fn: MemberFunctionView,
): boolean {
  return draft.rsvpStatus !== fn.rsvpStatus ||
    (draft.partySize ?? null) !== (fn.partySize ?? null) ||
    (draft.responseNote ?? null) !== (fn.responseNote ?? null);
}

export type HouseholdRsvpScreen =
  | {kind: "loading"}
  | {kind: "unavailable"; reason: "invalid" | "network"}
  | {
    kind: "ready";
    view: View;
    drafts: Map<string, ResponseDraft>;
    messagingConsent: boolean;
    dirty: boolean;
    pending: boolean;
    submitted: boolean;
    notice: string;
  };
