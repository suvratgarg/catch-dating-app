import {ExternalLink, Search} from "lucide-react";
import {useEffect, useMemo, useState} from "react";

import {
  AdminButton,
  AdminIntakeReviewWorkbench,
  AdminIntakeSection,
  AdminIntakeStageRail,
  AdminIntakeTaskToolbar,
  AdminLinkButton,
  AdminOrganizerIntakeCheckboxField,
  SearchField,
  SelectField,
  TextareaField,
} from "../../../../shared/ui/AdminPrimitives";
import type {AdminDecideOrganizerIntakeResponse} from
  "../../../../shared/types/adminTypes";
import {
  decisionLabel,
  publicationPacketReady,
} from "../controllers/organizerIntakeHelpers";
import type {OrganizerIntakeController} from
  "../controllers/useOrganizerIntakeController";
import type * as Intake from "../types/organizerIntakeTypes";

type OrganizerWorkbenchStage = "incoming" | "verify" | "resolve" | "ready";
type OrganizerQueueFilter = "all" | "attention" | "ready";

const organizerWorkbenchStageKey = "catch-admin.organizer-intake-stage.v1";

function OrganizerTaskWorkbench({
  controller,
  onShowDiagnostics,
}: {
  controller: OrganizerIntakeController;
  onShowDiagnostics: () => void;
}) {
  const {
    bridge,
    decisionInFlight,
    decisionNotes,
    handleDecision,
    localDecisions,
    manualReportAcknowledgements,
    publicationPacketByEntity,
    setDecisionNotes,
    setManualReportAcknowledgements,
  } = controller;
  const [activeStage, setActiveStageState] = useState<OrganizerWorkbenchStage>(
    readOrganizerWorkbenchStage
  );
  const [queueFilter, setQueueFilter] = useState<OrganizerQueueFilter>("all");
  const [searchQuery, setSearchQuery] = useState("");
  const [city, setCity] = useState("all");
  const [priority, setPriority] = useState("all");
  const [selectedEntityId, setSelectedEntityId] = useState<string | null>(
    bridge.items[0]?.entityId ?? null
  );

  const stageCounts = useMemo(() => ({
    incoming: stageItems(bridge.items, publicationPacketByEntity, "incoming").length +
      bridge.searchCandidates.summary.candidates,
    verify: stageItems(bridge.items, publicationPacketByEntity, "verify").length,
    resolve: stageItems(bridge.items, publicationPacketByEntity, "resolve").length,
    ready: stageItems(bridge.items, publicationPacketByEntity, "ready").length,
  }), [bridge.items, bridge.searchCandidates.summary.candidates, publicationPacketByEntity]);
  const cityOptions = useMemo(() => [
    {value: "all", label: "All launch cities"},
    ...Array.from(new Set(
      bridge.items.flatMap((item) => item.markets.map((market) => market.displayName))
    )).sort().map((label) => ({value: label, label})),
  ], [bridge.items]);
  const filteredItems = useMemo(() => {
    const query = searchQuery.trim().toLocaleLowerCase();
    return stageItems(bridge.items, publicationPacketByEntity, activeStage)
      .filter((item) => city === "all" ||
        item.markets.some((market) => market.displayName === city))
      .filter((item) => priority === "all" || item.priority === priority)
      .filter((item) => queueFilter !== "attention" ||
        organizerItemNeedsAttention(item, publicationPacketByEntity.get(item.entityId)))
      .filter((item) => queueFilter !== "ready" ||
        organizerItemIsReady(item, publicationPacketByEntity.get(item.entityId)))
      .filter((item) => !query || organizerSearchText(item).includes(query));
  }, [
    activeStage,
    bridge.items,
    city,
    priority,
    publicationPacketByEntity,
    queueFilter,
    searchQuery,
  ]);

  useEffect(() => {
    if (filteredItems.some((item) => item.entityId === selectedEntityId)) return;
    setSelectedEntityId(filteredItems[0]?.entityId ?? null);
  }, [filteredItems, selectedEntityId]);

  const item = bridge.items.find((candidate) =>
    candidate.entityId === selectedEntityId
  ) ?? null;
  const packet = item ? publicationPacketByEntity.get(item.entityId) : undefined;
  const manualReports = packet?.evidenceSummary.manualReportsWithoutArtifacts ?? 0;
  const reportsAcknowledged = item ?
    manualReportAcknowledgements[item.entityId] === true : false;
  const inFlight = item ? decisionInFlight[item.entityId] : undefined;
  const decision = item ? localDecisions[item.entityId] : undefined;
  const checklistEntries = Object.entries(packet?.approvalChecklist ?? {});
  const checklistComplete = checklistEntries.filter(([, passed]) => passed).length;
  const canApprove = Boolean(
    item && publicationPacketReady(packet) &&
    (manualReports === 0 || reportsAcknowledged)
  );

  const setStage = (stage: OrganizerWorkbenchStage) => {
    setActiveStageState(stage);
    setQueueFilter("all");
    try {
      window.localStorage.setItem(organizerWorkbenchStageKey, stage);
    } catch {
      // The in-memory stage still works when storage is unavailable.
    }
  };

  return (
    <>
      <AdminIntakeTaskToolbar aria-label="Organizer intake filters">
        <SearchField
          ariaLabel="Search organizer intake"
          icon={<Search size={15} strokeWidth={1.9} />}
          placeholder="Search organizer, source, city..."
          value={searchQuery}
          onChange={setSearchQuery}
        />
        <SelectField label="City" options={cityOptions} value={city} onChange={setCity} />
        <SelectField
          label="Priority"
          options={[
            {value: "all", label: "All priorities"},
            {value: "p0", label: "P0"},
            {value: "p1", label: "P1"},
            {value: "p2", label: "P2"},
          ]}
          value={priority}
          onChange={setPriority}
        />
        <AdminButton onClick={onShowDiagnostics}>Diagnostics</AdminButton>
        <AdminButton variant="primary" onClick={onShowDiagnostics}>
          Discovery plan
        </AdminButton>
      </AdminIntakeTaskToolbar>
      <AdminIntakeStageRail<OrganizerWorkbenchStage>
        ariaLabel="Organizer intake stages"
        options={[
          {id: "incoming", label: "Incoming", meta: `${stageCounts.incoming} new leads`},
          {id: "verify", label: "Verify", meta: `${stageCounts.verify} need review`},
          {id: "resolve", label: "Resolve", meta: `${stageCounts.resolve} need attention`},
          {id: "ready", label: "Ready", meta: `${stageCounts.ready} handoffs`},
        ]}
        value={activeStage}
        onChange={setStage}
      />
      <AdminIntakeReviewWorkbench
        detail={item ? {
          action: packet?.publicPresence.canonicalPath ? (
            <AdminLinkButton
              href={`https://catchdates.com${packet.publicPresence.canonicalPath}`}
              icon={<ExternalLink size={14} strokeWidth={1.9} />}
              label={`Open public preview for ${item.displayName}`}
              rel="noreferrer"
              target="_blank"
            >
              Open preview
            </AdminLinkButton>
          ) : null,
          checklistRows: organizerChecklistRows(packet, reportsAcknowledged),
          checklistTitle: "Review checklist",
          footerActions: (
            <>
              <AdminButton
                disabled={Boolean(inFlight)}
                loading={inFlight === "suppress"}
                loadingLabel="Rejecting"
                onClick={() => void handleDecision(item, "suppress")}
              >Reject</AdminButton>
              <AdminButton
                disabled={Boolean(inFlight)}
                loading={inFlight === "hold"}
                loadingLabel="Holding"
                onClick={() => void handleDecision(item, "hold")}
              >Hold</AdminButton>
              <AdminButton
                disabled={!canApprove || Boolean(inFlight)}
                loading={inFlight === "approve_public"}
                loadingLabel="Approving"
                variant="primary"
                onClick={() => void handleDecision(item, "approve_public")}
              >Approve listing</AdminButton>
            </>
          ),
          footerHint: organizerDecisionHint(
            decision, packet, manualReports, reportsAcknowledged
          ),
          impactRows: organizerImpactRows(item, packet),
          impactTitle: "Handoff impact",
          initials: initialsForLabel(item.displayName),
          note: (
            <AdminIntakeSection>
              <TextareaField
                label="Decision note"
                placeholder="Add evidence or explain why this organizer should advance..."
                rows={2}
                value={decisionNotes[item.entityId] ?? ""}
                onChange={(note) => setDecisionNotes((current) => ({
                  ...current,
                  [item.entityId]: note,
                }))}
              />
              {manualReports > 0 ? (
                <AdminOrganizerIntakeCheckboxField
                  checked={reportsAcknowledged}
                  label={`I reviewed ${manualReports} manual report${manualReports === 1 ? "" : "s"} without attached artifacts.`}
                  onChange={(checked) => setManualReportAcknowledgements((current) => ({
                    ...current,
                    [item.entityId]: checked,
                  }))}
                />
              ) : null}
            </AdminIntakeSection>
          ),
          noteTitle: "Decision note",
          primaryRows: organizerEvidenceRows(item, packet),
          primaryTitle: "Source evidence",
          readiness: {
            blockers: decisionBlockerCount(packet, reportsAcknowledged),
            complete: checklistComplete +
              (manualReports === 0 || reportsAcknowledged ? 1 : 0),
            label: "Decision readiness",
            total: checklistEntries.length + 1,
          },
          status: organizerItemStatus(item, packet).label,
          statusTone: organizerItemStatus(item, packet).tone,
          subtitle: `Organizer lead · ${item.entityId} · ${marketLabel(item)}`,
          title: item.displayName,
        } : null}
        emptyDetail="Select an organizer lead to review evidence and handoff impact."
        emptyQueue="No organizer leads match this stage and filter set."
        filters={[
          {id: "all", label: `All ${filteredItems.length}`, selected: queueFilter === "all"},
          {id: "attention", label: "Needs attention", selected: queueFilter === "attention"},
          {id: "ready", label: "Ready", selected: queueFilter === "ready"},
        ]}
        items={filteredItems.map((candidate) => queueItem(
          candidate,
          publicationPacketByEntity.get(candidate.entityId)
        ))}
        queueMeta={`${filteredItems.length} item${filteredItems.length === 1 ? "" : "s"}`}
        queueTitle={stageTitle(activeStage)}
        selectedId={selectedEntityId}
        onFilterChange={(filterId) => setQueueFilter(filterId as OrganizerQueueFilter)}
        onSelect={setSelectedEntityId}
      />
    </>
  );
}

