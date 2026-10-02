import {useCallback, useEffect, useRef, useState} from "react";
import {getIdTokenResult, onIdTokenChanged, type User} from "firebase/auth";
import {auth} from "../shared/api/firebase";
import {adminRoleClaimKeys, type DataMode} from "../shared/types/adminTypes";

interface AdminSession {
  user: User | null;
  roles: string[];
  epoch: number;
  resolved: boolean;
  error: string | null;
}

// Identity and claims are one snapshot: a new user must never inherit the
// previous user's resolved roles. Every token event starts a new cache epoch,
// including a refresh for the same Firebase User object.
export function useAdminSession(mode: DataMode) {
  const epoch = useRef(0);
  const [session, setSession] = useState<AdminSession>({
    user: null, roles: [], epoch: 0, resolved: mode === "sample", error: null,
  });

  const resolveClaims = useCallback(async (user: User | null, force = false) => {
    const currentEpoch = ++epoch.current;
    setSession({user, roles: [], epoch: currentEpoch, resolved: !user, error: null});
    if (!user) return;
    try {
      const token = await getIdTokenResult(user, force);
      if (epoch.current !== currentEpoch) return;
      setSession({
        user,
        roles: adminRoleClaimKeys.filter((claim) => token.claims[claim] === true),
        epoch: currentEpoch,
        resolved: true,
        error: null,
      });
    } catch {
      if (epoch.current !== currentEpoch) return;
      setSession({
        user, roles: [], epoch: currentEpoch, resolved: true,
        error: "Unable to read admin claims for this Firebase session.",
      });
    }
  }, []);

  useEffect(() => {
    if (mode !== "live") return;
    const unsubscribe = onIdTokenChanged(auth, (user) => {
      void resolveClaims(user);
    }, () => {
      void resolveClaims(null);
    });
    return () => {
      ++epoch.current;
      unsubscribe();
    };
  }, [mode, resolveClaims]);

  const refreshClaims = useCallback(() =>
    resolveClaims(session.user, true), [resolveClaims, session.user]);
  const clearSession = useCallback(() => resolveClaims(null), [resolveClaims]);

  const isCurrent = useCallback(() => epoch.current === session.epoch, [session.epoch]);

  return {...session, refreshClaims, clearSession, isCurrent};
}
