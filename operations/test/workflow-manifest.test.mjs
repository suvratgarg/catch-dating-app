import assert from "node:assert/strict";
import fs from "node:fs/promises";
import test from "node:test";
import {checkWorkflowManifest} from
  "../scripts/check-workflow-manifest.mjs";
import {WORKFLOW_REGISTRY} from "../src/workflows/registry.mjs";

async function canonicalManifest() {
  return JSON.parse(await fs.readFile(new URL(
    "../src/workflows/supply-intake/manifest.json",
    import.meta.url
  ), "utf8"));
}

test("workflow manifest binds the CLI, stages, lifecycle, profiles, and cap",
  async () => {
    const result = await checkWorkflowManifest();
    assert.equal(result.ok, true, JSON.stringify(result.findings));
  });

test("workflow manifest fails when a live CLI command is omitted", async () => {
  const manifest = await canonicalManifest();
  manifest.commands = manifest.commands.filter((command) =>
    command !== "export-admin");
  const result = await checkWorkflowManifest({manifest});
  assert.equal(result.ok, false);
  assert.ok(result.findings.some((finding) =>
    finding.contract?.endsWith(":cli-commands")));
});

test("workflow manifest binds every legacy compatibility artifact", async () => {
  const manifest = await canonicalManifest();
  manifest.compatibilityInputs[1].artifacts =
    manifest.compatibilityInputs[1].artifacts.slice(1);
  const result = await checkWorkflowManifest({manifest});
  assert.equal(result.ok, false);
  assert.ok(result.findings.some((finding) =>
    finding.contract?.endsWith(":compatibility-artifacts")));
});

test("workflow manifest fails on stage or lifecycle ordering drift", async () => {
  const manifest = await canonicalManifest();
  manifest.primaryStages = [...manifest.primaryStages].reverse();
  manifest.lifecycleStatuses = [...manifest.lifecycleStatuses].reverse();
  const result = await checkWorkflowManifest({manifest});
  assert.equal(result.ok, false);
  assert.ok(result.findings.some((finding) =>
    finding.contract?.endsWith(":primary-stages")));
  assert.ok(result.findings.some((finding) =>
    finding.contract?.endsWith(":lifecycle-statuses")));
});

test("workflow lifecycle semantics are bound and category-safe", async () => {
  const drifted = await canonicalManifest();
  drifted.lifecycleSemantics = {
    ...drifted.lifecycleSemantics,
    activeStatuses: ["published"],
  };
  const driftResult = await checkWorkflowManifest({manifest: drifted});
  assert.equal(driftResult.ok, false);
  assert.ok(driftResult.findings.some((finding) =>
    finding.contract?.endsWith(":lifecycle-semantics")));
  assert.ok(driftResult.findings.some((finding) =>
    finding.id === "workflow-lifecycle-semantics-invalid"));

  const custom = await canonicalManifest();
  custom.lifecycleStatuses = ["open", "released", "discarded"];
  custom.lifecycleSemantics = {
    activeStatuses: ["open"],
    publishedStatuses: ["released"],
    expiredStatuses: ["discarded"],
  };
  const descriptor = {
    ...WORKFLOW_REGISTRY[0],
    lifecycleStatuses: custom.lifecycleStatuses,
    lifecycleSemantics: custom.lifecycleSemantics,
    createWorkflow: (options) => {
      const workflow = WORKFLOW_REGISTRY[0].createWorkflow(options);
      workflow.lifecycleStatuses = custom.lifecycleStatuses;
      workflow.lifecycleSemantics = custom.lifecycleSemantics;
      return workflow;
    },
  };
  const customResult = await checkWorkflowManifest({
    manifest: custom,
    registry: [descriptor],
  });
  assert.equal(customResult.ok, true, JSON.stringify(customResult.findings));
});

test("workflow manifest binds entity kinds and the transition graph",
  async () => {
    const manifest = await canonicalManifest();
    manifest.entityKinds = manifest.entityKinds.filter((kind) =>
      kind !== "organizer");
    manifest.allowedTransitions = {
      ...manifest.allowedTransitions,
      ready: [],
    };
    const result = await checkWorkflowManifest({manifest});
    assert.equal(result.ok, false);
    assert.ok(result.findings.some((finding) =>
      finding.contract?.endsWith(":entity-kinds")));
    assert.ok(result.findings.some((finding) =>
      finding.contract?.endsWith(":allowed-transitions")));
  });

test("workflow manifest fails when the loaded source inventory drifts",
  async () => {
    const result = await checkWorkflowManifest({
      sourceProfiles: ["luma", "cntraveller", "unregistered-source"],
    });
    assert.equal(result.ok, false);
    assert.ok(result.findings.some((finding) =>
      finding.contract?.endsWith(":loaded-source-profiles")));
  });

test("workflow discovery fails when an on-disk workflow is unregistered",
  async () => {
    const result = await checkWorkflowManifest({
      workflowDirectories: ["future-workflow", "supply-intake"],
    });
    assert.equal(result.ok, false);
    assert.ok(result.findings.some((finding) =>
      finding.contract === "workflow-registry-directories"));
  });

