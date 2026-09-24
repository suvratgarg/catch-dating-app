import {createHash} from "crypto";
import {HttpsError} from "firebase-functions/v2/https";
import type {OrganizerFormResponseDocument,
  OrganizerFormVersionDocument} from
  "../shared/generated/firestoreAdminTypes";

type Definition = OrganizerFormVersionDocument["definition"];
type Question = Definition["sections"][number]["questions"][number];
type Answer = string | number | boolean | null | string[];

export interface ResponseQueryRow {
  id: string;
  organizerId: string;
  formId: string;
  versionId: string;
  status: "submitted" | "withdrawn";
  submittedAtMillis: number;
  withdrawnAtMillis: number | null;
  identityKind: OrganizerFormResponseDocument["identityKind"];
  identity: OrganizerFormResponseDocument["identity"];
  sourceLinkId: string | null;
  answers: Record<string, Answer>;
}

export type Clause =
  | {questionId: string; op: "present" | "missing"}
  | {questionId: string; op: "choiceAny" | "choiceAll" | "choiceNone";
    values: string[]}
  | {questionId: string; op: "textEquals" | "textContains" |
    "textStartsWith"; value: string}
  | {questionId: string; op: "numberEq" | "numberGt" | "numberGte" |
    "numberLt" | "numberLte"; value: number}
  | {questionId: string; op: "numberBetween";
    minimum: number; maximum: number}
  | {questionId: string; op: "dateOn" | "dateBefore" | "dateAfter";
    value: string}
  | {questionId: string; op: "dateBetween";
    minimum: string; maximum: string}
  | {questionId: string; op: "booleanIs"; value: boolean};

export type Predicate = Clause | {all: Predicate[]} | {any: Predicate[]};

export interface ResponseQuerySpec {
  organizerId: string;
  formId: string;
  versionId: string;
  statuses: Array<"submitted" | "withdrawn">;
  predicate: Predicate | null;
  sort: {questionId: string | null; direction: "asc" | "desc";
    nulls: "first" | "last"};
  limit: number;
  cursor: string | null;
}

export interface CompiledResponseQuery {
  spec: ResponseQuerySpec;
  questions: Map<string, Question>;
  hash: string;
}

export interface ResponseQuerySource {
  /** Must enforce manager authority and exact organizer/form/version scope. */
  readAll(maxRows: number): Promise<ResponseQueryRow[]>;
}

export interface MaterializedResponseQuery {
  rows: ResponseQueryRow[];
  selectedIds: string[];
  resultHash: string;
  queryHash: string;
}

const maxClauses = 20;
const maxDepth = 3;
const maxScanRows = 5_000;
const maxScanBytes = 8 * 1024 * 1024;
const maxPageSize = 100;
const textKinds = new Set(["shortText", "longText", "phone", "email", "url"]);
const choiceKinds = new Set(["singleChoice", "multiChoice"]);
const booleanKinds = new Set(["boolean", "acknowledgement"]);

function invalid(message: string): never {
  throw new HttpsError("invalid-argument", message);
}

function record(value: unknown): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    invalid("Response query must be an object.");
  }
  return value as Record<string, unknown>;
}

function keys(value: Record<string, unknown>, allowed: string[]) {
  if (Object.keys(value).some((key) => !allowed.includes(key))) {
    invalid("Response query contains an unsupported field.");
  }
}

function id(value: unknown): string {
  if (typeof value !== "string" || !/^[A-Za-z0-9_-]{1,128}$/u.test(value)) {
    invalid("Response query has an invalid identifier.");
  }
  return value;
}

function isoDay(value: unknown): string {
  if (typeof value !== "string" || !/^\d{4}-\d{2}-\d{2}$/u.test(value) ||
      !Number.isFinite(Date.parse(`${value}T00:00:00.000Z`)) ||
      new Date(`${value}T00:00:00.000Z`).toISOString().slice(0, 10) !== value) {
    invalid("Response query date must be a valid ISO day.");
  }
  return value;
}

