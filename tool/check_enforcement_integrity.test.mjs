import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {execFileSync} from "node:child_process";
import test from "node:test";
import {checkEnforcementIntegrity as checkWithRepositorySnapshot} from "./check_enforcement_integrity.mjs";

function checkEnforcementIntegrity({root}) {
  return checkWithRepositorySnapshot({root, snapshot: fixtureSnapshot(root)});
}

test("passes with manual and tool-backed enforcement", () => {
  const root = createFixture({
    rules: {
      "MANUAL-001": manualRule(),
      "TOOLED-001": {
        ...manualRule(),
        enforcement: [
          {
            tool: "audit:sample",
            stage: "scanner-gate",
            docAnchor: "docs/app_architecture.md#error-scanners",
          },
        ],
      },
    },
    tools: [
      gateTool({
        id: "audit:sample",
        path: "tool/architecture/check_sample.mjs",
        command: "node tool/architecture/check_sample.mjs",
        rules: ["TOOLED-001"],
        proofPath: "tool/architecture/check_sample.test.mjs",
        proofContains: ["flags bad input"],
      }),
    ],
    docs: {"docs/app_architecture.md": "# App Architecture\n\n### Error Scanners\n"},
    files: {
      "tool/architecture/check_sample.mjs": "#!/usr/bin/env node\n",
      "tool/architecture/check_sample.test.mjs":
        "test('flags bad input', () => {});\n",
    },
  });

  assert.deepEqual(checkEnforcementIntegrity({root}).errors, []);
});

test("fails when an active rule has no enforcement", () => {
  const root = createFixture({
    rules: {
      "RULE-001": {
        ...manualRule(),
        enforcement: undefined,
      },
    },
  });

  assert.match(
    checkEnforcementIntegrity({root}).errors.join("\n"),
    /RULE-001: active rule has no enforcement entries/u,
  );
});

test("fails on one-way tool mappings", () => {
  const root = createFixture({
    rules: {
      "RULE-001": {
        ...manualRule(),
        enforcement: [
          {
            tool: "audit:sample",
            stage: "scanner-gate",
            docAnchor: "docs/app_architecture.md#error-scanners",
          },
        ],
      },
    },
    tools: [
      gateTool({
        id: "audit:sample",
        path: "tool/architecture/check_sample.mjs",
        command: "node tool/architecture/check_sample.mjs",
        rules: ["OTHER-RULE"],
        proofPath: "tool/architecture/check_sample.test.mjs",
      }),
    ],
    docs: {"docs/app_architecture.md": "# App Architecture\n\n### Error Scanners\n"},
    files: {
      "tool/architecture/check_sample.mjs": "#!/usr/bin/env node\n",
      "tool/architecture/check_sample.test.mjs": "flags bad input\n",
    },
  });

  const errors = checkEnforcementIntegrity({root}).errors.join("\n");
  assert.match(errors, /RULE-001: tool audit:sample is missing reverse rules mapping/u);
  assert.match(errors, /audit:sample: references unknown rule OTHER-RULE/u);
});

test("fails gate tools that only run count or syntax checks", () => {
  const root = createFixture({
    rules: {
      "RULE-001": {
        ...manualRule(),
        enforcement: [
          {
            tool: "scanner:count-only",
            stage: "scanner-gate",
            docAnchor: "docs/app_architecture.md#error-scanners",
          },
        ],
      },
    },
    tools: [
      {
        id: "scanner:count-only",
        category: "lint",
        path: "tool/check_count_only.sh",
        command: "bash tool/check_count_only.sh",
        status: "active",
        role: "gate",
        rules: ["RULE-001"],
        checks: ["bash -n tool/check_count_only.sh", "bash tool/check_count_only.sh --count"],
        vacuityProof: {
          type: "probe-harness",
          path: "tool/check_probe.sh",
          diagnostics: ["catch_no_allow_debt"],
        },
      },
    ],
    docs: {"docs/app_architecture.md": "# App Architecture\n\n### Error Scanners\n"},
    files: {
      "tool/check_count_only.sh": "#!/usr/bin/env bash\n",
      "tool/check_probe.sh": "catch_no_allow_debt\n",
    },
  });

  assert.match(
    checkEnforcementIntegrity({root}).errors.join("\n"),
    /needs a manifest check that can execute the guard/u,
  );
});

