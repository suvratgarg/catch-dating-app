#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {
  defaultRepoRoot,
  loadAppTargets,
} from "./resolve_app_target.mjs";

const expectedRoles = ["consumer", "host"];
const expectedEnvironments = ["dev", "staging", "prod"];

export function validateManifestShape(manifest) {
  const findings = [];
  if (manifest?.schemaVersion !== 1) findings.push("schemaVersion must be 1");
  if (manifest?.logicalName !== "catch-installable-app-targets") {
    findings.push("logicalName must be catch-installable-app-targets");
  }
  for (const role of expectedRoles) {
    if (!manifest?.roles?.[role]) findings.push(`missing role ${role}`);
  }
  for (const environment of expectedEnvironments) {
    if (!manifest?.environments?.[environment]) {
      findings.push(`missing environment ${environment}`);
    }
  }

  const targets = manifest?.targets ?? [];
  if (targets.length !== 6) findings.push(`expected 6 targets, found ${targets.length}`);
  const ids = new Set();
  const pairs = new Set();
  const iosBundleIds = new Set();
  const androidApplicationIds = new Set();
  for (const target of targets) {
    if (!target.entrypoint) findings.push(`${target.id}: entrypoint is required`);
    if (ids.has(target.id)) findings.push(`duplicate target id ${target.id}`);
    ids.add(target.id);
    const pair = `${target.role}/${target.environment}`;
    if (pairs.has(pair)) findings.push(`duplicate target pair ${pair}`);
    pairs.add(pair);
    if (!expectedRoles.includes(target.role)) findings.push(`${target.id}: invalid role`);
    if (!expectedEnvironments.includes(target.environment)) {
      findings.push(`${target.id}: invalid environment`);
    }
    if (iosBundleIds.has(target.ios?.bundleId)) {
      findings.push(`${target.id}: duplicate iOS bundle id ${target.ios?.bundleId}`);
    }
    iosBundleIds.add(target.ios?.bundleId);
    if (androidApplicationIds.has(target.android?.applicationId)) {
      findings.push(
        `${target.id}: duplicate Android application id ${target.android?.applicationId}`,
      );
    }
    androidApplicationIds.add(target.android?.applicationId);
  }
  for (const role of expectedRoles) {
    for (const environment of expectedEnvironments) {
      if (!pairs.has(`${role}/${environment}`)) {
        findings.push(`missing target pair ${role}/${environment}`);
      }
    }
  }
  return findings;
}

export function androidClientFor(config, applicationId) {
  return config.client?.find(
    (client) =>
      client.client_info?.android_client_info?.package_name === applicationId,
  );
}

export function parseAppleBuildConfigurations(source) {
  const configurations = [];
  const pattern =
    /buildSettings = \{([\s\S]*?)\n\s*\};\n\s*name = ([^;]+);/gu;
  for (const match of source.matchAll(pattern)) {
    const settings = {};
    for (const line of match[1].split(/\r?\n/u)) {
      const setting = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*);\s*$/u);
      if (!setting) continue;
      settings[setting[1]] = unquoteBuildSetting(setting[2]);
    }
    if (settings.CATCH_APP_TARGET_ID) {
      configurations.push({name: unquoteBuildSetting(match[2].trim()), settings});
    }
  }
  return configurations;
}

export function validateAndroidBuildSource(source) {
  const findings = [];
  for (const marker of [
    "app_targets.json",
    "installableAppTargets",
    "requestedAppTarget",
    "target = requestedAppTarget",
  ]) {
    if (!source.includes(marker)) {
      findings.push(`Android target generation is missing manifest binding '${marker}'`);
    }
  }
  for (const taskPrefix of ["assemble", "bundle", "build", "check", "test", "lint"]) {
    if (!source.includes(`\"${taskPrefix}\"`)) {
      findings.push(`Android app-target guard does not cover aggregate '${taskPrefix}' tasks`);
    }
  }
  return findings;
}

