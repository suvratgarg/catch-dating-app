import {ExternalLink, Search} from "lucide-react";
import {useEffect, useMemo, useState} from "react";

import {
  AdminButton,
  AdminFieldGrid,
  AdminIntakeReviewWorkbench,
  AdminIntakeSection,
  AdminIntakeStageRail,
  AdminIntakeTaskToolbar,
  AdminLinkButton,
  AdminOrganizerIntakeCheckboxField,
  AdminWorkbenchNote,
  SearchField,
  SelectField,
  TextareaField,
  TextField,
} from "../../../../shared/ui/AdminPrimitives";
import type {AdminDecideOrganizerIntakeResponse} from
  "../../../../shared/types/adminTypes";
import {
  decisionLabel,
  organizerDraftFormFromCandidate,
  publicationPacketReady,
} from "../controllers/organizerIntakeHelpers";
import type {OrganizerIntakeController} from
  "../controllers/useOrganizerIntakeController";
import type * as Intake from "../types/organizerIntakeTypes";

type OrganizerWorkbenchStage = "incoming" | "verify" | "resolve" | "ready";
type OrganizerQueueFilter = "all" | "attention" | "ready";
type OrganizerWorkbenchEntry =
  | {
    id: string;
    kind: "entity";
    item: Intake.OrganizerIntakeItem;
  }
  | {
    id: string;
    kind: "candidate";
    candidate: Intake.OrganizerSearchCandidate;
  };

const organizerWorkbenchStageKey = "catch-admin.organizer-intake-stage.v2";
const organizerTypeOptions = [
  {value: "community", label: "Community"},
  {value: "club", label: "Club"},
  {value: "eventProducer", label: "Event producer"},
  {value: "venue", label: "Venue"},
  {value: "brand", label: "Brand"},
  {value: "individual", label: "Individual"},
];

