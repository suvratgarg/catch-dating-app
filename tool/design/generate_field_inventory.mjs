#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

import {fromRepo} from "../lib/repo_paths.mjs";

const DEFAULT_SOURCE = "lib/core/widgets/catch_field.dart";
const DEFAULT_SECTION_SOURCE = "lib/core/widgets/catch_section_layout.dart";
const DEFAULT_CONTRACTS = "design/components/catch.components.json";
const DEFAULT_OUTPUT = "docs/audit_registry/field_facade_inventory.json";

export const facadeUseWhen = Object.freeze({
  read: "Display a non-interactive value row with optional validity and save status.",
  content: "Display title and supporting copy as a stable content row with an optional action.",
  nav: "Open another destination or picker from a row that may show a current value.",
  action: "Run a non-navigation row action without implying inline value editing.",
  toggle: "Edit one boolean value with a row-owned toggle control.",
  input: "Edit text directly in a field with validation, helper copy, and optional adornments.",
  control: "Reveal a caller-supplied inline control while the field owns disclosure and commit chrome.",
  choices: "Choose terse single- or multi-select labels in a field-owned disclosure control.",
  optionCards: "Choose one explanatory option when each choice needs a title and supporting description.",
  stepper: "Edit a bounded numeric value with the canonical decrement and increment control.",
  inputActions: "Edit text in a controlled disclosure row with explicit cancel and submit actions.",
  add: "Offer a compact field-shaped action for adding a missing value or item.",
  select: "Choose one value from a conventional select control with field-owned label and support copy.",
});

export const forbiddenSurfaces = Object.freeze([
  {
    id: "browse",
    reason: "Browse surfaces tell a product story and must use their owning editorial or card composition.",
  },
  {
    id: "discovery",
    reason: "Discovery surfaces must preserve their feed and recommendation hierarchy instead of adopting form chrome.",
  },
  {
    id: "celebration",
    reason: "Celebration surfaces use outcome-specific composition rather than data-management fields and sections.",
  },
  {
    id: "insight-scorecard",
    reason: "Insight and scorecard surfaces communicate analysis and must not be flattened into form rows.",
  },
]);

const slotByParameter = Object.freeze({
  title: "title",
  body: "body",
  leading: "leading",
  leadingExtent: "leading",
  icon: "leading",
  iconColor: "leading",
  leadingUnit: "leading",
  value: "value",
  valueText: "value",
  selected: "value",
  initialValue: "value",
  controller: "value",
  placeholder: "placeholder",
  emptyValueText: "placeholder",
  hintText: "placeholder",
  inputHint: "placeholder",
  control: "control",
  values: "control",
  itemLabel: "control",
  itemTitle: "control",
  itemDescription: "control",
  helperText: "support",
  helperTone: "support",
  supporting: "support",
  badgeLabel: "badge",
  badgeTone: "badge",
  action: "action",
  prefixIcon: "prefix",
  prefixText: "prefix",
  suffixIcon: "suffix",
  suffixText: "suffix",
  secondaryAction: "actions",
  feedback: "feedback",
  status: "status",
  valid: "status",
  isLoading: "status",
  error: "error",
  errorText: "error",
  validator: "error",
  onCancel: "actions",
  onSubmit: "actions",
});

const slotOrder = Object.freeze([
  "title",
  "body",
  "leading",
  "value",
  "placeholder",
  "control",
  "support",
  "badge",
  "action",
  "prefix",
  "suffix",
  "feedback",
  "status",
  "error",
  "actions",
]);

const sectionSlotByParameter = Object.freeze({
  title: "title",
  subtitle: "subtitle",
  trailing: "trailing",
  count: "count",
  footer: "footer",
  children: "children",
  child: "child",
});

const sectionSlotOrder = Object.freeze([
  "title",
  "subtitle",
  "trailing",
  "count",
  "footer",
  "children",
  "child",
]);

