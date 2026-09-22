#!/usr/bin/env node
/** Bounded demo runner: ordinary public UI, real App Check, no direct writes. */
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

export const target = Object.freeze({
  organizerId: 'fJlZbx9BewUXsOZwQKv3',
  formId: 'form_88b03048d9fc1f5269ece582c5aa495d',
  publicFormId: 'p-waCu_4GrE4hKrV7GN4cDydV7OYtmqx',
  version: 2,
});
export const url = `https://catchdates.com/f/${target.publicFormId}/`;
export const existing = ['Maya RSVP Demo', 'Rohan RSVP Demo', 'Asha RSVP Demo'];
export const personas = [
  ['priya', 'Ahmedabad', 'Female', 'Life Partner'],
  ['dev', 'Dubai', 'Male', 'Friendship'],
  ['kabir', 'Mumbai', 'Male', 'Networking'],
  ['leena', 'Bangalore', 'Female', 'Fun Experience'],
  ['sara', 'Dubai', 'Female', 'Romantic Relationship'],
].map(([key, city, gender, intent], index) => ({
  key, city, name: `${key[0].toUpperCase()}${key.slice(1)} RSVP Demo`,
  answers: {
    eventCity: city, fullName: `${key[0].toUpperCase()}${key.slice(1)} RSVP Demo`,
    email: `${key}.rsvp.demo@example.com`, phone: `+1202555010${index + 4}`,
    homeCity: city, dubaiYears: '3 — fictional demo', single: true,
    gender, height: 5.7, age: 30, birthDate: '1996-05-12',
    instagram: `@rsvp_demo_${key}_fictional`,
    linkedin: `https://www.linkedin.com/in/rsvp-demo-${key}-fictional/`,
    intent, relationshipStatus: 'Never Been Married', hasChildren: false,
    futureChildren: 'Maybe', partnerAge: 'No Preference',
    sharedValues: 'Not Important', ethnicity: 'Fictional demo applicant',
    partnerEthnicity: 'No preference — fictional demo', drink: 'I don’t drink',
    food: 'Vegetarian', personality: ['Ambivert'],
    hobbies: ['Reading/Writing', 'Traveling'], college: 'Demo University (fictional)',
    occupation: 'Designer (fictional)', company: 'Demo Studio — synthetic applicant',
    singlesTravel: 'Unsure', referral: 'Catch demo testing — not a real guest',
  },
}));

export function assertTarget(form) {
  if (form?.organizer?.organizerId !== target.organizerId ||
      form.formId !== target.formId || form.publicFormId !== target.publicFormId ||
      form.version !== target.version || form.availabilityStatus !== 'active' ||
      form.definition?.identityPolicy !== 'anonymous' ||
      !/demo|demonstration/i.test(form.definition.consent?.consentCopy ?? '')) {
    throw new Error('Live form does not match the authorized active demo target.');
  }
  const questions = form.definition.sections.flatMap(section => section.questions);
  const expected = new Set([...Object.keys(personas[0].answers), 'photo']);
  if (questions.length !== expected.size || questions.some(question =>
    question.questionId !== `rsvp_${question.key}` || !expected.delete(question.key))) {
    throw new Error('Published question contract changed; review before applying.');
  }
}

export function plan(journal, only) {
  if (JSON.stringify(journal.target) !== JSON.stringify(target)) {
    throw new Error('Receipt journal belongs to another target.');
  }
  if (only && !personas.some(persona => persona.key === only)) {
    throw new Error('Unknown persona; only the five fixed demo personas are allowed.');
  }
  return personas.filter(persona => !only || persona.key === only).map(persona => {
    const receipt = journal.receipts[persona.key];
    if (receipt && receipt.status !== 'submitted') {
      throw new Error(`${persona.key} has an uncertain prior attempt. Reconcile in Host before any retry.`);
    }
    return {persona, action: receipt ? 'skip-submitted' : 'submit'};
  });
}

const escapeRegex = value => value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

async function fillQuestion(page, question, persona, photo) {
  // Use the rendered controls and normal controller, including all validation.
  const group = page.getByRole('group', {name: new RegExp(`^${escapeRegex(question.label)}`)});
  if (!await group.isVisible()) return;
  const value = persona.answers[question.key];
  if (question.kind === 'file') {
    await group.locator('input[type=file]').setInputFiles(photo);
    await group.getByText('Upload ready', {exact: true}).waitFor({timeout: 60000});
  } else if (question.kind === 'acknowledgement') {
    await group.getByRole('checkbox').check();
  } else if (question.kind === 'boolean') {
    await group.getByRole('button', {name: value ? 'Yes' : 'No', exact: true}).click();
  } else if (question.kind === 'singleChoice' && question.options.length > 4) {
    await group.getByRole('combobox').selectOption({label: value});
  } else if (question.kind === 'singleChoice' || question.kind === 'multiChoice') {
    for (const choice of Array.isArray(value) ? value : [value]) {
      await group.getByRole('button', {name: choice, exact: true}).click();
    }
  } else {
    await group.locator(`#form-question-${question.questionId}`).fill(String(value));
  }
}

