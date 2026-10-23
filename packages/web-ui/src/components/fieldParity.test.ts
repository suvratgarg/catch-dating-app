// @vitest-environment node
import fs from "node:fs";
import {fileURLToPath} from "node:url";
import {describe, expect, it} from "vitest";

// CatchField's geometry and its interim component values must equal the Dart
// values Flutter's CatchField reads (blueprint D11).
const read = (relative: string) =>
  fs.readFileSync(fileURLToPath(new URL(relative, import.meta.url)), "utf8");

const fieldTokensDart = read("../../../catch_tokens/lib/src/components/catch_field_tokens.dart");
const radiusDart = read("../../../catch_tokens/lib/src/primitives/catch_radius.dart");
const elevationDart = read("../../../catch_tokens/lib/src/semantic/catch_elevation.dart");
const fieldCss = read("./CatchField.module.css");

function dartConstant(source: string, name: string) {
  const match = source.match(new RegExp(`static const (?:double|Duration|Curve) ${name} =\\s*([^;]+);`));
  expect(match, `missing Dart constant ${name}`).not.toBeNull();
  return match![1].trim();
}

function cssValue(property: string, css = fieldCss) {
  const match = css.match(new RegExp(`${property}:\\s*([^;]+);`));
  expect(match, `missing CSS ${property}`).not.toBeNull();
  return match![1].replace(/\s+/g, " ").trim();
}

const spacingStep = (dartValue: string) => dartValue.replace(/^CatchSpacing\./, "");

describe("CatchField parity", () => {
  it("pads the row and spaces its support line as CatchFieldTokens does", () => {
    const vertical = spacingStep(dartConstant(fieldTokensDart, "rowVerticalPadding"));
    const horizontal = spacingStep(dartConstant(fieldTokensDart, "rowHorizontalPadding"));
    expect(fieldCss).toContain(
      `padding: var(--catch-space-${vertical}) var(--catch-space-${horizontal});`,
    );
    const supportTop = spacingStep(dartConstant(fieldTokensDart, "supportingTopGap"));
    expect(fieldCss).toContain(`margin-top: var(--catch-space-${supportTop});`);
    const counterGap = spacingStep(dartConstant(fieldTokensDart, "supportingCounterGap"));
    expect(fieldCss).toContain(`gap: var(--catch-space-${counterGap});`);
    const leadingGap = spacingStep(dartConstant(fieldTokensDart, "leadingGap"));
    expect(fieldCss).toContain(`column-gap: var(--catch-space-${leadingGap});`);
  });

  it("sizes the leading lane as CatchFieldTokens.leadingIconExtent", () => {
    expect(dartConstant(fieldTokensDart, "leadingIconExtent")).toBe("CatchIcon.md");
    const iconDart = read("../../../catch_tokens/lib/src/primitives/catch_icon.dart");
    const extent = Number(dartConstant(iconDart, "md"));
    expect(cssValue("--catch-field-leading-extent")).toBe(`${extent}px`);
  });

  it("uses the Flutter tile radius, tints, opacity and motion", () => {
    const radius = Number(dartConstant(radiusDart, "interactiveTile"));
    expect(cssValue("--catch-radius-interactive-tile")).toBe(`${radius}px`);
    expect(dartConstant(fieldTokensDart, "tileRadius")).toBe("CatchRadius.interactiveTile");

    const activeTint = Number(dartConstant(fieldTokensDart, "activeTintAlpha"));
    expect(cssValue("--catch-field-active-tint")).toBe(`${Math.round(activeTint * 100)}%`);
    const disabled = Number(dartConstant(fieldTokensDart, "disabledOpacity"));
    expect(Number(cssValue("--catch-field-disabled-opacity"))).toBe(disabled);

    const fast = dartConstant(fieldTokensDart, "fast").match(/milliseconds: (\d+)/)?.[1];
    expect(cssValue("--catch-field-motion-fast")).toBe(`${fast}ms`);
    const curve = dartConstant(fieldTokensDart, "curve").match(/Cubic\(([^)]+)\)/)?.[1];
    expect(cssValue("--catch-field-motion-curve")).toBe(
      `cubic-bezier(${curve!.split(",").map((value) => value.trim()).join(", ")})`,
    );
  });

  it("lifts the active tile with CatchElevation.fieldActive in both themes", () => {
    const body = elevationDart.slice(elevationDart.indexOf("fieldActive("));
    const colors = [...body.matchAll(/Color\.fromRGBO\(([^)]+)\)/g)].slice(0, 2)
      .map((match) => match[1].split(",").map((value) => value.trim()));
    const blur = body.match(/blurRadius: [^?]+\? (\d+) : (\d+)/);
    const offset = body.match(/Offset\(0, [^?]+\? (\d+) : (\d+)\)/);
    expect(colors.length).toBe(2);
    const [dark, light] = colors;
    const shadow = (rgba: string[], y: string, radius: string) =>
      `0 ${y}px ${radius}px rgb(${rgba[0]} ${rgba[1]} ${rgba[2]} / ${rgba[3]})`;
    expect(cssValue("--catch-elevation-field-active")).toBe(shadow(light, offset![2], blur![2]));
    const darkRule = fieldCss.slice(fieldCss.indexOf(':where([data-catch-theme="dark"]) .field'));
    expect(cssValue("--catch-elevation-field-active", darkRule)).toBe(shadow(dark, offset![1], blur![1]));
  });
});
