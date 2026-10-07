"use strict";

const fs = require("node:fs");
const path = require("node:path");
const {createHash, randomBytes} = require("node:crypto");
const {execFileSync} = require("node:child_process");
const repo = path.resolve(__dirname, "../../..");
const unavailable = () => {throw new Error("Protected Catch operator setup unavailable.");};
const sha = (bytes) => createHash("sha256").update(bytes).digest("hex");
const validId = (id) => typeof id === "string" && /^[A-Za-z0-9_-]{1,128}$/u.test(id);
const phases = ["reserved", "auth-intent", "auth-confirmed", "seeded",
  "root-active", "prepare-intent", "prepared", "finalize-intent", "complete",
  "publish-intent", "published", "readiness-intent", "ready", "revoke-intent", "revoked"];

// Artifact binding, not proof of compilation or protection from a hostile
// process with the delegated operator's own UID. No SDK/ADC is loaded here.
function executionIdentity() {
  const sourceSha = execFileSync("git", ["rev-parse", "HEAD"], {cwd: repo,
    encoding: "utf8", stdio: ["ignore", "pipe", "ignore"]}).trim();
  if (!/^[a-f0-9]{40}$/u.test(sourceSha) || execFileSync("git", ["status",
    "--porcelain=v1", "--untracked-files=no"], {cwd: repo,
    encoding: "utf8", stdio: ["ignore", "pipe", "ignore"]}).trim()) unavailable();
  const files = [];
  let bytes = 0;
  const add = (file) => {
    const stat = fs.lstatSync(file);
    if (!stat.isFile() || stat.isSymbolicLink() || stat.size > 64 * 1024 * 1024 ||
        (bytes += stat.size) > 256 * 1024 * 1024 || files.length >= 20000) unavailable();
    const fd = fs.openSync(file, fs.constants.O_RDONLY | fs.constants.O_NOFOLLOW);
    try {
      const opened = fs.fstatSync(fd);
      if (opened.dev !== stat.dev || opened.ino !== stat.ino ||
          !opened.isFile() || opened.size !== stat.size) unavailable();
      files.push([path.relative(repo, file), sha(fs.readFileSync(fd))]);
    } finally {fs.closeSync(fd);}
  };
  const walk = (dir) => {
    const stat = fs.lstatSync(dir);
    if (!stat.isDirectory() || stat.isSymbolicLink()) unavailable();
    for (const name of fs.readdirSync(dir).sort()) {
      const file = path.join(dir, name);
      if (fs.lstatSync(file).isDirectory()) walk(file);
      else add(file);
    }
  };
  walk(path.join(repo, "functions/lib"));
  for (const name of ["functions/package.json", "functions/package-lock.json",
    "functions/scripts/operations/setup-catch-whatsapp-reply.cjs",
    "functions/scripts/operations/catch-whatsapp-operator-runtime.cjs",
    "functions/scripts/operations/catch-whatsapp-operator-readiness.cjs"]) {
    execFileSync("git", ["cat-file", "-e", "HEAD:" + name], {cwd: repo,
      stdio: ["ignore", "ignore", "ignore"]});
    add(path.join(repo, name));
  }
  if (!files.length) unavailable();
  return {sourceSha, executionSha256: sha(JSON.stringify([process.version,
    files.sort(([a], [b]) => a.localeCompare(b))]))};
}

