import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {TextDecoder} from "node:util";
import {repoRoot} from "./repo_paths.mjs";

const regularModes = new Set(["100644", "100755"]);
const supportedModes = new Set([...regularModes, "120000", "160000"]);
const supportedStageZeroTags = new Set(["H", "S"]);
const utf8Decoder = new TextDecoder("utf-8", {fatal: true});

export class RepositorySnapshotStaleError extends Error {
  constructor(relativePath) {
    super(`Repository path changed after snapshot capture: ${relativePath}.`);
    this.name = "RepositorySnapshotStaleError";
    this.path = relativePath;
  }
}

export function createRepositorySnapshot({
  root = repoRoot,
  gitRunner = defaultGitRunner,
} = {}) {
  const absoluteRoot = path.resolve(root);
  const runGit = (args, {input = null} = {}) => {
    const result = gitRunner(args, {
      cwd: absoluteRoot,
      input,
      env: {
        ...process.env,
        GIT_OPTIONAL_LOCKS: "0",
        GIT_NO_LAZY_FETCH: "1",
      },
    });
    if (result.error) throw result.error;
    if (result.status !== 0) {
      throw new Error(
        bufferText(result.stderr).trim() ||
          `git ${args.join(" ")} failed with status ${result.status}.`,
      );
    }
    return result.stdout ?? Buffer.alloc(0);
  };

  const indexEntries = parseIndexEntries(
    runGit(["ls-files", "-z", "-t", "--stage", "--full-name", "--"]),
  );
  const nestedWorktreePrefixes = nestedRegisteredWorktreePrefixes(
    absoluteRoot,
    parseWorktreePaths(runGit(["worktree", "list", "--porcelain", "-z"])),
  );
  const untrackedPaths = new Set(parseNulPaths(
    runGit(["ls-files", "-z", "--others", "--exclude-standard", "--full-name", "--"]),
    "untracked Git path output",
    {excludedPrefixes: nestedWorktreePrefixes},
  ));
  const blobCache = new Map();
  const pathRecords = capturePathRecords(absoluteRoot, indexEntries, untrackedPaths);
  const capturedPaths = Object.freeze([...pathRecords.keys()].sort());
  const capturedFiles = Object.freeze(capturedPaths.filter((relativePath) => {
    const record = pathRecords.get(relativePath);
    return record.materializedKind === "file" ||
      (record.materializedKind == null && regularModes.has(record.entry?.mode));
  }));
  const capturedRootEntries = captureRootEntries(
    absoluteRoot,
    capturedPaths,
    pathRecords,
  );

  function exists(relativePath) {
    const normalized = normalizeRepositoryPath(relativePath);
    return pathRecords.has(normalized);
  }

  function readText(relativePath, {required = false} = {}) {
    const normalized = normalizeRepositoryPath(relativePath);
    return readTexts([normalized], {required}).get(normalized);
  }

  function readJson(relativePath, {required = false} = {}) {
    const normalized = normalizeRepositoryPath(relativePath);
    const source = readText(normalized, {required});
    if (source == null) return null;
    try {
      return JSON.parse(source);
    } catch (error) {
      throw new Error(`Repository JSON ${normalized} is invalid: ${error.message}`);
    }
  }

  function readTexts(relativePaths, {required = false} = {}) {
    if (typeof relativePaths === "string" || relativePaths?.[Symbol.iterator] == null) {
      throw new Error("Repository readTexts paths must be a non-string iterable.");
    }
    const normalizedPaths = [...new Set(
      [...relativePaths].map(normalizeRepositoryPath),
    )];
    const sources = new Map();
    const uncachedOids = new Set();

    for (const normalized of normalizedPaths) {
      const record = pathRecords.get(normalized);
      if (record == null) {
        if (required) throw new Error(`Required repository path is missing: ${normalized}`);
        sources.set(normalized, null);
        continue;
      }

      if (record.materializedKind != null) {
        const absolutePath = path.join(absoluteRoot, normalized);
        const currentKind = statKind(lstatOrNull(absolutePath));
        if (currentKind !== record.materializedKind) {
          throw new RepositorySnapshotStaleError(normalized);
        }
        if (currentKind !== "file") {
          throw new Error(`Repository path ${normalized} is not a regular text file.`);
        }
        sources.set(normalized, fs.readFileSync(absolutePath));
        continue;
      }

      const {entry} = record;
      if (entry?.skipWorktree === true) {
        if (!regularModes.has(entry.mode)) {
          throw new Error(`Repository path ${normalized} is not a regular text file.`);
        }
        sources.set(normalized, entry.oid);
        if (!blobCache.has(entry.oid)) uncachedOids.add(entry.oid);
        continue;
      }

      if (entry?.mode === "160000") {
        throw new Error(`Repository path ${normalized} is not a regular text file.`);
      }

      if (required) throw new Error(`Required repository path is missing: ${normalized}`);
      sources.set(normalized, null);
    }

    if (uncachedOids.size > 0) {
      const requestedOids = [...uncachedOids];
      let hydrated;
      try {
        hydrated = parseBatchBlobs(
          runGit(["cat-file", "--batch"], {
            input: Buffer.from(`${requestedOids.join("\n")}\n`),
          }),
          requestedOids,
        );
      } catch (error) {
        throw new Error(
          `Sparse-omitted repository content cannot be read from local Git objects: ` +
            error.message,
        );
      }
      for (const [oid, content] of hydrated) blobCache.set(oid, content);
    }

    const result = new Map();
    for (const normalized of normalizedPaths) {
      const source = sources.get(normalized);
      result.set(
        normalized,
        typeof source === "string"
          ? decodeText(blobCache.get(source), normalized)
          : source == null
            ? null
            : decodeText(source, normalized),
      );
    }
    return result;
  }

  function listFiles({prefix = ""} = {}) {
    const normalizedPrefix = normalizeRepositoryPrefix(prefix);
    return capturedFiles.filter((relativePath) => relativePath.startsWith(normalizedPrefix));
  }

  function listPaths({prefix = ""} = {}) {
    const normalizedPrefix = normalizeRepositoryPrefix(prefix);
    return capturedPaths.filter((relativePath) => relativePath.startsWith(normalizedPrefix));
  }

  function listRootEntries() {
    return capturedRootEntries;
  }

  return {
    root: absoluteRoot,
    files: capturedFiles,
    paths: capturedPaths,
    exists,
    listFiles,
    listPaths,
    listRootEntries,
    readText,
    readTexts,
    readJson,
  };
}

