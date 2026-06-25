import { mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, '..');

const args = parseArgs(process.argv.slice(2));
const configPath = path.resolve(root, args.config ?? 'config/mumbai.weekly-guide.config.json');
const candidatesPath = path.resolve(root, args.candidates ?? 'data/mumbai.sample.events.json');
const decisionsPath = args.decisions ? path.resolve(process.cwd(), args.decisions) : null;
const week = args.week ?? new Date().toISOString().slice(0, 10);
const tone = args.tone ?? 'both';
const runLabel = args['run-label'] ?? (decisionsPath ? `${week}-with-decisions` : week);

const config = JSON.parse(await readFile(configPath, 'utf8'));
const candidatesFile = JSON.parse(await readFile(candidatesPath, 'utf8'));
const decisionsFile = decisionsPath ? JSON.parse(await readFile(decisionsPath, 'utf8')) : null;

const weekStart = parseDate(week);
const weekEnd = addDays(weekStart, config.cadence.lookaheadDays ?? 7);
const outputDir = path.join(root, 'generated', config.city.id, runLabel);
await mkdir(outputDir, { recursive: true });

const sourceEvents = applyDecisions(candidatesFile.events, decisionsFile);

const candidates = sourceEvents
  .filter((event) => event.reviewState !== 'rejected')
  .filter((event) => overlapsWeek(event, weekStart, weekEnd))
  .map((event) => ({
    ...event,
    score: scoreEvent(event, config),
    warnings: warningsFor(event, config),
  }))
  .sort((a, b) => b.score - a.score)
  .slice(0, config.limits.candidatePool ?? 25);

const selected = balanceCategories(candidates, config).slice(0, config.limits.carouselSlots ?? 7);
const tones = tone === 'both' ? config.contentStrategy.toneVariants : [tone];

await writeFile(
  path.join(outputDir, 'run_manifest.json'),
  `${JSON.stringify(buildManifest({ config, candidates, selected, week, weekEnd }), null, 2)}\n`,
);

await writeFile(
  path.join(outputDir, 'crawl_plan.md'),
  renderCrawlPlan(config, week),
);

await writeFile(
  path.join(outputDir, 'review_queue.md'),
  renderReviewQueue({ config, selected, week, weekEnd }),
);

for (const variant of tones) {
  const packet = buildCarouselPacket({ config, selected, tone: variant, week, weekEnd });
  await writeFile(
    path.join(outputDir, `carousel.${variant}.json`),
    `${JSON.stringify(packet, null, 2)}\n`,
  );
  await writeFile(
    path.join(outputDir, `carousel.${variant}.md`),
    renderCarouselMarkdown(packet),
  );
  await writeFile(
    path.join(outputDir, `caption.${variant}.txt`),
    renderCaption(packet),
  );
}

console.log(`Weekly guide draft generated: ${outputDir}`);
console.log(`Candidates reviewed: ${candidates.length}`);
console.log(`Carousel slots drafted: ${selected.length}`);
console.log(`Tone variants: ${tones.join(', ')}`);
if (decisionsPath) {
  console.log(`Review decisions applied: ${decisionsPath}`);
}

