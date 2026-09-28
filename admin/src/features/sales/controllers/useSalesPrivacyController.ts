import {useQuery, useQueryClient} from "@tanstack/react-query";
import {useCallback, useEffect, useMemo, useRef, useState} from "react";
import {useAdminPendingOperationGuard} from "../../../shared/pendingOperation";
import {salesPrivacyApi} from "../api/salesPrivacyRepository";
import type {PrivacyApi, PrivacyPreview} from "../api/salesPrivacyTypes";

type Ticket =
  | {kind: "policy"; input: Parameters<PrivacyApi["reviewPolicy"]>[0]}
  | {kind: "restrict"; input: Parameters<PrivacyApi["restrict"]>[0]}
  | {kind: "review"; input: Parameters<PrivacyApi["reviewPlan"]>[0]}
  | {kind: "batch"; input: Parameters<PrivacyApi["applyBatch"]>[0]};
const definitive = new Set(["aborted", "invalid-argument", "permission-denied",
  "unauthenticated", "failed-precondition", "already-exists", "not-found",
  "resource-exhausted"]);
function errorCode(error: unknown): string {
  return error && typeof error === "object" && "code" in error ?
    String(error.code).replace(/^functions\//u, "") : "";
}

export function useSalesPrivacyController({actorUid, organizerId,
  api = salesPrivacyApi}: {actorUid: string; organizerId: string;
    api?: PrivacyApi}) {
  const client = useQueryClient();
  const {beginOperation, endOperation} = useAdminPendingOperationGuard();
  const scope = useMemo(() => ["sales-privacy", actorUid, organizerId] as const,
    [actorUid, organizerId]);
  const [preview, setPreview] = useState<PrivacyPreview | null>(null);
  const [busy, setBusy] = useState(false);
  const [previewBusy, setPreviewBusy] = useState(false);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [policyConflict, setPolicyConflict] = useState(false);
  const [confirmedPolicySaveId, setConfirmedPolicySaveId] =
    useState<string | null>(null);
  const [retryTicket, setRetryTicket] = useState<Ticket | null>(null);
  const pendingRef = useRef<Ticket | null>(null);
  const caseQuery = useQuery({queryKey: [...scope, "case"],
    queryFn: () => api.getCase(organizerId), retry: false});
  useEffect(() => () => {
    pendingRef.current = null;
    client.removeQueries({queryKey: scope});
  }, [client, scope]);

  const run = useCallback(async (ticket: Ticket): Promise<boolean> => {
    const lease = beginOperation();
    if (!lease) return false;
    setBusy(true); setError(""); setNotice("");
    if (ticket.kind === "policy") setPolicyConflict(false);
    try {
      if (ticket.kind === "policy") {
        await api.reviewPolicy(ticket.input);
        setNotice("Reviewed retention decision saved. Finance and audit records remain held for separate review.");
      } else if (ticket.kind === "restrict") {
        await api.restrict(ticket.input);
        setNotice("Private Sales processing is restricted for this organizer. The restriction is permanent in this workflow.");
      } else if (ticket.kind === "review") {
        await api.reviewPlan(ticket.input);
        setNotice("Exact inventory plan reviewed. Apply one bounded batch at a time.");
      } else {
        const result = await api.applyBatch(ticket.input);
        setNotice(result.batch.status === "processing" ?
          `Processed ${result.batch.nextCursor} of ${result.batch.itemCount} private records. Continue with the next batch.` :
          "Internal cleanup processed. Retained records and unverified copies remain; this is not complete erasure.");
      }
      pendingRef.current = null; setRetryTicket(null); setPreview(null);
      await client.invalidateQueries({queryKey: [...scope, "case"]});
      if (ticket.kind === "policy") {
        setConfirmedPolicySaveId(ticket.input.requestId);
      }
      return true;
    } catch (failure) {
      const code = errorCode(failure);
      if (definitive.has(code)) {
        pendingRef.current = null; setRetryTicket(null); setPreview(null);
        void client.invalidateQueries({queryKey: [...scope, "case"]});
        setPolicyConflict(ticket.kind === "policy" && code === "aborted");
        setError(failure instanceof Error ? failure.message :
          "The privacy action was rejected. Read the current case and review again.");
      } else {
        pendingRef.current = ticket; setRetryTicket(ticket);
        setError("The outcome is unconfirmed. Retry the same request before starting another action.");
      }
      return false;
    } finally {
      setBusy(false); endOperation(lease);
    }
  }, [api, beginOperation, client, endOperation, scope]);
  const dispatch = useCallback((ticket: Ticket) => {
    if (pendingRef.current || busy) return Promise.resolve(false);
    pendingRef.current = ticket; setRetryTicket(ticket);
    return run(ticket);
  }, [busy, run]);
  const reviewPolicy = useCallback((input: Omit<
    Parameters<PrivacyApi["reviewPolicy"]>[0], "requestId">) =>
    dispatch({kind: "policy", input: {...input, requestId: crypto.randomUUID()}}),
  [dispatch]);
  const restrict = useCallback((reason: string) => dispatch({kind: "restrict",
    input: {organizerId, reason, requestId: crypto.randomUUID()}}),
  [dispatch, organizerId]);
  const loadPreview = useCallback(async () => {
    if (pendingRef.current || busy) return;
    setPreviewBusy(true); setError("");
    try {
      const result = await api.preview(organizerId);
      setPreview(result);
    } catch (failure) {
      setPreview(null);
      setError(failure instanceof Error ? failure.message :
        "Inventory could not be reviewed. Try again.");
    } finally {setPreviewBusy(false);}
  }, [api, busy, organizerId]);
  const reviewPlan = useCallback(() => {
    if (!preview || preview.overflow) return Promise.resolve(false);
    return dispatch({kind: "review", input: {organizerId,
      requestId: crypto.randomUUID(),
      restrictionRevision: preview.restrictionRevision,
      expectedActivePlanId: preview.activePlanId,
      policyHash: preview.policyHash, inventoryHash: preview.inventoryHash}});
  }, [dispatch, organizerId, preview]);
  const applyBatch = useCallback(() => {
    const plan = caseQuery.data?.plan;
    if (!plan || plan.cursor >= plan.itemCount) return Promise.resolve(false);
    return dispatch({kind: "batch", input: {organizerId,
      planId: plan.planId, expectedCursor: plan.cursor,
      requestId: crypto.randomUUID()}});
  }, [caseQuery.data?.plan, dispatch, organizerId]);
  const retryPending = useCallback(() => pendingRef.current ?
    run(pendingRef.current) : Promise.resolve(false), [run]);
  const reviewCurrentPolicy = useCallback(async () => {
    const result = await caseQuery.refetch();
    if (!result.isSuccess || !result.data) return null;
    setPolicyConflict(false); setError("");
    return {revision: result.data.policy?.revision ?? 0};
  }, [caseQuery]);
  return {caseQuery, preview, previewBusy, busy, error, notice,
    policyConflict, confirmedPolicySaveId, reviewCurrentPolicy,
    pending: retryTicket, reviewPolicy, restrict, loadPreview, reviewPlan,
    applyBatch, retryPending};
}