function OrganizerTaskWorkbench({
  controller,
  onShowDiagnostics,
}: {
  controller: OrganizerIntakeController;
  onShowDiagnostics: () => void;
}) {
  const {
    bridge,
    diagnosticsBridge,
    decisionInFlight,
    decisionNotes,
    curationInFlight,
    handleDecision,
    handleAttachCandidate,
    handleCreateOrganizerDraft,
    handleOpenOrganizerDraft,
    localDecisions,
    localCuration,
    localOrganizerDrafts,
    manualReportAcknowledgements,
    organizerDraftForms,
    organizerDraftInFlight,
    publicationPacketByEntity,
    setDecisionNotes,
    setManualReportAcknowledgements,
    setOrganizerDraftForms,
  } = controller;
  const [activeStage, setActiveStageState] = useState<OrganizerWorkbenchStage>(
    readOrganizerWorkbenchStage
  );
  const [queueFilter, setQueueFilter] = useState<OrganizerQueueFilter>("all");
  const [searchQuery, setSearchQuery] = useState("");
  const [city, setCity] = useState("all");
  const [priority, setPriority] = useState("all");
  const [selectedEntryId, setSelectedEntryId] = useState<string | null>(null);
  const duplicateCandidateIds = useMemo(() => new Set(
    bridge.searchCandidates.duplicateKeys.flatMap((entry) => entry.candidateIds)
  ), [bridge.searchCandidates.duplicateKeys]);

  const draftedCandidateCount = bridge.searchCandidates.candidates.filter(
    (candidate) =>
      Boolean(candidate.draftLink || localOrganizerDrafts[candidate.candidateId])
  ).length;
  const stageCounts = useMemo(() => ({
    incoming: stageItems(bridge.items, publicationPacketByEntity, "incoming").length +
      bridge.searchCandidates.candidates.length - draftedCandidateCount,
    verify: stageItems(bridge.items, publicationPacketByEntity, "verify").length,
    resolve: stageItems(bridge.items, publicationPacketByEntity, "resolve").length,
    ready: stageItems(bridge.items, publicationPacketByEntity, "ready").length +
      draftedCandidateCount,
  }), [
    bridge.items,
    bridge.searchCandidates.candidates.length,
    draftedCandidateCount,
    publicationPacketByEntity,
  ]);
  const cityOptions = useMemo(() => [
    {value: "all", label: "All launch cities"},
    ...Array.from(new Set(
      [
        ...bridge.items.flatMap((item) =>
          item.markets.map((market) => market.displayName)),
        ...bridge.searchCandidates.candidates
          .map((candidate) => candidate.queryIntent.marketSlug)
          .filter((marketSlug): marketSlug is string => Boolean(marketSlug))
          .map(marketLabelForSlug),
      ]
    )).sort().map((label) => ({value: label, label})),
  ], [bridge.items, bridge.searchCandidates.candidates]);
  const stagedEntries = useMemo<OrganizerWorkbenchEntry[]>(() => {
    const entityEntries = stageItems(
      bridge.items,
      publicationPacketByEntity,
      activeStage
    ).map((item) => ({
      id: `entity:${item.entityId}`,
      kind: "entity" as const,
      item,
    }));
    const candidateEntries = bridge.searchCandidates.candidates
      .filter((candidate) => {
        const hasDraft = Boolean(
          candidate.draftLink || localOrganizerDrafts[candidate.candidateId]
        );
        return activeStage === "incoming" ? !hasDraft :
          activeStage === "ready" ? hasDraft : false;
      })
      .map((candidate) => ({
      id: `candidate:${candidate.candidateId}`,
      kind: "candidate" as const,
      candidate,
    }));
    return [...candidateEntries, ...entityEntries];
  }, [
    activeStage,
    bridge.items,
    bridge.searchCandidates.candidates,
    localOrganizerDrafts,
    publicationPacketByEntity,
  ]);
  const filteredEntries = useMemo(() => {
    const query = searchQuery.trim().toLocaleLowerCase();
    return stagedEntries
      .filter((entry) => city === "all" ||
        workbenchEntryMarkets(entry).includes(city))
      .filter((entry) => priority === "all" ||
        workbenchEntryPriority(entry, duplicateCandidateIds) === priority)
      .filter((entry) => queueFilter !== "attention" ||
        workbenchEntryNeedsAttention(
          entry,
          publicationPacketByEntity,
          duplicateCandidateIds
        ))
      .filter((entry) => queueFilter !== "ready" ||
        workbenchEntryIsReady(
          entry,
          publicationPacketByEntity,
          duplicateCandidateIds
        ))
      .filter((entry) => !query || workbenchEntrySearchText(entry).includes(query));
  }, [
    city,
    duplicateCandidateIds,
    priority,
    publicationPacketByEntity,
    queueFilter,
    searchQuery,
    stagedEntries,
  ]);

  useEffect(() => {
    if (filteredEntries.some((entry) => entry.id === selectedEntryId)) return;
    setSelectedEntryId(filteredEntries[0]?.id ?? null);
  }, [filteredEntries, selectedEntryId]);

  const selectedEntry = filteredEntries.find((entry) =>
    entry.id === selectedEntryId) ?? null;
  const item = selectedEntry?.kind === "entity" ? selectedEntry.item : null;
  const candidate = selectedEntry?.kind === "candidate" ?
    selectedEntry.candidate : null;
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
  const candidateChecklist = candidate ?
    organizerCandidateChecklistRows(candidate, duplicateCandidateIds) : [];
  const candidateChecklistComplete =
    candidateChecklist.filter((row) => row.passed).length;
  const candidateInFlight = candidate ?
    curationInFlight[candidate.candidateId] === true : false;
  const candidateCuration = candidate ?
    localCuration[candidate.candidateId] : undefined;
  const candidateDraft = candidate ?
    localOrganizerDrafts[candidate.candidateId] ?? candidate.draftLink :
    undefined;
  const candidateDraftForm = candidate ?
    organizerDraftForms[candidate.candidateId] ??
      organizerDraftFormFromCandidate(candidate) :
    null;
  const candidateDraftPending = candidate ?
    organizerDraftInFlight[candidate.candidateId] === true :
    false;
  const candidateHasDuplicateKey = candidate ?
    duplicateCandidateIds.has(candidate.candidateId) :
    false;

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
        {diagnosticsBridge ? (
          <>
            <AdminButton onClick={onShowDiagnostics}>Diagnostics</AdminButton>
            <AdminButton variant="primary" onClick={onShowDiagnostics}>
              Discovery plan
            </AdminButton>
          </>
        ) : null}
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
        } : candidate ? {
          action: (
            <AdminLinkButton
              href={candidate.canonicalUrl}
              icon={<ExternalLink size={14} strokeWidth={1.9} />}
              label={`Open source for ${candidate.title}`}
              rel="noreferrer"
              target="_blank"
            >
              Open source
            </AdminLinkButton>
          ),
          checklistRows: candidateChecklist,
          checklistTitle: "Candidate checks",
          footerActions: candidate.existingEntityMatches.length > 0 ? (
            <AdminButton
              disabled={candidateInFlight || Boolean(candidateCuration)}
              loading={candidateInFlight}
              loadingLabel="Attaching"
              variant="primary"
              onClick={() => void handleAttachCandidate(candidate)}
            >
              {candidateCuration ? "Attach recorded" : "Attach to existing organizer"}
            </AdminButton>
          ) : candidateDraft ? (
            <AdminButton
              variant="primary"
              onClick={() =>
                handleOpenOrganizerDraft(candidateDraft.organizerId)}
            >
              Open organizer draft
            </AdminButton>
          ) : (
            <AdminButton
              disabled={candidateDraftPending || candidateHasDuplicateKey}
              loading={candidateDraftPending}
              loadingLabel="Creating draft"
              variant="primary"
              onClick={() => void handleCreateOrganizerDraft(candidate)}
            >
              Create organizer draft
            </AdminButton>
          ),
          footerHint: candidateDraft ?
            `Draft ${candidateDraft.organizerId} is unclaimed, hidden, noindex, and crawl-disabled.` :
            candidateCuration ?
            `Recorded at ${candidateCuration.decisionPath}.` :
            candidate.existingEntityMatches.length > 0 ?
              "Attaching records curation only. Publication remains separately gated." :
              candidateHasDuplicateKey ?
                "Resolve the duplicate identity key before creating a canonical draft." :
                "Creation opens an unclaimed draft in Organizers. Publication, indexing, app visibility, crawling, and ownership remain disabled.",
          impactRows: organizerCandidateImpactRows(candidate),
          impactTitle: "Intake impact",
          initials: initialsForLabel(candidate.title),
          note: (
            <AdminIntakeSection>
              <p>
                {candidate.reviewContext?.reviewNotes ??
                  candidate.snippet ??
                  "No search-result snippet was captured for this candidate."}
              </p>
              {candidate.reviewContext?.eventSignal ? (
                <p>{candidate.reviewContext.eventSignal}</p>
              ) : null}
              {candidate.reviewContext?.formats.length ? (
                <p>
                  Formats: {candidate.reviewContext.formats.join(", ")}
                </p>
              ) : null}
              {candidate.existingEntityMatches.length === 0 &&
                !candidateDraft &&
                candidateDraftForm ? (
                  <AdminIntakeSection>
                    <AdminFieldGrid columns={2}>
                      <TextField
                        label="Organizer name"
                        readOnly
                        value={candidateDraftForm.name}
                        onChange={() => undefined}
                      />
                      <TextField
                        label="Public page slug"
                        value={candidateDraftForm.publicSlug}
                        onChange={(publicSlug) =>
                          setOrganizerDraftForms((current) => ({
                            ...current,
                            [candidate.candidateId]: {
                              ...candidateDraftForm,
                              publicSlug,
                            },
                          }))}
                      />
                    </AdminFieldGrid>
                    <SelectField
                      label="Organizer type"
                      options={organizerTypeOptions}
                      value={candidateDraftForm.organizerType}
                      onChange={(organizerType) =>
                        setOrganizerDraftForms((current) => ({
                          ...current,
                          [candidate.candidateId]: {
                            ...candidateDraftForm,
                            organizerType:
                              organizerType as
                                Intake.OrganizerDraftFormState["organizerType"],
                          },
                        }))}
                    />
                    <AdminWorkbenchNote>
                      The organizer record receives a separate opaque document
                      ID. The source title is copied unchanged; corrections use
                      the audited organizer editor. Member-facing description,
                      locality, and listing descriptor stay blank until they
                      are verified.
                    </AdminWorkbenchNote>
                    <TextareaField
                      label="Creation review note"
                      rows={2}
                      value={candidateDraftForm.reviewNote}
                      onChange={(reviewNote) =>
                        setOrganizerDraftForms((current) => ({
                          ...current,
                          [candidate.candidateId]: {
                            ...candidateDraftForm,
                            reviewNote,
                          },
                        }))}
                    />
                  </AdminIntakeSection>
                ) : null}
            </AdminIntakeSection>
          ),
          noteTitle: candidate.reviewContext ?
            "Reviewed intake context" : "Captured search context",
          primaryRows: organizerCandidateEvidenceRows(candidate),
          primaryTitle: "Source evidence",
          readiness: {
            blockers: candidateChecklist.length - candidateChecklistComplete,
            complete: candidateChecklistComplete,
            label: "Candidate readiness",
            total: candidateChecklist.length,
          },
          status: organizerCandidateStatus(
            candidate,
            duplicateCandidateIds,
            Boolean(candidateDraft)
          ).label,
          statusTone: organizerCandidateStatus(
            candidate,
            duplicateCandidateIds,
            Boolean(candidateDraft)
          ).tone,
          subtitle:
            `Search candidate · ${candidateMarketLabel(candidate)} · observed ${candidate.observedAt}`,
          title: candidate.title,
        } : null}
        emptyDetail="Select an organizer lead to review evidence and handoff impact."
        emptyQueue="No organizer leads match this stage and filter set."
        filters={[
          {id: "all", label: `All ${filteredEntries.length}`, selected: queueFilter === "all"},
          {id: "attention", label: "Needs attention", selected: queueFilter === "attention"},
          {id: "ready", label: "Ready", selected: queueFilter === "ready"},
        ]}
        items={filteredEntries.map((entry) =>
          entry.kind === "entity" ?
            queueItem(
              entry.item,
              publicationPacketByEntity.get(entry.item.entityId)
            ) :
            organizerCandidateQueueItem(
              entry.candidate,
              duplicateCandidateIds,
              Boolean(
                entry.candidate.draftLink ||
                localOrganizerDrafts[entry.candidate.candidateId]
              )
            ))}
        queueMeta={`${filteredEntries.length} item${filteredEntries.length === 1 ? "" : "s"}`}
        queueTitle={stageTitle(activeStage)}
        selectedId={selectedEntryId}
        onFilterChange={(filterId) => setQueueFilter(filterId as OrganizerQueueFilter)}
        onSelect={setSelectedEntryId}
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

