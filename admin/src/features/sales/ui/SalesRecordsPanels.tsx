import {useState} from "react";
import {CheckCircle2, ClipboardList} from "lucide-react";
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
  const [selectedRevision, setSelectedRevision] = useState<number | null>(null);
  const [status, setStatus] = useState<SalesContact["relationship"]["contactabilityStatus"]>("unknown");
  const [reason, setReason] = useState("");
  const [evidenceId, setEvidenceId] = useState("");
  const contacts = controller.contacts.data?.rows ?? [];
  const selected = contacts.find((item) => item.contactId === selectedContact);
  const contactChanged = Boolean(selected && selectedRevision !==
    selected.relationship.revision);
  const selectContact = (contact: SalesContact | undefined) => {
    setSelectedContact(contact?.contactId ?? "");
    setSelectedRevision(contact?.relationship.revision ?? null);
    setStatus(contact?.relationship.contactabilityStatus ?? "unknown");
    setReason("");
    setEvidenceId(contact?.relationship.draftReviewEvidenceId ?? "");
  };
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
    if (!selected || contactChanged || selectedRevision === null || !reason.trim() ||
      (status === "draft_reviewed" && !evidenceId)) return;
    const saved = await controller.saveContactability({organizerId,
      contactId: selected.contactId, expectedRevision: selectedRevision,
      status, reason: reason.trim(), evidenceId: status === "draft_reviewed" ? evidenceId :
        undefined});
    if (saved) selectContact(undefined);
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
      <SelectField label="Contact method (optional)" value={endpointKind}
        onChange={(value) => setEndpointKind(value as typeof endpointKind)} options={[
          {value: "email", label: "Email"}, {value: "phone", label: "Phone"},
        ]} />
      <TextField label={endpointKind === "email" ? "Email address (unverified)" :
        "Phone number (unverified)"} value={endpointValue}
        onChange={setEndpointValue} type={endpointKind === "email" ? "email" : "text"} />
      <p>These contact details still need review before they can be used.</p>
      <AdminButton type="submit" disabled={!name.trim() || !role.trim() ||
        controller.isSaving}>Add contact</AdminButton>
    </AdminForm>
    {contacts.length ? <AdminForm onSubmit={(event) => {event.preventDefault(); void review();}}>
      <h3>Contact restriction or draft review</h3>
      <SelectField label="Contact on this page" value={selectedContact}
        onChange={(value) => selectContact(contacts.find((item) =>
          item.contactId === value))}
        options={[{value: "", label: "Choose contact"}, ...contacts.map((item) => ({
          value: item.contactId, label: item.displayName,
        }))]} />
      {selected ? <StateRow label="Current status" value={
        selected.relationship.contactabilityStatus.replaceAll("_", " ")} /> : null}
      {contactChanged ? <p role="alert">This contact decision changed since you opened
        it. Compare the current status before recording another decision. <AdminButton
          type="button" onClick={() => selectContact(selected)}>Use latest contact
          decision</AdminButton></p> : null}
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
      <AdminButton type="submit" disabled={!selected || contactChanged || !reason.trim() ||
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
      <SelectField label="What this helps establish" value={claimKey}
        onChange={(next) => setClaimKey(next as typeof claimKey)} options={[
          "identity", "recurrence", "operation", "stack", "other",
        ]} />
      {claimKey === "operation" ? <TextField label="Operating signal (short label)"
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
      <TextField label="What you learned (optional)" value={value}
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
  const [reviewed, setReviewed] = useState(() => ({
    organizerId: detail.account.organizerId,
    revision: detail.account.revision,
    status: detail.account.suppressionStatus ?? "clear",
  }));
  const [status, setStatus] = useState<"clear" | "held" | "suppressed">(
    reviewed.status);
  const [reason, setReason] = useState("");
  const accountChanged = reviewed.organizerId !== detail.account.organizerId ||
    reviewed.revision !== detail.account.revision;
  const useLatest = () => {
    const latest = {organizerId: detail.account.organizerId,
      revision: detail.account.revision,
      status: detail.account.suppressionStatus ?? "clear"};
    setReviewed(latest);
    setStatus(latest.status);
    setReason("");
  };
  const save = async () => {
    if (!reason.trim() || accountChanged) return;
    const saved = await controller.saveAccountSuppression({
      organizerId: reviewed.organizerId,
      expectedRevision: reviewed.revision, status, reason: reason.trim(),
    });
    if (saved) {setReviewed({...reviewed, revision: reviewed.revision + 1,
      status}); setReason("");}
  };
  return <Panel title="Account restriction" icon={<ClipboardList size={18} />}>
    <StateRow label="Current status" value={detail.account.suppressionStatus ?? "clear"} />
    {accountChanged ? <p role="alert">This host record changed since you opened
      the restriction form. Compare the current status before recording another
      decision. <AdminButton type="button" onClick={useLatest}>Use latest account
      decision</AdminButton></p> : null}
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
      <AdminButton type="submit" disabled={!reason.trim() || accountChanged ||
        controller.isSaving}>
        Record account decision
      </AdminButton>
    </AdminForm>
  </Panel>;
}

function taskDateLabel(value: string | null) {
  if (!value) return "No date";
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value :
    date.toLocaleDateString(undefined, {day: "numeric", month: "short", year: "numeric"});
}

function taskOwnerLabel(uid: string, currentUserUid: string) {
  return uid === currentUserUid ? "You" : "Another teammate";
}

function taskStatusLabel(status: string) {
  return status.replaceAll("_", " ").replace(/\b\w/gu, (letter) =>
    letter.toUpperCase());
}

function SalesTasksPanel({detail, controller, currentUserUid}: {
  detail: SalesAccountDetail; controller: SalesWorkspaceController;
  currentUserUid: string;
}) {
  const [title, setTitle] = useState("");
  const [dueAt, setDueAt] = useState("");
  const [kind, setKind] = useState<"research" | "follow_up" | "demo">("research");
  const [contactId, setContactId] = useState("");
  const outbound = kind === "follow_up" || kind === "demo";
  const reviewedContacts = (controller.contacts.data?.rows ?? []).filter((contact) =>
    contact.relationship.contactabilityStatus === "draft_reviewed");
  const selectedContact = reviewedContacts.find((contact) =>
    contact.contactId === contactId);
  const add = async () => {
    const date = new Date(dueAt);
    if (!title.trim() || !dueAt || Number.isNaN(date.getTime()) ||
      !currentUserUid || (outbound && !selectedContact)) return;
    const saved = await controller.saveTask({organizerId: detail.account.organizerId,
      expectedRevision: 0,
      task: {kind, title: title.trim(), ownerUid: currentUserUid,
        dueAt: date.toISOString(), status: "open",
        contactId: outbound ? selectedContact!.contactId : null}});
    if (saved) {setTitle(""); setDueAt(""); setKind("research"); setContactId("");}
  };
  return <Panel title="Next steps" icon={<ClipboardList size={18} />}>
    {detail.tasks.map((task) => <StateRow key={task.taskId}
      label={task.title} value={<>
      {taskDateLabel(task.dueAt)} · {taskOwnerLabel(task.ownerUid, currentUserUid)} ·
        {taskStatusLabel(task.status)}{" "}
      {task.status === "open" ? <AdminButton disabled={controller.isSaving}
        icon={<CheckCircle2 size={15} />}
        onClick={() => void controller.saveTask({
          organizerId: detail.account.organizerId, taskId: task.taskId,
          expectedRevision: task.revision,
          task: {kind: task.kind, title: task.title, dueAt: task.dueAt,
            ownerUid: task.ownerUid, status: "completed",
            contactId: task.contactId ?? null},
        })}>Mark done</AdminButton> : null}
    </>} />)}
    {!detail.tasks.length ? <EmptyState>No tasks for this host.</EmptyState> : null}
    <AdminForm onSubmit={(event) => {event.preventDefault(); void add();}}>
      <TextField label="New task" value={title} onChange={setTitle} />
      <SelectField label="Task purpose" value={kind}
        onChange={(value) => {setKind(value as typeof kind); setContactId("");}}
        options={[{value: "research", label: "Internal research"},
          {value: "follow_up", label: "Follow up with a contact"},
          {value: "demo", label: "Arrange a demo with a contact"}]} />
      {outbound ? <>
        <SelectField label="Reviewed contact on this page" value={contactId}
          onChange={setContactId} options={[{value: "", label: "Choose contact"},
            ...reviewedContacts.map((contact) => ({value: contact.contactId,
              label: contact.displayName}))]} />
        <p>A contact review permits draft consideration only. The server checks
          current restrictions before recording this task; it does not send anything.</p>
        {!reviewedContacts.length ? <p role="alert">No reviewed contacts on this page.
          Review a contact in People, or choose Internal research.</p> : null}
      </> : null}
      <p>Assigned to you</p>
      <TextField label="Due" type="datetime-local" value={dueAt}
        onChange={setDueAt} />
      <AdminButton type="submit" disabled={!title.trim() || !currentUserUid ||
        !dueAt || (outbound && !selectedContact) || controller.isSaving}>Add task</AdminButton>
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

export function SalesRecordsWorkspace({section, detail, controller, currentUserUid}: {
  section: "people" | "evidence" | "suppression" | "draft" | "tasks";
  currentUserUid?: string;
  detail: SalesAccountDetail; controller: SalesWorkspaceController;
}) {
  if (section === "tasks") return <SalesTasksPanel key={detail.account.organizerId}
    detail={detail} controller={controller} currentUserUid={currentUserUid ?? ""} />;
  if (section === "people") return <SalesPeoplePanel key={detail.account.organizerId}
    detail={detail} controller={controller} />;
  if (section === "evidence") return <SalesEvidencePanel detail={detail}
    controller={controller} />;
  if (section === "suppression") return <SalesSuppressionPanel
    key={detail.account.organizerId} detail={detail} controller={controller} />;
  return <SalesDraftReadinessPanel />;
}
