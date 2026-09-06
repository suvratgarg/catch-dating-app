#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import crypto from 'node:crypto';

const repositoryRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const iosRoles = ['body', 'callout', 'caption1', 'caption2', 'footnote', 'headline', 'largeTitle', 'subhead', 'title1', 'title2', 'title3'];
const androidRoles = ['bodyLarge', 'bodyMedium', 'bodySmall', 'displayLarge', 'displayMedium', 'displaySmall', 'headlineLarge', 'headlineMedium', 'headlineSmall', 'labelLarge', 'labelMedium', 'labelSmall', 'titleLarge', 'titleMedium', 'titleSmall'];
const semanticRoles = ['headline', 'title', 'name', 'body', 'secondary', 'context', 'control', 'status', 'metric', 'fieldValue', 'fieldLabel', 'displayLarge', 'displayMedium', 'displaySmall', 'navigationLabel'];
export const requiredDomains = ['Typography', 'Typography tracking', 'Accessibility', 'Layout & device metrics', 'Components — Material', 'Components — UIKit snapshot', 'Components — Apple guidance', 'Shape', 'Colors', 'Colors — UIKit snapshot', 'Elevation', 'Interaction states', 'Motion', 'Materials', 'Assets & system surfaces'];
const dispositions = new Set(['semantic-and-runtime', 'runtime-and-brand', 'runtime', 'custom-component', 'reference-and-runtime', 'custom-theme', 'platform-assets']);

export function collectTokens(document) {
  const result = new Map();
  function walk(value, parts = [], inheritedType) {
    if (!value || typeof value !== 'object' || Array.isArray(value)) return;
    const type = value.$type ?? inheritedType;
    if ('$value' in value) result.set(parts.join('.'), { ...value, type });
    for (const [key, child] of Object.entries(value)) if (!key.startsWith('$')) walk(child, [...parts, key], type);
  }
  walk(document);
  return result;
}

export function resolveToken(tokens, name, visited = new Set()) {
  if (visited.has(name)) throw new Error(`Cyclic token alias: ${name}`);
  const token = tokens.get(name);
  if (!token) throw new Error(`Missing token: ${name}`);
  visited.add(name);
  const value = token.$value;
  return typeof value === 'string' && /^\{[^{}]+\}$/.test(value)
    ? resolveToken(tokens, value.slice(1, -1), visited)
    : value;
}

function at(document, dotted) {
  return dotted.split('.').reduce((value, key) => value?.[key], document);
}

// Applicability is a bounded executable predicate over the pinned inventory,
// not an "all rows covered" percentage or a wildcard that silently accepts a
// new source domain. Runtime snapshots remain explicit policies in token metadata.
export function requiresNativeImport(row) {
  return (row.category === 'Typography' && row.context === 'Large (default)')
    || row.origin === 'shared:font'
    || /^M:/.test(row.origin)
    || (row.category === 'Accessibility' && !row.concept.startsWith('Game '))
    || (row.category === 'Motion' && !/^(AR |Game )/.test(row.concept))
    || ['Shape', 'Elevation', 'Interaction states', 'Components — Apple guidance'].includes(row.category)
    || (row.category === 'Layout & device metrics' && row.evidence === 'Android API constant');
}

