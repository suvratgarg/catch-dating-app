#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {
  photoPromptCatalog,
  profilePromptCatalog,
} from "../contracts/generated/schema_contract_registry.mjs";

export const MIN_SALES_PROFILE_PHOTOS = 4;
export const MAX_PROFILE_PHOTOS = 6;

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "../..");
export const DEFAULT_PERSONA_CATALOG_PATH = path.join(
  repoRoot,
  "tool/demo/demo_seed/personas/us_nyc_sales_personas.draft.json"
);
export const DEFAULT_PHOTO_ACTIVITY_TAXONOMY_PATH = path.join(
  repoRoot,
  "tool/demo/demo_seed/personas/photo_activity_taxonomy.json"
);
export const DEFAULT_PHOTO_COMPOSITION_INDEX_PATH = path.join(
  repoRoot,
  "tool/demo/demo_seed/personas/photo_composition_index.json"
);
export const DEFAULT_PERSONA_PROFILE_PROJECTION_PATH = path.join(
  repoRoot,
  "tool/demo/demo_seed/personas/us_nyc_sales_profile_projection.planned.json"
);

const allowedGenders = new Set(["woman", "man", "nonBinary", "other"]);
const allowedAssetStatuses = new Set(["planned", "generated", "uploaded"]);
const profilePromptIds = new Set(profilePromptCatalog.prompts.map((prompt) => prompt.id));
const photoPromptIds = new Set(photoPromptCatalog.prompts.map((prompt) => prompt.id));
const profilePromptById = new Map(
  profilePromptCatalog.prompts.map((prompt) => [prompt.id, prompt])
);
const photoPromptById = new Map(
  photoPromptCatalog.prompts.map((prompt) => [prompt.id, prompt])
);

export function loadPhotoActivityTaxonomy(
  filePath = DEFAULT_PHOTO_ACTIVITY_TAXONOMY_PATH
) {
  const resolvedPath = path.resolve(repoRoot, filePath);
  return JSON.parse(fs.readFileSync(resolvedPath, "utf8"));
}

export function loadPhotoCompositionIndex(
  filePath = DEFAULT_PHOTO_COMPOSITION_INDEX_PATH
) {
  const resolvedPath = path.resolve(repoRoot, filePath);
  return JSON.parse(fs.readFileSync(resolvedPath, "utf8"));
}

export function loadPersonaCatalog(filePath = DEFAULT_PERSONA_CATALOG_PATH, options = {}) {
  const resolvedPath = path.resolve(repoRoot, filePath);
  const catalog = JSON.parse(fs.readFileSync(resolvedPath, "utf8"));
  assertValidPersonaCatalog(catalog, {...options, source: resolvedPath});
  return catalog;
}

export function validatePersonaCatalog(catalog, options = {}) {
  const issues = [];
  const source = options.source ?? "persona catalog";

  if (!isRecord(catalog)) {
    return {
      valid: false,
      issues: [`${source}: expected a JSON object.`],
      summary: personaCatalogSummary({personas: []}),
    };
  }

  if (catalog.schemaVersion !== 1) {
    issues.push(`${source}: schemaVersion must be 1.`);
  }
  requireString(catalog, "id", `${source}`, issues);
  requireString(catalog, "label", `${source}`, issues);

  const minPhotos = positiveInteger(
    catalog.qualityGate?.minimumPhotosPerPersona,
    MIN_SALES_PROFILE_PHOTOS
  );
  const maxPhotos = positiveInteger(
    catalog.qualityGate?.maximumPhotosPerPersona,
    MAX_PROFILE_PHOTOS
  );
  const requirePublishedAssets = Boolean(
    options.requirePublishedAssets ?? catalog.qualityGate?.publishedAssetRequired
  );
  const photoTaxonomy = options.photoTaxonomy ?? loadPhotoActivityTaxonomy();
  validatePhotoActivityTaxonomy(photoTaxonomy, `${source}.photoActivityTaxonomy`, issues);
  const taxonomyIndex = photoActivityTaxonomyIndex(photoTaxonomy);
  const photoCompositionIndex =
    options.photoCompositionIndex ?? loadPhotoCompositionIndex();
  validatePhotoCompositionIndex(
    photoCompositionIndex,
    `${source}.photoCompositionIndex`,
    issues,
    taxonomyIndex
  );

  if (
    typeof catalog.photoActivityTaxonomyId === "string" &&
    isRecord(photoTaxonomy) &&
    typeof photoTaxonomy.id === "string" &&
    catalog.photoActivityTaxonomyId !== photoTaxonomy.id
  ) {
    issues.push(
      `${source}: photoActivityTaxonomyId must match ${photoTaxonomy.id}.`
    );
  }
  if (
    typeof catalog.photoCompositionIndexId === "string" &&
    isRecord(photoCompositionIndex) &&
    typeof photoCompositionIndex.id === "string" &&
    catalog.photoCompositionIndexId !== photoCompositionIndex.id
  ) {
    issues.push(
      `${source}: photoCompositionIndexId must match ${photoCompositionIndex.id}.`
    );
  }

  if (minPhotos < MIN_SALES_PROFILE_PHOTOS) {
    issues.push(
      `${source}: qualityGate.minimumPhotosPerPersona must be at least ${MIN_SALES_PROFILE_PHOTOS}.`
    );
  }
  if (maxPhotos > MAX_PROFILE_PHOTOS) {
    issues.push(
      `${source}: qualityGate.maximumPhotosPerPersona must be at most ${MAX_PROFILE_PHOTOS}.`
    );
  }
  if (minPhotos > maxPhotos) {
    issues.push(`${source}: minimumPhotosPerPersona cannot exceed maximumPhotosPerPersona.`);
  }

  if (!Array.isArray(catalog.personas)) {
    issues.push(`${source}: personas must be an array.`);
    return {valid: false, issues, summary: personaCatalogSummary(catalog)};
  }
  if (catalog.personas.length === 0) {
    issues.push(`${source}: personas must not be empty.`);
  }

  const personaIds = new Set();
  for (const [index, persona] of catalog.personas.entries()) {
    validatePersona(persona, {
      index,
      issues,
      source,
      personaIds,
      minPhotos,
      maxPhotos,
      requirePublishedAssets,
      photoTaxonomy,
      photoCompositionIndex,
      taxonomyIndex,
    });
  }

  const summary = personaCatalogSummary(catalog);
  validateCatalogPhotoComposition({
    source,
    issues,
    catalog,
    photoCompositionIndex,
    summary,
  });

  return {
    valid: issues.length === 0,
    issues,
    summary,
  };
}