export function validateSharedAndroidManifestSource(source) {
  const findings = [];
  for (const [label, marker] of [
    ["Health Connect", "android.permission.health.READ_EXERCISE"],
    ["public app links", 'android:autoVerify="true"'],
  ]) {
    if (source.includes(marker)) {
      findings.push(`Android shared base manifest must not own Consumer-only ${label}`);
    }
  }
  return findings;
}

export function hasActiveDebt(manifest, debtId) {
  return (manifest.transitionalDebt ?? []).some(
    (debt) => debt.id === debtId && debt.status !== "resolved",
  );
}

export function validateReleaseOwnership({manifest, workflowSource}) {
  const findings = [];
  const warnings = [];
  const policy = manifest.releasePolicy ?? {};
  const workflow = ".github/workflows/mobile-internal-release.yml";
  for (const [label, actual, expected] of [
    ["release owner", policy.owner, "github-actions"],
    ["release workflow", policy.workflow, workflow],
    ["release trigger", policy.trigger, "app-relevant-main-push"],
    ["release environment", policy.environment, "prod-mobile"],
    ["release approval mode", policy.approvalMode, "none-after-main-merge"],
    ["release branch policy", policy.branchPolicy, "main-only"],
    ["iOS channel", policy.ios?.channel, "testflight"],
    ["iOS upload mode", policy.ios?.uploadMode, "automatic-main"],
    ["Android channel", policy.android?.channel, "play-internal"],
    ["Android track", policy.android?.track, "qa"],
    ["Android publisher auth", policy.android?.publisherAuth, "github-oidc"],
    [
      "Android publisher service account",
      policy.android?.publisherServiceAccount,
      "github-actions-play-publisher@catch-dating-app-64e51.iam.gserviceaccount.com",
    ],
  ]) {
    if (actual !== expected) findings.push(`${label} was '${actual ?? ""}'; expected '${expected}'`);
  }
  if (JSON.stringify(policy.roles) !== JSON.stringify(expectedRoles)) {
    findings.push("release policy roles must be [consumer, host]");
  }
  if (!/^[A-F0-9]{64}$/u.test(policy.android?.uploadCertificateSha256 ?? "")) {
    findings.push("Android upload certificate SHA-256 must be a checked 64-digit hex value");
  }

  const prodTargets = (manifest.targets ?? []).filter((target) => target.environment === "prod");
  for (const target of prodTargets) {
    if (target.release?.owner !== "github-actions") {
      findings.push(`${target.id}: release owner must be github-actions`);
    }
    if (target.release?.githubMode !== "automatic-main") {
      findings.push(`${target.id}: githubMode must be automatic-main`);
    }
    if (target.release?.githubWorkflow !== workflow) {
      findings.push(`${target.id}: release workflow must be ${workflow}`);
    }
    if (target.release?.googlePlayPackageName !== target.android?.applicationId) {
      findings.push(`${target.id}: Google Play package must match Android application id`);
    }
    if (!target.release?.legacyXcodeCloudWorkflow) {
      findings.push(`${target.id}: legacy Xcode Cloud workflow name is required for cutover`);
    }
  }

  for (const [label, marker] of [
    ["push-to-main trigger", /push:\s*[\s\S]*?branches:\s*[\s\S]*?- main/u],
    ["consumer role matrix", /roles='\["consumer","host"\]'/u],
    ["iOS role matrix", /prod-ios:[\s\S]*?matrix:[\s\S]*?app_role/u],
    ["Android role matrix", /prod-android:[\s\S]*?matrix:[\s\S]*?app_role/u],
    ["mobile credentials environment", /environment:\s*prod-mobile/u],
    ["TestFlight upload", /Upload to TestFlight/u],
    ["signed Android identity verification", /verify_android_release_bundle\.mjs/u],
    ["Play internal track", /--track qa/u],
    ["non-committing Play access probe", /probe_google_play_access\.mjs/u],
    ["legacy Xcode Cloud retirement", /set_xcode_cloud_workflow_state\.mjs/u],
    ["serialized release concurrency", /concurrency:[\s\S]*?cancel-in-progress:\s*false/u],
    ["App Store build-floor and processing proof", /verify_app_store_build\.mjs/u],
    ["pinned bundletool checksum", /BUNDLETOOL_SHA256/u],
    ["processed-build retirement evidence", /consumer_processed_ios_build_number/u],
    ["GitHub processing-receipt retirement evidence", /verify_ios_processing_receipts\.mjs/u],
    ["main-only signed release guard", /refs\/heads\/main/u],
  ]) {
    if (!marker.test(workflowSource)) findings.push(`mobile release workflow is missing ${label}`);
  }

  for (const debtId of [
    "APP-TARGET-IOS-GITHUB-CUTOVER-001",
    "APP-TARGET-ANDROID-PLAY-001",
  ]) {
    if (hasActiveDebt(manifest, debtId)) {
      warnings.push(`${debtId}: external store distribution proof remains pending`);
    } else {
      findings.push(`${debtId}: missing active external-proof debt record`);
    }
  }
  return {findings, warnings};
}

