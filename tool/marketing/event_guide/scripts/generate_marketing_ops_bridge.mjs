import {access, mkdir, readFile, writeFile} from "node:fs/promises";
import path from "node:path";
import {fileURLToPath} from "node:url";

const dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(dirname, "..");
const marketingRoot = path.resolve(root, "..");
const repoRoot = path.resolve(root, "../../..");

const args = parseArgs(process.argv.slice(2));
const configPath = path.resolve(root, args.config ?? "config/mumbai.weekly-guide.config.json");
const sourceResultsPath = path.resolve(root, args["source-results"] ?? "data/mumbai.sample.source_results.json");
const candidatesPath = path.resolve(root, args.candidates ?? "data/mumbai.sample.event_candidates.json");
const decisionsPath = args.decisions ?
  path.resolve(process.cwd(), args.decisions) :
  null;
const week = args.week ?? new Date().toISOString().slice(0, 10);

const config = JSON.parse(await readFile(configPath, "utf8"));
const sourceResultsFile = JSON.parse(await readFile(sourceResultsPath, "utf8"));
const candidatesFile = JSON.parse(await readFile(candidatesPath, "utf8"));
const decisionsFile = decisionsPath ?
  JSON.parse(await readFile(decisionsPath, "utf8")) :
  {reviewer: null, reviewedAt: null, decisions: []};

const weekStart = parseDate(week);
const weekEnd = addDays(weekStart, config.cadence.lookaheadDays ?? 7);
const outputDir = path.join(root, "generated", config.city.id, week);
await mkdir(outputDir, {recursive: true});

const decisionsByTarget = new Map(
  (decisionsFile.decisions ?? []).map((decision) => [
    `${decision.targetType}:${decision.targetId}`,
    decision,
  ])
);

const sourceResults = sourceResultsFile.results
  .slice(0, config.limits.sourceResults ?? 40)
  .map((result) => applyDecision(result, "source_result"));

const rawCandidates = candidatesFile.events
  .filter((event) => overlapsWeek(event, weekStart, weekEnd))
  .map((event) => applyDecision(event, "event_candidate"))
  .map((event) => ({
    ...event,
    normalizedEventKey: normalizedEventKey(event, config),
    sourceCoverage: sourceCoverageFor(event, sourceResults),
    score: scoreEvent(event, config),
  }))
  .map((event) => ({
    ...event,
    sourceStatus: sourceStatusFor(event),
    publishability: publishabilityFor(event),
  }))
  .map((event) => ({
    ...event,
    warnings: warningsFor(event),
  }));

const dedupeGroups = buildDedupeGroups(rawCandidates);
const candidates = canonicalizeCandidates(rawCandidates, dedupeGroups)
  .sort((left, right) => right.score - left.score)
  .slice(0, config.limits.candidatePool ?? 25);

const recommendable = balanceCategories(
  candidates.filter((event) =>
    event.reviewState !== "rejected" &&
    event.publishability !== "lead_needs_source"
  ),
  config
).slice(0, config.limits.recommendationSlots ?? 7);

const recommendationSets = buildRecommendationSets({
  config,
  events: recommendable,
  week,
  weekEnd,
});
const contentDrafts = buildContentDrafts({config, recommendationSets, week});
const appFeatureMedia = await buildAppFeatureMedia();
const bridge = buildBridge({
  config,
  sourceResults,
  candidates,
  recommendationSets,
  contentDrafts,
  dedupeGroups,
  week,
  weekEnd,
  decisionsFile,
  appFeatureMedia,
});
const eventIntakeBridge = buildEventIntakeBridge(bridge, week);

await writeJson(path.join(outputDir, "marketing_ops_bridge.json"), bridge);
await writeJson(path.join(outputDir, "event_intake_bridge.json"), eventIntakeBridge);
await writeFile(
  path.join(outputDir, "review_queue.md"),
  renderReviewQueue(bridge),
);
await writeFile(
  path.join(outputDir, "content_drafts.md"),
  renderContentDrafts(bridge),
);

if (args["admin-output"]) {
  const adminOutput = path.resolve(process.cwd(), args["admin-output"]);
  await mkdir(path.dirname(adminOutput), {recursive: true});
  await writeJson(adminOutput, bridge);
}
if (args["event-intake-admin-output"]) {
  const adminOutput = path.resolve(
    process.cwd(),
    args["event-intake-admin-output"]
  );
  await mkdir(path.dirname(adminOutput), {recursive: true});
  await writeJson(adminOutput, eventIntakeBridge);
}