export function assertValidPersonaCatalog(catalog, options = {}) {
  const result = validatePersonaCatalog(catalog, options);
  if (!result.valid) {
    throw new Error(
      `Persona catalog validation failed:\n- ${result.issues.join("\n- ")}`
    );
  }
  return catalog;
}

export function personaCatalogSummary(catalog) {
  const personas = Array.isArray(catalog?.personas) ? catalog.personas : [];
  const globalStats = emptyPhotoStats();
  const cityStats = new Map();
  const cohortStats = new Map();

  for (const persona of personas) {
    addPersonaToPhotoStats(globalStats, persona);

    const citySlug = persona?.citySlug ?? "unknown";
    if (!cityStats.has(citySlug)) cityStats.set(citySlug, emptyPhotoStats());
    addPersonaToPhotoStats(cityStats.get(citySlug), persona);

    const cohortIds = [
      ...(Array.isArray(catalog?.compositionCohortIds) ?
        catalog.compositionCohortIds :
        []),
      ...(Array.isArray(persona?.compositionCohortIds) ?
        persona.compositionCohortIds :
        []),
    ].filter((cohortId) => typeof cohortId === "string" && cohortId.length > 0);
    for (const cohortId of new Set(cohortIds)) {
      if (!cohortStats.has(cohortId)) cohortStats.set(cohortId, emptyPhotoStats());
      addPersonaToPhotoStats(cohortStats.get(cohortId), persona);
    }
  }

  const global = finalizePhotoStats(globalStats);
  return {
    id: catalog?.id ?? null,
    label: catalog?.label ?? null,
    personaCount: global.personaCount,
    photoCount: global.photoCount,
    uploadedPhotoCount: global.uploadedPhotoCount,
    runningPhotoCount: global.runningPhotoCount,
    runningPhotoShare: global.runningPhotoShare,
    cityCounts: global.cityCounts,
    genderCounts: global.genderCounts,
    categoryCounts: global.categoryCounts,
    categoryShares: global.categoryShares,
    activityCounts: global.activityCounts,
    activityShares: global.activityShares,
    cityPhotoComposition: statsMapToObject(cityStats),
    cohortPhotoComposition: statsMapToObject(cohortStats),
  };
}

export function profilePromptAnswersForPersona(persona) {
  return persona.profilePrompts.map((answer) => {
    const prompt = profilePromptById.get(answer.promptId);
    if (!prompt) throw new Error(`Unknown profile prompt id: ${answer.promptId}`);
    return {
      promptId: prompt.id,
      prompt: prompt.title,
      answer: answer.answer,
    };
  });
}

export function photoPromptAnswersForPersona(persona) {
  return persona.photos
    .slice()
    .sort((a, b) => a.position - b.position)
    .map((photo) => {
      const prompt = photoPromptById.get(photo.promptId);
      if (!prompt) throw new Error(`Unknown photo prompt id: ${photo.promptId}`);
      return {
        photoIndex: photo.position,
        promptId: prompt.id,
        prompt: prompt.title,
      };
    });
}