function finite(value: unknown): number {
  if (typeof value !== "number" || !Number.isFinite(value) ||
      Math.abs(value) > 1_000_000_000) {
    invalid("Response query number is invalid.");
  }
  return value;
}

function text(value: unknown): string {
  if (typeof value !== "string" || value.trim().length === 0 ||
      value.length > 200) {
    invalid("Response query text is invalid.");
  }
  return value.trim().toLocaleLowerCase("en");
}

function parsePredicate(value: unknown, questions: Map<string, Question>,
  depth: number, budget: {clauses: number}): Predicate {
  if (depth > maxDepth) invalid("Response query is too deeply nested.");
  const node = record(value);
  if ("all" in node || "any" in node) {
    keys(node, ["all", "any"]);
    if ("all" in node && "any" in node) invalid("Choose ALL or ANY.");
    const op = "all" in node ? "all" : "any";
    const children = node[op];
    if (!Array.isArray(children) || children.length === 0 ||
        children.length > maxClauses) {
      invalid("Response query group size is invalid.");
    }
    const parsed = children.map((child) =>
      parsePredicate(child, questions, depth + 1, budget));
    return {[op]: parsed} as Predicate;
  }
  budget.clauses += 1;
  if (budget.clauses > maxClauses) invalid("Too many response filters.");
  const questionId = id(node.questionId);
  const question = questions.get(questionId);
  if (!question) invalid("Response filter field is not published.");
  if (question.privacyClass === "sensitive") {
    invalid("Sensitive response fields cannot be queried.");
  }
  const op = node.op;
  if (op === "present" || op === "missing") {
    keys(node, ["questionId", "op"]);
    return {questionId, op};
  }
  if (op === "choiceAny" || op === "choiceAll" || op === "choiceNone") {
    keys(node, ["questionId", "op", "values"]);
    if (!choiceKinds.has(question.kind) || !Array.isArray(node.values) ||
        node.values.length === 0 || node.values.length > 20 ||
        node.values.some((item) => typeof item !== "string" ||
          !question.options.some((option) => option.value === item))) {
      invalid("Response choice filter is invalid.");
    }
    return {questionId, op, values: [...new Set(node.values)].sort()};
  }
  if (op === "textEquals" || op === "textContains" ||
      op === "textStartsWith") {
    keys(node, ["questionId", "op", "value"]);
    if (!textKinds.has(question.kind)) invalid("Field is not text.");
    return {questionId, op, value: text(node.value)};
  }
  if (op === "numberEq" || op === "numberGt" || op === "numberGte" ||
      op === "numberLt" || op === "numberLte") {
    keys(node, ["questionId", "op", "value"]);
    if (question.kind !== "number") invalid("Field is not numeric.");
    return {questionId, op, value: finite(node.value)};
  }
  if (op === "numberBetween") {
    keys(node, ["questionId", "op", "minimum", "maximum"]);
    if (question.kind !== "number") invalid("Field is not numeric.");
    const minimum = finite(node.minimum);
    const maximum = finite(node.maximum);
    if (minimum > maximum) invalid("Number range is reversed.");
    return {questionId, op, minimum, maximum};
  }
  if (op === "dateOn" || op === "dateBefore" || op === "dateAfter") {
    keys(node, ["questionId", "op", "value"]);
    if (question.kind !== "date") invalid("Field is not a date.");
    return {questionId, op, value: isoDay(node.value)};
  }
  if (op === "dateBetween") {
    keys(node, ["questionId", "op", "minimum", "maximum"]);
    if (question.kind !== "date") invalid("Field is not a date.");
    const minimum = isoDay(node.minimum);
    const maximum = isoDay(node.maximum);
    if (minimum > maximum) invalid("Date range is reversed.");
    return {questionId, op, minimum, maximum};
  }
  if (op === "booleanIs") {
    keys(node, ["questionId", "op", "value"]);
    if (!booleanKinds.has(question.kind) ||
        typeof node.value !== "boolean") {
      invalid("Field is not boolean.");
    }
    return {questionId, op, value: node.value};
  }
  invalid("Response filter operator is unsupported.");
}

