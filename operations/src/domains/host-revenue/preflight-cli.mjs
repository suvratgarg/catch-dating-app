#!/usr/bin/env node
import {constants} from "node:fs";
import {open} from "node:fs/promises";
import {pathToFileURL} from "node:url";
import {resolve} from "node:path";
import {MAX_INPUT_BYTES, createRevenuePreflight} from "./preflight.mjs";

const usage = "Usage: npm --prefix operations run revenue:preflight -- --input /absolute/path/normalized.json --policy /absolute/path/private-policy.json [--pretty]";

export async function main(argv) {
  if (argv.length === 1 && ["help", "--help", "-h"].includes(argv[0])) return usage;
  let inputPath;
  let policyPath;
  let pretty = false;
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === "--input" && !inputPath && i + 1 < argv.length) {
      inputPath = resolve(argv[++i]);
    } else if (argv[i] === "--policy" && !policyPath && i + 1 < argv.length) {
      policyPath = resolve(argv[++i]);
    } else if (argv[i] === "--pretty" && !pretty) {
      pretty = true;
    } else {
      throw new Error(usage);
    }
  }
  if (!inputPath || !policyPath) throw new Error(usage);
  const file = await open(inputPath, constants.O_RDONLY | constants.O_NOFOLLOW | constants.O_NONBLOCK);
  let bytes;
  try { bytes = await readBoundedInput(file); } finally { await file.close(); }
  const policyFile = await open(policyPath, constants.O_RDONLY | constants.O_NOFOLLOW | constants.O_NONBLOCK);
  let policyBytes;
  try { policyBytes = await readBoundedInput(policyFile); } finally { await policyFile.close(); }
  const policy = JSON.parse(new TextDecoder("utf-8", {fatal: true}).decode(policyBytes));
  return JSON.stringify(createRevenuePreflight(policy).preflightJson(bytes), null, pretty ? 2 : 0);
}

export async function readBoundedInput(file) {
  const metadata = await file.stat();
  if (!metadata.isFile()) throw new Error("Input must name a regular file.");
  if (metadata.size > MAX_INPUT_BYTES) throw new Error(`Input exceeds ${MAX_INPUT_BYTES} bytes.`);
  const buffer = Buffer.allocUnsafe(MAX_INPUT_BYTES + 1);
  let length = 0;
  while (length < buffer.length) {
    const {bytesRead} = await file.read(buffer, length, buffer.length - length, null);
    if (bytesRead === 0) break;
    length += bytesRead;
  }
  if (length > MAX_INPUT_BYTES) throw new Error(`Input exceeds ${MAX_INPUT_BYTES} bytes.`);
  return buffer.subarray(0, length);
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  main(process.argv.slice(2)).then((output) => {
    process.stdout.write(`${output}\n`);
  }).catch((error) => {
    process.stderr.write(`${JSON.stringify({error: error.message, effectsApplied: false,
      runtimeAuthority: "read_only"})}\n`);
    process.exitCode = 1;
  });
}
