#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";
import {
  DEFAULT_PERSONA_CATALOG_PATH,
  loadPersonaCatalog,
} from "./demo_persona_catalog.mjs";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "../..");

export const DEFAULT_PERSONA_IMAGE_PILOT_PATH = path.join(
  repoRoot,
  "tool/demo/demo_seed/personas/image_generation_pilot.json"
);
export const DEFAULT_PERSONA_IMAGE_OUTPUT_DIR = path.join(
  repoRoot,
  "build/demo-persona-images"
);

const defaultProvider = "openai";
const defaultSize = "1024x1536";
const defaultQuality = "high";
const defaultImageFormat = "jpeg";
const allowedProviders = new Set(["openai", "gemini"]);
const allowedImageFormats = new Set(["jpeg", "png", "webp"]);

const providerDefaults = {
  openai: {
    model: "gpt-image-2",
    fallbackModel: "gpt-image-1.5",
    imageFormat: "jpeg",
    api: "image-api",
  },
  gemini: {
    model: "gemini-3-pro-image-preview",
    fallbackModel: "gemini-3.1-flash-image-preview",
    imageFormat: "png",
    api: "gemini-generate-content",
  },
};

export function loadPersonaImagePilotConfig(
  filePath = DEFAULT_PERSONA_IMAGE_PILOT_PATH
) {
  const resolvedPath = path.resolve(repoRoot, filePath);
  return JSON.parse(fs.readFileSync(resolvedPath, "utf8"));
}

export function buildPersonaImageGenerationBatch(catalog, options = {}) {
  const pilotConfig = options.pilotConfig ?? loadPersonaImagePilotConfig();
  validatePilotConfig(pilotConfig);

  const provider = options.provider ?? pilotConfig.provider ?? defaultProvider;
  const providerMatchesConfig = provider === pilotConfig.provider;
  const defaults = providerDefaults[provider] ?? providerDefaults[defaultProvider];
  const model = options.model ??
    (providerMatchesConfig ? pilotConfig.model : undefined) ??
    defaults.model;
  const fallbackModel =
    options.fallbackModel ??
    (providerMatchesConfig ? pilotConfig.fallbackModel : undefined) ??
    defaults.fallbackModel;
  const size = options.size ?? pilotConfig.size ?? defaultSize;
  const quality = options.quality ?? pilotConfig.quality ?? defaultQuality;
  const imageFormat =
    options.imageFormat ??
    (providerMatchesConfig ? pilotConfig.imageFormat : undefined) ??
    defaults.imageFormat ??
    defaultImageFormat;
  const outputDir = path.resolve(
    repoRoot,
    options.outputDir ?? DEFAULT_PERSONA_IMAGE_OUTPUT_DIR
  );

  if (!allowedProviders.has(provider)) {
    throw new Error(`Unsupported image provider: ${provider}`);
  }
  if (!allowedImageFormats.has(imageFormat)) {
    throw new Error(`Unsupported image format: ${imageFormat}`);
  }

  const requestedPersonaIds = Array.isArray(options.personaIds) &&
      options.personaIds.length > 0 ?
    options.personaIds :
    pilotConfig.pilotPersonaIds;
  if (!Array.isArray(requestedPersonaIds) || requestedPersonaIds.length === 0) {
    throw new Error("Image generation batch requires at least one persona id.");
  }

  const personasById = new Map(catalog.personas.map((persona) => [persona.id, persona]));
  const personas = [];
  for (const personaId of requestedPersonaIds) {
    const persona = personasById.get(personaId);
    if (!persona) throw new Error(`Unknown persona id in image pilot: ${personaId}`);
    personas.push(buildPersonaImageRequests(persona, {
      outputDir,
      provider,
      model,
      fallbackModel,
      size,
      quality,
      imageFormat,
    }));
  }

  const photoCount = personas.reduce((total, persona) => total + persona.photos.length, 0);
  return {
    schemaVersion: 1,
    id: pilotConfig.id,
    label: pilotConfig.label,
    catalogId: catalog.id,
    provider,
    api: providerMatchesConfig ? (pilotConfig.api ?? defaults.api) : defaults.api,
    model,
    fallbackModel,
    size,
    quality,
    imageFormat,
    referenceStrategy: pilotConfig.referenceStrategy ?? "hero-only",
    outputDir,
    personaCount: personas.length,
    photoCount,
    reviewCriteria: Array.isArray(pilotConfig.reviewCriteria) ?
      pilotConfig.reviewCriteria :
      [],
    personas,
  };
}