console.log(`Marketing ops bridge generated: ${outputDir}`);
console.log(`Source results: ${sourceResults.length}`);
console.log(`Event candidates: ${candidates.length}`);
console.log(`Recommendation sets: ${recommendationSets.length}`);
console.log(`Content drafts: ${contentDrafts.length}`);
if (args["admin-output"]) {
  console.log(`Admin bridge updated: ${args["admin-output"]}`);
}
if (args["event-intake-admin-output"]) {
  console.log(
    `Event Intake admin bridge updated: ${args["event-intake-admin-output"]}`
  );
}

function parseArgs(rawArgs) {
  const parsed = {};
  for (let index = 0; index < rawArgs.length; index += 1) {
    const arg = rawArgs[index];
    if (!arg.startsWith("--")) continue;
    parsed[arg.slice(2)] = rawArgs[index + 1];
    index += 1;
  }
  return parsed;
}

function parseDate(value) {
  const date = new Date(`${value}T00:00:00.000Z`);
  if (Number.isNaN(date.getTime())) {
    throw new Error(`Invalid date: ${value}`);
  }
  return date;
}

function addDays(date, days) {
  const next = new Date(date);
  next.setUTCDate(next.getUTCDate() + days);
  return next;
}

function formatDate(date) {
  return date.toISOString().slice(0, 10);
}

function overlapsWeek(event, weekStart, weekEnd) {
  const start = parseDate(event.startDate);
  const end = event.endDate ? parseDate(event.endDate) : start;
  return start <= weekEnd && end >= weekStart;
}

function applyDecision(item, targetType) {
  const decision = decisionsByTarget.get(`${targetType}:${item.id}`);
  if (!decision) return item;
  return {
    ...item,
    ...(decision.edits ?? {}),
    reviewState: decision.decision ?? item.reviewState,
    status: decision.decision ?? item.status,
    latestDecision: {
      decision: decision.decision,
      note: decision.note ?? null,
      reviewer: decisionsFile.reviewer ?? null,
      reviewedAt: decisionsFile.reviewedAt ?? null,
    },
  };
}

function sourceCoverageFor(event, sourceResults) {
  const sourceIds = new Set(event.sourceResultIds ?? []);
  const matched = sourceResults.filter((result) => sourceIds.has(result.id));
  return {
    sourceResultIds: [...sourceIds],
    matchedSourceResults: matched.length,
    hasSourceUrl: Boolean(event.sourceUrl),
    hasManualInstagramReference: matched.some((result) =>
      result.riskFlags?.includes("instagram_manual_reference_only")
    ),
  };
}

function normalizedEventKey(event, config) {
  return [
    config.city.id,
    event.title,
    event.venue,
    event.neighborhood,
    event.startDate,
  ]
    .filter(Boolean)
    .join("|")
    .toLowerCase()
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9|]+/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function sourceStatusFor(event) {
  if (!event.sourceCoverage.hasSourceUrl) return "missing_source_url";
  if (event.sourceCoverage.hasManualInstagramReference) {
    return "manual_reference_needs_official_verification";
  }
  return "source_backed";
}

function publishabilityFor(event) {
  if (!event.sourceCoverage.hasSourceUrl) return "lead_needs_source";
  if (event.requiresVerification) return "reviewable_needs_verification";
  return "publishable_after_approval";
}

function buildDedupeGroups(events) {
  const groups = new Map();
  for (const event of events) {
    const group = groups.get(event.normalizedEventKey) ?? [];
    group.push(event.id);
    groups.set(event.normalizedEventKey, group);
  }
  return [...groups.entries()]
    .map(([normalizedEventKey, candidateIds]) => ({
      normalizedEventKey,
      candidateIds,
      canonicalCandidateId: candidateIds[0],
      duplicateCandidateIds: candidateIds.slice(1),
    }))
    .filter((group) => group.candidateIds.length > 1);
}

