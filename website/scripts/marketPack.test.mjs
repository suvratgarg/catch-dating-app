import assert from "node:assert/strict";
import test from "node:test";
import {inMarket} from "../src/content/markets/in.ts";

test("India market pack has stable, internally consistent city contracts", () => {
  assert.equal(inMarket.countryCode, "IN");
  assert.equal(inMarket.locale, "en-IN");
  assert.equal(inMarket.currencyCode, "INR");
  assert.deepEqual(inMarket.appStoreCountryCodes, ["IN"]);

  const cityIds = new Set(inMarket.cities.map((city) => city.id));
  const citySlugs = new Set(inMarket.cities.map((city) => city.slug));
  assert.equal(cityIds.size, inMarket.cities.length, "city ids must be unique");
  assert.equal(citySlugs.size, inMarket.cities.length, "city slugs must be unique");

  for (const city of inMarket.cities) {
    assert.match(city.id, /^in-[a-z0-9-]+$/u);
    assert.match(city.slug, /^[a-z0-9-]+$/u);
    assert.doesNotThrow(() =>
      new Intl.DateTimeFormat(inMarket.locale, {timeZone: city.timezone})
    );
  }

  assert.equal(cityIds.has(inMarket.featuredCityId), true);
  assert.equal(cityIds.has(inMarket.exampleEvent.cityId), true);
  assert.equal(inMarket.exampleEvent.currencyCode, inMarket.currencyCode);
  assert.equal(
    inMarket.cities.find((city) => city.id === inMarket.exampleEvent.cityId)?.timezone,
    inMarket.exampleEvent.timezone
  );
  assert.doesNotThrow(() =>
    new Intl.NumberFormat(inMarket.locale, {
      style: "currency",
      currency: inMarket.currencyCode,
    }).format(1200)
  );

  assert.deepEqual(inMarket.cities.filter((city) => city.status === "live").map(
    (city) => city.label
  ), [
    "Mumbai",
    "Indore",
  ]);
  assert.deepEqual(inMarket.cities.filter((city) => city.status === "waitlist").map(
    (city) => city.label
  ), [
    "Delhi",
    "Bangalore",
    "Pune",
    "Hyderabad",
  ]);
  assert.deepEqual(
    [...inMarket.cities.map((city) => city.label), inMarket.otherCityOptionLabel],
    ["Mumbai", "Indore", "Delhi", "Bangalore", "Pune", "Hyderabad", "Other"]
  );
});
