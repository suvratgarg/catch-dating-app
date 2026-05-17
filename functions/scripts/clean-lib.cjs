const fs = require("node:fs");
const path = require("node:path");

const libDir = path.resolve(__dirname, "..", "lib");
const functionsRoot = path.resolve(__dirname, "..");

if (!libDir.startsWith(functionsRoot + path.sep)) {
  throw new Error(`Refusing to clean unexpected build path: ${libDir}`);
}

fs.rmSync(libDir, {recursive: true, force: true});
