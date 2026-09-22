export interface TransportParty {
  id: string;
  programId: string;
  pickupPointId: string;
  destinationId: string;
  readiness: "expected" | "ready";
  availableAtMillis: number | null;
  passengers: number;
  luggageUnits: number;
  requiredCapabilities: readonly string[];
  dedicatedVehicle: boolean;
}

export interface VehicleClass {
  id: string;
  passengerCapacity: number;
  luggageCapacity: number;
  capabilities: readonly string[];
}

export interface TransportGroupSuggestion {
  programId: string;
  pickupPointId: string;
  destinationId: string;
  readiness: TransportParty["readiness"];
  partyIds: string[];
  vehicleClassId: string;
  passengers: number;
  luggageUnits: number;
  earliestAtMillis: number;
  latestAtMillis: number;
  dispatchByMillis: number | null;
  waitOverdue: boolean;
}

export interface TransportGroupingInput {
  parties: readonly TransportParty[];
  vehicleClasses: readonly VehicleClass[];
  windowMillis: number;
  maxReadyWaitMillis: number;
  nowMillis: number;
}

export interface TransportGroupingResult {
  groups: TransportGroupSuggestion[];
  unassigned: Array<{partyId: string;
    reason: "missingTime" | "noSuitableVehicle"}>;
}

interface Group {
  view: TransportGroupSuggestion;
  scope: string;
  dedicated: boolean;
  capabilities: Set<string>;
}

export function suggestTransportGroups(
  input: TransportGroupingInput
): TransportGroupingResult {
  validateInput(input);
  const classes = [...input.vehicleClasses].sort((a, b) =>
    a.passengerCapacity - b.passengerCapacity ||
    a.luggageCapacity - b.luggageCapacity ||
    a.capabilities.length - b.capabilities.length || compare(a.id, b.id));
  const parties = [...input.parties].sort((a, b) =>
    compare(scope(a), scope(b)) ||
    (a.availableAtMillis ?? Number.MAX_SAFE_INTEGER) -
      (b.availableAtMillis ?? Number.MAX_SAFE_INTEGER) || compare(a.id, b.id));
  const groups: Group[] = [];
  const unassigned: TransportGroupingResult["unassigned"] = [];
  for (const party of parties) {
    const time = party.availableAtMillis;
    if (time === null) {
      unassigned.push({partyId: party.id, reason: "missingTime"});
      continue;
    }
    const ownClass = fittingClass(classes, party.passengers,
      party.luggageUnits, party.requiredCapabilities);
    if (!ownClass) {
      unassigned.push({partyId: party.id, reason: "noSuitableVehicle"});
      continue;
    }
    const partyScope = scope(party);
    const window = party.readiness === "ready" ?
      Math.min(input.windowMillis, input.maxReadyWaitMillis) :
      input.windowMillis;
    const group = party.dedicatedVehicle ? undefined :
      groups.find((candidate) =>
        !candidate.dedicated && candidate.scope === partyScope &&
        time - candidate.view.earliestAtMillis <= window &&
        fittingClass(classes, candidate.view.passengers + party.passengers,
          candidate.view.luggageUnits + party.luggageUnits,
          [...candidate.capabilities, ...party.requiredCapabilities]) !==
          undefined);
    if (group) {
      const view = group.view;
      view.partyIds.push(party.id);
      view.passengers += party.passengers;
      view.luggageUnits += party.luggageUnits;
      view.latestAtMillis = time;
      for (const value of party.requiredCapabilities) {
        group.capabilities.add(value);
      }
      view.vehicleClassId = fittingClass(classes, view.passengers,
        view.luggageUnits, [...group.capabilities])!.id;
    } else {
      const dispatchByMillis = party.readiness === "ready" ?
        time + input.maxReadyWaitMillis : null;
      if (dispatchByMillis !== null) requireInteger(dispatchByMillis);
      groups.push({scope: partyScope, dedicated: party.dedicatedVehicle,
        capabilities: new Set(party.requiredCapabilities), view: {
          programId: party.programId, pickupPointId: party.pickupPointId,
          destinationId: party.destinationId, readiness: party.readiness,
          partyIds: [party.id], vehicleClassId: ownClass.id,
          passengers: party.passengers, luggageUnits: party.luggageUnits,
          earliestAtMillis: time, latestAtMillis: time, dispatchByMillis,
          waitOverdue: dispatchByMillis !== null &&
            input.nowMillis >= dispatchByMillis,
        }});
    }
  }
  return {groups: groups.map((group) => group.view), unassigned};
}

function fittingClass(classes: readonly VehicleClass[], passengers: number,
  luggage: number, capabilities: readonly string[]): VehicleClass | undefined {
  return classes.find((vehicle) => vehicle.passengerCapacity >= passengers &&
    vehicle.luggageCapacity >= luggage && capabilities.every((capability) =>
    vehicle.capabilities.includes(capability)));
}

function scope(party: TransportParty): string {
  return JSON.stringify([party.programId, party.pickupPointId,
    party.destinationId, party.readiness]);
}

function compare(a: string, b: string): number {
  return a < b ? -1 : a > b ? 1 : 0;
}

function requireInteger(value: number, minimum = 0): void {
  if (!Number.isSafeInteger(value) || value < minimum) {
    throw new RangeError("Invalid transport count or timestamp.");
  }
}

function requireId(value: string): void {
  if (!value || value.trim() !== value || value.length > 180) {
    throw new TypeError("Invalid transport identifier.");
  }
}

function uniqueIds(values: readonly string[]): void {
  values.forEach(requireId);
  if (new Set(values).size !== values.length) {
    throw new TypeError("Transport identifiers must be unique.");
  }
}

function validateInput(input: TransportGroupingInput): void {
  requireInteger(input.windowMillis);
  requireInteger(input.maxReadyWaitMillis);
  requireInteger(input.nowMillis);
  if (input.parties.length > 5000 || input.vehicleClasses.length > 64) {
    throw new RangeError("Transport planning input exceeds its bounded scope.");
  }
  uniqueIds(input.parties.map((party) => party.id));
  uniqueIds(input.vehicleClasses.map((vehicle) => vehicle.id));
  for (const vehicle of input.vehicleClasses) {
    requireInteger(vehicle.passengerCapacity, 1);
    requireInteger(vehicle.luggageCapacity);
    uniqueIds(vehicle.capabilities);
  }
  for (const party of input.parties) {
    [party.programId, party.pickupPointId, party.destinationId]
      .forEach(requireId);
    requireInteger(party.passengers, 1);
    requireInteger(party.luggageUnits);
    uniqueIds(party.requiredCapabilities);
    if (party.availableAtMillis !== null) {
      requireInteger(party.availableAtMillis);
      if (party.readiness === "ready" &&
          party.availableAtMillis > input.nowMillis) {
        throw new RangeError("A ready observation cannot be in the future.");
      }
    }
  }
}
