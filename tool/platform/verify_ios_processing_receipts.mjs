#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {defaultRepoRoot, loadAppTargets, resolveAppTarget} from "./resolve_app_target.mjs";

export function verifyIosProcessingReceipts({
  root = defaultRepoRoot,
  directory,
  githubRunId,
  builds,
}) {
  if (!/^\d+$/u.test(String(githubRunId))) throw new Error("GitHub source run id must be numeric");
  const manifest = loadAppTargets({root});
  const receipts = {};
  for (const role of ["consumer", "host"]) {
    const expectedBuild = String(builds[role] ?? "");
    if (!/^\d{18}$/u.test(expectedBuild)) {
      throw new Error(`${role} build must use the canonical 18-digit GitHub namespace`);
    }
    const target = resolveAppTarget({manifest, role, environment: "prod"});
    const receiptPath = path.resolve(directory, `${role}-testflight.json`);
    if (!fs.existsSync(receiptPath)) throw new Error(`Missing ${role} TestFlight receipt: ${receiptPath}`);
    const receipt = JSON.parse(fs.readFileSync(receiptPath, "utf8"));
    for (const [label, actual, expected] of [
      ["schema", receipt.$schema, "catch.app-store-build-processing/v1"],
      ["app id", receipt.appId, target.release.appStoreConnectAppId],
      ["build number", String(receipt.buildNumber), expectedBuild],
      ["processing state", receipt.processingState, "VALID"],
      ["GitHub run id", String(receipt.githubRunId), String(githubRunId)],
    ]) {
      if (actual !== expected) {
        throw new Error(`${role} receipt ${label} was '${actual ?? ""}'; expected '${expected}'`);
      }
    }
    receipts[role] = {targetId: target.id, appId: receipt.appId, buildNumber: receipt.buildNumber};
  }
  return {githubRunId: String(githubRunId), receipts};
}

function valueAfter(args, flag) {
  const index = args.indexOf(flag);
  return index >= 0 ? args[index + 1] : null;
}

const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  try {
    const args = process.argv.slice(2);
    if (args.includes("--help") || args.includes("-h")) {
      console.log("Usage: node tool/platform/verify_ios_processing_receipts.mjs --directory PATH --github-run-id ID --consumer-build 18_DIGITS --host-build 18_DIGITS");
      process.exit(0);
    }
    const result = verifyIosProcessingReceipts({
      directory: valueAfter(args, "--directory"),
      githubRunId: valueAfter(args, "--github-run-id"),
      builds: {
        consumer: valueAfter(args, "--consumer-build"),
        host: valueAfter(args, "--host-build"),
      },
    });
    console.log(JSON.stringify(result));
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}
