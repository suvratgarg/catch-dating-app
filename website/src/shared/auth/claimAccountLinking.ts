/** Keep SDK failures private while retaining explicit account recovery guidance. */
export function claimAccountLinkingErrorMessage(error: unknown, fallback: string): string {
  if (!(error instanceof Error)) return fallback;
  const code = "code" in error ? error.code : undefined;
  if ((typeof code === "string" && code.startsWith("auth/")) ||
      /^(?:auth\/|Firebase:)/u.test(error.message)) return fallback;
  return error.message || fallback;
}
