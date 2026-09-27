import {useState} from "react";
import {ClipboardList} from "lucide-react";
import {AdminButton, AdminForm, EmptyState, Panel, SelectField, StateRow,
  TextareaField, TextField} from "../../../shared/ui/AdminPrimitives";
import {toLocalDateTimeInput, type SalesWorkspaceController} from
  "../controllers/useSalesWorkspaceController";
import type {SalesAccountDetail, SalesContact, SalesEvidence} from "../api/salesTypes";

function PageControls({previous, next, onPrevious, onNext}: {
  previous: boolean; next: boolean; onPrevious: () => void; onNext: () => void;
}) {
  return <p><AdminButton disabled={!previous} onClick={onPrevious}>Previous</AdminButton>{" "}
    <AdminButton disabled={!next} onClick={onNext}>Next</AdminButton></p>;
}

function SalesPeoplePanel({detail, controller}: {
  detail: SalesAccountDetail; controller: SalesWorkspaceController;
}) {
  const organizerId = detail.account.organizerId;
  const [name, setName] = useState("");
  const [role, setRole] = useState("");
  const [influence, setInfluence] = useState<SalesContact["relationship"]["decisionInfluence"]>("unknown");
  const [primary, setPrimary] = useState("false");
  const [endpointKind, setEndpointKind] = useState<"email" | "phone">("email");
  const [endpointValue, setEndpointValue] = useState("");
  const [selectedContact, setSelectedContact] = useState("");
  const [status, setStatus] = useState<SalesContact["relationship"]["contactabilityStatus"]>("unknown");
  const [reason, setReason] = useState("");
  const [evidenceId, setEvidenceId] = useState("");
  const contacts = controller.contacts.data?.rows ?? [];
  const selected = contacts.find((item) => item.contactId === selectedContact);
  const matchingEvidence = (controller.evidence.data?.rows ?? []).filter(
    (item) => item.contactId === selectedContact);
  const create = async () => {
    if (!name.trim() || !role.trim()) return;
    const saved = await controller.saveContact({organizerId, expectedRevision: 0,
      contact: {displayName: name.trim()}, relationship: {
        role: role.trim(), decisionInfluence: influence, primary: primary === "true",
        ...(endpointValue.trim() ? {endpoints: [{kind: endpointKind,
          value: endpointValue.trim(), verificationStatus: "unverified" as const}]} : {}),
      }});
    if (saved) {setName(""); setRole(""); setInfluence("unknown"); setPrimary("false");
      setEndpointValue("");}
  };
  const review = async () => {
    if (!selected || !reason.trim() || (status === "draft_reviewed" && !evidenceId)) return;
    const saved = await controller.saveContactability({organizerId,
      contactId: selected.contactId, expectedRevision: selected.relationship.revision,
      status, reason: reason.trim(), evidenceId: status === "draft_reviewed" ? evidenceId :
        undefined});
    if (saved) {setReason(""); setEvidenceId("");}
  };
  return <Panel title="People" icon={<ClipboardList size={18} />}>
    <p>Private contact relationships. A review for drafting never authorizes sending.</p>
    {controller.contacts.isPending ? <EmptyState>Loading contacts…</EmptyState> :
      controller.contacts.error ? <EmptyState>Contacts could not be loaded. <AdminButton
        onClick={() => void controller.contacts.refetch()}>Try again</AdminButton></EmptyState> :
        contacts.length ? contacts.map((contact) => <StateRow key={contact.contactId}
          label={contact.displayName} value={<>{contact.relationship.role} ·
            {contact.relationship.decisionInfluence.replaceAll("_", " ")} ·
            {contact.relationship.contactabilityStatus.replaceAll("_", " ")}
            {contact.relationship.primary ? " · Primary" : ""}
            {contact.relationship.endpoints?.map((endpoint) =>
              ` · ${endpoint.kind}: ${endpoint.value} (${endpoint.verificationStatus})`)
              .join("") ?? ""}</>} />) :
          <EmptyState>No contacts recorded for this host.</EmptyState>}
    <PageControls previous={controller.hasPreviousContactPage}
      next={Boolean(controller.contacts.data?.nextCursor)}
      onPrevious={controller.previousContactPage} onNext={controller.nextContactPage} />
    <AdminForm onSubmit={(event) => {event.preventDefault(); void create();}}>
      <h3>Add contact relationship</h3>
      <TextField label="Name" value={name} onChange={setName} required />
      <TextField label="Role with host" value={role} onChange={setRole} required />
      <SelectField label="Decision influence" value={influence}
        onChange={(value) => setInfluence(value as typeof influence)} options={[
          {value: "unknown", label: "Unknown"},
          {value: "decision_maker", label: "Decision maker"},
          {value: "influencer", label: "Influencer"},
          {value: "operator", label: "Operator"},
        ]} />
      <SelectField label="Primary contact" value={primary} onChange={setPrimary}
        options={[{value: "false", label: "No"}, {value: "true", label: "Yes"}]} />
      <SelectField label="Optional endpoint type" value={endpointKind}
        onChange={(value) => setEndpointKind(value as typeof endpointKind)} options={[
          {value: "email", label: "Email"}, {value: "phone", label: "Phone"},
        ]} />
      <TextField label="Optional endpoint (unverified)" value={endpointValue}
        onChange={setEndpointValue} type={endpointKind === "email" ? "email" : "text"} />
      <p>Adding an endpoint does not verify contact identity or authorize messages.</p>
      <AdminButton type="submit" disabled={!name.trim() || !role.trim() ||
        controller.isSaving}>Add contact</AdminButton>
    </AdminForm>
    {contacts.length ? <AdminForm onSubmit={(event) => {event.preventDefault(); void review();}}>
      <h3>Contact restriction or draft review</h3>
      <SelectField label="Contact on this page" value={selectedContact}
        onChange={(value) => {setSelectedContact(value); setEvidenceId("");}}
        options={[{value: "", label: "Choose contact"}, ...contacts.map((item) => ({
          value: item.contactId, label: item.displayName,
        }))]} />
      {selected ? <StateRow label="Current status" value={
        selected.relationship.contactabilityStatus.replaceAll("_", " ")} /> : null}
      <SelectField label="New status" value={status}
        onChange={(value) => setStatus(value as typeof status)} options={[
          {value: "unknown", label: "Unknown"},
          {value: "draft_reviewed", label: "Reviewed for draft consideration"},
          {value: "held", label: "Hold"},
          {value: "suppressed", label: "Suppress"},
        ]} />
      {status === "draft_reviewed" ? <SelectField label="Reviewed contact evidence on this page"
        value={evidenceId} onChange={setEvidenceId} options={[
          {value: "", label: "Choose evidence"}, ...matchingEvidence.map((item) => ({
            value: item.evidenceId,
            label: `${item.claimKey}: ${item.sourceRef}`,
          })),
        ]} /> : null}
      <TextareaField label="Reason for decision" rows={2} value={reason}
        onChange={setReason} required />
      <p>Draft review is only a private eligibility input. It does not verify an
        endpoint, consent to send, or provider delivery.</p>
      <AdminButton type="submit" disabled={!selected || !reason.trim() ||
        (status === "draft_reviewed" && !evidenceId) || controller.isSaving}>
        Record contact decision
      </AdminButton>
    </AdminForm> : null}
  </Panel>;
}

