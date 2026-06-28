#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo, relativeToRepo, repoRoot} from "../lib/repo_paths.mjs";

const componentRegistryPath = fromRepo("design/components/catch.components.json");
const stateMatrixPath = fromRepo("docs/design_parity/state_matrix.json");
const screenContractsPath = fromRepo("design/screens/catch.screens.json");
const widgetbookDirectoriesPath = fromRepo("widgetbook/lib/main.directories.g.dart");
const widgetbookPrimitiveContractsPath = fromRepo("widgetbook/lib/primitives/primitive_contract_use_cases.dart");
const requiredFoundationSpecimens = [
  {
    component: "FoundationColorTokens",
    useCase: "Color roles",
    builder: "foundationColorRoles",
  },
  {
    component: "FoundationSpacingTokens",
    useCase: "Spacing and layout",
    builder: "foundationSpacingAndLayout",
  },
  {
    component: "FoundationShapeTokens",
    useCase: "Radius elevation opacity",
    builder: "foundationShapeTokens",
  },
  {
    component: "FoundationTypographyTokens",
    useCase: "Typography roles",
    builder: "foundationTypographyRoles",
  },
  {
    component: "FoundationIconMediaTokens",
    useCase: "Icons and media geometry",
    builder: "foundationIconMediaTokens",
  },
  {
    component: "FoundationStrokeMotionTokens",
    useCase: "Stroke and motion",
    builder: "foundationStrokeMotionTokens",
  },
  {
    component: "FoundationDataPhotoTokens",
    useCase: "Data pairs and photo grade",
    builder: "foundationDataPhotoTokens",
  },
  {
    component: "FoundationBrandTokens",
    useCase: "Wordmark",
    builder: "foundationBrandTokens",
  },
];

const args = process.argv.slice(2);
const command = args[0] ?? "--help";

if (command === "--help" || command === "-h" || command === "help") {
  printHelp();
} else if (command === "--check" || command === "check") {
  checkRefs();
} else if (command === "--summary" || command === "summary") {
  checkRefs({summary: true});
} else {
  console.error(`Unknown command: ${command}`);
  printHelp();
  process.exit(64);
}

function checkRefs({summary = false} = {}) {
  const componentRegistry = readJson(componentRegistryPath);
  const stateMatrix = readJson(stateMatrixPath);
  const screenContracts = readJson(screenContractsPath);
  const widgetbookSource = fs.readFileSync(widgetbookDirectoriesPath, "utf8");
  const primitiveContractSource = fs.readFileSync(widgetbookPrimitiveContractsPath, "utf8");
  const widgetbook = parseWidgetbookDirectories(widgetbookSource);
  const primitiveContracts = parsePrimitiveContractUseCases(primitiveContractSource);

  const errors = [
    ...validateComponentPreviews(componentRegistry, widgetbook),
    ...validatePrimitiveContractUseCases(componentRegistry, primitiveContracts),
    ...validateFoundationSpecimens(widgetbook),
    ...validatePreviewRefs({
      stateMatrix,
      screenContracts,
      widgetbook,
    }),
  ];

  if (summary || errors.length === 0) {
    console.log(
      [
        `Widgetbook contract refs: ${relativeToRepo(widgetbookDirectoriesPath)}`,
        `Components: ${widgetbook.componentNames.size}`,
        `Use case builders: ${widgetbook.builderNames.size}`,
        `Formal primitive contract previews: ${primitiveContracts.contractIds.size}`,
        `Required foundation specimens: ${requiredFoundationSpecimens.length}`,
        `Referenced preview ids: ${collectPreviewRefs(stateMatrix, screenContracts).length}`,
      ].join("\n")
    );
  }

  if (errors.length > 0) {
    console.error("Widgetbook contract reference check failed:");
    for (const error of errors) console.error(`- ${error}`);
    process.exit(1);
  }
}

function validateComponentPreviews(componentRegistry, widgetbook) {
  const errors = [];
  for (const component of componentRegistry.components ?? []) {
    const symbol = component.dart?.symbol;
    if (!symbol) continue;
    if (!widgetbook.componentNames.has(symbol)) {
      errors.push(`${component.id}: missing Widgetbook component for Dart symbol ${symbol}.`);
    }
  }
  return errors;
}

