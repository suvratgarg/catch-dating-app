export const supportedToolPlatforms = Object.freeze([
  "darwin",
  "linux",
  "win32",
]);

export function toolSupportsPlatform(tool, platform = process.platform) {
  return tool.platforms == null || tool.platforms.includes(platform);
}

export function validateToolPlatforms(tool) {
  if (tool.platforms == null) return [];
  if (!Array.isArray(tool.platforms) || tool.platforms.length === 0) {
    return ["platforms must be a non-empty array when declared"];
  }

  const errors = [];
  const uniquePlatforms = new Set(tool.platforms);
  if (uniquePlatforms.size !== tool.platforms.length) {
    errors.push("platforms must not contain duplicates");
  }
  for (const platform of tool.platforms) {
    if (!supportedToolPlatforms.includes(platform)) {
      errors.push(
        `platforms contains unsupported value ${JSON.stringify(platform)}`,
      );
    }
  }
  return errors;
}
