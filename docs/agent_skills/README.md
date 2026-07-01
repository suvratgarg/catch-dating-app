---
doc_id: agent_skills
version: 1.2.0
updated: 2026-07-01
owner: agent_operating_model
status: active
---

# Agent Skills

These are project-local workflow routers for Catch. They are intentionally
shorter than global Codex or Claude skills. Their job is to route agents to the
right source docs, ledgers, tools, and completion proof for repeated Catch work.

`skills_manifest.json` is the machine-readable source. The markdown files are
human-readable copies for quick review.

Validate this folder with:

```sh
node tool/agent/check_agent_readiness.mjs
```

Do not add broad doctrine here. Add durable architecture decisions to the owner
docs and reference them from the manifest.

Parallel worktree delegation is a workflow router, not a separate architecture
system. Use `catch-parallel-delegation.md` only to route agents to the parent-led
Git/worktree protocol, structured result packet, and metrics recorder.

Marketing website work routes through `catch-marketing-website.md` so public
routes, generated organizer listings, static metadata, CI, and route-review
states stay aligned before component-first review begins.
