import {ExternalLink, RefreshCw, Search} from "lucide-react";
import {useEffect, useState} from "react";

import {
  AdminButton,
  AdminIntakeReviewWorkbench,
  AdminIntakeSection,
  AdminIntakeStageRail,
  AdminIntakeTaskToolbar,
  AdminLinkButton,
  SearchField,
  SelectField,
  TextareaField,
} from "../../../../shared/ui/AdminPrimitives";
import type {
  EventIntakeCandidate,
  EventIntakeDecision,
  EventIntakeSourceResult,
  EventIntakeTargetType,
} from "../../../../shared/types/adminTypes";
import type {EventIntakeController} from
  "../controllers/useEventIntakeController";

type EventWorkbenchStage = "incoming" | "verify" | "resolve" | "ready";
type EventQueueFilter = "all" | "attention" | "sourced";
type EventWorkbenchRecord =
  | {kind: "source"; value: EventIntakeSourceResult}
  | {kind: "candidate"; value: EventIntakeCandidate};

const eventWorkbenchStageKey = "catch-admin.event-intake-stage.v1";

function EventTaskWorkbench({
  controller,
  onShowDiagnostics,
}: {
  controller: EventIntakeController;
  onShowDiagnostics: () => void;
}) {
  const {
    bridge,
    inFlight,
    isLoading,
    loadBridge,
    localDecisions,
    notes,
    setActiveTab,
    setNote,
    sourceResultById,
    targetDecision,
  } = controller;
  const [activeStage, setActiveStageState] = useState<EventWorkbenchStage>(
    readEventWorkbenchStage
  );
  const [queueFilter, setQueueFilter] = useState<EventQueueFilter>("all");
  const [searchQuery, setSearchQuery] = useState("");
  const [category, setCategory] = useState("all");
  const [sourceState, setSourceState] = useState("all");
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const stageRecords = bridge ?
    recordsForStage(bridge.sourceResults, bridge.eventCandidates, activeStage) : [];
  const categories = bridge ? Array.from(new Set(
    bridge.eventCandidates.map((candidate) => candidate.category)
  )).sort() : [];
  const records = stageRecords.filter((record) => {
    const text = recordSearchText(record);
    const candidate = record.kind === "candidate" ? record.value : null;
    const source = record.kind === "source" ? record.value : null;
    return (!searchQuery.trim() || text.includes(searchQuery.trim().toLocaleLowerCase())) &&
      (category === "all" || candidate?.category === category) &&
      (sourceState === "all" ||
        (sourceState === "sourced" && candidate?.sourceUrl) ||
        (sourceState === "missing" && candidate && !candidate.sourceUrl) ||
        (sourceState === "manual" && (
          candidate?.sourceStatus === "manual_reference_needs_official_verification" ||
          source?.resultType === "manual_social_reference"
        ))) &&
      (queueFilter === "all" ||
        (queueFilter === "attention" && recordNeedsAttention(record)) ||
        (queueFilter === "sourced" && recordIsSourced(record)));
  });

  useEffect(() => {
    if (records.some((record) => recordId(record) === selectedId)) return;
    setSelectedId(records[0] ? recordId(records[0]) : null);
  }, [records, selectedId]);

  if (!bridge) return null;

  const selected = records.find((record) => recordId(record) === selectedId) ?? null;
  const target = selected ? targetForRecord(selected) : null;
  const targetKey = target ? `${target.type}:${target.id}` : null;
  const localDecision = targetKey ? localDecisions[targetKey] : undefined;
  const targetInFlight = targetKey ? inFlight[targetKey] : false;
  const stageCounts = {
    incoming: bridge.sourceResults.length,
    verify: bridge.eventCandidates.filter((candidate) => candidate.reviewState !== "approved").length,
    resolve: bridge.eventCandidates.filter(candidateNeedsAttention).length,
    ready: bridge.eventCandidates.filter((candidate) => candidate.reviewState === "approved").length,
  };

  const setStage = (stage: EventWorkbenchStage) => {
    setActiveStageState(stage);
    setQueueFilter("all");
    try {
      window.localStorage.setItem(eventWorkbenchStageKey, stage);
    } catch {
      // The in-memory stage still works when storage is unavailable.
    }
  };
  const openDiagnostics = () => {
    setActiveTab(selected?.kind === "source" ? "inbox" : "candidates");
    onShowDiagnostics();
  };
  const recordDecision = (decision: EventIntakeDecision) => {
    if (!selected || !target) return;
    void targetDecision({
      targetType: target.type,
      targetId: target.id,
      decision,
      edits: selected.value as unknown as Record<string, unknown>,
      defaultNote: `${selected.value.title} reviewed for event intake use.`,
    });
  };

  return (
    <>
      <AdminIntakeTaskToolbar aria-label="Event intake filters">
        <SearchField
          ariaLabel="Search event intake"
          icon={<Search size={15} strokeWidth={1.9} />}
          placeholder="Search event, source, venue..."
          value={searchQuery}
          onChange={setSearchQuery}
        />
        <SelectField
          label="Category"
          options={[
            {value: "all", label: "All categories"},
            ...categories.map((value) => ({value, label: value.replaceAll("_", " ")})),
          ]}
          value={category}
          onChange={setCategory}
        />
        <SelectField
          label="Source state"
          options={[
            {value: "all", label: "All source states"},
            {value: "sourced", label: "Source-backed"},
            {value: "missing", label: "Missing source"},
            {value: "manual", label: "Manual reference"},
          ]}
          value={sourceState}
          onChange={setSourceState}
        />
        <AdminButton onClick={openDiagnostics}>Diagnostics</AdminButton>
        <AdminButton
          icon={<RefreshCw size={14} strokeWidth={1.9} />}
          loading={isLoading}
          loadingLabel="Refreshing"
          variant="primary"
          onClick={() => void loadBridge()}
        >Refresh</AdminButton>
      </AdminIntakeTaskToolbar>
      <AdminIntakeStageRail<EventWorkbenchStage>
        ariaLabel="Event intake stages"
        options={[
          {id: "incoming", label: "Incoming", meta: `${stageCounts.incoming} source leads`},
          {id: "verify", label: "Verify", meta: `${stageCounts.verify} candidates`},
          {id: "resolve", label: "Resolve", meta: `${stageCounts.resolve} need evidence`},
          {id: "ready", label: "Ready", meta: `${stageCounts.ready} reviewed`},
        ]}
        value={activeStage}
        onChange={setStage}
      />
      <AdminIntakeReviewWorkbench
        detail={selected && target ? detailForRecord({
          bridgeGeneratedAt: bridge.generatedAt,
          inFlight: targetInFlight,
          localDecision,
          note: notes[targetKey ?? ""] ?? "",
          record: selected,
          sourceResultById,
          onDecision: recordDecision,
          onEdit: openDiagnostics,
          onNoteChange: (value) => targetKey && setNote(targetKey, value),
        }) : null}
        emptyDetail="Select a lead or candidate to review its provenance and decision gates."
        emptyQueue="No event intake records match this stage and filter set."
        filters={[
          {id: "all", label: `All ${records.length}`, selected: queueFilter === "all"},
          {id: "attention", label: "Needs attention", selected: queueFilter === "attention"},
          {id: "sourced", label: "Source-backed", selected: queueFilter === "sourced"},
        ]}
        items={records.map(queueItemForRecord)}
        queueMeta={`${records.length} item${records.length === 1 ? "" : "s"}`}
        queueTitle={eventStageTitle(activeStage)}
        selectedId={selectedId}
        onFilterChange={(filterId) => setQueueFilter(filterId as EventQueueFilter)}
        onSelect={setSelectedId}
      />
    </>
  );
}

