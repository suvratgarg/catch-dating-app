DECLARE analytics_project STRING DEFAULT @@project_id;
DECLARE analytics_dataset STRING DEFAULT "catch_analytics";
DECLARE dataset_location STRING DEFAULT "asia-south1";

EXECUTE IMMEDIATE FORMAT(
  "CREATE SCHEMA IF NOT EXISTS `%s.%s` OPTIONS(location = '%s')",
  analytics_project,
  analytics_dataset,
  dataset_location
);

EXECUTE IMMEDIATE FORMAT("""
CREATE TABLE IF NOT EXISTS `%s.%s.host_analytics_events` (
  analytics_event_id STRING NOT NULL,
  occurred_at TIMESTAMP NOT NULL,
  event_date DATE NOT NULL,
  event_name STRING NOT NULL,
  club_id STRING NOT NULL,
  target_event_id STRING,
  page_path STRING NOT NULL,
  source STRING,
  session_hash STRING,
  platform STRING,
  ingested_at TIMESTAMP NOT NULL
)
PARTITION BY event_date
CLUSTER BY club_id, target_event_id, event_name
OPTIONS(
  description = 'Aggregate-safe host discovery event stream. Firestore is not the source of truth for these counters.'
)
""", analytics_project, analytics_dataset);