export function profilePhotosForPersona(
  persona,
  {assetStatuses = null, createdAt = null, updatedAt = null} = {}
) {
  const statusFilter = normalizeAssetStatusFilter(assetStatuses);
  return persona.photos
    .slice()
    .sort((a, b) => a.position - b.position)
    .filter((photo) => statusFilter === null || statusFilter.has(photo.assetStatus))
    .map((photo) => {
      const entry = {
        id: photo.id,
        url: photo.url,
        thumbnailUrl: photo.thumbnailUrl,
        storagePath: photo.storagePath,
        thumbnailStoragePath: photo.thumbnailStoragePath,
        promptId: photo.promptId,
        prompt: photoPromptById.get(photo.promptId)?.title ?? photo.promptId,
        position: photo.position,
        moderation: {
          status: "approved",
          synthetic: true,
        },
      };
      if (createdAt) entry.createdAt = createdAt;
      if (updatedAt) entry.updatedAt = updatedAt;
      return entry;
    });
}

export function personaProfileProjection(catalog, options = {}) {
  assertValidPersonaCatalog(catalog, options);
  if (!Object.prototype.hasOwnProperty.call(options, "assetStatuses") ||
      options.assetStatuses === null) {
    throw new Error(
      "personaProfileProjection requires explicit assetStatuses; pass planned, generated, uploaded, or all."
    );
  }
  if (
    (Array.isArray(options.assetStatuses) && options.assetStatuses.length === 0) ||
    (options.assetStatuses instanceof Set && options.assetStatuses.size === 0)
  ) {
    throw new Error(
      "personaProfileProjection requires at least one asset status; pass planned, generated, uploaded, or all."
    );
  }
  const statusFilter = normalizeAssetStatusFilter(options.assetStatuses);
  const personas = catalog.personas.map((persona) => {
    const profilePhotos = profilePhotosForPersona(persona, {
      assetStatuses: statusFilter,
      createdAt: options.createdAt ?? null,
      updatedAt: options.updatedAt ?? null,
    });
    return {
      id: persona.id,
      firstName: persona.firstName,
      lastName: persona.lastName,
      displayName: persona.displayName,
      gender: persona.gender,
      pronouns: persona.pronouns,
      dateOfBirth: persona.dateOfBirth,
      heightCm: persona.heightCm,
      countryCode: persona.countryCode,
      citySlug: persona.citySlug,
      cityLabel: persona.cityLabel,
      occupation: persona.occupation,
      company: persona.company,
      profilePrompts: profilePromptAnswersForPersona(persona),
      photoPrompts: photoPromptAnswersForPersona(persona),
      profilePhotos,
    };
  });
  return {
    schemaVersion: 1,
    kind: "sales-demo-persona-profile-projection",
    catalogId: catalog.id,
    catalogLabel: catalog.label,
    assetStatuses: statusFilter === null ? ["all"] : [...statusFilter].sort(),
    personaCount: personas.length,
    projectedPhotoCount: personas.reduce(
      (total, persona) => total + persona.profilePhotos.length,
      0
    ),
    personas,
  };
}

export function personaPhotoGenerationPlan(catalog, options = {}) {
  assertValidPersonaCatalog(catalog, options);
  const photos = [];
  for (const persona of catalog.personas) {
    for (const photo of persona.photos.slice().sort((a, b) => a.position - b.position)) {
      photos.push({
        personaId: persona.id,
        displayName: persona.displayName,
        gender: persona.gender,
        citySlug: persona.citySlug,
        photoId: photo.id,
        position: photo.position,
        categoryId: photo.categoryId,
        activityId: photo.activityId,
        promptId: photo.promptId,
        scene: photo.scene,
        generationPrompt: photo.generationPrompt,
        continuityNotes: photo.continuityNotes,
        storagePath: photo.storagePath,
        thumbnailStoragePath: photo.thumbnailStoragePath,
      });
    }
  }
  return {
    catalogId: catalog.id,
    summary: personaCatalogSummary(catalog),
    photos,
  };
}