function canonical(node: Predicate | null): Predicate | null {
  if (!node) return null;
  if ("all" in node) {
    return {all: (node.all.map(canonical) as Predicate[])
      .sort((a, b) => JSON.stringify(a).localeCompare(JSON.stringify(b)))};
  }
  if ("any" in node) {
    return {any: (node.any.map(canonical) as Predicate[])
      .sort((a, b) => JSON.stringify(a).localeCompare(JSON.stringify(b)))};
  }
  return node;
}

/** Parses only published fields and bounded, kind-compatible operators. */
export function compileResponseQuery(input: unknown,
  definition: Definition): CompiledResponseQuery {
  const raw = record(input);
  keys(raw, ["organizerId", "formId", "versionId", "statuses",
    "predicate", "sort", "limit", "cursor"]);
  if (!Array.isArray(raw.statuses) || raw.statuses.length === 0 ||
      raw.statuses.length > 2 || raw.statuses.some((status) =>
    status !== "submitted" && status !== "withdrawn")) {
    invalid("Response statuses are invalid.");
  }
  const questions = new Map(definition.sections.flatMap((section) =>
    section.questions).map((question) => [question.questionId, question]));
  const sortRaw = record(raw.sort);
  keys(sortRaw, ["questionId", "direction", "nulls"]);
  const sortId = sortRaw.questionId === null ? null : id(sortRaw.questionId);
  const sortQuestion = sortId ? questions.get(sortId) : null;
  if (sortId && (!sortQuestion || sortQuestion.privacyClass === "sensitive" ||
    !["singleChoice", "shortText",
      "longText", "phone", "email", "url", "number", "date", "boolean",
      "acknowledgement"].includes(sortQuestion.kind))) {
    invalid("Response sort field is not scalar and published.");
  }
  if (sortRaw.direction !== "asc" && sortRaw.direction !== "desc" ||
      sortRaw.nulls !== "first" && sortRaw.nulls !== "last") {
    invalid("Response sort order is invalid.");
  }
  if (!Number.isInteger(raw.limit) || Number(raw.limit) < 1 ||
      Number(raw.limit) > maxPageSize) {
    invalid("Response page size is invalid.");
  }
  if (raw.cursor !== null && (typeof raw.cursor !== "string" ||
      raw.cursor.length > 1000)) {
    invalid("Response cursor is invalid.");
  }
  const predicate = raw.predicate === null ? null :
    parsePredicate(raw.predicate, questions, 1, {clauses: 0});
  const spec: ResponseQuerySpec = {
    organizerId: id(raw.organizerId), formId: id(raw.formId),
    versionId: id(raw.versionId),
    statuses: [...new Set(raw.statuses)].sort(),
    predicate: canonical(predicate),
    sort: {questionId: sortId, direction: sortRaw.direction,
      nulls: sortRaw.nulls},
    limit: Number(raw.limit), cursor: raw.cursor,
  };
  const hash = digest({...spec, limit: undefined, cursor: undefined});
  return {spec, questions, hash};
}

/** Manager-only field choices from an immutable published definition. */
export function responseQueryFieldCatalog(definition: Definition) {
  return definition.sections.flatMap((section) => section.questions)
    .filter((question) => question.privacyClass !== "sensitive")
    .map((question) => {
      const operators = ["present", "missing"];
      if (choiceKinds.has(question.kind)) {
        operators.push("choiceAny", "choiceAll", "choiceNone");
      } else if (textKinds.has(question.kind)) {
        operators.push("textEquals", "textContains", "textStartsWith");
      } else if (question.kind === "number") {
        operators.push("numberEq", "numberGt", "numberGte", "numberLt",
          "numberLte", "numberBetween");
      } else if (question.kind === "date") {
        operators.push("dateOn", "dateBefore", "dateAfter", "dateBetween");
      } else if (booleanKinds.has(question.kind)) {
        operators.push("booleanIs");
      }
      const sortable = ["singleChoice", "shortText", "longText",
        "phone", "email", "url", "number", "date", "boolean",
        "acknowledgement"].includes(question.kind);
      return {questionId: question.questionId, label: question.label,
        kind: question.kind, operators, sortable,
        options: choiceKinds.has(question.kind) ? question.options.map(
          (option) => ({value: option.value, label: option.label})) : []};
    });
}

