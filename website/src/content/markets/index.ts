import {inMarket} from "./in";
import {interpolateContent} from "../interpolate";

export const activeMarket = inMarket;

export const activeEventLiveCities = activeMarket.cities.filter(
  (city) => city.status === "live"
);

export const activeWaitlistCityOptions = [
  ...activeMarket.cities.map((city) => city.label),
  activeMarket.otherCityOptionLabel,
];

export const activeHostApplicationCityOptions = [
  ...activeMarket.cities.map((city) => city.label),
  activeMarket.otherCityOptionLabel,
];

export const activeFeaturedCity = activeMarket.cities.find(
  (city) => city.id === activeMarket.featuredCityId
)!;

const liveCityList = activeEventLiveCities.map((city) => city.label);

export const activeMarketCopy = {
  heroEyebrow: interpolateContent(activeMarket.heroEyebrowTemplate, {
    cities: liveCityList.join(" · ").toLocaleUpperCase(activeMarket.locale),
  }),
  heroTicketLabel: interpolateContent(activeMarket.heroTicketLabelTemplate, {
    city: activeFeaturedCity.label.toLocaleUpperCase(activeMarket.locale),
  }),
  downloadBody: interpolateContent(activeMarket.downloadBodyTemplate, {
    cities: new Intl.ListFormat(activeMarket.locale, {
      style: "long",
      type: "conjunction",
    }).format(liveCityList),
  }),
} as const;
