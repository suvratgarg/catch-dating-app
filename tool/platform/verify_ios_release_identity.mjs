#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import {
  defaultRepoRoot,
  loadAppTargets,
} from "./resolve_app_target.mjs";

const controlledEntitlements = [
  "aps-environment",
  "com.apple.developer.devicecheck.appattest-environment",
  "com.apple.developer.associated-domains",
  "com.apple.developer.healthkit",
];

export function resolveReleaseTarget({manifest, targetId, role, environment, scheme}) {
  const candidates = (manifest.targets ?? []).filter((target) => {
    if (targetId && target.id !== targetId) return false;
    if (role && target.role !== role) return false;
    if (environment && target.environment !== environment) return false;
    if (scheme && target.ios?.scheme !== scheme) return false;
    return true;
  });
  if (candidates.length !== 1) {
    const selector = JSON.stringify({targetId, role, environment, scheme});
    throw new Error(
      `Expected one app target for ${selector}; found ${candidates.length}.`,
    );
  }
  return candidates[0];
}

export function parseFlutterBuildXcconfig(source) {
  const values = {};
  for (const line of source.split(/\r?\n/u)) {
    const match = line.match(/^\s*(FLUTTER_BUILD_NAME|FLUTTER_BUILD_NUMBER)\s*=\s*(.*?)\s*$/u);
    if (match) values[match[1]] = match[2];
  }
  return {
    version: values.FLUTTER_BUILD_NAME,
    build: values.FLUTTER_BUILD_NUMBER,
  };
}

export function collectReleaseIdentityFindings({
  target,
  roleEntitlements,
  appInfo,
  firebaseInfo,
  archiveInfo,
  signedEntitlements,
  expectedVersion,
  expectedBuild,
}) {
  const findings = [];
  const bundleId = stringValue(appInfo.CFBundleIdentifier);
  const version = stringValue(appInfo.CFBundleShortVersionString);
  const build = stringValue(appInfo.CFBundleVersion);
  const displayName = stringValue(appInfo.CFBundleDisplayName);
  const appTargetId = stringValue(appInfo.CatchAppTargetID);
  const flutterTarget = stringValue(appInfo.CatchFlutterTarget);
  const urlSchemes = (appInfo.CFBundleURLTypes ?? []).flatMap(
    (entry) => entry?.CFBundleURLSchemes ?? [],
  );

  expectEqual(findings, "bundle identifier", bundleId, target.ios.bundleId);
  expectEqual(findings, "display name", displayName, target.displayName);
  expectEqual(findings, "app target marker", appTargetId, target.id);
  if (!flutterTarget.endsWith(`/${target.entrypoint}`)) {
    findings.push(
      `Flutter target '${flutterTarget}' did not resolve to '${target.entrypoint}'`,
    );
  }
  if (!urlSchemes.includes(target.ios.urlScheme)) {
    findings.push(
      `URL schemes ${JSON.stringify(urlSchemes)} do not contain '${target.ios.urlScheme}'`,
    );
  }
  expectEqual(
    findings,
    "Firebase bundle identifier",
    stringValue(firebaseInfo?.BUNDLE_ID),
    target.ios.bundleId,
  );
  expectEqual(
    findings,
    "Firebase app id",
    stringValue(firebaseInfo?.GOOGLE_APP_ID),
    target.firebase?.ios?.appId,
  );
  expectEqual(
    findings,
    "Firebase project id",
    stringValue(firebaseInfo?.PROJECT_ID),
    target.firebase?.projectId,
  );
  expectEqual(findings, "marketing version", version, expectedVersion);
  expectEqual(findings, "build number", build, expectedBuild);

  if (!/^\d+(?:\.\d+){0,2}$/u.test(version)) {
    findings.push(`marketing version '${version}' is not an Apple numeric version`);
  }
  if (!/^\d+(?:\.\d+){0,2}$/u.test(build)) {
    findings.push(`build number '${build}' is not an Apple numeric build number`);
  }

  if (archiveInfo) {
    const properties = archiveInfo.ApplicationProperties;
    if (!properties || typeof properties !== "object") {
      findings.push("archive Info.plist is missing ApplicationProperties");
    } else {
      expectEqual(
        findings,
        "archive bundle identifier",
        stringValue(properties.CFBundleIdentifier),
        bundleId,
      );
      expectEqual(
        findings,
        "archive marketing version",
        stringValue(properties.CFBundleShortVersionString),
        version,
      );
      expectEqual(
        findings,
        "archive build number",
        stringValue(properties.CFBundleVersion),
        build,
      );
    }
  }

  validateRoleEntitlements({
    findings,
    target,
    expected: roleEntitlements,
    actual: signedEntitlements,
  });
  return findings;
}