function validatePrimitiveContractUseCases(componentRegistry, primitiveContracts) {
  const errors = [];
  const contractEntries = collectComponentContractEntries(componentRegistry);
  const componentIds = new Set(contractEntries.map((entry) => entry.id));
  const componentSymbols = new Set(contractEntries.map((entry) => entry.symbol).filter(Boolean));

  for (const entry of contractEntries) {
    if (entry.primary && !primitiveContracts.contractIds.has(entry.id)) {
      errors.push(
        `${entry.id}: missing formal Widgetbook primitive contract preview in ${relativeToRepo(widgetbookPrimitiveContractsPath)}.`
      );
    }
    const expectedStates = entry.states ?? [];
    const actualStates = primitiveContracts.statesByContractId.get(entry.id);
    if (actualStates) {
      const expected = expectedStates.join(",");
      const actual = actualStates.join(",");
      if (actual !== expected) {
        errors.push(
          `${entry.id}: Widgetbook contract states [${actual}] do not match component contract states [${expected}].`
        );
      }
    }
    if (entry.primary && entry.symbol && !primitiveContracts.types.has(entry.symbol)) {
      errors.push(
        `${entry.id}: formal Widgetbook primitive contract preview is missing @UseCase type ${entry.symbol}.`
      );
    }
  }

  for (const contractId of primitiveContracts.contractIds) {
    if (!componentIds.has(contractId)) {
      errors.push(
        `${relativeToRepo(widgetbookPrimitiveContractsPath)}: contractId ${contractId} is not declared in ${relativeToRepo(componentRegistryPath)}.`
      );
    }
  }
  for (const type of primitiveContracts.types) {
    if (!componentSymbols.has(type)) {
      errors.push(
        `${relativeToRepo(widgetbookPrimitiveContractsPath)}: @UseCase type ${type} is not declared as a component contract Dart symbol.`
      );
    }
  }

  return errors;
}

function collectComponentContractEntries(componentRegistry) {
  const entries = [];
  for (const component of componentRegistry.components ?? []) {
    entries.push({
      id: component.id,
      symbol: component.dart?.symbol,
      states: component.contract?.states ?? [],
      parentId: component.id,
      primary: true,
    });
    for (const member of component.contract?.members ?? []) {
      entries.push({
        id: member.id,
        symbol: member.symbol,
        states: member.states ?? [],
        parentId: component.id,
        primary: false,
      });
    }
  }
  return entries;
}

function validateFoundationSpecimens(widgetbook) {
  const errors = [];
  for (const specimen of requiredFoundationSpecimens) {
    if (!widgetbook.componentNames.has(specimen.component)) {
      errors.push(
        `foundation.${slug(specimen.component)}: missing required Widgetbook foundation component ${specimen.component}.`
      );
    }
    if (!widgetbook.useCaseNames.has(specimen.useCase)) {
      errors.push(
        `foundation.${slug(specimen.component)}: missing required Widgetbook foundation use case "${specimen.useCase}".`
      );
    }
    if (!widgetbook.builderNames.has(specimen.builder)) {
      errors.push(
        `foundation.${slug(specimen.component)}: missing required Widgetbook foundation builder ${specimen.builder}.`
      );
    }
  }
  return errors;
}

function validatePreviewRefs({stateMatrix, screenContracts, widgetbook}) {
  const errors = [];
  for (const ref of collectPreviewRefs(stateMatrix, screenContracts)) {
    if (!widgetbook.acceptedPreviewIds.has(ref.previewId)) {
      errors.push(`${ref.owner}: unknown Widgetbook previewId ${ref.previewId}.`);
    }
  }
  return errors;
}

function collectPreviewRefs(stateMatrix, screenContracts) {
  const refs = [];
  for (const feature of stateMatrix.features ?? []) {
    for (const screen of feature.screens ?? []) {
      for (const state of screen.states ?? []) {
        for (const previewId of state.previewIds ?? []) {
          refs.push({
            owner: `${feature.id}.${screen.id}.${state.id}`,
            previewId,
          });
        }
      }
    }
  }
  for (const screen of screenContracts.screens ?? []) {
    for (const state of screen.states ?? []) {
      for (const previewId of state.previewIds ?? []) {
        refs.push({owner: `${screen.id}.${state.id}`, previewId});
      }
    }
    for (const section of screen.composition?.sections ?? []) {
      for (const previewId of section.previewIds ?? []) {
        refs.push({owner: `${screen.id}.${section.id}`, previewId});
      }
    }
  }
  return refs;
}

