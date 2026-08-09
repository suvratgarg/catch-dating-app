import {EventDocument} from
  "../shared/generated/firestoreAdminTypes";

export const crossPathsPilotMarketId = "in-mh-mumbai";
export const crossPathsPilotMinimumEvents = 2;
export const crossPathsPilotMaximumEvents = 3;
export const crossPathsPilotMinimumMembers = 20;
export const crossPathsPilotMaximumMembers = 50;
export const crossPathsPilotMinimumEventLeadMillis = 6 * 60 * 60 * 1000;

/**
 * Returns whether an event is inside the selected-event Cross Paths pilot.
 * Real events must be explicitly enabled in Mumbai. Synthetic demo events
 * retain a separate, explicit escape hatch for dev/test fixtures.
 */
export function crossPathsPilotEventEnabled(
  event: EventDocument | unknown
): boolean {
  if (!event || typeof event !== "object" || Array.isArray(event)) {
    return false;
  }
  const row = event as Record<string, unknown>;
  if (row.crossPathsDiscoveryEnabled !== true) return false;
  return row.synthetic === true ||
    row.discoveryMarketId === crossPathsPilotMarketId;
}

export function crossPathsEventWriteInvalidationMode(
  before: EventDocument | unknown,
  after: EventDocument | unknown
): "none" | "pending" | "all" {
  const afterRow = after && typeof after === "object" && !Array.isArray(after) ?
    after as Record<string, unknown> : null;
  if (afterRow?.status !== "active") return "all";
  return crossPathsPilotEventEnabled(before) &&
    !crossPathsPilotEventEnabled(after) ? "pending" : "none";
}
