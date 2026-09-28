import {useQuery, useQueryClient} from "@tanstack/react-query";
import {useCallback, useEffect, useMemo, useRef, useState} from "react";
import {useAdminPendingOperationGuard} from "../../../shared/pendingOperation";
import {salesDemoManagementApi, type DemoBlueprint, type DemoIssueResult,
  type DemoManagementApi, type DemoSaveInput} from
  "../api/salesDemoManagement";

type Pending = {label: string; run: () => Promise<unknown>;
  accept: (result: never) => void};

export function useSalesDemoManagementController({isAdminOwner, actorUid, organizerId,
  api = salesDemoManagementApi}: {
  isAdminOwner: boolean; actorUid: string; organizerId: string;
  api?: DemoManagementApi;
}) {
  const queryClient = useQueryClient();
  const {beginOperation, endOperation} = useAdminPendingOperationGuard();
  const [blueprintId, setBlueprintId] = useState<string | null>(null);
  const [blueprintExists, setBlueprintExists] = useState(false);
  const [invitationId, setInvitationId] = useState<string | null>(null);
  const [issuedGrant, setIssuedGrant] = useState<DemoIssueResult | null>(null);
  const [confirmedSave, setConfirmedSave] = useState<{
    blueprintId: string; revision: number} | null>(null);
  const [retryTicket, setRetryTicket] = useState<Pending | null>(null);
  const pendingRef = useRef<Pending | null>(null);
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState("");
  const [error, setError] = useState("");
  const [blueprintCursor, setBlueprintCursor] = useState<string | undefined>();
  const [invitationCursor, setInvitationCursor] = useState<string | undefined>();
  const [blueprintHistory, setBlueprintHistory] = useState<Array<string | undefined>>([]);
  const [invitationHistory, setInvitationHistory] = useState<Array<string | undefined>>([]);
  const scope = useMemo(() => ["sales-demo", actorUid, organizerId] as const,
    [actorUid, organizerId]);
  useEffect(() => () => {
    queryClient.removeQueries({queryKey: scope});
  }, [queryClient, scope]);

  const capability = useQuery({queryKey: [...scope, "capability"],
    queryFn: api.capability, enabled: isAdminOwner, retry: false});
  const blueprintList = useQuery({queryKey: [...scope, "blueprints", blueprintCursor],
    queryFn: () => api.listBlueprints({organizerId, cursor: blueprintCursor,
      limit: 20}), enabled: isAdminOwner, retry: false});
  const blueprint = useQuery({queryKey: [...scope, "blueprint", blueprintId],
    queryFn: () => api.getBlueprint(blueprintId!),
    enabled: isAdminOwner && blueprintExists && Boolean(blueprintId), retry: false});
  const invitationList = useQuery({queryKey: [...scope, "invitations",
    blueprintId, invitationCursor],
  queryFn: () => api.listInvitations({blueprintId: blueprintId!,
    cursor: invitationCursor, limit: 20}),
  enabled: isAdminOwner && Boolean(blueprintId) && blueprintExists,
  retry: false});
  const invitation = useQuery({queryKey: [...scope, "invitation", invitationId],
    queryFn: () => api.getInvitation(invitationId!),
    enabled: isAdminOwner && Boolean(invitationId), retry: false});

  const loadBlueprint = useCallback((id: string) => {
    if (pendingRef.current) return;
    setBlueprintId(id); setBlueprintExists(true); setInvitationId(null);
    setInvitationCursor(undefined); setInvitationHistory([]);
    setIssuedGrant(null); setError(""); setNotice("");
    setConfirmedSave(null);
  }, []);
  const newBlueprint = useCallback(() => {
    if (pendingRef.current) return;
    const id = `demo_${crypto.randomUUID().replaceAll("-", "")}`;
    setBlueprintId(id); setBlueprintExists(false); setInvitationId(null);
    setInvitationCursor(undefined); setInvitationHistory([]);
    setIssuedGrant(null); setError(""); setNotice("");
    setConfirmedSave(null);
  }, []);
  const loadInvitation = useCallback((id: string) => {
    if (pendingRef.current) return;
    setInvitationId(id); setIssuedGrant(null); setError("");
  }, []);
  const nextBlueprintPage = useCallback((cursor: string) => {
    setBlueprintHistory((history) => [...history, blueprintCursor]);
    setBlueprintCursor(cursor);
  }, [blueprintCursor]);
  const previousBlueprintPage = useCallback(() => {
    if (!blueprintHistory.length) return;
    setBlueprintCursor(blueprintHistory.at(-1));
    setBlueprintHistory(blueprintHistory.slice(0, -1));
  }, [blueprintHistory]);
  const firstBlueprintPage = useCallback(() => {
    setBlueprintHistory([]); setBlueprintCursor(undefined);
  }, []);
  const nextInvitationPage = useCallback((cursor: string) => {
    setInvitationHistory((history) => [...history, invitationCursor]);
    setInvitationCursor(cursor);
  }, [invitationCursor]);
  const previousInvitationPage = useCallback(() => {
    if (!invitationHistory.length) return;
    setInvitationCursor(invitationHistory.at(-1));
    setInvitationHistory(invitationHistory.slice(0, -1));
  }, [invitationHistory]);
  const firstInvitationPage = useCallback(() => {
    setInvitationHistory([]); setInvitationCursor(undefined);
  }, []);

  const run = useCallback(async (operation: Pending) => {
    if (!isAdminOwner || busy) return false;
    const lease = beginOperation();
    if (!lease) return false;
    pendingRef.current = operation;
    setRetryTicket(operation); setBusy(true); setError(""); setNotice("");
    try {
      const result = await operation.run();
      operation.accept(result as never);
      pendingRef.current = null; setRetryTicket(null);
      setNotice(`${operation.label} confirmed.`);
      void queryClient.invalidateQueries({queryKey: scope}).catch(() => {
        setError("Saved, but the latest view could not refresh. Refresh to review it.");
      });
      return true;
    } catch (failure) {
      const code = failure && typeof failure === "object" &&
        "code" in failure ? String(failure.code).replace(/^functions\//u, "") : "";
      const definitive = ["aborted", "invalid-argument", "permission-denied",
        "unauthenticated", "failed-precondition", "already-exists",
        "not-found", "resource-exhausted"].includes(code);
      if (definitive) {
        pendingRef.current = null; setRetryTicket(null);
        void queryClient.invalidateQueries({queryKey: scope});
      }
      // Keep the original request ID and frozen material for an exact retry.
      setError(definitive ?
        `${operation.label} was rejected. Review the latest state before trying again.` :
        `${operation.label} was not confirmed. Retry the same request.`);
      return false;
    } finally {
      setBusy(false); endOperation(lease);
    }
  }, [beginOperation, busy, endOperation, isAdminOwner, queryClient, scope]);

  const submit = useCallback((operation: Pending) => {
    if (pendingRef.current) return Promise.resolve(false);
    return run(operation);
  }, [run]);
  const retry = useCallback(() => {
    const original = pendingRef.current;
    return original ? run(original) : Promise.resolve(false);
  }, [run]);

  const save = useCallback((input: Omit<DemoSaveInput, "requestId">) => {
    const frozen: DemoSaveInput = structuredClone({...input,
      requestId: crypto.randomUUID()});
    return submit({label: "Blueprint save",
      run: () => api.saveBlueprint(frozen),
      accept: (result) => {
        const saved = result as Pick<DemoBlueprint,
          "blueprintId" | "revision">;
        setConfirmedSave({blueprintId: saved.blueprintId,
          revision: saved.revision});
        setBlueprintExists(true);
      }});
  }, [api, submit]);
  const change = useCallback((kind: "review" | "withdraw",
    id: string, expectedRevision: number) => {
    const input = {blueprintId: id, expectedRevision,
      requestId: crypto.randomUUID()};
    return submit({label: kind === "review" ? "Blueprint review" :
      "Blueprint withdrawal",
    run: () => kind === "review" ? api.reviewBlueprint(input) :
      api.withdrawBlueprint(input), accept: () => {}});
  }, [api, submit]);
  const issue = useCallback((input: Omit<Parameters<DemoManagementApi[
    "issueInvitation"]>[0], "requestId">) => {
    const frozen = structuredClone({...input, requestId: crypto.randomUUID()});
    return submit({label: "Invitation issue",
      run: () => api.issueInvitation(frozen),
      accept: (result) => {
        const issued = result as DemoIssueResult;
        setIssuedGrant(issued); setInvitationId(issued.invitationId);
      }});
  }, [api, submit]);
  const revoke = useCallback((id: string, expectedRevision: number) => {
    const input = {invitationId: id, expectedRevision,
      requestId: crypto.randomUUID()};
    return submit({label: "Invitation revoke",
      run: () => api.revokeInvitation(input),
      accept: () => setIssuedGrant(null)});
  }, [api, submit]);

  return {capability, blueprintList, blueprint, invitationList, invitation,
    blueprintCursor, blueprintHistory, invitationCursor,
    invitationHistory, nextBlueprintPage, previousBlueprintPage,
    firstBlueprintPage, nextInvitationPage, previousInvitationPage,
    firstInvitationPage,
    blueprintId, blueprintExists,
    invitationId, issuedGrant, confirmedSave,
    pending: retryTicket, busy, notice, error,
    newBlueprint, loadBlueprint, loadInvitation, save, change, issue, revoke,
    retry};
}
