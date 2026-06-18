export function buildCanonicalHostEntityRegistry({
  entityList = [],
  projectionPlan = emptyProjectionPlan(),
  claimTargetPlan = emptyClaimTargetPlan(),
  dedupeIndex = emptyDedupeIndex(),
  reviewQueue = emptyReviewQueue(),
  curationState = emptyCurationState(),
} = {}) {
  const projectionByEntity = new Map(
    (projectionPlan.entries ?? []).map((entry) => [entry.entityId, entry])
  );
  const claimTargetByEntity = new Map(
    (claimTargetPlan.targets ?? []).map((target) => [target.entityId, target])
  );
  const reviewItemByEntity = new Map(
    (reviewQueue.items ?? []).map((item) => [item.entityId, item])
  );
  const dedupeKeysByEntity = groupBy(dedupeIndex.dedupeKeys ?? [], "entityId");
  const conflictsByEntity = conflictsByEntityId(dedupeIndex.conflicts ?? []);
  const curationByEntity = curationSummaryByEntity(curationState);

  const entries = [...entityList]
    .sort((a, b) => a.entityId.localeCompare(b.entityId))
    .map((entity) => canonicalHostEntity({
      claimTarget: claimTargetByEntity.get(entity.entityId) ?? null,
      conflicts: conflictsByEntity.get(entity.entityId) ?? [],
      curation: curationByEntity.get(entity.entityId) ?? emptyEntityCuration(),
      dedupeKeys: dedupeKeysByEntity.get(entity.entityId) ?? [],
      entity,
      projection: projectionByEntity.get(entity.entityId) ?? null,
      reviewItem: reviewItemByEntity.get(entity.entityId) ?? null,
    }));

  return {
    schemaVersion: 1,
    generatedFrom: {
      effectiveEntities: "tool/organizer_intake/batches/*.json plus curation decisions",
      dedupeIndex: "tool/organizer_intake/generated/organizer_dedupe_index.json",
      publicProjectionPlan:
        "tool/organizer_intake/generated/public_projection_plan.json",
      claimTargetPlan:
        "tool/organizer_intake/generated/organizer_claim_targets.json",
      adminReviewQueue:
        "tool/organizer_intake/generated/admin_review_queue.json",
      curationState:
        "tool/organizer_intake/generated/organizer_curation_state.json",
    },
    naming: {
      publicEntityLabel: "Host",
      canonicalDataModel: "OrganizerEntity",
      operatorAccountLabel: "HostAccount",
      legacyCompatibilityModel: "Club",
      note:
        "Public copy can say Host, while the private ingestion model remains OrganizerEntity until the naming migration is approved.",
    },
    summary: summaryForEntries(entries),
    guardrails: [
      "This registry is the canonical private entity view; raw/source payloads stay in the raw artifact manifest.",
      "A canonical host entity is not public until the projection plan says published.",
      "A public unclaimed page is still distinct from app discoverability and claimed host account access.",
      "The legacy clubs collection remains a compatibility projection until the naming migration is approved.",
      "Recurring crawls and event imports must reference canonicalHostId but remain disabled by their own policies.",
    ],
    entries,
  };
}

function canonicalHostEntity({
  claimTarget,
  conflicts,
  curation,
  dedupeKeys,
  entity,
  projection,
  reviewItem,
}) {
  const surfaces = (entity.surfaces ?? [])
    .map(canonicalSurface)
    .sort((a, b) =>
      surfaceSortKey(a).localeCompare(surfaceSortKey(b))
    );
  const surfaceInventory = surfaceInventoryFor(surfaces);
  const publicPresence = publicPresenceFor(entity, projection, reviewItem);
  const claim = claimStateFor(entity, claimTarget);
  const dedupe = dedupeSummaryFor(dedupeKeys, conflicts);

  return {
    canonicalHostId: entity.entityId,
    entityId: entity.entityId,
    displayName: entity.displayName,
    canonicalSlug: entity.canonicalSlug,
    aliases: [...(entity.aliases ?? [])].sort(),
    entityKind: entity.entityKind,
    entitySubtypes: [...(entity.entitySubtypes ?? [])].sort(),
    priority: entity.priority,
    activity: {
      primaryActivityKind: entity.activityDefaults?.primaryActivityKind ?? null,
      supportedActivityKinds: [
        ...(entity.activityDefaults?.supportedActivityKinds ?? []),
      ].sort(),
      confidence: entity.activityDefaults?.confidence ?? "low",
      derivedFromSurfaceIds: [
        ...(entity.activityDefaults?.derivedFromSurfaceIds ?? []),
      ].sort(),
    },
    geography: {
      scopeKind: entity.geographicScope?.kind ?? null,
      primaryMarketSlug: entity.geographicScope?.primaryMarketSlug ?? null,
      markets: (entity.geographicScope?.markets ?? [])
        .map((market) => ({
          marketSlug: market.marketSlug,
          displayName: market.displayName,
          countryCode: market.countryCode,
          eventFilter: market.eventFilter ?? null,
        }))
        .sort((a, b) => a.marketSlug.localeCompare(b.marketSlug)),
      countryCodes: [...(entity.geographicScope?.countryCodes ?? [])].sort(),
    },
    publicPresence,
    claim,
    legacyClubCompatibility: {
      collection: "clubs",
      documentId: claimTarget?.clubId ?? entity.entityId,
      status: claimTarget ?
        "ready_for_unclaimed_projection" :
        "not_projected_until_public_approval",
      writeMode: claimTarget?.writeMode ?? null,
      sourceHash: claimTarget?.sourceHash ?? null,
      note:
        "Compatibility only: canonicalHostId is the durable organizer identity for the intake pipeline.",
    },
    surfaceInventory,
    surfaces,
    evidenceRefs: uniqueEvidenceRefs(surfaces),
    dedupe,
    curation,
    reviewNotes: [...(entity.reviewNotes ?? [])].sort(),
    nextActions: nextActionsFor({
      claim,
      curation,
      publicPresence,
      reviewItem,
      surfaceInventory,
    }),
  };
}

