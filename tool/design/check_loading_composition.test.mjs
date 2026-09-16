import assert from 'node:assert/strict';
import test from 'node:test';
import {
  checkLoadingComposition,
  scanLoadingCompositionSource,
} from './check_loading_composition.mjs';

test('rejects hand-built loading rows on protected Host and Consumer screens', () => {
  for (const relativePath of [
    'lib/hosts/today/presentation/widgets/host_today_body.dart',
    'lib/hosts/events/presentation/widgets/host_events_list.dart',
    'lib/hosts/presentation/customers/host_customers_screen.dart',
    'lib/hosts/presentation/forms/host_form_responses_panel.dart',
    'lib/events/presentation/events_screen.dart',
    'lib/swipes/presentation/discover_screen.dart',
  ]) {
    const {findings} = scanLoadingCompositionSource({
      relativePath,
      source: 'return const CatchSkeleton.rows(count: 4);',
    });
    assert.deepEqual(findings.map((item) => item.code), ['LOADING-COMPOSITION-001']);
  }
});

test('allows known Field layouts and tracks unmigrated Host debt', () => {
  const valid = scanLoadingCompositionSource({
    relativePath: 'lib/hosts/events/presentation/widgets/host_events_list.dart',
    source: 'return CatchSection.sliverLoadingRows(itemCount: 4, layoutBuilder: (_, _) => CatchRecordLayout.placeholder(icon: CatchIcons.eventOutlined));',
  });
  assert.equal(valid.findings.length, 0);
  const legacy = scanLoadingCompositionSource({
    relativePath: 'lib/hosts/presentation/applications/host_applications_screen.dart',
    source: 'return const CatchSkeleton.rows(count: 4);',
  });
  assert.equal(legacy.findings.length, 0);
  assert.equal(legacy.legacyCount, 1);
});

test('rejects root typography overrides while ignoring comments and strings', () => {
  const relativePath = 'lib/hosts/today/presentation/widgets/host_today_body.dart';
  const broken = scanLoadingCompositionSource({
    relativePath,
    source: 'return CatchScreenHeader.block(title: "Today", titleStyle: CatchTextStyles.eventTitle(context));',
  });
  assert.deepEqual(broken.findings.map((item) => item.code), ['ROOT-TITLE-001']);
  const clean = scanLoadingCompositionSource({
    relativePath,
    source: '// CatchSkeleton.rows()\nfinal note = "CatchScreenHeader.block(titleStyle: bad)";\nreturn CatchScreenHeader.block(title: "Today");',
  });
  assert.equal(clean.findings.length, 0);
});

test('repository protected surfaces satisfy the loading contract', () => {
  const result = checkLoadingComposition();
  assert.deepEqual(result.findings, []);
  assert.ok(result.filesScanned > 0);
});
