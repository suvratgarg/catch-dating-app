#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import zlib from "node:zlib";
import {fromRepo, repoRoot} from "../lib/repo_paths.mjs";

const manifestPath = fromRepo("design/reference_screens/manifest.json");
const args = process.argv.slice(2);
const command = args[0] ?? "--help";

if (command === "--help" || command === "-h" || command === "help") {
  printHelp();
} else if (command === "--check" || command === "check") {
  checkReferences({summary: args.includes("--summary")});
} else if (command === "--summary" || command === "summary") {
  checkReferences({summary: true});
} else if (command === "--compare" || command === "compare") {
  compareReferences();
} else {
  console.error(`Unknown command: ${command}`);
  printHelp();
  process.exit(64);
}

function checkReferences({summary = false} = {}) {
  const {manifest, errors} = validateManifest();
  if (summary || errors.length === 0) printSummary(manifest);
  if (errors.length > 0) {
    console.error("Reference screen check failed:");
    for (const error of errors) console.error(`- ${error}`);
    process.exit(1);
  }
}

function compareReferences() {
  const captureDirArg = valueAfter("--capture-dir");
  if (!captureDirArg) {
    console.error("--compare requires --capture-dir.");
    process.exit(64);
  }

  const {manifest, errors} = validateManifest();
  if (errors.length > 0) {
    console.error("Reference screen check failed:");
    for (const error of errors) console.error(`- ${error}`);
    process.exit(1);
  }

  const captureDir = resolvePath(captureDirArg);
  const layout = valueAfter("--capture-layout") ?? "capture-first";
  const strict = args.includes("--strict");
  let compared = 0;
  let missing = 0;
  let dimensionMismatches = 0;
  let thresholdFailures = 0;

  console.log(`Reference screen comparison: ${path.relative(repoRoot, manifestPath)}`);
  console.log(`Capture directory: ${path.relative(repoRoot, captureDir) || captureDir}`);
  console.log(`Capture layout: ${layout}`);

  for (const ref of manifest.references ?? []) {
    const referencePath = fromRepo(ref.referencePath);
    const capturePath = captureFilePath({captureDir, layout, ref});
    if (!fs.existsSync(capturePath)) {
      missing += 1;
      console.warn(`- ${ref.id}: missing capture ${displayPath(capturePath)}`);
      continue;
    }

    const referencePng = readPng(referencePath);
    const capturePng = readPng(capturePath);
    if (referencePng.width !== capturePng.width || referencePng.height !== capturePng.height) {
      dimensionMismatches += 1;
      console.warn(
        `- ${ref.id}: dimension mismatch reference ${referencePng.width}x${referencePng.height}, capture ${capturePng.width}x${capturePng.height}`
      );
      continue;
    }

    const result = diffPngs({
      reference: referencePng,
      capture: capturePng,
      masks: readMasks(ref),
      perChannelDelta: ref.thresholds?.perChannelDelta ?? 16,
    });
    compared += 1;

    const maxMismatchRatio = ref.thresholds?.maxMismatchRatio ?? 0.18;
    const maxMeanDelta = ref.thresholds?.maxMeanDelta ?? 18;
    const failed =
      result.mismatchRatio > maxMismatchRatio || result.meanDelta > maxMeanDelta;
    if (failed) thresholdFailures += 1;

    const status = failed ? "above advisory threshold" : "within advisory threshold";
    console.log(
      `- ${ref.id}: ${status}; mismatch=${formatPercent(result.mismatchRatio)}, meanDelta=${result.meanDelta.toFixed(2)}, maxDelta=${result.maxDelta}, masked=${result.maskedPixels}`
    );
  }

  console.log(
    `Reference comparisons: ${compared} compared, ${missing} missing captures, ${dimensionMismatches} dimension mismatches, ${thresholdFailures} above threshold.`
  );
  if (strict && thresholdFailures > 0) process.exit(1);
}

function validateManifest() {
  const errors = [];
  if (!fs.existsSync(manifestPath)) {
    return {manifest: null, errors: [`missing manifest ${displayPath(manifestPath)}`]};
  }

  const manifest = readJson(manifestPath);
  if (manifest.version !== 1) errors.push("version must be 1.");
  if (!isDate(manifest.updated)) errors.push("updated must be YYYY-MM-DD.");
  if (!Array.isArray(manifest.references)) {
    errors.push("references must be an array.");
    return {manifest, errors};
  }

  const seen = new Set();
  for (const ref of manifest.references) {
    validateReference(errors, ref, seen);
  }
  return {manifest, errors};
}

