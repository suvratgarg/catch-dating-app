import {
  BigQueryClient,
  dateParam,
  defaultBigQueryClient,
  intParam,
  stringParam,
} from "../shared/bigQuery";

export interface UserAnalyticsBigQueryRange {
  startDate: string;
  endDate: string;
}

export interface UserAnalyticsBigQueryScope {
  uid: string;
}

export interface UserAnalyticsMartRow {
  date: string;
  uid: string;
  eventsBookedCount: number;
  eventsAttendedCount: number;
  outgoingLikeCount: number;
  incomingLikeCount: number;
  privateInterestSentCount: number;
  privateInterestReceivedCount: number;
  matchCount: number;
  chatStartedSentCount: number;
  chatStartedReceivedCount: number;
  chatMessageSentCount: number;
  chatMessageReceivedCount: number;
  feedbackSubmittedCount: number;
  profileViewCount: number;
  uniqueProfileViewerCount: number;
  profileDwellMs: number;
  photoImpressionCount: number;
  photoDwellMs: number;
  topPhotoId: string | null;
  topPhotoScore: number;
  appActiveMinutes: number;
  appEventCount: number;
  dataCompletenessScore: number;
}

export interface UserAnalyticsBigQuerySource {
  loadRows(
    range: UserAnalyticsBigQueryRange,
    scope: UserAnalyticsBigQueryScope,
  ): Promise<UserAnalyticsMartRow[]>;
}

interface RawUserAnalyticsMartRow {
  date: string;
  uid: string;
  eventsBookedCount: string | number | null;
  eventsAttendedCount: string | number | null;
  outgoingLikeCount: string | number | null;
  incomingLikeCount: string | number | null;
  privateInterestSentCount: string | number | null;
  privateInterestReceivedCount: string | number | null;
  matchCount: string | number | null;
  chatStartedSentCount: string | number | null;
  chatStartedReceivedCount: string | number | null;
  chatMessageSentCount: string | number | null;
  chatMessageReceivedCount: string | number | null;
  feedbackSubmittedCount: string | number | null;
  profileViewCount: string | number | null;
  uniqueProfileViewerCount: string | number | null;
  profileDwellMs: string | number | null;
  photoImpressionCount: string | number | null;
  photoDwellMs: string | number | null;
  topPhotoId: string | null;
  topPhotoScore: string | number | null;
  appActiveMinutes: string | number | null;
  appEventCount: string | number | null;
  dataCompletenessScore: string | number | null;
}

export class BigQueryUserAnalyticsSource
implements UserAnalyticsBigQuerySource {
  constructor(
    private readonly client: BigQueryClient = defaultBigQueryClient,
    private readonly table = userAnalyticsMartTable(),
  ) {}

  async loadRows(
    range: UserAnalyticsBigQueryRange,
    scope: UserAnalyticsBigQueryScope,
  ): Promise<UserAnalyticsMartRow[]> {
    const rows = await this.client.query<RawUserAnalyticsMartRow>(
      userAnalyticsRowsSql(this.table),
      [
        dateParam("startDate", range.startDate),
        dateParam("endDate", range.endDate),
        stringParam("uid", scope.uid),
        intParam("limit", 5000),
      ],
    );
    return rows.map(normalizeMartRow);
  }
}

export const defaultUserAnalyticsBigQuerySource =
  new BigQueryUserAnalyticsSource();

