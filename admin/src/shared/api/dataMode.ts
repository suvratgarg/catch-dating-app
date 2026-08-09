import type {DataMode} from "../types/adminTypes";

export function dataMode(): DataMode {
  return resolveDataMode(
    import.meta.env.VITE_ADMIN_DATA_MODE,
    import.meta.env.DEV
  );
}

export function resolveDataMode(
  configuredMode: unknown,
  isDevelopment: boolean
): DataMode {
  return configuredMode === "sample" && isDevelopment ? "sample" : "live";
}