function stageItems(
  items: Intake.OrganizerIntakeItem[],
  packets: Map<string, Intake.OrganizerPublicationReviewPacket>,
  stage: OrganizerWorkbenchStage
) {
  return items.filter((item) => {
    const packet = packets.get(item.entityId);
    if (stage === "incoming") {
      return item.reviewStatus === "new" || item.taskType.includes("discovery");
    }
    if (stage === "verify") {
      return item.reviewStatus.includes("review") || item.reviewStatus.includes("evidence");
    }
    if (stage === "resolve") return organizerItemNeedsAttention(item, packet);
    return organizerItemIsReady(item, packet);
  });
}

function organizerItemNeedsAttention(
  item: Intake.OrganizerIntakeItem,
  packet?: Intake.OrganizerPublicationReviewPacket
) {
  return item.blockers.length > 0 || item.surfaceSummary.ambiguous > 0 ||
    item.surfaceSummary.candidate > 0 ||
    (packet?.evidenceSummary.manualReportsWithoutArtifacts ?? 0) > 0 ||
    (packet?.dataBlockers.length ?? 0) > 0 ||
    (packet?.evidenceBlockers.length ?? 0) > 0;
}

function organizerItemIsReady(
  item: Intake.OrganizerIntakeItem,
  packet?: Intake.OrganizerPublicationReviewPacket
) {
  return publicationPacketReady(packet) || item.publishStatus === "published";
}

