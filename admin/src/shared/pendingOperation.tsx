import {
  createContext,
  type MouseEvent as ReactMouseEvent,
  type ReactNode,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "react";

type OperationToken = symbol;

type AdminPendingOperationContextValue = {
  beginOperation: () => OperationToken | null;
  endOperation: (token: OperationToken) => void;
  operationPending: boolean;
};

const AdminPendingOperationContext =
  createContext<AdminPendingOperationContextValue | null>(null);

export function AdminPendingOperationProvider({children}: {children: ReactNode}) {
  const activeOperation = useRef<OperationToken | null>(null);
  const [operationPending, setOperationPending] = useState(false);

  const beginOperation = useCallback(() => {
    if (activeOperation.current) return null;
    const token = Symbol("admin-operation");
    activeOperation.current = token;
    setOperationPending(true);
    return token;
  }, []);

  const endOperation = useCallback((token: OperationToken) => {
    if (activeOperation.current !== token) return;
    activeOperation.current = null;
    setOperationPending(false);
  }, []);

  useEffect(() => {
    if (!operationPending) return undefined;
    const handleBeforeUnload = (event: BeforeUnloadEvent) => {
      event.preventDefault();
      event.returnValue = "";
    };
    window.addEventListener("beforeunload", handleBeforeUnload);
    return () => {
      window.removeEventListener("beforeunload", handleBeforeUnload);
    };
  }, [operationPending]);

  const value = useMemo(
    () => ({beginOperation, endOperation, operationPending}),
    [beginOperation, endOperation, operationPending]
  );

  return (
    <AdminPendingOperationContext.Provider value={value}>
      {children}
    </AdminPendingOperationContext.Provider>
  );
}

export function useAdminPendingOperationGuard() {
  const context = useContext(AdminPendingOperationContext);
  const contextBeginOperation = context?.beginOperation;
  const contextEndOperation = context?.endOperation;
  const localOperation = useRef<OperationToken | null>(null);

  const beginOperation = useCallback(() => {
    if (contextBeginOperation) return contextBeginOperation();
    if (localOperation.current) return null;
    const token = Symbol("local-admin-operation");
    localOperation.current = token;
    return token;
  }, [contextBeginOperation]);

  const endOperation = useCallback((token: OperationToken) => {
    if (contextEndOperation) {
      contextEndOperation(token);
      return;
    }
    if (localOperation.current === token) localOperation.current = null;
  }, [contextEndOperation]);

  return {beginOperation, endOperation};
}

export function useAdminOperationPending() {
  return useContext(AdminPendingOperationContext)?.operationPending ?? false;
}

export function blockPendingAnchorClick(
  event: ReactMouseEvent<HTMLElement>,
  operationPending: boolean
) {
  if (!operationPending) return;
  const target = event.target;
  if (!(target instanceof Element) || !target.closest("a")) return;
  event.preventDefault();
  event.stopPropagation();
}
