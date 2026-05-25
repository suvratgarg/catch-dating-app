---
doc_id: sales_demo_persona_cohorts
version: 0.1.0
updated: 2026-05-25
owner: demo_data
status: active
---

# Sales Demo Persona Cohorts

This document owns the cohort-level plan for sales-grade synthetic people. The
persona catalogs own individual profile fields, photo prompts, and continuity
notes. The image-generation runbook owns the mechanical production workflow.

## Cohort Decisions

- Do not generate a complete new synthetic user library for every city at the
  outset.
- Build one high-quality New York cohort for the first U.S. host sales demo.
- Build one slightly larger India core cohort that can be reused across Indian
  demo events and city overlays.
- Reuse the same synthetic people across demos, but avoid showing the exact same
  roster in the exact same order for every event.
- Keep each persona's profile stable everywhere they appear. Event-specific
  documents should vary participation, answers, assignments, feedback, and
  check-in state, not identity.

## Active Cohorts

| Cohort | Catalog | Size | Photos | Status | Primary Use |
|---|---|---:|---:|---|---|
| `us-nyc-sales-personas-v1` | `tool/demo/demo_seed/personas/us_nyc_sales_personas.draft.json` | 24 | 96 | Draft, image generation pending | First U.S. host sales demo, browse overflow, event roster, public-profile QA. |
| `india-core-sales-personas-v1` | `tool/demo/demo_seed/personas/india_core_sales_personas.draft.json` | 36 planned | 144 planned | Planned | Reusable India demo/beta persona pool across Mumbai, Delhi NCR, Bengaluru, Pune, Hyderabad, Indore, and future Indian city overlays. |

## Individual Source Of Truth

Do not create separate markdown biographies for each synthetic user. Individual
profile documentation belongs in the persona catalog so the seeder, validator,
image prompts, and upload tooling all read the same source of truth.

Each persona entry must include:

- stable persona id, used as UID unless an explicit `uid` override exists;
- name, gender, pronouns, date of birth, height, country, city slug, and city
  label;
- occupation, company when useful, demographic brief, appearance-continuity
  brief, personality brief, and market-fit brief;
- complete profile prompts;
- four required photo slots with category, activity, scene, generation prompt,
  prompt id, position, continuity notes, asset status, URL, storage path,
  thumbnail URL, and thumbnail storage path;
- no ethnicity, name, gender, age, height, or city contradictions across copy
  and images.

The local image manifest created during generation is the individual production
log. It should record prompt text, download paths, review status, rejection
reason, dimensions, approved path, upload status, and final Storage paths.

## New York Cohort

Use the New York cohort first. It is already large enough for one 20-person
host sales roster, visible browse inventory, and a few alternate event rosters.

| Wave | Personas |
|---|---|
| 1 | Maya Shah, Jordan Ellis, Sofia Martinez, Ethan Brooks |
| 2 | Aisha Williams, Daniel Kim, Priya Desai, Marcus Chen |
| 3 | Chloe Bennett, Noah Patel, Olivia Nguyen, Caleb Johnson |
| 4 | Emma Rodriguez, Liam O'Connor, Nia Okafor, Arjun Mehta |
| 5 | Grace Liu, Miles Anderson, Hannah Cohen, Andre Baptiste |
| 6 | Isabella Romano, Samir Khan, Taylor Reed, Victor Alvarez |

Generate one ChatGPT conversation per persona and work four people at a time by
wave. Within a wave, generate photo position 0 for all four people, review the
four outputs, then continue to position 1 only for accepted identities. Repeat
through position 3.

The New York cohort should feel like a realistic dense social-dating audience:
polished, attractive, broad in background, plausible for NYC, and not only
fitness-oriented. It can include running photos, but running remains one minority
activity inside a wider dating-app profile mix.

## India Core Cohort

The first India pass should be a reusable core, not a separate full catalog per
city. City-specific event docs can provide local venues, GPS pins, host copy,
and roster subsets while drawing from the same people.

Initial target:

- 36 personas, four photos each;
- balanced men and women unless the product target or user feedback changes the
  mix;
- high-quality, attractive, internally consistent Indian urban profiles;
- photos that can plausibly work across multiple major Indian cities without
  making every persona look tied to one landmark or one event.

Preferred scene vocabulary for India:

- clear solo portraits in cafes, parks, rooftops, galleries, and city streets;
- social dining, dessert, coffee, supper club, or low-key nightlife;
- culture and creative contexts such as galleries, music, markets, books,
  design, startup/community events, or travel weekends;
- active lifestyle as a minority category: badminton, pickleball, tennis,
  football, cricket nets, yoga, gym, cycling, walking, hiking, or occasional
  running;
- friends/group photos only when the profile owner is obvious.

Avoid making the India core feel like travel stock photography. The profiles
should look like real dating-app profiles from high-intent city users.

## Roster Reuse Rules

Use overlapping subsets rather than one fixed roster:

| Event Shape | Roster Size | Reuse Guidance |
|---|---:|---|
| Small invite-only or approval event | 10-14 | Select one coherent subset; include 2-4 people from another event if useful. |
| Normal host sales demo | 20-24 | Use most of the New York cohort or 20-24 from the India core. |
| Larger India demo | 24-32 | Draw from the India core and rotate enough people to avoid a cloned roster. |
| Browse/investor/safety/payment demos | Variable | Reuse canonical personas and assets; do not create lower-quality substitutes. |

When a host demo needs multiple events, keep 30-60% roster overlap between
events and vary attendance states, compatibility responses, waitlist position,
feedback, and event-success assignments.

## City Overlay Policy

City overlays may add:

- venue catalog entries and exact coordinates;
- event titles, descriptions, capacity, pricing, booking policy, and host copy;
- local meeting-point instructions;
- roster subset and attendance state;
- event-success plan, compatibility questions, assignments, feedback, and
  scorecard state.

City overlays should not add:

- one-off users that bypass the canonical persona catalog;
- new profile photos that are not reviewed and uploaded through the runbook;
- local name/photo substitutions that break identity continuity;
- exact same roster cloned across all events.

## Read Before Generating

Before any image batch, read:

- `docs/sales_demo_image_generation_runbook.md`;
- `docs/sales_demo_seed_tracker.md`;
- the active persona catalog;
- `tool/demo/demo_seed/personas/photo_activity_taxonomy.json`;
- `tool/demo/demo_seed/personas/photo_composition_index.json`.

Before any upload or live seed write, confirm that the upload tooling writes
UID-owned profile photo paths under `users/{uid}/photos/` and that the live seed
requires uploaded assets.