export function buildReleaseIdentityReceipt({
  target,
  appInfo,
  firebaseInfo,
  signedEntitlements,
}) {
  const capabilities = Object.fromEntries(
    controlledEntitlements.map((key) => [key, signedEntitlements[key] ?? null]),
  );
  return {
    $schema: "catch.ios-release-identity/v1",
    targetId: target.id,
    role: target.role,
    environment: target.environment,
    bundleIdentifier: appInfo.CFBundleIdentifier,
    displayName: appInfo.CFBundleDisplayName,
    flutterTarget: appInfo.CatchFlutterTarget,
    firebase: {
      bundleIdentifier: firebaseInfo.BUNDLE_ID,
      appId: firebaseInfo.GOOGLE_APP_ID,
      projectId: firebaseInfo.PROJECT_ID,
      urlScheme: target.ios.urlScheme,
    },
    version: appInfo.CFBundleShortVersionString,
    build: appInfo.CFBundleVersion,
    releaseOwner: target.release?.owner ?? null,
    signedCapabilities: capabilities,
  };
}

export function readPlistFile(plistPath) {
  const result = spawnSync(
    "/usr/bin/plutil",
    ["-convert", "json", "-o", "-", plistPath],
    {encoding: "utf8"},
  );
  if (result.error?.code === "ENOENT") {
    return JSON.parse(fs.readFileSync(plistPath, "utf8"));
  }
  if (result.status !== 0) {
    throw new Error(
      `Could not read plist ${plistPath}: ${(
        result.stderr ||
        result.stdout ||
        result.error?.message ||
        "unknown plutil failure"
      ).trim()}`,
    );
  }
  return JSON.parse(result.stdout);
}

export function readSignedEntitlements(appPath) {
  const result = spawnSync(
    "/usr/bin/codesign",
    ["-d", "--entitlements", ":-", appPath],
    {encoding: "utf8"},
  );
  if (result.status !== 0) {
    throw new Error(
      `Could not read signed entitlements from ${appPath}: ${result.stderr.trim()}`,
    );
  }
  const xml = plistXmlFromOutput(`${result.stdout}\n${result.stderr}`);
  if (!xml) {
    throw new Error(`codesign returned no entitlement plist for ${appPath}`);
  }
  const parsed = spawnSync(
    "/usr/bin/plutil",
    ["-convert", "json", "-o", "-", "-"],
    {encoding: "utf8", input: xml},
  );
  if (parsed.status !== 0) {
    throw new Error(`Could not parse signed entitlements: ${parsed.stderr.trim()}`);
  }
  return JSON.parse(parsed.stdout);
}

export function locateArchivedApp(archivePath) {
  const applicationsDir = path.join(archivePath, "Products", "Applications");
  if (!fs.existsSync(applicationsDir)) {
    throw new Error(`Archive has no Products/Applications directory: ${archivePath}`);
  }
  const apps = fs
    .readdirSync(applicationsDir, {withFileTypes: true})
    .filter((entry) => entry.isDirectory() && entry.name.endsWith(".app"))
    .map((entry) => path.join(applicationsDir, entry.name));
  if (apps.length !== 1) {
    throw new Error(
      `Expected exactly one archived app in ${applicationsDir}; found ${apps.length}.`,
    );
  }
  return apps[0];
}

