import {useEffect, useState} from "react";
import {ClipboardList} from "lucide-react";
import {AdminButton, AdminForm, Panel, SelectField, StateRow,
  TextareaField, TextField} from "../../../shared/ui/AdminPrimitives";
import type {DemoBlueprint, DemoCapabilityReview, DemoDisposition,
  DemoFieldMapping, DemoManagementApi, DemoPreviewCopy} from
  "../api/salesDemoManagement";
import {useSalesDemoManagementController} from
  "../controllers/useSalesDemoManagementController";

const reviewAreas = [
  ["questionTypes", "Question types"], ["branching", "Branching"],
  ["requiredFields", "Required fields"], ["scoringApproval", "Scoring and approval"],
  ["uploads", "Uploads"],
] as const;
const dispositions: Array<{value: DemoDisposition; label: string}> = [
  {value: "exact", label: "Works the same way"},
  {value: "manual", label: "Needs a manual step"},
  {value: "retained", label: "Keep the existing tool"},
  {value: "unsupported", label: "Not supported"},
];
type FormState = {preview: DemoPreviewCopy;
  review: DemoCapabilityReview; mappings: DemoFieldMapping[]};
function emptyForm(organizerName: string): FormState {
  return {preview: {brandName: organizerName.slice(0, 160), headline: "",
    scenario: "", steps: ["", "", ""], retainedTools: [],
    limitations: ["Synthetic example only; no real messages or admissions."],
    cta: "Try the example"},
  review: {questionTypes: "manual", branching: "manual",
    requiredFields: "manual", scoringApproval: "manual", uploads: "retained"},
  mappings: []};
}
function lines(values: string[]): string {return values.join("\n");}
function splitLines(value: string): string[] {
  return value.split(/\r?\n/u);
}
function normalizedLines(values: string[]): string[] {
  return values.map((part) => part.trim()).filter(Boolean);
}
function validOrigin(): string | null {
  try {
    const url = new URL(import.meta.env.VITE_ADMIN_PUBLIC_SITE_ORIGIN ??
      "https://catchdates.com");
    if (!["http:", "https:"].includes(url.protocol) || url.username ||
        url.password || url.pathname !== "/" || url.search || url.hash) {
      return null;
    }
    return url.origin;
  } catch {return null;}
}

/** Mount inside a host detail; the server independently checks adminOwner. */
export function SalesDemoWorkspace({organizerId, organizerName, isAdminOwner,
  currentUserUid, api}: {organizerId: string; organizerName: string;
  isAdminOwner: boolean; currentUserUid: string; api?: DemoManagementApi}) {
  if (!isAdminOwner) return <Panel title="Private workflow example"
    icon={<ClipboardList size={18} />}>
    <p>An Admin owner can prepare and issue private demos.</p>
  </Panel>;
  return <OwnerDemoPanel key={`${currentUserUid}:${organizerId}`}
    organizerId={organizerId} organizerName={organizerName}
    currentUserUid={currentUserUid} api={api} />;
}