export function formatPersonaPhotoGenerationPlanMarkdown(plan) {
  const lines = [
    "# Persona Photo Generation Plan",
    "",
    `Catalog: ${plan.catalogId}`,
    `Personas: ${plan.summary.personaCount}`,
    `Photos: ${plan.photos.length}`,
    `Running photos: ${plan.summary.runningPhotoCount} (${formatShare(plan.summary.runningPhotoShare)})`,
    "",
    "## Composition",
    "",
    "| Category | Count | Share |",
    "|---|---:|---:|",
  ];

  for (const [categoryId, count] of sortedObjectEntries(plan.summary.categoryCounts)) {
    lines.push(
      `| ${categoryId} | ${count} | ${formatShare(plan.summary.categoryShares[categoryId])} |`
    );
  }

  lines.push(
    "",
    "| Activity | Count | Share |",
    "|---|---:|---:|",
  );
  for (const [activityId, count] of sortedObjectEntries(plan.summary.activityCounts)) {
    lines.push(
      `| ${activityId} | ${count} | ${formatShare(plan.summary.activityShares[activityId])} |`
    );
  }

  let currentPersonaId = null;
  for (const photo of plan.photos) {
    if (photo.personaId !== currentPersonaId) {
      currentPersonaId = photo.personaId;
      lines.push("", `## ${photo.displayName}`, "");
    }
    lines.push(
      `### Photo ${photo.position + 1}: ${photo.categoryId}/${photo.activityId}`,
      "",
      `Scene: ${photo.scene}`,
      "",
      `Prompt: ${photo.generationPrompt}`,
      "",
      `Continuity: ${photo.continuityNotes}`,
      ""
    );
  }

  return `${lines.join("\n").trimEnd()}\n`;
}

function normalizeAssetStatusFilter(assetStatuses) {
  if (assetStatuses === null || assetStatuses === "all") return null;
  const values = assetStatuses instanceof Set ?
    [...assetStatuses] :
    (Array.isArray(assetStatuses) ? assetStatuses : [assetStatuses]);
  const normalized = new Set();
  for (const value of values) {
    if (value === "all") return null;
    if (typeof value !== "string" || value.trim().length === 0) continue;
    const status = value.trim();
    if (!allowedAssetStatuses.has(status)) {
      throw new Error(
        `Unknown persona asset status ${status}; expected one of all, ` +
        `${[...allowedAssetStatuses].join(", ")}.`
      );
    }
    normalized.add(status);
  }
  return normalized.size > 0 ? normalized : null;
}

function validatePersona(
  persona,
  {
    index,
    issues,
    source,
    personaIds,
    minPhotos,
    maxPhotos,
    requirePublishedAssets,
    photoTaxonomy,
    photoCompositionIndex,
    taxonomyIndex,
  }
) {
  const label = personaLabel(source, index, persona);
  if (!isRecord(persona)) {
    issues.push(`${label}: expected an object.`);
    return;
  }

  requireString(persona, "id", label, issues);
  if (typeof persona.id === "string") {
    if (!/^[a-z0-9][a-z0-9_-]*$/.test(persona.id)) {
      issues.push(`${label}: id must be lowercase kebab/snake style.`);
    }
    if (personaIds.has(persona.id)) {
      issues.push(`${label}: duplicate persona id ${persona.id}.`);
    }
    personaIds.add(persona.id);
  }

  for (const field of [
    "firstName",
    "lastName",
    "displayName",
    "countryCode",
    "citySlug",
    "cityLabel",
    "occupation",
    "demographicBrief",
    "appearanceContinuityBrief",
    "personalityBrief",
    "marketFitBrief",
  ]) {
    requireString(persona, field, label, issues);
  }

  if (!allowedGenders.has(persona.gender)) {
    issues.push(`${label}: gender must be one of ${[...allowedGenders].join(", ")}.`);
  }

  if (!/^\d{4}-\d{2}-\d{2}$/.test(String(persona.dateOfBirth ?? ""))) {
    issues.push(`${label}: dateOfBirth must use YYYY-MM-DD.`);
  }

  if (!Number.isInteger(persona.heightCm) || persona.heightCm < 140 || persona.heightCm > 210) {
    issues.push(`${label}: heightCm must be an integer between 140 and 210.`);
  }

  validateProfilePrompts(persona.profilePrompts, label, issues);
  validatePhotos(persona.photos, {
    label,
    issues,
    minPhotos,
    maxPhotos,
    requirePublishedAssets,
    photoTaxonomy,
    photoCompositionIndex,
    taxonomyIndex,
  });
}