function parseArgs(rawArgs) {
  const parsed = {};
  for (let index = 0; index < rawArgs.length; index += 1) {
    const arg = rawArgs[index];
    if (!arg.startsWith('--')) {
      continue;
    }
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

function applyDecisions(events, decisionsFile) {
  if (!decisionsFile) {
    return events;
  }

  const decisionsByEventId = new Map(
    (decisionsFile.decisions ?? []).map((decision) => [decision.eventId, decision]),
  );

  return events.map((event) => {
    const decision = decisionsByEventId.get(event.id);
    if (!decision) {
      return event;
    }

    return {
      ...event,
      reviewState: decision.reviewState ?? event.reviewState,
      editorNotes: decision.editorNotes ?? event.editorNotes,
      decisionApplied: true,
    };
  });
}

function formatDate(date) {
  return date.toISOString().slice(0, 10);
}

function overlapsWeek(event, weekStart, weekEnd) {
  const start = parseDate(event.startDate);
  const end = event.endDate ? parseDate(event.endDate) : start;
  return start <= weekEnd && end >= weekStart;
}

function scoreEvent(event, config) {
  const weights = config.rankingWeights;
  const scores = event.scores ?? {};
  let total = 0;

  for (const [key, weight] of Object.entries(weights)) {
    total += (Number(scores[key]) || 0) * weight;
  }

  if (event.requiresVerification) {
    total += config.penalties.requiresVerification ?? 0;
  }
  if (!event.price || event.price === 'TBD') {
    total += config.penalties.missingPrice ?? 0;
  }
  if (!event.sourceUrl) {
    total += config.penalties.missingSourceUrl ?? 0;
  }
  if ((event.city && event.city !== config.city.id) || event.nonMumbai) {
    total += config.penalties.nonMumbai ?? -5;
  }

  return Number(total.toFixed(2));
}

function warningsFor(event) {
  const warnings = [];
  if (event.sampleOnly) {
    warnings.push('sample-only candidate');
  }
  if (event.requiresVerification) {
    warnings.push('requires verification');
  }
  if (!event.sourceUrl) {
    warnings.push('missing source URL');
  }
  if (!event.price || event.price === 'TBD') {
    warnings.push('missing price');
  }
  if (!event.explicitSinglesEvent) {
    warnings.push('not explicitly singles-only');
  }
  return warnings;
}

function balanceCategories(events, config) {
  const targets = config.contentStrategy.categoryMixTargets ?? {};
  const selected = [];
  const selectedIds = new Set();

  for (const [category, count] of Object.entries(targets)) {
    const matching = events.filter((event) => event.category === category);
    for (const event of matching.slice(0, count)) {
      if (!selectedIds.has(event.id)) {
        selected.push(event);
        selectedIds.add(event.id);
      }
    }
  }

  for (const event of events) {
    if (!selectedIds.has(event.id)) {
      selected.push(event);
      selectedIds.add(event.id);
    }
  }

  return selected;
}

function buildManifest({ config, candidates, selected, week, weekEnd }) {
  return {
    program: config.program,
    city: config.city,
    weekStart: week,
    weekEnd: formatDate(weekEnd),
    publishState: 'internal_draft_only',
    integrationBoundary: {
      app: 'not connected',
      website: 'not connected',
      firestore: 'not connected',
      instagramPublishing: 'not connected',
    },
    sourcePolicy: {
      instagram: 'manual reference only; no unofficial scraping',
      publicPublishing: 'requires human approval and source verification',
    },
    decisionsApplied: Boolean(decisionsFile),
    counts: {
      candidatesInQueue: candidates.length,
      carouselSlotsDrafted: selected.length,
      approvedSlots: selected.filter((event) => event.reviewState === 'approved').length,
    },
    sourceIds: config.sources.map((source) => source.id),
    weeklySearchIds: config.weeklySearches.map((search) => search.id),
    selectedEventIds: selected.map((event) => event.id),
  };
}

function renderCrawlPlan(config, week) {
  const sourceLines = config.sources.map((source) => {
    const itemLines = (source.items ?? [])
      .map((item) => `  - ${item.label}: ${item.url}`)
      .join('\n');
    return [
      `## ${source.id}`,
      ``,
      `Type: ${source.type}`,
      `Status: ${source.status}`,
      `Allowed use: ${source.allowedUse ?? 'TBD'}`,
      itemLines ? `\n${itemLines}` : '',
    ].filter(Boolean).join('\n');
  });

  const searchLines = config.weeklySearches
    .map((search) => `- ${search.query}\n  Intent: ${search.intent}`)
    .join('\n');

  return `# Weekly Crawl Plan: ${config.city.label} ${week}\n\nThis is a research plan, not an automated publishing run.\n\n## Policy\n\n- Use source URLs only where permitted by source terms and robots policy.\n- Treat Instagram as manual-reference only unless using an approved official API flow.\n- Save citations for every public event detail.\n- Do not publish without human approval.\n\n${sourceLines.join('\n\n')}\n\n## Weekly Searches\n\n${searchLines}\n`;
}

function renderReviewQueue({ config, selected, week, weekEnd }) {
  const rows = selected.map((event, index) => [
    index + 1,
    event.title,
    event.category,
    event.neighborhood,
    event.startDate === event.endDate || !event.endDate ? event.startDate : `${event.startDate} to ${event.endDate}`,
    event.reviewState,
    event.score,
    event.warnings.join('; '),
    event.editorNotes ?? '',
  ]);

  const table = [
    '| Slot | Event | Category | Area | Date | Review | Score | Warnings | Editor notes |',
    '| ---: | --- | --- | --- | --- | --- | ---: | --- | --- |',
    ...rows.map((row) => `| ${row.join(' | ')} |`),
  ].join('\n');

  return `# Review Queue: ${config.city.label} ${week} to ${formatDate(weekEnd)}\n\nPublic publishing should use approved events only. Draft and needs_changes items are for editorial review.\n\n${table}\n`;
}

function buildCarouselPacket({ config, selected, tone, week, weekEnd }) {
  const slots = selected.map((event, index) => buildEventSlide(event, index + 2, tone));
  const cover = buildCoverSlide(config, tone, week, weekEnd, selected.length);
  const cta = buildCtaSlide(config, tone, selected);

  return {
    program: config.program,
    city: config.city,
    tone,
    weekStart: week,
    weekEnd: formatDate(weekEnd),
    status: 'internal_draft_only',
    publishReadiness: selected.every((event) => event.reviewState === 'approved' && !event.requiresVerification)
      ? 'ready_for_final_editorial_review'
      : 'not_publish_ready',
    slides: [
      cover,
      ...slots,
      cta,
    ],
  };
}

function buildCoverSlide(config, tone, week, weekEnd, count) {
  const isSinglesSocial = tone === 'singles-social';
  return {
    slide: 1,
    type: 'cover',
    headline: isSinglesSocial
      ? `${config.city.label} singles social events`
      : `${config.city.label} events that are singles-friendly`,
    eyebrow: `${config.cadence.weeklyLabel} / ${week} to ${formatDate(weekEnd)}`,
    subhead: isSinglesSocial
      ? `${count} ways to show up offline`
      : 'Go solo. Bring a friend. Meet people offline.',
    designNotes: [
      'Off-white paper background',
      'Large editorial image crop',
      'Ink headline with one activity pigment accent',
      'Small mono source/review label',
    ],
  };
}

function buildEventSlide(event, slideNumber, tone) {
  const singlesQualifier = event.explicitSinglesEvent
    ? 'Singles social'
    : tone === 'singles-social'
      ? 'Singles-friendly, not singles-only'
      : 'Singles-friendly';

  return {
    slide: slideNumber,
    type: 'event',
    eventId: event.id,
    headline: event.title,
    meta: [
      event.neighborhood,
      event.startDate === event.endDate || !event.endDate ? event.startDate : `${event.startDate} to ${event.endDate}`,
      event.time,
      event.price,
    ].filter(Boolean),
    category: event.category,
    qualifier: singlesQualifier,
    body: tone === 'singles-social' && event.explicitSinglesEvent
      ? event.publicDescription
      : event.whySinglesFriendly,
    reviewState: event.reviewState,
    sourceLabel: event.sourceLabel,
    sourceUrl: event.sourceUrl,
    editorNotes: event.editorNotes,
    warnings: event.warnings,
    imageBrief: imageBriefFor(event),
  };
}

function imageBriefFor(event) {
  return `Warm desaturated editorial image for ${event.category} event in ${event.neighborhood}; no real venue logo unless licensed; leave calm negative space for type.`;
}

function buildCtaSlide(config, tone, selected) {
  const needsReview = selected.some((event) => event.reviewState !== 'approved' || event.requiresVerification);
  return {
    slide: selected.length + 2,
    type: 'cta',
    headline: tone === 'singles-social'
      ? 'Want more social plans in Mumbai?'
      : 'Want the full weekly list?',
    primaryCta: config.ctas.app_waitlist.label,
    secondaryCta: config.ctas.host_submission.label,
    body: 'Catch is building a better way to find social events and meet people offline.',
    reviewNote: needsReview
      ? 'Internal draft: verify and approve events before publishing.'
      : 'Reviewed events only.',
  };
}

function renderCarouselMarkdown(packet) {
  const slides = packet.slides.map((slide) => {
    if (slide.type === 'cover') {
      return [
        `## Slide ${slide.slide}: Cover`,
        ``,
        `Eyebrow: ${slide.eyebrow}`,
        `Headline: ${slide.headline}`,
        `Subhead: ${slide.subhead}`,
        `Design notes: ${slide.designNotes.join('; ')}`,
      ].join('\n');
    }

    if (slide.type === 'cta') {
      return [
        `## Slide ${slide.slide}: CTA`,
        ``,
        `Headline: ${slide.headline}`,
        `Body: ${slide.body}`,
        `Primary CTA: ${slide.primaryCta}`,
        `Secondary CTA: ${slide.secondaryCta}`,
        `Review note: ${slide.reviewNote}`,
      ].join('\n');
    }

    return [
      `## Slide ${slide.slide}: ${slide.headline}`,
      ``,
      `Category: ${slide.category}`,
      `Meta: ${slide.meta.join(' / ')}`,
      `Qualifier: ${slide.qualifier}`,
      `Body: ${slide.body}`,
      `Review: ${slide.reviewState}`,
      slide.editorNotes ? `Editor notes: ${slide.editorNotes}` : null,
      `Source: ${slide.sourceLabel}${slide.sourceUrl ? ` (${slide.sourceUrl})` : ''}`,
      `Warnings: ${slide.warnings.join('; ') || 'none'}`,
      `Image brief: ${slide.imageBrief}`,
    ].filter(Boolean).join('\n');
  });

  return `# Carousel Draft: ${packet.city.label} / ${packet.tone}\n\nStatus: ${packet.status}\nPublish readiness: ${packet.publishReadiness}\n\n${slides.join('\n\n')}\n`;
}

function renderCaption(packet) {
  const isSinglesSocial = packet.tone === 'singles-social';
  const title = isSinglesSocial
    ? `${packet.city.label} singles social events this week`
    : `${packet.city.label} events that are singles-friendly this week`;

  const eventLines = packet.slides
    .filter((slide) => slide.type === 'event')
    .map((slide) => `- ${slide.headline}: ${slide.meta.join(', ')}`);

  return [
    title,
    '',
    isSinglesSocial
      ? 'A draft list for people who want to show up offline and meet new people.'
      : 'A draft list for people who want plans that are easy to attend solo, with a friend, or with a small group.',
    '',
    ...eventLines,
    '',
    `${packet.slides.at(-1).primaryCta}.`,
    `${packet.slides.at(-1).secondaryCta}.`,
    '',
    'Internal note: verify every event detail before publishing.',
  ].join('\n');
}
