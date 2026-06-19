DECLARE analytics_project STRING DEFAULT @@project_id;
DECLARE analytics_dataset STRING DEFAULT "catch_user_analytics";
DECLARE dataset_location STRING DEFAULT "asia-south1";

EXECUTE IMMEDIATE FORMAT(
  "CREATE SCHEMA IF NOT EXISTS `%s.%s` OPTIONS(location = '%s')",
  analytics_project,
  analytics_dataset,
  dataset_location
);

EXECUTE IMMEDIATE FORMAT("""
CREATE TABLE IF NOT EXISTS `%s.%s.mart_user_analytics_daily` (
  date DATE NOT NULL,
  uid STRING NOT NULL,
  events_booked_count INT64,
  events_attended_count INT64,
  outgoing_like_count INT64,
  incoming_like_count INT64,
  private_interest_sent_count INT64,
  private_interest_received_count INT64,
  match_count INT64,
  chat_started_sent_count INT64,
  chat_started_received_count INT64,
  chat_message_sent_count INT64,
  chat_message_received_count INT64,
  feedback_submitted_count INT64,
  profile_view_count INT64,
  unique_profile_viewer_count INT64,
  profile_dwell_ms INT64,
  photo_impression_count INT64,
  photo_dwell_ms INT64,
  top_photo_id STRING,
  top_photo_score FLOAT64,
  app_active_minutes INT64,
  app_event_count INT64,
  profile_pull_score FLOAT64,
  connection_followthrough_score FLOAT64,
  event_anchor_score FLOAT64,
  internal_desirability_percentile FLOAT64,
  data_completeness_score FLOAT64,
  refreshed_at TIMESTAMP NOT NULL
)
PARTITION BY date
CLUSTER BY uid
OPTIONS(
  description = 'Daily user analytics mart. Internal scoring columns are for admin/composition systems and are not returned by user-facing callables.'
)
""", analytics_project, analytics_dataset);

EXECUTE IMMEDIATE FORMAT("""
ALTER TABLE `%s.%s.mart_user_analytics_daily`
ADD COLUMN IF NOT EXISTS profile_pull_score FLOAT64
""", analytics_project, analytics_dataset);

EXECUTE IMMEDIATE FORMAT("""
ALTER TABLE `%s.%s.mart_user_analytics_daily`
ADD COLUMN IF NOT EXISTS internal_desirability_percentile FLOAT64
""", analytics_project, analytics_dataset);
