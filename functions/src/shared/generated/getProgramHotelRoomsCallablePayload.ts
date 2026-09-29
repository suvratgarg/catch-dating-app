/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Hotel-scoped accommodation view: room blocks with computed capacity, live stays, and guests routed to the hotel with no live stay. Requires the caller's hotelDesk duty to cover the hotel, or program coordinator/manager access.
 */
export interface GetProgramHotelRoomsCallablePayload {
  programId: string;
  hotelId: string;
}
