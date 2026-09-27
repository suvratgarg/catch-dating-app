import {useState} from "react";
import {ClipboardList, Sparkles} from "lucide-react";
import {AdminButton, AdminForm, CheckboxField, EmptyState, Panel,
  SelectField, StateRow, TextareaField, TextField} from
  "../../../shared/ui/AdminPrimitives";
import type {ApprovedClause, IntelligenceApi,
  IntelligenceFactor} from "../api/salesIntelligenceTypes";
import {useSalesIntelligence} from "../controllers/useSalesIntelligence";

type Controller = ReturnType<typeof useSalesIntelligence>;
function label(value: string): string {
  return value.replaceAll("_", " ").replace(/\b\w/gu,
    (letter) => letter.toUpperCase());
}
function date(value: string): string {
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? "Date unavailable" :
    parsed.toLocaleDateString(undefined, {day: "numeric", month: "short",
      year: "numeric"});
}
function activeClause(row: ApprovedClause, now: string): boolean {
  return row.state === "approved" && row.permission !== "withdrawn" &&
    Date.parse(row.validUntil) > Date.parse(now) &&
    (row.kind !== "reference" || row.permission === "private_mention");
}
function QueryProblem({message, retry}: {message: string; retry: () => void}) {
  return <p role="alert">{message} <AdminButton onClick={retry}>Try again</AdminButton></p>;
}

/** Mount in a host detail tab; all authority remains in the callable services. */
export function SalesIntelligenceWorkspace({organizerId, organizerName,
  currentUserUid, isAdminOwner, api}: {organizerId: string;
    organizerName: string; currentUserUid: string; isAdminOwner: boolean;
    api?: IntelligenceApi}) {
  return <IntelligenceBody key={`${currentUserUid}:${organizerId}`}
    organizerId={organizerId} organizerName={organizerName}
    currentUserUid={currentUserUid} isAdminOwner={isAdminOwner} api={api} />;
}

function IntelligenceBody({organizerId, organizerName, currentUserUid,
  isAdminOwner, api}: {organizerId: string; organizerName: string;
    currentUserUid: string; isAdminOwner: boolean; api?: IntelligenceApi}) {
  const c = useSalesIntelligence({actorUid: currentUserUid, organizerId, api});
  return <>
    <Panel title="Fit and private outreach" icon={<Sparkles size={18} />}>
      <p>Evidence, reviewed wording and current contact restrictions decide what
        can be drafted for {organizerName}. Nothing here sends a message.</p>
      {c.error ? <p role="alert">{c.error}</p> : null}
      {c.notice ? <p role="status">{c.notice}</p> : null}
      {c.pending ? <AdminButton disabled={c.busy}
        onClick={() => void c.retry()}>Retry unchanged request</AdminButton> : null}
      <AdminButton disabled={c.busy || Boolean(c.pending)}
        onClick={() => void c.refresh()}>Refresh current source</AdminButton>
    </Panel>
    <FitPanel c={c} organizerId={organizerId} />
    <WordingPanel c={c} isAdminOwner={isAdminOwner} />
    <DraftPanel c={c} organizerId={organizerId} />
  </>;
}

