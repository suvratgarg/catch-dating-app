const storageKey = "catch_saved_organizers_v1";

export function readSavedOrganizer(clubId: string): boolean {
  try {
    const raw = window.localStorage.getItem(storageKey);
    const saved = raw ? JSON.parse(raw) as string[] : [];
    return saved.includes(clubId);
  } catch {
    return false;
  }
}

export function writeSavedOrganizer(clubId: string, saved: boolean) {
  try {
    const raw = window.localStorage.getItem(storageKey);
    const values = new Set(raw ? JSON.parse(raw) as string[] : []);
    if (saved) {
      values.add(clubId);
    } else {
      values.delete(clubId);
    }
    window.localStorage.setItem(storageKey, JSON.stringify([...values]));
  } catch {
    // Local saves should not block the public listing UI.
  }
}