function OwnerDemoPanel({organizerId, organizerName, currentUserUid, api}: {
  organizerId: string; organizerName: string; currentUserUid: string;
  api?: DemoManagementApi;
}) {
  const controller = useSalesDemoManagementController({isAdminOwner: true,
    actorUid: currentUserUid, organizerId, api});
  const [form, setForm] = useState<FormState>(() => emptyForm(organizerName));
  const [formRevision, setFormRevision] = useState(0);
  const [formBlueprintId, setFormBlueprintId] = useState<string | null>(null);
  const [dirty, setDirty] = useState(false);
  const [contactKind, setContactKind] = useState<"preview" | "email" | "phone">(
    "preview");
  const [contactValue, setContactValue] = useState("");
  const [expiresAt, setExpiresAt] = useState("");
  const [sessionCap, setSessionCap] = useState("1");
  const [copyNotice, setCopyNotice] = useState("");
  const selected = controller.blueprint.data;
  useEffect(() => {
    if (controller.confirmedSave?.blueprintId !== controller.blueprintId) return;
    setFormRevision(controller.confirmedSave.revision);
    setDirty(false);
  }, [controller.confirmedSave, controller.blueprintId]);
  useEffect(() => {
    if (!selected || dirty) return;
    if (controller.confirmedSave?.blueprintId === selected.blueprintId &&
        selected.revision < controller.confirmedSave.revision) return;
    setForm({preview: selected.preview,
      review: selected.formCapabilityReview,
      mappings: selected.fieldMappings});
    setFormRevision(selected.revision);
    setFormBlueprintId(selected.blueprintId);
  }, [selected, dirty, controller.confirmedSave]);
  const beginNew = () => {
    controller.newBlueprint();
    setForm(emptyForm(organizerName)); setFormRevision(0);
    setFormBlueprintId(null); setDirty(false); setCopyNotice("");
  };
  const selectBlueprint = (item: DemoBlueprint) => {
    controller.loadBlueprint(item.blueprintId);
    setForm({preview: item.preview, review: item.formCapabilityReview,
      mappings: item.fieldMappings});
    setFormRevision(item.revision); setFormBlueprintId(item.blueprintId);
    setDirty(false); setCopyNotice("");
  };
  const edit = (next: FormState) => {setForm(next); setDirty(true);};
  const stale = Boolean(selected && selected.revision !== formRevision &&
    selected.blueprintId === formBlueprintId);
  const active = controller.blueprintId !== null;
  const locked = controller.busy || Boolean(controller.pending);
  const capabilityReady = controller.capability.data?.enabled === true;
  const previewValid = Boolean(form.preview.brandName.trim() &&
    form.preview.headline.trim() && form.preview.scenario.trim() &&
    form.preview.steps.length === 3 &&
    form.preview.steps.every((step) => step.trim()) &&
    normalizedLines(form.preview.limitations).length);
  const expiryMillis = Date.parse(expiresAt);
  const expiryValid = Number.isFinite(expiryMillis) &&
    expiryMillis > Date.now() && expiryMillis <= Date.now() + 7 * 86_400_000;
  const save = async () => {
    if (!controller.blueprintId || !capabilityReady || !previewValid ||
        stale || locked || selected?.state === "withdrawn") return;
    await controller.save({blueprintId: controller.blueprintId,
      expectedRevision: formRevision, organizerId, candidateId: null,
      opportunityId: null,
      evidenceRevision: controller.capability.data!.evidenceRevision,
      preview: {...form.preview,
        retainedTools: normalizedLines(form.preview.retainedTools),
        limitations: normalizedLines(form.preview.limitations)},
      formCapabilityReview: form.review,
      fieldMappings: form.mappings});
  };
  const issue = async () => {
    if (!selected || selected.state !== "reviewed" || locked || stale ||
        dirty || !expiryValid) return;
    const parsed = expiryMillis;
    const cap = Number(sessionCap);
    if (!Number.isFinite(parsed) || !Number.isInteger(cap) ||
        cap < 1 || cap > 3) return;
    const binding = contactKind === "preview" ? null :
      {kind: contactKind, value: contactValue.trim()};
    await controller.issue({blueprintId: selected.blueprintId,
      blueprintRevision: formRevision, contactBinding: binding,
      expiresAt: new Date(parsed).toISOString(), sessionCap: cap});
    setContactValue("");
  };
  const copyLink = async () => {
    const issued = controller.issuedGrant;
    const origin = validOrigin();
    if (!issued || !origin || !/^[A-Za-z0-9_-]{43}$/u.test(
      issued.grantToken)) return;
    const link = `${origin}/demo/${encodeURIComponent(issued.invitationId)}`+
      `#grant=${issued.grantToken}`;
    try {
      await navigator.clipboard.writeText(link);
      setCopyNotice("Private link copied. Share it only with the intended contact.");
    } catch {setCopyNotice("The link could not be copied. Try again.");}
  };

  return <Panel title="Private workflow example" icon={<ClipboardList size={18} />}>
    <p>Build a private, synthetic example for {organizerName}. No real guests,
      messages, charges, membership, or publication are changed.</p>
    {controller.capability.isPending ? <p>Checking supported example…</p> : null}
    {!capabilityReady ? <p role="alert">The supported demo capability is
      unavailable. The demo has not been enabled for this environment.</p> : null}
    {controller.error ? <p role="alert">{controller.error}</p> : null}
    {controller.notice ? <p role="status">{controller.notice}</p> : null}
    {controller.pending ? <AdminButton disabled={controller.busy}
      onClick={() => void controller.retry()}>Retry unchanged request</AdminButton> : null}
    <h3>Saved examples</h3>
    {controller.blueprintList.isError ? <p role="alert">Saved examples could not be
      loaded. <AdminButton onClick={() => void controller.blueprintList.refetch()}>
        Try again</AdminButton></p> : null}
    {controller.blueprintList.data?.rows.map((item) =>
      <StateRow key={item.blueprintId} label={item.preview.headline}
        value={<>{item.state} · revision {item.revision}{" "}
          <AdminButton disabled={locked}
            onClick={() => selectBlueprint(item)}>Open</AdminButton></>} />)}
    {controller.blueprintList.data?.nextCursor ? <AdminButton disabled={locked}
      onClick={() => controller.nextBlueprintPage(
        controller.blueprintList.data!.nextCursor!)}>
        More examples</AdminButton> : null}
    {controller.blueprintHistory.length ? <AdminButton disabled={locked}
      onClick={controller.previousBlueprintPage}>Previous examples</AdminButton> : null}
    {controller.blueprintHistory.length > 1 ? <AdminButton disabled={locked}
      onClick={controller.firstBlueprintPage}>First examples</AdminButton> : null}
    <AdminButton disabled={locked || !capabilityReady}
      onClick={beginNew}>New example</AdminButton>
    {active ? <>
      <h3>{selected ? "Edit example" : "New example"}</h3>
      {controller.blueprint.isError ? <p role="alert">This blueprint could not
        be loaded. Choose it again from the list.</p> : null}
      {stale ? <p role="alert">This blueprint changed while you were editing.
        Review the current version before saving.</p> : null}
      <BlueprintEditor form={form} edit={edit} disabled={locked ||
        selected?.state === "withdrawn"} />
      <AdminButton variant="primary" disabled={locked || !capabilityReady ||
        !previewValid || stale || selected?.state === "withdrawn" ||
        (controller.blueprintExists && !dirty)} onClick={() => void save()}>
        Save draft</AdminButton>
      {selected?.state === "draft" ? <AdminButton disabled={locked || dirty ||
        stale} onClick={() => void controller.change("review",
        selected.blueprintId, formRevision)}>Mark reviewed</AdminButton> : null}
      {selected && selected.state !== "withdrawn" ? <AdminButton
        disabled={locked || dirty || stale}
        onClick={() => void controller.change("withdraw",
          selected.blueprintId, formRevision)}>Withdraw example</AdminButton> : null}
      {selected?.state === "reviewed" && !dirty ? <>
        <h3>Issue private invitation</h3>
        <p>An unbound link shows the preview only. Interactive access requires
          an intended email or verified phone.</p>
        <AdminForm onSubmit={(event) => {event.preventDefault(); void issue();}}>
          <SelectField label="Who may try it?" value={contactKind}
            onChange={(value) => setContactKind(value as typeof contactKind)}
            disabled={locked} options={[
              {value: "preview", label: "Preview only"},
              {value: "email", label: "Verified email"},
              {value: "phone", label: "Verified phone"},
            ]} />
          {contactKind !== "preview" ? <TextField label={contactKind === "email" ?
            "Intended email" : "Intended phone (+country code)"}
          type={contactKind === "email" ? "email" : "tel"}
          value={contactValue} onChange={setContactValue} disabled={locked} /> : null}
          <TextField label="Expires (within seven days)" type="datetime-local"
            value={expiresAt}
            onChange={setExpiresAt} disabled={locked} />
          {expiresAt && !expiryValid ? <p role="alert">Choose a future expiry
            within seven days.</p> : null}
          <SelectField label="Maximum trial sessions" value={sessionCap}
            onChange={setSessionCap} disabled={locked} options={[
              {value: "1", label: "One"}, {value: "2", label: "Two"},
              {value: "3", label: "Three"},
            ]} />
          <AdminButton type="submit" variant="primary" disabled={locked ||
            !expiryValid || (contactKind !== "preview" && !contactValue.trim())}>
            Issue invitation</AdminButton>
        </AdminForm>
      </> : null}
      <h3>Invitations</h3>
      {controller.invitationList.isPending ? <p>Loading invitations…</p> : null}
      {controller.invitationList.isError ? <p role="alert">Invitations could not
        be loaded. <AdminButton onClick={() => void controller.invitationList.refetch()}>
          Try again</AdminButton></p> : null}
      {controller.invitationList.data?.rows.map((item) =>
        <StateRow key={item.invitationId} label={item.revoked ?
          "Revoked invitation" : "Active invitation"} value={<>
          Expires {new Date(item.expiresAt).toLocaleString()} ·
          {item.sessionCount}/{item.sessionCap} sessions{" "}
          {!item.revoked ? <AdminButton disabled={locked}
            onClick={() => void controller.revoke(item.invitationId,
              item.revision)}>Revoke</AdminButton> : null}</>} />)}
      {controller.invitationList.data?.nextCursor ? <AdminButton
        disabled={locked} onClick={() => controller.nextInvitationPage(
          controller.invitationList.data!.nextCursor!)}>
          More invitations</AdminButton> : null}
      {controller.invitationHistory.length ? <AdminButton disabled={locked}
        onClick={controller.previousInvitationPage}>Previous invitations</AdminButton> : null}
      {controller.invitationHistory.length > 1 ? <AdminButton disabled={locked}
        onClick={controller.firstInvitationPage}>First invitations</AdminButton> : null}
      {controller.issuedGrant ? <p role="status">Invitation issued.
        The private link is available here until you leave this view.</p> : null}
      {controller.issuedGrant && validOrigin() ? <AdminButton disabled={locked}
        onClick={() => void copyLink()}>Copy private link</AdminButton> : null}
      {controller.issuedGrant && !validOrigin() ? <p role="alert">
        Public site origin is unavailable; link copying is disabled.</p> : null}
      {copyNotice ? <p role="status">{copyNotice}</p> : null}
    </> : null}
  </Panel>;
}

