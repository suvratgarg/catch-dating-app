#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";
import {inMarket} from "../../website/src/content/markets/in.ts";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, "..", "..");

const defaults = {
  canonicalHostEntities: path.join(scriptDir, "generated", "canonical_host_entities.json"),
  claimTargetSyncPreview: path.join(
    scriptDir,
    "generated",
    "organizer_claim_target_sync_preview.json"
  ),
  claimTargets: path.join(scriptDir, "generated", "organizer_claim_targets.json"),
  hostListings: path.join(repoRoot, "website", "src", "generated", "hostListings.json"),
  projectionPlan: path.join(scriptDir, "generated", "public_projection_plan.json"),
};
const liveMarketKeys = new Set(
  inMarket.cities
    .filter((city) => city.status === "live")
    .flatMap((city) => [city.slug, city.label, ...city.aliases])
    .map(normalizeMarketKey)
);

if (isMain()) {
  main();
}

export function checkPromotionBridge({
  canonicalHostEntities = {entries: []},
  claimTargetSyncPreview = {actions: [], summary: {}},
  claimTargetPlan,
  hostListings,
  projectionPlan,
}) {
  const errors = [];
  const warnings = [];
  const approvedEntries = (projectionPlan.entries ?? [])
    .filter((entry) =>
      entry.projectionStatus === "ready" &&
        entry.publishStatus === "published" &&
        entry.publicListing
    )
    .sort((a, b) => a.entityId.localeCompare(b.entityId));
  const websiteEligibleEntries = approvedEntries.filter(
    organizerIntakeProjectionHasLiveMarket
  );
  const listingsByPath = new Map();
  const listingsById = new Map();
  for (const listing of hostListings) {
    if (listing.path) {
      if (listingsByPath.has(listing.path)) {
        errors.push(`Duplicate website listing path: ${listing.path}`);
      }
      listingsByPath.set(listing.path, listing);
    }
    if (listing.id) {
      if (!listingsById.has(listing.id)) listingsById.set(listing.id, []);
      listingsById.get(listing.id).push(listing);
    }
  }

  const targetsByEntity = new Map(
    (claimTargetPlan.targets ?? []).map((target) => [target.entityId, target])
  );
  const syncPreviewByPath = new Map(
    (claimTargetSyncPreview.actions ?? []).map((action) => [action.path, action])
  );
  const canonicalByEntity = new Map(
    (canonicalHostEntities.entries ?? []).map((entry) => [entry.entityId, entry])
  );
  const approvedByEntity = new Map(
    approvedEntries.map((entry) => [entry.entityId, entry])
  );
  const websiteEligibleByEntity = new Map(
    websiteEligibleEntries.map((entry) => [entry.entityId, entry])
  );

  for (const entry of approvedEntries) {
    const canonical = canonicalByEntity.get(entry.entityId);
    if (!canonical) {
      errors.push(`${entry.entityId}: missing canonical host entity`);
    } else {
      checkCanonicalHostEntity({canonical, entry, errors});
    }

    if (websiteEligibleByEntity.has(entry.entityId)) {
      const listing = listingsByPath.get(entry.publicListing.path);
      if (!listing) {
        errors.push(`${entry.entityId}: missing website listing ${entry.publicListing.path}`);
      } else {
        checkWebsiteListing({entry, listing, errors, warnings});
      }

      for (const legacyPath of entry.legacyPaths ?? []) {
        if (listingsByPath.has(legacyPath)) {
          errors.push(
            `${entry.entityId}: legacy path still has a generated listing ${legacyPath}`
          );
        }
      }
    } else if (listingsByPath.has(entry.publicListing.path)) {
      errors.push(
        `${entry.entityId}: waitlist-market organizer leaked into website listings`
      );
    } else {
      for (const legacyPath of entry.legacyPaths ?? []) {
        if (listingsByPath.has(legacyPath)) {
          errors.push(
            `${entry.entityId}: waitlist-market legacy listing leaked at ${legacyPath}`
          );
        }
      }
    }

    const target = targetsByEntity.get(entry.entityId);
    if (!target) {
      errors.push(`${entry.entityId}: missing claim target`);
    } else {
      checkClaimTarget({entry, target, errors});
      checkClaimTargetSyncPreview({
        errors,
        previewAction: syncPreviewByPath.get(target.path),
        target,
      });
    }
  }

  for (const target of claimTargetPlan.targets ?? []) {
    if (!approvedByEntity.has(target.entityId)) {
      errors.push(`${target.entityId}: claim target exists without approved projection`);
    }
    const canonical = canonicalByEntity.get(target.entityId);
    if (!canonical) {
      errors.push(`${target.entityId}: claim target exists without canonical host entity`);
    } else if (canonical.claim?.claimTargetPath !== target.path) {
      errors.push(
        `${target.entityId}: canonical claim target path ${canonical.claim?.claimTargetPath} ` +
          `does not match ${target.path}`
      );
    }
  }

  checkClaimTargetSyncPreviewSummary({
    claimTargetPlan,
    claimTargetSyncPreview,
    errors,
  });

  for (const listing of hostListings.filter((item) => item.dataOrigin === "organizerIntake")) {
    const entry = websiteEligibleByEntity.get(listing.id);
    if (!entry) {
      errors.push(
        `${listing.id}: organizer-intake website listing without pilot-eligible approved projection`
      );
    } else if (entry.publicListing.path !== listing.path) {
      errors.push(
        `${listing.id}: organizer-intake listing path ${listing.path} does not match ` +
          `${entry.publicListing.path}`
      );
    }
    if (!canonicalByEntity.has(listing.id)) {
      errors.push(`${listing.id}: organizer-intake website listing without canonical host entity`);
    }
  }

  return {
    errors,
    warnings,
    summary: {
      approvedProjections: approvedEntries.length,
      pilotEligibleProjections: websiteEligibleEntries.length,
      pilotSuppressedProjections:
        approvedEntries.length - websiteEligibleEntries.length,
      canonicalHostEntities: canonicalHostEntities.entries?.length ?? 0,
      claimTargets: claimTargetPlan.targets?.length ?? 0,
      claimTargetSyncPreviewWrites:
        claimTargetSyncPreview.summary?.writesNeeded ?? 0,
      organizerIntakeListings: hostListings.filter((item) =>
        item.dataOrigin === "organizerIntake"
      ).length,
      websiteListings: hostListings.length,
    },
  };
}

