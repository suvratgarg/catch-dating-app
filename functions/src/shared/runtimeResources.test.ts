import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import {resolve} from "node:path";
import test from "node:test";

// Every function shares one deployment bundle, so index.ts module-scope
// imports land in every container's cold start. The measured baseline already
// exceeds the 256MiB default; the global floor below is what keeps public
// callables from being killed mid-request under default concurrency.
test("shared deployment retains its measured 512MiB memory floor", () => {
  const source = readFileSync(
    resolve(process.cwd(), "src/index.ts"),
    "utf8"
  );
  assert.match(source, /setGlobalOptions\(\{[^}]*memory:\s*"512MiB"/u);
});

// Native and parser-heavy packages must stay behind dynamic imports so they
// never load inside containers that do not call them.
test("heavy media dependencies stay out of the static module graph", () => {
  const heavy = /from "(?:sharp|exceljs|@google-cloud\/vision)"/u;
  for (const file of [
    "src/media/generateAttachedMediaThumbnails.ts",
    "src/moderation/moderatePhoto.ts",
    "src/organizers/generateOrganizerLogoThumbnail.ts",
    "src/organizers/organizerFormExports.ts",
    "src/profiles/formProfilePhoto.ts",
    "src/profiles/generateProfilePhotoThumbnail.ts",
  ]) {
    const source = readFileSync(resolve(process.cwd(), file), "utf8");
    const staticImports = source.split("\n")
      .filter((line) => /^import[ \t]/u.test(line) &&
        !/^import[ \t]+type[ \t]/u.test(line) && heavy.test(line));
    assert.deepEqual(staticImports, [], `${file} statically imports a heavy ` +
      "dependency; keep it behind an in-handler dynamic import");
  }
});
