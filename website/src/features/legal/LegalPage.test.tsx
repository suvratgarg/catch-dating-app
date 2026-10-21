import {expect, it, vi} from "vitest";
vi.mock("server-only", () => ({}));
vi.mock("../../server/publicCatalog", () => ({publicFirestore: vi.fn()}));
import {renderToStaticMarkup} from "react-dom/server";
import {publishedLegalContent} from "../../content/legal";
import {loadPublicContact} from "../../server/publicContact";
import {LegalPage} from "./LegalPage";

it.each(["help", "privacy", "terms"] as const)("renders a changed %s contact in text and every mailto without rebuilding", page => {
  const source = publishedLegalContent.pages[page];
  const first = renderToStaticMarkup(<LegalPage page={source} effectiveDate={publishedLegalContent.effectiveDate}
    contact={{supportEmail: "suvrat.garg@gmail.com"}} />);
  const changed = renderToStaticMarkup(<LegalPage page={source} effectiveDate={publishedLegalContent.effectiveDate}
    contact={{supportEmail: "support@example.org"}} />);
  expect(first).toContain("mailto:suvrat.garg@gmail.com");
  expect(changed).toContain("mailto:support@example.org");
  expect(changed).toContain("support@example.org");
  expect(changed).not.toContain("suvrat.garg@gmail.com");
  expect(changed).not.toContain("suvrat@catchdates.com");
  expect((changed.match(/mailto:support@example.org/gu) ?? []).length).toBe(2);
});

it("renders successive Firestore document revisions without rebuilding page source", async () => {
  const page = publishedLegalContent.pages.help;
  let document: unknown = {schemaVersion: 1, revision: 1, supportEmail: "suvrat.garg@gmail.com"};
  const render = async () => renderToStaticMarkup(<LegalPage page={page}
    effectiveDate={publishedLegalContent.effectiveDate}
    contact={await loadPublicContact(async () => document)} />);
  expect(await render()).toContain("mailto:suvrat.garg@gmail.com");
  document = {schemaVersion: 1, revision: 2, supportEmail: "support@example.org"};
  const updated = await render();
  expect(updated).toContain("mailto:support@example.org");
  expect(updated).not.toContain("suvrat.garg@gmail.com");
});
