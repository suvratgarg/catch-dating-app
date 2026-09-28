import {useEffect, useMemo, useState} from "react";
import {ArrowLeft, CalendarDays, ClipboardList, Search} from "lucide-react";
import {
  AdminButton, AdminDetailScreenStack, AdminDirectoryScreenStack,
  AdminForm, AdminTableRow, AdminTag, AdminToolbar, DataTable, EmptyState,
  PageHeader, Panel, SearchField, SegmentedControl, SelectField, StateRow,
  TableActionButton, TextareaField, TextField,
} from "../../../shared/ui/AdminPrimitives";
import {useAdminFeedback} from "../../../shared/feedback/AdminFeedbackContext";
import {dataMode} from "../../../shared/api/dataMode";
import {
  accountFormValues, researchStatusOptions, toLocalDateTimeInput,
  type SalesWorkspaceController,
  useSalesWorkspaceController,
} from "../controllers/useSalesWorkspaceController";
import type {
  SalesAccountDetail, SalesCustomFieldDefinition, SalesCustomFieldType,
  SalesInboundIntent, SalesOpportunity,
  SalesResearchStatus, SalesTask,
} from "../api/salesTypes";
import {SalesRecordsWorkspace} from "./SalesRecordsPanels";
import {SalesImportWorkspace} from "./SalesImportPanel";
import {SalesDemoWorkspace} from "./SalesDemoPanel";
import {SalesIntelligenceWorkspace} from "./SalesIntelligenceWorkspace";
import {renderSalesCommercialWorkspace} from "./SalesCommercialWorkspace";
import {renderSalesFitQueueWorkspace} from "./SalesFitQueueWorkspace";

type SalesArea = "today" | "hosts" | "pipeline" | "research" | "pilots" | "settings";
type DetailTab = "overview" | "people" | "workflow" | "activity" |
  "opportunities" | "research" | "demo" | "commercial" | "intelligence";

const areaOptions: Array<{id: SalesArea; label: string}> = [
  {id: "today", label: "Today"},
  {id: "hosts", label: "Hosts"},
  {id: "pipeline", label: "Pipeline"},
  {id: "research", label: "Research"},
  {id: "pilots", label: "Pilots"},
  {id: "settings", label: "Settings"},
];
const detailTabs: Array<{id: DetailTab; label: string}> = [
  {id: "overview", label: "Overview"},
  {id: "people", label: "People"},
  {id: "workflow", label: "Workflow"},
  {id: "demo", label: "Private demo"},
  {id: "activity", label: "Activity"},
  {id: "opportunities", label: "Opportunities"},
  {id: "intelligence", label: "Fit & outreach"},
  {id: "commercial", label: "Pilot & terms"},
  {id: "research", label: "Research"},
];
const stageOptions = [
  {value: "", label: "All stages"},
  {value: "new_enquiry", label: "New enquiry"},
  {value: "ready_to_contact", label: "Ready to contact"},
  {value: "contacted", label: "Contacted"},
  {value: "in_conversation", label: "In conversation"},
  {value: "demo_arranged", label: "Demo arranged"},
  {value: "demo_completed", label: "Demo completed"},
  {value: "pilot_agreed", label: "Pilot agreed"},
  {value: "pilot_running", label: "Pilot running"},
  {value: "commercial_discussion", label: "Commercial discussion"},
  {value: "closed_won", label: "Closed won"},
  {value: "closed_lost", label: "Closed lost"},
];

function labelFor(value: string | null | undefined): string {
  if (!value) return "Not recorded";
  return value.replaceAll("_", " ").replace(/\b\w/gu, (letter) =>
    letter.toUpperCase());
}

function dateLabel(value: string | null | undefined): string {
  if (!value) return "No date";
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value :
    date.toLocaleDateString(undefined, {day: "numeric", month: "short", year: "numeric"});
}

function ownerLabel(uid: string | null | undefined, currentUserUid: string): string {
  if (!uid) return "Unassigned";
  return uid === currentUserUid ? "You" : "Another teammate";
}

export function SalesWorkspaceScreen({
  area,
  currentUserUid,
  isAdminOwner = false,
  selectedOrganizerId,
  onAreaChange,
  onOpenHost,
  onBackToHosts,
  onOpenIntake,
  onOpenOrganizer,
}: {
  area: SalesArea;
  currentUserUid: string;
  isAdminOwner?: boolean;
  selectedOrganizerId: string | null;
  onAreaChange: (area: SalesArea) => void;
  onOpenHost: (organizerId: string) => void;
  onBackToHosts: () => void;
  onOpenIntake: () => void;
  onOpenOrganizer: (organizerId: string) => void;
}) {
  const {setError, setNotice} = useAdminFeedback();
  const controller = useSalesWorkspaceController({
    area, selectedOrganizerId, onError: setError, onNotice: setNotice,
  });
  const pageTitle = selectedOrganizerId ?
    controller.detail.data?.organizerSummary.name ?? "Host" :
    areaOptions.find((option) => option.id === area)?.label ?? "Sales";

  return (
    <AdminDirectoryScreenStack>
      <PageHeader eyebrow="Sales" title={pageTitle} actions={selectedOrganizerId ? (
        <AdminButton icon={<ArrowLeft size={16} />} onClick={onBackToHosts}>
          Back to hosts
        </AdminButton>
      ) : undefined}>
        {selectedOrganizerId ? "Private host workspace" :
          "Keep research, conversations, tasks and opportunities together."}
        {dataMode() === "sample" ? " Sample data is shown." : ""}
      </PageHeader>
      {!selectedOrganizerId ? (
        <SegmentedControl ariaLabel="Sales area" mobileLayout="content"
          mobileSelectLabel="Sales area" options={areaOptions}
          value={area} onChange={onAreaChange} />
      ) : null}
      {selectedOrganizerId ? (
        <HostDetail controller={controller} currentUserUid={currentUserUid}
          isAdminOwner={isAdminOwner} onOpenOrganizer={onOpenOrganizer} />
      ) : area === "today" ? (
        <TodayView controller={controller} currentUserUid={currentUserUid}
          onOpenHost={onOpenHost} />
      ) : area === "hosts" ? (
        <HostsView controller={controller} currentUserUid={currentUserUid}
          onOpenHost={onOpenHost} onOpenIntake={onOpenIntake} />
      ) : area === "pipeline" ? (
        <PipelineView controller={controller} currentUserUid={currentUserUid}
          onOpenHost={onOpenHost} />
      ) : area === "research" ? (
        <ResearchView controller={controller} onOpenHost={onOpenHost}
          onOpenIntake={onOpenIntake} />
      ) : area === "pilots" ? (
        <PilotsView controller={controller} onOpenHost={onOpenHost} />
      ) : (
        <SettingsView controller={controller} isAdminOwner={isAdminOwner} />
      )}
    </AdminDirectoryScreenStack>
  );
}

