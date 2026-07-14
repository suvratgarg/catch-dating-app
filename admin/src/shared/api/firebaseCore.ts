import {initializeApp} from "firebase/app";
import {initializeAppCheck, ReCaptchaV3Provider} from "firebase/app-check";

const devFirebaseConfig = {
  apiKey: "AIzaSyAl271K9YGiYZOEcNgoEwZiOQV0ydpWfrg",
  appId: "1:619661127800:web:b0673ad370947b2f077d8d",
  messagingSenderId: "619661127800",
  projectId: "catchdates-dev",
  authDomain: "catchdates-dev.firebaseapp.com",
  storageBucket: "catchdates-dev.firebasestorage.app",
  measurementId: "G-TCR62QJVH9",
};

export function firebaseConfig() {
  return {
    apiKey: import.meta.env.VITE_FIREBASE_API_KEY || devFirebaseConfig.apiKey,
    authDomain:
      import.meta.env.VITE_FIREBASE_AUTH_DOMAIN ||
      devFirebaseConfig.authDomain,
    projectId:
      import.meta.env.VITE_FIREBASE_PROJECT_ID || devFirebaseConfig.projectId,
    storageBucket:
      import.meta.env.VITE_FIREBASE_STORAGE_BUCKET ||
      devFirebaseConfig.storageBucket,
    messagingSenderId:
      import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID ||
      devFirebaseConfig.messagingSenderId,
    appId: import.meta.env.VITE_FIREBASE_APP_ID || devFirebaseConfig.appId,
    measurementId:
      import.meta.env.VITE_FIREBASE_MEASUREMENT_ID ||
      devFirebaseConfig.measurementId,
  };
}

export const firebaseApp = initializeApp(firebaseConfig());
const appCheckSiteKey = import.meta.env.VITE_ADMIN_APPCHECK_SITE_KEY;

if (appCheckSiteKey) {
  initializeAppCheck(firebaseApp, {
    provider: new ReCaptchaV3Provider(appCheckSiteKey),
    isTokenAutoRefreshEnabled: true,
  });
}
