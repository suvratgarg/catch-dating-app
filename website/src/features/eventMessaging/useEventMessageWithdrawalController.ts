import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useEffect, useRef, useState} from "react";
import {getEventAssistanceSmsWithdrawal, withdrawEventAssistanceSms, getEventWhatsappWithdrawal, withdrawEventWhatsapp} from "../../firebase";
import type {GetEventAssistanceSmsWithdrawalCallablePayload as Credential} from "../../shared/contracts/generated/getEventAssistanceSmsWithdrawalCallablePayload";
import type {WithdrawEventAssistanceSmsCallablePayload as Submission} from "../../shared/contracts/generated/withdrawEventAssistanceSmsCallablePayload";
import type {EventAssistanceSmsWithdrawalCallableResponse as SmsResponse} from "../../shared/contracts/generated/eventAssistanceSmsWithdrawalCallableResponse";
import {eventMessagingCopy, eventWhatsappMessagingCopy} from "../../content/eventMessaging";
import {websiteQueryKeys} from "../../shared/query/queryKeys";

import type {EventWhatsappWithdrawalCallableResponse as WhatsappResponse} from "../../shared/contracts/generated/eventWhatsappWithdrawalCallableResponse";

export type MessageWithdrawalChannel = "sms" | "whatsapp";
type Response = SmsResponse | WhatsappResponse;

export type MessageWithdrawalState = {kind: "hidden" | "loading" | "error"} |
  {kind: "ready"; view: Response["view"]; pending: boolean; uncertain: boolean; notice: string};

function newer(previous: Response | undefined, next: Response): Response {
  if (!previous) return next;
  if (previous.view.revision !== next.view.revision) {
    return next.view.revision > previous.view.revision ? next : previous;
  }
  return next.view.serverTime >= previous.view.serverTime ? next : previous;
}

/** The parent remounts this controller when the bearer credential changes. */
export function useEventMessageWithdrawalController(credential: Credential | null, channel: MessageWithdrawalChannel = "sms") {
  const copy = channel === "sms" ? eventMessagingCopy : eventWhatsappMessagingCopy;
  const readPreference = channel === "sms" ? getEventAssistanceSmsWithdrawal : getEventWhatsappWithdrawal;
  const withdrawPreference = channel === "sms" ? withdrawEventAssistanceSms : withdrawEventWhatsapp;
  const client = useQueryClient();
  const [instance] = useState(() => crypto.randomUUID());
  const queryKey = websiteQueryKeys.eventMessaging.messageWithdrawal(instance, channel);
  const pending = useRef<Submission | null>(null);
  const locked = useRef(false);
  const mounted = useRef(true);
  const [sending, setSending] = useState(false);
  const [unavailable, setUnavailable] = useState(false);
  const [notice, setNotice] = useState("");
  useEffect(() => {
    mounted.current = true;
    return () => { mounted.current = false; };
  }, []);
  const query = useQuery({
    queryKey, enabled: credential !== null && !sending && !unavailable,
    queryFn: async ({signal}) => {
      if (!credential) throw new Error("Missing event withdrawal credential");
      const response = await readPreference(credential);
      signal.throwIfAborted();
      return newer(client.getQueryData<Response>(queryKey), response);
    },
    retry: false, gcTime: 0, staleTime: 0,
    refetchInterval: 30_000, refetchIntervalInBackground: false,
    refetchOnWindowFocus: "always", refetchOnReconnect: "always",
  });
  const mutation = useMutation({
    retry: false, gcTime: 0,
    // The secret lives only in the pending ref and the callable request.
    mutationFn: async () => {
      const input = pending.current;
      if (!input) throw new Error("Missing event withdrawal request");
      await client.cancelQueries({queryKey});
      if (!mounted.current) throw new Error("Withdrawal page was closed");
      return withdrawPreference(input);
    },
    onSuccess: (response) => {
      if (!mounted.current) return;
      client.setQueryData<Response>(queryKey, (previous) => newer(previous, response));
      pending.current = null;
      setNotice(response.view.preference === "enabled" ? copy.withdrawalChanged : "");
    },
    onError: (error) => {
      if (!mounted.current) return;
      const code = errorCode(error);
      if (code === "functions/not-found") {
        pending.current = null;
        setUnavailable(true);
        client.removeQueries({queryKey});
      } else if (["functions/invalid-argument", "functions/failed-precondition"].includes(code)) {
        pending.current = null;
        setNotice(copy.rejected);
        void client.invalidateQueries({queryKey});
      } else setNotice(copy.uncertain);
    },
    onSettled: () => {
      if (!mounted.current) return;
      locked.current = false;
      setSending(false);
    },
  });
  function withdraw() {
    if (!mounted.current || locked.current || !credential || unavailable) return;
    const cached = client.getQueryData<Response>(queryKey)?.view;
    const displayed = query.data?.view;
    if (!pending.current && (!cached || !displayed || query.isError ||
        cached.revision !== displayed.revision || cached.preference !== "enabled")) return;
    pending.current ??= {...credential, expectedRevision: cached!.revision,
      requestId: crypto.randomUUID()};
    locked.current = true;
    setSending(true);
    setNotice("");
    mutation.mutate();
  }
  const uncertain = pending.current !== null && !sending;
  let state: MessageWithdrawalState;
  if (!credential || unavailable || errorCode(query.error) === "functions/not-found") state = {kind: "hidden"};
  else if (!query.data && query.isPending) state = {kind: "loading"};
  else if (!query.data || query.isError && !uncertain) state = {kind: "error"};
  else state = {kind: "ready", view: query.data.view, pending: sending, uncertain, notice};
  return {state, withdraw, refresh: () => { if (!locked.current) void query.refetch(); }};
}

function errorCode(error: unknown): string {
  return typeof error === "object" && error !== null && "code" in error &&
    typeof error.code === "string" ? error.code : "";
}