function digest(value: unknown): string {
  return createHash("sha256").update(JSON.stringify(value)).digest("hex");
}

function answer(row: ResponseQueryRow, questionId: string): Answer | undefined {
  return row.status === "withdrawn" ? undefined : row.answers[questionId];
}

function present(value: Answer | undefined): boolean {
  return value !== undefined && value !== null && value !== "" &&
    (!Array.isArray(value) || value.length > 0);
}

function matches(row: ResponseQueryRow, node: Predicate | null): boolean {
  if (!node) return true;
  if (row.status === "withdrawn") return false;
  if ("all" in node) return node.all.every((child) => matches(row, child));
  if ("any" in node) return node.any.some((child) => matches(row, child));
  const value = answer(row, node.questionId);
  if (node.op === "present") return present(value);
  if (node.op === "missing") return !present(value);
  if (!present(value)) return false;
  if (node.op === "choiceAny" || node.op === "choiceAll" ||
      node.op === "choiceNone") {
    const values = Array.isArray(value) ? value : [value];
    const selected = node.values;
    if (node.op === "choiceAny") {
      return selected.some((v) =>
        values.includes(v));
    }
    if (node.op === "choiceAll") {
      return selected.every((v) =>
        values.includes(v));
    }
    return selected.every((v) => !values.includes(v));
  }
  if (node.op === "textEquals" || node.op === "textContains" ||
      node.op === "textStartsWith") {
    if (typeof value !== "string") return false;
    const normalized = value.trim().toLocaleLowerCase("en");
    if (node.op === "textEquals") return normalized === node.value;
    if (node.op === "textContains") return normalized.includes(node.value);
    return normalized.startsWith(node.value);
  }
  if (node.op === "numberEq" || node.op === "numberGt" ||
      node.op === "numberGte" || node.op === "numberLt" ||
      node.op === "numberLte" || node.op === "numberBetween") {
    if (typeof value !== "number" || !Number.isFinite(value)) return false;
    if (node.op === "numberBetween") {
      return value >= node.minimum && value <= node.maximum;
    }
    if (node.op === "numberEq") return value === node.value;
    if (node.op === "numberGt") return value > node.value;
    if (node.op === "numberGte") return value >= node.value;
    if (node.op === "numberLt") return value < node.value;
    return value <= node.value;
  }
  if (node.op === "dateOn" || node.op === "dateBefore" ||
      node.op === "dateAfter" || node.op === "dateBetween") {
    if (typeof value !== "string" || !/^\d{4}-\d{2}-\d{2}$/u.test(value)) {
      return false;
    }
    if (node.op === "dateBetween") {
      return value >= node.minimum && value <= node.maximum;
    }
    if (node.op === "dateOn") return value === node.value;
    if (node.op === "dateBefore") return value < node.value;
    return value > node.value;
  }
  return node.op === "booleanIs" && typeof value === "boolean" &&
    value === node.value;
}

function sortValue(row: ResponseQueryRow,
  query: CompiledResponseQuery): number | string | boolean | null {
  const questionId = query.spec.sort.questionId;
  if (!questionId) return row.submittedAtMillis;
  const value = answer(row, questionId);
  return typeof value === "number" || typeof value === "boolean" ||
    typeof value === "string" && present(value) ? value : null;
}

function compare(left: ResponseQueryRow, right: ResponseQueryRow,
  query: CompiledResponseQuery): number {
  const a = sortValue(left, query);
  const b = sortValue(right, query);
  if (a === null || b === null) {
    if (a !== b) {
      return a === null ?
        (query.spec.sort.nulls === "first" ? -1 : 1) :
        (query.spec.sort.nulls === "first" ? 1 : -1);
    }
  } else {
    const va = typeof a === "string" ? a.toLocaleLowerCase("en") : a;
    const vb = typeof b === "string" ? b.toLocaleLowerCase("en") : b;
    const order = va < vb ? -1 : va > vb ? 1 : 0;
    if (order) return query.spec.sort.direction === "asc" ? order : -order;
  }
  return left.id.localeCompare(right.id);
}

