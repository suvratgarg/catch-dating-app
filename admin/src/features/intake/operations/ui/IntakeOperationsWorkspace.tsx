import {ListPlus, RefreshCw, Search} from "lucide-react";
import {useEffect, useMemo, useState} from "react";

import {useAdminFeedback} from
  "../../../../shared/feedback/AdminFeedbackContext";
import {
  operationItemsForStage,
  operationNeedsHumanReview,
  operationWorkItemSubtitle,
  operationWorkItemTitle,
} from "../../../../shared/operations/operationSelectors";
import type {
  OperationEntityKind,
  OperationWorkItem,
  SupplyIntakePrimaryStage,
} from "../../../../shared/operations/operationsTypes";
import {
  AdminButton,
  AdminIntakeBoundaryNotice,
  AdminIntakeReviewWorkbench,
  AdminIntakeStageRail,
  AdminIntakeTaskToolbar,
  AdminWorkbenchNote,
  EmptyState,
  SearchField,
  SelectField,
} from "../../../../shared/ui/AdminPrimitives";
import {
  type IntakeOperationsController,
  useIntakeOperationsController,
} from "../controllers/useIntakeOperationsController";

type OperationQueueFilter = "all" | "human_review";
type OperationEntityFilter = "all" | OperationEntityKind;

const operationsStageKey = "catch-admin.intake-operations-stage.v1";

export function IntakeOperationsWorkspace() {
  const {setError: onError} = useAdminFeedback();
  const controller = useIntakeOperationsController({onError});
  return <IntakeOperationsPreviewWorkspace controller={controller} />;
}

