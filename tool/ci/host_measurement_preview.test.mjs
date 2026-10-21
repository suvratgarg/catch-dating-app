import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import {fileURLToPath} from 'node:url';
import {release, assertInvocation, assertCi, prepare, verifyPackage, verifyPostDeployPackage,
  assertResponse} from './host_measurement_preview.mjs';
const root = fileURLToPath(new URL('../../', import.meta.url));
const source = path.join(root, 'website');
const sha = 'a'.repeat(40);
const invocation = {GITHUB_EVENT_NAME: 'workflow_dispatch', GITHUB_REF: 'refs/heads/main',
  GITHUB_REPOSITORY: release.repository, GITHUB_WORKFLOW_REF: `${release.repository}/${release.workflow}@refs/heads/main`,
  GITHUB_RUN_ATTEMPT: '1', GITHUB_SHA: sha};
const ci = {head_sha: sha, head_branch: 'main', event: 'push', path: '.github/workflows/ci.yml',
  repository: {full_name: release.repository}, head_repository: {full_name: release.repository},
  status: 'completed', conclusion: 'success'};
function fixture(t) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'host-measurement-preview-'));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  return path.join(directory, 'package');
}
function addFirebaseCache(destination) {
  const directory = path.join(destination, '.firebase');
  fs.mkdirSync(directory);
  const names = ['catch-acquisition-runtime.html', 'catch-acquisition-runtime.js'];
  const lines = names.map((name, index) =>
    `${name},${fs.statSync(path.join(destination, 'measurement-runtime', name)).mtime.getTime()},${String(index + 1).repeat(64)}`);
  const file = path.join(directory, 'hosting.bWVhc3VyZW1lbnQtcnVudGltZQ.cache');
  fs.writeFileSync(file, `${lines.join('\n')}\n`);
  return {directory, file, lines};
}
test('measurement preview rejects other callers, reruns and unaccepted CI', () => {
  assertInvocation(invocation); assertCi(ci, sha);
  for (const patch of [{GITHUB_EVENT_NAME: 'push'}, {GITHUB_REF: 'refs/heads/topic'},
    {GITHUB_REPOSITORY: 'fork/repo'}, {GITHUB_WORKFLOW_REF: 'wrong'}, {GITHUB_RUN_ATTEMPT: '2'}, {GITHUB_SHA: ''}]) {
    assert.throws(() => assertInvocation({...invocation, ...patch}));
  }
  for (const patch of [{head_sha: 'b'.repeat(40)}, {head_branch: 'topic'}, {event: 'pull_request'},
    {path: '.github/workflows/other.yml'}, {repository: {full_name: 'fork/repo'}},
    {head_repository: {full_name: 'fork/repo'}}, {status: 'in_progress'}, {conclusion: 'failure'}]) {
    assert.throws(() => assertCi({...ci, ...patch}, sha));
  }
});
test('measurement package rejects tampering, added files, links and source substitution', t => {
  const destination = fixture(t);
  prepare(source, destination, sha); verifyPackage(destination, sha);
  assert.throws(() => prepare(source, destination, sha));
  assert.throws(() => verifyPackage(destination, 'b'.repeat(40)));
  const runtime = path.join(destination, 'measurement-runtime');
  const script = path.join(runtime, 'catch-acquisition-runtime.js');
  const original = fs.readFileSync(script);
  fs.appendFileSync(script, '\n// drift');
  assert.throws(() => verifyPackage(destination, sha), /Unreviewed runtime bytes/);
  fs.writeFileSync(script, original);
  const extra = path.join(runtime, 'unreviewed.js'); fs.writeFileSync(extra, '');
  assert.throws(() => verifyPackage(destination, sha)); fs.unlinkSync(extra);
  fs.unlinkSync(script); fs.symlinkSync(path.join(source, 'measurement-runtime/catch-acquisition-runtime.js'), script);
  assert.throws(() => verifyPackage(destination, sha), /Non-regular/);
  fs.unlinkSync(script); fs.writeFileSync(script, original);
  fs.writeFileSync(path.join(destination, '.firebaserc'), '{}');
  assert.throws(() => verifyPackage(destination, sha));
});
test('post-deploy verification accepts only the pinned Hosting cache after strict preparation', t => {
  const destination = fixture(t);
  prepare(source, destination, sha);
  verifyPostDeployPackage(destination, sha);
  addFirebaseCache(destination);
  assert.throws(() => verifyPackage(destination, sha), 'Pre-deploy verification must still reject the cache');
  verifyPostDeployPackage(destination, sha);
});
test('post-deploy verification rejects unexpected cache paths, links, stale metadata and altered assets', t => {
  const fresh = () => { const destination = fixture(t); prepare(source, destination, sha); return destination; };

  let destination = fresh(); let cache = addFirebaseCache(destination);
  fs.writeFileSync(path.join(destination, 'unreviewed.js'), '');
  assert.throws(() => verifyPostDeployPackage(destination, sha));

  destination = fresh(); cache = addFirebaseCache(destination);
  fs.writeFileSync(path.join(cache.directory, 'other.cache'), '');
  assert.throws(() => verifyPostDeployPackage(destination, sha), /Unexpected Firebase cache contents/);

  destination = fresh(); cache = addFirebaseCache(destination);
  const movedCache = path.join(path.dirname(destination), 'moved-cache');
  fs.renameSync(cache.directory, movedCache);
  fs.symlinkSync(movedCache, cache.directory, 'dir');
  assert.throws(() => verifyPostDeployPackage(destination, sha), /not a link/);

  destination = fresh(); cache = addFirebaseCache(destination);
  fs.unlinkSync(cache.file);
  fs.symlinkSync(path.join(destination, 'release.json'), cache.file);
  assert.throws(() => verifyPostDeployPackage(destination, sha), /regular file/);

  for (const change of [
    lines => [lines[0].replace('catch-acquisition-runtime.html', '../../unreviewed'), lines[1]],
    lines => [lines[0], lines[0]],
    lines => [lines[0].replace(/,[0-9]+,/u, ',1,'), lines[1]],
    lines => [lines[0].replace(/[a-f0-9]{64}$/u, 'wrong'), lines[1]],
  ]) {
    destination = fresh(); cache = addFirebaseCache(destination);
    fs.writeFileSync(cache.file, `${change(cache.lines).join('\n')}\n`);
    assert.throws(() => verifyPostDeployPackage(destination, sha));
  }

  destination = fresh(); addFirebaseCache(destination);
  fs.appendFileSync(path.join(destination, 'measurement-runtime/catch-acquisition-runtime.js'), '\n// drift');
  assert.throws(() => verifyPostDeployPackage(destination, sha), /Unreviewed runtime bytes/);

  destination = fresh(); addFirebaseCache(destination);
  fs.writeFileSync(path.join(destination, 'release.json'), JSON.stringify({sourceSha: 'b'.repeat(40)}));
  assert.throws(() => verifyPostDeployPackage(destination, sha));
});
test('measurement serving acceptance requires exact bytes and all privacy headers', () => {
  const config = JSON.parse(fs.readFileSync(path.join(source, 'measurement-hosting.json'), 'utf8'));
  const headers = new Headers(config.hosting.headers[0].headers.map(({key, value}) => [key, value]));
  const name = 'catch-acquisition-runtime.html';
  const bytes = fs.readFileSync(path.join(source, 'measurement-runtime', name));
  assertResponse(name, bytes, headers, config);
  assert.throws(() => assertResponse(name, Buffer.from('wrong'), headers, config));
  for (const {key} of config.hosting.headers[0].headers) {
    const missing = new Headers(headers); missing.delete(key);
    assert.throws(() => assertResponse(name, bytes, missing, config));
  }
  const cookies = new Headers(headers); cookies.set('set-cookie', 'tracking=before-consent');
  assert.throws(() => assertResponse(name, bytes, cookies, config));
});
test('measurement workflow preserves site-only authority and precredential checks', () => {
  const workflow = fs.readFileSync(path.join(root, release.workflow), 'utf8');
  assert.match(workflow, /environment: prod-hosting/);
  assert.match(workflow, /persist-credentials: false/);
  assert.match(workflow, /cancel-in-progress: false/);
  assert.match(workflow, /firebase deploy --only hosting:catch-host-measurement --project catch-dating-app-64e51/);
  assert.doesNotMatch(workflow, /--force|functions:|firestore:|secrets: inherit|hosting:channel:clone/);
  assert.ok(workflow.indexOf('verify-package') < workflow.indexOf('google-github-actions/auth@'));
  assert.ok(workflow.lastIndexOf('verify-package') < workflow.indexOf('firebase deploy'));
  assert.ok(workflow.indexOf('verify-serving') > workflow.indexOf('firebase deploy'));
});
