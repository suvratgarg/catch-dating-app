/** Room time is an explicit Host setting. No production default is inferred. */
export type EventChatRoomMode =
  "notCreated" | "scheduled" | "open" | "announcementsOnly" |
  "paused" | "closed" | "archived";

export interface EventChatRoomSettings {
  status: "open" | "announcementsOnly" | "paused" | "closed" | "archived";
  opensAtMillis?: number | null;
  closesAtMillis?: number | null;
}

export function effectiveEventChatRoomMode(
  room: EventChatRoomSettings | null,
  nowMillis: number
): EventChatRoomMode {
  if (!room) return "notCreated";
  if (room.status === "archived" || room.status === "closed") {
    return room.status;
  }
  if (!Number.isFinite(nowMillis)) return "closed";
  if (room.opensAtMillis != null &&
      (!Number.isFinite(room.opensAtMillis) ||
        nowMillis < room.opensAtMillis)) return "scheduled";
  if (room.closesAtMillis != null &&
      (!Number.isFinite(room.closesAtMillis) ||
        nowMillis >= room.closesAtMillis)) return "closed";
  return room.status;
}

export function canReadEventChatMode(mode: EventChatRoomMode): boolean {
  return mode === "open" || mode === "announcementsOnly" ||
    mode === "paused";
}

export function canPostEventChatMode(
  mode: EventChatRoomMode, isHost: boolean
): boolean {
  return mode === "open" || (mode === "announcementsOnly" && isHost);
}
