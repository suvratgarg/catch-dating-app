import {HttpsError} from "firebase-functions/v2/https";
import {ClubDocument} from "./generated/firestoreAdminTypes";

interface PublicOrganizerPageEligibilityOptions {
  pagePath?: string | null;
  allowDirectorySearchPath?: boolean;
}

export function assertPublicOrganizerPageEligible(
  club: ClubDocument,
  options: PublicOrganizerPageEligibilityOptions = {}
) {
  if (club.archived || club.status === "archived") {
    throw new HttpsError(
      "failed-precondition",
      "This organizer profile is not accepting public website activity."
    );
  }
  if (club.claim?.state === "suppressed") {
    throw new HttpsError(
      "failed-precondition",
      "This organizer profile is not accepting public website activity."
    );
  }

  const publicPage = club.publicPage;
  if (
    !publicPage ||
    publicPage.publishStatus !== "published" ||
    publicPage.indexStatus === "noindex" ||
    publicPage.robots !== "index, follow"
  ) {
    throw new HttpsError(
      "failed-precondition",
      "This organizer profile is not accepting public website activity."
    );
  }

  if (options.pagePath === undefined || options.pagePath === null) return;
  const submittedPath = normalizePublicWebsitePath(options.pagePath);
  const canonicalPath = normalizePublicWebsitePath(publicPage.canonicalPath);
  const directorySearchPath = submittedPath === "/organizers/";
  if (
    submittedPath !== canonicalPath &&
    !(options.allowDirectorySearchPath && directorySearchPath)
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Public website activity must match the organizer page."
    );
  }
}

export function normalizePublicWebsitePath(value: string): string {
  const path = pathWithoutQueryOrHash(value);
  if (!path.startsWith("/")) return "/";
  return path.endsWith("/") ? path : `${path}/`;
}

function pathWithoutQueryOrHash(value: string): string {
  const trimmed = value.trim();
  if (!trimmed) return "/";
  try {
    if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
      return new URL(trimmed).pathname;
    }
  } catch {
    return "/";
  }
  return trimmed.split(/[?#]/u, 1)[0] || "/";
}
