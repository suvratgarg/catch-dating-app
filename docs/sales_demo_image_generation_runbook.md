---
doc_id: sales_demo_image_generation_runbook
version: 0.1.0
updated: 2026-05-25
owner: demo_data
status: active
---

# Sales Demo Image Generation Runbook

This runbook is the mechanical operating guide for producing, reviewing,
organizing, uploading, and publishing high-quality synthetic profile photos for
sales-grade demo users. It is written so a lower-reasoning pass can do the
repetitive image work without re-deciding the data model.

## Scope

Use this workflow for subscription web UI generation, especially ChatGPT web,
when API billing or API keys are not available. The web UI path is acceptable for
manual asset production and review. It is not the long-term automated pipeline.

The first production scope is:

- `us-nyc-sales-personas-v1`: 24 personas, 4 photos each, 96 images.
- `india-core-sales-personas-v1`: planned reusable India core cohort, 36
  personas, 4 photos each, 144 images.

Do not create separate full persona catalogs for every Indian city at the
outset. Use city and event overlays for Indian demos, then reuse the India core
persona pool across rosters.

## Source Documents

Read these before starting a batch:

- `docs/sales_demo_seed_tracker.md`
- `docs/sales_demo_persona_cohorts.md`
- `docs/demo_data_seeding.md`
- `tool/demo/demo_seed/personas/photo_activity_taxonomy.json`
- `tool/demo/demo_seed/personas/photo_composition_index.json`
- the active persona catalog being generated

For NYC, the active catalog is:

```bash
tool/demo/demo_seed/personas/us_nyc_sales_personas.draft.json
```

## Non-Negotiable Data Model

Use the persona catalog as the source of truth. Do not invent one-off users in a
ChatGPT conversation.

For sales personas, use the persona id as the synthetic UID unless a catalog
explicitly defines a different `uid` field. For example:

```text
personaId: nyc_maya_shah_001
uid:       nyc_maya_shah_001
```

Upload profile photos to the same UID-owned Storage shape the app uses for real
profile photos:

```text
users/{uid}/photos/{position}_{photoId}.jpg
users/{uid}/photoThumbnails/{position}_{photoId}.jpg
```

Examples:

```text
users/nyc_maya_shah_001/photos/0_hero_portrait.jpg
users/nyc_maya_shah_001/photoThumbnails/0_hero_portrait.jpg
```

Seeded `users/{uid}` and `publicProfiles/{uid}` must include:

- `profilePhotos`: grouped photo records with `id`, `url`, `thumbnailUrl`,
  `storagePath`, `thumbnailStoragePath`, `promptId`, prompt title,
  `position`, and approved synthetic moderation metadata.
- complete profile prompts, height, date of birth, city, gender, and profile
  copy from the catalog.

## Local Artifact Layout

Keep all generated review assets under ignored `build/` output until they are
approved and uploaded.

```text
build/demo-persona-images-web/{catalogId}/
  manifest.json
  batch-01/
    {uid}/
      raw/
        0_hero_portrait.png
        1_sidewalk_coffee.png
      approved/
        0_hero_portrait.jpg
        1_sidewalk_coffee.jpg
      review.json
```

The manifest must record:

- catalog id, batch id, provider, source surface, generation date;
- persona id, UID, display name, gender, height, city;
- photo id, position, category, activity, prompt text, local raw path;
- approved local path, review status, rejection reason, storage path, thumbnail
  storage path, and upload status;
- generated chat URL or conversation label when available.

Use these review statuses:

```text
planned
generated
candidate
needs_regen
approved
uploaded
rejected
blocked
```

Only `approved` images can be uploaded. Only `uploaded` images can be referenced
by a live seed write.

## Preflight Commands

Run these before opening ChatGPT:

```bash
node tool/demo/demo_ops.mjs validate-persona-catalog \
  --persona-catalog tool/demo/demo_seed/personas/us_nyc_sales_personas.draft.json

node tool/demo/demo_ops.mjs persona-photo-plan \
  --persona-catalog tool/demo/demo_seed/personas/us_nyc_sales_personas.draft.json \
  --format markdown
```

For the ChatGPT web production pass, do not run the API generator unless the
user explicitly approves API spend.

