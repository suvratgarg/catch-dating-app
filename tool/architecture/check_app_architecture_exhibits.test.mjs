import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {checkAppArchitectureExhibits} from "./check_app_architecture_exhibits.mjs";

test("passes when exhibits have freshness markers and tracker links", () => {
  const root = createFixture({
    doc: [
      "# App Architecture",
      "",
      "### Exhibit ARCH-SCREEN-001: Feature Screen Boundary",
      "<!-- exhibit-freshness: ARCH-SCREEN-001 source=docs/audit_registry/architecture_pattern_adoption.json owner=recursive_audit_loop -->",
      "",
      "```dart",
      "final sectionVisibility = eventDetailSectionVisibilityStateFrom();",
      "final companionState = eventDetailCompanionStateFrom();",
      "final hostState = eventDetailHostStateFrom();",
      "final socialState = eventDetailSocialStateFrom();",
      "EventDetailBody(sectionVisibility: sectionVisibility);",
      "```",
      "",
      "### Exhibit ARCH-UI-STATE-001: Provider-Free Presentation State Model",
      "<!-- exhibit-freshness: ARCH-UI-STATE-001 source=docs/audit_registry/architecture_pattern_adoption.json owner=recursive_audit_loop -->",
      "",
      "```dart",
      "class CalendarHomeState {}",
      "class CalendarEventSummary {}",
      "```",
      "",
    ].join("\n"),
  });

  assert.deepEqual(checkAppArchitectureExhibits({root}).errors, []);
});

test("flags stale event-detail snippets in screen exhibit", () => {
  const root = createFixture({
    doc: [
      "# App Architecture",
      "",
      "### Exhibit ARCH-SCREEN-001: Feature Screen Boundary",
      "<!-- exhibit-freshness: ARCH-SCREEN-001 source=docs/audit_registry/architecture_pattern_adoption.json owner=recursive_audit_loop -->",
      "",
      "```dart",
      "final companionState = _eventDetailCompanionState();",
      "EventDetailBody(isHost: vm.isHost);",
      "```",
      "",
    ].join("\n"),
  });

  const errors = checkAppArchitectureExhibits({root}).errors.join("\n");

  assert.match(errors, /stale exhibit token remains: isHost: vm\.isHost/u);
  assert.match(errors, /stale exhibit token remains: _eventDetailCompanionState/u);
});

test("flags missing freshness markers", () => {
  const root = createFixture({
    doc: [
      "# App Architecture",
      "",
      "### Exhibit ARCH-SCREEN-001: Feature Screen Boundary",
      "",
      "```dart",
      "final sectionVisibility = eventDetailSectionVisibilityStateFrom();",
      "final companionState = eventDetailCompanionStateFrom();",
      "final hostState = eventDetailHostStateFrom();",
      "final socialState = eventDetailSocialStateFrom();",
      "EventDetailBody(sectionVisibility: sectionVisibility);",
      "```",
      "",
    ].join("\n"),
  });

  assert.match(
    checkAppArchitectureExhibits({root}).errors.join("\n"),
    /ARCH-SCREEN-001: exhibit is missing an exhibit-freshness marker/u,
  );
});

test("flags tracker anchor drift", () => {
  const root = createFixture({
    doc: [
      "# App Architecture",
      "",
      "### Exhibit ARCH-SCREEN-001: Feature Screen Boundary",
      "<!-- exhibit-freshness: ARCH-SCREEN-001 source=docs/audit_registry/architecture_pattern_adoption.json owner=recursive_audit_loop -->",
      "",
      "```dart",
      "final sectionVisibility = eventDetailSectionVisibilityStateFrom();",
      "final companionState = eventDetailCompanionStateFrom();",
      "final hostState = eventDetailHostStateFrom();",
      "final socialState = eventDetailSocialStateFrom();",
      "EventDetailBody(sectionVisibility: sectionVisibility);",
      "```",
      "",
    ].join("\n"),
    overridePatterns: [
      {
        id: "ARCH-SCREEN-001",
        architectureExhibit: "docs/app_architecture.md#old-anchor",
      },
    ],
  });

  assert.match(
    checkAppArchitectureExhibits({root}).errors.join("\n"),
    /tracker architectureExhibit is docs\/app_architecture\.md#old-anchor/u,
  );
});

function createFixture({doc, overridePatterns}) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-exhibits-"));
  writeFile(root, "docs/app_architecture.md", doc);
  writeFile(
    root,
    "docs/audit_registry/architecture_pattern_adoption.json",
    JSON.stringify({patterns: overridePatterns ?? defaultPatterns()}, null, 2),
  );
  return root;
}

function defaultPatterns() {
  return [
    {
      id: "ARCH-SCREEN-001",
      architectureExhibit:
        "docs/app_architecture.md#exhibit-arch-screen-001-feature-screen-boundary",
    },
    {
      id: "ARCH-UI-STATE-001",
      architectureExhibit:
        "docs/app_architecture.md#exhibit-arch-ui-state-001-provider-free-presentation-state-model",
    },
  ];
}

function writeFile(root, relativePath, contents) {
  const file = path.join(root, relativePath);
  fs.mkdirSync(path.dirname(file), {recursive: true});
  fs.writeFileSync(file, `${contents}\n`);
}
