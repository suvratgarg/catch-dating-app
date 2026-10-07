import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useEffect, useLayoutEffect, useMemo, useRef, useState} from "react";
import {useAdminPendingOperationGuard} from "../../../shared/pendingOperation";
import type {DraftSourceRequest} from "../../../shared/domain/salesOutreach";
import {partnerOutreachApi} from "../api/partnerOutreachRepository";
import type {PartnerOutreachApi, PartnerGeneration, PartnerDraft, PartnerCopy,
  PartnerPreparation} from "../api/partnerOutreachTypes";

type Work = {kind: "generate" | "review" | "copy" | "record";
  requestId: string; run: () => Promise<unknown>};
const definitive = new Set(["aborted", "invalid-argument", "permission-denied", "unauthenticated",
  "failed-precondition", "already-exists", "resource-exhausted", "not-found"]);
const codeOf = (e: unknown) => e && typeof e === "object" && "code" in e ?
  String(e.code).replace(/^functions\//u, "") : "";

export function usePartnerOutreachController({actorUid, organizerId, assignmentRevision,
  accessExpiresAt, isCurrentSession, parentAccessCurrent = true, api = partnerOutreachApi}: {
  actorUid: string; organizerId: string; assignmentRevision: number; accessExpiresAt: string;
  isCurrentSession: () => boolean; parentAccessCurrent?: boolean; api?: PartnerOutreachApi;
}) {
  const client = useQueryClient();
  const {beginOperation, endOperation} = useAdminPendingOperationGuard();
  const scope = useMemo(() => ["partner-outreach", actorUid, organizerId, assignmentRevision] as const,
    [actorUid, organizerId, assignmentRevision]);
  const scopeToken = JSON.stringify(scope);
  const epoch = useRef(0);
  const pending = useRef<Work | null>(null);
  const [ticket, setTicket] = useState<Work | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [jobRequest, setJobRequest] = useState<{scope: string; requestId: string} | null>(null);
  const [selection, setSelection] = useState<{scope: string; draftId: string; contentHash: string} | null>(null);
  const payloadScope = {organizerId, expectedAssignmentRevision: assignmentRevision};
  const selected = selection?.scope === scopeToken ? selection : null;
  const request = jobRequest?.scope === scopeToken ? jobRequest : null;
  const preparation = useQuery({queryKey: [...scope, "preparation"],
    queryFn: () => api.preparation(payloadScope), enabled: parentAccessCurrent, retry: false, gcTime: 0, staleTime: 0});
  const job = useQuery({queryKey: [...scope, "job", request?.requestId], enabled: !!request && parentAccessCurrent,
    queryFn: () => api.job({...payloadScope, requestId: request!.requestId}),
    retry: false, gcTime: 0, staleTime: 0,
    refetchInterval: (q) => q.state.data?.status === "running" ? 5000 : false});
  const draft = useQuery({queryKey: [...scope, "draft", selected?.draftId], enabled: !!selected && parentAccessCurrent,
    queryFn: () => api.draft({...payloadScope, draftId: selected!.draftId}),
    retry: false, gcTime: 0, staleTime: 0});
  const mutation = useMutation({mutationFn: (work: Work) => work.run(), retry: false, gcTime: 0});
  const reads = useRef<{preparation: PartnerPreparation | null; draft: PartnerDraft | null;
    expiresAt: number; current: () => boolean}>({preparation: null, draft: null,
    expiresAt: 0, current: isCurrentSession});
  const prepared = preparation.isSuccess && !preparation.isFetching &&
    preparation.data.organizerId === organizerId && preparation.data.assignmentRevision === assignmentRevision ?
    preparation.data : null;
  const expiresAt = prepared ? Math.min(Date.parse(accessExpiresAt), Date.parse(prepared.evaluatedAt) + 60_000,
    ...prepared.clauses.map((c) => Date.parse(c.validUntil)),
    ...prepared.clauses.flatMap((c) => c.evidence.flatMap((e) => e.validThrough ? [Date.parse(e.validThrough)] : []))) : 0;
  const currentDraft = draft.isSuccess && !draft.isFetching && !job.isError && !job.isFetching && selected &&
    draft.data.draftId === selected.draftId && draft.data.draft.organizerId === organizerId &&
    draft.data.draft.contentHash === selected.contentHash ? draft.data : null;
  reads.current = {preparation: prepared, draft: currentDraft, expiresAt, current: () => parentAccessCurrent && isCurrentSession()};
  const readable = () => reads.current.current() && Date.now() < reads.current.expiresAt &&
    reads.current.preparation !== null;
  useLayoutEffect(() => {
    epoch.current += 1; pending.current = null; setTicket(null); setBusy(false);
    setError(null); setNotice(null); setSelection(null); setJobRequest(null);
    return () => {epoch.current += 1; pending.current = null;
      void client.cancelQueries({queryKey: scope}); client.removeQueries({queryKey: scope});};
  }, [client, scope]);
  useEffect(() => {
    if (!prepared || !parentAccessCurrent) return;
    const timer = window.setTimeout(() => {void client.invalidateQueries({queryKey: scope});},
      Math.max(0, Math.min(2_147_483_647, expiresAt - Date.now())));
    return () => window.clearTimeout(timer);
  }, [client, expiresAt, parentAccessCurrent, prepared, scope]);
  useEffect(() => {
    if (!job.isSuccess || job.isFetching || !request || !readable()) return;
    if (job.data.status === "completed" && job.data.result) {
      setSelection({scope: scopeToken, ...job.data.result});
      if (pending.current?.kind === "generate" && pending.current.requestId === request.requestId) {
        pending.current = null; setTicket(null); setError(null);
        setNotice("Draft recovered. Review its exact wording before copying.");
      }
    } else if (job.data.status === "failed") {
      pending.current = null; setTicket(null); setSelection(null);
      setError("Draft preparation stopped. Refresh the sources before preparing a new draft.");
    }
  }, [job.data, job.isSuccess, job.isFetching, request, scopeToken, prepared]);
  useEffect(() => {
    if (!job.isError || !definitive.has(codeOf(job.error)) || codeOf(job.error) === "not-found") return;
    pending.current = null; setTicket(null); setSelection(null);
    setError("Current draft access was rejected. Refresh the lead before continuing.");
  }, [job.isError, job.error]);
  const refresh = () => parentAccessCurrent && isCurrentSession() ?
    client.invalidateQueries({queryKey: scope}) : Promise.resolve();
  const run = async (work: Work): Promise<unknown | null> => {
    if (!readable() || (pending.current && pending.current !== work)) return null;
    const lease = beginOperation(); if (!lease) return null;
    const start = epoch.current;
    pending.current = work; setTicket(work); setBusy(true); setError(null); setNotice(null);
    try {
      const result = await mutation.mutateAsync(work);
      if (start !== epoch.current || !reads.current.current()) return null;
      if (work.kind === "generate") {
        const value = result as PartnerGeneration;
        setJobRequest({scope: scopeToken, requestId: work.requestId});
        if (value.status === "failed") throw Object.assign(new Error("Preparation stopped"), {code: "failed-precondition"});
        if (value.status === "completed") setSelection({scope: scopeToken, ...value.result});
        if (value.status === "running") {setNotice("Preparation is running. Check status or retry this exact request."); return result;}
      }
      pending.current = null; setTicket(null);
      setNotice(work.kind === "record" ? "Your manual-send attestation was recorded. No delivery confirmation is available." :
        work.kind === "copy" ? "Exact reviewed wording is ready for manual copying." :
          work.kind === "review" ? "Your composition review was recorded." : "Draft prepared for your review.");
      if (work.kind !== "copy") void refresh();
      return readable() ? result : null;
    } catch (failure) {
      if (start !== epoch.current || !reads.current.current()) return null;
      if (definitive.has(codeOf(failure))) {
        pending.current = null; setTicket(null); setSelection(null); void refresh();
        setError("The action was rejected. Refresh current access and sources before trying again.");
      } else {
        setError("The action was not confirmed. Retry the unchanged request to recover it.");
        if (work.kind === "generate") setJobRequest({scope: scopeToken, requestId: work.requestId});
      }
      return null;
    } finally {if (start === epoch.current) {setBusy(false); mutation.reset();} endOperation(lease);}
  };
  const submit = (kind: Work["kind"], invoke: (requestId: string) => Promise<unknown>) => {
    if (pending.current) return Promise.resolve(null);
    const requestId = crypto.randomUUID();
    return run({kind, requestId, run: () => invoke(requestId)});
  };
  const generate = (sourceRequest: DraftSourceRequest) => {
    const source = structuredClone(sourceRequest);
    if (!readable() || source.organizerId !== organizerId) return Promise.resolve(null);
    return submit("generate", (requestId) => api.generate({requestId, expectedAssignmentRevision: assignmentRevision,
      sourceRequest: source}));
  };
  const review = () => {
    const value = reads.current.draft;
    if (!readable() || value?.status !== "pending_review") return Promise.resolve(null);
    const frozen = {...payloadScope, draftId: value.draftId, expectedContentHash: value.draft.contentHash,
      factualValidity: "verified" as const, tone: "approved" as const, channelReadiness: "manual_copy_only" as const};
    return submit("review", (requestId) => api.review({...frozen, requestId}));
  };
  const copy = async (): Promise<PartnerCopy | null> => {
    const value = reads.current.draft;
    if (!readable() || value?.status !== "approved") return null;
    const frozen = {...payloadScope, draftId: value.draftId, expectedContentHash: value.draft.contentHash};
    const start = epoch.current;
    const result = await submit("copy", (requestId) => api.copy({...frozen, requestId})) as PartnerCopy | null;
    return start === epoch.current && readable() && reads.current.draft?.draft.contentHash === frozen.expectedContentHash &&
      result?.text === value.draft.text && result.subject === value.draft.subject ? result : null;
  };
  const record = (channel: "email" | "whatsapp" | "other", occurredAt: string) => {
    const value = reads.current.draft;
    if (!readable() || value?.status !== "approved") return Promise.resolve(null);
    const frozen = {...payloadScope, draftId: value.draftId, expectedContentHash: value.draft.contentHash,
      channel, occurredAt, attestation: "i_manually_sent_this_reviewed_draft" as const};
    return submit("record", (requestId) => api.record({...frozen, requestId}));
  };
  return {preparation, job, draft, prepared: readable() ? prepared : null,
    currentDraft: readable() ? currentDraft : null, busy, error, notice, ticket,
    refresh, generate, review, copy, record, retry: () => pending.current ? run(pending.current) : Promise.resolve(null)};
}