function QueryState({
  loading, error, empty, onRetry,
}: {loading: boolean; error: unknown; empty: boolean; onRetry: () => void}) {
  if (loading) return <EmptyState>Loading sales records…</EmptyState>;
  if (error) return <EmptyState>
    Sales records could not be loaded. <AdminButton onClick={onRetry}>Try again</AdminButton>
  </EmptyState>;
  if (empty) return <EmptyState>No records match this view.</EmptyState>;
  return null;
}

function TodayView({
  controller, currentUserUid, onOpenHost,
}: {controller: SalesWorkspaceController; currentUserUid: string;
  onOpenHost: (id: string) => void}) {
  const rows = controller.tasks.data?.rows ?? [];
  const now = Date.now();
  const groups = [
    {title: "Needs a reply", icon: <ClipboardList size={18} />,
      matches: (task: SalesTask) => /reply|inbound/iu.test(task.kind)},
    {title: "Follow-ups due", icon: <CalendarDays size={18} />,
      matches: (task: SalesTask) => !/reply|inbound|draft|pilot|research/iu.test(task.kind) &&
        Boolean(task.dueAt) && new Date(task.dueAt!).getTime() <= now},
    {title: "Ready to review", icon: <ClipboardList size={18} />,
      matches: (task: SalesTask) => /draft|review/iu.test(task.kind)},
    {title: "Pilots need attention", icon: <CalendarDays size={18} />,
      matches: (task: SalesTask) => /pilot/iu.test(task.kind)},
    {title: "Research blockers", icon: <Search size={18} />,
      matches: (task: SalesTask) => /research|duplicate/iu.test(task.kind)},
    {title: "Coming up", icon: <ClipboardList size={18} />,
      matches: (task: SalesTask) => !/reply|inbound|draft|review|pilot|research|duplicate/iu
        .test(task.kind) && Boolean(task.dueAt) &&
        new Date(task.dueAt!).getTime() > now},
    {title: "Needs a date", icon: <CalendarDays size={18} />,
      matches: (task: SalesTask) => !task.dueAt &&
        !/reply|inbound|draft|review|pilot|research|duplicate/iu.test(task.kind)},
  ];
  return <>
    <Panel title="Today's work" icon={<CalendarDays size={18} />}>
      <p>Tasks are shown in priority groups from this server page. Open a host to
        record the outcome and set the next step.</p>
      <QueryState loading={controller.tasks.isPending} error={controller.tasks.error}
        empty={!rows.length} onRetry={() => void controller.tasks.refetch()} />
    </Panel>
    {groups.map((group) => {
      const members = rows.filter(group.matches);
      return <Panel key={group.title} title={group.title} icon={group.icon}>
        {members.length ? members.map((task) => <TaskRow key={task.taskId}
          task={task} currentUserUid={currentUserUid}
          onOpenHost={onOpenHost} />) :
          <EmptyState>Nothing in this group on this page.</EmptyState>}
      </Panel>;
    })}
    <Pagination hasPrevious={controller.hasPreviousTaskPage}
      hasNext={Boolean(controller.tasks.data?.nextCursor)}
      onPrevious={controller.previousTaskPage} onNext={controller.nextTaskPage} />
  </>;
}

function TaskRow({task, currentUserUid, onOpenHost}: {
  task: SalesTask; currentUserUid: string; onOpenHost: (id: string) => void;
}) {
  return <StateRow label={task.title} value={<>
    {labelFor(task.kind)} · {dateLabel(task.dueAt)} · Owner {ownerLabel(
      task.ownerUid, currentUserUid)}
    {task.reason ? <> · {task.reason}</> : null}{" "}
    <AdminButton onClick={() => onOpenHost(task.organizerId)}>Open host</AdminButton>
  </>} />;
}

