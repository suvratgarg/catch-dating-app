import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import {fileURLToPath} from "node:url";
import {validateProvenanceManifest} from "./delivery_core.mjs";
import {validateFunctionsDeployment, validateFunctionIdentity, readMaterializedParamsSha256,
  captureFunctionIdentities} from "./firebase_functions_checkpoint.mjs";
import {gcloudIndexList} from "../firebase/wait_firestore_indexes_ready.mjs";

// Fixed, executable release admission. Never a general target selector or cursor.
export const RELEASE = Object.freeze({
 sourceSha: "24eab314944b20ce3035756bb5d08cfbf3007f4d",
 baseSha: "c450178cc3802b8d9d2862624bcd06903ffb1361",
 sourceCiRunId: "38895481991", sourceCiRunAttempt: "1", artifactId: 12044213158,
 artifactSha256: "980192cec7c7caf6423046b6559d34c783d209ece227d27b6447125a75121240",
 packageSha256: "b34f8fb8eb30a5010d39506d4d397838e7e16e866e8c2f00fd6a6e622e0bc97d",
});
export const TARGETS = Object.freeze([
  "functions:acceptEventWaitlistOffer",
  "functions:cancelEventSignUp",
  "functions:completeEventSuccessFirstHelloMission",
  "functions:createEventWaitlistOffers",
  "functions:decideEventJoinRequest",
  "functions:declineEventWaitlistOffer",
  "functions:joinEventWaitlist",
  "functions:leaveEventWaitlist",
  "functions:markEventAttendance",
  "functions:razorpayWebhook",
  "functions:selfCheckInAttendance",
  "functions:signUpForFreeEvent",
  "functions:stripeWebhook",
  "functions:verifyRazorpayPayment"
]);
const PROJECTS = Object.freeze({dev: "catchdates-dev", prod: "catch-dating-app-64e51"});
// Exact observed predecessors, including the separately approved webhook secret rotation.
export const PREDECESSORS = Object.freeze({
  "dev": {
    "acceptEventWaitlistOffer": {
      "revision": "accepteventwaitlistoffer-00130-vak",
      "build": "projects/619661127800/locations/asia-south1/builds/458b26dd-5eae-4679-a58c-a756a1bf4566",
      "source": {
        "bucket": "gcf-v2-sources-619661127800-asia-south1",
        "object": "acceptEventWaitlistOffer/function-source.zip",
        "generation": "1791122965689695"
      }
    },
    "cancelEventSignUp": {
      "revision": "canceleventsignup-00149-rad",
      "build": "projects/619661127800/locations/asia-south1/builds/84d2eaab-23a0-4bd2-a056-e299bf9e6ab3",
      "source": {
        "bucket": "gcf-v2-sources-619661127800-asia-south1",
        "object": "cancelEventSignUp/function-source.zip",
        "generation": "1791374191516371"
      }
    },
    "completeEventSuccessFirstHelloMission": {
      "revision": "completeeventsuccessfirsthellomission-00135-cam",
      "build": "projects/619661127800/locations/asia-south1/builds/5a8b9c2c-6320-4d51-ad0e-a2112450380a",
      "source": {
        "bucket": "gcf-v2-sources-619661127800-asia-south1",
        "object": "completeEventSuccessFirstHelloMission/function-source.zip",
        "generation": "1791124793296251"
      }
    },
    "createEventWaitlistOffers": {
      "revision": "createeventwaitlistoffers-00127-dux",
      "build": "projects/619661127800/locations/asia-south1/builds/bd3b4287-c338-4145-b0de-05c33c20c60f",
      "source": {
        "bucket": "gcf-v2-sources-619661127800-asia-south1",
        "object": "createEventWaitlistOffers/function-source.zip",
        "generation": "1791124994144918"
      }
    },
    "decideEventJoinRequest": {
      "revision": "decideeventjoinrequest-00131-fex",
      "build": "projects/619661127800/locations/asia-south1/builds/90361e79-8aa4-48a6-ba46-a123a90dbb1b",
      "source": {
        "bucket": "gcf-v2-sources-619661127800-asia-south1",
        "object": "decideEventJoinRequest/function-source.zip",
        "generation": "1791125303415841"
      }
    },
    "declineEventWaitlistOffer": {
      "revision": "declineeventwaitlistoffer-00127-cug",
      "build": "projects/619661127800/locations/asia-south1/builds/90361e79-8aa4-48a6-ba46-a123a90dbb1b",
      "source": {
        "bucket": "gcf-v2-sources-619661127800-asia-south1",
        "object": "declineEventWaitlistOffer/function-source.zip",
        "generation": "1791125303001483"
      }
    },
    "joinEventWaitlist": {
      "revision": "joineventwaitlist-00145-jet",
      "build": "projects/619661127800/locations/asia-south1/builds/69578b17-af2e-49e4-a06d-e26eb87eadf6",
      "source": {
        "bucket": "gcf-v2-sources-619661127800-asia-south1",
        "object": "joinEventWaitlist/function-source.zip",
        "generation": "1791126585705035"
      }
    },
    "leaveEventWaitlist": {
      "revision": "leaveeventwaitlist-00145-mij",
      "build": "projects/619661127800/locations/asia-south1/builds/74024410-7a26-4f0c-a3d7-edfc6402a0ac",
      "source": {
        "bucket": "gcf-v2-sources-619661127800-asia-south1",
        "object": "leaveEventWaitlist/function-source.zip",
        "generation": "1791126701852658"
      }
    },
    "markEventAttendance": {
      "revision": "markeventattendance-00146-nuf",
      "build": "projects/619661127800/locations/asia-south1/builds/c763bfa6-0dca-45a9-878d-c66f91273b30",
      "source": {
        "bucket": "gcf-v2-sources-619661127800-asia-south1",
        "object": "markEventAttendance/function-source.zip",
        "generation": "1791127356052658"
      }
    },
    "razorpayWebhook": {
      "revision": "razorpaywebhook-00119-bil",
      "build": "projects/619661127800/locations/asia-south1/builds/84d2eaab-23a0-4bd2-a056-e299bf9e6ab3",
      "source": {
        "bucket": "gcf-v2-sources-619661127800-asia-south1",
        "object": "razorpayWebhook/function-source.zip",
        "generation": "1791374191776495"
      }
    },
    "selfCheckInAttendance": {
      "revision": "selfcheckinattendance-00151-xik",
      "build": "projects/619661127800/locations/asia-south1/builds/f1359b6d-a6bb-4cb8-8d76-ee768f1fee08",
      "source": {
        "bucket": "gcf-v2-sources-619661127800-asia-south1",
        "object": "selfCheckInAttendance/function-source.zip",
        "generation": "1791128930702425"
      }
    },
    "signUpForFreeEvent": {
      "revision": "signupforfreeevent-00145-med",
      "build": "projects/619661127800/locations/asia-south1/builds/de29e0a3-dae6-430b-a948-a7519e64b8fa",
      "source": {
        "bucket": "gcf-v2-sources-619661127800-asia-south1",
        "object": "signUpForFreeEvent/function-source.zip",
        "generation": "1791129373261411"
      }
    },
    "stripeWebhook": {
      "revision": "stripewebhook-00125-kuv",
      "build": "projects/619661127800/locations/asia-south1/builds/de29e0a3-dae6-430b-a948-a7519e64b8fa",
      "source": {
        "bucket": "gcf-v2-sources-619661127800-asia-south1",
        "object": "stripeWebhook/function-source.zip",
        "generation": "1791129312580797"
      }
    },
    "verifyRazorpayPayment": {
      "revision": "verifyrazorpaypayment-00154-vun",
      "build": "projects/619661127800/locations/asia-south1/builds/84d2eaab-23a0-4bd2-a056-e299bf9e6ab3",
      "source": {
        "bucket": "gcf-v2-sources-619661127800-asia-south1",
        "object": "verifyRazorpayPayment/function-source.zip",
        "generation": "1791374191734003"
      }
    }
  },
  "prod": {
    "acceptEventWaitlistOffer": {
      "revision": "accepteventwaitlistoffer-00043-vaf",
      "build": "projects/574779808785/locations/asia-south1/builds/b1ae9069-2f65-437e-a4c4-686174403bca",
      "source": {
        "bucket": "gcf-v2-sources-574779808785-asia-south1",
        "object": "acceptEventWaitlistOffer/function-source.zip",
        "generation": "1791132129962251"
      }
    },
    "cancelEventSignUp": {
      "revision": "canceleventsignup-00052-qig",
      "build": "projects/574779808785/locations/asia-south1/builds/59b7da18-f517-405a-995b-da6231dd8c36",
      "source": {
        "bucket": "gcf-v2-sources-574779808785-asia-south1",
        "object": "cancelEventSignUp/function-source.zip",
        "generation": "1791375436517397"
      }
    },
    "completeEventSuccessFirstHelloMission": {
      "revision": "completeeventsuccessfirsthellomission-00043-pew",
      "build": "projects/574779808785/locations/asia-south1/builds/6eca2a3a-5421-4ab0-adfb-316257e09a7b",
      "source": {
        "bucket": "gcf-v2-sources-574779808785-asia-south1",
        "object": "completeEventSuccessFirstHelloMission/function-source.zip",
        "generation": "1791134049090678"
      }
    },
    "createEventWaitlistOffers": {
      "revision": "createeventwaitlistoffers-00042-wiq",
      "build": "projects/574779808785/locations/asia-south1/builds/1c03ec5f-2d9d-416b-9a5c-7099c5a0eba0",
      "source": {
        "bucket": "gcf-v2-sources-574779808785-asia-south1",
        "object": "createEventWaitlistOffers/function-source.zip",
        "generation": "1791134245158841"
      }
    },
    "decideEventJoinRequest": {
      "revision": "decideeventjoinrequest-00045-gul",
      "build": "projects/574779808785/locations/asia-south1/builds/7b4eef49-ea03-481d-897e-17426e21a57d",
      "source": {
        "bucket": "gcf-v2-sources-574779808785-asia-south1",
        "object": "decideEventJoinRequest/function-source.zip",
        "generation": "1791134566454182"
      }
    },
    "declineEventWaitlistOffer": {
      "revision": "declineeventwaitlistoffer-00042-vos",
      "build": "projects/574779808785/locations/asia-south1/builds/7b4eef49-ea03-481d-897e-17426e21a57d",
      "source": {
        "bucket": "gcf-v2-sources-574779808785-asia-south1",
        "object": "declineEventWaitlistOffer/function-source.zip",
        "generation": "1791134566242878"
      }
    },
    "joinEventWaitlist": {
      "revision": "joineventwaitlist-00050-puf",
      "build": "projects/574779808785/locations/asia-south1/builds/cef892a2-8511-47ac-9da3-671d9f5e7722",
      "source": {
        "bucket": "gcf-v2-sources-574779808785-asia-south1",
        "object": "joinEventWaitlist/function-source.zip",
        "generation": "1791135941372340"
      }
    },
    "leaveEventWaitlist": {
      "revision": "leaveeventwaitlist-00049-miw",
      "build": "projects/574779808785/locations/asia-south1/builds/e46de234-568f-4e16-bb48-40b670c83ac2",
      "source": {
        "bucket": "gcf-v2-sources-574779808785-asia-south1",
        "object": "leaveEventWaitlist/function-source.zip",
        "generation": "1791136065047503"
      }
    },
    "markEventAttendance": {
      "revision": "markeventattendance-00049-siz",
      "build": "projects/574779808785/locations/asia-south1/builds/d4c1fa53-0d35-4665-81bf-0ac6b3cc90bc",
      "source": {
        "bucket": "gcf-v2-sources-574779808785-asia-south1",
        "object": "markEventAttendance/function-source.zip",
        "generation": "1791136762751197"
      }
    },
    "razorpayWebhook": {
      "revision": "razorpaywebhook-00046-mon",
      "build": "projects/574779808785/locations/asia-south1/builds/78ce856a-a9b6-47f9-afb5-d28884b8baa3",
      "source": {
        "bucket": "gcf-v2-sources-574779808785-asia-south1",
        "object": "razorpayWebhook/function-source.zip",
        "generation": "1792151356020431"
      }
    },
    "selfCheckInAttendance": {
      "revision": "selfcheckinattendance-00054-ged",
      "build": "projects/574779808785/locations/asia-south1/builds/ca760e70-5a37-43d2-9b2b-a2db6306cbf2",
      "source": {
        "bucket": "gcf-v2-sources-574779808785-asia-south1",
        "object": "selfCheckInAttendance/function-source.zip",
        "generation": "1791138465718028"
      }
    },
    "signUpForFreeEvent": {
      "revision": "signupforfreeevent-00050-bux",
      "build": "projects/574779808785/locations/asia-south1/builds/e5052f63-f2d5-402a-8c36-83272931a0d5",
      "source": {
        "bucket": "gcf-v2-sources-574779808785-asia-south1",
        "object": "signUpForFreeEvent/function-source.zip",
        "generation": "1791138906819983"
      }
    },
    "stripeWebhook": {
      "revision": "stripewebhook-00043-luh",
      "build": "projects/574779808785/locations/asia-south1/builds/e5052f63-f2d5-402a-8c36-83272931a0d5",
      "source": {
        "bucket": "gcf-v2-sources-574779808785-asia-south1",
        "object": "stripeWebhook/function-source.zip",
        "generation": "1791138844485945"
      }
    },
    "verifyRazorpayPayment": {
      "revision": "verifyrazorpaypayment-00062-xid",
      "build": "projects/574779808785/locations/asia-south1/builds/59b7da18-f517-405a-995b-da6231dd8c36",
      "source": {
        "bucket": "gcf-v2-sources-574779808785-asia-south1",
        "object": "verifyRazorpayPayment/function-source.zip",
        "generation": "1791375437547474"
      }
    }
  }
});
const PROVIDER_PARAMS = ["RAZORPAY_PUBLIC_KEY_ID","RAZORPAY_PLATFORM_PAYMENT_CONFIG_VERSION","EVENT_VENUE_SESSION_TTL_SECONDS","EVENT_VENUE_SESSION_REFRESH_SECONDS","STRIPE_APPLICATION_FEE_BPS"];
const hashPattern = /^[0-9a-f]{64}$/;
const canonical = (value) => Array.isArray(value) ? value.map(canonical) :
 value && typeof value === "object" ? Object.fromEntries(Object.keys(value).sort().map(k=>[k,canonical(value[k])])) : value;