function canonicalSurface(surface) {
  return {
    surfaceId: surface.surfaceId,
    platform: surface.platform,
    surfaceKind: surface.surfaceKind,
    url: surface.url ?? null,
    normalizedKey: surface.normalizedKey ?? null,
    role: surface.role,
    status: surface.status,
    confidence: {
      entityMatch: surface.confidence?.entityMatch ?? "low",
      ownership: surface.confidence?.ownership ?? "low",
      city: surface.confidence?.city ?? "low",
    },
    crawl: {
      eventDiscoveryStatus: surface.crawl?.eventDiscoveryStatus ?? "disabled",
      policy: surface.crawl?.policy ?? "manualOnly",
      supportsEventExtraction: surface.crawl?.supportsEventExtraction === true,
    },
    evidenceRefs: (surface.evidenceRefs ?? []).map((evidence) => ({
      type: evidence.type,
      ref: evidence.ref ?? null,
      description: evidence.description,
    })),
    notes: surface.notes ?? "",
  };
}

function publicPresenceFor(entity, projection, reviewItem) {
  return {
    reviewStatus: entity.reviewStatus,
    projectionStatus: projection?.projectionStatus ?? "blocked",
    publishStatus: projection?.publishStatus ?? "blocked",
    indexStatus: projection?.indexStatus ?? "noindex",
    appVisibility: projection?.appVisibility ?? "hidden",
    canonicalPath:
      projection?.canonicalPath ??
      entity.publicListingIntent?.canonicalPath ??
      null,
    legacyPaths:
      projection?.legacyPaths ??
      entity.publicListingIntent?.legacyPaths ??
      [],
    pageMode: projection?.pageMode ??
      entity.publicListingIntent?.pageMode ??
      "singleEntity",
    publicListingId: projection?.publicListing?.id ?? null,
    publicListingStatus: projection?.publicListing?.status ?? null,
    reviewDecision: projection?.reviewDecision ?? null,
    blockedBy:
      projection?.blockedBy ??
      reviewItem?.blockers ??
      ["manual_admin_review_required"],
  };
}

function claimStateFor(entity, claimTarget) {
  const relationshipToCatch = entity.relationshipToCatch ?? "unclaimed";
  return {
    relationshipToCatch,
    claimState: claimTarget?.claimState ??
      relationshipClaimState(relationshipToCatch),
    claimTargetPath: claimTarget?.path ?? null,
    appVisibility: claimTarget?.appVisibility ?? "hidden",
    ownerAccountRequired: relationshipToCatch !== "claimed",
    writeMode: claimTarget?.writeMode ?? null,
  };
}

function relationshipClaimState(relationshipToCatch) {
  if (relationshipToCatch === "claimed") return "claimed";
  if (relationshipToCatch === "claimPending") return "claimPending";
  if (relationshipToCatch === "internalOnly") return "notClaimable";
  return "unclaimed";
}

function surfaceInventoryFor(surfaces) {
  return {
    surfaces: surfaces.length,
    active: surfaces.filter((surface) => surface.status === "active").length,
    ambiguous: surfaces.filter((surface) =>
      surface.status === "ambiguous" || surface.role === "ambiguous"
    ).length,
    rejected: surfaces.filter((surface) =>
      surface.status === "rejected" || surface.role === "rejected"
    ).length,
    historical: surfaces.filter((surface) =>
      surface.status === "historical" || surface.role === "historical"
    ).length,
    primarySurfaceIds: surfaces
      .filter((surface) => surface.role === "primary")
      .map((surface) => surface.surfaceId)
      .sort(),
    eventSourceSurfaceIds: surfaces
      .filter((surface) => surface.crawl.supportsEventExtraction)
      .map((surface) => surface.surfaceId)
      .sort(),
    socialProfileSurfaceIds: surfaces
      .filter((surface) => surface.surfaceKind === "socialProfile")
      .map((surface) => surface.surfaceId)
      .sort(),
    platforms: countBy(surfaces, "platform"),
    normalizedKeys: surfaces
      .map((surface) => surface.normalizedKey)
      .filter(Boolean)
      .sort(),
  };
}