function organizerItemStatus(
  item: Intake.OrganizerIntakeItem,
  packet?: Intake.OrganizerPublicationReviewPacket
): {label: string; tone: "neutral" | "warning" | "danger" | "success"} {
  if ((packet?.dataBlockers.length ?? 0) > 0 || item.blockers.length > 0) {
    return {label: "blocked", tone: "danger"};
  }
  if ((packet?.evidenceSummary.manualReportsWithoutArtifacts ?? 0) > 0 ||
      item.reviewStatus.includes("evidence")) {
    return {label: "needs evidence", tone: "warning"};
  }
  if (item.surfaceSummary.ambiguous > 0 || item.surfaceSummary.candidate > 0) {
    return {label: "resolve", tone: "warning"};
  }
  if (item.publishStatus === "published") return {label: "published", tone: "success"};
  return {label: "review", tone: "neutral"};
}

function organizerEvidenceRows(
  item: Intake.OrganizerIntakeItem,
  packet?: Intake.OrganizerPublicationReviewPacket
) {
  const rows = packet?.evidenceReview.records.slice(0, 4).map((record) => ({
    href: record.surface.url,
    id: record.evidenceId,
    meta: record.evidence.description ?? record.nextAction.replaceAll("_", " "),
    status: record.evidence.status === "resolved_artifact" ?
      "confirmed" : record.evidence.status.replaceAll("_", " "),
    statusTone: record.riskFlags.length > 0 ? "warning" as const :
      record.evidence.status === "resolved_artifact" ? "success" as const : "neutral" as const,
    title: `${record.surface.platform} · ${record.surface.surfaceKind.replaceAll("_", " ")}`,
  })) ?? [];
  return rows.length > 0 ? rows : item.surfaces.slice(0, 4).map((surface) => ({
    href: surface.url,
    id: surface.surfaceId,
    meta: surface.notes,
    status: surface.status.replaceAll("_", " "),
    statusTone: surface.status === "active" ? "success" as const : "warning" as const,
    title: `${surface.platform} · ${surface.surfaceKind.replaceAll("_", " ")}`,
  }));
}

