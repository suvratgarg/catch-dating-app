import assert from 'node:assert/strict';
import test from 'node:test';
import {buildRsvpFormDefinition,cities} from './form_definition.mjs';

test('consolidated intake retains five cities, mapped contact links and conditional Dubai questions',()=>{
 const definition=buildRsvpFormDefinition();
 const questions=definition.sections.flatMap(section=>section.questions);
 const byId=new Map(questions.map(question=>[question.questionId,question]));
 assert.equal(questions.length,31);
 assert.equal(byId.size,31);
 assert.deepEqual(byId.get('rsvp_eventCity').options.map(option=>option.value),cities);
 assert.equal(byId.get('rsvp_eventCity').hostPresentation,'filterable');
 assert.equal(byId.get('rsvp_phone').canonicalFieldId,'phoneNumber');
 assert.equal(byId.get('rsvp_instagram').canonicalFieldId,'instagramHandle');
 assert.deepEqual(definition.logicRules.map(rule=>rule.targetQuestionId),['rsvp_dubaiYears','rsvp_singlesTravel']);
 assert.ok(definition.logicRules.every(rule=>rule.conditions[0].expectedValues[0]==='Dubai'));
 assert.equal(definition.identityPolicy,'emailOrPhoneVerified');
 assert.match(definition.description,/DEMO/);
 assert.equal(definition.completion.actionUrl,null);
});
