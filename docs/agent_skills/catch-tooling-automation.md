# catch-tooling-automation

Use for repository tooling, scanners, generators, runners, and agent-harness
automation under `tool/`.

Read: `AGENTS.md`, `tool/README.md`, and `docs/agent_operating_model.md`.

Loop: generate a scoped context pack, update the owning implementation and its
focused test, register ownership and CI requirements in
`tool/tools_manifest.json`, run the exact affected checks plus manifest
validation, then run agent readiness before handoff.

Failure modes to avoid: adding an unregistered script, allowing one file to map
to every active tool, using a full-repository fallback for an index-safe check,
or describing enforcement in prose without an executable check and test.
