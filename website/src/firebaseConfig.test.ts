import {afterEach, describe, expect, it, vi} from "vitest";
import {developmentFirebaseConfig, firebaseConfigFromEnvironment} from "@catch/web-config/firebase";

const productionEnvironment = {
  VITE_FIREBASE_API_KEY: "production-key",
  VITE_FIREBASE_AUTH_DOMAIN: "production.firebaseapp.com",
  VITE_FIREBASE_PROJECT_ID: "production",
  VITE_FIREBASE_STORAGE_BUCKET: "production.firebasestorage.app",
  VITE_FIREBASE_MESSAGING_SENDER_ID: "123",
  VITE_FIREBASE_APP_ID: "production-app",
};

afterEach(() => {
  vi.unstubAllEnvs();
  vi.resetModules();
});

async function readConfig(development: boolean, env: Partial<typeof productionEnvironment>) {
  vi.resetModules();
  vi.stubEnv("DEV", development);
  for (const key of Object.keys(productionEnvironment)) {
    vi.stubEnv(key, env[key as keyof typeof productionEnvironment] ?? "");
  }
  return import("./firebaseConfig");
}

describe("shared Firebase environment resolution", () => {
  it("does not silently use development credentials for an incomplete public production build", async () => {
    const {firebaseConfig, claimFirebaseConfigured} = await readConfig(false, {
      VITE_FIREBASE_PROJECT_ID: "production",
    });
    expect(firebaseConfig).toBeNull();
    expect(claimFirebaseConfigured).toBe(false);
  });

  it("uses the complete explicit project in development and production", async () => {
    for (const development of [true, false]) {
      const {firebaseConfig} = await readConfig(development, productionEnvironment);
      expect(firebaseConfig).toMatchObject({projectId: "production", apiKey: "production-key"});
    }
  });

  it("uses one coherent development project when public development config is incomplete", async () => {
    const {firebaseConfig} = await readConfig(true, {VITE_FIREBASE_PROJECT_ID: "partial"});
    expect(firebaseConfig).toEqual(developmentFirebaseConfig);
  });

  it("requires callers to opt into the existing Admin development fallback policy", () => {
    expect(firebaseConfigFromEnvironment({})).toBeNull();
    expect(firebaseConfigFromEnvironment({}, developmentFirebaseConfig))
      .toEqual(developmentFirebaseConfig);
    expect(firebaseConfigFromEnvironment({VITE_FIREBASE_PROJECT_ID: "override"}, developmentFirebaseConfig))
      .toMatchObject({projectId: "override", apiKey: developmentFirebaseConfig.apiKey});
  });
});
