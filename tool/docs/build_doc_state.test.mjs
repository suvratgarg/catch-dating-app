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
      contentRevision: "blob456",
      lastIntegratedRevision: "commit789",
      lastIntegratedAt: "2026-07-25T12:00:00+05:30",
    }),
  });

  assert.deepEqual(state, {
    schemaVersion: "1.0.0",
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
