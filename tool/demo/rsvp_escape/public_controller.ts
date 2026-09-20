import {useState} from 'react';
import fixture from './fixture.json';
import {visiblePublicFormSections,validatePublicFormAnswers} from '../../../website/src/features/forms/publicFormModel';
// This adapter is only aliased by the local Vite config. Production auth and
// submission are unchanged. Public rendering and visibility use shipped code.
export function usePublicFormController() {
 const form={definition:fixture.editor.definition,organizer:{name:'Saket Run Club',logoUrl:null}};
 const [answers,setAnswers]=useState({...fixture.records[0].answers});
 const [stage,setStage]=useState('form');
 const [sectionIndex,setSectionIndex]=useState(0);
 const [errors,setErrors]=useState({});
 const [consentAccepted,updateConsent]=useState(false);
 const visibleSections=visiblePublicFormSections(form.definition,answers);
 const activeSection=visibleSections[sectionIndex];
 return {form,stage,setStage,answers,sectionIndex,setSectionIndex,errors,
  consentAccepted,updateConsent,visibleSections,activeSection,embed:false,
  uploads:{},uploadInProgress:false,pending:false,saveState:'idle',status:{message:'',tone:''},
  updateAnswer:(id,value)=>setAnswers(current=>({...current,[id]:value})),
  previousSection:()=>setSectionIndex(current=>Math.max(0,current-1)),
  nextSection:()=>{const found=validatePublicFormAnswers(activeSection.questions,answers);setErrors(found);if(Object.keys(found).length)return;if(sectionIndex===visibleSections.length-1)setStage('review');else setSectionIndex(sectionIndex+1);},
  uploadAnswer:async()=>{},
  submit:async()=>{setErrors({});},
 };
}