test("fails role-less covered runtime tools", () => {
  const root = createFixture({
    rules: {
      "RULE-001": manualRule(),
    },
    tools: [
      {
        id: "audit:unclassified",
        category: "audit",
        path: "tool/audit/unclassified.dart",
        command: "dart tool/audit/unclassified.dart",
        status: "active",
        checks: [
          "dart analyze tool/audit/unclassified.dart",
          "dart tool/audit/unclassified.dart --check",
        ],
      },
    ],
    files: {
      "tool/audit/unclassified.dart": "void main() {}\n",
    },
  });

  assert.match(
    checkEnforcementIntegrity({root}).errors.join("\n"),
    /audit:unclassified: active checked tool must declare role/u,
  );
});

test("fails root check tools that omit roles even with syntax-only checks", () => {
  const root = createFixture({
    rules: {
      "RULE-001": manualRule(),
    },
    tools: [
      {
        id: "meta:missing-role",
        category: "meta",
        path: "tool/check_missing_role.mjs",
        command: "node tool/check_missing_role.mjs",
        status: "active",
        checks: ["node --check tool/check_missing_role.mjs"],
      },
    ],
    files: {
      "tool/check_missing_role.mjs": "#!/usr/bin/env node\n",
    },
  });

  assert.match(
    checkEnforcementIntegrity({root}).errors.join("\n"),
    /meta:missing-role: active checked tool must declare role/u,
  );
});

test("fails satisfied sunset signals without review", () => {
  const root = createFixture({
    rules: {
      "RULE-001": {
        ...manualRule(),
        sunset_signals: [{type: "tool-exists", tool: "audit:sample"}],
      },
    },
    tools: [
      gateTool({
        id: "audit:sample",
        path: "tool/architecture/check_sample.mjs",
        command: "node tool/architecture/check_sample.mjs",
        rules: ["RULE-001"],
        proofPath: "tool/architecture/check_sample.test.mjs",
      }),
    ],
    files: {
      "tool/architecture/check_sample.mjs": "#!/usr/bin/env node\n",
      "tool/architecture/check_sample.test.mjs": "flags bad input\n",
    },
  });

  assert.match(
    checkEnforcementIntegrity({root}).errors.join("\n"),
    /RULE-001: sunset signal satisfied \(tool-exists:audit:sample\) but sunset_review is missing or invalid/u,
  );
});

test("passes satisfied sunset signals with review", () => {
  const root = createFixture({
    rules: {
      "RULE-001": {
        ...manualRule(),
        enforcement: [
          {
            tool: "audit:sample",
            stage: "scanner-gate",
            docAnchor: "docs/app_architecture.md#error-scanners",
          },
        ],
        sunset_signals: [{type: "tool-exists", tool: "audit:sample"}],
        sunset_review: {
          date: "2026-07-02",
          decision: "keep",
          note: "scanner exists but the manual review point remains active.",
        },
      },
    },
    tools: [
      gateTool({
        id: "audit:sample",
        path: "tool/architecture/check_sample.mjs",
        command: "node tool/architecture/check_sample.mjs",
        rules: ["RULE-001"],
        proofPath: "tool/architecture/check_sample.test.mjs",
      }),
    ],
    docs: {"docs/app_architecture.md": "# App Architecture\n\n### Error Scanners\n"},
    files: {
      "tool/architecture/check_sample.mjs": "#!/usr/bin/env node\n",
      "tool/architecture/check_sample.test.mjs": "flags bad input\n",
    },
  });

  assert.deepEqual(checkEnforcementIntegrity({root}).errors, []);
});

test("fails satisfied baseline-empty sunset signals without review", () => {
  const root = createFixture({
    rules: {
      "RULE-001": {
        ...manualRule(),
        sunset_signals: [
          {
            type: "baseline-empty",
            baseline: "tool/sample_baseline.json",
            countKey: "allowedFindings",
          },
        ],
      },
    },
    files: {
      "tool/sample_baseline.json": JSON.stringify({allowedFindings: []}),
    },
  });

  assert.match(
    checkEnforcementIntegrity({root}).errors.join("\n"),
    /baseline-empty:tool\/sample_baseline\.json:allowedFindings/u,
  );
});

