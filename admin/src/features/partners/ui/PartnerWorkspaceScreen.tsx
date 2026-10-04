import {AlertCircle, CheckCircle2, Handshake} from "lucide-react";
import {useState} from "react";
import {AdminButton, AdminDirectoryScreenStack, AdminForm, EmptyState, PageHeader,
  Panel, SelectField, StateRow, StatusBanner, TextareaField, TextField} from
  "../../../shared/ui/AdminPrimitives";
import {useAdminOperationPending} from "../../../shared/pendingOperation";
import {usePartnerWorkspaceController} from "../controllers/usePartnerWorkspaceController";
import type {PartnerLead} from "../api/partnerRepository";

export function PartnerWorkspaceScreen({onSignOut}: {onSignOut: () => void}) {
  const c = usePartnerWorkspaceController();
  const pending = useAdminOperationPending();
  const [displayName, setDisplayName] = useState("");
  const [name, setName] = useState(""); const [city, setCity] = useState("");
  const [url, setUrl] = useState(""); const [relationship, setRelationship] = useState("");
  const data = c.workspace.isSuccess && !c.workspace.isFetching ? c.workspace.data : undefined;
  const membershipRequired = !data && c.workspace.error &&
    "code" in c.workspace.error && c.workspace.error.code === "functions/permission-denied";
  return <AdminDirectoryScreenStack>
    <PageHeader title="Catch referral partners">Introduce an organizer, review the preparation, and keep the next action clear.</PageHeader>
    <AdminButton disabled={pending} onClick={onSignOut}>Sign out</AdminButton>
    {c.error && <StatusBanner tone="error" icon={<AlertCircle />}>{c.error}</StatusBanner>}
    {c.needsRetry && <AdminButton disabled={pending || c.workspace.isFetching} onClick={() => void c.retry()}>Retry interrupted save</AdminButton>}
    {c.notice && <StatusBanner tone="success" icon={<CheckCircle2 />}>{c.notice}</StatusBanner>}
    {c.workspace.isLoading && <StateRow label="Partner access" value="Checking your workspace…" />}
    {membershipRequired ? <Panel icon={<Handshake />} title="Accept a bounded referral role">
      <p>You can nominate organizers and review leads assigned to you. You are a prospective collaborator.
        This role does not make you a Catch employee or grant organizer control. Marketing access is granted separately.</p>
      <AdminForm onSubmit={(e) => {e.preventDefault(); void c.save("register", {
        displayName: displayName.trim(), termsVersion: "referral-preview-v1"});}}>
        <TextField label="Your name" value={displayName} onChange={setDisplayName} disabled={pending} />
        <AdminButton type="submit" variant="primary" disabled={pending || !displayName.trim()}>Accept referral role</AdminButton>
      </AdminForm>
    </Panel> : c.workspace.error ? <StatusBanner tone="error" icon={<AlertCircle />}>{c.workspace.error.message}</StatusBanner> : null}
    {data && <>
      <Panel icon={<Handshake />} title="Nominate an organizer">
        <p>A nomination is self-reported and requires identity review. It creates no claim or published listing.</p>
        <AdminForm onSubmit={(e) => {e.preventDefault(); void c.save("nominate", {
          name: name.trim(), city: city.trim(), url: url.trim(), relationshipContext: relationship.trim() || null})
          .then((saved) => {if (saved) {setName(""); setCity(""); setUrl(""); setRelationship("");}});}}>
          <TextField label="Organizer name" value={name} onChange={setName} disabled={pending} />
          <TextField label="City or region" value={city} onChange={setCity} disabled={pending} />
          <TextField label="Official site or event link" value={url} onChange={setUrl} disabled={pending} />
          <TextareaField rows={3} label="How you know them (optional)" value={relationship} onChange={setRelationship} disabled={pending} />
          <AdminButton type="submit" variant="primary" disabled={pending || !name.trim() || !city.trim() || !url.trim()}>Submit for review</AdminButton>
        </AdminForm>
      </Panel>
      <Panel icon={<Handshake />} title="Your nominations">
        {data.submissions.length ? data.submissions.map((s) => <StateRow key={s.intentId} label={s.name} value={s.status.replaceAll("_", " ")} />) :
          <EmptyState>No nominations yet. Start with one organizer you can introduce.</EmptyState>}
      </Panel>
      <Panel icon={<Handshake />} title="Assigned leads">
        {data.leads.length ? data.leads.map((lead) => renderLead(lead, pending, c.save)) :
          <EmptyState>No current assignments. A Catch lead owner will review identity and offer eligible leads here.</EmptyState>}
        {data.nextCursor && <AdminButton disabled={pending} onClick={() => c.setCursor(data.nextCursor)}>More leads</AdminButton>}
        {c.cursor && <AdminButton disabled={pending} onClick={() => c.setCursor(null)}>First page</AdminButton>}
      </Panel>
    </>}
  </AdminDirectoryScreenStack>;
}
function renderLead(lead: PartnerLead, pending: boolean,
  save: ReturnType<typeof usePartnerWorkspaceController>["save"]) {
  return <LeadReview key={`${lead.assignment.organizerId}:${lead.assignment.revision}`} lead={lead} pending={pending} save={save} />;
}
function LeadReview({lead, pending, save}: {lead: PartnerLead; pending: boolean;
  save: ReturnType<typeof usePartnerWorkspaceController>["save"]}) {
  const [relationship, setRelationship] = useState(lead.assignment.relationshipContext ?? "");
  const [channel, setChannel] = useState(lead.assignment.channel ?? "whatsapp");
  const [nextAction, setNextAction] = useState(lead.assignment.nextAction);
  const [reviewAt, setReviewAt] = useState(lead.assignment.reviewAt.slice(0, 16));
  return <Panel icon={<Handshake />} title={lead.organizer.name}>
    <p>{lead.organizer.city} · {lead.assignment.status} · claim: {lead.organizer.claimState}</p>
    <p>Next action: {lead.assignment.nextAction}. Review by {new Date(lead.assignment.reviewAt).toLocaleDateString()}.</p>
    {lead.assignment.status === "offered" && <AdminForm onSubmit={(e) => {e.preventDefault(); void save("decide", {
      organizerId: lead.organizer.organizerId, expectedRevision: lead.assignment.revision,
      decision: "accept", channel, relationshipContext: relationship.trim() || null});}}>
      <TextareaField rows={3} label="Relationship context" value={relationship} onChange={setRelationship} disabled={pending} />
      <SelectField label="Established contact channel" value={channel} onChange={setChannel} disabled={pending}
        options={[{value: "whatsapp", label: "WhatsApp"}, {value: "email", label: "Email"}, {value: "other", label: "Other"}]} />
      <AdminButton type="submit" disabled={pending}>Accept lead</AdminButton>
      <AdminButton disabled={pending} onClick={() => void save("decide", {
        organizerId: lead.organizer.organizerId, expectedRevision: lead.assignment.revision,
        decision: "decline", channel: null, relationshipContext: relationship.trim() || null})}>Decline</AdminButton>
    </AdminForm>}
    {lead.assignment.status === "accepted" && <AdminForm onSubmit={(e) => {
      e.preventDefault(); const date = new Date(`${reviewAt}:00.000Z`);
      if (!Number.isFinite(date.getTime())) return;
      void save("update", {organizerId: lead.organizer.organizerId,
        expectedRevision: lead.assignment.revision, relationshipContext: relationship.trim() || null,
        channel, nextAction: nextAction.trim(), reviewAt: date.toISOString()});
    }}>
      <TextareaField rows={3} label="Your relationship context (self-reported)" value={relationship}
        onChange={setRelationship} disabled={pending} />
      <SelectField label="Established contact channel" value={channel} onChange={setChannel} disabled={pending}
        options={[{value: "whatsapp", label: "WhatsApp"}, {value: "email", label: "Email"}, {value: "other", label: "Other"}]} />
      <TextField label="Next action" value={nextAction} onChange={setNextAction} disabled={pending} />
      <TextField label="Review at (UTC)" type="datetime-local" value={reviewAt} onChange={setReviewAt} disabled={pending} />
      <AdminButton type="submit" disabled={pending || !nextAction.trim() || !reviewAt}>Save private next step</AdminButton>
      <p>Saving context or a next step does not send outreach, claim or publish this organizer.</p>
    </AdminForm>}
  </Panel>;
}
