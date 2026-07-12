import type {OwnerGatedLegalPage} from "./types";

export const ownerGatedLegalPages = {
  help: {path: "/help", body: null},
  privacy: {path: "/privacy", body: null},
  terms: {path: "/terms", body: null},
} as const satisfies Readonly<Record<string, OwnerGatedLegalPage>>;