export function formatPersonaImageGenerationBatchMarkdown(batch) {
  const lines = [
    "# Persona Image Generation Batch",
    "",
    `Batch: ${batch.id}`,
    `Catalog: ${batch.catalogId}`,
    `Provider: ${batch.provider}`,
    `Model: ${batch.model}`,
    `Fallback model: ${batch.fallbackModel}`,
    `Size: ${batch.size}`,
    `Quality: ${batch.quality}`,
    `Image format: ${batch.imageFormat}`,
    `Reference strategy: ${batch.referenceStrategy}`,
    `Personas: ${batch.personaCount}`,
    `Photos: ${batch.photoCount}`,
    `Output dir: ${batch.outputDir}`,
    "",
    "## Review Criteria",
    "",
  ];
  for (const criterion of batch.reviewCriteria) {
    lines.push(`- ${criterion}`);
  }

  for (const persona of batch.personas) {
    lines.push("", `## ${persona.displayName}`, "");
    for (const photo of persona.photos) {
      const dependency = photo.dependsOnPhotoId ?
        `, depends on ${photo.dependsOnPhotoId}` :
        "";
      lines.push(
        `### Photo ${photo.position + 1}: ${photo.requestKind}${dependency}`,
        "",
        `Output: ${photo.localPath}`,
        "",
        `Prompt: ${photo.providerPrompt}`,
        ""
      );
    }
  }
  return `${lines.join("\n").trimEnd()}\n`;
}

export function formatPersonaImageGenerationBatchJsonl(batch) {
  return `${batch.personas.flatMap((persona) =>
    persona.photos.map((photo) => JSON.stringify({
      batchId: batch.id,
      catalogId: batch.catalogId,
      provider: batch.provider,
      model: batch.model,
      fallbackModel: batch.fallbackModel,
      size: batch.size,
      quality: batch.quality,
      imageFormat: batch.imageFormat,
      personaId: persona.personaId,
      displayName: persona.displayName,
      photoId: photo.photoId,
      position: photo.position,
      requestKind: photo.requestKind,
      dependsOnPhotoId: photo.dependsOnPhotoId,
      localPath: photo.localPath,
      prompt: photo.providerPrompt,
    }))
  ).join("\n")}\n`;
}

export async function generatePersonaImageBatch(batch, options = {}) {
  if (!allowedProviders.has(batch.provider)) {
    throw new Error(`Unsupported image provider: ${batch.provider}`);
  }
  const apiKey = options.apiKey ?? apiKeyForProvider(batch.provider);
  if (!apiKey) {
    throw new Error(apiKeyMissingMessage(batch.provider));
  }
  fs.mkdirSync(batch.outputDir, {recursive: true});

  const manifest = {
    schemaVersion: 1,
    batchId: batch.id,
    catalogId: batch.catalogId,
    provider: batch.provider,
    api: batch.api,
    model: batch.model,
    fallbackModel: batch.fallbackModel,
    size: batch.size,
    quality: batch.quality,
    imageFormat: batch.imageFormat,
    status: "running",
    generatedAt: new Date().toISOString(),
    outputs: [],
  };
  const manifestPath = path.join(batch.outputDir, `${batch.id}.manifest.json`);

  try {
    for (const persona of batch.personas) {
      const hero = persona.photos[0];
      for (const photo of persona.photos) {
        fs.mkdirSync(path.dirname(photo.localPath), {recursive: true});
        const inputPath = photo.requestKind === "edit" ? hero.localPath : null;
        if (typeof options.onProgress === "function") {
          options.onProgress({event: "start", persona, photo});
        }
        const result = await generateProviderImage({
          provider: batch.provider,
          apiKey,
          model: batch.model,
          fallbackModel: batch.fallbackModel,
          requestKind: photo.requestKind,
          prompt: photo.providerPrompt,
          inputPath,
          outputPath: photo.localPath,
          size: batch.size,
          quality: batch.quality,
          imageFormat: batch.imageFormat,
        });
        if (typeof options.onProgress === "function") {
          options.onProgress({event: "complete", persona, photo, result});
        }
        manifest.outputs.push({
          personaId: persona.personaId,
          displayName: persona.displayName,
          photoId: photo.photoId,
          position: photo.position,
          requestKind: photo.requestKind,
          model: result.model,
          requestId: result.requestId,
          mimeType: result.mimeType ?? null,
          localPath: photo.localPath,
          prompt: photo.providerPrompt,
          revisedPrompt: result.revisedPrompt ?? null,
          providerResponseText: result.providerResponseText ?? null,
        });
      }
    }
  } catch (error) {
    manifest.status = "failed";
    manifest.failedAt = new Date().toISOString();
    manifest.error = serializeGenerationError(error);
    fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
    error.manifestPath = manifestPath;
    throw error;
  }

  manifest.status = "complete";
  fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
  return {...manifest, manifestPath};
}

