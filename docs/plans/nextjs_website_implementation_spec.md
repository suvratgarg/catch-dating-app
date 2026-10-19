---
doc_id: nextjs_website_implementation_spec
version: 0.2.0
updated: 2026-10-19
owner: marketing_website
status: superseded
---

# Next.js implementation proposal — superseded

The initial Group A specification was written before implementation and remains
available in Git history. Its implemented decisions now live in the existing
owners, rather than a parallel architecture document:

- [Marketing website architecture](../marketing_website_architecture.md#nextjs-public-rendering-migration): route composition, server publication policy, public DTOs, freshness, private shells and checks.
- [Web surface architecture](../web_surface_architecture.md#nextjs-candidate-and-cutover-boundary): standalone runtime, identity, Hosting integration and the explicit preview/cutover boundary.
- [Website runbook](../../website/README.md#nextjs-candidate): build, isolated emulator acceptance and container packaging.

The approved [decision brief](https://chatgpt.com/space/page_4d48e536e9908191b1ba53c6c47a6e38)
remains the product-scope reference. This work retains Firestore, existing
Functions, Flutter, public content and browser flows. It does not authorize
PostgreSQL, backend/payment-rule rewrites, new private browser journeys,
provider activation, paid infrastructure, DNS changes or production cutover.

The source is a migration candidate, not a deployed release. Exact-head CI,
container execution, a configured cloud preview, performance/accessibility
acceptance and real Auth/App Check/payment/native handoffs remain release gates.
The guarded Next.js worktree remains owned until accepted closeout. Ownership
transfer approval preserved the previous branches/worktrees; queue admission
continues to belong to the merge coordinator.
