#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo} from "../lib/repo_paths.mjs";

const args = parseArgs(process.argv.slice(2));

const boundaryRules = [
  {
    id: "website-claim-route-state-owner",
    surface: "website",
    path: "website/src/features/claims/useClaimFlowController.ts",
    forbidden: [
      {
        pattern: /\bwindow\.location\b/u,
        description: "claim controller reads global window.location",
      },
      {
        pattern: /\buse(?:Location|Params|SearchParams)\b/u,
        description: "claim controller reads React Router state directly",
      },
      {
        pattern: /from\s+["'][^"']*organizers\/routing["']/u,
        description: "claim controller imports organizer routing helpers",
      },
      {
        pattern: /\bgetClaim(?:Listing|ListingLookup|RequestId)FromLocation\b/u,
        description: "claim controller parses URL state instead of receiving it",
      },
      {
        pattern: /\bclaimStateForLocation\b/u,
        description: "claim controller computes URL state instead of receiving it",
      },
    ],
    guidance:
      "Parse claim URL state in the React Router route shell and pass ClaimRouteState into useClaimFlowController.",
  },
  {
    id: "website-claim-routing-feature-owner",
    surface: "website",
    path: "website/src/features/organizers/routing.ts",
    forbidden: [
      {
        pattern: /\bClaimUrlState\b/u,
        description: "organizer routing exports claim URL state",
      },
      {
        pattern: /\bgetClaim(?:Listing|ListingLookup|RequestId)FromLocation\b/u,
        description: "organizer routing owns claim URL parsing",
      },
      {
        pattern: /\bclaimStateForLocation\b/u,
        description: "organizer routing owns claim URL status parsing",
      },
    ],
    guidance:
      "Keep organizer routing focused on organizer listing paths; claim URL parsing belongs in website/src/features/claims/claimRouting.ts.",
  },
  {
    id: "website-claim-section-routing-import",
    surface: "website",
    path: "website/src/features/claims/sections/ClaimPageSections.tsx",
    forbidden: [
      {
        pattern: /from\s+["'][^"']*organizers\/routing["']/u,
        description: "claim sections import organizer routing for claim URL types",
      },
    ],
    guidance:
      "Import claim route types from the claims feature, not from organizer routing.",
  },
];

const requiredRules = [
  {
    id: "website-claim-route-state-shell",
    surface: "website",
    path: "website/src/app/App.tsx",
    required: [
      {
        pattern: /\bclaimRouteStateForLocation\b/u,
        description: "React Router shell derives ClaimRouteState",
      },
      {
        pattern: /\buseParams\b/u,
        description: "React Router shell reads the claim listing path param",
      },
      {
        pattern: /<ClaimPage\b[\s\S]*\brouteState=/u,
        description: "ClaimPage receives explicit routeState",
      },
    ],
    guidance:
      "Claim route URL state must be read at the route shell and passed into ClaimPage.",
  },
  {
    id: "website-claim-routing-module",
    surface: "website",
    path: "website/src/features/claims/claimRouting.ts",
    required: [
      {
        pattern: /\bexport function claimRouteStateForLocation\b/u,
        description: "claims feature exposes the route-state parser",
      },
      {
        pattern: /\bexport interface ClaimRouteState\b/u,
        description: "claims feature owns the ClaimRouteState contract",
      },
    ],
    guidance:
      "Keep claim URL parsing and route-state contracts in the claims feature.",
  },
];

const selectedSurfaces = args.surface === "all" ? ["website", "admin"] : [args.surface];
const violations = [];

for (const rule of [...boundaryRules, ...requiredRules]) {
  if (!selectedSurfaces.includes(rule.surface)) continue;
  scanRule(rule);
}

if (violations.length > 0) {
  console.error("React architecture boundary violations:");
  for (const violation of violations) {
    console.error(`- ${violation.path}: ${violation.message}`);
    console.error(`  ${violation.guidance}`);
  }
  process.exit(1);
}

if (args.summary) {
  console.log(
    `React architecture boundaries ok: ${selectedSurfaces.join(", ")} (${boundaryRules.length + requiredRules.length} rules checked).`
  );
}

function scanRule(rule) {
  const filePath = fromRepo(rule.path);
  if (!fs.existsSync(filePath)) {
    violations.push({
      path: rule.path,
      message: "required boundary file is missing.",
      guidance: rule.guidance,
    });
    return;
  }

  const source = fs.readFileSync(filePath, "utf8");
  for (const forbidden of rule.forbidden ?? []) {
    if (!forbidden.pattern.test(source)) continue;
    violations.push({
      path: rule.path,
      message: `${rule.id}: ${forbidden.description}.`,
      guidance: rule.guidance,
    });
  }

  for (const required of rule.required ?? []) {
    if (required.pattern.test(source)) continue;
    violations.push({
      path: rule.path,
      message: `${rule.id}: missing ${required.description}.`,
      guidance: rule.guidance,
    });
  }
}

function parseArgs(argv) {
  const parsed = {surface: "all", summary: false};
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") {
      continue;
    }
    if (arg === "--summary") {
      parsed.summary = true;
      continue;
    }
    if (arg === "--surface") {
      parsed.surface = requiredValue(argv, ++index, arg);
      continue;
    }
    if (arg === "--help" || arg === "-h") {
      printHelp();
      process.exit(0);
    }
    fail(`Unknown argument: ${arg}`);
  }
  if (!["all", "website", "admin"].includes(parsed.surface)) {
    fail(`Unknown surface: ${parsed.surface}`);
  }
  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) fail(`${flag} requires a value.`);
  return value;
}

function fail(message) {
  console.error(message);
  process.exit(64);
}

function printHelp() {
  const name = path.basename(process.argv[1]);
  console.log(`Usage: node tool/web/${name} [--check] [--surface all|website|admin] [--summary]

Fails when React route-owned state or feature-boundary contracts drift.
`);
}
