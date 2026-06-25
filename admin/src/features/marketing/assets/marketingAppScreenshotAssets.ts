import type {MarketingAppScreenshotCapture} from "../../../shared/types/adminTypes";

const appScreenshotAssetModules = import.meta.glob(
  "../../../../../website/public/assets/app-screenshots/**/*.{png,svg}",
  {
    eager: true,
    import: "default",
    query: "?url",
  }
) as Record<string, string>;

const rawAppScreenshotAssetModules = import.meta.glob(
  "../../../../../artifacts/marketing/app-screenshots/raw/**/*.{png,svg}",
  {
    eager: true,
    import: "default",
    query: "?url",
  }
) as Record<string, string>;

export function appScreenshotPreviewUrl(
  capture: MarketingAppScreenshotCapture | null | undefined
): string | null {
  if (!capture) return null;
  const candidatePaths = [
    capture.websitePath,
    capture.placeholderPath,
  ].filter(Boolean);

  for (const candidatePath of candidatePaths) {
    const key = toImportKey(candidatePath);
    const assetUrl = appScreenshotAssetModules[key];
    if (assetUrl) return assetUrl;
  }

  return null;
}

export function appScreenshotRawPreviewUrl(
  capture: MarketingAppScreenshotCapture | null | undefined,
  register: "dark" | "light" | "system" = "dark"
): string | null {
  if (!capture?.captureId) return null;
  const tone = register === "light" ? "light" : "dark";
  const fallbackTone = tone === "dark" ? "light" : "dark";
  const candidatePaths = [
    `artifacts/marketing/app-screenshots/raw/${capture.captureId}/${tone}.png`,
    `artifacts/marketing/app-screenshots/raw/${capture.captureId}/${fallbackTone}.png`,
  ];

  for (const candidatePath of candidatePaths) {
    const key = toImportKey(candidatePath);
    const assetUrl = rawAppScreenshotAssetModules[key];
    if (assetUrl) return assetUrl;
  }

  return appScreenshotPreviewUrl(capture);
}

function toImportKey(repoRelativePath: string): string {
  return `../../${repoRelativePath.replace(/^\/+/, "")}`;
}
