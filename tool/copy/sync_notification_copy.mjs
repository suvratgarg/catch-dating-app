#!/usr/bin/env node
import fs from "node:fs";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const catalogPath = fromRepo("copy/notifications_en.json");
const outputPath = fromRepo(
  "functions/src/shared/generated/notificationCopyEn.ts",
);
const write = process.argv.includes("--write");
const catalog = JSON.parse(fs.readFileSync(catalogPath, "utf8"));
validate(catalog);
const expected = render(catalog);

if (write) {
  fs.mkdirSync(new URL("../../functions/src/shared/generated/", import.meta.url), {
    recursive: true,
  });
  fs.writeFileSync(outputPath, expected);
  console.log(
    `Generated ${Object.keys(catalog.messages).length} English notification templates.`,
  );
} else if (!fs.existsSync(outputPath) || fs.readFileSync(outputPath, "utf8") !== expected) {
  console.error(
    `Notification copy drift in ${relativeToRepo(outputPath)}. Run node tool/copy/sync_notification_copy.mjs --write.`,
  );
  process.exitCode = 1;
} else {
  console.log(
    `Notification copy valid: ${Object.keys(catalog.messages).length} English templates.`,
  );
}

function validate(value) {
  if (value?.version !== 1 || value?.locale !== "en" || !value.messages) {
    throw new Error("copy/notifications_en.json must be a version 1 English catalog.");
  }
  for (const [key, message] of Object.entries(value.messages)) {
    if (
      !/^[a-z][A-Za-z0-9]*$/.test(key) ||
      typeof message?.title !== "string" ||
      !message.title.trim() ||
      typeof message?.body !== "string" ||
      !message.body.trim() ||
      !["consumer", "host", "shared"].includes(message.audience) ||
      !["marketing", "product", "safety", "legal"].includes(message.owner)
    ) {
      throw new Error(`Invalid notification copy entry: ${key}.`);
    }
    for (const template of [message.title, message.body]) {
      for (const token of template.matchAll(/\{([^}]+)\}/g)) {
        if (!/^[a-z][A-Za-z0-9]*$/.test(token[1])) {
          throw new Error(`${key} has an invalid placeholder: ${token[1]}.`);
        }
      }
    }
  }
}

function render(value) {
  return `// GENERATED CODE - DO NOT MODIFY BY HAND.\n` +
    `// Source: copy/notifications_en.json\n\n` +
    `export const notificationCopyEn = ${JSON.stringify(value.messages, null, 2)} as const;\n\n` +
    `export type NotificationCopyKey = keyof typeof notificationCopyEn;\n`;
}
