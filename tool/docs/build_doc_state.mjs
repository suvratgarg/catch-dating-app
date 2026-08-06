#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import {fromRepo, repoRoot} from "../lib/repo_paths.mjs";
import {parseDocumentLifecycleStatus} from "./check_doc_version_monotonic.mjs";

export function buildDocState({catalog, sourceRevision, resolveDocument}) {
  const documents = {};
  const paths = new Set();
  const orderedEntries = Object.entries(catalog)
    .filter(([docId, entry]) => !(docId === "version" && typeof entry === "string"))
    .sort();

  for (const [docId, entry] of orderedEntries) {
    if (!entry || typeof entry !== "object") {
      throw new Error(`Document catalog entry "${docId}" must be an object.`);
    }
    if (typeof entry.path !== "string" || entry.path.length === 0) {
      throw new Error(`Document catalog entry "${docId}" is missing path.`);
    }
    if (paths.has(entry.path)) {
      throw new Error(`Document path is cataloged more than once: ${entry.path}`);
    }
    if (
      !entry.path.endsWith(".md") &&
      (typeof entry.status !== "string" || entry.status.length === 0)
    ) {
      throw new Error(
        `Non-Markdown document catalog entry "${docId}" is missing lifecycle status.`,
      );
    }
    paths.add(entry.path);
  }

  for (const [docId, entry] of orderedEntries) {
    const revision = resolveDocument(entry.path);
    const markdown = entry.path.endsWith(".md");
    const status = markdown
      ? parseDocumentLifecycleStatus(revision.source ?? "")
      : entry.status;
    if (markdown && status == null) {
      throw new Error(
        `Governed Markdown "${docId}" (${entry.path}) has no single valid ` +
          "source-frontmatter lifecycle status.",
      );
    }
    documents[docId] = {
      path: entry.path,
      status,
      semanticVersion: entry.version,
      contentRevision: revision.contentRevision,
      lastIntegratedRevision: revision.lastIntegratedRevision,
      lastIntegratedAt: revision.lastIntegratedAt,
    };
  }

  return {
    schemaVersion: "1.2.0",
    sourceRevision,
    documents,
  };
}

function git(args) {
  const result = spawnSync("git", args, {cwd: repoRoot, encoding: "utf8"});
  if (result.status !== 0) {
    throw new Error(result.stderr || `git ${args.join(" ")} failed.`);
  }
  return result.stdout.trim();
}

function resolveDocumentAt(ref, documentPath) {
  const contentRevision = git(["rev-parse", `${ref}:${documentPath}`]);
  const source = git(["show", `${ref}:${documentPath}`]);
  const lastChange = git([
    "log",
    "-1",
    "--format=%H%x09%cI",
    ref,
    "--",
    documentPath,
  ]);
  const [lastIntegratedRevision, lastIntegratedAt] = lastChange.split("\t");
  if (!lastIntegratedRevision || !lastIntegratedAt) {
    throw new Error(`No integration history found for ${documentPath} at ${ref}.`);
  }
  return {source, contentRevision, lastIntegratedRevision, lastIntegratedAt};
}

function valueAfter(args, flag) {
  const index = args.indexOf(flag);
  if (index === -1) return null;
  const value = args[index + 1];
  if (!value || value.startsWith("--")) throw new Error(`${flag} requires a value.`);
  return value;
}

function main() {
  const args = process.argv.slice(2);
  const ref = valueAfter(args, "--ref") ?? "HEAD";
  const output = valueAfter(args, "--output");
  const catalogPath = valueAfter(args, "--catalog") ??
    "docs/audit_registry/doc_versions.json";
  const catalog = JSON.parse(fs.readFileSync(fromRepo(catalogPath), "utf8"));
  const sourceRevision = git(["rev-parse", ref]);
  const state = buildDocState({
    catalog,
    sourceRevision,
    resolveDocument: (documentPath) => resolveDocumentAt(ref, documentPath),
  });
  const rendered = `${JSON.stringify(state, null, 2)}\n`;

  if (output) {
    const outputPath = path.resolve(repoRoot, output);
    fs.mkdirSync(path.dirname(outputPath), {recursive: true});
    fs.writeFileSync(outputPath, rendered);
  }
  if (!output || args.includes("--json")) process.stdout.write(rendered);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  main();
}
