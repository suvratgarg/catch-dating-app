import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useEffect, useRef, useState} from "react";
import {
  getEventAssistanceSmsPreference,
  setEventAssistanceSmsPreference,
  watchEventRuntimeAuthState,
} from "../../firebase";
import type {EventAssistanceSmsPreferenceCallableResponse as Response} from "../../shared/contracts/generated/eventAssistanceSmsPreferenceCallableResponse";
import type {SetEventAssistanceSmsPreferenceCallablePayload as Submission} from "../../shared/contracts/generated/setEventAssistanceSmsPreferenceCallablePayload";
import {eventMessagingCopy as copy} from "../../content/eventMessaging";
import {websiteQueryKeys} from "../../shared/query/queryKeys";
import {newerSmsPreference, type EventMessagingState} from "./eventMessagingModel";

type PendingRequest = {identity: string; submission: Submission};

export function useEventSmsPreferenceController(eventId: string, attendeeId: string) {
  const client = useQueryClient();
  const [instance] = useState(() => crypto.randomUUID());
  const [auth, setAuth] = useState<{uid: string | null; epoch: number}>({uid: null, epoch: 0});
  const authRef = useRef(auth);
  const mounted = useRef(true);
  const pendingRequest = useRef<PendingRequest | null>(null);
  const lock = useRef(false);
  const [sending, setSending] = useState(false);
  const [notice, setNotice] = useState("");
  const identity = JSON.stringify([eventId, attendeeId, auth.uid, auth.epoch]);
  const identityRef = useRef(identity);
  identityRef.current = identity;
  const queryKey = websiteQueryKeys.eventMessaging.smsPreference(instance, identity);

  useEffect(() => {
    mounted.current = true;
    const unsubscribe = watchEventRuntimeAuthState((user) => {
      if (!mounted.current || authRef.current.uid === (user?.uid ?? null)) return;
      const next = {uid: user?.uid ?? null, epoch: authRef.current.epoch + 1};
      authRef.current = next;
      // Immediately fence replies, even before React commits the auth render.
      identityRef.current = "auth-changing";
      pendingRequest.current = null;
      lock.current = false;
      setSending(false);
      setNotice("");
      setAuth(next);
    });
    return () => { mounted.current = false; unsubscribe(); };
  }, []);

  const query = useQuery({
    queryKey, enabled: auth.uid !== null && !sending,
    queryFn: async ({signal}) => {
      const response = await getEventAssistanceSmsPreference({eventId, attendeeId});
      signal.throwIfAborted();
      return newerSmsPreference(client.getQueryData<Response>(queryKey), response);
    },
    retry: false, staleTime: 0, gcTime: 0,
    refetchInterval: 30_000, refetchIntervalInBackground: false,
    refetchOnWindowFocus: "always", refetchOnReconnect: "always",
  });
  const mutation = useMutation({
    retry: false, gcTime: 0,
    mutationFn: async (request: PendingRequest) => {
      await client.cancelQueries({queryKey});
      if (!mounted.current || identityRef.current !== request.identity) {
        throw new Error("Preference scope changed");
      }
      return setEventAssistanceSmsPreference(request.submission);
    },
    onSuccess: (response, request) => {
      if (!mounted.current || identityRef.current !== request.identity) return;
      client.setQueryData<Response>(queryKey, (previous) => newerSmsPreference(previous, response));
      pendingRequest.current = null;
      setNotice(response.outcome === "conflict" ? copy.changed :
        response.view.preference === "enabled" ? copy.savedOn : copy.savedOff);
    },
    onError: (error, request) => {
      if (!mounted.current || identityRef.current !== request.identity) return;
      const code = typeof error === "object" && error !== null && "code" in error ? error.code : "";
      if (["functions/invalid-argument", "functions/failed-precondition",
        "functions/permission-denied", "functions/unauthenticated"].includes(String(code))) {
        pendingRequest.current = null;
        setNotice(copy.rejected);
        void client.invalidateQueries({queryKey});
      } else setNotice(copy.uncertain);
    },
    onSettled: (_result, _error, request) => {
      if (!mounted.current || identityRef.current !== request.identity) return;
      lock.current = false;
      setSending(false);
    },
  });

  function submit(decision: "grant" | "revoke" | "retry") {
    if (lock.current || !mounted.current || !auth.uid || identityRef.current !== identity) return;
    const view = query.data?.view;
    const cached = client.getQueryData<Response>(queryKey)?.view;
    const existing = pendingRequest.current;
    let request: PendingRequest;
    if (decision === "retry") {
      if (!existing || existing.identity !== identity) return;
      request = existing;
    } else {
      if (existing?.identity === identity || !view || !cached || query.isError ||
          view.revision !== cached.revision ||
          (decision === "grant" && !cached.canEnable)) return;
      request = {identity, submission: {eventId, attendeeId,
        requestId: crypto.randomUUID(), expectedRevision: cached.revision,
        decision: decision === "grant" ?
          {kind: "grant", copyVersion: cached.consent.version} : {kind: "revoke"}}};
    }
    pendingRequest.current = request;
    lock.current = true;
    setSending(true);
    setNotice("");
    mutation.mutate(request);
  }

  const view = query.data?.view;
  const uncertain = pendingRequest.current?.identity === identity && !sending;
  let state: EventMessagingState;
  if (!auth.uid) state = {kind: "hidden"};
  else if (!view && query.isPending) state = {kind: "loading"};
  else if (!view || query.isError && !uncertain) state = {kind: "error"};
  else if (!view.canEnable && view.preference === "notSet" && !uncertain) state = {kind: "hidden"};
  else state = {kind: "ready", view, pending: sending, uncertain, notice};
  return {state, enable: () => submit("grant"), disable: () => submit("revoke"),
    retry: () => submit("retry"), refresh: () => { if (!lock.current) void query.refetch(); }};
}