export function auditPlatformTokens(document, { inventory, textStyles } = {}) {
  const errors = [];
  const tokens = collectTokens(document);
  const foundation = document.$extensions?.['org.catch']?.platformFoundation;
  const fail = message => errors.push(message);
  if (!foundation || foundation.version !== 1) return ['Missing versioned platform foundation policy.'];
  if (!foundation.inventory?.materialRevision?.match(/^[a-f0-9]{40}$/) || !foundation.inventory?.appleProbe) fail('Missing pinned platform source versions.');
  const actualDomains = Object.keys(foundation.domains ?? {});
  for (const domain of requiredDomains) {
    const policy = foundation.domains?.[domain];
    if (!policy || !dispositions.has(policy.disposition) || !policy.rationale?.trim()) { fail(`Missing explicit applicability decision: ${domain}`); continue; }
    if (!Array.isArray(policy.targets) || policy.targets.length === 0) fail(`No semantic/reference owner for ${domain}`);
    for (const target of policy.targets ?? []) if (!at(document, target)) fail(`Unknown applicability target ${target} for ${domain}`);
  }
  for (const domain of actualDomains) if (!requiredDomains.includes(domain)) fail(`Unreviewed platform domain: ${domain}`);
  for (const owner of ['safeArea', 'keyboard', 'textScaling', 'reduceMotion', 'window', 'fontOptics', 'nativeControls']) if (!foundation.runtimeOwners?.[owner]?.trim()) fail(`Missing runtime policy: ${owner}`);
  for (const exception of ['brandTypography', 'dataTypography', 'avatarTypography', 'rasterTypography', 'spacing', 'floatingNavigation']) if (!foundation.authoredExceptions?.[exception]?.trim()) fail(`Missing authored exception: ${exception}`);

  const requireToken = name => { if (!tokens.has(name)) fail(`Missing required foundation token: ${name}`); };
  for (const [platform, roles, fields] of [['ios', iosRoles, ['size', 'lineHeight', 'weight', 'emphasizedWeight']], ['android', androidRoles, ['size', 'lineHeight', 'weight', 'tracking', 'font']]]) {
    const actual = Object.keys(document.platformReference?.[platform]?.typography ?? {}).filter(k => !k.startsWith('$'));
    for (const role of roles) for (const field of fields) requireToken(`platformReference.${platform}.typography.${role}.${field}`);
    if (actual.length !== roles.length || actual.some(r => !roles.includes(r))) fail(`Native ${platform} typography must have its complete named role set.`);
  }
  for (const platform of ['ios', 'android']) {
    const profile = document.typography?.[platform] ?? {};
    const actual = Object.keys(profile).filter(k => !k.startsWith('$'));
    if (actual.length !== semanticRoles.length || actual.some(r => !semanticRoles.includes(r))) fail(`Incomplete or unreviewed ${platform} semantic typography role set.`);
    for (const role of semanticRoles) {
      for (const field of ['size', 'lineHeight', 'weight', 'tracking']) requireToken(`typography.${platform}.${role}.${field}`);
      const decision = profile[role]?.$extensions?.['org.catch'];
      if (!decision?.decision?.trim() || !at(document, decision?.reference ?? '')) fail(`Missing reference/decision for ${platform}.${role}`);
    }
    requireToken(`platformReference.${platform}.accessibility.recommendedButtonHitTargetHeight`);
    requireToken(`platformReference.${platform}.accessibility.recommendedButtonHitTargetWidth`);
  }
  for (const role of ['pageGutter', 'pageBodyStart', 'recordAvatarExtent', 'recordLeadingGap', 'recordVerticalPadding', 'recordTitleGap', 'recordBodyGap']) requireToken(`layout.${role}`);
  for (const role of ['fast', 'micro', 'chatScroll', 'base', 'pageStep', 'calendarScroll', 'slow', 'standardCurve']) requireToken(`motion.${role}`);
  for (const role of ['minimumTextContrast', 'largeTextContrast', 'minimumTextScaleTest']) requireToken(`accessibility.${role}`);
  for (const role of ['heightDpExpandedLowerBound','heightDpMediumLowerBound','widthDpExpandedLowerBound','widthDpExtraLargeLowerBound','widthDpLargeLowerBound','widthDpMediumLowerBound']) requireToken(`platformReference.android.window.${role}`);
  for (const role of ['shapeCornerNoneTopLeft','shapeCornerExtraSmallTopLeft','shapeCornerSmallTopLeft','shapeCornerMediumTopLeft','shapeCornerLargeTopLeft','shapeCornerExtraLargeTopLeft','shapeCornerFullFamily']) requireToken(`platformReference.android.shape.${role}`);
  for (let level = 0; level <= 5; level++) requireToken(`platformReference.android.elevation.elevationLevel${level}`);
  for (const role of ['stateDraggedStateLayerOpacity','stateFocusStateLayerOpacity','stateHoverStateLayerOpacity','statePressedStateLayerOpacity']) requireToken(`platformReference.android.interactionStates.${role}`);
  for (const role of ['listItemLeadingAvatarSize','listItemLeadingSpace','listItemTrailingSpace','listItemOneLineContainerHeight','listItemTwoLineContainerHeight','listItemThreeLineContainerHeight']) requireToken(`platformReference.android.list.${role}`);
  for (const role of ['durationShort1Ms','durationShort2Ms','durationShort3Ms','durationShort4Ms','durationMedium1Ms','durationMedium2Ms','durationMedium3Ms','durationMedium4Ms','durationLong1Ms','durationLong2Ms','durationLong3Ms','durationLong4Ms','durationExtraLong1Ms','durationExtraLong2Ms','durationExtraLong3Ms','durationExtraLong4Ms','easingStandard']) requireToken(`platformReference.android.motion.${role}`);
  for (const role of ['swiftUIAnimationDefaultResponse','swiftUIAnimationDefaultDampingFraction','swiftUIAnimationDefaultBlendDuration','swiftUIEaseInOutDuration','swiftUISmoothDurationExtraBounceDuration','swiftUISnappyDurationExtraBounceDuration','swiftUIBouncyDurationExtraBounceDuration']) requireToken(`platformReference.ios.motion.${role}`);

  const referenceSources = new Map();
  for (const [name, token] of tokens) {
    try { resolveToken(tokens, name); } catch (error) { fail(error.message); }
    if (!name.startsWith('platformReference.')) continue;
    const source = token.$extensions?.['org.catch']?.source;
    const metadata = foundation.sources?.[source?.sourceKey];
    if (!source?.inventoryId?.match(/^V\d{5}$/) || !source?.origin || !metadata?.version || !metadata?.urls?.length || metadata.urls.some(url => !/^https:\/\/(developer\.apple\.com|developer\.android\.com|github\.com\/flutter\/flutter)\//.test(url))) { fail(`Incomplete native provenance: ${name}`); continue; }
    const identity = `${source.platform}:${source.inventoryId}`;
    if (referenceSources.has(identity)) fail(`Duplicate native source import: ${identity}`);
    referenceSources.set(identity, { name, source, value: resolveToken(tokens, name) });
  }
  if (referenceSources.size === 0) fail('Native source import cannot be empty.');
  errors.push(...auditPinnedSources(document, tokens));

  function scalar(name) { try { const value = resolveToken(tokens, name); return typeof value === 'object' ? value.value : value; } catch { return undefined; } }
  if (scalar('interaction.ios.minimumExtent') !== 44 || scalar('interaction.android.minimumExtent') !== 48) fail('Interactive floors must preserve the selected iOS44/Android48 recommendations.');
  if (scalar('accessibility.minimumTextContrast') < 4.5 || scalar('accessibility.largeTextContrast') < 3 || scalar('accessibility.minimumTextScaleTest') < 2) fail('Accessibility acceptance floors cannot be lowered.');
  if (scalar('platformReference.ios.typography.body.size') !== 17 || scalar('platformReference.ios.typography.body.lineHeight') !== 22) fail('Native iOS Body is17/22; Catch16/24 must remain a separate decision.');
  if (scalar('platformReference.ios.typography.caption1.size') !== 12 || scalar('platformReference.ios.typography.footnote.size') !== 13) fail('Do not mislabel Footnote as Caption1.');
  for (const platform of ['ios', 'android']) {
    const role = `typography.${platform}.navigationLabel`;
    const exception = at(document, role)?.$extensions?.['org.catch']?.exception;
    if (scalar(`${role}.size`) !== 13 || scalar(`${role}.lineHeight`) !== 13 || scalar(`${role}.weight`) !== 600 || scalar(`${role}.tracking`) !== 0 || exception !== 'floatingNavigation') fail(`Approved floating navigation typography must remain 13/13, weight 600, zero tracking: ${platform}`);
  }

  if (inventory) {
    if (!Array.isArray(inventory.rows) || inventory.rows.length === 0) fail('Source inventory must not be empty.');
    const ids = new Set();
    for (const row of inventory.rows ?? []) {
      if (ids.has(row.id)) fail(`Duplicate inventory id: ${row.id}`);
      ids.add(row.id);
      if (!requiredDomains.includes(row.category)) fail(`Inventory domain needs an applicability decision: ${row.category}`);
      if (!requiresNativeImport(row)) continue;
      for (const platform of ['ios', 'android']) {
        if (row[platform] == null) continue;
        const imported = referenceSources.get(`${platform}:${row.id}`);
        if (!imported) { fail(`Applicable native value not imported: ${platform}:${row.id} ${row.concept}`); continue; }
        const raw = imported.value?.unit === 'px' ? imported.value.value : imported.value;
        const expected = row.category === 'Typography' && /weight/i.test(row.concept) && typeof row[platform] === 'string' ? {Regular:400,Semibold:600,Bold:700}[row[platform]] : row[platform];
        if (JSON.stringify(raw) !== JSON.stringify(expected) || imported.source.origin !== row.origin) fail(`Source value/provenance differs: ${imported.name}`);
      }
    }
    for (const { source } of referenceSources.values()) if (!ids.has(source.inventoryId)) fail(`Imported source not found in inventory: ${source.inventoryId}`);
  }
  if (textStyles !== undefined) {
    if (!textStyles.trim()) fail('Typography consumer source must not be empty.');
    if (/\b_sans\s*\(/.test(textStyles) || /CatchFonts\.sans\s*\([^;]*?fontSize:\s*\d/.test(textStyles)) fail('Functional metrics must consume generated profiles; no second raw sans scale.');
    const material = textStyles.match(/static TextTheme materialTextTheme\([\s\S]*?\n  }/)?.[0];
    if (!material || !material.includes('CatchPlatformTokens.typography') || /style\(\s*\d/.test(material)) fail('Material fallback must consume the same platform profiles.');
  }
  return [...new Set(errors)];
}

// These are versioned third-party input dependencies, not an inventory of app
// adoption or a generated audit receipt. Independent source resolution makes
// normal CI reject arbitrary deleted/changed native references without access
// to the original researcher's machine or a network connection.
function auditPinnedSources(document, tokens) {
  const errors = [];
  const policy = document.$extensions['org.catch'].platformFoundation;
  const documents = {};
  const requiredFiles = ['badge','banner','bottom_app_bar','button_elevated','button_filled','button_filled_tonal','button_outlined','button_text','card_elevated','card_filled','card_outlined','carousel_item','checkbox','chip_assist','chip_filter','chip_input','chip_suggestion','color_dark','color_light','date_picker_docked','date_picker_input_modal','date_picker_modal','dialog','dialog_fullscreen','divider','elevation','fab_extended_primary','fab_large_primary','fab_primary','fab_small_primary','icon_button','icon_button_filled','icon_button_filled_tonal','icon_button_outlined','list','menu','motion','navigation_bar','navigation_drawer','navigation_rail','navigation_tab_primary','navigation_tab_secondary','palette','progress_indicator','radio_button','search_bar','search_view','segmented_button_outlined','shape','sheet_bottom','slider','snackbar','state','switch','text_field_filled','text_field_outlined','text_style','time_picker','top_app_bar_large','top_app_bar_medium','top_app_bar_small','typeface'];
  function inputFile(entry) {
    if (!entry?.path?.startsWith('design/tokens/platform_sources/') || entry.path.includes('..') || !/^[a-f0-9]{64}$/.test(entry.sha256 ?? '')) throw new Error('Missing or invalid pinned platform source dependency.');
    const source = fs.readFileSync(path.join(repositoryRoot, entry.path), 'utf8');
    if (crypto.createHash('sha256').update(source).digest('hex') !== entry.sha256) throw new Error(`Pinned platform source checksum differs: ${entry.path}`);
    return JSON.parse(source);
  }
  try {
    const entries = policy.materialSources?.files ?? {};
    if (Object.keys(entries).length !== requiredFiles.length || requiredFiles.some(name => !entries[`${name}.json`])) throw new Error('Complete pinned Material source dependency set is required.');
    if (policy.materialSources.revision !== policy.inventory.materialRevision) throw new Error('Material source and inventory revisions disagree.');
    const license = policy.materialSources.license;
    if (license !== 'design/tokens/platform_sources/material/LICENSE' || !fs.readFileSync(path.join(repositoryRoot, license), 'utf8').includes('Copyright 2014 The Flutter Authors')) throw new Error('Pinned Material source license is required.');
    for (const name of requiredFiles) documents[name] = inputFile(entries[`${name}.json`]);
    const nativeAcceptance = inputFile(policy.nativeAcceptance);
    if (!nativeAcceptance.cases || Object.keys(nativeAcceptance.cases).length === 0) throw new Error('Native source acceptance cases cannot be empty.');
    for (const [name, [raw, unit, origin, id, platform, urls, version]] of Object.entries(nativeAcceptance.cases)) {
      const token = tokens.get(name);
      if (!token) { errors.push(`Missing native source acceptance token: ${name}`); continue; }
      const source = token.$extensions?.['org.catch']?.source;
      const expected = unit === 'named weight' ? {Regular:400,Semibold:600,Bold:700}[raw] : raw;
      const resolved = resolveToken(tokens, name);
      const actual = resolved?.unit === 'px' ? resolved.value : resolved;
      const primaryUrls = policy.sources?.[source?.sourceKey]?.urls ?? [];
      if (JSON.stringify(actual) !== JSON.stringify(expected) || source?.origin !== origin || source?.inventoryId !== id || source?.unit !== unit || source?.platform !== platform || policy.sources?.[source?.sourceKey]?.version !== version || urls.some(url => !primaryUrls.includes(url))) errors.push(`Native source acceptance differs: ${name}`);
    }
  } catch (error) { errors.push(error.message); return errors; }

  const flat = Object.assign({}, ...Object.entries(documents).filter(([name]) => !['color_light','color_dark'].includes(name)).map(([,value]) => Object.fromEntries(Object.entries(value).filter(([key]) => key !== 'version'))));
  const flatEntries = Object.entries(flat);
  // Reuse prefix lookups only within this audit. Values still resolve with the
  // current mode and cycle trail; each audit reloads and verifies pinned files.
  const typeStyleReferences = new Map();
  const kebab = value => value.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();
  function resolve(value, mode, trail = new Set()) {
    if (typeof value !== 'string') return value;
    if (trail.has(value)) throw new Error(`Cyclic upstream Material reference: ${value}`);
    const next = new Set([...trail, value]);
    for (const key of [value, ...(!value.includes('.') ? [`md.sys.color.${kebab(value)}`] : [])]) {
      if (key in documents[`color_${mode}`]) return resolve(documents[`color_${mode}`][key], mode, next);
      if (key in flat) return resolve(flat[key], mode, next);
    }
    const prefix = `md.sys.typescale.${kebab(value)}.`;
    if (!typeStyleReferences.has(prefix)) {
      typeStyleReferences.set(prefix, flatEntries.filter(([key]) => key.startsWith(prefix)));
    }
    const parts = Object.fromEntries(typeStyleReferences.get(prefix).map(([key, v]) => [key.slice(prefix.length), resolve(v, mode, next)]));
    if (Object.keys(parts).length) return parts;
    return /^0x[0-9a-f]{8}$/i.test(value) ? `#${value.slice(4)}${value.slice(2,4)}` : value;
  }
  function* leaves(value, suffix = '') {
    if (Array.isArray(value)) { for (const [index, v] of value.entries()) yield* leaves(v, `${suffix}[${index}]`); }
    else if (value && typeof value === 'object') { for (const [key, v] of Object.entries(value)) yield* leaves(v, suffix ? `${suffix}.${key}` : key); }
    else yield [suffix, value];
  }
  function materialUnit(key, value) {
    if (typeof value === 'boolean') return 'boolean';
    if (typeof value === 'string' && value.startsWith('#')) return '#RRGGBBAA';
    if (typeof value === 'string' && value.startsWith('Cubic(')) return 'unitless curve';
    if (key.includes('.duration.')) return 'ms';
    if (/opacity|scale-factor/.test(key)) return 'ratio';
    if (key.includes('.weight')) return 'font weight (100–900)';
    if (key.endsWith('.font')) return 'font family';
    if (/\.typescale\.|\.text-style\./.test(key) && /\.(size|line-height|tracking)$/.test(key)) return 'sp';
    if (typeof value === 'number') return /height|width|size|space|padding|radius|elevation|thickness|offset|distance|corner|shape|topLeft|topRight|bottomLeft|bottomRight/.test(key) ? 'dp' : 'unitless';
    return 'symbol / expression';
  }
  const material = new Map();
  for (const [name, token] of tokens) {
    const source = token.$extensions?.['org.catch']?.source;
    if (!source?.origin?.startsWith('M:')) continue;
    const identity = `${source.origin}|${source.tokenName}|${source.context}`;
    if (material.has(identity)) errors.push(`Duplicate native Material identity: ${identity}`);
    material.set(identity, {name, token, source});
  }
  const expectedIds = new Set();
  for (const [component, values] of Object.entries(documents)) {
    for (const [key, raw] of Object.entries(values)) {
      if (key === 'version') continue;
      const light = resolve(raw, 'light'), dark = resolve(raw, 'dark');
      const modes = component === 'color_dark' ? ['dark'] : component !== 'color_light' && JSON.stringify(light) !== JSON.stringify(dark) ? ['light','dark'] : ['light'];
      for (const mode of modes) for (const [suffix, expected] of leaves(resolve(raw, mode))) {
        const context = modes.length > 1 || component.startsWith('color_') ? mode[0].toUpperCase()+mode.slice(1) : 'Baseline';
        const identity = `M:${component}::${key}|${key}${suffix ? `.${suffix}` : ''}|${context}`;
        expectedIds.add(identity);
        const imported = material.get(identity);
        if (!imported) { errors.push(`Pinned Material source not imported: ${identity}`); continue; }
        const resolved = resolveToken(tokens, imported.name);
        const actual = resolved?.unit === 'px' ? resolved.value : resolved;
        if (JSON.stringify(actual) !== JSON.stringify(expected)) errors.push(`Pinned Material source value differs: ${imported.name}`);
        const tokenName = `${key}${suffix ? `.${suffix}` : ''}`;
        const primaryUrl = `https://github.com/flutter/flutter/blob/${policy.materialSources.revision}/dev/tools/gen_defaults/data/${component}.json`;
        const sourceUrls = policy.sources?.[imported.source.sourceKey]?.urls ?? [];
        if (imported.source.unit !== materialUnit(tokenName, expected) || imported.source.platform !== 'android' || !sourceUrls.includes(primaryUrl)) errors.push(`Pinned Material source unit/provenance differs: ${imported.name}`);
      }
    }
  }
  for (const identity of material.keys()) if (!expectedIds.has(identity)) errors.push(`Native Material provenance has no pinned source: ${identity}`);
  return errors;
}

function main(args) {
  const inventoryIndex = args.indexOf('--inventory');
  if (args.length !== 0 && (args.length !== 2 || inventoryIndex !== 0 || !args[1] || args[1].startsWith('--'))) throw new Error('Usage: node tool/design/check_platform_token_coverage.mjs [--inventory /path/to/inventory.json]');
  const document = JSON.parse(fs.readFileSync(path.join(repositoryRoot, 'design/tokens/catch.tokens.json'), 'utf8'));
  const textStyles = fs.readFileSync(path.join(repositoryRoot, 'packages/catch_ui/lib/src/foundations/catch_text_styles.dart'), 'utf8');
  const inventory = inventoryIndex >= 0 ? JSON.parse(fs.readFileSync(args[inventoryIndex + 1], 'utf8')) : undefined;
  const errors = auditPlatformTokens(document, { inventory, textStyles });
  if (errors.length) { console.error(errors.map(error => `- ${error}`).join('\n')); process.exitCode = 1; }
  else console.log(`Platform foundation coverage passed${inventory ? ` against ${inventory.rows.length} source entries` : ''}.`);
}
if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main(process.argv.slice(2));