function validateProfilePrompts(profilePrompts, label, issues) {
  if (!Array.isArray(profilePrompts)) {
    issues.push(`${label}: profilePrompts must be an array.`);
    return;
  }
  if (profilePrompts.length !== profilePromptCatalog.limits.maxAnswers) {
    issues.push(
      `${label}: profilePrompts must contain exactly ${profilePromptCatalog.limits.maxAnswers} answers.`
    );
  }

  const seenPromptIds = new Set();
  for (const [index, answer] of profilePrompts.entries()) {
    const answerLabel = `${label}.profilePrompts[${index}]`;
    if (!isRecord(answer)) {
      issues.push(`${answerLabel}: expected an object.`);
      continue;
    }
    requireString(answer, "promptId", answerLabel, issues);
    requireString(answer, "answer", answerLabel, issues);
    if (typeof answer.promptId === "string") {
      if (!profilePromptIds.has(answer.promptId)) {
        issues.push(`${answerLabel}: unknown promptId ${answer.promptId}.`);
      }
      if (seenPromptIds.has(answer.promptId)) {
        issues.push(`${answerLabel}: duplicate promptId ${answer.promptId}.`);
      }
      seenPromptIds.add(answer.promptId);
    }
    if (
      typeof answer.answer === "string" &&
      answer.answer.length > profilePromptCatalog.limits.maxAnswerLength
    ) {
      issues.push(
        `${answerLabel}: answer exceeds ${profilePromptCatalog.limits.maxAnswerLength} characters.`
      );
    }
  }
}

function validatePhotos(
  photos,
  {
    label,
    issues,
    minPhotos,
    maxPhotos,
    requirePublishedAssets,
    photoTaxonomy,
    photoCompositionIndex,
    taxonomyIndex,
  }
) {
  if (!Array.isArray(photos)) {
    issues.push(`${label}: photos must be an array.`);
    return;
  }
  if (photos.length < minPhotos) {
    issues.push(`${label}: photos must contain at least ${minPhotos} entries.`);
  }
  if (photos.length > maxPhotos) {
    issues.push(`${label}: photos must contain at most ${maxPhotos} entries.`);
  }

  const positions = new Set();
  const ids = new Set();
  const categoryCounts = new Map();
  const activityCounts = new Map();
  const distinctCategories = new Set();
  let runningPhotoCount = 0;
  for (const [index, photo] of photos.entries()) {
    const photoLabel = `${label}.photos[${index}]`;
    if (!isRecord(photo)) {
      issues.push(`${photoLabel}: expected an object.`);
      continue;
    }
    for (const field of [
      "id",
      "url",
      "thumbnailUrl",
      "storagePath",
      "thumbnailStoragePath",
      "promptId",
      "categoryId",
      "activityId",
      "assetStatus",
      "scene",
      "generationPrompt",
      "continuityNotes",
    ]) {
      requireString(photo, field, photoLabel, issues);
    }
    if (typeof photo.id === "string") {
      if (ids.has(photo.id)) issues.push(`${photoLabel}: duplicate photo id ${photo.id}.`);
      ids.add(photo.id);
    }
    if (!Number.isInteger(photo.position) || photo.position < 0 || photo.position >= maxPhotos) {
      issues.push(`${photoLabel}: position must be an integer from 0 to ${maxPhotos - 1}.`);
    } else if (positions.has(photo.position)) {
      issues.push(`${photoLabel}: duplicate position ${photo.position}.`);
    } else {
      positions.add(photo.position);
    }
    if (typeof photo.promptId === "string" && !photoPromptIds.has(photo.promptId)) {
      issues.push(`${photoLabel}: unknown promptId ${photo.promptId}.`);
    }
    validatePhotoActivity(photo, {
      photoLabel,
      issues,
      taxonomyIndex,
      categoryCounts,
      activityCounts,
      distinctCategories,
    });
    if (photo.activityId === "running") runningPhotoCount += 1;
    if (typeof photo.assetStatus === "string" && !allowedAssetStatuses.has(photo.assetStatus)) {
      issues.push(
        `${photoLabel}: assetStatus must be one of ${[...allowedAssetStatuses].join(", ")}.`
      );
    }
    if (requirePublishedAssets && photo.assetStatus !== "uploaded") {
      issues.push(`${photoLabel}: assetStatus must be uploaded for live seed writes.`);
    }
    validateHttpsUrl(photo.url, `${photoLabel}.url`, issues);
    validateHttpsUrl(photo.thumbnailUrl, `${photoLabel}.thumbnailUrl`, issues);
    validateStoragePath(photo.storagePath, `${photoLabel}.storagePath`, issues);
    validateStoragePath(
      photo.thumbnailStoragePath,
      `${photoLabel}.thumbnailStoragePath`,
      issues
    );
  }

  for (let position = 0; position < Math.min(photos.length, maxPhotos); position += 1) {
    if (!positions.has(position)) {
      issues.push(`${label}: photos must use contiguous positions starting at 0.`);
      break;
    }
  }

  validatePhotoMix({
    label,
    issues,
    photoTaxonomy,
    photoCompositionIndex,
    categoryCounts,
    activityCounts,
    distinctCategories,
    runningPhotoCount,
  });
}