function SalesEvidencePanel({detail, controller}: {
  detail: SalesAccountDetail; controller: SalesWorkspaceController;
}) {
  const [contactId, setContactId] = useState("");
  const [claimKey, setClaimKey] = useState<SalesEvidence["claimKey"]>("identity");
  const [signalId, setSignalId] = useState("");
  const [sourceType, setSourceType] = useState<SalesEvidence["sourceType"]>("human_note");
  const [sourceRef, setSourceRef] = useState("");
  const [observedAt, setObservedAt] = useState(() => toLocalDateTimeInput(new Date()));
  const [confidence, setConfidence] = useState<SalesEvidence["confidence"]>("medium");
  const [value, setValue] = useState("");
  const [excerpt, setExcerpt] = useState("");
  const rows = controller.evidence.data?.rows ?? [];
  const save = async () => {
    const date = new Date(observedAt);
    if (!sourceRef.trim() || Number.isNaN(date.getTime()) ||
      (claimKey === "operation" && !signalId.trim())) return;
    const saved = await controller.saveEvidence({organizerId: detail.account.organizerId,
      contactId: contactId || null, claimKey,
      signalId: claimKey === "operation" ? signalId.trim() : undefined,
      sourceType, sourceRef: sourceRef.trim(), observedAt: date.toISOString(),
      confidence, normalizedValue: value.trim() || null, excerpt: excerpt.trim() || null});
    if (saved) {setSourceRef(""); setValue(""); setExcerpt(""); setSignalId("");}
  };
  return <Panel title="Research evidence" icon={<ClipboardList size={18} />}>
    <p>Record the source and observation separately from a conclusion. Evidence is
      private and does not publish claims.</p>
    {controller.evidence.isPending ? <EmptyState>Loading evidence…</EmptyState> :
      controller.evidence.error ? <EmptyState>Evidence could not be loaded. <AdminButton
        onClick={() => void controller.evidence.refetch()}>Try again</AdminButton></EmptyState> :
        rows.length ? rows.map((item) => <StateRow key={item.evidenceId}
          label={`${item.claimKey} · ${item.confidence}`} value={<>
            {item.sourceType.replaceAll("_", " ")} · {item.sourceRef} ·
            {new Date(item.observedAt).toLocaleDateString()}
            {item.normalizedValue ? ` · ${item.normalizedValue}` : ""}
          </>} />) : <EmptyState>No evidence recorded for this host.</EmptyState>}
    <PageControls previous={controller.hasPreviousEvidencePage}
      next={Boolean(controller.evidence.data?.nextCursor)}
      onPrevious={controller.previousEvidencePage} onNext={controller.nextEvidencePage} />
    <AdminForm onSubmit={(event) => {event.preventDefault(); void save();}}>
      <h3>Add reviewed observation</h3>
      <SelectField label="Related contact on this page (optional)" value={contactId}
        onChange={setContactId} options={[{value: "", label: "Host account"},
          ...(controller.contacts.data?.rows ?? []).map((item) => ({
            value: item.contactId, label: item.displayName,
          }))]} />
      <SelectField label="Claim category" value={claimKey}
        onChange={(next) => setClaimKey(next as typeof claimKey)} options={[
          "identity", "recurrence", "operation", "stack", "other",
        ]} />
      {claimKey === "operation" ? <TextField label="Distinct operating signal ID"
        value={signalId} onChange={setSignalId} required /> : null}
      <SelectField label="Source type" value={sourceType}
        onChange={(next) => setSourceType(next as typeof sourceType)} options={[
          {value: "first_party", label: "First party"},
          {value: "public_web", label: "Public web"},
          {value: "human_note", label: "Human note"},
          {value: "import_artifact", label: "Import artifact"},
        ]} />
      <TextField label="Source reference" value={sourceRef}
        onChange={setSourceRef} required maxLength={320} />
      <TextField label="Observed at" type="datetime-local" value={observedAt}
        onChange={setObservedAt} required />
      <SelectField label="Confidence" value={confidence}
        onChange={(next) => setConfidence(next as typeof confidence)} options={[
          "low", "medium", "high",
        ]} />
      <TextField label="Normalized value (optional)" value={value}
        onChange={setValue} maxLength={500} />
      <TextareaField label="Short source excerpt (optional)" rows={2}
        value={excerpt} onChange={setExcerpt} maxLength={500} />
      <AdminButton type="submit" disabled={!sourceRef.trim() || !observedAt ||
        (claimKey === "operation" && !signalId.trim()) || controller.isSaving}>
        Record evidence
      </AdminButton>
    </AdminForm>
  </Panel>;
}

