import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';

// Reviewed PR726 bytes. Changing runtime scope requires another source review.
export const release = Object.freeze({
  repository: 'suvratgarg/catch-dating-app',
  workflow: '.github/workflows/host-measurement-preview.yml',
  runtimeSource: '30a66b8e1df3ef405b76fa51ada6cc165bd302c9',
  project: 'catch-dating-app-64e51', site: 'catch-host-measurement',
  origin: 'https://catch-host-measurement.web.app',
  files: Object.freeze({
    'measurement-hosting.json': '9424ea8fb358050d881a4c2cbe01b5f3beb0f09afd214128faa5b439a6d6d80f',
    'measurement-runtime/catch-acquisition-runtime.html': '535d7ce950fd66d6ba743ae87b74cf0d1c51a1d7d609e35e72b65f8b162ad94a',
    'measurement-runtime/catch-acquisition-runtime.js': '2fa1f7f59654f0725f3cee742bef7010a8d5f596b683d84788f92b303cb82187',
  }),
});
export const digest = bytes => createHash('sha256').update(bytes).digest('hex');
const output = 'build/host-measurement-preview';
function command(name, args) {
  const result = spawnSync(name, args, {encoding: 'utf8', maxBuffer: 16 * 1024 * 1024});
  assert.equal(result.status, 0, result.stderr || `${name} failed`);
  return result.stdout.trim();
}
const github = endpoint => JSON.parse(command('gh', ['api', '-H', 'Cache-Control: no-cache', endpoint]));
export function assertInvocation(env) {
  assert.equal(env.GITHUB_EVENT_NAME, 'workflow_dispatch');
  assert.equal(env.GITHUB_REF, 'refs/heads/main');
  assert.equal(env.GITHUB_REPOSITORY, release.repository);
  assert.equal(env.GITHUB_WORKFLOW_REF, `${release.repository}/${release.workflow}@refs/heads/main`);
  assert.equal(env.GITHUB_RUN_ATTEMPT, '1', 'Use a new reviewed dispatch after failure');
  assert.match(env.GITHUB_SHA ?? '', /^[a-f0-9]{40}$/u);
}
export function assertCi(run, sourceSha) {
  assert.equal(run.head_sha, sourceSha);
  assert.equal(run.head_branch, 'main');
  assert.equal(run.event, 'push');
  assert.equal(run.path?.split('@')[0], '.github/workflows/ci.yml');
  assert.equal(run.repository?.full_name, release.repository);
  assert.equal(run.head_repository?.full_name, release.repository);
  assert.equal(run.status, 'completed');
  assert.equal(run.conclusion, 'success');
}
export function verifyFiles(root) {
  assert.ok(fs.lstatSync(root).isDirectory());
  const runtime = path.join(root, 'measurement-runtime');
  assert.ok(fs.lstatSync(runtime).isDirectory(), 'Runtime directory cannot be a link');
  assert.deepEqual(fs.readdirSync(runtime).sort(), ['catch-acquisition-runtime.html', 'catch-acquisition-runtime.js']);
  for (const [name, expected] of Object.entries(release.files)) {
    const file = path.join(root, name);
    assert.ok(fs.lstatSync(file).isFile(), `Non-regular file: ${name}`);
    assert.equal(digest(fs.readFileSync(file)), expected, `Unreviewed runtime bytes: ${name}`);
  }
}
export function prepare(sourceRoot, destination, sourceSha) {
  verifyFiles(sourceRoot);
  assert.match(sourceSha, /^[a-f0-9]{40}$/u);
  assert.ok(!fs.existsSync(destination), 'Release tree already exists');
  fs.mkdirSync(path.join(destination, 'measurement-runtime'), {recursive: true});
  for (const name of Object.keys(release.files)) fs.copyFileSync(path.join(sourceRoot, name), path.join(destination, name));
  fs.writeFileSync(path.join(destination, 'release.json'), JSON.stringify({sourceSha, ...release}, null, 2) + '\n');
  verifyPackage(destination, sourceSha);
}
export function verifyPackage(destination, sourceSha) {
  verifyFiles(destination);
  assert.deepEqual(fs.readdirSync(destination).sort(), ['measurement-hosting.json', 'measurement-runtime', 'release.json']);
  assert.ok(fs.lstatSync(path.join(destination, 'release.json')).isFile());
  assert.deepEqual(JSON.parse(fs.readFileSync(path.join(destination, 'release.json'), 'utf8')), {sourceSha, ...release});
}
function authorize() {
  assertInvocation(process.env);
  const sourceSha = process.env.GITHUB_SHA;
  assert.equal(command('git', ['rev-parse', 'HEAD']), sourceSha);
  assert.equal(github(`repos/${release.repository}/git/ref/heads/main`).object.sha, sourceSha, 'Current main changed');
  command('git', ['merge-base', '--is-ancestor', release.runtimeSource, sourceSha]);
  verifyFiles('website');
  const runs = github(`repos/${release.repository}/actions/workflows/ci.yml/runs?head_sha=${sourceSha}&event=push&per_page=100`).workflow_runs;
  const latest = [...runs].sort((a, b) => b.id - a.id)[0];
  assert.ok(latest, 'No exact-source main CI');
  const run = github(`repos/${release.repository}/actions/runs/${latest.id}`);
  assertCi(run, sourceSha);
  console.log(JSON.stringify({sourceSha, ciRunId: run.id, ciRunAttempt: run.run_attempt, runtimeSource: release.runtimeSource}));
}
export function assertResponse(name, bytes, headers, config) {
  assert.equal(digest(bytes), release.files[`measurement-runtime/${name}`], `Serving bytes differ: ${name}`);
  for (const {key, value} of config.hosting.headers[0].headers) assert.equal(headers.get(key), value, `Serving header differs: ${key}`);
  assert.equal(headers.get('set-cookie'), null, 'Static runtime must not set cookies before consent');
}
async function verifyServing() {
  verifyPackage(output, process.env.GITHUB_SHA);
  const config = JSON.parse(fs.readFileSync(path.join(output, 'measurement-hosting.json'), 'utf8'));
  const checks = [];
  for (const name of ['catch-acquisition-runtime.html', 'catch-acquisition-runtime.js']) {
    const response = await fetch(`${release.origin}/${name}`, {redirect: 'error', signal: AbortSignal.timeout(30000)});
    assert.equal(response.status, 200);
    const bytes = Buffer.from(await response.arrayBuffer());
    assertResponse(name, bytes, response.headers, config);
    checks.push({name, sha256: digest(bytes), status: response.status});
  }
  fs.writeFileSync(`${output}/../host-measurement-serving.json`, JSON.stringify({
    sourceSha: process.env.GITHUB_SHA, runtimeSource: release.runtimeSource, site: release.site,
    verifiedAt: new Date().toISOString(), checks, providerReceiptVerified: false, productionMeasurementEnabled: false,
  }, null, 2) + '\n');
}
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const mode = process.argv[2];
  if (mode === 'authorize') authorize();
  else if (mode === 'prepare') prepare('website', output, process.env.GITHUB_SHA);
  else if (mode === 'verify-package') verifyPackage(output, process.env.GITHUB_SHA);
  else if (mode === 'verify-serving') await verifyServing();
  else throw new Error('Expected authorize, prepare, verify-package or verify-serving');
}
