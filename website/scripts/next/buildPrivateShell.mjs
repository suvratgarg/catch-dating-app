import {build} from "vite";
import react from "@vitejs/plugin-react";
import {cp, mkdir, readFile, writeFile} from "node:fs/promises";
import path from "node:path";
import {fileURLToPath} from "node:url";
const root = fileURLToPath(new URL("../../", import.meta.url));
const out = path.join(root, ".next-legacy");
await build({root, configFile: false, plugins: [react(), {name: "request-time-organizers", enforce: "pre", resolveId(source, importer) {
    if (importer && path.resolve(path.dirname(importer), source).replace(/\.ts$/, "") === path.join(root, "src/features/organizers/data")) {
      return path.join(root, "src/features/organizers/emptyData.ts");
    }
  }}], publicDir: false,
  base: "/_legacy/", resolve: {alias: [
    {find: "@content", replacement: path.join(root, "src/content")},
  ]}, build: {outDir: out, emptyOutDir: true}});
const destination = path.join(root, "public/_legacy");
await mkdir(destination, {recursive: true});
await cp(path.join(out, "assets"), path.join(destination, "assets"), {recursive: true});
const built = await readFile(path.join(out, "index.html"), "utf8");
// A fixed empty shell: bearer path/query/fragment values never enter server HTML.
const assets = built.match(/<(?:script|link)[^>]*(?:src|href)="\/_legacy\/assets\/[^>]+>(?:<\/script>)?/g) ?? [];
await writeFile(path.join(destination, "index.html"), `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex,nofollow"><meta name="referrer" content="no-referrer"><title>Catch</title>${assets.join("")}</head><body><div id="root"></div></body></html>`);
