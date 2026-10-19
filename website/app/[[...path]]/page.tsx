import {exploreRouteStateForSearch, exploreDiscoveryHref} from "../../src/features/home/exploreDiscovery";
import {homeRouteStateForSearch} from "../../src/features/home/homeDiscovery";
import {notFound} from "next/navigation";
import {resolvePublicRoute} from "../../src/server/publicRoute";
import {PublicProviders} from "../../src/app/next/PublicProviders";
import {PublicPage} from "../../src/app/next/PublicPage";
export const dynamic = "force-dynamic";
export const runtime = "nodejs";
type Props = {params: Promise<{path?: string[]}>; searchParams: Promise<Record<string, string | string[] | undefined>>};
async function routeFor({params}: Props) {
  const {path = []} = await params;
  const pathname = path.length ? `/${path.map(encodeURIComponent).join("/")}/` : "/";
  return {pathname, ...await resolvePublicRoute(pathname)};
}
export async function generateMetadata(props: Props) {return (await routeFor(props)).metadata;}
export default async function Page(props: Props) {
  const route = await routeFor(props);
  if (route.page === "not_found") notFound();
  const search = await props.searchParams;
  const selected = homeRouteStateForSearch(new URLSearchParams({city: typeof search.city === "string" ? search.city : "", format: typeof search.format === "string" ? search.format : ""}).toString());
  // Only public allowlisted discovery choices enter the initial client state.
  const publicSearch = new URLSearchParams(Object.fromEntries(["city", "format", "q", "when", "experience"].map(key => [key, typeof search[key] === "string" ? search[key] : ""])));
  const initialSearch = route.page === "visitor_discovery"
    ? exploreDiscoveryHref(exploreRouteStateForSearch(publicSearch.toString())).replace("/explore/", "")
    : route.page === "home" ? `?${new URLSearchParams({city: selected.city, format: selected.category})}` : "";
  return <PublicProviders pathname={route.pathname} initialSearch={initialSearch} catalog={route.catalog} live={route.live}>
    <PublicPage page={route.page} readAt={route.catalog.readAt} />
  </PublicProviders>;
}
