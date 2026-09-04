import assert from 'node:assert/strict';
import fs from 'node:fs';
import test from 'node:test';
import { auditPlatformTokens, collectTokens, requiredDomains, resolveToken } from '../check_platform_token_coverage.mjs';

const root = new URL('../../../', import.meta.url);
const original = JSON.parse(fs.readFileSync(new URL('design/tokens/catch.tokens.json', root), 'utf8'));
const styles = fs.readFileSync(new URL('lib/core/theme/catch_text_styles.dart', root), 'utf8');
const copy = () => structuredClone(original);
const fails = (document, pattern, options) => assert(auditPlatformTokens(document, options).some(error => pattern.test(error)), `Expected ${pattern}`);

test('canonical foundation and actual typography consumers have complete coverage', () => {
  assert.deepEqual(auditPlatformTokens(original, { textStyles: styles }), []);
});

test('empty policy, empty source and deleting the same role on both platforms fail closed', () => {
  fails({}, /Missing versioned/);
  const t = copy();
  delete t.typography.ios.body;
  delete t.typography.android.body;
  fails(t, /semantic typography role set/);
  fails(original, /source must not be empty/, { textStyles: '' });
  fails(original, /inventory must not be empty/, { inventory: { rows: [] } });
});

test('native baseline fields cannot disappear while semantic values continue compiling', () => {
  const t = copy();
  delete t.platformReference.ios.typography.caption1.size;
  fails(t, /Missing required foundation token/);
  const u = copy();
  delete u.platformReference.android.typography.displayLarge.tracking;
  fails(u, /Missing required foundation token/);
});

test('every researched domain has a nonempty explicit owner and applicability decision', () => {
  for (const domain of requiredDomains) {
    const t = copy();
    delete t.$extensions['org.catch'].platformFoundation.domains[domain];
    fails(t, /applicability decision/);
  }
  const t = copy();
  t.$extensions['org.catch'].platformFoundation.domains.Typography.targets = [];
  fails(t, /No semantic\/reference owner/);
});

test('unknown runtime policy, missing provenance and fabricated targets fail', () => {
  const t = copy();
  delete t.$extensions['org.catch'].platformFoundation.runtimeOwners.safeArea;
  fails(t, /Missing runtime policy/);
  const u = copy();
  delete u.platformReference.ios.typography.body.size.$extensions;
  fails(u, /Incomplete native provenance/);
  const v = copy();
  v.typography.ios.body.$extensions['org.catch'].reference = 'fiction.typography';
  fails(v, /Missing reference\/decision/);
});

test('aliases are real dependencies and both dangling and cyclic aliases fail', () => {
  const t = copy();
  t.layout.pageGutter.$value = '{layout.notDefined}';
  fails(t, /Missing token: layout.notDefined/);
  const u = copy();
  u.layout.pageGutter.$value = '{layout.pageBodyStart}';
  u.layout.pageBodyStart.$value = '{layout.pageGutter}';
  fails(u, /Cyclic token alias/);
});

test('target and contrast floors cannot be weakened behind valid token names', () => {
  const t = copy();
  t.interaction.android.minimumExtent.$value = { value: 40, unit: 'px' };
  fails(t, /Interactive floors/);
  const u = copy();
  u.accessibility.minimumTextContrast.$value = 3;
  fails(u, /Accessibility acceptance floors/);
});

test('native and selected Catch metrics are intentionally distinct and correctly named', () => {
  const tokens = collectTokens(original);
  assert.equal(resolveToken(tokens, 'platformReference.ios.typography.body.size').value, 17);
  assert.equal(resolveToken(tokens, 'typography.ios.body.size').value, 16);
  assert.equal(resolveToken(tokens, 'platformReference.ios.typography.caption1.size').value, 12);
  assert.equal(resolveToken(tokens, 'typography.ios.context.size').value, 13);
});

