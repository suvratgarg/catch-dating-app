const devFirebaseConfig = {
  apiKey: "AIzaSyAl271K9YGiYZOEcNgoEwZiOQV0ydpWfrg",
  appId: "1:619661127800:web:b0673ad370947b2f077d8d",
  messagingSenderId: "619661127800",
  projectId: "catchdates-dev",
  authDomain: "catchdates-dev.firebaseapp.com",
  storageBucket: "catchdates-dev.firebasestorage.app",
  measurementId: "G-TCR62QJVH9",
};

export interface FirebaseConfig {
  apiKey: string;
  authDomain: string;
  projectId: string;
  storageBucket: string;
  messagingSenderId: string;
  appId: string;
  measurementId?: string;
}

export const firebaseConfig = resolveFirebaseConfig();
export const appCheckSiteKey = import.meta.env.VITE_WEBSITE_APPCHECK_SITE_KEY;

export const claimFirebaseConfigured = Boolean(
  firebaseConfig && appCheckSiteKey
);
export const publicReviewsFirebaseConfigured = Boolean(
  firebaseConfig && appCheckSiteKey
);
export const publicAnalyticsFirebaseConfigured = Boolean(
  firebaseConfig && appCheckSiteKey
);

function resolveFirebaseConfig(): FirebaseConfig | null {
  const explicitConfig = {
    apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
    authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
    projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
    storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
    messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
    appId: import.meta.env.VITE_FIREBASE_APP_ID,
    measurementId: import.meta.env.VITE_FIREBASE_MEASUREMENT_ID,
  };

  if (
    explicitConfig.apiKey &&
    explicitConfig.authDomain &&
    explicitConfig.projectId &&
    explicitConfig.storageBucket &&
    explicitConfig.messagingSenderId &&
    explicitConfig.appId
  ) {
    return explicitConfig;
  }

  return import.meta.env.DEV ? devFirebaseConfig : null;
}
