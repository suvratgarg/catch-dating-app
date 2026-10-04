import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useRef, useState} from "react";
import {useAdminPendingOperationGuard} from "../../../shared/pendingOperation";
import {readPartnerWorkspace, writePartner} from "../api/partnerRepository";

export function usePartnerWorkspaceController() {
  const [cursor, setCursor] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const unresolved = useRef<{key: string; action: "register" | "nominate" | "decide" | "update";
    material: Record<string, unknown>; requestId: string} | null>(null);
  const [needsRetry, setNeedsRetry] = useState(false);
  const queryClient = useQueryClient();
  const {beginOperation, endOperation} = useAdminPendingOperationGuard();
  const workspace = useQuery({queryKey: ["partner-workspace", cursor],
    queryFn: () => readPartnerWorkspace(cursor), retry: false, staleTime: 0});
  const mutation = useMutation({mutationFn: ({action, payload}: {
    action: "register" | "nominate" | "decide" | "update"; payload: Record<string, unknown>}) =>
    writePartner(action, payload)});
  const save = async (action: "register" | "nominate" | "decide" | "update", material: Record<string, unknown>) => {
    if (action !== "register" && (workspace.isError || workspace.isFetching || !workspace.data)) {
      setError("Refresh current partner access before saving."); return false;
    }
    const key = JSON.stringify({action, material});
    if (unresolved.current && unresolved.current.key !== key) {
      setError("Resolve the interrupted save with an exact retry before submitting different work."); return false;
    }
    const token = beginOperation();
    if (!token) return false;
    const requestId = unresolved.current?.requestId ?? crypto.randomUUID();
    unresolved.current = {key, action, material: {...material}, requestId};
    setError(null); setNotice(null);
    try {
      await mutation.mutateAsync({action, payload: {...material, requestId}});
      unresolved.current = null; setNeedsRetry(false);
      await queryClient.invalidateQueries({queryKey: ["partner-workspace"]});
      setNotice(action === "nominate" ? "Nomination saved for identity review." : "Your review was saved.");
      return true;
    } catch (e) {
      const code = e && typeof e === "object" && "code" in e ? String(e.code) : "";
      const definitive = ["functions/invalid-argument", "functions/permission-denied",
        "functions/failed-precondition", "functions/aborted", "functions/already-exists"].includes(code);
      if (definitive) unresolved.current = null;
      setNeedsRetry(!definitive);
      setError(e instanceof Error ? e.message : "Unable to save. Your edits are still here.");
      return false;
    } finally {endOperation(token);}
  };
  const retry = async () => {
    const work = unresolved.current;
    return work ? save(work.action, work.material) : false;
  };
  return {workspace, save, retry, needsRetry, error, notice, cursor, setCursor};
}
