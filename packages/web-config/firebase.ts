export interface FirebaseConfig {
  apiKey: string;
  authDomain: string;
  projectId: string;
  storageBucket: string;
  messagingSenderId: string;
  appId: string;
  measurementId?: string;
}

export const developmentFirebaseConfig: FirebaseConfig = {
  apiKey: "AIzaSyAl271K9YGiYZOEcNgoEwZiOQV0ydpWfrg",
  appId: "1:619661127800:web:b0673ad370947b2f077d8d",
  messagingSenderId: "619661127800",
  projectId: "catchdates-dev",
  authDomain: "catchdates-dev.firebaseapp.com",
  storageBucket: "catchdates-dev.firebasestorage.app",
  measurementId: "G-TCR62QJVH9",
};

// Callers explicitly choose whether development fallback is permitted. Never
// read import.meta.env here: each deployed surface supplies its own environment.
export function firebaseConfigFromEnvironment(
  env: Record<string, unknown>,
  fallback?: FirebaseConfig
): FirebaseConfig | null {
  const value = (key: string, defaultValue?: string) =>
    typeof env[key] === "string" && env[key] ? env[key] as string : defaultValue;
  const apiKey = value("VITE_FIREBASE_API_KEY", fallback?.apiKey);
  const authDomain = value("VITE_FIREBASE_AUTH_DOMAIN", fallback?.authDomain);
  const projectId = value("VITE_FIREBASE_PROJECT_ID", fallback?.projectId);
  const storageBucket = value("VITE_FIREBASE_STORAGE_BUCKET", fallback?.storageBucket);
  const messagingSenderId = value("VITE_FIREBASE_MESSAGING_SENDER_ID", fallback?.messagingSenderId);
  const appId = value("VITE_FIREBASE_APP_ID", fallback?.appId);
  if (!apiKey || !authDomain || !projectId || !storageBucket || !messagingSenderId || !appId) return null;
  return {
    apiKey, authDomain, projectId, storageBucket, messagingSenderId, appId,
    measurementId: value("VITE_FIREBASE_MEASUREMENT_ID", fallback?.measurementId),
  };
}
