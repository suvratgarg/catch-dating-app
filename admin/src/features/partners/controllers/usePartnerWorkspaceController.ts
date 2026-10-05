import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useEffect, useLayoutEffect, useRef, useState} from "react";
import {useAdminPendingOperationGuard} from "../../../shared/pendingOperation";
import {readPartnerWorkspace, writePartner} from "../api/partnerRepository";

export function usePartnerWorkspaceController({actorUid, isCurrentSession}: {actorUid: string; isCurrentSession: () => boolean}) {
  const epoch = useRef(0);
  const session = useRef(isCurrentSession); session.current = isCurrentSession;
  const [cursor, setCursor] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const unresolved = useRef<{key: string; action: "register" | "nominate" | "decide" | "update";
    material: Record<string, unknown>; requestId: string} | null>(null);
  const [needsRetry, setNeedsRetry] = useState(false);
  const queryClient = useQueryClient();
  const {beginOperation, endOperation} = useAdminPendingOperationGuard();
  const workspace = useQuery({queryKey: ["partner-workspace", actorUid, cursor],
    queryFn: () => readPartnerWorkspace(cursor, actorUid), retry: false, gcTime: 0, staleTime: 0});
  const expiresAt = workspace.data ? Math.min(Date.parse(workspace.data.membership.expiresAt),
    workspace.dataUpdatedAt + 60_000, ...workspace.data.leads.map((lead) => Date.parse(lead.assignment.expiresAt))) : 0;
  const data = workspace.isSuccess && !workspace.isFetching && session.current() &&
    workspace.data.membership.uid === actorUid && Date.now() < expiresAt ? workspace.data : undefined;
  useLayoutEffect(() => {
    epoch.current += 1; unresolved.current = null; setNeedsRetry(false); setError(null); setNotice(null); setCursor(null);
    return () => {epoch.current += 1; unresolved.current = null;
      void queryClient.cancelQueries({queryKey: ["partner-workspace", actorUid]});
      queryClient.removeQueries({queryKey: ["partner-workspace", actorUid]});};
  }, [actorUid, queryClient]);
  useEffect(() => {
    if (!workspace.isSuccess || workspace.isFetching) return;
    const timer = window.setTimeout(() => {void queryClient.invalidateQueries({queryKey: ["partner-workspace", actorUid]});},
      Math.max(0, Math.min(2_147_483_647, expiresAt - Date.now())));
    return () => window.clearTimeout(timer);
  }, [actorUid, expiresAt, queryClient, workspace.isSuccess, workspace.isFetching]);
  const mutation = useMutation({mutationFn: ({action, payload}: {
    action: "register" | "nominate" | "decide" | "update"; payload: Record<string, unknown>}) =>
    writePartner(action, payload), retry: false, gcTime: 0});
  const save = async (action: "register" | "nominate" | "decide" | "update", material: Record<string, unknown>) => {
    if (!session.current()) return false;
    const start = epoch.current;
    if (action !== "register" && !data) {
      setError("Refresh current partner access before saving."); return false;
    }
    const key = JSON.stringify({action, material});
    if (unresolved.current && unresolved.current.key !== key) {
      setError("Resolve the interrupted save with an exact retry before submitting different work."); return false;
    }
    const token = beginOperation();
    if (!token) return false;
    const requestId = unresolved.current?.requestId ?? crypto.randomUUID();
    unresolved.current = {key, action, material: structuredClone(material), requestId};
    setError(null); setNotice(null);
    try {
      await mutation.mutateAsync({action, payload: {...material, requestId}});
      if (start !== epoch.current || !session.current()) return false;
      unresolved.current = null; setNeedsRetry(false);
      await queryClient.invalidateQueries({queryKey: ["partner-workspace", actorUid]});
      if (start !== epoch.current || !session.current()) return false;
      setNotice(action === "nominate" ? "Nomination saved for identity review." : "Your review was saved.");
      return true;
    } catch (e) {
      if (start !== epoch.current || !session.current()) return false;
      const code = e && typeof e === "object" && "code" in e ? String(e.code) : "";
      const definitive = ["functions/invalid-argument", "functions/permission-denied",
        "functions/failed-precondition", "functions/aborted", "functions/already-exists"].includes(code);
      if (definitive) unresolved.current = null;
      setNeedsRetry(!definitive);
      setError(e instanceof Error ? e.message : "Unable to save. Your edits are still here.");
      return false;
    } finally {if (start === epoch.current) mutation.reset(); endOperation(token);}
  };
  const retry = async () => {
    const work = unresolved.current;
    return work ? save(work.action, work.material) : false;
  };
  return {workspace, data, save, retry, needsRetry, error, notice, cursor, setCursor};
}