function workbenchEntryMarkets(entry: OrganizerWorkbenchEntry) {
  if (entry.kind === "candidate") {
    return [candidateMarketLabel(entry.candidate)];
  }
  return entry.item.markets.map((market) => market.displayName);
}

function workbenchEntryPriority(
  entry: OrganizerWorkbenchEntry,
  duplicateCandidateIds: Set<string>
) {
  if (entry.kind === "entity") return entry.item.priority;
  if (
    entry.candidate.existingEntityMatches.length > 0 ||
    duplicateCandidateIds.has(entry.candidate.candidateId)
  ) {
    return "p0";
  }
  if (
    entry.candidate.reviewAction === "supporting_evidence_only" ||
    entry.candidate.normalizedKey === null
  ) {
    return "p2";
  }
  return "p1";
}

function workbenchEntryNeedsAttention(
  entry: OrganizerWorkbenchEntry,
  packets: Map<string, Intake.OrganizerPublicationReviewPacket>,
  duplicateCandidateIds: Set<string>
) {
  if (entry.kind === "candidate") {
    if (entry.candidate.draftLink) return true;
    return organizerCandidateChecklistRows(
      entry.candidate,
      duplicateCandidateIds
    ).some((row) => !row.passed);
  }
  return organizerItemNeedsAttention(
    entry.item,
    packets.get(entry.item.entityId)
  );
}

