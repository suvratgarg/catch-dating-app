import {createHash} from "crypto";
import {HttpsError} from "firebase-functions/v2/https";

export type SetupDecision<T> =
  {mode: "inherit"} |
  {mode: "set"; value: T} |
  {mode: "clear"};

export interface EventCity {
  cityId: string;
  marketId: string;
}

export interface OrganizerSetupDefaults {
  city?: EventCity;
  timezone?: string;
  revision?: number;
}

export interface ResolvedSetupField<T> {
  value: T | null;
  source: "organizer" | "event" | "cleared";
}

export interface ResolvedSetupDefaults {
  city: ResolvedSetupField<EventCity>;
  timezone: ResolvedSetupField<string>;
  organizerDefaultsRevision: number | null;
  organizerDefaultsHash: string;
}

/** Resolves event intent against one transaction-read organizer state. */
export function resolveProgressiveSetupDefaults(input: {
  city: SetupDecision<EventCity>;
  timezone: SetupDecision<string>;
  organizer: OrganizerSetupDefaults;
}): ResolvedSetupDefaults {
  const city = resolveField(input.city, input.organizer.city, false);
  const timezone = resolveField(
    input.timezone, input.organizer.timezone, false
  );
  if (!city.value || !timezone.value) {
    throw new HttpsError(
      "failed-precondition",
      "Choose an event city and timezone before saving."
    );
  }
  const revision = input.organizer.revision;
  if (revision !== undefined &&
      (!Number.isSafeInteger(revision) || revision < 0)) {
    throw new HttpsError("failed-precondition", "Invalid defaults revision.");
  }
  return {
    city,
    timezone,
    organizerDefaultsRevision: revision ?? null,
    organizerDefaultsHash: createHash("sha256")
      .update(JSON.stringify({
        city: input.organizer.city ?? null,
        timezone: input.organizer.timezone ?? null,
        revision: revision ?? null,
      }))
      .digest("hex"),
  };
}

/** Optional later settings may clear; required first-page fields may not. */
export function resolveField<T>(
  decision: SetupDecision<T>,
  inherited: T | undefined,
  optional: boolean
): ResolvedSetupField<T> {
  if (!decision || typeof decision !== "object") {
    throw new HttpsError("invalid-argument", "Missing default decision.");
  }
  if (decision.mode === "set") {
    if (decision.value === undefined || decision.value === null) {
      throw new HttpsError("invalid-argument", "Set needs a value.");
    }
    return {value: decision.value, source: "event"};
  }
  if (decision.mode === "clear") {
    if (!optional) {
      throw new HttpsError("invalid-argument", "This field cannot be cleared.");
    }
    return {value: null, source: "cleared"};
  }
  if (decision.mode === "inherit") {
    return {value: inherited ?? null, source: "organizer"};
  }
  throw new HttpsError("invalid-argument", "Unknown default decision.");
}