export function parseIndexEntries(output) {
  const records = parseNulRecords(output, "Git index output");
  const entries = new Map();
  for (const record of records) {
    const separator = record.indexOf("\t");
    if (separator <= 0 || separator === record.length - 1) {
      throw new Error(`Malformed Git index record: ${JSON.stringify(record)}.`);
    }
    const metadata = record.slice(0, separator);
    const relativePath = normalizeRepositoryPath(record.slice(separator + 1));
    const match = /^([^ ]) ([0-9]+) ([0-9a-f]{40}|[0-9a-f]{64}) ([0-3])$/u.exec(metadata);
    if (!match) {
      throw new Error(`Malformed Git index metadata: ${JSON.stringify(metadata)}.`);
    }
    const [, tag, mode, oid, stage] = match;
    if (stage !== "0") {
      throw new Error(`Repository index has unresolved stage ${stage} for ${relativePath}.`);
    }
    if (!supportedStageZeroTags.has(tag)) {
      throw new Error(`Unsupported Git index tag ${JSON.stringify(tag)} for ${relativePath}.`);
    }
    if (!supportedModes.has(mode)) {
      throw new Error(`Unsupported Git index mode ${mode} for ${relativePath}.`);
    }
    if (entries.has(relativePath)) {
      throw new Error(`Duplicate stage-0 Git index path: ${relativePath}.`);
    }
    entries.set(relativePath, {
      mode,
      oid,
      skipWorktree: tag === "S",
    });
  }
  return entries;
}

