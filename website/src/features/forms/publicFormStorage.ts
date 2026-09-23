/** Form recovery must work when privacy settings deny browser storage. */
export function readFormStorage(kind: "local" | "session", key: string): string | null {
  try {return window[`${kind}Storage`].getItem(key);} catch {return null;}
}

export function writeFormStorage(kind: "local" | "session", key: string, value: string): void {
  try {window[`${kind}Storage`].setItem(key, value);} catch { /* best effort cache */ }
}

export function removeFormStorage(kind: "local" | "session", key: string): void {
  try {window[`${kind}Storage`].removeItem(key);} catch { /* best effort cache */ }
}