test("counts entry-list baselines for sunset signals", () => {
  const root = createFixture({
    rules: {
      "RULE-001": {
        ...manualRule(),
        sunset_signals: [
          {
            type: "baseline-empty",
            baseline: "tool/sample_baseline.json",
            countKey: "entries",
          },
        ],
      },
    },
    files: {
      "tool/sample_baseline.json": JSON.stringify({entries: ["known debt"]}),
    },
  });

  assert.deepEqual(checkEnforcementIntegrity({root}).errors, []);
});

test("fails missing doc anchors and missing vacuity proof text", () => {
  const root = createFixture({
    rules: {
      "RULE-001": {
        ...manualRule(),
        enforcement: [
          {
            tool: "audit:sample",
            stage: "scanner-gate",
            docAnchor: "docs/app_architecture.md#missing-heading",
          },
        ],
      },
    },
    tools: [
      gateTool({
        id: "audit:sample",
        path: "tool/architecture/check_sample.mjs",
        command: "node tool/architecture/check_sample.mjs",
        rules: ["RULE-001"],
        proofPath: "tool/architecture/check_sample.test.mjs",
        proofContains: ["known bad"],
      }),
    ],
    docs: {"docs/app_architecture.md": "# App Architecture\n\n### Error Scanners\n"},
    files: {
      "tool/architecture/check_sample.mjs": "#!/usr/bin/env node\n",
      "tool/architecture/check_sample.test.mjs": "test('clean input', () => {});\n",
    },
  });

  const errors = checkEnforcementIntegrity({root}).errors.join("\n");
  assert.match(errors, /docAnchor heading not found/u);
  assert.match(errors, /does not contain known bad/u);
});

test("accepts ratchet baselines without a separate metric receipt", () => {
  const root = createFixture({
    rules: {
      "MAX-COUNTS-001": {
        ...manualRule(),
        enforcement: [
          {
            tool: "audit:max-counts",
            stage: "scanner-ratchet",
            docAnchor: "docs/app_architecture.md#error-scanners",
            baseline: "tool/max_counts_baseline.json",
          },
        ],
      },
      "ALLOWED-FINDINGS-001": {
        ...manualRule(),
        enforcement: [
          {
            tool: "audit:allowed-findings",
            stage: "scanner-ratchet",
            docAnchor: "docs/app_architecture.md#error-scanners",
            baseline: "tool/allowed_findings_baseline.json",
          },
        ],
      },
    },
    tools: [
      gateTool({
        id: "audit:max-counts",
        path: "tool/architecture/check_max_counts.mjs",
        command: "node tool/architecture/check_max_counts.mjs",
        role: "ratchet",
        rules: ["MAX-COUNTS-001"],
        proofPath: "tool/architecture/check_max_counts.test.mjs",
        baseline: "tool/max_counts_baseline.json",
      }),
      gateTool({
        id: "audit:allowed-findings",
        path: "tool/architecture/check_allowed_findings.mjs",
        command: "node tool/architecture/check_allowed_findings.mjs",
        role: "ratchet",
        rules: ["ALLOWED-FINDINGS-001"],
        proofPath: "tool/architecture/check_allowed_findings.test.mjs",
        baseline: "tool/allowed_findings_baseline.json",
      }),
    ],
    docs: {"docs/app_architecture.md": "# App Architecture\n\n### Error Scanners\n"},
    files: {
      "tool/architecture/check_max_counts.mjs": "#!/usr/bin/env node\n",
      "tool/architecture/check_max_counts.test.mjs": "flags bad input\n",
      "tool/architecture/check_allowed_findings.mjs": "#!/usr/bin/env node\n",
      "tool/architecture/check_allowed_findings.test.mjs": "flags bad input\n",
      "tool/max_counts_baseline.json": JSON.stringify({maxCounts: {review: 1}}),
      "tool/allowed_findings_baseline.json": JSON.stringify({
        allowedFindings: [{rule: "sample", path: "lib/example.dart"}],
      }),
    },
  });

  assert.deepEqual(checkEnforcementIntegrity({root}).errors, []);
});

