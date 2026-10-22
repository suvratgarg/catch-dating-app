import assert from 'node:assert/strict';
import {readFileSync, readdirSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import test from 'node:test';
const root = new URL('../../', import.meta.url);
const read = path => readFileSync(new URL(path, root), 'utf8');
test('measurement hosting publishes only the two isolated runtime assets', () => {
  const config = JSON.parse(read('measurement-hosting.json'));
  assert.deepEqual(Object.keys(config), ['hosting']);
  assert.equal(config.hosting.site, 'catch-host-measurement');
  assert.equal(config.hosting.public, 'measurement-runtime');
  assert.equal(config.hosting.rewrites, undefined);
  assert.equal(config.hosting.redirects, undefined);
  assert.deepEqual(readdirSync(fileURLToPath(new URL('measurement-runtime/', root))).sort(),
    ['catch-acquisition-runtime.html', 'catch-acquisition-runtime.js']);
  const headers = Object.fromEntries(config.hosting.headers[0].headers.map(({key, value}) => [key, value]));
  assert.equal(headers['Cache-Control'], 'no-store');
  assert.equal(headers['Referrer-Policy'], 'no-referrer');
  assert.equal(headers['X-Robots-Tag'], 'noindex, nofollow');
  assert.match(headers['Content-Security-Policy'], /frame-ancestors https:\/\/catch-dating-app-64e51--next-candidate-tnpxnhes.web.app$/);
  assert.doesNotMatch(headers['Content-Security-Policy'], /unsafe-inline|unsafe-eval|facebook|doubleclick/);
  assert.match(read('measurement-runtime/catch-acquisition-runtime.html'), /name="referrer" content="no-referrer"/);
});
