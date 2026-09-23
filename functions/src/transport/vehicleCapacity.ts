/** Capacity contract shared by suggestions and the final dispatch decision. */
export interface VehicleClass {
  id: string;
  passengerCapacity: number;
  luggageCapacity: number;
  capabilities: readonly string[];
}

export function vehicleFits(vehicle: VehicleClass, passengers: number,
  luggage: number, capabilities: readonly string[]): boolean {
  return vehicle.passengerCapacity >= passengers &&
    vehicle.luggageCapacity >= luggage && capabilities.every((capability) =>
    vehicle.capabilities.includes(capability));
}