function BlueprintEditor({form, edit, disabled}: {form: FormState;
  edit: (next: FormState) => void; disabled: boolean}) {
  const setPreview = (patch: Partial<DemoPreviewCopy>) => edit({...form,
    preview: {...form.preview, ...patch}});
  return <AdminForm onSubmit={(event) => event.preventDefault()}>
    <TextField label="Host name in preview" value={form.preview.brandName}
      onChange={(brandName) => setPreview({brandName})} disabled={disabled} />
    <TextField label="Headline" value={form.preview.headline}
      onChange={(headline) => setPreview({headline})} disabled={disabled} />
    <TextareaField label="Scenario" rows={2} value={form.preview.scenario}
      onChange={(scenario) => setPreview({scenario})} disabled={disabled} />
    {form.preview.steps.map((step, index) => <TextField
      key={index} label={`Synthetic step ${index + 1}`} value={step}
      onChange={(value) => setPreview({steps: form.preview.steps.map(
        (part, at) => at === index ? value : part)})} disabled={disabled} />)}
    <TextareaField label="Tools that stay in place (one per line)" rows={3}
      value={lines(form.preview.retainedTools)} disabled={disabled}
      onChange={(value) => setPreview({retainedTools: splitLines(value)})} />
    <TextareaField label="Limits to disclose (one per line)" rows={3}
      value={lines(form.preview.limitations)} disabled={disabled}
      onChange={(value) => setPreview({limitations: splitLines(value)})} />
    <TextField label="Try button text" value={form.preview.cta}
      onChange={(cta) => setPreview({cta})} disabled={disabled} />
    <h4>Form capability review</h4>
    {reviewAreas.map(([area, label]) => <SelectField key={area}
      label={label} value={form.review[area]} disabled={disabled}
      options={dispositions} onChange={(value) => edit({...form,
        review: {...form.review, [area]: value as DemoDisposition}})} />)}
    <h4>Field mapping</h4>
    {form.mappings.map((mapping, index) => <div key={index}>
      <TextField label={`Source field ${index + 1}`}
        value={mapping.sourceField} disabled={disabled}
        onChange={(sourceField) => edit({...form,
          mappings: form.mappings.map((part, at) => at === index ?
            {...part, sourceField} : part)})} />
      <TextField label={`Catch field ${index + 1} (if supported)`}
        value={mapping.catchField ?? ""} disabled={disabled}
        onChange={(catchField) => edit({...form,
          mappings: form.mappings.map((part, at) => at === index ?
            {...part, catchField: catchField || null} : part)})} />
      <SelectField label={`Mapping outcome ${index + 1}`}
        value={mapping.disposition} disabled={disabled}
        options={dispositions} onChange={(value) => edit({...form,
          mappings: form.mappings.map((part, at) => at === index ?
            {...part, disposition: value as DemoDisposition} : part)})} />
      <AdminButton disabled={disabled} onClick={() => edit({...form,
        mappings: form.mappings.filter((_, at) => at !== index)})}>
        Remove mapping</AdminButton>
    </div>)}
    <AdminButton disabled={disabled || form.mappings.length >= 30}
      onClick={() => edit({...form, mappings: [...form.mappings,
        {sourceField: "", catchField: null, disposition: "manual"}]})}>
      Add field mapping</AdminButton>
  </AdminForm>;
}
