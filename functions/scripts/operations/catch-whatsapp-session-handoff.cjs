#!/usr/bin/env node
"use strict";

const fs = require("node:fs");
const path = require("node:path");
const http = require("node:http");
const {createHash, randomBytes, timingSafeEqual} = require("node:crypto");
const {execFileSync} = require("node:child_process");
const {executionIdentity, protectedHome, createOperatorRuntime} =
  require("./catch-whatsapp-operator-runtime.cjs");
const {localPage, launchPage} = require("./catch-whatsapp-session-handoff-ui.cjs");
const repo = path.resolve(__dirname, "../../..");
const unavailable = () => {throw new Error("Protected session handoff unavailable.");};
const hash = value => createHash("sha256").update(value).digest("hex");
const equal = (a, b) => typeof a === "string" && typeof b === "string" &&
  a.length === b.length && timingSafeEqual(Buffer.from(a), Buffer.from(b));
const maxAge = 5 * 60 * 1000;
const present = file => {try {fs.lstatSync(file); return true;} catch (error) {
  if (error.code === "ENOENT") return false; throw error;
}};

// Separate from the planner/apply execution digest: these executables are not
// consumed by that runtime. Require committed bytes, then freeze this binding.
function handoffIdentity() {
  const runtime = executionIdentity();
  const files = [__filename, path.join(__dirname, "catch-whatsapp-session-handoff-ui.cjs")];
  const hashes = files.map(file => {
    const stat = fs.lstatSync(file);
    if (!stat.isFile() || stat.isSymbolicLink() || stat.nlink !== 1 || stat.size > 65536) unavailable();
    const fd = fs.openSync(file, fs.constants.O_RDONLY | fs.constants.O_NOFOLLOW);
    let bytes;
    try {
      const opened = fs.fstatSync(fd);
      if (opened.dev !== stat.dev || opened.ino !== stat.ino || opened.size !== stat.size) unavailable();
      bytes = fs.readFileSync(fd);
    } finally {fs.closeSync(fd);}
    const committed = execFileSync("git", ["cat-file", "blob", "HEAD:" + path.relative(repo, file)],
      {cwd: repo, stdio: ["ignore", "pipe", "ignore"]});
    if (!bytes.equals(committed)) unavailable();
    return hash(bytes);
  });
  return {runtime, helperSha256: hash(JSON.stringify(hashes))};
}

function verifyFactory(projectId) {
  if (["FIREBASE_AUTH_EMULATOR_HOST", "FIRESTORE_EMULATOR_HOST"].some(key =>
    Object.hasOwn(process.env, key))) unavailable();
  const {initializeApp} = require("firebase-admin/app");
  const {getAuth} = require("firebase-admin/auth");
  const auth = getAuth(initializeApp({projectId}, "catch-session-" + randomBytes(16).toString("hex")));
  return token => auth.verifyIdToken(token, true);
}

function assertSession(token, scope, now) {
  const integer = value => Number.isSafeInteger(value) && value >= 0;
  if (!token || token.uid !== scope.actorUid || token.sub !== scope.actorUid ||
      token.aud !== scope.projectId || token.iss !== "https://securetoken.google.com/" + scope.projectId ||
      token.firebase?.sign_in_provider !== "google.com" ||
      token.firebase?.tenant !== undefined || token.tenant_id !== undefined ||
      token.email_verified !== true || typeof token.email !== "string" ||
      hash(JSON.stringify(token.email.trim().toLowerCase())) !== scope.actorEmailSha256 ||
      ![token.auth_time, token.iat, token.exp].every(integer) ||
      ![token.auth_time, token.iat, token.exp].every(value => integer(value * 1000)) ||
      token.auth_time > token.iat || token.iat * 1000 > now ||
      now - token.auth_time * 1000 > maxAge || token.exp * 1000 <= now ||
      token.exp <= token.iat || token.exp - token.iat > 3600) unavailable();
}

