import test from "node:test";
import assert from "node:assert/strict";
import {buildDocState} from "./build_doc_state.mjs";

test("derived document state keeps semantic metadata separate from Git state", () => {
  const state = buildDocState({
    catalog: {
      release_operations: {
        path: "docs/release_operations.md",
        version: "1.11.5",
        status: "active",
      },
    },
    sourceRevision: "abc123",
    resolveDocument: () => ({
      source: "---\nstatus: active\n---\n\n# Release operations\n",
      contentRevision: "blob456",
      lastIntegratedRevision: "commit789",
      lastIntegratedAt: "2026-07-25T12:00:00+05:30",
    }),
  });

  assert.deepEqual(state, {
    schemaVersion: "1.1.0",
    sourceRevision: "abc123",
    documents: {
      release_operations: {
        path: "docs/release_operations.md",
        status: "active",
        semanticVersion: "1.11.5",
        contentRevision: "blob456",
        lastIntegratedRevision: "commit789",
        lastIntegratedAt: "2026-07-25T12:00:00+05:30",
      },
    },
  });
});

test("derived document state uses source lifecycle for Markdown and catalog lifecycle otherwise", () => {
  const state = buildDocState({
    catalog: {
      retired: {
        path: "docs/retired.md",
        version: "1.0.0",
        status: "implemented",
      },
      contract: {
        path: "contracts/example.json",
        version: "2.0.0",
        status: "active",
      },
    },
    sourceRevision: "abc123",
    resolveDocument: (documentPath) => ({
      source: documentPath.endsWith(".md")
        ? "---\nstatus: retirement_ready\n---\n"
        : "{}\n",
      contentRevision: `blob-${documentPath}`,
      lastIntegratedRevision: "commit789",
      lastIntegratedAt: "2026-08-06T12:00:00+05:30",
    }),
  });

  assert.equal(state.documents.retired.status, "retirement_ready");
  assert.equal(state.documents.contract.status, "active");
});

test("derived document state rejects duplicate catalog paths", () => {
  assert.throws(
    () => buildDocState({
      catalog: {
        one: {path: "docs/shared.md", version: "1", status: "active"},
        two: {path: "docs/shared.md", version: "2", status: "active"},
      },
      sourceRevision: "abc123",
      resolveDocument: () => {
        throw new Error("should not resolve duplicate");
      },
    }),
    /cataloged more than once/,
  );
});
