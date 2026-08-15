/** Returns whether a Storage object belongs to a photo-moderated surface. */
export function isModeratedPhotoPath(filePath: string): boolean {
  const isUserMedia = filePath.startsWith("users/") &&
    (filePath.includes("/photos/") || filePath.includes("/hostedMedia/"));
  const isOrganizerMedia = filePath.startsWith("organizers/") &&
    (filePath.includes("/photos/") || filePath.includes("/logo/"));
  const isClubMedia = filePath.startsWith("clubs/") &&
    (filePath.includes("/photos/") || filePath.includes("/logo/"));
  const isEventMedia = filePath.startsWith("events/") &&
    filePath.includes("/photos/");
  const isChatImage = filePath.startsWith("matches/");

  return isUserMedia ||
    isOrganizerMedia ||
    isClubMedia ||
    isEventMedia ||
    isChatImage;
}
