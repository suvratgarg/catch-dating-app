#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {fromRepo} from "../lib/repo_paths.mjs";

const toolPath = fileURLToPath(import.meta.url);
const isCli = process.argv[1] && path.resolve(process.argv[1]) === toolPath;

const customerRouteConsumers = new Set([
  "lib/hosts/presentation/customers/host_customer_detail_screen.dart",
  "lib/hosts/presentation/customers/host_customer_timeline.dart",
]);
const savedAudienceMutationOwners = new Set([
  "lib/hosts/presentation/host_audience_controller.dart",
]);
const manualQueueOwners = new Set([
  "lib/hosts/presentation/inbox/host_manual_send_queue.dart",
  "lib/hosts/presentation/inbox/host_sends_workspace.dart",
]);
const permissionCollectionReviewers = new Set([
  "functions/src/events/eventAttendees.ts",
  "functions/src/organizers/organizerAudienceProjection.ts",
  "functions/src/organizers/organizerCampaignDispatcher.ts",
  "functions/src/organizers/organizerCampaigns.ts",
  "functions/src/organizers/organizerContacts.ts",
  "functions/src/organizers/organizerCrm.ts",
  "functions/src/organizers/organizerSavedAudiences.ts",
  "functions/src/organizers/organizerWhatsappWebhook.ts",
  "functions/src/safety/accountDeletion.ts",
]);

const collectionWriteOwners = new Map([
  ["organizerContacts", {
    operations: ["create", "set"],
    owners: new Set([
      "functions/src/organizers/organizerAudienceProjection.ts",
      "functions/src/organizers/organizerContacts.ts",
    ]),
  }],
  ["organizerSavedAudiences", {
    operations: ["create", "set", "update", "delete"],
    owners: new Set([
      "functions/src/organizers/organizerSavedAudiences.ts",
    ]),
  }],
  ["organizerManualSendTasks", {
    operations: ["create", "set", "update", "delete"],
    owners: new Set([
      "functions/src/organizers/organizerManualSendTasks.ts",
    ]),
  }],
]);

const manualSendStatuses = [
  "queued",
  "handoffOpened",
  "hostMarkedSent",
  "skipped",
  "cancelled",
  "superseded",
  "expired",
];

if (isCli) runCli();

export function scanHostCrmBoundaries({root = fromRepo()} = {}) {
  const findings = [];
  const presentationFiles = collectFiles(
    path.join(root, "lib/hosts/presentation"),
    ".dart"
  );
  const backendFiles = collectFiles(
    path.join(root, "functions/src"),
    ".ts"
  ).filter((file) =>
    !file.endsWith(".test.ts") &&
    !normalizePath(file).includes("/shared/generated/")
  );

  for (const file of presentationFiles) {
    const relativePath = normalizePath(path.relative(root, file));
    findings.push(...scanPresentationFile({
      relativePath,
      source: fs.readFileSync(file, "utf8"),
    }));
  }
  for (const file of backendFiles) {
    const relativePath = normalizePath(path.relative(root, file));
    findings.push(...scanBackendFile({
      relativePath,
      source: fs.readFileSync(file, "utf8"),
    }));
  }

  findings.push(...scanManualSendContract(root));
  findings.push(...scanFormProvenanceContract(root));
  findings.push(...scanHostCrmCountCopy(root));
  findings.push(...scanApplicationRouteOwnership(root));
  return {
    checkedFiles: presentationFiles.length + backendFiles.length,
    enforcedBoundaries: 11,
    findings,
  };
}

