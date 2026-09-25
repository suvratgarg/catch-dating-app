// Pure work-shell resolution for restricted Host staff. A duty grant names
// what a staff member may do; this module maps those duties onto the small
// destination set each shell mode can render. It never imports Firebase,
// contracts, or generated code so the same policy can run anywhere.

export type WorkDuty =
  "programCoordinator" | "guestRelations" | "communications" |
    "functionCheckIn" | "functionLead" | "airportGreeter" | "hotelDesk" |
    "transportDispatcher" | "reconciliationViewer" | "stakeholderViewer" |
    "eventLead";

// Destinations stay camelCase like the rest of the codebase's enum strings;
// the shell maps them onto labels such as "Now & Next" or "RSVP Inbox".
export type WorkDestination =
  "arrivals" | "dispatch" | "inbound" | "rooms" | "nowNext" | "door" |
    "walkIns" | "attention" | "guests" | "rsvpInbox" | "imports" | "inbox" |
    "moments" | "trips" | "exceptions" | "export" | "overview";

export type WorkShellMode = "task" | "tabs" | "programWorkspace" | "none";

export interface WorkScope {
  kind: "program" | "event";
  id: string;
}

export interface WorkDutyLike {
  duty: string;
  // Optional restriction: when present and non-empty the duty only applies
  // to the listed scope ids. Absent or empty means the whole assignment
  // scope, which is the common case for a duty carried on one assignment.
  scopeIds?: ReadonlyArray<string>;
}

export interface WorkShellResolution {
  // Union across the scope's duties in canonical order. When more than
  // three destinations resolve, the shell shows the first three plus an
  // overflow entry; `overflow` mirrors that tail for callers and tests.
  destinations: WorkDestination[];
  overflow: WorkDestination[];
  shellMode: WorkShellMode;
}

// Canonical bottom-bar order. Sorting by this order keeps the rendered
// shell stable no matter which order grants or duties arrive in.
export const WORK_DESTINATIONS: ReadonlyArray<WorkDestination> = [
  "arrivals", "dispatch", "inbound", "rooms", "nowNext", "door", "walkIns",
  "attention", "guests", "rsvpInbox", "imports", "inbox", "moments", "trips",
  "exceptions", "export", "overview",
];

const DESTINATION_RANK = new Map<WorkDestination, number>(
  WORK_DESTINATIONS.map((destination, index) => [destination, index]));

// Duty -> destinations. Each duty grants at most three destinations; the
// shell's assignment menu carries anything else a duty needs. The
// programCoordinator row is intentionally empty: it resolves to the
// program-locked workspace shell mode instead of bar destinations.
export const WORK_DUTY_DESTINATIONS:
Readonly<Record<WorkDuty, ReadonlyArray<WorkDestination>>> = {
  programCoordinator: [],
  guestRelations: ["guests", "rsvpInbox", "imports"],
  communications: ["inbox", "moments"],
  functionCheckIn: ["door", "walkIns"],
  functionLead: ["nowNext", "door", "attention"],
  airportGreeter: ["arrivals"],
  hotelDesk: ["inbound", "rooms"],
  transportDispatcher: ["arrivals", "dispatch"],
  reconciliationViewer: ["trips", "exceptions", "export"],
  stakeholderViewer: ["overview"],
  eventLead: ["nowNext", "door", "attention"],
};

export function resolveScopeDestinations(
  scope: WorkScope,
  duties: ReadonlyArray<WorkDutyLike>,
): WorkShellResolution {
  const applicable = duties.filter((duty) => dutyAppliesToScope(duty, scope));
  const grantedDuties = new Set(applicable.map((duty) => duty.duty));
  if (grantedDuties.has("programCoordinator")) {
    // The coordinator workspace is a distinct program-locked shell mode
    // with its own local sections; it never fills the bottom bar.
    return {destinations: [], overflow: [], shellMode: "programWorkspace"};
  }
  const granted = new Set<WorkDestination>();
  for (const duty of applicable) {
    for (const destination of destinationsForDuty(duty.duty)) {
      granted.add(destination);
    }
    // A greeter only reaches Dispatch when the same scope also grants
    // transportDispatcher; alone, the airport station stays read/run only.
    if (duty.duty === "airportGreeter" &&
        grantedDuties.has("transportDispatcher")) {
      granted.add("dispatch");
    }
  }
  const destinations = [...granted].sort((a, b) =>
    (DESTINATION_RANK.get(a) ?? 0) - (DESTINATION_RANK.get(b) ?? 0));
  return {
    destinations,
    overflow: destinations.slice(3),
    shellMode: destinations.length === 0 ? "none" :
      destinations.length === 1 ? "task" : "tabs",
  };
}

// Event grants carry role names, not duty names. This is the only place the
// role vocabulary maps onto the shared duty union; unknown roles resolve to
// null so callers can drop them rather than granting destinations.
export function mapEventRoleToDuty(role: string): WorkDuty | null {
  switch (role) {
  case "checkInOperator":
    return "functionCheckIn";
  case "eventOperator":
    return "eventLead";
  default:
    return null;
  }
}

function dutyAppliesToScope(duty: WorkDutyLike, scope: WorkScope): boolean {
  return duty.scopeIds === undefined || duty.scopeIds.length === 0 ||
    duty.scopeIds.includes(scope.id);
}

function destinationsForDuty(duty: string): ReadonlyArray<WorkDestination> {
  // Unknown duty names are forward-compatible no-ops: a newer duty must
  // never widen a restricted shell by accident.
  const table: Readonly<Record<string, ReadonlyArray<WorkDestination>>> =
    WORK_DUTY_DESTINATIONS;
  return table[duty] ?? [];
}
