import Ajv from "ajv";
import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";

interface Rule {
  ruleId: string;
  claimKey: string;
  sourceTypes: string[];
  confidence: string[];
  minimumCount: number;
  distinctSignalIds: boolean;
  distinctSourceRoots: boolean;
  maxAgeDays: number | null;
}

interface QualificationPolicy {
  schemaVersion: 1;
  classification: "sales_private";
  status: "active";
  policyId: string;
  version: string;
  policyHash: string;
  rules: Rule[];
}

const id = {
  type: "string",
  minLength: 1,
  maxLength: 96,
  pattern: "^[A-Za-z0-9][A-Za-z0-9._:-]*$",
};
const policySchema = {
  type: "object",
  additionalProperties: false,
  required: [
    "schemaVersion",
    "classification",
    "status",
    "policyId",
    "version",
    "policyHash",
    "rules",
  ],
  properties: {
    schemaVersion: {const: 1},
    classification: {const: "sales_private"},
    status: {const: "active"},
    policyId: id,
    version: id,
    policyHash: {type: "string", pattern: "^[a-f0-9]{64}$"},
    rules: {
      type: "array",
      minItems: 1,
      maxItems: 8,
      items: {
        type: "object",
        additionalProperties: false,
        required: [
          "ruleId",
          "claimKey",
          "sourceTypes",
          "confidence",
          "minimumCount",
          "distinctSignalIds",
          "distinctSourceRoots",
          "maxAgeDays",
        ],
        properties: {
          ruleId: id,
          claimKey: {
            enum: ["identity", "recurrence", "operation", "stack", "other"],
          },
          sourceTypes: {
            type: "array",
            minItems: 1,
            maxItems: 4,
            uniqueItems: true,
            items: {
              enum: [
                "first_party",
                "public_web",
                "human_note",
                "import_artifact",
              ],
            },
          },
          confidence: {
            type: "array",
            minItems: 1,
            maxItems: 3,
            uniqueItems: true,
            items: {enum: ["high", "medium", "low"]},
          },
          minimumCount: {type: "integer", minimum: 1, maximum: 5},
          distinctSignalIds: {type: "boolean"},
          distinctSourceRoots: {type: "boolean"},
          maxAgeDays: {type: ["integer", "null"], minimum: 0, maximum: 365},
        },
      },
    },
  },
};
const validate = new Ajv({allErrors: true, strict: true}).compile(
  policySchema,
);

export function qualificationPolicyHash(
  policy: Pick<QualificationPolicy, "policyId" | "version" | "rules">,
): string {
  return createHash("sha256")
    .update(
      canonical({
        policyId: policy.policyId,
        version: policy.version,
        rules: policy.rules,
      }),
    )
    .digest("hex");
}

export async function assertQualifiedByRuntimePolicy(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  organizerId: string,
  now: string,
): Promise<{ policyId: string; version: string; policyHash: string }> {
  const policySnap = await tx.get(
    db.collection("salesSettings").doc("qualificationPolicy"),
  );
  const rawPolicy = policySnap.data();
  if (!policySnap.exists || !validate(rawPolicy)) {
    throw new HttpsError(
      "failed-precondition",
      "An active versioned qualification policy is required.",
    );
  }
  const policy = rawPolicy as unknown as QualificationPolicy;
  if (
    new Set(policy.rules.map((rule) => rule.ruleId)).size !==
      policy.rules.length ||
    qualificationPolicyHash(policy) !== policy.policyHash
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Qualification policy integrity check failed.",
    );
  }
  const evidenceSnap = await tx.get(
    db
      .collection("salesEvidence")
      .where("organizerId", "==", organizerId)
      .limit(51),
  );
  if (evidenceSnap.size > 50) {
    throw new HttpsError(
      "resource-exhausted",
      "Evidence must be curated before qualification.",
    );
  }
  const nowMs = Date.parse(now);
  const evidence = evidenceSnap.docs
    .map((doc) => doc.data())
    .filter(
      (row) =>
        row.classification === "sales_private" &&
        !row.contactId &&
        typeof row.observedAt === "string" &&
        Number.isFinite(Date.parse(row.observedAt)) &&
        Date.parse(row.observedAt) <= nowMs &&
        (!row.validThrough || Date.parse(row.validThrough) >= nowMs),
    );
  for (const rule of policy.rules) {
    const matches = evidence.filter(
      (row) =>
        row.claimKey === rule.claimKey &&
        rule.sourceTypes.includes(row.sourceType) &&
        rule.confidence.includes(row.confidence) &&
        (rule.maxAgeDays === null ||
          nowMs - Date.parse(row.observedAt) <= rule.maxAgeDays * 86_400_000),
    );
    if (!hasIndependentCount(matches, rule, 0, new Set(), new Set(), 0)) {
      throw new HttpsError(
        "failed-precondition",
        `Qualification evidence is incomplete for rule ${rule.ruleId}.`,
      );
    }
  }
  return {
    policyId: policy.policyId,
    version: policy.version,
    policyHash: policy.policyHash,
  };
}

function hasIndependentCount(
  rows: FirebaseFirestore.DocumentData[],
  rule: Rule,
  index: number,
  signalIds: Set<string>,
  roots: Set<string>,
  count: number,
): boolean {
  if (count >= rule.minimumCount) return true;
  if (index >= rows.length || count + rows.length - index < rule.minimumCount) {
    return false;
  }
  const row = rows[index];
  const signal = typeof row.signalId === "string" ? row.signalId : "";
  const root = sourceRoot(row.sourceRef);
  if (
    (!rule.distinctSignalIds || (signal && !signalIds.has(signal))) &&
    (!rule.distinctSourceRoots || (root && !roots.has(root)))
  ) {
    const nextSignals = new Set(signalIds);
    const nextRoots = new Set(roots);
    nextSignals.add(signal);
    nextRoots.add(root);
    if (
      hasIndependentCount(
        rows,
        rule,
        index + 1,
        nextSignals,
        nextRoots,
        count + 1,
      )
    ) {
      return true;
    }
  }
  return hasIndependentCount(rows, rule, index + 1, signalIds, roots, count);
}

function sourceRoot(value: unknown): string {
  if (typeof value !== "string") return "";
  try {
    const url = new URL(value);
    return url.hostname.toLowerCase();
  } catch {
    return value.trim().toLowerCase();
  }
}

function canonical(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(canonical).join(",")}]`;
  if (value && typeof value === "object") {
    return `{${Object.entries(value)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, child]) => `${JSON.stringify(key)}:${canonical(child)}`)
      .join(",")}}`;
  }
  return JSON.stringify(value);
}
