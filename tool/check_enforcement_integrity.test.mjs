import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {checkEnforcementIntegrity} from "./check_enforcement_integrity.mjs";

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

test("fails baseline maxCounts without matching metric receipt", () => {
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
      "tool/sample_baseline.json": JSON.stringify({maxCounts: {review: 1}}),
    },
  });

  assert.match(
    checkEnforcementIntegrity({root}).errors.join("\n"),
    /baseline tool\/sample_baseline\.json has no metric receipt/u,
  );
});

test("fails allowedFindings baselines without matching metric receipt", () => {
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
      "tool/sample_baseline.json": JSON.stringify({
        allowedFindings: [
          {
            rule: "sample",
            path: "lib/example.dart",
            import: "package:example/example.dart",
          },
        ],
      }),
    },
  });

  assert.match(
    checkEnforcementIntegrity({root}).errors.join("\n"),
    /baseline tool\/sample_baseline\.json has no metric receipt/u,
  );
});

test("fails allowedFindings baselines with stale metric receipt", () => {
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
      "tool/sample_baseline.json": JSON.stringify({
        allowedFindings: [
          {
            rule: "sample",
            path: "lib/example.dart",
            import: "package:example/example.dart",
          },
        ],
      }),
    },
    metrics: [
      {
        event: "enforcement_baseline",
        baseline: "tool/sample_baseline.json",
        counts: {allowedFindings: 2},
      },
    ],
  });

  assert.match(
    checkEnforcementIntegrity({root}).errors.join("\n"),
    /allowedFindings count/u,
  );
});

test("passes allowedFindings baselines with matching metric receipt", () => {
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
      "tool/sample_baseline.json": JSON.stringify({
        allowedFindings: [
          {
            rule: "sample",
            path: "lib/example.dart",
            import: "package:example/example.dart",
          },
        ],
      }),
    },
    metrics: [
      {
        event: "enforcement_baseline",
        baseline: "tool/sample_baseline.json",
        counts: {allowedFindings: 1},
      },
    ],
  });

  assert.deepEqual(checkEnforcementIntegrity({root}).errors, []);
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

function createFixture({
  rules,
  tools = [],
  docs = {},
  files = {},
  metrics = [],
  ledger = {entries: []},
}) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-enforcement-"));
  writeJson(root, "docs/audit_registry/rules.json", {rules});
  writeJson(root, "tool/tools_manifest.json", {version: 1, tools});
  writeJson(root, "docs/agent_regression_ledger.json", ledger);
  writeFile(
    root,
    "docs/audit_registry/agent_metrics.jsonl",
    metrics.map((metric) => JSON.stringify(metric)).join("\n"),
  );
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