export function IntakeOperationsPreviewWorkspace({
  controller,
}: {
  controller: IntakeOperationsController;
}) {
  const {data, isLoading, isLoadingMore, loadMore, refresh} = controller;
  const [activeStage, setActiveStageState] =
    useState<SupplyIntakePrimaryStage>(readOperationsStage);
  const [queueFilter, setQueueFilter] =
    useState<OperationQueueFilter>("all");
  const [entityFilter, setEntityFilter] =
    useState<OperationEntityFilter>("all");
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const items = useMemo(() => {
    if (!data) return [];
    const query = searchQuery.trim().toLocaleLowerCase();
    return operationItemsForStage(data.workItems, activeStage)
      .filter((item) => entityFilter === "all" ||
        item.entityKind === entityFilter)
      .filter((item) => queueFilter === "all" ||
        operationNeedsHumanReview(item))
      .filter((item) => !query || [
        operationWorkItemTitle(item),
        item.externalKey,
        item.entityKind,
        ...item.taskFlags,
        ...item.blockerCodes,
      ].filter(Boolean).join(" ").toLocaleLowerCase().includes(query));
  }, [activeStage, data, entityFilter, queueFilter, searchQuery]);

  useEffect(() => {
    if (items.some((item) => item.workItemId === selectedId)) return;
    setSelectedId(items[0]?.workItemId ?? null);
  }, [items, selectedId]);

  if (!data) {
    return (
      <EmptyState
        icon={<RefreshCw size={18} strokeWidth={1.9} />}
        variant="marketing"
      >
        {isLoading ?
          "Loading Supply Intake operations..." :
          "No durable Supply Intake operations are available."}
      </EmptyState>
    );
  }

  const selected = data.workItems.find((item) =>
    item.workItemId === selectedId
  ) ?? null;
  const run = selected ? data.runs.find((candidate) =>
    candidate.runId === selected.runId
  ) ?? null : null;
  const setStage = (stage: SupplyIntakePrimaryStage) => {
    setActiveStageState(stage);
    setQueueFilter("all");
    try {
      window.localStorage.setItem(operationsStageKey, stage);
    } catch {
      // The in-memory stage remains usable when storage is unavailable.
    }
  };

  return (
    <>
      <AdminIntakeBoundaryNotice
        title={`${data.runs.length} shadow run${data.runs.length === 1 ? "" : "s"} loaded${data.nextRunCursor ? " · more runs available" : ""} · ${data.summary.humanReviewCount} human exception${data.summary.humanReviewCount === 1 ? "" : "s"} · ${data.workItems.length} of ${data.summary.workItemCount} items loaded`}
      >
        The browser is read-only. It cannot request runs, fetch sources, call a
        model, deploy a rule, or publish a listing. Stage totals describe the
        full persisted run even when this response is paginated.
      </AdminIntakeBoundaryNotice>
      <AdminIntakeTaskToolbar aria-label="Supply Intake operation filters">
        <SearchField
          ariaLabel="Search Supply Intake operations"
          icon={<Search size={15} strokeWidth={1.9} />}
          placeholder="Search item, source, blocker..."
          value={searchQuery}
          onChange={setSearchQuery}
        />
        <SelectField
          label="Entity"
          options={[
            {value: "all", label: "All entities"},
            {value: "event", label: "Events"},
            {value: "organizer", label: "Organizers"},
            {value: "source_result", label: "Source results"},
            {value: "source_profile", label: "Source profiles"},
          ]}
          value={entityFilter}
          onChange={(value) => setEntityFilter(value as OperationEntityFilter)}
        />
        <AdminButton
          icon={<RefreshCw size={14} strokeWidth={1.9} />}
          loading={isLoading}
          loadingLabel="Refreshing"
          variant="primary"
          onClick={() => void refresh()}
        >
          Refresh
        </AdminButton>
        {data.nextWorkItemCursor ? (
          <AdminButton
            icon={<ListPlus size={14} strokeWidth={1.9} />}
            loading={isLoadingMore}
            loadingLabel="Loading more"
            onClick={() => void loadMore()}
          >
            Load 200 more
          </AdminButton>
        ) : null}
      </AdminIntakeTaskToolbar>
      <AdminIntakeStageRail<SupplyIntakePrimaryStage>
        ariaLabel="Supply Intake operation stages"
        options={[
          {id: "incoming", label: "Incoming", meta: `${data.summary.stages.incoming} items`},
          {id: "verify", label: "Verify", meta: `${data.summary.stages.verify} items`},
          {id: "resolve", label: "Resolve", meta: `${data.summary.stages.resolve} items`},
          {id: "ready", label: "Ready", meta: `${data.summary.stages.ready} items`},
        ]}
        value={activeStage}
        onChange={setStage}
      />
      <AdminIntakeReviewWorkbench
        detail={selected ? operationDetail(selected, run?.status ?? "unknown") : null}
        emptyDetail="Select a persisted work item to inspect its evidence, blockers, and run receipt state."
        emptyQueue="No loaded work items match this stage and filter set. Load another page if ordinary inventory remains."
        filters={[
          {id: "all", label: `All ${items.length}`, selected: queueFilter === "all"},
          {
            id: "human_review",
            label: "Human review",
            selected: queueFilter === "human_review",
          },
        ]}
        items={items.map(operationQueueItem)}
        queueMeta={`${items.length} item${items.length === 1 ? "" : "s"}`}
        queueTitle={`${stageLabel(activeStage)} inventory`}
        selectedId={selectedId}
        onFilterChange={(value) =>
          setQueueFilter(value as OperationQueueFilter)}
        onSelect={setSelectedId}
      />
    </>
  );
}

