#!/usr/bin/env node

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {createHash} from "node:crypto";
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
const artifactStages = new Set(["archive", "export"]);
const signingEnvironments = new Set(["development", "production"]);

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
  expectedGoogleMapsApiKey,
  artifactStage = "export",
}) {
  if (!artifactStages.has(artifactStage)) {
    throw new Error(`Unsupported iOS release artifact stage '${artifactStage}'.`);
  }
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
  if (!flutterTarget.endsWith(`/${target.packageEntrypoint}`)) {
    findings.push(
      `Flutter target '${flutterTarget}' did not resolve to '${target.packageEntrypoint}'`,
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
  if (expectedGoogleMapsApiKey !== undefined) {
    expectEqual(
      findings,
      "compiled Google Maps API key",
      stringValue(appInfo.GoogleMapsApiKey),
      expectedGoogleMapsApiKey,
    );
  }

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
    requiresDistributionSigning: artifactStage === "export",
  });
  return findings;
}

export function buildReleaseIdentityReceipt({
  target,
  appInfo,
  firebaseInfo,
  signedEntitlements,
  artifactStage = "export",
  artifactBinding,
  googleMapsApiKey,
  signatureVerified = false,
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
    artifactStage,
    signatureVerified,
    ...(artifactBinding ? {artifactBinding} : {}),
    ...(googleMapsApiKey ? {
      googleMapsApiKeySha256: createHash("sha256").update(googleMapsApiKey).digest("hex"),
    } : {}),
    releaseOwner: target.release?.owner ?? null,
    signedCapabilities: capabilities,
  };
}

export function buildArtifactBinding(artifactPath) {
  const resolved = path.resolve(artifactPath);
  const stat = fs.lstatSync(resolved);
  if (!stat.isFile() || stat.isSymbolicLink()) {
    throw new Error(`Release artifact must be a regular non-symlink file: ${resolved}`);
  }
  return {
    path: path.basename(resolved),
    sizeBytes: stat.size,
    sha256: createHash("sha256").update(fs.readFileSync(resolved)).digest("hex"),
  };
}

export function assertStableArtifactBinding(expected, actual) {
  const validExpected = expected &&
    typeof expected.path === "string" && expected.path === path.basename(expected.path) &&
    Number.isSafeInteger(expected.sizeBytes) && expected.sizeBytes >= 0 &&
    typeof expected.sha256 === "string" && /^[0-9a-f]{64}$/u.test(expected.sha256);
  if (!validExpected || JSON.stringify(expected) !== JSON.stringify(actual)) {
    throw new Error("Signed IPA bytes changed after export identity extraction.");
  }
  return actual;
}

export function extractIpaForIdentity(ipaPath) {
  const resolved = path.resolve(ipaPath);
  const artifactBindingBefore = buildArtifactBinding(resolved);
  const listing = spawnSync("/usr/bin/unzip", ["-Z1", resolved], {encoding: "utf8"});
  if (listing.status !== 0) {
    throw new Error(`Could not list signed IPA ${resolved}: ${(listing.stderr || listing.stdout).trim()}`);
  }
  const entries = listing.stdout.split(/\r?\n/u).filter(Boolean);
  if (entries.length === 0 || entries.some((entry) =>
    entry.includes("\\") || entry.startsWith("/") || /(^|\/)\.\.($|\/)/u.test(entry)
  ) || new Set(entries).size !== entries.length
  ) {
    throw new Error("Signed IPA contains an unsafe or empty archive path set.");
  }

  const extractionRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-ios-identity-"));
  try {
    const extraction = spawnSync(
      "/usr/bin/unzip",
      ["-q", resolved, "-d", extractionRoot],
      {encoding: "utf8"},
    );
    if (extraction.status !== 0) {
      throw new Error(
        `Could not extract signed IPA ${resolved}: ${(extraction.stderr || extraction.stdout).trim()}`,
      );
    }
    const visit = (directory) => {
      for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
        const candidate = path.join(directory, entry.name);
        const stat = fs.lstatSync(candidate);
        if (stat.isSymbolicLink()) {
          throw new Error(`Signed IPA contains a symbolic link: ${path.relative(extractionRoot, candidate)}`);
        }
        if (stat.isDirectory()) visit(candidate);
      }
    };
    visit(extractionRoot);
    const payload = path.join(extractionRoot, "Payload");
    if (!fs.existsSync(payload) || !fs.lstatSync(payload).isDirectory()) {
      throw new Error("Signed IPA has no regular Payload directory.");
    }
    const apps = fs.readdirSync(payload, {withFileTypes: true})
      .filter((entry) => entry.isDirectory() && entry.name.endsWith(".app"))
      .map((entry) => path.join(payload, entry.name));
    if (apps.length !== 1) {
      throw new Error(`Expected exactly one Payload/*.app in signed IPA; found ${apps.length}.`);
    }
    return {
      appPath: apps[0],
      artifactBindingBefore,
      cleanup: () => fs.rmSync(extractionRoot, {recursive: true, force: true}),
    };
  } catch (error) {
    fs.rmSync(extractionRoot, {recursive: true, force: true});
    throw error;
  }
}

