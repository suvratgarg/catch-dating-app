import {defineConfig} from '../../../node_modules/vite/dist/node/index.js';
import react from '../../../website/node_modules/@vitejs/plugin-react/dist/index.js';
import {fileURLToPath} from 'node:url';
export default defineConfig({root:fileURLToPath(new URL('.',import.meta.url)),plugins:[react()],
 resolve:{alias:[{find:'./usePublicFormController',replacement:fileURLToPath(new URL('./public_controller.ts',import.meta.url))}]},
 server:{host:'127.0.0.1',port:5173,fs:{allow:[fileURLToPath(new URL('../../..',import.meta.url))]}}});