export function scanAppTargets({root = defaultRepoRoot} = {}) {
  const manifest = loadAppTargets({root});
  const findings = validateManifestShape(manifest);
  const warnings = [];
  const read = (relativePath) =>
    fs.readFileSync(resolveRepoPath(root, relativePath, findings), "utf8");

  for (const role of expectedRoles) {
    const roleConfig = manifest.roles?.[role];
    if (!roleConfig) continue;
    for (const field of ["entrypoint", "iosEntitlements", "androidManifestOverlay"]) {
      checkRepoFile(root, roleConfig[field], `${role}.${field}`, findings);
    }
    const entrypointPath = resolveRepoPath(root, roleConfig.entrypoint, findings);
    if (fs.existsSync(entrypointPath)) {
      const source = fs.readFileSync(entrypointPath, "utf8");
      if (!source.includes(`AppRole.${role}`)) {
        findings.push(`${role}.entrypoint does not install AppRole.${role}`);
      }
    }
  }

  const appleGeneratorPath = path.join(root, "tool/platform/configure_apple_flavors.rb");
  const appleGenerator = fs.existsSync(appleGeneratorPath)
    ? fs.readFileSync(appleGeneratorPath, "utf8")
    : "";
  if (
    !appleGenerator.includes("APP_TARGETS_PATH") ||
    !appleGenerator.includes("app_targets.json")
  ) {
    findings.push("Apple flavor generator does not read tool/app_targets.json");
  }

  const androidBuildPath = path.join(root, "android/app/build.gradle.kts");
  const androidBuild = fs.existsSync(androidBuildPath)
    ? fs.readFileSync(androidBuildPath, "utf8")
    : "";
  if (androidBuild.includes("catchAppRole")) {
    findings.push("Android still selects product identity through catchAppRole");
  }
  findings.push(...validateAndroidBuildSource(androidBuild));

  const sharedAndroidManifestPath = path.join(root, "android/app/src/main/AndroidManifest.xml");
  if (fs.existsSync(sharedAndroidManifestPath)) {
    findings.push(
      ...validateSharedAndroidManifestSource(
        fs.readFileSync(sharedAndroidManifestPath, "utf8"),
      ),
    );
  } else {
    findings.push("missing Android shared base manifest");
  }

  const appleProjectPath = path.join(root, "ios/Runner.xcodeproj/project.pbxproj");
  const appleProject = fs.existsSync(appleProjectPath)
    ? fs.readFileSync(appleProjectPath, "utf8")
    : "";
  const appleConfigurations = parseAppleBuildConfigurations(appleProject);
  const macosProjectPath = path.join(root, "macos/Runner.xcodeproj/project.pbxproj");
  const macosProject = fs.existsSync(macosProjectPath)
    ? fs.readFileSync(macosProjectPath, "utf8")
    : "";
  const macosConfigurations = parseAppleBuildConfigurations(macosProject);

  for (const target of manifest.targets ?? []) {
    validateTarget({
      root,
      manifest,
      target,
      findings,
      read,
      appleGenerator,
      appleConfigurations,
      macosConfigurations,
    });
  }

  validateRoleCapabilities({root, manifest, findings});
  validateDeepLinkOwnership({root, manifest, findings});
  validateRemoteConfigOwnership({root, manifest, findings});

  const prodWorkflow = path.join(root, ".github/workflows/mobile-internal-release.yml");
  if (fs.existsSync(prodWorkflow)) {
    const releaseResult = validateReleaseOwnership({
      manifest,
      workflowSource: fs.readFileSync(prodWorkflow, "utf8"),
    });
    findings.push(...releaseResult.findings);
    warnings.push(...releaseResult.warnings);
  } else {
    findings.push("missing .github/workflows/mobile-internal-release.yml");
  }

  return {manifest, findings, warnings};
}

