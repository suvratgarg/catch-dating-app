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