function validateReference(errors, ref, seen) {
  const label = ref?.id ?? "<missing reference id>";
  if (!/^[a-z0-9_.-]+$/u.test(label)) errors.push(`${label}: invalid id.`);
  if (seen.has(label)) errors.push(`${label}: duplicate id.`);
  seen.add(label);
  if (!/^screen\.[a-z0-9_.-]+$/u.test(ref?.screenId ?? "")) {
    errors.push(`${label}: screenId must start with screen.`);
  }
  if (!/^[a-z0-9_.-]+$/u.test(ref?.stateId ?? "")) errors.push(`${label}: invalid stateId.`);
  if (!/^[a-z0-9_.-]+$/u.test(ref?.captureId ?? "")) errors.push(`${label}: invalid captureId.`);
  if (!["light", "dark"].includes(ref?.theme)) errors.push(`${label}: theme must be light or dark.`);
  if (typeof ref?.textScale !== "number") errors.push(`${label}: textScale must be numeric.`);
  if (!ref?.referencePath) errors.push(`${label}: referencePath is required.`);
  if (!ref?.source?.path) errors.push(`${label}: source.path is required.`);

  const referencePath = ref?.referencePath ? fromRepo(ref.referencePath) : null;
  if (referencePath && !fs.existsSync(referencePath)) {
    errors.push(`${label}: missing referencePath ${ref.referencePath}.`);
  }
  if (referencePath && fs.existsSync(referencePath)) {
    try {
      const header = readPngHeader(referencePath);
      if (ref.device?.width !== header.width || ref.device?.height !== header.height) {
        errors.push(
          `${label}: device dimensions ${ref.device?.width}x${ref.device?.height} do not match PNG ${header.width}x${header.height}.`
        );
      }
    } catch (error) {
      errors.push(`${label}: ${error.message}`);
    }
  }

  if (ref?.maskPath) {
    const maskPath = fromRepo(ref.maskPath);
    if (!fs.existsSync(maskPath)) {
      errors.push(`${label}: missing maskPath ${ref.maskPath}.`);
    } else {
      validateMasks(errors, label, readJson(maskPath));
    }
  }
}

function validateMasks(errors, label, masks) {
  if (masks.version !== 1) errors.push(`${label}: mask version must be 1.`);
  if (!Array.isArray(masks.regions)) errors.push(`${label}: mask regions must be an array.`);
  for (const region of masks.regions ?? []) {
    const regionLabel = `${label}.mask.${region?.id ?? "<missing region id>"}`;
    if (!/^[a-z0-9_.-]+$/u.test(region?.id ?? "")) errors.push(`${regionLabel}: invalid id.`);
    const rect = region?.rect;
    for (const key of ["x", "y", "width", "height"]) {
      if (!Number.isInteger(rect?.[key]) || rect[key] < 0) {
        errors.push(`${regionLabel}: rect.${key} must be a non-negative integer.`);
      }
    }
  }
}

function printSummary(manifest) {
  const refs = manifest?.references ?? [];
  const screens = new Set(refs.map((ref) => ref.screenId));
  console.log(
    `Reference screens: ${refs.length} references across ${screens.size} screen(s).`
  );
}

function captureFilePath({captureDir, layout, ref}) {
  if (ref.capturePath) return resolvePath(ref.capturePath);
  if (layout === "theme-first") {
    return path.join(captureDir, ref.theme, `${ref.captureId}.png`);
  }
  if (layout === "capture-first") {
    return path.join(captureDir, ref.captureId, `${ref.theme}.png`);
  }
  console.error(`Unknown capture layout: ${layout}`);
  process.exit(64);
}

function readMasks(ref) {
  if (!ref.maskPath) return [];
  const maskData = readJson(fromRepo(ref.maskPath));
  return (maskData.regions ?? [])
    .filter((region) => !region.stateIds || region.stateIds.includes(ref.stateId))
    .map((region) => region.rect);
}

function diffPngs({reference, capture, masks, perChannelDelta}) {
  let comparedPixels = 0;
  let maskedPixels = 0;
  let mismatchedPixels = 0;
  let sumDelta = 0;
  let maxDelta = 0;

  for (let y = 0; y < reference.height; y += 1) {
    for (let x = 0; x < reference.width; x += 1) {
      if (isMasked(x, y, masks)) {
        maskedPixels += 1;
        continue;
      }
      const offset = (y * reference.width + x) * 4;
      let pixelMismatch = false;
      for (let channel = 0; channel < 3; channel += 1) {
        const delta = Math.abs(reference.data[offset + channel] - capture.data[offset + channel]);
        sumDelta += delta;
        if (delta > maxDelta) maxDelta = delta;
        if (delta > perChannelDelta) pixelMismatch = true;
      }
      if (pixelMismatch) mismatchedPixels += 1;
      comparedPixels += 1;
    }
  }

  return {
    comparedPixels,
    maskedPixels,
    mismatchedPixels,
    mismatchRatio: comparedPixels === 0 ? 0 : mismatchedPixels / comparedPixels,
    meanDelta: comparedPixels === 0 ? 0 : sumDelta / (comparedPixels * 3),
    maxDelta,
  };
}

function isMasked(x, y, masks) {
  return masks.some(
    (rect) =>
      x >= rect.x &&
      y >= rect.y &&
      x < rect.x + rect.width &&
      y < rect.y + rect.height
  );
}

