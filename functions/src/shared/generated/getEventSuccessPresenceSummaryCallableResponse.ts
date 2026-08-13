/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface GetEventSuccessPresenceSummaryCallableResponse {
  serverTimeMillis: number;
  liveControlRevision: number;
  nextRoundIndex: number;
  policy: {
    heartbeatIntervalSeconds: number;
    presentWindowSeconds: number;
    likelyDepartedAfterSeconds: number;
  };
  /**
   * @maxItems 200
   */
  entries: {
    uid: string;
    displayName: string;
    presenceState: "present" | "idle" | "likelyDeparted";
    heartbeatAtMillis: number;
  }[];
  /**
   * @maxItems 200
   */
  lateArrivals: {
    uid: string;
    displayName: string;
    checkedInAtMillis: number;
  }[];
}