function workbenchEntryIsReady(
  entry: OrganizerWorkbenchEntry,
  packets: Map<string, Intake.OrganizerPublicationReviewPacket>,
  duplicateCandidateIds: Set<string>
) {
  if (entry.kind === "candidate") {
    return organizerCandidateChecklistRows(
      entry.candidate,
      duplicateCandidateIds
    ).every((row) => row.passed);
  }
  return organizerItemIsReady(entry.item, packets.get(entry.item.entityId));
}

function workbenchEntrySearchText(entry: OrganizerWorkbenchEntry) {
  if (entry.kind === "entity") return organizerSearchText(entry.item);
  const candidate = entry.candidate;
  return [
    candidate.title,
    candidate.candidateId,
    candidate.platform,
    candidate.surfaceKind,
    candidate.reviewAction,
    candidate.snippet,
    candidate.query,
    candidate.queryIntent.marketSlug,
    candidate.queryIntent.activityKind,
    ...candidate.diagnostics,
    ...candidate.existingEntityMatches.map((match) => match.entityId),
    candidate.reviewContext?.recordStatus,
    candidate.reviewContext?.eventSignal,
    candidate.reviewContext?.reviewNotes,
    ...(candidate.reviewContext?.formats ?? []),
    ...(candidate.reviewContext?.sources ?? []),
  ].filter(Boolean).join(" ").toLocaleLowerCase();
}

