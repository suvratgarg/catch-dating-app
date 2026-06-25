import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, '..');

const configPath = path.join(root, 'config', 'mumbai.weekly-guide.config.json');
const candidatesPath = path.join(root, 'data', 'mumbai.sample.events.json');
const decisionsPath = path.join(root, 'review_decisions', 'mumbai.2026-06-22.example.json');

const config = JSON.parse(await readFile(configPath, 'utf8'));
const candidates = JSON.parse(await readFile(candidatesPath, 'utf8'));
const decisions = JSON.parse(await readFile(decisionsPath, 'utf8'));

const errors = [];

function requireField(object, field, label) {
  if (object[field] === undefined || object[field] === null || object[field] === '') {
    errors.push(`${label} missing required field: ${field}`);
  }
}

for (const field of ['program', 'city', 'cadence', 'contentStrategy', 'ctas', 'sources', 'weeklySearches', 'rankingWeights', 'limits']) {
  requireField(config, field, 'config');
}

for (const field of ['id', 'label', 'timezone']) {
  requireField(config.city ?? {}, field, 'config.city');
}

if (!Array.isArray(config.sources) || config.sources.length === 0) {
  errors.push('config.sources must include at least one source');
}

if (!Array.isArray(config.weeklySearches) || config.weeklySearches.length === 0) {
  errors.push('config.weeklySearches must include at least one query');
}

if (!Array.isArray(candidates.events)) {
  errors.push('candidates.events must be an array');
} else {
  for (const event of candidates.events) {
    for (const field of ['id', 'title', 'category', 'neighborhood', 'startDate', 'reviewState', 'requiresVerification', 'explicitSinglesEvent', 'whySinglesFriendly', 'scores']) {
      requireField(event, field, `event:${event.id ?? 'unknown'}`);
    }
    if (!['draft', 'needs_changes', 'approved', 'rejected'].includes(event.reviewState)) {
      errors.push(`event:${event.id} has invalid reviewState: ${event.reviewState}`);
    }
  }
}

if (!Array.isArray(decisions.decisions)) {
  errors.push('review decisions must be an array');
} else {
  const eventIds = new Set((candidates.events ?? []).map((event) => event.id));
  for (const decision of decisions.decisions) {
    requireField(decision, 'eventId', 'reviewDecision');
    requireField(decision, 'reviewState', `reviewDecision:${decision.eventId ?? 'unknown'}`);
    if (!['draft', 'needs_changes', 'approved', 'rejected'].includes(decision.reviewState)) {
      errors.push(`reviewDecision:${decision.eventId} has invalid reviewState: ${decision.reviewState}`);
    }
    if (decision.eventId && !eventIds.has(decision.eventId)) {
      errors.push(`reviewDecision:${decision.eventId} does not match a candidate event`);
    }
  }
}

if (errors.length > 0) {
  console.error('Weekly guide PoC config validation failed:');
  for (const error of errors) {
    console.error(`- ${error}`);
  }
  process.exit(1);
}

console.log(`Weekly guide PoC config ok: ${config.city.label}, ${candidates.events.length} sample candidates, ${decisions.decisions.length} example decisions`);
