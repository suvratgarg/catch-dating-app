import {useRef, useState} from "react";
import {ClipboardList, Upload} from "lucide-react";
import {AdminButton, AdminForm, EmptyState, FilePickerButton, Panel,
  SelectField, StateRow, TextField} from "../../../shared/ui/AdminPrimitives";
import {dataMode} from "../../../shared/api/dataMode";
import type {SalesWorkspaceController} from "../controllers/useSalesWorkspaceController";
import type {SalesImportPacket, SalesImportPreview} from "../api/salesTypes";
import {parseSalesCsv, salesImportPacket, type SalesCsvMapping} from "./salesCsv";

const unset: SalesCsvMapping = {organizerId: -1, name: -1, researchStatus: -1,
  summary: -1};

function guessMapping(headers: string[]): SalesCsvMapping {
  const find = (names: string[]) => headers.findIndex((header) =>
    names.includes(header.trim().toLowerCase().replaceAll(/[^a-z0-9]/gu, "")));
  return {organizerId: find(["organizerid", "hostid"]),
    name: find(["name", "hostname", "organizername"]),
    researchStatus: find(["researchstatus", "status"]),
    summary: find(["summary", "notes"])};
}

export function SalesImportWorkspace({controller}: {controller: SalesWorkspaceController}) {
  const [rows, setRows] = useState<string[][]>([]);
  const [fileName, setFileName] = useState("");
  const [sourceId, setSourceId] = useState("");
  const [contentHash, setContentHash] = useState("");
  const [mapping, setMapping] = useState<SalesCsvMapping>(unset);
  const [batch, setBatch] = useState(0);
  const [preview, setPreview] = useState<SalesImportPreview | null>(null);
  const [packet, setPacket] = useState<SalesImportPacket | null>(null);
  const [reviewed, setReviewed] = useState(false);
  const [applied, setApplied] = useState<number[]>([]);
  const [error, setError] = useState("");
  const previewVersion = useRef(0);
  const busy = controller.isSaving || controller.importPreviewPending;
  const batchCount = Math.ceil(Math.max(0, rows.length - 1) / 25);
  const clearPreview = () => {
    previewVersion.current += 1;
    setPreview(null); setPacket(null); setReviewed(false);
  };
  const upload = async (file: File | undefined) => {
    clearPreview(); setRows([]); setApplied([]); setError("");
    setFileName(""); setContentHash("");
    const version = previewVersion.current;
    if (!file) return;
    if (file.size > 1024 * 1024) {
      setError("CSV must be at most 1 MB. Split this file into smaller uploads."); return;
    }
    try {
      const text = await file.text();
      const parsed = parseSalesCsv(text);
      const bytes = await crypto.subtle.digest("SHA-256", await file.arrayBuffer());
      const hash = Array.from(new Uint8Array(bytes), (part) =>
        part.toString(16).padStart(2, "0")).join("");
      if (version !== previewVersion.current) return;
      setRows(parsed); setFileName(file.name); setContentHash(hash);
      setMapping(guessMapping(parsed[0])); setBatch(0);
      setSourceId(file.name.replace(/\.[^.]+$/u, "").replace(/[^A-Za-z0-9._:-]/gu, "-")
        .replace(/^[^A-Za-z0-9]+/u, "").slice(0, 80) || "sales-import");
    } catch (cause) {
      if (version === previewVersion.current) {
        setError(cause instanceof Error ? cause.message : String(cause));
      }
    }
  };
  const inspect = async () => {
    clearPreview(); setError("");
    const version = previewVersion.current;
    try {
      const mapped = salesImportPacket(rows, mapping, sourceId, contentHash, batch);
      const result = await controller.previewImport(mapped);
      if (result && version === previewVersion.current) {
        setPacket(mapped); setPreview(result);
      }
    } catch (cause) {setError(cause instanceof Error ? cause.message : String(cause));}
  };
  const apply = async () => {
    if (!packet || !preview || !reviewed) return;
    const version = previewVersion.current;
    const saved = await controller.applyImport(packet, preview.previewHash);
    if (saved && version === previewVersion.current) {
      setApplied((current) => [...current, batch]); clearPreview();
      if (batch + 1 < batchCount) setBatch(batch + 1);
    }
  };
  const headers = rows[0] ?? [];
  const mappingOptions = [{value: "-1", label: "Not mapped"}, ...headers.map(
    (header, index) => ({value: String(index), label: header || `Column ${index + 1}`}))];
  const mapField = (key: keyof SalesCsvMapping, value: string) => {
    setMapping((current) => ({...current, [key]: Number(value)})); clearPreview();
  };
  return <Panel title="Reviewed CSV import" icon={<ClipboardList size={18} />}>
    <p>Upload a private CSV, map its columns, and review each 25-row batch before
      applying. Unresolved identities stay unresolved; the preview makes no changes.</p>
    {dataMode() === "sample" ? <EmptyState>Imports require a live employee workspace.
      No sample import is applied.</EmptyState> : <>
      <FilePickerButton inputLabel="Choose Sales CSV" accept=".csv,text/csv"
        disabled={busy}
        icon={<Upload size={16} />} onChange={(event) =>
          void upload(event.target.files?.[0])}>Choose CSV</FilePickerButton>
      {fileName ? <p role="status">{fileName} · {rows.length - 1} rows ·
        {batchCount} batch{batchCount === 1 ? "" : "es"}</p> : null}
      {rows.length ? <>
        <TextField label="Import name" value={sourceId}
          disabled={busy}
          onChange={(value) => {setSourceId(value); clearPreview();}} />
        <p>This name keeps batches from the same file together. All columns are
          preserved privately, including columns you do not map below.</p>
        {(["organizerId", "name", "researchStatus", "summary"] as const).map((key) =>
          <SelectField key={key} label={{organizerId: "Existing Catch host ID (optional)",
            name: "Host name", researchStatus: "Previous research status (optional)",
            summary: "Summary"}[key]} value={String(mapping[key])} disabled={busy}
          onChange={(value) => mapField(key, value)} options={mappingOptions} />)}
        <p>If the file has Catch host IDs, select that column. Other rows stay in
          identity review. New hosts begin as Needs research; previous statuses
          are retained as history and do not grant qualification.</p>
        <SelectField label="Batch to review" value={String(batch)}
          disabled={busy}
          onChange={(value) => {setBatch(Number(value)); clearPreview();}}
          options={Array.from({length: batchCount}, (_, index) => ({
            value: String(index), label: `Batch ${index + 1} · rows ${index * 25 + 1}–${
              Math.min((index + 1) * 25, rows.length - 1)}${
              applied.includes(index) ? " · applied" : ""}`,
          }))} />
        <p>Selected batch: {Math.min(25, rows.length - 1 - batch * 25)} rows ·
          {applied.length} of {batchCount} batches applied in this session.</p>
        {rows.slice(1 + batch * 25, 1 + (batch + 1) * 25).map((cells, index) =>
          <StateRow key={batch * 25 + index} label={`Row ${batch * 25 + index + 2}`}
            value={<>{mapping.name >= 0 ? cells[mapping.name] : "Unmapped name"} ·
              {mapping.organizerId >= 0 ? cells[mapping.organizerId] ||
                "Unresolved identity" : "Unresolved identity"} ·
              {mapping.researchStatus >= 0 ? cells[mapping.researchStatus] :
                "Unmapped status"}</>} />)}
        {error ? <p role="alert">{error}</p> : null}
        <AdminButton onClick={() => void inspect()}
          disabled={applied.includes(batch) || controller.importPreviewPending ||
            controller.isSaving}>Preview batch on server</AdminButton>
      </> : error ? <p role="alert">{error}</p> : null}
      {preview ? <>
        <p role="status">Server preview only · effects applied: no ·
          {Object.entries(preview.counts).map(([key, count]) =>
            ` ${key}: ${count}`).join(" ·")}</p>
        {preview.rows.map((row) => <StateRow key={row.sourceRowId}
          label={row.sourceRowId} value={<>{row.organizerId || "Unresolved identity"} ·
            {row.disposition} · {row.reason}</>} />)}
        <AdminForm onSubmit={(event) => {event.preventDefault(); void apply();}}>
          <SelectField label="Review decision" value={reviewed ? "yes" : "no"}
            disabled={busy}
            onChange={(value) => setReviewed(value === "yes")} options={[
              {value: "no", label: "Not reviewed"},
              {value: "yes", label: "I reviewed every row above"},
            ]} />
          <AdminButton type="submit" variant="primary"
            disabled={!reviewed || controller.isSaving}>Apply reviewed batch</AdminButton>
        </AdminForm>
      </> : null}
    </>}
  </Panel>;
}
