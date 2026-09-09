import fs from "node:fs/promises";
import path from "node:path";

/** Collect local contract dependencies once, including fragment references. */
export async function collectSchema(schemaPath, schemas) {
  schemaPath = path.resolve(schemaPath);
  if (schemas.has(schemaPath)) return;
  const schema = JSON.parse(await fs.readFile(schemaPath, "utf8"));
  schemas.set(schemaPath, schema);
  const refs = new Set();
  visit(schema, (ref) => {
    if (!ref.startsWith("#")) refs.add(ref.split("#", 1)[0]);
  });
  for (const relative of refs) {
    await collectSchema(path.resolve(path.dirname(schemaPath), relative), schemas);
  }
}

function visit(value, onRef) {
  if (Array.isArray(value)) {
    value.forEach((entry) => visit(entry, onRef));
    return;
  }
  if (!value || typeof value !== "object") return;
  if (typeof value.$ref === "string") onRef(value.$ref);
  Object.values(value).forEach((entry) => visit(entry, onRef));
}
