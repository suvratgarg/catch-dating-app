import type {ProgramDutyAssignment} from "./programAuthority";

export type ProgramResourceScope = {pickup: string[]; hotels: string[]};

/** Keep both restrictions within each duty, then union the resulting queries.
 * Account for other IN predicates so each query stays within 30 disjunctions.
 * null assignments is an explicitly unrestricted manager; [] grants nothing.
 */
export function programResourceScopes(
  assignments: readonly ProgramDutyAssignment[] | null,
  options: {requestedPickup?: string | null; baseDisjunctions?: number} = {},
): ProgramResourceScope[] {
  const budget = Math.floor(30 / (options.baseDisjunctions ?? 1));
  if (budget < 1) throw new RangeError("Invalid query disjunction budget.");
  const chunks = (ids: string[]): string[][] => ids.length === 0 ? [[]] :
    Array.from({length: Math.ceil(ids.length / budget)}, (_, index) =>
      ids.slice(index * budget, (index + 1) * budget));
  const scopes = (assignments ?? [{pickupPointIds: [], hotelIds: []}])
    .flatMap((assignment) => {
      let pickups = [...new Set(assignment.pickupPointIds)].sort();
      const hotels = [...new Set(assignment.hotelIds)].sort();
      if (options.requestedPickup) {
        if (pickups.length && !pickups.includes(options.requestedPickup)) {
          return [];
        }
        pickups = [options.requestedPickup];
      }
      const pickupChunks = hotels.length ?
        (pickups.length ? pickups.map((id) => [id]) : [[]]) : chunks(pickups);
      return pickupChunks.flatMap((pickup) =>
        chunks(hotels).map((hotelScope) => ({pickup, hotels: hotelScope})));
    });
  return [...new Map(scopes.map((scope) =>
    [JSON.stringify(scope), scope])).values()];
}