function FitPanel({c, organizerId}: {c: Controller; organizerId: string}) {
  const [factorId, setFactorId] = useState("");
  const [state, setState] = useState<"known" | "unknown" | "disputed">("unknown");
  const [rating, setRating] = useState("3");
  const [evidenceId, setEvidenceId] = useState("");
  const [reason, setReason] = useState("");
  const policy = c.catalog.data?.policy;
  const factor = policy?.factors.find((item) => item.id === factorId);
  const assessment = c.catalog.data?.assessments.find((item) =>
    item.factorId === factorId);
  const evidenceRows = c.evidence.data?.rows ?? [];
  const relevant = factor ? evidenceRows.filter((row) =>
    row.organizerId === organizerId && !row.contactId &&
    factor.claimKeys.includes(row.claimKey) &&
    (!row.validThrough || Date.parse(row.validThrough) > Date.now())) : [];
  const score = c.score.data?.snapshot;
  const selectFactor = (next: string) => {
    setFactorId(next); setEvidenceId(""); setReason("");
    const found = c.catalog.data?.assessments.find((item) => item.factorId === next);
    setState(found?.state ?? "unknown"); setRating(String(found?.value ?? 3));
    setReason(found?.reason ?? "");
    setEvidenceId(found?.evidenceIds[0] ?? "");
  };
  const save = async () => {
    if (!factor || c.busy || c.pending) return;
    if (state === "known" && (!evidenceId || !Number.isInteger(Number(rating)))) return;
    if (state !== "known" && !reason.trim()) return;
    await c.assess({factorId: factor.id, expectedRevision: assessment?.revision ?? 0,
      state, value: state === "known" ? Number(rating) : null,
      evidenceIds: state === "known" ? [evidenceId] : [],
      reason: state === "known" ? null : reason.trim()});
  };
  return <Panel title="Evidence-backed fit" icon={<ClipboardList size={18} />}>
    {c.catalog.isPending || c.score.isPending ? <p>Checking current fit…</p> : null}
    {c.catalog.isError ? <QueryProblem message="Current fit policy could not load."
      retry={() => void c.catalog.refetch()} /> : null}
    {c.score.isError ? <QueryProblem message="Current fit could not be evaluated."
      retry={() => void c.score.refetch()} /> : null}
    {!policy && !c.catalog.isPending && !c.catalog.isError ?
      <EmptyState>An Admin owner must add a reviewed private fit policy before
        this host can be scored.</EmptyState> : null}
    {policy ? <>
      <StateRow label="Policy" value={`${policy.version} · ${label(policy.status)}`} />
      <StateRow label="Current fit" value={score?.score === null ||
        score?.score === undefined ? "Unknown · more reviewed evidence needed" :
        `${score.score.toFixed(1)} / 100 · ${label(score.priority)} priority`} />
      {score?.status === "review_required" ? <p role="alert">A factor needs
        review before a priority can be assigned.</p> : null}
      {policy.factors.map((item: IntelligenceFactor) => {
        const current = c.catalog.data?.assessments.find((row) =>
          row.factorId === item.id);
        return <StateRow key={item.id} label={label(item.id)} value={
          current?.state === "known" ? `${current.value} of 5 · reviewed` :
            current?.state === "disputed" ? "Disputed · review needed" :
              "Unknown · evidence needed"} />;
      })}
      <AdminForm onSubmit={(event) => {event.preventDefault(); void save();}}>
        <h3>Review one fit factor</h3>
        <SelectField label="Factor" value={factorId} onChange={selectFactor}
          options={[{value: "", label: "Choose factor"},
            ...policy.factors.map((item) => ({value: item.id,
              label: label(item.id)}))]} />
        {factor ? <>
          <SelectField label="What is known?" value={state}
            onChange={(value) => setState(value as typeof state)} options={[
              {value: "unknown", label: "Not known yet"},
              {value: "known", label: "Supported by evidence"},
              {value: "disputed", label: "Conflicting evidence"},
            ]} />
          {state === "known" ? <>
            <SelectField label="Rating" value={rating} onChange={setRating}
              options={[0, 1, 2, 3, 4, 5].map((value) => ({
                value: String(value), label: `${value} of 5`}))} />
            <SelectField label="Reviewed host evidence on this page"
              value={evidenceId} onChange={setEvidenceId} options={[
                {value: "", label: "Choose evidence"}, ...relevant.map((row) => ({
                  value: row.evidenceId, label: `${label(row.claimKey)} · ${row.sourceRef}`})),
              ]} />
          </> : <TextareaField label="Why is this unknown or disputed?"
            rows={2} value={reason} onChange={setReason} />}
          <AdminButton type="submit" variant="primary" disabled={c.busy ||
            Boolean(c.pending) || (state === "known" ? !evidenceId :
            !reason.trim())}>Record review</AdminButton>
        </> : null}
      </AdminForm>
    </> : null}
    {c.evidence.data?.nextCursor ? <AdminButton onClick={() =>
      c.nextEvidencePage(c.evidence.data!.nextCursor!)}>More evidence</AdminButton> : null}
    {c.evidenceHistory.length ? <AdminButton onClick={c.previousEvidencePage}>
      Previous evidence</AdminButton> : null}
    {c.evidence.isError ? <QueryProblem message="Evidence could not load."
      retry={() => void c.evidence.refetch()} /> : null}
  </Panel>;
}

