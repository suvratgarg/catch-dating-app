#!/usr/bin/env node
import {surfaceFromUrl} from "./lib/platform_adapters.mjs";

const argv = process.argv.slice(2);
const url = argv.find((arg) => !arg.startsWith("--"));
const flags = parseFlags(argv);

if (!url || flags.help) {
  printHelp();
  process.exit(url ? 0 : 64);
}

try {
  const surface = surfaceFromUrl(url, {
    surfaceId: flags["surface-id"] ?? undefined,
    role: flags.role ?? undefined,
    status: flags.status ?? undefined,
  });

  assertExpected(surface, flags);
  console.log(`${stableStringify(surface)}\n`);
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
}

function assertExpected(surface, flags) {
  const expected = {
    platform: flags["expect-platform"],
    surfaceKind: flags["expect-kind"],
    normalizedKey: flags["expect-key"],
  };
  for (const [field, value] of Object.entries(expected)) {
    if (!value) continue;
    if (surface[field] !== value) {
      throw new Error(`Expected ${field}=${value}; received ${surface[field] ?? "null"}.`);
    }
  }
}

function parseFlags(args) {
  const flags = {};
  for (let index = 0; index < args.length; index += 1) {
    const arg = args[index];
    if (!arg.startsWith("--")) continue;
    const key = arg.slice(2);
    if (["help", "h"].includes(key)) {
      flags.help = true;
      continue;
    }
    const next = args[index + 1];
    if (!next || next.startsWith("--")) {
      flags[key] = true;
      continue;
    }
    flags[key] = next;
    index += 1;
  }
  return flags;
}

function printHelp() {
  console.log(`Usage:
  node tool/organizer_intake/normalize_surface_url.mjs <url> [flags]

Flags:
  --surface-id <id>        Override the generated surfaceId.
  --role <role>            Override the default surface role.
  --status <status>        Override the default surface status.
  --expect-platform <id>   Fail if the normalized platform differs.
  --expect-kind <kind>     Fail if the normalized surfaceKind differs.
  --expect-key <key>       Fail if the normalizedKey differs.
`);
}

function stableStringify(value) {
  return JSON.stringify(sortValue(value), null, 2);
}

function sortValue(value) {
  if (Array.isArray(value)) return value.map(sortValue);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([key, nested]) => [key, sortValue(nested)])
    );
  }
  return value;
}