export function extractCatchFieldFacades(source, {useWhen = facadeUseWhen} = {}) {
  const declarations = [
    ...extractDeclarations(
      source,
      /\bconst\s+factory\s+CatchField\.([A-Za-z][A-Za-z0-9_]*)\s*\(/gu,
      "factory",
      "CatchField",
    ),
    ...extractDeclarations(
      source,
      /\bstatic\s+CatchField\s+([A-Za-z][A-Za-z0-9_]*)(?:<[^>{}()]+>)?\s*\(/gu,
      "static-facade",
      "CatchField",
    ),
  ].sort((left, right) => left.offset - right.offset);

  if (declarations.length === 0) {
    throw new Error("No public CatchField facades were found.");
  }

  const seen = new Set();
  return declarations.map(({name, kind, parameters}) => {
    if (seen.has(name)) throw new Error(`Duplicate CatchField facade: ${name}`);
    seen.add(name);
    if (!useWhen[name]) {
      throw new Error(`CatchField.${name} is missing owner-reviewed use-when metadata.`);
    }
    const observedSlots = new Set(
      parameters.map((parameter) => slotByParameter[parameter.name]).filter(Boolean),
    );
    return {
      facade: `CatchField.${name}`,
      mode: name,
      kind,
      parameters,
      slots: slotOrder.filter((slot) => observedSlots.has(slot)),
      useWhen: useWhen[name],
    };
  });
}

export function extractCatchSectionVariants(source) {
  return extractCatchSectionContract(source).variants;
}

export function extractCatchSectionContract(source) {
  const declarations = extractDeclarations(
    source,
    /\bconst\s+CatchSection\.([A-Za-z][A-Za-z0-9_]*)\s*\(/gu,
    "constructor",
    "CatchSection",
  ).filter((declaration) => !declaration.name.startsWith("_"));
  if (declarations.length === 0) throw new Error("No public CatchSection variants were found.");
  const observedSlots = new Set(
    declarations.flatMap((declaration) =>
      declaration.parameters
        .map((parameter) => sectionSlotByParameter[parameter.name])
        .filter(Boolean),
    ),
  );
  return {
    variants: declarations.map((declaration) => declaration.name),
    slots: sectionSlotOrder.filter((slot) => observedSlots.has(slot)),
  };
}

export function buildFieldFacadeInventory({
  fieldSource,
  sectionSource,
  interactionContracts,
  sourcePath = DEFAULT_SOURCE,
  sectionSourcePath = DEFAULT_SECTION_SOURCE,
} = {}) {
  const facades = extractCatchFieldFacades(fieldSource);
  const section = extractCatchSectionContract(sectionSource);
  const saveStates = extractEnumValues(fieldSource, "CatchFieldStatus");
  const fieldContract = interactionContracts?.field_row;
  const sectionContract = interactionContracts?.field_section;
  if (!fieldContract || !sectionContract) {
    throw new Error("interactionContracts must define field_row and field_section.");
  }

  const modes = facades.map((entry) => entry.mode);
  const slots = slotOrder.filter((slot) => facades.some((entry) => entry.slots.includes(slot)));
  assertExactArray(fieldContract.modes, modes, "interactionContracts.field_row.modes");
  assertExactArray(fieldContract.slots, slots, "interactionContracts.field_row.slots");
  assertExactArray(
    fieldContract.saveStates,
    saveStates,
    "interactionContracts.field_row.saveStates",
  );
  assertExactArray(
    sectionContract.variants,
    section.variants,
    "interactionContracts.field_section.variants",
  );
  assertExactArray(
    sectionContract.slots,
    section.slots,
    "interactionContracts.field_section.slots",
  );

  return {
    schemaVersion: 1,
    generatedBy: "tool/design/generate_field_inventory.mjs",
    source: {
      catchField: sourcePath,
      catchFieldApiSha256: sha256(JSON.stringify(facades)),
      catchSection: sectionSourcePath,
      catchSectionApiSha256: sha256(JSON.stringify(section)),
      interactionContracts: DEFAULT_CONTRACTS,
    },
    summary: {
      facadeCount: facades.length,
      modeCount: modes.length,
      slotCount: slots.length,
      saveStateCount: saveStates.length,
      sectionVariantCount: section.variants.length,
      forbiddenSurfaceCount: forbiddenSurfaces.length,
    },
    forbiddenSurfaces,
    facades,
  };
}

export function buildFromRepo({repoRoot = process.cwd()} = {}) {
  const fieldSource = fs.readFileSync(path.resolve(repoRoot, DEFAULT_SOURCE), "utf8");
  const sectionSource = fs.readFileSync(path.resolve(repoRoot, DEFAULT_SECTION_SOURCE), "utf8");
  const componentContracts = JSON.parse(
    fs.readFileSync(path.resolve(repoRoot, DEFAULT_CONTRACTS), "utf8"),
  );
  return buildFieldFacadeInventory({
    fieldSource,
    sectionSource,
    interactionContracts: componentContracts.interactionContracts,
  });
}

function extractDeclarations(source, expression, kind, owner) {
  const declarations = [];
  for (const match of source.matchAll(expression)) {
    const openIndex = match.index + match[0].lastIndexOf("(");
    const closeIndex = findMatching(source, openIndex, "(", ")");
    const body = source.slice(openIndex + 1, closeIndex).trim();
    if (!body.startsWith("{") || !body.endsWith("}")) {
      throw new Error(`${owner}.${match[1]} must use named parameters.`);
    }
    declarations.push({
      name: match[1],
      kind,
      offset: match.index,
      parameters: splitParameters(body.slice(1, -1)).map(parseParameter),
    });
  }
  return declarations;
}

function extractEnumValues(source, enumName) {
  const expression = new RegExp(`\\benum\\s+${enumName}\\s*\\{([^}]*)\\}`, "u");
  const body = source.match(expression)?.[1];
  if (!body) throw new Error(`Unable to find enum ${enumName}.`);
  const values = body
    .split(",")
    .map((value) => value.trim())
    .filter(Boolean);
  if (values.some((value) => !/^[A-Za-z_][A-Za-z0-9_]*$/u.test(value))) {
    throw new Error(`Unable to parse enum ${enumName}.`);
  }
  return values;
}

function findMatching(source, start, open, close) {
  let depth = 0;
  let quote = null;
  for (let index = start; index < source.length; index += 1) {
    const character = source[index];
    if (quote) {
      if (character === "\\") index += 1;
      else if (character === quote) quote = null;
      continue;
    }
    if (character === "'" || character === '"') {
      quote = character;
      continue;
    }
    if (character === open) depth += 1;
    if (character === close) depth -= 1;
    if (depth === 0) return index;
  }
  throw new Error(`Unbalanced ${open}${close} declaration.`);
}

function splitParameters(source) {
  const parts = [];
  let start = 0;
  let round = 0;
  let square = 0;
  let angle = 0;
  for (let index = 0; index < source.length; index += 1) {
    const character = source[index];
    if (character === "(") round += 1;
    else if (character === ")") round -= 1;
    else if (character === "[") square += 1;
    else if (character === "]") square -= 1;
    else if (character === "<") angle += 1;
    else if (character === ">") angle = Math.max(0, angle - 1);
    else if (character === "," && round === 0 && square === 0 && angle === 0) {
      const part = source.slice(start, index).trim();
      if (part) parts.push(part);
      start = index + 1;
    }
  }
  const last = source.slice(start).trim();
  if (last) parts.push(last);
  return parts;
}

function parseParameter(source) {
  const equalsIndex = source.indexOf("=");
  const declaration = (equalsIndex === -1 ? source : source.slice(0, equalsIndex)).trim();
  const name = declaration.match(/([A-Za-z_][A-Za-z0-9_]*)\s*$/u)?.[1];
  if (!name) throw new Error(`Unable to parse CatchField parameter: ${source}`);
  return {
    name,
    required: /^required\b/u.test(declaration),
    hasDefault: equalsIndex !== -1,
  };
}

function assertExactArray(actual, expected, label) {
  if (!Array.isArray(actual) || JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `${label} drifted from the Flutter API. Expected ${JSON.stringify(expected)}, received ${JSON.stringify(actual)}.`,
    );
  }
}

function sha256(source) {
  return crypto.createHash("sha256").update(source).digest("hex");
}

function serialize(value) {
  return `${JSON.stringify(value, null, 2)}\n`;
}

function runCli(argv) {
  const check = argv.includes("--check");
  const unknown = argv.filter((arg) => arg !== "--check");
  if (unknown.length > 0) {
    console.error(`Unknown argument: ${unknown[0]}`);
    process.exit(64);
  }
  const outputPath = fromRepo(DEFAULT_OUTPUT);
  const expected = serialize(buildFromRepo({repoRoot: fromRepo(".")}));
  if (check) {
    const actual = fs.existsSync(outputPath) ? fs.readFileSync(outputPath, "utf8") : "";
    if (actual !== expected) {
      console.error(`${DEFAULT_OUTPUT} is stale. Run node tool/design/generate_field_inventory.mjs.`);
      process.exit(1);
    }
    console.log("Field facade inventory is current.");
    return;
  }
  fs.writeFileSync(outputPath, expected);
  console.log(`Wrote ${DEFAULT_OUTPUT}.`);
}

if (process.argv[1] && fileURLToPath(import.meta.url) === path.resolve(process.argv[1])) {
  runCli(process.argv.slice(2));
}
