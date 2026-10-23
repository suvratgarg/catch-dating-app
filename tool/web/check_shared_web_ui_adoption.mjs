#!/usr/bin/env node
// React component inventory gate (UI blueprint Phase 7d). Every exported
// React component in website/, admin/ and packages/web-ui maps to a registry
// concept, a T4 owner or deletion, measured from the TypeScript reference
// graph; judgments are recorded in the website and admin registries. The
// generated inventory is written only to ignored local output.
import fs from "node:fs";
import path from "node:path";
import {fromRepo, repoRoot} from "../lib/repo_paths.mjs";
import {buildReactComponentGraph} from "./lib/react_component_graph.mjs";
import {buildReactComponentInventory} from "./lib/react_component_inventory.mjs";
import {graphProbeProblems, inventoryProbeProblems} from "./lib/react_component_inventory_probes.mjs";

const inventoryOutput = "build/react_component_inventory.json";
const args = new Set(process.argv.slice(2));
const allowed = new Set(["--check", "--self-test", "--json", "--write"]);
const unknown = [...args].filter((arg) => !allowed.has(arg));
if (unknown.length > 0) {
  console.error(`Unknown argument(s): ${unknown.join(", ")}. Use --check, --self-test, --json or --write.`);
  process.exit(64);
}
if (args.has("--self-test")) {
  runSelfTest();
  process.exit(0);
}

const readJson = (relativePath) => JSON.parse(fs.readFileSync(fromRepo(relativePath), "utf8"));
const inventory = buildReactComponentInventory({
  graph: buildReactComponentGraph({repoRoot}),
  registry: readJson("design/components/catch.components.json"),
  surfaceRegistries: {
    website: readJson("design/website/components.json"),
    admin: readJson("design/admin/components.json"),
  },
});
const findings = [
  ...inventory.problems,
  ...productionShellProblems(inventory),
  ...validateRequiredSourceContracts(),
];

if (args.has("--json")) {
  process.stdout.write(`${JSON.stringify(inventory, null, 2)}\n`);
}
if (args.has("--write")) {
  fs.mkdirSync(path.dirname(fromRepo(inventoryOutput)), {recursive: true});
  fs.writeFileSync(fromRepo(inventoryOutput), `${JSON.stringify(inventory, null, 2)}\n`);
}
if (findings.length > 0) {
  console.error(`React component inventory check failed (${findings.length} finding(s)):`);
  findings.forEach((finding) => console.error(`- ${finding}`));
  process.exit(1);
}
if (!args.has("--json")) {
  console.log(
    `React component inventory check passed: ${inventory.rows.length} exported components, 0 unmapped ` +
    `(${formatSummary(inventory.summary)}).` +
    (args.has("--write") ? ` Wrote ${inventoryOutput}.` : ""),
  );
}

/**
 * The Next App Router routes in website/app render these website/src
 * components on catchdates.com; a deletion verdict for one means the graph
 * lost its consumer roots.
 */
function productionShellProblems({rows}) {
  const shell = [
    "website/src/app/next/PublicPage.tsx::PublicPage",
    "website/src/app/next/PublicProviders.tsx::PublicProviders",
  ];
  return shell.flatMap((id) => {
    const row = rows.find((candidate) => candidate.id === id);
    if (!row) return [`${id}: missing from the inventory; update the production shell list`];
    return row.mapping?.kind === "delete"
      ? [`${id}: classified as dead although website/app renders it in production`]
      : [];
  });
}

function validateRequiredSourceContracts(readSource = readRepoSource) {
  const contracts = [
    {
      path: "packages/web-config/styles/catch-web.css",
      includes: ["--catch-focus-ring-color", ":focus-visible"],
    },
    {
      path: "packages/web-ui/src/primitives.tsx",
      includes: ["role=\"region\"", "ariaLabel", "aria-busy", "aria-invalid"],
    },
    {
      path: "website/src/styles/home.css",
      includes: [".public-search__input:focus-within"],
    },
    {
      path: "admin/src/styles.css",
      includes: [".search-control:focus-within", ".marketing-title-input:focus-visible"],
    },
  ];
  const findings = [];
  for (const contract of contracts) {
    const source = readSource(contract.path);
    for (const expected of contract.includes) {
      if (!source.includes(expected)) {
        findings.push(`${contract.path}: missing shared web contract marker ${expected}`);
      }
    }
  }
  findings.push(...validateWorkflowContracts(readSource));
  return findings;
}

function validateWorkflowContracts(readSource = readRepoSource) {
  const reusableWorkflow = ".github/workflows/react-surface-validation.yml";
  const contracts = [
    {
      path: reusableWorkflow,
      includes: [
        "workflow_call:",
        "npm run web:shared-ui-adoption:check",
        "npm run web:ui:test && npm run web:ui:typecheck",
      ],
    },
    {
      path: ".github/workflows/marketing-website.yml",
      includes: [
        "packages/web-ui/**",
        reusableWorkflow,
        `uses: ./${reusableWorkflow}`,
        "surface: marketing",
      ],
    },
    {
      path: ".github/workflows/admin-website.yml",
      includes: [
        "packages/web-ui/**",
        reusableWorkflow,
        `uses: ./${reusableWorkflow}`,
        "surface: admin",
      ],
    },
  ];
  const findings = [];
  for (const contract of contracts) {
    const source = readSource(contract.path);
    for (const expected of contract.includes) {
      if (!source.includes(expected)) {
        findings.push(`${contract.path}: missing shared web contract marker ${expected}`);
      }
    }
  }
  return findings;
}

function readRepoSource(relativePath) {
  return fs.readFileSync(fromRepo(relativePath), "utf8");
}

function runSelfTest() {
  const probeProblems = [...graphProbeProblems(), ...inventoryProbeProblems()];
  if (probeProblems.length > 0) {
    throw new Error(`inventory self-test failed:\n${probeProblems.join("\n")}`);
  }
  const workflowSources = new Map([
    [".github/workflows/react-surface-validation.yml", "workflow_call:\nrun: npm run web:shared-ui-adoption:check\n"],
    [".github/workflows/marketing-website.yml",
      "packages/web-ui/**\n.github/workflows/react-surface-validation.yml\nuses: ./.github/workflows/react-surface-validation.yml\nsurface: marketing\n"],
    [".github/workflows/admin-website.yml",
      "packages/web-ui/**\n.github/workflows/react-surface-validation.yml\nuses: ./.github/workflows/react-surface-validation.yml\nsurface: admin\n"],
  ]);
  const deadShell = productionShellProblems({rows: [
    {id: "website/src/app/next/PublicPage.tsx::PublicPage", mapping: {kind: "delete", reason: "no production consumer"}},
    {id: "website/src/app/next/PublicProviders.tsx::PublicProviders", mapping: {kind: "t4", owner: "website:app"}},
  ]});
  if (deadShell.length !== 1 || !deadShell[0].includes("PublicPage")) {
    throw new Error("self-test failed to reject a dead verdict for the Next App Router shell");
  }
  const workflowFindings = validateWorkflowContracts((relativePath) => workflowSources.get(relativePath) ?? "");
  if (!workflowFindings.some((finding) => finding.includes("npm run web:ui:test && npm run web:ui:typecheck"))) {
    throw new Error("self-test failed to reject a reusable workflow missing shared UI validation");
  }
  console.log("React component inventory self-test passed.");
}

function formatSummary(summary) {
  return Object.entries(summary)
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([surface, counts]) => `${surface} ${Object.entries(counts)
      .sort(([left], [right]) => left.localeCompare(right))
      .map(([kind, count]) => `${kind}=${count}`).join(" ")}`)
    .join("; ");
}