async function generateProviderImage(args) {
  if (args.provider === "openai") return generateOpenAiImage(args);
  if (args.provider === "gemini") return generateGeminiImage(args);
  throw new Error(`Unsupported image provider: ${args.provider}`);
}

async function generateOpenAiImage({
  apiKey,
  model,
  fallbackModel,
  requestKind,
  prompt,
  inputPath,
  outputPath,
  size,
  quality,
  imageFormat,
}) {
  try {
    return await requestOpenAiImage({
      apiKey,
      model,
      requestKind,
      prompt,
      inputPath,
      outputPath,
      size,
      quality,
      imageFormat,
    });
  } catch (error) {
    if (!fallbackModel || !shouldTryFallback(error)) throw error;
    return requestOpenAiImage({
      apiKey,
      model: fallbackModel,
      requestKind,
      prompt,
      inputPath,
      outputPath,
      size,
      quality,
      imageFormat,
    });
  }
}

async function requestOpenAiImage({
  apiKey,
  model,
  requestKind,
  prompt,
  inputPath,
  outputPath,
  size,
  quality,
  imageFormat,
}) {
  const response = requestKind === "edit" ?
    await postOpenAiImageEdit({
      apiKey,
      model,
      prompt,
      inputPath,
      size,
      quality,
      imageFormat,
    }) :
    await postOpenAiImageGeneration({
      apiKey,
      model,
      prompt,
      size,
      quality,
      imageFormat,
    });

  const data = await parseOpenAiJson(response);
  const imageBase64 = data?.data?.[0]?.b64_json;
  if (typeof imageBase64 !== "string" || imageBase64.length === 0) {
    throw new Error(`OpenAI image response did not include data[0].b64_json.`);
  }
  fs.writeFileSync(outputPath, Buffer.from(imageBase64, "base64"));
  return {
    model,
    requestId: response.headers.get("x-request-id") ?? null,
    revisedPrompt: data.data[0].revised_prompt ?? null,
  };
}

async function postOpenAiImageGeneration({
  apiKey,
  model,
  prompt,
  size,
  quality,
  imageFormat,
}) {
  return fetch("https://api.openai.com/v1/images/generations", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      prompt,
      n: 1,
      size,
      quality,
      output_format: imageFormat,
    }),
  });
}

async function postOpenAiImageEdit({
  apiKey,
  model,
  prompt,
  inputPath,
  size,
  quality,
  imageFormat,
}) {
  if (!inputPath || !fs.existsSync(inputPath)) {
    throw new Error(`Reference image does not exist: ${inputPath}`);
  }
  const form = new FormData();
  form.append("model", model);
  form.append("prompt", prompt);
  form.append("size", size);
  form.append("quality", quality);
  form.append("output_format", imageFormat);
  form.append(
    "image[]",
    new Blob([fs.readFileSync(inputPath)], {type: mimeTypeForFormat(imageFormat)}),
    path.basename(inputPath)
  );
  return fetch("https://api.openai.com/v1/images/edits", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
    },
    body: form,
  });
}

async function generateGeminiImage({
  apiKey,
  model,
  fallbackModel,
  requestKind,
  prompt,
  inputPath,
  outputPath,
  size,
}) {
  try {
    return await requestGeminiImage({
      apiKey,
      model,
      requestKind,
      prompt,
      inputPath,
      outputPath,
      size,
    });
  } catch (error) {
    if (!fallbackModel || !shouldTryFallback(error)) throw error;
    return requestGeminiImage({
      apiKey,
      model: fallbackModel,
      requestKind,
      prompt,
      inputPath,
      outputPath,
      size,
    });
  }
}