function recordsForStage(
  sources: EventIntakeSourceResult[],
  candidates: EventIntakeCandidate[],
  stage: EventWorkbenchStage
): EventWorkbenchRecord[] {
  if (stage === "incoming") return sources.map((value) => ({kind: "source", value}));
  if (stage === "verify") {
    return candidates.filter((value) => value.reviewState !== "approved")
      .map((value) => ({kind: "candidate", value}));
  }
  if (stage === "resolve") {
    return candidates.filter(candidateNeedsAttention)
      .map((value) => ({kind: "candidate", value}));
  }
  return candidates.filter((value) => value.reviewState === "approved")
    .map((value) => ({kind: "candidate", value}));
}

function detailForRecord({
  bridgeGeneratedAt,
  inFlight,
  localDecision,
  note,
  record,
  sourceResultById,
  onDecision,
  onEdit,
  onNoteChange,
}: {
  bridgeGeneratedAt: string | null;
  inFlight: boolean;
  localDecision: EventIntakeController["localDecisions"][string] | undefined;
  note: string;
  record: EventWorkbenchRecord;
  sourceResultById: Map<string, EventIntakeSourceResult>;
  onDecision: (decision: EventIntakeDecision) => void;
  onEdit: () => void;
  onNoteChange: (value: string) => void;
}) {
  const candidate = record.kind === "candidate" ? record.value : null;
  const source = record.kind === "source" ? record.value : null;
  const checks = candidate ? candidateChecks(candidate) : sourceChecks(source!);
  const canApprove = checks.every((check) => check.passed);
  const status = recordStatus(record);
  return {
    action: (
      <AdminButton onClick={onEdit}>Edit evidence</AdminButton>
    ),
    checklistRows: checks,
    checklistTitle: "Review checklist",
    footerActions: (
      <>
        <AdminButton disabled={inFlight} onClick={() => onDecision("reject")}>Reject</AdminButton>
        <AdminButton disabled={inFlight} onClick={() => onDecision("hold")}>Hold</AdminButton>
        <AdminButton disabled={inFlight} onClick={() => onDecision("needs_changes")}>Needs changes</AdminButton>
        <AdminButton disabled={!canApprove || inFlight} variant="primary" onClick={() => onDecision("approve")}>
          Approve intake
        </AdminButton>
      </>
    ),
    footerHint: localDecision ?
      `Recorded ${localDecision.decisionStatus.replaceAll("_", " ")} at ${localDecision.decisionPath}.` :
      canApprove ?
        "Approval records a decision only; publishing remains in the Events workflow." :
        "Approval is disabled until source, date, venue, copy, and rights checks pass.",
    impactRows: candidate ? [
      {id: "intake", label: "Intake state", value: candidate.reviewState.replaceAll("_", " ")},
      {id: "marketing", label: "Marketing eligibility", value: candidate.sourceUrl ? "Reviewable" : "Blocked"},
      {id: "external", label: "External supply", value: "Separate import plan"},
      {id: "canonical", label: "Canonical event", value: "Not created here"},
      {id: "booking", label: "Catch booking", value: "Not enabled"},
    ] : [
      {id: "lead", label: "Lead state", value: source!.status.replaceAll("_", " ")},
      {id: "candidate", label: "Candidate creation", value: "Separate dedupe step"},
      {id: "publish", label: "Publication", value: "Not available"},
      {id: "snapshot", label: "Bridge generated", value: formatTimestamp(bridgeGeneratedAt)},
    ],
    impactTitle: "Downstream impact",
    initials: initialsForLabel(record.value.title),
    note: (
      <AdminIntakeSection>
        <TextareaField
          label="Decision note"
          placeholder="Record source, duplicate, timing, or location evidence..."
          rows={2}
          value={note}
          onChange={onNoteChange}
        />
      </AdminIntakeSection>
    ),
    noteTitle: "Decision note",
    primaryRows: candidate ? candidate.sourceResultIds.map((sourceId) => {
      const result = sourceResultById.get(sourceId);
      return {
        href: result?.url,
        id: sourceId,
        meta: result ? `${result.sourceLabel} · observed ${formatTimestamp(result.observedAt)}` : "Source result missing from bridge",
        status: result ? result.status.replaceAll("_", " ") : "missing",
        statusTone: result ? "warning" as const : "danger" as const,
        title: result?.title ?? sourceId,
      };
    }) : [{
      href: source!.url,
      id: source!.id,
      meta: `${source!.sourceLabel} · observed ${formatTimestamp(source!.observedAt)}`,
      status: source!.status.replaceAll("_", " "),
      statusTone: source!.riskFlags.length > 0 ? "warning" as const : "success" as const,
      title: source!.resultType.replaceAll("_", " "),
    }],
    primaryTitle: "Source evidence",
    readiness: {
      blockers: checks.filter((check) => !check.passed).length,
      complete: checks.filter((check) => check.passed).length,
      label: "Decision readiness",
      total: checks.length,
    },
    status: status.label,
    statusTone: status.tone,
    subtitle: candidate ?
      `${candidate.category.replaceAll("_", " ")} · ${candidate.neighborhood} · score ${candidate.score}` :
      `${source!.sourceLabel} · ${source!.resultType.replaceAll("_", " ")}`,
    title: record.value.title,
  };
}