function validatePhotoActivity(
  photo,
  {photoLabel, issues, taxonomyIndex, categoryCounts, activityCounts, distinctCategories}
) {
  const categoryId = photo.categoryId;
  const activityId = photo.activityId;
  if (typeof categoryId !== "string" || typeof activityId !== "string") return;
  const category = taxonomyIndex.categoriesById.get(categoryId);
  const activity = taxonomyIndex.activitiesById.get(activityId);
  if (!category) {
    issues.push(`${photoLabel}: unknown categoryId ${categoryId}.`);
  }
  if (!activity) {
    issues.push(`${photoLabel}: unknown activityId ${activityId}.`);
  }
  if (category && activity && activity.categoryId !== category.id) {
    issues.push(
      `${photoLabel}: activityId ${activityId} belongs to ${activity.categoryId}, not ${categoryId}.`
    );
  }
  if (category) {
    increment(categoryCounts, category.id);
    distinctCategories.add(category.id);
  }
  if (activity) {
    increment(activityCounts, activity.id);
  }
}

function validatePhotoMix({
  label,
  issues,
  photoTaxonomy,
  photoCompositionIndex,
  categoryCounts,
  activityCounts,
  distinctCategories,
  runningPhotoCount,
}) {
  if (isRecord(photoCompositionIndex?.profileRules)) {
    validateProfilePhotoComposition({
      label,
      issues,
      profileRules: photoCompositionIndex.profileRules,
      categoryCounts,
      activityCounts,
      distinctCategories,
      runningPhotoCount,
    });
    return;
  }
  const policy = photoTaxonomy?.profileMixPolicy;
  if (!isRecord(policy)) return;

  for (const categoryId of Array.isArray(policy.requiredCategoryIds) ?
    policy.requiredCategoryIds :
    []) {
    if (!distinctCategories.has(categoryId)) {
      issues.push(`${label}: photos must include category ${categoryId}.`);
    }
  }

  const minimumDistinct = policy.minimumDistinctCategoriesPerPersona;
  if (
    Number.isInteger(minimumDistinct) &&
    distinctCategories.size < minimumDistinct
  ) {
    issues.push(
      `${label}: photos must span at least ${minimumDistinct} distinct categories.`
    );
  }

  if (isRecord(policy.maximumCategoryCounts)) {
    for (const [categoryId, maxCount] of Object.entries(policy.maximumCategoryCounts)) {
      if (
        Number.isInteger(maxCount) &&
        (categoryCounts.get(categoryId) ?? 0) > maxCount
      ) {
        issues.push(`${label}: category ${categoryId} can appear at most ${maxCount} time(s).`);
      }
    }
  }

  if (
    Number.isInteger(policy.maximumRunningPhotosPerPersona) &&
    runningPhotoCount > policy.maximumRunningPhotosPerPersona
  ) {
    issues.push(
      `${label}: running photos can appear at most ${policy.maximumRunningPhotosPerPersona} time(s).`
    );
  }
}

function validateProfilePhotoComposition({
  label,
  issues,
  profileRules,
  categoryCounts,
  activityCounts,
  distinctCategories,
}) {
  const photoCount = sumMapValues(categoryCounts);
  validateNumericBounds(
    photoCount,
    profileRules.photoCount,
    `${label}: photo count`,
    issues
  );

  const minimumDistinct = profileRules.minimumDistinctCategories;
  if (
    Number.isInteger(minimumDistinct) &&
    distinctCategories.size < minimumDistinct
  ) {
    issues.push(
      `${label}: photos must span at least ${minimumDistinct} distinct categories.`
    );
  }

  validateCountRules({
    label,
    issues,
    kind: "category",
    rules: profileRules.categoryCounts,
    counts: categoryCounts,
  });
  validateCountRules({
    label,
    issues,
    kind: "activity",
    rules: profileRules.activityCounts,
    counts: activityCounts,
  });
}

function validateCatalogPhotoComposition({
  source,
  issues,
  catalog,
  photoCompositionIndex,
  summary,
}) {
  if (!isRecord(photoCompositionIndex)) return;

  validateStatsAgainstCompositionRules({
    label: source,
    issues,
    stats: summary,
    rules: photoCompositionIndex.catalogRules,
  });

  if (isRecord(photoCompositionIndex.cityRules)) {
    for (const [citySlug, rules] of Object.entries(photoCompositionIndex.cityRules)) {
      const stats = summary.cityPhotoComposition?.[citySlug];
      if (stats) {
        validateStatsAgainstCompositionRules({
          label: `${source}.city[${citySlug}]`,
          issues,
          stats,
          rules,
        });
      }
    }
  }

  const cohortIds = Array.isArray(catalog?.compositionCohortIds) ?
    catalog.compositionCohortIds :
    [];
  if (isRecord(photoCompositionIndex.cohortRules)) {
    for (const cohortId of cohortIds) {
      const rules = photoCompositionIndex.cohortRules[cohortId];
      const stats = summary.cohortPhotoComposition?.[cohortId];
      if (rules && stats) {
        validateStatsAgainstCompositionRules({
          label: `${source}.cohort[${cohortId}]`,
          issues,
          stats,
          rules,
        });
      }
    }
  }
}