const bytesDigest = value => createHash("sha256").update(value).digest("hex");
const digest = value => bytesDigest(JSON.stringify(canonical(value)));
function exactKeys(value, keys) {assert.ok(value && typeof value === "object"); assert.deepEqual(Object.keys(value).sort(), keys.slice().sort());}
function projectFor(environment) {assert.ok(Object.hasOwn(PROJECTS,environment));return PROJECTS[environment];}
const scopeFor = environment => `firebase:${environment}:${projectFor(environment)}`;
const targetName = (environment,target) => `projects/${projectFor(environment)}/locations/asia-south1/functions/${target.slice(10)}`;
export function verifyManifest(manifest) {
 validateProvenanceManifest(manifest);
 for(const k of ["sourceSha","sourceCiRunId","sourceCiRunAttempt"]) assert.equal(manifest[k],RELEASE[k]);
 assert.equal(manifest.artifact.sha256,RELEASE.packageSha256);
 assert.equal(manifest.artifact.name,"firebase-backend.tar.gz");assert.deepEqual(manifest.stages,["functions"]);
 return manifest;
}
export function prepare({manifest, packagePlan}) {
 verifyManifest(manifest);
 assert.equal(packagePlan.schema,"catch.firebase-delivery-plan/v2");
 for(const k of ["sourceSha","baseSha","sourceCiRunId","sourceCiRunAttempt"]) assert.equal(packagePlan[k],RELEASE[k]);
 assert.deepEqual(packagePlan.stages,["functions"]);assert.deepEqual(packagePlan.deployGroups,["functions"]);
 assert.equal(packagePlan.targets.length,1);const names=packagePlan.targets[0].split(",");
 assert.equal(new Set(names).size,names.length);assert.ok(TARGETS.every(t=>names.includes(t)));
 return {...packagePlan,targets:[TARGETS.join(",")]};
}
export function checkSource(currentSha,cwd=process.cwd()) {
 assert.match(currentSha,/^[0-9a-f]{40}$/);
 const git=args=>{const r=spawnSync("git",args,{cwd,encoding:"utf8",timeout:10000});assert.equal(r.status,0,"Source ancestry unavailable");return r.stdout;};
 git(["merge-base","--is-ancestor",RELEASE.sourceSha,currentSha]);
 // PR622 only adds a Sales action-catalog entry and its test. Neither changes
 // the booking writer; accept exactly these reviewed blobs, never future drift.
 const unrelated = {
  "functions/src/shared/generated/adminActionCatalog.ts":"fea21aa2729bc236db824c77808f1d370b7cacbb",
  "functions/src/admin/sales/contracts.test.ts":"95b003909a40bd1094aea4069ba598545f52f264",
 };
 const changed=git(["diff","--name-only",RELEASE.sourceSha,currentSha,"--","functions","firebase.json",".firebaserc","firestore.rules","firestore.indexes.json","storage.rules"]).trim().split("\n").filter(Boolean);
 for(const file of changed){assert.ok(Object.hasOwn(unrelated,file),"Backend drift requires a new reviewed release");assert.equal(git(["rev-parse",`${currentSha}:${file}`]).trim(),unrelated[file],"Reviewed unrelated source changed");}
 return {sourceSha:RELEASE.sourceSha,currentSha};
}
export function verifyArtifact(artifact) {
 assert.equal(artifact.id,RELEASE.artifactId);assert.equal(artifact.expired,false);
 assert.equal(artifact.name,`firebase-delivery-${RELEASE.sourceSha}-1`);
 assert.equal(artifact.digest,`sha256:${RELEASE.artifactSha256}`);
 assert.equal(artifact.workflow_run.id,Number(RELEASE.sourceCiRunId));assert.equal(artifact.workflow_run.head_sha,RELEASE.sourceSha);
 return {artifactVerified:true};
}
function snapshotShape(value,environment) {
 exactKeys(value,["schema","projectId","functions","protectedResources","selected"]);
 assert.equal(value.schema,"catch.cat151-booking-metadata/v1");assert.equal(value.projectId,projectFor(environment));
 assert.ok(Array.isArray(value.functions)&&value.functions.length>0&&value.functions.length<=3000);
 const names=value.functions.map(r=>{exactKeys(r,["name","sha256"]);assert.match(r.sha256,hashPattern);return r.name;});
 assert.equal(new Set(names).size,names.length);assert.deepEqual(names,names.slice().sort((a,b)=>a.localeCompare(b)));
 exactKeys(value.protectedResources,["extensions","indexes","fields","rules","remoteConfig","projectIam"]);
 for(const h of Object.values(value.protectedResources))assert.match(h,hashPattern);
 exactKeys(value.selected,TARGETS);
 for(const target of TARGETS){const row=value.selected[target];
  exactKeys(row,["identity","runtime","iamSha256","publicInvoker"]);
  validateFunctionIdentity(row.identity,{scope:scopeFor(environment),target});assert.ok(names.includes(targetName(environment,target)));
  assert.match(row.iamSha256,hashPattern);assert.equal(row.publicInvoker,true);
  exactKeys(row.runtime,["configurationSha256","paramsSha256","secretBindings","providerParams","serviceAccount"]);assert.match(row.runtime.configurationSha256,hashPattern);
 }
 return value;
}
export function verifyPredecessors(snapshot,environment) {
 snapshotShape(snapshot,environment);
 for(const target of TARGETS){const current=snapshot.selected[target].identity,pin=PREDECESSORS[environment][target.slice(10)];
  for(const k of ["revision","build","source"])assert.deepEqual(current[k],pin[k],"Selected predecessor changed");
 }
 return {predecessorsVerified:true};
}
export function verifyPreservation(before,after,{environment,completed=false,paramsSha256}={}) {
 snapshotShape(before,environment);snapshotShape(after,environment);
 const selected=new Set(TARGETS.map(t=>targetName(environment,t)));
 const retained=s=>s.functions.filter(r=>!selected.has(r.name));
 assert.deepEqual(retained(after),retained(before),"Unselected Function or Extension changed");
 assert.deepEqual(after.protectedResources,before.protectedResources,"Protected resource changed");
 if(!completed){assert.deepEqual(after,before,"Metadata changed at mutation boundary");return {unchanged:true};}
 assert.match(paramsSha256,hashPattern);
 for(const target of TARGETS){const a=before.selected[target],b=after.selected[target];
  assert.equal(b.runtime.serviceAccount,a.runtime.serviceAccount);
  assert.equal(b.iamSha256,a.iamSha256,"Selected invocation policy changed");
  assert.equal(b.runtime.configurationSha256,a.runtime.configurationSha256,"Selected runtime settings changed");
  assert.deepEqual(b.runtime.secretBindings,a.runtime.secretBindings,"Selected secret versions changed");
  assert.deepEqual(b.runtime.providerParams,a.runtime.providerParams,"Selected provider settings changed");
  assert.equal(b.runtime.paramsSha256,paramsSha256);
  for(const k of ["revision","build","source"])assert.notDeepEqual(b.identity[k],a.identity[k],"Selected deployment identity did not change");
 }
 return {completed:true,targets:TARGETS,retainedFunctions:retained(before).length};
}
export function verifyParams(file, provenance, expectedBinding, environment) {
  const r = {...RELEASE,projectId:projectFor(environment)};
  assert.equal(provenance.version, 1); assert.equal(provenance.projectId, r.projectId);
  assert.equal(provenance.sourceSha, r.sourceSha); assert.match(provenance.paramsSha256, hashPattern);
  const materializedSha256 = readMaterializedParamsSha256(file, r.projectId);
  const bytes = fs.readFileSync(file);
  const marker = Buffer.from(`CATCH_DEPLOY_CONFIG_SHA256=${JSON.stringify(provenance.paramsSha256)}\n`);
  assert.ok(bytes.length > marker.length && bytes.subarray(-marker.length).equals(marker), "Verified configuration marker missing.");
  const contents = bytes.subarray(0, bytes.length - marker.length);
  assert.ok(!contents.includes(Buffer.from("CATCH_DEPLOY_CONFIG_SHA256=")), "Duplicate configuration marker.");
  assert.equal(bytesDigest(contents), provenance.paramsSha256, "Materialized parameters differ from approved provenance.");
  const result = {materializedSha256, configurationSha256: provenance.paramsSha256};
  if (expectedBinding) assert.deepEqual(result, expectedBinding, "Parameter bytes changed at the mutation boundary.");
  return result;
}
export async function readSnapshot(environment, {run = spawnSync, request = fetch, listIndexes = gcloudIndexList} = {}) {
  const project = projectFor(environment);
  const tokenResult = run("gcloud", ["auth", "print-access-token"], {encoding: "utf8", timeout: 30000, maxBuffer: 1024 * 1024});
  assert.ifError(tokenResult.error); assert.equal(tokenResult.status, 0, "Metadata authentication unavailable.");
  const token = String(tokenResult.stdout ?? "").trim(); assert.ok(token && !/[\r\n]/.test(token));
  const get = async (url, init = {}) => {
    const response = await request(url, {...init, headers: {Authorization: `Bearer ${token}`, "Content-Type": "application/json"},
      signal: AbortSignal.timeout(30000)});
    assert.ok(response.ok, `Read-only metadata failed: HTTP ${response.status}.`); return response.json();
  };
  const pages = async (url, field, extra = {}, pageSize = "100") => {
    const rows = [], seen = new Set(); let cursor = "";
    do {
      assert.ok(seen.size < 30 && !seen.has(cursor)); seen.add(cursor);
      const response = await get(`${url}?${new URLSearchParams({...extra, pageSize, ...(cursor ? {pageToken: cursor} : {})})}`);
      assert.deepEqual(response.unreachable ?? [], []); assert.ok(Array.isArray(response[field] ?? []));
      rows.push(...(response[field] ?? [])); cursor = response.nextPageToken ?? ""; assert.equal(typeof cursor, "string");
    } while (cursor);
    return rows.sort((a, b) => String(a.name).localeCompare(String(b.name)));
  };
  // Hash complete metadata in memory; parameter values and tokens never enter receipts or logs.
  const functions = await pages(`https://cloudfunctions.googleapis.com/v2/projects/${project}/locations/-/functions`, "functions");
  assert.ok(functions.length > 0 && new Set(functions.map((fn) => fn.name)).size === functions.length);
  const selected = {}; let cursor = 0;
  await Promise.all(Array.from({length: 5}, async () => {
    while (cursor < functions.length) {
      const fn = functions[cursor++];
      assert.match(fn.name, new RegExp(`^projects/${project}/locations/[a-z0-9-]+/functions/[A-Za-z0-9_-]+$`));
      if (fn.environment === "GEN_2") {
        const service = fn.serviceConfig?.service;
        assert.match(service, new RegExp(`^projects/${project}/locations/[a-z0-9-]+/services/[a-z0-9-]+$`));
        fn.runService = await get(`https://run.googleapis.com/v2/${service}`);
        fn.iam = await get(`https://run.googleapis.com/v2/${service}:getIamPolicy?options.requestedPolicyVersion=3`);
      } else {
        assert.equal(fn.environment, "GEN_1");
        fn.iam = await get(`https://cloudfunctions.googleapis.com/v1/${fn.name}:getIamPolicy?options.requestedPolicyVersion=3`);
      }
      // Eventarc criteria have no evaluation order; retain every complete filter.
      if (Array.isArray(fn.eventTrigger?.eventFilters)) fn.eventTrigger.eventFilters.sort((a, b) =>
        JSON.stringify(canonical(a)).localeCompare(JSON.stringify(canonical(b))));
      const target = TARGETS.find(t=>fn.name===targetName(environment,t));
      if (target) {
        const config=fn.serviceConfig;
        const {service,uri,revision,environmentVariables,secretEnvironmentVariables,secretVolumes,...settings}=config;
        selected[target]={identity:captureFunctionIdentities([fn],scopeFor(environment),[target])[0],
          runtime:{serviceAccount:config.serviceAccountEmail,configurationSha256:digest({settings,runtime:fn.buildConfig.runtime,entryPoint:fn.buildConfig.entryPoint,eventTrigger:fn.eventTrigger??null}),
            paramsSha256:environmentVariables?.CATCH_DEPLOY_CONFIG_SHA256??null,
            secretBindings:{environment:secretEnvironmentVariables??[],volumes:secretVolumes??[]},
            providerParams:Object.fromEntries(PROVIDER_PARAMS.map(k=>[k,digest(environmentVariables?.[k]??"")]))},
          iamSha256:digest(fn.iam),publicInvoker:(fn.iam.bindings??[]).some(b=>b.role==="roles/run.invoker"&&!b.condition&&b.members?.includes("allUsers"))};
      }
    }
  }));
  const fields = new Map();
  for (const filter of ["indexConfig.usesAncestorConfig:false", "ttlConfig:*"]) {
    for (const field of await pages(`https://firestore.googleapis.com/v1/projects/${project}/databases/(default)/collectionGroups/-/fields`, "fields", {filter}, "0")) {
      assert.equal(typeof field.name, "string");
      if (fields.has(field.name)) assert.deepEqual(field, fields.get(field.name));
      fields.set(field.name, field);
    }
  }
  const protectedResources = {
    extensions: digest(await pages(`https://firebaseextensions.googleapis.com/v1beta/projects/${project}/instances`, "instances")),
    indexes: digest(listIndexes({projectId: project}).sort((a, b) => String(a.name).localeCompare(String(b.name)))),
    fields: digest([...fields.values()].sort((a, b) => a.name.localeCompare(b.name))),
    rules: digest(await pages(`https://firebaserules.googleapis.com/v1/projects/${project}/releases`, "releases")),
    remoteConfig: digest(await get(`https://firebaseremoteconfig.googleapis.com/v1/projects/${project}/remoteConfig`)),
    projectIam: digest(await get(`https://cloudresourcemanager.googleapis.com/v1/projects/${project}:getIamPolicy`,
      {method: "POST", body: JSON.stringify({options: {requestedPolicyVersion: 3}})})),
  };
  return snapshotShape({schema: "catch.cat151-booking-metadata/v1", projectId: project,
    functions: functions.map((fn) => ({name: fn.name, sha256: digest(fn)})), protectedResources, selected},environment);
}

