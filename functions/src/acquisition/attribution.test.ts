import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import {FieldValue, Timestamp, type Firestore} from "firebase-admin/firestore";
import ts from "typescript";
import {hostCampaignLabels, prepareHostAttribution, expireHostAttribution,
  withdrawHostAttribution} from "./attribution";
import {newHostConsentAuthority} from "./consentPolicy";

const now = 1792512000000;
const consentId = "a".repeat(64);
const authority = newHostConsentAuthority({version: 1,
  purpose: "host_acquisition_measurement", analytics: true,
  advertising: false, chosenAt: now - 1000}, now - 1000);
const consentDocument = {schemaVersion: 1, classification: "sales_private",
  consentId, status: "active", authority,
  createdAt: Timestamp.fromMillis(now - 1000),
  updatedAt: Timestamp.fromMillis(now - 1000),
  expiresAt: Timestamp.fromMillis(authority.expiresAt)};
const touch = {capturedAt: new Date(now - 500).toISOString(),
  landingPath: "/host/", landingUrl: "https://bad.example/?secret=private",
  referrer: "private", values: {utm_source: "google", utm_medium: "cpc",
    utm_campaign: "host_acquisition_2026", gclid: "private",
    utm_term: "private", unknown: "private"}};
const input = {enabled: true, isNew: true,
  eventId: `host_lead_${now}_00000000-0000-4000-8000-000000000001`,
  consentId, consentDocument, now,
  attribution: {firstTouch: touch, lastTouch: touch}};

test("snapshot requires analytics authority and projects only reviewed labels",
  () => {
    const snapshot = prepareHostAttribution(input)!;
    assert.ok(snapshot);
    assert.equal(snapshot.acceptedAt, now);
    assert.equal(snapshot.expiresAt, authority.expiresAt);
    assert.equal(snapshot.firstTouch?.capturedAt, now - 500);
    assert.deepEqual(snapshot.firstTouch?.values, {utm_source: "google",
      utm_medium: "cpc", utm_campaign: "host_acquisition_2026"});
    assert.equal(JSON.stringify(snapshot).includes("private"), false);
    assert.equal(JSON.stringify(snapshot).includes("gclid"), false);
  });

test("old, revoked, mismatched and disabled permissions cannot capture", () => {
  for (const changed of [{enabled: false}, {isNew: false},
    {consentId: "b".repeat(64)}, {eventId: "client-submitted"},
    {now: now - 1}, {now: authority.expiresAt},
    {consentDocument: {consent: {analytics: true}}},
    {consentDocument: {...consentDocument, status: "revoked"}},
    {consentDocument: {...consentDocument, authority: {...authority,
      analytics: false}}}]) {
    assert.equal(prepareHostAttribution({...input, ...changed}), null);
  }
});

test("invalid dates, private routes and unlabelled touches stay unassigned",
  () => {
    for (const changed of [
      {capturedAt: new Date(now + 1).toISOString()},
      {capturedAt: new Date(authority.chosenAt - 1).toISOString()},
      {capturedAt: "not-a-date"}, {landingPath: "/"},
      {landingPath: "/host/apply/?email=private"},
      {landingPath: "/claim/private-id"}, {landingPath: "/events/private"},
      {values: {utm_campaign: "private"}},
    ]) {
      const bad = {...touch, ...changed};
      assert.equal(prepareHostAttribution({...input,
        attribution: {firstTouch: bad, lastTouch: bad}}), null);
    }
    assert.equal(prepareHostAttribution({...input, attribution: {
      firstTouch: {...touch, capturedAt: new Date(now).toISOString()},
      lastTouch: touch}}), null);
  });

test("server and schema vocabularies match the reviewed website vocabulary",
  () => {
    const root = path.resolve(__dirname, "../../..");
    const source = ts.createSourceFile("catchMeasurement.ts", fs.readFileSync(
      path.join(root, "website/src/analytics/catchMeasurement.ts"), "utf8"),
    ts.ScriptTarget.Latest, true);
    let labels: Record<string, string[]> | undefined;
    source.forEachChild((node) => {
      if (!ts.isVariableStatement(node)) return;
      for (const declaration of node.declarationList.declarations) {
        if (declaration.name.getText(source) !== "campaignLabels" ||
            !declaration.initializer ||
            !ts.isObjectLiteralExpression(declaration.initializer)) continue;
        labels = {};
        for (const property of declaration.initializer.properties) {
          assert.ok(ts.isPropertyAssignment(property));
          assert.ok(ts.isArrayLiteralExpression(property.initializer));
          labels[property.name.getText(source)] =
            property.initializer.elements.map((element) => {
              assert.ok(ts.isStringLiteral(element)); return element.text;
            });
        }
      }
    });
    assert.deepEqual(hostCampaignLabels, labels);
    const schema = JSON.parse(fs.readFileSync(path.join(root,
      "contracts/firestore/sales_inbound_intents.schema.json"), "utf8"));
    assert.deepEqual(Object.fromEntries(Object.entries(
      schema.definitions.hostAttributionTouch.properties.values.properties)
      .map(([key, value]) => [key, (value as {enum: string[]}).enum])), labels);
  });

test("withdrawal and expiry clear only the matching snapshot, rechecking rows",
  async () => {
    const rows = new Map<string, Record<string, unknown>>([
      ["expired", {fullName: "Keep operational record", acquisitionAttribution:
        {consentId, expiresAt: now - 1}}],
      ["future", {acquisitionAttribution:
        {consentId: "b".repeat(64), expiresAt: now + 1}}],
      ["removed", {}],
    ]);
    const db = {
      collection: (collection: string) => {
        assert.equal(collection, "salesInboundIntents");
        return {where: () => ({limit: (limit: number) => {
          assert.equal(limit, 500);
          return {get: async () => ({docs: [...rows.keys()].map((id) =>
            ({ref: {id}}))})};
        }})};
      },
      runTransaction: async (run: (tx: unknown) => Promise<unknown>) => run({
        get: async ({id}: {id: string}) => ({data: () => rows.get(id)}),
        update: ({id}: {id: string}, patch: Record<string, unknown>) => {
          assert.deepEqual(Object.keys(patch), ["acquisitionAttribution"]);
          assert.ok(patch.acquisitionAttribution instanceof FieldValue);
          delete rows.get(id)!.acquisitionAttribution;
        },
      }),
    } as unknown as Firestore;
    assert.equal(await expireHostAttribution(db, now), 1);
    assert.equal(rows.get("expired")?.fullName, "Keep operational record");
    assert.equal(await withdrawHostAttribution(db, consentId), 0);
    assert.equal(await withdrawHostAttribution(db, "b".repeat(64)), 1);
    assert.equal(await withdrawHostAttribution(db, "invalid"), 0);
  });
