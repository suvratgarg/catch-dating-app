#!/usr/bin/env node

import path from "node:path";
import {fileURLToPath} from "node:url";

export function computeMobileBuildNumber({platform, utcDate, runNumber, runAttempt}) {
  const date = String(utcDate);
  const run = positiveInteger(runNumber, "GitHub run number");
  const attempt = positiveInteger(runAttempt, "GitHub run attempt");
  if (!/^\d{8}$/u.test(date)) throw new Error("UTC date must use YYYYMMDD");
  if (attempt > 99) throw new Error("GitHub run attempt exceeds the reserved two digits");

  if (platform === "ios") {
    if (run > 99_999_999) throw new Error("GitHub run number exceeds the reserved eight digits");
    return `${date}${String(run).padStart(8, "0")}${String(attempt).padStart(2, "0")}`;
  }
  if (platform === "android") {
    const versionCode = 100_000 + run * 100 + attempt;
    if (versionCode > 2_100_000_000) {
      throw new Error("Android version code exceeds Google Play's supported maximum");
    }
    return String(versionCode);
  }
  throw new Error(`Unsupported platform: ${platform}`);
}

function positiveInteger(value, label) {
  const parsed = Number(value);
  if (!Number.isSafeInteger(parsed) || parsed <= 0) throw new Error(`${label} must be a positive integer`);
  return parsed;
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
      console.log("Usage: node tool/platform/compute_mobile_build_number.mjs --platform <ios|android> --utc-date YYYYMMDD --run-number N --run-attempt N");
      process.exit(0);
    }
    const result = computeMobileBuildNumber({
      platform: valueAfter(args, "--platform"),
      utcDate: valueAfter(args, "--utc-date"),
      runNumber: valueAfter(args, "--run-number"),
      runAttempt: valueAfter(args, "--run-attempt"),
    });
    console.log(result);
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}