function normalizeMarketKey(value) {
  return String(value ?? "").toLowerCase().replace(/[^a-z0-9]+/gu, "");
}

function isLiveMarketValue(value) {
  const key = normalizeMarketKey(value);
  return key.length > 0 && liveMarketKeys.has(key);
}

function organizerIntakeProjectionHasLiveMarket(entry) {
  return (entry?.publicListing?.markets ?? []).some((market) =>
    isLiveMarketValue(market?.marketSlug) ||
      isLiveMarketValue(market?.displayName)
  );
}

function checkCanonicalHostEntity({canonical, entry, errors}) {
  if (canonical.canonicalHostId !== entry.entityId) {
    errors.push(`${entry.entityId}: canonicalHostId ${canonical.canonicalHostId} does not match entityId`);
  }
  if (canonical.publicPresence?.publishStatus !== entry.publishStatus) {
    errors.push(`${entry.entityId}: canonical publish status does not match projection`);
  }
  if (canonical.publicPresence?.indexStatus !== entry.indexStatus) {
    errors.push(`${entry.entityId}: canonical index status does not match projection`);
  }
  if (canonical.publicPresence?.canonicalPath !== entry.publicListing.path) {
    errors.push(`${entry.entityId}: canonical path does not match public listing`);
  }
  if (canonical.legacyClubCompatibility?.documentId !== entry.publicListing.id) {
    errors.push(`${entry.entityId}: canonical legacy club document id does not match public listing id`);
  }
}

