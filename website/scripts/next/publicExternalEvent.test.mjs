import fs from "node:fs";
import assert from "node:assert/strict";
import test from "node:test";
import {publicExternalEvent} from "../../src/server/publicExternalEvent.ts";
const fixture = () => JSON.parse(fs.readFileSync(new URL("../../../contracts/fixtures/valid/external_event_doc.json", import.meta.url), "utf8"));
test("external read model keeps only public outbound event display", () => {
  const raw = fixture();
  const result = publicExternalEvent(raw.eventId, raw);
  assert(result);
  assert.equal(result.organizerId, raw.canonicalHostId);
  assert.equal(result.event.sourceHref, raw.booking.externalLinks[0].url);
  assert.equal(result.event.availability, "read_only_external");
  assert(!JSON.stringify(result).includes('primaryCandidateId'));
});
test("withdrawn, conflicting, synthetic and active-scheme external records are withheld", () => {
  for (const alter of [
    data => {data.publicationStatus = "private";},
    data => {data.status = "cancelled";},
    data => {data.eventId = "different";},
    data => {data.synthetic = true;},
    data => {data.booking.catchPaymentsEnabled = true;},
    data => {data.booking.externalLinks[0].url = "javascript:alert(1)";},
  ]) {
    const raw = fixture(); const id = raw.eventId; alter(raw);
    assert.equal(publicExternalEvent(id, raw), null);
  }
});