Before generating, confirm the browser is signed into the user-approved paid
ChatGPT account. Do not store personal account identifiers, passwords, cookies,
or screenshots in the repo. Stop if ChatGPT is signed into an unknown account,
asks for billing, shows a usage-limit wall, or requires account recovery.

## Parallel Chat Strategy

Use one ChatGPT conversation per persona. Do not put multiple synthetic people
in the same generated image request, and do not use one conversation to generate
different people.

Each image request should ask for exactly one output image. If the UI returns a
grid, collage, or multiple people, reject the output and retry with a stricter
single-image prompt.

Work in four-person waves:

```text
Wave 1: personas 1-4
Wave 2: personas 5-8
Wave 3: personas 9-12
Wave 4: personas 13-16
Wave 5: personas 17-20
Wave 6: personas 21-24
```

Within each wave:

1. Open four ChatGPT conversations.
2. Label or track them as `Catch Demo: {displayName} ({uid})`.
3. Generate the hero portrait for all four personas.
4. Download and review all four hero portraits.
5. Only after a persona hero is accepted, generate that persona's photo 2 in
   the same conversation.
6. Repeat by photo position: all accepted photo 2s, then all photo 3s, then all
   photo 4s.

This gives parallelism without losing identity continuity.

## Prompt Protocol

Hero prompts create the identity. Later prompts preserve that identity.

Hero prompt template:

```text
Create one portrait-oriented photorealistic image for a synthetic adult dating-app profile. Do not create a grid or collage. Do not include readable text, brand logos, watermarks, or celebrity resemblance. The person should be attractive in a natural, believable way, not airbrushed or fashion-campaign styled.

Subject: {demographicBrief}. {appearanceContinuityBrief}

Scene: {photo.scene}

Use plausible proportions for {heightCm} cm. The image should look like a real high-quality dating-app profile photo, not a stock campaign.

Continuity brief for later images: keep this exact same synthetic person's face shape, skin tone, hair, height, and body proportions consistent across later photos.
```

Follow-up prompt template:

```text
Using the exact same synthetic person from the previous image as the identity reference, create one new portrait-oriented photorealistic dating-app profile image. Preserve the same face, age, skin tone, hair, height, body proportions, and natural style. Do not include readable text, brand logos, watermarks, or celebrity resemblance.

Scene: {photo.scene}

This should look like a normal dating-app profile photo in a different outfit and setting, not a model shoot.
```

If the identity drifts, retry once in the same conversation with a stricter
continuity prompt. If it drifts again, mark the photo `needs_regen` and continue
with the rest of the wave.

## Visual Review Gate

Reject or regenerate when any of these are true:

- the person does not match the persona's name, gender, demographic brief, age,
  or height;
- the image looks like a different person from the hero;
- the person is not attractive enough for a high-fidelity sales demo;
- the image looks like an ad, influencer shoot, fashion campaign, or stock
  photo;
- there is readable text, brand/logo content, a generated-image marker, or a
  watermark;
- there are visible face, hand, limb, background, or object artifacts;
- the scene contradicts the catalog category or activity;
- running or fitness dominates the set beyond the composition index;
- group photos make it unclear which person owns the profile.

Approve only when the full set reads like one coherent, high-quality dating-app
profile.

## Download And Organize

After each accepted generation:

1. Use the ChatGPT image download control.
2. Find the newest downloaded image in `~/Downloads`.
3. Copy it into the correct raw folder.
4. Rename it deterministically as `{position}_{photoId}.{ext}`.
5. Record the source download path and raw path in the manifest.
6. View the local image before marking it `candidate` or `approved`.

Do not leave images identified only by generic ChatGPT download names.

## Normalize Before Upload

Normalize approved full-size images to app-like profile-photo constraints:

- output format: JPEG;
- maximum width: 1600 px;
- maximum height: 2133 px;
- preferred display crop: 3:4 portrait;
- quality: 85;
- maximum upload size: under 8 MB;
- preserve enough vertical room for swipe/profile UI crops.

Use `sips` to verify dimensions after normalization:

```bash
sips -g pixelWidth -g pixelHeight build/demo-persona-images-web/{catalogId}/batch-01/{uid}/approved/*.jpg
```