// This profile-selected directory is the explicitly delegated OS owner's
// policy trust root. Permissions do not certify independent human review.
function protectedHome(input) {
  if (typeof input !== "string" || !path.isAbsolute(input)) unavailable();
  const home = path.resolve(input);
  if (home === repo || home.startsWith(repo + path.sep)) unavailable();
  for (let p = home; p !== path.dirname(p); p = path.dirname(p)) {
    if (fs.lstatSync(p).isSymbolicLink()) unavailable();
  }
  const directory = (relative) => {
    const file = path.join(home, relative);
    const stat = fs.lstatSync(file);
    if (!stat.isDirectory() || stat.isSymbolicLink() ||
        stat.uid !== process.getuid() || (stat.mode & 0o777) !== 0o700) unavailable();
    return file;
  };
  directory("");
  const readBytes = (relative, limit = 65536) => {
    if (!Number.isSafeInteger(limit) || limit < 1 || limit > 512 * 1024) unavailable();
    if (path.isAbsolute(relative) || relative.split(path.sep).includes("..")) unavailable();
    directory(path.dirname(relative));
    const fd = fs.openSync(path.join(home, relative), fs.constants.O_RDONLY | fs.constants.O_NOFOLLOW);
    try {
      const stat = fs.fstatSync(fd);
      if (!stat.isFile() || stat.uid !== process.getuid() || stat.nlink !== 1 ||
          (stat.mode & 0o777) !== 0o600 || stat.size > limit) unavailable();
      const bytes = fs.readFileSync(fd);
      if (bytes.byteLength > limit) unavailable();
      return bytes;
    } finally {fs.closeSync(fd);}
  };
  const read = (relative, json = true) => {
    const raw = new TextDecoder("utf-8", {fatal: true}).decode(readBytes(relative));
    if (!json) return raw.trim();
    const value = JSON.parse(raw);
    // One compact record rejects duplicate keys and ambiguous encodings.
    if (raw.trim() !== JSON.stringify(value)) unavailable();
    return value;
  };
  const create = (relative, value) => {
    const dir = path.dirname(relative);
    try {fs.mkdirSync(path.join(home, dir), {mode: 0o700});} catch (e) {
      if (e.code !== "EEXIST") throw e;
    }
    directory(dir);
    const fd = fs.openSync(path.join(home, relative), fs.constants.O_WRONLY |
      fs.constants.O_CREAT | fs.constants.O_EXCL | fs.constants.O_NOFOLLOW, 0o600);
    try {fs.writeFileSync(fd, JSON.stringify(value) + "\n"); fs.fsyncSync(fd);}
    finally {fs.closeSync(fd);}
  };
  return {read, readBytes, create};
}

function liveSdk(profile, beforeDispatch) {
  if (["FIREBASE_AUTH_EMULATOR_HOST", "FIRESTORE_EMULATOR_HOST",
    "FIREBASE_STORAGE_EMULATOR_HOST", "STORAGE_EMULATOR_HOST"].some((key) =>
    Object.hasOwn(process.env, key))) unavailable();
  const {initializeApp} = require("firebase-admin/app");
  const {getAuth} = require("firebase-admin/auth");
  const {getFirestore} = require("firebase-admin/firestore");
  const {SecretManagerServiceClient} = require("@google-cloud/secret-manager");
  const {createCatchGoogleFirebaseLookupTransport} = require("../../lib/catchMessaging/whatsappFirebaseAuthority.js");
  const app = initializeApp({projectId: profile.scope.projectId},
    "catch-operator-" + randomBytes(16).toString("hex"));
  const sdkAuth = getAuth(app);
  // Admin SDK mutation HTTP retries are unsafe after an unknown committed
  // response. Keep public SDK reads/verification, replace only this setter.
  const auth = {app: sdkAuth.app,
    getUser: (...args) => sdkAuth.getUser(...args),
    listUsers: (...args) => sdkAuth.listUsers(...args),
    verifyIdToken: (...args) => sdkAuth.verifyIdToken(...args),
    setCustomUserClaims: createSingleAttemptClaimsSetter(profile.scope, {beforeDispatch})};
  return {auth, db: getFirestore(app),
    transport: createCatchGoogleFirebaseLookupTransport(),
    secrets: new SecretManagerServiceClient()};
}

