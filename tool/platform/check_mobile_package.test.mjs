import test from "node:test";
import assert from "node:assert/strict";
import {
  comparePackageReports,
  evaluatePackageReport,
  packageBudgetHeadroom,
  validatePackagePolicy,
} from "./check_mobile_package.mjs";

const policy = {
  forbiddenEntries: ["flutter_assets/assets/fixtures/"],
  platforms: {
    ios: {
      host: {
        maxArtifactBytes: 100,
        maxUncompressedBytes: 200,
        forbiddenNativeEntries: ["health.framework"],
      },
    },
  },
  comparison: {
    requireDifferentAppBinary: true,
    requireDifferentEntrySet: true,
  },
};

test("package policy enforces budgets and role-forbidden payload", () => {
  const findings = evaluatePackageReport({
    policy,
    report: {
      role: "host",
      platform: "ios",
      artifactKind: "archive",
      artifactBytes: 101,
      uncompressedBytes: 201,
      entries: [
        {path: "Payload/App/Frameworks/health.framework/health"},
        {path: "Payload/App/flutter_assets/assets/fixtures/person.jpg"},
      ],
    },
  });
  assert.equal(findings.length, 4);
});

test("expanded app directories enforce payload size but not archive size", () => {
  const findings = evaluatePackageReport({
    policy,
    report: {
      role: "host",
      platform: "ios",
      artifactKind: "expandedDirectory",
      artifactBytes: 101,
      uncompressedBytes: 199,
      entries: [],
    },
  });
  assert.deepEqual(findings, []);
});

test("cross-role comparison rejects identical compiled products", () => {
  const report = {
    platform: "ios",
    appBinaries: [{sha256: "same"}],
    entries: [{path: "Payload/App"}],
  };
  assert.deepEqual(
    comparePackageReports({consumer: report, host: report, policy}),
    [
      "Consumer and Host compiled app binaries are byte-identical.",
      "Consumer and Host package entry sets are identical.",
    ],
  );
});

test("cross-role comparison fails closed on missing or asymmetric binaries", () => {
  const findings = comparePackageReports({
    consumer: {platform: "android", appBinaries: [], entries: [{path: "consumer"}]},
    host: {
      platform: "android",
      appBinaries: [{sha256: "host"}],
      entries: [{path: "host"}],
    },
    policy,
  });
  assert.deepEqual(findings, [
    "Consumer and Host package reports must each contain compiled app binaries.",
    "Consumer and Host package reports must contain the same app-binary count.",
  ]);
});

test("signed-package baselines must fit inside bounded budget headroom", () => {
  const calibratedPolicy = {
    baseline: {
      requireSignedArtifactMeasurements: true,
      maxBudgetHeadroomRatio: 0.2,
    },
    platforms: {
      ios: {
        host: {
          baselineArtifactBytes: 100,
          maxArtifactBytes: 130,
          baselineUncompressedBytes: 200,
          maxUncompressedBytes: 199,
        },
      },
    },
  };
  assert.deepEqual(validatePackagePolicy(calibratedPolicy), [
    "ios/host maxArtifactBytes has more than 20% headroom over baselineArtifactBytes.",
    "ios/host baselineUncompressedBytes 200 exceeds maxUncompressedBytes 199.",
  ]);
});

test("legacy test policies may omit signed baselines", () => {
  assert.deepEqual(validatePackagePolicy(policy), []);
});


test("headroom reports remaining capacity, exact limits, overruns, and expanded payloads", () => {
  const report = {role: "host", platform: "ios", artifactKind: "archive",
    artifactBytes: 80, uncompressedBytes: 200};
  assert.deepEqual(packageBudgetHeadroom({report, policy}), {
    artifact: {budgetBytes: 100, remainingBytes: 20, remainingRatio: 0.2},
    uncompressed: {budgetBytes: 200, remainingBytes: 0, remainingRatio: 0},
  });
  assert.equal(packageBudgetHeadroom({report: {...report, artifactBytes: 110}, policy}).artifact.remainingBytes, -10);
  assert.equal(packageBudgetHeadroom({report: {...report, artifactKind: "expandedDirectory"}, policy}).artifact, null);
  assert.equal(packageBudgetHeadroom({report: {...report, role: "missing"}, policy}), null);
});
