/** Explicit public participation declarations only. Format defaults, booking and attendance never qualify. */
export function publicExperienceActivities(value: unknown): Array<"introductions" | "sharedActivities" | "rotations"> {
  if (!Array.isArray(value) || value.length < 1 || value.length > 3 || new Set(value).size !== value.length ||
    !value.every(item => item === "introductions" || item === "sharedActivities" || item === "rotations")) return [];
  return value as Array<"introductions" | "sharedActivities" | "rotations">;
}
