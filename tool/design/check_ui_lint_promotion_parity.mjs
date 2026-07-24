#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

import {fromRepo} from "../lib/repo_paths.mjs";

const retiredTitles = [
  "Brittle widget-test timing and missed-tap patterns",
  "Async unit-test flush candidates",
  "Brittle positional widget finders",
  "Presentation widgets reaching directly into repository providers",
  "Feature widgets prop-drilling CatchTokens",
  "Profile field editors that still use bottom sheets",
  "Profile inline chip editors that repeat the expanded tile label",
  "Profile inline chip editors with separate Clear actions",
  "Profile text tile editors that stack a separate text field below the row",
  "Profile chip tile editors that stack selected chips below the row",
  "Feature-local decorated surface candidates that should consider CatchSurface",
  "App-facing Text candidates without nearby CatchTextStyles",
  "App-facing low-level typography role candidates",
  "Nonzero letter-spacing candidates",
  "Legacy 4-point spacing migration candidates",
  "Fine-grained spacing compatibility helpers",
  "Plugin/platform side effects inside presentation code",
  "Raw app-facing error surface migration candidates",
];

const parityFixtures = {
  catch_no_raw_network_image: "Image.network('https://example.com/probe.png')",
  catch_no_presentation_platform_import: "package:url_launcher/url_launcher.dart",
  catch_no_tokens_prop_drilling: "final CatchTokens tokens",
  catch_no_presentation_repository_reach: "eventRepositoryProvider",
  catch_no_legacy_spacing_token: "Sizes.p12",
  catch_no_low_level_typography_role: "CatchTextStyles.bodyM(context)",
  catch_screen_gutter_uses_semantic_insets: "_probeScreenPadding = EdgeInsets.fromLTRB",
  catch_text_requires_style: "Text('raw'",
  catch_no_brittle_pump_timing: "tester.pumpAndSettle()",
  catch_no_positional_widget_finder: "find.text('Save').first",
  catch_no_async_flush_hack: "Future<void>.delayed(Duration.zero)",
  catch_no_raw_error_surface: "Center(child: Text('Failed to load'))",
};

const isCli = process.argv[1] &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isCli) runCli();

export function checkPromotionParity({scannerSource, harnessSource}) {
  const failures = [];
  for (const title of retiredTitles) {
    if (scannerSource.includes(title)) failures.push(`retired scanner remains active: ${title}`);
  }
  for (const [code, fixture] of Object.entries(parityFixtures)) {
    if (!harnessSource.includes(fixture)) failures.push(`${code}: missing parity fixture ${fixture}`);
    if (!harnessSource.includes(`"${code}"`)) failures.push(`${code}: missing diagnostic expectation`);
  }
  return failures;
}

function runCli() {
  const scannerSource = fs.readFileSync(fromRepo("tool/widget_cleanup_scan.sh"), "utf8");
  const harnessSource = fs.readFileSync(fromRepo("tool/check_catch_ui_lints.sh"), "utf8");
  const failures = checkPromotionParity({scannerSource, harnessSource});
  if (failures.length) {
    console.error("Catch UI lint promotion parity failed:");
    for (const failure of failures) console.error(`- ${failure}`);
    process.exit(1);
  }
  console.log(
    `Catch UI lint promotion parity passed (${Object.keys(parityFixtures).length} seeded fixtures; ${retiredTitles.length} retired categories absent).`,
  );
}
