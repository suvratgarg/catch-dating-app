import {useRef, useState} from "react";
import {RotateCcw} from "lucide-react";
import {AdminButton, AdminForm, EmptyState, Panel, SelectField,
  StateRow, TextareaField, TextField} from
  "../../../shared/ui/AdminPrimitives";
import {dataMode} from "../../../shared/api/dataMode";
import type {SalesWorkspaceController} from
  "../controllers/useSalesWorkspaceController";
import type {SalesImportCompensationPreview} from "../api/salesTypes";

const id = /^[A-Za-z0-9][A-Za-z0-9._:-]{0,95}$/u;

function CompensationPanel({controller}: {controller: SalesWorkspaceController}) {
  const [importId, setImportId] = useState("");
  const [organizerId, setOrganizerId] = useState("");
  const [reason, setReason] = useState("");
  const [reviewed, setReviewed] = useState(false);
  const [plan, setPlan] = useState<SalesImportCompensationPreview | null>(null);
  const version = useRef(0);
  const busy = controller.isSaving;
  const clearPlan = () => {
    version.current += 1;
    setPlan(null);
    setReviewed(false);
  };
  const preview = async () => {
    clearPlan();
    const pending = version.current;
    const result = await controller.previewCompensation({importId, organizerId});
    if (result && pending === version.current) setPlan(result);
  };
  const apply = async () => {
    if (!plan || plan.mode === "blocked" || plan.blockers.length ||
      plan.alreadyCompensated || !reviewed || !reason.trim()) return;
    const saved = await controller.applyCompensation({importId, organizerId,
      previewHash: plan.previewHash, reason: reason.trim()});
    // A failed attempt may have committed remotely. Re-preview before retrying;
    // the controller retains the stable request ID for identical material.
    clearPlan();
    if (saved) setReason("");
  };
  return <Panel title="Correct a reviewed import" icon={<RotateCcw size={18} />}>
    <p>Admin Owner review only. Correct one imported organizer at a time. The
      original import receipt and source lineage stay in place.</p>
    {dataMode() === "sample" ? <EmptyState>Compensation requires a live Admin
      Owner workspace. No sample correction is applied.</EmptyState> : <>
      <TextField label="Applied import ID" value={importId} disabled={busy}
        onChange={(value) => {setImportId(value); clearPlan();}} />
      <TextField label="Canonical organizer ID" value={organizerId}
        disabled={busy}
        onChange={(value) => {setOrganizerId(value); clearPlan();}} />
      <AdminButton onClick={() => void preview()}
        disabled={busy || controller.compensationPreviewPending ||
          !id.test(importId) || !id.test(organizerId)}>
        Preview current correction</AdminButton>
      {plan ? <>
        <p role="status">Server plan: {plan.mode.replaceAll("_", " ")} ·
          account revision {plan.accountRevision ?? "unavailable"}</p>
        <p>Review hash: <code>{plan.previewHash}</code></p>
        {plan.mode === "archive_companion" ?
          <p>This archives the pristine private Sales companion and holds
            outreach. The canonical organizer and import evidence remain.</p> : null}
        {plan.mode === "remove_cohorts" ?
          <p>Only these import-owned cohorts will be removed:
            {plan.cohortIdsRemoved.join(", ")}. Later account content remains.</p> : null}
        {plan.alreadyCompensated ? <p>This import effect is already corrected.
          Refresh the Sales account for its current state.</p> : null}
        {plan.blockers.map((blocker) => <StateRow key={blocker}
          label="Correction blocked" value={blocker.replaceAll("_", " ")} />)}
        {plan.mode !== "blocked" && !plan.blockers.length &&
          !plan.alreadyCompensated ?
          <AdminForm onSubmit={(event) => {event.preventDefault(); void apply();}}>
            <TextareaField label="Reason for correction" rows={2} value={reason}
              disabled={busy} onChange={(value) => {
                setReason(value); setReviewed(false);
              }} />
            <SelectField label="Review decision" value={reviewed ? "yes" : "no"}
              disabled={busy}
              onChange={(value) => setReviewed(value === "yes")} options={[
                {value: "no", label: "Not reviewed"},
                {value: "yes", label: "I reviewed this exact server plan"},
              ]} />
            <AdminButton type="submit" variant="primary"
              disabled={busy || controller.compensationPreviewPending ||
                !reviewed || !reason.trim() ||
                reason.trim().length > 2000}>
              Apply reviewed correction</AdminButton>
          </AdminForm> : null}
      </> : null}
    </>}
  </Panel>;
}

/** Lower-case feature module API keeps this panel out of route registries. */
export function renderSalesImportCompensation(controller: SalesWorkspaceController) {
  return <CompensationPanel controller={controller} />;
}
