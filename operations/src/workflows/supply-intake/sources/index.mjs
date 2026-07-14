import fs from "node:fs/promises";
import path from "node:path";
import {fileURLToPath} from "node:url";

const directory = path.dirname(fileURLToPath(import.meta.url));

export async function loadSourceProfiles() {
  const profiles = await Promise.all(["luma", "cntraveller"].map(async (id) =>
    JSON.parse(await fs.readFile(path.join(directory, id, "profile.json"), "utf8"))
  ));
  return profiles.sort((left, right) => left.sourceProfileId.localeCompare(right.sourceProfileId));
}

export function sourceProfileById(profiles, id) {
  return profiles.find((profile) => profile.sourceProfileId === id) ?? null;
}
