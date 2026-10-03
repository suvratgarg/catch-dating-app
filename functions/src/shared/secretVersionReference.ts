import * as admin from "firebase-admin";

const unavailable = () => new Error("Secret version reference unavailable.");
const metadataRoot = "http://metadata.google.internal/computeMetadata/v1/" +
  "project/";

export function runtimeProjectId(): string | undefined {
  return process.env.GCLOUD_PROJECT ?? admin.app().options.projectId;
}

/** Runtime metadata proves the project; a stored reference cannot. */
export async function runtimeProjectNumber(projectId: string,
  fetchImpl: typeof fetch = fetch): Promise<string> {
  try {
    const read = async (field: string): Promise<string> => {
      const response = await fetchImpl(metadataRoot + field, {
        headers: {"Metadata-Flavor": "Google"}, redirect: "error",
        signal: AbortSignal.timeout(2000),
      });
      if (!response.ok ||
          response.headers.get("Metadata-Flavor") !== "Google") {
        throw unavailable();
      }
      const value = await response.text();
      if (value.length > 128 || /\s/u.test(value)) throw unavailable();
      return value;
    };
    // The configured project must describe this runtime.
    if (await read("project-id") !== projectId) throw unavailable();
    const number = await read("numeric-project-id");
    if (!/^[1-9][0-9]*$/u.test(number)) throw unavailable();
    return number;
  } catch {
    throw unavailable();
  }
}

/** Numbered references; numeric project aliases need runtime proof. */
export class SecretVersionReferenceGuard {
  private projectNumber?: {projectId: string; value: Promise<string>};

  constructor(private readonly project: () => string | undefined =
  runtimeProjectId,
  private readonly resolveNumber: (projectId: string) => Promise<string> =
  runtimeProjectNumber) {}

  async assert(reference: string, secret: string | RegExp): Promise<void> {
    try {
      const parts = reference.split("/");
      const projectId = this.project();
      if (!projectId || !/^[A-Za-z0-9:-]+$/u.test(projectId) ||
          /\s/u.test(projectId) || /\s/u.test(reference) ||
          parts.length !== 6 || parts[0] !== "projects" ||
          parts[2] !== "secrets" || parts[4] !== "versions" ||
          !/^[A-Za-z0-9_-]{1,255}$/u.test(parts[3]) ||
          !/^[1-9][0-9]*$/u.test(parts[5]) ||
          (typeof secret === "string" ? parts[3] !== secret :
            !secret.test(parts[3]))) throw unavailable();
      if (parts[1] === projectId) return;
      if (!/^[1-9][0-9]*$/u.test(parts[1])) throw unavailable();
      if (this.projectNumber?.projectId !== projectId) {
        this.projectNumber = {projectId, value: this.resolveNumber(projectId)};
      }
      let number: string;
      try {
        number = await this.projectNumber.value;
      } catch {
        this.projectNumber = undefined;
        throw unavailable();
      }
      if (!/^[1-9][0-9]*$/u.test(number) || parts[1] !== number) {
        throw unavailable();
      }
    } catch {
      throw unavailable();
    }
  }
}
