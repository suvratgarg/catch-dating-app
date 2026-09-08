export function isComponentSourcePath(value) {
  if (typeof value !== "string" || value.includes("\\")) return false;
  if (value.split("/").some((part) => ["", ".", ".."].includes(part))) return false;
  return /^(?:lib|packages\/catch_ui\/lib)\/.+\.dart$/u.test(value);
}
