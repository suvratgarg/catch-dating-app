// Intentionally small, dependency-free JSON Schema validator for model output.
// It implements the closed subset accepted by the operations model boundary.
export function validateJsonSchema(schema, value, {registry = {}} = {}) {
  const errors = [];
  validateNode(schema, value, "$", errors, {registry, root: schema});
  return {valid: errors.length === 0, errors};
}

function validateNode(schema, value, path, errors, context) {
  if (!schema || typeof schema !== "object" || Array.isArray(schema)) {
    errors.push({path, keyword: "schema", message: "schema must be an object"});
    return;
  }
  if (schema.$ref) {
    const resolved = resolveReference(schema.$ref, context);
    if (!resolved) {
      errors.push({path, keyword: "$ref", message: `cannot resolve ${schema.$ref}`});
      return;
    }
    validateNode(resolved.schema, value, path, errors, resolved.context);
    return;
  }
  if (schema.const !== undefined && !deepEqual(schema.const, value)) {
    errors.push({path, keyword: "const", message: "value does not match const"});
  }
  if (Array.isArray(schema.enum) && !schema.enum.some((item) => deepEqual(item, value))) {
    errors.push({path, keyword: "enum", message: "value is not in enum"});
  }
  if (schema.anyOf) {
    const matches = schema.anyOf.some((candidate) => {
      const candidateErrors = [];
      validateNode(candidate, value, path, candidateErrors, context);
      return candidateErrors.length === 0;
    });
    if (!matches) errors.push({path, keyword: "anyOf", message: "value matches no allowed schema"});
    return;
  }

  if (schema.type && !matchesType(schema.type, value)) {
    errors.push({path, keyword: "type", message: `expected ${schema.type}`});
    return;
  }

  if (typeof value === "string") {
    if (schema.minLength !== undefined && value.length < schema.minLength) {
      errors.push({path, keyword: "minLength", message: `must have at least ${schema.minLength} characters`});
    }
    if (schema.maxLength !== undefined && value.length > schema.maxLength) {
      errors.push({path, keyword: "maxLength", message: `must have at most ${schema.maxLength} characters`});
    }
    if (schema.pattern && !new RegExp(schema.pattern, "u").test(value)) {
      errors.push({path, keyword: "pattern", message: "does not match required pattern"});
    }
    if (schema.format === "date-time" && Number.isNaN(Date.parse(value))) {
      errors.push({path, keyword: "format", message: "must be an ISO date-time"});
    }
  }

  if (typeof value === "number") {
    if (schema.minimum !== undefined && value < schema.minimum) {
      errors.push({path, keyword: "minimum", message: `must be >= ${schema.minimum}`});
    }
    if (schema.maximum !== undefined && value > schema.maximum) {
      errors.push({path, keyword: "maximum", message: `must be <= ${schema.maximum}`});
    }
  }

  if (Array.isArray(value)) {
    if (schema.minItems !== undefined && value.length < schema.minItems) {
      errors.push({path, keyword: "minItems", message: `must contain at least ${schema.minItems} items`});
    }
    if (schema.maxItems !== undefined && value.length > schema.maxItems) {
      errors.push({path, keyword: "maxItems", message: `must contain at most ${schema.maxItems} items`});
    }
    if (schema.uniqueItems && new Set(value.map((item) => JSON.stringify(item))).size !== value.length) {
      errors.push({path, keyword: "uniqueItems", message: "must not contain duplicate items"});
    }
    if (schema.items) value.forEach((item, index) => validateNode(schema.items, item, `${path}[${index}]`, errors, context));
  }

  if (isPlainObject(value)) {
    const properties = schema.properties ?? {};
    if (schema.maxProperties !== undefined && Object.keys(value).length > schema.maxProperties) {
      errors.push({path, keyword: "maxProperties", message: `must contain at most ${schema.maxProperties} properties`});
    }
    for (const key of schema.required ?? []) {
      if (!Object.hasOwn(value, key)) {
        errors.push({path: `${path}.${key}`, keyword: "required", message: "property is required"});
      }
    }
    for (const [key, child] of Object.entries(value)) {
      if (properties[key]) validateNode(properties[key], child, `${path}.${key}`, errors, context);
      else if (schema.additionalProperties === false) {
        errors.push({path: `${path}.${key}`, keyword: "additionalProperties", message: "property is not allowed"});
      } else if (isPlainObject(schema.additionalProperties)) {
        validateNode(schema.additionalProperties, child, `${path}.${key}`, errors, context);
      }
    }
  }
}

function resolveReference(reference, context) {
  const [documentId, pointer = ""] = reference.split("#");
  const root = documentId ? context.registry[documentId] : context.root;
  if (!root) return null;
  let schema = root;
  if (pointer) {
    for (const segment of pointer.replace(/^\//, "").split("/")) {
      const key = segment.replace(/~1/g, "/").replace(/~0/g, "~");
      schema = schema?.[key];
      if (!schema) return null;
    }
  }
  return {schema, context: {...context, root}};
}

function matchesType(type, value) {
  if (Array.isArray(type)) return type.some((candidate) => matchesType(candidate, value));
  if (type === "null") return value === null;
  if (type === "array") return Array.isArray(value);
  if (type === "object") return isPlainObject(value);
  if (type === "integer") return Number.isInteger(value);
  if (type === "number") return typeof value === "number" && Number.isFinite(value);
  return typeof value === type;
}

function isPlainObject(value) {
  return Boolean(value) && typeof value === "object" && !Array.isArray(value);
}

function deepEqual(left, right) {
  return JSON.stringify(left) === JSON.stringify(right);
}
