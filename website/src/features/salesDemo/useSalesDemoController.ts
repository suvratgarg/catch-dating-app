import {useMutation, useQuery} from "@tanstack/react-query";
import {useCallback, useEffect, useRef, useState} from "react";
import type {SalesDemoAuth, SalesDemoViewer} from "./salesDemoAuth";
import type {SalesDemoAction, SalesDemoApi, SalesDemoSession, SalesDemoSetup} from
  "./salesDemoModel";

type Choice = "approve" | "needs_info" | "welcome" | "clarify";
type ActionInput = {action: SalesDemoAction; choice?: Choice};
type PendingAction = ActionInput & {requestId: string; expectedRevision: number};

function errorMessage(error: unknown): string {
  const message = error instanceof Error ? error.message : String(error);
  if (/permission-denied|verified contact does not match/iu.test(message)) {
    return "This account does not match the invitation. Use the invited email or verify the invited phone below, or ask the inviter to review the link.";
  }
  if (/retry later/iu.test(message)) {
    return "Please wait a minute before trying again. Your invitation is still available.";
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
  const [setup, setSetup] = useState<SalesDemoSetup | null>(null);
  const [setupFresh, setSetupFresh] = useState(false);
  const [setupNotice, setSetupNotice] = useState("");
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
        setSetup(null); setSetupFresh(false); setSetupNotice("");
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
      setSetup(null); setSetupFresh(false);
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
      setSetup(null); setSetupFresh(false);
      if (actionAttempt.current && latest.revision >
          actionAttempt.current.expectedRevision) {
        actionAttempt.current = null; setRetryAction(null);
      }
    } catch (error) {
      if (epoch.current === startedEpoch) {setFresh(false); setSetupFresh(false);
        setNotice(errorMessage(error));}
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
      setSetup(null); setSetupFresh(false);
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
        setSetup(null); setSetupFresh(false);
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

  const performReadSetup = useCallback(async () => {
    if (locked.current || !session || session.status !== "completed" ||
        !fresh || !viewer || !grantToken ||
        sessionRef.current?.revision !== session.revision ||
        Date.parse(session.expiresAt) <= Date.now()) return;
    locked.current = true; setSetupNotice(""); setSetupFresh(false); setSetup(null);
    const startedEpoch = epoch.current;
    try {
      const latest = await api.getSetup({sessionId: session.sessionId, grantToken});
      if (epoch.current !== startedEpoch || sessionRef.current?.revision !==
          session.revision) return;
      if (latest.schemaVersion !== 1 || latest.publicationAuthority !== false ||
          !/^[a-f0-9]{64}$/u.test(latest.setupHash)) {
        throw new Error("Invalid setup projection.");
      }
      setSetup(latest); setSetupFresh(true);
    } catch (error) {
      if (epoch.current === startedEpoch) setSetupNotice(errorMessage(error));
    } finally {locked.current = false;}
  }, [api, fresh, grantToken, session, viewer]);

  const performPrepareSetup = useCallback(async () => {
    if (locked.current || !session || session.status !== "completed" ||
        !fresh || !setupFresh || setup?.status !== "ready" ||
        setup.plan.mode !== "template" || !viewer || !grantToken ||
        sessionRef.current?.revision !== session.revision ||
        Date.parse(session.expiresAt) <= Date.now()) return;
    locked.current = true; setSetupNotice(""); setSetupFresh(false);
    const startedEpoch = epoch.current;
    try {
      const result = await api.prepareSetup({sessionId: session.sessionId,
        grantToken, setupHash: setup.setupHash});
      if (epoch.current !== startedEpoch || sessionRef.current?.revision !==
          session.revision) return;
      if (result.schemaVersion !== 1 || result.publicationAuthority !== false ||
          result.setupHash !== setup.setupHash || result.status !== "prepared") {
        throw new Error("Invalid prepared setup projection.");
      }
      setSetup(result); setSetupFresh(true);
    } catch (error) {
      if (epoch.current !== startedEpoch) return;
      setSetup(null); setSetupNotice(errorMessage(error));
      // A timed-out transaction might have committed. Read before another action.
      try {
        const latest = await api.getSetup({sessionId: session.sessionId,
          grantToken});
        if (epoch.current !== startedEpoch || sessionRef.current?.revision !==
            session.revision) return;
        if (latest.schemaVersion === 1 && latest.publicationAuthority === false) {
          setSetup(latest); setSetupFresh(true);
          if (latest.status === "prepared") setSetupNotice("");
        }
      } catch { /* Keep the explicit retry-read action available. */ }
    } finally {locked.current = false;}
  }, [api, fresh, grantToken, session, setup, setupFresh, viewer]);

  const startMutation = useMutation({mutationFn: performStart,
    retry: false, gcTime: 0});
  const refreshMutation = useMutation({mutationFn: performRefresh,
    retry: false, gcTime: 0});
  const advanceMutation = useMutation({mutationFn: performAdvance,
    retry: false, gcTime: 0});
  const setupMutation = useMutation({mutationFn: performReadSetup,
    retry: false, gcTime: 0});
  const prepareMutation = useMutation({mutationFn: performPrepareSetup,
    retry: false, gcTime: 0});
  const pending = startMutation.isPending || refreshMutation.isPending ||
    advanceMutation.isPending || setupMutation.isPending ||
    prepareMutation.isPending;
  const start = () => startMutation.mutateAsync();
  const refresh = () => refreshMutation.mutateAsync();
  const advance = (input: ActionInput) => advanceMutation.mutateAsync(input);
  const readSetup = () => setupMutation.mutateAsync();
  const prepareSetup = () => prepareMutation.mutateAsync();

  return {preview, viewer, authReady, session, fresh, pending, notice,
    canTry, start, refresh, advance, retryAction, setup, setupFresh,
    setupNotice, readSetup, prepareSetup};
}