export function scanPresentationFile({relativePath, source}) {
  const findings = [];
  const inCustomers = relativePath.startsWith(
    "lib/hosts/presentation/customers/"
  );
  const audienceOwner = inCustomers ||
    savedAudienceMutationOwners.has(relativePath);
  for (const pattern of [
    /\bsaveAudience\s*\(/gu,
    /\barchiveAudience\s*\(/gu,
    /\bupsertSavedAudience\s*\(/gu,
    /\barchiveSavedAudience\s*\(/gu,
  ]) {
    for (const match of source.matchAll(pattern)) {
      if (!audienceOwner) findings.push(finding(
        relativePath,
        source,
        match.index,
        "Saved-audience definition mutations belong to Customers."
      ));
    }
  }

  if (source.includes("HostCommunicationRouteId") &&
      !customerRouteConsumers.has(relativePath)) {
    findings.push(finding(
      relativePath,
      source,
      source.indexOf("HostCommunicationRouteId"),
      "Host presentation must consume an intent plan, not select a transport route."
    ));
  }
  for (const pattern of [
    /CatchField\.select\s*<\s*HostCommunicationRouteId\s*>/u,
    /DropdownButton\s*<\s*HostCommunicationRouteId\s*>/u,
    /SegmentedButton\s*<\s*HostCommunicationRouteId\s*>/u,
  ]) {
    const match = pattern.exec(source);
    if (match) findings.push(finding(
      relativePath,
      source,
      match.index,
      "Hosts choose communication intent; transport is server-resolved."
    ));
  }

  if (relativePath.endsWith("/host_inbox_screen.dart")) {
    for (const widget of ["HostInboxBroadcastCard", "ChatBlastComposerSheet"] ) {
      const index = source.indexOf(widget);
      if (index >= 0) findings.push(finding(
        relativePath,
        source,
        index,
        `${widget} does not belong in the inbound Inbox workspace.`
      ));
    }
  }
  const queueIndex = source.indexOf("HostManualSendQueue");
  if (queueIndex >= 0 && !manualQueueOwners.has(relativePath)) {
    findings.push(finding(
      relativePath,
      source,
      queueIndex,
      "Manual external handoff work belongs to the Sends workspace."
    ));
  }
  return findings;
}

export function scanBackendFile({relativePath, source}) {
  const findings = [];
  const permissionIndex = firstCollectionIndex(source, [
    "organizerCommunicationPreferences",
    "organizerCommunicationPermissionReceipts",
  ]);
  if (permissionIndex >= 0 &&
      !permissionCollectionReviewers.has(relativePath)) {
    findings.push(finding(
      relativePath,
      source,
      permissionIndex,
      "Permission-authority collection access requires an explicit reviewed owner."
    ));
  }
  if (permissionIndex >= 0) {
    const templateId = /collection\(\s*["']organizerCommunicationPreferences["']\s*\)[\s\S]{0,320}?\.doc\(\s*`/u
      .exec(source);
    if (templateId) findings.push(finding(
      relativePath,
      source,
      templateId.index,
      "Use organizerCommunicationPreferenceId; do not reconstruct preference ids."
    ));
  }

  for (const [collectionName, boundary] of collectionWriteOwners) {
    const mutations = collectionMutations(
      source,
      collectionName,
      boundary.operations
    );
    if (mutations.length > 0 && !boundary.owners.has(relativePath)) {
      for (const mutation of mutations) findings.push(finding(
        relativePath,
        source,
        mutation.index,
        `${collectionName} writes belong to its canonical server owner.`
      ));
    }
  }

  if (relativePath.endsWith("/organizerFormAutomations.ts")) {
    for (const pattern of [
      /from\s+["']\.\/organizerCampaignDispatcher["']/u,
      /from\s+["']\.\.\/events\/sendEventBroadcast["']/u,
      /\bdispatchOrganizerCampaign\s*\(/u,
      /\bsendEventBroadcastHandler\s*\(/u,
      /\bsendOrganizerWhatsappMessage\s*\(/u,
    ]) {
      const match = pattern.exec(source);
      if (match) findings.push(finding(
        relativePath,
        source,
        match.index,
        "Host Form automations may prepare reviewed work but cannot dispatch outreach."
      ));
    }
  }
  return findings;
}

export function manualSendContractFindings({relativePath, schema}) {
  const statuses = schema?.definitions?.status?.enum;
  if (JSON.stringify(statuses) === JSON.stringify(manualSendStatuses)) return [];
  return [{
    path: relativePath,
    line: 1,
    reason: "Manual handoffs may record host work only; delivered/read states are forbidden.",
  }];
}

export function hostCrmCountCopyFindings({relativePath, catalog}) {
  const findings = [];
  const keyPattern = /^(?:hostCustomers|hostSavedAudience|hostSends|hostForm|hostApplications)/u;
  const countNamePattern = /(?:count|opens|starts|submissions|created|skipped)$/iu;
  for (const [metadataKey, metadata] of Object.entries(catalog)) {
    if (!metadataKey.startsWith("@") || !keyPattern.test(metadataKey.slice(1)) ||
        !metadata || typeof metadata !== "object") continue;
    const key = metadataKey.slice(1);
    const value = catalog[key];
    if (typeof value !== "string") continue;
    for (const [placeholder, contract] of Object.entries(
      metadata.placeholders ?? {}
    )) {
      if (contract?.type !== "int" || !countNamePattern.test(placeholder)) {
        continue;
      }
      if (!value.includes(`{${placeholder}, plural,`)) {
        findings.push({
          path: relativePath,
          line: 1,
          reason: `${key}.${placeholder} is a visible CRM count without ICU plural ownership.`,
        });
      }
    }
  }
  return findings;
}

export function applicationRouteOwnershipFindings({
  routeContractPath,
  routeContractSource,
  routerPath,
  routerSource,
}) {
  const findings = [];
  const expectedListPath =
    "hostApplicationsScreen('/host/forms/applications'";
  const expectedDetailPath =
    "'/host/forms/applications/:applicationId'";
  if (!routeContractSource.includes(expectedListPath) ||
      !routeContractSource.includes(expectedDetailPath) ||
      routeContractSource.includes("/host/customers/applications")) {
    findings.push({
      path: routeContractPath,
      line: 1,
      reason: "Applications and application detail routes must be canonically Forms-owned.",
    });
  }

  const customersBranch = shellBranchSource(
    routerSource,
    "navigatorKey: keys.hostCustomers"
  );
  const formsBranch = shellBranchSource(
    routerSource,
    "navigatorKey: keys.hostForms"
  );
  const applicationsRoute = "name: Routes.hostApplicationsScreen.name";
  const applicationDetailRoute =
    "name: Routes.hostApplicationDetailScreen.name";
  const formsOwnBothRoutes = formsBranch.includes(applicationsRoute) &&
    formsBranch.includes(applicationDetailRoute) &&
    !customersBranch.includes(applicationsRoute) &&
    !customersBranch.includes(applicationDetailRoute);
  if (!formsOwnBothRoutes) {
    findings.push({
      path: routerPath,
      line: 1,
      reason: "Named application routes must be mounted in the Forms shell branch.",
    });
  }

  if (!customersBranch.includes("hostApplicationsLegacyRedirect")) {
    findings.push({
      path: routerPath,
      line: 1,
      reason: "Legacy Customers application links must redirect to Forms ownership.",
    });
  }
  return findings;
}

function shellBranchSource(source, navigatorAnchor) {
  const start = source.indexOf(navigatorAnchor);
  if (start < 0) return "";
  const end = source.indexOf("StatefulShellBranch(", start);
  return source.slice(start, end < 0 ? source.length : end);
}

function scanManualSendContract(root) {
  const relativePath =
    "contracts/firestore/organizer_manual_send_tasks.schema.json";
  const file = path.join(root, relativePath);
  if (!fs.existsSync(file)) return [missingFinding(relativePath)];
  try {
    return manualSendContractFindings({
      relativePath,
      schema: JSON.parse(fs.readFileSync(file, "utf8")),
    });
  } catch {
    return [{path: relativePath, line: 1, reason: "Manual-send schema is invalid JSON."}];
  }
}

function scanHostCrmCountCopy(root) {
  const relativePath = "lib/l10n/app_en.arb";
  const file = path.join(root, relativePath);
  if (!fs.existsSync(file)) return [missingFinding(relativePath)];
  try {
    return hostCrmCountCopyFindings({
      relativePath,
      catalog: JSON.parse(fs.readFileSync(file, "utf8")),
    });
  } catch {
    return [{path: relativePath, line: 1, reason: "English locale catalog is invalid JSON."}];
  }
}

function scanApplicationRouteOwnership(root) {
  const routeContractPath = "lib/routing/route_contract.dart";
  const routerPath = "lib/routing/go_router.dart";
  const routeContractFile = path.join(root, routeContractPath);
  const routerFile = path.join(root, routerPath);
  if (!fs.existsSync(routeContractFile) || !fs.existsSync(routerFile)) {
    return [
      ...(!fs.existsSync(routeContractFile)
        ? [missingFinding(routeContractPath)]
        : []),
      ...(!fs.existsSync(routerFile) ? [missingFinding(routerPath)] : []),
    ];
  }
  return applicationRouteOwnershipFindings({
    routeContractPath,
    routeContractSource: fs.readFileSync(routeContractFile, "utf8"),
    routerPath,
    routerSource: fs.readFileSync(routerFile, "utf8"),
  });
}

function scanFormProvenanceContract(root) {
  const required = [
    {
      path: "functions/src/organizers/organizerContacts.ts",
      anchors: [
        "origin: OrganizerContactCreationOrigin;",
        "formResponseOrganizerContactOrigin({",
      ],
    },
    {
      path: "functions/src/organizers/organizerFormConversions.ts",
      anchors: [
        'params.data.kind !== "crmContact"',
        "origin: target.origin",
      ],
    },
    {
      path: "functions/src/shared/organizerContactOrigins.ts",
      anchors: [
        "formResponseOrganizerContactOrigin",
        'sourceEntityKind: "hostFormResponse"',
      ],
    },
  ];
  const findings = [];
  for (const item of required) {
    const file = path.join(root, item.path);
    if (!fs.existsSync(file)) {
      findings.push(missingFinding(item.path));
      continue;
    }
    const source = fs.readFileSync(file, "utf8");
    for (const anchor of item.anchors) {
      if (!source.includes(anchor)) findings.push({
        path: item.path,
        line: 1,
        reason: `Required Host Form contact provenance seam is missing: ${anchor}`,
      });
    }
  }
  return findings;
}

function collectionMutations(source, collectionName, operations) {
  const aliases = new Set();
  for (const match of source.matchAll(
    /\b(?:const|let)\s+(\w+)\s*=\s*([\s\S]*?);/gu
  )) {
    if (new RegExp(
      `\\.collection\\(\\s*["']${collectionName}["']\\s*\\)`,
      "u"
    ).test(match[2])) aliases.add(match[1]);
  }
  const findings = [];
  for (const alias of aliases) {
    const pattern = new RegExp(
      `\\b(?:tx|batch)\\.(?:${operations.join("|")})\\s*\\(\\s*${alias}\\b`,
      "gu"
    );
    for (const match of source.matchAll(pattern)) findings.push(match);
  }
  const inline = new RegExp(
    `\\b(?:tx|batch)\\.(?:${operations.join("|")})\\s*\\([\\s\\S]{0,320}?` +
      `\\.collection\\(\\s*["']${collectionName}["']\\s*\\)`,
    "gu"
  );
  for (const match of source.matchAll(inline)) findings.push(match);
  return findings;
}

function firstCollectionIndex(source, names) {
  const indexes = names.map((name) => source.search(new RegExp(
    `\\.collection\\(\\s*["']${name}["']\\s*\\)`,
    "u"
  ))).filter((index) => index >= 0);
  return indexes.length ? Math.min(...indexes) : -1;
}

function collectFiles(root, extension) {
  if (!fs.existsSync(root)) return [];
  const files = [];
  const walk = (directory) => {
    for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
      const absolute = path.join(directory, entry.name);
      if (entry.isDirectory()) walk(absolute);
      else if (entry.isFile() && absolute.endsWith(extension) &&
          !absolute.endsWith(`.g${extension}`)) files.push(absolute);
    }
  };
  walk(root);
  return files.sort((a, b) => a.localeCompare(b));
}

function finding(relativePath, source, index, reason) {
  return {
    path: relativePath,
    line: 1 + source.slice(0, Math.max(0, index)).split("\n").length - 1,
    reason,
  };
}

function missingFinding(relativePath) {
  return {path: relativePath, line: 1, reason: "Required CRM authority file is missing."};
}

function normalizePath(value) {
  return value.split(path.sep).join("/");
}

function parseArgs(argv) {
  const parsed = {root: fromRepo(), json: false, help: false};
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--root") parsed.root = requireValue(argv, ++index, arg);
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--help" || arg === "-h") parsed.help = true;
    else throw new Error(`Unknown argument: ${arg}`);
  }
  return parsed;
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) throw new Error(`${flag} requires a value.`);
  return value;
}

function runCli() {
  let args;
  try {
    args = parseArgs(process.argv.slice(2));
  } catch (error) {
    console.error(error.message);
    process.exit(2);
  }
  if (args.help) {
    console.log("Usage: node tool/architecture/check_host_crm_boundaries.mjs [--root PATH] [--json]");
    return;
  }
  const result = scanHostCrmBoundaries({root: args.root});
  if (args.json) console.log(JSON.stringify(result, null, 2));
  else if (result.findings.length === 0) {
    console.log(
      `Host CRM boundary check passed (${result.checkedFiles} files, ` +
      `${result.enforcedBoundaries} boundaries).`
    );
  } else {
    for (const item of result.findings) {
      console.error(`${item.path}:${item.line}: ${item.reason}`);
    }
  }
  if (result.findings.length > 0) process.exitCode = 1;
}
