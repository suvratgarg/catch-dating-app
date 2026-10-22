// @vitest-environment node
import fs from "node:fs";
import {fileURLToPath} from "node:url";
import {describe, expect, it} from "vitest";

// The Flutter implementation is the reference (blueprint D11). These tests
// read its sources so a web role cannot drift from the Flutter role it names.
const read = (relative: string) =>
  fs.readFileSync(fileURLToPath(new URL(relative, import.meta.url)), "utf8");

const gapsDart = read("../../../catch_tokens/lib/src/semantic/catch_gaps.dart");
const insetsDart = read("../../../catch_tokens/lib/src/semantic/catch_insets.dart");
const textStylesDart = read("../../../catch_ui/lib/src/foundations/catch_text_styles.dart");
const foundationsCss = read("../foundations.css");
const gapCss = read("./CatchGap.module.css");
const sectionListCss = read("./CatchSectionList.module.css");
const insetCss = read("./CatchInset.module.css");
const textCss = read("./CatchText.module.css");

const kebab = (name: string) => name.replace(/[A-Z]/g, (letter) => `-${letter.toLowerCase()}`);

function cssRule(css: string, selector: string) {
  const start = css.indexOf(`${selector} {`);
  expect(start, `missing CSS rule ${selector}`).toBeGreaterThanOrEqual(0);
  return css.slice(start, css.indexOf("}", start));
}

function declaration(rule: string, property: string) {
  const match = rule.match(new RegExp(`(?:^|[\\s{;])${property}:\\s*([^;]+);`));
  return match?.[1].replace(/\s+/g, " ").trim();
}

function selectorValues(css: string, attribute: string) {
  return [...css.matchAll(new RegExp(`\\[data-${attribute}="([A-Za-z]+)"\\]`, "g"))]
    .map((match) => match[1]);
}

describe("CatchGaps parity", () => {
  const dartGaps = Object.fromEntries(
    [...gapsDart.matchAll(/static const double (\w+) = CatchSpacing\.(\w+);/g)]
      .map((match) => [match[1], match[2]]),
  );

  it("declares every Flutter gap role with the same spacing step", () => {
    expect(Object.keys(dartGaps).length).toBeGreaterThan(0);
    for (const [role, step] of Object.entries(dartGaps)) {
      expect(foundationsCss).toContain(`--catch-gap-${kebab(role)}: var(--catch-space-${step});`);
    }
  });

  it("offers exactly the Flutter gap roles on CatchGap and CatchSectionList", () => {
    const roles = Object.keys(dartGaps).sort();
    expect(selectorValues(gapCss, "size").sort()).toEqual(roles);
    expect(selectorValues(sectionListCss, "gap").sort()).toEqual(roles);
  });
});

describe("CatchInsets parity", () => {
  type Edges = [string, string, string, string];
  const step = (token: string) => {
    const trimmed = token.trim();
    if (trimmed === "CatchSpacing.screenPx") return "pageGutter";
    const match = trimmed.match(/^CatchSpacing\.(\w+)$/);
    expect(match, `unsupported inset value ${trimmed}`).not.toBeNull();
    return match![1];
  };

  function dartEdges(role: string): Edges {
    const match = insetsDart.match(
      new RegExp(`static const EdgeInsets ${role} = EdgeInsets\\.(\\w+)\\(([^;]*)\\);`),
    );
    expect(match, `missing CatchInsets.${role}`).not.toBeNull();
    const [, kind, rawArgs] = match!;
    const args = rawArgs.split(",").map((arg) => arg.trim()).filter(Boolean);
    if (kind === "all") {
      const value = step(args[0]);
      return [value, value, value, value];
    }
    if (kind === "fromLTRB") {
      const [left, top, right, bottom] = args.map(step);
      return [top, right, bottom, left];
    }
    if (kind === "symmetric") {
      const named = Object.fromEntries(args.map((arg) => arg.split(":").map((part) => part.trim())));
      const vertical = named.vertical ? step(named.vertical) : "s0";
      const horizontal = named.horizontal ? step(named.horizontal) : "s0";
      return [vertical, horizontal, vertical, horizontal];
    }
    throw new Error(`unsupported EdgeInsets.${kind} for ${role}`);
  }

  function cssEdges(role: string): Edges {
    const value = declaration(cssRule(insetCss, `.inset[data-padding="${role}"]`), "padding");
    expect(value, `missing padding for ${role}`).toBeDefined();
    const parts = value!
      .split(" ")
      .map((part) => part === "0"
        ? "s0"
        : part.replace("var(--catch-layout-page-gutter)", "pageGutter")
          .replace(/^var\(--catch-space-(\w+)\)$/, "$1"));
    const [top, right = top, bottom = top, left = right] = parts;
    return [top, right, bottom, left];
  }

  it("resolves every CatchInset role to its Flutter CatchInsets value", () => {
    const roles = selectorValues(insetCss, "padding");
    expect(roles.length).toBeGreaterThan(0);
    for (const role of roles) {
      expect(cssEdges(role), role).toEqual(dartEdges(role));
    }
  });
});

describe("CatchTextStyles parity", () => {
  function roleBody(role: string) {
    const start = textStylesDart.indexOf(`static TextStyle ${role}(`);
    expect(start, `missing CatchTextStyles.${role}`).toBeGreaterThanOrEqual(0);
    const next = textStylesDart.indexOf("static ", start + 1);
    return textStylesDart.slice(start, next === -1 ? undefined : next);
  }

  function flutterRole(role: string): {profile: string; color: string; weight?: string} {
    const body = roleBody(role);
    const color = body.match(/CatchTokens\.of\(context\)\.(\w+)/)?.[1];
    const weight = body.match(/fontWeight: FontWeight\.w(\d+)/)?.[1];
    if (body.includes("_functionStrong14(")) {
      return {profile: "secondary", color: color ?? "ink", weight: "700"};
    }
    const profile = body.match(/CatchPlatformTokens\.typography\.(\w+)/)?.[1];
    if (profile) {
      expect(color, `${role} default color`).toBeDefined();
      return {profile, color: color!, weight};
    }
    const delegate = body.match(/=>\s*(\w+)\(\s*context/)?.[1];
    expect(delegate, `${role} resolves to no profile`).toBeDefined();
    const base = flutterRole(delegate!);
    return {profile: base.profile, color: color ?? base.color, weight: weight ?? base.weight};
  }

  it("binds each CatchText variant to its Flutter role's profile, weight and color", () => {
    const variants = selectorValues(textCss, "variant");
    expect(variants.length).toBeGreaterThan(0);
    for (const variant of variants) {
      const flutter = flutterRole(variant);
      const rule = cssRule(textCss, `.text[data-variant="${variant}"]`);
      const profile = `--catch-typography-ios-${kebab(flutter.profile)}`;
      expect(declaration(rule, "--catch-text-size"), variant).toBe(`var(${profile}-size)`);
      expect(declaration(rule, "--catch-text-line-height"), variant)
        .toBe(`var(${profile}-line-height)`);
      expect(declaration(rule, "--catch-text-tracking"), variant)
        .toBe(`var(${profile}-tracking)`);
      expect(declaration(rule, "--catch-text-weight"), variant)
        .toBe(flutter.weight ?? `var(${profile}-weight)`);
      expect(declaration(rule, "--catch-text-role-color"), variant)
        .toBe(`var(--catch-theme-${kebab(flutter.color)})`);
    }
  });
});