function organizerChecklistRows(
  packet: Intake.OrganizerPublicationReviewPacket | undefined,
  reportsAcknowledged: boolean
) {
  if (!packet) return [{id: "packet", label: "Generate a publication packet", meta: "required", passed: false}];
  const checklist = Object.entries(packet.approvalChecklist);
  const complete = checklist.filter(([, passed]) => passed).length;
  const rows = [{
    id: "checks",
    label: `${complete} identity, market, copy, media, and crawl checks passed`,
    meta: complete === checklist.length ? "complete" : "required",
    passed: complete === checklist.length,
  }];
  [...packet.blockers, ...packet.dataBlockers, ...packet.evidenceBlockers]
    .slice(0, 2).forEach((blocker, index) => rows.push({
      id: `blocker:${index}`,
      label: blocker.replaceAll("_", " "),
      meta: "required",
      passed: false,
    }));
  if (packet.evidenceSummary.manualReportsWithoutArtifacts > 0) rows.push({
    id: "manual-reports",
    label: `Acknowledge ${packet.evidenceSummary.manualReportsWithoutArtifacts} manual reports`,
    meta: reportsAcknowledged ? "complete" : "required",
    passed: reportsAcknowledged,
  });
  if (packet.status === "published") rows.push({
    id: "published",
    label: "Publishing handoff already completed",
    meta: "complete",
    passed: true,
  });
  return rows;
}

function organizerImpactRows(
  item: Intake.OrganizerIntakeItem,
  packet?: Intake.OrganizerPublicationReviewPacket
) {
  return [
    {
      id: "website",
      label: "Website listing",
      tone: item.publishStatus === "published" ? "success" as const : "neutral" as const,
      value: item.publishStatus === "published" ? "Published" : "Ready after review",
    },
    {id: "app", label: "App visibility", value: item.appVisibility.replaceAll("_", " ")},
    {id: "claim", label: "Claim handoff", value: packet?.publicPresence.claimTargetPath ? "Target prepared" : "No target"},
    {id: "crawl", label: "Recurring crawl", value: item.surfaces.some((surface) => surface.crawl.policy !== "blocked") ? "Manual only" : "Blocked"},
    {id: "canonical", label: "Canonical organizer", value: "Separate workspace"},
  ];
}