/** Fully resolves one bounded exact result set for pages, IDs, and export. */
export async function materializeResponseQuery(query: CompiledResponseQuery,
  source: ResponseQuerySource,
  displayContext?: {formTitle: string; version: number}
): Promise<MaterializedResponseQuery> {
  const scanned = await source.readAll(maxScanRows);
  if (scanned.length > maxScanRows) {
    throw new HttpsError("resource-exhausted",
      "This form exceeds the 5,000-response interactive scan limit.");
  }
  if (scanned.some((row) => row.organizerId !== query.spec.organizerId ||
      row.formId !== query.spec.formId ||
      row.versionId !== query.spec.versionId)) {
    throw new HttpsError("permission-denied",
      "Response query source returned an out-of-scope row.");
  }
  let bytes = 0;
  for (const row of scanned) {
    bytes += Buffer.byteLength(JSON.stringify(row), "utf8");
    if (bytes > maxScanBytes) {
      throw new HttpsError("resource-exhausted",
        "Response query exceeds the 8 MiB interactive scan limit.");
    }
  }
  const safeRows = scanned.map((row) => ({...row,
    answers: row.status === "withdrawn" ? {} : Object.fromEntries(
      Object.entries(row.answers).filter(([questionId]) => {
        const question = query.questions.get(questionId);
        return question && question.privacyClass !== "sensitive";
      }))}));
  const resultHash = digest({displayContext, rows: safeRows.map((row) => [
    row.id, row.status, row.submittedAtMillis, row.withdrawnAtMillis,
    row.identityKind, row.identity, row.sourceLinkId, row.answers,
  ])});
  const rows = safeRows.filter((row) =>
    query.spec.statuses.includes(row.status) &&
    matches(row, query.spec.predicate))
    .sort((a, b) => compare(a, b, query));
  return {rows, selectedIds: rows.map((row) => row.id), resultHash,
    queryHash: query.hash};
}

/** Resolves an ID selection only against the same current exact result. */
export function resolveSelectedResponseIds(query: CompiledResponseQuery,
  result: MaterializedResponseQuery, requestedIds: string[],
  expectedResultHash: string): string[] {
  if (result.queryHash !== query.hash ||
      result.resultHash !== expectedResultHash) {
    invalid("Response results changed. Refresh to continue.");
  }
  const selected = new Set(result.selectedIds);
  if (!Array.isArray(requestedIds) || requestedIds.length > maxScanRows ||
      new Set(requestedIds).size !== requestedIds.length ||
      requestedIds.some((value) => typeof value !== "string" ||
        !selected.has(value))) {
    invalid("Selected responses are not in the current query.");
  }
  return requestedIds;
}

export function pageResponseQuery(query: CompiledResponseQuery,
  result: MaterializedResponseQuery): {items: ResponseQueryRow[];
  nextCursor: string | null; total: number} {
  if (result.queryHash !== query.hash) invalid("Response query changed.");
  let offset = 0;
  if (query.spec.cursor) {
    try {
      const cursor = JSON.parse(Buffer.from(query.spec.cursor, "base64url")
        .toString("utf8")) as Record<string, unknown>;
      if (cursor.version !== 1 || cursor.queryHash !== query.hash ||
          cursor.resultHash !== result.resultHash ||
          !Number.isSafeInteger(cursor.offset) || Number(cursor.offset) < 1 ||
          Number(cursor.offset) > result.rows.length) {
        throw new Error("stale");
      }
      offset = Number(cursor.offset);
    } catch {
      invalid("Response results changed. Refresh to continue.");
    }
  }
  const end = Math.min(offset + query.spec.limit, result.rows.length);
  return {items: result.rows.slice(offset, end), total: result.rows.length,
    nextCursor: end < result.rows.length ? Buffer.from(JSON.stringify({
      version: 1, queryHash: query.hash, resultHash: result.resultHash,
      offset: end,
    })).toString("base64url") : null};
}