async function requestGeminiImage({
  apiKey,
  model,
  requestKind,
  prompt,
  inputPath,
  outputPath,
  size,
}) {
  const response = await postGeminiImageGeneration({
    apiKey,
    model,
    requestKind,
    prompt,
    inputPath,
    size,
  });
  const data = await parseProviderJson(response, "Gemini image request");
  const parts = data?.candidates?.[0]?.content?.parts ?? [];
  const imagePart = parts.find((part) =>
    part?.inlineData?.data || part?.inline_data?.data
  );
  const textParts = parts
    .map((part) => part?.text)
    .filter((text) => typeof text === "string" && text.trim().length > 0);
  const imageBase64 = imagePart?.inlineData?.data ?? imagePart?.inline_data?.data;
  const mimeType = imagePart?.inlineData?.mimeType ??
    imagePart?.inline_data?.mime_type ??
    null;
  if (typeof imageBase64 !== "string" || imageBase64.length === 0) {
    throw new Error("Gemini image response did not include inline image data.");
  }
  fs.writeFileSync(outputPath, Buffer.from(imageBase64, "base64"));
  return {
    model,
    requestId: response.headers.get("x-request-id") ??
      response.headers.get("x-goog-request-id") ??
      null,
    mimeType,
    providerResponseText: textParts.join("\n\n") || null,
  };
}

