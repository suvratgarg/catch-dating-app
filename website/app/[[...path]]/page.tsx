import {notFound} from "next/navigation";
import {resolvePublicRoute} from "../../src/server/publicRoute";
import {PublicProviders} from "../../src/app/next/PublicProviders";
import {PublicPage} from "../../src/app/next/PublicPage";
export const dynamic = "force-dynamic";
export const runtime = "nodejs";
type Props = {params: Promise<{path?: string[]}>};
async function routeFor({params}: Props) {
  const {path = []} = await params;
  const pathname = path.length ? `/${path.map(encodeURIComponent).join("/")}/` : "/";
  return {pathname, ...await resolvePublicRoute(pathname)};
}
export async function generateMetadata(props: Props) {return (await routeFor(props)).metadata;}
export default async function Page(props: Props) {
  const route = await routeFor(props);
  if (route.page === "not_found") notFound();
  return <PublicProviders pathname={route.pathname} catalog={route.catalog}>
    <PublicPage page={route.page} readAt={route.catalog.readAt} />
  </PublicProviders>;
}
