import {useCallback, useEffect, useMemo, useState} from "react";
import type {
  UserAnalyticsGranularity,
  UserAnalyticsQueryPayload,
  UserAnalyticsRangePreset,
  UserAnalyticsResponse,
} from "../../../shared/types/adminTypes";
import {
  isUserAnalyticsSampleMode,
  loadUserAnalyticsReport,
} from "../api/userAnalyticsRepository";

export type UserLookupMode =
  | "empty"
  | "users_path"
  | "uid_prefix"
  | "raw_uid"
  | "invalid";

export interface UserLookupContract {
  mode: UserLookupMode;
  canLoad: boolean;
  normalizedUserId: string | null;
  targetPath: string | null;
  statusLabel: string;
  statusDetail: string;
  allowedSources: string[];
  unavailableDomains: string[];
  blockedActions: string[];
}

export function useUserAnalyticsController({
  handoffRequestId,
  handoffUserId,
  onError,
  onNotice,
}: {
  handoffRequestId?: number | null;
  handoffUserId?: string | null;
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const initialUserId = handoffUserId ??
    (isUserAnalyticsSampleMode() ? "user-1" : "");
  const [userId, setUserId] = useState(
    initialUserId
  );
  const [rangePreset, setRangePreset] =
    useState<UserAnalyticsRangePreset>("30d");
  const [granularity, setGranularity] =
    useState<UserAnalyticsGranularity>("day");
  const [startDate, setStartDate] = useState(defaultDate(29));
  const [endDate, setEndDate] = useState(defaultDate(0));
  const [report, setReport] = useState<UserAnalyticsResponse | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [lastHandoffRequestId, setLastHandoffRequestId] =
    useState<number | null>(null);

  const payload = useMemo(
    () => buildUserAnalyticsPayload({
      endDate,
      granularity,
      rangePreset,
      startDate,
      userId,
    }),
    [endDate, granularity, rangePreset, startDate, userId]
  );
  const lookupContract = useMemo(
    () => buildUserLookupContract(userId),
    [userId]
  );

  const load = useCallback(async (nextUserId?: string) => {
    const contract = buildUserLookupContract(nextUserId ?? userId);
    const nextPayload = nextUserId ?
      buildUserAnalyticsPayload({
        endDate,
        granularity,
        rangePreset,
        startDate,
        userId: nextUserId,
      }) :
      payload;
    if (!nextPayload.userId) {
      onError(contract.statusDetail);
      return false;
    }
    if (rangePreset === "custom" && (!startDate || !endDate)) {
      onError("Choose both start and end dates for a custom analytics range.");
      return false;
    }
    setIsLoading(true);
    try {
      const nextReport = await loadUserAnalyticsReport(nextPayload);
      setReport(nextReport);
      onError(null);
      onNotice(`Loaded analytics for ${nextReport.scope.userId}.`);
      return true;
    } catch (error) {
      onError(messageFromError(error, "Unable to load user analytics."));
      return false;
    } finally {
      setIsLoading(false);
    }
  }, [
    endDate,
    granularity,
    onError,
    onNotice,
    payload,
    rangePreset,
    startDate,
  ]);

  useEffect(() => {
    if (!handoffUserId || !handoffRequestId) return;
    if (handoffRequestId === lastHandoffRequestId) return;
    setLastHandoffRequestId(handoffRequestId);
    setUserId(handoffUserId);
    setReport(null);
    void load(handoffUserId);
  }, [
    handoffRequestId,
    handoffUserId,
    lastHandoffRequestId,
    load,
  ]);

  useEffect(() => {
    if (!isUserAnalyticsSampleMode() || !userId) return;
    void load();
  }, [load, userId]);

  return {
    endDate,
    granularity,
    isLoading,
    lookupContract,
    payload,
    rangePreset,
    report,
    startDate,
    userId,
    load,
    setEndDate,
    setGranularity,
    setRangePreset,
    setStartDate,
    setUserId,
  };
}

export function buildUserLookupContract(input: string): UserLookupContract {
  const trimmed = input.trim();
  const normalizedUserId = normalizeUserAnalyticsUserId(trimmed);
  const base = {
    allowedSources: [
      "adminGetUserAnalytics aggregate response",
      "BigQuery user analytics mart",
      "adminAuditLogs read receipt",
    ],
    unavailableDomains: [
      "Email, phone, or name identity search",
      "Account status and profile edit history",
      "Safety, moderation, and report history",
      "Payment, refund, and attendance history",
      "Referral, invite, support-note, and audit timelines",
    ],
    blockedActions: [
      "Suspend, delete, or restore account",
      "Edit profile or onboarding state",
      "Apply safety restriction",
      "Issue refund or payment adjustment",
      "Send support message",
    ],
  };

  if (!trimmed) {
    return {
      ...base,
      mode: "empty",
      canLoad: false,
      normalizedUserId: null,
      targetPath: null,
      statusLabel: "Exact UID required",
      statusDetail:
        "Enter an exact users/{uid}, uid:{uid}, or raw uid value before loading user analytics.",
    };
  }

  if (!normalizedUserId) {
    return {
      ...base,
      mode: "invalid",
      canLoad: false,
      normalizedUserId: null,
      targetPath: null,
      statusLabel: "Unsupported lookup input",
      statusDetail:
        "This field only accepts a Firestore user path, uid: value, or raw uid. It does not search email, phone, display name, or free text.",
    };
  }

  return {
    ...base,
    mode: userLookupMode(trimmed),
    canLoad: true,
    normalizedUserId,
    targetPath: `users/${normalizedUserId}`,
    statusLabel: "Exact aggregate lookup",
    statusDetail:
      "The admin console will load aggregate analytics for this normalized uid only; identity search and account actions are separate contracts.",
  };
}

export function buildUserAnalyticsPayload({
  endDate,
  granularity,
  rangePreset,
  startDate,
  userId,
}: {
  endDate: string;
  granularity: UserAnalyticsGranularity;
  rangePreset: UserAnalyticsRangePreset;
  startDate: string;
  userId: string;
}): UserAnalyticsQueryPayload {
  const isCustom = rangePreset === "custom";
  return {
    userId: normalizeUserAnalyticsUserId(userId),
    rangePreset,
    granularity,
    startDate: isCustom ? startDate : null,
    endDate: isCustom ? endDate : null,
  };
}

export function normalizeUserAnalyticsUserId(input: string): string | null {
  const normalized = input.trim().replace(/^\/+/u, "");
  if (!normalized) return null;

  const usersPathMatch = normalized.match(/^users\/([^/\s]+)$/iu);
  if (usersPathMatch) return validatedUserAnalyticsUserId(usersPathMatch[1]);

  const uidMatch = normalized.match(/^uid[:\s]+([^/\s]+)$/iu);
  if (uidMatch) return validatedUserAnalyticsUserId(uidMatch[1]);

  return validatedUserAnalyticsUserId(normalized);
}

function validatedUserAnalyticsUserId(input: string): string | null {
  const trimmed = input.trim();
  if (!/^[A-Za-z0-9_-]{3,128}$/u.test(trimmed)) return null;
  return trimmed;
}

function defaultDate(daysAgo: number): string {
  const date = new Date();
  date.setUTCDate(date.getUTCDate() - daysAgo);
  return date.toISOString().slice(0, 10);
}

function userLookupMode(input: string): UserLookupMode {
  const normalized = input.trim().replace(/^\/+/u, "");
  if (/^users\/([^/\s]+)$/iu.test(normalized)) return "users_path";
  if (/^uid[:\s]+([^/\s]+)$/iu.test(normalized)) return "uid_prefix";
  return "raw_uid";
}

function messageFromError(error: unknown, fallback: string): string {
  if (error && typeof error === "object" && "message" in error) {
    const message = (error as {message?: unknown}).message;
    if (typeof message === "string" && message.trim()) return message;
  }
  return fallback;
}
