import {AlertCircle} from "lucide-react";
import {lazy, Suspense, useState} from "react";
import {GoogleAuthProvider, signInWithPopup} from "firebase/auth";
import {auth, signOutAdmin} from "../shared/api/firebase";
import {useAdminSession} from "./useAdminSession";
import {AdminQueryProvider} from "../shared/query/queryClient";
import {AdminPendingOperationProvider} from "../shared/pendingOperation";
import {AdminButton, AdminFeatureLoadingState, AdminSignInPanel,
  AdminSignInScreen, StatusBanner} from "../shared/ui/AdminPrimitives";
const PartnerWorkspaceScreen = lazy(() => import("../features/partners/ui/PartnerWorkspaceScreen")
  .then((m) => ({default: m.PartnerWorkspaceScreen})));

export function PartnerRouteApp() {
  const session = useAdminSession("live");
  const [error, setError] = useState<string | null>(null);
  const [pending, setPending] = useState(false);
  const signIn = async () => {
    if (pending) return;
    setPending(true); setError(null);
    try {await signInWithPopup(auth, new GoogleAuthProvider());}
    catch (e) {setError(e instanceof Error ? e.message : "Unable to sign in.");}
    finally {setPending(false);}
  };
  if (!session.user || !session.resolved) return <AdminSignInScreen><AdminSignInPanel>
    <h1>Catch referral partners</h1><p>Sign in to nominate organizers and review assigned leads.</p>
    {(error || session.error) && <StatusBanner tone="error" icon={<AlertCircle />}>{error ?? session.error}</StatusBanner>}
    <AdminButton disabled={pending || !!session.user} onClick={() => void signIn()}>Sign in with Google</AdminButton>
  </AdminSignInPanel></AdminSignInScreen>;
  return <AdminQueryProvider sessionKey={`partner:${session.user.uid}:${session.epoch}`} isCurrentSession={session.isCurrent}>
    <AdminPendingOperationProvider><Suspense fallback={<AdminFeatureLoadingState label="Loading partner workspace" />}>
      <PartnerWorkspaceScreen onSignOut={() => {void signOutAdmin();}} />
    </Suspense></AdminPendingOperationProvider>
  </AdminQueryProvider>;
}
