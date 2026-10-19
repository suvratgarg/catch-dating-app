import {productionIndexing} from "../src/server/publicEnvironment";
export const dynamic = "force-dynamic";
import type {MetadataRoute} from "next";
export default function robots(): MetadataRoute.Robots {
  if (!productionIndexing()) return {rules: {userAgent: "*", disallow: "/"}};
  return {rules: {userAgent: "*", allow: "/", disallow: ["/api/", "/_legacy/", "/booking/", "/offer/",
    "/join/", "/event-update/", "/rehearse/", "/invite/", "/rsvp/", "/f/", "/demo/", "/claim/"]},
    sitemap: "https://catchdates.com/sitemap.xml"};
}