function validateRoleEntitlements({findings, target, expected, actual}) {
  for (const key of controlledEntitlements) {
    const expectsKey = Object.hasOwn(expected, key);
    const hasKey = Object.hasOwn(actual, key);
    if (!expectsKey && hasKey) {
      findings.push(`${target.role} app has forbidden entitlement '${key}'`);
      continue;
    }
    if (expectsKey && !hasKey) {
      findings.push(`${target.role} app is missing entitlement '${key}'`);
      continue;
    }
    if (!expectsKey) continue;

    const expectedValue = expected[key];
    const actualValue = actual[key];
    if (Array.isArray(expectedValue)) {
      const expectedItems = [...expectedValue].sort();
      const actualItems = Array.isArray(actualValue) ? [...actualValue].sort() : [];
      if (JSON.stringify(actualItems) !== JSON.stringify(expectedItems)) {
        findings.push(
          `entitlement '${key}' was ${JSON.stringify(actualValue)}; expected ${JSON.stringify(expectedValue)}`,
        );
      }
      continue;
    }
    if (typeof expectedValue === "string" && expectedValue.startsWith("$(")) {
      if (typeof actualValue !== "string" || actualValue.length === 0 || actualValue.startsWith("$(")) {
        findings.push(`entitlement '${key}' was not resolved at signing time`);
      } else if (target.environment === "prod" && actualValue !== "production") {
        findings.push(`prod entitlement '${key}' must be 'production'; found '${actualValue}'`);
      }
      continue;
    }
    if (JSON.stringify(actualValue) !== JSON.stringify(expectedValue)) {
      findings.push(
        `entitlement '${key}' was ${JSON.stringify(actualValue)}; expected ${JSON.stringify(expectedValue)}`,
      );
    }
  }

  const applicationIdentifier = stringValue(actual["application-identifier"]);
  if (!applicationIdentifier.endsWith(`.${target.ios.bundleId}`)) {
    findings.push(
      `signed application-identifier '${applicationIdentifier}' does not end with '.${target.ios.bundleId}'`,
    );
  }
  const teamIdentifier = stringValue(actual["com.apple.developer.team-identifier"]);
  if (!teamIdentifier) {
    findings.push("signed entitlements are missing com.apple.developer.team-identifier");
  } else if (!applicationIdentifier.startsWith(`${teamIdentifier}.`)) {
    findings.push("signed application-identifier does not use the signed team identifier");
  }
  if (target.environment === "prod" && actual["get-task-allow"] === true) {
    findings.push("prod app has get-task-allow=true");
  }
}

function expectEqual(findings, label, actual, expected) {
  if (!expected) {
    findings.push(`expected ${label} is empty`);
  } else if (actual !== expected) {
    findings.push(`${label} '${actual}' did not match expected '${expected}'`);
  }
}

function stringValue(value) {
  if (value === undefined || value === null) return "";
  return String(value);
}

function plistXmlFromOutput(output) {
  const start = output.indexOf("<?xml");
  const end = output.lastIndexOf("</plist>");
  if (start < 0 || end < start) return null;
  return output.slice(start, end + "</plist>".length);
}

function valueAfter(args, flag) {
  const index = args.indexOf(flag);
  return index >= 0 ? args[index + 1] : null;
}

function usage() {
  return [
    "Usage: node tool/platform/verify_ios_release_identity.mjs",
    "  (--archive <path> | --app <path>)",
    "  [--target <id> | --role <role> --environment <env> | --scheme <scheme>]",
    "  (--expected-xcconfig <path> | --expected-version <value> --expected-build <value>)",
    "  [--entitlements-plist <path>] [--receipt <path>]",
  ].join("\n");
}