export function userAnalyticsRowsSql(table: string): string {
  return `
SELECT
  CAST(date AS STRING) AS date,
  uid,
  SUM(events_booked_count) AS eventsBookedCount,
  SUM(events_attended_count) AS eventsAttendedCount,
  SUM(outgoing_like_count) AS outgoingLikeCount,
  SUM(incoming_like_count) AS incomingLikeCount,
  SUM(private_interest_sent_count) AS privateInterestSentCount,
  SUM(private_interest_received_count) AS privateInterestReceivedCount,
  SUM(match_count) AS matchCount,
  SUM(chat_started_sent_count) AS chatStartedSentCount,
  SUM(chat_started_received_count) AS chatStartedReceivedCount,
  SUM(chat_message_sent_count) AS chatMessageSentCount,
  SUM(chat_message_received_count) AS chatMessageReceivedCount,
  SUM(feedback_submitted_count) AS feedbackSubmittedCount,
  SUM(profile_view_count) AS profileViewCount,
  SUM(unique_profile_viewer_count) AS uniqueProfileViewerCount,
  SUM(profile_dwell_ms) AS profileDwellMs,
  SUM(photo_impression_count) AS photoImpressionCount,
  SUM(photo_dwell_ms) AS photoDwellMs,
  ARRAY_AGG(top_photo_id IGNORE NULLS ORDER BY top_photo_score DESC LIMIT 1)
    [SAFE_OFFSET(0)] AS topPhotoId,
  MAX(top_photo_score) AS topPhotoScore,
  SUM(app_active_minutes) AS appActiveMinutes,
  SUM(app_event_count) AS appEventCount,
  MAX(data_completeness_score) AS dataCompletenessScore
FROM \`${table}\`
WHERE date >= @startDate
  AND date <= @endDate
  AND uid = @uid
GROUP BY date, uid
ORDER BY date ASC
LIMIT @limit`;
}

function normalizeMartRow(
  row: RawUserAnalyticsMartRow,
): UserAnalyticsMartRow {
  return {
    date: row.date,
    uid: row.uid,
    eventsBookedCount: numberValue(row.eventsBookedCount),
    eventsAttendedCount: numberValue(row.eventsAttendedCount),
    outgoingLikeCount: numberValue(row.outgoingLikeCount),
    incomingLikeCount: numberValue(row.incomingLikeCount),
    privateInterestSentCount: numberValue(row.privateInterestSentCount),
    privateInterestReceivedCount: numberValue(
      row.privateInterestReceivedCount
    ),
    matchCount: numberValue(row.matchCount),
    chatStartedSentCount: numberValue(row.chatStartedSentCount),
    chatStartedReceivedCount: numberValue(row.chatStartedReceivedCount),
    chatMessageSentCount: numberValue(row.chatMessageSentCount),
    chatMessageReceivedCount: numberValue(row.chatMessageReceivedCount),
    feedbackSubmittedCount: numberValue(row.feedbackSubmittedCount),
    profileViewCount: numberValue(row.profileViewCount),
    uniqueProfileViewerCount: numberValue(row.uniqueProfileViewerCount),
    profileDwellMs: numberValue(row.profileDwellMs),
    photoImpressionCount: numberValue(row.photoImpressionCount),
    photoDwellMs: numberValue(row.photoDwellMs),
    topPhotoId: row.topPhotoId,
    topPhotoScore: numberValue(row.topPhotoScore),
    appActiveMinutes: numberValue(row.appActiveMinutes),
    appEventCount: numberValue(row.appEventCount),
    dataCompletenessScore: numberValue(row.dataCompletenessScore),
  };
}

function numberValue(value: string | number | null): number {
  if (typeof value === "number") return Number.isFinite(value) ? value : 0;
  if (typeof value === "string") {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : 0;
  }
  return 0;
}

function userAnalyticsMartTable(): string {
  const explicit = process.env.USER_ANALYTICS_MART_TABLE;
  if (explicit) return explicit;
  const project = process.env.USER_ANALYTICS_BIGQUERY_PROJECT_ID ||
    process.env.BIGQUERY_PROJECT_ID ||
    process.env.GCLOUD_PROJECT ||
    process.env.GCP_PROJECT ||
    "catch-dating-app-64e51";
  const dataset = process.env.USER_ANALYTICS_BIGQUERY_DATASET ||
    "catch_user_analytics";
  return `${project}.${dataset}.mart_user_analytics_daily`;
}