function organizerCandidateQueueItem(
  candidate: Intake.OrganizerSearchCandidate,
  duplicateCandidateIds: Set<string>,
  hasDraft = Boolean(candidate.draftLink)
) {
  const status = organizerCandidateStatus(
    candidate,
    duplicateCandidateIds,
    hasDraft
  );
  return {
    description: `${candidate.platform} · ${candidateMarketLabel(candidate)}`,
    id: `candidate:${candidate.candidateId}`,
    initials: initialsForLabel(candidate.title),
    meta: candidate.reviewContext ?
      `${candidate.reviewContext.recordStatus.replaceAll("_", " ")} · verified ${candidate.reviewContext.verifiedAt ?? "date unavailable"}` :
      `#${candidate.rank} · ${candidate.reviewAction.replaceAll("_", " ")}`,
    status: status.label,
    statusTone: status.tone,
    title: candidate.title,
  };
}

function organizerCandidateStatus(
  candidate: Intake.OrganizerSearchCandidate,
  duplicateCandidateIds: Set<string>,
  hasDraft = Boolean(candidate.draftLink)
): {label: string; tone: "neutral" | "warning" | "danger" | "success"} {
  if (hasDraft) {
    return {label: "draft created", tone: "success"};
  }
  if (duplicateCandidateIds.has(candidate.candidateId)) {
    return {label: "duplicate key", tone: "danger"};
  }
  if (candidate.existingEntityMatches.length > 0) {
    return {label: "matched", tone: "success"};
  }
  if (!candidate.normalizedKey) {
    return {label: "needs identity", tone: "danger"};
  }
  if (candidate.diagnostics.length > 0) {
    return {label: "needs review", tone: "warning"};
  }
  if (candidate.reviewContext?.recordStatus === "review_now") {
    return {label: "review now", tone: "success"};
  }
  return {label: "new lead", tone: "neutral"};
}

function organizerCandidateChecklistRows(
  candidate: Intake.OrganizerSearchCandidate,
  duplicateCandidateIds: Set<string>
) {
  const duplicateKey = duplicateCandidateIds.has(candidate.candidateId);
  const ownershipConfirmed =
    candidate.suggestedSurface.confidence.ownership === "high";
  return [
    {
      id: "market",
      label: "Pilot market assigned",
      meta: candidateMarketLabel(candidate),
      passed: Boolean(candidate.queryIntent.marketSlug),
    },
    {
      id: "source",
      label: "Source URL captured",
      meta: candidate.platform,
      passed: Boolean(candidate.canonicalUrl),
    },
    {
      id: "identity",
      label: "Unique identity key",
      meta: duplicateKey ?
        "collides with another candidate" :
        candidate.normalizedKey ?? "missing",
      passed: Boolean(candidate.normalizedKey) && !duplicateKey,
    },
    {
      id: "ownership",
      label: "Organizer ownership confirmed",
      meta: ownershipConfirmed ? "confirmed" : "manual review required",
      passed: ownershipConfirmed,
    },
    {
      id: "review-context",
      label: "Reviewed intake evidence",
      meta: candidate.reviewContext?.verifiedAt ??
        "No reviewed shortlist context",
      passed: Boolean(candidate.reviewContext?.verifiedAt),
    },
  ];
}