function createSessionHandoff({home, clientOrigin, now = Date.now,
  identity = handoffIdentity, verifierFactory = verifyFactory} = {}) {
  const client = new URL(clientOrigin);
  if (client.protocol !== "https:" || client.origin !== clientOrigin ||
      client.username || client.password || client.pathname !== "/" || client.search || client.hash) unavailable();
  if (!path.isAbsolute(home ?? "") || path.resolve(home) !== home) unavailable();
  for (let p = home; p !== path.dirname(p); p = path.dirname(p)) {
    if (present(path.join(p, ".git")) || (present(p) && fs.lstatSync(p).isSymbolicLink())) unavailable();
  }
  try {fs.mkdirSync(home, {mode: 0o700});} catch (error) {if (error.code !== "EEXIST") throw error;}
  const privateFiles = protectedHome(home);
  const homeStat = fs.lstatSync(home);
  const binding = structuredClone(identity());
  const bindingHash = hash(JSON.stringify(binding));
  const startedAtMillis = now();
  if (!Number.isSafeInteger(startedAtMillis) || startedAtMillis < 0) unavailable();
  const expiresAtMillis = startedAtMillis + maxAge;
  const capability = randomBytes(32).toString("hex");
  const csrf = randomBytes(32).toString("hex");
  const cookie = randomBytes(32).toString("hex");
  const cookieName = "catch_session_" + randomBytes(8).toString("hex");
  const challenge = randomBytes(32).toString("hex");
  const temporary = fs.mkdtempSync(path.join(home, ".session-handoff-"));
  fs.chmodSync(temporary, 0o700);
  let origin, launchFile, launchStat, initialProfile, profile, profileHash, verifier;
  let phase = "bootstrap", consumed = false, timer;
  const current = () => {
    const stat = fs.lstatSync(home);
    if (stat.dev !== homeStat.dev || stat.ino !== homeStat.ino ||
        hash(JSON.stringify(identity())) !== bindingHash || !Number.isSafeInteger(now()) ||
        now() < startedAtMillis || now() >= expiresAtMillis ||
        (profileHash && hash(JSON.stringify([profile, challenge, expiresAtMillis, binding])) !== profileHash) ||
        ["cancelled", "saved"].includes(phase)) unavailable();
    protectedHome(home);
  };
  const validate = candidate => {
    // Reuse the complete existing profile validator without SDK/ADC dispatch.
    const stage = fs.mkdtempSync(path.join(temporary, "profile-"));
    fs.chmodSync(stage, 0o700);
    try {
      fs.writeFileSync(path.join(stage, "profile.json"), JSON.stringify(candidate) + "\n", {flag: "wx", mode: 0o600});
      createOperatorRuntime({home: stage, identity: () => binding.runtime});
    } finally {
      if (present(path.join(stage, "profile.json"))) fs.unlinkSync(path.join(stage, "profile.json"));
      fs.rmdirSync(stage);
    }
  };
  try {
    if (present(path.join(home, "profile.json"))) {
      initialProfile = privateFiles.readBytes("profile.json");
      profile = privateFiles.read("profile.json");
      validate(profile);
    }
  } catch (error) {fs.rmdirSync(temporary); throw error;}
  const unchangedProfile = () => {
    const file = path.join(home, "profile.json");
    if (initialProfile ? !privateFiles.readBytes("profile.json").equals(initialProfile) : present(file)) unavailable();
  };
  const oldToken = () => {
    const file = path.join(home, "actor-id-token.txt");
    if (!present(file)) return null;
    return hash(privateFiles.readBytes("actor-id-token.txt", 16384));
  };
  const cleanup = () => {
    clearTimeout(timer);
    if (launchFile && present(launchFile)) {
      const stat = fs.lstatSync(launchFile);
      if (stat.dev === launchStat?.dev && stat.ino === launchStat?.ino) fs.unlinkSync(launchFile);
    }
    try {fs.rmdirSync(temporary);} catch { /* Preserve any unexpected files. */ }
  };
  const reply = (response, status, value) => {
    response.writeHead(status, {"Content-Type": "application/json", "Cache-Control": "no-store", "X-Content-Type-Options": "nosniff"});
    response.end(JSON.stringify(value));
  };
  const body = async request => {
    if (request.headers["content-type"] !== "application/json") unavailable();
    const chunks = [];
    let size = 0;
    for await (const chunk of request) {
      if ((size += chunk.length) > 32768) unavailable();
      chunks.push(chunk);
    }
    return JSON.parse(new TextDecoder("utf-8", {fatal: true}).decode(Buffer.concat(chunks)));
  };
  const server = http.createServer(async (request, response) => {
    try {
      if (request.headers.host !== new URL(origin).host || request.socket.remoteAddress !== "127.0.0.1") unavailable();
      if (request.method === "GET" && request.url === "/") {
        response.writeHead(200, {"Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-store", "Referrer-Policy": "no-referrer",
          "Content-Security-Policy": "default-src 'none'; script-src 'sha256-" + localPage.scriptHash + "'; connect-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'none'",
          "X-Content-Type-Options": "nosniff"});
        response.end(localPage.html);
        return;
      }
      if (request.method !== "POST" || request.headers.origin !== origin ||
          request.headers["sec-fetch-site"] !== "same-origin") unavailable();
      if (request.url === "/bootstrap") {
        current();
        if (phase !== "bootstrap" || !equal(request.headers["x-catch-bootstrap"], capability)) unavailable();
        phase = "configuration";
        response.setHeader("Set-Cookie", `${cookieName}=${cookie}; HttpOnly; SameSite=Strict; Path=/; Max-Age=300`);
        reply(response, 200, {csrf, profile: profile ?? null, runtime: binding.runtime});
        return;
      }
      const selectedCookies = (request.headers.cookie ?? "").split(";").map(value => value.trim())
        .filter(value => value.startsWith(cookieName + "="));
      if (!equal(request.headers["x-catch-csrf"], csrf) || selectedCookies.length !== 1 ||
          !equal(selectedCookies[0], `${cookieName}=${cookie}`)) unavailable();
      if (request.url === "/cancel") {
        if (phase === "saved") {reply(response, 409, {state: "saved"}); return;}
        phase = "cancelled"; cleanup();
        reply(response, 200, {state: "cancelled"}); server.close(); return;
      }
      current(); unchangedProfile();
      if (request.url === "/configure") {
        if (phase !== "configuration") unavailable();
        const candidate = await body(request);
        current(); unchangedProfile();
        validate(candidate);
        const bytes = JSON.stringify(candidate) + "\n";
        if (initialProfile && bytes.trim() !== initialProfile.toString("utf8").trim()) unavailable();
        profile = structuredClone(candidate);
        profileHash = hash(JSON.stringify([profile, challenge, expiresAtMillis, binding]));
        phase = "transfer";
        reply(response, 200, {clientOrigin, request: {kind: "catch-operator-session-request", schemaVersion: 1,
          challenge, projectId: profile.scope.projectId, actorUid: profile.scope.actorUid,
          actorEmailSha256: profile.scope.actorEmailSha256, scopeSha256: hash(JSON.stringify(profile.scope)),
          sourceSha: profile.sourceSha, expiresAtMillis}});
        return;
      }
      if (request.url !== "/session" || phase !== "transfer" || consumed) unavailable();
      consumed = true; phase = "verifying";
      const input = await body(request);
      if (!input || Object.keys(input).sort().join(",") !== "challenge,idToken" ||
          !equal(input.challenge, challenge) || typeof input.idToken !== "string" ||
          input.idToken.length > 16384 || !/^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/u.test(input.idToken)) unavailable();
      current(); unchangedProfile();
      const priorToken = oldToken();
      verifier ??= verifierFactory(profile.scope.projectId);
      let deadline;
      const verified = await Promise.race([verifier(input.idToken), new Promise((_, reject) => {
        deadline = setTimeout(() => reject(new Error("Protected session handoff unavailable.")), 10000);
      })]).finally(() => clearTimeout(deadline));
      current(); unchangedProfile();
      if (oldToken() !== priorToken) unavailable();
      assertSession(verified, profile.scope, now());
      const tokenStage = path.join(temporary, "actor-id-token.txt");
      const fd = fs.openSync(tokenStage, fs.constants.O_WRONLY | fs.constants.O_CREAT | fs.constants.O_EXCL | fs.constants.O_NOFOLLOW, 0o600);
      try {fs.writeFileSync(fd, input.idToken + "\n"); fs.fsyncSync(fd);} finally {fs.closeSync(fd);}
      let createdProfile;
      try {
        current(); unchangedProfile();
        if (oldToken() !== priorToken) unavailable();
        if (!initialProfile) {
          privateFiles.create("profile.json", profile);
          createdProfile = fs.lstatSync(path.join(home, "profile.json"));
        }
        fs.renameSync(tokenStage, path.join(home, "actor-id-token.txt"));
      } catch (error) {
        if (createdProfile) {
          const stat = fs.lstatSync(path.join(home, "profile.json"));
          if (stat.dev === createdProfile.dev && stat.ino === createdProfile.ino) fs.unlinkSync(path.join(home, "profile.json"));
        }
        if (fs.existsSync(tokenStage)) fs.unlinkSync(tokenStage);
        throw error;
      }
      phase = "saved"; cleanup();
      reply(response, 200, {kind: "catch-operator-session", state: "saved", sourceSha: profile.sourceSha,
        expiresAtMillis: verified.exp * 1000}); server.close();
    } catch {
      reply(response, 400, {state: "unavailable"});
    }
  });
  return {
    async start() {
      await new Promise((resolve, reject) => {server.once("error", reject); server.listen(0, "127.0.0.1", resolve);});
      origin = "http://127.0.0.1:" + server.address().port;
      launchFile = path.join(temporary, "launch.html");
      fs.writeFileSync(launchFile, launchPage(origin, capability), {flag: "wx", mode: 0o600});
      launchStat = fs.lstatSync(launchFile);
      timer = setTimeout(() => {phase = "cancelled"; cleanup(); server.close();}, maxAge);
      return {launchFile, expiresAtMillis};
    },
    close() {phase = "cancelled"; cleanup(); server.close();},
  };
}

async function run(argv = process.argv.slice(2)) {
  if (argv.length !== 4 || argv[0] !== "--home" || argv[2] !== "--client-origin") unavailable();
  return createSessionHandoff({home: argv[1], clientOrigin: argv[3]}).start();
}
if (require.main === module) run().then(value => {
  process.stdout.write(JSON.stringify({kind: "catch-operator-session-launch", ...value}) + "\n");
}).catch(() => {process.stderr.write("Protected session handoff unavailable.\n"); process.exitCode = 1;});
module.exports = {createSessionHandoff, assertSession, handoffIdentity, verifyFactory, run};