function canonicalizeCandidates(events, dedupeGroups) {
  const groupByCandidateId = new Map();
  for (const group of dedupeGroups) {
    for (const candidateId of group.candidateIds) {
      groupByCandidateId.set(candidateId, group);
    }
  }
  const byKey = new Map();
  for (const event of events) {
    const existing = byKey.get(event.normalizedEventKey);
    if (!existing) {
      byKey.set(event.normalizedEventKey, event);
      continue;
    }
    byKey.set(
      event.normalizedEventKey,
      canonicalCandidateWinner(existing, event)
    );
  }
  return [...byKey.values()].map((event) => {
    const group = groupByCandidateId.get(event.id) ??
      dedupeGroups.find((item) => item.normalizedEventKey === event.normalizedEventKey);
    return {
      ...event,
      dedupe: group ? {
        normalizedEventKey: group.normalizedEventKey,
        canonicalCandidateId: event.id,
        duplicateCandidateIds: group.candidateIds.filter((id) => id !== event.id),
      } : {
        normalizedEventKey: event.normalizedEventKey,
        canonicalCandidateId: event.id,
        duplicateCandidateIds: [],
      },
    };
  });
}

function canonicalCandidateWinner(left, right) {
  if (Boolean(right.sourceUrl) !== Boolean(left.sourceUrl)) {
    return right.sourceUrl ? right : left;
  }
  if (right.score !== left.score) return right.score > left.score ? right : left;
  return left.id.localeCompare(right.id) <= 0 ? left : right;
}

function scoreEvent(event, config) {
  const weights = config.rankingWeights ?? {};
  const scores = event.scores ?? {};
  let total = 0;
  for (const [key, weight] of Object.entries(weights)) {
    total += (Number(scores[key]) || 0) * Number(weight);
  }
  if (event.requiresVerification) total += config.penalties.requiresVerification ?? 0;
  if (!event.price || event.price === "TBD") total += config.penalties.missingPrice ?? 0;
  if (!event.sourceUrl) total += config.penalties.missingSourceUrl ?? 0;
  if (event.city && event.city !== config.city.id) total += config.penalties.nonCity ?? -5;
  return Number(total.toFixed(2));
}

function warningsFor(event) {
  const warnings = [];
  if (event.publishability === "lead_needs_source") {
    warnings.push("lead only: add a source URL before shortlisting");
  }
  if (event.requiresVerification) warnings.push("requires verification");
  if (!event.sourceUrl) warnings.push("missing source URL");
  if (!event.price || event.price === "TBD") warnings.push("missing price");
  if (!event.explicitSinglesEvent) warnings.push("not explicitly singles-only");
  if (event.sourceCoverage?.hasManualInstagramReference) {
    warnings.push("manual Instagram reference");
  }
  return warnings;
}

function balanceCategories(events, config) {
  const targets = config.contentStrategy.categoryMixTargets ?? {};
  const selected = [];
  const selectedIds = new Set();
  for (const [category, count] of Object.entries(targets)) {
    const matching = events.filter((event) => event.category === category);
    for (const event of matching.slice(0, Number(count))) {
      if (selectedIds.has(event.id)) continue;
      selected.push(event);
      selectedIds.add(event.id);
    }
  }
  for (const event of events) {
    if (selectedIds.has(event.id)) continue;
    selected.push(event);
    selectedIds.add(event.id);
  }
  return selected;
}

function buildRecommendationSets({config, events, week, weekEnd}) {
  return config.contentStrategy.toneVariants.map((tone) => ({
    id: `${config.city.id}-${week}-${tone}`,
    cityId: config.city.id,
    weekStart: week,
    weekEnd: formatDate(weekEnd),
    tone,
    title: tone === "singles-social" ?
      `${config.city.label} singles socials to review` :
      `${config.city.label} singles-friendly plans this week`,
    status: tone === "singles-social" &&
      events.filter((event) => event.explicitSinglesEvent).length === 0 ?
      "blocked_no_explicit_singles_events" :
      "draft",
    reviewState: "new",
    explanation: tone === "singles-social" ?
      "This variant should only use events explicitly framed as singles, dating, or mixer events." :
      "This is the recommended default: third-party events that are credible, source-backed, and easy to attend solo.",
    items: events
      .filter((event) => tone !== "singles-social" || event.explicitSinglesEvent)
      .map((event, index) => ({
      id: `${tone}-${index + 1}-${event.id}`,
      eventCandidateId: event.id,
      rank: index + 1,
      title: event.title,
      category: event.category,
      neighborhood: event.neighborhood,
      score: event.score,
      inclusionReason: tone === "singles-social" && !event.explicitSinglesEvent ?
        "Singles-friendly, not singles-only. Needs careful public copy." :
        event.whySinglesFriendly,
      warnings: event.warnings,
      reviewState: event.reviewState,
      sourceStatus: event.sourceStatus,
      publishability: event.publishability,
    })),
  }));
}