function operationDetail(item: OperationWorkItem, runStatus: string) {
  const openChecks = item.blockerCodes.map((code) => ({
    id: `blocker:${code}`,
    label: code.replaceAll("_", " "),
    meta: "blocking",
    passed: false,
  }));
  const taskChecks = item.taskFlags
    .filter((flag) => !item.blockerCodes.includes(flag))
    .map((flag) => ({
      id: `task:${flag}`,
      label: flag.replaceAll("_", " "),
      meta: "tracked",
      passed: true,
    }));
  const checks = [...openChecks, ...taskChecks];
  const evidenceRows = item.evidenceRefs.map((evidence) => ({
    href: evidence.locator,
    id: evidence.artifactId,
    meta: `Observed ${formatTimestamp(evidence.observedAt)} · ${evidence.contentHash.slice(0, 12)}`,
    status: "hash bound",
    statusTone: "success" as const,
    title: evidence.artifactId,
  }));
  return {
    checklistRows: checks.length > 0 ? checks : [{
      id: "none",
      label: "No open tasks or blockers",
      meta: "complete",
      passed: true,
    }],
    checklistTitle: "Persisted tasks and blockers",
    footerActions: null,
    footerHint: operationNeedsHumanReview(item) ?
      "Resolve this exception in the matching Event or Organizer Intake queue. After that queue's generated artifact is refreshed, a new Supply Intake run can project the backed decision." :
      "This projection is read-only. Worker execution and public writes remain disabled.",
    impactRows: [
      {id: "stage", label: "Primary stage", value: stageLabel(item.primaryStage)},
      {id: "lifecycle", label: "Lifecycle", value: item.lifecycleStatus.replaceAll("_", " ")},
      {id: "run", label: "Run status", value: runStatus.replaceAll("_", " ")},
      {id: "decision", label: "Decision receipt", value: item.decisionId ?? "Not recorded"},
      {id: "publication", label: "Publication plan", value: item.publicationPlanId ?? "Not created"},
    ],
    impactTitle: "Durable state",
    initials: initialsForLabel(operationWorkItemTitle(item)),
    note: (
      <AdminWorkbenchNote>
        Run {item.runId} · revision {item.revision} · updated {formatTimestamp(item.updatedAt)}
      </AdminWorkbenchNote>
    ),
    noteTitle: "Run receipt",
    primaryRows: evidenceRows.length > 0 ? evidenceRows : [{
      id: "missing-evidence",
      meta: "Attach source evidence before promotion planning.",
      status: "missing",
      statusTone: "danger" as const,
      title: "No evidence references",
    }],
    primaryTitle: "Hash-bound evidence",
    readiness: {
      blockers: item.blockerCodes.length,
      complete: checks.filter((check) => check.passed).length,
      label: "Automation readiness",
      total: Math.max(checks.length, 1),
    },
    status: item.lifecycleStatus.replaceAll("_", " "),
    statusTone: operationTone(item),
    subtitle: operationWorkItemSubtitle(item),
    title: operationWorkItemTitle(item),
  };
}

function operationQueueItem(item: OperationWorkItem) {
  return {
    description: operationWorkItemSubtitle(item),
    id: item.workItemId,
    initials: initialsForLabel(operationWorkItemTitle(item)),
    meta: `${item.evidenceRefs.length} evidence ref${item.evidenceRefs.length === 1 ? "" : "s"} · ${item.blockerCodes.length} blocker${item.blockerCodes.length === 1 ? "" : "s"}`,
    status: operationNeedsHumanReview(item) ?
      "human review" : item.lifecycleStatus.replaceAll("_", " "),
    statusTone: operationTone(item),
    title: operationWorkItemTitle(item),
  };
}

function operationTone(item: OperationWorkItem) {
  if (item.blockerCodes.length > 0) return "danger" as const;
  if (item.warningCodes.length > 0 || item.lifecycleStatus === "waiting") {
    return "warning" as const;
  }
  if (item.primaryStage === "ready" || item.lifecycleStatus === "published") {
    return "success" as const;
  }
  return "neutral" as const;
}

function stageLabel(stage: SupplyIntakePrimaryStage) {
  return stage[0].toUpperCase() + stage.slice(1);
}

function initialsForLabel(label: string) {
  return label.split(/\s+/u).filter(Boolean).slice(0, 2)
    .map((part) => part[0]?.toUpperCase()).join("") || "?";
}

function formatTimestamp(value: string | null | undefined) {
  return value ? value.replace("T", " ").replace(/\.\d{3}Z$/u, "Z") : "n/a";
}

function readOperationsStage(): SupplyIntakePrimaryStage {
  if (typeof window === "undefined") return "resolve";
  try {
    const value = window.localStorage.getItem(operationsStageKey);
    if (value === "incoming" || value === "verify" ||
      value === "resolve" || value === "ready") return value;
  } catch {
    // Fall through to the exception-first default.
  }
  return "resolve";
}