function parseWidgetbookDirectories(source) {
  const componentNames = new Set(
    [...source.matchAll(/WidgetbookComponent\(\s*name: '([^']+)'/gu)].map(
      (match) => match[1]
    )
  );
  const useCaseNames = new Set(
    [...source.matchAll(/WidgetbookUseCase\(\s*name: '([^']+)'/gu)].map(
      (match) => match[1]
    )
  );
  const builderNames = new Set(
    [...source.matchAll(/builder:\s*[\s\S]*?\.([A-Za-z0-9_]+),/gu)].map(
      (match) => match[1]
    )
  );
  const acceptedPreviewIds = new Set(builderNames);

  for (const componentName of componentNames) {
    acceptedPreviewIds.add(componentName);
    acceptedPreviewIds.add(slug(componentName));
    for (const useCaseName of useCaseNames) {
      acceptedPreviewIds.add(`${componentName}/${useCaseName}`);
      acceptedPreviewIds.add(`${slug(componentName)}/${slug(useCaseName)}`);
    }
  }

  return {componentNames, useCaseNames, builderNames, acceptedPreviewIds};
}

function parsePrimitiveContractUseCases(source) {
  const statesByContractId = new Map();
  for (const block of extractCallBlocks(source, "_ContractScreen")) {
    const contractId = matchString(block, /\bcontractId:\s*'([^']+)'/u);
    const statesMatch =
      /\bstates:\s*(?:const\s*)?(?:<String>\s*)?\[([\s\S]*?)\]/u.exec(block);
    const statesBlock = statesMatch?.[1] ?? null;
    if (!contractId) continue;
    statesByContractId.set(contractId, parseStringList(statesBlock));
  }

  return {
    contractIds: new Set(
      [...source.matchAll(/contractId:\s*'([^']+)'/gu)].map((match) => match[1])
    ),
    types: new Set(
      [...source.matchAll(/@widgetbook\.UseCase\(\s*[\s\S]*?type:\s*([A-Za-z0-9_]+),/gu)].map(
        (match) => match[1]
      )
    ),
    statesByContractId,
  };
}

function parseStringList(value) {
  if (!value) return [];
  return [...value.matchAll(/'([^']+)'/gu)].map((match) => match[1]);
}

function matchString(source, pattern) {
  return pattern.exec(source)?.[1] ?? null;
}

function extractCallBlocks(source, callName) {
  const blocks = [];
  let searchIndex = 0;
  while (searchIndex < source.length) {
    const callIndex = source.indexOf(`${callName}(`, searchIndex);
    if (callIndex === -1) break;
    const openIndex = source.indexOf("(", callIndex);
    const endIndex = findBalancedEnd(source, openIndex, "(", ")");
    blocks.push(source.slice(callIndex, endIndex + 1));
    searchIndex = endIndex + 1;
  }
  return blocks;
}

function findBalancedEnd(source, openIndex, openChar, closeChar) {
  let depth = 0;
  let stringQuote = null;
  let escaped = false;
  for (let index = openIndex; index < source.length; index += 1) {
    const char = source[index];
    if (stringQuote) {
      if (escaped) {
        escaped = false;
      } else if (char === "\\") {
        escaped = true;
      } else if (char === stringQuote) {
        stringQuote = null;
      }
      continue;
    }
    if (char === "'" || char === '"') {
      stringQuote = char;
      continue;
    }
    if (char === openChar) depth += 1;
    if (char === closeChar) {
      depth -= 1;
      if (depth === 0) return index;
    }
  }
  throw new Error(`Could not find balanced ${openChar}${closeChar} block.`);
}

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch (error) {
    console.error(`Failed to parse ${path.relative(repoRoot, file)}: ${error.message}`);
    process.exit(1);
  }
}

function slug(value) {
  return value
    .replace(/([a-z0-9])([A-Z])/gu, "$1-$2")
    .replace(/[^A-Za-z0-9]+/gu, "-")
    .replace(/^-|-$/gu, "")
    .toLowerCase();
}

function printHelp() {
  console.log(`Usage:
  node tool/design/check_widgetbook_contract_refs.mjs --check
  node tool/design/check_widgetbook_contract_refs.mjs --summary

Validates that component contracts have Widgetbook component entries, formal
primitive contract previews with matching contract-state lists, and that any
previewIds declared by screen/state contracts refer to generated Widgetbook
components, use cases, or builder ids. Also validates that required
foundation-token specimen pages stay present in generated Widgetbook output.`);
}