function validateStatsAgainstCompositionRules({label, issues, stats, rules}) {
  if (!isRecord(rules)) return;
  if (
    Number.isInteger(rules.minimumPersonas) &&
    stats.personaCount < rules.minimumPersonas
  ) {
    issues.push(`${label}: must include at least ${rules.minimumPersonas} personas.`);
  }

  validateShareRules({
    label,
    issues,
    kind: "category",
    rules: rules.categoryShare,
    shares: stats.categoryShares,
  });
  validateShareRules({
    label,
    issues,
    kind: "activity",
    rules: rules.activityShare,
    shares: stats.activityShares,
  });
}

function validateShareRules({label, issues, kind, rules, shares}) {
  if (!isRecord(rules)) return;
  for (const [id, bounds] of Object.entries(rules)) {
    const share = Number(shares?.[id] ?? 0);
    if (typeof bounds.minimum === "number" && share < bounds.minimum) {
      issues.push(
        `${label}: ${kind} ${id} share ${formatShare(share)} is below ${formatShare(bounds.minimum)}.`
      );
    }
    if (typeof bounds.maximum === "number" && share > bounds.maximum) {
      issues.push(
        `${label}: ${kind} ${id} share ${formatShare(share)} exceeds ${formatShare(bounds.maximum)}.`
      );
    }
  }
}

function validateCountRules({label, issues, kind, rules, counts}) {
  if (!isRecord(rules)) return;
  for (const [id, bounds] of Object.entries(rules)) {
    validateNumericBounds(
      counts.get(id) ?? 0,
      bounds,
      `${label}: ${kind} ${id}`,
      issues
    );
  }
}

function validateNumericBounds(value, bounds, label, issues) {
  if (!isRecord(bounds)) return;
  if (typeof bounds.minimum === "number" && value < bounds.minimum) {
    issues.push(`${label} must be at least ${bounds.minimum}.`);
  }
  if (typeof bounds.maximum === "number" && value > bounds.maximum) {
    issues.push(`${label} can be at most ${bounds.maximum}.`);
  }
}

function validatePhotoActivityTaxonomy(taxonomy, label, issues) {
  if (!isRecord(taxonomy)) {
    issues.push(`${label}: expected a JSON object.`);
    return;
  }
  if (taxonomy.schemaVersion !== 1) {
    issues.push(`${label}: schemaVersion must be 1.`);
  }
  requireString(taxonomy, "id", label, issues);
  if (!Array.isArray(taxonomy.categories) || taxonomy.categories.length === 0) {
    issues.push(`${label}: categories must be a non-empty array.`);
  }
  if (!Array.isArray(taxonomy.activities) || taxonomy.activities.length === 0) {
    issues.push(`${label}: activities must be a non-empty array.`);
  }
}

function validatePhotoCompositionIndex(index, label, issues, taxonomyIndex) {
  if (!isRecord(index)) {
    issues.push(`${label}: expected a JSON object.`);
    return;
  }
  if (index.schemaVersion !== 1) {
    issues.push(`${label}: schemaVersion must be 1.`);
  }
  requireString(index, "id", label, issues);
  if (
    typeof index.photoActivityTaxonomyId === "string" &&
    !index.photoActivityTaxonomyId.endsWith("photo-activity-taxonomy-v1")
  ) {
    issues.push(`${label}: photoActivityTaxonomyId is not a recognized taxonomy id.`);
  }
  validateCompositionRuleReferences(
    index.profileRules?.categoryCounts,
    `${label}.profileRules.categoryCounts`,
    issues,
    taxonomyIndex.categoriesById
  );
  validateCompositionRuleReferences(
    index.profileRules?.activityCounts,
    `${label}.profileRules.activityCounts`,
    issues,
    taxonomyIndex.activitiesById
  );
  validateCompositionRuleReferences(
    index.catalogRules?.categoryShare,
    `${label}.catalogRules.categoryShare`,
    issues,
    taxonomyIndex.categoriesById
  );
  validateCompositionRuleReferences(
    index.catalogRules?.activityShare,
    `${label}.catalogRules.activityShare`,
    issues,
    taxonomyIndex.activitiesById
  );
}

function validateCompositionRuleReferences(rules, label, issues, knownIds) {
  if (!isRecord(rules)) return;
  for (const id of Object.keys(rules)) {
    if (!knownIds.has(id)) {
      issues.push(`${label}: unknown id ${id}.`);
    }
  }
}

