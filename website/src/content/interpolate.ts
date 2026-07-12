type ContentValue = string | number;

type TemplateToken<Template extends string> =
  Template extends `${string}{${infer Token}}${infer Rest}`
    ? Token | TemplateToken<Rest>
    : never;

export type ContentTemplateValues<Template extends string> =
  string extends Template
    ? Readonly<Record<string, ContentValue>>
    : {readonly [Token in TemplateToken<Template>]: ContentValue};

export function interpolateContent<const Template extends string>(
  template: Template,
  values: ContentTemplateValues<Template>
) {
  const runtimeValues = values as Readonly<Record<string, ContentValue>>;
  const tokens = [...String(template).matchAll(/\{([A-Za-z0-9_]+)\}/gu)]
    .map((match) => match[1]);
  const expected = new Set(tokens);
  const missing = [...expected].filter((token) => !(token in runtimeValues));
  const extra = Object.keys(runtimeValues).filter((token) => !expected.has(token));
  if (missing.length > 0 || extra.length > 0) {
    const details = [
      missing.length ? `missing: ${missing.join(", ")}` : null,
      extra.length ? `extra: ${extra.join(", ")}` : null,
    ].filter(Boolean).join("; ");
    throw new Error(`Invalid content template values (${details})`);
  }
  const output = String(template).replace(
    /\{([A-Za-z0-9_]+)\}/gu,
    (_match, token) => String(runtimeValues[token])
  );
  if (/\{[A-Za-z0-9_]+\}/u.test(output)) {
    throw new Error(`Unresolved content template token in: ${output}`);
  }
  return output;
}