export function verifyCandidate(before,candidate,params,environment) {
 snapshotShape(before,environment);assert.equal(candidate.projectId,projectFor(environment));assert.equal(candidate.environment,environment);
 assert.equal(candidate.sourceSha,RELEASE.sourceSha);assert.equal(candidate.version,1);
 assert.deepEqual(candidate.functions.map(f=>"functions:"+f.consumer).sort(),TARGETS);
 for(const target of TARGETS){const runtime=before.selected[target].runtime;
  assert.deepEqual(runtime.secretBindings.volumes,[],"Secret volumes are not authorized");
  assert.equal(candidate.functions.find(f=>f.consumer===target.slice(10)).serviceAccount,runtime.serviceAccount,"Runtime identity change is not authorized");
  const expectedReferences=runtime.secretBindings.environment.map(binding=>`projects/${projectFor(environment)}/secrets/${binding.secret}/versions/${binding.version}`).sort();
  assert.deepEqual(candidate.bindings.filter(b=>b.consumer===target.slice(10)).map(b=>b.reference).sort(),expectedReferences,"Secret expansion is not authorized");
  for(const binding of runtime.secretBindings.environment){
   const match=candidate.bindings.filter(b=>b.consumer===target.slice(10)&&b.reference?.includes(`/secrets/${binding.secret}/versions/`));
   assert.equal(match.length,1);assert.equal(match[0].active,true);
   assert.equal(match[0].reference,`projects/${projectFor(environment)}/secrets/${binding.secret}/versions/${binding.version}`,"Secret rebinding is not authorized");
  }
  for(const key of PROVIDER_PARAMS)assert.equal(digest(params[key]??""),runtime.providerParams[key],"Provider parameter drift is not authorized");
 }
 return {candidatePreservesProviderBindings:true};
}
function readParams(file) {
 const values={};
 for(const line of fs.readFileSync(file,"utf8").split("\n")){
  if(!line.trim()||line.startsWith("#"))continue;
  const i=line.indexOf("=");assert.ok(i>0);const key=line.slice(0,i);assert.ok(!Object.hasOwn(values,key));
  values[key]=JSON.parse(line.slice(i+1));assert.equal(typeof values[key],"string");
 }
 return values;
}

