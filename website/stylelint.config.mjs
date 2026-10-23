/**
 * Website CSS takes every color from the generated Catch tokens
 * (packages/web-config/generated/catch-tokens.css) or the --website-*
 * semantics built on them in src/styles/base.css. `color-mix()` over token
 * colors is allowed; literal colors are not.
 */
const rawColorRules = {
  "color-no-hex": true,
  "color-named": "never",
  "function-disallowed-list": ["rgb", "rgba", "hsl", "hsla", "hwb", "lab", "lch", "oklab", "oklch", "color"],
};

/** Stylesheets still on literal colors. Shrink this list; never add to it. */
export const rawColorDebt = [
  "src/styles/event-runtime.css",
  "src/styles/host-landing.css",
  "src/styles/host.css",
  "src/styles/public-forms.css",
];

export default {
  reportDescriptionlessDisables: true,
  reportInvalidScopeDisables: true,
  reportNeedlessDisables: true,
  rules: rawColorRules,
  overrides: [{
    files: rawColorDebt,
    rules: Object.fromEntries(Object.keys(rawColorRules).map((rule) => [rule, null])),
  }],
};
