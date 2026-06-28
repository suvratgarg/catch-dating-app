import fs from "node:fs";
import path from "node:path";

const repoRoot = process.cwd();
const claudeRoot =
  process.env.CLAUDE_DS_ROOT ??
  "/Users/suvratgarg/Downloads/Catch Design System (2)";
const outputPath = path.join(
  repoRoot,
  "docs/design_parity/widgetbook_compare.html",
);

const readJson = (filePath) => JSON.parse(fs.readFileSync(filePath, "utf8"));
const fromRepo = (...parts) => path.join(repoRoot, ...parts);
const fromClaude = (...parts) => path.join(claudeRoot, ...parts);

const manifest = readJson(fromClaude("_ds_manifest.json"));
const contracts = readJson(
  fromRepo("design/components/catch.components.json"),
).components;
const widgetbookSource = fs.readFileSync(
  fromRepo("widgetbook/lib/main.directories.g.dart"),
  "utf8",
);
const inventorySource = fs.readFileSync(
  fromRepo("docs/design_parity/claude_widgetbook_inventory.md"),
  "utf8",
);

const canonicalOverrides = {
  ActivityAvatar: {
    id: "catch.person_avatar",
    name: "CatchPersonAvatar",
    bucket: "canonical",
    note: "Use the CatchPersonAvatar activity-context variant; activity avatars are not a separate Flutter primitive.",
  },
  AppBar: {
    id: "catch.top_bar",
    name: "CatchTopBar",
    bucket: "unify",
    note: "Retire AppBar naming to avoid Material AppBar ambiguity.",
  },
  Callout: {
    id: "catch.surface",
    name: "CatchSurface",
    bucket: "canonical",
    note: "Use CatchSurface.message; Callout is not a separate Flutter primitive.",
  },
  InfoGroup: {
    id: "catch.section",
    name: "CatchSection",
    bucket: "canonical",
    note: "Use CatchSection; InfoGroup is a section variant, not a separate primitive.",
  },
  InfoRow: {
    id: "catch.field",
    name: "CatchField",
    bucket: "canonical",
    note: "Use CatchField read/nav/action modes; InfoRow is not a separate primitive.",
  },
  Panel: {
    id: "catch.surface",
    name: "CatchSurface",
    bucket: "canonical",
    note: "Use CatchSurface.card; Panel is not a separate Flutter primitive.",
  },
  SoftBand: {
    id: "catch.surface",
    name: "CatchSurface",
    bucket: "canonical",
    note: "Use CatchSurface.tinted; SoftBand is not a separate Flutter primitive.",
  },
  TextField: {
    id: "catch.field",
    name: "CatchField",
    bucket: "canonical",
    note: "Use CatchField input modes; text input is not a separate Catch primitive.",
  },
  FieldGroup: {
    id: "catch.section",
    name: "CatchSection",
    bucket: "canonical",
    note: "Use CatchSection with contained or divided variants; FieldGroup is not a separate primitive.",
  },
  SegPill: {
    id: "catch.segmented_control",
    name: "CatchSegmentedControl",
    bucket: "unify",
    note: "SegPill is a visual nickname for the segmented control.",
  },
  FacePile: {
    id: "catch.person_avatar_stack",
    name: "CatchPersonAvatarStack",
    bucket: "unify",
    note: "Fold FacePile into the global overlapping-avatar primitive.",
  },
  AvatarStack: {
    id: "catch.person_avatar_stack",
    name: "CatchPersonAvatarStack",
    bucket: "unify",
    note: "Fold AvatarStack into the global overlapping-avatar primitive.",
  },
  Sheet: {
    id: "catch.bottom_sheet",
    name: "CatchBottomSheetScaffold",
    bucket: "unify",
    note: "Use the global sheet concept; Flutter can keep the scaffold implementation name.",
  },
  Stepper: {
    id: "catch.number_stepper",
    name: "CatchNumberStepper",
    bucket: "unify",
    note: "Generic Stepper should not survive as a parallel name.",
  },
  Section: {
    id: "catch.section",
    name: "CatchSection",
    bucket: "canonical",
    note: "CatchSection is the canonical information-grouping primitive.",
  },
  MapPin: {
    id: "catch.activity_map_pin",
    name: "CatchActivityMapPin",
    bucket: "unify",
    note: "The local name makes the activity ownership explicit.",
  },
  EventTicket: {
    id: "catch.event_card",
    name: "CatchEventCard",
    bucket: "canonical",
    note: "Event ticket visuals are variants of the canonical event card primitive.",
    sourcePath: "components/events/EventCard/EventCard.jsx",
  },
  ExpandingSearch: {
    id: "catch.search",
    name: "CatchSearchField",
    bucket: "canonical",
    note: "Use CatchSearchField expanding mode; expanding search is not a separate Flutter primitive.",
  },
  Celebration: {
    id: "catch.celebration",
    name: "CatchCelebrationScreen",
    bucket: "unify",
    note: "Decide whether this is a screen pattern or a reusable celebration primitive.",
  },
  ChatBubble: {
    id: "catch.chat_bubble",
    name: "ChatBubble",
    bucket: "unify",
    note: "Existing local MessageBubble should converge on the design concept name.",
  },
  [["Chat", "List", "Tile"].join("")]: {
    id: "catch.person_row",
    name: "CatchPersonRow",
    bucket: "canonical",
    note: "Chat inbox rows are the chat-preview variant of the canonical person-row primitive.",
    sourcePath: "components/messaging/PersonRow/PersonRow.jsx",
  },
  ChatComposer: {
    id: "catch.chat_composer",
    name: "ChatComposer",
    bucket: "unify",
    note: "Existing local ChatInputBar should converge on the design concept name.",
  },
  ChatThreadHeader: {
    id: "catch.chat_thread_header",
    name: "ChatThreadHeader",
    bucket: "unify",
    note: "Existing local ChatEventContextHeader should converge on the design concept name.",
  },
  ConversationTopBar: {
    id: "catch.catch_top_bar_identity",
    name: "ConversationTopBar",
    bucket: "unify",
    note: "Conversation title/avatar chrome now belongs to CatchTopBar.identity.",
  },
  ClubHero: {
    id: "catch.club_hero",
    name: "ClubHero",
    bucket: "unify",
    note: "Existing local ClubHeroAppBar should converge on the design concept name.",
  },
  BlastComposer: {
    id: "catch.event_broadcast_composer",
    name: "CatchEventBroadcastComposer",
    bucket: "register",
    note: "Prefer descriptive event-scoped broadcast language over Blast shorthand.",
  },
  NeedsYouQueue: {
    id: "catch.needs_you_queue",
    name: "CatchNeedsYouQueue",
    bucket: "register",
    note: "Host Today queue should be globally tracked, even if host-only today.",
  },
  NeedsYouCard: {
    id: "catch.needs_you_card",
    name: "CatchNeedsYouCard",
    bucket: "register",
    note: "Host Today task cards should be globally tracked.",
  },
  NextUpHero: {
    id: "catch.next_up_hero",
    name: "CatchNextUpHero",
    bucket: "register",
    note: "Lifecycle marquee should not stay private to the Today screen.",
  },
  EventLifecycleRow: {
    id: "catch.event_lifecycle_row",
    name: "CatchEventLifecycleRow",
    bucket: "register",
    note: "Event-first lifecycle list row needs a global contract.",
  },
  MetricGrid: {
    id: "catch.metric_grid",
    name: "CatchMetricGrid",
    bucket: "register",
    note: "Private analytics grids should converge on one metric-grid contract.",
  },
  StatStrip: {
    id: "catch.metric_strip",
    name: "CatchMetricStrip",
    bucket: "canonical",
    note: "Use CatchMetricStrip; stat-strip styling is not a separate Flutter primitive.",
  },
  StatCard: {
    id: "catch.stat_card",
    name: "CatchStatCard",
    bucket: "register",
    note: "Metric tile grammar should be tracked separately from the canonical metric rail.",
  },
  TrendStrip: {
    id: "catch.trend_strip",
    name: "CatchTrendStrip",
    bucket: "register",
    note: "Organizer-to-Insights trend teaser needs a global contract.",
  },
  OrganizerHeader: {
    id: "catch.organizer_header",
    name: "CatchOrganizerHeader",
    bucket: "register",
    note: "Organizer identity should replace club/account aliases in host v2.",
  },
  DateRangePicker: {
    id: "catch.date_range_picker",
    name: "CatchDateRangePicker",
    bucket: "register",
    note: "Analytics range control should not stay screen-local.",
  },
  LiveConsole: {
    id: "catch.live_console",
    name: "CatchLiveConsole",
    bucket: "register",
    note: "Manage Live console should be a globally tracked host primitive.",
  },
  RotationCard: {
    id: "catch.rotation_card",
    name: "CatchRotationCard",
    bucket: "register",
    note: "Guided-rotation card should not stay event-success-private.",
  },
};