function createSingleAttemptClaimsSetter(scope, {credentialFactory, dispatch = fetch,
  beforeDispatch, deadline = () => AbortSignal.timeout(10000)} = {}) {
  const pinned = structuredClone(scope);
  let google;
  const credential = () => google ??= credentialFactory ? credentialFactory() :
    new (require("google-auth-library").GoogleAuth)({scopes: ["https://www.googleapis.com/auth/identitytoolkit"]});
  return async (uid, input) => {
    const claims = structuredClone(input);
    if (uid !== pinned.actorUid || !validId(uid) ||
        !/^[a-z][a-z0-9-]{4,28}[a-z0-9]$/u.test(pinned.projectId) ||
        !claims || Object.getPrototypeOf(claims) !== Object.prototype ||
        Buffer.byteLength(JSON.stringify(claims)) > 1000) unavailable();
    const url = `https://identitytoolkit.googleapis.com/v1/projects/${pinned.projectId}/accounts:update?fields=localId`;
    const body = JSON.stringify({localId: uid, customAttributes: JSON.stringify(claims)});
    if (typeof beforeDispatch !== "function") unavailable();
    const signal = deadline();
    const bounded = async (promise) => {
      signal.throwIfAborted();
      let listener;
      const aborted = new Promise((_, reject) => {
        listener = () => reject(new Error("Operator credential deadline elapsed."));
        signal.addEventListener("abort", listener, {once: true});
      });
      try {return await Promise.race([promise, aborted]);}
      finally {signal.removeEventListener("abort", listener);}
    };
    const client = credential();
    if (await bounded(client.getProjectId()) !== pinned.projectId) unavailable();
    const headers = new Headers(await bounded(client.getRequestHeaders(url)));
    headers.set("Content-Type", "application/json");
    await bounded(beforeDispatch()); // Reread exact approval after credential waits.
    signal.throwIfAborted();
    // Exactly one mutation HTTP request. No Google RequestClient or SDK retry.
    const response = await dispatch(url, {method: "POST", headers, body,
      redirect: "error", signal});
    if (!response.ok || (await response.json()).localId !== uid) unavailable();
  };
}

// Only metadata methods are available to this producer. A missing supported
// direct binding is unproven access, not evidence that an IAM grant is missing.
async function credentialMetadata(profile, secrets) {
  const name = profile.credentialVersionName;
  const resource = name.slice(0, name.lastIndexOf("/versions/"));
  const [[version], [policy]] = await Promise.all([
    secrets.getSecretVersion({name}, {timeout: 10000, retry: null}),
    secrets.getIamPolicy({resource, options: {requestedPolicyVersion: 3}},
      {timeout: 10000, retry: null}),
  ]);
  const bindings = (policy.bindings ?? []).filter((b) =>
    b.role === "roles/secretmanager.secretAccessor" && !b.condition &&
    Array.isArray(b.members) && b.members.includes(profile.runtimePrincipal));
  return {resourceSha256: sha(name), enabled: version.name === name &&
    (version.state === "ENABLED" || version.state === 1),
  runtimeAccessor: bindings.length === 1};
}

