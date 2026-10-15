import {
  Component, lazy, useEffect, useId, useRef,
  type ComponentType, type ReactNode,
} from "react";
import {useLocation, useNavigate} from "react-router";
import {routeRecoveryCopy as copy} from "../content/routeRecovery";
import {usePendingRequestNavigationBlocked} from "../shared/pendingRequest";
import {WebsitePageMain} from "../shared/site";
import {Button, EmptyState} from "../shared/ui/primitives";
import {isCatchWebsiteHost} from "./CustomFormDomainGate";

class RouteChunkLoadError extends Error {
  constructor(readonly recover: (() => boolean) | null) {
    super("Route module unavailable");
  }
}

/** Retry only a loader that never mounted its page, once per route module/session.
 * A fresh lazy type clears React's rejected promise; the recovery loader must
 * use a separate compiled entry to avoid the browser's failed-module cache.
 */
export function recoverableLazy<P extends object>(
  load: () => Promise<{default: ComponentType<P>}>,
  recover: () => Promise<{default: ComponentType<P>}>,
) {
  let recoveryUsed = false;
  const retry = () => {
    if (recoveryUsed) return false;
    recoveryUsed = true;
    LazyPage = lazy(loadRecovery);
    return true;
  };
  const loadRecovery = async () => {
    try { return await recover(); }
    catch { throw new RouteChunkLoadError(null); }
  };
  let LazyPage = lazy(async () => {
    try { return await load(); }
    catch { throw new RouteChunkLoadError(retry); }
  });
  return function RecoverableRoute(props: P) {
    return <LazyPage {...props} />;
  };
}

type BoundaryProps = {
  children: ReactNode;
  resetKey: string;
};
type BoundaryState = {error: RouteChunkLoadError | null; resetKey: string};

class RouteErrorBoundary extends Component<BoundaryProps, BoundaryState> {
  state: BoundaryState = {error: null, resetKey: this.props.resetKey};

  static getDerivedStateFromProps(props: BoundaryProps, state: BoundaryState) {
    return props.resetKey === state.resetKey ? null :
      {error: null, resetKey: props.resetKey};
  }

  static getDerivedStateFromError(error: unknown) {
    // Mounted controller/render errors retain their existing policy. Replacing
    // them with navigation actions could release an in-flight request's lease.
    if (!(error instanceof RouteChunkLoadError)) throw error;
    return {error};
  }

  recover = () => {
    if (this.state.error?.recover?.()) this.setState({error: null});
  };

  render() {
    if (this.state.error === null) return this.props.children;
    const canRecover = this.state.error.recover !== null;
    return <RouteFailure canRecover={canRecover} onRecover={this.recover} />;
  }
}

function RouteFailure({canRecover, onRecover}: {
  canRecover: boolean; onRecover: () => void;
}) {
  const blocked = usePendingRequestNavigationBlocked();
  const navigate = useNavigate();
  const titleId = useId();
  const heading = useRef<HTMLHeadingElement>(null);
  useEffect(() => { heading.current?.focus(); }, []);
  return <WebsitePageMain>
    <section role="alert" aria-labelledby={titleId}>
    <EmptyState variant="public-event">
      <h1 id={titleId} ref={heading} tabIndex={-1}>{copy.title}</h1>
      <p>{canRecover ? copy.body : copy.unavailable}</p>
      {canRecover ? <Button type="button" disabled={blocked}
        onClick={() => { if (!blocked) onRecover(); }}>{copy.retry}</Button> : null}
      {isCatchWebsiteHost(window.location.hostname) ?
        <Button type="button" variant="ghost" disabled={blocked}
          onClick={() => { if (!blocked) void navigate("/"); }}>{copy.home}</Button> : null}
    </EmptyState>
    </section>
  </WebsitePageMain>;
}

/** Kept inside CustomFormDomainGate and PendingRequestProvider. Location changes
 * clear only a failure, without remounting healthy forms or their controllers.
 */
export function RouteChunkRecovery({children}: {children: ReactNode}) {
  const location = useLocation();
  return <RouteErrorBoundary resetKey={location.key}>
    {children}
  </RouteErrorBoundary>;
}