function buildContentDrafts({config, recommendationSets, week}) {
  return recommendationSets.map((set) => ({
    id: `${set.id}-instagram-carousel`,
    recommendationSetId: set.id,
    cityId: config.city.id,
    weekStart: week,
    format: "instagram_carousel",
    tone: set.tone,
    status: "draft",
    reviewState: "new",
    aspectRatio: "4:5",
    delivery: {
      posting: "manual_instagram_upload",
      currentExport: "json_packet_and_png_slide_export",
      finalImageExport: "browser_png_export_available",
      autoPosting: false,
    },
    brandContract: {
      logo: "reference existing Catch _ logo asset/component",
      headlineFont: "Archivo",
      labelFont: "IBM Plex Mono",
      bodyFont: "San Francisco",
      primitives: ["CatchBadge", "CatchChip", "CatchButton"],
      rendererStatus: "functional_browser_export_uses_catch_web_tokens",
    },
    slides: [
      {
        id: "cover",
        role: "cover",
        headline: set.tone === "singles-social" ?
          `${config.city.label} singles socials` :
          `${config.city.label} plans that work solo`,
        body: "Editor-reviewed picks for the week.",
        image: null,
      },
      ...set.items.map((item) => ({
        id: `event-${item.rank}`,
        role: "event",
        eventCandidateId: item.eventCandidateId,
        headline: item.title,
        body: item.inclusionReason,
        image: null,
      })),
      {
        id: "cta",
        role: "cta",
        headline: "Want more plans like this?",
        body: "Join the Catch waitlist or submit a host event for review.",
        image: null,
      },
    ],
    caption: renderCaption(config, set),
    ctas: config.contentStrategy.ctaPriority.map((ctaId) => ({
      id: ctaId,
      ...config.ctas[ctaId],
    })),
  }));
}

function renderCaption(config, set) {
  const intro = set.tone === "singles-social" ?
    `${config.city.label} singles-social leads for this week. Some picks still need source review before public use.` :
    `${config.city.label} plans that are easy to attend solo and good for meeting people.`;
  const items = set.items
    .map((item) => `${item.rank}. ${item.title} - ${item.neighborhood}`)
    .join("\n");
  return [
    intro,
    "",
    items,
    "",
    "Join the Catch waitlist for more city plans. Hosting something social? Submit it for review.",
  ].join("\n");
}

