import {
  createContext,
  type ReactNode,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from "react";

type PendingRequestContextValue = {
  navigationBlocked: boolean;
  registerPendingRequest: () => () => void;
};

const PendingRequestContext = createContext<PendingRequestContextValue>({
  navigationBlocked: false,
  registerPendingRequest: () => () => undefined,
});

export function PendingRequestProvider({children}: {children: ReactNode}) {
  const [activeRequestCount, setActiveRequestCount] = useState(0);
  const registerPendingRequest = useCallback(() => {
    let registered = true;
    setActiveRequestCount((current) => current + 1);
    return () => {
      if (!registered) return;
      registered = false;
      setActiveRequestCount((current) => Math.max(0, current - 1));
    };
  }, []);
  const navigationBlocked = activeRequestCount > 0;

  useEffect(() => {
    if (!navigationBlocked) return undefined;
    const handleBeforeUnload = (event: BeforeUnloadEvent) => {
      event.preventDefault();
      event.returnValue = "";
    };
    window.addEventListener("beforeunload", handleBeforeUnload);
    return () => {
      window.removeEventListener("beforeunload", handleBeforeUnload);
    };
  }, [navigationBlocked]);

  const value = useMemo(
    () => ({navigationBlocked, registerPendingRequest}),
    [navigationBlocked, registerPendingRequest]
  );

  return (
    <PendingRequestContext.Provider value={value}>
      {children}
    </PendingRequestContext.Provider>
  );
}

export function usePendingRequestRegistration(isPending: boolean) {
  const {registerPendingRequest} = useContext(PendingRequestContext);

  useEffect(() => {
    if (!isPending) return undefined;
    return registerPendingRequest();
  }, [isPending, registerPendingRequest]);
}

export function usePendingRequestNavigationBlocked() {
  return useContext(PendingRequestContext).navigationBlocked;
}
