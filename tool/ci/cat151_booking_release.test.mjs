import assert from 'node:assert/strict';
import test from 'node:test';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {createCheckpointState} from './delivery_core.mjs';
import {functionsParamsProvenance, prepareFunctionsParamsForDeploy} from '../firebase/prepare_functions_params_for_deploy.mjs';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {extractSteps} from '../harness/lib/workflow_steps.mjs';
import {RELEASE,TARGETS,PREDECESSORS,prepare,verifyManifest,verifyArtifact,verifyPredecessors,
  verifyPreservation,verifyCandidate,verifyParams,verifyDev,verifyPredeployRecovery,complete,readSnapshot,runCli,checkSource} from './cat151_booking_release.mjs';
const hash=v=>createHash('sha256').update(JSON.stringify(v)).digest('hex');
const projects={dev:'catchdates-dev',prod:'catch-dating-app-64e51'};
const manifest=()=>({schema:'catch.delivery-provenance/v2',sourceSha:RELEASE.sourceSha,
 sourceCiRunId:RELEASE.sourceCiRunId,sourceCiRunAttempt:'1',artifact:{name:'firebase-backend.tar.gz',sizeBytes:8314774,sha256:RELEASE.packageSha256},stages:['functions']});
const plan=()=>({schema:'catch.firebase-delivery-plan/v2',sourceSha:RELEASE.sourceSha,baseSha:RELEASE.baseSha,
 sourceCiRunId:RELEASE.sourceCiRunId,sourceCiRunAttempt:'1',stages:['functions'],deployGroups:['functions'],targets:[[...TARGETS,'functions:retained'].sort().join(',')]});
