import {strict as assert} from "node:assert";
import {describe, it} from "node:test";
import {organizerFormEmbedAssets} from "./organizerFormEmbed";

describe("form embed installer", () => {
  it("retains the canonical direct link and escapes form titles", () => {
    const result = organizerFormEmbedAssets(
      "https://catchdates.com/f/public-1/",
      "<img src=x onerror=\"evil()\">", "embed-1"
    );
    assert.match(result.embedUrl, /[?&]embed=1/u);
    assert.match(result.embedSnippet, /Open the form directly/u);
    assert.match(result.embedSnippet,
      /href="https:\/\/catchdates.com\/f\/public-1\/"/u);
    assert.doesNotMatch(result.embedSnippet, /<img/u);
  });

  it("loads an external installer for restrictive parent CSP", () => {
    const {embedSnippet} = organizerFormEmbedAssets(
      "https://catchdates.com/f/public-1/", "Application", "embed-1"
    );
    assert.match(embedSnippet,
      /src="https:\/\/catchdates.com\/form-embed-resize.js"/u);
    assert.doesNotMatch(embedSnippet, /<script>/u);
  });
});
