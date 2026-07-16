# Catch

Catch is a Flutter dating and social-events product with Firebase backends, a React marketing site, and a separate React admin console.

## Start here

- [AGENTS.md](AGENTS.md): required agent workflow and source-of-truth routing.
- [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md): concise product and repository map.
- [docs/README.md](docs/README.md): canonical documentation index.
- [lib/README.md](lib/README.md): Flutter feature ownership map.
- [firebase/README.md](firebase/README.md): Firebase environment setup.
- [functions/README.md](functions/README.md): Functions architecture and security.
- [TESTS.md](TESTS.md): generated test inventory and test commands.
- [docs/release_operations.md](docs/release_operations.md): build, signing, deploy, and release runbook.

## Local setup

Requirements are pinned in `tool/ci/toolchain.env`. Install Flutter, Node, Java, Firebase CLI, Xcode/CocoaPods for Apple builds, and Android Studio/SDK for Android builds.

```sh
flutter pub get
npm ci
npm --prefix functions ci
cp .env.example .env.local
node tool/agent/check_agent_readiness.mjs
```

Firebase defaults to the development project. Every deployment or remote log command must still name an environment explicitly through `tool/firebase_with_env.sh`; see [firebase/README.md](firebase/README.md).

## Main surfaces

| Surface | Source | Typical local command |
|---|---|---|
| Flutter consumer app | `lib/` | `./tool/flutter_with_env.sh dev run` |
| Flutter host app | `lib/host/` | `./tool/flutter_with_env.sh dev run --target lib/host/main_host.dart` |
| Marketing website | `website/` | `npm run web:marketing:dev` |
| Admin console | `admin/` | `npm run web:admin:dev` |
| Cloud Functions | `functions/` | `npm --prefix functions run build` |
| Widgetbook | `widgetbook/` | `flutter run -d chrome -t widgetbook/main.dart` |

## Core checks

```sh
flutter analyze
flutter test
npm --prefix functions test
npm run web:typecheck
node tool/run.mjs check --manifest-only
node tool/agent/check_agent_readiness.mjs
```

Use `node tool/run.mjs list` to discover governed checks. Data-contract changes must also run `./tool/check_data_contract.sh`.

## Repository housekeeping

Inspect regenerable disk usage without deleting anything:

```sh
npm run repo:hygiene
```

Apply only an explicit scope, for example:

```sh
node tool/repository_hygiene.mjs --apply --scope logs
```

The cleaner is manifest-backed, refuses tracked/protected paths and symlinks, and never invokes `git clean`. See [artifacts/README.md](artifacts/README.md) for evidence retention.

## Secrets and releases

Never commit `.env`, `.env.local`, service-account JSON, signing keys, provisioning profiles, or App Store credentials. `.env.example` documents names only.

Do not deploy with bare `firebase deploy`. Use the guarded environment wrapper and the ordering in [docs/release_operations.md](docs/release_operations.md). Release readiness, signing identity, TestFlight, App Check, and smoke-test evidence live there rather than in this README.