async function submitPersona(browser, persona, photo) {
  const context = await browser.newContext();
  try {
    const page = await context.newPage();
    const publicResponse = page.waitForResponse(response =>
      response.url().includes('getPublicOrganizerForm'), {timeout: 45000});
    await page.goto(url, {waitUntil: 'domcontentloaded'});
    const response = await publicResponse;
    if (response.status() !== 200) throw new Error(`Public form denied: HTTP ${response.status()}`);
    const form = (await response.json()).result;
    assertTarget(form);
    for (const [index, section] of form.definition.sections.entries()) {
      await page.getByRole('heading', {name: section.title, exact: true}).waitFor();
      for (const question of section.questions) await fillQuestion(page, question, persona, photo);
      await page.getByRole('button', {
        name: index === form.definition.sections.length - 1 ? 'Review answers' : 'Continue', exact: true,
      }).click();
    }
    await page.getByRole('heading', {name: 'Review before submitting', exact: true}).waitFor();
    await page.getByRole('checkbox').check();
    const submitted = page.waitForResponse(response =>
      response.url().includes('submitOrganizerFormResponse'), {timeout: 60000});
    await page.getByRole('button', {name: 'Submit response', exact: true}).click();
    const submitResponse = await submitted;
    const body = await submitResponse.json();
    if (submitResponse.status() !== 200 || !body.result?.responseId) {
      throw new Error(`Submit did not return a receipt: HTTP ${submitResponse.status()}`);
    }
    await page.getByRole('heading', {name: 'Application received', exact: true}).waitFor();
    return {status: 'submitted', responseId: body.result.responseId,
      name: persona.name, city: persona.city, submittedAt: new Date().toISOString()};
  } finally {await context.close();}
}

async function main(args) {
  const apply = args.includes('--apply');
  const value = flag => args.includes(flag) ? args[args.indexOf(flag) + 1] : undefined;
  const journalPath = value('--journal');
  const photo = value('--photo');
  const only = value('--only');
  const journal = journalPath && fs.existsSync(journalPath) ?
    JSON.parse(fs.readFileSync(journalPath, 'utf8')) : {target, receipts: {}};
  const entries = plan(journal, only);
  console.log(JSON.stringify({apply, target, preserve: existing,
    plan: entries.map(({persona, action}) => ({name: persona.name, city: persona.city, action}))}, null, 2));
  if (!apply) return;
  if (!journalPath || !photo || !fs.existsSync(photo)) {
    throw new Error('--apply requires an existing synthetic --photo and persistent --journal path.');
  }
  // Exclusive lock plus write-ahead attempt record makes uncertain retries fail closed.
  const lockPath = `${journalPath}.lock`;
  const lock = fs.openSync(lockPath, 'wx', 0o600);
  let browser;
  const save = () => {
    const temporary = `${journalPath}.tmp`;
    fs.writeFileSync(temporary, JSON.stringify(journal, null, 2), {mode: 0o600});
    fs.renameSync(temporary, journalPath);
  };
  try {
    // Re-read under the lock; never overwrite another runner's receipts.
    if (fs.existsSync(journalPath)) Object.assign(journal, JSON.parse(fs.readFileSync(journalPath, 'utf8')));
    const lockedEntries = plan(journal, only);
    const {chromium} = await import('playwright');
    browser = await chromium.launch({channel: 'chrome', headless: false});
    for (const {persona, action} of lockedEntries) {
      if (action === 'skip-submitted') continue;
      journal.receipts[persona.key] = {status: 'attempting', name: persona.name,
        startedAt: new Date().toISOString()};
      save();
      journal.receipts[persona.key] = await submitPersona(browser, persona, photo);
      save();
      console.log(JSON.stringify(journal.receipts[persona.key]));
    }
  } finally {
    await browser?.close();
    fs.closeSync(lock);
    fs.unlinkSync(lockPath);
  }
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  main(process.argv.slice(2)).catch(error => {console.error(error.message); process.exitCode = 1;});
}