test("still fails when a referenced ratchet baseline is missing", () => {
  const root = createFixture({
    rules: {
      "RULE-001": {
        ...manualRule(),
        enforcement: [
          {
            tool: "audit:sample",
            stage: "scanner-ratchet",
            docAnchor: "docs/app_architecture.md#error-scanners",
            baseline: "tool/sample_baseline.json",
          },
        ],
      },
    },
    tools: [
      gateTool({
        id: "audit:sample",
        path: "tool/architecture/check_sample.mjs",
        command: "node tool/architecture/check_sample.mjs",
        role: "ratchet",
        rules: ["RULE-001"],
        proofPath: "tool/architecture/check_sample.test.mjs",
        baseline: "tool/sample_baseline.json",
      }),
    ],
    docs: {"docs/app_architecture.md": "# App Architecture\n\n### Error Scanners\n"},
    files: {
      "tool/architecture/check_sample.mjs": "#!/usr/bin/env node\n",
      "tool/architecture/check_sample.test.mjs": "flags bad input\n",
    },
  });

  assert.match(
    checkEnforcementIntegrity({root}).errors.join("\n"),
    /audit:sample: referenced file does not exist: tool\/sample_baseline\.json/u,
  );
});

test("fails broad flutter regression guards without plain-name or evidence", () => {
  const root = createFixture({
    rules: {"RULE-001": manualRule()},
    ledger: {
      entries: [
        {
          id: "REG-TEST-001",
          status: "active",
          guard: {
            type: "command",
            command: "flutter test test/example_test.dart",
          },
        },
      ],
    },
    files: {"test/example_test.dart": "void main() {}\n"},
  });

  assert.match(
    checkEnforcementIntegrity({root}).errors.join("\n"),
    /REG-TEST-001: active flutter test guard .* needs --plain-name or guardEvidence/u,
  );
});

test("passes flutter regression guards with plain-name filters", () => {
  const root = createFixture({
    rules: {"RULE-001": manualRule()},
    ledger: {
      entries: [
        {
          id: "REG-TEST-001",
          status: "active",
          guard: {
            type: "command",
            command: "flutter test test/example_test.dart --plain-name 'specific regression'",
          },
        },
      ],
    },
    files: {"test/example_test.dart": "void main() {}\n"},
  });

  assert.deepEqual(checkEnforcementIntegrity({root}).errors, []);
});

test("validates flutter regression guard evidence literals", () => {
  const root = createFixture({
    rules: {"RULE-001": manualRule()},
    ledger: {
      entries: [
        {
          id: "REG-TEST-001",
          status: "active",
          guard: {
            type: "command",
            command: "flutter test test/example_test.dart",
            guardEvidence: "specific regression",
          },
        },
        {
          id: "REG-TEST-002",
          status: "active",
          guard: {
            type: "command",
            command: "flutter test test/missing_evidence_test.dart",
            guardEvidence: "absent regression",
          },
        },
      ],
    },
    files: {
      "test/example_test.dart": "test('specific regression', () {});\n",
      "test/missing_evidence_test.dart": "void main() {}\n",
    },
  });

  const errors = checkEnforcementIntegrity({root}).errors.join("\n");
  assert.doesNotMatch(errors, /REG-TEST-001/u);
  assert.match(errors, /REG-TEST-002: guardEvidence not found/u);
});

