#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {repoRoot} from '../lib/repo_paths.mjs';

const legacyRows = /\bCatchSkeleton\.(?:rows|mediaRows|iconRows)\s*\(/gu;
const legacyCollections = /\bCatchSkeleton\.(?:cards|boxes|chips)\s*\(/gu;
// Temporary allowances for older routes that still need their real loading
// composition. Decrease or remove an entry with each migration. New files and
// increases in an existing file fail even if another file loses a recipe.
const allowedLegacyRowsByPath = Object.freeze({
  'lib/event_rehearsal/presentation/host_event_rehearsal_screen.dart': 1,
  'lib/event_success/presentation/companion/event_success_companion_loading_page_body.dart': 1,
  'lib/event_success/presentation/host_components/event_success_host_section_skeleton.dart': 1,
  'lib/hosts/presentation/applications/host_application_detail_screen.dart': 1,
  'lib/hosts/presentation/club_management/create/widgets/host_club_editor_loading_screen.dart': 2,
  'lib/hosts/presentation/customers/host_contact_merge_review.dart': 1,
  'lib/hosts/presentation/forms/host_form_analytics_screen.dart': 2,
  'lib/hosts/presentation/forms/host_form_builder_screen.dart': 1,
  'lib/hosts/presentation/forms/host_form_preview_screen.dart': 1,
  'lib/hosts/presentation/forms/host_form_response_detail_screen.dart': 1,
  'lib/hosts/presentation/forms/host_form_share_screen.dart': 2,
  'lib/hosts/presentation/host_operations/host_audience.dart': 1,
  'lib/hosts/presentation/host_operations/host_club_team_screen.dart': 2,
  'lib/hosts/presentation/inbox/host_campaign_composer.dart': 2,
  'lib/hosts/presentation/inbox/host_inbox_person_page_body.dart': 1,
  'lib/hosts/presentation/inbox/host_messaging_setup_screen.dart': 1,
  'lib/hosts/presentation/inbox/host_whatsapp_thread_sheet.dart': 1,
  'lib/hosts/presentation/widgets/host_event_attendance_panel.dart': 1,
  'lib/hosts/presentation/widgets/host_event_participants_section_list.dart': 1,
  'lib/hosts/presentation/widgets/host_loading_skeletons.dart': 3,
  'lib/routing/go_router.dart': 1,
});
const allowedLegacyCollectionsByPath = Object.freeze({
  'lib/clubs/presentation/detail/widgets/club_detail_skeleton.dart': 1,
  'lib/event_success/presentation/host_components/event_success_host_section_skeleton.dart': 1,
  'lib/hosts/presentation/club_management/create/widgets/host_club_editor_loading_screen.dart': 2,
  'lib/swipes/presentation/filters_screen.dart': 1,
  'lib/swipes/presentation/swipe_hub_screen.dart': 2,
});
export const legacyRowRecipeCeiling = Object.values(
  allowedLegacyRowsByPath,
).reduce((sum, count) => sum + count, 0);
export const legacyCollectionRecipeCeiling = Object.values(
  allowedLegacyCollectionsByPath,
).reduce((sum, count) => sum + count, 0);
export const legacyRowAllowanceFor = (relativePath) =>
  allowedLegacyRowsByPath[relativePath] ?? 0;
export const legacyCollectionAllowanceFor = (relativePath) =>
  allowedLegacyCollectionsByPath[relativePath] ?? 0;
const rootHeader = /\bCatchScreenHeader\.block\s*\(/gu;
const protectedHostPaths = [
  'lib/hosts/today/',
  'lib/hosts/events/presentation/',
  'lib/hosts/presentation/customers/host_customers_screen.dart',
  'lib/hosts/presentation/customers/host_customers_directory.dart',
  'lib/hosts/presentation/customers/host_saved_audiences_workspace.dart',
  'lib/hosts/presentation/customers/host_saved_audience_overview.dart',
  'lib/hosts/presentation/customers/host_customer_applications_panel.dart',
  'lib/hosts/presentation/forms/host_form_responses_panel.dart',
  'lib/hosts/presentation/forms/host_forms_screen.dart',
  'lib/hosts/presentation/forms/host_form_overview_section_list.dart',
  'lib/hosts/presentation/forms/host_form_templates_screen.dart',
  'lib/hosts/presentation/forms/host_form_automations_screen.dart',
  'lib/hosts/presentation/inbox/host_new_message_screen.dart',
  'lib/hosts/presentation/host_operations/host_team_hosted_clubs_section.dart',
  'lib/hosts/presentation/applications/host_applications_screen.dart',
];
const unresolvedHostPrefixes = [
  'lib/hosts/',
  'lib/event_success/',
  'lib/event_rehearsal/',
];

export function scanLoadingCompositionSource({relativePath, source}) {
  const masked = maskDartCommentsAndStrings(source);
  const findings = [];
  let legacyCount = 0;
  let legacyCollectionCount = 0;
  const protectedPath =
    protectedHostPaths.some((prefix) => relativePath.startsWith(prefix)) ||
    (relativePath.startsWith('lib/') &&
      !unresolvedHostPrefixes.some((prefix) => relativePath.startsWith(prefix)) &&
      relativePath !== 'lib/routing/go_router.dart');

  for (const match of masked.matchAll(legacyRows)) {
    legacyCount += 1;
    if (protectedPath) {
      findings.push({
        path: relativePath,
        line: lineFor(source, match.index),
        code: 'LOADING-COMPOSITION-001',
        message: 'Known rows must load through the matching CatchSection loading variant and eventual CatchFieldLayout.',
      });
    }
  }
  for (const match of masked.matchAll(legacyCollections)) {
    legacyCollectionCount += 1;
  }
  for (const match of masked.matchAll(rootHeader)) {
    const open = masked.indexOf('(', match.index);
    const close = balancedClose(masked, open);
    if (close == null) continue;
    if (/\btitleStyle\s*:/u.test(masked.slice(open, close))) {
      findings.push({
        path: relativePath,
        line: lineFor(source, match.index),
        code: 'ROOT-TITLE-001',
        message: 'Root titles use the CatchScreenHeader typography; do not override titleStyle at the screen.',
      });
    }
  }
  return {findings, legacyCount, legacyCollectionCount};
}

export function checkLoadingComposition({root = repoRoot} = {}) {
  const findings = [];
  let legacyCount = 0;
  let legacyCollectionCount = 0;
  let filesScanned = 0;
  const scannedPaths = new Set();
  for (const relativePath of dartFiles(path.join(root, 'lib'), root)) {
    const source = fs.readFileSync(path.join(root, relativePath), 'utf8');
    const result = scanLoadingCompositionSource({relativePath, source});
    findings.push(...result.findings);
    legacyCount += result.legacyCount;
    legacyCollectionCount += result.legacyCollectionCount;
    filesScanned += 1;
    scannedPaths.add(relativePath);
    const allowance = legacyRowAllowanceFor(relativePath);
    if (result.legacyCount !== allowance) {
      findings.push({
        path: relativePath,
        line: 1,
        code: 'LOADING-COMPOSITION-RATCHET',
        message: `Expected ${allowance} legacy row recipes in this file; found ${result.legacyCount}. Remove a new recipe or lower this file's allowance after migration.`,
      });
    }
    const collectionAllowance = legacyCollectionAllowanceFor(relativePath);
    if (result.legacyCollectionCount !== collectionAllowance) {
      findings.push({
        path: relativePath,
        line: 1,
        code: 'LOADING-COMPOSITION-RATCHET',
        message: `Expected ${collectionAllowance} legacy collection recipes in this file; found ${result.legacyCollectionCount}. Remove a new recipe or lower this file's allowance after migration.`,
      });
    }
  }
  for (const relativePath of new Set([
    ...Object.keys(allowedLegacyRowsByPath),
    ...Object.keys(allowedLegacyCollectionsByPath),
  ])) {
    if (scannedPaths.has(relativePath)) continue;
    findings.push({
      path: relativePath,
      line: 1,
      code: 'LOADING-COMPOSITION-RATCHET',
      message: 'The allowed legacy recipe file is gone; remove its allowance.',
    });
  }
  return {findings, legacyCount, legacyCollectionCount, filesScanned};
}

function* dartFiles(directory, root) {
  if (!fs.existsSync(directory)) return;
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    const absolutePath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      yield* dartFiles(absolutePath, root);
    } else if (
      entry.name.endsWith('.dart') &&
      !/\.(?:g|freezed|mocks)\.dart$/u.test(entry.name)
    ) {
      yield path.relative(root, absolutePath).replaceAll(path.sep, '/');
    }
  }
}

function lineFor(source, offset) {
  return source.slice(0, offset).split('\n').length;
}

function balancedClose(source, open) {
  let depth = 0;
  for (let index = open; index < source.length; index += 1) {
    if (source[index] === '(') depth += 1;
    if (source[index] === ')' && --depth === 0) return index;
  }
  return null;
}

function maskDartCommentsAndStrings(source) {
  let output = '';
  for (let index = 0; index < source.length; index += 1) {
    const char = source[index];
    const next = source[index + 1];
    if (char === '/' && next === '/') {
      while (index < source.length && source[index] !== '\n') {
        output += ' ';
        index += 1;
      }
      output += '\n';
      continue;
    }
    if (char === '/' && next === '*') {
      output += '  ';
      index += 2;
      while (index < source.length && !(source[index] === '*' && source[index + 1] === '/')) {
        output += source[index] === '\n' ? '\n' : ' ';
        index += 1;
      }
      if (index < source.length) output += '  ';
      index += 1;
      continue;
    }
    if (char === '"' || char === "'") {
      const quote = char;
      output += ' ';
      while (++index < source.length) {
        const current = source[index];
        output += current === '\n' ? '\n' : ' ';
        if (current === '\\' && index + 1 < source.length) {
          index += 1;
          output += source[index] === '\n' ? '\n' : ' ';
          continue;
        }
        if (current === quote) break;
      }
      continue;
    }
    output += char;
  }
  return output;
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const result = checkLoadingComposition();
  for (const finding of result.findings) {
    process.stderr.write(`${finding.path}:${finding.line} ${finding.code} ${finding.message}\n`);
  }
  process.stdout.write(
    `Loading composition: ${result.filesScanned} files, ${result.findings.length} violations, ${result.legacyCount} legacy row and ${result.legacyCollectionCount} legacy collection recipes remaining.\n`,
  );
  if (result.findings.length > 0) process.exitCode = 1;
}