function HostsView({controller, currentUserUid, onOpenHost, onOpenIntake}: {
  controller: SalesWorkspaceController;
  currentUserUid: string;
  onOpenHost: (id: string) => void;
  onOpenIntake: () => void;
}) {
  const [showAddHost, setShowAddHost] = useState(false);
  const [selectedCanonicalId, setSelectedCanonicalId] = useState("");
  const rows = controller.accounts.data?.rows ?? [];
  return <>
  {renderSalesFitQueueWorkspace(currentUserUid, onOpenHost)}
  {showAddHost ? <Panel title="Add a host" icon={<Search size={18} />}>
    <p>First find the existing organizer identity. Adding it to Sales creates a
      private record and does not publish a listing or approve a claim.</p>
    <SearchField ariaLabel="Search existing organizers" icon={<Search size={16} />}
      value={controller.canonicalSearch} placeholder="Organizer name"
      onChange={(value) => {
        controller.setCanonicalSearch(value); setSelectedCanonicalId("");
      }} />
    {controller.canonicalMatches.isPending ? <p>Searching organizers…</p> : null}
    {controller.canonicalMatches.error ? <p role="alert">
      Organizer search failed. Try again.</p> : null}
    {controller.canonicalMatches.data?.length ? <SelectField
      label="Reviewed organizer" value={selectedCanonicalId}
      onChange={setSelectedCanonicalId} options={[
        {value: "", label: "Choose a matching organizer"},
        ...controller.canonicalMatches.data.map((item) => ({
          value: item.clubId,
          label: `${item.name} · ${item.cityName || "Location unknown"} · ${labelFor(item.publishStatus)}`,
        })),
      ]} /> : null}
    <AdminToolbar>
      <AdminButton variant="primary" disabled={!selectedCanonicalId || controller.isSaving}
        onClick={() => void controller.addAccount({
          organizerId: selectedCanonicalId,
        }).then((saved) => {
          if (saved) onOpenHost(selectedCanonicalId);
        })}>Add selected host to Sales</AdminButton>
      <AdminButton onClick={onOpenIntake}>Review a new organizer in Intake</AdminButton>
      <AdminButton onClick={() => setShowAddHost(false)}>Cancel</AdminButton>
    </AdminToolbar>
  </Panel> : null}
  <Panel title="Hosts" icon={<ClipboardList size={18} />} action={
    <AdminButton onClick={() => setShowAddHost(true)}>Add host</AdminButton>
  }>
    <AdminToolbar>
      <SearchField ariaLabel="Search a name, city, or market word"
        icon={<Search size={16} />}
        placeholder="One word, at least two letters" value={controller.query}
        onChange={(query) => controller.setAccountFilters({query})} />
      {!controller.validAccountQuery ? <p role="status">
        Search one word of 2–80 letters or numbers.</p> : null}
      <SelectField label="Research status" value={controller.researchStatus}
        onChange={(value) => controller.setAccountFilters({
          researchStatus: value as "all" | SalesResearchStatus,
        })}
        options={[{value: "all", label: "All research statuses"},
          ...researchStatusOptions]} />
      <SelectField label="Owner" value={controller.ownerUid ? "mine" : "all"}
        onChange={(value) => controller.setAccountFilters({
          ownerUid: value === "mine" ? currentUserUid : "",
        })} options={[{value: "all", label: "All owners"},
          {value: "mine", label: "Assigned to me"}]} />
    </AdminToolbar>
    <QueryState loading={controller.accounts.isPending} error={controller.accounts.error}
      empty={!rows.length} onRetry={() => void controller.accounts.refetch()} />
    {rows.length ? <DataTable ariaLabel="Sales hosts">
      <thead><tr>
        <th>Host</th><th>Market</th><th>Events</th><th>Fit</th>
        <th>Research</th><th>Stage</th><th>Owner</th><th>Next step</th><th />
      </tr></thead><tbody>
        {rows.map((row) => <AdminTableRow key={row.organizerId}>
          <td><strong>{row.name}</strong></td>
          <td>{[row.city, row.marketLabel].filter(Boolean).join(", ") || "Not recorded"}</td>
          <td>{row.eventTypes?.join(", ") || "Not recorded"}</td>
          <td>{row.fitLabel || "Needs review"}</td>
          <td>{labelFor(row.researchStatus)}</td>
          <td>{labelFor(row.stage)}</td>
          <td>{ownerLabel(row.assignedOwnerUid, currentUserUid)}</td>
          <td>{row.nextAction || "Not set"}</td>
          <td><TableActionButton onClick={() => onOpenHost(row.organizerId)}>
            Open
          </TableActionButton></td>
        </AdminTableRow>)}
      </tbody>
    </DataTable> : null}
    <Pagination hasPrevious={controller.hasPreviousPage}
      hasNext={Boolean(controller.accounts.data?.nextCursor)}
      onPrevious={controller.previousPage} onNext={controller.nextPage} />
  </Panel>
  </>;
}

function Pagination({hasPrevious, hasNext, onPrevious, onNext}: {
  hasPrevious: boolean; hasNext: boolean;
  onPrevious: () => void; onNext: () => void;
}) {
  return <AdminToolbar>
    <AdminButton disabled={!hasPrevious} onClick={onPrevious}>Previous page</AdminButton>
    <AdminButton disabled={!hasNext} onClick={onNext}>Next page</AdminButton>
  </AdminToolbar>;
}

function PipelineView({controller, currentUserUid, onOpenHost}: {
  controller: SalesWorkspaceController; currentUserUid: string;
  onOpenHost: (id: string) => void;
}) {
  const rows = controller.opportunities.data?.rows ?? [];
  return <Panel title="Opportunities" icon={<ClipboardList size={18} />}>
    <p>Stages describe commercial work. Organizer ownership and product activation are managed separately.</p>
    <SelectField label="Stage" value={controller.opportunityStage}
      onChange={controller.setStageFilter} options={stageOptions} />
    <QueryState loading={controller.opportunities.isPending}
      error={controller.opportunities.error} empty={!rows.length}
      onRetry={() => void controller.opportunities.refetch()} />
    {rows.length ? <DataTable ariaLabel="Sales opportunities">
      <thead><tr><th>Motion</th><th>Stage</th><th>Owner</th>
        <th>Next step</th><th>Due</th><th /></tr></thead>
      <tbody>{rows.map((row) => <AdminTableRow key={row.opportunityId}>
        <td>{labelFor(row.motion)}</td><td>{labelFor(row.stage)}</td>
        <td>{ownerLabel(row.ownerUid, currentUserUid)}</td>
        <td>{row.nextStep || "Not set"}</td>
        <td>{dateLabel(row.nextStepAt)}</td>
        <td><TableActionButton onClick={() => onOpenHost(row.organizerId)}>
          Open host
        </TableActionButton></td>
      </AdminTableRow>)}</tbody>
    </DataTable> : null}
    <Pagination hasPrevious={controller.hasPreviousOpportunityPage}
      hasNext={Boolean(controller.opportunities.data?.nextCursor)}
      onPrevious={controller.previousOpportunityPage}
      onNext={controller.nextOpportunityPage} />
  </Panel>;
}

