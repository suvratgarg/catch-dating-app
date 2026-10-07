import {useEffect, useRef, useState} from "react";
import {auth} from "../../../shared/api/firebase";
import {AdminButton, AdminSignInPanel, AdminSignInScreen} from "../../../shared/ui/AdminPrimitives";
import {loopbackOrigin, sessionRequest, transferSession, type SessionRequest} from "../api/operatorSessionHandoff";

// Independent of workspace roles: this exports this actor's own session and
// exposes no Admin data, queries, callables or authority changes.
export function OperatorSessionScreen() {
  const [request, setRequest] = useState<SessionRequest | null>(null);
  const [status, setStatus] = useState("Open this view from your protected local session UI.");
  const [pending, setPending] = useState(false);
  const connection = useRef<{opener: Window; origin: string; request: SessionRequest} | null>(null);
  const alive = useRef(true);
  const consumed = useRef(false);
  useEffect(() => {
    alive.current = true;
    const opener = window.opener as Window | null;
    if (!opener || window.location.protocol !== "https:") return;
    const receive = (event: MessageEvent) => {
      if (event.source !== opener || !loopbackOrigin(event.origin)) return;
      if (connection.current && event.data && Object.keys(event.data).sort().join(",") === "challenge,kind" &&
          event.data.kind === "catch-operator-session-cancel" &&
          event.origin === connection.current.origin && event.data.challenge === connection.current.request.challenge) {
        alive.current = false; setPending(false); setStatus("Cancelled. No session was transferred."); return;
      }
      if (connection.current) return;
      try {
        const value = sessionRequest(event.data);
        if (value.projectId !== auth.app.options.projectId) return;
        connection.current = {opener, origin: event.origin, request: value};
        setRequest(value); setStatus("Review this account and local destination before transferring your session.");
        opener.postMessage({kind: "catch-operator-session-ready", challenge: value.challenge}, event.origin);
      } catch { /* Ignore untrusted or expired handshakes. */ }
    };
    window.addEventListener("message", receive);
    return () => {alive.current = false; window.removeEventListener("message", receive);};
  }, []);
  const transfer = async () => {
    if (!alive.current || consumed.current || !connection.current) return;
    consumed.current = true; setPending(true);
    const saved = connection.current;
    const isCurrent = () => alive.current && window.opener === saved.opener &&
      !saved.opener.closed && connection.current === saved;
    try {
      const value = await transferSession(auth, saved.request, isCurrent);
      if (!isCurrent()) return;
      saved.opener.postMessage(value, saved.origin);
      setStatus("Session transferred to the selected local helper. Check its save receipt.");
    } catch {
      setStatus("Session unavailable. Use Catch’s normal Google sign-in UI, then restart the local handoff. A token refresh does not replace a fresh sign-in.");
    } finally {if (alive.current) setPending(false);}
  };
  const cancel = () => {
    alive.current = false;
    const saved = connection.current;
    saved?.opener.postMessage({kind: "catch-operator-session-cancel", challenge: saved.request.challenge}, saved.origin);
    setPending(false); setStatus("Cancelled. No session was transferred.");
  };
  return <AdminSignInScreen><AdminSignInPanel>
    <h1>Catch operator session</h1><p>{status}</p>
    {request ? <><p>Project: {request.projectId}. Account: {request.actorUid}.</p>
      <p>Local destination: {connection.current?.origin}. Source: {request.sourceSha}.</p></> : null}
    <AdminButton disabled={!request || pending || consumed.current || !alive.current} onClick={() => void transfer()}>Transfer my current Google session</AdminButton>
    <AdminButton disabled={!request || !alive.current} onClick={cancel}>Cancel</AdminButton>
    <p>This creates no plan, approval or Admin grant. Your credentials stay out of chat and this page’s text.</p>
  </AdminSignInPanel></AdminSignInScreen>;
}