function organizerCandidateEvidenceRows(
  candidate: Intake.OrganizerSearchCandidate
) {
  const primarySource = {
    href: candidate.canonicalUrl,
    id: "source",
    meta: candidate.snippet ?? candidate.query,
    status: `observed ${candidate.observedAt}`,
    statusTone: "neutral" as const,
    title:
      `${candidate.platform} · ${candidate.surfaceKind.replaceAll("_", " ")}`,
  };
  const reviewedSources = (candidate.reviewContext?.sources ?? [])
    .filter((source) => source !== candidate.canonicalUrl)
    .map((source, index) => ({
      href: source,
      id: `review-source:${index}`,
      meta: candidate.reviewContext?.eventSignal ?? "Reviewed source",
      status: `verified ${candidate.reviewContext?.verifiedAt ?? "date unavailable"}`,
      statusTone: "success" as const,
      title: `Reviewed source ${index + 1}`,
    }));
  return [
    primarySource,
    ...reviewedSources,
    {
      id: "query",
      meta: candidate.query,
      status: candidate.reviewAction.replaceAll("_", " "),
      statusTone: candidate.existingEntityMatches.length > 0 ?
        "success" as const : "warning" as const,
      title: "Discovery query",
    },
    {
      id: "provenance",
      meta: "Only source-linked values are projected into the draft.",
      status:
        `${candidate.fieldProvenance?.length ?? 0} mapped source fields`,
      statusTone: candidate.fieldProvenance?.length ?
        "success" as const :
        "warning" as const,
      title: "Field provenance",
    },
  ];
}

function organizerCandidateImpactRows(
  candidate: Intake.OrganizerSearchCandidate
) {
  return [
    {
      id: "entity",
      label: "Organizer record",
      value: candidate.existingEntityMatches[0]?.entityId ?
        `Attach to ${candidate.existingEntityMatches[0].entityId}` :
        "Draft required",
    },
    {id: "website", label: "Website listing", value: "No write"},
    {id: "app", label: "App visibility", value: "Hidden"},
    {id: "crawl", label: "Recurring crawl", value: "Disabled"},
    {id: "market", label: "Pilot market", value: candidateMarketLabel(candidate)},
    ...(candidate.reviewContext ? [{
      id: "record-status",
      label: "Review status",
      value: candidate.reviewContext.recordStatus.replaceAll("_", " "),
    }, {
      id: "inventory",
      label: "Existing inventory",
      value: candidate.reviewContext.existingInventory ? "Attach" : "Net new",
    }] : []),
  ];
}

function candidateMarketLabel(candidate: Intake.OrganizerSearchCandidate) {
  return candidate.queryIntent.marketSlug ?
    marketLabelForSlug(candidate.queryIntent.marketSlug) :
    "Market unassigned";
}

function marketLabelForSlug(slug: string) {
  return slug.split("-")
    .map((part) => part.length > 0 ?
      `${part[0]?.toLocaleUpperCase()}${part.slice(1)}` : part)
    .join(" ");
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
  if (typeof window === "undefined") return "incoming";
  try {
    const value = window.localStorage.getItem(organizerWorkbenchStageKey);
    if (value === "incoming" || value === "verify" || value === "resolve" || value === "ready") {
      return value;
    }
  } catch {
    // Fall through to the review-first default.
  }
  return "incoming";
}

export const organizerIntakeWorkbench = {OrganizerTaskWorkbench};
