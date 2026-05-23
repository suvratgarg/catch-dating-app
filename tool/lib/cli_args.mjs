export function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    throw new Error(`${flag} requires a value.`);
  }
  return value;
}

export function parseCommonArgs(argv, {booleanFlags = [], valueFlags = []} = {}) {
  const parsed = {
    env: null,
    project: null,
    emulatorHost: null,
    apply: false,
    allowProd: false,
    confirmProd: false,
    json: false,
    help: false,
    positionals: [],
  };
  const booleans = new Set([
    "--apply",
    "--allow-prod",
    "--confirm-prod",
    "--json",
    "--help",
    "-h",
    "--emulator",
    ...booleanFlags,
  ]);
  const values = new Set([
    "--env",
    "--project",
    "--emulator-host",
    ...valueFlags,
  ]);

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--apply") parsed.apply = true;
    else if (arg === "--allow-prod") parsed.allowProd = true;
    else if (arg === "--confirm-prod") parsed.confirmProd = true;
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--emulator") parsed.emulatorHost = "127.0.0.1:8080";
    else if (values.has(arg)) {
      const value = requireValue(argv, ++i, arg);
      if (arg === "--env") parsed.env = value;
      else if (arg === "--project") parsed.project = value;
      else if (arg === "--emulator-host") parsed.emulatorHost = value;
      else parsed[arg.replace(/^--/, "").replaceAll("-", "_")] = value;
    } else if (booleans.has(arg)) {
      parsed[arg.replace(/^--/, "").replaceAll("-", "_")] = true;
    } else if (arg.startsWith("--")) {
      throw new Error(`Unknown argument: ${arg}`);
    } else {
      parsed.positionals.push(arg);
    }
  }

  return parsed;
}

export function isMain(importMetaUrl) {
  return process.argv[1] && importMetaUrl === pathToFileURL(process.argv[1]).href;
}
import {pathToFileURL} from "node:url";
