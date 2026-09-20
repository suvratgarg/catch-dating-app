import React from 'react';
import {createRoot} from 'react-dom/client';
import {MemoryRouter} from 'react-router';
import {PublicFormPage} from '../../../website/src/features/forms/PublicFormPage';
import '../../../website/src/styles.css';
createRoot(document.getElementById('root')!).render(<MemoryRouter><div style={{background:'#ffedc8',textAlign:'center',fontSize:12,padding:8}}>LOCAL PREVIEW · Actual Catch form renderer · Synthetic data</div><PublicFormPage /></MemoryRouter>);
