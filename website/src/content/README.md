# Marketing content

This directory is the runtime owner for static, marketing-authored website
copy. Generated organizer/event data, user content, route ids, analytics ids,
URLs, and machine-owned anchors keep their existing owners.

The migration is incremental:

- `meta.json` owns route metadata and static organizer-profile labels now.
- `metaContract.ts` is the browser-safe runtime validator shared by
  `pageMeta.ts`, the Node postbuild reader, tests, and the route gate. Do not
  replace the client validation call with a type assertion.
- Metadata tests run the same valid/invalid fixture matrix through both Ajv
  (`meta.schema.json`) and `metaContract.ts`, preventing editor-schema and
  runtime-validator drift.
- `markets/in.ts` owns India-specific cities, currency, geo-adaptive labels,
  comparison columns, and the coherent example event fixture.
  `markets/index.ts` selects the
  active pack.
- `site.ts` owns site-wide authored labels such as app-store CTA copy. Its
  feature hook owns environment-derived destinations and combines them at the
  adapter boundary; content modules never read `import.meta.env`.
- `legal.json` owns the published `/privacy/`, `/terms/`, and `/help/` document
  content plus confirmed operator, contact, notice-address, court, and grievance
  facts. `legal.ts` exposes the typed content; `site.ts` owns the public contact
  destination and footer links. The published-legal-content test rejects empty
  sections, placeholders, or missing runtime routes.
- Cities are structured records with stable ids/slugs, aliases, IANA timezone,
  and `live`/`waitlist` status. Event-live inventory is derived from status;
  waitlist/host options derive from the configured city records; only the
  featured city has a separate explicit id.
- Page copy will move into page-specific modules in later implementation
  batches after the approved page composition is settled.

Editing rules:

- Change text values, not object keys, ids, tokens, or route paths.
- Keep required template tokens such as `{name}` and `{city}` intact.
- Use `interpolateContent` for templates. It rejects missing, extra, and
  misspelled tokens in both client metadata and static postbuild output.
  Literal templates also enforce their exact token keys at compile time; the
  checked negative cases live in `interpolate.typecheck.ts`.
- Keep city/currency-specific values in the active market pack rather than page
  modules.
- Never publish the internal names “Event Success” or “crushes”.
- Avoid system language such as loop, surface, cohort, signal, projection,
  roster, module, aggregate-safe, mechanic, claim state, and source ledger.
- Avoid dating-app clichés such as “meaningful connections”, “find your
  person”, “spark”, and “journey”.
- Open a pull request and rely on the content, route, typecheck, and build gates
  before publishing.
- Authored data modules do not own JSX, functions, environment reads, or
  imports from feature code. Pure contract helpers such as metadata validation
  and interpolation may export functions, but remain browser-safe and
  side-effect free. The import-boundary gate rejects content `.tsx` modules and
  `import.meta.env` reads.
- The copy-ownership ratchet scans production `.ts` and `.tsx` files,
  including single-word visible labels, accessibility text, copy-bearing data
  fields, interpolated template literals, and validation/status setters.
- Baseline and allowlist entries are exact `(file, text)` contracts. Duplicate,
  overlapping, malformed, unreasoned allowlist, and stale entries fail the gate
  so migration debt must shrink honestly as copy moves here.
