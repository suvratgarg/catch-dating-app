import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useCallback, useEffect, useMemo, useState} from "react";
import {eventRehearsalCopy} from "../../content/eventRehearsal";
import {
  getEventRehearsalGuestBootstrap,
  submitEventRehearsalGuestAction,
  type EventRehearsalGuestAction,
  type EventRehearsalGuestBootstrap,
} from "../../firebase";
import {websiteQueryKeys} from "../../shared/query/queryKeys";
import {eventRehearsalGuestActionClientId} from "./eventRehearsalModel";

const clientStoragePrefix = "catch:event-rehearsal:client:";
const slotStoragePrefix = "catch:event-rehearsal:slot:";

export function useEventRehearsalController(publicRehearsalId: string) {
  const queryClient = useQueryClient();
  const clientInstanceId = useMemo(
    () => storedClientInstanceId(publicRehearsalId),
    [publicRehearsalId]
  );
  const [slotToken, setSlotToken] = useState<string | null>(() =>
    readSessionValue(`${slotStoragePrefix}${publicRehearsalId}`)
  );
  const queryKey = websiteQueryKeys.eventRehearsal.guest(publicRehearsalId);
  const guestQuery = useQuery({
    enabled: publicRehearsalId.length > 0,
    queryKey,
    queryFn: () => getEventRehearsalGuestBootstrap({
      publicRehearsalId,
      clientInstanceId,
      viewerToken: null,
      slotToken,
    }),
    refetchInterval: (query) =>
      query.state.data?.session.faultId === "lowBandwidth" ? 5_000 : 1_200,
    retry: 3,
  });

  useEffect(() => {
    const nextSlotToken = guestQuery.data?.slotToken;
    if (!nextSlotToken || nextSlotToken === slotToken) return;
    writeSessionValue(`${slotStoragePrefix}${publicRehearsalId}`, nextSlotToken);
    setSlotToken(nextSlotToken);
  }, [guestQuery.data?.slotToken, publicRehearsalId, slotToken]);

  const actionMutation = useMutation({
    mutationKey: websiteQueryKeys.eventRehearsal.action(publicRehearsalId),
    mutationFn: async (action: EventRehearsalGuestAction) => {
      const activeSlot = guestQuery.data?.slotToken ?? slotToken;
      if (!activeSlot) throw new Error("missing rehearsal guest slot");
      return submitEventRehearsalGuestAction({
        publicRehearsalId,
        slotToken: activeSlot,
        clientActionId: eventRehearsalGuestActionClientId(
          clientInstanceId,
          Date.now() * 1_000
        ),
        action,
      });
    },
    onSuccess: (bootstrap) => {
      queryClient.setQueryData<EventRehearsalGuestBootstrap>(queryKey, bootstrap);
    },
  });

  const submit = useCallback((action: EventRehearsalGuestAction) => {
    if (!actionMutation.isPending) actionMutation.mutate(action);
  }, [actionMutation]);

  const message = actionMutation.isError
    ? eventRehearsalCopy.unavailableBody
    : actionMutation.isSuccess
      ? eventRehearsalCopy.actionSuccess
      : guestQuery.isError && guestQuery.data
        ? eventRehearsalCopy.refreshNotice
        : "";

  return {
    bootstrap: guestQuery.data ?? null,
    isLoading: guestQuery.isPending,
    isUnavailable: guestQuery.isError && !guestQuery.data,
    pending: actionMutation.isPending,
    refresh: guestQuery.refetch,
    status: {
      message,
      tone: actionMutation.isError ? "is-error" as const : "" as const,
    },
    submit,
  };
}

function storedClientInstanceId(publicRehearsalId: string): string {
  const key = `${clientStoragePrefix}${publicRehearsalId}`;
  const existing = readSessionValue(key);
  if (existing) return existing;
  const created = typeof crypto !== "undefined" && crypto.randomUUID
    ? crypto.randomUUID()
    : `web_${Date.now().toString(36)}_${Math.random().toString(36).slice(2)}`;
  writeSessionValue(key, created);
  return created;
}

function readSessionValue(key: string): string | null {
  try {
    return window.sessionStorage.getItem(key);
  } catch {
    return null;
  }
}

function writeSessionValue(key: string, value: string): void {
  try {
    window.sessionStorage.setItem(key, value);
  } catch {
    // A private browser can still use the in-memory slot for this page load.
  }
}