const providerKeys=['RAZORPAY_PUBLIC_KEY_ID','RAZORPAY_PLATFORM_PAYMENT_CONFIG_VERSION','EVENT_VENUE_SESSION_TTL_SECONDS','EVENT_VENUE_SESSION_REFRESH_SECONDS','STRIPE_APPLICATION_FEE_BPS'];
function before(environment='prod') {
 const project=projects[environment];
 const selected=Object.fromEntries(TARGETS.map(target=>{const name=target.slice(10),service=`projects/${project}/locations/asia-south1/services/${name.toLowerCase()}`;
  return [target,{identity:{...structuredClone(PREDECESSORS[environment][name]),name:`projects/${project}/locations/asia-south1/functions/${name}`,
   updateTime:'2026-10-16T10:00:00Z',service,serviceUid:'synthetic-uid',serviceGeneration:'1'},
   runtime:{serviceAccount:'synthetic',configurationSha256:'a'.repeat(64),paramsSha256:'b'.repeat(64),secretBindings:{environment:name==='razorpayWebhook'?[{key:'RAZORPAY_WEBHOOK_SECRET',secret:'RAZORPAY_WEBHOOK_SECRET',projectId:project,version:environment==='prod'?'2':'1'}]:[],volumes:[]},
    providerParams:Object.fromEntries(providerKeys.map(k=>[k,hash('')]))},iamSha256:'c'.repeat(64),publicInvoker:true}];}));
 return {schema:'catch.cat151-booking-metadata/v1',projectId:project,selected,
  functions:[...Object.values(selected).map(r=>({name:r.identity.name,sha256:'d'.repeat(64)})),{name:`projects/${project}/locations/asia-south1/functions/retained`,sha256:'e'.repeat(64)}].sort((a,b)=>a.name.localeCompare(b.name)),
  protectedResources:Object.fromEntries(['extensions','indexes','fields','rules','remoteConfig','projectIam'].map(k=>[k,'f'.repeat(64)]))};
}
function after(environment='prod') {
 const result=before(environment);
 for(const row of Object.values(result.selected)){
  row.identity.revision+='-new';row.identity.build+='-new';row.identity.source.generation=String(BigInt(row.identity.source.generation)+1n);
  row.identity.serviceGeneration='2';row.identity.updateTime='2026-10-16T11:00:00Z';row.runtime.paramsSha256='1'.repeat(64);
 }
 return result;
}
function candidate(environment='prod') {
 const snapshot=before(environment);return {version:1,projectId:projects[environment],environment,sourceSha:RELEASE.sourceSha,
  functions:TARGETS.map(t=>({consumer:t.slice(10),serviceAccount:'synthetic'})),
  bindings:Object.entries(snapshot.selected).flatMap(([t,r])=>r.runtime.secretBindings.environment.map(b=>({consumer:t.slice(10),active:true,reference:`projects/${projects[environment]}/secrets/${b.secret}/versions/${b.version}`})))};
}
test('CAT151 selects exactly fourteen fixed writers from the immutable main package',()=>{
 assert.equal(TARGETS.length,14);assert.deepEqual(prepare({manifest:manifest(),packagePlan:plan()}).targets,[TARGETS.join(',')]);
 for(const mutate of [v=>v.sourceSha='0'.repeat(40),v=>v.sourceCiRunId='1',v=>v.sourceCiRunAttempt='2',v=>v.artifact.sha256='0'.repeat(64),v=>v.stages.push('firestore-rules')]){
  const m=manifest();mutate(m);assert.throws(()=>verifyManifest(m));
 }
 for(const mutate of [v=>v.baseSha='0'.repeat(40),v=>v.targets=['functions:razorpayWebhook'],v=>v.targets=[TARGETS.join(',')+','+TARGETS[0]],v=>v.deployGroups.push('storage')]){
  const p=plan();mutate(p);assert.throws(()=>prepare({manifest:manifest(),packagePlan:p}));
 }
});
test('CAT151 artifact metadata rejects wrong producer, source, archive and expired evidence',()=>{
 const a={id:RELEASE.artifactId,expired:false,name:`firebase-delivery-${RELEASE.sourceSha}-1`,digest:`sha256:${RELEASE.artifactSha256}`,workflow_run:{id:Number(RELEASE.sourceCiRunId),head_sha:RELEASE.sourceSha}};
 assert.equal(verifyArtifact(a).artifactVerified,true);
 for(const mutate of [v=>v.id++,v=>v.expired=true,v=>v.digest='sha256:'+'0'.repeat(64),v=>v.workflow_run.id++,v=>v.workflow_run.head_sha='0'.repeat(40)]){const v=structuredClone(a);mutate(v);assert.throws(()=>verifyArtifact(v));}
});
for(const environment of ['dev','prod']) {
 test(`CAT151 ${environment} pins every observed predecessor and rejects revision/build/source drift`,()=>{
  assert.equal(verifyPredecessors(before(environment),environment).predecessorsVerified,true);
  for(const target of TARGETS)for(const key of ['revision','build','source']){
   const v=before(environment);if(key==='source')v.selected[target].identity.source.generation='1';else v.selected[target].identity[key]+='-changed';
   assert.throws(()=>verifyPredecessors(v,environment));
  }
 });
 test(`CAT151 ${environment} permits only fresh selected identities with unchanged retained resources`,()=>{
  assert.equal(verifyPreservation(before(environment),before(environment),{environment}).unchanged,true);
  assert.equal(verifyPreservation(before(environment),after(environment),{environment,completed:true,paramsSha256:'1'.repeat(64)}).completed,true);
  assert.throws(()=>verifyPreservation(before(environment),after(environment),{environment}));
  for(const target of TARGETS)for(const mutate of [r=>r.iamSha256='0'.repeat(64),r=>r.publicInvoker=false,r=>r.runtime.configurationSha256='0'.repeat(64),r=>r.runtime.paramsSha256='0'.repeat(64),r=>r.runtime.secretBindings.volumes.push({secret:'foreign'}),r=>r.runtime.providerParams.RAZORPAY_PUBLIC_KEY_ID='0'.repeat(64)]){
   const v=after(environment);mutate(v.selected[target]);assert.throws(()=>verifyPreservation(before(environment),v,{environment,completed:true,paramsSha256:'1'.repeat(64)}));
  }
  for(const key of ['extensions','indexes','fields','rules','remoteConfig','projectIam']){const v=after(environment);v.protectedResources[key]='0'.repeat(64);assert.throws(()=>verifyPreservation(before(environment),v,{environment,completed:true,paramsSha256:'1'.repeat(64)}));}
  const v=after(environment);v.functions.find(r=>r.name.endsWith('/retained')).sha256='0'.repeat(64);assert.throws(()=>verifyPreservation(before(environment),v,{environment,completed:true,paramsSha256:'1'.repeat(64)}));
 });
 test(`CAT151 ${environment} rejects secret rebinding and provider changes before mutation`,()=>{
  assert.equal(verifyCandidate(before(environment),candidate(environment),{},environment).candidatePreservesProviderBindings,true);
  const c=candidate(environment);c.bindings[0].reference=c.bindings[0].reference.replace(/versions\/\d+$/,'versions/9');assert.throws(()=>verifyCandidate(before(environment),c,{},environment));
  assert.throws(()=>verifyCandidate(before(environment),candidate(environment),{RAZORPAY_PUBLIC_KEY_ID:'changed'},environment));
  const extra=candidate(environment);extra.bindings.push({consumer:'razorpayWebhook',active:true,reference:`projects/${projects[environment]}/secrets/foreign/versions/1`});assert.throws(()=>verifyCandidate(before(environment),extra,{},environment));
  const identity=candidate(environment);identity.functions[0].serviceAccount='foreign';assert.throws(()=>verifyCandidate(before(environment),identity,{},environment));
  const foreign=candidate(environment);foreign.functions.push({consumer:'foreign'});assert.throws(()=>verifyCandidate(before(environment),foreign,{},environment));
 });
}
test('CAT151 CLI rejects target overrides, recovery and unknown environments before cloud reads',async()=>{
 let reads=0;const snapshot=async()=>{reads++;return before();};
 for(const args of [['before','--environment','prod','--output','unused','--target','functions:foreign'],['before','--environment','staging','--output','unused'],['restore','--environment','prod']])await assert.rejects(runCli(args,{snapshot}));
 assert.equal(reads,0);
});
test('CAT151 source compatibility is pinned and rejects non-SHA input',()=>{
 assert.throws(()=>checkSource('HEAD'));assert.equal(checkSource(RELEASE.sourceSha).sourceSha,RELEASE.sourceSha);
 assert.equal(checkSource('8a10447b353082712c28b63008d1a5ebb4c7bd61').sourceSha,RELEASE.sourceSha);
});
function jobText(source,name) {
 const start=source.indexOf(`\n  ${name}:\n`);assert.ok(start>=0);const part=source.slice(start+1);const end=part.search(/\n  [A-Za-z_][A-Za-z0-9_-]*:\n/);return end<0?part:part.slice(0,end);
}
test('CAT151 protected workflow admits only fixed mode and chains exact DEV evidence into human PROD',()=>{
 const caller=fs.readFileSync('.github/workflows/selective-backend-release.yml','utf8');
 const reusable=fs.readFileSync('.github/workflows/_firebase-promote.yml','utf8');
 const dev=jobText(caller,'dev-cat151-booking'),prod=jobText(caller,'prod-cat151-booking');
 assert.match(dev,/environment: dev/);assert.match(prod,/environment: prod/);assert.match(prod,/needs: \[authorize-cat151-booking, dev-cat151-booking\]/);
 for(const job of [dev,prod]){assert.ok(job.includes(RELEASE.sourceSha));assert.match(job,/cat151_booking_release: true/);assert.match(job,/uses: \.\/\.github\/workflows\/_firebase-promote.yml/);}
 for(const key of ['receipt_sha256','artifact_id','artifact_digest'])assert.ok(prod.includes(`needs['dev-cat151-booking'].outputs.cat151_${key}`));
 const job=jobText(reusable,'promote-cat151-booking');assert.match(job,/environment: \$\{\{ inputs.environment \}\}/);assert.match(job,/cancel-in-progress: false/);
 const steps=extractSteps(job),names=steps.map(s=>s.name);
 const approval=steps.find(s=>s.name?.startsWith('Require recorded human'));assert.match(approval.run,/reviewers/);assert.match(approval.run,/actions\/runs\/\$GITHUB_RUN_ID\/approvals/);
 assert.ok(job.indexOf('Verify this run')<job.indexOf('google-github-actions/auth@v3'));
 assert.ok(job.indexOf('if: ${{ inputs.environment == \'prod\' }}')<job.indexOf('Require recorded human')+150);
 const mutations=steps.filter(s=>s.run?.includes('firebase_with_env.sh'));assert.equal(mutations.length,1);assert.ok(mutations[0].run.includes('--only '+TARGETS.join(',')));
 assert.doesNotMatch(job,/--force|sync:callable-invokers|restore-decision|backend-delivery-cursor/);
 const all=steps.filter(s=>s.run).map(s=>s.run.replace(/\$\{\{[\s\S]*?\}\}/g,'test-value')).join('\n');const syntax=spawnSync('bash',['-n'],{input:all,encoding:'utf8'});assert.equal(syntax.status,0,syntax.stderr);
});
test('CAT151 completion and DEV admission reject cross-environment or partial deployment evidence',()=>{
 const paramsBinding={configurationSha256:'1'.repeat(64),materializedSha256:'2'.repeat(64)};
 const m=manifest(),scope='firebase:dev:catchdates-dev';
 const deployment={schema:'catch.firebase-functions-deployment/v1',scope,provenance:createCheckpointState(m,scope).provenance,
  baseSha:RELEASE.baseSha,targets:TARGETS,paramsSha256:paramsBinding.materializedSha256,functions:TARGETS.map(t=>after('dev').selected[t].identity)};
 const receipt=complete({manifest:m,packagePlan:plan(),before:before('dev'),after:after('dev'),deployment,paramsBinding,environment:'dev'});
 assert.equal(verifyDev(receipt,m).devVerified,true);
 for(const mutate of [r=>r.environment='prod',r=>r.deployment.scope='firebase:prod:catch-dating-app-64e51',r=>r.deployment.functions.pop(),r=>r.proof.completed=false,r=>r.packageSha256='0'.repeat(64),r=>r.paramsBinding.materializedSha256='0'.repeat(64)]){
  const r=structuredClone(receipt);mutate(r);assert.throws(()=>verifyDev(r,m));
 }
 const stale=structuredClone(deployment);stale.functions[0]=before('dev').selected[TARGETS[0]].identity;
 assert.throws(()=>complete({manifest:m,packagePlan:plan(),before:before('dev'),after:after('dev'),deployment:stale,paramsBinding,environment:'dev'}));
});
test('CAT151 caller scope predicate rejects mixed profiles and missing DEV evidence',()=>{
 const source=fs.readFileSync('.github/workflows/_firebase-promote.yml','utf8');
 const step=extractSteps(jobText(source,'promote-cat151-booking'))[0];
 const predicate=step.run.match(/jq -e '\n([\s\S]*?)\n\s*' <<</)[1];
 const base={cat151_predeploy_recovery:false,cat151_booking_release:true,intake_pr596_release:false,operator_release:false,whatsapp_five_release:false,sales_pr543_release:false,wedding_phone_import_release:false,require_current_main:false,environment:'dev',approval_environment:'',control_plane_sha:'a'.repeat(40),source_sha:RELEASE.sourceSha,base_sha:RELEASE.baseSha,source_ci_run_id:RELEASE.sourceCiRunId,source_ci_run_attempt:'1',resume_delivery_run_id:'',resume_delivery_attempt:'1',dev_completion_artifact_id:'',dev_completion_artifact_digest:'',dev_completion_receipt_sha256:''};
 const accepts=v=>spawnSync('jq',['-e',predicate],{input:JSON.stringify(v),encoding:'utf8',env:{...process.env,GITHUB_SHA:'a'.repeat(40)}}).status===0;
 assert.equal(accepts(base),true);
 for(const patch of [{operator_release:true},{intake_pr596_release:true},{environment:'staging'},{environment:'prod'},{source_sha:'0'.repeat(40)},{resume_delivery_run_id:'123'},{dev_completion_artifact_id:'123'}])assert.equal(accepts({...base,...patch}),false);
 assert.equal(accepts({...base,environment:'prod',dev_completion_artifact_id:'123',dev_completion_artifact_digest:'b'.repeat(64),dev_completion_receipt_sha256:'c'.repeat(64)}),true);
});
test('CAT151 snapshot rejects incomplete or cyclic Function inventories',async()=>{
 const deps=body=>({run:()=>({status:0,stdout:'synthetic-token'}),request:async()=>({ok:true,json:async()=>body})});
 await assert.rejects(readSnapshot('prod',deps({functions:[],unreachable:['europe-west1']})));
 await assert.rejects(readSnapshot('prod',deps({functions:[],nextPageToken:'repeat'})));
});
test('CAT151 binds real materializer bytes and rejects changed values under an unchanged marker',t=>{
 const directory=fs.mkdtempSync(path.join(os.tmpdir(),'cat151-params-'));t.after(()=>fs.rmSync(directory,{recursive:true,force:true}));
 fs.writeFileSync(path.join(directory,'package.json'),'{}');
 const environment={ALGOLIA_APPLICATION_ID:'ABCDEFGHIJ',RAZORPAY_PUBLIC_KEY_ID:'rzp_test_synthetic'},projectId=projects.prod,sourceSha=RELEASE.sourceSha;
 const provenance=functionsParamsProvenance({environment,projectId,sourceSha});
 const {outputPath}=prepareFunctionsParamsForDeploy({functionsDir:directory,projectId,sourceSha,environment,expectedProvenance:provenance});
 const binding=verifyParams(outputPath,provenance,undefined,'prod');assert.equal(binding.configurationSha256,provenance.paramsSha256);
 assert.throws(()=>verifyParams(outputPath,provenance,undefined,'dev'));
 fs.writeFileSync(outputPath,fs.readFileSync(outputPath,'utf8').replace('rzp_test_synthetic','rzp_test_changed'));
 assert.throws(()=>verifyParams(outputPath,provenance,binding,'prod'));
});