function buildBridge({
  config,
  sourceResults,
  candidates,
  recommendationSets,
  contentDrafts,
  dedupeGroups,
  week,
  weekEnd,
  decisionsFile,
  appFeatureMedia,
}) {
  const approvedCandidates = candidates.filter((event) => event.reviewState === "approved");
  const reviewableCandidates = candidates.filter((event) =>
    event.publishability !== "lead_needs_source"
  );
  const sourceMissingCandidates = candidates.filter((event) =>
    event.publishability === "lead_needs_source"
  );
  const needsReviewCandidates = candidates.filter((event) =>
    ["new", "needs_changes", "held"].includes(event.reviewState)
  );
  const generatedAt = new Date().toISOString();
  return {
    schemaVersion: 1,
    program: config.program,
    generatedAt,
    city: config.city,
    weekStart: week,
    weekEnd: formatDate(weekEnd),
    timezone: config.city.timezone,
    summary: {
      status: "internal_review",
      sourceProfiles: config.sourceProfiles.length,
      queryTemplates: config.queryTemplates.length,
      sourceResults: sourceResults.length,
      sourceResultsNeedingReview: sourceResults.filter((result) =>
        ["new", "needs_review", "needs_changes"].includes(result.status)
      ).length,
      eventCandidates: candidates.length,
      reviewableCandidates: reviewableCandidates.length,
      sourceMissingCandidates: sourceMissingCandidates.length,
      approvedCandidates: approvedCandidates.length,
      candidatesNeedingReview: needsReviewCandidates.length,
      duplicateGroups: dedupeGroups.length,
      recommendationSets: recommendationSets.length,
      contentDrafts: contentDrafts.length,
      exportReadyDrafts: contentDrafts.filter((draft) => draft.reviewState === "approved").length,
      deliverable: "Manual Instagram carousel packet with downloadable PNG slides; no auto-posting.",
    },
    guardrails: [
      ...config.contentStrategy.copyGuardrails,
      "Instagram is manual-reference only until an official API flow is approved.",
      "Do not promote source results into app event inventory from this module.",
      "PNG export is browser-side for manual upload; do not auto-post without a separate approval flow.",
    ],
    sourceProfiles: config.sourceProfiles,
    queryTemplates: expandQueryTemplates(config),
    runPlan: buildRunPlan(config, week, generatedAt),
    sourceResults,
    eventCandidates: candidates,
    dedupeGroups,
    recommendationSets,
    contentDrafts,
    appFeatureMedia,
    auditTrail: (decisionsFile.decisions ?? []).map((decision) => ({
      ...decision,
      reviewer: decisionsFile.reviewer,
      reviewedAt: decisionsFile.reviewedAt,
    })),
    commands: {
      regenerate:
        `node tool/marketing/event_guide/scripts/generate_marketing_ops_bridge.mjs --week ${week}`,
      updateAdminBridge:
        `node tool/marketing/event_guide/scripts/generate_marketing_ops_bridge.mjs --week ${week} --admin-output admin/src/generated/marketingOpsBridge.json`,
      withDecisions:
        `node tool/marketing/event_guide/scripts/generate_marketing_ops_bridge.mjs --week ${week} --decisions tool/marketing/event_guide/review_decisions/mumbai.${week}.example.json --admin-output admin/src/generated/marketingOpsBridge.json`,
    },
  };
}

function buildEventIntakeBridge(marketingBridge, week) {
  return {
    schemaVersion: marketingBridge.schemaVersion,
    program: "catch-event-intake",
    generatedAt: marketingBridge.generatedAt,
    bridgeSource: "native_generated",
    city: marketingBridge.city,
    weekStart: marketingBridge.weekStart,
    weekEnd: marketingBridge.weekEnd,
    timezone: marketingBridge.timezone,
    summary: {
      status: marketingBridge.summary.status,
      sourceProfiles: marketingBridge.summary.sourceProfiles,
      queryTemplates: marketingBridge.summary.queryTemplates,
      sourceResults: marketingBridge.summary.sourceResults,
      sourceResultsNeedingReview:
        marketingBridge.summary.sourceResultsNeedingReview,
      eventCandidates: marketingBridge.summary.eventCandidates,
      reviewableCandidates: marketingBridge.summary.reviewableCandidates,
      sourceMissingCandidates: marketingBridge.summary.sourceMissingCandidates,
      approvedCandidates: marketingBridge.summary.approvedCandidates,
      candidatesNeedingReview: marketingBridge.summary.candidatesNeedingReview,
      duplicateGroups: marketingBridge.summary.duplicateGroups,
      deliverable:
        "Private Event Intake review bridge; no marketing export or event import.",
    },
    guardrails: [
      "Event Intake approvals are private supply review decisions.",
      "Do not create canonical events from this bridge.",
      "Do not publish marketing content from this bridge.",
      "Keep source attribution visible before downstream use.",
    ],
    sourceProfiles: marketingBridge.sourceProfiles,
    queryTemplates: marketingBridge.queryTemplates,
    runPlan: marketingBridge.runPlan,
    sourceResults: marketingBridge.sourceResults,
    eventCandidates: marketingBridge.eventCandidates,
    dedupeGroups: marketingBridge.dedupeGroups,
    auditTrail: marketingBridge.auditTrail,
    commands: {
      regenerate:
        `node tool/marketing/event_guide/scripts/generate_marketing_ops_bridge.mjs --week ${week}`,
      updateAdminBridge:
        `node tool/marketing/event_guide/scripts/generate_marketing_ops_bridge.mjs --week ${week} --event-intake-admin-output admin/src/generated/eventIntakeBridge.json`,
      withDecisions:
        `node tool/marketing/event_guide/scripts/generate_marketing_ops_bridge.mjs --week ${week} --decisions tool/marketing/event_guide/review_decisions/mumbai.${week}.example.json --event-intake-admin-output admin/src/generated/eventIntakeBridge.json`,
    },
  };
}