function ResearchView({controller, onOpenHost, onOpenIntake}: {
  controller: SalesWorkspaceController; onOpenHost: (id: string) => void;
  onOpenIntake: () => void;
}) {
  return <>
    <InboundReview controller={controller} onOpenIntake={onOpenIntake} />
    <Panel title="Research review" icon={<Search size={18} />}>
      <p>Use the host record to capture a sourced summary, owner and next action.
        Qualification and fit remain separate decisions.</p>
      <SelectField label="Research status" value={controller.researchStatus}
        onChange={(value) => controller.setAccountFilters({
          researchStatus: value as "all" | SalesResearchStatus,
        })} options={[{value: "all", label: "All"}, ...researchStatusOptions]} />
      <QueryState loading={controller.accounts.isPending} error={controller.accounts.error}
        empty={!controller.accounts.data?.rows.length}
        onRetry={() => void controller.accounts.refetch()} />
      {controller.accounts.data?.rows.map((row) => <StateRow
        key={row.organizerId} label={row.name} value={<>
          {labelFor(row.researchStatus)} · {row.fitLabel || "Fit not assessed"}{" "}
          <AdminButton onClick={() => onOpenHost(row.organizerId)}>Review</AdminButton>
        </>} />)}
      <Pagination hasPrevious={controller.hasPreviousPage}
        hasNext={Boolean(controller.accounts.data?.nextCursor)}
        onPrevious={controller.previousPage} onNext={controller.nextPage} />
    </Panel>
  </>;
}

function InboundReview({controller, onOpenIntake}: {
  controller: SalesWorkspaceController; onOpenIntake: () => void;
}) {
  const [selectedId, setSelectedId] = useState("");
  const [matchId, setMatchId] = useState("");
  const selected = controller.inboundIntents.data?.rows.find((row) =>
    row.intentId === selectedId);
  const matches = controller.identityMatches.data?.rows ?? [];
  const select = (intent: SalesInboundIntent) => {
    setSelectedId(intent.intentId);
    setMatchId("");
    const firstWord = intent.fullName.trim().match(/[A-Za-z0-9]{2,80}/u)?.[0] ?? "";
    controller.setIdentitySearch(firstWord);
  };
  const link = async () => {
    if (!selected || !matchId) return;
    const linked = await controller.linkInboundIntent({
      intentId: selected.intentId, organizerId: matchId,
      expectedRevision: selected.revision,
    });
    if (linked) {setSelectedId(""); setMatchId("");
      controller.setIdentitySearch("");}
  };
  return <Panel title="New website enquiries" icon={<Search size={18} />}>
    <p>These details were entered by the sender. Review the identity before attaching
      an enquiry to a host; linking does not approve an organizer claim.</p>
    <QueryState loading={controller.inboundIntents.isPending}
      error={controller.inboundIntents.error}
      empty={!controller.inboundIntents.data?.rows.length}
      onRetry={() => void controller.inboundIntents.refetch()} />
    {controller.inboundIntents.data?.rows.map((intent) =>
      <StateRow key={intent.intentId} label={intent.fullName} value={<>
        {intent.city || "City not supplied"} · {dateLabel(intent.createdAt)} ·
        Self reported{" "}
        <AdminButton onClick={() => select(intent)}>Review match</AdminButton>
      </>} />)}
    <Pagination hasPrevious={controller.hasPreviousInboundPage}
      hasNext={Boolean(controller.inboundIntents.data?.nextCursor)}
      onPrevious={controller.previousInboundPage}
      onNext={controller.nextInboundPage} />
    {selected ? <AdminForm onSubmit={(event) => {event.preventDefault(); void link();}}>
      <h3>Match enquiry from {selected.fullName}</h3>
      <SearchField ariaLabel="Search existing hosts for this enquiry"
        icon={<Search size={16} />} placeholder="One name, city, or market word"
        value={controller.identitySearch}
        onChange={(value) => {controller.setIdentitySearch(value); setMatchId("");}} />
      <SelectField label="Existing host" value={matchId} onChange={setMatchId}
        options={[{value: "", label: "Choose a reviewed match"},
          ...matches.map((row) => ({value: row.organizerId,
            label: `${row.name} · ${row.city || row.marketLabel || "Location unknown"}`}))]} />
      {controller.identityMatches.isPending ? <p>Searching hosts…</p> : null}
      {controller.identitySearch.trim() &&
        !/^[A-Za-z0-9]{2,80}$/u.test(controller.identitySearch.trim()) ?
        <p role="status">Search one word of 2–80 letters or numbers.</p> : null}
      {controller.identityMatches.error ? <p role="alert">
        Host search failed. Try another search.</p> : null}
      {controller.identityMatches.data?.nextCursor ? <p>
        More matches exist. Narrow the search before linking.</p> : null}
      <AdminToolbar>
        <AdminButton type="submit" variant="primary"
          disabled={!matchId || controller.isSaving}>Link to selected host</AdminButton>
        <AdminButton onClick={onOpenIntake}>Review as a new host</AdminButton>
        <AdminButton onClick={() => setSelectedId("")}>Cancel</AdminButton>
      </AdminToolbar>
    </AdminForm> : null}
  </Panel>;
}

