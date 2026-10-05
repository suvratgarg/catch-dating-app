import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";
import {prepareFunctionsDeployment} from "./firebase_functions_checkpoint.mjs";
import {WEDDING_RELEASE as r, prepareWeddingRelease, verifyWeddingBefore, completeWeddingRelease,
  verifyWeddingDevReceipt, closedControls, runWeddingReleaseCli, readWeddingSnapshot} from "./wedding_phone_import_release.mjs";
const copy = (value) => structuredClone(value);
const manifest = {schema: "catch.delivery-provenance/v2", sourceSha:r.sourceSha,
  sourceCiRunId:r.sourceCiRunId, sourceCiRunAttempt:r.sourceCiRunAttempt, stages:["functions"],
  artifact:{name:"firebase-backend.tar.gz", sizeBytes:7838486, sha256:r.packageSha256}};
const retainedTargets = Array.from({length:578}, (_,i)=>`functions:retained${i}`).sort();
const packagePlan = {sourceSha:r.sourceSha, baseSha:r.baseSha, sourceCiRunId:r.sourceCiRunId,
  sourceCiRunAttempt:r.sourceCiRunAttempt, stages:["functions"], deployGroups:["functions"],
  targets:[[...retainedTargets,r.target].join(",")]};
function liveFunction(name, project) {
  const runName=name.toLowerCase();
  const service=`projects/${project}/locations/asia-south1/services/${runName}`;
  const revision=`${service}/revisions/${runName}-00001-abc`;
  return {name:`projects/${project}/locations/asia-south1/functions/${name}`,environment:"GEN_2",state:"ACTIVE",
    updateTime:"2026-09-06T12:00:00.123456789Z", labels:{"deployment-callable":"true"},
    buildConfig:{runtime:"nodejs24",entryPoint:name,build:`projects/42/locations/asia-south1/builds/build-${name}`,
      sourceProvenance:{resolvedStorageSource:{bucket:"source-bucket",object:"functions.zip",generation:"123"}}},
    serviceConfig:{service,revision:`${runName}-00001-abc`,timeoutSeconds:120,maxInstanceCount:5,
      availableMemory:"512Mi",serviceAccountEmail:"42-compute@developer.gserviceaccount.com"},
    runService:{name:service,uid:`${name}-uid`,generation:"1",observedGeneration:"1",
      latestReadyRevision:revision,latestCreatedRevision:revision,terminalCondition:{state:"CONDITION_SUCCEEDED"},
      trafficStatuses:[{type:"TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST",percent:100}]},
    runIamPolicy:{bindings:[{role:"roles/run.invoker",members:["allUsers"]}]}};
}
function fixture(environment="dev") {
  const project=environment==="dev"?"catchdates-dev":"catch-dating-app-64e51";
  const scope=`firebase:${environment}:${project}`;
  const snapshot={projectId:project,projectNumber:"42",selectedHttpStatus:404,runtimeServiceAccountExists:true,
    functions:retainedTargets.map(t=>liveFunction(t.slice(10),project))};
  for(const key of ["indexesSha256","fieldsSha256","projectIamSha256","remoteConfigSha256","rulesSha256"])
    snapshot[key]="a".repeat(64);
  const baselineDeployment=prepareFunctionsDeployment({manifest:{...manifest,sourceSha:r.baselineSha},scope,
    baseSha:r.baseSha,selectedTargets:retainedTargets,paramsSha256:"b".repeat(64),functions:snapshot.functions});
  const before=verifyWeddingBefore({snapshot,retainedTargets,baselineDeployment,environment});
  const after=copy(snapshot); after.selectedHttpStatus=200;
  after.functions.push(liveFunction("importWeddingPhoneContacts",project));
  const deployment=prepareFunctionsDeployment({manifest,scope,baseSha:r.baseSha,selectedTargets:[r.target],
    paramsSha256:"b".repeat(64),functions:after.functions});
  return {snapshot,retainedTargets,baselineDeployment,environment,before,deployment,manifest,
    paramsSha256:"b".repeat(64),after};
}
function complete(f) {return completeWeddingRelease({...f,snapshot:f.after});}
test("579-export package produces exactly one target without inventory deployment authority",()=>{
  const result=prepareWeddingRelease({packagePlan,verifiedPlan:packagePlan,manifest});
  assert.deepEqual(result.executionPlan.targets,[r.target]);
  assert.deepEqual(result.retainedTargets,retainedTargets);
  for(const mutate of [p=>p.sourceSha="a".repeat(40),p=>p.baseSha="a".repeat(40),
    p=>p.targets=[retainedTargets.join(",")],p=>p.deployGroups.push("firestore-indexes"),
    p=>p.stages.push("firestore-rules")]) {
    const bad=copy(packagePlan); mutate(bad);
    assert.throws(()=>prepareWeddingRelease({packagePlan:bad,verifiedPlan:packagePlan,manifest}));
  }
  assert.throws(()=>prepareWeddingRelease({packagePlan,verifiedPlan:{...packagePlan,targets:[retainedTargets.join(",")]},manifest}));
  assert.throws(()=>prepareWeddingRelease({packagePlan,verifiedPlan:packagePlan,
    manifest:{...manifest,artifact:{...manifest.artifact,sha256:"a".repeat(64)}}}));
});
test("new callable requires confirmed absence and accepted unchanged 578-target PROD identity",()=>{
  const f=fixture("prod");
  assert.equal(complete(f).retainedTargetCount,578);
  for(const mutate of [v=>v.snapshot.selectedHttpStatus=403,v=>v.snapshot.selectedHttpStatus=200,
    v=>v.snapshot.runtimeServiceAccountExists=false,v=>v.baselineDeployment.functions[0].updateTime="drift",
    v=>v.retainedTargets.pop()]) {
    const bad=copy(f); mutate(bad); assert.throws(()=>verifyWeddingBefore(bad));
  }
});
test("one-target completion binds package and serving checkpoint; DEV proof gates PROD",()=>{
  const f=fixture(); const receipt=complete(f);
  assert.deepEqual(verifyWeddingDevReceipt(receipt,manifest),{verifiedDev:true});
  for(const mutate of [v=>v.selectedTargets.push("functions:extra"),v=>v.controlsClosed=false,
    v=>v.sourceSha="c".repeat(40),v=>v.deployment.paramsSha256="invalid"]){
    const bad=copy(receipt);mutate(bad);assert.throws(()=>verifyWeddingDevReceipt(bad,manifest));
  }
  const bad=copy(f);bad.paramsSha256="c".repeat(64);assert.throws(()=>complete(bad));
});
test("unselected Function, IAM, index, TTL, rules and control drift blocks completion",()=>{
  const f=fixture();
  for(const mutate of [v=>v.after.functions[0].updateTime="drift",v=>v.after.functions[0].runIamPolicy.bindings=[],
    ...["indexesSha256","fieldsSha256","projectIamSha256","remoteConfigSha256","rulesSha256"].map(k=>v=>v.after[k]="c".repeat(64))]){
    const bad=copy(f);mutate(bad);assert.throws(()=>complete(bad));
  }
});
test("selected runtime, existing service account, secrets and IAM cannot broaden",()=>{
  const f=fixture();
  for(const mutate of [v=>v.buildConfig.runtime="nodejs22",v=>v.buildConfig.entryPoint="other",
    v=>v.serviceConfig.timeoutSeconds=121,v=>v.serviceConfig.maxInstanceCount=50,
    v=>v.serviceConfig.availableMemory="1Gi",v=>v.serviceConfig.serviceAccountEmail="new@example.com",
    v=>v.serviceConfig.secretEnvironmentVariables=[{key:"NEW_SECRET"}],v=>v.serviceConfig.secretVolumes=[{}],
    v=>v.labels["deployment-callable"]="false",
    v=>v.runIamPolicy.bindings.push({role:"roles/run.admin",members:["allUsers"]})]){
    const bad=copy(f);mutate(bad.after.functions.at(-1));assert.throws(()=>complete(bad));
  }
});
test("activation controls stay closed in default, conditional and grouped Remote Config",()=>{
  closedControls({});closedControls({parameters:{host_wedding_phone_import_enabled:{defaultValue:{value:"false"}}}});
  for(const template of [{parameters:{CATCH_WEDDING_PHONE_IMPORT_READY:{defaultValue:{value:"true"}}}},
    {parameterGroups:{hidden:{parameters:{host_wedding_phone_import_enabled:{defaultValue:{value:"false"},conditionalValues:{x:{value:"true"}}}}}}}])
    assert.throws(()=>closedControls(template));
});
test("CLI rejects unknown authority inputs before metadata access",async()=>{
  await assert.rejects(runWeddingReleaseCli(["prepare","--all-functions","true"]));
});
test("separate caller requires DEV receipt and protected PROD; ordinary delivery retains parity",()=>{
  const caller=fs.readFileSync(new URL("../../.github/workflows/wedding-phone-import-release.yml",import.meta.url),"utf8");
  const reusable=fs.readFileSync(new URL("../../.github/workflows/_firebase-promote.yml",import.meta.url),"utf8");
  assert.match(caller,/needs: \[authorize, dev\]/);
  assert.match(caller,/dev_completion_artifact_id:.*needs.dev.outputs.wedding_artifact_id/);
  assert.match(caller,/confirm_one_callable/);
  assert.match(caller,/needs.dev.outputs.wedding_receipt_sha256/);
  assert.ok(reusable.includes('[[ "$EXPECTED_RECEIPT_SHA256" =~ ^[0-9a-f]{64}$ ]]'));
  assert.match(reusable,/Require recorded human PROD environment approval/);
  assert.match(reusable,/if:.*!inputs.wedding_phone_import_release/);
  assert.match(reusable,/wedding-firebase-checkpoint/);
  assert.ok(reusable.includes("format('sha256:{0}', steps.wedding_receipt.outputs.artifact-digest)"));
  assert.match(reusable,/wedding_phone_import_release.mjs unchanged/);
  assert.match(reusable,/wedding_phone_import_release.mjs complete/);
});

