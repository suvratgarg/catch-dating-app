/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Create or update reserved room inventory at a program hotel. Coordinator/manager only — hotelDesk consumes inventory but cannot define it. totalRooms may not be lowered below the block's live consuming stays.
 */
export interface UpsertProgramRoomBlockCallablePayload {
  programId: string;
  /**
   * Existing block to update. Omit to create a new block.
   */
  roomBlockId?: string;
  /**
   * Required on updates; the write fails when the stored revision moved.
   */
  expectedRevision?: number;
  /**
   * Hotel the block is at. Immutable on existing blocks.
   */
  hotelId: string;
  /**
   * Human label for the block (e.g. "Bride family", "Floor 3").
   */
  label: string;
  /**
   * Optional room class (Deluxe, Suite). Null when the block is type-agnostic.
   */
  roomType?: string | null;
  totalRooms: number;
  /**
   * Guest groups this block is earmarked for; empty for general inventory.
   *
   * @maxItems 100
   */
  heldForGroupIds: string[];
  /**
   * Block window start. Required on create; omit on update to keep the stored value.
   */
  startsAtMillis?: number;
  /**
   * Block window end. Required on create; omit on update to keep the stored value.
   */
  endsAtMillis?: number;
  notes?: string | null;
}
