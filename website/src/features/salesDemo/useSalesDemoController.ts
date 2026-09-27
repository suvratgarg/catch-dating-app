import {useMutation, useQuery} from "@tanstack/react-query";
import {useCallback, useEffect, useRef, useState} from "react";
import type {SalesDemoAuth, SalesDemoViewer} from "./salesDemoAuth";
import type {SalesDemoAction, SalesDemoApi, SalesDemoSession} from
  "./salesDemoModel";

type Choice = "approve" | "needs_info" | "welcome" | "clarify";
type ActionInput = {action: SalesDemoAction; choice?: Choice};
type PendingAction = ActionInput & {requestId: string; expectedRevision: number};

function errorMessage(error: unknown): string {
  const message = error instanceof Error ? error.message : String(error);
  if (/permission-denied|verified contact does not match/iu.test(message)) {
    return "This signed-in contact is not approved for the interactive example. Ask the inviter to review the link.";
  }
  if (/resource-exhausted|renewed invitation/iu.test(message)) {
    return "This invitation has reached its trial limit. Ask the inviter for a renewed link.";
  }
  if (/not-found|expired|revoked|unavailable/iu.test(message)) {
    return "This demo is unavailable or has expired. Ask the inviter for a current link.";
  }
  return "We could not confirm the change. Your next retry will use the same request. Refresh the example to check its latest state.";
}

export function useSalesDemoController({invitationId, grantToken, api, auth}: {
  invitationId: string; grantToken: string | null;
  api: SalesDemoApi; auth: SalesDemoAuth;
}) {
  const [viewer, setViewer] = useState<SalesDemoViewer | null>(null);
  const [authReady, setAuthReady] = useState(false);
  const [session, setSession] = useState<SalesDemoSession | null>(null);
  const sessionRef = useRef<SalesDemoSession | null>(null);
  const [fresh, setFresh] = useState(false);
  const [notice, setNotice] = useState("");
  const [retryAction, setRetryAction] = useState<ActionInput | null>(null);
  const startRequestId = useRef<string | null>(null);
  const actionAttempt = useRef<PendingAction | null>(null);
  const locked = useRef(false);
  const authUid = useRef<string | null>(null);
  const epoch = useRef(0);
  sessionRef.current = session;

  const preview = useQuery({
    queryKey: ["sales-demo-preview", invitationId],
    enabled: /^[A-Za-z0-9_-]{3,128}$/u.test(invitationId),
    queryFn: () => api.preview({invitationId}),
    retry: false, staleTime: 0, gcTime: 0,
  });

  useEffect(() => {
    const unsubscribe = auth.watch((next) => {
      if (authUid.current !== next?.uid && authUid.current !== null) {
        epoch.current += 1;
        setSession(null); setFresh(false); setNotice("");
        startRequestId.current = null; actionAttempt.current = null;
        setRetryAction(null);
      }
      authUid.current = next?.uid ?? null;
      setViewer(next); setAuthReady(true);
    });
    return () => {epoch.current += 1; unsubscribe();};
  }, [auth]);

  const canTry = Boolean(preview.data?.interactiveAvailable && grantToken &&
    viewer && (viewer.emailVerified || viewer.phoneNumber));

  const performStart = useCallback(async () => {
    if (locked.current || sessionRef.current || !canTry || !grantToken || !viewer ||
        (preview.data && Date.parse(preview.data.expiresAt) <= Date.now())) return;
    locked.current = true; setNotice("");
    const requestId = startRequestId.current ?? crypto.randomUUID();
    startRequestId.current = requestId;
    const startedEpoch = epoch.current;
    try {
      const next = await api.start({invitationId, grantToken, requestId});
      if (epoch.current !== startedEpoch) return;
      if (next.synthetic !== true || next.invitationId !== invitationId) {
        throw new Error("Invalid synthetic session projection.");
      }
      setSession(next); setFresh(true); startRequestId.current = null;
    } catch (error) {
      if (epoch.current === startedEpoch) setNotice(errorMessage(error));
    } finally {
      locked.current = false;
    }
  }, [api, canTry, grantToken, invitationId, preview.data, viewer]);

  const performRefresh = useCallback(async () => {
    if (locked.current || !session || !grantToken) return;
    locked.current = true; setNotice("");
    const startedEpoch = epoch.current;
    try {
      const latest = await api.getSession({sessionId: session.sessionId, grantToken});
      if (epoch.current !== startedEpoch) return;
      if (latest.synthetic !== true || latest.sessionId !== session.sessionId) {
        throw new Error("Invalid synthetic session projection.");
      }
      setSession(latest); setFresh(true);
      if (actionAttempt.current && latest.revision >
          actionAttempt.current.expectedRevision) {
        actionAttempt.current = null; setRetryAction(null);
      }
    } catch (error) {
      if (epoch.current === startedEpoch) {setFresh(false); setNotice(errorMessage(error));}
    } finally {
      locked.current = false;
    }
  }, [api, grantToken, session]);

  const performAdvance = useCallback(async ({action, choice}: ActionInput) => {
    if (locked.current || !session || sessionRef.current?.revision !== session.revision ||
        !fresh || !grantToken || Date.parse(session.expiresAt) <= Date.now() ||
        !session.allowedActions.includes(action)) return;
    const existing = actionAttempt.current;
    if (existing && (existing.action !== action || existing.choice !== choice)) return;
    const attempt: PendingAction = existing ?? {action, choice,
      expectedRevision: session.revision, requestId: crypto.randomUUID()};
    actionAttempt.current = attempt;
    setRetryAction({action, choice});
    locked.current = true; setNotice("");
    const startedEpoch = epoch.current;
    try {
      const next = await api.advance({sessionId: session.sessionId, grantToken,
        requestId: attempt.requestId, expectedRevision: attempt.expectedRevision,
        action, ...(choice === undefined ? {} : {choice})});
      if (epoch.current !== startedEpoch) return;
      if (next.synthetic !== true || next.sessionId !== session.sessionId) {
        throw new Error("Invalid synthetic session projection.");
      }
      setSession(next); setFresh(true); actionAttempt.current = null;
      setRetryAction(null);
    } catch (error) {
      if (epoch.current !== startedEpoch) return;
      setFresh(false);
      try {
        const latest = await api.getSession({sessionId: session.sessionId, grantToken});
        if (epoch.current !== startedEpoch) return;
        if (latest.synthetic !== true || latest.sessionId !== session.sessionId) {
          throw new Error("Invalid synthetic session projection.");
        }
        setSession(latest); setFresh(true);
        if (latest.revision > attempt.expectedRevision) {
          actionAttempt.current = null; setRetryAction(null);
          setNotice("The latest sample state is shown.");
        } else setNotice(errorMessage(error));
      } catch {
        if (epoch.current === startedEpoch) setNotice(errorMessage(error));
      }
    } finally {
      locked.current = false;
    }
  }, [api, fresh, grantToken, session]);

  const startMutation = useMutation({mutationFn: performStart,
    retry: false, gcTime: 0});
  const refreshMutation = useMutation({mutationFn: performRefresh,
    retry: false, gcTime: 0});
  const advanceMutation = useMutation({mutationFn: performAdvance,
    retry: false, gcTime: 0});
  const pending = startMutation.isPending || refreshMutation.isPending ||
    advanceMutation.isPending;
  const start = () => startMutation.mutateAsync();
  const refresh = () => refreshMutation.mutateAsync();
  const advance = (input: ActionInput) => advanceMutation.mutateAsync(input);

  return {preview, viewer, authReady, session, fresh, pending, notice,
    canTry, start, refresh, advance, retryAction};
}
