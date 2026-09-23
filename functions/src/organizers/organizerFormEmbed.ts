/** Installer code contains only public URLs, title, and frame identifier. */
export function organizerFormEmbedAssets(
  canonicalUrl: string,
  title: string,
  embedId: string
) {
  if (!/^[A-Za-z0-9_-]{1,80}$/u.test(embedId)) {
    throw new Error("Invalid embed ID");
  }
  const embedUrl = new URL(canonicalUrl);
  if (embedUrl.protocol !== "https:") {
    throw new Error("Embed URL must use HTTPS");
  }
  embedUrl.searchParams.set("embed", "1");
  embedUrl.searchParams.set("embedId", embedId);
  const url = embedUrl.toString();
  const frameId = `catch-form-${embedId}`;
  // The external installer derives its specific iframe from currentScript.
  // This works for repeated installs and sites that disallow inline scripts.
  const snippet = `<iframe id="${frameId}" src="${escapeHtml(url)}" ` +
    `title="${escapeHtml(title)}" loading="lazy" ` +
    "style=\"display:block;width:100%;height:720px;border:0\" " +
    "referrerpolicy=\"strict-origin-when-cross-origin\" " +
    "allow=\"payment\" scrolling=\"auto\"></iframe>" +
    `<script src="${embedUrl.origin}/form-embed-resize.js"></script>` +
    `<p><a href="${escapeHtml(canonicalUrl)}">Open the form directly</a></p>`;
  return {embedUrl: url, embedSnippet: snippet};
}

function escapeHtml(value: string): string {
  return value.replace(/[&<>"']/gu, (character) => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;", "'": "&#39;",
  })[character] ?? character);
}