function readPng(filePath) {
  const buffer = fs.readFileSync(filePath);
  const chunks = readPngChunks(buffer);
  const ihdr = parseIhdr(chunks.find((chunk) => chunk.type === "IHDR")?.data, filePath);
  if (ihdr.bitDepth !== 8) throw new Error(`${displayPath(filePath)}: only 8-bit PNGs are supported.`);
  if (![2, 6].includes(ihdr.colorType)) {
    throw new Error(`${displayPath(filePath)}: only RGB/RGBA PNGs are supported.`);
  }
  if (ihdr.interlace !== 0) throw new Error(`${displayPath(filePath)}: interlaced PNGs are not supported.`);

  const idat = Buffer.concat(chunks.filter((chunk) => chunk.type === "IDAT").map((chunk) => chunk.data));
  const inflated = zlib.inflateSync(idat);
  const channels = ihdr.colorType === 6 ? 4 : 3;
  const stride = ihdr.width * channels;
  const raw = Buffer.alloc(ihdr.height * stride);
  let src = 0;

  for (let y = 0; y < ihdr.height; y += 1) {
    const filter = inflated[src];
    src += 1;
    const rowStart = y * stride;
    for (let x = 0; x < stride; x += 1) {
      const value = inflated[src + x];
      const left = x >= channels ? raw[rowStart + x - channels] : 0;
      const up = y > 0 ? raw[rowStart + x - stride] : 0;
      const upLeft = y > 0 && x >= channels ? raw[rowStart + x - stride - channels] : 0;
      raw[rowStart + x] = unfilter(filter, value, left, up, upLeft);
    }
    src += stride;
  }

  const rgba = new Uint8Array(ihdr.width * ihdr.height * 4);
  for (let i = 0, p = 0; i < raw.length; i += channels, p += 4) {
    rgba[p] = raw[i];
    rgba[p + 1] = raw[i + 1];
    rgba[p + 2] = raw[i + 2];
    rgba[p + 3] = channels === 4 ? raw[i + 3] : 255;
  }
  return {width: ihdr.width, height: ihdr.height, data: rgba};
}

function readPngHeader(filePath) {
  const buffer = fs.readFileSync(filePath);
  const chunks = readPngChunks(buffer, {stopAfterIhdr: true});
  return parseIhdr(chunks.find((chunk) => chunk.type === "IHDR")?.data, filePath);
}

function readPngChunks(buffer, {stopAfterIhdr = false} = {}) {
  const signature = "89504e470d0a1a0a";
  if (buffer.subarray(0, 8).toString("hex") !== signature) {
    throw new Error("not a PNG file.");
  }
  const chunks = [];
  let offset = 8;
  while (offset < buffer.length) {
    const length = buffer.readUInt32BE(offset);
    const type = buffer.subarray(offset + 4, offset + 8).toString("ascii");
    const data = buffer.subarray(offset + 8, offset + 8 + length);
    chunks.push({type, data});
    offset += 12 + length;
    if (stopAfterIhdr && type === "IHDR") break;
    if (type === "IEND") break;
  }
  return chunks;
}

function parseIhdr(data, filePath) {
  if (!data || data.length !== 13) throw new Error(`${displayPath(filePath)}: missing IHDR.`);
  return {
    width: data.readUInt32BE(0),
    height: data.readUInt32BE(4),
    bitDepth: data[8],
    colorType: data[9],
    compression: data[10],
    filter: data[11],
    interlace: data[12],
  };
}

function unfilter(filter, value, left, up, upLeft) {
  switch (filter) {
    case 0:
      return value;
    case 1:
      return (value + left) & 0xff;
    case 2:
      return (value + up) & 0xff;
    case 3:
      return (value + Math.floor((left + up) / 2)) & 0xff;
    case 4:
      return (value + paeth(left, up, upLeft)) & 0xff;
    default:
      throw new Error(`unsupported PNG filter ${filter}.`);
  }
}

function paeth(left, up, upLeft) {
  const p = left + up - upLeft;
  const pa = Math.abs(p - left);
  const pb = Math.abs(p - up);
  const pc = Math.abs(p - upLeft);
  if (pa <= pb && pa <= pc) return left;
  if (pb <= pc) return up;
  return upLeft;
}

function valueAfter(flag) {
  const index = args.indexOf(flag);
  if (index === -1) return null;
  const value = args[index + 1];
  if (!value || value.startsWith("--")) {
    console.error(`${flag} requires a value.`);
    process.exit(64);
  }
  return value;
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function resolvePath(value) {
  return path.isAbsolute(value) ? value : fromRepo(value);
}

function displayPath(filePath) {
  return path.isAbsolute(filePath) ? path.relative(repoRoot, filePath) || filePath : filePath;
}

function isDate(value) {
  return typeof value === "string" && /^\d{4}-\d{2}-\d{2}$/u.test(value);
}

function formatPercent(value) {
  return `${(value * 100).toFixed(2)}%`;
}

function printHelp() {
  console.log(`Usage:
  node tool/design/check_reference_screens.mjs --check [--summary]
  node tool/design/check_reference_screens.mjs --summary
  node tool/design/check_reference_screens.mjs --compare --capture-dir <dir> [--capture-layout capture-first|theme-first] [--strict]

Validates exported design references under design/reference_screens/. The compare
mode performs an advisory pixel diff against UI capture PNGs. Use --strict only
after masks and thresholds are stable enough to block a gate.`);
}
