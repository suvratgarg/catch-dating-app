#!/usr/bin/env node

import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import {fromRepo} from "../lib/repo_paths.mjs";

const defaultPolicyPath = fromRepo("tool/platform/mobile_package_policy.json");

function sha256(filePath) {
  const hash = crypto.createHash("sha256");
  hash.update(fs.readFileSync(filePath));
  return hash.digest("hex");
}

function run(command, args) {
  const result = spawnSync(command, args, {encoding: "utf8"});
  if (result.status !== 0) {
    throw new Error(result.stderr || `${command} ${args.join(" ")} failed.`);
  }
  return result.stdout;
}

function archiveEntries(artifactPath) {
  const listing = run("unzip", ["-l", artifactPath]);
  const entries = [];
  for (const line of listing.split(/\r?\n/)) {
    const match = line.match(/^\s*(\d+)\s+\S+\s+\S+\s+(.+)$/u);
    if (!match) continue;
    entries.push({path: match[2].trim(), bytes: Number(match[1])});
  }
  return entries;
}

function walkDirectory(root) {
  const entries = [];
  const visit = (directory) => {
    for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
      const absolute = path.join(directory, entry.name);
      if (entry.isDirectory()) visit(absolute);
      if (entry.isFile()) {
        entries.push({
          path: path.relative(root, absolute).split(path.sep).join("/"),
          bytes: fs.statSync(absolute).size,
        });
      }
    }
  };
  visit(root);
  return entries;
}

function extractedAppBinaries(artifactPath, entries) {
  const candidates = entries
    .map((entry) => entry.path)
    .filter((entryPath) =>
      /(?:^|\/)Frameworks\/App\.framework\/App$/u.test(entryPath) ||
      /\/lib\/[^/]+\/libapp\.so$/u.test(`/${entryPath}`)
    );
  if (candidates.length === 0) return [];

  if (fs.statSync(artifactPath).isDirectory()) {
    return candidates.map((entryPath) => path.join(artifactPath, entryPath));
  }

  const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-package-"));
  try {
    for (const candidate of candidates) {
      run("unzip", ["-qq", artifactPath, candidate, "-d", tempRoot]);
    }
    return candidates.map((candidate) => ({
      sourcePath: candidate,
      bytes: fs.statSync(path.join(tempRoot, candidate)).size,
      sha256: sha256(path.join(tempRoot, candidate)),
    }));
  } finally {
    fs.rmSync(tempRoot, {recursive: true, force: true});
  }
}

export function evaluatePackageReport({report, policy}) {
  const findings = [];
  const rolePolicy = policy.platforms?.[report.platform]?.[report.role];
  if (!rolePolicy) {
    return [`No package policy exists for ${report.platform}/${report.role}.`];
  }
  if (
    report.artifactKind === "archive" &&
    report.artifactBytes > rolePolicy.maxArtifactBytes
  ) {
    findings.push(
      `Artifact is ${report.artifactBytes} bytes; budget is ${rolePolicy.maxArtifactBytes}.`,
    );
  }
  if (report.uncompressedBytes > rolePolicy.maxUncompressedBytes) {
    findings.push(
      `Uncompressed payload is ${report.uncompressedBytes} bytes; budget is ${rolePolicy.maxUncompressedBytes}.`,
    );
  }
  for (const marker of policy.forbiddenEntries ?? []) {
    if (report.entries.some((entry) => entry.path.includes(marker))) {
      findings.push(`Production payload contains forbidden entry marker: ${marker}`);
    }
  }
  for (const marker of rolePolicy.forbiddenNativeEntries ?? []) {
    if (report.entries.some((entry) =>
      entry.path.toLowerCase().includes(marker.toLowerCase())
    )) {
      findings.push(`${report.role} payload contains forbidden native entry: ${marker}`);
    }
  }
  return findings;
}

