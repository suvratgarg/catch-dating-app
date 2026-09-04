/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import Ajv from "ajv";
import type {ValidateFunction} from "ajv";
import addFormats from "ajv-formats";

const ajv = new Ajv({allErrors: true, strict: false});
addFormats(ajv);

export function lazyValidator<T>(
  schema: Record<string, unknown>
): ValidateFunction<T> {
  let compiled: ValidateFunction<T> | null = null;
  const validate = ((data: unknown) => {
    compiled ??= ajv.compile(schema) as ValidateFunction<T>;
    return compiled(data);
  }) as ValidateFunction<T>;
  Object.defineProperty(validate, "errors", {
    get: () => compiled?.errors ?? null,
  });
  return validate;
}

export function schemaErrorMessages(
  validator: ValidateFunction<unknown>
): string[] {
  return (validator.errors ?? []).map((error) => {
    const location = error.instancePath || "/";
    return `${location} ${error.message ?? "failed validation"}`;
  });
}
