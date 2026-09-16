import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useEffect, useRef, useState} from "react";
import {eventRehearsalCopy as copy} from "../../content/eventRehearsal";
import {
  getEventRehearsalGuestBootstrap, submitEventRehearsalGuestAction,
  type EventRehearsalGuestAction, type EventRehearsalGuestBootstrap,
} from "../../firebase";
import type {SubmitEventRehearsalGuestActionCallablePayload as WireAction} from
  "../../shared/contracts/generated/submitEventRehearsalGuestActionCallablePayload";
import {websiteQueryKeys} from "../../shared/query/queryKeys";
import {availableEventRehearsalGuestActions, canReplyToRehearsal,
  reconcileRehearsalProjection,
  type RehearsalReply, type RehearsalReplyState} from "./eventRehearsalModel";

const clientStoragePrefix = "catch:event-rehearsal:client:";
const slotStoragePrefix = "catch:event-rehearsal:slot:";
type Submission = Pick<WireAction,
  "publicRehearsalId" | "slotToken" | "clientActionId"> & (
    {action: EventRehearsalGuestAction} |
    ({action: "respondToAssistance"} & RehearsalReply));

// The route remounts this controller for each public link. Private query data
// belongs to this mounted phone; cancelled reads cannot undo a confirmed reply.
export function useEventRehearsalController(publicRehearsalId: string) {
  const client = useQueryClient();
  const [instanceId] = useState(() => crypto.randomUUID());
  const [clientInstanceId] = useState(() => storedClientInstanceId(publicRehearsalId));
  const [initialSlot] = useState(() => readSessionValue(`${slotStoragePrefix}${publicRehearsalId}`));
  const slotToken = useRef(initialSlot);
  const queryKey = [...websiteQueryKeys.eventRehearsal.guest(publicRehearsalId), instanceId];
  const pending = useRef<Submission | null>(null);
  const locked = useRef(false);
  const mounted = useRef(true);
  const [sending, setSending] = useState(false);
  const [notice, setNotice] = useState("");
  const freshUntil = useRef(0);
  const [, tick] = useState(0);
  useEffect(() => {
    mounted.current = true;
    return () => { mounted.current = false; };
  }, []);
  const query = useQuery({
    enabled: publicRehearsalId.length > 0 && !sending,
    queryKey, retry: false, gcTime: 0, staleTime: 1_000,
    queryFn: async ({signal}) => {
      const started = performance.now();
      const value = await getEventRehearsalGuestBootstrap({
        publicRehearsalId, clientInstanceId, viewerToken: null,
        slotToken: slotToken.current,
      });
      signal.throwIfAborted();
      freshUntil.current = started + 15_000;
      return reconcileRehearsalProjection(
        client.getQueryData<EventRehearsalGuestBootstrap>(queryKey), value);
    },
    refetchInterval: (state) =>
      state.state.data?.session.faultId === "lowBandwidth" ? 5_000 : 1_200,
    refetchIntervalInBackground: false,
    refetchOnWindowFocus: "always", refetchOnReconnect: "always",
  });
  useEffect(() => {
    if (!query.data || performance.now() >= freshUntil.current) return;
    const timer = setTimeout(() => tick((value) => value + 1),
      Math.max(0, freshUntil.current - performance.now()));
    return () => clearTimeout(timer);
  }, [query.data, query.dataUpdatedAt]);
  useEffect(() => {
    const next = query.data?.slotToken;
    if (!next || next === slotToken.current) return;
    slotToken.current = next;
    writeSessionValue(`${slotStoragePrefix}${publicRehearsalId}`, next);
  }, [query.data?.slotToken, publicRehearsalId]);

  const mutation = useMutation({
    mutationKey: [...websiteQueryKeys.eventRehearsal.action(publicRehearsalId), instanceId],
    retry: false, gcTime: 0,
    // Retain the bearer only in the pending ref, never in mutation variables.
    mutationFn: async (_action: string) => {
      const input = pending.current;
      if (!input) throw new Error("Missing practice action");
      await client.cancelQueries({queryKey});
      const started = performance.now();
      return {value: await submitEventRehearsalGuestAction(input), started};
    },
    onSuccess: ({value, started}) => {
      if (!mounted.current) return;
      freshUntil.current = started + 15_000;
      client.setQueryData<EventRehearsalGuestBootstrap>(queryKey, value);
      setNotice(pending.current?.action === "respondToAssistance" ? "" : copy.actionSuccess);
      pending.current = null;
    },
    onError: () => {
      if (mounted.current) setNotice(pending.current?.action === "respondToAssistance"
        ? copy.replyUncertain : copy.unavailableBody);
    },
    onSettled: () => {
      locked.current = false;
      if (mounted.current) setSending(false);
    },
  });

  const displayed = query.data;
  const instruction = displayed?.actor.assistanceMessage;
  const unresolved = pending.current?.action === "respondToAssistance" &&
    pending.current.slotToken === displayed?.slotToken &&
    pending.current.messageId === instruction?.messageId &&
    pending.current.intentRevision === instruction?.intentRevision &&
    !instruction?.responseChoiceId && displayed &&
    canReplyToRehearsal(displayed) ? pending.current : null;
  const isFresh = () => !query.isError && performance.now() < freshUntil.current;

  function send(input: Submission) {
    pending.current = input;
    locked.current = true;
    setSending(true);
    setNotice("");
    mutation.mutate(input.action);
  }
  function submit(action: EventRehearsalGuestAction) {
    const current = client.getQueryData<EventRehearsalGuestBootstrap>(queryKey);
    if (locked.current || unresolved || !isFresh() || !current ||
        current !== displayed || !availableEventRehearsalGuestActions(current).includes(action)) return;
    const previous = pending.current;
    send(previous?.action === action && previous.slotToken === current.slotToken
      ? previous : {publicRehearsalId, slotToken: current.slotToken,
        clientActionId: `guest_${crypto.randomUUID()}`, action});
  }
  function reply(input: RehearsalReply) {
    const current = client.getQueryData<EventRehearsalGuestBootstrap>(queryKey);
    const message = current?.actor.assistanceMessage;
    if (locked.current || !isFresh() || !current || current !== displayed ||
        !message || message.messageId !== input.messageId ||
        message.intentRevision !== input.intentRevision ||
        !message.choices.some((choice) => choice.choiceId === input.choiceId)) return;
    if (unresolved && unresolved.choiceId !== input.choiceId) return;
    if (!unresolved && !canReplyToRehearsal(current)) return;
    send(unresolved ?? {...input, publicRehearsalId, slotToken: current.slotToken,
      clientActionId: `guest_${crypto.randomUUID()}`, action: "respondToAssistance"});
  }
  const replyState: RehearsalReplyState = {
    fresh: isFresh(),
    pendingChoice: sending && pending.current?.action === "respondToAssistance"
      ? pending.current.choiceId : null,
    retryChoice: unresolved?.choiceId ?? null,
    notice: unresolved && !sending ? notice : "",
  };
  return {
    bootstrap: displayed ?? null,
    isLoading: query.isPending,
    isUnavailable: query.isError && !displayed,
    pending: sending,
    refresh: () => { if (!locked.current) void query.refetch(); },
    status: {message: pending.current?.action === "respondToAssistance" ? "" :
      query.isError ? copy.refreshNotice : notice,
      tone: mutation.isError ? "is-error" as const : "" as const},
    submit, reply, replyState,
  };
}

function storedClientInstanceId(publicRehearsalId: string): string {
  const key = `${clientStoragePrefix}${publicRehearsalId}`;
  const existing = readSessionValue(key);
  if (existing) return existing;
  const created = crypto.randomUUID();
  writeSessionValue(key, created);
  return created;
}
function readSessionValue(key: string): string | null {
  try { return window.sessionStorage.getItem(key); } catch { return null; }
}
function writeSessionValue(key: string, value: string): void {
  try { window.sessionStorage.setItem(key, value); } catch {
    // A private browser can still use the in-memory slot for this page load.
  }
}