function validateTarget({
  root,
  manifest,
  target,
  findings,
  read,
  appleGenerator,
  appleConfigurations,
  macosConfigurations,
}) {
  const label = target.id ?? "<missing-target-id>";
  const environment = manifest.environments?.[target.environment];
  if (target.firebase?.projectId !== environment?.firebaseProjectId) {
    findings.push(`${label}: Firebase project does not match environment contract`);
  }

  checkRepoFile(root, target.entrypoint, `${label}.entrypoint`, findings);
  const entrypointPath = resolveRepoPath(root, target.entrypoint, findings);
  if (fs.existsSync(entrypointPath)) {
    const source = fs.readFileSync(entrypointPath, "utf8");
    for (const marker of [
      `AppRole.${target.role}`,
      `AppEnvironment.${target.environment}`,
    ]) {
      if (!source.includes(marker)) {
        findings.push(`${label}: entrypoint is missing ${marker}`);
      }
    }
  }

  for (const platform of ["android", "ios", "macos", "web"]) {
    checkRepoFile(
      root,
      target.firebase?.[platform]?.configPath,
      `${label}.firebase.${platform}.configPath`,
      findings,
    );
  }
  checkRepoFile(root, target.firebase?.dartOptionsFile, `${label}.dartOptionsFile`, findings);

  const androidPath = resolveRepoPath(root, target.firebase?.android?.configPath, findings);
  if (fs.existsSync(androidPath)) {
    const config = JSON.parse(fs.readFileSync(androidPath, "utf8"));
    const client = androidClientFor(config, target.android?.applicationId);
    if (!client) {
      findings.push(`${label}: Android Firebase config has no ${target.android?.applicationId} client`);
    } else if (client.client_info?.mobilesdk_app_id !== target.firebase.android.appId) {
      findings.push(`${label}: Android Firebase app id drift`);
    }
    if (config.project_info?.project_id !== target.firebase.projectId) {
      findings.push(`${label}: Android Firebase project id drift`);
    }
  }

  for (const platform of ["ios", "macos"]) {
    const configPath = resolveRepoPath(root, target.firebase?.[platform]?.configPath, findings);
    if (!fs.existsSync(configPath)) continue;
    const plist = fs.readFileSync(configPath, "utf8");
    if (plistString(plist, "GOOGLE_APP_ID") !== target.firebase[platform].appId) {
      findings.push(`${label}: ${platform} Firebase app id drift`);
    }
    if (plistString(plist, "BUNDLE_ID") !== target.ios.bundleId) {
      findings.push(`${label}: ${platform} Firebase bundle id drift`);
    }
    if (plistString(plist, "PROJECT_ID") !== target.firebase.projectId) {
      findings.push(`${label}: ${platform} Firebase project id drift`);
    }
  }

  const webPath = resolveRepoPath(root, target.firebase?.web?.configPath, findings);
  if (fs.existsSync(webPath)) {
    const webSource = fs.readFileSync(webPath, "utf8");
    for (const expected of [target.firebase.web.appId, target.firebase.projectId]) {
      if (!webSource.includes(expected)) findings.push(`${label}: web Firebase config missing ${expected}`);
    }
  }

  const dartOptionsPath = resolveRepoPath(root, target.firebase?.dartOptionsFile, findings);
  if (fs.existsSync(dartOptionsPath)) {
    const dartSource = fs.readFileSync(dartOptionsPath, "utf8");
    for (const platform of ["android", "ios", "macos", "web"]) {
      const member = target.firebase.dartOptionsMembers?.[platform];
      const block = firebaseOptionsBlock(dartSource, member);
      if (!block) {
        findings.push(`${label}: missing Dart Firebase options member ${member}`);
        continue;
      }
      for (const expected of [target.firebase[platform].appId, target.firebase.projectId]) {
        if (!block.includes(expected)) {
          findings.push(`${label}: Dart ${member} options missing ${expected}`);
        }
      }
    }
  }

  validateAppleScheme({root, target, platform: "ios", findings});
  validateAppleScheme({root, target, platform: "macos", findings});

  validateAppleTargetConfigurations({
    manifest,
    target,
    platform: "ios",
    configurations: appleConfigurations,
    findings,
  });
  validateAppleTargetConfigurations({
    manifest,
    target,
    platform: "macos",
    configurations: macosConfigurations,
    findings,
  });
  for (const platform of ["ios", "macos"]) {
    const iconPath = path.join(
      root,
      platform,
      "Runner/Assets.xcassets",
      `${target.ios.iconSet}.appiconset/Contents.json`,
    );
    if (!fs.existsSync(iconPath)) {
      findings.push(`${label}: missing ${platform} icon set ${target.ios.iconSet}`);
    }
  }

  const androidResRoot = target.android.iconSourceSet === "main"
    ? path.join(root, "android/app/src/main/res")
    : path.join(root, "android/app/src", target.android.iconSourceSet, "res");
  for (const icon of ["ic_launcher.png", "ic_launcher_round.png"]) {
    if (!findFile(androidResRoot, icon)) {
      findings.push(`${label}: ${target.android.iconSourceSet} is missing ${icon}`);
    }
  }

  if (target.release && target.release.appStoreConnectAppId !== manifest.roles[target.role].storeProduct.appStoreConnectAppId) {
    findings.push(`${label}: App Store Connect id differs from role store product`);
  }
}