function SalesSuppressionPanel({detail, controller}: {
  detail: SalesAccountDetail; controller: SalesWorkspaceController;
}) {
  const [status, setStatus] = useState<"clear" | "held" | "suppressed">(
    detail.account.suppressionStatus ?? "clear");
  const [reason, setReason] = useState("");
  const save = async () => {
    if (!reason.trim()) return;
    const saved = await controller.saveAccountSuppression({
      organizerId: detail.account.organizerId,
      expectedRevision: detail.account.revision, status, reason: reason.trim(),
    });
    if (saved) setReason("");
  };
  return <Panel title="Account restriction" icon={<ClipboardList size={18} />}>
    <StateRow label="Current status" value={detail.account.suppressionStatus ?? "clear"} />
    <AdminForm onSubmit={(event) => {event.preventDefault(); void save();}}>
      <SelectField label="New status" value={status}
        onChange={(value) => setStatus(value as typeof status)} options={[
          {value: "clear", label: "Clear hold"},
          {value: "held", label: "Hold"},
          {value: "suppressed", label: "Suppress"},
        ]} />
      <TextareaField label="Reason" rows={2} value={reason} onChange={setReason}
        required />
      <p>Clearing a hold does not grant permission to draft or send outreach.</p>
      <AdminButton type="submit" disabled={!reason.trim() || controller.isSaving}>
        Record account decision
      </AdminButton>
    </AdminForm>
  </Panel>;
}

function SalesDraftReadinessPanel() {
  return <Panel title="Outreach draft readiness" icon={<ClipboardList size={18} />}>
    <p>Private draft generation is waiting for the live eligibility bridge, approved
      evidence clauses, capability and reference checks, and a reviewed CTA set.
      Contact review alone does not enable a draft or a send. Record research and
      manual activity here while those controls are being integrated.</p>
  </Panel>;
}

export function SalesRecordsWorkspace({section, detail, controller}: {
  section: "people" | "evidence" | "suppression" | "draft";
  detail: SalesAccountDetail; controller: SalesWorkspaceController;
}) {
  if (section === "people") return <SalesPeoplePanel detail={detail} controller={controller} />;
  if (section === "evidence") return <SalesEvidencePanel detail={detail}
    controller={controller} />;
  if (section === "suppression") return <SalesSuppressionPanel detail={detail}
    controller={controller} />;
  return <SalesDraftReadinessPanel />;
}