function runCli() {
  const args = process.argv.slice(2);
  if (args.includes("--help") || args.includes("-h")) {
    console.log(usage());
    return;
  }
  const archivePathArg = valueAfter(args, "--archive");
  const appPathArg = valueAfter(args, "--app");
  if (Boolean(archivePathArg) === Boolean(appPathArg)) {
    throw new Error("Provide exactly one of --archive or --app.\n" + usage());
  }

  const root = defaultRepoRoot;
  const manifest = loadAppTargets({root});
  const target = resolveReleaseTarget({
    manifest,
    targetId: valueAfter(args, "--target"),
    role: valueAfter(args, "--role"),
    environment: valueAfter(args, "--environment"),
    scheme: valueAfter(args, "--scheme"),
  });
  if (target.environment === "prod" && !target.release) {
    throw new Error(`Prod target ${target.id} has no release ownership contract.`);
  }

  let expectedVersion = valueAfter(args, "--expected-version");
  let expectedBuild = valueAfter(args, "--expected-build");
  const expectedXcconfig = valueAfter(args, "--expected-xcconfig");
  if (expectedXcconfig) {
    const expected = parseFlutterBuildXcconfig(
      fs.readFileSync(path.resolve(expectedXcconfig), "utf8"),
    );
    expectedVersion = expected.version;
    expectedBuild = expected.build;
  }
  if (!expectedVersion || !expectedBuild) {
    throw new Error(
      "Expected version and build are required; pass --expected-xcconfig or both explicit flags.",
    );
  }

  const archivePath = archivePathArg ? path.resolve(archivePathArg) : null;
  const appPath = archivePath ? locateArchivedApp(archivePath) : path.resolve(appPathArg);
  const infoPath = path.join(appPath, "Info.plist");
  if (!fs.existsSync(infoPath)) throw new Error(`App is missing Info.plist: ${appPath}`);
  const firebaseInfoPath = path.join(appPath, "GoogleService-Info.plist");
  if (!fs.existsSync(firebaseInfoPath)) {
    throw new Error(`App is missing GoogleService-Info.plist: ${appPath}`);
  }

  const roleEntitlementsPath = path.join(
    root,
    manifest.roles[target.role].iosEntitlements,
  );
  const entitlementOverride = valueAfter(args, "--entitlements-plist");
  const signedEntitlements = entitlementOverride
    ? readPlistFile(path.resolve(entitlementOverride))
    : readSignedEntitlements(appPath);
  const appInfo = readPlistFile(infoPath);
  const firebaseInfo = readPlistFile(firebaseInfoPath);
  const archiveInfo = archivePath
    ? readPlistFile(path.join(archivePath, "Info.plist"))
    : null;
  const roleEntitlements = readPlistFile(roleEntitlementsPath);
  const findings = collectReleaseIdentityFindings({
    target,
    roleEntitlements,
    appInfo,
    firebaseInfo,
    archiveInfo,
    signedEntitlements,
    expectedVersion,
    expectedBuild,
  });
  if (findings.length > 0) {
    throw new Error(
      `iOS release identity verification failed for ${target.id}:\n- ${findings.join("\n- ")}`,
    );
  }

  const receipt = buildReleaseIdentityReceipt({
    target,
    appInfo,
    firebaseInfo,
    signedEntitlements,
  });
  const receiptPath = valueAfter(args, "--receipt");
  if (receiptPath) {
    const resolvedReceipt = path.resolve(receiptPath);
    fs.mkdirSync(path.dirname(resolvedReceipt), {recursive: true});
    fs.writeFileSync(resolvedReceipt, `${JSON.stringify(receipt, null, 2)}\n`);
  }
  console.log(JSON.stringify(receipt, null, 2));
}

const isMain = process.argv[1]
  ? path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)
  : false;
if (isMain) {
  try {
    runCli();
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