export function parseNulPaths(
  output,
  label = "Git path output",
  {excludedPrefixes = []} = {},
) {
  const prefixes = excludedPrefixes.map(normalizeRepositoryPath);
  return parseNulRecords(output, label)
    .filter((relativePath) => {
      const comparable = relativePath.replace(/\/+$/u, "");
      return !prefixes.some((prefix) =>
        comparable === prefix || comparable.startsWith(`${prefix}/`));
    })
    .map(normalizeRepositoryPath);
}

export function parseWorktreePaths(output) {
  return parseNulRecords(output, "Git worktree porcelain output")
    .filter((record) => record.startsWith("worktree "))
    .map((record) => {
      const worktreePath = record.slice("worktree ".length);
      if (worktreePath === "") {
        throw new Error("Git worktree porcelain output contains an empty path.");
      }
      return worktreePath;
    });
}

export function parseBatchBlobs(output, requestedOids) {
  const source = Buffer.isBuffer(output) ? output : Buffer.from(output ?? "");
  const blobs = new Map();
  let offset = 0;
  for (const requestedOid of requestedOids) {
    const lineEnd = source.indexOf(0x0a, offset);
    if (lineEnd < 0) {
      throw new Error(`Missing cat-file batch header for ${requestedOid}.`);
    }
    const header = decodeUtf8(source.subarray(offset, lineEnd), "cat-file batch header");
    if (header === `${requestedOid} missing`) {
      throw new Error(`Local Git object ${requestedOid} is missing.`);
    }
    const match = /^([0-9a-f]+) ([^ ]+) ([0-9]+)$/u.exec(header);
    if (!match || match[1] !== requestedOid) {
      throw new Error(`Malformed cat-file batch header: ${JSON.stringify(header)}.`);
    }
    const [, oid, type, sizeSource] = match;
    if (type !== "blob") {
      throw new Error(`Git object ${oid} has unsupported type ${JSON.stringify(type)}.`);
    }
    const size = Number(sizeSource);
    if (!Number.isSafeInteger(size)) {
      throw new Error(`Git object ${oid} has invalid size ${JSON.stringify(sizeSource)}.`);
    }
    const contentStart = lineEnd + 1;
    const contentEnd = contentStart + size;
    if (contentEnd >= source.length || source[contentEnd] !== 0x0a) {
      throw new Error(`Git object ${oid} has malformed batch framing.`);
    }
    blobs.set(oid, Buffer.from(source.subarray(contentStart, contentEnd)));
    offset = contentEnd + 1;
  }
  if (offset !== source.length) {
    throw new Error("cat-file batch output contains unexpected trailing bytes.");
  }
  return blobs;
}

function parseNulRecords(output, label) {
  const buffer = Buffer.isBuffer(output) ? output : Buffer.from(output ?? "");
  if (buffer.length === 0) return [];
  if (buffer.at(-1) !== 0) throw new Error(`${label} is not NUL terminated.`);
  const records = [];
  let start = 0;
  for (let cursor = 0; cursor < buffer.length; cursor += 1) {
    if (buffer[cursor] !== 0) continue;
    records.push(decodeUtf8(buffer.subarray(start, cursor), label));
    start = cursor + 1;
  }
  return records;
}

function normalizeRepositoryPath(value) {
  if (typeof value !== "string" || value === "" || /[\u0000-\u001f]/u.test(value)) {
    throw new Error(`Invalid repository path: ${JSON.stringify(value)}.`);
  }
  if (path.posix.isAbsolute(value) || value.includes("\\")) {
    throw new Error(`Repository path must be relative and canonical: ${JSON.stringify(value)}.`);
  }
  const segments = value.split("/");
  if (segments.some((segment) => segment === "" || segment === "." || segment === "..")) {
    throw new Error(`Repository path must be relative and canonical: ${JSON.stringify(value)}.`);
  }
  return value;
}

function normalizeRepositoryPrefix(value) {
  if (value === "") return "";
  const withoutSlash = value.endsWith("/") ? value.slice(0, -1) : value;
  return `${normalizeRepositoryPath(withoutSlash)}/`;
}

function lstatOrNull(filePath) {
  try {
    return fs.lstatSync(filePath);
  } catch (error) {
    if (error?.code === "ENOENT" || error?.code === "ENOTDIR") return null;
    throw error;
  }
}