function photoActivityTaxonomyIndex(taxonomy) {
  const categoriesById = new Map();
  const activitiesById = new Map();
  for (const category of Array.isArray(taxonomy?.categories) ? taxonomy.categories : []) {
    if (isRecord(category) && typeof category.id === "string") {
      categoriesById.set(category.id, category);
    }
  }
  for (const activity of Array.isArray(taxonomy?.activities) ? taxonomy.activities : []) {
    if (isRecord(activity) && typeof activity.id === "string") {
      activitiesById.set(activity.id, activity);
    }
  }
  return {categoriesById, activitiesById};
}

function emptyPhotoStats() {
  return {
    personaCount: 0,
    photoCount: 0,
    uploadedPhotoCount: 0,
    runningPhotoCount: 0,
    cityCounts: new Map(),
    genderCounts: new Map(),
    categoryCounts: new Map(),
    activityCounts: new Map(),
  };
}

function addPersonaToPhotoStats(stats, persona) {
  stats.personaCount += 1;
  increment(stats.cityCounts, persona?.citySlug ?? "unknown");
  increment(stats.genderCounts, persona?.gender ?? "unknown");
  for (const photo of Array.isArray(persona?.photos) ? persona.photos : []) {
    stats.photoCount += 1;
    if (photo?.assetStatus === "uploaded") stats.uploadedPhotoCount += 1;
    increment(stats.categoryCounts, photo?.categoryId ?? "unknown");
    increment(stats.activityCounts, photo?.activityId ?? "unknown");
    if (photo?.activityId === "running") stats.runningPhotoCount += 1;
  }
}

function finalizePhotoStats(stats) {
  return {
    personaCount: stats.personaCount,
    photoCount: stats.photoCount,
    uploadedPhotoCount: stats.uploadedPhotoCount,
    runningPhotoCount: stats.runningPhotoCount,
    runningPhotoShare: stats.photoCount > 0 ? stats.runningPhotoCount / stats.photoCount : 0,
    cityCounts: mapToSortedObject(stats.cityCounts),
    genderCounts: mapToSortedObject(stats.genderCounts),
    categoryCounts: mapToSortedObject(stats.categoryCounts),
    categoryShares: shareObject(stats.categoryCounts, stats.photoCount),
    activityCounts: mapToSortedObject(stats.activityCounts),
    activityShares: shareObject(stats.activityCounts, stats.photoCount),
  };
}

function statsMapToObject(statsMap) {
  return Object.fromEntries(
    [...statsMap.entries()]
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, stats]) => [key, finalizePhotoStats(stats)])
  );
}

function mapToSortedObject(map) {
  return Object.fromEntries([...map.entries()].sort(([a], [b]) => a.localeCompare(b)));
}

function shareObject(map, total) {
  return Object.fromEntries(
    [...map.entries()]
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, count]) => [key, total > 0 ? count / total : 0])
  );
}

function sortedObjectEntries(record) {
  return Object.entries(isRecord(record) ? record : {})
    .sort(([a], [b]) => a.localeCompare(b));
}

function validateHttpsUrl(value, label, issues) {
  if (typeof value !== "string") return;
  try {
    const url = new URL(value);
    if (url.protocol !== "https:") {
      issues.push(`${label}: must be an https URL.`);
    }
  } catch {
    issues.push(`${label}: must be a valid URL.`);
  }
}

function validateStoragePath(value, label, issues) {
  if (typeof value !== "string") return;
  if (value.startsWith("/") || value.includes("..") || value.trim() !== value) {
    issues.push(`${label}: must be a normalized storage path.`);
  }
}

function personaLabel(source, index, persona) {
  const id = isRecord(persona) && typeof persona.id === "string" ? ` ${persona.id}` : "";
  return `${source}.personas[${index}]${id}`;
}

function requireString(object, field, label, issues) {
  if (typeof object?.[field] !== "string" || object[field].trim().length === 0) {
    issues.push(`${label}: ${field} must be a non-empty string.`);
  }
}

function positiveInteger(value, fallback) {
  return Number.isInteger(value) && value > 0 ? value : fallback;
}

function increment(map, key) {
  map.set(key, (map.get(key) ?? 0) + 1);
}

function sumMapValues(map) {
  let total = 0;
  for (const value of map.values()) total += value;
  return total;
}

function formatShare(value) {
  return `${Math.round(value * 1000) / 10}%`;
}

function isRecord(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function main(argv) {
  const requirePublishedAssets = argv.includes("--require-published-assets");
  const positional = argv.filter((arg) => !arg.startsWith("--"));
  const catalogPath = positional[0] ?? DEFAULT_PERSONA_CATALOG_PATH;
  const catalog = loadPersonaCatalog(catalogPath, {requirePublishedAssets});
  process.stdout.write(`${JSON.stringify(personaCatalogSummary(catalog), null, 2)}\n`);
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  main(process.argv.slice(2));
}
