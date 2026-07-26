import {HttpsError} from "firebase-functions/v2/https";
import {OrganizerSupplyCapabilities} from
  "./generated/organizerSupplyCapabilities";

export interface OrganizerCapabilityAuthority {
  ownershipState?: unknown;
  claimState?: unknown;
}

/**
 * Derives the organizer-level member-affordance ceiling from canonical
 * ownership and claim authority. This is the only server policy constructor;
 * callers persist its output instead of recreating ownership conditionals.
 * @param {OrganizerCapabilityAuthority} authority Canonical authority fields.
 * @return {OrganizerSupplyCapabilities} Capability ceiling.
 */
export function organizerSupplyCapabilitiesFor(
  authority: OrganizerCapabilityAuthority
): OrganizerSupplyCapabilities {
  const ownershipState = stringValue(authority.ownershipState);
  const claimState = stringValue(authority.claimState);
  const managed = ["userCreated", "claimed", "transferred"].includes(
    ownershipState
  ) || ["claimed", "verified"].includes(claimState);
  if (managed) {
    return {
      mode: "claimed_managed",
      bookable: true,
      paymentsEnabled: true,
      waitlistEnabled: true,
      hostContactEnabled: true,
      claimable: false,
      reviewPolicy: "attended_event_only",
    };
  }
  return {
    mode: "unclaimed_read_only",
    bookable: false,
    paymentsEnabled: false,
    waitlistEnabled: false,
    hostContactEnabled: false,
    claimable: claimState === "unclaimed",
    reviewPolicy: "after_event_end",
  };
}

/**
 * Reads a stored capability set only when it exactly matches canonical
 * authority. Legacy missing fields derive safely; stale or broadened stored
 * values fail closed.
 * @param {Record<string, unknown>} organizer Organizer document.
 * @return {OrganizerSupplyCapabilities} Verified capability ceiling.
 */
export function verifiedOrganizerSupplyCapabilities(
  organizer: Record<string, unknown>
): OrganizerSupplyCapabilities {
  const ownership = recordValue(organizer.ownership);
  const claim = recordValue(organizer.claim);
  const expected = organizerSupplyCapabilitiesFor({
    ownershipState: ownership.state,
    claimState: claim.state,
  });
  const stored = organizer.supplyCapabilities;
  if (stored === undefined) return expected;
  if (!sameCapabilities(stored, expected)) {
    throw new HttpsError(
      "failed-precondition",
      "Organizer supply capabilities do not match canonical ownership."
    );
  }
  return expected;
}

/**
 * Rejects a booking, payment, waitlist, or host-contact action that exceeds
 * the organizer capability ceiling.
 * @param {OrganizerSupplyCapabilities} capabilities Verified capabilities.
 * @param {"booking"|"payment"|"waitlist"|"host_contact"} action Action.
 */
export function assertOrganizerCapability(
  capabilities: OrganizerSupplyCapabilities,
  action: "booking" | "payment" | "waitlist" | "host_contact"
) {
  const allowed = {
    booking: capabilities.bookable,
    payment: capabilities.paymentsEnabled,
    waitlist: capabilities.waitlistEnabled,
    host_contact: capabilities.hostContactEnabled,
  }[action];
  if (!allowed) {
    throw new HttpsError(
      "failed-precondition",
      "This unclaimed organizer is read-only on Catch."
    );
  }
}

function sameCapabilities(
  value: unknown,
  expected: OrganizerSupplyCapabilities
): boolean {
  if (!value || typeof value !== "object" || Array.isArray(value)) return false;
  const candidate = value as Record<string, unknown>;
  return Object.entries(expected).every(([key, expectedValue]) =>
    candidate[key] === expectedValue
  ) && Object.keys(candidate).length === Object.keys(expected).length;
}

function recordValue(value: unknown): Record<string, unknown> {
  return value && typeof value === "object" && !Array.isArray(value) ?
    value as Record<string, unknown> :
    {};
}

function stringValue(value: unknown): string {
  return typeof value === "string" ? value : "";
}
