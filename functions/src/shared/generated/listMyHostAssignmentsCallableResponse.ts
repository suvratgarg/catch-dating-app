/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * The caller's host work assignments with server-resolved shell destinations. Assignments sort by scope kind (event before program) then scope id.
 */
export interface ListMyHostAssignmentsCallableResponse {
  /**
   * @maxItems 128
   */
  assignments: {
    kind: "event" | "program";
    /**
     * The eventId or programId this assignment scopes to.
     */
    scopeId: string;
    organizerId: string;
    title: string;
    subtitle: string | null;
    organizerName: string;
    duties: {
      /**
       * Canonical duty across event and program scopes. checkInOperator event grants map to functionCheckIn; eventOperator grants map to eventLead.
       */
      duty:
        | "programCoordinator"
        | "guestRelations"
        | "communications"
        | "functionCheckIn"
        | "functionLead"
        | "airportGreeter"
        | "transportDispatcher"
        | "hotelDesk"
        | "reconciliationViewer"
        | "stakeholderViewer"
        | "eventLead";
      /**
       * Station scope for airportGreeter/transportDispatcher duties.
       *
       * @maxItems 32
       */
      pickupPointIds?: string[];
      /**
       * Hotel scope for hotelDesk duties.
       *
       * @maxItems 64
       */
      hotelIds?: string[];
      /**
       * Function scope for functionCheckIn/functionLead duties.
       *
       * @maxItems 64
       */
      functionIds?: string[];
    }[];
    /**
     * Resolved destinations in canonical order; the shell renders the first three plus an overflow entry.
     */
    destinations: (
      | "arrivals"
      | "dispatch"
      | "inbound"
      | "rooms"
      | "nowNext"
      | "door"
      | "walkIns"
      | "attention"
      | "guests"
      | "rsvpInbox"
      | "imports"
      | "inbox"
      | "moments"
      | "trips"
      | "exceptions"
      | "export"
      | "overview"
    )[];
    /**
     * Destinations beyond the first three, for the overflow menu.
     */
    overflowDestinations: (
      | "arrivals"
      | "dispatch"
      | "inbound"
      | "rooms"
      | "nowNext"
      | "door"
      | "walkIns"
      | "attention"
      | "guests"
      | "rsvpInbox"
      | "imports"
      | "inbox"
      | "moments"
      | "trips"
      | "exceptions"
      | "export"
      | "overview"
    )[];
    /**
     * task = single destination, no bar; tabs = two or three destinations in the bar; programWorkspace = program-locked coordinator workspace; none = no reachable destination.
     */
    shellMode: "task" | "tabs" | "programWorkspace" | "none";
    grantExpiresAtMillis: number | null;
  }[];
  /**
   * The app shell the caller should land in: managers always get managerShell even when they also hold staff assignments; staff get workShell only while at least one assignment is live.
   */
  shellEntry: "managerShell" | "workShell" | "none";
}
