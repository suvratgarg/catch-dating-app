import assert from "node:assert/strict";
import test from "node:test";
import {createRepositorySnapshot} from "../lib/repository_snapshot.mjs";
import {
  hasWidgetbookReviewSource,
  loadVariantReviewCandidates,
} from "./widgetbook_compare_server.mjs";

const retiredDerivedPaths = [
  "docs/design_parity/widgetbook_compare.html",
  "docs/design_parity/widgetbook_coverage_audit_plan.json",
  "docs/design_parity/widgetbook_coverage_report.json",
  "docs/audit_registry/widget_variant_inventory.json",
  "docs/audit_registry/widget_similarity.json",
  "tool/design/build_widgetbook_compare.mjs",
];

test("classification-only widgets remain comparison candidates", () => {
  const widgetbookByName = new Map([["PreviewedWidget", [{}]]]);
  const classificationByName = new Map([
    ["SourceOnlyWidget", {file: "lib/source_only_widget.dart"}],
  ]);

  assert.equal(
    hasWidgetbookReviewSource(
      "PreviewedWidget",
      widgetbookByName,
      classificationByName,
    ),
    true,
  );
  assert.equal(
    hasWidgetbookReviewSource(
      "SourceOnlyWidget",
      widgetbookByName,
      classificationByName,
    ),
    true,
  );
  assert.equal(
    hasWidgetbookReviewSource(
      "UnknownWidget",
      widgetbookByName,
      classificationByName,
    ),
    false,
  );
});

test("comparison derives variant candidates from the logical snapshot", () => {
  const candidates = loadVariantReviewCandidates();
  assert.ok(candidates.length > 0);
  assert.ok(candidates.every((candidate) => candidate.review?.needsReview));
});

test("Widgetbook comparison keeps derived snapshots out of trunk", () => {
  const snapshot = createRepositorySnapshot();
  for (const relativePath of retiredDerivedPaths) {
    assert.equal(snapshot.exists(relativePath), false, relativePath);
  }
  const serverSource = snapshot.readText(
    "tool/design/widgetbook_compare_server.mjs",
    {required: true},
  );
  assert.doesNotMatch(serverSource, /widgetbook_coverage_report/u);
  assert.doesNotMatch(
    serverSource,
    /docs\/audit_registry\/widget_variant_inventory\.json/u,
  );
  assert.doesNotMatch(
    serverSource,
    /docs\/audit_registry\/widget_similarity\.json/u,
  );
});
