# Screen Composition Registry

`catch.screens.json` binds each public screen contract to its route inventory,
resolved Dart source, state controller, captures, sections, and three UI
enforcement columns:

- `shell` names the consumer, host, or standalone root and whether a nested
  Scaffold is intentionally allowed;
- `topBar` names the canonical chrome role/expression and owner;
- `statePolicy` names the loading/error/empty/data states the registered screen
  must own.

Run both gates after changing a screen or route composition:

```sh
node tool/design/check_screen_contracts.mjs --check
dart run tool/architecture/check_ui_composition_contracts.dart --check
```

The first checker validates route, capture, state, and component references.
The second resolves every Dart source and fails missing symbols, mismatched
top-bar/state contracts, or increases to the shell-owned nested-Scaffold
ratchet. New screen contracts must add all three enforcement columns in the
same change.
