# catch-marketing-website

Use when changing the public marketing website, organizer directory/listing
routes, public SEO metadata, marketing media, shared React web config, or
marketing website CI.

Read: `docs/marketing_website_architecture.md`,
`docs/web_surface_architecture.md`,
`docs/marketing_landing_page_research.md`,
`docs/marketing_app_media_pipeline.md`, `website/README.md`,
`packages/web-config/README.md`, `design/website/routes.json`, and
`design/website/components.json`.

Loop:

1. Generate a scoped context pack for the marketing website paths before
   editing.
2. Use `docs/marketing_website_architecture.md` for source layout,
   page/controller/component boundaries, and refactor order.
3. Update `design/website/routes.json` before changing public route, metadata,
   static-output, sitemap, robots, generated listing, or review-state behavior.
4. Update `design/website/components.json` before changing component ownership,
   CSS ownership, or Storybook route/section coverage.
5. Run the route and component contract checks before visual/component review:
   `node tool/run.mjs check marketing:website-routes`.
   `node tool/run.mjs check marketing:website-components`.
6. Run the marketing typecheck/build loop for behavior changes:
   `npm --workspace catch-marketing run typecheck` and
   `npm --workspace catch-marketing run build`.
7. Run `npm --workspace catch-marketing run build:storybook` when Storybook
   stories, component registry entries, or route/section composition changed.
8. Keep website source-of-truth docs, tool manifest entries, CI path filters,
   regression guards, and audit receipts current when enforcement changes.

Current route-first contract: public route ownership lives in
`design/website/routes.json`, is validated by
`tool/marketing/check_website_routes.mjs`, and is enforced in the marketing
workflow before the production build.

Current component-first contract: component ownership lives in
`design/website/components.json`, is validated by
`tool/marketing/check_website_components.mjs`, and attaches route and section
Storybook coverage to the same route ids rather than creating a second
independent website inventory. The first coverage layer is route plus sections,
not small reusable component atoms.

Failure modes to avoid: route metadata drifting from postbuild output, generated
organizer URLs changing without contract review, `noindex`/canonical behavior
hydrating differently from static HTML, CI building after silently mutating
generated listings, component review beginning before public routes have an
owned contract, and Storybook stories drifting from `design/website/components.json`.
