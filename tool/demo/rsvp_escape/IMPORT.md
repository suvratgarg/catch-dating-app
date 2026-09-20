# Synthetic spreadsheet import demonstration

This separate local entrypoint loads a real XLSX file through Catch's production
parser and `HostRosterImportSheet`. The confirmed plan is sent to the normal
`importEventAttendeesHandler` and audience projection using an in-memory test
store. It never initializes Firebase Admin, writes a live account or sends a
message. The generic fixture is not a verified Urbanot export.

Prepare a synthetic workbook with first-row column headers, then:

```sh
npm --prefix functions run build
node tool/demo/rsvp_escape/import_server.cjs --verify
node tool/demo/rsvp_escape/import_server.cjs /absolute/path/to/synthetic.xlsx
flutter build web --release --target=tool/demo/rsvp_escape/import_main.dart --output=build/rsvp-import-web
python3 -m http.server 8791 --bind 127.0.0.1 --directory build/rsvp-import-web
```

Open http://127.0.0.1:8791. The API binds only 127.0.0.1:8792. Its only write
operation imports into the fixed synthetic event. Restarting the server clears
the in-memory roster and contacts.

The review sheet exposes ready, needs-review and excluded rows before the
normal handler receives them. The completion page displays the stored roster
and CRM count. Repeat the same import to verify replay without new records.
Missing revenue remains unknown; imported revenue is not a Catch payment.

For coordinated local development only, `CATCH_DEMO_SOURCE_ROOT` may point to
another explicit repository checkout with compiled Functions and dependencies.
The server still uses only an in-memory store. It does not read cloud config,
initialize Firebase Admin or fall back to a live Firestore dependency.
