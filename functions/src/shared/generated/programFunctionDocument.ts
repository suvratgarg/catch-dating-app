/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned private function (ceremony, reception, offsite session) inside a program. Separate from public events documents; no public read surface exists.
 */
export interface ProgramFunctionDocument {
  programId: string;
  organizerId: string;
  name: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  startsAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  endsAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  venueName: string;
  venueNotes?: string | null;
  /**
   * Optional precise venue pin selected from Places or dropped manually; venueName remains the display string.
   */
  venueLocation?: {
    name: string;
    address?: string | null;
    placeId?: string | null;
    latitude: number;
    longitude: number;
    notes?: string | null;
  } | null;
  /**
   * Short wardrobe guidance shown on invitations and reminders, such as 'Pastel formal' or 'Poolside casual'.
   */
  dressCode?: string | null;
  /**
   * Guest-facing instructions for this function (entry gate, shuttle note, what to bring). Never carries staff-only detail.
   */
  instructions?: string | null;
  /**
   * Absent on functions written before per-function invitations; reads as allGuests.
   */
  invitationMode?: "allGuests" | "selectedGuests";
  /**
   * When true, functionCheckIn/functionLead duties may mark programFunctionGuests attendanceStatus at the door.
   */
  checkInEnabled?: boolean;
  /**
   * Server-maintained rollup of attending party sizes for catering and venue counts.
   */
  expectedCount?: number | null;
  /**
   * Server-maintained rollup of programFunctionGuests attendanceStatus=checkedIn.
   */
  checkedInCount?: number | null;
  status: "scheduled" | "completed" | "cancelled";
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
