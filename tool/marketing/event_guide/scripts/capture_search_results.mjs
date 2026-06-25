import crypto from "node:crypto";
import {mkdir, readFile, writeFile} from "node:fs/promises";
import path from "node:path";
import {fileURLToPath} from "node:url";

const dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(dirname, "..");

const args = parseArgs(process.argv.slice(2));
const configPath = path.resolve(root, args.config ?? "config/mumbai.weekly-guide.config.json");
const config = JSON.parse(await readFile(configPath, "utf8"));
const week = args.week ?? new Date().toISOString().slice(0, 10);
const provider = args.provider ?? "plan";
const outputPath = path.resolve(
  process.cwd(),
  args.output ?? `tool/marketing/event_guide/generated/${config.city.id}/${week}/captured_source_results.json`
);
const maxQueries = Number(args["max-queries"] ?? config.limits?.maxQueries ?? 8);
const queries = expandQueryTemplates(config).slice(0, maxQueries);

let results;
if (provider === "serpapi") {
  results = await captureSerpApiResults(queries, config);
} else if (provider === "plan") {
  results = queries.map((query) => plannedResult(query));
} else {
  throw new Error(`Unsupported provider: ${provider}`);
}

const packet = {
  $schema: "../schemas/source_results.schema.json",
  city: config.city.id,
  week,
  provider,
  capturedAt: new Date().toISOString(),
  results,
};

await mkdir(path.dirname(outputPath), {recursive: true});
await writeFile(outputPath, `${JSON.stringify(packet, null, 2)}\n`);

console.log(`Captured ${results.length} source result(s): ${outputPath}`);
if (provider === "plan") {
  console.log("Provider plan mode wrote query placeholders only; no network fetches ran.");
}

function parseArgs(rawArgs) {
  const parsed = {};
  for (let index = 0; index < rawArgs.length; index += 1) {
    const arg = rawArgs[index];
    if (!arg.startsWith("--")) continue;
    parsed[arg.slice(2)] = rawArgs[index + 1];
    index += 1;
  }
  return parsed;
}

function expandQueryTemplates(config) {
  const cities = [config.city.label, ...(config.city.aliases ?? [])];
  return config.queryTemplates.flatMap((template) =>
    cities.map((cityLabel) => ({
      ...template,
      cityLabel,
      query: template.template.replaceAll("{city}", cityLabel),
    }))
  );
}

async function captureSerpApiResults(queries, config) {
  const apiKey = process.env.SERPAPI_API_KEY;
  if (!apiKey) {
    throw new Error("SERPAPI_API_KEY is required when --provider serpapi is used.");
  }
  const captured = [];
  for (const query of queries) {
    const url = new URL("https://serpapi.com/search.json");
    url.searchParams.set("engine", "google");
    url.searchParams.set("q", query.query);
    url.searchParams.set("api_key", apiKey);
    url.searchParams.set("hl", "en");
    url.searchParams.set("gl", "in");
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`SerpAPI request failed for ${query.query}: ${response.status}`);
    }
    const payload = await response.json();
    for (const result of payload.organic_results ?? []) {
      const link = result.link ?? result.redirect_link ?? null;
      if (!link) continue;
      captured.push({
        id: sourceResultId(query.id, link),
        sourceProfileId: "search-provider-serpapi",
        sourceLabel: "SerpAPI Google Search",
        queryTemplateId: query.id,
        resultType: "search_result",
        title: String(result.title ?? "Untitled result"),
        url: String(link),
        snippet: String(result.snippet ?? ""),
        observedAt: new Date().toISOString(),
        status: "new",
        riskFlags: [],
        operatorNotes:
          `Captured from query "${query.query}" for ${config.city.label}.`,
      });
    }
  }
  return dedupeByUrl(captured);
}

function plannedResult(query) {
  return {
    id: sourceResultId(query.id, query.query),
    sourceProfileId: "search-provider-plan",
    sourceLabel: "Search provider plan",
    queryTemplateId: query.id,
    resultType: "planned_search_query",
    title: query.query,
    url: `https://www.google.com/search?q=${encodeURIComponent(query.query)}`,
    snippet: query.intent,
    observedAt: new Date().toISOString(),
    status: "new",
    riskFlags: ["planned_no_network_fetch"],
    operatorNotes: "Approve a search provider and rerun capture before extraction.",
  };
}

function sourceResultId(queryId, value) {
  const hash = crypto
    .createHash("sha256")
    .update(`${queryId}:${value}`)
    .digest("hex")
    .slice(0, 10);
  return `src-${queryId}-${hash}`
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function dedupeByUrl(results) {
  const seen = new Set();
  const deduped = [];
  for (const result of results) {
    const key = result.url.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    deduped.push(result);
  }
  return deduped;
}