export function readExpectedGoogleMapsKey({root, target}) {
  const keyPath = path.join(
    root,
    target.projectRoot,
    "ios/Flutter/GoogleMapsKeys.xcconfig",
  );
  if (!fs.existsSync(keyPath)) {
    throw new Error(`Missing protected iOS Maps key file: ${keyPath}`);
  }
  const keyName = `GOOGLE_MAPS_IOS_API_KEY_${target.environment.toUpperCase()}`;
  const match = fs.readFileSync(keyPath, "utf8").match(
    new RegExp(`^\\s*${keyName}\\s*=\\s*(.+?)\\s*$`, "mu"),
  );
  const value = match?.[1]?.trim() ?? "";
  if (!/^AIza[0-9A-Za-z_-]{20,}$/u.test(value)) {
    throw new Error(`Missing or invalid ${keyName} in ${keyPath}`);
  }
  return value;
}

export function readPlistFile(plistPath) {
  const source = fs.readFileSync(plistPath, "utf8");
  try {
    return JSON.parse(source);
  } catch {
    // Real archive plists continue through the native plist converter.
  }
  const result = spawnSync(
    "/usr/bin/plutil",
    ["-convert", "json", "-o", "-", plistPath],
    {encoding: "utf8"},
  );
  if (result.error?.code === "ENOENT") {
    return parseXmlPlistDictionary(source);
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

export function readArchiveInfoPlist(plistPath) {
  try {
    const archiveInfo = readPlistFile(plistPath);
    if (archiveInfo?.ApplicationProperties) return archiveInfo;
  } catch {
    // Xcode archives include CreationDate at the root. plutil cannot convert
    // that date-bearing dictionary to JSON, so extract only the identity data.
  }

  const result = spawnSync(
    "/usr/bin/plutil",
    ["-extract", "ApplicationProperties", "json", "-o", "-", plistPath],
    {encoding: "utf8"},
  );
  if (result.status !== 0) {
    throw new Error(
      `Could not read ApplicationProperties from archive plist ${plistPath}: ${(
        result.stderr ||
        result.stdout ||
        result.error?.message ||
        "unknown plutil failure"
      ).trim()}`,
    );
  }
  return {ApplicationProperties: JSON.parse(result.stdout)};
}

function parseXmlPlistDictionary(source) {
  const values = {};
  const entries = source.matchAll(
    /<key>([^<]+)<\/key>\s*(?:<string>([^<]*)<\/string>|<(true|false)\s*\/>|<array>([\s\S]*?)<\/array>)/gu,
  );
  for (const match of entries) {
    const [, key, stringValue, booleanValue, arrayValue] = match;
    if (stringValue != null) {
      values[key] = stringValue;
    } else if (booleanValue != null) {
      values[key] = booleanValue === "true";
    } else {
      values[key] = [...arrayValue.matchAll(/<string>([^<]*)<\/string>/gu)].map(
        (item) => item[1],
      );
    }
  }
  if (Object.keys(values).length === 0) {
    throw new Error("Could not parse XML plist dictionary without plutil");
  }
  return values;
}

export function readSignedEntitlements(appPath, {verify = true} = {}) {
  if (verify) verifyCodeSignature(appPath);
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

export function verifyCodeSignature(appPath) {
  const result = spawnSync(
    "/usr/bin/codesign",
    ["--verify", "--deep", "--strict", "--verbose=2", appPath],
    {encoding: "utf8"},
  );
  if (result.status !== 0) {
    throw new Error(
      `iOS app signature verification failed for ${appPath}: ${(result.stderr || result.stdout).trim()}`,
    );
  }
  return true;
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

function validateRoleEntitlements({
  findings,
  target,
  expected,
  actual,
  requiresDistributionSigning,
}) {
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
      } else if (!signingEnvironments.has(actualValue)) {
        findings.push(
          `entitlement '${key}' resolved to unsupported signing environment '${actualValue}'`,
        );
      } else if (
        requiresDistributionSigning &&
        target.environment === "prod" &&
        actualValue !== "production"
      ) {
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
  if (requiresDistributionSigning && target.environment === "prod") {
    const getTaskAllow = actual["get-task-allow"];
    if (getTaskAllow !== false) {
      findings.push(
        `prod exported app must set get-task-allow=false; found ${JSON.stringify(getTaskAllow) ?? "undefined"}`,
      );
    }
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
    "  (--archive <path> | --app <path> | --ipa <signed.ipa>)",
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
  const ipaPathArg = valueAfter(args, "--ipa");
  if ([archivePathArg, appPathArg, ipaPathArg].filter(Boolean).length !== 1) {
    throw new Error("Provide exactly one of --archive, --app, or --ipa.\n" + usage());
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
  const extractedIpa = ipaPathArg ? extractIpaForIdentity(ipaPathArg) : null;
  const appPath = archivePath
    ? locateArchivedApp(archivePath)
    : extractedIpa?.appPath ?? path.resolve(appPathArg);
  try {
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
  let signatureVerified = false;
  if (ipaPathArg) signatureVerified = verifyCodeSignature(appPath);
  const signedEntitlements = entitlementOverride
    ? readPlistFile(path.resolve(entitlementOverride))
    : readSignedEntitlements(appPath, {verify: !ipaPathArg});
  if (!entitlementOverride) signatureVerified = true;
  const appInfo = readPlistFile(infoPath);
  const firebaseInfo = readPlistFile(firebaseInfoPath);
  const archiveInfo = archivePath
    ? readArchiveInfoPlist(path.join(archivePath, "Info.plist"))
    : null;
  const artifactStage = archivePath ? "archive" : "export";
  const expectedGoogleMapsApiKey = ipaPathArg
    ? readExpectedGoogleMapsKey({root, target})
    : undefined;
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
    expectedGoogleMapsApiKey,
    artifactStage,
  });
  if (findings.length > 0) {
    throw new Error(
      `iOS release identity verification failed for ${target.id}:\n- ${findings.join("\n- ")}`,
    );
  }

  const receiptPath = valueAfter(args, "--receipt");
  if (receiptPath && artifactStage === "export" && !ipaPathArg) {
    throw new Error("An exported identity receipt requires --ipa <signed.ipa>.");
  }
  const artifactBinding = ipaPathArg ? buildArtifactBinding(ipaPathArg) : undefined;
  if (extractedIpa) {
    assertStableArtifactBinding(extractedIpa.artifactBindingBefore, artifactBinding);
  }
  const receipt = buildReleaseIdentityReceipt({
    target,
    appInfo,
    firebaseInfo,
    signedEntitlements,
    artifactStage,
    artifactBinding,
    googleMapsApiKey: ipaPathArg ? stringValue(appInfo.GoogleMapsApiKey) : undefined,
    signatureVerified,
  });
  if (receiptPath) {
    const resolvedReceipt = path.resolve(receiptPath);
    fs.mkdirSync(path.dirname(resolvedReceipt), {recursive: true});
    fs.writeFileSync(resolvedReceipt, `${JSON.stringify(receipt, null, 2)}\n`);
  }
  console.log(JSON.stringify(receipt, null, 2));
  } finally {
    extractedIpa?.cleanup();
  }
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