test("produces the same result after fixture files become sparse omitted", (context) => {
  const root = createFixture({
    rules: {
      "TOOLED-001": {
        ...manualRule(),
        enforcement: [{
          tool: "audit:sample",
          stage: "scanner-gate",
          docAnchor: "docs/app_architecture.md#error-scanners",
        }],
      },
    },
    tools: [gateTool({
      id: "audit:sample",
      path: "tool/architecture/check_sample.mjs",
      command: "node tool/architecture/check_sample.mjs",
      rules: ["TOOLED-001"],
      proofPath: "tool/architecture/check_sample.test.mjs",
      proofContains: ["flags bad input"],
    })],
    docs: {"docs/app_architecture.md": "# App Architecture\n\n### Error Scanners\n"},
    files: {
      "tool/architecture/check_sample.mjs": "#!/usr/bin/env node\n",
      "tool/architecture/check_sample.test.mjs": "flags bad input\n",
    },
  });
  context.after(() => fs.rmSync(root, {recursive: true, force: true}));
  git(root, ["init", "-q"]);
  git(root, ["config", "user.email", "snapshot@example.com"]);
  git(root, ["config", "user.name", "Snapshot Test"]);
  git(root, ["add", "."]);
  git(root, ["commit", "-qm", "fixture"]);

  const full = checkWithRepositorySnapshot({root});
  git(root, ["sparse-checkout", "init", "--no-cone"]);
  git(root, ["sparse-checkout", "set", "--no-cone", "/tool/"]);
  const sparse = checkWithRepositorySnapshot({root});

  assert.deepEqual(sparse, full);
  assert.equal(fs.existsSync(path.join(root, "docs/audit_registry/rules.json")), false);
});

function createFixture({
  rules,
  tools = [],
  docs = {},
  files = {},
  ledger = {entries: []},
}) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-enforcement-"));
  writeJson(root, "docs/audit_registry/rules.json", {rules});
  writeJson(root, "tool/tools_manifest.json", {version: 1, tools});
  writeJson(root, "docs/agent_regression_ledger.json", ledger);
  for (const [filePath, contents] of Object.entries({
    "docs/app_architecture.md": "# App Architecture\n",
    ...docs,
    ...files,
  })) {
    writeFile(root, filePath, contents);
  }
  return root;
}

function manualRule() {
  return {
    title: "Rule",
    status: "active",
    kind: "contract",
    applies_to: ["tool/**"],
    instruction: "Do the thing.",
    sunset_signals: [{type: "manual"}],
    enforcement: [
      {
        stage: "manual",
        docAnchor: "docs/audit_registry/rules.json",
      },
    ],
  };
}

function gateTool({
  id,
  path: filePath,
  command,
  role = "gate",
  rules,
  proofPath,
  proofContains = ["flags bad input"],
  baseline,
}) {
  return {
    id,
    category: "audit",
    path: filePath,
    command,
    status: "active",
    role,
    rules,
    checks: [`node --check ${filePath}`, command],
    baseline,
    vacuityProof: {
      type: "test",
      path: proofPath,
      contains: proofContains,
    },
  };
}

function writeJson(root, relativePath, value) {
  writeFile(root, relativePath, `${JSON.stringify(value, null, 2)}\n`);
}

function writeFile(root, relativePath, contents) {
  const file = path.join(root, relativePath);
  fs.mkdirSync(path.dirname(file), {recursive: true});
  fs.writeFileSync(file, contents);
}

function fixtureSnapshot(root) {
  return {
    exists(relativePath) {
      return fs.existsSync(path.join(root, relativePath));
    },
    listFiles({prefix = ""} = {}) {
      return walkFiles(root).filter((relativePath) => relativePath.startsWith(prefix));
    },
    readJson(relativePath, {required = false} = {}) {
      const source = this.readText(relativePath, {required});
      return source == null ? null : JSON.parse(source);
    },
    readText(relativePath, {required = false} = {}) {
      const absolutePath = path.join(root, relativePath);
      if (!fs.existsSync(absolutePath)) {
        if (required) throw new Error(`Required fixture path is missing: ${relativePath}`);
        return null;
      }
      return fs.readFileSync(absolutePath, "utf8");
    },
  };
}

function walkFiles(root, directory = root) {
  const files = [];
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    const absolutePath = path.join(directory, entry.name);
    if (entry.isDirectory()) files.push(...walkFiles(root, absolutePath));
    else if (entry.isFile()) files.push(path.relative(root, absolutePath).split(path.sep).join("/"));
  }
  return files.sort();
}

function git(root, args) {
  execFileSync("git", args, {cwd: root, stdio: "pipe"});
}
