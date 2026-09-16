#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {repoRoot} from '../lib/repo_paths.mjs';

const legacyRows = /\bCatchSkeleton\.(?:rows|mediaRows|iconRows)\s*\(/gu;
const rootHeader = /\bCatchScreenHeader\.block\s*\(/gu;
const protectedHostPaths = [
  'lib/hosts/today/',
  'lib/hosts/events/presentation/',
  'lib/hosts/presentation/customers/host_customers_screen.dart',
  'lib/hosts/presentation/customers/host_customers_directory.dart',
  'lib/hosts/presentation/forms/host_form_responses_panel.dart',
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
        message: 'Known rows must load through CatchSection.loadingRows/sliverLoadingRows with the eventual CatchFieldLayout.',
      });
    }
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
  return {findings, legacyCount};
}

export function checkLoadingComposition({root = repoRoot} = {}) {
  const findings = [];
  let legacyCount = 0;
  let filesScanned = 0;
  for (const relativePath of dartFiles(path.join(root, 'lib'), root)) {
    const source = fs.readFileSync(path.join(root, relativePath), 'utf8');
    const result = scanLoadingCompositionSource({relativePath, source});
    findings.push(...result.findings);
    legacyCount += result.legacyCount;
    filesScanned += 1;
  }
  return {findings, legacyCount, filesScanned};
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
    `Loading composition: ${result.filesScanned} files, ${result.findings.length} violations, ${result.legacyCount} legacy row recipes outside and inside protected paths.\n`,
  );
  if (result.findings.length > 0) process.exitCode = 1;
}