async function buildAppFeatureMedia() {
  const captureManifestPath = path.join(marketingRoot, "capture_manifest.json");
  const designContextPath = path.join(marketingRoot, "app_screenshots_design_context.json");
  const websiteManifestPath = path.join(
    repoRoot,
    "website/public/assets/app-screenshots/manifest.json"
  );
  const captureManifest = await readJsonOrNull(captureManifestPath);
  const designContext = await readJsonOrNull(designContextPath);
  const websiteManifest = await readJsonOrNull(websiteManifestPath);
  const sourceDocs = {
    pipelineDoc: "docs/marketing_app_media_pipeline.md",
    captureManifest: relativeRepoPath(captureManifestPath),
    designContext: relativeRepoPath(designContextPath),
    websiteManifest: relativeRepoPath(websiteManifestPath),
  };
  const commands = {
    listCaptures: "node tool/marketing/export_app_screenshots.mjs --list",
    updateScreenshots: "node tool/marketing/export_app_screenshots.mjs --update",
    checkScreenshots: "node tool/marketing/export_app_screenshots.mjs --check",
    updateDesignContext: "node tool/marketing/export_app_screenshots.mjs --update-design-json",
    checkDesignContext: "node tool/marketing/export_app_screenshots.mjs --check-design-json",
    syncWebsiteMedia: "node tool/marketing/sync_website_media.mjs --update",
    checkWebsiteMedia: "node tool/marketing/sync_website_media.mjs --check",
  };

  if (!captureManifest) {
    return {
      schemaVersion: 1,
      status: "missing_manifest",
      generatedAt: new Date().toISOString(),
      sourceDocs,
      summary: {
        totalCaptures: 0,
        activeCaptures: 0,
        memberCaptures: 0,
        hostCaptures: 0,
        pendingCaptures: 0,
        pausedCaptures: 0,
      },
      commands,
      captures: [],
    };
  }

  const designById = new Map(
    (designContext?.captures ?? []).map((capture) => [capture.id, capture])
  );
  const websiteById = new Map(
    (websiteManifest?.captures ?? []).map((capture) => [capture.id, capture])
  );
  const captures = await Promise.all(
    (captureManifest.captures ?? []).map(async (capture) => {
      const designCapture = designById.get(capture.id);
      const websiteCapture = websiteById.get(capture.id);
      const sourcePath = capture.sourcePath ?? designCapture?.assets?.sourcePath ?? "";
      const websitePath = capture.websitePath ?? designCapture?.assets?.websitePath ?? "";
      const placeholderPath = capture.placeholderPath ??
        designCapture?.assets?.placeholderPath ??
        "";
      const [sourceExists, websiteExists, placeholderExists] = await Promise.all([
        fileExists(sourcePath ? path.join(repoRoot, sourcePath) : ""),
        fileExists(websitePath ? path.join(repoRoot, websitePath) : ""),
        fileExists(placeholderPath ? path.join(repoRoot, placeholderPath) : ""),
      ]);

      return {
        id: capture.id,
        audience: capture.audience,
        surface: capture.surface,
        status: capture.status,
        assetState: assetStateFor({
          sourceExists,
          websiteExists,
          placeholderExists,
          status: capture.status,
          webPath: websiteCapture?.webPath,
        }),
        device: capture.device ?? designCapture?.device?.id ?? "",
        fixtureKey: capture.fixtureKey,
        captureId: designCapture?.captureId ?? null,
        routeIds: designCapture?.routeIds ?? [],
        sourcePath,
        websitePath,
        placeholderPath,
        webPath: websiteCapture?.webPath ?? null,
        alt: capture.alt ?? websiteCapture?.alt ?? designCapture?.copy?.alt ?? "",
        caption: capture.caption ??
          websiteCapture?.caption ??
          designCapture?.copy?.caption ??
          "",
        walkthroughStep: capture.walkthroughStep ??
          websiteCapture?.walkthroughStep ??
          designCapture?.copy?.walkthroughStep ??
          "",
      };
    })
  );
  const summary = {
    totalCaptures: captures.length,
    activeCaptures: captures.filter((capture) => capture.status === "active").length,
    memberCaptures: captures.filter((capture) => capture.audience === "member").length,
    hostCaptures: captures.filter((capture) => capture.audience === "host").length,
    pendingCaptures: captures.filter((capture) => capture.status === "pending-fixture").length,
    pausedCaptures: captures.filter((capture) => capture.status === "paused").length,
  };
  const status = captures.some((capture) =>
    capture.status === "active" && capture.assetState !== "website_synced"
  ) ? "partial" : "ready";

  return {
    schemaVersion: 1,
    status,
    generatedAt: new Date().toISOString(),
    sourceDocs,
    summary,
    commands,
    captures,
  };
}

