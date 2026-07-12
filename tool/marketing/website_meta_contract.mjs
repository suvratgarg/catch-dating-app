import fs from "node:fs";
import {interpolateContent} from "../../website/src/content/interpolate.ts";
import {
  staticMetaKeys,
  validateWebsiteMeta,
  validatedWebsiteMeta,
} from "../../website/src/content/metaContract.ts";

export {staticMetaKeys, validateWebsiteMeta};

export function readWebsiteMeta(filePath) {
  let value;
  try {
    value = JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch (error) {
    throw new Error(`Unable to read website metadata at ${filePath}: ${error.message}`);
  }
  try {
    return validatedWebsiteMeta(value);
  } catch (error) {
    throw new Error(
      `Website metadata validation failed at ${filePath}:\n` +
        String(error instanceof Error ? error.message : error)
          .replace(/^Website metadata validation failed:\n/u, "")
    );
  }
}

export function formatContentTemplate(template, values) {
  return interpolateContent(template, values);
}

export function staticRouteMeta(content, key, baseUrl) {
  const meta = content.routes[key];
  if (!meta) throw new Error(`Unknown static website metadata key: ${key}`);
  return {
    ...meta,
    canonical: `${String(baseUrl).replace(/\/+$/u, "")}${meta.canonicalPath}`,
  };
}
