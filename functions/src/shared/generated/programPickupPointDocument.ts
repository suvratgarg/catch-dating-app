/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned program pickup station such as an airport terminal arrivals zone. Scopes greeter and dispatcher duties and transport grouping.
 */
export interface ProgramPickupPointDocument {
  programId: string;
  organizerId: string;
  kind: "airport" | "railway" | "venue" | "other";
  /**
   * Station label such as 'DEL T3 arrivals exit 4'.
   */
  label: string;
  iataCode: string | null;
  terminal: string | null;
  meetingZone: string | null;
  latitude: number | null;
  longitude: number | null;
  /**
   * Guest-facing pickup instructions shown on travel confirmations.
   */
  instructions: string | null;
  active: boolean;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  revision: number;
}