async function postGeminiImageGeneration({
  apiKey,
  model,
  requestKind,
  prompt,
  inputPath,
  size,
}) {
  const parts = [{text: prompt}];
  if (requestKind === "edit") {
    if (!inputPath || !fs.existsSync(inputPath)) {
      throw new Error(`Reference image does not exist: ${inputPath}`);
    }
    parts.push({
      inline_data: {
        mime_type: mimeTypeForPath(inputPath),
        data: fs.readFileSync(inputPath).toString("base64"),
      },
    });
  }
  const imageConfig = geminiImageConfigForSize(size);
  return fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`,
    {
      method: "POST",
      headers: {
        "x-goog-api-key": apiKey,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        contents: [{
          role: "user",
          parts,
        }],
        generationConfig: {
          responseModalities: ["TEXT", "IMAGE"],
          responseFormat: {
            image: imageConfig,
          },
        },
      }),
    }
  );
}

async function parseOpenAiJson(response) {
  return parseProviderJson(response, "OpenAI image request");
}

async function parseProviderJson(response, label) {
  const text = await response.text();
  let data = null;
  try {
    data = text ? JSON.parse(text) : null;
  } catch {
    data = null;
  }
  if (!response.ok) {
    const error = new Error(
      data?.error?.message ?? data?.error ?? `${label} failed with ${response.status}.`
    );
    error.status = response.status;
    error.code = data?.error?.code ?? data?.error?.status;
    error.type = data?.error?.type ?? data?.error?.status;
    throw error;
  }
  return data;
}

function buildPersonaImageRequests(persona, {
  outputDir,
  provider,
  model,
  fallbackModel,
  size,
  quality,
  imageFormat,
}) {
  const personaDir = path.join(outputDir, slugForPersona(persona));
  const sortedPhotos = persona.photos.slice().sort((a, b) => a.position - b.position);
  const heroPhoto = sortedPhotos[0];
  return {
    personaId: persona.id,
    displayName: persona.displayName,
    gender: persona.gender,
    citySlug: persona.citySlug,
    photos: sortedPhotos.map((photo) => {
      const requestKind = photo.position === 0 ? "generation" : "edit";
      const dependsOnPhotoId = requestKind === "edit" ? heroPhoto.id : null;
      return {
        personaId: persona.id,
        displayName: persona.displayName,
        photoId: photo.id,
        position: photo.position,
        requestKind,
        dependsOnPhotoId,
        provider,
        model,
        fallbackModel,
        size,
        quality,
        imageFormat,
        categoryId: photo.categoryId,
        activityId: photo.activityId,
        storagePath: photo.storagePath,
        thumbnailStoragePath: photo.thumbnailStoragePath,
        localPath: path.join(
          personaDir,
          `${String(photo.position + 1).padStart(2, "0")}-${photo.id}.${imageFormat}`
        ),
        providerPrompt: providerPromptForPhoto(persona, photo, requestKind),
      };
    }),
  };
}

function providerPromptForPhoto(persona, photo, requestKind) {
  const sharedInstructions = [
    "Photorealistic synthetic adult dating-app profile photo.",
    "The person must be attractive in a natural, believable way, not airbrushed.",
    "No brand logos, no readable text, no watermark, no celebrity resemblance.",
    "Avoid stock-photo staging, plastic skin, distorted hands, duplicated faces, or ambiguous subject identity.",
    `Persona continuity: ${persona.appearanceContinuityBrief}`,
    `Profile context: ${persona.demographicBrief}`,
  ];
  if (requestKind === "edit") {
    sharedInstructions.unshift(
      "Use the provided reference image only to preserve the same synthetic person's identity, face, age, skin tone, hair, height, build, and proportions while creating a new scene."
    );
  }
  return [
    photo.generationPrompt,
    `Scene: ${photo.scene}`,
    `Continuity: ${photo.continuityNotes}`,
    ...sharedInstructions,
  ].join(" ");
}

function validatePilotConfig(config) {
  if (!config || typeof config !== "object" || Array.isArray(config)) {
    throw new Error("Image generation pilot config must be a JSON object.");
  }
  if (config.schemaVersion !== 1) {
    throw new Error("Image generation pilot config schemaVersion must be 1.");
  }
  if (!Array.isArray(config.pilotPersonaIds) || config.pilotPersonaIds.length === 0) {
    throw new Error("Image generation pilot config requires pilotPersonaIds.");
  }
}

function shouldTryFallback(error) {
  const code = String(error?.code ?? "");
  const message = String(error?.message ?? "").toLowerCase();
  return [
    "model_not_found",
    "model_not_available",
    "invalid_model",
    "unsupported_model",
  ].includes(code) ||
    (Number(error?.status) === 404 && message.includes("model")) ||
    (Number(error?.status) === 400 &&
      message.includes("model") &&
      message.includes("not"));
}

function slugForPersona(persona) {
  return String(persona.displayName ?? persona.id)
    .trim()
    .toLowerCase()
    .replace(/['"]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function mimeTypeForFormat(format) {
  if (format === "png") return "image/png";
  if (format === "webp") return "image/webp";
  return "image/jpeg";
}

function mimeTypeForPath(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  if (ext === ".png") return "image/png";
  if (ext === ".webp") return "image/webp";
  return "image/jpeg";
}

function apiKeyForProvider(provider) {
  if (provider === "gemini") {
    return process.env.GEMINI_API_KEY ??
      process.env.GOOGLE_API_KEY ??
      process.env.GOOGLE_GENAI_API_KEY;
  }
  return process.env.OPENAI_API_KEY;
}

function apiKeyMissingMessage(provider) {
  if (provider === "gemini") {
    return "GEMINI_API_KEY, GOOGLE_API_KEY, or GOOGLE_GENAI_API_KEY is required to generate Gemini persona images.";
  }
  return "OPENAI_API_KEY is required to generate OpenAI persona images.";
}

function geminiImageConfigForSize(size) {
  const [width, height] = String(size).split("x").map((part) => Number(part));
  if (!Number.isFinite(width) || !Number.isFinite(height) || width <= 0 || height <= 0) {
    return {aspectRatio: "2:3", imageSize: "1K"};
  }
  const divisor = gcd(width, height);
  const ratio = `${width / divisor}:${height / divisor}`;
  const supportedRatios = new Set([
    "1:1",
    "1:4",
    "1:8",
    "2:3",
    "3:2",
    "3:4",
    "4:1",
    "4:3",
    "4:5",
    "5:4",
    "8:1",
    "9:16",
    "16:9",
    "21:9",
  ]);
  const maxDimension = Math.max(width, height);
  let imageSize = "1K";
  if (maxDimension <= 512) imageSize = "512";
  else if (maxDimension <= 1536) imageSize = "1K";
  else if (maxDimension <= 2048) imageSize = "2K";
  else imageSize = "4K";
  return {
    aspectRatio: supportedRatios.has(ratio) ? ratio : "2:3",
    imageSize,
  };
}

function gcd(a, b) {
  let x = Math.abs(a);
  let y = Math.abs(b);
  while (y) {
    const next = x % y;
    x = y;
    y = next;
  }
  return x || 1;
}

function serializeGenerationError(error) {
  return {
    message: error?.message ?? "Unknown image generation error.",
    status: error?.status ?? null,
    code: error?.code ?? null,
    type: error?.type ?? null,
  };
}

function main(argv) {
  const catalogPath = argv[0] ?? DEFAULT_PERSONA_CATALOG_PATH;
  const catalog = loadPersonaCatalog(catalogPath);
  const batch = buildPersonaImageGenerationBatch(catalog);
  process.stdout.write(formatPersonaImageGenerationBatchMarkdown(batch));
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  main(process.argv.slice(2));
}