test("workflow discovery fails when a registered workflow omits its manifest",
  async () => {
    const current = WORKFLOW_REGISTRY[0];
    const result = await checkWorkflowManifest({
      workflowDirectories: ["future-workflow", "supply-intake"],
      registry: [
        current,
        {
          ...current,
          directory: "future-workflow",
          workflowId: "future-workflow",
        },
      ],
    });
    assert.equal(result.ok, false);
    assert.ok(result.findings.some((finding) =>
      finding.id === "workflow-manifest-missing" &&
        finding.workflow === "future-workflow"));
  });

test("workflow manifests may declare a supported CLI command subset",
  async () => {
    const manifest = await canonicalManifest();
    manifest.commands = ["plan"];
    const descriptor = {...WORKFLOW_REGISTRY[0], commands: ["plan"]};
    const result = await checkWorkflowManifest({
      manifest,
      registry: [descriptor],
    });
    assert.equal(result.ok, true, JSON.stringify(result.findings));
    assert.equal(result.checked.workflows[0].commands, 1);
  });

test("workflows without source inventories may omit a source loader",
  async () => {
    const manifest = await canonicalManifest();
    manifest.sourceProfiles = [];
    const descriptor = {
      ...WORKFLOW_REGISTRY[0],
      sourceProfileIds: [],
      loadSourceProfiles: undefined,
    };
    const result = await checkWorkflowManifest({
      manifest,
      registry: [descriptor],
    });
    assert.equal(result.ok, true, JSON.stringify(result.findings));
  });

test("workflows with source inventories require a source loader", async () => {
  const descriptor = {
    ...WORKFLOW_REGISTRY[0],
    loadSourceProfiles: undefined,
  };
  const result = await checkWorkflowManifest({registry: [descriptor]});
  assert.equal(result.ok, false);
  assert.ok(result.findings.some((finding) =>
    finding.id === "workflow-source-profile-loader-missing"));
});

test("transition graphs must cover every stage and remain stage-closed",
  async () => {
    const missingKeyManifest = await canonicalManifest();
    delete missingKeyManifest.allowedTransitions.ready;
    const missingKeyDescriptor = {
      ...WORKFLOW_REGISTRY[0],
      allowedTransitions: missingKeyManifest.allowedTransitions,
    };
    const missingKey = await checkWorkflowManifest({
      manifest: missingKeyManifest,
      registry: [missingKeyDescriptor],
    });
    assert.equal(missingKey.ok, false);
    assert.ok(missingKey.findings.some((finding) =>
      finding.id === "workflow-transition-graph-invalid"));

    const unknownTargetManifest = await canonicalManifest();
    unknownTargetManifest.allowedTransitions = {
      ...unknownTargetManifest.allowedTransitions,
      ready: ["archive"],
    };
    const unknownTargetDescriptor = {
      ...WORKFLOW_REGISTRY[0],
      allowedTransitions: unknownTargetManifest.allowedTransitions,
    };
    const unknownTarget = await checkWorkflowManifest({
      manifest: unknownTargetManifest,
      registry: [unknownTargetDescriptor],
    });
    assert.equal(unknownTarget.ok, false);
    assert.ok(unknownTarget.findings.some((finding) =>
      finding.id === "workflow-transition-graph-invalid"));
  });

test("workflow manifests cannot exceed platform mode or capability authority",
  async () => {
    const manifest = await canonicalManifest();
    manifest.executionModes = ["autonomous"];
    manifest.capabilities = {
      ...manifest.capabilities,
      publicWrites: true,
    };
    const descriptor = {
      ...WORKFLOW_REGISTRY[0],
      executionModes: ["autonomous"],
      capabilities: manifest.capabilities,
    };
    const result = await checkWorkflowManifest({
      manifest,
      registry: [descriptor],
    });
    assert.equal(result.ok, false);
    assert.ok(result.findings.some((finding) =>
      finding.contract?.endsWith(":platform-execution-modes")));
    assert.ok(result.findings.some((finding) =>
      finding.contract?.endsWith(":platform-capability-ceiling")));
  });

test("learn command declarations require a learner factory", async () => {
  const descriptor = {
    ...WORKFLOW_REGISTRY[0],
    createLearner: undefined,
  };
  const result = await checkWorkflowManifest({registry: [descriptor]});
  assert.equal(result.ok, false);
  assert.ok(result.findings.some((finding) =>
    finding.contract?.endsWith(":learner-factory")));
});

test("declared workflow commands require executable factory methods",
  async () => {
    const createWorkflow = WORKFLOW_REGISTRY[0].createWorkflow;
    const descriptor = {
      ...WORKFLOW_REGISTRY[0],
      createWorkflow: (options) => {
        const workflow = createWorkflow(options);
        workflow.promotionCandidates = undefined;
        return workflow;
      },
    };
    const result = await checkWorkflowManifest({registry: [descriptor]});
    assert.equal(result.ok, false);
    assert.ok(result.findings.some((finding) =>
      finding.contract?.endsWith(
        ":factory-method-promotionCandidates"
      )));
  });