function PilotsView({controller, onOpenHost}: {
  controller: SalesWorkspaceController; onOpenHost: (id: string) => void;
}) {
  return <Panel title="Pilots" icon={<ClipboardList size={18} />}>
    <p>Select a pilot stage to see its opportunities and next commitments. Pilot outcomes
      require linked evidence before a commercial or reference claim is made.</p>
    <SelectField label="Pilot stage" value={controller.opportunityStage}
      onChange={controller.setStageFilter} options={[
        {value: "", label: "All opportunities"},
        {value: "pilot_agreed", label: "Pilot agreed"},
        {value: "pilot_running", label: "Pilot running"},
      ]} />
    <QueryState loading={controller.opportunities.isPending}
      error={controller.opportunities.error}
      empty={!controller.opportunities.data?.rows.length}
      onRetry={() => void controller.opportunities.refetch()} />
    {controller.opportunities.data?.rows.map((item) =>
      <StateRow key={item.opportunityId} label={labelFor(item.stage)} value={<>
        {item.nextStep || "No next step"} · {dateLabel(item.nextStepAt)}{" "}
        <AdminButton onClick={() => onOpenHost(item.organizerId)}>Open host</AdminButton>
      </>} />)}
    <Pagination hasPrevious={controller.hasPreviousOpportunityPage}
      hasNext={Boolean(controller.opportunities.data?.nextCursor)}
      onPrevious={controller.previousOpportunityPage}
      onNext={controller.nextOpportunityPage} />
  </Panel>;
}

function customFieldId(label: string): string {
  const slug = label.trim().normalize("NFKD").toLowerCase()
    .replace(/[^a-z0-9]+/gu, "_").replace(/^_+|_+$/gu, "");
  return slug ? `sales.${slug}` : "";
}

function SettingsView({controller, isAdminOwner}: {
  controller: SalesWorkspaceController; isAdminOwner: boolean;
}) {
  const [label, setLabel] = useState("");
  const [type, setType] = useState<SalesCustomFieldType>("string");
  const [helpText, setHelpText] = useState("");
  const [enumText, setEnumText] = useState("");
  const [localError, setLocalError] = useState("");
  const fields = controller.customFields.data?.rows ?? [];
  const id = customFieldId(label);
  const similar = fields.filter((field) => field.fieldId === id ||
    field.label.toLocaleLowerCase().includes(label.trim().toLocaleLowerCase()))
    .filter(() => label.trim().length >= 3);
  const enumOptions = enumText.split(",").map((value) => value.trim())
    .filter(Boolean);
  const save = async () => {
    if (!id) {setLocalError("Enter a field label with letters or numbers."); return;}
    if (type === "enum" && !enumOptions.length) {
      setLocalError("Add at least one choice for this field."); return;
    }
    if (similar.some((field) => field.fieldId === id)) {
      setLocalError("A field with this name already exists. Review it below.");
      return;
    }
    setLocalError("");
    const saved = await controller.addCustomField({field: {
      fieldId: id, label: label.trim(), type, recordType: "account",
      helpText: helpText.trim() || undefined,
      enumOptions: type === "enum" ? enumOptions : undefined,
    }});
    if (saved) {setLabel(""); setHelpText(""); setEnumText("");}
  };
  return <><Panel title="Sales settings" icon={<ClipboardList size={18} />}>
    <p>Add a private account field when the team needs the same information for
      several hosts. Check existing fields first.</p>
    <QueryState loading={controller.customFields.isPending}
      error={controller.customFields.error} empty={false}
      onRetry={() => void controller.customFields.refetch()} />
    {fields.map((field) => <StateRow key={field.fieldId} label={field.label}
      value={<>{labelFor(field.type)} · {field.helpText || "No help text"}</>} />)}
    {similar.length ? <p role="status">Similar fields: {similar.map((field) =>
      field.label).join(", ")}. Check these before adding another.</p> : null}
    <AdminForm onSubmit={(event) => {event.preventDefault(); void save();}}>
      <h3>New host field</h3>
      <TextField label="Field label" value={label} onChange={setLabel}
        placeholder="For example, preferred demo language" />
      <SelectField label="Type" value={type}
        onChange={(value) => setType(value as SalesCustomFieldType)} options={[
          {value: "string", label: "Text"},
          {value: "number", label: "Number"},
          {value: "boolean", label: "Yes or no"},
          {value: "date", label: "Date"},
          {value: "enum", label: "Choice"},
        ]} />
      {type === "enum" ? <TextField label="Choices, separated by commas"
        value={enumText} onChange={setEnumText} /> : null}
      <TextareaField label="Help text" rows={2} value={helpText}
        onChange={setHelpText} />
      <p>Preview: {label.trim() || "Field label"} · {labelFor(type)}
        {helpText.trim() ? ` · ${helpText.trim()}` : ""}</p>
      {localError ? <p role="alert">{localError}</p> : null}
      <AdminButton type="submit" variant="primary" disabled={controller.isSaving}>
        Add private field
      </AdminButton>
    </AdminForm>
  </Panel><SalesImportWorkspace controller={controller} isAdminOwner={isAdminOwner} /></>;
}