function organizerDecisionHint(
  decision: AdminDecideOrganizerIntakeResponse | undefined,
  packet: Intake.OrganizerPublicationReviewPacket | undefined,
  manualReports: number,
  reportsAcknowledged: boolean
) {
  if (decision) return `Recorded ${decisionLabel(decision.decision)} at ${decision.decisionPath}.`;
  if (!packet) return "Approval is disabled until a publication packet exists.";
  if (packet.status === "published") {
    return "This handoff is already published. Use Organizers for canonical edits or visibility changes.";
  }
  if (manualReports > 0 && !reportsAcknowledged) {
    return "Approval is disabled until manual reports are acknowledged.";
  }
  return publicationPacketReady(packet) ?
    "Approval records a website handoff and keeps app visibility hidden." :
    "Approval is disabled until packet blockers and checklist gates are resolved.";
}

function decisionBlockerCount(
  packet: Intake.OrganizerPublicationReviewPacket | undefined,
  reportsAcknowledged: boolean
) {
  if (!packet || packet.status === "published") return packet ? 0 : 1;
  return packet.blockers.length + packet.dataBlockers.length +
    packet.evidenceBlockers.length +
    Object.values(packet.approvalChecklist).filter((passed) => !passed).length +
    (packet.evidenceSummary.manualReportsWithoutArtifacts > 0 && !reportsAcknowledged ? 1 : 0);
}

function queueItem(
  item: Intake.OrganizerIntakeItem,
  packet?: Intake.OrganizerPublicationReviewPacket
) {
  const status = organizerItemStatus(item, packet);
  return {
    description: `${activityLabel(packet)} · ${marketLabel(item)}`,
    id: item.entityId,
    initials: initialsForLabel(item.displayName),
    meta: `${item.surfaceSummary.total} surfaces · ${packet?.evidenceSummary.manualReportsWithoutArtifacts ?? 0} reports`,
    status: status.label,
    statusTone: status.tone,
    title: item.displayName,
  };
}

function organizerSearchText(item: Intake.OrganizerIntakeItem) {
  return [
    item.displayName,
    item.entityId,
    item.taskType,
    item.reviewStatus,
    ...item.markets.map((market) => market.displayName),
    ...Object.keys(item.surfaceSummary.platforms),
  ].join(" ").toLocaleLowerCase();
}

function activityLabel(packet?: Intake.OrganizerPublicationReviewPacket) {
  return packet?.identity.activity.primaryActivityKind
    ?.replaceAll(/([a-z])([A-Z])/gu, "$1 $2") ?? "Organizer";
}

function marketLabel(item: Intake.OrganizerIntakeItem) {
  return item.markets.map((market) => market.displayName).join(", ") || "Market unassigned";
}

function initialsForLabel(label: string) {
  return label.split(/\s+/u).filter(Boolean).slice(0, 2)
    .map((part) => part[0]?.toUpperCase()).join("") || "?";
}

function stageTitle(stage: OrganizerWorkbenchStage) {
  if (stage === "incoming") return "Incoming organizer leads";
  if (stage === "verify") return "Needs verification";
  if (stage === "resolve") return "Resolve evidence and identity";
  return "Ready handoffs";
}

function readOrganizerWorkbenchStage(): OrganizerWorkbenchStage {
  if (typeof window === "undefined") return "verify";
  try {
    const value = window.localStorage.getItem(organizerWorkbenchStageKey);
    if (value === "incoming" || value === "verify" || value === "resolve" || value === "ready") {
      return value;
    }
  } catch {
    // Fall through to the review-first default.
  }
  return "verify";
}

export const organizerIntakeWorkbench = {OrganizerTaskWorkbench};