If a generated image cannot be cropped cleanly to the app aspect without losing
face/body context, regenerate it instead of forcing a bad crop.

## Upload Workflow

The upload step must be tool-driven and dry-run-first. Do not upload sales demo
profile images by hand through the Firebase console.

Required command shape:

```bash
node tool/demo/demo_ops.mjs persona-assets-upload \
  --env dev \
  --persona-catalog tool/demo/demo_seed/personas/us_nyc_sales_personas.draft.json \
  --asset-manifest build/demo-persona-images-web/us-nyc-sales-personas-v1/manifest.json
```

Apply only after the dry run is correct:

```bash
node tool/demo/demo_ops.mjs persona-assets-upload \
  --env dev \
  --persona-catalog tool/demo/demo_seed/personas/us_nyc_sales_personas.draft.json \
  --asset-manifest build/demo-persona-images-web/us-nyc-sales-personas-v1/manifest.json \
  --apply
```

Production uploads require explicit user approval and `--allow-prod`.

The upload tool should:

1. Resolve the Firebase project and default Storage bucket for `--env`.
2. Read only `approved` images from the asset manifest.
3. Derive UID-owned Storage paths from persona id and photo id.
4. Generate Firebase Storage download tokens for full-size images.
5. Pre-stage or update the `users/{uid}` document with `profilePhotos` entries
   that include the full-size URL, storage path, expected thumbnail storage
   path, prompt id, position, and synthetic approved moderation metadata.
6. Upload the full-size image bytes to `users/{uid}/photos/{position}_{photoId}.jpg`
   with `image/jpeg` content type and the generated download token.
7. Let the deployed `generateProfilePhotoThumbnail` trigger create
   `users/{uid}/photoThumbnails/{position}_{photoId}.jpg`.
8. Poll Firestore until `users/{uid}.profilePhotos[position].thumbnailUrl`
   points at the generated thumbnail URL.
9. Confirm `publicProfiles/{uid}` received the projected grouped photos and
   thumbnail arrays.
10. Patch the persona catalog photo entries to `assetStatus: uploaded` with the
    final URL and storage path values.
11. Write an upload receipt under `build/demo-persona-images-web/{catalogId}/`.

If the thumbnail trigger does not run in the target environment, use the
existing thumbnail backfill path or add an admin thumbnail fallback that writes
the exact same thumbnail path and then updates `users/{uid}` and
`publicProfiles/{uid}`.

Current Storage buckets:

```text
dev:     catchdates-dev.firebasestorage.app
staging: catchdates-staging.firebasestorage.app
prod:    catch-dating-app-64e51.firebasestorage.app
```

## Post-Upload Validation

After upload, run:

```bash
node tool/demo/demo_ops.mjs validate-persona-catalog \
  --persona-catalog tool/demo/demo_seed/personas/us_nyc_sales_personas.draft.json \
  --require-published-assets
```

Then verify:

- every `url` and `thumbnailUrl` returns an image;
- every `storagePath` starts with `users/{uid}/photos/`;
- every `thumbnailStoragePath` starts with `users/{uid}/photoThumbnails/`;
- `users/{uid}.profilePhotos` has contiguous positions starting at 0;
- `publicProfiles/{uid}` has the same visible photo order;
- app browse, roster, public profile, and host attendance surfaces load the
  thumbnails without broken images.

## Roster Reuse Policy

Reuse the same high-quality synthetic people across demos. Do not generate a
fresh user set for every event.

Different events should not have the exact same roster in the exact same order.
Use overlapping subsets:

- small event: 10-14 attendees;
- normal host demo: 20-24 attendees;
- larger India demo: 24-32 attendees from the India core cohort.

When the same persona appears in multiple events, keep their profile unchanged.
Only event participation state, compatibility answers, check-in state, feedback,
and assignments should vary by event.

## Stop Conditions

Stop and report before continuing if:

- ChatGPT shows a usage-limit or policy warning;
- the browser asks for payment, upgrade, CAPTCHA, or account recovery;
- generated images repeatedly fail identity continuity for a cohort;
- upload tooling is missing or cannot dry-run safely;
- a target environment cannot run thumbnail generation or public profile
  projection;
- production upload would be required and the user has not explicitly approved
  it.
