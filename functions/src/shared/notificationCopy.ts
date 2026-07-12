import {
  notificationCopyEn,
  NotificationCopyKey,
} from "./generated/notificationCopyEn";

export interface NotificationCopy {
  title: string;
  body: string;
}

/**
 * Resolves a reviewed notification template for the requested locale.
 * English is the fallback until another generated locale catalog is added.
 * @param {NotificationCopyKey} key Stable notification template id.
 * @param {Record<string, string>} values Named placeholder values.
 * @param {string} locale Recipient BCP-47 locale.
 * @return {NotificationCopy} Resolved push title and body.
 */
export function notificationCopy(
  key: NotificationCopyKey,
  values: Record<string, string>,
  locale = "en"
): NotificationCopy {
  void locale;
  const template = notificationCopyEn[key];
  return {
    title: interpolate(template.title, values, key),
    body: interpolate(template.body, values, key),
  };
}

function interpolate(
  template: string,
  values: Record<string, string>,
  key: NotificationCopyKey
): string {
  return template.replace(
    /\{([a-z][A-Za-z0-9]*)\}/g,
    (_match, name: string) => {
      const value = values[name];
      if (value == null) {
        throw new Error(`Missing notification placeholder ${name} for ${key}.`);
      }
      return value;
    }
  );
}