function dedupeSummaryFor(dedupeKeys, conflicts) {
  return {
    keys: dedupeKeys.length,
    strongKeys: dedupeKeys.filter((key) => key.strength === "strong").length,
    mediumKeys: dedupeKeys.filter((key) => key.strength === "medium").length,
    weakKeys: dedupeKeys.filter((key) => key.strength === "weak").length,
    conflicts: conflicts.length,
    keyTypes: countBy(dedupeKeys, "type"),
    conflictKeys: conflicts.map((conflict) => ({
      type: conflict.type,
      value: conflict.value,
      maxStrength: conflict.maxStrength,
      entityIds: [...(conflict.entityIds ?? [])].sort(),
    })),
  };
}

function curationSummaryByEntity(curationState) {
  const byEntity = new Map();
  const ensure = (entityId) => {
    if (!byEntity.has(entityId)) byEntity.set(entityId, emptyEntityCuration());
    return byEntity.get(entityId);
  };

  for (const operation of curationState.attachedSurfaces ?? []) {
    ensure(operation.entityId).attachedSurfaces.push({
      surfaceId: operation.surface?.surfaceId ?? operation.surfaceId ?? null,
      sourceCandidateId: operation.sourceCandidateId ?? null,
      reason: operation.reason,
    });
  }
  for (const operation of curationState.mergedEntities ?? []) {
    ensure(operation.targetEntityId).mergedFrom.push(operation.sourceEntityId);
    ensure(operation.sourceEntityId).mergedInto = operation.targetEntityId;
  }
  for (const operation of curationState.suppressedEntities ?? []) {
    ensure(operation.entityId).suppressed = operation.reason;
  }
  for (const operation of curationState.surfaceDecisions ?? []) {
    ensure(operation.entityId).surfaceDecisions.push({
      surfaceId: operation.surfaceId,
      decision: operation.decision,
      reason: operation.reason,
    });
  }
  for (const operation of curationState.splitSurfaces ?? []) {
    ensure(operation.entityId).splitSurfaces.push({
      surfaceId: operation.surfaceId,
      newEntityId: operation.newEntityId,
      reason: operation.reason,
    });
  }

  for (const curation of byEntity.values()) {
    curation.attachedSurfaces.sort(compareSurfaceReason);
    curation.mergedFrom.sort();
    curation.surfaceDecisions.sort(compareSurfaceReason);
    curation.splitSurfaces.sort(compareSurfaceReason);
  }
  return byEntity;
}

function emptyEntityCuration() {
  return {
    attachedSurfaces: [],
    mergedFrom: [],
    mergedInto: null,
    suppressed: null,
    surfaceDecisions: [],
    splitSurfaces: [],
  };
}

function uniqueEvidenceRefs(surfaces) {
  const rows = [];
  for (const surface of surfaces) {
    for (const evidence of surface.evidenceRefs ?? []) {
      rows.push({
        surfaceId: surface.surfaceId,
        type: evidence.type,
        ref: evidence.ref ?? null,
        description: evidence.description,
      });
    }
  }
  return [...new Map(rows.map((row) => [
    `${row.surfaceId}:${row.type}:${row.ref ?? ""}:${row.description}`,
    row,
  ])).values()].sort((a, b) =>
    `${a.surfaceId}:${a.type}:${a.ref ?? ""}`.localeCompare(
      `${b.surfaceId}:${b.type}:${b.ref ?? ""}`
    )
  );
}

function nextActionsFor({
  claim,
  curation,
  publicPresence,
  reviewItem,
  surfaceInventory,
}) {
  const actions = [];
  if (curation.suppressed) {
    actions.push("keep_suppressed");
    return actions;
  }
  if (surfaceInventory.ambiguous > 0 || surfaceInventory.rejected > 0) {
    actions.push("review_surface_inventory");
  }
  if (publicPresence.publishStatus !== "published") {
    actions.push(reviewItem?.blockers?.length ?
      "resolve_review_blockers" :
      "manual_admin_publication_review");
  }
  if (publicPresence.publishStatus === "published" &&
    claim.claimState === "unclaimed") {
    actions.push("eligible_for_claim_outreach");
  }
  if (publicPresence.appVisibility === "hidden") {
    actions.push("keep_app_hidden_until_claim_or_app_approval");
  }
  if (surfaceInventory.eventSourceSurfaceIds.length > 0) {
    actions.push("keep_recurring_crawl_disabled_until_policy_approval");
  }
  return [...new Set(actions)].sort();
}

