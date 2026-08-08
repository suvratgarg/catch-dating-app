import {parseArgs as parseNodeArgs} from "node:util";
import {pathToFileURL} from "node:url";

const booleanOptions = ["apply", "allow-prod", "confirm-prod", "json", "help", "emulator"];
const valueOptions = ["env", "project", "emulator-host"];
const standardOptionNames = new Set([...booleanOptions, ...valueOptions]);

export function parseCommonArgs(argv, {booleanFlags = [], valueFlags = []} = {}) {
  const options = Object.fromEntries([
    ...booleanOptions.map((name) => [name, {type: "boolean", ...(name === "help" ? {short: "h"} : {})}]),
    ...valueOptions.map((name) => [name, {type: "string"}]),
    ...booleanFlags.map((flag) => [optionName(flag), {type: "boolean"}]),
    ...valueFlags.map((flag) => [optionName(flag), {type: "string"}]),
  ]);
  const {values, positionals, tokens} = parseNodeArgs({
    args: argv,
    options,
    allowPositionals: true,
    strict: true,
    tokens: true,
  });
  const parsed = {
    env: values.env ?? null,
    project: values.project ?? null,
    emulatorHost: null,
    apply: values.apply ?? false,
    allowProd: values["allow-prod"] ?? false,
    confirmProd: values["confirm-prod"] ?? false,
    json: values.json ?? false,
    help: values.help ?? false,
    positionals,
  };

  for (const token of tokens) {
    if (token.kind !== "option") continue;
    if (token.name === "emulator") {
      parsed.emulatorHost = "127.0.0.1:8080";
    } else if (token.name === "emulator-host") {
      parsed.emulatorHost = token.value;
    } else if (!standardOptionNames.has(token.name)) {
      parsed[token.name.replaceAll("-", "_")] = token.value ?? true;
    }
  }

  return parsed;
}

function optionName(flag) {
  if (typeof flag !== "string" || !/^--[a-z][a-z0-9-]*$/u.test(flag)) {
    throw new Error(`Common CLI option must be a long flag: ${flag}`);
  }
  return flag.slice(2);
}

export function isMain(importMetaUrl) {
  return process.argv[1] && importMetaUrl === pathToFileURL(process.argv[1]).href;
}
