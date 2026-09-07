import fs from "node:fs";

function freeze(value) {
  if (value && typeof value === "object") {
    Object.values(value).forEach(freeze);
    Object.freeze(value);
  }
  return value;
}

export const EVENT_ASSISTANCE_DEFINITION = freeze(JSON.parse(
  fs.readFileSync(new URL("./manifest.json", import.meta.url), "utf8")
));