function metadataFixture({unreachable=false, selectedStatus=404, controls={}}={}) {
  const calls=[]; const fn=liveFunction("retained0","catchdates-dev");
  const request=async(url,init={})=>{
    calls.push({url,method:init.method??"GET"});const u=new URL(url);let body={};
    if(u.hostname==="cloudresourcemanager.googleapis.com" && !u.pathname.endsWith(":getIamPolicy")) body={projectNumber:"42"};
    else if(u.hostname==="iam.googleapis.com") body={email:"42-compute@developer.gserviceaccount.com"};
    else if(u.pathname.endsWith("/importWeddingPhoneContacts")) return {ok:selectedStatus===200,status:selectedStatus,json:async()=>({})};
    else if(u.hostname==="cloudfunctions.googleapis.com") {
      assert.ok(u.searchParams.get("fields").includes("unreachable"));
      assert.ok(!u.searchParams.get("fields").includes("environmentVariables"));
      body={functions:[fn],...(unreachable?{unreachable:["us-west1"]}:{})};
    } else if(u.hostname==="run.googleapis.com" && u.pathname.endsWith(":getIamPolicy")) body=fn.runIamPolicy;
    else if(u.hostname==="run.googleapis.com") body=fn.runService;
    else if(u.hostname==="firestore.googleapis.com") body={fields:[]};
    else if(u.hostname==="firebaserules.googleapis.com") body={releases:[]};
    else if(u.hostname==="firebaseremoteconfig.googleapis.com") body=controls;
    else {assert.equal(u.pathname,"/v1/projects/catchdates-dev:getIamPolicy");assert.equal(init.method,"POST");body={bindings:[]};}
    return {ok:true,status:200,json:async()=>copy(body)};
  };
  return {calls,request,run:()=>({status:0,stdout:"synthetic-test-token"}),listIndexes:()=>[]};
}
test("metadata reader uses read-only APIs and rejects incomplete inventories and unresolved absence",async()=>{
  const f=metadataFixture();const result=await readWeddingSnapshot("dev",f);
  assert.equal(result.selectedHttpStatus,404);assert.equal(result.functions.length,1);
  assert.equal(result.runtimeServiceAccountExists,true);
  assert.ok(f.calls.every(c=>c.method==="GET" || (c.method==="POST" && c.url.includes(":getIamPolicy"))));
  assert.ok(!JSON.stringify(result).includes("synthetic-test-token"));
  await assert.rejects(readWeddingSnapshot("dev",metadataFixture({unreachable:true})),/unreachable/);
  await assert.rejects(readWeddingSnapshot("dev",metadataFixture({selectedStatus:403})),/absence/);
  await assert.rejects(readWeddingSnapshot("dev",metadataFixture({controls:{parameters:{host_wedding_phone_import_enabled:{defaultValue:{value:"true"}}}}})),/closed/);
});