function createOperatorRuntime({home = process.env.CATCH_WHATSAPP_OPERATOR_HOME,
  now = Date.now, sdkFactory = liveSdk, identity = executionIdentity} = {}) {
  const privateFiles = protectedHome(home);
  const profile = structuredClone(privateFiles.read("profile.json"));
  const binding = identity(); // Check approved bytes before requiring helpers.
  if (profile.sourceSha !== binding.sourceSha ||
      profile.executionSha256 !== binding.executionSha256) unavailable();
  const helper = require("../../lib/catchMessaging/whatsappOperatorSetup.js");
  const {setupExact, setupHash, validateSetupPlan, validateSetupRequest,
    validateSetupScope} = helper;
  setupExact(profile, ["schemaVersion", "scope", "sourceSha", "executionSha256",
    "credentialVersionName", "runtimePrincipal"]);
  validateSetupScope(profile.scope);
  const secretPrefix = `projects/${profile.scope.projectId}/secrets/CATCH_WHATSAPP_ACCESS_TOKEN/versions/`;
  if (profile.schemaVersion !== 1 || !/^[a-f0-9]{40}$/u.test(profile.sourceSha) ||
      !/^[a-f0-9]{64}$/u.test(profile.executionSha256) ||
      !profile.credentialVersionName.startsWith(secretPrefix) ||
      !/^[1-9][0-9]{0,19}$/u.test(profile.credentialVersionName.slice(secretPrefix.length)) ||
      sha(profile.credentialVersionName) !== profile.scope.credentialVersionSha256 ||
      !/^serviceAccount:[A-Za-z0-9._-]+@(?:[a-z0-9.-]+\.iam\.gserviceaccount\.com|developer\.gserviceaccount\.com)$/u.test(profile.runtimePrincipal)) unavailable();
  const assertBinding = () => {
    if (setupHash(identity()) !== setupHash(binding)) unavailable();
  };
  let sdk;
  let mutationBinding;
  let mutationAdmission;
  const admitMutation = async () => {
    if (!mutationAdmission) unavailable();
    await mutationAdmission();
  };
  const clients = () => sdk ??= sdkFactory(structuredClone(profile), admitMutation);
  const token = async () => {
    const value = privateFiles.read("actor-id-token.txt", false);
    if (!/^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/u.test(value)) unavailable();
    return value;
  };
  const load = (id) => {
    if (!validId(id)) unavailable();
    const plan = structuredClone(privateFiles.read(`reviewed-plans/${id}.json`));
    const request = validateSetupRequest(privateFiles.read(`requests/${id}.json`));
    validateSetupPlan(plan);
    if (plan.planId !== id || request.planId !== id || request.planSha256 !== setupHash(plan) ||
        setupHash(plan.scope) !== setupHash(profile.scope) || plan.sourceSha !== profile.sourceSha) unavailable();
    return {plan, request};
  };
  const authorize = (saved, action = "bootstrap-apply") => {
    let admittedReadiness;
    return async (digest) => {
      const {plan, request} = saved;
      assertBinding();
      const bootstrap = action === "bootstrap-apply";
      const approval = privateFiles.read(`approvals/${plan.planId}${bootstrap ? "" : "." + action}.json`);
      setupExact(approval, ["schemaVersion", "action", "planSha256", "scopeSha256",
        "sourceSha", "executionSha256", "replaySha256", "expiresAtMillis",
        ...(!bootstrap ? ["readinessSha256", "auditBindingSha256"] : []),
        ...(action === "readiness-apply" ? ["publicationAuditSha256"] : [])]);
      if (approval.schemaVersion !== 1 || approval.action !== action ||
          digest !== setupHash(plan) || approval.planSha256 !== digest ||
          approval.scopeSha256 !== setupHash(profile.scope) ||
          approval.sourceSha !== binding.sourceSha ||
          approval.executionSha256 !== binding.executionSha256 ||
          approval.replaySha256 !== setupHash(request.replayKey) ||
          !Number.isSafeInteger(approval.expiresAtMillis) || now() >= approval.expiresAtMillis ||
          (bootstrap && (approval.expiresAtMillis > plan.expiresAtMillis || now() >= plan.expiresAtMillis)) ||
          setupHash(load(plan.planId)) !== setupHash({plan, request})) unavailable();
      if (!bootstrap) {
        const evidence = readinessFor(saved).authorizationBinding(action);
        if (approval.readinessSha256 !== evidence.readinessSha256 ||
            approval.auditBindingSha256 !== evidence.auditBindingSha256 ||
            approval.expiresAtMillis > evidence.expiresAtMillis ||
            (action === "readiness-apply" &&
              approval.publicationAuditSha256 !== evidence.publicationAuditSha256)) unavailable();
        const exactBinding = setupHash({approval, evidence});
        if (admittedReadiness && admittedReadiness !== exactBinding) unavailable();
        admittedReadiness ??= exactBinding;
      }
    };
  };
  const sourcesFor = (saved, policy) => {
    const {createProtectedOperatorSetupSources} = require("../../lib/catchMessaging/whatsappOperatorSetupSources.js");
    const {auth: sdkAuth, db, transport, secrets} = clients();
    const auth = {app: sdkAuth.app, tenantId: sdkAuth.tenantId,
      getUser: (...args) => sdkAuth.getUser(...args),
      listUsers: (...args) => sdkAuth.listUsers(...args),
      verifyIdToken: (...args) => sdkAuth.verifyIdToken(...args),
      setCustomUserClaims: async (...args) => {
        await admitMutation();
        return sdkAuth.setCustomUserClaims(...args);
      }};
    return createProtectedOperatorSetupSources({scope: profile.scope,
      sourceSha: profile.sourceSha, auth, db, transport, now,
      actorIdToken: token, reviewedPlans: new Map(saved ? [[saved.plan.planId, saved.plan]] : []),
      ...(policy ? {authorizeApply: policy} : {}),
      credentialMetadata: () => credentialMetadata(profile, secrets)});
  };
  const servicesFor = (saved, policy, adaptDatabase = db => db) => {
    const sources = sourcesFor(saved, policy);
    const {CatchAppAuthorityStore, withCatchFreshAuthContext} = require("../../lib/catchMessaging/whatsappAppAuthorityStore.js");
    const {createCatchFirebaseAuthority} = require("../../lib/catchMessaging/whatsappFirebaseAuthority.js");
    const {FirestoreOperatorSetupJournal} = require("../../lib/catchMessaging/whatsappOperatorSetupFirestore.js");
    const {auth, db: originalDb, transport} = clients();
    const db = adaptDatabase(originalDb);
    const firebase = createCatchFirebaseAuthority({projectId: profile.scope.projectId, auth, transport, now});
    const store = new CatchAppAuthorityStore(db, {projectId: profile.scope.projectId,
      now, firebase, withAuditedAuthFence: async () => unavailable(),
      withFreshAuthContext: (who, callback) => withCatchFreshAuthContext(firebase, who, callback, now)});
    const journal = new FirestoreOperatorSetupJournal(db, store, sources, token);
    return {sources, store, journal, engine: new helper.CatchWhatsappOperatorSetup(sources, journal)};
  };
  const readinessFor = saved => require("./catch-whatsapp-operator-readiness.cjs")
    .createProtectedReadinessRuntime({privateFiles, binding, now,
      assertBinding, saved, load, servicesFor, token});
  const readinessAction = async (id, action, method) => {
    const saved = load(id);
    const policy = authorize(saved, action);
    await policy(saved.request.planSha256); // No SDK/ADC before exact action approval.
    return readinessFor(saved)[method](policy);
  };
  return {
    readinessPlan: id => readinessFor(load(id)).plan(),
    readinessIngress: id => readinessAction(id, "readiness-ingress", "ingress"),
    readinessPublish: id => readinessAction(id, "readiness-publish", "publish"),
    readinessReview: id => readinessFor(load(id)).review(),
    readinessApply: id => readinessAction(id, "readiness-apply", "apply"),
    async plan() {
      assertBinding();
      const sources = sourcesFor();
      const snapshot = await sources.snapshot();
      const plan = helper.planOperatorSetup(profile.scope, snapshot, {
        planId: randomBytes(16).toString("hex"), sourceSha: profile.sourceSha,
        now: now(), grantNonce: randomBytes(32).toString("hex"),
        createReviewRef: randomBytes(16).toString("hex"),
        revokeReviewRef: randomBytes(16).toString("hex")});
      const request = {planId: plan.planId, planSha256: setupHash(plan),
        replayKey: randomBytes(32).toString("hex")};
      privateFiles.create(`pending-plans/${plan.planId}.json`,
        {plan, executionSha256: binding.executionSha256});
      privateFiles.create(`requests/${plan.planId}.json`, request);
      return {kind: "catch-operator-plan", planId: plan.planId,
        planSha256: request.planSha256, scopeSha256: setupHash(plan.scope),
        ...binding, expiresAtMillis: plan.expiresAtMillis, reviewed: false};
    },
    async apply(id) {
      const saved = load(id);
      const policy = authorize(saved);
      await policy(saved.request.planSha256); // Before SDK/ADC or any live read.
      const savedBinding = setupHash(saved);
      if (mutationBinding && mutationBinding !== savedBinding) unavailable();
      if (!mutationBinding) {
        // This instance's final admission cannot be replaced by another apply
        // while its existing writer is waiting for credentials or a response.
        mutationBinding = savedBinding;
        mutationAdmission = () => policy(saved.request.planSha256);
      }
      const result = await servicesFor(saved, policy).engine.apply(saved.request);
      return {kind: "catch-operator-apply", planSha256: saved.request.planSha256, state: result.state};
    },
    async reconcile(id) {
      const {plan, request} = load(id); // Saved plans remain readable after expiry.
      assertBinding();
      const sources = sourcesFor({plan, request});
      const {db} = clients();
      const {readOperatorSetupOperation, OPERATOR_SETUP_OPERATIONS, OPERATOR_SETUP_AUDITS} = require("../../lib/catchMessaging/whatsappOperatorSetupFirestore.js");
      const {validateCatchWhatsappOperatorSetupAuditDocument: validAudit} = require("../../lib/shared/generated/validators/catchWhatsappOperatorSetupAuditDocument.js");
      const {readCatchAppAuthority, authorizeCatchAppCapability} = require("../../lib/catchMessaging/whatsappAppAuthority.js");
      const observed = await db.runTransaction(async (tx) => {
        const ref = (collection, name) => db.collection(collection).doc(name);
        const slot = await tx.get(ref(OPERATOR_SETUP_OPERATIONS, profile.scope.projectId));
        if (!slot.exists) return null;
        const operation = readOperatorSetupOperation(slot.data(), plan, request);
        const audits = await Promise.all(Array.from({length: operation.revision}, (_, i) =>
          tx.get(ref(OPERATOR_SETUP_AUDITS, `${profile.scope.projectId}_${i + 1}`))));
        let previous = null;
        for (let i = 0; i < audits.length; i++) {
          const audit = audits[i].data();
          const after = {...operation, phase: phases[i], revision: i + 1, updatedAtMillis: audit?.atMillis};
          if (!validAudit(audit) || setupHash(audit) !== setupHash({schemaVersion: 1,
            receiptKind: "phase", auditId: `${profile.scope.projectId}_${i + 1}`,
            operationId: operation.operationId, projectId: operation.projectId,
            actorUid: operation.actorUid, planSha256: operation.planSha256,
            scopeSha256: operation.scopeSha256, fromPhase: i ? phases[i - 1] : null,
            toPhase: phases[i], revision: i + 1, atMillis: after.updatedAtMillis,
            beforeSha256: previous ? setupHash(previous) : null,
            afterSha256: setupHash(after), effectSha256: audit.effectSha256}) ||
            after.updatedAtMillis < (previous?.updatedAtMillis ?? plan.createdAtMillis) ||
            after.updatedAtMillis > now()) unavailable();
          previous = after;
        }
        if (setupHash(previous) !== setupHash(operation)) unavailable();
        const [dispatch, root, recipient] = await Promise.all([
          tx.get(ref(OPERATOR_SETUP_AUDITS, `${profile.scope.projectId}_auth_dispatch`)),
          tx.get(ref("catchWhatsappAppAuthorities", profile.scope.actorUid)),
          tx.get(ref("catchWhatsappAppAuthorities", profile.scope.recipientUid))]);
        if (dispatch.exists) {
          const audit = dispatch.data();
          const intent = {...operation, phase: "auth-intent", revision: 2, updatedAtMillis: audits[1]?.data()?.atMillis};
          if (!validAudit(audit) || operation.revision < 2 || setupHash(audit) !== setupHash({
            schemaVersion: 1, receiptKind: "auth-dispatch-intent", auditId: `${profile.scope.projectId}_auth_dispatch`,
            operationId: operation.operationId, projectId: operation.projectId, actorUid: operation.actorUid,
            planSha256: operation.planSha256, scopeSha256: operation.scopeSha256,
            fromPhase: "auth-intent", toPhase: "auth-intent", revision: 2,
            atMillis: audit.atMillis, beforeSha256: setupHash(intent), afterSha256: setupHash(intent),
            effectSha256: plan.desiredClaimsSha256}) || audit.atMillis < intent.updatedAtMillis ||
            audit.atMillis > now()) unavailable();
        } else if (operation.revision >= 3) unavailable();
        // Validate without normalizing array order: effect receipts hash the
        // exact committed record, not the reader's sorted capability projection.
        if (root.exists) readCatchAppAuthority(root.data());
        if (recipient.exists) readCatchAppAuthority(recipient.data());
        return {operation, audits: audits.map((a) => a.data()), dispatch: dispatch.exists,
          root: root.exists ? root.data() : null,
          recipient: recipient.exists ? recipient.data() : null};
      }, {readOnly: true});
      // No snapshot(), metadata, engine or journal write. Recipient observation
      // below is optional and its absence is reported rather than blocking reads.
      const actor = await sources.actor();
      const claims = setupHash(actor.claims);
      const actorMatches = actor.auth.creationTimeMillis === plan.actorCreationTimeMillis &&
        actor.auth.tokensValidAfterMillis === plan.actorTokensValidAfterMillis &&
        actor.googleSubjectSha256 === plan.googleSubjectSha256 &&
        actor.auth.disabled === false &&
        actor.auth.relevantRoles.includes("adminOwner") === (actor.claims.adminOwner === true) &&
        actor.auth.relevantRoles.includes("support") === (actor.claims.support === true);
      const claimsState = claims === plan.desiredClaimsSha256 ? "desired-observed" :
        claims === plan.beforeClaimsSha256 ? "before-observed" : "drift-observed";
      if (!observed) return {kind: "catch-operator-reconciliation",
        state: actorMatches && claimsState === "before-observed" ? "not-started" : "reconciliation-required",
        actorMatches, claimsState, planExpired: now() >= plan.expiresAtMillis};
      const {operation, audits, root, recipient} = observed;
      let effectsMatch = true;
      if (operation.revision >= 4) {
        if (operation.phase === "seeded") effectsMatch = setupHash([root, recipient]) === audits[3].effectSha256;
        else effectsMatch = !!root && setupHash(root) === audits[4]?.effectSha256 &&
          root.projectId === plan.scope.projectId && root.uid === plan.scope.actorUid &&
          root.state === "active" && root.revision === 2 && root.grantedBy === null &&
          root.incarnation === setupHash(["catch.firebase-creation/v1", plan.scope.projectId,
            plan.scope.actorUid, plan.actorCreationTimeMillis]);
      }
      if (operation.revision >= 7 && operation.revision <= 8) effectsMatch &&= !!recipient && setupHash(recipient) === audits[6].effectSha256;
      if (operation.revision >= 9 && operation.revision < 14) effectsMatch &&= !!recipient && setupHash(recipient) === audits[8].effectSha256;
      let actorAuthorityState = "not-applicable";
      if (operation.revision >= 5) {
        try {
          for (const capability of ["review", "reply"]) authorizeCatchAppCapability({record: root,
            auth: actor.auth, session: actor.session}, capability, now(),
          {projectId: plan.scope.projectId, uid: plan.scope.actorUid});
          actorAuthorityState = "current-observed";
        } catch {
          actorAuthorityState = actorMatches && root && actor.session.authTimeSeconds < root.authNotBeforeSeconds ?
            "fresh-sign-in-required" : "drift-observed";
        }
      }
      let recipientAuthState = "not-observed";
      if (operation.revision >= 4 && operation.revision < 14) {
        const {createCatchFirebaseAuthority} = require("../../lib/catchMessaging/whatsappFirebaseAuthority.js");
        const {auth, transport} = clients();
        try {
          const current = await createCatchFirebaseAuthority({projectId: profile.scope.projectId,
            auth, transport, now}).observe(profile.scope.recipientUid);
          recipientAuthState = current.disabled === false && current.endpointHash === plan.scope.endpointHash &&
            current.creationTimeMillis === plan.recipientCreationTimeMillis &&
            current.tokensValidAfterMillis === plan.recipientTokensValidAfterMillis ? "current-observed" : "drift-observed";
        } catch {recipientAuthState = "unavailable";}
      }
      let state = "phase-observed";
      if (!actorMatches || !effectsMatch || claimsState === "drift-observed" ||
          actorAuthorityState === "drift-observed" ||
          ["unavailable", "drift-observed"].includes(recipientAuthState) ||
          (operation.revision >= 3 && claimsState !== "desired-observed") || operation.phase.endsWith("-intent")) state = "reconciliation-required";
      else if (actorAuthorityState === "fresh-sign-in-required" ||
          (operation.phase === "seeded" && actor.session.authTimeSeconds < root.authNotBeforeSeconds)) state = "fresh-sign-in-required";
      else if (operation.phase === "complete") state = "bootstrap-complete";
      let readinessVerified = false;
      if (operation.phase === "ready") {
        try {readinessVerified = await readinessFor({plan, request}).observe();} catch { /* Fail closed on missing or changed evidence. */ }
        state = readinessVerified && state !== "reconciliation-required" ? "readiness-ready-observed" : "readiness-unavailable";
      }
      return {kind: "catch-operator-reconciliation", state, phase: operation.phase,
        revision: operation.revision, claimsState, actorMatches, actorAuthorityState, effectsMatch,
        authDispatchConsumed: observed.dispatch, planExpired: now() >= plan.expiresAtMillis,
        recipientPresent: recipient !== null, recipientAuthState, readinessVerified};
    },
  };
}

module.exports = {createOperatorRuntime, executionIdentity, protectedHome, credentialMetadata,
  createSingleAttemptClaimsSetter};