function candidateChecks(candidate: EventIntakeCandidate) {
  return [
    {id: "source", label: "Official source URL attached", meta: "required", passed: Boolean(candidate.sourceUrl)},
    {id: "date", label: "Date and time recorded", meta: "required", passed: Boolean(candidate.startDate && candidate.time)},
    {id: "venue", label: "Venue or meeting point recorded", meta: "required", passed: Boolean(candidate.venue && candidate.neighborhood)},
    {id: "copy", label: "Owner-safe public copy reviewed", meta: "required", passed: Boolean(candidate.publicDescription)},
    {id: "rights", label: "External hosting and rights boundary clear", meta: "required", passed: candidate.sourceStatus !== "missing_source_url"},
    {id: "dedupe", label: "Duplicate candidates reviewed", meta: "required", passed: (candidate.dedupe?.duplicateCandidateIds ?? []).length === 0},
  ];
}

function sourceChecks(source: EventIntakeSourceResult) {
  return [
    {id: "url", label: "Source URL captured", meta: "required", passed: Boolean(source.url)},
    {id: "observed", label: "Observation timestamp recorded", meta: "required", passed: Boolean(source.observedAt)},
    {id: "profile", label: "Source profile linked", meta: "required", passed: Boolean(source.sourceProfileId)},
    {id: "query", label: "Discovery query recorded", meta: "required", passed: Boolean(source.queryTemplateId)},
    {id: "placeholder", label: "Result is not placeholder evidence", meta: "required", passed: !source.riskFlags.includes("placeholder_result")},
  ];
}

