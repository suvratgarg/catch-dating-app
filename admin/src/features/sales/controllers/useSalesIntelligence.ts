import {useQuery, useQueryClient} from "@tanstack/react-query";
import {useCallback, useEffect, useMemo, useRef, useState} from "react";
import {useAdminPendingOperationGuard} from "../../../shared/pendingOperation";
import {salesIntelligenceApi} from "../api/salesIntelligenceRepository";
import type {ApprovedClause, DraftSourceRequest, FactorAssessment,
  IntelligenceApi} from "../api/salesIntelligenceTypes";

type Pending = {label: string; kind: "generate" | "mutation";
  requestId: string; run: () => Promise<unknown>;
  accept: (result: never) => void};
const definitiveCodes = new Set(["aborted", "invalid-argument",
  "permission-denied", "unauthenticated", "failed-precondition",
  "already-exists", "not-found", "resource-exhausted"]);
function codeOf(error: unknown): string {
  return error && typeof error === "object" && "code" in error ?
    String(error.code).replace(/^functions\//u, "") : "";
}

export function useSalesIntelligence({actorUid, organizerId,
  api = salesIntelligenceApi}: {actorUid: string; organizerId: string;
    api?: IntelligenceApi}) {
  const client = useQueryClient();
  const {beginOperation, endOperation} = useAdminPendingOperationGuard();
  const scope = useMemo(() => ["sales-intelligence", actorUid, organizerId] as const,
    [actorUid, organizerId]);
  const [selectedDraftId, setSelectedDraftId] = useState<string | null>(null);
  const [jobRequestId, setJobRequestId] = useState<string | null>(null);
  const [contactCursor, setContactCursor] = useState<string | undefined>();
  const [evidenceCursor, setEvidenceCursor] = useState<string | undefined>();
  const [contactHistory, setContactHistory] = useState<Array<string | undefined>>([]);
  const [evidenceHistory, setEvidenceHistory] = useState<Array<string | undefined>>([]);
  const [retryTicket, setRetryTicket] = useState<Pending | null>(null);
  const pendingRef = useRef<Pending | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  useEffect(() => () => {
    client.removeQueries({queryKey: scope});
  }, [client, scope]);
  const catalog = useQuery({queryKey: [...scope, "catalog"],
    queryFn: () => api.catalog(organizerId), retry: false});
  const score = useQuery({queryKey: [...scope, "score"],
    queryFn: () => api.score(organizerId), retry: false});
  const account = useQuery({queryKey: [...scope, "account"],
    queryFn: () => api.account(organizerId), retry: false});
  const contacts = useQuery({queryKey: [...scope, "contacts", contactCursor],
    queryFn: () => api.contacts(organizerId, contactCursor), retry: false});
  const evidence = useQuery({queryKey: [...scope, "evidence", evidenceCursor],
    queryFn: () => api.evidence(organizerId, evidenceCursor), retry: false});
  const drafts = useQuery({queryKey: [...scope, "drafts"],
    queryFn: () => api.drafts(organizerId), retry: false});
  const draft = useQuery({queryKey: [...scope, "draft", selectedDraftId],
    queryFn: () => api.draft(selectedDraftId!),
    enabled: Boolean(selectedDraftId), retry: false});
  const job = useQuery({queryKey: [...scope, "job", jobRequestId],
    queryFn: () => api.job(jobRequestId!), enabled: Boolean(jobRequestId),
    retry: false, refetchInterval: (query) =>
      query.state.data?.status === "running" ? 5000 : false});

  useEffect(() => {
    if (job.data?.status !== "completed" || !job.data.result) return;
    setSelectedDraftId(job.data.result.draftId);
    if (pendingRef.current?.kind === "generate" &&
        pendingRef.current.requestId === jobRequestId) {
      pendingRef.current = null; setRetryTicket(null);
      setNotice("Draft prepared for factual review."); setError("");
      void client.invalidateQueries({queryKey: [...scope, "drafts"]});
    }
  }, [client, job.data, jobRequestId, scope]);
  useEffect(() => {
    if (codeOf(job.error) === "not-found") {
      setError("No confirmed draft job yet. Retry the unchanged request.");
      return;
    }
    if (!job.isError || !definitiveCodes.has(codeOf(job.error))) return;
    if (pendingRef.current?.kind === "generate" &&
        pendingRef.current.requestId === jobRequestId) {
      pendingRef.current = null; setRetryTicket(null);
      setError("Draft preparation was rejected. Refresh the current source before retrying.");
    }
  }, [job.error, job.isError, jobRequestId]);

  const refresh = useCallback(async () => {
    await client.invalidateQueries({queryKey: scope});
  }, [client, scope]);
  const run = useCallback(async <T,>(operation: Pending): Promise<T | null> => {
    if (busy || (pendingRef.current && pendingRef.current !== operation)) return null;
    const lease = beginOperation();
    if (!lease) return null;
    pendingRef.current = operation; setRetryTicket(operation);
    setBusy(true); setError(""); setNotice("");
    try {
      const result = await operation.run() as T;
      if (operation.kind === "generate" &&
          (result as {status?: string}).status === "failed") {
        throw Object.assign(new Error("Draft preparation failed."),
          {code: "functions/failed-precondition"});
      }
      operation.accept(result as never);
      if (operation.kind !== "generate" ||
          (result as {status?: string}).status !== "running") {
        pendingRef.current = null; setRetryTicket(null);
      }
      setNotice(operation.kind === "generate" ?
        (result as {status?: string}).status === "running" ?
          "Draft is being prepared. Check its status or retry this request." :
          "Draft prepared for factual review." : `${operation.label} confirmed.`);
      void refresh().catch(() => {
        setError("The change was confirmed, but the latest view could not refresh.");
      });
      return result;
    } catch (failure) {
      if (definitiveCodes.has(codeOf(failure))) {
        pendingRef.current = null; setRetryTicket(null);
        void refresh();
        setError(`${operation.label} was rejected. Review current source before trying again.`);
      } else {
        setError(`${operation.label} was not confirmed. Check status or retry the unchanged request.`);
        if (operation.kind === "generate") setJobRequestId(operation.requestId);
      }
      return null;
    } finally {
      setBusy(false); endOperation(lease);
    }
  }, [beginOperation, busy, endOperation, refresh]);
  const submit = useCallback(<T,>(operation: Pending): Promise<T | null> => {
    if (pendingRef.current) return Promise.resolve(null);
    return run<T>(operation);
  }, [run]);
  const retry = useCallback(() => pendingRef.current ?
    run(pendingRef.current) : Promise.resolve(null), [run]);

  const assess = useCallback((input: {factorId: string;
    expectedRevision: number; state: FactorAssessment["state"];
    value: number | null; evidenceIds: string[]; reason: string | null}) => {
    const frozen = structuredClone({...input, organizerId,
      requestId: crypto.randomUUID()});
    return submit({label: "Factor review", kind: "mutation",
      requestId: frozen.requestId,
      run: () => api.assess(frozen), accept: () => {}});
  }, [api, organizerId, submit]);
  const saveClause = useCallback((input: {kind: ApprovedClause["kind"];
    text: string; evidenceIds: string[]; validUntil: string}) => {
    const frozen = structuredClone({...input, organizerId,
      clauseId: `clause_${crypto.randomUUID().replaceAll("-", "")}`,
      expectedRevision: 0, requestId: crypto.randomUUID(),
      permission: input.kind === "reference" ?
        "private_mention" as const : "not_required" as const});
    return submit({label: "Reviewed wording", kind: "mutation",
      requestId: frozen.requestId, run: () => api.saveClause(frozen),
      accept: () => {}});
  }, [api, organizerId, submit]);
  const reviewClause = useCallback((clauseId: string,
    expectedRevision: number, decision: "approve" | "withdraw") => {
    const frozen = {requestId: crypto.randomUUID(), clauseId,
      expectedRevision, decision};
    return submit({label: decision === "approve" ?
      "Wording approval" : "Wording withdrawal", kind: "mutation",
    requestId: frozen.requestId, run: () => api.reviewClause(frozen),
    accept: () => {}});
  }, [api, submit]);
  const generate = useCallback((sourceRequest: DraftSourceRequest) => {
    const frozen = structuredClone({requestId: crypto.randomUUID(), sourceRequest});
    return submit({label: "Draft preparation", kind: "generate",
      requestId: frozen.requestId, run: () => api.generate(frozen),
      accept: (result) => {
        const response = result as Awaited<ReturnType<IntelligenceApi["generate"]>>;
        setJobRequestId(frozen.requestId);
        if (response.status === "completed" && response.result) {
          setSelectedDraftId(response.result.draftId);
        }
      }});
  }, [api, submit]);
  const review = useCallback((draftId: string, expectedContentHash: string) => {
    const frozen = {requestId: crypto.randomUUID(), draftId,
      expectedContentHash, factualValidity: "verified" as const,
      tone: "approved" as const, channelReadiness: "manual_copy_only" as const};
    return submit({label: "Draft review", kind: "mutation",
      requestId: frozen.requestId,
      run: () => api.review(frozen), accept: () => {}});
  }, [api, submit]);
  const copy = useCallback((draftId: string, expectedContentHash: string) => {
    const frozen = {requestId: crypto.randomUUID(), draftId,
      expectedContentHash};
    return submit<Awaited<ReturnType<IntelligenceApi["copy"]>>>(
      {label: "Manual copy", kind: "mutation", requestId: frozen.requestId,
        run: () => api.copy(frozen), accept: () => {}});
  }, [api, submit]);
  const nextContactPage = useCallback((cursor: string) => {
    setContactHistory((old) => [...old, contactCursor]); setContactCursor(cursor);
  }, [contactCursor]);
  const previousContactPage = useCallback(() => {
    setContactCursor(contactHistory.at(-1));
    setContactHistory(contactHistory.slice(0, -1));
  }, [contactHistory]);
  const nextEvidencePage = useCallback((cursor: string) => {
    setEvidenceHistory((old) => [...old, evidenceCursor]); setEvidenceCursor(cursor);
  }, [evidenceCursor]);
  const previousEvidencePage = useCallback(() => {
    setEvidenceCursor(evidenceHistory.at(-1));
    setEvidenceHistory(evidenceHistory.slice(0, -1));
  }, [evidenceHistory]);
  return {catalog, score, account, contacts, evidence, drafts, draft, job,
    selectedDraftId, setSelectedDraftId, jobRequestId,
    pending: retryTicket, busy, error,
    notice, retry, refresh, assess, saveClause, reviewClause, generate,
    review, copy,
    contactHistory, evidenceHistory, nextContactPage, previousContactPage,
    nextEvidencePage, previousEvidencePage};
}
