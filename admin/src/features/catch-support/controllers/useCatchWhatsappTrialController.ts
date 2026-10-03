import {useMutation} from "@tanstack/react-query";
import {useEffect, useMemo, useRef, useState} from "react";
import {useAdminPendingOperationGuard} from "../../../shared/pendingOperation";
import {CatchWhatsappReplyAttempts, CatchWhatsappReplySession} from
  "../../../shared/controllers/catchWhatsappReplySession";
import {catchWhatsappTrialApi, type CatchTrialApi, type CatchTrialScope} from
  "../api/catchWhatsappTrialRepository";

// Page-lifetime tombstones live outside the session-keyed provider subtree.
// Retain only project + opaque inbound ID across account changes/remounts, never
// review text, reply text, tokens, actor IDs or results. No browser persistence;
// server claims remain authoritative across reloads and other tabs/devices.
const replyAttempts = new CatchWhatsappReplyAttempts();

export function useCatchWhatsappTrialController({scope, enabled,
  api = catchWhatsappTrialApi}: {
  scope: CatchTrialScope; enabled: boolean; api?: CatchTrialApi;
}) {
  const {beginOperation, endOperation} = useAdminPendingOperationGuard();
  const holder = useMemo(() => {
    const session = new CatchWhatsappReplySession(replyAttempts);
    const context = {actorUid: scope.actorUid, projectId: scope.projectId,
      sessionKey: scope.sessionKey, enabled};
    session.setContext(context);
    return {session, context, active: true, busy: false, error: "", eventId: ""};
  }, [scope.actorUid, scope.projectId, scope.sessionKey, enabled]);
  const latest = useRef({holder, scope});
  latest.current = {holder, scope};
  const [, render] = useState(0);
  const refresh = () => render((value) => value + 1);
  const current = () => holder.active && latest.current.holder === holder &&
    latest.current.scope.isCurrent();

  useEffect(() => {
    holder.active = true;
    // StrictMode may retire and restore this effect without another render.
    holder.session.setContext(holder.context);
    return () => {
      holder.active = false;
      holder.session.setContext(null);
      holder.eventId = "";
      holder.error = "";
    };
  }, [holder]);
  const view = holder.session.snapshot();
  useEffect(() => {
    if (!view.inbound) return undefined;
    const delay = view.inbound.deadlineMillis - Date.now();
    if (delay <= 0) return undefined;
    const timer = setTimeout(() => render((value) => value + 1), delay);
    return () => clearTimeout(timer);
  }, [view.inbound]);

  const mutation = useMutation({
    // Never queue an offline send to resume later or automatically retry.
    retry: false, gcTime: 0, networkMode: "always",
    mutationFn: async (kind: "review" | "send") => {
      if (!current()) throw new Error("Session changed.");
      if (kind === "review") {
        const ticket = holder.session.startReview(holder.eventId);
        refresh();
        try {
          const assertCurrent = await api.prepare(scope);
          if (!current()) return;
          assertCurrent();
          const review = await api.review(ticket.eventId, scope);
          if (current()) holder.session.acceptReview(ticket, review, Date.now());
        } catch {
          holder.session.failReview(ticket);
          throw new Error("Support request could not be reviewed.");
        }
      } else {
        // Resolve credentials/session first, then recheck the exact confirmation
        // and deadline immediately before consuming and dispatching the command.
        try {
          const assertCurrent = await api.prepare(scope);
          if (!current()) return;
          assertCurrent();
          const ticket = holder.session.takeConfirmedCommand(Date.now());
          refresh();
          assertCurrent();
          const result = await api.send(ticket.command, scope);
          if (current()) holder.session.acceptResult(ticket, result);
        } catch {
          throw new Error("Support reply outcome is unavailable.");
        }
      }
      // Do not retain private response bodies in TanStack mutation data.
    },
  });

  const run = async (kind: "review" | "send") => {
    if (!enabled || !current() || holder.busy) return;
    const lease = beginOperation();
    if (!lease) return;
    holder.busy = true; holder.error = ""; refresh();
    try {
      await mutation.mutateAsync(kind);
    } catch {
      if (current()) {
        holder.error = holder.session.snapshot().phase === "unknown" ?
          "The outcome is unconfirmed. Do not send again; request reconciliation." :
          "The action is unavailable. Review the request and current session again.";
      }
    } finally {
      holder.busy = false;
      mutation.reset();
      endOperation(lease);
      if (current()) refresh();
    }
  };
  const editReply = (body: string) => {
    if (holder.busy || !current()) return;
    holder.session.editReply(body); holder.error = ""; refresh();
  };
  const confirm = (checked: boolean) => {
    if (holder.busy || !current()) return;
    try {
      if (checked) holder.session.confirmSupportRequest(Date.now());
      else holder.session.editReply(holder.session.snapshot().replyBody);
      holder.error = "";
    } catch {
      holder.error = "A current support request and reply are required.";
    }
    refresh();
  };
  const terminal = view.phase === "unknown" || view.phase === "sent";
  const expired = Boolean(view.inbound &&
    view.inbound.deadlineMillis <= Date.now());
  return {
    ...view, enabled, busy: holder.busy, error: holder.error,
    eventId: holder.eventId, expired, terminal,
    setEventId: (value: string) => {
      if (holder.busy || terminal || !current()) return;
      // Changing the target invalidates any visible review and confirmation.
      holder.eventId = value;
      holder.session.setContext(null);
      holder.session.setContext({...scope, enabled});
      holder.error = ""; refresh();
    },
    editReply, confirm,
    review: () => run("review"),
    send: () => run("send"),
  };
}
