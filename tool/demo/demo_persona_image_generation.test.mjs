import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  buildPersonaImageGenerationBatch,
  formatPersonaImageGenerationBatchJsonl,
  formatPersonaImageGenerationBatchMarkdown,
  generatePersonaImageBatch,
  loadPersonaImagePilotConfig,
} from "./demo_persona_image_generation.mjs";
import {loadPersonaCatalog} from "./demo_persona_catalog.mjs";

test("image generation pilot builds hero-first reference batch", () => {
  const catalog = loadPersonaCatalog(
    "tool/demo/demo_seed/personas/us_nyc_sales_personas.draft.json"
  );
  const pilotConfig = loadPersonaImagePilotConfig(
    "tool/demo/demo_seed/personas/image_generation_pilot.json"
  );

  const batch = buildPersonaImageGenerationBatch(catalog, {pilotConfig});

  assert.equal(batch.provider, "openai");
  assert.equal(batch.model, "gpt-image-2");
  assert.equal(batch.fallbackModel, "gpt-image-1.5");
  assert.equal(batch.personaCount, 3);
  assert.equal(batch.photoCount, 12);
  assert.deepEqual(
    batch.personas.map((persona) => persona.personaId),
    ["nyc_maya_shah_001", "nyc_jordan_ellis_002", "nyc_sofia_martinez_003"]
  );

  for (const persona of batch.personas) {
    assert.equal(persona.photos[0].requestKind, "generation");
    assert.equal(persona.photos[0].dependsOnPhotoId, null);
    for (const photo of persona.photos.slice(1)) {
      assert.equal(photo.requestKind, "edit");
      assert.equal(photo.dependsOnPhotoId, persona.photos[0].photoId);
      assert.match(photo.providerPrompt, /provided reference image/);
    }
  }
});

test("image generation batch supports explicit persona selection", () => {
  const catalog = loadPersonaCatalog(
    "tool/demo/demo_seed/personas/us_nyc_sales_personas.draft.json"
  );

  const batch = buildPersonaImageGenerationBatch(catalog, {
    personaIds: ["nyc_taylor_reed_023"],
    model: "gpt-image-1.5",
    imageFormat: "png",
    outputDir: "build/test-persona-images",
  });

  assert.equal(batch.personaCount, 1);
  assert.equal(batch.photoCount, 4);
  assert.equal(batch.model, "gpt-image-1.5");
  assert.equal(batch.imageFormat, "png");
  assert.equal(batch.personas[0].displayName, "Taylor Reed");
  assert.match(batch.personas[0].photos[0].localPath, /taylor-reed\/01-hero_dumbo\.png$/);
});

test("gemini image generation batch uses Nano Banana Pro defaults", () => {
  const catalog = loadPersonaCatalog(
    "tool/demo/demo_seed/personas/us_nyc_sales_personas.draft.json"
  );

  const batch = buildPersonaImageGenerationBatch(catalog, {
    provider: "gemini",
    personaIds: ["nyc_maya_shah_001"],
    outputDir: "build/test-gemini-persona-images",
  });

  assert.equal(batch.provider, "gemini");
  assert.equal(batch.api, "gemini-generate-content");
  assert.equal(batch.model, "gemini-3-pro-image-preview");
  assert.equal(batch.fallbackModel, "gemini-3.1-flash-image-preview");
  assert.equal(batch.imageFormat, "png");
  assert.match(batch.personas[0].photos[0].localPath, /maya-shah\/01-hero_portrait\.png$/);
});

test("image generation batch renders markdown and jsonl review outputs", () => {
  const catalog = loadPersonaCatalog(
    "tool/demo/demo_seed/personas/us_nyc_sales_personas.draft.json"
  );
  const batch = buildPersonaImageGenerationBatch(catalog, {
    personaIds: ["nyc_maya_shah_001"],
  });

  const markdown = formatPersonaImageGenerationBatchMarkdown(batch);
  assert.match(markdown, /^# Persona Image Generation Batch/);
  assert.match(markdown, /## Maya Shah/);
  assert.match(markdown, /Reference strategy: hero-only/);

  const rows = formatPersonaImageGenerationBatchJsonl(batch).trim().split("\n")
    .map((line) => JSON.parse(line));
  assert.equal(rows.length, 4);
  assert.equal(rows[0].requestKind, "generation");
  assert.equal(rows[1].dependsOnPhotoId, "hero_portrait");
});

test("image generation batch rejects unknown personas", () => {
  const catalog = loadPersonaCatalog(
    "tool/demo/demo_seed/personas/us_nyc_sales_personas.draft.json"
  );

  assert.throws(
    () => buildPersonaImageGenerationBatch(catalog, {personaIds: ["unknown_persona"]}),
    /Unknown persona id/
  );
});

test("image generation does not fallback for billing errors", async () => {
  const catalog = loadPersonaCatalog(
    "tool/demo/demo_seed/personas/us_nyc_sales_personas.draft.json"
  );
  const outputDir = fs.mkdtempSync(path.join(os.tmpdir(), "catch-persona-images-"));
  const batch = buildPersonaImageGenerationBatch(catalog, {
    personaIds: ["nyc_maya_shah_001"],
    outputDir,
  });
  let requestCount = 0;
  const originalFetch = globalThis.fetch;
  globalThis.fetch = async () => {
    requestCount += 1;
    return new Response(JSON.stringify({
      error: {
        message: "Billing hard limit has been reached.",
        code: "billing_hard_limit_reached",
        type: "billing_limit_user_error",
      },
    }), {status: 400});
  };

  try {
    await assert.rejects(
      () => generatePersonaImageBatch(batch, {apiKey: "test-key"}),
      /Billing hard limit/
    );
    assert.equal(requestCount, 1);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("gemini image generation sends hero and reference edit requests", async () => {
  const catalog = loadPersonaCatalog(
    "tool/demo/demo_seed/personas/us_nyc_sales_personas.draft.json"
  );
  const outputDir = fs.mkdtempSync(path.join(os.tmpdir(), "catch-gemini-images-"));
  const batch = buildPersonaImageGenerationBatch(catalog, {
    provider: "gemini",
    personaIds: ["nyc_maya_shah_001"],
    outputDir,
  });
  const requests = [];
  const originalFetch = globalThis.fetch;
  globalThis.fetch = async (url, options) => {
    requests.push({url: String(url), body: JSON.parse(options.body)});
    return new Response(JSON.stringify({
      candidates: [{
        content: {
          parts: [{
            inlineData: {
              mimeType: "image/png",
              data: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADElEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
            },
          }],
        },
      }],
    }), {status: 200});
  };

  try {
    const manifest = await generatePersonaImageBatch(batch, {apiKey: "gemini-key"});
    assert.equal(manifest.outputs.length, 4);
    assert.equal(requests.length, 4);
    assert.match(requests[0].url, /gemini-3-pro-image-preview:generateContent/);
    assert.equal(
      requests[0].body.generationConfig.responseFormat.image.aspectRatio,
      "2:3"
    );
    assert.equal(
      requests[0].body.generationConfig.responseFormat.image.imageSize,
      "1K"
    );
    assert.equal(requests[0].body.contents[0].parts.length, 1);
    assert.equal(requests[1].body.contents[0].parts.length, 2);
    assert.equal(requests[1].body.contents[0].parts[1].inline_data.mime_type, "image/png");
  } finally {
    globalThis.fetch = originalFetch;
  }
});