function WordingPanel({c, isAdminOwner}: {c: Controller; isAdminOwner: boolean}) {
  const [kind, setKind] = useState<ApprovedClause["kind"]>("observation");
  const [wording, setWording] = useState("");
  const [evidenceId, setEvidenceId] = useState("");
  const [expires, setExpires] = useState("");
  const catalog = c.catalog.data;
  const save = async () => {
    const expiry = new Date(expires);
    if (!wording.trim() || Number.isNaN(expiry.getTime()) ||
        expiry.getTime() <= Date.now() || (kind !== "cta" && !evidenceId)) return;
    const result = await c.saveClause({kind, text: wording.trim(),
      evidenceIds: evidenceId ? [evidenceId] : [],
      validUntil: expiry.toISOString()});
    if (result) {setWording(""); setEvidenceId(""); setExpires("");}
  };
  return <Panel title="Reviewed wording" icon={<ClipboardList size={18} />}>
    <p>Only approved, current sentences can appear in a draft. A reference
      needs explicit private-mention permission.</p>
    {catalog?.clauses.length ? catalog.clauses.map((row) =>
      <StateRow key={row.clauseId} label={`${label(row.kind)} · ${row.text}`}
        value={<>{label(row.state)} · valid until {date(row.validUntil)}{" "}
          {isAdminOwner && row.state === "draft" ? <AdminButton
            disabled={c.busy || Boolean(c.pending)} onClick={() => void
              c.reviewClause(row.clauseId, row.revision, "approve")}>
              Approve wording</AdminButton> : null}
          {isAdminOwner && row.state === "approved" ? <AdminButton
            disabled={c.busy || Boolean(c.pending)} onClick={() => void
              c.reviewClause(row.clauseId, row.revision, "withdraw")}>
              Withdraw wording</AdminButton> : null}</>} />) :
      <EmptyState>No reviewed wording is available for this host.</EmptyState>}
    {isAdminOwner ? <AdminForm onSubmit={(event) => {event.preventDefault(); void save();}}>
      <h3>Prepare an exact sentence for review</h3>
      <SelectField label="Sentence purpose" value={kind}
        onChange={(value) => setKind(value as typeof kind)} options={[
          {value: "observation", label: "Host observation"},
          {value: "capability", label: "Catch capability"},
          {value: "reference", label: "Private reference"},
          {value: "cta", label: "Question or next step"},
        ]} />
      <TextareaField label="Exact wording" rows={3} value={wording}
        onChange={setWording} />
      <SelectField label="Reviewed evidence on this page" value={evidenceId}
        onChange={setEvidenceId} options={[
          {value: "", label: kind === "cta" ? "No evidence needed" :
            "Choose evidence"}, ...(c.evidence.data?.rows ?? []).map((row) => ({
            value: row.evidenceId, label: `${label(row.claimKey)} · ${row.sourceRef}`})),
        ]} />
      <TextField label="Valid until" type="datetime-local" value={expires}
        onChange={setExpires} />
      <AdminButton type="submit" disabled={c.busy || Boolean(c.pending) ||
        !wording.trim() || !expires || (kind !== "cta" && !evidenceId)}>
        Save sentence for approval</AdminButton>
    </AdminForm> : null}
  </Panel>;
}

