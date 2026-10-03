/** Calendar dates are property-local YYYY-MM-DD values, never UTC instants.
 * These planner inputs are private event snapshots, not public hotel facts. */
export interface LodgingWindow {arrival: string; departure: string}
export interface LodgingGuest extends LodgingWindow {
  id: string;
  requiredFeatures: string[];
  beds: number;
}
export interface LodgingGroup {id: string; parentIds: string[]}
export interface MembershipSuggestion {
  guestId: string;
  groupId: string;
  sourceId: string;
  sourceLabel: string;
}
export interface MembershipDecision {
  guestId: string;
  groupId: string;
  included: boolean;
  authority: "manual" | "acceptedSuggestion";
  sourceId: string | null;
}
export interface LodgingParty {
  id: string;
  guestIds: string[];
  /** Sharing requires an explicit decision, never household inference. */
  confirmed: boolean;
  priority: number;
  requiredRoomType: string | null;
  pin: {inventoryId?: string; hotelId?: string; zoneId?: string} | null;
}
export interface LodgingRoomFacts {
  id: string;
  hotelId: string;
  zoneId: string;
  building: string | null;
  floor: string | null;
  wing: string | null;
  roomType: string;
  beds: number;
  maxOccupants: number;
  /** Only verified functional features can satisfy a guest requirement. */
  verifiedFeatures: string[];
  /** Leaf room IDs; a whole villa lists every component it consumes. */
  resourceIds: string[];
  position: {x: number; y: number} | null;
}
export interface LodgingContract extends LodgingWindow {
  id: string;
  hotelId: string;
  nightlyRoomQuota: number;
}
export interface LodgingInventory {
  id: string;
  contractId: string;
  /** Stable reusable property ID, absent until exact rooms are released. */
  physicalRoomId: string | null;
  /** Type-only capacity is a private contracted unit, never a made-up room. */
  provisional: Omit<LodgingRoomFacts, "id" | "resourceIds" | "position"> | null;
  availability: LodgingWindow[];
}
export interface LodgingPlacement {partyId: string; inventoryId: string}
export interface PublishedLodgingPlacement extends LodgingPlacement {
  locked: boolean;
  checkedIn: boolean;
}
export interface LodgingRevisions {
  source: number;
  inventory: number;
  layout: number;
  published: number;
}
export interface LodgingSnapshot {
  scope: {organizerId: string; programId: string};
  revisions: LodgingRevisions;
  guests: LodgingGuest[];
  parties: LodgingParty[];
  groups: LodgingGroup[];
  memberships: MembershipDecision[];
  rooms: LodgingRoomFacts[];
  contracts: LodgingContract[];
  inventory: LodgingInventory[];
  published: PublishedLodgingPlacement[];
}
export interface LodgingIssue {
  code: string;
  partyIds: string[];
  inventoryIds: string[];
  detail: string;
}
export interface LodgingProposal {
  scope: Readonly<{organizerId: string; programId: string}>;
  id: string;
  revisions: Readonly<LodgingRevisions>;
  placements: ReadonlyArray<Readonly<LodgingPlacement>>;
  unplacedPartyIds: readonly string[];
  explanations: readonly string[];
  score: readonly number[];
  search: {complete: boolean; explored: number};
}