function summaryForEntries(entries) {
  const allSurfaces = entries.flatMap((entry) => entry.surfaces);
  return {
    entities: entries.length,
    publicPublished: entries.filter((entry) =>
      entry.publicPresence.publishStatus === "published").length,
    indexed: entries.filter((entry) =>
      entry.publicPresence.indexStatus === "indexed").length,
    appDiscoverable: entries.filter((entry) =>
      entry.publicPresence.appVisibility === "discoverable").length,
    claimTargets: entries.filter((entry) =>
      Boolean(entry.claim.claimTargetPath)).length,
    unclaimed: entries.filter((entry) =>
      entry.claim.claimState === "unclaimed").length,
    claimed: entries.filter((entry) =>
      entry.claim.claimState === "claimed").length,
    internalOnly: entries.filter((entry) =>
      entry.claim.claimState === "notClaimable").length,
    cityScoped: entries.filter((entry) =>
      entry.geography.scopeKind === "city").length,
    multiCityScoped: entries.filter((entry) =>
      entry.geography.scopeKind === "multiCity").length,
    nationalScoped: entries.filter((entry) =>
      entry.geography.scopeKind === "national").length,
    globalScoped: entries.filter((entry) =>
      entry.geography.scopeKind === "global").length,
    remoteScoped: entries.filter((entry) =>
      entry.geography.scopeKind === "remote").length,
    surfaces: allSurfaces.length,
    activeSurfaces: allSurfaces.filter((surface) =>
      surface.status === "active").length,
    ambiguousSurfaces: allSurfaces.filter((surface) =>
      surface.status === "ambiguous" || surface.role === "ambiguous").length,
    rejectedSurfaces: allSurfaces.filter((surface) =>
      surface.status === "rejected" || surface.role === "rejected").length,
    crawlCapableSurfaces: allSurfaces.filter((surface) =>
      surface.crawl.supportsEventExtraction).length,
    eventSourceSurfaces: allSurfaces.filter((surface) =>
      surface.surfaceKind === "eventListing" ||
      surface.surfaceKind === "eventCalendar").length,
    socialProfileSurfaces: allSurfaces.filter((surface) =>
      surface.surfaceKind === "socialProfile").length,
    legacyClubProjected: entries.filter((entry) =>
      entry.legacyClubCompatibility.status ===
        "ready_for_unclaimed_projection").length,
    pendingManualReview: entries.filter((entry) =>
      entry.publicPresence.publishStatus === "blocked").length,
    byEntityKind: countBy(entries, "entityKind"),
    byScopeKind: countBy(entries.map((entry) => ({
      scopeKind: entry.geography.scopeKind ?? "unknown",
    })), "scopeKind"),
  };
}

function conflictsByEntityId(conflicts) {
  const byEntity = new Map();
  for (const conflict of conflicts) {
    for (const entityId of conflict.entityIds ?? []) {
      if (!byEntity.has(entityId)) byEntity.set(entityId, []);
      byEntity.get(entityId).push(conflict);
    }
  }
  return byEntity;
}

function groupBy(items, field) {
  const groups = new Map();
  for (const item of items) {
    const key = item[field];
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(item);
  }
  for (const [key, values] of groups.entries()) {
    groups.set(key, [...values].sort((a, b) =>
      JSON.stringify(a).localeCompare(JSON.stringify(b))
    ));
  }
  return groups;
}

function countBy(items, field) {
  const counts = {};
  for (const item of items) {
    const key = item[field] ?? "unknown";
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return Object.fromEntries(
    Object.entries(counts).sort(([a], [b]) => a.localeCompare(b))
  );
}

function surfaceSortKey(surface) {
  return [
    surface.status === "active" ? "0" : "1",
    surface.role,
    surface.platform,
    surface.surfaceId,
  ].join(":");
}

function compareSurfaceReason(a, b) {
  return `${a.surfaceId ?? ""}:${a.reason ?? ""}`.localeCompare(
    `${b.surfaceId ?? ""}:${b.reason ?? ""}`
  );
}

function emptyProjectionPlan() {
  return {entries: []};
}

function emptyClaimTargetPlan() {
  return {targets: []};
}

function emptyDedupeIndex() {
  return {dedupeKeys: [], conflicts: []};
}

function emptyReviewQueue() {
  return {items: []};
}

function emptyCurationState() {
  return {
    attachedSurfaces: [],
    mergedEntities: [],
    suppressedEntities: [],
    surfaceDecisions: [],
    splitSurfaces: [],
  };
}