export function comparePackageReports({consumer, host, policy}) {
  const findings = [];
  if (policy.comparison?.requireDifferentAppBinary) {
    const consumerHashes = consumer.appBinaries.map((entry) => entry.sha256).sort();
    const hostHashes = host.appBinaries.map((entry) => entry.sha256).sort();
    if (
      consumerHashes.length > 0 &&
      JSON.stringify(consumerHashes) === JSON.stringify(hostHashes)
    ) {
      findings.push("Consumer and Host compiled app binaries are byte-identical.");
    }
  }
  if (policy.comparison?.requireDifferentEntrySet) {
    const consumerEntries = consumer.entries.map((entry) => entry.path).sort();
    const hostEntries = host.entries.map((entry) => entry.path).sort();
    if (JSON.stringify(consumerEntries) === JSON.stringify(hostEntries)) {
      findings.push("Consumer and Host package entry sets are identical.");
    }
  }
  return findings;
}

export function inspectArtifact({artifactPath, role, platform, policy}) {
  const stats = fs.statSync(artifactPath);
  const entries = stats.isDirectory()
    ? walkDirectory(artifactPath)
    : archiveEntries(artifactPath);
  const rawBinaries = extractedAppBinaries(artifactPath, entries);
  const appBinaries = rawBinaries.map((entry) =>
    typeof entry === "string"
      ? {
          sourcePath: path.relative(artifactPath, entry),
          bytes: fs.statSync(entry).size,
          sha256: sha256(entry),
        }
      : entry
  );
  const report = {
    schemaVersion: "1.0.0",
    role,
    platform,
    artifact: path.basename(artifactPath),
    artifactKind: stats.isFile() ? "archive" : "expandedDirectory",
    artifactBytes: stats.isFile()
      ? stats.size
      : entries.reduce((sum, entry) => sum + entry.bytes, 0),
    uncompressedBytes: entries.reduce((sum, entry) => sum + entry.bytes, 0),
    entryCount: entries.length,
    entries,
    appBinaries,
  };
  return {...report, findings: evaluatePackageReport({report, policy})};
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
  const policyPath = valueAfter(args, "--policy") ?? defaultPolicyPath;
  const policy = JSON.parse(fs.readFileSync(policyPath, "utf8"));
  const compare = valueAfter(args, "--compare");

  if (compare) {
    const [consumerPath, hostPath] = compare.split(",");
    if (!consumerPath || !hostPath) {
      throw new Error("--compare requires consumer-report.json,host-report.json.");
    }
    const consumer = JSON.parse(fs.readFileSync(consumerPath, "utf8"));
    const host = JSON.parse(fs.readFileSync(hostPath, "utf8"));
    const findings = comparePackageReports({consumer, host, policy});
    console.log(JSON.stringify({consumer: consumerPath, host: hostPath, findings}, null, 2));
    if (findings.length > 0) process.exitCode = 1;
    return;
  }

  const artifactPath = valueAfter(args, "--artifact");
  const role = valueAfter(args, "--role");
  const platform = valueAfter(args, "--platform");
  const outputPath = valueAfter(args, "--output");
  if (!artifactPath || !["consumer", "host"].includes(role)) {
    throw new Error("--artifact and --role consumer|host are required.");
  }
  if (!["ios", "android"].includes(platform)) {
    throw new Error("--platform ios|android is required.");
  }
  const report = inspectArtifact({artifactPath, role, platform, policy});
  const rendered = `${JSON.stringify(report, null, 2)}\n`;
  if (outputPath) fs.writeFileSync(outputPath, rendered);
  process.stdout.write(
    outputPath
      ? `${JSON.stringify(
          {
            output: outputPath,
            role: report.role,
            platform: report.platform,
            artifactBytes: report.artifactBytes,
            uncompressedBytes: report.uncompressedBytes,
            entryCount: report.entryCount,
            appBinaries: report.appBinaries,
            findings: report.findings,
          },
          null,
          2,
        )}\n`
      : rendered,
  );
  if (report.findings.length > 0) process.exitCode = 1;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  main();
}
