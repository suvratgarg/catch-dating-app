import type {EventAssistanceSmsPermissionDocument} from
  "../../shared/generated/eventAssistanceSmsPermissionDocument";

/** Shared closed provenance, never consent or a provider delivery permit. */
export type MessageRecipientBinding =
  NonNullable<EventAssistanceSmsPermissionDocument["recipientBinding"]>;
export interface MessageRecipientSource {
  rosterPhone: unknown;
  linkedUid: unknown;
  sourceGeneration: string;
}
interface PriorRecipient {
  phoneE164: string;
  status: "granted" | "revoked";
  recipientBinding?: MessageRecipientBinding;
}
export interface MessageRecipientReview {
  phone: string | null;
  binding: MessageRecipientBinding | null;
}

/**
 * Only a signed phone and explicit consent may create a private endpoint.
 * A present but invalid/conflicting roster number never falls back silently.
 * A current private grant continues to identify its reviewed number, even if
 * Auth changes; withdraw it before reviewing a different number.
 */
export function reviewMessageRecipient(
  actor: {uid: string; phone: string | null},
  source: MessageRecipientSource,
  accepts: (phone: unknown) => boolean,
  previous: PriorRecipient | null,
  previousGrantCurrent: boolean
): MessageRecipientReview {
  const supported = (value: unknown): value is string =>
    typeof value === "string" && accepts(value);
  if (source.linkedUid !== actor.uid) return {phone: null, binding: null};
  if (source.rosterPhone !== null && source.rosterPhone !== undefined) {
    return supported(source.rosterPhone) ? {phone: source.rosterPhone,
      binding: {kind: "rosterPhone", subjectUid: actor.uid,
        sourceGeneration: source.sourceGeneration}} :
      {phone: null, binding: null};
  }
  if (previous?.recipientBinding?.kind === "privateVerifiedPhone" &&
      messageRecipientMatches(previous.recipientBinding, source,
        (phone) => phone === previous.phoneE164) &&
      supported(previous.phoneE164) &&
      ((previous.status === "granted" && previousGrantCurrent) ||
        !supported(actor.phone))) {
    return {phone: previous.phoneE164, binding: previous.recipientBinding};
  }
  return supported(actor.phone) ? {phone: actor.phone,
    binding: {kind: "privateVerifiedPhone", subjectUid: actor.uid,
      sourceGeneration: source.sourceGeneration}} :
    {phone: null, binding: null};
}

/**
 * Legacy absence means roster matching. New bindings also require the exact
 * linked UID and Firestore source generation; clearing a phone never upgrades
 * an old roster grant. Hash-only reply records use the same predicate.
 */
export function messageRecipientMatches(
  binding: MessageRecipientBinding | undefined,
  source: MessageRecipientSource,
  matchesRoster: (phone: unknown) => boolean
): boolean {
  if (binding === undefined) return matchesRoster(source.rosterPhone);
  if (binding.subjectUid !== source.linkedUid ||
      binding.sourceGeneration !== source.sourceGeneration) return false;
  switch (binding.kind) {
  case "rosterPhone": return matchesRoster(source.rosterPhone);
  case "privateVerifiedPhone":
    return source.rosterPhone === null || source.rosterPhone === undefined;
  default: return unsupported(binding);
  }
}

function unsupported(value: never): never {
  void value;
  throw new Error("Unsupported message recipient binding");
}
