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
  verifyPreservation,verifyCandidate,verifyParams,verifyDev,complete,readSnapshot,runCli,checkSource} from './cat151_receipt_release.mjs';
const hash=v=>createHash('sha256').update(JSON.stringify(v)).digest('hex');
const projects={dev:'catchdates-dev',prod:'catch-dating-app-64e51'};
const manifest=()=>({schema:'catch.delivery-provenance/v2',sourceSha:RELEASE.sourceSha,
 sourceCiRunId:RELEASE.sourceCiRunId,sourceCiRunAttempt:'1',artifact:{name:'firebase-backend.tar.gz',sizeBytes:8317451,sha256:RELEASE.packageSha256},stages:['functions']});
const plan=()=>({schema:'catch.firebase-delivery-plan/v2',sourceSha:RELEASE.sourceSha,baseSha:RELEASE.baseSha,
 sourceCiRunId:RELEASE.sourceCiRunId,sourceCiRunAttempt:'1',stages:['functions'],deployGroups:['functions'],targets:[[...TARGETS,'functions:retained'].sort().join(',')]});
const providerKeys=['RAZORPAY_PUBLIC_KEY_ID','RAZORPAY_PLATFORM_PAYMENT_CONFIG_VERSION','EVENT_VENUE_SESSION_TTL_SECONDS','EVENT_VENUE_SESSION_REFRESH_SECONDS','STRIPE_APPLICATION_FEE_BPS'];
function before(environment='prod') {
 const project=projects[environment];
 const selected=Object.fromEntries(TARGETS.map(target=>{const name=target.slice(10),service=`projects/${project}/locations/asia-south1/services/${name.toLowerCase()}`;
  return [target,{identity:{...structuredClone(PREDECESSORS[environment][name]),name:`projects/${project}/locations/asia-south1/functions/${name}`,
   updateTime:'2026-10-16T10:00:00Z',service,serviceUid:'synthetic-uid',serviceGeneration:'1'},
   runtime:{serviceAccount:'synthetic',configurationSha256:'a'.repeat(64),paramsSha256:'b'.repeat(64),secretBindings:{environment:[{key:'RAZORPAY_KEY_SECRET',secret:'RAZORPAY_KEY_SECRET',projectId:project,version:'1'}],volumes:[]},
    providerParams:Object.fromEntries(providerKeys.map(k=>[k,hash('')]))},iamSha256:'c'.repeat(64),publicInvoker:true}];}));
 return {schema:'catch.cat151-receipt-metadata/v1',projectId:project,selected,
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
test('CAT151 selects only the fixed order creator from the immutable main package',()=>{
 assert.deepEqual(TARGETS,["functions:createRazorpayOrder"]);assert.deepEqual(prepare({manifest:manifest(),packagePlan:plan()}).targets,[TARGETS.join(',')]);
 for(const mutate of [v=>v.sourceSha='0'.repeat(40),v=>v.sourceCiRunId='1',v=>v.sourceCiRunAttempt='2',v=>v.artifact.sha256='0'.repeat(64),v=>v.stages.push('firestore-rules')]){
  const m=manifest();mutate(m);assert.throws(()=>verifyManifest(m));
 }
 for(const mutate of [v=>v.baseSha='0'.repeat(40),v=>v.targets=['functions:razorpayWebhook'],v=>v.targets=[TARGETS.join(',')+','+TARGETS[0]],v=>v.deployGroups.push('storage')]){
  const p=plan();mutate(p);assert.throws(()=>prepare({manifest:manifest(),packagePlan:p}));
 }
});
test('CAT151 uses the packaged delivery baseline rather than the source parent',()=>{
 // Binding read from artifact12059462962 delivery-plan.json; independent of RELEASE.
 const packaged={...plan(),sourceSha:'bbff52defd3c0dfb8df7c78c336c6549af7df47a',
  baseSha:'6817b248294ccb8e0084e7d3cac9161d058fe70d',sourceCiRunId:'38931076239',sourceCiRunAttempt:'1'};
 assert.deepEqual(prepare({manifest:manifest(),packagePlan:packaged}).targets,['functions:createRazorpayOrder']);
 assert.throws(()=>prepare({manifest:manifest(),packagePlan:{...packaged,baseSha:'2f3d78db47343a0a363e619ee7dddc9cf8ad1199'}}));
 const workflow=fs.readFileSync('.github/workflows/_cat151-receipt-promote.yml','utf8');
 const pins=[...workflow.matchAll(/--base-sha ([a-f0-9]{40})/g)].map(m=>m[1]);
 assert.deepEqual(pins,Array(3).fill(packaged.baseSha));
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
});
function jobText(source,name) {
 const start=source.indexOf(`\n  ${name}:\n`);assert.ok(start>=0);const part=source.slice(start+1);const end=part.search(/\n  [A-Za-z_][A-Za-z0-9_-]*:\n/);return end<0?part:part.slice(0,end);
}
test('CAT151 protected workflow admits only fixed mode and chains exact DEV evidence into human PROD',()=>{
 const caller=fs.readFileSync('.github/workflows/selective-backend-release.yml','utf8');
 const reusable=fs.readFileSync('.github/workflows/_cat151-receipt-promote.yml','utf8');
 const dev=jobText(caller,'dev-cat151-receipt'),prod=jobText(caller,'prod-cat151-receipt');
 assert.match(dev,/environment: dev/);assert.match(prod,/environment: prod/);assert.match(prod,/needs: \[authorize-cat151-receipt, dev-cat151-receipt\]/);
 for(const job of [dev,prod])assert.match(job,/uses: \.\/\.github\/workflows\/_cat151-receipt-promote.yml/);
 assert.ok(jobText(caller,'authorize-cat151-receipt').includes(RELEASE.sourceSha));
 for(const key of ['receipt_sha256','artifact_id','artifact_digest'])assert.ok(prod.includes(`needs['dev-cat151-receipt'].outputs.${key}`));
 const job=jobText(reusable,'promote-cat151-receipt');assert.match(job,/environment: \$\{\{ inputs.environment \}\}/);assert.match(job,/cancel-in-progress: false/);
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
 const source=fs.readFileSync('.github/workflows/_cat151-receipt-promote.yml','utf8');
 const step=extractSteps(jobText(source,'promote-cat151-receipt'))[0];
 const predicate=step.run.match(/jq -e '\n([\s\S]*?)\n\s*' <<</)[1];
 const base={environment:'dev',control_plane_sha:'a'.repeat(40),dev_completion_artifact_id:'',dev_completion_artifact_digest:'',dev_completion_receipt_sha256:''};
 const accepts=v=>spawnSync('jq',['-e',predicate],{input:JSON.stringify(v),encoding:'utf8',env:{...process.env,GITHUB_SHA:'a'.repeat(40)}}).status===0;
 assert.equal(accepts(base),true);
 // Run38936482759 exposed caller dispatch inputs in the reusable context.
 // Exercise those actual shapes, including the omitted empty resume input.
 const inherited={release_kind:'cat151-order-receipt',source_sha:RELEASE.sourceSha,
  reason:'Deploy bounded receipts for the approved native TEST booking.',
  confirm_four_functions_five_indexes:false,confirm_whatsapp_five:false,
  confirm_sales_pr543:false,confirm_booking_functions:false,confirm_intake_pr596:false,
  resume_delivery_attempt:'1'};
 for(const stage of [base,{...base,environment:'prod',dev_completion_artifact_id:'123',dev_completion_artifact_digest:'b'.repeat(64),dev_completion_receipt_sha256:'c'.repeat(64)}]) {
  assert.equal(accepts({...stage,...inherited}),true);
  assert.equal(accepts({...stage,...inherited,resume_delivery_run_id:''}),true);
  for(const patch of [{release_kind:'cat151-booking'},{source_sha:'0'.repeat(40)},
   {confirm_booking_functions:true},{confirm_four_functions_five_indexes:true},
   {confirm_whatsapp_five:true},{confirm_sales_pr543:true},{confirm_intake_pr596:true},
   {confirm_booking_functions:'false'},{resume_delivery_attempt:'2'},
   {resume_delivery_run_id:'123'},{reason:'short'},{reason:'line break\nforbidden'},
   {reason:' '.repeat(20)},{reason:'x'.repeat(241)},{unknown_scope:true}]) {
   assert.equal(accepts({...stage,...inherited,...patch}),false,JSON.stringify(patch));
  }
 }
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