function queueItemForRecord(record: EventWorkbenchRecord) {
  const status = recordStatus(record);
  const candidate = record.kind === "candidate" ? record.value : null;
  const source = record.kind === "source" ? record.value : null;
  return {
    description: candidate ? `${candidate.category.replaceAll("_", " ")} · ${candidate.neighborhood}` : source!.sourceLabel,
    id: recordId(record),
    initials: initialsForLabel(record.value.title),
    meta: candidate ? `${candidate.sourceResultIds.length} sources · score ${candidate.score}` : `${source!.resultType.replaceAll("_", " ")} · ${formatTimestamp(source!.observedAt)}`,
    status: status.label,
    statusTone: status.tone,
    title: record.value.title,
  };
}

function recordStatus(record: EventWorkbenchRecord): {
  label: string;
  tone: "neutral" | "warning" | "danger" | "success";
} {
  if (record.kind === "source") {
    if (record.value.riskFlags.includes("placeholder_result")) return {label: "placeholder", tone: "danger"};
    return {label: record.value.status.replaceAll("_", " "), tone: "warning"};
  }
  if (record.value.reviewState === "approved") return {label: "approved", tone: "success"};
  if (!record.value.sourceUrl) return {label: "needs source", tone: "danger"};
  if (record.value.sourceStatus === "manual_reference_needs_official_verification") {
    return {label: "verify source", tone: "warning"};
  }
  return {label: record.value.reviewState.replaceAll("_", " "), tone: "neutral"};
}

function candidateNeedsAttention(candidate: EventIntakeCandidate) {
  return !candidate.sourceUrl ||
    candidate.sourceStatus === "manual_reference_needs_official_verification" ||
    candidate.warnings.length > 0;
}

function recordNeedsAttention(record: EventWorkbenchRecord) {
  return record.kind === "candidate" ? candidateNeedsAttention(record.value) :
    record.value.riskFlags.length > 0;
}

function recordIsSourced(record: EventWorkbenchRecord) {
  return record.kind === "source" ? Boolean(record.value.url) : Boolean(record.value.sourceUrl);
}

function targetForRecord(record: EventWorkbenchRecord): {
  id: string;
  type: EventIntakeTargetType;
} {
  return record.kind === "source" ?
    {id: record.value.id, type: "source_result"} :
    {id: record.value.id, type: "event_candidate"};
}

function recordId(record: EventWorkbenchRecord) {
  return `${record.kind}:${record.value.id}`;
}

function recordSearchText(record: EventWorkbenchRecord) {
  const candidate = record.kind === "candidate" ? record.value : null;
  const source = record.kind === "source" ? record.value : null;
  return [
    record.value.title,
    candidate?.category,
    candidate?.venue,
    candidate?.neighborhood,
    source?.sourceLabel,
    source?.snippet,
  ].filter(Boolean).join(" ").toLocaleLowerCase();
}

function eventStageTitle(stage: EventWorkbenchStage) {
  if (stage === "incoming") return "Incoming source leads";
  if (stage === "verify") return "Candidates to verify";
  if (stage === "resolve") return "Resolve source and event details";
  return "Ready event handoffs";
}

function initialsForLabel(label: string) {
  return label.split(/\s+/u).filter(Boolean).slice(0, 2)
    .map((part) => part[0]?.toUpperCase()).join("") || "?";
}

function formatTimestamp(value: string | null | undefined) {
  return value ? value.replace("T", " ").replace(/\.\d{3}Z$/u, "Z") : "n/a";
}

function readEventWorkbenchStage(): EventWorkbenchStage {
  if (typeof window === "undefined") return "verify";
  try {
    const value = window.localStorage.getItem(eventWorkbenchStageKey);
    if (value === "incoming" || value === "verify" || value === "resolve" || value === "ready") {
      return value;
    }
  } catch {
    // Fall through to the review-first default.
  }
  return "verify";
}

export const eventIntakeWorkbench = {EventTaskWorkbench};