function capturePathRecords(root, indexEntries, untrackedPaths) {
  const records = new Map();
  for (const [relativePath, entry] of indexEntries) {
    const materializedKind = statKind(lstatOrNull(path.join(root, relativePath)));
    if (
      materializedKind != null ||
      entry.skipWorktree ||
      entry.mode === "160000"
    ) {
      records.set(relativePath, {entry, materializedKind});
    }
  }
  for (const relativePath of untrackedPaths) {
    if (indexEntries.has(relativePath)) {
      throw new Error(`Git path appears as both tracked and untracked: ${relativePath}.`);
    }
    const materializedKind = statKind(lstatOrNull(path.join(root, relativePath)));
    if (materializedKind != null) {
      records.set(relativePath, {entry: null, materializedKind});
    }
  }
  return records;
}

function nestedRegisteredWorktreePrefixes(root, worktreePaths) {
  const canonicalRoot = canonicalFilesystemPath(root);
  const prefixes = [];
  for (const worktreePath of worktreePaths) {
    const relativePath = path.relative(
      canonicalRoot,
      canonicalFilesystemPath(worktreePath),
    );
    if (
      relativePath === "" ||
      relativePath.startsWith("..") ||
      path.isAbsolute(relativePath)
    ) continue;
    prefixes.push(normalizeRepositoryPath(relativePath.split(path.sep).join("/")));
  }
  return [...new Set(prefixes)].sort();
}

function canonicalFilesystemPath(value) {
  const absolutePath = path.resolve(value);
  try {
    return fs.realpathSync.native(absolutePath);
  } catch (error) {
    if (error?.code === "ENOENT" || error?.code === "ENOTDIR") return absolutePath;
    throw error;
  }
}

function captureRootEntries(root, capturedPaths, pathRecords) {
  const entries = new Map();
  for (const dirent of fs.readdirSync(root, {withFileTypes: true})) {
    entries.set(dirent.name, direntKind(dirent));
  }
  for (const relativePath of capturedPaths) {
    const separator = relativePath.indexOf("/");
    if (separator >= 0) {
      entries.set(relativePath.slice(0, separator), "directory");
      continue;
    }
    if (entries.has(relativePath)) continue;
    const record = pathRecords.get(relativePath);
    entries.set(
      relativePath,
      record.materializedKind ?? modeKind(record.entry?.mode),
    );
  }
  return Object.freeze([...entries]
    .map(([name, kind]) => Object.freeze({name, kind}))
    .sort((left, right) => left.name.localeCompare(right.name)));
}

function statKind(stat) {
  if (stat == null) return null;
  if (stat.isDirectory()) return "directory";
  if (stat.isFile()) return "file";
  if (stat.isSymbolicLink()) return "symlink";
  return "other";
}

function direntKind(dirent) {
  if (dirent.isDirectory()) return "directory";
  if (dirent.isFile()) return "file";
  if (dirent.isSymbolicLink()) return "symlink";
  return "other";
}

function modeKind(mode) {
  if (regularModes.has(mode)) return "file";
  if (mode === "120000") return "symlink";
  if (mode === "160000") return "directory";
  return "other";
}

function decodeText(buffer, label) {
  const source = Buffer.isBuffer(buffer) ? buffer : Buffer.from(buffer ?? "");
  if (source.includes(0)) throw new Error(`Repository text ${label} contains NUL bytes.`);
  return decodeUtf8(source, label);
}

function decodeUtf8(source, label) {
  try {
    return utf8Decoder.decode(source);
  } catch (error) {
    throw new Error(`Repository text ${label} is not valid UTF-8: ${error.message}`);
  }
}

function bufferText(value) {
  if (value == null) return "";
  try {
    return utf8Decoder.decode(Buffer.isBuffer(value) ? value : Buffer.from(value));
  } catch {
    return String(value);
  }
}

function defaultGitRunner(args, options) {
  return spawnSync("git", args, {
    cwd: options.cwd,
    env: options.env,
    input: options.input,
    maxBuffer: 64 * 1024 * 1024,
  });
}