function snakeCase(value) {
  return value
    .replace(/([a-z0-9])([A-Z])/g, "$1_$2")
    .replace(/[^A-Za-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .toLowerCase();
}

function stripMarkdown(value) {
  return value
    .replace(/`/g, "")
    .replace(/\*\*/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

function extractBackticks(value) {
  return [...value.matchAll(/`([^`]+)`/g)].map((match) => match[1]);
}

function parseInventoryMappings(markdown) {
  const map = new Map();
  for (const line of markdown.split(/\r?\n/u)) {
    if (!line.startsWith("| `")) continue;
    const cells = line
      .split("|")
      .slice(1, -1)
      .map((cell) => cell.trim());
    if (cells.length < 3) continue;
    const claudeTerms = extractBackticks(cells[0]);
    if (claudeTerms.length !== 1) continue;
    const localTerms = extractBackticks(cells[1]);
    const rawLocal = stripMarkdown(cells[1]);
    const rawStatus = stripMarkdown(cells[2]);
    if (claudeTerms[0] === "Claude Design") continue;
    map.set(claudeTerms[0], {
      locals: localTerms.length > 0 ? localTerms : rawLocal ? [rawLocal] : [],
      status: rawStatus,
      rawLocal,
    });
  }
  return map;
}

function parseWidgetbook(source) {
  const components = [];
  const folders = [];
  let pending = null;
  let category = "";
  let currentComponent = null;

  const lines = source.split(/\r?\n/u);
  for (const line of lines) {
    const start = line.match(
      /^(\s*)_widgetbook\.Widgetbook(Category|Folder|Component|UseCase)\(/u,
    );
    if (start) {
      pending = { indent: start[1].length, type: start[2] };
      continue;
    }

    const nameMatch = line.match(/^\s*name: '([^']+)'/u);
    if (!pending || !nameMatch) continue;

    const name = nameMatch[1];
    if (pending.type === "Category") {
      category = name;
      folders.length = 0;
      currentComponent = null;
    } else if (pending.type === "Folder") {
      while (folders.length && folders.at(-1).indent >= pending.indent) {
        folders.pop();
      }
      folders.push({ indent: pending.indent, name });
      currentComponent = null;
    } else if (pending.type === "Component") {
      currentComponent = {
        name,
        category,
        folders: folders.map((folder) => folder.name),
        useCases: [],
      };
      components.push(currentComponent);
    } else if (pending.type === "UseCase" && currentComponent) {
      currentComponent.useCases.push(name);
    }
    pending = null;
  }

  return components;
}

function groupByName(components) {
  const byName = new Map();
  for (const component of components) {
    if (!byName.has(component.name)) byName.set(component.name, []);
    byName.get(component.name).push(component);
  }
  return byName;
}

function contractForClaudeName(name) {
  return contracts.find((contract) => {
    const handoffName = contract.design?.claude?.handoffName;
    return (
      handoffName === name ||
      contract.name === name ||
      contract.name === `Catch${name}` ||
      contract.id === `catch.${snakeCase(name)}`
    );
  });
}

function contractForLocalName(name) {
  return contracts.find((contract) => contract.name === name);
}

function contractForId(id) {
  return contracts.find((contract) => contract.id === id);
}

function componentGroup(component) {
  const match = component.sourcePath?.match(/^components\/([^/]+)\//u);
  return match?.[1] ?? "other";
}

function priorityFor(row) {
  if (row.bucket === "unify") return "P0";
  if (row.bucket === "repair") return "P1";
  if (row.bucket === "register" && ["core", "activity"].includes(row.group)) {
    return "P1";
  }
  if (row.duplicates) return "P1";
  if (row.bucket === "register") return "P2";
  return "P3";
}

const inventoryMappings = parseInventoryMappings(inventorySource);
const widgetbookComponents = parseWidgetbook(widgetbookSource);
const widgetbookByName = groupByName(widgetbookComponents);
const contractNames = new Set(contracts.map((contract) => contract.name));

const rows = manifest.components.map((component) => {
  const name = component.name;
  const group = componentGroup(component);
  const override = canonicalOverrides[name];
  const mapping = inventoryMappings.get(name);
  const effectiveMapping = override?.name
    ? {
        locals: [override.name],
        status: override.note ?? "Canonical override.",
        rawLocal: override.name,
      }
    : mapping;
  const displayName = override?.name ?? name;
  const directNames = [
    name,
    `Catch${name}`,
    ...(effectiveMapping?.locals ?? []),
    ...(override?.name ? [override.name] : []),
  ].filter(Boolean);
  const seen = new Set();
  const matchedWidgets = directNames
    .flatMap((candidate) => widgetbookByName.get(candidate) ?? [])
    .filter((candidate) => {
      const key = `${candidate.category}/${candidate.folders.join("/")}/${
        candidate.name
      }`;
      if (seen.has(key)) return false;
      seen.add(key);
      return true;
    });
  const contract =
    contractForClaudeName(name) ??
    (override?.id ? contractForId(override.id) : null) ??
    (override?.name ? contractForLocalName(override.name) : null) ??
    matchedWidgets.map((widget) => contractForLocalName(widget.name)).find(Boolean);
  const mappingStatus = effectiveMapping?.status?.toLowerCase() ?? "";

  let bucket = "register";
  if (override?.bucket) {
    bucket = override.bucket;
  } else if (mappingStatus.includes("alias")) {
    bucket = "unify";
  } else if (contract && matchedWidgets.length > 0) {
    bucket = "canonical";
  } else if (contract && matchedWidgets.length === 0) {
    bucket = "repair";
  }

  const recommendedId =
    override?.id ?? contract?.id ?? `catch.${snakeCase(name)}`;
  const recommendedName =
    override?.name ?? contract?.name ?? `Catch${name}`;
  const duplicates = matchedWidgets.length > 1;

  return {
    rowType: "claude",
    name: displayName,
    group,
    sourcePath: override?.sourcePath ?? component.sourcePath,
    recommendedId,
    recommendedName,
    bucket,
    priority: "",
    note:
      override?.note ??
      (effectiveMapping?.status
        ? effectiveMapping.status
        : contract
          ? "Formal contract exists."
          : "No formal global contract yet."),
    mapping: effectiveMapping ?? null,
    contract: contract
      ? {
          id: contract.id,
          name: contract.name,
          kind: contract.kind,
          states: contract.contract?.states ?? [],
          file: contract.dart?.file,
        }
      : null,
    widgets: matchedWidgets,
    duplicates,
  };
});

for (const row of rows) row.priority = priorityFor(row);

const mappedWidgetNames = new Set(
  rows.flatMap((row) => row.widgets.map((widget) => widget.name)),
);
const widgetbookOnly = widgetbookComponents
  .filter(
    (component) =>
      !mappedWidgetNames.has(component.name) && !contractNames.has(component.name),
  )
  .map((component) => ({
    rowType: "widgetbook",
    name: component.name,
    group: component.category,
    sourcePath: "",
    recommendedId: `catch.${snakeCase(component.name.replace(/^Catch/u, ""))}`,
    recommendedName: component.name,
    bucket: "register",
    priority: "P2",
    note: "Widgetbook listing has no Claude manifest or formal contract match.",
    mapping: null,
    contract: null,
    widgets: [component],
    duplicates: (widgetbookByName.get(component.name) ?? []).length > 1,
  }));

const contractOnly = contracts
  .filter((contract) => {
    const hasClaude = rows.some((row) => row.contract?.id === contract.id);
    return !hasClaude;
  })
  .map((contract) => ({
    rowType: "contract",
    name: contract.name,
    group: "contracts",
    sourcePath: contract.dart?.file ?? "",
    recommendedId: contract.id,
    recommendedName: contract.name,
    bucket: widgetbookByName.has(contract.name) ? "canonical" : "repair",
    priority: "P1",
    note: "Formal contract is not directly named in the Claude manifest.",
    mapping: null,
    contract: {
      id: contract.id,
      name: contract.name,
      kind: contract.kind,
      states: contract.contract?.states ?? [],
      file: contract.dart?.file,
    },
    widgets: widgetbookByName.get(contract.name) ?? [],
    duplicates: (widgetbookByName.get(contract.name) ?? []).length > 1,
  }));

const allRows = [...rows, ...contractOnly, ...widgetbookOnly].map((row, index) => ({
  ...row,
  id: `${row.rowType}-${row.name}-${index}`,
}));

const summary = {
  generatedAt: new Date().toISOString(),
  claudeRoot,
  claudeComponents: manifest.components.length,
  claudeTemplates: manifest.templates.length,
  widgetbookComponents: widgetbookComponents.length,
  widgetbookUseCases: widgetbookComponents.reduce(
    (total, component) => total + component.useCases.length,
    0,
  ),
  contracts: contracts.length,
  buckets: Object.fromEntries(
    ["canonical", "repair", "unify", "register", "discard"].map((bucket) => [
      bucket,
      allRows.filter((row) => row.bucket === bucket).length,
    ]),
  ),
};

const data = {
  summary,
  rows: allRows,
  groups: [...new Set(allRows.map((row) => row.group))].sort(),
};

function safeJson(value) {
  return JSON.stringify(value).replace(/</g, "\\u003c");
}

function html() {
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Catch Widgetbook Compare</title>
  <style>
    :root {
      --bg: #f5f2ec;
      --paper: #fffaf2;
      --ink: #17130e;
      --muted: #70685e;
      --line: #ded6cb;
      --line-strong: #bbae9e;
      --primary: #111111;
      --ok: #2f6d4f;
      --warn: #a45d19;
      --bad: #9b2f27;
      --blue: #345f88;
      --shadow: 0 18px 50px rgba(23, 19, 14, 0.09);
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
      background: var(--bg);
      color: var(--ink);
      font: 14px/1.45 ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    }
    button, input, select {
      font: inherit;
    }
    .app {
      display: grid;
      grid-template-columns: 320px minmax(0, 1fr);
      min-height: 100vh;
    }
    aside {
      position: sticky;
      top: 0;
      height: 100vh;
      overflow: auto;
      padding: 24px 18px;
      border-right: 1px solid var(--line);
      background: #eee8dd;
    }
    main {
      min-width: 0;
      padding: 28px;
    }
    h1 {
      margin: 0 0 8px;
      font-family: Georgia, "Times New Roman", serif;
      font-size: 30px;
      line-height: 1.05;
      letter-spacing: 0;
    }
    h2 {
      margin: 0 0 10px;
      font-size: 13px;
      text-transform: uppercase;
      letter-spacing: 0.08em;
    }
    p {
      margin: 0;
      color: var(--muted);
    }
    .source {
      overflow-wrap: anywhere;
      font-size: 12px;
      color: var(--muted);
      margin-top: 8px;
    }
    .stats {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 10px;
      margin: 22px 0;
    }
    .stat {
      padding: 12px;
      border: 1px solid var(--line);
      background: rgba(255, 250, 242, 0.72);
    }
    .stat strong {
      display: block;
      font-size: 22px;
      line-height: 1;
    }
    .stat span {
      display: block;
      margin-top: 6px;
      color: var(--muted);
      font-size: 12px;
    }
    .controls {
      display: grid;
      gap: 10px;
      margin-top: 18px;
    }
    .controls input,
    .controls select {
      width: 100%;
      border: 1px solid var(--line-strong);
      background: var(--paper);
      color: var(--ink);
      padding: 10px 11px;
      border-radius: 0;
    }
    .button-row {
      display: flex;
      flex-wrap: wrap;
      gap: 7px;
    }
    .filter-button,
    .decision-button,
    .download {
      border: 1px solid var(--line-strong);
      background: var(--paper);
      color: var(--ink);
      padding: 8px 10px;
      border-radius: 999px;
      cursor: pointer;
      min-height: 34px;
    }
    .filter-button.active,
    .decision-button.active {
      background: var(--ink);
      color: var(--paper);
      border-color: var(--ink);
    }
    .download {
      width: 100%;
      margin-top: 12px;
      border-radius: 0;
      background: var(--ink);
      color: var(--paper);
    }
    .legend {
      display: grid;
      gap: 8px;
      margin-top: 20px;
      font-size: 12px;
      color: var(--muted);
    }
    .legend b { color: var(--ink); }
    .topline {
      display: flex;
      justify-content: space-between;
      align-items: flex-end;
      gap: 16px;
      margin-bottom: 18px;
    }
    .count {
      color: var(--muted);
      white-space: nowrap;
    }
    .rows {
      display: grid;
      gap: 14px;
    }
    .row {
      border: 1px solid var(--line);
      background: var(--paper);
      box-shadow: var(--shadow);
    }
    .row-head {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
      padding: 12px 14px;
      border-bottom: 1px solid var(--line);
      background: rgba(238, 232, 221, 0.55);
    }
    .row-title {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 8px;
      min-width: 0;
    }
    .row-title strong {
      font-size: 16px;
    }
    .pill {
      display: inline-flex;
      align-items: center;
      min-height: 24px;
      padding: 3px 8px;
      border: 1px solid var(--line-strong);
      border-radius: 999px;
      font-size: 12px;
      color: var(--muted);
      background: rgba(255, 255, 255, 0.36);
    }
    .bucket-canonical { color: var(--ok); border-color: rgba(47, 109, 79, 0.35); }
    .bucket-repair { color: var(--warn); border-color: rgba(164, 93, 25, 0.35); }
    .bucket-unify { color: var(--blue); border-color: rgba(52, 95, 136, 0.38); }
    .bucket-register { color: var(--bad); border-color: rgba(155, 47, 39, 0.34); }
    .bucket-discard { color: #5c5349; border-color: rgba(92, 83, 73, 0.36); }
    .compare {
      display: grid;
      grid-template-columns: minmax(0, 1fr) minmax(0, 1.15fr);
      min-height: 220px;
    }
    .pane {
      padding: 16px;
      min-width: 0;
    }
    .pane + .pane {
      border-left: 1px solid var(--line);
      background: #fffdf8;
    }
    .pane-title {
      display: flex;
      justify-content: space-between;
      gap: 12px;
      margin-bottom: 12px;
      color: var(--muted);
      font-size: 12px;
      text-transform: uppercase;
      letter-spacing: 0.08em;
    }
    .big-name {
      font-size: 22px;
      font-weight: 700;
      line-height: 1.1;
      overflow-wrap: anywhere;
    }
    .meta {
      display: grid;
      gap: 6px;
      margin-top: 12px;
      color: var(--muted);
      font-size: 13px;
    }
    code {
      padding: 2px 5px;
      background: #eee8dd;
      border: 1px solid var(--line);
      color: var(--ink);
      font-family: "SF Mono", ui-monospace, Menlo, Consolas, monospace;
      font-size: 12px;
    }
    .widget-list,
    .state-list {
      display: grid;
      gap: 8px;
      margin-top: 12px;
    }
    .widget {
      border: 1px solid var(--line);
      padding: 10px;
      background: var(--paper);
    }
    .widget strong {
      display: block;
    }
    .widget small {
      display: block;
      color: var(--muted);
      margin-top: 4px;
    }
    .states {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
      margin-top: 8px;
    }
    .state {
      padding: 3px 7px;
      border-radius: 999px;
      background: #eee8dd;
      color: var(--muted);
      font-size: 12px;
    }
    .decision-bar {
      padding: 12px 14px;
      border-top: 1px solid var(--line);
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
      flex-wrap: wrap;
    }
    .empty {
      color: var(--muted);
      border: 1px dashed var(--line-strong);
      padding: 14px;
      background: rgba(238, 232, 221, 0.45);
    }
    @media (max-width: 980px) {
      .app { grid-template-columns: 1fr; }
      aside {
        position: static;
        height: auto;
        border-right: 0;
        border-bottom: 1px solid var(--line);
      }
      .compare { grid-template-columns: 1fr; }
      .pane + .pane {
        border-left: 0;
        border-top: 1px solid var(--line);
      }
      main { padding: 18px; }
    }
  </style>
</head>
<body>
  <script id="payload" type="application/json">${safeJson(data)}</script>
  <div class="app">
    <aside>
      <h1>Widgetbook Compare</h1>
      <p>Claude design symbols beside current Widgetbook listings and global contracts.</p>
      <div class="source">${claudeRoot}</div>
      <div class="stats" id="stats"></div>
      <div class="controls">
        <input id="search" type="search" placeholder="Search components, paths, states">
        <select id="group"></select>
        <select id="priority">
          <option value="">All priorities</option>
          <option value="P0">P0 first</option>
          <option value="P1">P1</option>
          <option value="P2">P2</option>
          <option value="P3">P3</option>
        </select>
        <div class="button-row" id="bucketFilters"></div>
        <button class="download" id="download">Download review decisions</button>
      </div>
      <div class="legend">
        <div><b>canonical</b> means the concept already has a plausible global name, contract, and listing.</div>
        <div><b>unify</b> means duplicate naming exists and needs one canonical name.</div>
        <div><b>register</b> means the concept is valid but not globally tracked yet.</div>
        <div><b>repair</b> means the concept exists but the registry/listing/source relationship is suspect.</div>
      </div>
    </aside>
    <main>
      <div class="topline">
        <div>
          <h2>Review Queue</h2>
          <p>Pick a decision per row. Decisions are saved in this browser and can be exported.</p>
        </div>
        <div class="count" id="count"></div>
      </div>
      <div class="rows" id="rows"></div>
    </main>
  </div>
  <script>
    const payload = JSON.parse(document.getElementById("payload").textContent);
    const rowsEl = document.getElementById("rows");
    const countEl = document.getElementById("count");
    const searchEl = document.getElementById("search");
    const groupEl = document.getElementById("group");
    const priorityEl = document.getElementById("priority");
    const bucketFiltersEl = document.getElementById("bucketFilters");
    const statsEl = document.getElementById("stats");
    const decisionsKey = "catch-widgetbook-compare-decisions";
    let bucketFilter = "";
    let decisions = JSON.parse(localStorage.getItem(decisionsKey) || "{}");

    const buckets = ["", "unify", "register", "repair", "canonical", "discard"];
    const decisionOptions = ["approved", "rename", "not same", "visual first", "discard"];

    function esc(value) {
      return String(value ?? "")
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll('"', "&quot;");
    }

    function searchable(row) {
      return [
        row.name,
        row.group,
        row.sourcePath,
        row.recommendedId,
        row.recommendedName,
        row.bucket,
        row.note,
        row.contract?.id,
        row.contract?.name,
        row.contract?.states?.join(" "),
        row.widgets.map((widget) => [widget.name, widget.category, widget.folders.join(" "), widget.useCases.join(" ")].join(" ")).join(" "),
      ].join(" ").toLowerCase();
    }

    function saveDecision(id, value) {
      if (!value) delete decisions[id];
      else decisions[id] = { value, savedAt: new Date().toISOString() };
      localStorage.setItem(decisionsKey, JSON.stringify(decisions));
      render();
    }

    function renderStats() {
      const items = [
        [payload.summary.claudeComponents, "Claude symbols"],
        [payload.summary.widgetbookComponents, "Widgetbook listings"],
        [payload.summary.widgetbookUseCases, "Widgetbook use cases"],
        [payload.summary.contracts, "Global contracts"],
      ];
      statsEl.innerHTML = items
        .map(([value, label]) => '<div class="stat"><strong>' + esc(value) + '</strong><span>' + esc(label) + '</span></div>')
        .join("");
    }

    function renderControls() {
      groupEl.innerHTML = '<option value="">All groups</option>' + payload.groups.map((group) => '<option value="' + esc(group) + '">' + esc(group) + '</option>').join("");
      bucketFiltersEl.innerHTML = buckets.map((bucket) => {
        const label = bucket || "all";
        return '<button class="filter-button ' + (bucketFilter === bucket ? "active" : "") + '" data-bucket="' + esc(bucket) + '">' + esc(label) + '</button>';
      }).join("");
      bucketFiltersEl.querySelectorAll("button").forEach((button) => {
        button.addEventListener("click", () => {
          bucketFilter = button.dataset.bucket;
          renderControls();
          render();
        });
      });
    }

    function widgetHtml(widget) {
      const path = [widget.category, ...widget.folders].filter(Boolean).join(" / ");
      const useCases = widget.useCases.length ? widget.useCases.join(", ") : "No use cases parsed";
      return '<div class="widget"><strong>' + esc(widget.name) + '</strong><small>' + esc(path) + '</small><small>Use cases: ' + esc(useCases) + '</small></div>';
    }

    function rowHtml(row) {
      const decision = decisions[row.id]?.value || "";
      const states = row.contract?.states ?? [];
      const duplicatePill = row.duplicates ? '<span class="pill bucket-repair">duplicate listings</span>' : "";
      const contractPane = row.contract
        ? '<div class="meta"><div>Contract: <code>' + esc(row.contract.id) + '</code></div><div>Kind: ' + esc(row.contract.kind) + '</div><div>File: <code>' + esc(row.contract.file) + '</code></div></div><div class="states">' + states.map((state) => '<span class="state">' + esc(state) + '</span>').join("") + '</div>'
        : '<div class="empty">No formal contract found.</div>';
      const widgetPane = row.widgets.length
        ? '<div class="widget-list">' + row.widgets.map(widgetHtml).join("") + '</div>'
        : '<div class="empty">No Widgetbook listing found.</div>';
      const buttons = decisionOptions.map((option) => {
        return '<button class="decision-button ' + (decision === option ? "active" : "") + '" data-id="' + esc(row.id) + '" data-decision="' + esc(option) + '">' + esc(option) + '</button>';
      }).join("");
      return '<article class="row">' +
        '<div class="row-head"><div class="row-title"><strong>' + esc(row.name) + '</strong><span class="pill">' + esc(row.group) + '</span><span class="pill">' + esc(row.priority) + '</span><span class="pill bucket-' + esc(row.bucket) + '">' + esc(row.bucket) + '</span>' + duplicatePill + '</div><div><code>' + esc(row.recommendedId) + '</code></div></div>' +
        '<div class="compare">' +
        '<section class="pane"><div class="pane-title"><span>Claude / Source</span><span>' + esc(row.rowType) + '</span></div><div class="big-name">' + esc(row.name) + '</div><div class="meta"><div>Source: <code>' + esc(row.sourcePath || "none") + '</code></div><div>Recommended Flutter: <code>' + esc(row.recommendedName) + '</code></div><div>Recommendation: ' + esc(row.note) + '</div></div></section>' +
        '<section class="pane"><div class="pane-title"><span>Widgetbook / Contract</span><span>' + esc(row.widgets.length) + ' listing(s)</span></div>' + contractPane + widgetPane + '</section>' +
        '</div>' +
        '<div class="decision-bar"><div class="button-row">' + buttons + '</div><div class="count">' + (decision ? "Saved: " + esc(decision) : "No decision") + '</div></div>' +
        '</article>';
    }

    function filteredRows() {
      const search = searchEl.value.trim().toLowerCase();
      const group = groupEl.value;
      const priority = priorityEl.value;
      return payload.rows.filter((row) => {
        if (bucketFilter && row.bucket !== bucketFilter) return false;
        if (group && row.group !== group) return false;
        if (priority && row.priority !== priority) return false;
        if (search && !searchable(row).includes(search)) return false;
        return true;
      });
    }

    function render() {
      const rows = filteredRows();
      countEl.textContent = rows.length + " of " + payload.rows.length + " rows";
      rowsEl.innerHTML = rows.map(rowHtml).join("") || '<div class="empty">No rows match the current filters.</div>';
      rowsEl.querySelectorAll(".decision-button").forEach((button) => {
        button.addEventListener("click", () => {
          const active = decisions[button.dataset.id]?.value === button.dataset.decision;
          saveDecision(button.dataset.id, active ? "" : button.dataset.decision);
        });
      });
    }

    document.getElementById("download").addEventListener("click", () => {
      const selected = payload.rows
        .filter((row) => decisions[row.id])
        .map((row) => ({
          id: row.id,
          name: row.name,
          group: row.group,
          recommendedId: row.recommendedId,
          recommendedName: row.recommendedName,
          bucket: row.bucket,
          decision: decisions[row.id].value,
          savedAt: decisions[row.id].savedAt,
        }));
      const blob = new Blob([JSON.stringify(selected, null, 2)], { type: "application/json" });
      const url = URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      link.download = "catch-widgetbook-decisions.json";
      link.click();
      URL.revokeObjectURL(url);
    });

    searchEl.addEventListener("input", render);
    groupEl.addEventListener("change", render);
    priorityEl.addEventListener("change", render);
    renderStats();
    renderControls();
    render();
  </script>
</body>
</html>`;
}

fs.writeFileSync(outputPath, html());
console.log(`Wrote ${path.relative(repoRoot, outputPath)}`);
console.log(
  `Rows: ${allRows.length} | Claude: ${manifest.components.length} | Widgetbook: ${widgetbookComponents.length} | Contracts: ${contracts.length}`,
);