function validateAppleScheme({root, target, platform, findings}) {
  const schemePath = path.join(
    root,
    `${platform}/Runner.xcodeproj/xcshareddata/xcschemes`,
    `${target.ios.scheme}.xcscheme`,
  );
  if (!fs.existsSync(schemePath)) {
    findings.push(`${target.id}: missing ${platform} scheme ${target.ios.scheme}`);
    return;
  }
  const scheme = fs.readFileSync(schemePath, "utf8");
  for (const configuration of Object.values(target.ios.configurations ?? {})) {
    if (!scheme.includes(`buildConfiguration = "${configuration}"`)) {
      findings.push(`${target.id}: ${platform} scheme missing ${configuration}`);
    }
  }
  if (!scheme.includes(`BuildableName = "${target.displayName}.app"`)) {
    findings.push(`${target.id}: ${platform} scheme product name drift`);
  }
}

function validateAppleTargetConfigurations({
  manifest,
  target,
  platform,
  configurations,
  findings,
}) {
  const role = manifest.roles[target.role];
  const expectedSettings = {
    PRODUCT_BUNDLE_IDENTIFIER: target.ios.bundleId,
    PRODUCT_NAME: target.displayName,
    ASSETCATALOG_COMPILER_APPICON_NAME: target.ios.iconSet,
    CATCH_APP_TARGET_ID: target.id,
    FLUTTER_TARGET: `$(SRCROOT)/../${target.entrypoint}`,
    FLAVOR: target.ios.scheme,
    FIREBASE_ENV: target.environment,
    FIREBASE_ROLE: target.role,
    FIREBASE_ROLE_PATH: target.role === "host" ? "host/" : "",
  };
  if (platform === "ios") {
    expectedSettings.APP_DISPLAY_NAME = target.displayName;
    expectedSettings.CODE_SIGN_ENTITLEMENTS = role.iosEntitlements.replace(/^ios\//u, "");
    expectedSettings.FIREBASE_IOS_URL_SCHEME = target.ios.urlScheme;
  }

  for (const configurationName of Object.values(target.ios.configurations ?? {})) {
    const matches = configurations.filter(
      (configuration) => configuration.name === configurationName,
    );
    if (matches.length !== 1) {
      findings.push(
        `${target.id}: expected one ${platform} Runner configuration ${configurationName}; found ${matches.length}`,
      );
      continue;
    }
    for (const [key, expected] of Object.entries(expectedSettings)) {
      const actual = matches[0].settings[key];
      if (actual !== expected) {
        findings.push(
          `${target.id}: ${configurationName} ${key} was '${actual ?? ""}'; expected '${expected}'`,
        );
      }
    }
  }
}

function validateRoleCapabilities({root, manifest, findings}) {
  for (const role of expectedRoles) {
    const roleConfig = manifest.roles[role];
    const entitlementsPath = resolveRepoPath(root, roleConfig.iosEntitlements, findings);
    const entitlements = fs.existsSync(entitlementsPath)
      ? fs.readFileSync(entitlementsPath, "utf8")
      : "";
    const androidManifestPath = resolveRepoPath(root, roleConfig.androidManifestOverlay, findings);
    const androidManifest = fs.existsSync(androidManifestPath)
      ? fs.readFileSync(androidManifestPath, "utf8")
      : "";
    const expectsConsumerCapabilities = role === "consumer";
    for (const [label, source, marker] of [
      ["HealthKit", entitlements, "com.apple.developer.healthkit"],
      ["associated domains", entitlements, "com.apple.developer.associated-domains"],
      ["Health Connect", androidManifest, "android.permission.health.READ_EXERCISE"],
      ["public app links", androidManifest, "android:autoVerify=\"true\""],
    ]) {
      if (expectsConsumerCapabilities && !source.includes(marker)) {
        findings.push(`${role}: missing ${label} capability`);
      }
      if (!expectsConsumerCapabilities && source.includes(marker)) {
        findings.push(`${role}: must not inherit ${label} capability`);
      }
    }
  }
}

function validateDeepLinkOwnership({root, manifest, findings}) {
  const aasaPath = path.join(root, "website/public/.well-known/apple-app-site-association");
  const assetLinksPath = path.join(root, "website/public/.well-known/assetlinks.json");
  if (!fs.existsSync(aasaPath) || !fs.existsSync(assetLinksPath)) {
    findings.push("missing public deep-link association files");
    return;
  }
  const aasa = JSON.parse(fs.readFileSync(aasaPath, "utf8"));
  const assetLinks = JSON.parse(fs.readFileSync(assetLinksPath, "utf8"));
  const appleIds = new Set((aasa.applinks?.details ?? []).map((item) => item.appID));
  const androidPackages = new Set(assetLinks.map((item) => item.target?.package_name));
  const teamId = "2HQBK4UMUT";
  for (const target of manifest.targets ?? []) {
    const ownsLinks = manifest.roles[target.role].deepLinks.policy === "public-event-links";
    const appleId = `${teamId}.${target.ios.bundleId}`;
    if (ownsLinks !== appleIds.has(appleId)) {
      findings.push(`${target.id}: Apple deep-link ownership drift`);
    }
    if (ownsLinks !== androidPackages.has(target.android.applicationId)) {
      findings.push(`${target.id}: Android deep-link ownership drift`);
    }
  }
}

function validateRemoteConfigOwnership({root, manifest, findings}) {
  const templatePath = path.join(root, "firebase/remote_config.template.json");
  const providerPath = path.join(root, "lib/force_update/data/app_version_config_provider.dart");
  if (!fs.existsSync(templatePath) || !fs.existsSync(providerPath)) {
    findings.push("missing force-update source files");
    return;
  }
  const parameters = JSON.parse(fs.readFileSync(templatePath, "utf8")).parameters ?? {};
  for (const role of expectedRoles) {
    const prefix = manifest.roles[role].remoteConfigPrefix;
    for (const suffix of [
      "min_version",
      "min_build_android",
      "min_build_ios",
      "min_build_web",
      "min_build_macos",
      "store_url_android",
      "store_url_ios",
    ]) {
      if (!parameters[`${prefix}_${suffix}`]) {
        findings.push(`Remote Config is missing ${prefix}_${suffix}`);
      }
    }
  }
  const providerSource = fs.readFileSync(providerPath, "utf8");
  if (!providerSource.includes("AppConfig.appRole")) {
    findings.push("force-update provider does not select keys by app role");
  }
}

function checkRepoFile(root, relativePath, label, findings) {
  if (!relativePath) {
    findings.push(`${label}: path is required`);
    return;
  }
  const resolved = resolveRepoPath(root, relativePath, findings);
  if (!fs.existsSync(resolved)) findings.push(`${label}: missing ${relativePath}`);
}

function resolveRepoPath(root, relativePath, findings) {
  const safePath = typeof relativePath === "string" ? relativePath : "";
  if (path.isAbsolute(safePath)) findings.push(`absolute repo path is forbidden: ${safePath}`);
  const resolved = path.resolve(root, safePath);
  if (resolved !== root && !resolved.startsWith(`${root}${path.sep}`)) {
    findings.push(`repo path escapes root: ${safePath}`);
  }
  return resolved;
}

function plistString(source, key) {
  const escaped = key.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
  return source.match(new RegExp(`<key>${escaped}</key>\\s*<string>([^<]+)</string>`, "u"))?.[1];
}

function firebaseOptionsBlock(source, member) {
  if (!member) return null;
  const start = source.indexOf(`static const FirebaseOptions ${member} = FirebaseOptions(`);
  if (start < 0) return null;
  const end = source.indexOf("\n  );", start);
  return end < 0 ? source.slice(start) : source.slice(start, end + 5);
}

function findFile(root, filename) {
  if (!fs.existsSync(root)) return false;
  const queue = [root];
  while (queue.length > 0) {
    const current = queue.pop();
    for (const entry of fs.readdirSync(current, {withFileTypes: true})) {
      const candidate = path.join(current, entry.name);
      if (entry.isDirectory()) queue.push(candidate);
      if (entry.isFile() && entry.name === filename) return true;
    }
  }
  return false;
}

function unquoteBuildSetting(value) {
  if (value.startsWith('"') && value.endsWith('"')) {
    return value.slice(1, -1);
  }
  return value;
}

function runCli() {
  const result = scanAppTargets();
  console.log(
    `App targets: ${result.manifest.targets.length} checked, ${result.findings.length} finding(s), ${result.warnings.length} transitional warning(s).`,
  );
  for (const warning of result.warnings) console.warn(`- warning: ${warning}`);
  if (result.findings.length > 0) {
    for (const finding of result.findings) console.error(`- ${finding}`);
    process.exitCode = 1;
  }
}

const isMain = process.argv[1]
  ? path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)
  : false;
if (isMain) {
  try {
    runCli();
  } catch (error) {
    console.error(error.stack ?? error.message);
    process.exitCode = 1;
  }
}
