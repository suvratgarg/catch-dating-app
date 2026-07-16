import type {DataMode} from "../types/adminTypes";

export function dataMode(): DataMode {
  return import.meta.env.VITE_ADMIN_DATA_MODE === "live" ? "live" : "sample";
}
