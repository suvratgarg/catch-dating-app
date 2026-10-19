import {PublicProviders} from "../src/app/next/PublicProviders";
import {PublicPage} from "../src/app/next/PublicPage";
export default function NotFound() {
  return <PublicProviders pathname="/404/" catalog={{listings: [], readAt: 0}} live={false}>
    <PublicPage page="not_found" readAt={0} />
  </PublicProviders>;
}
