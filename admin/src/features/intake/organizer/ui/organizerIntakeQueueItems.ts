import type * as Intake from "../types/organizerIntakeTypes";

export function organizerEntityEntryId(entityId: string) {
  return `entity:${entityId}`;
}

export function organizerItemStatus(
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
  if (item.publishStatus === "published") {
    return {label: "published", tone: "success"};
  }
  return {label: "review", tone: "neutral"};
}

export function organizerMarketLabel(item: Intake.OrganizerIntakeItem) {
  return item.markets.map((market) => market.displayName).join(", ") ||
    "Market unassigned";
}

export function initialsForLabel(label: string) {
  return label.split(/\s+/u).filter(Boolean).slice(0, 2)
    .map((part) => part[0]?.toUpperCase()).join("") || "?";
}

export function candidateMarketLabel(
  candidate: Intake.OrganizerSearchCandidate
) {
  return candidate.queryIntent.marketSlug ?
    marketLabelForSlug(candidate.queryIntent.marketSlug) :
    "Market unassigned";
}

export function marketLabelForSlug(slug: string) {
  return slug.split("-")
    .map((part) => part.length > 0 ?
      `${part[0]?.toLocaleUpperCase()}${part.slice(1)}` : part)
    .join(" ");
}

export function organizerIntakeAgeDays(
  value: string | null | undefined,
  nowMs = Date.now()
) {
  if (!value) return null;
  const timestamp = Date.parse(value);
  if (!Number.isFinite(timestamp)) return null;
  return Math.max(0, Math.floor((nowMs - timestamp) / 86_400_000));
}

export function organizerIntakeAgeLabel(
  value: string | null | undefined,
  nowMs = Date.now()
) {
  const days = organizerIntakeAgeDays(value, nowMs);
  return days === null ? "—" : days === 0 ? "Today" : `${days}d`;
}

export function organizerCandidateQueueItem(
  candidate: Intake.OrganizerSearchCandidate,
  duplicateCandidateIds: Set<string>,
  hasDraft = Boolean(candidate.draftLink),
  nowMs = Date.now()
) {
  const status = organizerCandidateStatus(
    candidate,
    duplicateCandidateIds,
    hasDraft
  );
  const checklist = organizerCandidateChecklistRows(
    candidate,
    duplicateCandidateIds
  );
  const blocker = checklist.find((row) => !row.passed);
  return {
    age: organizerIntakeAgeLabel(candidate.observedAt, nowMs),
    ageDays: organizerIntakeAgeDays(candidate.observedAt, nowMs),
    blocker: blocker?.label ?? "—",
    blockerKey: blocker?.id ?? null,
    description: `${candidate.platform} · ${candidateMarketLabel(candidate)}`,
    id: `candidate:${candidate.candidateId}`,
    initials: initialsForLabel(candidate.title),
    kind: "Candidate",
    market: candidateMarketLabel(candidate),
    meta: candidate.reviewContext ?
      `${candidate.reviewContext.recordStatus.replaceAll("_", " ")} · verified ${candidate.reviewContext.verifiedAt ?? "date unavailable"}` :
      `#${candidate.rank} · ${candidate.reviewAction.replaceAll("_", " ")}`,
    source: candidate.platform,
    status: status.label,
    statusTone: status.tone,
    title: candidate.title,
  };
}

export function organizerCandidateStatus(
  candidate: Intake.OrganizerSearchCandidate,
  duplicateCandidateIds: Set<string>,
  hasDraft = Boolean(candidate.draftLink)
): {label: string; tone: "neutral" | "warning" | "danger" | "success"} {
  if (hasDraft) return {label: "draft created", tone: "success"};
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

export function organizerCandidateChecklistRows(
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

export function organizerEntityQueueItem(
  item: Intake.OrganizerIntakeItem,
  packet?: Intake.OrganizerPublicationReviewPacket
) {
  const status = organizerItemStatus(item, packet);
  const market = organizerMarketLabel(item);
  return {
    age: "—",
    ageDays: null,
    blocker: item.blockers[0]?.replaceAll("_", " ") ??
      packet?.dataBlockers[0]?.replaceAll("_", " ") ??
      packet?.evidenceBlockers[0]?.replaceAll("_", " ") ??
      "—",
    blockerKey: item.blockers[0] ??
      packet?.dataBlockers[0] ??
      packet?.evidenceBlockers[0] ??
      null,
    description: `${packet?.identity.activity.primaryActivityKind
      ?.replaceAll(/([a-z])([A-Z])/gu, "$1 $2") ?? "Organizer"} · ${market}`,
    id: organizerEntityEntryId(item.entityId),
    initials: initialsForLabel(item.displayName),
    kind: "Organizer",
    market,
    meta: `${item.surfaceSummary.total} surfaces · ${packet?.evidenceSummary.manualReportsWithoutArtifacts ?? 0} reports`,
    source: Object.keys(item.surfaceSummary.platforms).join(", ") || "No source",
    status: status.label,
    statusTone: status.tone,
    title: item.displayName,
  };
}