function HostDetail({controller, currentUserUid, isAdminOwner, onOpenOrganizer}: {
  controller: SalesWorkspaceController; currentUserUid: string;
  isAdminOwner: boolean;
  onOpenOrganizer: (id: string) => void;
}) {
  const [tab, setTab] = useState<DetailTab>("overview");
  const detail = controller.detail.data;
  if (controller.detail.isPending) return <EmptyState>Loading host…</EmptyState>;
  if (controller.detail.error || !detail) return <EmptyState>
    Host details could not be loaded.
    <AdminButton onClick={() => void controller.detail.refetch()}>Try again</AdminButton>
  </EmptyState>;
  return <AdminDetailScreenStack>
    <AdminToolbar>
      <AdminTag tone="neutral">Research: {labelFor(detail.account.researchStatus)}</AdminTag>
      <AdminTag tone="neutral">Listing: {labelFor(detail.organizerSummary.appVisibility)}</AdminTag>
      <AdminTag tone="neutral">Claim: {labelFor(detail.organizerSummary.claimStatus)}</AdminTag>
      <AdminButton onClick={() => onOpenOrganizer(detail.account.organizerId)}>
        Open organizer record
      </AdminButton>
    </AdminToolbar>
    <SegmentedControl ariaLabel="Host detail tab" mobileLayout="content"
      mobileSelectLabel="Host detail section" options={detailTabs}
      value={tab} onChange={setTab} />
    {tab === "overview" || tab === "research" ?
      <HostAccountEditor key={detail.account.organizerId} detail={detail}
        controller={controller} currentUserUid={currentUserUid} /> : null}
    {tab === "activity" ? <HostActivity detail={detail} controller={controller} /> : null}
    {tab === "opportunities" ? <HostOpportunities detail={detail}
      controller={controller} currentUserUid={currentUserUid} /> : null}
    {tab === "intelligence" ? <SalesIntelligenceWorkspace
      organizerId={detail.account.organizerId}
      organizerName={detail.organizerSummary.name}
      currentUserUid={currentUserUid} isAdminOwner={isAdminOwner} /> : null}
    {tab === "commercial" ? renderSalesCommercialWorkspace(detail,
      controller.evidence.data?.rows ?? [], isAdminOwner) : null}
    {tab === "people" ? <SalesRecordsWorkspace section="people" detail={detail}
      controller={controller} /> : null}
    {tab === "demo" ? <SalesDemoWorkspace
      key={`${currentUserUid}:${detail.account.organizerId}:${isAdminOwner}`}
      organizerId={detail.account.organizerId}
      organizerName={detail.organizerSummary.name}
      isAdminOwner={isAdminOwner} currentUserUid={currentUserUid} /> : null}
    {tab === "workflow" ? <SalesRecordsWorkspace section="draft" detail={detail}
      controller={controller} /> : null}
    {tab === "research" ? <SalesRecordsWorkspace section="evidence" detail={detail}
      controller={controller} /> : null}
    {tab === "overview" || tab === "research" ? <SalesRecordsWorkspace
      section="suppression" detail={detail} controller={controller} /> : null}
    {tab === "overview" || tab === "research" ? <HostCustomFields
      detail={detail} controller={controller} /> : null}
    <SalesRecordsWorkspace section="tasks" detail={detail} controller={controller}
      currentUserUid={currentUserUid} />
  </AdminDetailScreenStack>;
}

function HostCustomFields({detail, controller}: {
  detail: SalesAccountDetail; controller: SalesWorkspaceController;
}) {
  const fields = controller.customFields.data?.rows ?? [];
  return <Panel title="Additional host information" icon={<ClipboardList size={18} />}>
    <QueryState loading={controller.customFields.isPending}
      error={controller.customFields.error} empty={!fields.length}
      onRetry={() => void controller.customFields.refetch()} />
    {fields.map((field) => <CustomFieldValueEditor key={field.fieldId}
      field={field} detail={detail} controller={controller} />)}
  </Panel>;
}

function CustomFieldValueEditor({field, detail, controller}: {
  field: SalesCustomFieldDefinition; detail: SalesAccountDetail;
  controller: SalesWorkspaceController;
}) {
  const current = detail.customValues?.find((value) => value.fieldId === field.fieldId);
  const [textValue, setTextValue] = useState(() => String(current?.value ?? ""));
  const [dirty, setDirty] = useState(false);
  const [baseRevision, setBaseRevision] = useState(current?.revision ?? 0);
  useEffect(() => {
    if (dirty) return;
    setTextValue(String(current?.value ?? ""));
    setBaseRevision(current?.revision ?? 0);
  }, [current?.revision, current?.value, dirty]);
  const changedElsewhere = (current?.revision ?? 0) !== baseRevision;
  const validNumber = field.type !== "number" ||
    (textValue.trim() !== "" && Number.isFinite(Number(textValue)));
  const save = async () => {
    if (!textValue.trim() || !validNumber || changedElsewhere) return;
    const value = field.type === "number" ? Number(textValue) :
      field.type === "boolean" ? textValue === "true" : textValue.trim();
    const saved = await controller.saveCustomValue({
      organizerId: detail.account.organizerId, fieldId: field.fieldId,
      expectedRevision: baseRevision, value,
    });
    if (saved) setDirty(false);
  };
  const update = (value: string) => {setTextValue(value); setDirty(true);};
  return <AdminForm onSubmit={(event) => {event.preventDefault(); void save();}}>
    {field.type === "enum" ? <SelectField label={field.label} value={textValue}
      onChange={update} options={[{value: "", label: "Choose"},
        ...(field.enumOptions ?? []).map((option) => ({
          value: option, label: option,
        }))]} /> : field.type === "boolean" ?
      <SelectField label={field.label} value={textValue} onChange={update}
        options={[{value: "", label: "Unknown"}, {value: "true", label: "Yes"},
          {value: "false", label: "No"}]} /> :
      <TextField label={field.label} value={textValue} onChange={update}
        type={field.type === "number" ? "number" :
          field.type === "date" ? "date" : "text"} />}
    {field.helpText ? <p>{field.helpText}</p> : null}
    {!validNumber ? <p role="alert">Enter a valid number.</p> : null}
    {changedElsewhere ? <p role="alert">This value changed elsewhere.
      Latest saved value: {String(current?.value ?? "Unknown")}.</p> : null}
    <AdminButton type="submit" disabled={!dirty || changedElsewhere || !textValue.trim() ||
      !validNumber || controller.isSaving}>Save field</AdminButton>
    {changedElsewhere ? <AdminButton onClick={() => {
      setTextValue(String(current?.value ?? ""));
      setBaseRevision(current?.revision ?? 0);
      setDirty(false);
    }}>Use latest value</AdminButton> : null}
  </AdminForm>;
}