function checkWebsiteListing({entry, listing, errors, warnings}) {
  const publicListing = entry.publicListing;
  if (listing.id !== publicListing.id) {
    errors.push(`${entry.entityId}: website listing id ${listing.id} does not match ${publicListing.id}`);
  }
  if (listing.dataOrigin !== "organizerIntake") {
    errors.push(`${entry.entityId}: website listing dataOrigin must be organizerIntake`);
  }
  if (listing.indexing !== publicListing.indexing) {
    errors.push(`${entry.entityId}: website indexing ${listing.indexing} does not match ${publicListing.indexing}`);
  }
  if (listing.status !== publicListing.status) {
    errors.push(`${entry.entityId}: website status ${listing.status} does not match ${publicListing.status}`);
  }
  const missingLegacy = (entry.legacyPaths ?? [])
    .filter((legacyPath) => !(listing.legacyPaths ?? []).includes(legacyPath));
  if (missingLegacy.length > 0) {
    errors.push(`${entry.entityId}: website listing missing legacy paths ${missingLegacy.join(", ")}`);
  }
  if (listing.indexing !== "index, follow") {
    warnings.push(`${entry.entityId}: approved public listing is not indexable (${listing.indexing})`);
  }
}

function checkClaimTarget({entry, target, errors}) {
  if (target.path !== `clubs/${entry.publicListing.id}`) {
    errors.push(`${entry.entityId}: claim target path ${target.path} does not match clubs/${entry.publicListing.id}`);
  }
  if (target.claimState !== "unclaimed") {
    errors.push(`${entry.entityId}: claim target state must be unclaimed`);
  }
  if (target.clubDocument?.publicPage?.canonicalPath !== entry.publicListing.path) {
    errors.push(`${entry.entityId}: claim target canonical path does not match public listing`);
  }
  if (target.clubDocument?.claim?.state !== "unclaimed") {
    errors.push(`${entry.entityId}: claim target club document must start unclaimed`);
  }
  if (target.clubDocument?.ownership?.state !== "programmatic") {
    errors.push(`${entry.entityId}: claim target club document must start as programmatic ownership`);
  }
}

function checkClaimTargetSyncPreview({errors, previewAction, target}) {
  if (!previewAction) {
    errors.push(`${target.entityId}: missing claim-target sync preview action`);
    return;
  }
  if (previewAction.entityId !== target.entityId) {
    errors.push(
      `${target.entityId}: claim-target sync preview entity ` +
        `${previewAction.entityId} does not match target`
    );
  }
  if (previewAction.path !== target.path) {
    errors.push(
      `${target.entityId}: claim-target sync preview path ${previewAction.path} ` +
        `does not match ${target.path}`
    );
  }
  if (previewAction.status !== "create") {
    errors.push(
      `${target.entityId}: empty-fixture claim-target sync preview must create, ` +
        `got ${previewAction.status}`
    );
  }
  if (previewAction.requiresFirestoreDryRun !== true) {
    errors.push(
      `${target.entityId}: claim-target sync preview must require Firestore dry run`
    );
  }
}