test('an applicable source row cannot silently remain unmapped or change numeric value', () => {
  const body = { id: 'V00026', category: 'Typography', concept: 'Body / Size (points)', context: 'Large (default)', origin: 'A:typography:table12:row6:col2', ios: 17, android: null };
  const changed = { ...body, ios: 18 };
  fails(original, /Source value\/provenance differs/, { inventory: { rows: [changed] } });
  const unmapped = { ...body, id: 'V99999', concept: 'New published style / Size (points)' };
  fails(original, /Applicable native value not imported/, { inventory: { rows: [unmapped] } });
  fails(original, /domain needs an applicability decision/, { inventory: { rows: [{ ...body, category: 'New platform domain' }] } });
});

test('floating navigation metrics are an explicit authored exception, not generic button typography', () => {
  const tokens = collectTokens(original);
  for (const platform of ['ios', 'android']) {
    for (const [field, expected] of [['size', 13], ['lineHeight', 13], ['weight', 600], ['tracking', 0]]) {
      const value = resolveToken(tokens, `typography.${platform}.navigationLabel.${field}`);
      assert.equal(typeof value === 'object' ? value.value : value, expected);
      const changed = copy();
      const token = changed.typography[platform].navigationLabel[field];
      if (typeof token.$value === 'object') token.$value.value += 1;
      else token.$value += 100;
      fails(changed, /Approved floating navigation typography/);
    }
    const missingException = copy();
    delete missingException.typography[platform].navigationLabel.$extensions['org.catch'].exception;
    fails(missingException, /Approved floating navigation typography/);
  }
});

test('a second raw functional scale and a raw Material fallback are rejected', () => {
  fails(original, /no second raw sans scale/, { textStyles: `${styles}\nfinal bad = CatchFonts.sans(fontSize: 13, height: 1);` });
  fails(original, /Material fallback must consume/, { textStyles: styles.replace('final profile = CatchPlatformTokens.typography;', 'final profile = TextTheme();') });
});

test('normal CI rejects arbitrary native deletions and value changes without the external inventory', () => {
  const t = copy();
  delete t.platformReference.ios.componentGuidance.alertTitleSuggestedLineLimit;
  fails(t, /Missing native source acceptance token/);
  const u = copy();
  u.platformReference.ios.typography.subhead.size.$value.value = 14;
  fails(u, /Native source acceptance differs/);
  const v = copy();
  const components = v.platformReference.android.components;
  const nativeButton = Object.entries(components.buttonFilled).find(([,token]) => token.$extensions['org.catch'].source.tokenName === 'md.comp.filled-button.container.height');
  assert(nativeButton);
  delete components.buttonFilled[nativeButton[0]];
  fails(v, /Pinned Material source not imported/);
});

test('the independent source dependency set, hashes and provenance cannot be vacuous', () => {
  const t = copy();
  t.$extensions['org.catch'].platformFoundation.materialSources.files = {};
  fails(t, /Complete pinned Material source dependency set/);
  const u = copy();
  u.$extensions['org.catch'].platformFoundation.nativeAcceptance.sha256 = '0'.repeat(64);
  fails(u, /source checksum differs/);
  const v = copy();
  v.platformReference.android.typography.bodyLarge.size.$extensions['org.catch'].source.tokenName = 'md.sys.typescale.invented.size';
  fails(v, /provenance has no pinned source/);
  const versionChanged = copy();
  const nativeSource = versionChanged.platformReference.ios.typography.body.size.$extensions['org.catch'].source.sourceKey;
  versionChanged.$extensions['org.catch'].platformFoundation.sources[nativeSource].version = 'unverified source revision';
  fails(versionChanged, /Native source acceptance differs/);
  for (const [field, wrongValue] of [['unit', 'pt'], ['platform', 'ios']]) {
    const mutated = copy();
    const button = Object.values(mutated.platformReference.android.components.buttonFilled)
      .find(token => token.$extensions['org.catch'].source.tokenName === 'md.comp.filled-button.container.height');
    assert(button);
    button.$extensions['org.catch'].source[field] = wrongValue;
    fails(mutated, /Pinned Material source unit\/provenance differs/);
  }
});