async function readJsonOrNull(filePath) {
  try {
    return JSON.parse(await readFile(filePath, "utf8"));
  } catch (error) {
    if (error?.code === "ENOENT") return null;
    throw error;
  }
}

async function fileExists(filePath) {
  if (!filePath.trim()) return false;
  try {
    await access(filePath);
    return true;
  } catch {
    return false;
  }
}

function assetStateFor({
  sourceExists,
  websiteExists,
  placeholderExists,
  status,
  webPath,
}) {
  if (websiteExists && webPath) return "website_synced";
  if (sourceExists) return "source_only";
  if (placeholderExists || status === "pending-fixture") return "placeholder";
  return "missing";
}

function relativeRepoPath(filePath) {
  return path.relative(repoRoot, filePath).split(path.sep).join("/");
}

function expandQueryTemplates(config) {
  const cities = [config.city.label, ...(config.city.aliases ?? [])];
  return config.queryTemplates.flatMap((template) =>
    cities.map((cityLabel) => ({
      ...template,
      cityLabel,
      query: template.template.replaceAll("{city}", cityLabel),
      status: "enabled",
    }))
  );
}

function buildRunPlan(config, week, generatedAt) {
  const expandedQueries = expandQueryTemplates(config);
  return {
    id: `${config.city.id}-${week}-weekly-event-guide`,
    cityId: config.city.id,
    weekStart: week,
    status: "planned",
    generatedAt,
    schedule: {
      cadence: "weekly",
      publishDay: config.cadence.publishDay,
      lookaheadDays: config.cadence.lookaheadDays,
    },
    budgets: {
      maxQueries: expandedQueries.length,
      maxSourceResults: config.limits.sourceResults,
      maxCandidatePool: config.limits.candidatePool,
    },
    automationPolicy: {
      searchProvider: "not_configured",
      networkFetchesEnabled: false,
      instagramScrapingEnabled: false,
      requiresHumanApprovalBeforePublish: true,
    },
    queryIds: expandedQueries.map((query) => query.id),
    sourceProfileIds: config.sourceProfiles.map((source) => source.id),
  };
}

function renderReviewQueue(bridge) {
  const rows = bridge.eventCandidates.map((event, index) => [
    index + 1,
    event.title,
    event.category,
    event.neighborhood,
    event.startDate === event.endDate || !event.endDate ?
      event.startDate :
      `${event.startDate} to ${event.endDate}`,
    event.reviewState,
    event.score,
    event.warnings.join("; "),
  ]);
  const table = [
    "| Slot | Event | Category | Area | Date | Review | Score | Warnings |",
    "| ---: | --- | --- | --- | --- | --- | ---: | --- |",
    ...rows.map((row) => `| ${row.join(" | ")} |`),
  ].join("\n");
  return `# Marketing Review Queue: ${bridge.city.label} ${bridge.weekStart}\n\n${table}\n`;
}

function renderContentDrafts(bridge) {
  return bridge.contentDrafts.map((draft) => [
    `# ${draft.id}`,
    "",
    `Tone: ${draft.tone}`,
    `Format: ${draft.format}`,
    `Aspect ratio: ${draft.aspectRatio}`,
    "",
    "## Slides",
    "",
    ...draft.slides.map((slide) =>
      `- ${slide.role}: ${slide.headline}${slide.body ? ` - ${slide.body}` : ""}`
    ),
    "",
    "## Caption",
    "",
    draft.caption,
  ].join("\n")).join("\n\n");
}

async function writeJson(filePath, value) {
  await writeFile(filePath, `${JSON.stringify(value, null, 2)}\n`);
}