function HostAccountEditor({detail, controller, currentUserUid}: {
  detail: SalesAccountDetail; controller: SalesWorkspaceController;
  currentUserUid: string;
}) {
  const [form, setForm] = useState(() => accountFormValues(detail.account));
  const [dirty, setDirty] = useState(false);
  const [baseRevision, setBaseRevision] = useState(detail.account.revision);
  useEffect(() => {
    if (dirty) return;
    setForm(accountFormValues(detail.account));
    setBaseRevision(detail.account.revision);
  }, [detail.account, dirty]);
  const changedElsewhere = detail.account.revision !== baseRevision;
  const save = async () => {
    if (!dirty || changedElsewhere) return;
    const saved = await controller.saveAccount({
      organizerId: detail.account.organizerId,
      expectedRevision: baseRevision,
      patch: {
        researchStatus: form.researchStatus,
        assignedOwnerUid: form.assignedOwnerUid.trim() || null,
        summary: form.summary.trim() || null,
        nextAction: form.nextAction.trim() || null,
      },
    });
    if (saved) setDirty(false);
  };
  return <Panel title="Host summary" icon={<ClipboardList size={18} />} action={
    <AdminButton disabled={!dirty || changedElsewhere || controller.isSaving}
      variant="primary"
      onClick={() => void save()}>{controller.isSaving ? "Saving…" : "Save research"}</AdminButton>
  }>
    <p>{detail.organizerSummary.name} ·
      {[detail.organizerSummary.city, detail.organizerSummary.marketLabel]
        .filter(Boolean).join(", ") || "Location not recorded"}</p>
    {changedElsewhere ? <p role="alert">This host changed since you started editing.
      Compare the latest version below; your edits are retained.</p> : null}
    <AdminForm onSubmit={(event) => {event.preventDefault(); void save();}}>
      <SelectField label="Research status" value={form.researchStatus}
        options={researchStatusOptions}
        onChange={(value) => {
          setForm((current) => ({...current,
            researchStatus: value as SalesResearchStatus})); setDirty(true);
        }} />
      <StateRow label="Owner" value={ownerLabel(form.assignedOwnerUid,
        currentUserUid)} />
      {form.assignedOwnerUid !== currentUserUid ? <AdminButton
        onClick={() => {setForm((current) => ({...current,
          assignedOwnerUid: currentUserUid})); setDirty(true);}}>
        Assign to me
      </AdminButton> : null}
      <TextareaField label="Working summary" rows={4} value={form.summary}
        onChange={(summary) => {
          setForm((current) => ({...current, summary})); setDirty(true);
        }} />
      <TextField label="Next action" value={form.nextAction}
        onChange={(nextAction) => {
          setForm((current) => ({...current, nextAction})); setDirty(true);
        }} />
    </AdminForm>
    {changedElsewhere ? <StateRow label="Latest saved version" value={<>
      Summary: {detail.account.summary || "None"}<br />
      Next action: {detail.account.nextAction || "None"}{" "}
      <AdminButton onClick={() => {
        setForm(accountFormValues(detail.account));
        setBaseRevision(detail.account.revision);
        setDirty(false);
      }}>Use latest version</AdminButton>
    </>} /> : null}
  </Panel>;
}

function HostActivity({detail, controller}: {
  detail: SalesAccountDetail; controller: SalesWorkspaceController;
}) {
  const [type, setType] = useState<"note" | "reply" | "call" | "demo" | "pilot" |
    "outreach_sent_manual">("note");
  const [channel, setChannel] = useState<"email" | "whatsapp" | "other">("email");
  const [note, setNote] = useState("");
  const [occurredAt, setOccurredAt] = useState(() =>
    toLocalDateTimeInput(new Date()));
  const save = async () => {
    if (!note.trim() || Number.isNaN(new Date(occurredAt).getTime())) return;
    const saved = await controller.logActivity({
      organizerId: detail.account.organizerId, type,
      occurredAt: new Date(occurredAt).toISOString(), note: note.trim(),
      ...(type === "outreach_sent_manual" ? {
        channel, attestation: "sent_elsewhere_by_actor" as const,
      } : {}),
    });
    if (saved) setNote("");
  };
  return <Panel title="Activity" icon={<ClipboardList size={18} />}>
    <AdminForm onSubmit={(event) => {event.preventDefault(); void save();}}>
      <SelectField label="What happened?" value={type}
        onChange={(value) => setType(value as typeof type)}
        options={[
          {value: "note", label: "Research or conversation note"},
          {value: "call", label: "Call"},
          {value: "reply", label: "Reply received"},
          {value: "demo", label: "Demo"},
          {value: "pilot", label: "Pilot update"},
          {value: "outreach_sent_manual", label: "Sent elsewhere (manual log)"},
        ]} />
      {type === "outreach_sent_manual" ? <>
        <SelectField label="Channel" value={channel}
          onChange={(value) => setChannel(value as typeof channel)} options={[
            {value: "email", label: "Email"},
            {value: "whatsapp", label: "WhatsApp"},
            {value: "other", label: "Other"},
          ]} />
        <p>You attest this was sent outside Catch. Delivery is unconfirmed.</p>
      </> : null}
      <TextField label="When" type="datetime-local" value={occurredAt}
        onChange={setOccurredAt} />
      <TextareaField label="What should the team know?" rows={3} value={note}
        onChange={setNote} />
      <AdminButton type="submit" variant="primary"
        disabled={!note.trim() || controller.isSaving}>Record activity</AdminButton>
    </AdminForm>
    {detail.activities.length ? detail.activities.map((activity) =>
      <StateRow key={activity.activityId} label={labelFor(activity.type)}
        value={<>{dateLabel(activity.occurredAt)} · {activity.note}
          {activity.type === "outreach_sent_manual" ?
            ` · ${activity.channel || "other"} · Actor-attested; delivery unconfirmed` : ""}
        </>} />
    ) : <EmptyState>No activity recorded yet.</EmptyState>}
  </Panel>;
}

