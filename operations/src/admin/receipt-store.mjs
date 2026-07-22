import fs from "node:fs/promises";
import path from "node:path";
import {stableStringify} from "../platform/canonical-json.mjs";
import {OperationsError} from "../platform/errors.mjs";

export class AdminActionReceiptStore {
  constructor(root) {
    this.root = path.resolve(root);
  }

  async put(receipt) {
    await fs.mkdir(this.root, {recursive: true});
    const target = path.join(this.root, `${receipt.executionId}.json`);
    const temporary = `${target}.${process.pid}.tmp`;
    const content = `${stableStringify(receipt, {space: 2})}\n`;
    const existing = await readIfPresent(target);
    if (existing !== null) return resolveExisting(target, existing, content);
    await fs.writeFile(temporary, content, {
      encoding: "utf8",
      flag: "wx",
      mode: 0o600,
    });
    try {
      await fs.link(temporary, target);
      return target;
    } catch (error) {
      if (error?.code !== "EEXIST") throw error;
      return resolveExisting(target, await fs.readFile(target, "utf8"), content);
    } finally {
      await fs.unlink(temporary).catch(() => undefined);
    }
  }
}

async function readIfPresent(target) {
  try {
    return await fs.readFile(target, "utf8");
  } catch (error) {
    if (error?.code === "ENOENT") return null;
    throw error;
  }
}

function resolveExisting(target, existing, content) {
  if (existing === content) return target;
  throw new OperationsError(
    "ADMIN_ACTION_RECEIPT_CONFLICT",
    "A different immutable local receipt already uses this execution id.",
    {details: {receiptPath: target}}
  );
}
