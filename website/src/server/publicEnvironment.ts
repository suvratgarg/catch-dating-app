export function productionIndexing(env: NodeJS.ProcessEnv = process.env): boolean {
  return env.CATCH_WEBSITE_STAGE === "production";
}
export function validatePublicRuntimeEnvironment(env: NodeJS.ProcessEnv = process.env): void {
  if (!productionIndexing(env)) return;
  if (env.FIRESTORE_EMULATOR_HOST || env.CATCH_PUBLIC_FIRESTORE_PROJECT !== "catch-dating-app-64e51") {
    throw new Error("INVALID_PRODUCTION_PUBLIC_READER_ENVIRONMENT");
  }
}