function HostOpportunities({detail, controller, currentUserUid}: {
  detail: SalesAccountDetail; controller: SalesWorkspaceController;
  currentUserUid: string;
}) {
  const [selectedId, setSelectedId] = useState("");
  const [selectedRevision, setSelectedRevision] = useState(0);
  const [transitionReason, setTransitionReason] = useState("");
  const selected = useMemo(() => detail.opportunities.find((item) =>
    item.opportunityId === selectedId), [detail.opportunities, selectedId]);
  const [motion, setMotion] = useState("first_workflow_pilot");
  const [stage, setStage] = useState("new_enquiry");
  const [ownerUid, setOwnerUid] = useState(currentUserUid);
  const [nextStep, setNextStep] = useState("");
  const [nextStepAt, setNextStepAt] = useState("");
  const select = (item: SalesOpportunity | null) => {
    setTransitionReason("");
    setSelectedId(item?.opportunityId ?? "");
    setSelectedRevision(item?.revision ?? 0);
    setMotion(item?.motion ?? "first_workflow_pilot");
    setStage(item?.stage ?? "new_enquiry");
    setOwnerUid(item?.ownerUid ?? currentUserUid);
    setNextStep(item?.nextStep ?? "");
    setNextStepAt(item?.nextStepAt ?
      toLocalDateTimeInput(new Date(item.nextStepAt)) : "");
  };
  const save = async () => {
    if (selected && selected.revision !== selectedRevision) return;
    if (!ownerUid.trim() || !nextStep.trim() || !nextStepAt) return;
    const saved = await controller.saveOpportunity({
      organizerId: detail.account.organizerId,
      opportunityId: selected?.opportunityId,
      expectedRevision: selectedRevision,
      ...(transitionReason.trim() ? {transitionReason: transitionReason.trim()} : {}),
      fields: {motion, stage, ownerUid: ownerUid.trim(),
        nextStep: nextStep.trim(), nextStepAt: new Date(nextStepAt).toISOString()},
    });
    if (saved) select(null);
  };
  return <Panel title="Opportunities" icon={<ClipboardList size={18} />}>
    {detail.opportunities.map((item) => <StateRow key={item.opportunityId}
      label={labelFor(item.stage)} value={<>
        {labelFor(item.motion)} · {item.nextStep} ({dateLabel(item.nextStepAt)}){" "}
        <AdminButton onClick={() => select(item)}>Update</AdminButton>
      </>} />)}
    {!detail.opportunities.length ? <EmptyState>No opportunity recorded yet.</EmptyState> : null}
    <AdminForm onSubmit={(event) => {event.preventDefault(); void save();}}>
      <h3>{selected ? "Update opportunity" : "New opportunity"}</h3>
      {selected && selected.revision !== selectedRevision ? <p role="alert">
        This opportunity changed while you were editing. Review the latest stage and
        next step before saving.
        <AdminButton onClick={() => select(selected)}>Use latest version</AdminButton>
      </p> : null}
      <SelectField label="Motion" value={motion} onChange={setMotion} options={[
        {value: "first_workflow_pilot", label: "First workflow pilot"},
        {value: "listing_claim_assistance", label: "Listing claim assistance"},
        {value: "inbound_stack_review", label: "Inbound stack review"},
        {value: "expansion", label: "Expansion"},
        {value: "renewal", label: "Renewal"},
      ]} />
      <SelectField label="Stage" value={stage} onChange={setStage}
        options={stageOptions.filter((item) => item.value &&
          (item.value !== "closed_won" || selected?.stage === "closed_won"))} />
      <StateRow label="Owner" value={ownerLabel(ownerUid, currentUserUid)} />
      {ownerUid !== currentUserUid ? <AdminButton onClick={() =>
        setOwnerUid(currentUserUid)}>Assign to me</AdminButton> : null}
      {stage === "closed_lost" || selected?.stage === "closed_lost" ? (
        <TextareaField label="Reason for closing or reopening" value={transitionReason}
          onChange={setTransitionReason} rows={3} />
      ) : null}
      {stage === "closed_won" ? <p>Payment-backed closing is managed in Pilot &amp; terms.</p> : null}
      <TextField label="Next step" value={nextStep} onChange={setNextStep} />
      <TextField label="Due" type="datetime-local" value={nextStepAt}
        onChange={setNextStepAt} />
      <AdminButton type="submit" variant="primary" disabled={controller.isSaving ||
        (selected && selected.revision !== selectedRevision) ||
        stage === "closed_won" ||
        ((stage === "closed_lost" || selected?.stage === "closed_lost") &&
          !transitionReason.trim()) ||
        !ownerUid.trim() || !nextStep.trim() || !nextStepAt}>
        {selected ? "Save opportunity" : "Add opportunity"}
      </AdminButton>
      {selected ? <AdminButton onClick={() => select(null)}>Cancel editing</AdminButton> : null}
    </AdminForm>
  </Panel>;
}
