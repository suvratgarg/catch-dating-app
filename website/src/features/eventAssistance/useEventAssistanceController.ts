import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useEffect, useRef, useState} from "react";
import {getEventAssistanceGuestView, submitEventAssistanceGuestChoice} from "../../firebase";
import {eventAssistanceCopy as copy} from "../../content/eventAssistance";
import type {SubmitEventAssistanceGuestChoiceCallablePayload as Submission} from "../../shared/contracts/generated/submitEventAssistanceGuestChoiceCallablePayload";
import {websiteQueryKeys} from "../../shared/query/queryKeys";
import {guestSnapshot, newerGuestSnapshot, type AssistanceScreen, type Credential, type GuestSnapshot} from "./eventAssistanceModel";

export function useEventAssistanceController(credential: Credential | null) {
  const client = useQueryClient();
  // A page instance owns its cache. Credentials never enter query/mutation keys.
  const [instanceId] = useState(() => crypto.randomUUID());
  const queryKey = websiteQueryKeys.eventAssistance.guest(instanceId);
  const pending = useRef<Submission | null>(null);
  const locked = useRef(false);
  const mounted = useRef(true);
  useEffect(() => {
    mounted.current = true;
    return () => { mounted.current = false; };
  }, []);
  const [sending, setSending] = useState(false);
  const [notice, setNotice] = useState("");
  const [, tick] = useState(0);
  const query = useQuery({
    queryKey, enabled: credential !== null && !sending,
    queryFn: async ({signal}) => {
      if (!credential) throw new Error("Missing event update credential");
      const started = performance.now();
      const view = await getEventAssistanceGuestView(credential);
      signal.throwIfAborted();
      return newerGuestSnapshot(client.getQueryData<GuestSnapshot>(queryKey),
        guestSnapshot(view, started));
    },
    retry: false, gcTime: 0, staleTime: 0,
    refetchInterval: 15_000, refetchIntervalInBackground: false,
    refetchOnWindowFocus: "always", refetchOnReconnect: "always",
  });

  useEffect(() => {
    if (!query.data || query.data.view.status !== "ready") return;
    const timer = setTimeout(() => tick((value) => value + 1),
      Math.max(0, query.data.freshUntil - performance.now()));
    return () => clearTimeout(timer);
  }, [query.data]);

  const mutation = useMutation({
    mutationKey: websiteQueryKeys.eventAssistance.reply(instanceId),
    retry: false, gcTime: 0,
    // Only the choice id is kept in mutation variables, never the bearer secret.
    mutationFn: async (_choiceId: string) => {
      const input = pending.current;
      if (!input) throw new Error("Missing guest reply");
      await client.cancelQueries({queryKey});
      const started = performance.now();
      const output = await submitEventAssistanceGuestChoice(input);
      return {output, started};
    },
    onSuccess: ({output, started}) => {
      if (!mounted.current) return;
      client.setQueryData<GuestSnapshot>(queryKey, (previous) =>
        newerGuestSnapshot(previous, guestSnapshot(output.view, started)));
      pending.current = null;
      setNotice(output.result.kind === "rejected" ? copy.changed : "");
    },
    onError: () => { if (mounted.current) setNotice(copy.uncertain); },
    onSettled: () => {
      locked.current = false;
      if (mounted.current) setSending(false);
    },
  });

  function submit(choiceId: string) {
    const snapshot = client.getQueryData<GuestSnapshot>(queryKey);
    const view = snapshot?.view;
    const displayed = query.data?.view;
    if (displayed?.status !== "ready" || view?.status !== "ready" ||
        displayed.intentId !== view.intentId ||
        displayed.intentRevision !== view.intentRevision ||
        displayed.guestRevision !== view.guestRevision) return;
    if (locked.current || !credential || !snapshot || view?.status !== "ready" ||
        view.response || query.isError || performance.now() >= snapshot.freshUntil ||
        !view.choices.some((choice) => choice.choiceId === choiceId)) return;
    const previous = pending.current;
    const sameInstruction = previous?.intentId === view.intentId &&
      previous.intentRevision === view.intentRevision;
    if (sameInstruction && previous.choiceId !== choiceId) return;
    const input = sameInstruction ? previous : {...credential,
      intentId: view.intentId, intentRevision: view.intentRevision,
      expectedGuestRevision: view.guestRevision, choiceId,
      requestId: crypto.randomUUID()};
    pending.current = input;
    locked.current = true;
    setSending(true);
    setNotice("");
    mutation.mutate(choiceId);
  }

  const snapshot = query.data;
  let screen: AssistanceScreen;
  if (!credential) screen = {kind: "unavailable", reason: "invalid"};
  else if (query.error && typeof query.error === "object" &&
      "code" in query.error && query.error.code === "functions/not-found") {
    screen = {kind: "unavailable", reason: "invalid"};
  } else if (!snapshot && query.isPending) screen = {kind: "loading"};
  else if (!snapshot) screen = {kind: "unavailable", reason: "network"};
  else if (snapshot.view.status === "unavailable") {
    screen = {kind: "unavailable", reason: snapshot.view.reason};
  } else {
    const matchesPending = pending.current?.intentId === snapshot.view.intentId &&
      pending.current?.intentRevision === snapshot.view.intentRevision;
    screen = {kind: "ready", view: snapshot.view,
      fresh: !query.isError && performance.now() < snapshot.freshUntil,
      pending: sending, pendingChoice: sending ? pending.current?.choiceId ?? null : null,
      retryChoice: matchesPending ? pending.current!.choiceId : null, notice};
  }
  return {screen, submit, refreshing: query.isFetching,
    refresh: () => { if (!locked.current) void query.refetch(); }};
}
