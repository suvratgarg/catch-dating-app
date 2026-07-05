import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  scanRailContracts,
  scanSourceForRailContracts,
} from "./check_rail_contracts.mjs";

test("flags old rail chrome zeroing in production code", () => {
  const result = scanSourceForRailContracts({
    relativePath: "lib/dashboard/presentation/widgets/dashboard_full.dart",
    source: `
      Widget build(context) => ClubAvatarRail(
        clubs: clubs,
        showDivider: false,
        headerPadding: EdgeInsets.zero,
        listPadding: EdgeInsets.zero,
      );
    `,
  });

  assert.equal(result.findings.length, 1);
  assert.equal(result.findings[0].level, "high");
});

test("allows embedded rail defaults", () => {
  const result = scanSourceForRailContracts({
    relativePath: "lib/dashboard/presentation/widgets/dashboard_full.dart",
    source: "Widget build(context) => ClubAvatarRail(clubs: clubs);",
  });

  assert.equal(result.findings.length, 0);
});

test("allows full-bleed rail opt-in", () => {
  const result = scanSourceForRailContracts({
    relativePath: "lib/explore/presentation/widgets/explore_body.dart",
    source:
      "Widget build(context) => ClubAvatarRail(clubs: clubs, fullBleed: true);",
  });

  assert.equal(result.findings.length, 0);
  assert.equal(result.inventory.fullBleedOptIns, 1);
});

test("reports redundant showDivider false without failing high", () => {
  const result = scanSourceForRailContracts({
    relativePath: "lib/dashboard/presentation/widgets/recommendations.dart",
    source: `
      Widget build(context) => CatchHorizontalRail(
        title: 'Recommended',
        itemCount: 2,
        itemBuilder: itemBuilder,
        showDivider: false,
      );
    `,
  });

  assert.equal(result.findings.length, 1);
  assert.equal(result.findings[0].level, "medium");
});

test("ignores canonical rail implementations", () => {
  const result = scanSourceForRailContracts({
    relativePath: "lib/clubs/presentation/discovery/widgets/club_avatar_rail.dart",
    source: `
      Widget build(context) => CatchHorizontalRail(
        title: 'Your clubs',
        fullBleed: fullBleed,
        showDivider: showDivider,
        headerPadding: headerPadding,
        listPadding: listPadding,
        itemCount: clubs.length,
        itemBuilder: itemBuilder,
      );
    `,
  });

  assert.equal(result.findings.length, 0);
});

test("scanRailContracts covers only production lib sources", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-rail-contracts-"));
  writeFile(
    root,
    "lib/dashboard/presentation/widgets/dashboard_full.dart",
    `
      Widget build(context) => ClubAvatarRail(
        clubs: clubs,
        showDivider: false,
        headerPadding: EdgeInsets.zero,
      );
    `,
  );
  writeFile(
    root,
    "widgetbook/lib/clubs/club_detail_use_cases.dart",
    `
      Widget build(context) => ClubAvatarRail(
        clubs: clubs,
        showDivider: false,
        headerPadding: EdgeInsets.zero,
      );
    `,
  );

  const result = scanRailContracts({root});

  assert.equal(result.counts.high, 1);
  assert.equal(result.findings[0].path, "lib/dashboard/presentation/widgets/dashboard_full.dart");
});

function writeFile(root, relativePath, source) {
  const file = path.join(root, relativePath);
  fs.mkdirSync(path.dirname(file), {recursive: true});
  fs.writeFileSync(file, source);
}
