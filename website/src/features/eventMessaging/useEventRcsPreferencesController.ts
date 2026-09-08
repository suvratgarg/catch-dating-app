import {useInfiniteQuery, useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useEffect, useRef, useState} from "react";
import {getEventRcsPreference, listEventRcsPreferences, setEventRcsPreference,
  watchEventRuntimeAuthState} from "../../firebase";
import type {EventRcsPreferenceCallableResponse as Response} from "../../shared/contracts/generated/eventRcsPreferenceOutput";
import type {SetEventRcsPreferenceCallablePayload as Submission} from "../../shared/contracts/generated/setEventRcsPreferenceInput";
import {eventRcsMessagingCopy as copy} from "../../content/eventMessaging";
import {websiteQueryKeys} from "../../shared/query/queryKeys";
import {newerRcsPreference, rcsPreferenceOptions, rcsPreferenceResponse,
  type RcsPreferenceState} from "./rcsPreferenceModel";

type Request = {identity: string; submission: Submission};
export function useEventRcsPreferencesController(eventId: string, attendeeId: string) {
  const client = useQueryClient();
  const [instance] = useState(() => crypto.randomUUID());
  const [auth, setAuth] = useState<{uid: string | null; epoch: number}>({uid: null, epoch: 0});
  const authRef = useRef(auth);
  const mounted = useRef(true);
  const pending = useRef<Request | null>(null);
  const lock = useRef(false);
  const [sending, setSending] = useState(false);
  const [notice, setNotice] = useState("");
  const [selection, setSelection] = useState<{identity: string; senderId: string} | null>(null);
  const identity = JSON.stringify([eventId, attendeeId, auth.uid, auth.epoch]);
  const identityRef = useRef(identity);
  identityRef.current = identity;
  const preferenceIdentityRef = useRef("");

  useEffect(() => {
    mounted.current = true;
    const unsubscribe = watchEventRuntimeAuthState((user) => {
      if (!mounted.current || authRef.current.uid === (user?.uid ?? null)) return;
      const next = {uid: user?.uid ?? null, epoch: authRef.current.epoch + 1};
      authRef.current = next;
      identityRef.current = "auth-changing";
      preferenceIdentityRef.current = "auth-changing";
      pending.current = null; lock.current = false;
      setSending(false); setNotice(""); setSelection(null); setAuth(next);
    });
    return () => { mounted.current = false; unsubscribe(); };
  }, []);

  const optionsKey = websiteQueryKeys.eventMessaging.rcsOptions(instance, identity);
  const options = useInfiniteQuery({
    queryKey: optionsKey, enabled: auth.uid !== null,
    initialPageParam: null as string | null,
    queryFn: async ({signal, pageParam}) => {
      const result = await listEventRcsPreferences({eventId, attendeeId, cursor: pageParam});
      signal.throwIfAborted();
      return rcsPreferenceOptions(result, {eventId, attendeeId}, pageParam);
    },
    getNextPageParam: (last) => last.nextCursor,
    // Discovery is a page-session selection. It cannot replace a reviewed sender mid-save.
    retry: false, gcTime: 0, staleTime: Infinity,
    refetchOnWindowFocus: false, refetchOnReconnect: false,
  });
  const configured = options.data?.pages[0]?.configuredSenderId ?? null;
  const earlierIds = [...new Set(options.data?.pages.flatMap((p) => p.previousSenderIds) ?? [])]
    .filter((id) => id !== configured);
  const senderId = selection?.identity === identity ? selection.senderId : configured ?? earlierIds[0] ?? null;
  const earlier = senderId !== null && senderId !== configured;
  const preferenceIdentity = JSON.stringify([identity, senderId]);
  preferenceIdentityRef.current = preferenceIdentity;
  const queryKey = websiteQueryKeys.eventMessaging.rcsPreference(instance, preferenceIdentity);
  const unresolved = pending.current?.identity === preferenceIdentity;
  const query = useQuery({
    queryKey, enabled: auth.uid !== null && senderId !== null && !sending && !unresolved,
    queryFn: async ({signal}) => {
      const scope = {eventId, attendeeId, senderId: senderId!};
      const result = await getEventRcsPreference(scope);
      signal.throwIfAborted();
      return newerRcsPreference(client.getQueryData<Response>(queryKey),
        rcsPreferenceResponse(result, scope, "read"));
    },
    retry: false, staleTime: 0, gcTime: 0,
    refetchInterval: 30_000, refetchIntervalInBackground: false,
    refetchOnWindowFocus: "always", refetchOnReconnect: "always",
  });
  const mutation = useMutation({retry: false, gcTime: 0,
    mutationFn: async (request: Request) => {
      await client.cancelQueries({queryKey});
      if (!mounted.current || preferenceIdentityRef.current !== request.identity) {
        throw new Error("Preference scope changed");
      }
      return rcsPreferenceResponse(await setEventRcsPreference(request.submission),
        request.submission, "mutation");
    },
    onSuccess: (response, request) => {
      if (!mounted.current || preferenceIdentityRef.current !== request.identity) return;
      const current = newerRcsPreference(client.getQueryData<Response>(queryKey), response);
      client.setQueryData(queryKey, current);
      pending.current = null;
      setNotice(response.outcome === "conflict" || current !== response ? copy.changed :
        current.view.preference === "enabled" ? copy.savedOn : copy.savedOff);
    },
    onError: (error, request) => {
      if (!mounted.current || preferenceIdentityRef.current !== request.identity) return;
      const code = typeof error === "object" && error !== null && "code" in error ? error.code : "";
      if (["functions/invalid-argument", "functions/failed-precondition",
        "functions/permission-denied", "functions/unauthenticated"].includes(String(code))) {
        pending.current = null;
        setNotice(copy.rejected);
        void client.invalidateQueries({queryKey});
      } else setNotice(copy.uncertain);
    },
    onSettled: (_response, _error, request) => {
      if (!mounted.current || preferenceIdentityRef.current !== request.identity) return;
      lock.current = false; setSending(false);
    },
  });

  function submit(decision: "grant" | "revoke" | "retry") {
    if (lock.current || !mounted.current || !auth.uid || !senderId ||
        preferenceIdentityRef.current !== preferenceIdentity || identityRef.current !== identity) return;
    let request: Request;
    if (decision === "retry") {
      if (pending.current?.identity !== preferenceIdentity) return;
      request = pending.current;
    } else {
      const shown = query.data?.view;
      const cached = client.getQueryData<Response>(queryKey)?.view;
      if (pending.current || !shown || !cached || query.isError || options.isError ||
          shown.revision !== cached.revision || shown.reviewHash !== cached.reviewHash ||
          (decision === "grant" && (earlier || !cached.canEnable)) ||
          (decision === "revoke" && cached.preference !== "enabled")) return;
      request = {identity: preferenceIdentity, submission: {eventId, attendeeId, senderId,
        requestId: crypto.randomUUID(), expectedRevision: shown.revision,
        decision: decision === "grant" ? {kind: "grant", copyVersion: shown.consent.version,
          reviewHash: shown.reviewHash} : {kind: "revoke"}}};
    }
    pending.current = request; lock.current = true; setSending(true); setNotice("");
    mutation.mutate(request);
  }

  const canNavigate = () => mounted.current && identityRef.current === identity &&
    !lock.current && !pending.current && !options.isFetching;
  function choose(id: string | null) {
    if (!id || !canNavigate() || (id !== configured && !earlierIds.includes(id))) return;
    preferenceIdentityRef.current = "selection-changing";
    setNotice(""); setSelection({identity, senderId: id});
  }
  async function next() {
    if (!canNavigate()) return;
    const index = senderId ? earlierIds.indexOf(senderId) : -1;
    if (earlierIds[index + 1]) { choose(earlierIds[index + 1]); return; }
    if (!options.hasNextPage) return;
    const result = await options.fetchNextPage();
    if (!mounted.current || identityRef.current !== identity || pending.current || result.isError) return;
    const ids = [...new Set(result.data?.pages.flatMap((p) => p.previousSenderIds) ?? [])]
      .filter((id) => id !== configured);
    const id = ids[index + 1];
    if (id) {
      preferenceIdentityRef.current = "selection-changing";
      setNotice(""); setSelection({identity, senderId: id});
    }
  }
  function refresh() {
    if (!canNavigate()) return;
    if (options.isError || !senderId) void options.refetch();
    else void query.refetch();
  }

  const view = query.data?.view;
  const uncertain = unresolved && !sending;
  let state: RcsPreferenceState;
  if (!auth.uid) state = {kind: "hidden"};
  else if (options.isError && !unresolved) state = {kind: "error"};
  else if (!options.data || senderId && !view && query.isPending) state = {kind: "loading"};
  else if (senderId && (!view || query.isError && !unresolved)) state = {kind: "error"};
  else if (!view) state = {kind: "hidden"};
  else state = {kind: "ready", view, earlier, pending: sending, uncertain, notice};
  const index = senderId ? earlierIds.indexOf(senderId) : -1;
  return {state, navigation: {
    earlier, showEarlier: !earlier && (earlierIds.length > 0 || options.hasNextPage),
    showCurrent: earlier && configured !== null,
    showPrevious: earlier && index > 0,
    showNext: (earlier || !senderId) && (index + 1 < earlierIds.length || options.hasNextPage),
    busy: sending || unresolved || options.isFetching,
  }, enable: () => submit("grant"), disable: () => submit("revoke"),
  retry: () => submit("retry"), refresh, next,
  previous: () => choose(earlierIds[index - 1] ?? null),
  current: () => choose(configured), manageEarlier: () => {
    if (earlierIds[0]) choose(earlierIds[0]); else void next();
  }};
}
