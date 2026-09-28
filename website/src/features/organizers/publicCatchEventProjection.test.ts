import {expect, it, vi} from "vitest";
import {projectLivePublicCatchEvent as project, projectPublicCatchEventSnapshot as snapshot} from "./publicCatchEventProjection";
const base = () => ({organizerId: "host", publicationState: "published", status: "active",
  startTime: {toMillis: () => 9e12}, endTime: {toMillis: () => 9e12 + 3600000},
  meetingLocation: {name: "Park"}, eventFormat: {activityKind: "socialRun"},
  capacityLimit: 20, bookedCount: 2, priceInPaise: 0, currency: "INR",
  publicRegistrationEnabled: true, publicRegistrationMode: "free"});
it("requires explicit public active state before decoding rich fields", () => {
  const read = vi.fn(() => {throw Error();});
  for (const publicationState of [undefined, "private", "archived"]) {
    expect(project("event", {publicationState, get startTime() {return read();}})).toBeNull();
  }
  expect(read).not.toHaveBeenCalled();
  expect(project("event", {...base(), status: "cancelled"})).toBeNull();
});
it("keeps free international events but rejects unsupported paid currency", () => {
  expect(project("event", {...base(), currency: "USD"})?.event)
    .toMatchObject({currency: "USD", registrationMode: "free", priceLabel: "Free"});
  expect(project("event", {...base(), priceInPaise: 100, currency: "USD", publicRegistrationMode: "paid"})).toBeNull();
});
it("withholds malformed identities, dates, prices, and timezones", () => {
  for (const change of [{clubId: "other"}, {capacityLimit: 0}, {bookedCount: -1},
    {priceInPaise: -1}, {startTime: {toMillis: () => {throw Error();}}},
    {endTime: {toMillis: () => 1}}, {eventTimezone: "invalid"}]) {
    expect(project("event", {...base(), ...change})).toBeNull();
  }
  expect(project("bad/id", base())).toBeNull();
});
it("displays restricted events without an open checkout CTA", () => {
  const admission = {format: "open", privateAccessPolicy: {mode: "none"}};
  const policy = {admission, pricing: {basePriceInPaise: 0}};
  expect(project("event", {...base(), eventPolicy: policy})?.event.registrationMode).toBe("free");
  for (const change of [{inviteRequired: true}, {membershipRequired: true},
    {manualApprovalRequired: true}, {privateAccessPolicy: {mode: "inviteCode"}},
    {cohortCapacityLimits: {men: 2}}, {balancedRatioPolicy: {}},
    {crossPathsPairInventory: {enabled: true}}]) {
    expect(project("event", {...base(), eventPolicy: {...policy, admission: {...admission, ...change}}})?.event)
      .toMatchObject({registrationMode: "closed", publicRegistrationEnabled: false});
  }
  for (const change of [{constraints: {maxMen: 3}}, {crossPathsPairHeldCount: 1},
    {crossPathsPairConfirmedCount: 1}, {crossPathsPairHeldCohortCounts: {men: 1}},
    {eventPolicy: {...policy, pricing: {basePriceInPaise: 0, demandPricingRules: [{}]}}}]) {
    expect(project("event", {...base(), ...change})?.event.registrationMode).toBe("closed");
  }
});
it("rejects cached, pending and oversized snapshots before decoding and handles removal", () => {
  const data = vi.fn(() => base());
  const source = {metadata: {fromCache: false, hasPendingWrites: false}, size: 1, docs: [{id: "event", data}]};
  for (const change of [{metadata: {fromCache: true, hasPendingWrites: false}},
    {metadata: {fromCache: false, hasPendingWrites: true}}, {size: 401}]) {
    expect(snapshot({...source, ...change})).toBeNull();
  }
  expect(data).not.toHaveBeenCalled();
  expect(snapshot(source)).toHaveLength(1);
  expect(snapshot({...source, size: 0, docs: []})).toEqual([]);
});