function DraftPanel({c, organizerId}: {c: Controller; organizerId: string}) {
  const [contactId, setContactId] = useState("");
  const [opportunityId, setOpportunityId] = useState("");
  const [observationId, setObservationId] = useState("");
  const [capabilityId, setCapabilityId] = useState("");
  const [referenceId, setReferenceId] = useState("");
  const [ctaId, setCtaId] = useState("");
  const [channel, setChannel] = useState<"email" | "message">("email");
  const [factsChecked, setFactsChecked] = useState(false);
  const [toneChecked, setToneChecked] = useState(false);
  const [copyStatus, setCopyStatus] = useState("");
  const account = c.account.data?.account;
  const now = c.catalog.data?.evaluatedAt ?? new Date().toISOString();
  const approved = c.catalog.data?.clauses.filter((row) =>
    activeClause(row, now)) ?? [];
  const ofKind = (kind: ApprovedClause["kind"]) => approved.filter((row) =>
    row.kind === kind);
  const contacts = c.contacts.data?.rows.filter((row) =>
    row.relationship.contactabilityStatus === "draft_reviewed") ?? [];
  const opportunities = c.account.data?.opportunities.filter((row) =>
    row.stage === "ready_to_contact") ?? [];
  const eligible = account?.researchStatus === "qualified" &&
    account.suppressionStatus !== "held" &&
    account.suppressionStatus !== "suppressed" &&
    c.catalog.data?.policy?.status === "active";
  const canGenerate = eligible && contactId && opportunityId &&
    observationId && capabilityId && ctaId && !c.pending && !c.busy;
  const generate = () => c.generate({organizerId, contactId,
    opportunityId, observationIds: [observationId],
    capabilityIds: [capabilityId], referenceIds: referenceId ?
      [referenceId] : [], ctaIds: [ctaId], channel,
    purpose: "first_message"});
  const selected = c.draft.data;
  const copy = async () => {
    if (!selected || selected.status !== "approved") return;
    const receipt = await c.copy(selected.draftId, selected.draft.contentHash);
    if (!receipt) return;
    try {
      await navigator.clipboard.writeText(
        [receipt.subject, receipt.text].filter(Boolean).join("\n\n"));
      setCopyStatus("Reviewed text copied. Sending, if appropriate, is a separate manual action.");
    } catch {
      setCopyStatus("Copy was reviewed, but the browser clipboard failed. Select the text below manually.");
    }
  };
  const options = (kind: ApprovedClause["kind"], optional = false) => [
    {value: "", label: optional ? "No reference" : "Choose approved wording"},
    ...ofKind(kind).map((row) => ({value: row.clauseId, label: row.text})),
  ];
  return <Panel title="Draft for manual review" icon={<ClipboardList size={18} />}>
    <p>Drafts use exact approved sentences. They cannot be sent from this workspace.</p>
    {!eligible ? <p role="alert">This host needs an active fit policy, a
      qualified Sales record and clear contact restrictions before drafting.</p> : null}
    {c.account.isError ? <QueryProblem message="Host details could not load."
      retry={() => void c.account.refetch()} /> : null}
    {c.contacts.isError ? <QueryProblem message="Contacts could not load."
      retry={() => void c.contacts.refetch()} /> : null}
    <AdminForm onSubmit={(event) => {event.preventDefault(); void generate();}}>
      <h3>Prepare a first message</h3>
      <SelectField label="Reviewed contact" value={contactId}
        onChange={setContactId} options={[{value: "", label: "Choose contact"},
          ...contacts.map((row) => ({value: row.contactId,
            label: `${row.displayName} · ${row.relationship.role}`}))]} />
      {c.contacts.data?.nextCursor ? <AdminButton onClick={() =>
        c.nextContactPage(c.contacts.data!.nextCursor!)}>More contacts</AdminButton> : null}
      {c.contactHistory.length ? <AdminButton onClick={c.previousContactPage}>
        Previous contacts</AdminButton> : null}
      <SelectField label="Opportunity ready for contact" value={opportunityId}
        onChange={setOpportunityId} options={[{value: "", label: "Choose opportunity"},
          ...opportunities.map((row) => ({value: row.opportunityId,
            label: `${label(row.motion)} · ${label(row.stage)}`}))]} />
      <SelectField label="Host observation" value={observationId}
        onChange={setObservationId} options={options("observation")} />
      <SelectField label="Catch capability" value={capabilityId}
        onChange={setCapabilityId} options={options("capability")} />
      <SelectField label="Private reference (optional)" value={referenceId}
        onChange={setReferenceId} options={options("reference", true)} />
      <SelectField label="Question or next step" value={ctaId}
        onChange={setCtaId} options={options("cta")} />
      <SelectField label="Draft channel" value={channel}
        onChange={(value) => setChannel(value as typeof channel)} options={[
          {value: "email", label: "Email draft"},
          {value: "message", label: "Message draft"},
        ]} />
      <AdminButton type="submit" variant="primary"
        disabled={!canGenerate}>Prepare private draft</AdminButton>
    </AdminForm>
    {c.jobRequestId ? <p role="status">Preparation status: {
      c.job.data?.status === "completed" ? "Ready for review" :
        c.job.data?.status === "running" ? "Still preparing" :
          c.job.isError ? "Could not confirm status" : "Checking"}{" "}
      <AdminButton onClick={() => void c.job.refetch()}>Check again</AdminButton></p> : null}
    <h3>Saved drafts</h3>
    {c.drafts.isError ? <QueryProblem message="Saved drafts could not load."
      retry={() => void c.drafts.refetch()} /> : null}
    {c.drafts.data?.rows.length ? c.drafts.data.rows.map((row) =>
      <StateRow key={row.draftId} label={row.subject ?? "Message draft"}
        value={<>{label(row.status)} · {date(row.createdAt)}{" "}
          <AdminButton disabled={c.busy || Boolean(c.pending)}
            onClick={() => {c.setSelectedDraftId(row.draftId);
              setFactsChecked(false); setToneChecked(false); setCopyStatus("");}}>
              Open draft</AdminButton></>} />) :
      <EmptyState>No drafts have been prepared for this host.</EmptyState>}
    {c.draft.isError ? <QueryProblem message="This draft is no longer current."
      retry={() => void c.draft.refetch()} /> : null}
    {selected ? <>
      <h3>Review exact draft</h3>
      {selected.draft.subject ? <StateRow label="Subject"
        value={selected.draft.subject} /> : null}
      <TextareaField label="Draft text" rows={8} value={selected.draft.text}
        onChange={() => undefined} readOnly />
      <StateRow label="Source" value="Reviewed evidence and approved wording" />
      <StateRow label="Model use" value="None · deterministic wording" />
      <StateRow label="Status" value={label(selected.status)} />
      {selected.status === "pending_review" ? <>
        <CheckboxField checked={factsChecked} onChange={setFactsChecked}
          label="I checked every factual claim against the current source." />
        <CheckboxField checked={toneChecked} onChange={setToneChecked}
          label="I approve the tone and understand this is manual copy only." />
        <AdminButton disabled={!factsChecked || !toneChecked ||
          c.busy || Boolean(c.pending)} onClick={() => void c.review(
          selected.draftId, selected.draft.contentHash)}>
          Approve exact draft</AdminButton>
      </> : <AdminButton disabled={c.busy || Boolean(c.pending)}
        onClick={() => void copy()}>Copy approved text</AdminButton>}
      {copyStatus ? <p role="status">{copyStatus}</p> : null}
    </> : null}
  </Panel>;
}