function checkClaimTargetSyncPreviewSummary({
  claimTargetPlan,
  claimTargetSyncPreview,
  errors,
}) {
  const targetCount = claimTargetPlan.targets?.length ?? 0;
  const previewSummary = claimTargetSyncPreview.summary ?? {};
  if (claimTargetSyncPreview.schemaVersion !== 1) {
    errors.push("claim-target sync preview schemaVersion must be 1");
  }
  if (claimTargetSyncPreview.mode?.previewOnly !== true) {
    errors.push("claim-target sync preview must be previewOnly");
  }
  if (claimTargetSyncPreview.mode?.remoteWrites !== 0) {
    errors.push("claim-target sync preview must not include remote writes");
  }
  if (previewSummary.targets !== targetCount) {
    errors.push(
      `claim-target sync preview targets ${previewSummary.targets ?? "missing"} ` +
        `does not match claim target plan ${targetCount}`
    );
  }
  if ((claimTargetSyncPreview.actions ?? []).length !== targetCount) {
    errors.push(
      `claim-target sync preview action count ` +
        `${(claimTargetSyncPreview.actions ?? []).length} does not match ` +
        `claim target plan ${targetCount}`
    );
  }
  if (targetCount > 0 && previewSummary.creates !== targetCount) {
    errors.push(
      `empty-fixture claim-target sync preview creates ` +
        `${previewSummary.creates ?? "missing"} does not match ${targetCount}`
    );
  }
  if (targetCount > 0 && previewSummary.writesNeeded !== targetCount) {
    errors.push(
      `empty-fixture claim-target sync preview writesNeeded ` +
        `${previewSummary.writesNeeded ?? "missing"} does not match ${targetCount}`
    );
  }
}

function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }
  const canonicalHostEntities = readJson(path.resolve(
    args.canonicalHostEntities ?? defaults.canonicalHostEntities
  ));
  const claimTargetSyncPreview = readJson(path.resolve(
    args.claimTargetSyncPreview ?? defaults.claimTargetSyncPreview
  ));
  const projectionPlan = readJson(path.resolve(args.projectionPlan ?? defaults.projectionPlan));
  const claimTargetPlan = readJson(path.resolve(args.claimTargets ?? defaults.claimTargets));
  const hostListings = readJson(path.resolve(args.hostListings ?? defaults.hostListings));
  const result = checkPromotionBridge({
    canonicalHostEntities,
    claimTargetSyncPreview,
    claimTargetPlan,
    hostListings,
    projectionPlan,
  });
  for (const warning of result.warnings) console.warn(`Warning: ${warning}`);
  if (result.errors.length > 0) {
    console.error("Organizer promotion bridge validation failed:");
    for (const error of result.errors) console.error(`- ${error}`);
    process.exit(1);
  }
  console.log(
    "Organizer promotion bridge ok: " +
    `${result.summary.approvedProjections} approved projection(s), ` +
      `${result.summary.claimTargets} claim target(s), ` +
      `${result.summary.claimTargetSyncPreviewWrites} preview write(s), ` +
      `${result.summary.organizerIntakeListings} organizer-intake website listing(s).`
  );
}

function parseArgs(argv) {
  const parsed = {
    claimTargets: null,
    claimTargetSyncPreview: null,
    canonicalHostEntities: null,
    help: false,
    hostListings: null,
    projectionPlan: null,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--canonical-host-entities") {
      parsed.canonicalHostEntities = requiredValue(argv, ++index, arg);
    }
    else if (arg === "--claim-target-sync-preview") {
      parsed.claimTargetSyncPreview = requiredValue(argv, ++index, arg);
    }
    else if (arg === "--claim-targets") parsed.claimTargets = requiredValue(argv, ++index, arg);
    else if (arg === "--host-listings") parsed.hostListings = requiredValue(argv, ++index, arg);
    else if (arg === "--projection-plan") parsed.projectionPlan = requiredValue(argv, ++index, arg);
    else fail(`Unknown argument: ${arg}`);
  }
  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) fail(`${flag} requires a value.`);
  return value;
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/check_promotion_bridge.mjs [options]

Options:
  --canonical-host-entities <path>
                            Canonical host entities JSON.
  --projection-plan <path>  Public projection plan JSON.
  --claim-targets <path>    Organizer claim targets JSON.
  --claim-target-sync-preview <path>
                            Generated claim-target sync preview JSON.
  --host-listings <path>    Website generated host listings JSON.
`);
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function fail(message) {
  console.error(message);
  process.exit(1);
}

function isMain() {
  return process.argv[1] &&
    import.meta.url === pathToFileURL(process.argv[1]).href;
}