test('CAT151 recovery requires the exact terminal predeployment failure and successful DEV',()=>{
 const run={id:38910329785,run_attempt:1,workflow_id:375348513,head_sha:'621454fe1f2c61ec7647f2de9ec9a66378ef8efd',path:'.github/workflows/selective-backend-release.yml',event:'workflow_dispatch',head_branch:'main',status:'completed',conclusion:'failure'};
 const names=['Require recorded human PROD environment approval for operator release',"Verify this run's successful DEV receipt before PROD credentials",'Capture all retained Functions, Extensions and protected configuration','Verify environment prerequisites for the approved targets','Install Firebase CLI','Create a separate deploy tree','Deploy the fixed fourteen CAT151 Functions once'];
 const jobs={total_count:2,jobs:[{name:'dev-cat151-booking / CAT151 booking writer dev promotion',status:'completed',conclusion:'success'},
  {name:'prod-cat151-booking / CAT151 booking writer prod promotion',status:'completed',conclusion:'failure',steps:names.map((name,i)=>({name,number:i+1,conclusion:i<4?'success':i===4?'failure':'skipped'}))}]};
 assert.equal(verifyPredeployRecovery(run,jobs).productionMutationStarted,false);
 for(const patch of [{id:1},{run_attempt:2},{head_sha:'0'.repeat(40)},{status:'in_progress'},{conclusion:'success'},{workflow_id:1},{head_branch:'other'}])assert.throws(()=>verifyPredeployRecovery({...run,...patch},jobs));
 for(const mutate of [j=>j.total_count++,j=>j.jobs[0].conclusion='failure',j=>j.jobs[1].steps[4].conclusion='success',j=>j.jobs[1].steps[5].conclusion='success',j=>j.jobs[1].steps[6].conclusion='success',j=>j.jobs[1].steps.pop(),j=>j.jobs[1].steps[0].conclusion='skipped']){
  const changed=structuredClone(jobs);mutate(changed);assert.throws(()=>verifyPredeployRecovery(run,changed));
 }
});
test('CAT151 recovery workflow pins DEV proof and checks prior failure before cloud credentials',()=>{
 const caller=fs.readFileSync('.github/workflows/selective-backend-release.yml','utf8');
 const reusable=fs.readFileSync('.github/workflows/_firebase-promote.yml','utf8');
 const recovery=jobText(caller,'prod-cat151-booking-recovery');
 assert.match(recovery,/environment: prod/);assert.match(recovery,/cat151_predeploy_recovery: true/);
 assert.match(jobText(caller,'dev-cat151-booking'),/inputs.release_kind == 'cat151-booking'/);
 for(const pin of ['12051195096','ddc8037be3aa68377cd6cd8c0e59433e944f5dc4a7eb2d87c52d8615bca7266f','b93c177b877956d8b044c3f1f3b8f89c1a31b2fdc026013170b6a625ab62bb09'])assert.ok(recovery.includes(pin));
 const job=jobText(reusable,'promote-cat151-booking');
 assert.ok(job.indexOf('verify-predeploy-recovery')<job.indexOf('google-github-actions/auth@v3'));
 assert.match(job,/actions\/runs\/38910329785\/attempts\/1/);
 const predicate=extractSteps(job)[0].run.match(/jq -e '\n([\s\S]*?)\n\s*' <<</)[1];
 const base={cat151_predeploy_recovery:true,cat151_booking_release:true,intake_pr596_release:false,operator_release:false,whatsapp_five_release:false,sales_pr543_release:false,wedding_phone_import_release:false,require_current_main:false,environment:'prod',approval_environment:'',control_plane_sha:'a'.repeat(40),source_sha:RELEASE.sourceSha,base_sha:RELEASE.baseSha,source_ci_run_id:RELEASE.sourceCiRunId,source_ci_run_attempt:'1',resume_delivery_run_id:'',resume_delivery_attempt:'1',dev_completion_artifact_id:'12051195096',dev_completion_artifact_digest:'ddc8037be3aa68377cd6cd8c0e59433e944f5dc4a7eb2d87c52d8615bca7266f',dev_completion_receipt_sha256:'b93c177b877956d8b044c3f1f3b8f89c1a31b2fdc026013170b6a625ab62bb09'};
 const accepts=v=>spawnSync('jq',['-e',predicate],{input:JSON.stringify(v),encoding:'utf8',env:{...process.env,GITHUB_SHA:'a'.repeat(40)}}).status===0;
 assert.equal(accepts(base),true);
 for(const patch of [{environment:'dev'},{dev_completion_artifact_id:'1'},{dev_completion_artifact_digest:'0'.repeat(64)},{dev_completion_receipt_sha256:'0'.repeat(64)}])assert.equal(accepts({...base,...patch}),false);
});
