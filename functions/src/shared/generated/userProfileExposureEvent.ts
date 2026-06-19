/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Raw BigQuery event for profile impression, dwell, and photo performance analytics. This table is the denominator for user-safe profile analytics and internal composition models.
 */
export interface UserProfileExposureEvent {
  analytics_event_id: string;
  occurred_at: string;
  event_date: string;
  viewer_uid?: string | null;
  subject_uid: string;
  event_id?: string | null;
  club_id?: string | null;
  event_name:
    | "profileImpression"
    | "profileView"
    | "profileDwell"
    | "photoImpression"
    | "photoDwell";
  surface?: string | null;
  photo_id?: string | null;
  photo_slot?: number | null;
  dwell_ms?: number | null;
  session_hash?: string | null;
  platform?: string | null;
  ingested_at: string;
}