export function complete({manifest,packagePlan,before,after,deployment,paramsBinding,environment}) {
 prepare({manifest,packagePlan});verifyPredecessors(before,environment);
 const proof=verifyPreservation(before,after,{environment,completed:true,paramsSha256:paramsBinding.configurationSha256});
 validateFunctionsDeployment(deployment,{manifest,scope:scopeFor(environment),baseSha:RELEASE.baseSha,selectedTargets:TARGETS,paramsSha256:paramsBinding.materializedSha256});
 assert.deepEqual(deployment.functions,TARGETS.map(t=>after.selected[t].identity));
 return {schema:"catch.cat151-booking-release/v1",environment,sourceSha:RELEASE.sourceSha,packageSha256:RELEASE.packageSha256,proof,deployment,paramsBinding};
}
export function verifyDev(receipt,manifest) {
 verifyManifest(manifest);assert.equal(receipt.schema,"catch.cat151-booking-release/v1");assert.equal(receipt.environment,"dev");
 assert.equal(receipt.sourceSha,RELEASE.sourceSha);assert.equal(receipt.packageSha256,RELEASE.packageSha256);
 assert.equal(receipt.proof.completed,true);assert.deepEqual(receipt.proof.targets,TARGETS);
 validateFunctionsDeployment(receipt.deployment,{manifest,scope:scopeFor("dev"),baseSha:RELEASE.baseSha,selectedTargets:TARGETS,paramsSha256:receipt.paramsBinding.materializedSha256});
 return {devVerified:true};
}
// One reviewed recovery for the CLI install failure before PROD mutation.
export function verifyPredeployRecovery(run, jobs) {
 assert.equal(run.id,38910329785);assert.equal(run.run_attempt,1);
 assert.equal(run.workflow_id,375348513);assert.equal(run.head_sha,"621454fe1f2c61ec7647f2de9ec9a66378ef8efd");
 assert.equal(run.path,".github/workflows/selective-backend-release.yml");
 assert.equal(run.event,"workflow_dispatch");assert.equal(run.head_branch,"main");
 assert.equal(run.status,"completed");assert.equal(run.conclusion,"failure");
 assert.ok(Array.isArray(jobs.jobs));assert.equal(jobs.total_count,jobs.jobs.length);
 const one=name=>{const found=jobs.jobs.filter(j=>j.name===name);assert.equal(found.length,1);return found[0];};
 const dev=one("dev-cat151-booking / CAT151 booking writer dev promotion");
 assert.equal(dev.status,"completed");assert.equal(dev.conclusion,"success");
 const prod=one("prod-cat151-booking / CAT151 booking writer prod promotion");
 assert.equal(prod.status,"completed");assert.equal(prod.conclusion,"failure");
 const step=name=>{const found=prod.steps.filter(s=>s.name===name);assert.equal(found.length,1);return found[0];};
 const install=step("Install Firebase CLI");assert.equal(install.conclusion,"failure");
 for(const name of ["Require recorded human PROD environment approval for operator release",
   "Verify this run's successful DEV receipt before PROD credentials",
   "Capture all retained Functions, Extensions and protected configuration",
   "Verify environment prerequisites for the approved targets"])
   assert.equal(step(name).conclusion,"success");
 const deploy=step("Deploy the fixed fourteen CAT151 Functions once");
 assert.ok(deploy.number>install.number);assert.equal(deploy.conclusion,"skipped");
 for(const row of prod.steps.filter(s=>s.number>install.number&&s.number<=deploy.number))
   assert.equal(row.conclusion,"skipped");
 assert.equal(prod.steps.filter(s=>s.conclusion==="failure").length,1);
 return {predeployRecoveryVerified:true,priorRunId:run.id,productionMutationStarted:false};
}
const read=file=>JSON.parse(fs.readFileSync(file,"utf8"));
const write=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+"\n",{flag:"wx",mode:0o600});
export async function runCli(argv,{snapshot=readSnapshot}={}) {
 const [command,...rest]=argv,args={};
 for(let i=0;i<rest.length;i+=2){assert.match(rest[i],/^--[a-z-]+$/);assert.ok(rest[i+1]);const k=rest[i].slice(2);assert.ok(!Object.hasOwn(args,k));args[k]=rest[i+1];}
 const keys={"verify-predeploy-recovery":["run","jobs"],source:["current-main","source-root"],artifact:["metadata"],archive:["archive"],provenance:["manifest"],prepare:["manifest","package-plan","output"],
  before:["environment","output"],params:["environment","params-file","provenance","output"],"verify-params":["environment","params-file","provenance","binding"],
  "verify-before":["environment","before"],complete:["environment","before","params-file","params-provenance","params-binding","manifest","package-plan","deployment","output"],
  "verify-dev":["receipt","manifest"],"verify-candidate":["environment","candidate","before","params-file"]};
 assert.ok(Object.hasOwn(keys,command));exactKeys(args,keys[command]);
 if(command==="verify-predeploy-recovery")return verifyPredeployRecovery(read(args.run),read(args.jobs));
 if(command==="source")return checkSource(args["current-main"],args["source-root"]);
 if(command==="artifact")return verifyArtifact(read(args.metadata));
 if(command==="archive"){assert.equal(bytesDigest(fs.readFileSync(args.archive)),RELEASE.artifactSha256);return {archiveVerified:true};}
 if(command==="provenance"){verifyManifest(read(args.manifest));return {provenanceVerified:true};}
 if(command==="prepare"){write(args.output,prepare({manifest:read(args.manifest),packagePlan:read(args["package-plan"])}));return {targets:TARGETS};}
 if(command==="verify-dev")return verifyDev(read(args.receipt),read(args.manifest));
 const environment=args.environment;projectFor(environment);
 if(["params","verify-params"].includes(command)){
  const result=verifyParams(args["params-file"],read(args.provenance),command==="verify-params"?read(args.binding):undefined,environment);
  if(command==="params")write(args.output,result);return {paramsBound:true};
 }
 if(command==="verify-candidate")return verifyCandidate(read(args.before),read(args.candidate),readParams(args["params-file"]),environment);
 const after=await snapshot(environment);
 if(command==="before"){verifyPredecessors(after,environment);write(args.output,after);return {predecessorsVerified:true};}
 const before=read(args.before);
 if(command==="verify-before"){verifyPredecessors(before,environment);return verifyPreservation(before,after,{environment});}
 const result=complete({before,after,environment,manifest:read(args.manifest),packagePlan:read(args["package-plan"]),deployment:read(args.deployment),
  paramsBinding:verifyParams(args["params-file"],read(args["params-provenance"]),read(args["params-binding"]),environment)});
 write(args.output,result);return {completed:true,targets:TARGETS};
}
if(process.argv[1]===fileURLToPath(import.meta.url))runCli(process.argv.slice(2)).then(r=>console.log(JSON.stringify(r))).catch(()=>{
 console.error("CAT151 fixed release verification failed; no broader deploy or automatic retry is authorized.");process.exitCode=1;
});
